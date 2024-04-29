--------------------------------------------------------
--  DDL for Package Body PON_AUCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUCTION_PKG" as
/* $Header: PONAUCTB.pls 120.93.12010000.64 2014/10/21 14:18:53 spapana ship $ */

g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.PON_AUCTION_PKG.';
g_userName    varchar2(2000);
g_phoneNumber varchar2(2000);
g_faxNumber   varchar2(2000);
g_eMail       varchar2(2000);
p_t_zone_temp varchar2(20) := '243';
g_module      varchar2(200) := 'pon.plsql.pon_auction_pkg';
g_original_language  FND_LANGUAGES.nls_language%TYPE;
g_original_lang_code FND_LANGUAGES.language_code%TYPE;
g_tp_cache_rec two_part_cache_rec; -- bug 6374353

-------------------------------------------------------------------------------
--------------------------  HELPER FUNCTIONS ----------------------------------
-------------------------------------------------------------------------------

PROCEDURE EMAIL_LIST(p_itemtype      IN  VARCHAR2,
         p_itemkey      IN  VARCHAR2,
            p_actid      IN  NUMBER,
         p_notification_id    OUT NOCOPY NUMBER);

PROCEDURE EMAIL_BIDDERS(p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
               p_actid        IN  NUMBER,
           p_message_name      IN  VARCHAR2,
           p_notification_id    OUT NOCOPY NUMBER);


PROCEDURE SET_PREVIEW_DATE(
          p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
           p_preview_date  IN DATE,
          p_publish_auction_now_flag IN VARCHAR2,
          p_timezone_disp  IN VARCHAR2,
          p_msg_suffix  IN VARCHAR2);

PROCEDURE SET_OPEN_DATE(
          p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
           p_auction_start_date  IN DATE,
          p_open_auction_now_flag IN VARCHAR2,
          p_timezone_disp  IN VARCHAR2,
          p_msg_suffix  IN VARCHAR2);

PROCEDURE SET_CLOSE_DATE(
          p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
           p_auction_end_date  IN DATE,
          p_timezone_disp  IN VARCHAR2);


PROCEDURE ADD_BIDDER_TO_ROLE(p_user_name  VARCHAR2,
           p_role_name  VARCHAR2);


PROCEDURE LAUNCH_NOTIF_PROCESS(p_itemtype    in varchar2,
             p_itemkey    in varchar2,
             p_actid                  IN NUMBER,
             p_process   IN VARCHAR2);

FUNCTION IS_EVENT_AUCTION(p_auction_number IN NUMBER) RETURN VARCHAR2;

FUNCTION getTokenMessage (msg VARCHAR2) RETURN VARCHAR2;

PROCEDURE init_two_part_cache; -- bug 6374353
PROCEDURE update_cache_rec; -- bug 6374353

PO_SUCCESS NUMBER := 1;
DUPLICATE_PO_NUMBER NUMBER := 2;
PO_SYSTEM_ERROR NUMBER := 3;
SOURCING_SYSTEM_ERROR NUMBER := 4;

TYPE MsgTokensType IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
TYPE MsgTokenValuesType IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

MsgTokens MsgTokensType;
MsgTokenValues MsgTokenValuesType;

FUNCTION GET_USER_NAME (p_user_id NUMBER) RETURN VARCHAR2;
--Bug 16666395
FUNCTION GET_VENDOR_SITE_ADDRESS (p_vendor_site_id NUMBER) RETURN VARCHAR2;
FUNCTION MEMBER_USER(p_user_name VARCHAR2) RETURN BOOLEAN;
FUNCTION ADDITIONAL_BIDDER(p_user_name VARCHAR2, p_doc_id int, p_preparer_tp_contact_name varchar2,
x_profile_user IN OUT NOCOPY VARCHAR2) return BOOLEAN;

FUNCTION differentStrings(st1 VARCHAR2, st2 VARCHAR2) return BOOLEAN;

PROCEDURE NOTIFY_MEMBER(p_userPartyId           IN NUMBER,
                        p_auctioneer_user_name  IN VARCHAR2,
                        p_auction_start_date    IN DATE,
                        p_auction_end_date      IN DATE,
                        p_preview_date          IN DATE,
                        p_msg_sent_date         IN DATE,
                        p_msg_suffix            IN VARCHAR2,
                        p_doc_number            IN VARCHAR2,
                        p_auction_title         IN VARCHAR2,
                        p_entryid               IN NUMBER,
                        p_auction_header_id     IN NUMBER,
                        p_fromFirstName         IN VARCHAR2,
                        p_fromLastName          IN VARCHAR2,
                        p_from_id               IN NUMBER,
                        p_notif_performer       IN VARCHAR2,
                        p_subject               IN VARCHAR2,
                        p_content               IN VARCHAR2,
                        p_message_type          IN VARCHAR2,
                        p_fromCompanyName       IN VARCHAR2,
                        p_discussion_id         IN NUMBER,
                        p_stagger_closing_interval IN NUMBER,
                        p_open_auction_now_flag IN VARCHAR2,
                        p_publish_auction_now_flag IN VARCHAR2
                        );

-- Bug 8992789
FUNCTION IS_INTERNAL_ONLY(p_auction_header_id NUMBER) RETURN BOOLEAN;

-- Bug 9309785
FUNCTION GET_SUPPLIER_REG_URL(p_supp_reg_id NUMBER) RETURN VARCHAR2;

-- Bug 10075648
PROCEDURE UPDATE_SUPPLIER_REG_STATUS(p_supp_reg_id IN NUMBER);


-------------------------------------------------------------------------------
--------------------------  PACKAGE BODY --------------------------------------
-------------------------------------------------------------------------------
-- FPK: CPA Function to check if negotiation has lines or not
FUNCTION NEG_HAS_LINES (p_auction_number IN NUMBER) RETURN VARCHAR2 AS
      x_has_items_flag       VARCHAR2(1);
BEGIN
     BEGIN
         select has_items_flag
         into x_has_items_flag
         from pon_auction_headers_all
         where auction_header_id = p_auction_number;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        x_has_items_flag := 'Y';
     END;
         return(x_has_items_flag);
END NEG_HAS_LINES;


PROCEDURE EMAIL_LIST(p_itemtype      IN  VARCHAR2,
         p_itemkey      IN  VARCHAR2,
            p_actid      IN  NUMBER,
         p_notification_id    OUT NOCOPY  NUMBER) IS

x_auction_header_id  NUMBER;
x_open_bidding_date  DATE;
x_close_bidding_date  DATE;
x_original_close_bidding_date DATE;
x_newpreviewtime     DATE;
x_progress     VARCHAR2(3);
x_sequence    NUMBER;
x_itemtype    VARCHAR2(8) := 'PONPBLSH';
x_itemkey    VARCHAR2(50);
x_user_name    VARCHAR2(100);
x_contact_id    NUMBER;
x_timezone    VARCHAR2(80);
x_timezone1    VARCHAR2(80);
x_newstarttime    DATE;
x_newendtime    DATE;
x_startdate    DATE;
x_enddate    DATE;
x_auction_type          Varchar2(30);
x_auction_type_name     Varchar2(30) := '';
x_auctioneer_tag        Varchar2(30);
x_event_id              NUMBER;
x_event_title           VARCHAR2(80);
x_language_code    VARCHAR2(30) := null;
x_auctioneer_user_name  FND_USER.USER_NAME%TYPE;
x_preview_message       VARCHAR2(100);
x_article_doc_type      VARCHAR2(100);

x_doctype_group_name    VARCHAR2(100);
x_msg_suffix     VARCHAR2(3) := '';
x_doc_number_dsp   VARCHAR2(30);
x_auction_contact_id    NUMBER;
x_oex_timezone          VARCHAR2(80);
x_oex_timezone1          VARCHAR2(80);

x_wf_role_name          VARCHAR2(30);
x_app                   VARCHAR2(20);

x_oex_header            VARCHAR2(2000);
x_oex_footer            VARCHAR2(2000);
x_status                VARCHAR2(10);
x_exception_msg         VARCHAR2(100);
x_operation_url   VARCHAR2(300);
x_oex_operation    VARCHAR2(2000);
x_auction_owner_tp_name VARCHAR2(300);
x_tp_display_name  VARCHAR2(300);
x_tp_id      NUMBER;
x_auction_title    VARCHAR2(2000);
x_note_to_new_supplier_type  VARCHAR2(30);
x_appstr                VARCHAR2(20);
x_auction_creator_contact_id  NUMBER;
x_timezone_disp                VARCHAR2(240);
x_timezone1_disp               VARCHAR2(240);
x_oex_timezone1_disp           VARCHAR2(240);
x_registration_key             VARCHAR2(100);
x_neg_summary_url_supplier     VARCHAR2(2000);
x_l_neg_summary_url_supplier     VARCHAR2(2000);
x_net_changes_url_supplier     VARCHAR2(2000);
x_l_net_changes_url_supplier     VARCHAR2(2000);
x_isp_supplier_register_url    VARCHAR2(2000);
x_ack_part_url_supplier        VARCHAR2(2000);
x_amendment_number             NUMBER;
x_isAmendment                  VARCHAR(1) := 'N';
x_auction_round_number                 NUMBER;
x_auction_header_id_encrypted  varchar2(2000);
x_auction_header_id_orig_amend NUMBER;
x_orig_document_number PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
x_preview_date        DATE;
x_preview_date_notspec VARCHAR2(240);
l_origin_user_name             FND_USER.USER_NAME%TYPE;

x_staggered_closing_interval   NUMBER;
x_staggered_close_note         VARCHAR2(1000);
x_exempt_flag                  VARCHAR2(1);

-- bug 8613271
x_supplier_sequence            NUMBER;
x_emd_received_flag         VARCHAR2(1) := 'N';
x_new_round_flag         VARCHAR2(1) := 'N';
x_new_amend_flag         VARCHAR2(1) := 'N';
x_refund_supplier_msg    VARCHAR2(2000);

--SLM UI Enhancement
l_is_slm VARCHAR2(1);
l_slm_neg_doc VARCHAR2(15);

-- Bug 3824928: Removed obsolete columns from the SELECT below

-- Bug 17525991
x_supp_reg_qual_flag    pon_auction_headers_all.supp_reg_qual_flag%TYPE;

CURSOR bidder_list IS
    select pbp.trading_partner_name,
     pbp.trading_partner_id,
     pbp.trading_partner_contact_id,
     pbp.trading_partner_contact_name,
     pbp.additional_contact_email,
     pbp.wf_user_name,
           pbp.registration_id,
           pbp.vendor_site_id,
           decode(pbp.vendor_site_code, '-1', null, pbp.vendor_site_code) vendor_site_code,
           pbp.requested_supplier_id,
           pbp.requested_supplier_name,
           pbp.requested_supplier_contact_id,
           pbp.requested_supp_contact_name,
           pcr.email_address rs_contact_email
-- lxchen
    from pon_bidding_parties pbp,
         pos_contact_requests pcr
    where pbp.auction_header_id = x_auction_header_id and
          pbp.requested_supplier_contact_id = pcr.contact_request_id (+)
    union
    select distinct trading_partner_name,
           trading_partner_id,
           trading_partner_contact_id,
           pon_locale_pkg.get_party_display_name(trading_partner_contact_id) trading_partner_contact_name,
           null additional_contact_email,
           null wf_user_name,
           to_number(null) registration_id,
           vendor_site_id,
           decode(vendor_site_code, '-1', null, vendor_site_code) vendor_site_code,
           null requested_supplier_id,
           null requested_supplier_name,
           null requested_supplier_contact_id,
           null requested_supp_contact_name,
           null rs_contact_email
     from  pon_bid_headers
     where x_isAmendment = 'Y' and
           auction_header_id in (select auction_header_id
                                 from   pon_auction_headers_all
                                 where  auction_header_id_orig_amend = (select auction_header_id_orig_amend
                                                                        from   pon_auction_headers_all
                                                                        where  auction_header_id = x_auction_header_id)) and
           bid_status in ('ACTIVE', 'RESUBMISSION', 'DISQUALIFIED', 'DRAFT') and
           trading_partner_contact_id NOT IN
                       (SELECT nvl(trading_partner_contact_id, -1)
                        FROM   pon_bidding_parties
                        WHERE  auction_header_id = x_auction_header_id)

     AND( EXISTS (SELECT 1 FROM fnd_user fu WHERE
         fu.person_party_id = TRADING_PARTNER_CONTACT_ID
         AND Nvl(fu.end_date,sysdate) >=SYSDATE)

      OR EXISTS (SELECT 1
        FROM hz_parties hp,
            hz_relationships hzr,
            hz_party_usg_assignments hpua,
            hz_contact_points hcpe
        WHERE hp.party_id = hzr.subject_id
          AND hzr.relationship_type = 'CONTACT'
          AND hzr.relationship_code = 'CONTACT_OF'
          AND hzr.subject_type = 'PERSON'
          AND hzr.object_type = 'ORGANIZATION'
          AND hzr.status = 'A'
          AND NVL(hzr.end_date, SYSDATE) >= SYSDATE
          AND hpua.party_id = hp.party_id
          AND hpua.status_flag = 'A'
          AND hpua.party_usage_code = 'SUPPLIER_CONTACT'
          AND NVL(hpua.effective_end_date, SYSDATE) >= SYSDATE
          AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
          AND hcpe.owner_table_id(+) = hzr.party_id
          AND hcpe.contact_point_type(+) = 'EMAIL'
          AND hcpe.primary_flag(+) = 'Y'
          AND NVL(hcpe.status, 'A') = 'A'
          AND hcpe.email_address IS NOT NULL
        AND hp.party_id = TRADING_PARTNER_CONTACT_ID));
CURSOR c1_auction_type IS
    select auction_header_id_orig_amend, nvl(amendment_number,0), nvl(auction_round_number, 1), auction_type,
    event_id, event_title, trading_partner_id,
    trading_partner_contact_id, original_close_bidding_date, trading_partner_contact_name,
    staggered_closing_interval,
    supp_reg_qual_flag
    from pon_auction_headers_all
    where auction_header_id = x_auction_header_id;

BEGIN

    x_progress := '010';

    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                        itemkey  => p_itemkey,
                                                       aname    => 'AUCTION_ID');


    -- Bug 8992789
    IF (IS_INTERNAL_ONLY(x_auction_header_id)) THEN
      RETURN;
    END IF;

    l_origin_user_name := wf_engine.GetItemAttrText   (itemtype => p_itemtype,
                                                        itemkey  => p_itemkey,
                                                       aname    => 'ORIGIN_USER_NAME');

    x_auction_header_id_encrypted := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                         itemkey  => p_itemkey,
                                                         aname    => 'AUCTION_ID_ENCRYPTED');

--    x_auctioneer_user_name := wf_engine.GetItemAttrText (itemtype => p_itemtype,
--                                             itemkey  => p_itemkey,
--                                               aname    => 'PREPARER_TP_CONTACT_NAME');

    x_doctype_group_name := wf_engine.GetItemAttrText   (itemtype => p_itemtype,
                                                         itemkey  => p_itemkey,
                                                        aname    => 'DOC_INTERNAL_NAME');

    x_doc_number_dsp     := wf_engine.GetItemAttrText   (itemtype => p_itemtype,
                                                         itemkey  => p_itemkey,
                                                        aname    => 'DOC_NUMBER');

    x_preview_date := wf_engine.GetItemAttrDate (itemtype   => p_itemtype,
                                                 itemkey    => p_itemkey,
                                                 aname      => 'PREVIEW_DATE');


    x_progress := '020';
    open c1_auction_type;
    fetch c1_auction_type
    into x_auction_header_id_orig_amend,
         x_amendment_number,
         x_auction_round_number,
         x_auction_type,
         x_event_id,
         x_event_title,
   x_tp_id,
   x_auction_creator_contact_id,
         x_original_close_bidding_date,
         x_auctioneer_user_name,
         x_staggered_closing_interval,
         x_supp_reg_qual_flag;
    close c1_auction_type;

    --x_msg_suffix := GET_MESSAGE_SUFFIX (x_doctype_group_name);
    --SLM UI Enhancement :
    x_msg_suffix := PON_SLM_UTIL_PKG.GET_AUCTION_MESSAGE_SUFFIX (x_auction_header_id, x_doctype_group_name);

    if (x_amendment_number > 0) then
       x_isAmendment := 'Y';
    end if;

    --SLM UI Enhancement
    l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(x_auction_header_id);
    l_slm_neg_doc :=  PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE(l_is_slm);

    FOR bidder IN bidder_list LOOP

      --
      -- Get next value in sequence for itemkey
      --

      SELECT pon_auction_wf_publish_s.nextval
      INTO   x_sequence
      FROM   dual;


      x_itemkey := (p_itemkey||'-'||to_char(x_sequence));

      wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'PUBLISH_MAIN');

      --
      -- Set all the item attributes
      --

      x_progress := '022';

      --SLM UI Enhancement
      PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => x_itemtype,
                                                  p_itemkey  => x_itemkey,
                                                  p_value    => l_slm_neg_doc);


      wf_engine.SetItemAttrDate   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'ORIGINAL_AUCTION_CLOSE_DATE',
                                   avalue     => x_original_close_bidding_date);

      wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'AUCTION_ID',
                                   avalue     => x_auction_header_id); /* using auction_id instead of
                                                                         auction_number as a standard
                                                                         across item types */

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_NUMBER',
                                 avalue     => x_doc_number_dsp);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'ORIGIN_USER_NAME',
                                 avalue     => l_origin_user_name);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NOTE_TO_BIDDERS',
                                 avalue     => replaceHtmlChars(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'NOTE_TO_BIDDERS')));

      x_auction_title := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'AUCTION_TITLE');

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_TITLE',
                                 avalue     => replaceHtmlChars(x_auction_title));

      x_auction_owner_tp_name := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'PREPARER_TP_NAME');

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PREPARER_TP_NAME',
                             avalue     => x_auction_owner_tp_name);

      wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'NUMBER_OF_ITEMS',
                             avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                                 itemkey  => p_itemkey,
                                                                aname    => 'NUMBER_OF_ITEMS'));
      wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'TRADING_PARTNER_ID',
                             avalue     => bidder.trading_partner_id);

      wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'DOC_ROUND_NUMBER',
                             avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                                  itemkey  => p_itemkey,
                                                                 aname    => 'DOC_ROUND_NUMBER'));


      wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'DOC_AMENDMENT_NUMBER',
                                                   avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                                              itemkey  => p_itemkey,
                                                                              aname    => 'DOC_AMENDMENT_NUMBER'));

      begin

        wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                         itemkey    => x_itemkey,
                                         aname      => '#WFM_HTMLAGENT',
                                         avalue     => pon_wf_utl_pkg.get_base_external_supplier_url);
      exception when others then
        null;
      end;


      wf_engine.setItemAttrNumber  (itemtype =>  x_itemtype,
                                    itemkey    => x_itemkey,
                                    aname      => 'VENDOR_SITE_ID',
                                    avalue     => bidder.vendor_site_id);


     wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                             itemkey  => x_itemkey,
                             aname  => 'PREPARER_TP_CONTACT_NAME',
                             avalue  => x_auctioneer_user_name);

     BEGIN
          x_staggered_close_note := NULL;
          IF x_staggered_closing_interval IS NOT NULL THEN
               x_staggered_close_note := wf_core.newline || wf_core.newline ||
                                         getMessage('PON_STAGGERED_CLOSE_NOTIF_MSG') ||
                                         wf_core.newline || wf_core.newline;
          END IF;
          wf_engine.SetItemAttrText( itemtype => x_itemtype,
                                     itemkey  => x_itemkey,
                                     aname    => 'STAGGERED_CLOSE_NOTE',
                                     avalue   => x_staggered_close_note);
                                                                                                                                                               EXCEPTION
          WHEN OTHERS THEN
               NULL;
     END;

      begin
        if (x_event_id is not null) then
         wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                    itemkey    => x_itemkey,
                                    aname      => 'EVENT_TITLE',
                              avalue     => replaceHtmlChars(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                                 itemkey  => p_itemkey,
                                                                   aname    => 'EVENT_TITLE')));
  end if;
      exception
   when others then
    null;  -- if event title attr. does not exist in the workflow item then it is an older version
      end;

       x_oex_timezone := Get_Oex_Time_Zone;

         --
         -- Get the dates from the auction workflow
         --

       x_startdate := wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                                                 itemkey  => p_itemkey,
                                                 aname    => 'AUCTION_START_DATE');

       x_enddate   := wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                                                 itemkey  => p_itemkey,
                                                 aname    => 'AUCTION_END_DATE');


          x_progress := '030';

    -- Try and send the notification to the Auction Contact user for the company.
    -- If no such person exists, then just send the noification to the Default
    -- Admin for the company.  Every company should have a Default Admin relationship
    -- and we do not allow users to invite companies that do not have a Defualt Admin
    -- relationship.
    -- FPH: bidder.trading_partner_contact_id should never be null and thus no need
    -- for this if.

    x_auction_contact_id := bidder.trading_partner_contact_id;

     -- Bug 3824928: Contact id may be null.  Added IF below to prevent a
     -- no data found error
     IF x_auction_contact_id IS NOT NULL
     THEN
      BEGIN
    select user_name,
                 person_party_id
    into x_user_name,
               x_contact_id
    from fnd_user
          where person_party_id = x_auction_contact_id
          and nvl(end_date, sysdate+1) > sysdate;
      EXCEPTION
       WHEN TOO_MANY_ROWS THEN
          IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
               IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                         FND_LOG.string(log_level => FND_LOG.level_unexpected,
                                        module    => 'pon.plsql.pon_auction_pkg.email_list',
                                        message   => 'Multiple Users found for person_party_id:'|| x_auction_contact_id);
               END IF;
         END IF;
         select user_name,
                person_party_id
          into x_user_name,
               x_contact_id
          from fnd_user
          where person_party_id = x_auction_contact_id
          and nvl(end_date, sysdate+1) > sysdate
          and rownum=1;

          -- bug#16690631 for surrogate quote enhancement
          WHEN No_Data_Found THEN
          CHECK_NOTIFY_USER_INFO(null,
                        x_auction_contact_id,
                        x_user_name);

      END;


      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                         itemkey  => x_itemkey,
                         aname  => 'BIDDER_TP_CONTACT_NAME',
                         avalue  => x_user_name);

    -- Get the user's time zone
    --
    -- bug#16690631 for surrogate quote enhancement
    begin
    x_timezone := Get_Time_Zone(x_auction_contact_id);
    EXCEPTION
    WHEN OTHERS THEN
    x_timezone:=NULL;
    end;

    if (x_timezone is null or x_timezone = '') then
    x_timezone := x_oex_timezone;
    end if;


    --
      -- Convert the dates to the user's timezone.
    -- If the timezone is not recognized, just use PST
    --

    IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN
       x_newstarttime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_startdate,x_oex_timezone,x_timezone);
       x_newendtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_enddate,x_oex_timezone,x_timezone);
       x_newpreviewtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone);
    ELSE
       x_newstarttime := x_startdate;
       x_newendtime := x_enddate;
         x_newpreviewtime := x_preview_date;
       x_timezone := x_oex_timezone;
      END IF;

    PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_user_name,x_language_code);
   ELSE -- auction_contact_id is null -- Bug 3824928: added this

             --
             -- Get the auctioneer's time zone
             --
             x_timezone := Get_Time_Zone(x_auctioneer_user_name);

             if (x_timezone is null or x_timezone = '') then
                   x_timezone := x_oex_timezone;
             end if;


             --
             -- Convert the dates to the auctioneer's timezone.
             -- If the timezone is not recognized, just use PST
             --

             IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN

                x_newstarttime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_startdate,x_oex_timezone,x_timezone);
                x_newendtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_enddate,x_oex_timezone,x_timezone);
                x_newpreviewtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone);
             ELSE

                x_newstarttime := x_startdate;
                x_newendtime := x_enddate;
                x_newpreviewtime := x_preview_date;
                x_timezone := x_oex_timezone;
            END IF;
         -- Get the auctioneer's language
            PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_auctioneer_user_name,x_language_code);

        -- add requested supplier info if specified
        if (bidder.requested_supplier_contact_id is not null) then --{
        wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'REQ_SUPPLIER_CONTACT_NAME',
                                   avalue   => bidder.requested_supp_contact_NAME);

          wf_engine.SetItemAttrNumber (itemtype => x_itemtype,
                                     itemkey  => x_itemkey,
                                     aname    => 'REQ_SUPPLIER_CONTACT_ID',
                                     avalue   => bidder.requested_supplier_contact_id);

          wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'BIDDER_TP_CONTACT_NAME',
                                   avalue   => bidder.requested_supp_contact_name);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                     itemkey    => x_itemkey,
                                     aname      => 'REQ_SUPPLIER_USERNAME',
                                     avalue   => bidder.wf_user_name); --(performer)

        end if; --} bidder.requested_supplier_contact_id is not null

      END IF; -- IF x_auction_contact_id IS NOT NULL


    --
     --Set the dates based on the user's time zone or auctioneer's time zone if bidder contact id is null
    --

     x_timezone_disp := Get_TimeZone_Description(x_timezone, x_language_code);


    wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                         itemkey  => x_itemkey,
                         aname  => 'TP_TIME_ZONE',
                         avalue  => x_timezone_disp);

          IF (x_preview_date IS NULL) THEN
             x_timezone1_disp := null;
          ELSE
            x_timezone1_disp := x_timezone_disp;
          END IF;

 -- Bug 4304399: Set the values of AUCTION_START_DATE and AUCTION_END_DATE
 -- as the end_date is used to determine the timeout for the notifications
 -- sent to the supplier
          wf_engine.SetItemAttrDate     (itemtype   => x_itemtype,
                                     itemkey    => x_itemkey,
                                   aname      => 'AUCTION_START_DATE',
                                   avalue     => x_startdate);

          wf_engine.SetItemAttrDate     (itemtype   => x_itemtype,
                                     itemkey    => x_itemkey,
                                   aname      => 'AUCTION_END_DATE',
                                   avalue     => x_enddate);

          wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                     itemkey    => x_itemkey,
                                   aname      => 'AUCTION_START_DATE_TZ',
                                   avalue     => x_newstarttime);


          wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                     itemkey    => x_itemkey,
                                   aname      => 'AUCTION_END_DATE_TZ',
                                   avalue     => x_newendtime);

          --
          -- Set the Languague code base on the user's language or auctioneer's language if bidder contact id is null
        --

    wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'TP_LANGUAGE_CODE',
             avalue  => x_language_code);

          -- Set the userenv language so the message token (attribute) values that we retrieve using the
          -- getMessage call return the message in the correct language => x_language_code
     IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
       FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || 'EMAIL_LIST',
          message  => '1. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
     END IF; --}

	  SET_SESSION_LANGUAGE(null, x_language_code);

      --Bug 6472383 : Shifted the setting of preview date to this place so that the recipient's language, instead
      --of the sender's language is taken into account when setting the preview date to 'Not Specified'

      IF (x_newpreviewtime is not null) THEN
            wf_engine.SetItemAttrDate (itemtype    => x_itemtype,
                                                       itemkey        => x_itemkey,
                                                       aname        => 'PREVIEW_DATE_TZ',
                                                       avalue        => x_newpreviewtime);

            wf_engine.SetItemAttrText (itemtype    => x_itemtype,
                                                       itemkey        => x_itemkey,
                                                       aname        => 'TP_TIME_ZONE1',
                                                       avalue        => x_timezone1_disp);

            wf_engine.SetItemAttrText (itemtype    => x_itemtype,
                                                      itemkey        => x_itemkey,
                                                      aname        => 'PREVIEW_DATE_NOTSPECIFIED',
                                                      avalue        => null);
      ELSE
            wf_engine.SetItemAttrDate (itemtype    => x_itemtype,
                                                       itemkey        => x_itemkey,
                                                       aname        => 'PREVIEW_DATE_TZ',
                                                       avalue        => null);

            wf_engine.SetItemAttrText (itemtype    => x_itemtype,
                                                        itemkey        => x_itemkey,
                                                       aname        => 'TP_TIME_ZONE1',
                                                        avalue        => x_timezone1_disp);

           wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                                      itemkey        => x_itemkey,
                                                      aname        => 'PREVIEW_DATE_NOTSPECIFIED',
                                                      avalue        => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));
      END IF;

      --Bug 6268467 : Shifted the operation of setting of the attribute NET_CHANGES_URL to this place (i.e. after call to SET_SESSION_LANGUAGE) so that the
      --logged in user will be able to login to the application in the language that is set in his preferences.
      if (x_amendment_number > 0) then
         -- call to notification utility package to get the redirect page url that
         -- is responsible for getting the Net Changes page url and forward to it.
         x_net_changes_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PONINQ_VIEW_NET_CHNG'
                                 ,p_notif_performer  => 'SUPPLIER');
      elsif (x_auction_round_number > 1 and x_amendment_number = 0) then
         -- call to notification utility package to get the redirect page url that
         -- is responsible for getting the Round Modifications page url and forward to it.
         x_net_changes_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PONINQ_NEW_ROUND_SUM'
                                 ,p_notif_performer  => 'SUPPLIER');
      end if;

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NET_CHANGES_URL',
                                 avalue     => x_net_changes_url_supplier);

      --Bug 6268467 : Shifted the operation of setting of the attribute NEG_SUMMARY_URL to this place (i.e. after call to SET_SESSION_LANGUAGE) so that the
      --logged in user will be able to login to the application in the language that is set in his preferences.

       -- call to notification utility package to get the redirect page url that
       -- is responsible for getting the Negotiation Summary url and forward to it.
       x_neg_summary_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PON_NEG_SUMMARY'
                                 ,p_notif_performer  => 'SUPPLIER');


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NEG_SUMMARY_URL',
                                 avalue     => x_neg_summary_url_supplier);

     --Bug 14572394
      x_l_neg_summary_url_supplier:=   pos_url_pkg.get_external_login_url||'?requestUrl='||wfa_html.conv_special_url_chars(x_neg_summary_url_supplier);
      x_l_neg_summary_url_supplier:=  regexp_replace(x_l_neg_summary_url_supplier ,'notificationId%3D%26%23NID', 'notificationId%3D&#NID');
      x_l_net_changes_url_supplier:=   pos_url_pkg.get_external_login_url||'?requestUrl='||wfa_html.conv_special_url_chars(x_net_changes_url_supplier);
      x_l_net_changes_url_supplier:=  regexp_replace(x_l_net_changes_url_supplier ,'notificationId%3D%26%23NID', 'notificationId%3D&#NID');

     IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS  NULL ) THEN
             wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_TB',
                                         avalue      => null);
            wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_HB',
                                         avalue      => null);
			 wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_NEWRND_DTLS_TB',
                                         avalue      => null);
            wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_NEWRND_DTLS_HB',
                                         avalue      => null);
			 wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_AMEND_DTLS_TB',
                                         avalue      => null);
            wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_AMEND_DTLS_HB',
                                         avalue      => null);
     ELSE
             wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_URL',
                                     avalue => x_l_neg_summary_url_supplier);

			wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'LOGIN_VIEW_NET_CHANGES_URL',
                                 avalue     => x_l_net_changes_url_supplier);
    END IF;

      --Bug 6268467 : Shifted the operation of setting of the attribute ACK_PARTICIPATION_URL to this place (i.e. after call to SET_SESSION_LANGUAGE) so that the
      --logged in user will be able to login to the application in the language that is set in his preferences.

       -- call to notification utility package to get the redirect page url that
       -- is responsible for getting the Acknowledge participation url and forward to it.
       x_ack_part_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PONRESAPN_ACKPARTICIPATN'
                                 ,p_notif_performer  => 'SUPPLIER');

       wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'ACK_PARTICIPATION_URL',
                                 avalue     => x_ack_part_url_supplier);


      x_tp_display_name := nvl(bidder.trading_partner_name, bidder.requested_supplier_name);

      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
        itemkey  => x_itemkey,
        aname   => 'TP_DISPLAY_NAME',
        avalue  => x_tp_display_name);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                        itemkey    => x_itemkey,
                                        aname      => 'BIDDER_TP_NAME',
                                        avalue     => x_tp_display_name);

     --Bug 16666395 modified from vendor_site_code to address
      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
        itemkey  => x_itemkey,
        aname      => 'BIDDER_TP_ADDRESS_NAME',
        avalue     => GET_VENDOR_SITE_ADDRESS(bidder.vendor_site_id));


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'DOC_INTERNAL_NAME',
                               avalue     => x_doctype_group_name);


      -- New messages for complete customization

      select document_number
      into   x_orig_document_number
      from   pon_auction_headers_all
      where  auction_header_id = x_auction_header_id_orig_amend;


      wf_engine.SetItemAttrText (itemtype       => x_itemtype,
                                 itemkey        => x_itemkey,
                                 aname          => 'AMENDMENT_START_SUB',
                                 avalue         => getMessage('PON_AUC_WF_PUB_AMEND_RG_S', x_msg_suffix,
                                                                      'AMENDMENT_NUMBER', x_amendment_number,
                                                                      'ORIG_NUMBER', x_orig_document_number,
                                          'AUCTION_TITLE', replaceHtmlChars(x_auction_title)));


      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
         itemkey  => x_itemkey,
         aname    => 'INVITE_NEW_ROUND_START_SUB',
         avalue    => getMessage('PON_AUC_WF_PUB_NEWRND_RG_S', x_msg_suffix,
                            'DOC_NUMBER', x_doc_number_dsp,
                                          'AUCTION_TITLE', replaceHtmlChars(x_auction_title)));

      -- Begin Bug 9309785
      -- Use a different subject for Supplier Hub
      -- Bug 17525991
      -- Use different subject only for Supplier Registration and Pre-Qualification RFI
      IF (x_supp_reg_qual_flag = 'Y' AND bidder.requested_supplier_id IS NOT NULL) THEN
        wf_engine.SetItemAttrText (itemtype       => x_itemtype,
                                   itemkey        => x_itemkey,
                                   aname          => 'INVITE_RESPONSE_SUB',
                                   avalue         => getMessage('PON_SM_AUC_WF_PUB_OPEN_RG_S'));

        wf_engine.SetItemAttrText (itemtype       => x_itemtype,
                                   itemkey        => x_itemkey,
                                   aname          => 'ISP_NEW_SUPPLIER_REG_URL',
                                   avalue         => get_supplier_reg_url(bidder.requested_supplier_id));

        -- Begin Supplier Management: Bug 10378806 / 11071755
        -- RFI amendment / new round e-mail for prospective supplier
        wf_engine.SetItemAttrText (itemtype       => x_itemtype,
                                   itemkey        => x_itemkey,
                                   aname          => 'REQ_SUPP_AMEND_START_SUB',
                                   avalue         => getMessage('PON_SM_REQ_SUPP_AMEND_S'));

        wf_engine.SetItemAttrText (itemtype       => x_itemtype,
                                   itemkey        => x_itemkey,
                                   aname          => 'INV_REQ_SUPP_NEWRND_SUB',
                                   avalue         => getMessage('PON_SM_INV_REQ_SUPP_NEWRND_S'));
        -- End Supplier Management: Bug 10378806 / 11071755

        -- Bug 10075648
        -- Update supplier registration status to 'Supplier to Provide Details' when sending notification.
        update_supplier_reg_status(bidder.requested_supplier_id);
      ELSE
        wf_engine.SetItemAttrText (itemtype       => x_itemtype,
                                   itemkey        => x_itemkey,
                                   aname          => 'INVITE_RESPONSE_SUB',
                                   avalue         => getMessage('PON_AUC_WF_PUB_OPEN_RG_S', x_msg_suffix,
                                                                'DOC_NUMBER', x_doc_number_dsp,
                                                                'AUCTION_TITLE', replaceHtmlChars(x_auction_title)));
      END IF;
      -- End Bug 9309785


      --
      -- Start the publish notification
      --

      -- IF (bidder.additional_contact_email is not null) then we need to send a notification
      -- to the additional contact as well
      -- Populate the ADDITIONAL_CONTACT_USERNAME attribute so that a notification is sent to this local
      -- use as well
      -- In FPH, we provide a registration link to the additional contact.

      if (bidder.additional_contact_email is not null) then

        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                    itemkey    => x_itemkey,
                                    aname      => 'ADDITIONAL_CONTACT_USERNAME',
                           avalue    => bidder.wf_user_name);


              begin
                select registration_key
                  into x_registration_key
                  from fnd_registrations
                 where registration_id  = bidder.registration_id;
              exception
                  WHEN NO_DATA_FOUND THEN
                       x_registration_key := '';
              end;

           -- call to notification utility package to get the iSupplier registration page url
           x_isp_supplier_register_url := pon_wf_utl_pkg.get_isp_supplier_register_url(p_registration_key => x_registration_key
                                                                                      ,p_language_code => x_language_code);

           wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                      itemkey    => x_itemkey,
                                      aname      => 'ISP_SUPPLIER_REG_URL',
                                      avalue     => x_isp_supplier_register_url);

      end if;
      --choli for SUPPLIER_EXEMPTED_INFO
 BEGIN
   select exempt_flag
     into x_exempt_flag
     from pon_bidding_parties b
    where auction_header_id = x_auction_header_id
      and trading_partner_id = bidder.trading_partner_id
      and rownum = 1;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_exempt_flag := 'N';
   WHEN OTHERS THEN
     x_exempt_flag := 'N';
 END;
 IF(x_exempt_flag = 'Y') THEN
 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'SUPPLIER_EXEMPTED_INFO',
                                 avalue     => 'You are exempted from paying the EMD/Bank Guarantee for this Negotiation');
ELSE
 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'SUPPLIER_EXEMPTED_INFO',
                                 avalue     => ' ');
END IF;

    /*
    * Added below code for bug 8613271
    * When a new round or amendment is created,
    * notification sent to suppliers should include message
    * that EMD paid earlier will be refunded.
    */
    BEGIN

    -- determine whether new round or new amendment.
    SELECT Decode(Nvl(auction_header_id_prev_round,0),0,'N','Y'),
           Decode(Nvl(auction_header_id_prev_amend,0),0,'N','Y')
    INTO x_new_round_flag, x_new_amend_flag
    FROM pon_auction_headers_all
    WHERE auction_header_id = x_auction_header_id;

    IF(x_new_round_flag = 'Y') THEN
      x_refund_supplier_msg :=  getMessage('PON_EMD_REFUND_SUP_NEW_RND');
    ELSIF(x_new_amend_flag = 'Y') THEN
      x_refund_supplier_msg :=  getMessage('PON_EMD_REFUND_SUP_NEW_AMEND');
    END IF;

    SELECT sequence INTO x_supplier_sequence FROM pon_bidding_parties
    WHERE auction_header_id = (SELECT Decode(Nvl(auction_header_id_prev_round,0),0,Nvl(auction_header_id_prev_amend,0),auction_header_id_prev_round)
    FROM pon_auction_headers_all
    WHERE auction_header_id = x_auction_header_id)
    --x_auction_header_id_orig_amend
    AND TRADING_PARTNER_ID = bidder.trading_partner_id
    AND vendor_site_id = bidder.vendor_site_id;


    SELECT 'Y' INTO x_emd_received_flag FROM pon_emd_transactions
    WHERE auction_header_id = (SELECT Decode(Nvl(auction_header_id_prev_round,0),0,Nvl(auction_header_id_prev_amend,0),auction_header_id_prev_round)
    FROM pon_auction_headers_all
    WHERE auction_header_id = x_auction_header_id)
    AND SUPPLIER_SEQUENCE = x_supplier_sequence
     AND STATUS_LOOKUP_CODE = 'RECEIVED';

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'REFUND_SUPPLIER',
                                 avalue     => x_refund_supplier_msg);
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    -- end of change for bug 8613271

        --Bug 8446265 Modifications
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_AMENDMENT_START_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_AUC_AMEND_BODY/'||x_itemtype ||':' ||x_itemkey
                               );

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_NEW_RND_START_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INV_NEWRND_START_BODY/'||x_itemtype ||':' ||x_itemkey
                               );


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_NEW_RND_START_AD_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INV_NEWRND_START_AD_BODY/'||x_itemtype ||':' ||x_itemkey
                               );


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INVITE_REQ_SUPP_RESP_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INVITE_REQ_SUPP_RESP_BODY/'||x_itemtype ||':' ||x_itemkey
                               );


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INVITE_RESPONSE_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INVITE_CONT_RESP_BODY/'||x_itemtype ||':' ||x_itemkey
                               );


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_RESP_ADD_CONT_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INVITE_ADD_CONT_RESP_BODY/'||x_itemtype ||':' ||x_itemkey
                               );
    --Bug 8446265 Modifications

    -- Begin Supplier Management: Bug 10378806 / 11071755
    -- RFI amendment / new round e-mail for prospective supplier
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_REQ_SUPP_AMEND_START_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_REQ_SUPP_AUC_AMEND_BODY/'||x_itemtype ||':' ||x_itemkey
                               );

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_REQ_SUPP_NEWRND_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INV_REQ_SUPP_NEWRND_BODY/'||x_itemtype ||':' ||x_itemkey
                               );
    -- End Supplier Management: Bug 10378806 / 11071755
	-- Amendment,New Round email for Prospective supplier : Bug 18097527
	wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_PROSP_SUPP_AMEND_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_AUC_AMEND_BODY_PROSP_SUPP/'||x_itemtype ||':' ||x_itemkey
                               );

	wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_PROSP_SUPP_NEW_ROUND',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INV_NEWRND_BODY_PROSP_SUPP/'||x_itemtype ||':' ||x_itemkey
                               );

    -- Bug 4295915: Set the  workflow owner
      wf_engine.SetItemOwner(itemtype => x_itemtype,
                             itemkey  => x_itemkey,
                             owner    => fnd_global.user_name);

      wf_engine.StartProcess(itemtype => x_itemtype,
                             itemkey  => x_itemkey );

      update pon_bidding_parties
         set wf_item_key = x_itemkey
      where  auction_header_id = x_auction_header_id and
             ((trading_partner_id = bidder.trading_partner_id and
               vendor_site_id = bidder.vendor_site_id) or
               requested_supplier_id = bidder.requested_supplier_id);

   END LOOP;

   UNSET_SESSION_LANGUAGE;

END;

-- choli update for emd
PROCEDURE NotifyEmdAdminNegCancel(p_auction_header_id           NUMBER,    --  2
                p_emd_admin_name         VARCHAR2,  --  3
                p_auction_tp_name            VARCHAR2,  --  4
                p_auction_title               VARCHAR2,  --  5
                x_doc_number_dsp    VARCHAR2,
                x_cancel_date       DATE,
                x_cancel_reason    VARCHAR2,
                x_event_title      VARCHAR2,
                x_start_date       DATE) IS



x_number_awarded  NUMBER;
x_number_rejected  NUMBER;
x_sequence  NUMBER;
x_itemtype  VARCHAR2(8) := 'PONAUCT';
x_itemkey  VARCHAR2(50);
x_bid_list  VARCHAR2(1);
x_progress  VARCHAR2(3);
x_bid_contact_tp_dp_name varchar2(240);
x_auction_type varchar2(30);
x_auction_type_name varchar2(30) := '';

x_event_id          NUMBER;
x_auction_open_bidding_date DATE;
x_auction_close_bidding_date DATE;
x_language_code VARCHAR2(30) := null;
x_timezone  VARCHAR2(80);
x_newstarttime  DATE;
x_newendtime  DATE;
x_newawardtime  DATE;
x_doctype_group_name   VARCHAR2(60);
x_msg_suffix     VARCHAR2(3) := '';

x_auction_round_number    NUMBER;
x_doctype_id_value    NUMBER;
x_oex_timezone VARCHAR2(80);
x_bidder_contact_id   NUMBER;
x_timezone_disp VARCHAR2(240);
x_bid           VARCHAR2(10);
x_bid_caps      VARCHAR2(10);
x_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE;
x_view_quote_url_supplier VARCHAR2(2000);
x_award_date PON_AUCTION_HEADERS_ALL.AWARD_DATE%TYPE;
x_trading_partner_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
x_tp_display_name PON_BID_HEADERS.TRADING_PARTNER_NAME%TYPE;
x_tp_address_name PON_BID_HEADERS.VENDOR_SITE_CODE%TYPE;
x_preview_date             DATE;
x_preview_date_in_tz             DATE;
x_timezone1_disp                VARCHAR2(240);
x_has_items_flag                PON_AUCTION_HEADERS_ALL.HAS_ITEMS_FLAG%TYPE;
x_staggered_closing_interval    NUMBER;
x_staggered_close_note          VARCHAR2(1000);
x_bid_award_status PON_BID_HEADERS.AWARD_STATUS%TYPE;



BEGIN

    IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_auction_pkg.NotifyEmdAdminNegCancel'
                      ,message   => 'Start calling NotifyEmdAdminNegCancel');
      END IF;
    x_progress := '010';

    --
    -- Get the bidder's language code so that the c1_bid_info
    -- has right value for x_language_code
    --
    IF p_emd_admin_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_emd_admin_name,x_language_code);
    END IF;

    -- Set the userenv language so the message token (attribute) values that we retrieve using the
    -- getMessage call return the message in the correct language => x_language_code


    pon_auction_pkg.SET_SESSION_LANGUAGE(null, x_language_code);

    --
    -- Get next value in sequence for itemkey
    --

    SELECT pon_auction_wf_acbid_s.nextval
    INTO   x_sequence
    FROM   dual;

    --
    -- get the contact name and auction type
    --


    x_progress := '020';



    x_itemkey := (to_char(p_emd_admin_name)||'-'||to_char(x_sequence));

    x_progress := '022';

    --
    -- Create the wf process
    --

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'NOTIFY_EMD_NOG_CANCEL');

    --
    -- Set all the item attributes
    --
    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_ID',
                                 avalue     => p_auction_header_id);
    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_NUMBER',
                                 avalue     => p_auction_header_id);
	      /* Setting the Company header attribute */
    wf_engine.SetItemAttrText(itemtype   => x_itemtype
                             ,itemkey    => x_itemkey
                             ,aname      => 'AUCTION_TP_NAME'
	                         ,avalue     => p_auction_tp_name);
    wf_engine.SetItemAttrDate(itemtype   => x_itemtype
                             ,itemkey    => x_itemkey
                             ,aname      => 'AUCTION_END_DATE'
	                         ,avalue     => x_cancel_date);
    wf_engine.SetItemAttrText(itemtype   => x_itemtype
                             ,itemkey    => x_itemkey
                             ,aname      => 'CANCEL_REASON'
	                         ,avalue     => x_cancel_reason);
    wf_engine.SetItemAttrText(itemtype   => x_itemtype
                             ,itemkey    => x_itemkey
                             ,aname      => 'EVENT_TITLE'
	                         ,avalue     => x_event_title);
    wf_engine.SetItemAttrDate(itemtype   => x_itemtype
                             ,itemkey    => x_itemkey
                             ,aname      => 'AUCTION_START_DATE'
	                         ,avalue     => x_start_date);
              /* Setting the negotiation title header attribute */
    wf_engine.SetItemAttrText(itemtype   => x_itemtype
	                         ,itemkey    => x_itemkey
                             ,aname      => 'AUCTION_TITLE'
                             ,avalue     =>  pon_auction_pkg.replaceHtmlChars(p_auction_title));
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_TYPE_NAME',
                               avalue     => x_auction_type_name);

    wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'EMD_ADMIN_NAME',
                                 avalue     => p_emd_admin_name);
        -- Bug 4295915: Set the  workflow owner

    wf_engine.SetItemAttrText  (itemtype    => x_itemtype,
                             itemkey    => x_itemkey,
                             aname      => 'ORIGIN_USER_NAME',
                             avalue     => fnd_global.user_name);

    wf_engine.SetItemOwner(itemtype => x_itemtype,
                           itemkey  => x_itemkey,
                           owner    => fnd_global.user_name);


    --
    -- Start the workflow
    --

    wf_engine.StartProcess(itemtype => x_itemtype,
                           itemkey  => x_itemkey );
    pon_auction_pkg.UNSET_SESSION_LANGUAGE;

    x_progress := '029';
        IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_auction_pkg.NotifyEmdAdminNegCancel'
                      ,message   => 'End calling NotifyEmdAdminNegCancel');
      END IF;

END;


-- choli update for emd
PROCEDURE email_emd_admins(p_auction_header_id IN NUMBER) IS

x_cancel_reason PON_ACTION_HISTORY.ACTION_NOTE%TYPE := '';
x_cancel_date   PON_AUCTION_HEADERS_ALL.CANCEL_DATE%TYPE;
x_event_title   PON_AUCTION_HEADERS_ALL.Event_Title%TYPE;
x_start_date    PON_AUCTION_HEADERS_ALL.PUBLISH_DATE%TYPE;
x_emd_admin_name fnd_user.user_name%TYPE;
x_auction_tp_name PON_AUCTION_HEADERS_ALL.trading_partner_name%TYPE;
x_doc_number_dsp  PON_AUCTION_HEADERS_ALL.document_number%TYPE;
x_auction_title   PON_AUCTION_HEADERS_ALL.auction_title%TYPE;
CURSOR all_emdAdmins(p_auction_header_id NUMBER) IS
       select u.user_name,
              a.trading_partner_name,
              a.auction_title,
              a.document_number, a.cancel_date, a.event_title, a.publish_date
         from pon_neg_team_members b, pon_auction_headers_all a, fnd_user u
        where b.menu_name = 'EMD_ADMIN'
          and b.approver_flag = 'Y'
          and a.auction_header_id = b.auction_header_id
          and u.user_id = b.user_id
          and a.auction_header_id = p_auction_header_id;

BEGIN
    IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_auction_pkg.email_emd_admins'
                      ,message   => 'Start calling email_emd_admins');
      END IF;
  BEGIN
    select action_note
      into x_cancel_reason
      from pon_action_history
     where object_id = p_auction_header_id
       and object_type_code = 'PON_AUCTION'
       and action_type = 'CANCEL' and rownum=1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_cancel_reason := '';
  END;

       open all_emdAdmins(p_auction_header_id);
       loop
            fetch all_emdAdmins
             into x_emd_admin_name,
                  x_auction_tp_name,
                  x_auction_title,
                  x_doc_number_dsp,
                  x_cancel_date,
                  x_event_title,
                  x_start_date;
            exit when all_emdAdmins%notfound;



            NotifyEmdAdminNegCancel(p_auction_header_id,
                                      x_emd_admin_name,
                                      x_auction_tp_name,
                                      x_auction_title,
                                      x_doc_number_dsp,
                                      x_cancel_date,
                                      x_cancel_reason,
                                      x_event_title,
                                      x_start_date);
       end loop;
       close all_emdAdmins;
    IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_auction_pkg.email_emd_admins'
                      ,message   => 'End calling email_emd_admins');
      END IF;

END;


PROCEDURE EMAIL_BIDDERS(p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
               p_actid        IN  NUMBER,
           p_message_name      IN  VARCHAR2,
           p_notification_id    OUT NOCOPY NUMBER) IS

x_auction_header_id  NUMBER;
x_progress     VARCHAR2(3);
x_trading_partner_contact_id pon_bid_headers.trading_partner_contact_id%TYPE;
l_tp_contact_user_name   wf_users.name%TYPE;

CURSOR bidder_list IS
    select trading_partner_contact_name,trading_partner_contact_id
    from pon_bid_headers
    where auction_header_id = x_auction_header_id;

BEGIN

    x_progress := '010';

    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                        itemkey  => p_itemkey,
                                                       aname    => 'AUCTION_ID');

    x_progress := '020';

    FOR bidder IN bidder_list LOOP

       x_progress := '030';

          wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                                  itemkey    => p_itemkey,
                                    aname      => 'BIDDER_DISPLAY_NAME',
                                     avalue     => bidder.trading_partner_contact_name);
     -- bug#16690631 for surrogate quote enhancement

    CHECK_NOTIFY_USER_INFO(bidder.trading_partner_contact_name,
                        bidder.trading_partner_contact_id,
                        l_tp_contact_user_name);

    p_notification_id := WF_NOTIFICATION.send(role   => l_tp_contact_user_name,
                 context  => p_itemtype||':'||p_itemkey||':'||to_char(p_actid),
                       msg_type   => 'PONAUCT',
                msg_name   => p_message_name);
   END LOOP;


END;

PROCEDURE START_AUCTION(p_auction_header_id_encrypted   VARCHAR2,   --  1
                        p_auction_header_id            NUMBER,    --  2
                  p_trading_partner_contact_name  VARCHAR2,  --  3
                      p_trading_partner_contact_id  NUMBER,    --  4
                    p_trading_partner_name        VARCHAR2,  --  5
                      p_trading_partner_id        NUMBER,    --  6
                     p_open_bidding_date            DATE,    --  7
                    p_close_bidding_date        DATE,    --  8
                  p_award_by_date                 DATE,       --  9
                  p_reminder_date              DATE,    -- 10
                  p_bid_list_type              VARCHAR2,  -- 11
                     p_note_to_bidders            VARCHAR2,  -- 12
                  p_number_of_items            NUMBER,    -- 13
                  p_auction_title              VARCHAR2,  -- 14
                        p_event_id                      NUMBER) IS   -- 15



x_sequence  NUMBER;
x_itemtype  VARCHAR2(7) := 'PONAUCT';
x_itemkey  VARCHAR2(50);
x_bid_list  VARCHAR2(1);
x_progress  VARCHAR2(3);
x_new_bidders_flag  VARCHAR2(1) := 'N';
x_timezone  VARCHAR2(80);
x_newstarttime  DATE;
x_newendtime  DATE;
x_preparer_contact_dp_name varchar2(240);
x_event_title   varchar2(80);
x_notification_date DATE;
x_language_code VARCHAR2(30) := null;
x_reminder_date DATE;
x_auction_round_number NUMBER;
x_amendment_number NUMBER;
x_auction_header_id_orig_amend NUMBER;
x_preview_date DATE;
x_difference NUMBER;

x_doctype_group_name VARCHAR2(60);
x_doc_number_dsp     PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
x_neg_summary_url_buyer       VARCHAR2(2000);
x_net_changes_url_buyer       VARCHAR2(2000);
x_msg_suffix VARCHAR2(3);

x_oex_timezone VARCHAR2(80);

x_timezone_disp VARCHAR2(240);
x_doctype_display_name  VARCHAR2(10);
x_notif_subject VARCHAR2(300);
x_orig_document_number PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;

x_timezone1    VARCHAR2(80); -- preview timezone
x_newpreviewtime  DATE;
x_timezone1_disp        VARCHAR2(240);

x_return_status   VARCHAR2(20);
x_msg_count       NUMBER;
x_msg_data         VARCHAR2(2000);

--SLM UI Enhancement
l_is_slm VARCHAR2(1);
l_slm_doc_type VARCHAR2(15);

CURSOR c1_auction_info(x_lang VARCHAR2) IS
    select document_number, auction_header_id_orig_amend, dt.doctype_group_name,
           nvl(auction_round_number, 1), nvl(amendment_number, 0),
     hz.person_first_name || ' ' ||  hz.person_last_name,
       decode(sign(close_bidding_date - nvl(view_by_date, open_bidding_date) - 7), 1, nvl(view_by_date, open_bidding_date)+3,
                  decode(sign(close_bidding_date - nvl(view_by_date, open_bidding_date) - 1), 1, nvl(view_by_date, open_bidding_date) + 1,
                  nvl(view_by_date, open_bidding_date) + 1/24)) reminder_time
    from pon_auction_headers_all auh, hz_parties hz, pon_auc_doctypes dt
    where hz.party_id = auh.trading_partner_contact_id
    and auh.doctype_id = dt.doctype_id
    and auction_header_id = p_auction_header_id;
BEGIN

    --
    -- Get the auctioneer's language code so that the c1_auction_info
    -- has right value for x_language_code
    --
    IF p_trading_partner_contact_name is not null THEN
      PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_trading_partner_contact_name,x_language_code);
    END IF;

    x_progress := '010';

    --
    -- Get next value in sequence for itemkey
    --
    SELECT pon_auction_wf_s.nextval
    INTO   x_sequence
    FROM   dual;
    -- get the contact name and auction type
    -- to fix bug 2797825, overwritting reminder_date, which is null up to
    -- this point
    open c1_auction_info(x_language_code);
    fetch c1_auction_info
    into x_doc_number_dsp, x_auction_header_id_orig_amend, x_doctype_group_name, x_auction_round_number, x_amendment_number, x_preparer_contact_dp_name, x_reminder_date;

    x_progress := '020';

    x_itemkey := (to_char(p_auction_header_id)||'-'||to_char(x_sequence));


    --SLM UI Enhancement
    l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id);
    l_slm_doc_type := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE(l_is_slm);

    --
    -- Create the wf process
    --

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'AUCTION_ENGINE');


    -- Set the userenv language so the message token (attribute) values that we retrieve using the
    -- getMessage call return the message in the correct language => x_language_code
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
       FND_LOG.string(log_level => FND_LOG.level_statement,
         module => g_module_prefix || 'START_AUCTION',
         message  => '2. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
    END IF; --}

    SET_SESSION_LANGUAGE(null, x_language_code);


    --
    -- Set all the item attributes
    --

    x_progress := '022';

    --SLM UI Enhancement
    PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => x_itemtype,
                                                p_itemkey  => x_itemkey,
                                                p_value    => l_slm_doc_type);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_REMINDER_DATE',
                               avalue     => x_reminder_date);

    wf_engine.SetItemAttrText(itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'AUCTION_ID_ENCRYPTED',
                              avalue     => p_auction_header_id_encrypted);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_ID',
                               avalue     => p_auction_header_id);


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ORIGIN_USER_NAME',
                               avalue     => fnd_global.user_name);


    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PREPARER_TP_CONTACT_ID',
                               avalue     => p_trading_partner_contact_id);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PREPARER_TP_ID',
                               avalue     => p_trading_partner_id);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_START_DATE',
                               avalue     => p_open_bidding_date);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_END_DATE',
                               avalue     => p_close_bidding_date);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_AWARD_DATE',
                               avalue     => p_award_by_date);


   select nvl(view_by_date,open_bidding_date)
   into x_notification_date
   from pon_auction_headers_all where auction_header_id = p_auction_header_id;

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_NOTIFICATION_DATE',
                               avalue     => x_notification_date);

    IF (p_bid_list_type IS NULL) THEN
  x_bid_list := 'N';
    ELSE
  x_bid_list := 'Y';
    END IF;

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_LIST_FLAG',
                               avalue     => x_bid_list);

    IF(x_bid_list = 'Y') THEN
  BEGIN
          select 'Y' into x_new_bidders_flag from pon_bidding_parties
          where auction_header_id = p_auction_header_id
          and trading_partner_id is null group by auction_header_id;
  EXCEPTION
         WHEN NO_DATA_FOUND THEN
      x_new_bidders_flag := 'N';
    END;

    END IF;

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'NEW_BIDDERS_FLAG',
                               avalue     => x_new_bidders_flag);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'NOTE_TO_BIDDERS',
                               avalue     => replaceHtmlChars(p_note_to_bidders));

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'NUMBER_OF_ITEMS',
                               avalue     => p_number_of_items);

    -- call to notification utility package to set the message header common attributes and #from_role
    pon_wf_utl_pkg.set_hdr_attributes (p_itemtype        => x_itemtype
                                  ,p_itemkey        => x_itemkey
                                      ,p_auction_tp_name  => p_trading_partner_name
                                    ,p_auction_title    => p_auction_title
                                    ,p_document_number  => x_doc_number_dsp
                                      ,p_auction_tp_contact_name => p_trading_partner_contact_name
                                      );

    -- added the contact display name
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PREPARER_CONTACT_DP_NAME',
                               avalue     => x_preparer_contact_dp_name);


    -- 000001

   select view_by_date
   into x_preview_date
   from pon_auction_headers_all where auction_header_id = p_auction_header_id;

   if ((x_preview_date is not null) AND (p_open_bidding_date is not null)) then
      x_difference := p_open_bidding_date - x_preview_date;
   else
      x_difference := 0;
   end if;

   wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'PREVIEW_DATE',
                              avalue     => x_preview_date);

    --
    -- Get the exchange's time zone
    --

         x_oex_timezone := Get_Oex_Time_Zone;

    --
    -- Get the user's time zone
    --
  x_timezone := Get_Time_Zone(p_trading_partner_contact_id);

    --
    -- Make sure that it is a valid time zone
    --

    IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 0) THEN
  x_timezone := x_oex_timezone;
    END IF;

    --
    -- Convert the dates to the user's timezone.
    --
    IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN
       x_newstarttime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_open_bidding_date,x_oex_timezone,x_timezone);
       x_newendtime   := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_close_bidding_date,x_oex_timezone,x_timezone);
       x_newpreviewtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone);
    ELSE
     x_newstarttime := p_open_bidding_date;
     x_newendtime := p_close_bidding_date;
       x_newpreviewtime := x_preview_date;
    END IF;

    IF (x_preview_date IS NULL) THEN
        x_timezone1 := ' ';
    ELSE
        x_timezone1 := x_timezone;
    END IF;

    x_timezone_disp:= Get_TimeZone_Description(x_timezone, x_language_code);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'TP_TIME_ZONE',
                               avalue     => x_timezone_disp);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_START_DATE_TZ',
                               avalue     => x_newstarttime);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_END_DATE_TZ',
                               avalue     => x_newendtime);

    IF (x_newpreviewtime is not null) THEN
      wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_TZ',
                           avalue   => x_newpreviewtime);

      x_timezone1_disp := Get_TimeZone_Description(x_timezone1, x_language_code);

      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey   => x_itemkey,
                           aname     => 'TP_TIME_ZONE1',
                           avalue    => x_timezone1_disp);

        wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => null);
    ELSE
        wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_TZ',
                           avalue     => null);

      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                             aname  => 'TP_TIME_ZONE1',
                             avalue     => null);

        wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));
    END IF;


    if (p_event_id is not null) then
        x_event_title := getEventTitle (p_auction_header_id);
      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'EVENT_TITLE',
                                   avalue     => replaceHtmlChars(x_event_title));
    end if;

    -- new 6.2 attributes.

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'DOC_INTERNAL_NAME',
                               avalue     => x_doctype_group_name);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_ROUND_NUMBER',
                                 avalue     => x_auction_round_number);

    -- amendment attribute

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_AMENDMENT_NUMBER',
                                 avalue     => x_amendment_number);

    --  New attribute to hold the vendor site id. Attribute value is going
  -- to be used as a parameter to access Negotiation Summary page
    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'VENDOR_SITE_ID',
                               avalue     => -1);


    --x_msg_suffix := GET_MESSAGE_SUFFIX (x_doctype_group_name);
    --SLM UI Enhancement :
    x_msg_suffix := PON_SLM_UTIL_PKG.GET_AUCTION_MESSAGE_SUFFIX (p_auction_header_id, x_doctype_group_name);

       -- call to notification utility package to get the redirect page url that
       -- is responsible for getting the Negotiation Summary url and forward to it.
       x_neg_summary_url_buyer := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PON_NEG_SUMMARY'
                                 ,p_notif_performer  => 'BUYER');

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'NEG_SUMMARY_URL',
                               avalue     => x_neg_summary_url_buyer);

    -- call to notification utility package to get the Net Changes url accessed by buyer.

    if (x_amendment_number > 0) then
      -- call to notification utility package to get the redirect page url that
       -- is responsible for getting the Net Changes page url and forward to it.
       x_net_changes_url_buyer := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PONINQ_VIEW_NET_CHNG'
                                 ,p_notif_performer  => 'BUYER');
    elsif (x_auction_round_number > 1 and x_amendment_number = 0) then
       -- call to notification utility package to get the redirect page url that
       -- is responsible for getting the Round Modifications page url and forward to it.
       x_net_changes_url_buyer := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PONINQ_NEW_ROUND_SUM'
                                 ,p_notif_performer  => 'BUYER');
    end if;


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'NET_CHANGES_URL',
                               avalue     => x_net_changes_url_buyer);


   select document_number
   into   x_orig_document_number
   from   pon_auction_headers_all
   where  auction_header_id = x_auction_header_id_orig_amend;


--- 000001

   if (x_amendment_number = 0) then -- first round negotiaton
     if (x_difference > 0 and sysdate < p_open_bidding_date) then -- preview mode
       if (x_event_title is not null) then -- part of event
         x_notif_subject := getMessage('PON_AUC_WF_PSTART_EVENT_SUB', x_msg_suffix, 'DOC_NUMBER', x_doc_number_dsp, 'AUCTION_TITLE', replaceHtmlChars(p_auction_title), 'EVENT_TITLE', x_event_title);
       else -- NOT part of event
         x_notif_subject := getMessage('PON_AUC_WF_AUC_PSTART_SUB', x_msg_suffix,'DOC_NUMBER', x_doc_number_dsp,'AUCTION_TITLE', replaceHtmlChars(p_auction_title));
       end if;
     else -- open mode
       if (x_event_title is not null) then -- part of event
         x_notif_subject := getMessage('PON_AUC_WF_START_EVENT_SUB', x_msg_suffix, 'DOC_NUMBER', x_doc_number_dsp, 'AUCTION_TITLE', replaceHtmlChars(p_auction_title), 'EVENT_TITLE', x_event_title);
       else
         x_notif_subject := getMessage('PON_AUC_WF_AUC_START_SUB', x_msg_suffix, 'DOC_NUMBER', x_doc_number_dsp, 'AUCTION_TITLE', replaceHtmlChars(p_auction_title));
       end if;
     end if;
   else -- amendment
     if (x_difference > 0 and sysdate < p_open_bidding_date) then -- preview mode
       if (x_event_title is not null) then -- part of event
         x_notif_subject := getMessage('PON_AUC_AM_PSTART_EVENT_SUB', x_msg_suffix, 'AMENDMENT_NUMBER', x_amendment_number, 'ORIG_NUMBER', x_orig_document_number, 'AUCTION_TITLE', replaceHtmlChars(p_auction_title), 'EVENT_TITLE', x_event_title);
       else -- NOT part of event
         x_notif_subject := getMessage('PON_AUC_AM_AUC_PSTART_SUB', x_msg_suffix, 'AMENDMENT_NUMBER', x_amendment_number, 'ORIG_NUMBER', x_orig_document_number, 'AUCTION_TITLE', replaceHtmlChars(p_auction_title));
       end if;
     else -- open mode
       if (x_event_title is not null) then -- part of event
         x_notif_subject := getMessage('PON_AUC_AM_START_EVENT_SUB', x_msg_suffix, 'AMENDMENT_NUMBER', x_amendment_number, 'ORIG_NUMBER', x_orig_document_number, 'AUCTION_TITLE', replaceHtmlChars(p_auction_title), 'EVENT_TITLE', x_event_title);
       else
         x_notif_subject := getMessage('PON_AUC_AM_AUC_START_SUB', x_msg_suffix, 'AMENDMENT_NUMBER', x_amendment_number, 'ORIG_NUMBER', x_orig_document_number, 'AUCTION_TITLE', replaceHtmlChars(p_auction_title));
       end if;
     end if;
   end if;


   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'AUCTION_STARTED_SUB',
                              avalue     => x_notif_subject);


   UNSET_SESSION_LANGUAGE;

   --
   -- Start the workflow
   --

   -- Bug 4295915: Set the  workflow owner
   wf_engine.SetItemOwner(itemtype => x_itemtype,
                          itemkey  => x_itemkey,
                          owner    => fnd_global.user_name);

   wf_engine.StartProcess(itemtype => x_itemtype,
                          itemkey  => x_itemkey );


   UPDATE pon_auction_headers_all set
          wf_item_key = x_itemkey,
          reminder_date = x_reminder_date
   WHERE auction_header_id = p_auction_header_id;

   -- Raise Business Event
   PON_BIZ_EVENTS_PVT.RAISE_NEG_PUB_EVENT (
      p_api_version  => 1.0 ,
      p_init_msg_list => FND_API.G_FALSE,
      p_commit         => FND_API.G_FALSE,
      p_auction_header_id => p_auction_header_id,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data        => x_msg_data);

END;

PROCEDURE START_BID(    p_bid_id               NUMBER,    --  1
      p_auction_header_id    NUMBER,    --  2
      p_bid_tp_contact_name    VARCHAR2,  --  3
      p_auction_tp_name      VARCHAR2,  --  4
         p_auction_open_bidding_date  DATE,    --  5
        p_auction_close_bidding_date  DATE,     --  6
      p_visibility_code    VARCHAR2,  --  7
      p_item_description    VARCHAR2,   --  8
      p_old_price      NUMBER,    --  9
      p_new_price      NUMBER,    -- 10
      p_auction_title      VARCHAR2,  -- 11
      p_oex_operation      VARCHAR2,  -- 12
      p_oex_operation_url    VARCHAR2) IS  -- 13


x_sequence  NUMBER;
x_itemtype  VARCHAR2(7) := 'PONABID';
x_itemkey  VARCHAR2(50);
x_progress  VARCHAR2(3);
x_sealed_flag  VARCHAR2(1) := 'N';
x_winning_bid   VARCHAR2(1) := 'N';

BEGIN


    x_progress := '010';

    --
    -- Get next value in sequence for itemkey
    --
    SELECT pon_auction_wf_bid_s.nextval
    INTO   x_sequence
    FROM   dual;

    x_progress := '020';


    x_itemkey := (to_char(p_bid_id)||'-'||to_char(x_sequence));

    x_progress := '022';


    --
    -- Create the wf process
    --

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'PON_AUCTION_BID');

    --
    -- Set all the item attributes
    --

    x_progress := '025';


    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'BID_ID',
                                 avalue     => p_bid_id);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                 aname      => 'AUCTION_ID',
                                 avalue     => p_auction_header_id);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_TP_NAME',
                               avalue     => p_auction_tp_name);


    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_START_DATE',
                               avalue     => p_auction_open_bidding_date);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_END_DATE',
                               avalue     => p_auction_close_bidding_date);


    IF (p_visibility_code = 'SEALED_BIDDING') THEN
  x_sealed_flag := 'Y';
    END IF;

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'SEALED_FLAG',
                               avalue     => x_sealed_flag);

    x_progress := '028';


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                itemkey    => x_itemkey,
                               aname      => 'OUTBID_TP_CONTACT_NAME',
                         avalue     => p_bid_tp_contact_name);



    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ITEM_DESCRIPTION',
                               avalue     => replaceHtmlChars(p_item_description));

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                 aname      => 'OLD_BID',
                           avalue     => p_old_price);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                 aname      => 'NEW_BID',
                           avalue     => p_new_price);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_TITLE',
                               avalue     => replaceHtmlChars(p_auction_title));
/*
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'OEX_OPERATION',
                               avalue     => p_oex_operation);
*/
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'OEX_OPERATION_URL',
                               avalue     => p_oex_operation_url);

    -- Bug 4295915: Set the  workflow owner
    wf_engine.SetItemOwner(itemtype => x_itemtype,
                           itemkey  => x_itemkey,
                           owner    => fnd_global.user_name);

    --
    -- Start the workflow
    --
    wf_engine.StartProcess(itemtype => x_itemtype,
                           itemkey  => x_itemkey );

    x_progress := '029';


END;


PROCEDURE DISQUALIFY_BID(p_auction_header_id_encrypted   VARCHAR2,  --  1
                         p_bid_id                        NUMBER,  --  2
                   p_auction_header_id         NUMBER,    --  3
                         p_bid_tp_contact_name           VARCHAR2,  --  4
                   p_auction_tp_name               VARCHAR2,  --  5
                     p_auction_title               VARCHAR2,  --  6
                       p_disqualify_date                DATE,    --  7
                   p_disqualify_reason           VARCHAR2  --  8
                  ) IS



x_sequence    NUMBER;
x_itemtype    VARCHAR2(8) := 'PONDQBID';
x_itemkey    VARCHAR2(50);
x_bid_list    VARCHAR2(1);
x_progress    VARCHAR2(3);
x_role_name    VARCHAR2(30);
x_sealed_flag    VARCHAR2(1) := 'N';
x_bid_contact_dp_name   VARCHAR2(240);
x_auction_type_name   VARCHAR2(30) := '';
x_auctioneer_tag        VARCHAR2(30);
x_timezone        VARCHAR2(80);
x_new_disqualify_date   DATE;
x_language_code VARCHAR2(30) := null;
x_newstarttime    DATE;
x_newendtime    DATE;
x_startdate    DATE;
x_enddate    DATE;
x_doctype_group_name   VARCHAR2(60);
x_msg_suffix     VARCHAR2(3) := '';
p_doc_number_dsp   PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
p_view_quote_url    VARCHAR2(2000);
x_l_view_quote_url_supplier VARCHAR2(2000);
x_auction_tp_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
p_bid_name           VARCHAR2(2000); --Bug15903246 - changing the variable length same as MESSAGE_TEXT in FND_NEW_MESSAGES
x_bidder_contact_id             NUMBER;
x_auctioneer_contact_id NUMBER;
x_oex_timezone VARCHAR2(80);
x_timezone_disp VARCHAR2(240);

-- bidder specific time zone related values
x_timezone_bidder VARCHAR2(80);
x_timezone_disp_bidder VARCHAR2(240);
x_newstarttime_bidder    DATE;
x_newendtime_bidder    DATE;
x_new_disqualify_date_bidder   DATE;

x_newendtime1    VARCHAR2(80);
x_newstarttime1    VARCHAR2(80);
p_view_quote_url_supplier VARCHAR2(2000);
x_tp_display_name PON_BID_HEADERS.TRADING_PARTNER_NAME%TYPE;
x_tp_address_name PON_BID_HEADERS.VENDOR_SITE_CODE%TYPE;
x_auction_tp_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
x_preview_date           DATE;
x_preview_date_in_tz       DATE;
x_timezone1_disp          VARCHAR2(240);

-- Bisuness Events Related Changes
x_return_status   VARCHAR2(20);
x_msg_count       NUMBER;
x_msg_data         VARCHAR2(2000);

x_staggered_closing_interval NUMBER;
x_vendor_site_id NUMBER;
x_staggered_close_note       VARCHAR2(1000);
x_trading_partner_contact_id pon_bid_headers.trading_partner_contact_id%TYPE;
l_tp_contact_user_name           wf_users.name%TYPE;

CURSOR c1_bid_info(x_lang VARCHAR2) IS
    select ah.document_number, ah.trading_partner_name, dt.doctype_group_name,
     nvl(substr(bhz.attribute2,0,3),''),
     bhz.person_first_name || ' ' ||  bhz.person_last_name,
       bih.trading_partner_name, decode(bih.vendor_site_code, '-1', null, bih.vendor_site_code) vendor_site_code,
       decode(bih.vendor_site_id, -1, null, bih.vendor_site_id) vendor_site_id,
       ah.view_by_date, ah.staggered_closing_interval,bih.trading_partner_contact_id
    from hz_parties bhz, pon_bid_headers bih, pon_auction_headers_all ah, pon_auc_doctypes dt
    where bhz.party_id = bih.trading_partner_contact_id
    and   bih.bid_number = p_bid_id
    and   ah.auction_header_id = bih.auction_header_id
    and   ah.doctype_id = dt.doctype_id;

BEGIN


    x_progress := '010';

    --
    -- Get the bidder's language code so that the c1_bid_info
    -- has right value for x_language_code
    --
    IF p_bid_tp_contact_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_bid_tp_contact_name,x_language_code);
    END IF;

    -- Set the userenv language so the message token (attribute) values that we retrieve using the
    -- getMessage call return the message in the correct language => x_language_code

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
     FND_LOG.string(log_level => FND_LOG.level_statement,
       module => g_module_prefix || 'DISQUALIFY_BID',
       message  => '3. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
    END IF; --}

    SET_SESSION_LANGUAGE(null, x_language_code);

    --
    -- Get next value in sequence for itemkey
    --

    SELECT pon_auction_wf_dqbid_s.nextval
    INTO   x_sequence
    FROM   dual;

        -- lxchen why???
    --
    -- Get the exchange's time zone
    --

  select trading_partner_contact_id
  into x_bidder_contact_id
  from pon_bid_headers
  where bid_number = p_bid_id ;

    x_oex_timezone := Get_Oex_Time_Zone;

    --
    -- Get the contact name, bidder's timezone and auction type
    --

    open c1_bid_info(x_language_code);
    fetch c1_bid_info
    into p_doc_number_dsp, x_auction_tp_name, x_doctype_group_name,
       x_timezone_bidder, x_bid_contact_dp_name,
         x_tp_display_name, x_tp_address_name, x_vendor_site_id, x_preview_date,
         x_staggered_closing_interval,x_trading_partner_contact_id;


    x_timezone_bidder:= Get_Time_Zone(p_bid_tp_contact_name);

    x_progress := '020';

    x_itemkey := (to_char(p_bid_id)||'-'||to_char(x_sequence));

    x_progress := '022';

    --
    -- Create the wf process
    --

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'PON_DISQUALIFY_BID');

    --
    -- Set all the item attributes
    --

    x_progress := '025';

    --x_msg_suffix := GET_MESSAGE_SUFFIX (x_doctype_group_name);
    --SLM UI Enhancement :
    x_msg_suffix := PON_SLM_UTIL_PKG.GET_AUCTION_MESSAGE_SUFFIX (p_auction_header_id, x_doctype_group_name);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_NUMBER',
                                 avalue     => p_doc_number_dsp);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_ID',
                                 avalue     => p_auction_header_id);

    wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'ORIGIN_USER_NAME',
                                 avalue     => fnd_global.user_name);

    -- Item attribute value is going to be used as a parameter to View Quote page
    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'BID_ID',
                                 avalue     => p_bid_id);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_NAME',
                               avalue     => x_tp_display_name);

    --Bug 16666395 modified from vendor_site_code to address
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_ADDRESS_NAME',
                               avalue     => GET_VENDOR_SITE_ADDRESS(x_vendor_site_id));

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'DOC_INTERNAL_NAME',
                               avalue     => x_doctype_group_name);

    --SLM UI Enhancement
    PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(x_itemtype, x_itemkey, p_auction_header_id);

    BEGIN
        x_staggered_close_note := NULL;
        IF x_staggered_closing_interval IS NOT NULL THEN
             x_staggered_close_note := wf_core.newline || wf_core.newline ||
                                       getMessage('PON_STAGGERED_CLOSE_NOTIF_MSG') ||
                                       wf_core.newline || wf_core.newline;
        END IF;
        wf_engine.SetItemAttrText( itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'STAGGERED_CLOSE_NOTE',
                                   avalue   => x_staggered_close_note);
    EXCEPTION
        WHEN OTHERS THEN
             NULL;
    END;

    BEGIN
      wf_engine.SetItemAttrText(itemtype   => x_itemtype,
                                itemkey    => x_itemkey,
                                aname      => '#WFM_HTMLAGENT',
                                avalue     => pon_wf_utl_pkg.get_base_external_supplier_url);
    EXCEPTION
          WHEN OTHERS THEN
        NULL;
    END;

    -- Bug 7156205. Get the value for p_bid_name from getMessage instead of hardcoding the message
    p_bid_name := getMessage('PON_AUC_BID_L', x_msg_suffix);

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BID',
                               avalue     => p_bid_name);


      -- bug#16690631 for surrogate quote enhancement
     CHECK_NOTIFY_USER_INFO(p_bid_tp_contact_name,
                        x_trading_partner_contact_id,
                        l_tp_contact_user_name);


     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_CONTACT_NAME',
                               avalue     => l_tp_contact_user_name);


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                               aname      => 'DISQUALIFY_REASON',
                               avalue     => replaceHtmlChars(p_disqualify_reason));
    --
    -- Get the dates from the auction header table
    --

    select open_bidding_date, close_bidding_date, trading_partner_contact_name
    into x_startdate, x_enddate, x_auction_tp_contact_name
    from pon_auction_headers_all
    where auction_header_id = p_auction_header_id;

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                itemkey    => x_itemkey,
                              aname      => 'AUCTION_START_DATE',
                              avalue     => x_startdate);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'AUCTION_END_DATE',
                             avalue     => x_enddate);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                itemkey    => x_itemkey,
                              aname      => 'PREVIEW_DATE',
                             avalue     => x_preview_date);

    --
    -- Convert the dates to the bidder's timezone.
    -- If the timezone is not recognized, just use PST
    --

    IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone_bidder) = 1) THEN
      x_newstarttime_bidder := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_startdate,x_oex_timezone,x_timezone_bidder);
       x_newendtime_bidder := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_enddate,x_oex_timezone,x_timezone_bidder);
       x_new_disqualify_date_bidder := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_disqualify_date,x_oex_timezone,x_timezone_bidder);
        x_preview_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone_bidder);
    ELSE
       x_newstarttime_bidder := x_startdate;
       x_newendtime_bidder := x_enddate;
       x_new_disqualify_date_bidder := p_disqualify_date;
       x_timezone_bidder := x_oex_timezone;
        x_preview_date_in_tz := x_preview_date;
    END IF;

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_DISQUALIFY_DATE',
                               avalue     => x_new_disqualify_date_bidder);

    x_timezone_disp_bidder := Get_TimeZone_Description(x_timezone_bidder, x_language_code);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'TP_TIME_ZONE',
                               avalue     => x_timezone_disp_bidder);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                            itemkey    => x_itemkey,
                          aname      => 'AUCTION_START_DATE_BIDDER',
                          avalue     => x_newstarttime_bidder);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                            itemkey    => x_itemkey,
                          aname      => 'AUCTION_END_DATE_BIDDER',
                          avalue     => x_newendtime_bidder);

    --
    -- Get the role name for this auction and the bid visibilty code
    -- to see if other bidders should be notified of this bid disqualification
    --

    select wf_role_name, decode(bid_visibility_code,'OPEN_BIDDING','N','SEALED_BIDDING','Y','N')
    into x_role_name, x_sealed_flag
    from pon_auction_headers_all
    where auction_header_id = p_auction_header_id;

    --
    -- Set the attributes
    --

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                itemkey    => x_itemkey,
                               aname      => 'NEW_BIDDER_ROLE',
                             avalue     => x_role_name);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'SEALED_FLAG',
                               avalue     => x_sealed_flag);

    -- added the contact display name and the auction type ( sellers or buyers)

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BID_CONTACT_DP_NAME',
                               avalue     => x_bid_contact_dp_name);


    IF (x_preview_date_in_tz IS NULL) THEN
        x_timezone1_disp := null;

        wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_TZ',
                           avalue  => null);

        wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'TP_TIME_ZONE1',
                           avalue  => null);

        wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));
    ELSE
        x_timezone1_disp := x_timezone_disp;

        wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
                             itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_TZ',
                           avalue  => x_preview_date_in_tz);

        wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'TP_TIME_ZONE1',
                           avalue  => x_timezone1_disp);

        wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => null);
    END IF;




     -- call to notification utility package to set the message header common attributes and #from_role
    pon_wf_utl_pkg.set_hdr_attributes (p_itemtype        => x_itemtype
                                  ,p_itemkey        => x_itemkey
                                      ,p_auction_tp_name  => x_auction_tp_name
                                    ,p_auction_title    => p_auction_title
                                    ,p_document_number  => p_doc_number_dsp
                                      ,p_auction_tp_contact_name => x_auction_tp_contact_name
                                      );

    -- call to notification utility package to get the redirect page url that
    -- is responsible for getting the View Quote url and forward to it.
       p_view_quote_url := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PONRESENQ_VIEWBID'
                                 ,p_notif_performer  => 'SUPPLIER');

	       --Bug 14572394
      x_l_view_quote_url_supplier:=   pos_url_pkg.get_external_login_url||'?requestUrl='||wfa_html.conv_special_url_chars(p_view_quote_url);
      x_l_view_quote_url_supplier:=  regexp_replace(x_l_view_quote_url_supplier ,'notificationId%3D%26%23NID', 'notificationId%3D&#NID');

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'VIEW_QUOTE_URL',
                               avalue     => p_view_quote_url);


    IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS  NULL ) THEN
             wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_TB',
                                         avalue      => null);
            wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_HB',
                                         avalue      => null);
	ELSE
             wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_URL',
                                     avalue => x_l_view_quote_url_supplier);
	END IF;

	x_newstarttime1 := to_char(x_newstarttime_bidder,'Month dd, yyyy hh:mi am');
       x_newendtime1   := to_char(x_newendtime_bidder,'Month dd, yyyy hh:mi am');




--- 000001
    wf_engine.SetItemAttrText ( itemtype => x_itemtype,
                                itemkey   => x_itemkey,
                                aname     => 'PON_WF_AUC_DSQBID_SUB',
                                avalue     => getMessage('PON_WF_AUC_DSQBID_SUB', x_msg_suffix,
                                                'BID_ID', p_bid_id,
                                               'DOC_NUMBER', p_doc_number_dsp,
                                               'AUCTION_TITLE', replaceHtmlChars(p_auction_title)));

    -- Bug 8446265 Modification
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_DSQBID_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_PON_DSQBID_BODY/'||x_itemtype ||':' ||x_itemkey
                               );



    UNSET_SESSION_LANGUAGE;

    x_progress := '027';

    -- Bug 4295915: Set the  workflow owner
    wf_engine.SetItemOwner(itemtype => x_itemtype,
                           itemkey  => x_itemkey,
                           owner    => fnd_global.user_name);

    --
    -- Start the workflow
    --

    wf_engine.StartProcess(itemtype => x_itemtype,
                           itemkey  => x_itemkey );

    x_progress := '029';

    -- Raise Business Event
    PON_BIZ_EVENTS_PVT.RAISE_RESPNSE_DISQ_EVENT (
      p_api_version  => 1.0 ,
      p_init_msg_list => FND_API.G_FALSE,
      p_commit         => FND_API.G_FALSE,
      p_bid_number => p_bid_id,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data        => x_msg_data);

END;


PROCEDURE RETRACT_BID(   p_bid_id               NUMBER,    --  1
       p_auction_header_id    NUMBER,    --  2
       p_bid_tp_contact_name    VARCHAR2,  --  3
       p_bid_tp_contact_id    NUMBER,    --  4
       p_auction_tp_contact_name    VARCHAR2,  --  5
          p_auction_tp_contact_id  NUMBER,    --  6
          p_auction_open_bidding_date  DATE,    --  7
         p_auction_close_bidding_date  DATE,     --  8
       p_oex_operation_url    VARCHAR2) IS  -- 9

x_sequence  NUMBER;
x_itemtype  VARCHAR2(7) := 'PONBCAN';
x_itemkey  VARCHAR2(50);
x_bid_list  VARCHAR2(1);
x_progress  VARCHAR2(3);
l_tp_contact_user_name  wf_users.name%TYPE;

BEGIN


    x_progress := '010';


    --
    -- Get next value in sequence for itemkey
    --
    SELECT pon_auction_wf_rtbid_s.nextval
    INTO   x_sequence
    FROM   dual;

    x_progress := '020';


    x_itemkey := (to_char(p_bid_id)||'-'||to_char(x_sequence));

    x_progress := '022';


    --
    -- Create the wf process
    --

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'PON_BID_CANCEL');

    --
    -- Set all the item attributes
    --

    x_progress := '025';


    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_ID',
                               avalue     => p_auction_header_id);


    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BID_ID',
                               avalue     => p_bid_id);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PREPARER_TP_CONTACT_NAME',
                               avalue     => p_auction_tp_contact_name);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PREPARER_TP_CONTACT_ID',
                               avalue     => p_auction_tp_contact_id);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ORIGIN_USER_NAME',
                               avalue     => fnd_global.user_name);
    x_progress := '026';

    -- bug#16690631 for surrogate quote enhancement

    CHECK_NOTIFY_USER_INFO(p_bid_tp_contact_name,
                        p_bid_tp_contact_id,
                        l_tp_contact_user_name);
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_CONTACT_NAME',
                               avalue     => l_tp_contact_user_name);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_CONTACT_ID',
                               avalue     => p_bid_tp_contact_id);


    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_START_DATE',
                               avalue     => p_auction_open_bidding_date);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_END_DATE',
                               avalue     => p_auction_close_bidding_date);


--    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
--                               itemkey    => x_itemkey,
--                               aname      => 'OEX_OPERATION',
--                               avalue     => p_oex_operation);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'OEX_OPERATION_URL',
                               avalue     => 'p_oex_operation_url');
    x_progress := '027';


    -- Bug 4295915: Set the  workflow owner
    wf_engine.SetItemOwner(itemtype => x_itemtype,
                           itemkey  => x_itemkey,
                           owner    => fnd_global.user_name);

    --
    -- Start the workflow
    --
    wf_engine.StartProcess(itemtype => x_itemtype,
                           itemkey  => x_itemkey );

    x_progress := '029';

END;


PROCEDURE AWARD_BID(p_bid_id                      NUMBER,    --  1
                p_auction_header_id           NUMBER,    --  2
                p_bid_tp_contact_name         VARCHAR2,  --  3
                p_auction_tp_name            VARCHAR2,  --  4
                p_auction_title               VARCHAR2,  --  5
                p_auction_header_id_encrypted  VARCHAR2    --  6
                ) IS



x_number_awarded  NUMBER;
x_number_rejected  NUMBER;
x_sequence  NUMBER;
x_itemtype  VARCHAR2(8) := 'PONAWARD';
x_itemkey  VARCHAR2(50);
x_bid_list  VARCHAR2(1);
x_progress  VARCHAR2(3);
x_bid_contact_tp_dp_name varchar2(240);
x_auction_type varchar2(30);
x_auction_type_name varchar2(30) := '';
x_event_title       varchar2(80);
x_event_id          NUMBER;
x_auction_open_bidding_date DATE;
x_auction_close_bidding_date DATE;
x_language_code VARCHAR2(30) := null;
x_timezone  VARCHAR2(80);
x_newstarttime  DATE;
x_newendtime  DATE;
x_newawardtime  DATE;
x_doctype_group_name   VARCHAR2(60);
x_msg_suffix     VARCHAR2(3) := '';
x_doc_number_dsp    PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
x_auction_round_number    NUMBER;
x_doctype_id_value    NUMBER;
x_oex_timezone VARCHAR2(80);
x_bidder_contact_id   NUMBER;
x_timezone_disp VARCHAR2(240);
x_bid           VARCHAR2(10);
x_bid_caps      VARCHAR2(10);
x_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE;
x_view_quote_url_supplier VARCHAR2(2000);
x_l_view_quote_url_supplier VARCHAR2(2000);
x_award_date PON_AUCTION_HEADERS_ALL.AWARD_DATE%TYPE;
x_trading_partner_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
x_tp_display_name PON_BID_HEADERS.TRADING_PARTNER_NAME%TYPE;
x_tp_address_name PON_BID_HEADERS.VENDOR_SITE_CODE%TYPE;
x_preview_date             DATE;
x_preview_date_in_tz             DATE;
x_timezone1_disp                VARCHAR2(240);
x_has_items_flag                PON_AUCTION_HEADERS_ALL.HAS_ITEMS_FLAG%TYPE;
x_staggered_closing_interval    NUMBER;
x_vendor_site_id    NUMBER;
x_staggered_close_note          VARCHAR2(1000);
x_bid_award_status PON_BID_HEADERS.AWARD_STATUS%TYPE;
l_tp_contact_user_name     wf_users.name%TYPE;
x_trading_partner_contact_id pon_bid_headers.trading_partner_contact_id%TYPE;


l_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE :='';


CURSOR c1_bid_info(x_lang VARCHAR2) IS
    select bid_type, nvl(ah.auction_round_number, 1) auction_round_number, bih.note_to_supplier,
     ah.document_number, dt.doctype_group_name, dt.doctype_id,
     bhz.person_first_name || ' ' ||  bhz.person_last_name, ah.trading_partner_contact_name,
       bih.trading_partner_name, decode(bih.vendor_site_code, '-1', null, bih.vendor_site_code) vendor_site_code,
       decode(bih.vendor_site_id, -1, null, bih.vendor_site_id) vendor_site_id,
       view_by_date, nvl(ah.has_items_flag, 'Y'), ah.staggered_closing_interval,bih.award_status,bih.trading_partner_contact_id
    from hz_parties bhz, pon_bid_headers bih, pon_auction_headers_all ah, pon_auc_doctypes dt
    where bhz.party_id = bih.trading_partner_contact_id
    and   bih.bid_number = p_bid_id
    and   ah.auction_header_id = bih.auction_header_id
    and   ah.doctype_id = dt.doctype_id;

        CURSOR note_to_supplier IS
         select LINE_NUMBER,REASON
          FROM pon_acceptances
          WHERE auction_header_id = p_auction_header_id
          and bid_number = p_bid_id;

      l_note note_to_supplier%ROWTYPE;

BEGIN


    x_progress := '010';

    --
    -- Get the bidder's language code so that the c1_bid_info
    -- has right value for x_language_code
    --
    IF p_bid_tp_contact_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_bid_tp_contact_name,x_language_code);
    END IF;

    -- Set the userenv language so the message token (attribute) values that we retrieve using the
    -- getMessage call return the message in the correct language => x_language_code
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
     FND_LOG.string(log_level => FND_LOG.level_statement,
       module => g_module_prefix || 'AWARD_BID',
       message  => '4. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
    END IF; --}

    SET_SESSION_LANGUAGE(null, x_language_code);

    --
    -- Get next value in sequence for itemkey
    --

    SELECT pon_auction_wf_acbid_s.nextval
    INTO   x_sequence
    FROM   dual;

    --
    -- get the contact name and auction type
    --

    open c1_bid_info(x_language_code);
    fetch c1_bid_info
    into x_auction_type, x_auction_round_number, x_note_to_supplier, x_doc_number_dsp,
   x_doctype_group_name, x_doctype_id_value,
   x_bid_contact_tp_dp_name, x_trading_partner_contact_name, x_tp_display_name,
         x_tp_address_name, x_vendor_site_id, x_preview_date, x_has_items_flag, x_staggered_closing_interval,x_bid_award_status,x_trading_partner_contact_id;

 -- bug 6020309 : Get rejection note if any at the line level, if the buyer has
 -- not specified rejection note at the bid level. Though the buyer enters a
 -- single note in case of rejecting all the bids, the note is stored at the line level.
 	--Bug 12654369
        --Added Code to Send Note to Supplier for Awarded, Partially Awarded and Rejected Suppliers
     if (x_note_to_supplier is null ) THEN
       begin
          FOR l_note in note_to_supplier
              LOOP
                EXIT WHEN length(l_note_to_supplier||fnd_message.get_string('PON', 'PON_AUCTION_LINE_NUMBER')||' '||l_note.line_number||':'||RTRIM(LTRIM(l_note.reason))||'<br>') >1000;
                IF(l_note.reason IS NOT NULL) then
                l_note_to_supplier := l_note_to_supplier||fnd_message.get_string('PON', 'PON_AUCTION_LINE_NUMBER')||' '||l_note.line_number||':'||RTRIM(LTRIM(l_note.reason))||'<br>';
                END IF;
              END LOOP;
       exception
      when others then null;
     end;
	x_note_to_supplier:= l_note_to_supplier;
     end if;



    IF (x_doctype_group_name = 'BUYER_AUCTION') THEN
      --x_bid := 'bid';
        --x_bid_caps := 'Bid';
        x_bid := fnd_message.get_string('PON', 'PON_AUC_BID_L_B');
        x_bid_caps := fnd_message.get_string('PON', 'PON_RESPONSE_TYPE_B');
    ELSIF (x_doctype_group_name = 'REQUEST_FOR_QUOTE') THEN
      --x_bid := 'quote';
        --x_bid_caps := 'Quote';
        x_bid := fnd_message.get_string('PON', 'PON_AUC_BID_L_R');
        x_bid_caps := fnd_message.get_string('PON', 'PON_RESPONSE_TYPE_R');
    ELSIF (x_doctype_group_name = 'REQUEST_FOR_INFORMATION') THEN
        --x_bid := 'response';
        --x_bid_caps := 'Response';
        x_bid := fnd_message.get_string('PON', 'PON_AUC_BID_L_I');
        x_bid_caps := fnd_message.get_string('PON', 'PON_RESPONSE_TYPE_I');
    END IF;

    x_progress := '020';

    --x_msg_suffix := GET_MESSAGE_SUFFIX (x_doctype_group_name);
    --SLM UI Enhancement :
    x_msg_suffix := PON_SLM_UTIL_PKG.GET_AUCTION_MESSAGE_SUFFIX (p_auction_header_id, x_doctype_group_name);

    x_itemkey := (to_char(p_bid_id)||'-'||to_char(x_sequence));

    x_progress := '022';

    --
    -- Create the wf process
    --

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'PON_AWARD_BID');

    --
    -- Set all the item attributes
    --

    wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_NUMBER',
                                 avalue     => x_doc_number_dsp);


    -- call to notification utility package to get the redirect page url that
    -- is responsible for getting the View Quote url and forward to it.
  x_view_quote_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PONRESENQ_VIEWBID'
                                 ,p_notif_performer  => 'SUPPLIER');

       --Bug 14572394
      x_l_view_quote_url_supplier:=   pos_url_pkg.get_external_login_url||'?requestUrl='||wfa_html.conv_special_url_chars(x_view_quote_url_supplier);
      x_l_view_quote_url_supplier:=  regexp_replace(x_l_view_quote_url_supplier ,'notificationId%3D%26%23NID', 'notificationId%3D&#NID');


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'VIEW_QUOTE_URL',
                               avalue     => x_view_quote_url_supplier);

    IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS  NULL ) THEN
             wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_TB',
                                         avalue      => null);
            wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_HB',
                                         avalue      => null);
	ELSE
             wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_URL',
                                     avalue => x_l_view_quote_url_supplier);
	END IF;


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_NAME',
                               avalue     => x_tp_display_name);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'HAS_ITEMS_FLAG',
                               avalue     => x_has_items_flag);

   --Bug 16666395 modified from vendor_site_code to address
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_ADDRESS_NAME',
                               avalue     => GET_VENDOR_SITE_ADDRESS(x_vendor_site_id));

    BEGIN
        x_staggered_close_note := NULL;
        IF x_staggered_closing_interval IS NOT NULL THEN
             x_staggered_close_note := wf_core.newline || wf_core.newline ||
                                       getMessage('PON_STAGGERED_CLOSE_NOTIF_MSG') ||
                                       wf_core.newline || wf_core.newline;
        END IF;
        wf_engine.SetItemAttrText( itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'STAGGERED_CLOSE_NOTE',
                                   avalue   => x_staggered_close_note);
    EXCEPTION
        WHEN OTHERS THEN
              NULL;
    END;

    BEGIN
      wf_engine.SetItemAttrText(itemtype   => x_itemtype,
                                itemkey    => x_itemkey,
                                aname      => '#WFM_HTMLAGENT',
                                avalue     => pon_wf_utl_pkg.get_base_external_supplier_url);
    EXCEPTION
          WHEN OTHERS THEN
        NULL;
    END;

    x_progress := '025';

-- FPK: CPA Setting number of items awarded or rejected only when negotiation has lines.
IF x_has_items_flag  = 'Y' THEN

    /* set these variables to a default zero */
    x_number_awarded  := 0;
    x_number_rejected := 0;


    select   count(pbip.line_number)
    into   x_number_awarded
    from   pon_bid_item_prices pbip,
    pon_auction_item_prices_all paip
    where   paip.auction_header_id   = p_auction_header_id
    and    paip.line_number   = pbip.line_number
    and    pbip.bid_number    = p_bid_id
    and    nvl(pbip.award_status,'NONE')= 'AWARDED'
    and    paip.group_type in ('LINE', 'LOT', 'GROUP_LINE');

    select   count(pbip.line_number)
    into   x_number_rejected
    from   pon_bid_item_prices pbip,
    pon_auction_item_prices_all paip
    where   paip.auction_header_id   = p_auction_header_id
    and    paip.line_number   = pbip.line_number
    and    pbip.bid_number    = p_bid_id
    and    nvl(pbip.award_status,'NONE')= 'REJECTED'
    and    paip.group_type in ('LINE', 'LOT', 'GROUP_LINE');

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NUMBER_AWARDED',
                                 avalue     => x_number_awarded);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NUMBER_REJECTED',
                                 avalue     => x_number_rejected);
END IF;


    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_ID',
                                 avalue     => p_auction_header_id);

    -- Item attribute value is going to be used as a parameter to View Quote page
    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'BID_ID',
                                 avalue     => p_bid_id);

    -- bug#16690631 for surrogate quote enhancement

   CHECK_NOTIFY_USER_INFO(p_bid_tp_contact_name,
                        x_trading_partner_contact_id,
                        l_tp_contact_user_name);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_CONTACT_NAME',
                               avalue     => l_tp_contact_user_name);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ORIGIN_USER_NAME',
                               avalue     => fnd_global.user_name);

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BID',
                               avalue     => x_bid);

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BID_CAPS',
                               avalue     => x_bid_caps);

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'NOTE_TO_SUPPLIER',
                               avalue     => x_note_to_supplier);

-- added the contact display name and the auction type ( sellers or buyers)

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BID_CONTACT_TP_DP_NAME',
                         avalue     => x_bid_contact_tp_dp_name);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_TYPE_NAME',
                               avalue     => x_auction_type_name);

    select open_bidding_date, close_bidding_date, award_date, event_id
    into x_auction_open_bidding_date, x_auction_close_bidding_date, x_award_date, x_event_id
    from pon_auction_headers_all
    where auction_header_id = p_auction_header_id;

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AWARD_DATE',
                               avalue     => x_award_date);

    if (x_event_id is not null) then
        x_event_title := getEventTitle (p_auction_header_id);
      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                             itemkey    => x_itemkey,
                             aname      => 'EVENT_TITLE',
                             avalue     => replaceHtmlChars(x_event_title));
    end if;

    --
    -- Get the exchange's time zone
    --

                x_oex_timezone := Get_Oex_Time_Zone;


  select trading_partner_contact_id
  into x_bidder_contact_id
  from pon_bid_headers
  where bid_number = p_bid_id;

  begin
  x_timezone := Get_Time_Zone(x_bidder_contact_id);
   EXCEPTION
  WHEN OTHERS THEN
    x_timezone := x_oex_timezone;
        END;


    --
    -- Convert the dates to the user's timezone.
    -- If the timezone is not recognized, just use the default
    --

    IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN
      x_newstarttime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_auction_open_bidding_date,x_oex_timezone,x_timezone);
       x_newendtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_auction_close_bidding_date,x_oex_timezone,x_timezone);
        x_newawardtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_award_date,x_oex_timezone,x_timezone);
        x_preview_date_in_tz := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone);
    ELSE
      x_newstarttime := x_auction_open_bidding_date;
      x_newendtime := x_auction_close_bidding_date;
        x_newawardtime := x_award_date;
      x_timezone := x_oex_timezone;
        x_preview_date_in_tz := x_preview_date;
    END IF;

    --
    -- Set the dates based on the user's time zone
    --

   x_timezone_disp := Get_TimeZone_Description(x_timezone, x_language_code);


    wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'TP_TIME_ZONE_AUCTION',
             avalue  => x_timezone_disp);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                               aname      => 'AUCTION_START_DATE_TZ',
                               avalue     => x_newstarttime);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                               aname      => 'AUCTION_END_DATE_TZ',
                               avalue     => x_newendtime);

    wf_engine.SetItemAttrDate (itemtype     => x_itemtype,
                                 itemkey    => x_itemkey,
                               aname      => 'AWARD_DATE_TZ',
                               avalue     => x_newawardtime);

  IF (x_preview_date_in_tz IS NULL) THEN

     x_timezone1_disp := null;

     wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
                        itemkey  => x_itemkey,
                        aname  => 'PREVIEW_DATE_TZ',
                        avalue  => null);

     wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                        itemkey  => x_itemkey,
                        aname  => 'TP_TIME_ZONE1',
                        avalue  => null);

     wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                         itemkey  => x_itemkey,
                         aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                         avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));
 ELSE
     x_timezone1_disp := x_timezone_disp;

     wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
                        itemkey  => x_itemkey,
                        aname  => 'PREVIEW_DATE_TZ',
                        avalue  => x_preview_date_in_tz);

     wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                        itemkey  => x_itemkey,
                        aname  => 'TP_TIME_ZONE1',
                        avalue  => x_timezone1_disp);

       wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                          itemkey  => x_itemkey,
                          aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                          avalue  => null);
 END IF;

    x_progress := '027';

    -- call to notification utility package to set the message header common attributes and #from_role
    pon_wf_utl_pkg.set_hdr_attributes (p_itemtype               => x_itemtype
                                  ,p_itemkey               => x_itemkey
                                      ,p_auction_tp_name         => p_auction_tp_name
                                    ,p_auction_title           => p_auction_title
                                    ,p_document_number         => x_doc_number_dsp
                                      ,p_auction_tp_contact_name => x_trading_partner_contact_name
                                      );


     if (x_event_title is not null) then

        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PON_AUC_WF_AWARD_SUBJECT',
                                   avalue     => getMessage('PON_AUC_WF_AWARD_EVENT_SUB', x_msg_suffix,
                    'DOC_NUMBER', x_doc_number_dsp,
                    'AUCTION_TITLE', replaceHtmlChars(p_auction_title),
                                  'EVENT_TITLE', x_event_title));

    else

       wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                  aname      => 'PON_AUC_WF_AWARD_SUBJECT',
                                  avalue     => getMessage('PON_AUC_WF_AWARD_SUBJECT', x_msg_suffix,
                   'DOC_NUMBER', x_doc_number_dsp,
                   'AUCTION_TITLE', replaceHtmlChars(p_auction_title)));

   end if;

   --Bug 8446265 Modifications
   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_AUC_WF_AWARD_L_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_AWARD_LINES_BODY/'||x_itemtype ||':' ||x_itemkey
                               );


   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_AUC_WF_AWARD_NL_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_AWARD_NOLINES_BODY/'||x_itemtype ||':' ||x_itemkey
                               );

   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_AUC_WF_AWARD_EVENT_L_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_AWARD_EVENT_LINES_BODY/'||x_itemtype ||':' ||x_itemkey
                               );

   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_AUC_WF_AWARD_EVENT_NL_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_AWARD_EVENT_NOLINES_BODY/'||x_itemtype ||':' ||x_itemkey
                               );

    UNSET_SESSION_LANGUAGE;

    -- Bug 4295915: Set the  workflow owner
    wf_engine.SetItemOwner(itemtype => x_itemtype,
                           itemkey  => x_itemkey,
                           owner    => fnd_global.user_name);

    --
    -- Start the workflow
    --

    wf_engine.StartProcess(itemtype => x_itemtype,
                           itemkey  => x_itemkey );

    x_progress := '029';

END;

PROCEDURE UNREGISTERED_BIDDERS(  itemtype    in varchar2,
           itemkey    in varchar2,
                       actid           in number,
                       uncmode    in varchar2,
                       resultout       out NOCOPY varchar2) IS

x_flag   VARCHAR2(1);
BEGIN

    x_flag := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NEW_BIDDERS_FLAG');


    IF (x_flag = 'Y') THEN
  resultout := 'Y';
    ELSE
  resultout := 'N';

    END IF;

END;

PROCEDURE BIDDERS_LIST(  itemtype    in varchar2,
           itemkey    in varchar2,
                       actid           in number,
                       uncmode    in varchar2,
                       resultout       out NOCOPY varchar2) IS

x_flag   VARCHAR2(1);
BEGIN

    x_flag := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'BIDDER_LIST_FLAG');


    IF (x_flag = 'Y') THEN
  resultout := 'Y';
    ELSE
  resultout := 'N';

    END IF;

END;


PROCEDURE COMPLETE_PREV_ROUND_WF(  p_itemtype            in varchar2,
           p_itemkey             in varchar2,
           actid                 in number,
           uncmode               in varchar2,
           resultout             out NOCOPY varchar2) IS
  x_doc_header_id number;
  x_itemkey varchar2(240);
BEGIN

    x_doc_header_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => 'AUCTION_ID');

    begin
      select wf_item_key into x_itemkey
  from pon_auction_headers_all
  where auction_header_id = (select auction_header_id_prev_round
           from pon_auction_headers_all where auction_header_id = x_doc_header_id);

  wf_engine.completeActivity('PONAUCT', x_itemkey, 'WAIT_FOR_AUCTION_COMPLETE', 'PREPARER_COMPLETE');

    exception
  when others then
  null;
    end;
END;


PROCEDURE COMPLETE_PREV_DOC_WF(  p_itemtype            in varchar2,
                                 p_itemkey             in varchar2,
                                 actid                 in number,
                                 uncmode               in varchar2,
                                 resultout             out NOCOPY varchar2) IS
        x_doc_header_id number;
        x_prev_doc_header_id number;
        x_prev_doc_amendment_number number;
        x_itemtype                VARCHAR2(7) := 'PONAUCT';
        x_itemkey varchar2(240);
        x_current_activity        VARCHAR2(30);
BEGIN

    x_doc_header_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                  itemkey  => p_itemkey,
                                                  aname    => 'AUCTION_ID');

    begin

        select auction_header_id_prev_amend
        into   x_prev_doc_header_id
        from pon_auction_headers_all
        where auction_header_id = x_doc_header_id;

        select wf_item_key, nvl(amendment_number, 0)
        into x_itemkey, x_prev_doc_amendment_number
        from pon_auction_headers_all
        where auction_header_id = x_prev_doc_header_id;

        -- need to complete first round supplier notifications (might be waiting on ack response)
        if (x_prev_doc_amendment_number = 0) then
          complete_prev_suppl_notifs(x_prev_doc_header_id);
        end if;

        --
        -- First, see what activity (if any) the workflow is on
        -- If none, then return.  Workflow has already completed??
        --
        BEGIN
           select activity_label
           into x_current_activity
           from wf_item_activity_statuses_v
           where item_type = x_itemtype
           AND item_key = x_itemkey
           and activity_status_code = 'NOTIFIED';
        EXCEPTION WHEN no_data_found THEN
           RETURN;
        END;

        wf_engine.CompleteActivity(x_itemtype,x_itemkey,x_current_activity,'PREPARER_COMPLETE');

    exception
        when others then
        null;
    end;
END;

PROCEDURE COMPLETE_PREV_SUPPL_NOTIFS(p_prev_doc_header_id IN NUMBER) IS

x_itemtype         varchar2(8) := 'PONPBLSH';
x_itemkey          varchar2(240);
x_current_activity varchar2(30);

CURSOR bidder_list_wf_keys IS
    select pbp.wf_item_key wf_item_key, act.activity_label activity_label
    from   pon_bidding_parties pbp,
           wf_item_activity_statuses_v act
    where  pbp.auction_header_id = p_prev_doc_header_id and
           act.item_type = x_itemtype and
           act.item_key = pbp.wf_item_key and
           act.activity_status_code = 'NOTIFIED';
BEGIN

  FOR item_key IN bidder_list_wf_keys LOOP


     x_itemkey := item_key.wf_item_key;
     x_current_activity := item_key.activity_label;

     wf_engine.CompleteActivity(x_itemtype,x_itemkey,x_current_activity,'PREPARER_COMPLETE');

  END LOOP;

END;

PROCEDURE SEND_BIDDERS_NOTIFICATION(itemtype                      in varchar2,
                                    itemkey                       in varchar2,
                                    actid                         in number,
                                    p_action_code                 in varchar2,
                                    p_user                        in varchar2,
                                    p_bidder_tp_name              in varchar2,
                                    p_vendor_site_code            in varchar2,
                                    p_vendor_site_id              in number,
                                    p_message_name                in varchar2,
                                    p_doc_number_dsp              in varchar2,
                                    p_auction_title               in varchar2,
                                    p_auction_start_date          in date,
                                    p_auction_end_date            in date,
                                    p_preview_date                in date,
                                    p_language_code               in varchar2,
                                    p_timezone                    in varchar2,
                                    p_change_type                 in number,
                                    p_original_close_bidding_date in date,
                                    p_event_title                 in varchar2,
                                    p_auc_tp_contact_name         in varchar2,
                                    p_staggered_closing_interval  in number)
IS

   x_auction_header_id_encrypted  varchar2(2000);
   x_neg_summary_url_supplier VARCHAR2(2000);
   x_l_neg_summary_url_supplier VARCHAR2(2000);
   x_nid number;

   x_msg_suffix varchar2(3) := '';
   x_tp_time_zone_auction varchar2(30);
   x_oex_timezone varchar2(80);
   x_timezone     varchar2(80);
   x_new_auction_start_date date;
   x_new_auction_end_date date;

   x_close_early_subject varchar2(200);
   x_close_early_reason  varchar2(2000);
   x_close_early_no_reason varchar2(2000);
   x_close_early_at varchar2(200);

   x_close_changed_message varchar2(2000);
   x_close_changed_subject varchar2(200);
   x_close_changed_reason varchar2(2000);
   x_close_changed_no_reason varchar2(2000);

   x_status                VARCHAR2(10);
   x_exception_msg         VARCHAR2(100);
   x_person_party_id       NUMBER;

   x_new_supplier_name     VARCHAR2(240) := '';
   x_additional_invitee_flag BOOLEAN;
   x_deleted_contact_flag    BOOLEAN;
   x_count       NUMBER;

   x_listed_company_user   VARCHAR2(240) := '';
   x_timezone_disp VARCHAR2(240);

   x_close_early_date  DATE;
   x_close_date_changed DATE;
   x_new_close_early_date date;
   x_new_close_changed_date date;
   x_new_auction_preview_date DATE;
   x_timezone1_disp  VARCHAR2(240);

   x_cancel_reason PON_ACTION_HISTORY.ACTION_NOTE%TYPE := '';
   x_cancel_date          DATE;
   x_new_cancel_date      DATE;
   x_new_disqualify_date  DATE;
   x_disqualify_reason varchar2(2000) := '';
   x_bid_number number;
   x_disqualify_date date;
   x_bid_name      VARCHAR2(10);
   x_staggered_close_note   VARCHAR2(1000);

   l_origin_user_name    fnd_user.user_name%TYPE;

   --SLM UI Enhancement
   l_is_slm_doc  VARCHAR2(1);
   l_neg_assess  VARCHAR2(15);

   x_auction_header_id NUMBER;

begin

    if (p_action_code = 'CANCEL') then

        x_cancel_reason := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                         aname    => 'CANCEL_REASON');

        x_cancel_date := wf_engine.GetItemAttrDate(itemtype => itemtype,
                                           itemkey  => itemkey,
                                         aname    => 'CANCEL_DATE');

    elsif (p_action_code = 'DISQUALIFY_BID') then

        x_disqualify_reason := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'DISQUALIFY_REASON');

        x_bid_number := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'BID_ID');


        x_disqualify_date := wf_engine.GetItemAttrDate (itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'BIDDER_DISQUALIFY_DATE');

        x_bid_name := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                 itemkey  => itemkey,
                                               aname    => 'BID');

    end if;


      l_origin_user_name := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                 aname    => 'ORIGIN_USER_NAME');

      /* x_msg_suffix := GET_MESSAGE_SUFFIX (wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                                     itemkey   => itemkey,
                                                                     aname      => 'DOC_INTERNAL_NAME'));*/
      --SLM UI Enhancement
      x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'AUCTION_ID');
      x_msg_suffix := PON_SLM_UTIL_PKG.GET_AUCTION_MESSAGE_SUFFIX (x_auction_header_id,
                                                  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                                             itemkey   => itemkey,
                                                                             aname      => 'DOC_INTERNAL_NAME'));
      --SLM UI Enhancement
      l_is_slm_doc := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(x_auction_header_id);
      l_neg_assess := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE(l_is_slm_doc);

      UNSET_SESSION_LANGUAGE;

      x_nid := WF_NOTIFICATION.send(role      => p_user ,
                                    context   => itemtype||':'||itemkey||':'||actid,
                                    msg_type  => itemtype,
                                    msg_name  => p_message_name);

      IF (p_language_code is not null) THEN

         IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
         FND_LOG.string(log_level => FND_LOG.level_statement,
           module => g_module_prefix || 'SEND_BIDDERS_NOTIFICATION',
           message  => '5. Calling SET_SESSION_LANGUAGE with x_language_code : ' || p_language_code);
         END IF; --}
         SET_SESSION_LANGUAGE(null, p_language_code);
      END IF;

      -- Set the staggered closing attribute
      x_staggered_close_note := NULL;
      IF p_staggered_closing_interval IS NOT NULL THEN
           x_staggered_close_note := wf_core.newline || wf_core.newline ||
                                     getMessage('PON_STAGGERED_CLOSE_NOTIF_MSG') ||
                                     wf_core.newline || wf_core.newline;
      END IF;
      wf_Notification.setAttrText(x_nid, 'STAGGERED_CLOSE_NOTE', x_staggered_close_note);

      BEGIN
        wf_Notification.setAttrText(x_nid,'#WFM_HTMLAGENT', pon_wf_utl_pkg.get_base_external_supplier_url);
      EXCEPTION
            WHEN OTHERS THEN
          NULL;
      END;

      if (p_action_code = 'CLOSEEARLY') then

        x_close_early_date := p_auction_end_date;
        x_close_early_subject := getMessage('PON_AUC_CLOSE_WF_1', x_msg_suffix,
                                            'DOC_NUMBER', p_doc_number_dsp,
                                            'AUCTION_TITLE', replaceHtmlChars(p_auction_title));

      elsif (p_action_code = 'CLOSECHANGED') then

       x_close_date_changed := p_auction_end_date;

       x_auction_header_id_encrypted := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'AUCTION_ID_ENCRYPTED');

     -- call to notification utility package to get the redirect page url that
     -- is responsible for getting the Negotiation Summary url and forward to it.
        x_neg_summary_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
                                  p_dest_func => 'PON_NEG_SUMMARY'
                                     ,p_notif_performer  => 'SUPPLIER');

     --Bug 14572394
      x_l_neg_summary_url_supplier:=   pos_url_pkg.get_external_login_url||'?requestUrl='||wfa_html.conv_special_url_chars(x_neg_summary_url_supplier);
      x_l_neg_summary_url_supplier:=  regexp_replace(x_l_neg_summary_url_supplier ,'notificationId%3D%26%23NID', 'notificationId%3D&#NID');


       -- auctioneer extends the auction
        if (p_change_type = 1) then

           x_close_changed_subject := getMessage('PON_AUC_EXTEND_WF_1', x_msg_suffix,
                                                 'DOC_NUMBER', p_doc_number_dsp,
                                                 'AUCTION_TITLE', replaceHtmlChars(p_auction_title));

        -- auctioneer shortens the auction
        else
           x_close_changed_subject := getMessage('PON_AUC_SHORTEN_WF_1', x_msg_suffix,
                                                 'DOC_NUMBER', p_doc_number_dsp,
                                                 'AUCTION_TITLE', replaceHtmlChars(p_auction_title));
        end if;
     end if;

      x_oex_timezone := Get_Oex_Time_Zone;
      x_timezone     := p_timezone;

      IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN
          x_new_auction_start_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_auction_start_date,x_oex_timezone,x_timezone);
          x_new_auction_preview_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_preview_date,x_oex_timezone,x_timezone);

          if (p_action_code = 'CLOSEEARLY' or p_action_code = 'CLOSECHANGED') then
              x_new_auction_end_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME  (p_original_close_bidding_date,x_oex_timezone,x_timezone);
          else
             x_new_auction_end_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_auction_end_date,x_oex_timezone,x_timezone);
         end if;

          if (p_action_code = 'CLOSEEARLY') then
              x_new_close_early_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_close_early_date,x_oex_timezone,x_timezone);
              x_new_close_changed_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_close_date_changed,x_oex_timezone,x_timezone);
          elsif (p_action_code = 'CLOSECHANGED') then
                 x_new_close_changed_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_close_date_changed,x_oex_timezone,x_timezone);
          elsif (p_action_code = 'CANCEL') then
                 x_new_cancel_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_cancel_date,x_oex_timezone,x_timezone);
          end if;
      ELSE
          x_new_auction_start_date := p_auction_start_date;
        x_new_auction_end_date := p_original_close_bidding_date;
          x_new_auction_preview_date := p_preview_date;
          if (p_action_code = 'CLOSEEARLY') then
             x_new_close_early_date := x_close_early_date;
          elsif (p_action_code = 'CLOSECHANGED') then
             x_new_close_changed_date := x_close_date_changed;
        end if;
        x_timezone := x_oex_timezone;
      END IF;

    x_timezone_disp := Get_TimeZone_Description(x_timezone, p_language_code);
      IF x_new_auction_preview_date IS NOT NULL THEN
         x_timezone1_disp := x_timezone_disp;
      ELSE
         x_timezone1_disp := null;
      END IF;

      -- Setup common attributes
      wf_Notification.setAttrDate(x_nid, 'AUCTION_START_DATE', x_new_auction_start_date);
      wf_Notification.setAttrDate(x_nid, 'AUCTION_END_DATE', x_new_auction_end_date);
      wf_Notification.SetAttrDate(x_nid, 'PREVIEW_DATE', x_new_auction_preview_date);
      wf_Notification.SetAttrText(x_nid, 'TP_TIME_ZONE1', x_timezone1_disp);
      wf_Notification.setAttrText(x_nid, '#HDR_NEG_TITLE', p_auction_title);
      wf_Notification.setAttrText(x_nid, '#HDR_NEG_NUMBER', p_doc_number_dsp);
      wf_Notification.setAttrText(x_nid, '#HDR_NEG_TP_NAME', wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                                                        itemkey   => itemkey,
                                                                                        aname     =>'PREPARER_TP_NAME'));

      wf_Notification.setAttrText(x_nid, '#FROM_ROLE', l_origin_user_name);

      IF (x_new_auction_preview_date is null) THEN
            wf_Notification.SetAttrText(x_nid, 'PREVIEW_DATE_NOTSPECIFIED', PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));

      ELSE
            wf_Notification.SetAttrText(x_nid, 'PREVIEW_DATE_NOTSPECIFIED', wf_engine.GetItemAttrText (itemtype => itemtype,
                                                                                                 itemkey  => itemkey,
                                                                                                 aname    => 'PREVIEW_DATE_NOTSPECIFIED'));
      END IF;

      if (p_action_code <> 'DISQUALIFY_BID') then
          wf_Notification.setAttrText(x_nid, 'BIDDER_TP_NAME', p_bidder_tp_name);
          --Bug 16666395 modified from vendor_site_code to address
	  wf_Notification.setAttrText(x_nid, 'BIDDER_TP_ADDRESS_NAME',GET_VENDOR_SITE_ADDRESS(p_vendor_site_id));
      end if;

      IF (p_action_code is not null and p_action_code = 'CLOSEEARLY') THEN

          wf_Notification.setAttrText(x_nid, 'TP_TIME_ZONE_AUCTION', x_timezone_disp);
          wf_Notification.SetAttrText(x_nid, 'AUCTION_CLOSE_EARLY_SUB', x_close_early_subject);
          wf_Notification.SetAttrDate(x_nid, 'AUCTION_CLOSE_EARLY_DATE', x_new_close_early_date);
          wf_Notification.SetAttrText(x_nid, 'CLOSECHANGED_REASON', wf_engine.GetItemAttrText (itemtype => itemtype,
                                                                                               itemkey  => itemkey,
                                                                                               aname => 'CLOSECHANGED_REASON'));
          --SLM UI Enhancement
          PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_NOTIF_ATTR(x_nid, l_neg_assess);

      ELSIF (p_action_code = 'CLOSECHANGED') then

          wf_Notification.setAttrText(x_nid, 'TP_TIME_ZONE_AUCTION', x_timezone_disp);
          wf_Notification.SetAttrText(x_nid, 'CLOSE_DATE_CHANGED_SUBJECT', x_close_changed_subject);
          wf_Notification.SetAttrDate(x_nid, 'CLOSE_DATE_CHANGED', x_new_close_changed_date);
          wf_Notification.SetAttrText(x_nid, 'NEG_SUMMARY_URL_SUPPLIER', x_neg_summary_url_supplier);

          --SLM UI Enhancement
          PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_NOTIF_ATTR(x_nid, l_neg_assess);

		  IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS  NULL ) THEN
             wf_Notification.SetAttrText (x_nid, 'LOGIN_VIEW_DETAILS_TB', null);
		  ELSE
		     wf_Notification.SetAttrText(x_nid, 'LOGIN_VIEW_DETAILS_TB', wf_engine.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname => 'LOGIN_VIEW_DETAILS_TB'));
             wf_Notification.SetAttrText (x_nid, 'LOGIN_VIEW_DETAILS_URL', x_l_neg_summary_url_supplier);
		  END IF;
		  wf_Notification.SetAttrNumber(x_nid, 'VENDOR_SITE_ID', p_vendor_site_id);

          IF p_change_type <> 1  THEN --i.e if it is 'NEGOTIATION_SHORTENED'
            wf_Notification.SetAttrText(x_nid, 'CLOSECHANGED_REASON', wf_engine.GetItemAttrText (itemtype => itemtype,
                                                                                               itemkey  => itemkey,
                                                                                               aname => 'CLOSECHANGED_REASON'));
          END IF;

      ELSIF (p_action_code = 'CANCEL') THEN

            --SLM UI Enhancement
            PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_NOTIF_ATTR(x_nid, l_neg_assess);

            wf_Notification.SetAttrText(x_nid, 'TP_TIME_ZONE',x_timezone_disp);
            wf_Notification.SetAttrDate(x_nid, 'CANCEL_DATE', x_new_cancel_date);

           IF (p_event_title is not null) THEN
                    wf_Notification.SetAttrText(x_nid, 'EVENT_TITLE', p_event_title);
                    wf_Notification.SetAttrText(x_nid, 'AUCTION_CANCELED_SUB',
                                                getMessage('PON_AUC_WF_CANCEL_EVENT_SUB', x_msg_suffix,
                                       'DOC_NUMBER', p_doc_number_dsp,
                                     'AUCTION_TITLE', p_auction_title,
                                                 'EVENT_TITLE', p_event_title));
            ELSE
                    wf_Notification.SetAttrText(x_nid, 'AUCTION_CANCELED_SUB',
                                                getMessage('PON_AUC_WF_AUC_CANCEL_SUB', x_msg_suffix,
                                                   'DOC_NUMBER', p_doc_number_dsp,
                                               'AUCTION_TITLE', p_auction_title));
            END IF;

          IF (empty_reason(x_cancel_reason) = 'N') then
              wf_Notification.SetAttrText(x_nid, 'CANCEL_REASON', x_cancel_reason);
          END IF;

       ELSIF (p_action_code = 'DISQUALIFY_BID') then

            --SLM UI Enhancement
            PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_NOTIF_ATTR(x_nid, l_neg_assess);

            wf_Notification.SetAttrText(x_nid, 'TP_TIME_ZONE', x_timezone_disp);

            -- convert the disqualify date to user's timezone
        x_new_disqualify_date :=  PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_disqualify_date,x_oex_timezone,x_timezone);

        wf_Notification.SetAttrDate(x_nid, 'DISQUALIFY_DATE', x_new_disqualify_date);
            wf_Notification.SetAttrText(x_nid, 'BID', x_bid_name);
          wf_Notification.SetAttrText ( x_nid, 'PON_WF_AUC_DSQ_OTH_SUB',
                                          getMessage('PON_WF_AUC_DSQ_OTH_SUB', x_msg_suffix,
                                            'DOC_NUMBER', p_doc_number_dsp,
                                           'AUCTION_TITLE', p_auction_title));
     END IF;

END;


PROCEDURE NEW_ROUND_BIDDERS_NOT_INVITED(p_itemtype    in varchar2, -- {
                                 p_itemkey    in varchar2,
                                     actid           in number,
                                     uncmode        in varchar2,
                                     resultout       out NOCOPY varchar2) IS

-- Bug 3824928: Added outer join to get previous invited bidder that does
-- not have a contact specified and did not place a bid or previous
-- invited bidder that has a contact specified and did not place a bid.
--
-- This cursor now returns all the previous round bidders to send this notifn.
CURSOR c_prev_round_bidders (x_doc_header_id_prev_round NUMBER, x_role_name VARCHAR2)
IS
-- First pick all the invited suppliers from bidding parties table.

--
-- First sql of the cursor can have multiple fnd_user entries for a given trading
-- partner contact id and thus it has virtually no way to remove the rows with
-- duplicate TPC Ids. We are assuming that only one fnd_user will be alive after
-- a party merge
--
SELECT fu.user_name user_name,
       trading_partner_id   party_id,
       trading_partner_name party_name,
       DECODE(vendor_site_code, '-1', NULL, vendor_site_code) vendor_site_code,
       vendor_site_id
FROM   pon_bidding_parties pbp,
     fnd_user fu
WHERE  auction_header_id = x_doc_header_id_prev_round
AND    fu.person_party_id = pbp.trading_partner_contact_id
AND    nvl(fu.end_date, sysdate+1) > sysdate
UNION
-- Then pick all the additional contacts from bidding parties table.
SELECT DISTINCT(wlur.user_name)  user_name,
       pbp.trading_partner_id   party_id,
       pbp.trading_partner_name party_name,
       DECODE(pbp.vendor_site_code, '-1', NULL, pbp.vendor_site_code) vendor_site_code,
       pbp.vendor_site_id
FROM   pon_bidding_parties pbp,
     wf_local_user_roles wlur
WHERE  pbp.auction_header_id = x_doc_header_id_prev_round
AND    wlur.role_name = x_role_name
AND    wlur.user_name = pbp.wf_user_name
AND pbp.trading_partner_id is not null --leave out requested suppliers
UNION
-- Then pick all the suppliers who have bid.
-- The responses for negotiation may or may not be invited.
SELECT DISTINCT(wlur.user_name)  user_name,
       pbh.trading_partner_id    party_id,
     pbh.trading_partner_name  party_name,
       DECODE(pbh.vendor_site_code, '-1', NULL, pbh.vendor_site_code) vendor_site_code,
       pbh.vendor_site_id
FROM   wf_local_user_roles wlur,
       pon_bid_headers pbh
WHERE  wlur.role_name = x_role_name
AND    x_doc_header_id_prev_round  = pbh.auction_header_id
AND    wlur.user_name = pbh.trading_partner_contact_name(+);

CURSOR c2_inv_list (x_doc_header_id NUMBER) IS
    select trading_partner_id,vendor_site_id
    from   pon_bidding_parties pbp
    where  auction_header_id = x_doc_header_id;

x_itemtype                 VARCHAR2(20) := 'PONPBLSH';
x_itemkey                 VARCHAR2(60);
x_process_name              VARCHAR2(30) := 'NEW_ROUND_NOT_INVITED_BIDDERS';
x_flag                    VARCHAR2(1);
x_doc_header_id            NUMBER;
x_doc_header_id_prev_round NUMBER;
x_bidder_found             BOOLEAN;
x_member                 BOOLEAN;
x_new_member               BOOLEAN;
x_user_name              VARCHAR2(100);
x_bidder_name              VARCHAR2(440);
x_contact_id               NUMBER;
x_language_code            VARCHAR2(60);
x_doctype_group_name       VARCHAR2(80);
x_app                      VARCHAR2(20);
x_msg_suffix            VARCHAR2(3) := '';
x_progress               VARCHAR2(3);
x_sequence             NUMBER;

x_role_name              VARCHAR2(240);
x_trading_partner_id     NUMBER;
l_vendor_site_id        NUMBER;
x_invitation_id           NUMBER;

x_oex_header              VARCHAR2(2000);
x_oex_footer              VARCHAR2(2000);
x_status                  VARCHAR2(10);
x_exception_msg           VARCHAR2(100);
x_prev_supplier_name      VARCHAR2(240);
x_prev_supplier_site_code PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE;
x_prev_supplier_site_id   PO_VENDOR_SITES_ALL.VENDOR_SITE_ID%TYPE;
x_prev_trading_partner_id NUMBER;
x_bidder_username         VARCHAR2(60);
x_oex_operation           VARCHAR2(640);
x_auction_title           VARCHAR2(640);
x_auction_owner_tp_name   VARCHAR2(640);
x_tp_display_name         VARCHAR2(640);
x_auction_contact_id      NUMBER;
x_person_party_id         NUMBER;
x_language             VARCHAR2(60) := null;
x_territory_code          VARCHAR2(30) := 'AMERICA';
x_doc_number_dsp          PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
x_startdate               DATE;
x_enddate                 DATE;
x_auctioneer_user_name    PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
x_add_contact_email       PON_BIDDING_PARTIES.ADDITIONAL_CONTACT_EMAIL%TYPE;
x_preview_date       DATE;
x_preview_date_notspec    VARCHAR2(240);
x_timezone1_disp          VARCHAR2(240);
x_newstarttime            DATE;
x_newendtime              DATE;
x_newpreviewtime          DATE;
x_oex_timezone          VARCHAR2(80);
x_timezone    VARCHAR2(80);
x_timezone_disp VARCHAR2(240);
x_staggered_closing_interval NUMBER;
x_staggered_close_note   VARCHAR2(1000);

l_origin_user_name       fnd_user.user_name%TYPE;

-- bug 8613271
x_supplier_sequence NUMBER;
x_emd_received_flag VARCHAR2(1);
x_refund_supplier_msg VARCHAR2(2000);


BEGIN

    x_doc_header_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => 'AUCTION_ID');

    -- Bug 8992789
    IF (IS_INTERNAL_ONLY(x_doc_header_id)) THEN
      RETURN;
    END IF;

    l_origin_user_name := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                itemkey  => p_itemkey,
                                                aname    => 'ORIGIN_USER_NAME');

    x_doctype_group_name := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                      aname    => 'DOC_INTERNAL_NAME');

    x_startdate := wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                    aname    => 'AUCTION_START_DATE');

  x_enddate   := wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => 'AUCTION_END_DATE');

--    x_auctioneer_user_name := wf_engine.GetItemAttrText (itemtype => p_itemtype,
--                                                     itemkey  => p_itemkey,
--                                                       aname    => 'PREPARER_TP_CONTACT_NAME');

    x_preview_date := wf_engine.GetItemAttrDate (itemtype   => p_itemtype,
                                                 itemkey    => p_itemkey,
                                                 aname      => 'PREVIEW_DATE');

    select auction_header_id_prev_round, trading_partner_contact_name,
           staggered_closing_interval
    into x_doc_header_id_prev_round, x_auctioneer_user_name,
         x_staggered_closing_interval
    from pon_auction_headers_all where auction_header_id = x_doc_header_id;

    select wf_role_name
    into x_role_name
    from pon_auction_headers_all
    where auction_header_id = x_doc_header_id_prev_round;

    FOR prevBidder IN c_prev_round_bidders(x_doc_header_id_prev_round, x_role_name) LOOP

  x_bidder_found := false;
  x_prev_supplier_name := prevBidder.party_name;
    x_prev_supplier_site_code := prevBidder.vendor_site_code;
    x_prev_supplier_site_id := prevBidder.vendor_site_id;
  x_prev_trading_partner_id := prevBidder.party_id;

  open c2_inv_list(x_doc_header_id);
  LOOP

      fetch c2_inv_list into  x_trading_partner_id, l_vendor_site_id;

      if c2_inv_list%NOTFOUND then
    exit;
      end if;

        -- Check if the combination of Trading-Partner-Id and Vendor-Site-Id
        -- are not existing in the current round.
    if (x_prev_trading_partner_id = x_trading_partner_id AND
            x_prev_supplier_site_id = l_vendor_site_id  ) then
      x_bidder_found := true;
      exit;
    end if;

      END LOOP;

  if (NOT x_bidder_found) then

      -- this bidder has not been invited to the new round
      -- Get next value in sequence for itemkey

      SELECT pon_auction_wf_publish_s.nextval
      INTO   x_sequence
      FROM   dual;

      x_itemkey := (p_itemkey||'-'||to_char(x_sequence));

      wf_engine.CreateProcess(itemtype => x_itemtype,
                              itemkey  => x_itemkey,
                              process  => x_process_name);

      --
      -- Set all the item attributes
      --

        wf_engine.SetItemAttrDate   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'AUCTION_START_DATE',
                                   avalue     => x_startdate);

        wf_engine.SetItemAttrDate   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'AUCTION_END_DATE',
                                   avalue     => x_enddate);

        wf_engine.SetItemAttrDate   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PREVIEW_DATE',
                                   avalue     => x_preview_date);

        wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PREPARER_TP_CONTACT_NAME',
                                   avalue     => x_auctioneer_user_name);

        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'BIDDER_TP_NAME',
                                   avalue     => x_prev_supplier_name);

        --Bug 16666395 modified from vendor_site_code to address
	wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'BIDDER_TP_ADDRESS_NAME',
                                   avalue     => GET_VENDOR_SITE_ADDRESS(x_prev_supplier_site_id));

        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                             itemkey    => x_itemkey,
                             aname      => 'ORIGIN_USER_NAME',
                             avalue     => l_origin_user_name);


      wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'AUCTION_ID',
                                   avalue     => x_doc_header_id); /* using auction_id instead of
                                                                       auction_number as a standard
                                                                       across item types */

        x_doc_number_dsp := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                 itemkey  => p_itemkey,
                                                 aname    => 'DOC_NUMBER');

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_NUMBER',
                                 avalue     => x_doc_number_dsp);

      x_auction_title := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname    => 'AUCTION_TITLE');


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_TITLE',
                                 avalue     => replaceHtmlChars(x_auction_title));

      x_auction_owner_tp_name := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'PREPARER_TP_NAME');

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PREPARER_TP_NAME',
                                 avalue     => x_auction_owner_tp_name);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'DOC_INTERNAL_NAME',
                               avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                                          itemkey  => p_itemkey,
                                                                          aname    => 'DOC_INTERNAL_NAME'));


            BEGIN
                 x_staggered_close_note := NULL;
                 IF x_staggered_closing_interval IS NOT NULL THEN
                      x_staggered_close_note := wf_core.newline || wf_core.newline ||
                                                getMessage('PON_STAGGERED_CLOSE_NOTIF_MSG') ||
                                                wf_core.newline || wf_core.newline;
                 END IF;
                 wf_engine.SetItemAttrText( itemtype => x_itemtype,
                                            itemkey  => x_itemkey,
                                            aname    => 'STAGGERED_CLOSE_NOTE',
                                            avalue   => x_staggered_close_note);
            EXCEPTION
                 WHEN OTHERS THEN
                        NULL;
            END;

            begin

              wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                               itemkey    => x_itemkey,
                                               aname      => '#WFM_HTMLAGENT',
                                               avalue     => pon_wf_utl_pkg.get_base_external_supplier_url);
            exception when others then
              null;
            end;

        -- Use the language of the user to send the notification.

        x_bidder_username := prevBidder.user_name;

        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'BIDDER_TP_CONTACT_NAME',
                                 avalue     => x_bidder_username);


        IF x_bidder_username is not null THEN
         PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_bidder_username,x_language_code);
      END IF;

        -- Bug 3824928 Added code below
        begin
              if(x_language_code = null) then
                           select language into x_language_code
                           from wf_users where name = x_bidder_username;
              end if;
        exception
              when others then
                   x_language_code := null;

        end;

        x_oex_timezone := Get_Oex_Time_Zone;

        --
        -- Get the user's time zone
        --
      x_timezone := Get_Time_Zone(x_bidder_username);

        --
        -- Make sure that it is a valid time zone
        --

        IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 0) THEN
          x_timezone := x_oex_timezone;
        END IF;

        -- Create new timezone
        IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN
            x_newstarttime   := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_startdate,x_oex_timezone,x_timezone);
            x_newendtime     := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_enddate,x_oex_timezone,x_timezone);
            x_newpreviewtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone);
        ELSE
            x_newstarttime   := x_startdate;
          x_newendtime     := x_enddate;
            x_newpreviewtime := x_preview_date;
        END IF;

        x_timezone_disp := Get_TimeZone_Description(x_timezone, x_language_code);

        IF (x_preview_date IS NULL) THEN
            x_timezone1_disp := null;
        ELSE
            x_timezone1_disp := x_timezone_disp;
        END IF;

      wf_engine.SetItemAttrDate   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'AUCTION_START_DATE_TZ',
                                   avalue     => x_newstarttime);

        wf_engine.SetItemAttrDate   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'AUCTION_END_DATE_TZ',
                                   avalue     => x_newendtime);

        wf_engine.SetItemAttrDate   (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PREVIEW_DATE_TZ',
                                   avalue     => x_newpreviewtime);


        -- IF (x_add_contact_email is not null) then we need to send a notification
        -- to the additional contact as well (Bug 3824928: this can be deleted. We don't need to check separately
        -- for additional contact as prev_round_bidders cursor will return additional contact even when he is
        -- not associated to a tp contact id (new outer joins added to the query)

      x_bidder_name := null;
          x_member := true;

      begin
        -- Bug 3824928: Deleted IF condition that tested if trading_partner_id is not null
            -- since the condition is always true.
      select party_name into x_bidder_name
      from hz_parties where party_id = x_prev_trading_partner_id;

      exception
    when others then
    null;
      end;

      if (x_bidder_name is null or x_bidder_name = '') then
        begin
    select party_name into x_bidder_name
    from hz_parties where
    party_id = (select person_party_id from fnd_user where user_name = prevBidder.user_name);
        exception
    when others then
    x_bidder_name := prevBidder.user_name;
        end;
      end if;

      if (x_bidder_name is null or x_bidder_name = '') then
    x_bidder_name := prevBidder.user_name;
      end if;

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                           itemkey    => x_itemkey,
                           aname      => 'TP_DISPLAY_NAME',
                           avalue     => x_bidder_name);

      x_tp_display_name := x_bidder_name;

        -- Set the userenv language so the message token (attribute) values that we retrieve
      -- using the getMessage call return the message in the correct language => x_language_code

     SET_SESSION_LANGUAGE(null, x_language_code);

     --Bug 6472383 : Shifted the setting of preview date to this place so that the recipient's language, instead
     --of the sender's language is taken into account when setting the preview date to 'Not Specified'

     IF (x_newpreviewtime is not null) THEN
        wf_engine.SetItemAttrDate (itemtype        => x_itemtype,
                                                   itemkey        => x_itemkey,
                                                   aname        => 'PREVIEW_DATE_TZ',
                                                   avalue        => x_newpreviewtime);

        wf_engine.SetItemAttrText (itemtype        => x_itemtype,
                                                   itemkey        => x_itemkey,
                                                   aname        => 'TP_TIME_ZONE1',
                                                   avalue        => x_timezone1_disp);

        wf_engine.SetItemAttrText (itemtype        => x_itemtype,
                                                   itemkey        => x_itemkey,
                                                   aname        => 'PREVIEW_DATE_NOTSPECIFIED',
                                                   avalue        => null);
     ELSE
        wf_engine.SetItemAttrDate (itemtype        => x_itemtype,
                                                   itemkey        => x_itemkey,
                                                   aname        => 'PREVIEW_DATE_TZ',
                                                   avalue        => null);

        wf_engine.SetItemAttrText (itemtype        => x_itemtype,
                                                    itemkey        => x_itemkey,
                                                   aname        => 'TP_TIME_ZONE1',
                                                    avalue        => x_timezone1_disp);

        wf_engine.SetItemAttrText (itemtype        => x_itemtype,
                                                   itemkey        => x_itemkey,
                                                   aname        => 'PREVIEW_DATE_NOTSPECIFIED',
                                                   avalue        => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));
      END IF;

      x_msg_suffix := GET_MESSAGE_SUFFIX (x_doctype_group_name);

     /*added for bug 8613271
     * notification sent to non invited suppliers should
     * contain message that previously paid EMD amount will
     * be repaid.
     */
      BEGIN
          x_refund_supplier_msg :=  getMessage('PON_EMD_REFUND_N_RND_NOINV');

    SELECT sequence INTO x_supplier_sequence FROM pon_bidding_parties
    WHERE auction_header_id = x_doc_header_id_prev_round
    AND TRADING_PARTNER_ID = x_prev_trading_partner_id
    AND vendor_site_id = x_prev_supplier_site_id;


    SELECT 'Y' INTO x_emd_received_flag FROM pon_emd_transactions
    WHERE auction_header_id = x_doc_header_id_prev_round
    AND SUPPLIER_SEQUENCE = x_supplier_sequence
     AND STATUS_LOOKUP_CODE = 'RECEIVED';

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'REFUND_SUPPLIER',
                                 avalue     => x_refund_supplier_msg);
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;

  --end of change for bug 8613271


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NON_INVITE_NEW_ROUND_START_SUB',
                                 avalue     => getMessage('PON_AUC_WF_PUB_NEWRND_NI_S', x_msg_suffix,
                                                            'DOC_NUMBER', x_doc_number_dsp,
                                      'AUCTION_TITLE', x_auction_title));

      --Bug 8446265 Modifications
            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_NON_INV_NEW_RND_START_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_PON_ARI_UNINVITED_BODY/'||x_itemtype ||':' ||x_itemkey
                               );


    -- Bug 4295915: Set the  workflow owner
            wf_engine.SetItemOwner(itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   owner    => fnd_global.user_name);

      wf_engine.StartProcess(itemtype => x_itemtype,
                             itemkey  => x_itemkey);
        end if;

  close c2_inv_list;

    END LOOP;

    UNSET_SESSION_LANGUAGE;

END;  -- NEW_ROUND_BIDDERS_NOT_INVITED }



PROCEDURE REGISTERED_BIDDER(itemtype    in varchar2,
                 itemkey    in varchar2,
                            actid           in number,
                            uncmode    in varchar2,
                            resultout       out NOCOPY varchar2) IS

x_flag   VARCHAR2(1);
BEGIN

    x_flag := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'REGISTERED');


    IF (x_flag = 'Y') THEN
  resultout := 'Y';
    ELSE
  resultout := 'N';

    END IF;

END;

PROCEDURE CREATE_LOCAL_ROLES(   itemtype  in varchar2,
        itemkey    in varchar2,
                                actid           in number,
                                uncmode          in varchar2,
                                resultout       out NOCOPY varchar2) IS

x_role_name      VARCHAR2(30);
x_user_name      VARCHAR2(100);
x_role_display_name    VARCHAR2(30);
x_user_display_name    VARCHAR2(30);
x_note_to_new_bidder    VARCHAR2(2000);
x_auction_header_id      NUMBER;
x_progress      VARCHAR2(3);
x_sequence      NUMBER;
x_user_orig_system    VARCHAR2(30);
x_user_orig_system_id    NUMBER;
x_role_orig_system    VARCHAR2(30) := 'WF_LOCAL_ROLES';
x_role_orig_system_id    NUMBER := 0;
x_person_party_id               NUMBER;

BEGIN
    x_progress := '010';

    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AUCTION_ID');

    x_progress := '020';

    --
    -- Create a role for all bidders in this auction.
    --

           SELECT pon_auction_wf_role_s.nextval
    INTO   x_sequence
    FROM   dual;

    x_role_name := ('WF_PON_ROLE_'||to_char(x_auction_header_id)||'_'||to_char(x_sequence));

    x_progress := '021';

    WF_DIRECTORY.CreateAdHocRole(x_role_name,
         x_role_name,
               'AMERICAN',
               'AMERICA',
         'Oracle Exchange Bidder '||to_char(x_auction_header_id),
               'MAILHTML',
               null,
               null,
               null,
               'ACTIVE',
         null);

    UPDATE pon_auction_headers_all set
    wf_role_name = x_role_name
    WHERE auction_header_id = x_auction_header_id;

    wf_engine.SetItemAttrText (itemtype   => itemtype,
                                itemkey    => itemkey,
                               aname      => 'NEW_BIDDER_ROLE',
                         avalue     => x_role_name);
   x_progress := '030';

END;


PROCEDURE POPULATE_ROLE_WITH_SUPPLIERS (itemtype         IN VARCHAR2,
                                        itemkey          IN VARCHAR2,
                                        actid            IN NUMBER,
                                        uncmode          IN VARCHAR2,
                                        resultout        OUT NOCOPY VARCHAR2) IS

x_role_name            VARCHAR2(30);
x_prev_doc_role_name       VARCHAR2(30);
x_user_name            VARCHAR2(100);
x_auction_header_id    NUMBER;
x_progress             VARCHAR2(3);

l_users   WF_DIRECTORY.UserTable;

CURSOR suppliers IS
    select user_name
    from   wf_user_roles
    where  role_name = x_prev_doc_role_name;

BEGIN

    x_progress := '010';

    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AUCTION_ID');

    x_progress := '20';

    select wf_role_name
    into   x_prev_doc_role_name
    from   pon_auction_headers_all
    where  auction_header_id = (select auction_header_id_prev_amend
                                from   pon_auction_headers_all
                                where  auction_header_id = x_auction_header_id);


    x_progress := '30';

    x_role_name := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                              itemkey    => itemkey,
                                              aname      => 'NEW_BIDDER_ROLE');

    x_progress := '40';

    FOR supplier IN suppliers LOOP

        x_user_name := supplier.user_name;

        /*WF_DIRECTORY.AddUsersToAdHocRole(x_role_name,
                                         x_user_name);*/
		-- Modified from  AddUsersToAdHocRole to AddUsersToAdHocRole2 for bug 11067310
 	    if (x_user_name is NOT NULL) then
 	        string_to_userTable(x_user_name, l_users);
 	        WF_DIRECTORY.AddUsersToAdHocRole2(x_role_name,
 	                                    l_users);
 	    end if;

    END LOOP;

    x_progress := '50';

END;


PROCEDURE POPULATE_ROLE_WITH_INVITEES (itemtype    IN VARCHAR2,
                    itemkey    IN VARCHAR2,
                    actid             IN NUMBER,
                    uncmode          IN VARCHAR2,
                    resultout         OUT NOCOPY VARCHAR2) IS

x_role_name      VARCHAR2(30);
x_user_name      VARCHAR2(100);
x_role_display_name    VARCHAR2(30);
x_user_display_name    VARCHAR2(30);
x_note_to_new_bidder    VARCHAR2(2000);
x_auction_header_id    NUMBER;
x_progress      VARCHAR2(10);
x_sequence      NUMBER;
x_user_orig_system    VARCHAR2(30);
x_user_orig_system_id    NUMBER;
x_role_orig_system    VARCHAR2(30) := 'WF_LOCAL_ROLES';
x_role_orig_system_id    NUMBER := 0;
x_person_party_id               NUMBER;
x_bidder_count      NUMBER;
x_contact_notif_pref    VARCHAR2(4000);
x_contact_lang      VARCHAR2(4000);
x_contact_territory    VARCHAR2(4000);

x_auctioneer_user_name         VARCHAR2(100);
x_language_code                VARCHAR2(30) := null;
x_nls_language                 VARCHAR2(60) := 'AMERICAN';
x_territory_code               VARCHAR2(30) := 'AMERICA';
x_nls_territory                VARCHAR2(60);

l_auctioneer_nls_language      fnd_languages.nls_language%TYPE;
l_auctioneer_nls_territory     fnd_territories.nls_territory%TYPE;
l_users WF_DIRECTORY.UserTable;

CURSOR new_bidders IS
    select pbp.trading_partner_contact_name,
     pbp.trading_partner_contact_id,
     pbp.trading_partner_name,
     pbp.trading_partner_id,
     pbp.additional_contact_email,
           pbp.vendor_site_id,
           pbp.requested_supplier_id,
           pbp.requested_supplier_contact_id,
           pcr.email_address rs_contact_email
    from pon_bidding_parties pbp, pos_contact_requests pcr
    where pbp.auction_header_id = x_auction_header_id
    and pbp.requested_supplier_contact_id = pcr.contact_request_id (+);

CURSOR c_user_name IS
    select user_name
  from fnd_user where person_party_id = (select   trading_partner_contact_id
                                       from pon_auction_headers_all
                                       where auction_header_id = x_auction_header_id)
        and nvl(end_date,sysdate+1) > sysdate
        and rownum = 1;

BEGIN
    x_progress := '010';
    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AUCTION_ID');

    x_progress := '020';
    x_role_name := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                          itemkey    => itemkey,
                                       aname      => 'NEW_BIDDER_ROLE');
    x_progress := '021';

    OPEN c_user_name;
    FETCH c_user_name
    INTO x_auctioneer_user_name;
    CLOSE c_user_name;

    IF x_auctioneer_user_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_PREFERENCES(x_auctioneer_user_name,x_language_code,x_territory_code);
    END IF;

   -- Bug 3824928: Store the auctioneer's language and territory in new
   -- variables so that they can be used later.

    select NLS_LANGUAGE into l_auctioneer_nls_language
    from fnd_languages
    where language_code = x_language_code;

    select nls_territory into l_auctioneer_nls_territory
    from   fnd_territories
    where  territory_code = x_territory_code;

    FOR bidder IN new_bidders LOOP

        -- Bug 3824928: Handle the case where the contact is present (removed earlier
        -- if-else)

     IF bidder.trading_partner_contact_id IS NOT NULL  -- {
     THEN

    x_person_party_id := bidder.trading_partner_contact_id;

      BEGIN
        select user_name
      into x_user_name
      from fnd_user where person_party_id = x_person_party_id
            and nvl(end_date, sysdate+1) > sysdate;
      EXCEPTION
        when too_many_rows then
           if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
               if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                         fnd_log.string(log_level => fnd_log.level_unexpected,
                                        module    => 'pon.plsql.pon_auction_pkg.populate_role_with_invitees',
                                        message   => 'Multiple Users found for person_party_id:'|| x_person_party_id);
               end if;
          end if;

           select user_name
           into x_user_name
           from fnd_user
           where person_party_id = x_person_party_id
           and nvl(end_date, sysdate+1) > sysdate
           and rownum=1;

      END;


    x_user_orig_system := 'FND_USR';
          begin
            select to_char(user_id)
            into x_user_orig_system_id
            from fnd_user
            where user_name = x_user_name;
          exception when others then
        x_user_orig_system_id := 0;
          end;

  select count(*)
  into x_bidder_count
  from wf_local_user_roles
  where role_name = x_role_name
  and user_name = x_user_name;

  if (x_bidder_count < 1) then

  -- Added for the bug#8847938 to remove the space as delimitter in user name
		 if (x_user_name is NOT NULL) then
 	               string_to_userTable(x_user_name, l_users);

 	         /*WF_DIRECTORY.AddUsersToAdHocRole(x_role_name,
 	                                          x_user_name);  */
 	     WF_DIRECTORY.AddUsersToAdHocRole2(x_role_name,
 	                                          l_users);
	    end if;

  end if;
   END IF;-- end IF bidder.trading_partner_contact_id IS NOT NULL }
   IF (bidder.additional_contact_email IS NOT NULL) THEN

    -- add new user to local users and also add to the role.

    -- Bug 3824928: If trading partner contact is not there then prevent
    -- this SELECT from erroring out
    -- The steps below try to set up the user for the additional contact
    -- email so that they have the same settings as the existing contact.
    -- However, if the row in pon_bidding_parties does not have a contact,
    -- then the additional contact user inherits the settings of the
    -- auctioneer

    IF bidder.trading_partner_contact_id IS NOT NULL  --{
    THEN  --<


    select NOTIFICATION_PREFERENCE, LANGUAGE, TERRITORY
    into   x_contact_notif_pref, x_contact_lang, x_contact_territory
    from wf_users where name = x_user_name;

    -- Get NLS_LANGUAGE and NLS_TERRITORY for the user corresponding to additional contact

    IF x_user_name is not null THEN
             PON_PROFILE_UTIL_PKG.GET_WF_PREFERENCES(x_user_name ,x_language_code,x_territory_code);
          END IF;

         x_progress := '021';


         begin
         select NLS_LANGUAGE into x_nls_language
         from fnd_languages
         where language_code = x_language_code;

         select nls_territory into x_nls_territory
         from   fnd_territories
         where  territory_code = x_territory_code;
       exception
        when others then
             x_nls_language := 'AMERICAN';
             x_nls_territory := 'AMERICA';
          end;

     ELSE
      -- Get auctioneer's settings

                x_nls_language := l_auctioneer_nls_language;
                x_nls_territory:= l_auctioneer_nls_territory;
     END IF;--}

     SELECT pon_auction_wf_bidder_s.nextval
             INTO   x_sequence
             FROM   dual;

      x_user_name := ('WF_PON_ADD_USER_'||to_char(x_sequence));

       x_progress := '022';

       -- Create an adhoc user for the additional contact

    WF_DIRECTORY.CreateAdHocUser(x_user_name,
                     bidder.additional_contact_email,
                     x_nls_language,
                     x_nls_territory,
                     'Oracle Exchange Additional Bidder '||to_char(x_auction_header_id),
                     'MAILHTML',
                     bidder.additional_contact_email,
                     null,
                     'ACTIVE',
                     null);
    x_progress := '023';
    UPDATE pon_bidding_parties set
        wf_user_name = x_user_name
    WHERE auction_header_id = x_auction_header_id
    AND   trading_partner_id = bidder.trading_partner_id
      AND   vendor_site_id     = bidder.vendor_site_id;

    -- Also insert into the role


-- Added for the bug#8847938 to remove the space as delimitter in user name
              /* WF_DIRECTORY.AddUsersToAdHocRole(x_role_name,
 	                                            x_user_name);  */
 	           if (x_user_name is NOT NULL) then
 	                     string_to_userTable(x_user_name, l_users);

 	       WF_DIRECTORY.AddUsersToAdHocRole2(x_role_name,
 	                                          l_users);
 	       end if;

  end if;  -- (bidder.additional_contact_email IS NOT NULL)

    -- add requested suppliers
    if (bidder.trading_partner_id is null and
        bidder.requested_supplier_contact_id is not null) then
   -- {
      -- Get auctioneer's settings
      x_nls_language := l_auctioneer_nls_language;
      x_nls_territory:= l_auctioneer_nls_territory;

      -- Get next bidder from sequence
      SELECT pon_auction_wf_bidder_s.nextval
      INTO x_sequence
      FROM dual;

      x_user_name := ('WF_PON_ADD_USER_'||to_char(x_sequence));
      x_progress := '022_REQ';

      -- Create an adhoc user for the requested_supplier
      -- Bug 17356448 - User email id as display name so that display name will be used in
      -- TO field in notification
      WF_DIRECTORY.CreateAdHocUser(x_user_name,
                                 --x_user_name,
                                 bidder.rs_contact_email,
                                 x_nls_language,
                                 x_nls_territory,
                                 'Oracle Exchange Requested Bidder'||to_char(x_auction_header_id),
                                 'MAILHTML',
                                 bidder.rs_contact_email,
                                 null,
                                 'ACTIVE',
                                 null);
      x_progress := '023_REQ';

      -- record wf_user_name in pon_bidding_parties
      UPDATE pon_bidding_parties
         set wf_user_name = x_user_name
       WHERE auction_header_id = x_auction_header_id
         AND requested_supplier_id = bidder.requested_supplier_id;

      x_progress := '024_REQ';

      -- Also insert into the role
      --WF_DIRECTORY.AddUsersToAdHocRole(x_role_name, x_user_name);

 	           -- Added for the bug#8847938 to remove the space as delimitter in user name
 	           if (x_user_name is NOT NULL) then
 	                     string_to_userTable(x_user_name, l_users);

 	       WF_DIRECTORY.AddUsersToAdHocRole2(x_role_name,
 	                                          l_users);
 	       end if;

    end if; --} tp_id == null and requested_supplier_contact_id != null

   END LOOP;

   x_progress := '030';

END;



PROCEDURE REACHED_AUCTION_START_DATE (  itemtype  in varchar2,
          itemkey    in varchar2,
                                  actid           in number,
                                  uncmode          in varchar2,
                                  resultout       out NOCOPY varchar2) IS
x_start_date  DATE;
x_progress  VARCHAR2(3);
x_reached_date  VARCHAR2(1) := 'N';

BEGIN

    x_progress := '010';

    x_start_date := wf_engine.GetItemAttrDate (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'AUCTION_NOTIFICATION_DATE');
    x_progress := '020';

    IF x_start_date <= SYSDATE
    THEN
       x_reached_date := 'Y';
    END IF;

    x_progress := '030';

    IF (x_reached_date = 'Y') THEN
  resultout := 'Y';
    ELSE
  resultout := 'N';

    END IF;

END;

PROCEDURE REACHED_AUCTION_END_DATE (  itemtype  in varchar2,
          itemkey    in varchar2,
                                  actid           in number,
                                  uncmode          in varchar2,
                                  resultout       out NOCOPY varchar2) IS

x_end_date  DATE;
x_progress  VARCHAR2(3);
x_reached_date  VARCHAR2(1) := 'N';

BEGIN

    x_progress := '010';

    x_end_date := wf_engine.GetItemAttrDate (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'AUCTION_END_DATE');
    x_progress := '020';

    IF x_reached_date <= SYSDATE
    THEN
      x_reached_date := 'Y';
    END IF;

    x_progress := '030';

    IF (x_reached_date = 'Y') THEN
  resultout := 'Y';
    ELSE
  resultout := 'N';

    END IF;

END;

PROCEDURE DOES_BIDDER_LIST_EXIT(  itemtype  in varchar2,
          itemkey  in varchar2,
                             actid         in number,
                                uncmode  in varchar2,
                                  resultout     out NOCOPY varchar2) IS

x_flag     VARCHAR2(1);
x_progress  VARCHAR2(3);

BEGIN

   x_progress := '010';

   x_flag := wf_engine.GetItemAttrText (itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'BIDDER_LIST_FLAG');

   x_progress := '020';

   IF (x_flag = 'Y') THEN
     resultout := 'Y';
   ELSE
     resultout := 'N';
   END IF;

END;


PROCEDURE NON_BID_LIST_BIDDERS(  itemtype    in varchar2,
           itemkey    in varchar2,
                       actid           in number,
                       uncmode    in varchar2,
                       resultout       out NOCOPY varchar2) IS

BEGIN
null;
END;



PROCEDURE NOTIFY_BIDDER_LIST_START(itemtype  in varchar2,
        itemkey    in varchar2,
                         actid           in number,
                            uncmode    in varchar2,
                              resultout       out NOCOPY varchar2) IS

x_notification_id  NUMBER;
x_progress    VARCHAR2(3);

BEGIN

    x_progress := '010';


    email_list(p_itemtype    => itemtype,
         p_itemkey    => itemkey,
         p_actid      => actid,
         p_notification_id  => x_notification_id);

    x_progress := '020';

END;

PROCEDURE NOTIFY_BIDDER_LIST_CANCEL(  itemtype  in varchar2,
        itemkey    in varchar2,
                         actid           in number,
                            uncmode    in varchar2,
                              resultout       out NOCOPY varchar2) IS
BEGIN
null;
END;


PROCEDURE NOTIFY_NON_BIDDER_LIST_CANCEL(  itemtype  in varchar2,
        itemkey    in varchar2,
                         actid           in number,
                            uncmode    in varchar2,
                              resultout       out NOCOPY varchar2) IS

x_notification_id  NUMBER;
x_progress    VARCHAR2(3);

BEGIN

    x_progress := '010';


    email_bidders(p_itemtype    => itemtype,
             p_itemkey    => itemkey,
               p_actid    => actid,
            p_message_name  => 'AUCTION_CANCELLED',
           p_notification_id  => x_notification_id);

    x_progress := '020';

END;

PROCEDURE NOTIFY_BIDDER_LIST_END(  itemtype  in varchar2,
        itemkey    in varchar2,
                         actid           in number,
                            uncmode    in varchar2,
                              resultout       out NOCOPY varchar2) IS

BEGIN
null;
END;

PROCEDURE NOTIFY_NON_BIDDER_LIST_END(  itemtype  in varchar2,
        itemkey    in varchar2,
                         actid           in number,
                            uncmode    in varchar2,
                              resultout       out NOCOPY varchar2) IS


x_notification_id  NUMBER;
x_progress    VARCHAR2(3);

BEGIN

    x_progress := '010';


    email_bidders(p_itemtype    => itemtype,
             p_itemkey    => itemkey,
               p_actid    => actid,
            p_message_name  => 'AUCTION_ENDED',
           p_notification_id  => x_notification_id);

    x_progress := '020';

END;

PROCEDURE CHECK_AUCTION_BIDDER
          (p_trading_partner_contact_id IN NUMBER,
           p_auction_header_id IN NUMBER,
           x_return_status OUT NOCOPY NUMBER)
IS

x_progress              VARCHAR2(3);
x_bidder_user_name      VARCHAR2(100);
x_role_name             VARCHAR2(30);

BEGIN

    x_progress := '010';

    select wf_role_name
    into   x_role_name
    from   pon_auction_headers_all
    where  auction_header_id = p_auction_header_id;

    BEGIN
      select user_name
      into   x_bidder_user_name
      from   fnd_user
      where  person_party_id= p_trading_partner_contact_id
      and nvl(end_date, sysdate+1) > sysdate;
    EXCEPTION
       when too_many_rows then
          if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
               if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                         fnd_log.string(log_level => fnd_log.level_unexpected,
                                        module    => 'pon.plsql.pon_auction_pkg.check_auction_bidder',
                                        message   => 'Multiple Users found for person_party_id:'|| p_trading_partner_contact_id);
               end if;
         end if;

         select user_name
         into x_bidder_user_name
         from fnd_user
         where person_party_id = p_trading_partner_contact_id
         and nvl(end_date, sysdate+1) > sysdate
         and rownum=1;

    END;

    x_progress := '020';

    add_bidder_to_role(x_bidder_user_name,x_role_name);

    x_return_status := 0;

EXCEPTION

    WHEN OTHERS THEN
       x_return_status := 1;

END;


PROCEDURE BIDDER_IN_LIST    (  itemtype  in varchar2,
        itemkey    in varchar2,
                         actid           in number,
                            uncmode    in varchar2,
                              resultout       out NOCOPY varchar2)  IS

x_flag   VARCHAR2(1) := 'N';
x_auction_header_id  NUMBER;
x_bidder_contact_id   NUMBER;
x_progress    VARCHAR2(3);

BEGIN

    x_progress := '010';

    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                     aname    => 'AUCTION_ID');

    x_bidder_contact_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                     aname    => 'PREPARER_TP_CONTACT_ID');

    x_progress := '020';

  begin
    select 'Y' into x_flag
    from pon_bidding_parties
    where auction_header_id = x_auction_header_id
    and trading_partner_contact_id = x_bidder_contact_id
    group by trading_partner_contact_id;
        exception when NO_DATA_FOUND then
     x_flag := 'N';
  end;

    x_progress := '030';

   IF (x_flag = 'Y') THEN
     resultout := 'Y';
   ELSE
     resultout := 'N';
   END IF;

END;


PROCEDURE ADD_BIDDER_TO_ROLE(p_user_name  VARCHAR2,
           p_role_name  VARCHAR2) IS

x_progress      VARCHAR2(3);
x_user_orig_system    VARCHAR2(30) := 'FND_USR';
x_user_orig_system_id    NUMBER := 0;
x_role_orig_system    VARCHAR2(30) := 'WF_LOCAL_ROLES';
x_role_orig_system_id    NUMBER := 0;
x_bidder_count      NUMBER;
l_users WF_DIRECTORY.UserTable;

BEGIN
    x_progress := '010';

  select count(*)
  into x_bidder_count
  from wf_local_user_roles
  where role_name = p_role_name
  and user_name = p_user_name;

  if (x_bidder_count < 1) then
     --WF_DIRECTORY.AddUsersToAdHocRole(p_role_name,
                                             --   p_user_name);

 	         -- Added for the bug#8847938 to remove the space as delimitter in user name
 	                 if (p_user_name is NOT NULL) then
 	                     string_to_userTable(p_user_name, l_users);


 	         WF_DIRECTORY.AddUsersToAdHocRole2(p_role_name,
 	                                          l_users);
 	         end if;
  end if;
END;

PROCEDURE SEALED_BIDS(  itemtype  in varchar2,
        itemkey    in varchar2,
                         actid           in number,
                            uncmode    in varchar2,
                              resultout       out NOCOPY varchar2) IS

x_flag       VARCHAR2(1);
x_progress    VARCHAR2(3);

BEGIN

    x_progress := '010';

    x_flag := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                     aname    => 'SEALED_FLAG');

    x_progress := '020';

   IF (x_flag = 'Y') THEN
     resultout := 'Y';
   ELSE
     resultout := 'N';
   END IF;

END;

----------------------------------------------------------------
-- Procedure call to cancel an auction                        --
----------------------------------------------------------------
PROCEDURE CANCEL_AUCTION (p_auction_header_id  IN NUMBER) IS

x_itemtype   VARCHAR2(7) := 'PONAUCT';
x_itemkey  VARCHAR2(30);
x_notification_date  DATE;
x_now    DATE;
x_cancel_reason PON_ACTION_HISTORY.ACTION_NOTE%TYPE := '';
x_cancel_date   PON_AUCTION_HEADERS_ALL.CANCEL_DATE%TYPE;
x_current_activity VARCHAR2(30);


BEGIN
   -- choli update for emd
   email_emd_admins(p_auction_header_id);
   --
   -- Get the workflow item key and the current time so that we
   -- can complete the workflow
   --
   x_now := SYSDATE;

   select wf_item_key, sysdate, cancel_date
     into x_itemkey, x_now, x_cancel_date
     from pon_auction_headers_all
     where auction_header_id = p_auction_header_id;


   --
   -- First, see what activity (if any) the workflow is on
   -- If none, then return.  Workflow has already completed??
   --
   BEGIN
      select activity_label
  into x_current_activity
  from wf_item_activity_statuses_v
  where item_type = x_itemtype
  AND item_key = x_itemkey
  and activity_status_code = 'NOTIFIED';
   EXCEPTION WHEN no_data_found THEN
     RETURN;
   END;
   --
   -- Get the cancel reason from the action history table
   --
   BEGIN
      select action_note
  into   x_cancel_reason
  from pon_action_history
  where object_id = p_auction_header_id
  and   object_type_code = 'PON_AUCTION'
  and action_type = 'CANCEL';
   EXCEPTION WHEN NO_DATA_FOUND THEN
      x_cancel_reason := '';
   END;


   --
   -- Set the workflow attribute
   --

   if (x_cancel_reason is null) then
     wf_engine.SetItemAttrText(itemtype => x_itemtype,
          itemkey  => x_itemkey,
          aname    => 'CANCEL_REASON',
          avalue   => getMessage('PON_AUC_WF_NO_REASON', ''));
   else
     wf_engine.SetItemAttrText(itemtype => x_itemtype,
               itemkey  => x_itemkey,
               aname    => 'CANCEL_REASON',
               avalue   => x_cancel_reason);
   end if;


   if (x_cancel_date is not null) then
          wf_engine.SetItemAttrDate(itemtype => x_itemtype,
          itemkey  => x_itemkey,
          aname    => 'CANCEL_DATE',
          avalue   => x_cancel_date);

   end if;

   --
   -- Complete the workflow with a cancel action.
   -- This should either be
   --   1) Waiting for the start of the auction
   --   2) Pre  6.1 - waiting for the end of the auction
   --      Post 6.1 - waiting for user to complete the auction
   --

   wf_engine.CompleteActivity(x_itemtype,x_itemkey,x_current_activity,'PREPARER_CANCEL');

END;

FUNCTION GET_CLOSE_BIDDING_DATE(p_auction_header_id IN NUMBER) RETURN DATE

IS

  v_end_date DATE;

BEGIN


     select pah.close_bidding_date
     into   v_end_date
     from   pon_auction_headers_all pah
     where  pah.auction_header_id = p_auction_header_id;

     RETURN v_end_date;

END;


FUNCTION TIME_REMAINING_ORDER(p_auction_header_id IN NUMBER) RETURN NUMBER

IS

  v_auction_status     VARCHAR2(25);
  v_creation_date      DATE;
  v_end_date           DATE;
  v_time_left_order    NUMBER;
  v_is_paused         VARCHAR2(1);
  v_last_pause_date    DATE;
  v_auction_header_id_orig_round NUMBER;
  v_auction_round_number NUMBER;
  v_amendment_number NUMBER;

BEGIN

     select pah.auction_status, pah.creation_date, pah.close_bidding_date, nvl( pah.is_paused, 'N' ), nvl( pah.last_pause_date, sysdate )
            , auction_header_id_orig_round, nvl(auction_round_number,0),
nvl(amendment_number,0)
     into   v_auction_status, v_creation_date, v_end_date, v_is_paused, v_last_pause_date
            , v_auction_header_id_orig_round, v_auction_round_number,
v_amendment_number
     from   pon_auction_headers_all pah
     where  pah.auction_header_id = p_auction_header_id;

   RETURN TIME_REMAINING_ORDER( v_auction_status, v_creation_date , v_end_date, v_is_paused, v_last_pause_date, v_auction_header_id_orig_round, v_auction_round_number, v_amendment_number );

END;


-- Overloaded function to calculate time_remaining.
-- This function will not make any database call,
-- since all the necessary parameters are passed as an arguments.
FUNCTION TIME_REMAINING_ORDER( p_auction_status      IN VARCHAR2,
                               p_creation_date       IN DATE,
                               p_close_bidding_date  IN DATE,
                               p_is_paused           IN VARCHAR2,
                               p_last_pause_date     IN DATE,
                               p_auction_header_id_orig_round IN NUMBER,
                               p_auction_round_number IN NUMBER,
                               p_amendment_number IN NUMBER) RETURN NUMBER

IS

  v_time_left_order    NUMBER;

BEGIN

   -- Check the dates are having valid inputs. If the dates are null,
   -- we will return output as Zero (0), since those records will be displayed at the top
   -- and the users can easily find out the problems.
   IF ( p_creation_date IS NULL OR  p_close_bidding_date IS NULL ) THEN
      v_time_left_order := 0;
      RETURN v_time_left_order;
   END IF;

   --
   -- If cancelled
   --
   IF ( p_auction_status = 'CANCELLED') THEN
      v_time_left_order := (2000*365) + (p_close_bidding_date - sysdate);
      RETURN v_time_left_order;
   END IF;

   --
   -- If amended or completed
   --
   IF (p_auction_status = 'AMENDED' or p_auction_status = 'AUCTION_CLOSED') THEN
      v_time_left_order := (1500*365) - (p_auction_header_id_orig_round +
                           nvl(p_auction_round_number,0)*0.0001 +
                           nvl(p_amendment_number,0)*0.00000001)/10000000000000000;
      --v_time_left_order := (1500*365) + (sysdate - p_creation_date);
      RETURN v_time_left_order;
   END IF;

   --
   -- If the negotiation is paused, return the constant time remaining.
   --
   IF ( p_is_paused = 'Y' ) THEN
      IF p_last_pause_date IS NOT NULL THEN
        v_time_left_order :=  p_close_bidding_date - p_last_pause_date;
        RETURN v_time_left_order;
      ELSE
        v_time_left_order := 0;
        RETURN v_time_left_order;
      END IF;
   END IF;

   --
   -- If closed
   --
   IF (p_close_bidding_date < sysdate) THEN
      v_time_left_order := (1000*365) + (p_close_bidding_date - sysdate);
      RETURN v_time_left_order;
   END IF;

   v_time_left_order := p_close_bidding_date - sysdate;
   return v_time_left_order;

END;


--
-- Bug 3283581 and Bug 3275373
--
-- TIME_REMAINING has been revamped to always return the time left in
-- days, hours, and minutes.  The actual date will never be returned to avoid
-- any date formatting and translation issues.
--


FUNCTION TIME_REMAINING(p_auction_header_id IN NUMBER) RETURN VARCHAR2

IS

BEGIN

  RETURN TIME_REMAINING(p_auction_header_id, null);

END;

FUNCTION TIME_REMAINING(p_auction_header_id IN NUMBER, p_line_number IN NUMBER) RETURN VARCHAR2

IS

  v_auction_status     VARCHAR2(25);
  v_startdate          DATE;
  v_enddate            DATE;
  v_difference         NUMBER := 0;
  v_days               NUMBER := 0;
  v_hours              NUMBER := 0;
  v_minutes            NUMBER := 0;
  v_time_left          VARCHAR2(50) := null;
  v_opens_in_suffix    VARCHAR2(2)  := '';
  v_pausedate          DATE;
  v_ispaused           VARCHAR2(1);
  v_staggered_closing_interval NUMBER := NULL;

BEGIN

  IF (p_line_number is null) THEN

     select auction_status, open_bidding_date, close_bidding_date, nvl( last_pause_date, sysdate ), nvl( is_paused, 'N' ), staggered_closing_interval
     into   v_auction_status, v_startdate, v_enddate, v_pausedate, v_ispaused, v_staggered_closing_interval
     from   pon_auction_headers_all
     where  auction_header_id = p_auction_header_id;

  ELSE

     select pah.auction_status, pah.open_bidding_date, nvl(paip.close_bidding_date, pah.close_bidding_date),
            nvl( pah.last_pause_date, sysdate ), nvl( pah.is_paused, 'N' )
     into   v_auction_status, v_startdate, v_enddate, v_pausedate, v_ispaused
     from   pon_auction_headers_all pah, pon_auction_item_prices_all paip
     where  pah.auction_header_id = p_auction_header_id and
            paip.auction_header_id = pah.auction_header_id and
            paip.line_number = p_line_number;

  END IF;

  RETURN TIME_REMAINING( v_auction_status, v_startdate, v_enddate, v_ispaused, v_pausedate, v_staggered_closing_interval);

END;

-- Overloaded function to calculate time_remaining.
-- This function will not make any database call,
-- since all the necessary parameters are passed as an arguments.
FUNCTION TIME_REMAINING( p_auction_status      IN VARCHAR2,
                         p_open_bidding_date   IN DATE,
                         p_close_bidding_date  IN DATE,
                         p_is_paused           IN VARCHAR2,
                         p_last_pause_date     IN DATE,
                         p_staggered_closing_interval IN NUMBER ) RETURN VARCHAR2
IS

  v_difference         NUMBER := 0;
  v_days               NUMBER := 0;
  v_hours              NUMBER := 0;
  v_minutes            NUMBER := 0;
  v_seconds            NUMBER := 0;
  v_time_left          VARCHAR2(50) := null;
  v_opens_in_suffix    VARCHAR2(2)  := '';

BEGIN

   --
   -- If cancelled, then return "Cancelled"
   --
   IF (p_auction_status = 'CANCELLED') THEN
      v_time_left :=  fnd_message.get_string('PON', 'PON_AUC_CANCELLED');
      RETURN v_time_left;
   END IF;

   --
   -- If amended, then return "N/A"
   --
   IF (p_auction_status = 'AMENDED') THEN
     v_time_left := fnd_message.get_string('PON', 'PON_NOT_APPLICABLE');
     RETURN v_time_left;
   END IF;

   -- We will check the dates are valid.
   -- If the dates are null, then we will return, BLANK message as time left.
   IF p_open_bidding_date IS NULL OR p_close_bidding_date IS NULL THEN
      v_time_left :=  ' ';
      RETURN v_time_left;
   END IF;

   --
   -- If the negotiation is paused, return the constant time remaining.
   --
   IF ( p_is_paused = 'Y' ) THEN

            IF p_last_pause_date IS NULL THEN
                v_time_left :=  ' ';
                RETURN v_time_left;
            ELSE
                -- if a staggered  auction
                --then show STAGGERED CLOSING for close date
                IF p_staggered_closing_interval IS NOT NULL THEN
                  return fnd_message.get_string('PON','PON_STAGGERED_CLOSING_MSG');
                END IF;
                v_difference := to_number( p_close_bidding_date - p_last_pause_date );
            END IF;

   ELSE

     --
     -- If closed, then return "0 seconds"
     --
     IF (p_close_bidding_date < sysdate) THEN
        fnd_message.clear;
        fnd_message.set_name('PON','PON_AUC_INTERVAL_SEC');
        fnd_message.set_token('SECONDS',0);
        v_time_left := fnd_message.get;
        RETURN v_time_left;
     END IF;

     -- if a staggered  auction
     --then show STAGGERED CLOSING for close date
     IF p_staggered_closing_interval IS NOT NULL THEN
       return fnd_message.get_string('PON','PON_STAGGERED_CLOSING_MSG');
     END IF;
     --
     -- If the start date is in the future, then
     -- calculate the difference from sysdate to start date and
     -- use "Opens in XXXX" messages
     --
     IF(p_open_bidding_date > Sysdate) THEN
        v_opens_in_suffix := '_F';
        v_difference := to_number(p_open_bidding_date - sysdate);
      --
      -- Otherwise, calculate the difference from sysdate to end date
      --
      ELSE
        v_difference := to_number(p_close_bidding_date - sysdate);
     END IF;
   END IF;

   --
   -- Calculate time components
   --
   v_days := trunc(v_difference);
   v_hours := trunc(mod(v_difference*24,24));
   v_minutes := trunc(mod(v_difference*(24*60),60));
   v_seconds := trunc(mod(v_difference*(24*60*60),60));

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'TIME_REMAINING',
        message  => 'v_days = ' || v_days
                    || ' v_hours = ' || v_hours
                    || ' v_minutes = ' || v_minutes
                    || ' v_seconds = ' || v_seconds
            );
    END IF;

   --
   -- If we have less than one minute
   --
   IF(v_days < 1 AND v_hours < 1 AND v_minutes < 1 AND 0 < v_seconds) THEN
      v_time_left :=  fnd_message.get_string('PON', 'PON_LESS_MINUTE'||v_opens_in_suffix);
   --
   -- If we have less than one second, display 0 minutes
   --
   ELSIF(v_days < 1 AND v_hours < 1 AND v_minutes < 1 AND v_seconds < 1) THEN
      fnd_message.clear;
      IF (v_opens_in_suffix is not null) THEN
        fnd_message.set_name('PON','PON_MINUTES'||v_opens_in_suffix);
        fnd_message.set_token('NUM_MINUTES',0);
      ELSE
        fnd_message.set_name('PON','PON_AUC_INTERVAL_SEC');
        fnd_message.set_token('SECONDS',0);
      END IF;
      v_time_left := fnd_message.get;
    --
    -- If we have just one minute
    --
    ELSIF(v_days < 1 AND v_hours < 1 AND v_minutes = 1) THEN
      v_time_left :=  fnd_message.get_string('PON', 'PON_MINUTE'||v_opens_in_suffix);
    --
    -- If we have just minutes
    --
    ELSIF(v_days < 1 AND v_hours < 1 AND v_minutes > 1 ) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_MINUTES'||v_opens_in_suffix);
      fnd_message.set_token('NUM_MINUTES',v_minutes);
      v_time_left := fnd_message.get;
    --
    -- If we have one hour
    --
    ELSIF(v_days < 1 AND v_hours = 1 AND v_minutes < 1) THEN
      v_time_left := fnd_message.get_string('PON','PON_HOUR'||v_opens_in_suffix);
    --
    -- If we have one hour and one minute
    --
    ELSIF(v_days < 1 AND v_hours = 1 AND v_minutes = 1) THEN
      v_time_left := fnd_message.get_string('PON','PON_HOUR_MINUTE'||v_opens_in_suffix);
    --
    -- If we have one hour and minutes
    --
    ELSIF(v_days < 1 AND v_hours = 1 AND v_minutes > 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_HOUR_MINUTES'||v_opens_in_suffix);
      fnd_message.set_token('NUM_MINUTES',v_minutes);
      v_time_left := fnd_message.get;
    --
    -- If we have hours
    --
    ELSIF(v_days < 1 AND v_hours > 1 AND v_minutes < 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_HOURS'||v_opens_in_suffix);
      fnd_message.set_token('NUM_HOURS',v_hours);
      v_time_left := fnd_message.get;
    --
    -- If we have hours and one minute
    --
    ELSIF(v_days < 1 AND v_hours > 1 AND v_minutes = 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_HOURS_MINUTE'||v_opens_in_suffix);
      fnd_message.set_token('NUM_HOURS',v_hours);
      v_time_left := fnd_message.get;
    --
    -- If we have hours and minutes
    --
    ELSIF(v_days < 1 AND v_hours > 1 AND v_minutes > 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_HOURS_MINUTES'||v_opens_in_suffix);
      fnd_message.set_token('NUM_HOURS',v_hours);
      fnd_message.set_token('NUM_MINUTES',v_minutes);
      v_time_left := fnd_message.get;
    --
    -- If we have one day
    --
    ELSIF(v_days = 1 AND v_hours < 1) THEN
      v_time_left := fnd_message.get_string('PON','PON_DAY'||v_opens_in_suffix);
    --
    -- If we have one day and one hour
    --
    ELSIF(v_days = 1 AND v_hours = 1) THEN
      v_time_left := fnd_message.get_string('PON','PON_DAY_HOUR'||v_opens_in_suffix);
    --
    -- If we have one day and hours
    --
    ELSIF(v_days = 1 AND v_hours > 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_DAY_HOURS'||v_opens_in_suffix);
      fnd_message.set_token('NUM_HOURS',v_hours);
      v_time_left := fnd_message.get;
    --
    -- If we have days
    --
    ELSIF(v_days > 1 AND v_hours < 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_DAYS'||v_opens_in_suffix);
      fnd_message.set_token('NUM_DAYS',v_days);
      v_time_left := fnd_message.get;
    --
    -- If we have days and one hour
    --
    ELSIF(v_days > 1 AND v_hours = 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_DAYS_HOUR'||v_opens_in_suffix);
      fnd_message.set_token('NUM_DAYS',v_days);
      v_time_left := fnd_message.get;
    --
    -- If we have days and hours
    --
    ELSIF(v_days > 1 AND v_hours > 1) THEN
      fnd_message.clear;
      fnd_message.set_name('PON','PON_DAYS_HOURS'||v_opens_in_suffix);
      fnd_message.set_token('NUM_DAYS',v_days);
      fnd_message.set_token('NUM_HOURS',v_hours);
      v_time_left := fnd_message.get;
   END IF;
   --
   -- Return the time left
   --
   RETURN v_time_left;

END;



PROCEDURE AUCTION_OPEN(   itemtype  IN VARCHAR2,
        itemkey    IN VARCHAR2,
                                actid           IN NUMBER,
                                uncmode          IN VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2) IS

x_auction_header_id  NUMBER;
x_progress    VARCHAR2(3);

BEGIN

    x_progress := '010';

    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                     aname    => 'AUCTION_ID');

    x_progress := '020';

    update pon_auction_headers_all
    set    auction_status = 'OPEN_FOR_BIDDING',
     auction_status_name = (select meaning from fnd_lookups
          where lookup_type = 'PON_AUCTION_STATUS' and
          lookup_code = 'OPEN_FOR_BIDDING')
    where auction_header_id = x_auction_header_id;


    x_progress := '030';

END AUCTION_OPEN;

PROCEDURE AUCTION_CLOSED(   itemtype  IN VARCHAR2,
        itemkey    IN VARCHAR2,
                                actid           IN NUMBER,
                                uncmode          IN VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2) IS
x_auction_header_id  NUMBER;
x_progress    VARCHAR2(3);

BEGIN

    x_progress := '010';

    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                     aname    => 'AUCTION_ID');

    x_progress := '020';

    update pon_auction_headers_all
    set    auction_status = 'CLOSED_FOR_BIDDING',
     auction_status_name = (select meaning from fnd_lookups
          where lookup_type = 'PON_AUCTION_STATUS' and
          lookup_code = 'CLOSED_FOR_BIDDING')
    where auction_header_id = x_auction_header_id;


    x_progress := '030';

END AUCTION_CLOSED;



----------------------------------------------------------------
-- getLookupMeaning returns the description of a lookup code
-- in the language mentioaned as a parameter.
-- PL/SQL equivalent of Lookups.getMeaning() (in services package)
----------------------------------------------------------------
Function getLookupMeaning(lookupType in varchar2,
                          langCode   in varchar2,
                          lookupCode in varchar2) return varchar2 AS
lookupMeaning varchar2(8000) :=  '';
Begin
 begin
if  nvl(lookupCode,'!') <> '!' then
select meaning into lookupMeaning
from fnd_lookup_values
where lookup_type = lookupType and
      language    = langCode   and
      lookup_code = lookupCode;
end if;
end;
return (lookupMeaning);
End getLookupMeaning;

----------------------------------------------------------------
-- GetPoTotal returns the sum of the extend amount for the lines
-- including with this PO
----------------------------------------------------------------
Function GetPOTotal( p_po_id    IN number) return Number AS
x_amount number;
cursor c1(p_po_id number) is
select sum(AWARD_QUANTITY * BID_CURRENCY_PRICE)
from pon_bid_item_prices
where bid_number = p_po_id
and award_status = 'AWARDED';
Begin
 begin
    open c1(p_po_id);
    fetch c1
       into x_amount;
    close c1;
 exception When others then
   x_amount := 0;
 end;
 return(x_amount);
End GetPOTotal;

----------------------------------------------------------------
-- Replace HTML entity characters to actual characters    --
-- This is required to pass proper string to workflow
-- Example : <amp>quot;Test<amp>quit; is converted to "Test"
----------------------------------------------------------------
function replaceHtmlChars(html_in varchar2) return varchar2 is
html_out1 varchar2(4000);
html_out2 varchar2(4000);
html_out3 varchar2(4000);
begin
html_out1 := replace(html_in,concat(fnd_global.local_chr(38),'quot;'),fnd_global.local_chr(34));
html_out2 := replace(html_out1,concat(fnd_global.local_chr(38),'lt;'),fnd_global.local_chr(60));
html_out3 := replace(html_out2,concat(fnd_global.local_chr(38),'gt;'),fnd_global.local_chr(62));
return(html_out3);
end;


----------------------------------------------------------------
-- Tells if a particular auction is part of an event using    --
-- the auction id                                             --
----------------------------------------------------------------
PROCEDURE EVENT_AUCTION    (itemtype    in varchar2,
                 itemkey    in varchar2,
                            actid           in number,
                            uncmode    in varchar2,
                            resultout       out NOCOPY varchar2) IS

x_auction_number  NUMBER;

BEGIN

    x_auction_number := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                       aname    => 'AUCTION_NUMBER');


    resultout := is_event_auction(x_auction_number);
END;

----------------------------------------------------------------
-- Tells if a particular auction is part of an event using    --
-- the auction id                                             --
----------------------------------------------------------------
PROCEDURE EVENT_AUCTION_ID(itemtype    in varchar2,
         itemkey    in varchar2,
         actid           in number,
         uncmode    in varchar2,
         resultout       out NOCOPY varchar2) IS

x_auction_number  NUMBER;

BEGIN

    x_auction_number := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'AUCTION_ID');

    resultout := is_event_auction(x_auction_number);
END;

----------------------------------------------------------------
-- Local function which returns a flag 'Y' if an auction is   --
-- part of an event and 'N' if it is not                      --
----------------------------------------------------------------
FUNCTION IS_EVENT_AUCTION (p_auction_number IN NUMBER) RETURN VARCHAR2 AS

x_flag       VARCHAR2(1);

BEGIN
   BEGIN
      select 'Y'
  into x_flag
  from pon_auction_headers_all
  where auction_header_id = p_auction_number
  and   event_id is not null;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
   x_flag := 'N';
   END;

   return(x_flag);
END;


----------------------------------------------------------------
-- Tells if the cancel reason is empty                        --
----------------------------------------------------------------
PROCEDURE EMPTY_CANCEL_REASON(itemtype    in varchar2,
            itemkey    in varchar2,
            actid           in number,
            uncmode    in varchar2,
            resultout       out NOCOPY varchar2) IS

x_cancel_reason PON_ACTION_HISTORY.ACTION_NOTE%TYPE;

BEGIN

    x_cancel_reason := wf_engine.GetItemAttrText (itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'CANCEL_REASON');


    resultout := empty_reason(x_cancel_reason);
END;

----------------------------------------------------------------
-- Tells if the auction close date changed reason is empty                      --
----------------------------------------------------------------
PROCEDURE EMPTY_CLOSECHANGED_REASON(itemtype          in varchar2,
                              itemkey           in varchar2,
                              actid             in number,
                              uncmode           in varchar2,
                              resultout         out NOCOPY varchar2) IS

x_closechanged_reason VARCHAR2(2000);

BEGIN

    x_closechanged_reason := wf_engine.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CLOSECHANGED_REASON');

    resultout := empty_reason(x_closechanged_reason);
END;

----------------------------------------------------------------
-- Tells if the disqualify reason is empty                    --
----------------------------------------------------------------
PROCEDURE EMPTY_DISQUALIFY_REASON(itemtype    in varchar2,
          itemkey    in varchar2,
          actid           in number,
          uncmode    in varchar2,
          resultout       out NOCOPY varchar2) IS

x_disqualify_reason VARCHAR2(2000);

BEGIN

    x_disqualify_reason := wf_engine.GetItemAttrText (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'DISQUALIFY_REASON');


    resultout := empty_reason(x_disqualify_reason);
END;

----------------------------------------------------------------
-- Local function which returns a flag 'Y' if a string is     --
-- empty and 'N' if it not                                    --
----------------------------------------------------------------
FUNCTION EMPTY_REASON(p_reason IN VARCHAR2) RETURN VARCHAR2 AS

x_flag  VARCHAR2(1) := 'Y';

BEGIN

   IF(p_reason IS NOT NULL) THEN
      x_flag := 'N';
   END IF;

   return(x_flag);
END;

----------------------------------------------------------------
-- Procedure to call to end an auction workflow.              --
-- Once called, no more notifications for the auction can be  --
-- sent.  Has the same effect as canceling an auction         --
----------------------------------------------------------------
PROCEDURE COMPLETE_AUCTION(p_auction_header_id  IN NUMBER) IS

x_now    DATE;
x_itemtype   VARCHAR2(7) := 'PONAUCT';
x_itemkey  VARCHAR2(30);
x_notification_date  DATE;
x_current_activity VARCHAR2(30);

BEGIN
   --
   -- Get the workflow item key and the current time so that we
   -- can complete the workflow
   --
   select wf_item_key, sysdate
     into x_itemkey, x_now
     from pon_auction_headers_all
     where auction_header_id = p_auction_header_id;

   --
   -- First, see what activity (if any) the workflow is on
   -- If none, then return.  Workflow has already completed??
   --
   BEGIN
      select activity_label
  into x_current_activity
  from wf_item_activity_statuses_v
  where item_type = x_itemtype
  AND item_key = x_itemkey
  and activity_status_code = 'NOTIFIED';
   EXCEPTION WHEN no_data_found THEN
     RETURN;
   END;

   --
   -- Otherwise we have an active workflow, so go ahead and complete it
   --
   -- Get the notification date from the workflow
   --
   x_notification_date := wf_engine.GetItemAttrDate (itemtype => x_itemtype,
                 itemkey  => x_itemkey,
                 aname    => 'AUCTION_NOTIFICATION_DATE');

   --
   -- Only complete the workflow if it is in a 'completeable' state.
   -- That is, if we have passed the notification date for the auction.
   -- If we try and complete the auction before that, we will get a workflow
   -- exception.
   --

   IF(x_now > x_notification_date AND x_current_activity = 'WAIT_FOR_AUCTION_COMPLETE') THEN
      wf_engine.CompleteActivity(x_itemtype,x_itemkey,'WAIT_FOR_AUCTION_COMPLETE','PREPARER_COMPLETE');
   END IF;

END;

FUNCTION sub_token(msg IN OUT NOCOPY varchar2, msgdata IN varchar2)
  RETURN VARCHAR2
  IS

  TOK_NAM   varchar2(30);
  TOK_VAL   varchar2(2000);
  SRCH      varchar2(2000);
  FLAG      varchar2(1);
  POS       NUMBER;
  NEXTPOS   NUMBER;
  DATA_SIZE NUMBER;
  TSLATE    BOOLEAN;

BEGIN
        POS := 1;
        DATA_SIZE := LENGTH(MSGDATA);
        while POS < DATA_SIZE loop
            FLAG := SUBSTR(MSGDATA, POS, 1);
            POS := POS + 2;
            /* Note that we are intentionally using chr(0) rather than */
            /* FND_GLOBAL.LOCAL_CHR() for a performance bug (982909) */
            NEXTPOS := INSTR(MSGDATA, chr(0), POS);
            TOK_NAM := SUBSTR(MSGDATA, POS, NEXTPOS - POS);
            POS := NEXTPOS + 1;
            NEXTPOS := INSTR(MSGDATA, chr(0), POS);
            TOK_VAL := SUBSTR(MSGDATA, POS, NEXTPOS - POS);
            POS := NEXTPOS + 1;

            SRCH := '&' || TOK_NAM;
            if (INSTR(MSG, SRCH) <> 0) then
                MSG := substrb(REPLACE(MSG, SRCH, TOK_VAL),1,2000);
            else
                /* try the uppercased version of the token name in case */
                /* the caller is (wrongly) passing a mixed case token name */
                /* Because now (July 99) all tokens in msg text should be */
                /* uppercase. */
                SRCH := '&' || UPPER(TOK_NAM);
                if (INSTR(MSG, SRCH) <> 0) then
                   MSG := substrb(REPLACE(MSG, SRCH, TOK_VAL),1,2000);
                else
                   MSG :=substrb(MSG||' ('||TOK_NAM||'='||TOK_VAL||')',1,2000);
              end if;
            end if;
        END LOOP;
        RETURN MSG;
END sub_token;

FUNCTION get_string(appin IN VARCHAR2,
        namein IN VARCHAR2,
        langin IN VARCHAR2)
  RETURN VARCHAR2
  IS
     MSG  varchar2(2000) := NULL;
     MSGDATA  varchar2(2000) := NULL;

BEGIN
   /* In the PON_PROFILE_UTIL_PKG there is a three var input fn.*/
   MSG := PON_PROFILE_UTIL_PKG.get_string(appin,namein,langin);
   FOR i in 1 .. MsgTokens.COUNT LOOP
  MSGDATA := MSGDATA||'N'||chr(0)||MsgTokens(i)||chr(0)||MsgTokenValues(i)||chr(0);
   END LOOP;
   return sub_token(MSG, MSGDATA);

END get_string;

----------------------------------------------------------------
-- Procedure call to close an auction early                   --
----------------------------------------------------------------
PROCEDURE CLOSEEARLY_AUCTION (p_auction_header_id   IN NUMBER,
                              p_new_close_date      IN DATE,
                              p_closeearly_reason   IN VARCHAR2) IS

x_itemtype                VARCHAR2(7) := 'PONAUCT';
x_itemkey                 VARCHAR2(30);
x_current_activity        VARCHAR2(30);
x_contact_id              NUMBER;
x_timezone                VARCHAR2(80);
x_oex_timezone            VARCHAR2(80);
x_auctioneer_contact_id   NUMBER ;
x_timezone_disp VARCHAR2(240);
x_user_name         VARCHAR2(100);
x_language_code     VARCHAR2(30);

-------------------------------

--select user_name, person_party_id
--    into x_user_name, x_contact_id
--    from fnd_user where person_party_id = x_auction_contact_id;
--

BEGIN
   --
   -- Get the workflow item key and the current time so that we
   -- can complete the workflow
   --
   select wf_item_key, trading_partner_contact_id
     into x_itemkey, x_contact_id
     from pon_auction_headers_all
     where auction_header_id = p_auction_header_id;

  BEGIN
    select user_name
    into x_user_name
    from fnd_user
    where  person_party_id = x_contact_id
    and nvl(end_date, sysdate+1) > sysdate;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
         if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
               if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                         fnd_log.string(log_level => fnd_log.level_unexpected,
                                        module    => 'pon.plsql.pon_auction_pkg.closeearly_auction',
                                        message   => 'Multiple Users found for person_party_id:'|| x_contact_id);
               end if;
         end if;

         select user_name
         into x_user_name
         from fnd_user
         where person_party_id = x_contact_id
         and nvl(end_date, sysdate+1) > sysdate
         and rownum=1;

   WHEN NO_DATA_FOUND THEN
        RETURN;

  END;
          IF x_user_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_user_name,x_language_code);
    END IF;


   --
   -- First, see what activity (if any) the workflow is on
   -- If none, then return.  Workflow has already completed??
   --
   BEGIN
      select activity_label
        into x_current_activity
        from wf_item_activity_statuses_v
        where item_type = x_itemtype
        AND item_key = x_itemkey
        and activity_status_code = 'NOTIFIED';
   EXCEPTION WHEN no_data_found THEN
     RETURN;
   END;

   --
   -- Get the exchange's time zone
   --


   --
   -- Set the auction end date
   --
   wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'AUCTION_END_DATE',
                              avalue     => p_new_close_date);


   wf_engine.SetItemAttrText(itemtype => x_itemtype,
                             itemkey  => x_itemkey,
                             aname    => 'CLOSECHANGED_REASON',
                             avalue   => replaceHtmlChars(p_closeearly_reason));


   complete_prev_suppl_notifs(p_auction_header_id);

   --
   -- Complete the workflow with a close early action.
   -- This should either be
   --   1) Waiting for the start of the auction
   --   2) Pre  6.1 - waiting for the end of the auction
   --      Post 6.1 - waiting for user to complete the auction
   --
   wf_engine.CompleteActivity(x_itemtype,x_itemkey,x_current_activity,'PREPARER_CLOSEEARLY');

END;



----------------------------------------------------------------
-- Procedure call to extend or shorten an auction             --
----------------------------------------------------------------
PROCEDURE CLOSECHANGED_AUCTION (p_auction_header_id   IN NUMBER,
                                p_change_type         IN NUMBER,
                                p_new_close_date      IN DATE,
                                p_closechanged_reason   IN VARCHAR2) IS

x_itemtype                VARCHAR2(7) := 'PONAUCT';
x_itemkey                 VARCHAR2(30);
x_current_activity        VARCHAR2(30);
x_contact_id              NUMBER;
x_timezone                VARCHAR2(80);
x_oex_timezone            VARCHAR2(80);
x_auctioneer_contact_id   NUMBER;
x_timezone_disp VARCHAR2(240);
x_user_name         VARCHAR2(100);
x_language_code     VARCHAR2(30);





BEGIN
   --
   -- Get the workflow item key and the current time so that we
   -- can complete the workflow
   --

   select wf_item_key, trading_partner_contact_id
     into x_itemkey, x_contact_id
     from pon_auction_headers_all
     where auction_header_id = p_auction_header_id;

   BEGIN
     select user_name
     into x_user_name
     from fnd_user
     where  person_party_id = x_contact_id
     and nvl(end_date, sysdate+1) > sysdate;
   EXCEPTION
    WHEN TOO_MANY_ROWS THEN
          if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
               if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                         fnd_log.string(log_level => fnd_log.level_unexpected,
                                        module    => 'pon.plsql.pon_auction_pkg.closechanged_auction',
                                        message   => 'Multiple Users found for person_party_id:'|| x_contact_id);
               end if;
         end if;

         select user_name
         into x_user_name
         from fnd_user
         where person_party_id = x_contact_id
         and nvl(end_date, sysdate+1) > sysdate
         and rownum=1;

   END;
          IF x_user_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_user_name,x_language_code);
    END IF;

   --
   -- First, see what activity (if any) the workflow is on
   -- If none, then return.  Workflow has already completed??
   --
   BEGIN
      select activity_label
        into x_current_activity
        from wf_item_activity_statuses_v
        where item_type = x_itemtype
        AND item_key = x_itemkey
        and activity_status_code = 'NOTIFIED';
   EXCEPTION WHEN no_data_found THEN
        RETURN;
   END;

   --
   -- Set the auction end date
   --
   wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'AUCTION_END_DATE',
                              avalue     => p_new_close_date);

begin

   wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'CHANGE_TYPE',
                              avalue     => p_change_type);

exception
   when others then
      null; -- for auctions created before version 115.20 of ponwfau1.wft this attribute did not exist
end;

  IF p_closechanged_reason IS NOT NULL THEN
    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
             aname      => 'CLOSECHANGED_REASON',
             avalue     => replaceHtmlChars(p_closechanged_reason));
  END IF;

   --
   -- Complete the workflow with a close early action.
   -- This should either be
   --   1) Waiting for the start of the auction
   --   2) Pre  6.1 - waiting for the end of the auction
   --      Post 6.1 - waiting for user to complete the auction
   --
   wf_engine.CompleteActivity(x_itemtype,x_itemkey,x_current_activity,'PREPARER_CLOSECHANGED');




END;


----------------------------------------------------------------
-- Function which returns EVENT_TITLE if an auction is   --
-- part of an event and '' if it is not                 --
----------------------------------------------------------------
FUNCTION getEventTitle (p_auction_number IN NUMBER) RETURN VARCHAR2 AS

eventTitle    VARCHAR2(80);

BEGIN
   BEGIN
      select event.event_title
 into eventTitle
 from pon_auction_headers_all ah,pon_auction_events event
 where auction_header_id = p_auction_number
 and  ah.event_id=event.event_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
 eventTitle := '';
   END;

   return(eventTitle);
END;

--
-- Retrieves message for the specific document type based on the msg_suffix (_B, _R etc.)
--

FUNCTION getMessage (msg VARCHAR2) RETURN VARCHAR2 AS
message VARCHAR2(2000);
BEGIN
   BEGIN

        -- In ERP only three arguements.
  --message := PON_PROFILE_UTIL_PKG.GET_STRING(PON_AUCTION_PKG.OperationId, 'PON', msg, PON_AUCTION_PKG.SessionLanguage);
  message := PON_PROFILE_UTIL_PKG.GET_STRING('PON', msg, PON_AUCTION_PKG.SessionLanguage);

  if (message is null) then
    message := fnd_message.get_string('PON', msg);
  end if;

   EXCEPTION
      WHEN others THEN
      message := null;
   END;

   if (message is null) then
  message := msg;
   end if;

   return(message);
END;

--
-- Retrieves tokenized message for the specific document type based on the msg_suffix (_B, _R etc.)
--

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2) RETURN VARCHAR2 AS
message VARCHAR2(2000);
BEGIN
    message := getMessage(substrb(msg,1,28)||msg_suffix);
   if ( message = substrb(msg,1,28)||msg_suffix) then
      return getMessage (msg);
   else
      return(message);
   end if;

END;

--
-- Retrieves tokenized message for the specific document type based on the msg_suffix (_B, _R etc.)
--

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token VARCHAR2, token_value VARCHAR2) RETURN VARCHAR2 AS
   message VARCHAR2(2000);
   application_code VARCHAR2(5) := 'PON';
   ind NUMBER := 1;
BEGIN

   MsgTokens.DELETE;
   MsgTokenValues.DELETE;
   MsgTokens(ind) := token;
   MsgTokenValues(ind) := token_value;

   message := getMessage(substrb(msg,1,28)||msg_suffix);
   if ( message = substrb(msg,1,28)||msg_suffix) then
      return getTokenMessage(msg);
   else
      return getTokenMessage(substrb(msg,1,28)||msg_suffix);
   end if;
END;


FUNCTION getTokenMessage (msg VARCHAR2) RETURN
 VARCHAR2 AS
   message VARCHAR2(1000);
   application_code VARCHAR2(5) := 'PON';
BEGIN
   BEGIN
      message := GET_STRING('PON', msg, PON_AUCTION_PKG.SessionLanguage);
   EXCEPTION
      WHEN others THEN
      message := null;
   END;

   if (message is null) then
      return msg;
   else
      return(message);
   end if;
END;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2,
      token1_value VARCHAR2, token2 VARCHAR2, token2_value VARCHAR2) RETURN VARCHAR2 AS
   message VARCHAR2(2000);
   application_code VARCHAR2(5) := 'PON';
   ind NUMBER := 1;
BEGIN
   message := getMessage(substrb(msg,1,28)||msg_suffix);

   MsgTokens.DELETE;
   MsgTokenValues.DELETE;
   MsgTokens(ind) := token1;
   MsgTokenValues(ind) := token1_value;
   MsgTokens(ind+1) := token2;
   MsgTokenValues(ind+1) := token2_value;

   if ( message = substrb(msg,1,28)||msg_suffix) then
      return getTokenMessage(msg);
   else
      return getTokenMessage(substrb(msg,1,28)||msg_suffix);
   end if;
END;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2, token1_value VARCHAR2,
         token2 VARCHAR2, token2_value VARCHAR2, token3 VARCHAR2,
         token3_value VARCHAR2) RETURN VARCHAR2 AS
   message VARCHAR2(2000);
   application_code VARCHAR2(5) := 'PON';
   ind NUMBER := 1;
BEGIN
   message := getMessage(substrb(msg,1,28)||msg_suffix);

   MsgTokens.DELETE;
   MsgTokenValues.DELETE;
   MsgTokens(ind) := token1;
   MsgTokenValues(ind) := token1_value;
   MsgTokens(ind+1) := token2;
   MsgTokenValues(ind+1) := token2_value;
   MsgTokens(ind+2) := token3;
   MsgTokenValues(ind+2) := token3_value;

   if ( message = substrb(msg,1,28)||msg_suffix) then
      return getTokenMessage(msg);
   else
      return getTokenMessage(substrb(msg,1,28)||msg_suffix);
   end if;
END;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2, token1_value VARCHAR2,
         token2 VARCHAR2, token2_value VARCHAR2, token3 VARCHAR2, token3_value VARCHAR2,
         token4 VARCHAR2, token4_value VARCHAR2) RETURN VARCHAR2 AS
   message VARCHAR2(2000);
   application_code VARCHAR2(5) := 'PON';
   ind NUMBER := 1;
BEGIN
   message := getMessage(substrb(msg,1,28)||msg_suffix);

   MsgTokens.DELETE;
   MsgTokenValues.DELETE;
   MsgTokens(ind) := token1;
   MsgTokenValues(ind) := token1_value;
   MsgTokens(ind+1) := token2;
   MsgTokenValues(ind+1) := token2_value;
   MsgTokens(ind+2) := token3;
   MsgTokenValues(ind+2) := token3_value;
   MsgTokens(ind+3) := token4;
   MsgTokenValues(ind+3) := token4_value;

   if ( message = substrb(msg,1,28)||msg_suffix) then
      return getTokenMessage(msg);
   else
      return getTokenMessage(substrb(msg,1,28)||msg_suffix);
   end if;
END;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2, token1_value VARCHAR2,
         token2 VARCHAR2, token2_value VARCHAR2, token3 VARCHAR2, token3_value VARCHAR2,
         token4 VARCHAR2, token4_value VARCHAR2, token5 VARCHAR2, token5_value VARCHAR2) RETURN VARCHAR2 AS
   message VARCHAR2(2000);
   application_code VARCHAR2(5) := 'PON';
   ind NUMBER := 1;
BEGIN
   message := getMessage(substrb(msg,1,28)||msg_suffix);

   MsgTokens.DELETE;
   MsgTokenValues.DELETE;
   MsgTokens(ind) := token1;
   MsgTokenValues(ind) := token1_value;
   MsgTokens(ind+1) := token2;
   MsgTokenValues(ind+1) := token2_value;
   MsgTokens(ind+2) := token3;
   MsgTokenValues(ind+2) := token3_value;
   MsgTokens(ind+3) := token4;
   MsgTokenValues(ind+3) := token4_value;
   MsgTokens(ind+4) := token5;
   MsgTokenValues(ind+4) := token5_value;

   if ( message = substrb(msg,1,28)||msg_suffix) then
      return getTokenMessage(msg);
   else
      return getTokenMessage(substrb(msg,1,28)||msg_suffix);
   end if;
END;

FUNCTION GET_MESSAGE_SUFFIX (x_doctype_group_name VARCHAR2) RETURN VARCHAR2 AS

x_msg_suffix PON_AUC_DOCTYPES.MESSAGE_SUFFIX%TYPE := '';

BEGIN
   BEGIN
      SELECT message_suffix
      INTO x_msg_suffix
      FROM pon_auc_doctypes
      WHERE doctype_group_name = x_doctype_group_name;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      x_msg_suffix := '';
   END;
   IF(x_msg_suffix IS null) THEN
      RETURN '';
   ELSE
      RETURN ('_'||x_msg_suffix);
   END IF;
END;

FUNCTION GET_TRANSACTION_TYPE (p_doctype_group_name PON_AUC_DOCTYPES.INTERNAL_NAME%TYPE)
  RETURN PON_AUC_DOCTYPES.TRANSACTION_TYPE%TYPE AS

x_trans_type PON_AUC_DOCTYPES.TRANSACTION_TYPE%TYPE;

BEGIN
   BEGIN
      SELECT transaction_type
      INTO x_trans_type
      FROM pon_auc_doctypes
      WHERE doctype_group_name = p_doctype_group_name;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      x_trans_type := '';
   END;
   return x_trans_type;
END;


--
-- must provide at least one of the two arguments. both cannot be null.
--

PROCEDURE SET_SESSION_LANGUAGE(p_language VARCHAR2, p_language_code VARCHAR2) is

  x_language_code VARCHAR2(60);
  x_language VARCHAR2(60);
BEGIN
     IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
       FND_LOG.string(log_level => FND_LOG.level_statement,
         module => g_module_prefix || 'SET_SESSION_LANGUAGE',
         message  => 'Entered procedure : p_language_code ' || p_language_code);
     END IF; --}

     g_original_lang_code := fnd_global.current_language;

     IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || 'SET_SESSION_LANGUAGE',
          message  => 'g_original_lang_code ' || g_original_lang_code);
     END IF; --}

   if (g_original_lang_code  is not null) then

           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
               module => g_module_prefix || 'SET_SESSION_LANGUAGE',
               message  => 'g_original_lang_code is not null so selecting g_original_language from the DB ');
           END IF; --}

         select nls_language
         into g_original_language
         from fnd_languages
         where language_code = g_original_lang_code;

           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module => g_module_prefix || 'SET_SESSION_LANGUAGE',
              message  => 'g_original_lang_code is : ' || g_original_lang_code || ' after selecting it from the DB ');
           END IF; --}


   else
           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
           FND_LOG.string(log_level => FND_LOG.level_statement,
             module => g_module_prefix || 'SET_SESSION_LANGUAGE',
             message  => 'g_original_lang_code is null, so defaulting the language to US');
           END IF; --}

          g_original_lang_code := 'US';
        g_original_language := 'AMERICAN';

     end if;

          begin
       IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
         FND_LOG.string(log_level => FND_LOG.level_statement,
           module => g_module_prefix || 'SET_SESSION_LANGUAGE',
           message  => 'p_language_code : ' || p_language_code);
         END IF; --}

    if (p_language_code is null) then

         IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
               FND_LOG.string(log_level => FND_LOG.level_statement,
                 module => g_module_prefix || 'SET_SESSION_LANGUAGE',
                 message  => 'p_language_code is NULL so selecting it from fnd_language ');
         END IF; --}

      select language_code
      into x_language_code
      from fnd_languages
      where nls_language = p_language;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
             FND_LOG.string(log_level => FND_LOG.level_statement,
               module => g_module_prefix || 'SET_SESSION_LANGUAGE',
               message  => 'x_language_code : ' || x_language_code);
            END IF; --}

    else

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
             FND_LOG.string(log_level => FND_LOG.level_statement,
               module => g_module_prefix || 'SET_SESSION_LANGUAGE',
               message  => 'p_language_code is NOT NULL so assigning it to x_language_code');
            END IF; --}

      x_language_code := p_language_code;


            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'SET_SESSION_LANGUAGE',
                message  => 'x_language_code : ' || x_language_code);
            END IF; --}
    end if;

       IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || 'SET_SESSION_LANGUAGE',
          message  => 'p_language : ' || p_language);
        END IF; --}

    if (p_language is not null) then

           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'SET_SESSION_LANGUAGE',
                message  => 'p_language is not NULL so calling the dbms_session.set_nls with p_language : '|| p_language);
           END IF; --}

       dbms_session.set_nls('NLS_LANGUAGE', p_language);
    else

           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
             FND_LOG.string(log_level => FND_LOG.level_statement,
               module => g_module_prefix || 'SET_SESSION_LANGUAGE',
               message  => 'p_language is NULL so selecting it from fnd_languages');
           END IF; --}

      select nls_language
      into x_language
      from fnd_languages
      where language_code = x_language_code;

      dbms_session.set_nls('NLS_LANGUAGE', x_language);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
             FND_LOG.string(log_level => FND_LOG.level_statement,
               module => g_module_prefix || 'SET_SESSION_LANGUAGE',
               message  => 'x_language : ' || x_language ||'; calling dbms_session.set_nls with x_language : '|| x_language);
            END IF; --}

    end if;
          exception
    when others then

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'SET_SESSION_LANGUAGE',
                message  => 'Exception when running the procedure; doing nothing');
          END IF; --}

    null;
          end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'SET_SESSION_LANGUAGE',
                message  => 'Setting PON_AUCTION_PKG.SessionLanguage to x_language_code : ' || x_language_code);
        END IF; --}

    -- set this package variable to be used with the get_message calls.
    PON_AUCTION_PKG.SessionLanguage := x_language_code;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
               module => g_module_prefix || 'SET_SESSION_LANGUAGE',
               message  => 'Setting PON_AUCTION_PKG.SessionLanguage : ' || PON_AUCTION_PKG.SessionLanguage);
        END IF; --}

END;


PROCEDURE UNSET_SESSION_LANGUAGE is
BEGIN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'UNSET_SESSION_LANGUAGE',
                message  => 'Entered the procedure; g_original_language : ' || g_original_language);
        END IF; --}

          begin
    --dbms_session.set_nls('NLS_LANGUAGE', 'AMERICAN');
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'UNSET_SESSION_LANGUAGE',
                message  => 'calling  dbms_session.set_nls with g_original_language : ' || g_original_language);
        END IF; --}

        dbms_session.set_nls('NLS_LANGUAGE', g_original_language);
          exception
    when others then
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || 'UNSET_SESSION_LANGUAGE',
          message  => 'Exception when running the procedure; doing nothing');
        END IF; --}

    null;
          end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'UNSET_SESSION_LANGUAGE',
                message  => 'Setting PON_AUCTION_PKG.SessionLanguage to g_original_lang_code : ' || g_original_lang_code);
        END IF; --}
    -- unset this package variable (used by the get_message calls).
   -- PON_AUCTION_PKG.SessionLanguage := 'US';
      PON_AUCTION_PKG.SessionLanguage := g_original_lang_code;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
                module => g_module_prefix || 'UNSET_SESSION_LANGUAGE',
                message  => 'Setting PON_AUCTION_PKG.SessionLanguage : ' || PON_AUCTION_PKG.SessionLanguage);
        END IF; --}

END;


PROCEDURE NOTIFY_BIDDERS_OF_CANCEL (itemtype    in varchar2,
            itemkey    in varchar2,
            actid           in number,
            uncmode    in varchar2,
            resultout       out NOCOPY varchar2)
IS
   x_action_code varchar2(40) := 'CANCEL';
BEGIN

  NOTIFY_BIDDERS_AUC_CHANGED(itemtype,
           itemkey,
           actid,
           uncmode,
           x_action_code);
END;


--
-- Called to notify other bidders that a bid has been disqualified
--

PROCEDURE NOTIFY_OTHER_BIDDERS_OF_DISQ(itemtype    in varchar2,
               itemkey    in varchar2,
               actid           in number,
               uncmode    in varchar2,
               resultout       out NOCOPY varchar2)
IS
        x_action_code varchar2(40) := 'DISQUALIFY_BID';
BEGIN

  NOTIFY_BIDDERS_AUC_CHANGED(itemtype,
           itemkey,
           actid,
           uncmode,
           x_action_code);
END;


PROCEDURE NOTIFY_BIDDERS_AUC_CHANGED(itemtype    in varchar2,
             itemkey    in varchar2,
             actid           in number,
             uncmode    in varchar2,
             action_code    in varchar2)
IS

   x_doc_number                  number;
   x_profile_user               VARCHAR2(240) := '';
   x_bidder_tp_name              PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
   x_vendor_site_code            PON_BIDDING_PARTIES.VENDOR_SITE_CODE%TYPE;
   x_vendor_site_id              NUMBER;
   x_trading_partner_contact_id  PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_ID%TYPE;
   x_wf_role_name                varchar2(100) := '';
   x_language_code               varchar2(30);
   x_message_name                varchar2(80);
   x_doc_number_dsp              varchar2(60);
   x_auction_title               PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
   x_auction_start_date          date;
   x_auction_end_date            date;
   x_preview_date              DATE;
   x_timezone                    VARCHAR2(80);
   x_wf_item_key               VARCHAR2(240);
   x_change_type                 number; -- extend: 1, shorten: 2
   x_original_close_bidding_date PON_AUCTION_HEADERS_ALL.ORIGINAL_CLOSE_BIDDING_DATE%TYPE;
   x_event_title                 varchar2(240) := '';
   x_event_id                    NUMBER;
   x_bad_bidder                  varchar2(80) := null;
   x_tp_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE; -- Bug 3824928 added
   x_staggered_closing_interval  NUMBER;
   l_tp_contact_user_name           wf_users.name%TYPE;
   x_bidder_user_name  wf_users.name%TYPE;
   x_supp_reg_qual_flag          pon_auction_headers_all.supp_reg_qual_flag%TYPE;


    -- Bug 18494910
    -- Modify the query so that for Pre-Qualification RFIs, the notifications
    -- are also sent to prospective suppliers
    CURSOR bidders IS
      select wfu.user_name user_name, person_party_id
      from wf_user_roles wfu, fnd_user fnd
      where role_name = x_wf_role_name
        and fnd.user_name (+) =  wfu.user_name
        AND ('Y' = x_supp_reg_qual_flag
             OR
             wfu.user_name NOT IN (SELECT wf_user_name
                                   FROM pon_bidding_parties
                                   WHERE auction_header_id = x_doc_number
                                     AND trading_partner_id IS NULL)
            )
        AND wfu.user_name NOT IN (SELECT trading_partner_contact_name
                                  FROM pon_bid_headers
                                  WHERE auction_header_id = x_doc_number
                                    AND vendor_id = -1)
      UNION
      SELECT trading_partner_contact_name, trading_partner_contact_id
      FROM pon_bid_headers
      WHERE  auction_header_id = x_doc_number
        AND vendor_id <> -1
        AND NVL(evaluation_flag, 'N') = 'N';

    CURSOR bidders_info IS
      select trading_partner_name, decode(vendor_site_code, '-1', null, vendor_site_code) vendor_site_code, nvl(vendor_site_id, -1) vendor_site_id,trading_partner_contact_id
      from pon_bidding_parties
      where trading_partner_contact_id = x_trading_partner_contact_id
      and auction_header_id = x_doc_number
      union
      select trading_partner_name, decode(vendor_site_code, '-1', null, vendor_site_code) vendor_site_code, nvl(vendor_site_id, -1) vendor_site_id,trading_partner_contact_id
      from pon_bid_headers
      where trading_partner_contact_id = x_trading_partner_contact_id
      and auction_header_id = x_doc_number;


begin

      x_doc_number := wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                                   itemkey    => itemkey,
                                                   aname      => 'AUCTION_ID');

      x_doc_number_dsp := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                                     itemkey    => itemkey,
                                                  aname      => 'DOC_NUMBER');

      x_auction_title := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                                    itemkey    => itemkey,
                                                    aname      => 'AUCTION_TITLE');

      x_auction_start_date  := wf_engine.GetItemAttrDate (itemtype   => itemtype,
                                                          itemkey    => itemkey,
                                                          aname      => 'AUCTION_START_DATE');

      x_auction_end_date  := wf_engine.GetItemAttrDate (itemtype   => itemtype,
                                                        itemkey    => itemkey,
                                                        aname      => 'AUCTION_END_DATE');

      -- Bug 3824928: added below
--      x_tp_contact_name := wf_engine.GetItemAttrText (itemtype => itemtype,
--                                                         itemkey  => itemkey,
--                                                         aname    => 'PREPARER_TP_CONTACT_NAME');



      x_preview_date := wf_engine.GetItemAttrDate (itemtype   => itemtype,
                                                   itemkey    => itemkey,
                                                   aname      => 'PREVIEW_DATE_TZ');


    begin
        select wf_role_name, wf_item_key, original_close_bidding_date, event_id, trading_partner_contact_name,
               staggered_closing_interval, supp_reg_qual_flag
        into  x_wf_role_name, x_wf_item_key, x_original_close_bidding_date, x_event_id, x_tp_contact_name,
              x_staggered_closing_interval, x_supp_reg_qual_flag
        from pon_auction_headers_all
        where auction_header_id = x_doc_number;
    exception
        when others then
        x_wf_role_name := '';
    end;

    if (x_wf_role_name = '') then
        return;
    end if;

    if (action_code is not null and action_code = 'CLOSEEARLY') then
        x_message_name := 'NEGOTIATION_CLOSED_EARLY';
    elsif (action_code = 'CLOSECHANGED') then

        begin
          x_change_type := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname => 'CHANGE_TYPE');
        exception
        when others then
          x_change_type := 1; -- for auctions created before version 115.20 of ponwfau1.wft this attribute did not exist
        end;

        -- auctioneer extends the auction
        if (x_change_type = 1) then
            x_message_name := 'NEGOTIATION_EXTENDED';
        -- auctioneer shortens the auction
        else
            x_message_name := 'NEGOTIATION_SHORTENED';
        end if;
    elsif (action_code = 'CANCEL') then
      IF (x_event_id is not null) THEN
          x_event_title := getEventTitle (x_doc_number);
          IF x_event_title IS NOT NULL THEN
             x_message_name := 'NEGOTIATION_CANCELED_EVENT';
          END IF;
      ELSE
          x_message_name := 'NEGOTIATION_CANCELED';
      END IF;
    elsif (action_code = 'DISQUALIFY_BID') then
        x_message_name := 'BID_DISQUALIFY_NOTIFY_OTHER';

    end if;

   FOR bidder IN bidders LOOP

      if (member_user(bidder.user_name)) then

         PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(bidder.user_name,x_language_code);
         x_trading_partner_contact_id := bidder.person_party_id;

         -- Get the timezone for the user
         x_timezone := Get_Time_Zone(bidder.user_name);

         FOR bidder_info IN bidders_info LOOP

          x_bidder_tp_name := bidder_info.trading_partner_name;
          x_vendor_site_code := bidder_info.vendor_site_code;
          x_vendor_site_id := bidder_info.vendor_site_id;

          -- bug#16690631 for surrogate quote enhancement
          CHECK_NOTIFY_USER_INFO(bidder.user_name,
                        x_trading_partner_contact_id,
                        l_tp_contact_user_name);
          x_bidder_user_name:= l_tp_contact_user_name;


          -- send a notification to bidders
          SEND_BIDDERS_NOTIFICATION(itemtype                   => itemtype,
                                 itemkey                       => itemkey,
                                 actid                         => actid,
                                 p_action_code                 => action_code,
                                 p_user                        => x_bidder_user_name,
                                 p_bidder_tp_name              => x_bidder_tp_name,
                                 p_vendor_site_code            => x_vendor_site_code,
                                 p_vendor_site_id              => x_vendor_site_id,
                                 p_message_name                => x_message_name,
                                 p_doc_number_dsp              => x_doc_number_dsp,
                                 p_auction_title               => x_auction_title,
                                 p_auction_start_date          => x_auction_start_date,
                                 p_auction_end_date            => x_auction_end_date,
                                 p_preview_date                => x_preview_date,
                                 p_language_code               => x_language_code,
                                 p_timezone                    => x_timezone,
                                 p_change_type                 => x_change_type,
                                 p_original_close_bidding_date => x_original_close_bidding_date,
                                 p_event_title                 => x_event_title,
                                 p_auc_tp_contact_name         => x_tp_contact_name,
                                 p_staggered_closing_interval  => x_staggered_closing_interval);


         END LOOP;
      elsif (additional_bidder(bidder.user_name, x_doc_number, x_tp_contact_name, x_profile_user)) then
         -- Bug 3824928: logic here will handle additional contact users
         -- associated to a trading partner contact id or not.

        PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_profile_user,x_language_code);

       select nvl(trading_partner_name, requested_supplier_name) trading_partner_name,
              decode(vendor_site_code, '-1', null, vendor_site_code) vendor_site_code,
              nvl(vendor_site_id, -1) vendor_site_id
       into x_bidder_tp_name, x_vendor_site_code, x_vendor_site_id
       from pon_bidding_parties
       where wf_user_name = bidder.user_name
       and auction_header_id = x_doc_number;

       -- Get the timezone for the user
       x_timezone := Get_Time_Zone(x_profile_user);

       -- send a notification to additional bidder contact
       SEND_BIDDERS_NOTIFICATION(itemtype                      => itemtype,
                                 itemkey                       => itemkey,
                                 actid                         => actid,
                                 p_action_code                 => action_code,
                                 p_user                        => bidder.user_name,
                                 p_bidder_tp_name              => x_bidder_tp_name,
                                 p_vendor_site_code            => x_vendor_site_code,
                                 p_vendor_site_id              => x_vendor_site_id,
                                 p_message_name                => x_message_name,
                                 p_doc_number_dsp              => x_doc_number_dsp,
                                 p_auction_title               => x_auction_title,
                                 p_auction_start_date          => x_auction_start_date,
                                 p_auction_end_date            => x_auction_end_date,
                                 p_preview_date                => x_preview_date,
                                 p_language_code               => x_language_code,
                                 p_timezone                    => x_timezone,
                                 p_change_type                 => x_change_type,
                                 p_original_close_bidding_date => x_original_close_bidding_date,
                                 p_event_title                 => x_event_title,
                                 p_auc_tp_contact_name         => x_tp_contact_name,
                                 p_staggered_closing_interval  => x_staggered_closing_interval);


    end if;

  END LOOP;
  UNSET_SESSION_LANGUAGE;

end;

PROCEDURE NOTIFY_BIDDERS_OF_CLOSEEARLY (itemtype            in varchar2,
                                    itemkey             in varchar2,
                                    actid               in number,
                                    uncmode             in varchar2,
                                    resultout           out NOCOPY varchar2)
IS
   x_action_code varchar2(40) := 'CLOSEEARLY';
BEGIN

        NOTIFY_BIDDERS_AUC_CHANGED(itemtype,
                                   itemkey,
                                   actid,
                                   uncmode,
                                   x_action_code);
END;

PROCEDURE NOTIFY_BIDDERS_OF_CLOSECHANGED (itemtype            in varchar2,
                                    itemkey             in varchar2,
                                    actid               in number,
                                    uncmode             in varchar2,
                                    resultout           out NOCOPY varchar2)
IS
   x_action_code varchar2(40) := 'CLOSECHANGED';
BEGIN

        NOTIFY_BIDDERS_AUC_CHANGED(itemtype,
                                   itemkey,
                                   actid,
                                   uncmode,
                                   x_action_code);
END;


PROCEDURE  NOTIFY_NEW_INVITEES (p_auction_id  NUMBER) IS -- 1

x_auction_header_id  NUMBER;
x_preview_date     DATE;
x_progress     VARCHAR2(3);
x_sequence    NUMBER;
x_itemtype    VARCHAR2(8) := 'PONPBLSH';
x_itemkey    VARCHAR2(50);
x_user_name    VARCHAR2(100);
x_contact_id    NUMBER;
x_timezone    VARCHAR2(80);
x_timezone1    VARCHAR2(80);
x_newstarttime    DATE;
x_newendtime    DATE;
x_startdate    DATE;
x_enddate    DATE;
x_auctioneer_tag        Varchar2(30);
x_event_id              NUMBER;
x_event_title           VARCHAR2(80);
x_language_code    VARCHAR2(30);
x_auctioneer_user_name  VARCHAR2(100);
x_preview_message       VARCHAR2(100);
x_article_doc_type      VARCHAR2(100);

x_doctype_group_name    VARCHAR2(100);
x_msg_suffix     VARCHAR2(3) := '';
x_doc_number_dsp   VARCHAR2(30);
x_auction_contact_id    NUMBER;
x_oex_timezone          VARCHAR2(80);
x_oex_timezone1          VARCHAR2(80);

x_wf_role_name          VARCHAR2(30);
x_app                   VARCHAR2(20);

x_oex_header            VARCHAR2(2000);
x_oex_footer            VARCHAR2(2000);
x_status                VARCHAR2(10);
x_exception_msg         VARCHAR2(100);
x_oex_operation    VARCHAR2(2000);
x_auction_owner_tp_name VARCHAR2(300);
x_tp_display_name  VARCHAR2(300);
x_auction_title    VARCHAR2(2000);
--lxchen
x_note_to_new_supplier_type  VARCHAR2(30);

p_itemtype varchar2(20) := 'PONAUCT';
p_itemkey varchar2(360);
x_timezone_disp VARCHAR2(240);
x_auction_header_id_encrypted VARCHAR2(2000);
x_vendor_site_id     NUMBER;
x_preview_date_notspec VARCHAR2(240);


BEGIN

      select wf_item_key into p_itemkey
      from pon_auction_headers_all
      where auction_header_id = p_auction_id;

      x_progress := '010';

      x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                          itemkey  => p_itemkey,
                                                          aname    => 'AUCTION_ID');


      -- Bug 8992789
      IF (IS_INTERNAL_ONLY(x_auction_header_id)) THEN
        RETURN;
      END IF;

      x_auction_header_id_encrypted := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                         itemkey  => p_itemkey,
                                                         aname    => 'AUCTION_ID_ENCRYPTED');

      x_preview_date := wf_engine.GetItemAttrDate (itemtype   => p_itemtype,
                                                   itemkey    => p_itemkey,
                                                   aname      => 'PREVIEW_DATE');

      x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                           itemkey  => p_itemkey,
                                                           aname    => 'PREVIEW_DATE_NOTSPECIFIED');

      BEGIN
            x_doctype_group_name := wf_engine.GetItemAttrText   (itemtype => p_itemtype,
                                                                 itemkey  => p_itemkey,
                                                                 aname    => 'DOC_INTERNAL_NAME');
      EXCEPTION
      WHEN OTHERS THEN
            select dt.doctype_group_name
            into x_doctype_group_name
            from pon_auction_headers_all auh, pon_auc_doctypes dt
            where auh.auction_header_id = x_auction_header_id
            and auh.doctype_id = dt.doctype_id;
      END;

      BEGIN
            x_doc_number_dsp     := wf_engine.GetItemAttrText   (itemtype => p_itemtype,
                                                                 itemkey  => p_itemkey,
                                                                 aname    => 'DOC_NUMBER');
      EXCEPTION
      WHEN OTHERS THEN
            x_doc_number_dsp   := to_char(x_auction_header_id);
      END;



      --
      -- Get next value in sequence for itemkey
      --

      SELECT pon_auction_wf_publish_s.nextval
      INTO   x_sequence
      FROM   dual;


      x_itemkey := (p_itemkey||'-'||to_char(x_sequence));

      wf_engine.CreateProcess(itemtype => x_itemtype,
                              itemkey  => x_itemkey,
                              process  => 'ADDED_INVITEES_MESSAGE');

      --
      -- Set all the item attributes
      --

      x_progress := '022';

      wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'AUCTION_ID',
                                   avalue     => x_auction_header_id); /* using auction_id instead of
                                                                         auction_number as a standard
                                                                         across item types */

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_NUMBER',
                                 avalue     => x_doc_number_dsp);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'ORIGIN_USER_NAME',
                                 avalue     => fnd_global.user_name);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NOTE_TO_BIDDERS',
                                 avalue     => replaceHtmlChars(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'NOTE_TO_BIDDERS')));

      --SLM UI Enhancement
      PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(x_itemtype, x_itemkey, x_auction_header_id);

      select view_by_date
      into x_preview_date
      from pon_auction_headers_all where auction_header_id = x_auction_header_id;

      x_auction_title := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'AUCTION_TITLE');

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_TITLE',
                                 avalue     => replaceHtmlChars(x_auction_title));

      x_auction_owner_tp_name := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'PREPARER_TP_NAME');

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PREPARER_TP_NAME',
                             avalue     => x_auction_owner_tp_name);

      wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'NUMBER_OF_ITEMS',
                             avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                                 itemkey  => p_itemkey,
                                                                aname    => 'NUMBER_OF_ITEMS'));
      wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PREVIEW_DATE',
                             avalue     => x_preview_date);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PREVIEW_DATE_NOTSPECIFIED',
                             avalue     => x_preview_date_notspec);

      BEGIN
            wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
                                         itemkey    => x_itemkey,
                                         aname      => 'DOC_ROUND_NUMBER',
                                         avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                                                                    itemkey  => p_itemkey,
                                                                                    aname    => 'DOC_ROUND_NUMBER'));
      EXCEPTION
      WHEN OTHERS THEN
            wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                         itemkey    => x_itemkey,
                                         aname      => 'DOC_ROUND_NUMBER',
                                         avalue     => 1);
      END;

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'DOC_INTERNAL_NAME',
                               avalue     => x_doctype_group_name);

      begin

        wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                         itemkey    => x_itemkey,
                                         aname      => '#WFM_HTMLAGENT',
                                         avalue     => pon_wf_utl_pkg.get_base_external_supplier_url);
      exception when others then
        null;
      end;

     -- Bug 4295915: Set the  workflow owner
      wf_engine.SetItemOwner(itemtype => x_itemtype,
                             itemkey  => x_itemkey,
                             owner    => fnd_global.user_name);

      --
      -- Start the workflow
      --

      wf_engine.StartProcess(itemtype => x_itemtype,
                             itemkey  => x_itemkey );

END;

PROCEDURE NOTIFY_ADDED_INVITEES(x_itemtype          in varchar2,
                               x_itemkey           in varchar2,
                               actid               in number,
                               uncmode             in varchar2,
                               resultout           out NOCOPY varchar2) IS

x_role_name VARCHAR2(240);
x_user_name VARCHAR2(100);
x_additional_user_name          VARCHAR2(100);
x_progress      VARCHAR2(3);
x_sequence      NUMBER;
x_user_orig_system    VARCHAR2(30);
x_stringa                       VARCHAR2(30);
x_user_orig_system_id    NUMBER;
x_role_orig_system    VARCHAR2(30) := 'WF_LOCAL_ROLES';
x_role_orig_system_id    NUMBER := 0;
x_person_party_id               NUMBER;
x_bidder_count      NUMBER;
x_message      VARCHAR2(80);
x_language_code      VARCHAR2(30);
x_nid         NUMBER;
x_auction_header_id    NUMBER;
p_itemtype      VARCHAR2(8) := 'PONAUCT';
p_itemkey      VARCHAR2(240);
x_member      VARCHAR2(8) := 'None';
x_doctype_group_name    VARCHAR2(80);
x_msg_suffix      VARCHAR2(8);
x_oex_timezone          VARCHAR2(80);
x_oex_timezone1          VARCHAR2(80);
x_timezone    VARCHAR2(80);
x_timezone1    VARCHAR2(80);
x_tp_display_name  VARCHAR2(300);
x_startdate    DATE;
x_enddate    DATE;
x_newstarttime    DATE;
x_newendtime    DATE;
x_preview_date     DATE;
x_newpreviewtime     DATE;
x_open_bidding_date  DATE;

x_auctioneer_user_name  VARCHAR2(100);
x_preview_message       VARCHAR2(100);
x_article_doc_type      VARCHAR2(100);

x_wf_role_name          VARCHAR2(30);
x_app                   VARCHAR2(20);
x_invitation_id    NUMBER;

x_oex_header            VARCHAR2(2000);
x_oex_footer            VARCHAR2(2000);
x_status                VARCHAR2(10);
x_exception_msg         VARCHAR2(100);
x_operation_url   VARCHAR2(300);
x_oex_operation    VARCHAR2(2000);
x_auction_owner_tp_name VARCHAR2(300);
x_auction_title    VARCHAR2(2000);
x_note_to_new_supplier_type  VARCHAR2(30);
x_doc_number_dsp   VARCHAR2(30);

x_auction_type          Varchar2(30);
x_auction_type_name     Varchar2(30) := '';
x_event_id              NUMBER;
x_event_title           VARCHAR2(80);
flag       BOOLEAN;
t_itemtype    VARCHAR2(8) := 'PONPBLSH';
t_itemkey    VARCHAR2(50);
x_appstr                VARCHAR2(20);
x_auction_creator_contact_id  NUMBER;
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);

-- Added the following declaration for Affiliate ID related changes
-- Auctioneer's trading partner id
x_tp_id                      NUMBER;

x_nls_language               VARCHAR2(60);
x_territory_code             VARCHAR2(30);
x_nls_territory              VARCHAR2(60);

x_nls_addnl_language         VARCHAR2(60);
x_nls_addnl_territory        VARCHAR2(30);
x_registration_key           VARCHAR2(100);
x_neg_summary_url_supplier   VARCHAR2(2000);
x_l_neg_summary_url_supplier   VARCHAR2(2000);
x_isp_supplier_register_url  VARCHAR2(2000);
x_ack_part_url_supplier      VARCHAR2(2000);
x_vendor_site_code           PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE;
x_vendor_site_id       NUMBER;
x_auction_header_id_encrypted VARCHAR2(2000);
x_preview_date_notspec VARCHAR2(240);
x_staggered_closing_interval NUMBER;
x_staggered_close_note       VARCHAR2(1000);


-- added following for requested suppliers project
l_requested_supplier      BOOLEAN;
x_rs_user_name            VARCHAR2(100);
x_nls_rs_language         VARCHAR2(60);
x_nls_rs_territory        VARCHAR2(30);

-- Bug 17525991
x_supp_reg_qual_flag    pon_auction_headers_all.supp_reg_qual_flag%TYPE;

l_users WF_DIRECTORY.UserTable;

--SLM UI Enhancement
l_neg_assess_doctype VARCHAR2(15);

cursor newInvitees is
    select
     trading_partner_contact_name,
     trading_partner_contact_id,
     trading_partner_name,
     trading_partner_id,
     wf_user_name,
     additional_contact_email,
       registration_id,
       decode(pbp.vendor_site_code, '-1', null, pbp.vendor_site_code) vendor_site_code,
       pbp.vendor_site_id,
       pbp.requested_supplier_id,
       pbp.requested_supplier_name,
       pbp.requested_supplier_contact_id,
       pbp.requested_supp_contact_name,
       pcr.email_address rs_contact_email
    from pon_bidding_parties pbp,
         pos_contact_requests pcr
    where auction_header_id = x_auction_header_id
    and pbp.requested_supplier_contact_id = pcr.contact_request_id(+)
    and wf_item_key IS NULL;

CURSOR c1_auction_type IS
    select auction_type, event_id, event_title, open_bidding_date, trading_partner_id,
           staggered_closing_interval, supp_reg_qual_flag
    from pon_auction_headers_all
    where auction_header_id = x_auction_header_id;

BEGIN
    x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype   => x_itemtype,
                                                       itemkey    => x_itemkey,
                                                       aname      => 'AUCTION_ID'); /* using auction_id instead of
                                                                                     auction_number as a standard
                                                                                     across item types */

    -- Bug 8992789
    IF (IS_INTERNAL_ONLY(x_auction_header_id)) THEN
      RETURN;
    END IF;

    select wf_item_key , trading_partner_contact_name into p_itemkey, x_auctioneer_user_name
      from pon_auction_headers_all
      where auction_header_id = x_auction_header_id;

--    x_auctioneer_user_name := wf_engine.GetItemAttrText (itemtype => p_itemtype,
--                                               itemkey  => p_itemkey,
--                                                     aname    => 'PREPARER_TP_CONTACT_NAME');

    x_auction_header_id_encrypted := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                         itemkey  => p_itemkey,
                                                         aname    => 'AUCTION_ID_ENCRYPTED');

    x_doc_number_dsp :=  wf_engine.GetItemAttrText (itemtype   => x_itemtype,
                                         itemkey    => x_itemkey,
                                         aname      => 'DOC_NUMBER');

    x_auction_owner_tp_name := wf_engine.GetItemAttrText (itemtype => x_itemtype,
                                                          itemkey  => x_itemkey,
                                                          aname    => 'PREPARER_TP_NAME');

    x_auction_title := wf_engine.GetItemAttrText(itemtype => x_itemtype,
                                                 itemkey  => x_itemkey,
                                                 aname    => 'AUCTION_TITLE');


    x_preview_date := wf_engine.GetItemAttrDate (itemtype => x_itemtype,
                                      itemkey  => x_itemkey,
                                       aname    => 'PREVIEW_DATE');

     x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => x_itemtype,
                                                           itemkey  => x_itemkey,
                                                           aname    => 'PREVIEW_DATE_NOTSPECIFIED');


    x_doctype_group_name := wf_engine.GetItemAttrText   (itemtype => x_itemtype,
                                                         itemkey  => x_itemkey,
                                                         aname    => 'DOC_INTERNAL_NAME');

    x_startdate := wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                                              itemkey  => p_itemkey,
                                              aname    => 'AUCTION_START_DATE');

    x_enddate   := wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                                              itemkey  => p_itemkey,
                                              aname    => 'AUCTION_END_DATE');

    --SLM UI Enhancement
    l_neg_assess_doctype := PON_SLM_UTIL_PKG.GET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => x_itemtype,
                                                                        p_itemkey  => x_itemkey);

    --x_msg_suffix := GET_MESSAGE_SUFFIX (x_doctype_group_name);
    --SLM UI Enhancement :
    x_msg_suffix := PON_SLM_UTIL_PKG.GET_AUCTION_MESSAGE_SUFFIX (x_auction_header_id, x_doctype_group_name);

    IF x_auctioneer_user_name is not null THEN
       PON_PROFILE_UTIL_PKG.GET_WF_PREFERENCES(x_auctioneer_user_name,x_language_code,x_territory_code);
    END IF;

    select NLS_LANGUAGE into x_nls_language
    from fnd_languages
    where language_code = x_language_code;

    select nls_territory into x_nls_territory
    from   fnd_territories
    where  territory_code = x_territory_code;

    open c1_auction_type;
    fetch c1_auction_type
    into x_auction_type,
         x_event_id,
         x_event_title,
   x_open_bidding_date,
         x_tp_id,
         x_staggered_closing_interval,
         x_supp_reg_qual_flag;
    close c1_auction_type;


    select wf_role_name, wf_item_key into x_role_name, p_itemkey
    from pon_auction_headers_all
    where auction_header_id = x_auction_header_id;

    x_oex_timezone := Get_Oex_Time_Zone;

   -- Get the auctioneer's language
     PON_PROFILE_UTIL_PKG.GET_WF_PREFERENCES(x_auctioneer_user_name,x_language_code,x_territory_code);
     for bidder in newInvitees loop

       -- Bug 3824928: Removed unnecessary statements from this version

    -- If we have a contact name, use it.
      -- Bug 3824928: Trading partner contact id can be null
      IF bidder.trading_partner_contact_id IS NOT NULL THEN -- {

      x_person_party_id := bidder.trading_partner_contact_id;

         -- check if the contact is in the role - if not this is a new invitee
      x_user_name := GET_USER_NAME(x_person_party_id);

       select count(*) into x_bidder_count
     from wf_local_user_roles
     where role_name = x_role_name
     and user_name = x_user_name;


     if (x_bidder_count < 1) then

        -- Add new user and send notification.

        /*WF_DIRECTORY.AddUsersToAdHocRole(x_role_name,
                     x_user_name);*/
		-- Modified from  AddUsersToAdHocRole to AddUsersToAdHocRole2 for bug 11067310
 	    if (x_user_name is NOT NULL) then
 	        string_to_userTable(x_user_name, l_users);
 	        WF_DIRECTORY.AddUsersToAdHocRole2(x_role_name,
 	                                       l_users);
 	    end if;
       end if; -- Bug 3824928: Added end if

      -- send notfication to this bidder.


      -- Set bidder specific attributes

     -- Bug 3824928: calling get_wf_preferences instead of get_wf_language

       PON_PROFILE_UTIL_PKG.GET_WF_PREFERENCES(x_user_name,x_language_code,x_territory_code);

    --
    -- Get the user's time zone
    --
     x_timezone := Get_Time_Zone(x_person_party_id);
     ELSE  -- Bug 3824928: bidder.trading_partner_contact_id IS NULL

    --
    -- Get the auctioneer's time zone

        x_timezone := Get_Time_Zone(x_auctioneer_user_name);
              if (x_timezone is null or x_timezone = '') then
                             x_timezone := x_oex_timezone;
              end if;

     END IF; -- } IF bidder.trading_partner_contact_id IS NOT NULL

        -- Convert the dates to the user's or auctioneer's timezone
    -- If the timezone is not recognized, just use PST
    --

    IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN
       x_newstarttime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_startdate,x_oex_timezone,x_timezone);
       x_newendtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_enddate,x_oex_timezone,x_timezone);
           if x_preview_date is not null then
         x_newpreviewtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone);
           end if;
    ELSE
       x_newstarttime := x_startdate;
       x_newendtime := x_enddate;
           x_newpreviewtime := x_preview_date;
       x_timezone := x_oex_timezone;
    END IF;

        -- check if supplier is requested supplier
        IF (bidder.trading_partner_id is null
            AND bidder.requested_supplier_id is not null)THEN
           l_requested_supplier := TRUE;
        END IF;

        x_tp_display_name := nvl(bidder.trading_partner_name, bidder.requested_supplier_name);

        x_vendor_site_code := bidder.vendor_site_code;

        x_vendor_site_id := bidder.vendor_site_id;


      -- this is needed here because of a bug in wf (fixed in 2.6)
      UNSET_SESSION_LANGUAGE;

      SELECT pon_auction_wf_publish_s.nextval
      INTO   x_sequence
      FROM   dual;

      t_itemkey := (x_itemkey||'-'||to_char(x_sequence));

      wf_engine.CreateProcess(itemtype => t_itemtype,
                              itemkey  => t_itemkey,
                        process  => 'SEND_ADDED_INVITEES');

      IF (l_requested_supplier) THEN

            wf_engine.SetItemAttrText (itemtype => t_itemtype,
                                       itemkey    => t_itemkey,
                                       aname    => 'REQ_SUPPLIER_CONTACT_NAME',
                                       avalue   => bidder.requested_supp_contact_name);
      ELSE
            wf_engine.SetItemAttrText (itemtype => t_itemtype,
                                       itemkey  => t_itemkey,
                                       aname    => 'BIDDER_TP_CONTACT_NAME',
                                       avalue   => x_user_name);
      END IF;

      wf_engine.SetItemAttrNumber (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'TRADING_PARTNER_ID',
               avalue   => bidder.trading_partner_id);

            wf_engine.SetItemAttrNumber (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'AUCTION_ID',
               avalue   => x_auction_header_id); /* using auction_id instead of
                                                           auction_number as a standard
                                                           across item types */

            BEGIN
                 x_staggered_close_note := NULL;
                 IF x_staggered_closing_interval IS NOT NULL THEN
                     x_staggered_close_note := wf_core.newline || wf_core.newline ||
                                               getMessage('PON_STAGGERED_CLOSE_NOTIF_MSG') ||
                                               wf_core.newline || wf_core.newline;
                 END IF;
                 wf_engine.SetItemAttrText( itemtype     => t_itemtype,
                                            itemkey      => t_itemkey,
                                            aname        => 'STAGGERED_CLOSE_NOTE',
                                            avalue       => x_staggered_close_note);
            EXCEPTION                                                                                                                                                       WHEN OTHERS THEN NULL;
                                                                                                                                                                      END;

            IF (x_language_code is not null) THEN

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
                FND_LOG.string(log_level => FND_LOG.level_statement,
                  module => g_module_prefix || 'NOTIFY_ADDED_INVITEES',
                  message  => '7. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
                END IF; --}

        SET_SESSION_LANGUAGE(null, x_language_code);
            END IF;


      --- 000001

      -- Begin Bug 9309785
      -- Use a different subject for Supplier Hub
      -- Bug 17525991
      -- Use different subject only for Supplier Registration and Pre-Qualification RFI
      IF (x_supp_reg_qual_flag = 'Y' AND l_requested_supplier) THEN
        wf_engine.SetItemAttrText (itemtype       => t_itemtype,
                                   itemkey        => t_itemkey,
                                   aname          => 'INVITE_RESPONSE_SUB',
                                   avalue         => getMessage('PON_SM_AUC_WF_PUB_OPEN_RG_S'));

        wf_engine.SetItemAttrText (itemtype       => t_itemtype,
                                   itemkey        => t_itemkey,
                                   aname          => 'ISP_NEW_SUPPLIER_REG_URL',
                                   avalue         => get_supplier_reg_url(bidder.requested_supplier_id));

        -- Bug 10075648
        -- Update supplier registration status to 'Supplier to Provide Details' when sending notification.
        update_supplier_reg_status(bidder.requested_supplier_id);
      ELSE
            wf_engine.SetItemAttrText (itemtype       => t_itemtype,
                                       itemkey        => t_itemkey,
                                       aname          => 'INVITE_RESPONSE_SUB',
                                       avalue         => getMessage('PON_AUC_WF_PUB_OPEN_RG_S', x_msg_suffix,
                                                                    'DOC_NUMBER', x_doc_number_dsp,
                                                                    'AUCTION_TITLE', replaceHtmlChars(x_auction_title)));
      END IF;
      -- End Bug 9309785

      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
                           itemkey  => t_itemkey,
                           aname  => 'PREPARER_TP_CONTACT_NAME',
                           avalue   => x_auctioneer_user_name);

      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
                           itemkey  => t_itemkey,
                           aname  => 'TP_DISPLAY_NAME',
                           avalue   => x_tp_display_name);

        wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                                   itemkey    => t_itemkey,
                                   aname      => 'BIDDER_TP_NAME',
                                   avalue     => x_tp_display_name);

        --Bug 16666395 modified from vendor_site_code to address
	wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                               itemkey    => t_itemkey,
                               aname      => 'BIDDER_TP_ADDRESS_NAME',
                               avalue     => GET_VENDOR_SITE_ADDRESS(x_vendor_site_id));

    -- Item attribute value is going to be used as a parameter to Acknowledge Participation page
        wf_engine.SetItemAttrNumber (itemtype   => t_itemtype,
                               itemkey    => t_itemkey,
                               aname      => 'VENDOR_SITE_ID',
                               avalue     => x_vendor_site_id);

        -- call to notification utility package to get the redirect page url that
        -- is responsible for getting the Negotiation Summary url and forward to it.
        x_neg_summary_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PON_NEG_SUMMARY'
                                 ,p_notif_performer  => 'SUPPLIER');

--Bug 11898698
--Modifying the language_code in the URL with that of the recipient
--The profile "ICX_LANGUAGE" needs to be set for the recipient for this fix
x_neg_summary_url_supplier:=regexp_replace(x_neg_summary_url_supplier , 'language_code='||fnd_global.current_language, 'language_code='||x_language_code);

        wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                               itemkey    => t_itemkey,
                               aname      => 'NEG_SUMMARY_URL',
                               avalue     => x_neg_summary_url_supplier);

      --Bug 14572394
  x_l_neg_summary_url_supplier:=   pos_url_pkg.get_external_login_url||'?requestUrl='||wfa_html.conv_special_url_chars(x_neg_summary_url_supplier);
  x_l_neg_summary_url_supplier:=  regexp_replace(x_l_neg_summary_url_supplier ,'notificationId%3D%26%23NID', 'notificationId%3D&#NID');

    IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS  NULL ) THEN
            wf_engine.SetItemAttrText (itemtype     => t_itemtype,
                                        itemkey      => t_itemkey,
                                        aname      =>
                                  'LOGIN_VIEW_DETAILS_TB',
                                        avalue      => null);
            wf_engine.SetItemAttrText (itemtype     => t_itemtype,
                                        itemkey      => t_itemkey,
                                        aname      =>
                                  'LOGIN_VIEW_DETAILS_HB',
                                        avalue      => null);
    ELSE
            wf_engine.SetItemAttrText (itemtype => t_itemtype,
                                        itemkey      => t_itemkey,
                                        aname      =>
                                  'LOGIN_VIEW_DETAILS_URL',
                                    avalue => x_l_neg_summary_url_supplier);
    END IF;

        begin
          wf_engine.SetItemAttrText   (itemtype   => t_itemtype,
                                         itemkey    => t_itemkey,
                                         aname      => '#WFM_HTMLAGENT',
                                         avalue     => pon_wf_utl_pkg.get_base_external_supplier_url);
        exception
          when others then
            null;
        end;

      if (x_open_bidding_date < sysdate) then


      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'PON_AUC_WF_DOC_IN_PR0G',
               avalue   => getMessage('PON_AUC_WF_DOC_IN_PR0G', x_msg_suffix));

      end if;


      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'PREPARER_TP_NAME',
               avalue   => x_auction_owner_tp_name);


      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'AUCTION_TITLE',
               avalue   => replaceHtmlChars(x_auction_title));


      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'DOC_NUMBER',
               avalue   => x_doc_number_dsp);

        x_timezone_disp := Get_TimeZone_Description(x_timezone, x_language_code);
        IF (x_preview_date IS NULL) THEN
        x_timezone1_disp := null;
    ELSE
        x_timezone1_disp := x_timezone_disp;
    END IF;

  IF (x_preview_date is not null) THEN
         wf_engine.SetItemAttrDate (itemtype  => t_itemtype,
                   itemkey  => t_itemkey,
                   aname  => 'PREVIEW_DATE',
                   avalue   => x_newpreviewtime);

         wf_engine.SetItemAttrDate (itemtype  => t_itemtype,
                   itemkey  => t_itemkey,
                   aname  => 'PREVIEW_DATE_TZ',
                   avalue   => x_newpreviewtime);

         wf_engine.SetItemAttrText (itemtype  => t_itemtype,
                   itemkey  => t_itemkey,
                   aname  => 'TP_TIME_ZONE1',
                   avalue   => x_timezone1_disp);

         wf_engine.SetItemAttrText (itemtype  => t_itemtype,
                           itemkey  => t_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => null);
    ELSE
         wf_engine.SetItemAttrDate (itemtype  => t_itemtype,
                  itemkey  => t_itemkey,
                  aname  => 'PREVIEW_DATE',
                  avalue   => null);

         wf_engine.SetItemAttrDate (itemtype  => t_itemtype,
                   itemkey  => t_itemkey,
                   aname  => 'PREVIEW_DATE_TZ',
                   avalue   => null);

         wf_engine.SetItemAttrText (itemtype  => t_itemtype,
                   itemkey  => t_itemkey,
                   aname  => 'TP_TIME_ZONE1',
                   avalue   => x_timezone1_disp);

         wf_engine.SetItemAttrText (itemtype  => t_itemtype,
                           itemkey  => t_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));

  END IF;

      wf_engine.SetItemAttrDate (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'AUCTION_START_DATE_TZ',
               avalue   => x_newstarttime);

      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'TP_TIME_ZONE',
               avalue   => x_timezone_disp);


      wf_engine.SetItemAttrDate (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'AUCTION_END_DATE_TZ',
               avalue   => x_newendtime);

      wf_engine.SetItemAttrText (itemtype  => t_itemtype,
               itemkey  => t_itemkey,
               aname  => 'ORIGIN_USER_NAME',
               avalue   => fnd_global.user_name);

      --SLM UI Enhancement
      PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE (p_itemtype  => t_itemtype,
                                                   p_itemkey  => t_itemkey,
                                                   p_value   => l_neg_assess_doctype);
  -- Bug 3824928: Deleted unwanted lines here


  -- end if;
    -- Bug 3824928: Checking if additional_contact_email is not null

   if bidder.additional_contact_email is not NULL THEN --{

         SELECT pon_auction_wf_bidder_s.nextval
      INTO   x_sequence
      FROM   dual;
        -- Bug 3824928 - check if the additional contact is in the role - if
        -- not this is the additional contact of a new invitee


         select count(*) into x_bidder_count
         from wf_local_user_roles
         where role_name = x_role_name
        and user_name = bidder.wf_user_name;

       if (x_bidder_count < 1) then


      x_additional_user_name := ('WF_PON_USER_'||to_char(x_sequence));

         wf_engine.SetItemAttrText (itemtype  => t_itemtype,
             itemkey  => t_itemkey,
               aname  => 'ADDITIONAL_CONTACT_USERNAME',
               avalue   => x_additional_user_name);

              -- add a registration link in FPH for additional contact
              begin
                 select registration_key
                  into x_registration_key
                  from fnd_registrations
                 where registration_id = bidder.registration_id;
              exception
                  WHEN NO_DATA_FOUND THEN
                       x_registration_key := '';
              end;

        -- call to notification utility package to get the iSupplier registration page url
        x_isp_supplier_register_url := pon_wf_utl_pkg.get_isp_supplier_register_url(p_registration_key => x_registration_key
                                                                                   ,p_language_code => x_language_code);


        wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                                   itemkey    => t_itemkey,
                                   aname      => 'ISP_SUPPLIER_REG_URL',
                                   avalue     => x_isp_supplier_register_url);

           -- call to notification utility package to get the redirect page url that
           -- is responsible for getting the Acknowledge participation url and forward to it.
           x_ack_part_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PONRESAPN_ACKPARTICIPATN'
                                 ,p_notif_performer  => 'SUPPLIER');

        wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                                   itemkey    => t_itemkey,
                                   aname      => 'ACK_PARTICIPATION_URL',
                                   avalue     => x_ack_part_url_supplier);

    -- Bug 3824928: if tpcontactid is not null use language and territory
        -- from tp contact id else use auctioneer's language and territory

        select NLS_LANGUAGE into x_nls_addnl_language
        from fnd_languages
        where language_code = x_language_code;

        select nls_territory into x_nls_addnl_territory
        from   fnd_territories
        where  territory_code = x_territory_code;


      WF_DIRECTORY.CreateAdHocUser(x_additional_user_name,
                                         x_additional_user_name,
                                         x_nls_addnl_language,
                                         x_nls_addnl_territory,
                                         'Oracle Exchange Additional Bidder '||to_char(x_auction_header_id),
                                             'MAILHTML',
                                         bidder.additional_contact_email,
                                         null,
                                         'ACTIVE',
                                             null);

    /*WF_DIRECTORY.AddUsersToAdHocRole(x_role_name,
                   x_additional_user_name);*/
	-- Modified from  AddUsersToAdHocRole to AddUsersToAdHocRole2 for bug 11067310
 	if (x_additional_user_name is NOT NULL) then
 	    string_to_userTable(x_additional_user_name, l_users);
 	    WF_DIRECTORY.AddUsersToAdHocRole2(x_role_name,
 	                                 l_users);
 	end if;

         -- Bug 3709564
         -- If this update is not performed here, it will error out
         -- in notify_bidder_list_reminder as wf_user_name will be null
            UPDATE pon_bidding_parties set
            wf_user_name = x_additional_user_name
            WHERE auction_header_id = x_auction_header_id
            AND  trading_partner_id = bidder.trading_partner_id
            AND  vendor_site_id = bidder.vendor_site_id;

      end if; -- if (x_bidder_count < 1)

   end if; -- } if bidder.additional_contact_email is not NULL

-- create adhoc user for this rs contact
if (l_requested_supplier and bidder.rs_contact_email is not NULL) THEN
-- {
       SELECT pon_auction_wf_bidder_s.nextval
                INTO   x_sequence
                FROM   dual;

       SELECT count(*) INTO x_bidder_count
       FROM wf_local_user_roles
       WHERE role_name = x_role_name
          AND user_name = bidder.wf_user_name;

       IF (x_bidder_count < 1) THEN  --{

          x_rs_user_name := ('WF_PON_USER_'||to_char(x_sequence));
          wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                                     itemkey    => t_itemkey,
                                     aname      => 'REQ_SUPPLIER_USERNAME',
                                     avalue   => x_rs_user_name); --(performer)

          x_ack_part_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
                                          p_dest_func => 'PONRESAPN_ACKPARTICIPATN'
                                         ,p_notif_performer  => 'SUPPLIER');

          wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                                   itemkey    => t_itemkey,
                                   aname      => 'ACK_PARTICIPATION_URL',
                                   avalue     => x_ack_part_url_supplier);

          -- create user

          WF_DIRECTORY.CreateAdHocUser(x_rs_user_name,
                     x_rs_user_name,
                     x_nls_rs_language,
                     x_nls_rs_territory,
                     'Oracle Exchange Requested Bidder'||to_char(x_auction_header_id),
                     'MAILHTML',
                     bidder.rs_contact_email,
                     null,
                     'ACTIVE',
                     null);

          /*WF_DIRECTORY.AddUsersToAdHocRole(x_role_name,
                                           x_rs_user_name);*/
		  -- Modified from  AddUsersToAdHocRole to AddUsersToAdHocRole2 for bug 11067310
 	      if (x_rs_user_name is NOT NULL) then
 	          string_to_userTable(x_rs_user_name, l_users);
 	          WF_DIRECTORY.AddUsersToAdHocRole2(x_role_name,
 	                                     l_users);
 	      end if;

          UPDATE pon_bidding_parties SET
            wf_user_name = x_rs_user_name
            WHERE auction_header_id = x_auction_header_id
            AND  (trading_partner_id = bidder.trading_partner_id
                             or requested_supplier_id = bidder.requested_supplier_id)
            AND  vendor_site_id = bidder.vendor_site_id;

      END IF; --} if (x_bidder_count < 1)

   END IF; --} if requested supplier

  --Bug 8446265 Modifications
    wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                               itemkey    => t_itemkey,
                               aname      => 'PON_INVITE_REQ_SUPP_RESP_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INVITE_REQ_SUPP_RESP_BODY/'||t_itemtype ||':' ||t_itemkey
                               );

    wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                               itemkey    => t_itemkey,
                               aname      => 'PON_INVITE_RESPONSE_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INVITE_CONT_RESP_BODY/'||t_itemtype ||':' ||t_itemkey
                               );

    wf_engine.SetItemAttrText (itemtype   => t_itemtype,
                               itemkey    => t_itemkey,
                               aname      => 'PON_INV_RESP_ADD_CONT_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INVITE_ADD_CONT_RESP_BODY/'||t_itemtype ||':' ||t_itemkey
                               );
	-- Amendment email for Prospective supplier : Bug 18097527
	wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_PROSP_SUPP_AMEND_BODY',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_AUC_AMEND_BODY_PROSP_SUPP/'||x_itemtype ||':' ||x_itemkey
                               );

	 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_INV_PROSP_SUPP_NEW_ROUND',
                               avalue     => 'PLSQLCLOB:pon_auction_pkg.GEN_INV_NEWRND_BODY_PROSP_SUPP/'||x_itemtype ||':' ||x_itemkey
                               );
    -- Bug 4295915: Set the  workflow owner
       wf_engine.SetItemOwner(itemtype => t_itemtype,
                              itemkey  => t_itemkey,
                              owner    => fnd_global.user_name);

  wf_engine.StartProcess(itemtype => t_itemtype,
                               itemkey  => t_itemkey );

    -- Bug 3709564
    -- If this update is not performed here, wf_engine.abort_process call
    -- in notify_bidder_list_reminder will fail, as wf_item_key will be null
       update pon_bidding_parties
       set wf_item_key = t_itemkey
       where  auction_header_id = x_auction_header_id and
              (trading_partner_id = bidder.trading_partner_id
               or requested_supplier_id = bidder.requested_supplier_Id) and
              vendor_site_id = bidder.vendor_site_id and
              wf_item_key is null;

    -- end if;  -- if newly added invitee check Bug 3824928 commenting this

    end loop;

    UNSET_SESSION_LANGUAGE;

END;


PROCEDURE SET_INVITATION_LIST_FLAG(p_auction_header_id  NUMBER) IS
  x_item_key VARCHAR2(240);
BEGIN

  select wf_item_key into x_item_key
  from pon_auction_headers_all
  where auction_header_id = p_auction_header_id;

        wf_engine.SetItemAttrText (itemtype   => 'PONAUCT',
                                   itemkey    => x_item_key,
                                   aname      => 'BIDDER_LIST_FLAG',
                                   avalue     => 'Y');
END;


FUNCTION GET_USER_NAME (p_user_id NUMBER) RETURN VARCHAR2
IS
x_user_name varchar2(100);
BEGIN
      begin
  select user_name
        into x_user_name
  from fnd_user
        where person_party_id = p_user_id
        and nvl(end_date,sysdate+1) > sysdate;
      exception
       when too_many_rows then
          if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
               if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                         fnd_log.string(log_level => fnd_log.level_unexpected,
                                        module    => 'pon.plsql.pon_auction_pkg.get_user_name',
                                        message   => 'Multiple Users found for person_party_id:'|| p_user_id);
               end if;
         end if;

         select user_name
         into x_user_name
         from fnd_user
         where person_party_id = p_user_id
         and nvl(end_date, sysdate+1) > sysdate
         and rownum=1;
      end;
      return x_user_name;
END;


FUNCTION MEMBER_USER(p_user_name VARCHAR2) RETURN BOOLEAN
IS
x_count int := 0;
BEGIN
  select count(*) into x_count
  from fnd_user where user_name = p_user_name;

  if (x_count > 0) then return true; else return false; end if;
END;


FUNCTION ADDITIONAL_BIDDER(p_user_name VARCHAR2, p_doc_id int, p_preparer_tp_contact_name varchar2,
x_profile_user IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
x_found BOOLEAN;
x_user_name VARCHAR2(100);
x_user_id   int;
BEGIN
  begin
    select trading_partner_contact_id
        into x_user_id
    from pon_bidding_parties
    where auction_header_id = p_doc_id
    and wf_user_name = p_user_name;

         if x_user_id is null then -- it means the additional contact is not associated to any
                                    -- tp_contact_id
             x_profile_user := p_preparer_tp_contact_name;
         else

       x_profile_user := GET_USER_NAME(x_user_id);

       if (x_profile_user is null) then -- this condition should not occur. It may
                                            -- occur if user is deleted from fnd_user table
       x_profile_user := p_preparer_tp_contact_name; -- Bug 3824928: changed from p_user_name to
                                                          -- default to the auctioneer name
       end if;
        end if;
    x_found := true;
  exception
    when no_data_found then
    -- no additional contact
    x_found := false;
  end;
  return x_found;

END;

FUNCTION Get_TimeZone_Description(p_timezone_id varchar2, lang varchar2) return varchar2
is
x_timezone_desc  varchar2(80) := '';
begin

  begin
    select name
    into x_timezone_desc
    from fnd_timezones_tl tl, fnd_timezones_b b
    where b.upgrade_tz_id = p_timezone_id
    and b.timezone_code = tl.timezone_code
          and tl.language = lang;
  exception
    when others  then
            null;
        end;

  return x_timezone_desc  ;
end;


FUNCTION Get_Oex_Time_Zone return varchar2
is
x_oex_timezone  varchar2(80) := '';
begin
    --
    -- Get the exchange time zone
    --
                x_oex_timezone :=  fnd_profile.value_specific('SERVER_TIMEZONE_ID');
    return x_oex_timezone;
end;


FUNCTION Get_Time_Zone(contact_id number) return varchar2
is
x_timezone  varchar2(80) := '';
x_user_id NUMBER;
begin
    --
    -- Get the contact/tp time zone
    --

  begin
    select user_id
    into  x_user_id
    from fnd_user
    where person_party_id = contact_id
                and nvl(end_date, sysdate+1) > sysdate;
    x_timezone := fnd_profile.value_specific('CLIENT_TIMEZONE_ID',x_user_id);
  exception
               when too_many_rows then
                  if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
                       if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                                 fnd_log.string(log_level => fnd_log.level_unexpected,
                                                module    => 'pon.plsql.pon_auction_pkg.get_time_zone',
                                                message   => 'Multiple Users found for person_party_id:'|| contact_id);
                       end if;
                 end if;

                 select user_id
                 into x_user_id
                 from fnd_user
                 where person_party_id = contact_id
                 and nvl(end_date, sysdate+1) > sysdate
                 and rownum=1;

                 x_timezone := fnd_profile.value_specific('CLIENT_TIMEZONE_ID',x_user_id);

               when NO_DATA_FOUND then
                  if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
                       if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                                 fnd_log.string(log_level => fnd_log.level_unexpected,
                                                module    => 'pon.plsql.pon_auction_pkg.get_time_zone',
                                                message   => 'No Active Users found for person_party_id:'|| contact_id);
                       end if;
                 end if;

                 select user_id
                 into x_user_id
                 from fnd_user
                 where person_party_id = contact_id
                 and rownum=1;

                 x_timezone := fnd_profile.value_specific('CLIENT_TIMEZONE_ID',x_user_id);

               when OTHERS then
                  if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
                       if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                                 fnd_log.string(log_level => fnd_log.level_unexpected,
                                                module    => 'pon.plsql.pon_auction_pkg.get_time_zone',
                                                message   => 'Unknown exception for person_party_id:'|| contact_id);
                       end if;
                 end if;
                 x_timezone := Get_Oex_Time_Zone;

  end;

  return x_timezone;


end;


FUNCTION Get_Time_Zone(contact_name varchar2) return varchar2
is
x_timezone  varchar2(80) := null;
x_contact_id number;
begin
         begin
    SELECT person_party_id
    INTO x_contact_id
    FROM fnd_user
    WHERE user_name = contact_name;
  exception
    when others then
    x_contact_id := null;
  end;

  if (x_contact_id is null) then
    return '';
  end if;

  --
  -- Get the contact/tp time zone
  --
  x_timezone := Get_Time_Zone(x_contact_id);

  return x_timezone;
end;


FUNCTION differentStrings(st1 VARCHAR2, st2 VARCHAR2) return BOOLEAN
IS
BEGIN
  if (st1 is not null and st2 is not null) then
    if (st1 = st2) then
      return false;
    else
      return true;
    end if;
  else
    return false;
  end if;
END;

----------------------------------------------------------------
-- getNeedByDatesToPrint
-- XTANG: in FPJ, we added timestamp to need-by dates.
----------------------------------------------------------------
Function getNeedByDatesToPrint(auctionID IN number, lineNumber IN number,userDateFormat IN varchar2) return varchar2 AS
outputString varchar2(8000) := '';
x_msg_suffix varchar2(3) := '';
needByFromDate Date := null;
needByToDate Date := null;
sLanguage varchar2(30) := 'US';
cursor c1(auctionID number,lineNumber number) is
select need_by_start_date,need_by_date
from   pon_auction_item_prices_all
where  auction_header_id = auctionID and
      line_number = lineNumber;
Begin
 begin
sLanguage := USERENV('LANG');
PON_AUCTION_PKG.SessionLanguage := sLanguage;

 open c1(auctionID,lineNumber);
    loop
       fetch c1 into needByFromDate,needByToDate;
     EXIT WHEN c1%NOTFOUND;
end loop;
if needByFromDate IS NOT NULL and needByToDate IS NULL then
return (getMessage('PON_AUC_NEEDBY_ONLY_START_DATE',x_msg_suffix,'FROMDATE',PON_OA_UTIL_PKG.DISPLAY_DATE_TIME(needByFromDate,fnd_profile.value('CLIENT_TIMEZONE_ID'),fnd_profile.value('SERVER_TIMEZONE_ID'),userDateFormat,'N')));
else
if needByFromDate IS NULL and needByToDate IS NOT NULL then
return (getMessage('PON_AUC_NEEDBY_ONLY_END_DATE',x_msg_suffix,'TODATE',PON_OA_UTIL_PKG.DISPLAY_DATE_TIME(needByToDate,fnd_profile.value('CLIENT_TIMEZONE_ID'),fnd_profile.value('SERVER_TIMEZONE_ID'),userDateFormat,'N')));
else
if needByFromDate IS NOT NULL and needByToDate IS NOT NULL then
return (getMessage('PON_AUC_NEEDBY_RANGE',x_msg_suffix,'FROMDATE',PON_OA_UTIL_PKG.DISPLAY_DATE_TIME(needByFromDate,fnd_profile.value('CLIENT_TIMEZONE_ID'),fnd_profile.value('SERVER_TIMEZONE_ID'),userDateFormat,'N'),
'TODATE',PON_OA_UTIL_PKG.DISPLAY_DATE_TIME(needByToDate,fnd_profile.value('CLIENT_TIMEZONE_ID'),fnd_profile.value('SERVER_TIMEZONE_ID'),userDateFormat,'N')));
else return (outputString);
          end if;
       end if;
end if;
    close c1;
 exception When others then
   return (outputString);
 end;
End getNeedByDatesToPrint;




PROCEDURE AUCTION_PO_SEND (
        transaction_code        IN     VARCHAR2,
        document_id             IN     NUMBER,
  party_id    IN     NUMBER,
        debug_mode              IN     PLS_INTEGER,
  trigger_id    OUT    NOCOPY  PLS_INTEGER,
  retcode            OUT    NOCOPY  PLS_INTEGER,
  errmsg      OUT    NOCOPY  VARCHAR2
)
IS
l_seq varchar2(10);
l_ItemType     VARCHAR2(8) := 'PONAUCT';
l_ItemKey      VARCHAR2(240) ;
l_debug_level varchar2(3);

BEGIN

trigger_id := 1;
retcode := 0;
errmsg := null;

l_debug_level := '0';
/* Hardcoded for present
begin
  select parameter_value into l_debug_level from pon_operator_parameters where parameter_name ='xmlDebugLevel' ;
  exception when others then
  l_debug_level := '0';
end;

 select to_char(PON_PO_WF_ITEMKEY_S.NEXTVAL)
 into l_seq from sys.dual;
*/
-- Hardcoded sequence number not acceptable
l_seq := 9999;
l_itemkey := to_char (document_id)|| '-' || l_seq;

wf_engine.createProcess     ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey,
                                  Process   => 'MAIN_AUCTION_PROCESS');

wf_engine.SetItemAttrText (   itemtype   => l_ItemType,
                                        itemkey    => l_ItemKey,
                                        aname      => 'XML_EVENT_KEY',
                                        avalue     => l_itemkey);

wf_engine.SetItemAttrText (      itemtype => l_ItemType,
                     itemkey  => l_ItemKey,
                     aname    => 'ECX_TRANSACTION_TYPE',
                     avalue   => 'PON_AUPO');
wf_engine.SetItemAttrText (      itemtype => l_ItemType,
                     itemkey  => l_ItemKey,
                     aname    => 'ECX_TRANSACTION_SUBTYPE',
                     avalue   => 'AUPO');

wf_engine.SetItemAttrText (      itemtype => l_ItemType,
                     itemkey  => l_ItemKey,
                     aname    => 'ECX_DOCUMENT_ID',
                     avalue   => document_id);

wf_engine.SetItemAttrText (      itemtype => l_ItemType,
                     itemkey  => l_ItemKey,
                     aname    => 'ECX_PARTY_ID',
                     avalue   => party_id);

wf_engine.SetItemAttrText (      itemtype => l_ItemType,
                     itemkey  => l_ItemKey,
                     aname    => 'ECX_PARTY_SITE_ID',
                     avalue   => party_id);

wf_engine.SetItemAttrText (   itemtype => l_ItemType,
                          itemkey => l_ItemKey,
        aname  => 'ECX_DEBUG_LEVEL',
        avalue => l_debug_level );

    -- Bug 4295915: Set the  workflow owner
wf_engine.SetItemOwner(itemtype => l_itemtype,
                       itemkey  => l_itemkey,
                       owner    => fnd_global.user_name);

wf_engine.StartProcess ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey );

END AUCTION_PO_SEND;

PROCEDURE SET_NEW_ITEM_KEY(  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out NOCOPY varchar2)
IS
l_doc_id number;
l_xml_event_key varchar2(100);
l_wf_item_seq number;
BEGIN
if (funcmode <> wf_engine.eng_run) then
       resultout := wf_engine.eng_null;
       return;  --do not raise the exception, as it would end the wflow.
end if;
l_doc_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid,
'ECX_DOCUMENT_ID');
/* sequence number hardcoded
select PON_PO_WF_ITEMKEY_S.nextval into l_wf_item_seq from dual;
*/
l_wf_item_seq := 9999;

 l_xml_event_key := to_char(l_doc_id) || '-' || to_char(l_wf_item_seq);

wf_engine.SetItemAttrText (   itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'XML_EVENT_KEY',
                              avalue     => l_xml_event_key);

END SET_NEW_ITEM_KEY;






 PROCEDURE CLOSEDATE_EARLIER_REMINDERDATE(  itemtype    in varchar2,
           itemkey    in varchar2,
                       actid           in number,
                       uncmode    in varchar2,
             resultout       out NOCOPY varchar2)
  IS

     x_closedate   DATE;
     x_reminderdate     DATE;
     x_this_auction_header_id   NUMBER;

BEGIN

    x_this_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                       aname    => 'AUCTION_ID');

   SELECT close_bidding_date, reminder_date
     INTO x_closedate, x_reminderdate
     FROM pon_auction_headers_all
     WHERE auction_header_id=x_this_auction_header_id;


    IF (x_closedate<x_reminderdate) THEN
  resultout := 'Y';
    ELSE
  resultout := 'N';

    END IF;

END;

PROCEDURE  update_ack_to_YES (        itemtype    in varchar2,
             itemkey    in varchar2,
             actid           in number,
             uncmode    in varchar2,
             resultout          out NOCOPY varchar2)

  IS

     x_trading_partner_id     NUMBER;
     x_wf_user_name    VARCHAR2(100);
     x_doc_number NUMBER;
     x_note     VARCHAR2(4000);
     x_closedate DATE;
     x_now DATE;
     x_auction_status VARCHAR2(100);
     x_vendor_site_id NUMBER;

BEGIN


    x_wf_user_name := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
             aname    => 'BIDDER_TP_CONTACT_NAME');

    x_trading_partner_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                               aname    => 'TRADING_PARTNER_ID');

    x_vendor_site_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                               aname    => 'VENDOR_SITE_ID');

    x_doc_number := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                     aname    => 'AUCTION_ID'); /* using auction_id instead of
                                                                              auction_number as a standard
                                                                              across item types */


        x_note :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
             aname    => 'NOTE_TO_BUYER');

   SELECT close_bidding_date,auction_status
     INTO x_closedate, x_auction_status
     FROM pon_auction_headers_all
     WHERE auction_header_id=x_doc_number;

   x_now := SYSDATE;

   IF (x_closedate>x_now AND x_auction_status<>'CANCELLED' AND x_auction_status<>'DELETED') then

        UPDATE pon_bidding_parties
  SET supp_acknowledgement='Y',
    ack_note_to_auctioneer = x_note,
          ack_partner_contact_id = trading_partner_contact_id,
          acknowledgement_time = x_now
        WHERE (trading_partner_id= x_trading_partner_id
         or  wf_user_name= x_wf_user_name )
         and nvl(vendor_site_id, -1) = nvl(x_vendor_site_id , -1)
         and auction_header_id=x_doc_number;

       x_doc_number :=x_doc_number;

   END IF;

   END update_ack_to_yes;




PROCEDURE  UPDATE_ACK_TO_NO (        itemtype    in varchar2,
             itemkey    in varchar2,
             actid           in number,
             uncmode    in varchar2,
             resultout          out NOCOPY varchar2)

  IS

     x_trading_partner_id     NUMBER;
     x_wf_user_name    VARCHAR2(100);
     x_doc_number NUMBER;
     x_note     VARCHAR2(4000);
     x_closedate DATE;
     x_now DATE;
     x_auction_status VARCHAR2(100);
     x_vendor_site_id NUMBER;


   BEGIN


    x_wf_user_name := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
             aname    => 'BIDDER_TP_CONTACT_NAME');

    x_trading_partner_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                               aname    => 'TRADING_PARTNER_ID');

    x_vendor_site_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                               aname    => 'VENDOR_SITE_ID');

    x_doc_number := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                     aname    => 'AUCTION_ID'); /* using auction_id instead of
                                                                              auction_number as a standard
                                                                              across item types */

        x_note :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
             aname    => 'NOTE_TO_BUYER');

  SELECT close_bidding_date,auction_status
     INTO x_closedate, x_auction_status
     FROM pon_auction_headers_all
     WHERE auction_header_id=x_doc_number;

   x_now := SYSDATE;

   IF (x_closedate>x_now AND x_auction_status<>'CANCELLED' AND x_auction_status<>'DELETED') then


        UPDATE pon_bidding_parties
  SET supp_acknowledgement='N',
    ack_note_to_auctioneer = x_note,
          ack_partner_contact_id = trading_partner_contact_id,
          acknowledgement_time = x_now
       WHERE (trading_partner_id= x_trading_partner_id
         or  wf_user_name= x_wf_user_name )
         and nvl(vendor_site_id,-1) = nvl(x_vendor_site_id,-1)
         and auction_header_id=x_doc_number;

       x_doc_number :=x_doc_number;

   END IF;

   END update_ack_to_no;


   PROCEDURE launch_init_notif_proc(itemtype IN VARCHAR2,
            itemkey  IN VARCHAR2,
            actid    IN NUMBER,
            uncmode  IN VARCHAR2,
            resultout OUT NOCOPY VARCHAR2)
     IS

--  x_process VARCHAR2;
  x_progress VARCHAR2(3);
--  x_notification_id NUMBER;

   BEGIN

 --     x_process :='NOT_BIDDERS_AUC_START';
      x_progress :='010';


      launch_notif_process(p_itemtype => itemtype,
         p_itemkey => itemkey,
         p_actid => actid,
         p_process => 'NOT_BIDDERS_AUC_START');
      x_progress :='020';

   END launch_init_notif_proc;

     PROCEDURE launch_init_notif_p_add(itemtype IN VARCHAR2,
            itemkey  IN VARCHAR2,
            actid    IN NUMBER,
            uncmode  IN VARCHAR2,
            resultout OUT NOCOPY VARCHAR2)
     IS

--  x_process VARCHAR2;
  x_progress VARCHAR2(3);
--  x_notification_id NUMBER;

   BEGIN

 --     x_process :='NOT_BIDDERS_AUC_START';
      x_progress :='010';


      launch_notif_process(p_itemtype => itemtype,
         p_itemkey => itemkey,
         p_actid => actid,
         p_process => 'NOT_BIDDER_AUC_START_ADD');
      x_progress :='020';

     END launch_init_notif_p_add;

        PROCEDURE launch_new_round_notif(itemtype IN VARCHAR2,
            itemkey  IN VARCHAR2,
            actid    IN NUMBER,
            uncmode  IN VARCHAR2,
            resultout OUT NOCOPY VARCHAR2)
     IS

--  x_process VARCHAR2;
  x_progress VARCHAR2(3);
--  x_notification_id NUMBER;

   BEGIN

 --     x_process :='NOT_BIDDERS_AUC_START';
      x_progress :='010';


      launch_notif_process(p_itemtype => itemtype,
         p_itemkey => itemkey,
         p_actid => actid,
         p_process => 'NOT_NEW_ROUND_START');
      x_progress :='020';

   END launch_new_round_notif;

      PROCEDURE launch_new_round_notif_add(itemtype IN VARCHAR2,
            itemkey  IN VARCHAR2,
            actid    IN NUMBER,
            uncmode  IN VARCHAR2,
            resultout OUT NOCOPY VARCHAR2)
     IS

--  x_process VARCHAR2;
  x_progress VARCHAR2(3);
--  x_notification_id NUMBER;

   BEGIN

 --     x_process :='NOT_BIDDERS_AUC_START';
      x_progress :='010';


      launch_notif_process(p_itemtype => itemtype,
         p_itemkey => itemkey,
         p_actid => actid,
         p_process => 'NOT_NEW_ROUND_START_ADD');
      x_progress :='020';

   END launch_new_round_notif_add;

    PROCEDURE launch_added_notif_proc(itemtype IN VARCHAR2,
            itemkey  IN VARCHAR2,
            actid    IN NUMBER,
            uncmode  IN VARCHAR2,
            resultout OUT NOCOPY VARCHAR2)
     IS

--  x_process VARCHAR2;
  x_progress VARCHAR2(3);
--  x_notification_id NUMBER;

   BEGIN

 --     x_process :='NOT_BIDDERS_AUC_START';
      x_progress :='010';


      launch_notif_process(p_itemtype => itemtype,
         p_itemkey => itemkey,
         p_actid => actid,
         p_process => 'NOT_ADD_BIDDERS_AUC_START');
      x_progress :='020';

   END launch_added_notif_proc;


PROCEDURE LAUNCH_NOTIF_PROCESS(p_itemtype    in varchar2,
             p_itemkey    in varchar2,
             p_actid                  IN NUMBER,
             p_process   IN VARCHAR2)


  IS

     x_itemtype    VARCHAR2(8) := 'PONPBLSH';
     x_sequence    NUMBER;
     x_itemkey    VARCHAR2(50);
     x_auction_header_id          NUMBER;
     x_tp_id                      NUMBER;
     x_supplier_exampt_count  NUMBER;    --choli
     x_exempt_flag VARCHAR2(1);          --choli
BEGIN

      SELECT pon_auction_wf_publish_s.nextval
      INTO   x_sequence
      FROM   dual;
      x_itemkey := (p_itemkey||'-'||to_char(x_sequence));

      wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
            process  => p_process);

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'BIDDER_TP_CONTACT_NAME',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'BIDDER_TP_CONTACT_NAME'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'ORIGIN_USER_NAME',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'ORIGIN_USER_NAME'));

       wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_ID',
                                 avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'AUCTION_ID')); /* using auction_id instead of
                                                                    auction_number as a standard
                                                                    across item types */

       wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'INVITATION_ID',
                                 avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'INVITATION_ID'));

       wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                  aname      => 'EVENT_TITLE',
                                  avalue     => replaceHtmlChars(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                                             itemkey  => p_itemkey,
                                                                             aname    => 'EVENT_TITLE')));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_DESCRIPTION',
                                 avalue     => replaceHtmlChars(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'AUCTION_DESCRIPTION')));

      wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_START_DATE',
                                 avalue     => wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'AUCTION_START_DATE'));

      wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_END_DATE',
                                 avalue     => wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'AUCTION_END_DATE'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NOTE_TO_BIDDERS',
                                 avalue     => replaceHtmlChars(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'NOTE_TO_BIDDERS')));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'TP_DISPLAY_NAME',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'TP_DISPLAY_NAME'));


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_DOC_TYPE_OPEN',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_DOC_TYPE_OPEN'));

       wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_DOC_TYPE_CLOSE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_DOC_TYPE_CLOSE'));

        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_PUB_OPEN_RG_S',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_PUB_OPEN_RG_S'));

   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_PUB_OPEN_RG_M1',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_PUB_OPEN_RG_M1'));

   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PLACE_BID',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  =>p_itemkey,
                    aname    => 'PLACE_BID'));

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_TOACKNOWLEDGE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_TOACKNOWLEDGE'));

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PREPARER_TP_NAME',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PREPARER_TP_NAME'));


      wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'NUMBER_OF_ITEMS',
                                 avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                      aname    => 'NUMBER_OF_ITEMS'));
      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_TITLE',
                                 avalue     => replaceHtmlChars(wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'AUCTION_TITLE')));

--      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
--                                 itemkey    => x_itemkey,
--                                 aname      => 'OEX_OPERATION',
--                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
--                    itemkey  => p_itemkey,
--                    aname    => 'OEX_OPERATION'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'OEX_OPERATION_URL',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'OEX_OPERATION_URL'));
        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'TP_TIME_ZONE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'TP_TIME_ZONE'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_TYPE_NAME',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'AUCTION_TYPE_NAME'));

/*
      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'OEX_OPERATION_START',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'OEX_OPERATION_START'));


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'TEXT_HEADER',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'TEXT_HEADER'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'TEXT_FOOTER',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'TEXT_FOOTER'));


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'HTML_HEADER',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'HTML_HEADER'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'HTML_FOOTER',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'HTML_FOOTER'));
*/
      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'TP_LANGUAGE_CODE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'TP_LANGUAGE_CODE'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_DOC_TITLE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_DOC_TITLE'));


      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_DOC_NUM',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_DOC_NUM'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_DOC_EVENT',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_DOC_EVENT'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_PUB_NEWRND_M1',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_PUB_NEWRND_M1'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_PUB_NEWRND_M2',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_PUB_NEWRND_M2'));

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_PUB_NEWRND_RG_S',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_PUB_NEWRND_RG_S'));

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_AUCTIONEER',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_AUCTIONEER'));

 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PREVIEW_MESSAGE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PREVIEW_MESSAGE'));

   wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_NOTIFICATION_DATE',
                                 avalue     => wf_engine.GetItemAttrDate (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'AUCTION_NOTIFICATION_DATE'));

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'TP_TIME_ZONE1',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'TP_TIME_ZONE1'));

     wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'ARTICLE_DOC_TYPE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'ARTICLE_DOC_TYPE'));
 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'APPSTR',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'APPSTR'));


 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'APP',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'APP'));

 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'DOC_NUMBER',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'DOC_NUMBER'));

       wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'TRADING_PARTNER_ID',
                                 avalue     => wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'TRADING_PARTNER_ID'));

 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'ADDITIONAL_CONTACT_USERNAME',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'ADDITIONAL_CONTACT_USERNAME'));

 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_DOC_IN_PR0G',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_DOC_IN_PR0G'));

 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'PON_AUC_WF_LOGON_BEFORE',
                                 avalue     => wf_engine.GetItemAttrText (itemtype => p_itemtype,
                    itemkey  => p_itemkey,
                    aname    => 'PON_AUC_WF_LOGON_BEFORE'));

    -- Bug 4295915: Set the  workflow owner
 wf_engine.SetItemOwner(itemtype => x_itemtype,
                        itemkey  => x_itemkey,
                        owner    => fnd_global.user_name);

-- choli update for emd
 -- For members, store item key in pom_bidding_parties
 x_auction_header_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                    itemkey  => p_itemkey,
                                                    aname    => 'AUCTION_ID'); /* using auction_id instead of
                                                                                 auction_number as a standard
                                                                                 across item types */

 x_tp_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                         aname    => 'TRADING_PARTNER_ID');

      --choli for SUPPLIER_EXEMPTED_INFO
 BEGIN
   select exempt_flag
     into x_exempt_flag
     from pon_bidding_parties b
    where auction_header_id = x_auction_header_id
      and trading_partner_id = x_tp_id
      and rownum = 1;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_exempt_flag := 'N';
   WHEN OTHERS THEN
     x_exempt_flag := 'N';
 END;
 IF(x_exempt_flag = 'Y') THEN
 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'SUPPLIER_EXEMPTED_INFO',
                                 avalue     => 'You are exampted from paying the EMD/Bank Guarantee for this Negotiation');
ELSE
 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'SUPPLIER_EXEMPTED_INFO',
                                 avalue     => ' ');
END IF;

 wf_engine.StartProcess(itemtype => x_itemtype,
                        itemkey  => x_itemkey );



 UPDATE pon_bidding_parties set
 wf_item_key = x_itemkey
 WHERE trading_partner_id = x_tp_id
 AND auction_header_id = x_auction_header_id;


END LAUNCH_NOTIF_PROCESS;

PROCEDURE NOTIFY_BIDDER_LIST_REMINDER(itemtype    in varchar2,
                              itemkey    in varchar2,
                              actid           in number,
                              uncmode    in varchar2,
                              resultout          out NOCOPY varchar2)
IS

    x_doc_number                   NUMBER;
    x_neg_summary_url_supplier     VARCHAR2(2000);
    x_isp_supplier_register_url    VARCHAR2(2000);
    x_ack_part_url_supplier        VARCHAR2(2000);
    x_auction_tp_contact_name      PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
    x_preview_date                DATE;
    x_preview_date_notspec         VARCHAR2(240);
    x_timezone1_disp               VARCHAR2(240);
-- Bug 3824928: Removed obsolete columns
CURSOR bidders IS
   select
     fu.user_name my_user_name,
     pbd.trading_partner_id,
     pbd.trading_partner_name my_user_display_name,
     decode(pbd.vendor_site_code, '-1', null, pbd.vendor_site_code) vendor_site_code,
     pbd.wf_user_name additional_name,
     pbd.wf_item_key,
     pbd.additional_contact_email,
     pbd.registration_id,
     pbd.trading_partner_contact_id, -- Bug 3824928 added
     pbd.vendor_site_id
   from pon_bidding_parties pbd,
        fnd_user fu
   WHERE pbd.trading_partner_contact_id=fu.person_party_id (+) AND -- Bug 3824928: added outer join
          nvl(fu.end_date, sysdate+1) > sysdate  AND                                -- Added for TCA project
          pbd.auction_header_id=x_doc_number AND
          nvl(pbd.supp_acknowledgement,'havenot')= 'havenot'
          and pbd.trading_partner_id is not null;

   -- Bug 3824928: Removed union below

    x_language_code varchar2(30);
  x_auctioneer_user_name VARCHAR2(60);
    x_profile_user VARCHAR2(60);
  x_member_flag VARCHAR2(3);
    x_message_name varchar2(80);
  x_process_name VARCHAR2(80);
  x_text_header varchar2(540) := '';
  x_text_footer varchar2(540) := '';
  x_doc_internal_name varchar2(60) := '';
  x_msg_suffix varchar2(3) := '';
  x_nid number;
  x_newendtime          DATE;
  x_itemtype    VARCHAR2(8) := 'PONPBLSH';
    x_itemkey    VARCHAR2(50);
  x_sequence    NUMBER;
  x_auction_tp_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE := '';
    x_auction_contact_dp_name varchar2(240) := '';
  x_tp_display_name varchar2(240) :='';
  x_auction_title varchar2(240) := '';
  x_auction_start_date date;
  x_auction_end_date date;
  x_operation_url   VARCHAR2(300);
  x_invitation_id number;
  x_oex_operation   VARCHAR2(640);
  x_wf_item_key VARCHAR2(240);
  x_appstr VARCHAR2(20);
  x_app VARCHAR2(20);
  x_oex_timezone VARCHAR2(80);
  x_person_party_id NUMBER(15);
  x_timezone    VARCHAR2(80);
  x_newstarttime          DATE;
  x_doc_number_dsp   VARCHAR2(30);
  x_bids_by_company NUMBER;
  x_commits_by_company NUMBER;
  x_total_participations NUMBER;
  x_timezone_disp  VARCHAR2(240);
    x_timezone1    VARCHAR2(80); -- preview timezone
    x_newpreviewtime  DATE;
    x_timezone1_dsp         VARCHAR2(240);

    -- Added the following declaration for Affiliate ID related changes
    -- Auctioneer's trading partner id
    x_tp_id NUMBER;

    x_registration_key VARCHAR2(100);

    l_origin_user_name   fnd_user.user_name%TYPE;

	x_l_neg_summary_url_supplier     VARCHAR2(2000);

  --SLM UI Enhancement
  l_slm_neg_doc  VARCHAR2(15);
  l_is_slm  VARCHAR2(1);

BEGIN

            x_doc_number := wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                                   itemkey    => itemkey,
                                                   aname      => 'AUCTION_ID');

    -- Bug 8992789
    IF (IS_INTERNAL_ONLY(x_doc_number)) THEN
      RETURN;
    END IF;

          x_doc_internal_name := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                                              itemkey    => itemkey,
                                                aname      => 'DOC_INTERNAL_NAME');

             BEGIN
                 x_preview_date := wf_engine.GetItemAttrDate (itemtype   => itemtype,
                                                              itemkey    => itemkey,
                                                     aname      => 'PREVIEW_DATE');

                 x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                                      itemkey  => itemkey,
                                                                      aname    => 'PREVIEW_DATE_NOTSPECIFIED');
             EXCEPTION
           WHEN NO_DATA_FOUND
           THEN
           -- Assigning null to the item attributes
               x_preview_date := null;
                 x_preview_date_notspec := null;
             WHEN OTHERS
           THEN
               RAISE;
           END;

        --x_msg_suffix := GET_MESSAGE_SUFFIX (x_doc_internal_name);
        --SLM UI Enhancement :
        l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(x_doc_number);
        x_msg_suffix := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE_SUFFIX (l_is_slm, x_doc_internal_name);
        l_slm_neg_doc := PON_SLM_UTIL_PKG.GET_SLM_NEG_MESSAGE(l_is_slm);

      x_doc_number_dsp     := wf_engine.GetItemAttrText   (itemtype => itemtype,
                                                             itemkey  => itemkey,
                                                            aname    => 'DOC_NUMBER');
        x_oex_timezone := Get_Oex_Time_Zone;

--        x_auction_tp_contact_name  := wf_engine.GetItemAttrText (itemtype   => itemtype,
--                                                                 itemkey    => itemkey,
--                                                                 aname      => 'PREPARER_TP_CONTACT_NAME');




      x_auction_tp_name := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                                        itemkey    => itemkey,
                                          aname      => 'PREPARER_TP_NAME');

      x_auction_contact_dp_name := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                                        itemkey    => itemkey,
                                          aname      => 'PREPARER_CONTACT_DP_NAME');

       x_auction_title := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                                    itemkey    => itemkey,
                                                    aname      => 'AUCTION_TITLE');

       l_origin_user_name := wf_engine.GetItemAttrText (itemtype   => itemtype,
                                                          itemkey    => itemkey,
                                                          aname      => 'ORIGIN_USER_NAME');

      x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => itemtype,
                                                    itemkey    => itemkey,
                                                    aname      => 'AUCTION_START_DATE');

      x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => itemtype,
                                                    itemkey    => itemkey,
                                                    aname      => 'AUCTION_END_DATE');

     begin
    SELECT wf_item_key
    INTO x_wf_item_key
    FROM pon_auction_headers_all
    WHERE auction_header_id=x_doc_number;

       select trading_partner_id, trading_partner_contact_name
          into x_tp_id, x_auction_tp_contact_name
          from pon_auction_headers_all
          where auction_header_id = x_doc_number;

     END;


     FOR bidder IN bidders LOOP --{

  SELECT COUNT(bid_number)
    INTO x_bids_by_company
    FROM pon_bid_headers
    WHERE auction_header_id=x_doc_number
    AND trading_partner_id=bidder.trading_partner_id;

  x_total_participations :=x_bids_by_company;


  IF(x_total_participations=0) then

      x_member_flag :='Y';
      x_process_name :='REMIND_MEMBERS_PROCESS';
     -- Bug 3824928: Trading partner contact id can be null
       IF bidder.trading_partner_contact_id is not null then -- {
         PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(bidder.my_user_name,x_language_code);


          BEGIN
            SELECT person_party_id
        INTO x_person_party_id
        FROM fnd_user
        WHERE user_name = bidder.my_user_name;
          EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            null;  -- This can never throw too many row exception
          END;

      -- Get the user's time zone
      --
    x_timezone := Get_Time_Zone(x_person_party_id);

      --
      -- Make sure that it is a valid time zone
      --

      IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 0) THEN
       x_timezone := x_oex_timezone;
      END IF;

      -- Create new timezone
      IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 1) THEN
        x_newstarttime   := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_auction_start_date,x_oex_timezone,x_timezone);
        x_newendtime     := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_auction_end_date,x_oex_timezone,x_timezone);
        x_newpreviewtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_preview_date,x_oex_timezone,x_timezone);
      ELSE
        x_newstarttime   := x_auction_start_date;
      x_newendtime     := x_auction_end_date;
        x_newpreviewtime := x_preview_date;
      END IF;
    END IF; -- IF bidder.trading_partner_contact_id is not null

    -- Bug 3824928: Checking if additional_contact_email is not null
    if bidder.additional_contact_email is not null then -- {

           if bidder.trading_partner_contact_id is null then -- {
                         -- use auctioneer's language
                         --x_auctioneer_user_name := wf_engine.GetItemAttrText (itemtype => 'PONAUCT',
                         --                                                     itemkey  => x_wf_item_key,
                         --                                                     aname    => 'PREPARER_TP_CONTACT_NAME');
                         x_auctioneer_user_name := x_auction_tp_contact_name;

                         PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_auctioneer_user_name,x_language_code);

                         -- get auctioneer's timezone
                         x_timezone := Get_Time_Zone(x_auctioneer_user_name);

                         --
                         -- Make sure that it is a valid time zone
                         --

                         IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 0) THEN
                            x_timezone := x_oex_timezone;
                         END IF;

                         -- Create new timezone
                         x_newstarttime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_auction_start_date,x_oex_timezone,x_timezone);
                         x_newendtime   := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(x_auction_end_date,x_oex_timezone,x_timezone);


             end if; -- }

      end if; -- }

       -- For bug#8353407
	   --IF (x_language_code is not null) THEN
           --IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
               -- FND_LOG.string(log_level => FND_LOG.level_statement,
                 -- module => g_module_prefix || 'NOTIFY_BIDDER_LIST_REMINDER',
                  --message  => '8. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
           --END IF; --}

        --SET_SESSION_LANGUAGE(null, x_language_code);
       --END IF;
	   UNSET_SESSION_LANGUAGE;

    SELECT pon_auction_wf_publish_s.nextval
      INTO   x_sequence
      FROM   dual;

      x_tp_display_name := bidder.my_user_display_name;

      x_itemkey := (itemkey||'-'||to_char(x_sequence));

      wf_engine.CreateProcess(itemtype => x_itemtype,
                              itemkey  => x_itemkey,
                        process  => x_process_name);

      -- For bug#8353407
	  IF (x_language_code is not null) THEN

 	            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
 	                 FND_LOG.string(log_level => FND_LOG.level_statement,
 	                   module => g_module_prefix || 'NOTIFY_BIDDER_LIST_REMINDER',
 	                   message  => '8. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
 	            END IF; --}

 	               SET_SESSION_LANGUAGE(null, x_language_code);
 	           END IF;

      --SLM UI Enhancement
      PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => x_itemtype,
                                                  p_itemkey  => x_itemkey,
                                                  p_value    => l_slm_neg_doc);

      wf_engine.SetItemAttrText (itemtype => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PREPARER_TP_CONTACT_NAME',
                               avalue     => x_auction_tp_contact_name);

      wf_engine.SetItemAttrText (itemtype => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ORIGIN_USER_NAME',
                               avalue     => l_origin_user_name);

      wf_engine.SetItemAttrText (itemtype => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_NAME',
                               avalue     => bidder.my_user_display_name);

     --Bug 16666395 modified from vendor_site_code to address
     wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'BIDDER_TP_ADDRESS_NAME',
                               avalue     => GET_VENDOR_SITE_ADDRESS(bidder.vendor_site_id));


     wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'REGISTERED',
        avalue  => x_member_flag);

     wf_engine.SetItemAttrText   (itemtype => x_itemtype,
          itemkey  => x_itemkey,
          aname    => 'DOC_NUMBER',
          avalue   => x_doc_number_dsp);


      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'BIDDER_TP_CONTACT_NAME',
         avalue  => bidder.my_user_name);


     wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                                  itemkey  => x_itemkey,
                           aname=> 'PREPARER_TP_NAME',
         avalue  => x_auction_tp_name);


              wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'TRADING_PARTNER_ID',
           avalue  => bidder.trading_partner_id);


            wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'PREPARER_CONTACT_DP_NAME',
         avalue  => x_auction_contact_dp_name);


              wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'INVITE_REMINDER_SUB',
             avalue  => getMessage('PON_AUC_WF_REQA', x_msg_suffix,
                                          'DOC_NUMBER', x_doc_number_dsp,
                                          'AUCTION_TITLE', replaceHtmlChars(x_auction_title)));
-- Bug 6965954: START of Code Fix
-- Set the values of AUCTION_START_DATE and AUCTION_END_DATE
-- as the end_date is used to determine the timeout for the notifications
-- sent to the supplier

             wf_engine.SetItemAttrDate     (itemtype   => x_itemtype,
                                     itemkey    => x_itemkey,
                                     aname      => 'AUCTION_START_DATE',
                                     avalue     => x_auction_start_date);

             wf_engine.SetItemAttrDate     (itemtype   => x_itemtype,
                                     itemkey    => x_itemkey,
                                     aname      => 'AUCTION_END_DATE',
                                     avalue     => x_auction_end_date);

-- Bug 6965954: End of Code Fix

           wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'TP_DISPLAY_NAME',
         avalue  => x_tp_display_name);


           wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'AUCTION_TITLE',
         avalue  => replaceHtmlChars(x_auction_title));


           wf_engine.SetItemAttrNumber (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'AUCTION_ID',
             avalue  => x_doc_number); /* using auction_id instead of
                                               auction_number as a standard
                                               across item types */


              wf_engine.SetItemAttrDate(itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'AUCTION_END_DATE_TZ',
         avalue  => x_newendtime);

           wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'AUCTION_START_DATE_TZ',
         avalue  => x_newstarttime);

       -- call to notification utility package to get the redirect page url that
       -- is responsible for getting the Neg. Summary url and forward to it.
       x_neg_summary_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PON_NEG_SUMMARY'
                                 ,p_notif_performer  => 'SUPPLIER');

     --Bug 14572394
      x_l_neg_summary_url_supplier:=   pos_url_pkg.get_external_login_url||'?requestUrl='||wfa_html.conv_special_url_chars(x_neg_summary_url_supplier);

      x_l_neg_summary_url_supplier:=  regexp_replace(x_l_neg_summary_url_supplier ,'notificationId%3D%26%23NID', 'notificationId%3D&#NID');

      IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS  NULL ) THEN
            wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_TB',
                                         avalue      => null);
            wf_engine.SetItemAttrText (itemtype     => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_HB',
                                         avalue      => null);
      ELSE
             wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                         itemkey      => x_itemkey,
                                         aname      =>
                                   'LOGIN_VIEW_DETAILS_URL',
                                     avalue => x_l_neg_summary_url_supplier);
      END IF;

      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                        itemkey    => x_itemkey,
                        aname      => 'NEG_SUMMARY_URL',
                        avalue      => x_neg_summary_url_supplier);

     -- call to notification utility package to get the redirect page url that
       -- is responsible for getting the Acknowledge participation url and forward to it.
       x_ack_part_url_supplier := pon_wf_utl_pkg.get_dest_page_url (
                              p_dest_func => 'PONRESAPN_ACKPARTICIPATN'
                                 ,p_notif_performer  => 'SUPPLIER');

       begin
        wf_engine.SetItemAttrText   (itemtype   => x_itemtype,
                                         itemkey    => x_itemkey,
                                         aname      => '#WFM_HTMLAGENT',
                                         avalue     => pon_wf_utl_pkg.get_base_external_supplier_url);
        exception
          when others then
            null;
        end;


      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                        itemkey    => x_itemkey,
                        aname      => 'ACK_PARTICIPATION_URL',
                        avalue      => x_ack_part_url_supplier);

   x_timezone_disp := Get_TimeZone_Description(x_timezone, x_language_code);
     IF (x_preview_date IS NULL) THEN
         x_timezone1_disp := null;
     ELSE
         x_timezone1_disp := x_timezone_disp;
     END IF;

           wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'TP_TIME_ZONE',
         avalue  => x_timezone_disp);

  IF (x_preview_date is not null) THEN
        wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'PREVIEW_DATE_TZ',
             avalue   => x_newpreviewtime);

      wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                 itemkey   => x_itemkey,
                 aname     => 'TP_TIME_ZONE1',
                 avalue    => x_timezone1_disp);

        wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => null);

  ELSE
          wf_engine.SetItemAttrDate (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'PREVIEW_DATE_TZ',
             avalue     => null);

          wf_engine.SetItemAttrText (itemtype  => x_itemtype,
             itemkey  => x_itemkey,
             aname  => 'TP_TIME_ZONE1',
             avalue     => x_timezone1_disp);

         wf_engine.SetItemAttrText (itemtype  => x_itemtype,
                           itemkey  => x_itemkey,
                           aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                           avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));


    END IF;


           if (bidder.additional_contact_email is not null) then

                 wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                           itemkey    => x_itemkey,
                                   aname      => 'ADDITIONAL_CONTACT_USERNAME',
                                   avalue     => bidder.additional_name);

              begin
                select registration_key
                  into x_registration_key
                  from fnd_registrations
                 where registration_id = bidder.registration_id;
              exception
                  WHEN NO_DATA_FOUND THEN
                       x_registration_key := '';
              end;


             -- call to notification utility package to get the iSupplier registration page url
             x_isp_supplier_register_url := pon_wf_utl_pkg.get_isp_supplier_register_url(p_registration_key => x_registration_key
                                                                                        ,p_language_code => x_language_code);

             wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                        itemkey    => x_itemkey,
                                        aname      => 'ISP_SUPPLIER_REG_URL',
                                        avalue     => x_isp_supplier_register_url);

           end if;


    -- Bug 4295915: Set the  workflow owner
      wf_engine.SetItemOwner(itemtype => x_itemtype,
                             itemkey  => x_itemkey,
                             owner    => fnd_global.user_name);

      wf_engine.StartProcess(itemtype => x_itemtype,
                             itemkey  => x_itemkey );

      -- Bug 3824928: replacing if x_member_flag ='Y' with IF trading
      -- partner contact id is not null

      IF bidder.trading_partner_contact_id IS NOT NULL THEN -- {

        -- For members, store item key in pon_bidding_parties
        -- End the previous waiting process
        Wf_Engine.AbortProcess(x_itemtype, bidder.wf_item_key, '', null);

        UPDATE pon_bidding_parties set
            wf_item_key = x_itemkey
        WHERE trading_partner_id = bidder.trading_partner_id
        AND auction_header_id = x_doc_number
        AND vendor_site_id = bidder.vendor_site_id; -- Supplier/supplier site combination can be different in 11.5.10

       END IF; -- } IF bidder.trading_partner_contact_id IS NOT NULL

       END IF; -- } participation already check

     END LOOP; --}

	 -- For bug#8353407
	 UNSET_SESSION_LANGUAGE;


END notify_bidder_list_reminder;

procedure retrieve_user_info(param1 varchar2) is
type refCurType is Ref Cursor;
param2 integer;
param3  varchar2(2000);
param4  varchar2(2000);
param5  varchar2(2000);
param6  varchar2(2000);
param7  varchar2(2000);
param8  varchar2(2000);
param9  varchar2(2000);
param11  varchar2(2000);
param12  varchar2(2000);
param14  varchar2(2000);
param15  varchar2(2000);
param16  varchar2(2000);
param18  varchar2(2000);
param19  varchar2(2000);
param20  varchar2(2000);
param21  refCurType;
param22  integer;
param23  integer;
param24  integer;
param25  integer;
param26  varchar2(2000);
param27  varchar2(2000);
param28  varchar2(2000);
param29  integer;
param30  varchar2(2000);
param31  varchar2(2000);
param32  varchar2(2000);
param33  refCurType;
param34  varchar2(2000);
param35  varchar2(2000);
param36  varchar2(2000);
param37  varchar2(2000);

begin
-- this is tricky there are just 20 vars as input in the new fn.

g_userName := param1;
end retrieve_user_info;

/*======================================================================
 PROCEDURE :  DELETE_NEGOTIATION_LINE_REF    PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_negotiation_line_num  in      negotiation line number
  x_org_id                in      organization id
x  x_error_code            out     internal code for error

 COMMENT   : delete negotiation line references
======================================================================*/
PROCEDURE DELETE_NEGOTIATION_LINE_REF (
    x_negotiation_id        in   number,
    x_negotiation_line_num  in   number,
    x_org_id                in   number,
    x_error_code            out  NOCOPY varchar2) is

BEGIN

      -- first, remove records in pon_backing_requisitions
      delete
        from  pon_backing_requisitions
       where  auction_header_id = x_negotiation_id
         and  line_number = x_negotiation_line_num;

      -- remove negotiation references in po_requisition_lines
      -- and return the requisitions to the req pool
      PO_NEGOTIATIONS_SV1.DELETE_NEGOTIATION_REF(
  X_NEGOTIATION_ID  =>  x_negotiation_id,
  X_NEGOTIATION_LINE_NUM  =>  x_negotiation_line_num,
  X_ERROR_CODE    =>  x_error_code);

END DELETE_NEGOTIATION_LINE_REF;

/*======================================================================
 PROCEDURE :  DELETE_NEGOTIATION_REF    PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_error_code            out     internal code for error

 COMMENT   : delete negotiation references
======================================================================*/
PROCEDURE DELETE_NEGOTIATION_REF (
   x_negotiation_id in  number,
   x_error_code     out NOCOPY varchar2) is

BEGIN

      PO_NEGOTIATIONS_SV1.DELETE_NEGOTIATION_REF(
  X_NEGOTIATION_ID  =>  x_negotiation_id,
  X_NEGOTIATION_LINE_NUM  =>  null,
  X_ERROR_CODE    =>  x_error_code);

END DELETE_NEGOTIATION_REF;

/*======================================================================
 PROCEDURE :  CANCEL_NEGOTIATION_REF   PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_error_code            out     internal code for error

 COMMENT   : cancel negotiation references
======================================================================*/
PROCEDURE CANCEL_NEGOTIATION_REF (
   x_negotiation_id in  number,
   x_error_code     out NOCOPY varchar2) is

BEGIN

      -- return backing requisitions to the req pool
      PO_NEGOTIATIONS_SV1.UPDATE_REQ_POOL(
  X_NEGOTIATION_ID  =>  x_negotiation_id,
  X_NEGOTIATION_LINE_NUM  =>  null,
  X_FLAG_VALUE    =>  'Y',
  X_ERROR_CODE    =>  x_error_code);

END CANCEL_NEGOTIATION_REF;

/*======================================================================
 PROCEDURE :  UPDATE_NEGOTIATION_REF   PUBLIC
 PARAMETERS:
  x_old_negotiation_id   in   old auction header id
  x_old_negotiation_num  in   old auction display number
  x_new_negotiation_id   in   new auction header id
  x_new_negotiation_num  in   new auction display number
  x_error_code           out  internal code for error
  x_error_message        out  error message

 COMMENT   : update negotiation references
======================================================================*/
PROCEDURE UPDATE_NEGOTIATION_REF(
    x_old_negotiation_id   in   number,
    x_old_negotiation_num  in   varchar2,
    x_new_negotiation_id   in   number,
    x_new_negotiation_num  in   varchar2,
    x_error_code           out  NOCOPY varchar2,
    x_error_message        out  NOCOPY varchar2  ) is

l_line_number number;

CURSOR deletedItems IS
     SELECT LINE_NUMBER
      FROM  PON_AUCTION_ITEM_PRICES_ALL
     WHERE  auction_header_id = x_old_negotiation_id and
            line_number not in ( select line_number
                                   from PON_AUCTION_ITEM_PRICES_ALL
                                  where auction_header_id = x_new_negotiation_id);

BEGIN

      PO_NEGOTIATIONS_SV1.UPDATE_NEGOTIATION_REF(
  X_OLD_NEGOTIATION_ID  =>  x_old_negotiation_id,
  X_NEW_NEGOTIATION_ID  =>  x_new_negotiation_id,
  X_NEW_NEGOTIATION_NUM  =>  x_new_negotiation_num,
  X_ERROR_CODE    =>  x_error_code);

      -- the above routine does't use FND constants,
      -- while UPDATE_NEGOTIATION_LINE_REF does, so convert it.
      IF (x_error_code = 'SUCCESS') THEN
   x_error_code := FND_API.G_RET_STS_SUCCESS;
      END IF;

      -- changes for FPI. For items that are carried over from previous round
      -- update the corresponding backing requisition references (no change
      -- from FPH).
      -- For items that are deleted between rounds, do nothing (ie, keep
      -- the references, references are cleared in FPH).
      -- We can either update only the carried over items or update all items
      -- and change deleted items back.
      -- Use the second approach here based on the assumption that a small
      -- number of items are deleted between rounds.

      -- some items may be deleted between rounds. Remove corresponding references
      -- and return requisition back to pool (FPH)
      OPEN deletedItems;
      LOOP
        FETCH deletedItems INTO
          l_line_number;
        EXIT WHEN deletedItems%NOTFOUND OR (x_error_code <> FND_API.G_RET_STS_SUCCESS);

      --  PO_NEGOTIATIONS_SV1.DELETE_NEGOTIATION_REF(x_new_negotiation_id, l_line_number, x_error_code);

        PO_NEGOTIATIONS_SV1.UPDATE_NEGOTIATION_LINE_REF(
    P_API_VERSION      =>  1.0,
    P_OLD_NEGOTIATION_ID    =>  x_new_negotiation_id,
    P_OLD_NEGOTIATION_LINE_NUM  =>  l_line_number,
    P_NEW_NEGOTIATION_ID    =>  x_old_negotiation_id,
    P_NEW_NEGOTIATION_LINE_NUM  =>  l_line_number,
    P_NEW_NEGOTIATION_NUM    =>  x_old_negotiation_num,
    X_RETURN_STATUS      =>  x_error_code,
    X_ERROR_MESSAGE      =>  x_error_message);
      END LOOP;

      -- FPI: bug 2811671 still need to return the req back to pool
      IF (x_error_code = FND_API.G_RET_STS_SUCCESS) THEN
        PO_NEGOTIATIONS_SV1.UPDATE_REQ_POOL(
    X_NEGOTIATION_ID    =>  x_old_negotiation_id,
    X_NEGOTIATION_LINE_NUM     =>  null,
    X_FLAG_VALUE      =>  'Y',
    X_ERROR_CODE      =>  x_error_code);
      END IF;

      -- convert fnd constant to our own internal code
      IF (x_error_code = FND_API.G_RET_STS_SUCCESS) THEN
   x_error_code := 'SUCCESS';
      END IF;

END UPDATE_NEGOTIATION_REF;

/*======================================================================
 PROCEDURE :  COPY_BACKING_REQ  PUBLIC
 PARAMETERS:
  x_old_negotiation_id   in   old auction header id
  x_new_negotiation_id   in   new auction header id
  x_error_code           out  internal code for error

 COMMENT   : update negotiation references
======================================================================*/
PROCEDURE COPY_BACKING_REQ(x_old_negotiation_id in  number,
                           x_new_negotiation_id in  number,
                           x_error_code         out NOCOPY varchar2) is

neg_item_count    NUMBER;
l_count           NUMBER;

l_line_number     NUMBER;
l_req_header_id   NUMBER;
l_req_line_id     NUMBER;
l_req_quantity    NUMBER;
l_req_number      pon_backing_requisitions.requisition_number%TYPE;

CURSOR backingReqs IS
     SELECT LINE_NUMBER,
            REQUISITION_HEADER_ID,
            REQUISITION_LINE_ID,
            REQUISITION_QUANTITY,
            REQUISITION_NUMBER
      FROM  PON_BACKING_REQUISITIONS
     WHERE  auction_header_id = x_old_negotiation_id;

BEGIN
   IF(x_new_negotiation_id IS NOT NULL) THEN
     OPEN backingReqs;
     LOOP
       FETCH backingReqs INTO
         l_line_number,
         l_req_header_id,
         l_req_line_id,
         l_req_quantity,
         l_req_number;
       EXIT WHEN backingReqs%NOTFOUND;

       SELECT count(*)
         INTO l_count
         FROM PON_BACKING_REQUISITIONS
        WHERE auction_header_id = x_new_negotiation_id and
              line_number = l_line_number and
              requisition_header_id = l_req_header_id and
              requisition_line_id = l_req_line_id;

       -- check if the item is still in the next round negotiation
       SELECT count(*)
   INTO neg_item_count
         FROM PON_AUCTION_ITEM_PRICES_ALL
        WHERE auction_header_id = x_new_negotiation_id and
              line_number = l_line_number;

       IF ((l_count = 0) AND (neg_item_count) = 1) THEN
          INSERT INTO PON_BACKING_REQUISITIONS(
            AUCTION_HEADER_ID,
            LINE_NUMBER,
            REQUISITION_HEADER_ID,
            REQUISITION_LINE_ID,
            REQUISITION_QUANTITY,
            REQUISITION_NUMBER)
          VALUES (
            x_new_negotiation_id,
            l_line_number,
            l_req_header_id,
            l_req_line_id,
            l_req_quantity,
            l_req_number);
       END IF;
     END LOOP;
  END IF;

  x_error_code := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
    x_error_code := 'FAILURE';

END COPY_BACKING_REQ;


/*======================================================================
 PROCEDURE :  CANCEL_NEGOTIATION_REF_BY_LINE   PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_negotiation_line_id   in      line number
  x_error_code            out     internal code for error

 COMMENT   : cancel negotiation references
======================================================================*/
PROCEDURE CANCEL_NEGOTIATION_REF_BY_LINE (
   x_negotiation_id in  number,
   x_negotiation_line_id number,
   x_error_code     out NOCOPY varchar2) is

BEGIN

      -- return backing requisitions to the req pool
      PO_NEGOTIATIONS_SV1.UPDATE_REQ_POOL(
    X_NEGOTIATION_ID  =>  x_negotiation_id,
    X_NEGOTIATION_LINE_NUM   =>  x_negotiation_line_id,
    X_FLAG_VALUE    =>  'Y',
    X_ERROR_CODE    =>  x_error_code);

END CANCEL_NEGOTIATION_REF_BY_LINE;

--Added X_bid_number for bug 11895155 fix
PROCEDURE Check_Unique_Wrapper(X_Segment1 In VARCHAR2,
                               X_rowid IN VARCHAR2,
                               X_Type_lookup_code IN VARCHAR2,
							   X_bid_number IN NUMBER,
                               X_Unique OUT NOCOPY VARCHAR2) is
BEGIN
  IF (PO_HEADERS_PKG_S2.Check_Unique(X_Segment1, X_rowid, X_Type_lookup_code, X_bid_number)) THEN
    X_Unique := 'T';
    RETURN;
  ELSE
    X_Unique := 'F';
    RETURN;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_Unique := 'F';
    RETURN;
  WHEN OTHERS THEN
    raise;
END Check_Unique_Wrapper;

--Added p_bid_number for bug 11895155 fix
FUNCTION CHECK_UNIQUE_ORDER_NUMBER (p_auction_id IN NUMBER,
                                p_order_number IN VARCHAR2,
								p_bid_number IN NUMBER)
RETURN VARCHAR2 IS
  v_contract_type pon_auction_headers_all.contract_type%TYPE;
  v_org_id pon_auction_headers_all.org_id%TYPE;
  v_old_org_id NUMBER;
  v_old_policy VARCHAR2(1);
  v_is_unique VARCHAR2(1);

BEGIN
   -- Get the current policy
   v_old_policy := mo_global.get_access_mode();
   v_old_org_id := mo_global.get_current_org_id();

   if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
     fnd_log.string(
        fnd_log.level_statement,
        g_module || '.check_unique_order_number',
        'old_policy = ' || v_old_policy || ', old_org_id = ' || v_old_org_id);
   end if;

   -- Get the org id for the negotiation
   SELECT org_id, contract_type
   INTO   v_org_id, v_contract_type
   FROM   pon_auction_headers_all
   WHERE  auction_header_id = p_auction_id;

   -- Set the connection's policy context
   mo_global.set_policy_context('S', v_org_id);

   PON_AUCTION_PKG.Check_Unique_Wrapper(p_order_number, null,
                                        v_contract_type, p_bid_number, v_is_unique);

   -- Set the org context back
   mo_global.set_policy_context(v_old_policy, v_old_org_id);

   return v_is_unique;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     return 'E';
        WHEN OTHERS THEN
           RETURN 'E';

END CHECK_UNIQUE_ORDER_NUMBER;


/* This procedure helps to send the response back to workflow for
   Acknowledgments.
*/

PROCEDURE ACK_NOTIF_RESPONSE(p_wf_item_key VARCHAR2,
                             p_user_name   VARCHAR2,
                             p_supp_ack    VARCHAR2,
                             p_ack_note    VARCHAR2,
                             x_return_status OUT NOCOPY NUMBER)

is

l_supp_ack varchar2(10);
l_notification_id number;
l_activity_status wf_item_activity_statuses.ACTIVITY_STATUS%type;

begin

    BEGIN

   select   notification_id,   ACTIVITY_STATUS
      into   l_notification_id, l_activity_status
    from   wf_item_activity_statuses
    where   item_key  = p_wf_item_key
    and   item_type  = 'PONPBLSH'
    and   notification_id is not null
  and   activity_status = 'NOTIFIED'
    and   rownum    = 1;

   EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Do we want to fail this procedure if we there's no such email sent?
    -- x_return_status   := 1;
    l_notification_id := -9999;
   END;

  IF p_supp_ack ='Y' then
     l_supp_ack :='A-YES';
  ELSIF p_supp_ack='N' THEN
     l_supp_ack :='B-NO';
  END IF;

  if (l_notification_id > 0) then
     Wf_Notification.SetAttrText(l_notification_id, 'RESULT', l_supp_ack);
     Wf_Notification.SetAttrText(l_notification_id, 'NOTE_TO_BUYER', p_ack_note);
     Wf_Notification.Respond(l_notification_id, 'On-Line', p_user_name);
  end if;

  x_return_status := 0;

 EXCEPTION

  WHEN OTHERS THEN
          x_return_status := 1;

end ACK_NOTIF_RESPONSE;

PROCEDURE ACK_NOTIF_RESPONSE(p_wf_item_key VARCHAR2,
                             p_user_name   VARCHAR2,
                             p_supp_ack    VARCHAR2,
                             p_ack_note    VARCHAR2)
IS

  v_temp NUMBER;

BEGIN

    ACK_NOTIF_RESPONSE(p_wf_item_key, p_user_name, p_supp_ack, p_ack_note, v_temp);

END;

/* Implemented as part of bug 2809753.  Move logic for
   NegotiationDoc.getTimeRemaining() to pl/sql procedure to bypass binding
   of timestamps on sql arithmetic operations, which causes problems on
   certain jdbc versions */

PROCEDURE GET_TIME_REMAINING(p_auction_header_id IN NUMBER,
                             p_time_remaining OUT NOCOPY FLOAT) is
begin
  select (sysdate - close_bidding_date) into p_time_remaining
  from pon_auction_headers_all
  where auction_header_id = p_auction_header_id;

EXCEPTION
  WHEN OTHERS THEN
      RAISE;
end GET_TIME_REMAINING;

FUNCTION get_product_install_status ( x_product_name IN VARCHAR2) RETURN VARCHAR2 IS
  x_progress     VARCHAR2(3) := NULL;
  x_app_id       NUMBER;
  x_install      BOOLEAN;
  x_status       VARCHAR2(1);
  x_org          VARCHAR2(1);
  x_temp_product_name varchar2(10);
begin
  --Retreive product id from fnd_application based on product name
  x_progress := 10;

  select application_id
  into   x_app_id
  from   fnd_application
  where application_short_name = x_product_name ;

  --get product installation status
  x_progress := 20;
  x_install := fnd_installation.get(x_app_id,x_app_id,x_status,x_org);

  if (x_install)
  THEN
    x_status := 'Y';
  ELSE
    x_status := 'N';
  end if;

  RETURN(x_status);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      null;
      RETURN(null);
    WHEN OTHERS THEN
      RAISE;

end get_product_install_status;



function getPhoneNumber(p_user_name varchar2) return varchar2 is
begin
if g_userName is null or g_userName <> p_user_name then
retrieve_user_info(p_user_name);
end if;
return g_phoneNumber;
end getPhoneNumber;

function getFaxNumber(p_user_name varchar2) return varchar2 is
begin
if g_userName is null or g_userName <> p_user_name then
retrieve_user_info(p_user_name);
end if;
return g_faxNumber;
end getFaxNumber;

function getEMail(p_user_name varchar2) return varchar2 is
begin
if g_userName is null or g_userName <> p_user_name then
retrieve_user_info(p_user_name);
end if;
return g_eMail;
end getEMail;


procedure getTriangulationRate(toCurrency varchar2,
                              fromCurrency varchar2,
                              rateDate date,
                              rateType varchar2,
                              rollDays number,
                              rate out nocopy number
                              ) is
denom number;
num number;

begin
GL_CURRENCY_API.get_closest_triangulation_Rate(toCurrency,fromCurrency,rateDate,null,rollDays,denom,num,rate);

end getTriangulationRate;


function getClosestRate(fromCurrency varchar2,
                        toCurrency varchar2,
                        conversionDate date,
                        conversionType varchar2,
                        maxRollDays number) return varchar2 is
  x_rate number;
begin
  x_rate := GL_CURRENCY_API.get_closest_rate(fromCurrency, toCurrency, conversionDate, conversionType, maxRollDays);
  return x_rate;
end getClosestRate;


/*======================================================================
 PROCEDURE :  DELETE_NEGOTIATION_AMENDMENTS    PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_error_code            out     internal code for error

 COMMENT   : delete negotiation amendments created
======================================================================*/
PROCEDURE DELETE_NEGOTIATION_AMENDMENTS (
    x_negotiation_id        in   number,
    x_error_code            out  NOCOPY varchar2) is

    x_original_auction_id NUMBER;
BEGIN

    x_error_code := 'SUCCESS';

    BEGIN

  UPDATE PON_AUCTION_HEADERS_ALL
  SET AUCTION_STATUS = 'DELETED'
  WHERE
    AUCTION_HEADER_ID_ORIG_AMEND IS NOT NULL
  AND  AUCTION_HEADER_ID_ORIG_AMEND = x_negotiation_id;

  UPDATE PON_AUCTION_HEADERS_ALL
  SET AUCTION_STATUS = 'DELETED'
  WHERE
    AUCTION_HEADER_ID  = x_negotiation_id;

	--bug 16943040
	--For Amendment Delete, when there is backing Requisition in originial Negotiation
	--and Amendment is in approved state, backing Reqs should be sent to pool in the original Negotiation
    begin
      SELECT AUCTION_HEADER_ID_ORIG_AMEND
        INTO x_original_auction_id
          FROM PON_AUCTION_HEADERS_ALL
            WHERE AUCTION_HEADER_ID  = x_negotiation_id;

        DELETE_NEGOTIATION_REF(x_original_auction_id,x_error_code);
    END;

     EXCEPTION

  WHEN OTHERS THEN
    x_error_code := 'FAILURE';
     END;

END DELETE_NEGOTIATION_AMENDMENTS;

/*======================================================================
 *  PROCEDURE :  GET_MOST_RECENT_AMENDMENT    PUBLIC
 *   PARAMETERS:
 *     x_negotiation_id        in      auction header id
 *
 *        COMMENT   : returns the auction header id of the most recent active
 *        amendment
 *        ======================================================================*/
FUNCTION GET_MOST_RECENT_AMENDMENT(p_auction_header_id IN NUMBER) RETURN NUMBER

IS

    v_auction_status               VARCHAR2(25);
    v_auction_header_id_orig_amend NUMBER;
    v_most_recent_amendment        NUMBER;


BEGIN

    select auction_status
    into   v_auction_status
    from   pon_auction_headers_all
    where  auction_header_id = p_auction_header_id;

    IF (v_auction_status = 'AMENDED') THEN

      select auction_header_id_orig_amend
      into   v_auction_header_id_orig_amend
      from   pon_auction_headers_all
      where  auction_header_id = p_auction_header_id;

      select auction_header_id
      into   v_most_recent_amendment
      from   pon_auction_headers_all
      where  auction_header_id_orig_amend = v_auction_header_id_orig_amend and
             auction_status <> 'AMENDED' and auction_status <> 'DRAFT' and
             rownum = 1;  -- rownum = 1 is a sanity check

    ELSE

      v_most_recent_amendment := p_auction_header_id;

    END IF;

   RETURN v_most_recent_amendment;

END GET_MOST_RECENT_AMENDMENT;

FUNCTION GET_MEMBER_TYPE(p_auction_header_id IN NUMBER,p_user_id IN NUMBER) RETURN VARCHAR2
IS
    v_member_type               VARCHAR2(1);
BEGIN
    v_member_type   := 'X';
    select nvl(member_type,'X')
                into v_member_type
                from pon_neg_team_members
    where auction_header_id =p_auction_header_id
    and user_id = p_user_id;

                return v_member_type;
END GET_MEMBER_TYPE;


-- this procedure is added for header price break default
-- The procedure determines the price_break_response for pon_auction_headers_all table.
-- It's used in plsql routines where new negotiation created,
-- including negotiation copy/new round/amendment, autocreation and renegotiation.
-- The logic is same as AuctionHeadersAllEO

PROCEDURE get_default_hdr_pb_settings (p_doctype_id IN NUMBER,
                                       p_tp_id IN NUMBER,
                                       x_price_break_response OUT NOCOPY VARCHAR2) IS

        l_pref_unused_1       VARCHAR2(300);
        l_pref_unused_2       VARCHAR2(300);
        l_pref_unused_3       VARCHAR2(300);

        l_price_break_display_flag PON_AUC_DOCTYPE_RULES.display_flag%type;

BEGIN

        select display_flag
          into l_price_break_display_flag
          from PON_AUC_DOCTYPE_RULES dr,
               PON_AUC_BIZRULES b
         where b.bizrule_id = dr.bizrule_id
           and dr.doctype_id = p_doctype_id
           and b.name = 'PRICE_BREAK';

        if (l_price_break_display_flag = 'N') then
           x_price_break_response := 'NONE';
        else

           BEGIN
                PON_PROFILE_UTIL_PKG.RETRIEVE_PARTY_PREF_COVER(
                                p_party_id        => p_tp_id,
                                p_app_short_name  => 'PON',
                                p_pref_name       => 'PRICE_BREAK_RESPONSE_TYPE',
                                x_pref_value      => x_price_break_response,
                                x_pref_meaning    => l_pref_unused_1,
                                x_status          => l_pref_unused_2,
                                x_exception_msg   => l_pref_unused_3);

                                IF  (l_pref_unused_2 <> FND_API.G_RET_STS_SUCCESS) THEN
                                        x_price_break_response := 'NONE';
                                END IF;

           EXCEPTION
                WHEN OTHERS THEN
                        x_price_break_response := 'NONE';
           END;

        end if;

END get_default_hdr_pb_settings;


-- this procedure is added for header price break default
-- The procedure determines the price_break_type and price_break_neg_flag
-- for pon_auction_item_prices_all table.
-- It assumes the auction header already exists.
-- It's used in plsql routines where lines are inserted, including line spreadsheet upload,
-- negotiation copy/new round/amendment, autocreation and renegotiation.

PROCEDURE get_default_pb_settings (p_auction_header_id IN NUMBER,
                                   x_price_break_type OUT NOCOPY VARCHAR2,
                                   x_price_break_neg_flag OUT NOCOPY VARCHAR2) IS

l_price_break_response                pon_auction_headers_all.price_break_response%type;
l_contract_type                       pon_auction_headers_all.contract_type%type;
l_doctype_id                          pon_auction_headers_all.doctype_id%type;
l_po_style_id                         pon_auction_headers_all.po_style_id%type;
l_template_id                         pon_auction_headers_all.template_id%type;
l_template_pb_type                    pon_auction_item_prices_all.price_break_type%type;
l_org_id                              pon_auction_headers_all.org_id%type;
l_po_pb_type                          po_system_parameters_all.price_break_lookup_code%type;
l_price_break_display_flag            PON_AUC_DOCTYPE_RULES.display_flag%type;
l_price_break_enabled_flag            VARCHAR2(1);
l_price_break_allowed                 VARCHAR2(1);
l_price_tiers_indicator               pon_auction_headers_all.price_tiers_indicator%type;

l_dummy1     VARCHAR2(240);
l_dummy2     VARCHAR2(240);
l_dummy3     VARCHAR2(30);
l_dummy4     VARCHAR2(30);
l_dummy5     VARCHAR2(1);
l_dummy6     VARCHAR2(1);
l_dummy7     VARCHAR2(1);
l_dummy8     VARCHAR2(1);
l_dummy9     VARCHAR2(1);
l_dummy10    VARCHAR2(30);

BEGIN

      select contract_type, doctype_id, price_break_response, po_style_id, template_id, org_id, price_tiers_indicator
        into l_contract_type, l_doctype_id, l_price_break_response, l_po_style_id, l_template_id, l_org_id, l_price_tiers_indicator
        from pon_auction_headers_all
       where auction_header_id = p_auction_header_id;

      select display_flag
        into l_price_break_display_flag
        from PON_AUC_DOCTYPE_RULES dr,
             PON_AUC_BIZRULES b
       where b.bizrule_id = dr.bizrule_id
         and dr.doctype_id = l_doctype_id
         and b.name = 'PRICE_BREAK';


      -- invoke po api to get price break setting for the po style
      BEGIN
                PO_DOC_STYLE_GRP.GET_DOCUMENT_STYLE_SETTINGS(
                                                   P_API_VERSION => '1.0',
                                                   P_STYLE_ID    => l_po_style_id,
                                                   X_STYLE_NAME  => l_dummy1,
                                                   X_STYLE_DESCRIPTION => l_dummy2,
                                                   X_STYLE_TYPE  => l_dummy3,
                                                   X_STATUS => l_dummy4,
                                                   X_ADVANCES_FLAG => l_dummy5,
                                                   X_RETAINAGE_FLAG => l_dummy6,
                                                   X_PRICE_BREAKS_FLAG => l_price_break_enabled_flag,
                                                   X_PRICE_DIFFERENTIALS_FLAG => l_dummy7,
                                                   X_PROGRESS_PAYMENT_FLAG=> l_dummy8,
                                                   X_CONTRACT_FINANCING_FLAG=> l_dummy9,
                                                   X_LINE_TYPE_ALLOWED  => l_dummy10);

      EXCEPTION
                WHEN OTHERS THEN
                    l_price_break_enabled_flag := 'Y';
      END;


      -- if price break doesn't apply, set to NONE
      -- check if price break is allowed
      if ( l_price_break_display_flag = 'Y' and
           (l_contract_type = 'BLANKET' or l_contract_type = 'CONTRACT') and
           l_price_break_enabled_flag = 'Y') then

            l_price_break_allowed := 'Y';
      else
            l_price_break_allowed := 'N';
            l_price_break_response := 'NONE';
      end if;


      if (l_price_break_allowed = 'N' or l_price_break_response = 'NONE' or l_price_tiers_indicator = 'QUANTITY_BASED' ) then
           -- not allowed by biz rule or header setting is NONE
           x_price_break_type := 'NONE';
      else
           x_price_break_type := 'NON-CUMULATIVE';

           -- if negotiation has template, use template setting if template is CUMULATIVE or NON CUMULATIVE
           if (l_template_id is not null) then

                   BEGIN
                       select price_break_type
                         into l_template_pb_type
                         from pon_auction_item_prices_all
                        where auction_header_id = l_template_id;
                   EXCEPTION
                         WHEN OTHERS THEN
                             l_template_pb_type := 'NONE';
                   END;

                   if (l_template_pb_type <> 'NONE') then
                        x_price_break_type := l_template_pb_type;
                   end if;
           else
           -- get the setting from po price break setting for the specified org
                   BEGIN
                        select decode(price_break_lookup_code, 'NON CUMULATIVE',
                                      'NON-CUMULATIVE', price_break_lookup_code)
                          into l_po_pb_type
                          from po_system_parameters_all
                         where org_id = l_org_id;
                   EXCEPTION
                         WHEN OTHERS THEN
                             l_po_pb_type := 'NON-CUMULATIVE';
                   END;

                   x_price_break_type := l_po_pb_type;
           end if;
      end if;


      if (l_price_break_response = 'REQUIRED') then
         x_price_break_neg_flag := 'N';
      else
         x_price_break_neg_flag := 'Y';
      end if;

END get_default_pb_settings;


-- Used in Complex work
--returns whether Projects is installed for current org or not
FUNCTION getPAOUInstalled (p_orgId IN NUMBER) RETURN VARCHAR2 IS
    l_progress     VARCHAR2(3) := NULL;
    l_app_id       NUMBER;
    l_install      BOOLEAN;
    l_status       VARCHAR2(1);
  begin
    l_progress := 10;
    --get Projects  installation status
    return  PA_UTILS4.IsProjectsImplemented(p_orgId);

EXCEPTION
      WHEN OTHERS THEN
        RAISE;

end getPAOUInstalled;

-- Used in Complex work
--returns whether Grants is installed for current org or not
FUNCTION getGMSOUInstalled ( p_orgId IN NUMBER) RETURN VARCHAR2 IS
    l_progress     VARCHAR2(3) := NULL;
    l_app_id       NUMBER;
    l_install      BOOLEAN;
    l_status       VARCHAR2(1);
  begin
    l_progress := 10;
    --get Grants  installation status
      l_install := GMS_INSTALL.ENABLED(p_orgId);

         l_progress := 20;
    if (l_install)
    THEN
      l_status := 'Y';
    ELSE
      l_status := 'N';
    end if;

    RETURN(l_status);

EXCEPTION
      WHEN OTHERS THEN
        RAISE;

end getGMSOUInstalled;

--------------------------------------------------------------------------------
--                      IS_NEGOTIATION_REQ_BACKED                         --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: IS_NEGOTIATION_REQ_BACKED
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API is called by the Negotiation Import Spreadsheet code.
--           It determines if all the lines in the spreadsheet have a
--           backing requisition or not.  If all the lines have a backing
--           requisition, then project related attributes will not be downloaded
--           into the spreasheet
--
-- Parameters:
--
--              p_auction_header_id       IN      NUMBER
--                   Auction header id - required
--
--              x_req_backed OUT      VARCHAR2
--                   Returns Y if all the lines that are eligible to have
--                   payitems have a backing Requisition
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE  IS_NEGOTIATION_REQ_BACKED(
             p_auction_header_id       IN        NUMBER,
             x_req_backed              OUT NOCOPY VARCHAR2) IS
BEGIN
  x_req_backed := 'Y';

    SELECT 'N'
      INTO x_req_backed
      FROM dual
     WHERE EXISTS (SELECT 1
       FROM pon_auction_item_prices_all al
      WHERE al.auction_header_id = p_auction_header_id
            AND al.group_type NOT IN ('GROUP','LOT_LINE')
            AND nvl(al.line_origination_code,'-9998') <> 'REQUISITION');
EXCEPTION
  WHEN NO_DATA_FOUND
   THEN
     x_req_backed := 'N';
  WHEN OTHERS THEN
       RAISE;
END IS_NEGOTIATION_REQ_BACKED;

/*=========================================================================+
-- 12.0 Enhancement
-- New procedure to send Notification to the given Collaboration
-- Team Member as requested by Negotiation Creator.
-- Parameter :
--
--           p_auction_header_id IN NUMBER,
--           p_user_id           IN NUMBER, This will be user id
--                                          of Notification Recipient,
--                                          i.e. Team Member.
--           x_return_status     OUT NOCOPY VARCHAR2,
--                                          flag to indicate if the copy procedure
--                                          was successful or not; It can have
--                                          following values -
--                                              FND_API.G_RET_STS_SUCCESS (Success)
--                                              FND_API.G_RET_STS_ERROR  (Success with warning)
--                                              FND_API.G_RET_STS_UNEXP_ERROR (Failed due to error)
--
+=========================================================================*/


PROCEDURE SEND_TASK_ASSIGN_NOTIF (p_auction_header_id IN     NUMBER,
                                  p_user_id           IN     NUMBER,
                                  x_return_status     OUT NOCOPY VARCHAR2)
IS
    l_module_name constant VARCHAR2(40) := 'SEND_TASK_ASSIGN_NOTIF';
    l_progress                  VARCHAR2(3);
    l_language_code             VARCHAR2(60);
    l_lang_code                 VARCHAR2(30);
    l_doc_number                PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
    l_auction_start_date        DATE;
    l_auction_end_date          DATE;
    l_preview_date              DATE;
    l_msg_suffix                PON_AUC_DOCTYPES.MESSAGE_SUFFIX%TYPE;
    l_auction_title             PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
    l_preparer_tp_name          HZ_PARTIES.PARTY_NAME%TYPE;
    l_task_name                 PON_NEG_TEAM_MEMBERS.TASK_NAME%TYPE;
    l_task_target_date          DATE;
    l_task_assignment_date      DATE;
    l_task_assigned_subject     VARCHAR2(2000);
    l_timezone_disp             VARCHAR2(240);
    l_auctioneer_user_name      VARCHAR2(244);
    l_user_name       VARCHAR2(244);
    l_person_party_id           NUMBER;
    l_sequence                  NUMBER;
    x_itemtype                  VARCHAR2(7);
    x_itemkey                  VARCHAR2(50);
    l_open_auction_now_flag VARCHAR2(1);
    l_publish_auction_now_flag VARCHAR2(1);

    --SLM UI Enhancement
    l_is_slm VARCHAR2(1);

 BEGIN
      BEGIN

         l_progress := '000';
         x_return_status := FND_API.G_RET_STS_SUCCESS;
             IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string (log_level => FND_LOG.level_procedure,
                                       module => g_module || l_module_name,
                                       message  => 'Entering to Procedure ' || g_module || l_module_name
                                       || ', l_progress = ' || l_progress
                                       || ', p_auction_header_id = ' || p_auction_header_id
                                       || ', p_user_id = ' || p_user_id);
             END IF;


           l_language_code := fnd_profile.value_specific('ICX_LANGUAGE', p_user_id, NULL, NULL);

           l_progress := '010';

           SELECT LANGUAGE_CODE
           INTO l_lang_code
           FROM FND_LANGUAGES
           WHERE NLS_LANGUAGE = l_language_code;

           l_progress := '020';

           --SLM UI Enhancement
           l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id);

           select auh.DOCUMENT_NUMBER,
                  auh.OPEN_BIDDING_DATE,
                  auh.CLOSE_BIDDING_DATE,
                  auh.VIEW_BY_DATE,
                  Decode(l_is_slm, 'Y', PON_SLM_UTIL_PKG.SLM_MESSAGE_SUFFIX, pad.MESSAGE_SUFFIX), --SLM UI Enhancement
                  auh.AUCTION_TITLE,
                  hz.PARTY_NAME PREPARER_TP_NAME,
                  pntm.TASK_NAME,
                  pntm.TARGET_DATE TASK_TARGET_DATE,
                  pntm.LAST_NOTIFIED_DATE TASK_ASSIGNMENT_DATE,
                  auh.TRADING_PARTNER_CONTACT_NAME,
                  fu.person_party_id,
                  fu.user_name,
                  auh.open_auction_now_flag,
                  auh.publish_auction_now_flag

            into  l_doc_number,
                  l_auction_start_date,
                  l_auction_end_date,
                  l_preview_date,
                  l_msg_suffix,
                  l_auction_title,
                  l_preparer_tp_name,
                  l_task_name,
                  l_task_target_date,
                  l_task_assignment_date,
                  l_auctioneer_user_name,
                  l_person_party_id,
                  l_user_name,
                  l_open_auction_now_flag,
                  l_publish_auction_now_flag

           from pon_auction_headers_all auh,
                  hz_parties hz,
                  pon_neg_team_members pntm,
                  fnd_user fu,
                  pon_auc_doctypes pad
           where auh.auction_header_id = p_auction_header_id
                  AND hz.party_id = auh.trading_partner_id
                  AND pntm.auction_header_id = auh.auction_header_id
                  AND pntm.user_id = p_user_id
                  AND fu.user_id = pntm.user_id
                  AND pad.doctype_id = auh.doctype_id;

              l_progress := '030';

              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After query execution : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_doc_number          = ' || l_doc_number
                                        || ', l_language_code = ' || l_language_code
                                        || ', l_lang_code = ' || l_lang_code
                                        || ', l_auction_start_date      = ' || l_auction_start_date
                                        || ', l_auction_end_date        = ' || l_auction_end_date
                                        || ', l_preview_date            = ' || l_preview_date
                                        || ', l_msg_suffix          = ' || l_msg_suffix
                                        || ', l_auction_title           = ' || l_auction_title
                                        || ', l_preparer_tp_name        = ' || l_preparer_tp_name
                                        || ', l_task_name           = ' || l_task_name
                                        || ', l_task_target_date        = ' || l_task_target_date
                                        || ', l_task_assignment_date        = ' || l_task_assignment_date
                                        || ', l_auctioneer_user_name        = ' || l_auctioneer_user_name
                                        || ', l_user_name         = ' || l_user_name
                                        || ', l_open_auction_now_flag         = ' || l_open_auction_now_flag
                                        || ', l_publish_auction_now_flag         = ' || l_publish_auction_now_flag
                                        || ', l_person_party_id     = ' || l_person_party_id);

              END IF;

          -- Get the recipient user's language preference
          -- And set the session language so messages are
          -- retrieved in that language.
          IF p_user_id IS NOT NULL THEN
            PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE (p_user_id, l_lang_code);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module => g_module_prefix || 'SEND_TASK_ASSIGN_NOTIF',
              message  => '9. Calling SET_SESSION_LANGUAGE with l_lang_code : ' || l_lang_code);
            END IF; --}

            SET_SESSION_LANGUAGE (null, l_lang_code);
          END IF;

          --Subject should be retrieved from seed message

          PON_OEX_TIMEZONE_PKG.CONVERT_DATE_TO_USER_TZ(p_person_party_id => l_person_party_id,
                                                       p_auctioneer_user_name => l_auctioneer_user_name,
                                                       x_date_value1  => l_auction_start_date,
                                                       x_date_value2  => l_auction_end_date,
                                                       x_date_value3  => l_preview_date,
                                                       x_date_value4  => l_task_target_date,
                                                       x_date_value5  => l_task_assignment_date,
                                                       x_timezone_disp =>l_timezone_disp);

          l_progress := '040';

          l_task_assigned_subject :=  PON_AUCTION_PKG.getMessage( msg => 'PON_AUC_TASK_ASN_NOTIF_SUB',
                                                                 msg_suffix => '_'|| l_msg_suffix,
                                                                 token1 => 'DOC_NUMBER',
                                                                 token1_value => l_doc_number,
                                                                 token2 => 'AUCTION_TITLE',
                                                                 token2_value => replaceHtmlChars(l_auction_title));
          l_progress := '050';


              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After getting new time and subject : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_auction_start_date      = ' || l_auction_start_date
                                        || ', l_auction_end_date        = ' || l_auction_end_date
                                        || ', l_preview_date            = ' || l_preview_date
                                        || ', l_timezone_disp = ' || l_timezone_disp
                                        || ', l_task_assigned_subject = ' || l_task_assigned_subject);
              END IF;

          x_itemtype := 'PONAUCT';

          SELECT pon_auction_wf_publish_s.nextval
          INTO   l_sequence
          FROM   dual;

          x_itemkey := p_auction_header_id||'-'|| l_sequence;

          wf_engine.CreateProcess(itemtype => x_itemtype,
                                  itemkey  => x_itemkey,
                                  process  => 'TEAM_MEM_TASK_ASSIGNED');
          l_progress := '060';

              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After CreateProcess ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', x_itemtype = ' || x_itemtype
                                        || ', x_itemkey = ' || x_itemkey);
              END IF;


              SET_PREVIEW_DATE(
                        p_itemtype => x_itemtype,
                        p_itemkey   => x_itemkey,
                        p_preview_date  => l_preview_date,
                        p_publish_auction_now_flag => l_publish_auction_now_flag,
                        p_timezone_disp  => l_timezone_disp,
                        p_msg_suffix => l_msg_suffix);

              SET_OPEN_DATE(
                        p_itemtype      => x_itemtype,
                        p_itemkey      => x_itemkey,
                        p_auction_start_date  => l_auction_start_date,
                        p_open_auction_now_flag => l_open_auction_now_flag,
                        p_timezone_disp  => l_timezone_disp,
                        p_msg_suffix => l_msg_suffix);

              SET_CLOSE_DATE(
                        p_itemtype  =>x_itemtype,
                        p_itemkey    =>x_itemkey,
                        p_auction_end_date  => l_auction_end_date,
                        p_timezone_disp  => l_timezone_disp);

             l_progress := '090';

             wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'DOC_NUMBER',
                                       avalue     => l_doc_number);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'AUCTION_TITLE',
                                       avalue     => l_auction_title);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'PREPARER_TP_CONTACT_NAME',
                                       avalue     => l_auctioneer_user_name);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'ORIGIN_USER_NAME',
                                       avalue     => fnd_global.user_name);

             wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                        itemkey    => x_itemkey,
                                        aname      => 'RECIPIENT_ROLE',
                                        avalue     => l_user_name);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'PREPARER_TP_NAME',
                                       avalue     => l_preparer_tp_name);

            wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'TASK_TARGET_DATE',
                                       avalue     => l_task_target_date);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'TASK_NAME',
                                       avalue     => l_task_name);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'TASK_ASSIGNED_SUBJECT',
                                       avalue     => l_task_assigned_subject);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'AUCTION_ID',
                                       avalue     => p_auction_header_id);

            --SLM UI Enhancement
            PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(x_itemtype, x_itemkey, p_auction_header_id);

            l_progress := '100';

    -- Bug 4295915: Set the  workflow owner
            wf_engine.SetItemOwner(itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   owner    => fnd_global.user_name);

            wf_engine.StartProcess(itemtype => x_itemtype,
                                   itemkey  => x_itemkey );


            l_progress := 'END';

            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                         FND_LOG.string (log_level => FND_LOG.level_procedure,
                                      module => g_module || l_module_name,
                                       message  => 'Procedure Ends ' || g_module || l_module_name
                                      || ', l_progress = ' || l_progress);
            END IF;

            UNSET_SESSION_LANGUAGE;

        EXCEPTION WHEN OTHERS THEN
            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'In Exception Block : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', p_auction_header_id = ' || p_auction_header_id
                                        || ', p_user_id = ' || p_user_id);
            END IF;
            UNSET_SESSION_LANGUAGE;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END;

END SEND_TASK_ASSIGN_NOTIF;

/*===========================================================================================+
--
-- 12.0 Enhancement
-- SEND_TASK_COMPL_NOTIF procedure will be responsible
-- for sending notification from the Buyer user to the
-- Negotiation Creator when the former completes a given
-- task for a Collaboration Team Member.
-- Parameter :
--             p_auction_header_id IN NUMBER,
--             p_user_id           IN NUMBER, This will be user id
--                                            Notification sender,
--                                            i.e.Team Member.
--             x_return_status     OUT NOCOPY VARCHAR2,
--                                          flag to indicate if the copy procedure
--                                          was successful or not; It can have
--                                          following values -
--                                              FND_API.G_RET_STS_SUCCESS (Success)
--                                              FND_API.G_RET_STS_ERROR  (Success with warning)
--                                              FND_API.G_RET_STS_UNEXP_ERROR (Failed due to error)
--
+===========================================================================================*/

PROCEDURE SEND_TASK_COMPL_NOTIF ( p_auction_header_id IN NUMBER,
                                  p_user_id           IN NUMBER,
                                  x_return_status     OUT NOCOPY VARCHAR2)
IS
    l_module_name constant VARCHAR2(40) := 'SEND_TASK_COMPL_NOTIF';
    l_progress                  VARCHAR2(3);
    l_language_code             VARCHAR2(60);
    l_lang_code                 VARCHAR2(30);
    l_doc_number                PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
    l_auction_start_date        DATE;
    l_auction_end_date          DATE;
    l_preview_date              DATE;
    l_msg_suffix                PON_AUC_DOCTYPES.MESSAGE_SUFFIX%TYPE;
    l_auction_title             PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
    l_preparer_tp_name          HZ_PARTIES.PARTY_NAME%TYPE;
    l_task_name                 PON_NEG_TEAM_MEMBERS.TASK_NAME%TYPE;
    l_task_target_date          DATE;
    l_task_completion_date      DATE;
    l_task_completed_subject     VARCHAR2(2000);
    l_timezone_disp             VARCHAR2(240);
    l_auctioneer_user_name      VARCHAR2(244);
    l_user_name                 VARCHAR2(244);
    l_tp_contact_id             NUMBER;
    l_tp_contact_usr_id         NUMBER;
    l_trading_partner_id        NUMBER;
    l_sequence                  NUMBER;
    x_itemtype                  VARCHAR2(7);
    x_itemkey                  VARCHAR2(50);
    l_open_auction_now_flag VARCHAR2(1);
    l_publish_auction_now_flag   VARCHAR2(1);
    l_doctype_group_name varchar2(100);

    --SLM UI Enhancement
    l_is_slm VARCHAR2(1);

 BEGIN
      BEGIN

         l_progress := '000';
         x_return_status := FND_API.G_RET_STS_SUCCESS;

             IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string (log_level => FND_LOG.level_procedure,
                                       module => g_module || l_module_name,
                                       message  => 'Entering to Procedure ' || g_module || l_module_name
                                       || ', l_progress = ' || l_progress
                                       || ', p_auction_header_id = ' || p_auction_header_id
                                       || ', p_user_id = ' || p_user_id);
             END IF;

             --SLM UI Enhancement
             l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id);

             BEGIN
                   select auh.DOCUMENT_NUMBER,
                          auh.OPEN_BIDDING_DATE,
                          auh.CLOSE_BIDDING_DATE,
                          auh.VIEW_BY_DATE,
                          Decode(l_is_slm, 'Y', PON_SLM_UTIL_PKG.SLM_MESSAGE_SUFFIX, pad.MESSAGE_SUFFIX), --SLM UI Enhancement
                          auh.AUCTION_TITLE,
                          auh.TRADING_PARTNER_CONTACT_NAME,
                          auh.TRADING_PARTNER_CONTACT_ID,
                          auh.TRADING_PARTNER_ID,
                          fu.user_id,
                          auh.open_auction_now_flag,
                          auh.publish_auction_now_flag
                    into  l_doc_number,
                          l_auction_start_date,
                          l_auction_end_date,
                          l_preview_date,
                          l_msg_suffix,
                          l_auction_title,
                          l_auctioneer_user_name,
                          l_tp_contact_id,
                          l_trading_partner_id,
                          l_tp_contact_usr_id,
                          l_open_auction_now_flag,
                          l_publish_auction_now_flag
                   from pon_auction_headers_all auh,
                          pon_auc_doctypes pad,
                          fnd_user fu
                   where auh.auction_header_id = p_auction_header_id
                          AND pad.doctype_id = auh.doctype_id
                          AND fu.person_party_id = auh.TRADING_PARTNER_CONTACT_ID
                          AND nvl(fu.end_date,sysdate+1) > sysdate;

           EXCEPTION
                   WHEN TOO_MANY_ROWS THEN
                     if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
                           if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                                         fnd_log.string(log_level => fnd_log.level_unexpected,
                                                        module    => 'pon.plsql.pon_auction_pkg.send_task_compl_notif',
                                                        message   => 'Multiple Users found for auction_header_id:'|| p_auction_header_id);
                           end if;
                     end if;

                    select auh.DOCUMENT_NUMBER,
                          auh.OPEN_BIDDING_DATE,
                          auh.CLOSE_BIDDING_DATE,
                          auh.VIEW_BY_DATE,
                          Decode(l_is_slm, 'Y', PON_SLM_UTIL_PKG.SLM_MESSAGE_SUFFIX, pad.MESSAGE_SUFFIX), --SLM UI Enhancement
                          auh.AUCTION_TITLE,
                          auh.TRADING_PARTNER_CONTACT_NAME,
                          auh.TRADING_PARTNER_CONTACT_ID,
                          auh.TRADING_PARTNER_ID,
                          fu.user_id,
                          auh.open_auction_now_flag,
                          auh.publish_auction_now_flag
                     into  l_doc_number,
                          l_auction_start_date,
                          l_auction_end_date,
                          l_preview_date,
                          l_msg_suffix,
                          l_auction_title,
                          l_auctioneer_user_name,
                          l_tp_contact_id,
                          l_trading_partner_id,
                          l_tp_contact_usr_id,
                          l_open_auction_now_flag,
                          l_publish_auction_now_flag
                    from pon_auction_headers_all auh,
                          pon_auc_doctypes pad,
                          fnd_user fu
                    where auh.auction_header_id = p_auction_header_id
                          AND pad.doctype_id = auh.doctype_id
                          AND fu.person_party_id = auh.TRADING_PARTNER_CONTACT_ID
                          AND nvl(fu.end_date,sysdate+1) > sysdate
                          AND rownum=1;
           END;

           l_progress := '005';

           IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                   FND_LOG.string (log_level => FND_LOG.level_procedure,
                                     module => g_module || l_module_name,
                                     message  => 'Entering to Procedure ' || g_module || l_module_name
                                     || ', l_progress = ' || l_progress
                                     || ', l_doc_number           = ' || l_doc_number
                                     || ', l_auction_start_date       = ' || l_auction_start_date
                                     || ', l_auction_end_date     = ' || l_auction_end_date
                                     || ', l_preview_date         = ' || l_preview_date
                                     || ', l_msg_suffix           = ' || l_msg_suffix
                                     || ', l_auction_title            = ' || l_auction_title
                                     || ', l_auctioneer_user_name     = ' || l_auctioneer_user_name
                                     || ', l_user_name     = ' || l_user_name
                                     || ', l_tp_contact_id        = ' || l_tp_contact_id
                                     || ', l_tp_contact_usr_id = ' || l_tp_contact_usr_id
                                     || ', l_trading_partner_id       = ' || l_trading_partner_id
                                     || ', l_open_auction_now_flag  = ' || l_open_auction_now_flag
                                     || ', l_publish_auction_now_flag = ' || l_publish_auction_now_flag
                                     );
           END IF;

           l_language_code := fnd_profile.value_specific('ICX_LANGUAGE', l_tp_contact_usr_id, NULL, NULL);

           l_progress := '010';

           SELECT LANGUAGE_CODE
           INTO l_lang_code
           FROM FND_LANGUAGES
           WHERE NLS_LANGUAGE = l_language_code;

           l_progress := '020';

           select hz.PARTY_NAME PREPARER_TP_NAME,
                  pntm.TASK_NAME,
                  pntm.TARGET_DATE TASK_TARGET_DATE,
                  pntm.COMPLETION_DATE TASK_COMPLETION_DATE,
                  fu.user_name
            into  l_preparer_tp_name,
                  l_task_name,
                  l_task_target_date,
                  l_task_completion_date,
                  l_user_name
           from hz_parties hz,
                  pon_neg_team_members pntm,
                  fnd_user fu
           where pntm.auction_header_id = p_auction_header_id
                  AND hz.party_id = l_trading_partner_id
                  AND pntm.user_id = p_user_id
                  AND fu.user_id = pntm.user_id;


              l_progress := '030';

              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After query execution : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_language_code = ' || l_language_code
                                        || ', l_lang_code = ' || l_lang_code
                                        || ', l_preparer_tp_name        = ' || l_preparer_tp_name
                                        || ', l_task_name           = ' || l_task_name
                                        || ', l_task_target_date        = ' || l_task_target_date
                                        || ', l_task_completion_date = ' || l_task_completion_date);
              END IF;

          -- Get the recipient user's language preference
          -- And set the session language so messages are
          -- retrieved in that language.
          IF l_tp_contact_usr_id IS NOT NULL THEN
            PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE (l_tp_contact_usr_id, l_lang_code);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module => g_module_prefix || 'SEND_TASK_COMPL_NOTIF',
              message  => '10. Calling SET_SESSION_LANGUAGE with l_lang_code : ' || l_lang_code);
            END IF; --}

            SET_SESSION_LANGUAGE (null, l_lang_code);
          END IF;


          --Subject should be retrieved from seed message

          PON_OEX_TIMEZONE_PKG.CONVERT_DATE_TO_USER_TZ(p_person_party_id => l_tp_contact_id,
                                                       p_auctioneer_user_name => l_auctioneer_user_name,
                                                       x_date_value1  => l_auction_start_date,
                                                       x_date_value2  => l_auction_end_date,
                                                       x_date_value3  => l_preview_date,
                                                       x_date_value4  => l_task_target_date,
                                                       x_date_value5  => l_task_completion_date,
                                                       x_timezone_disp =>l_timezone_disp);

          l_progress := '040';

          l_task_completed_subject :=  PON_AUCTION_PKG.getMessage( msg => 'PON_AUC_TASK_COMPL_NOTIF_SUB',
                                                                 msg_suffix => '_'|| l_msg_suffix,
                                                                 token1 => 'DOC_NUMBER',
                                                                 token1_value => l_doc_number,
                                                                 token2 => 'AUCTION_TITLE',
                                                                 token2_value => replaceHtmlChars(l_auction_title));

          l_progress := '050';


              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After getting new time and subject : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_auction_start_date      = ' || l_auction_start_date
                                        || ', l_auction_end_date        = ' || l_auction_end_date
                                        || ', l_preview_date            = ' || l_preview_date
                                        || ', l_task_target_date = ' || l_task_target_date
                                        || ', l_task_completion_date = ' || l_task_completion_date
                                        || ', l_timezone_disp = ' || l_timezone_disp
                                        || ', l_task_completed_subject = ' || l_task_completed_subject);
              END IF;

          x_itemtype := 'PONAUCT';

          SELECT pon_auction_wf_publish_s.nextval
          INTO   l_sequence
          FROM   dual;

          x_itemkey := p_auction_header_id||'-'|| l_sequence;

          wf_engine.CreateProcess(itemtype => x_itemtype,
                                  itemkey  => x_itemkey,
                                  process  => 'TEAM_MEM_TASK_COMPLTD');
          l_progress := '060';

              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After CreateProcess ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', x_itemtype = ' || x_itemtype
                                        || ', x_itemkey = ' || x_itemkey);
              END IF;

                SET_PREVIEW_DATE(
                          p_itemtype => x_itemtype,
                          p_itemkey   => x_itemkey,
                          p_preview_date  => l_preview_date,
                          p_publish_auction_now_flag => l_publish_auction_now_flag,
                          p_timezone_disp  => l_timezone_disp,
                          p_msg_suffix => l_msg_suffix);

                SET_OPEN_DATE(
                          p_itemtype      => x_itemtype,
                          p_itemkey      => x_itemkey,
                          p_auction_start_date  => l_auction_start_date,
                          p_open_auction_now_flag => l_open_auction_now_flag,
                          p_timezone_disp  => l_timezone_disp,
                          p_msg_suffix => l_msg_suffix);

                SET_CLOSE_DATE(
                          p_itemtype  =>x_itemtype,
                          p_itemkey    =>x_itemkey,
                          p_auction_end_date  => l_auction_end_date,
                          p_timezone_disp  => l_timezone_disp);

            l_progress := '091';

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'DOC_NUMBER',
                                       avalue     => l_doc_number);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'AUCTION_TITLE',
                                       avalue     => l_auction_title);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'PREPARER_TP_CONTACT_NAME',
                                       avalue     => l_auctioneer_user_name);

             wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                        itemkey    => x_itemkey,
                                        aname      => 'RECIPIENT_ROLE',
                                        avalue     => l_user_name);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'PREPARER_TP_NAME',
                                       avalue     => l_preparer_tp_name);

            wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'TASK_TARGET_DATE',
                                       avalue     => l_task_target_date);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'TASK_NAME',
                                       avalue     => l_task_name);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'TASK_COMPLETED_SUBJECT',
                                       avalue     => l_task_completed_subject);

            wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                       itemkey    => x_itemkey,
                                       aname      => 'AUCTION_ID',
                                       avalue     => p_auction_header_id);

            --SLM UI Enhancement
            PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(x_itemtype, x_itemkey, p_auction_header_id);

    -- Bug 4295915: Set the  workflow owner
            wf_engine.SetItemOwner(itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   owner    => fnd_global.user_name);

            l_progress := '100';

            wf_engine.StartProcess(itemtype => x_itemtype,
                                   itemkey  => x_itemkey );


            l_progress := 'END';

            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                         FND_LOG.string (log_level => FND_LOG.level_procedure,
                                      module => g_module || l_module_name,
                                       message  => 'Procedure Ends ' || g_module || l_module_name
                                      || ', l_progress = ' || l_progress);
            END IF;

            UNSET_SESSION_LANGUAGE;

        EXCEPTION WHEN OTHERS THEN
            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'In Exception Block : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', p_auction_header_id = ' || p_auction_header_id
                                        || ', p_user_id = ' || p_user_id);
            END IF;
            UNSET_SESSION_LANGUAGE;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END;

END SEND_TASK_COMPL_NOTIF;


/*=========================================================================+
-- 12.0 Enhancement
-- SEND_RESP_NOTIF procedure will be responsible for
-- sending notification to the Buyer when a Seller
-- submits a Response.
-- Parameter :
--            p_bid_number               IN NUMBER,
--            x_return_status            OUT NOCOPY VARCHAR2
--
+=========================================================================*/

PROCEDURE SEND_RESP_NOTIF ( p_bid_number               IN NUMBER,
                           x_return_status             OUT NOCOPY VARCHAR2)
IS
    l_module_name constant VARCHAR2(40) := 'SEND_RESP_NOTIF';
    l_msg_suffix                PON_AUC_DOCTYPES.MESSAGE_SUFFIX%TYPE;
    l_progress                  VARCHAR2(3);
    l_lang_code                 VARCHAR2(30);
    l_itemtype                  VARCHAR2(7);
    l_language_code             VARCHAR2(60);
    l_itemkey                  VARCHAR2(50);
    l_auctioneer_user_name      VARCHAR2(244);
    l_bidder_user_name          VARCHAR2(244);

    l_doc_number                PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
    l_auction_header_id         PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID%TYPE;
    l_auction_title             PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
    l_tp_contact_id             PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_ID%TYPE;
    l_trading_partner_id        PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_ID%TYPE;
    l_preparer_tp_name          PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
    l_response_number           PON_BID_HEADERS.BID_NUMBER%TYPE;
    l_bidder_tpc_id             PON_BID_HEADERS.TRADING_PARTNER_CONTACT_ID%TYPE;
    l_bidder_tp_name            HZ_PARTIES.PARTY_NAME%TYPE;
    l_tp_contact_usr_id         FND_USER.USER_ID%TYPE;
    l_timezone_disp             VARCHAR2(240);
    l_bid_contact_dp_name       VARCHAR2(350);
    l_bidder_dp_name            VARCHAR2(350);
    l_response_type_name        VARCHAR2(2000);
    l_supplier_site_name        VARCHAR2(2000);
    l_response_url              VARCHAR2(2000);
    l_resp_publish_sub          VARCHAR2(2000);
    l_preview_date              DATE;
    l_auction_start_date        DATE;
    l_auction_end_date          DATE;
    l_bid_publish_date          DATE;
    l_null_date                 DATE;

    --SLM UI Enhancement
    l_is_slm_doc  VARCHAR2(1);

 BEGIN
      BEGIN

         l_progress := '000';
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_null_date := null;

             IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string (log_level => FND_LOG.level_procedure,
                                       module => g_module || l_module_name,
                                       message  => 'Entering to Procedure ' || g_module || l_module_name
                                       || ', l_progress = ' || l_progress
                                       || ', p_bid_number = ' || p_bid_number);
             END IF;

         BEGIN
           select auh.DOCUMENT_NUMBER,
                  auh.OPEN_BIDDING_DATE,
                  auh.CLOSE_BIDDING_DATE,
                  auh.VIEW_BY_DATE,
                  pad.MESSAGE_SUFFIX,
                  auh.AUCTION_TITLE,
                  auh.TRADING_PARTNER_CONTACT_NAME,
                  auh.TRADING_PARTNER_NAME PREPARER_TP_NAME,
                  auh.TRADING_PARTNER_CONTACT_ID,
                  auh.TRADING_PARTNER_ID,
                  fu.user_name,
                  decode(pbh.VENDOR_SITE_CODE, null, '', pbh.VENDOR_SITE_CODE) SUPPLIER_SITE_NAME,
                  pbh.TRADING_PARTNER_NAME BIDDER_TP_NAME,
                  pbh.PUBLISH_DATE BID_PUBLISH_DATE,
                  pbh.TRADING_PARTNER_CONTACT_ID BIDDER_TPC_ID,
                  auh.AUCTION_HEADER_ID
           into  l_doc_number,
                  l_auction_start_date,
                  l_auction_end_date,
                  l_preview_date,
                  l_msg_suffix,
                  l_auction_title,
                  l_auctioneer_user_name,
                  l_preparer_tp_name,
                  l_tp_contact_id,
                  l_trading_partner_id,
                  l_bidder_user_name,
                  l_supplier_site_name,
                  l_bidder_tp_name,
                  l_bid_publish_date,
                  l_bidder_tpc_id,
                  l_auction_header_id
           from pon_auction_headers_all auh,
                  pon_auc_doctypes pad,
                  pon_bid_headers pbh,
                  fnd_user fu
           where pbh.bid_number = p_bid_number
                  AND pad.doctype_id = auh.doctype_id
                  AND auh.auction_header_id = pbh.auction_header_id
                  AND fu.person_party_id = pbh.trading_partner_contact_id
                  AND nvl(fu.end_date, sysdate+1) > sysdate;
         EXCEPTION
             WHEN TOO_MANY_ROWS THEN
                  if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
                       if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                                 fnd_log.string(log_level => fnd_log.level_unexpected,
                                                module    => 'pon.plsql.pon_auction_pkg.send_resp_notif',
                                                message   => 'Multiple Users found for bid number:'|| p_bid_number);
                       end if;
                 end if;

           select auh.DOCUMENT_NUMBER,
                  auh.OPEN_BIDDING_DATE,
                  auh.CLOSE_BIDDING_DATE,
                  auh.VIEW_BY_DATE,
                  pad.MESSAGE_SUFFIX,
                  auh.AUCTION_TITLE,
                  auh.TRADING_PARTNER_CONTACT_NAME,
                  auh.TRADING_PARTNER_NAME PREPARER_TP_NAME,
                  auh.TRADING_PARTNER_CONTACT_ID,
                  auh.TRADING_PARTNER_ID,
                  fu.user_name,
                  decode(pbh.VENDOR_SITE_CODE, null, '', pbh.VENDOR_SITE_CODE) SUPPLIER_SITE_NAME,
                  pbh.TRADING_PARTNER_NAME BIDDER_TP_NAME,
                  pbh.PUBLISH_DATE BID_PUBLISH_DATE,
                  pbh.TRADING_PARTNER_CONTACT_ID BIDDER_TPC_ID,
                  auh.AUCTION_HEADER_ID
           into  l_doc_number,
                  l_auction_start_date,
                  l_auction_end_date,
                  l_preview_date,
                  l_msg_suffix,
                  l_auction_title,
                  l_auctioneer_user_name,
                  l_preparer_tp_name,
                  l_tp_contact_id,
                  l_trading_partner_id,
                  l_bidder_user_name,
                  l_supplier_site_name,
                  l_bidder_tp_name,
                  l_bid_publish_date,
                  l_bidder_tpc_id,
                  l_auction_header_id
           from pon_auction_headers_all auh,
                  pon_auc_doctypes pad,
                  pon_bid_headers pbh,
                  fnd_user fu
           where pbh.bid_number = p_bid_number
                  AND pad.doctype_id = auh.doctype_id
                  AND auh.auction_header_id = pbh.auction_header_id
                  AND fu.person_party_id = pbh.trading_partner_contact_id
                  AND nvl(fu.end_date, sysdate+1) > sysdate
                  AND rownum = 1;


         END;

         --SLM UI Enhancement
         l_is_slm_doc := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(l_auction_header_id);
         IF l_is_slm_doc = 'Y' THEN

            l_msg_suffix := 'Z';

         END IF;

           l_progress := '010';

           IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                               FND_LOG.string (log_level => FND_LOG.level_procedure,
                                     module => g_module || l_module_name,
                                     message  => 'Entering to Procedure ' || g_module || l_module_name
                                     || ', l_progress = ' || l_progress
                                     || ', l_doc_number           = ' || l_doc_number
                                     || ', l_auction_start_date       = ' || l_auction_start_date
                                     || ', l_auction_end_date     = ' || l_auction_end_date
                                     || ', l_preview_date         = ' || l_preview_date
                                     || ', l_msg_suffix           = ' || l_msg_suffix
                                     || ', l_auction_title            = ' || l_auction_title
                                     || ', l_auctioneer_user_name     = ' || l_auctioneer_user_name
                                     || ', l_bidder_user_name = ' || l_bidder_user_name
                                     || ', l_tp_contact_id        = ' || l_tp_contact_id
                                     || ', l_trading_partner_id       = ' || l_trading_partner_id
                                     || ', l_supplier_site_name = ' || l_supplier_site_name
                                     || ', l_bidder_tp_name = ' || l_bidder_tp_name
                                     || ', l_bid_publish_date = ' || l_bid_publish_date
                                     || ', l_auction_header_id = ' || l_auction_header_id
                                     || ', l_bidder_tpc_id = ' || l_bidder_tpc_id);
           END IF;

           l_progress := '020';

     PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(l_auctioneer_user_name,l_lang_code);

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix ||l_module_name,
            message  => '11. Calling SET_SESSION_LANGUAGE with l_lang_code : ' || l_lang_code);
          END IF; --}
           SET_SESSION_LANGUAGE (null, l_lang_code);

           l_progress := '030';

              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After query execution : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_language_code = ' || l_language_code
                                        || ', l_lang_code = ' || l_lang_code);
              END IF;

          --Subject should be retrieved from seed message

          PON_OEX_TIMEZONE_PKG.CONVERT_DATE_TO_USER_TZ(p_person_party_id => l_tp_contact_id,
                                                       p_auctioneer_user_name => l_auctioneer_user_name,
                                                       x_date_value1  => l_auction_start_date,
                                                       x_date_value2  => l_auction_end_date,
                                                       x_date_value3  => l_preview_date,
                                                       x_date_value4  => l_bid_publish_date,
                                                       x_date_value5  => l_null_date,
                                                       x_timezone_disp =>l_timezone_disp);

          l_progress := '040';

          -- Submitted: <Quote> 4512 for <RFQ> 2759 (Equipment Renewal)

          l_resp_publish_sub :=  PON_AUCTION_PKG.getMessage( msg => 'PON_AUC_RESP_SUBM_NOTIF_SUB',
                                                                 msg_suffix => '_'||l_msg_suffix,
                                                                 token1 => 'RESPONSE_NUMBER',
                                                                 token1_value => p_bid_number,
                                                                 token2 => 'DOC_NUMBER',
                                                                 token2_value => l_doc_number,
                                                                 token3 => 'AUCTION_TITLE',
                                                                 token3_value => replaceHtmlChars(l_auction_title));

          l_progress := '050';


              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After getting new time and subject : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_auction_start_date      = ' || l_auction_start_date
                                        || ', l_auction_end_date        = ' || l_auction_end_date
                                        || ', l_preview_date            = ' || l_preview_date
                                        || ', l_bid_publish_date = ' ||l_bid_publish_date
                                        || ', l_timezone_disp = ' || l_timezone_disp
                                        || ', l_resp_publish_sub = ' || l_resp_publish_sub);
              END IF;

          l_itemtype := 'PONAUCT';
          l_itemkey := p_bid_number ||'-'|| l_bidder_tpc_id;

          l_response_url := pon_wf_utl_pkg.get_dest_page_url (p_dest_func => 'PONRESENQ_VIEWBID'
                                 ,p_notif_performer  => 'BUYER');

          l_response_type_name :=  PON_AUCTION_PKG.getMessage( msg => 'PON_AUCTS_BID',
                                                                 msg_suffix => '_'||l_msg_suffix);

          wf_engine.CreateProcess(itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  process  => 'RESPONSE_PUBLISH');
          l_progress := '060';

              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'After CreateProcess ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_itemtype = ' || l_itemtype
                                        || ', l_itemkey = ' || l_itemkey);
              END IF;

          IF (l_preview_date is not null) THEN
             l_progress := '070';
             wf_engine.SetItemAttrDate (itemtype  => l_itemtype,
                                itemkey  => l_itemkey,
                                aname  => 'PREVIEW_DATE',
                                avalue  => l_preview_date);

             wf_engine.SetItemAttrText (itemtype  => l_itemtype,
                                itemkey  => l_itemkey,
                                aname  => 'TP_TIME_ZONE1',
                                avalue  => l_timezone_disp);

             wf_engine.SetItemAttrText (itemtype  => l_itemtype,
                               itemkey  => l_itemkey,
                               aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                               avalue  => null);
          ELSE
             l_progress := '080';
             wf_engine.SetItemAttrDate (itemtype  => l_itemtype,
                                itemkey  => l_itemkey,
                                aname  => 'PREVIEW_DATE',
                                avalue  => null);

             wf_engine.SetItemAttrText (itemtype  => l_itemtype,
                                 itemkey  => l_itemkey,
                                aname  => 'TP_TIME_ZONE1',
                                 avalue  => null);

            wf_engine.SetItemAttrText (itemtype  => l_itemtype,
                               itemkey  => l_itemkey,
                               aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                               avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));
          END IF;

            l_progress := '090';

            wf_engine.SetItemAttrNumber (itemtype       => l_itemtype,
                                                        itemkey => l_itemkey,
                                                        aname   => 'BID_ID',
                                                        avalue  => p_bid_number);

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'DOC_NUMBER',
                                       avalue     => l_doc_number);

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'TP_TIME_ZONE',
                                       avalue     => l_timezone_disp);

            wf_engine.SetItemAttrDate (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'AUCTION_START_DATE',
                                       avalue     => l_auction_start_date);

            wf_engine.SetItemAttrDate (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'AUCTION_END_DATE',
                                       avalue     => l_auction_end_date);

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'AUCTION_TITLE',
                                       avalue     => l_auction_title);

           /* Set value for Role - PREPARER_TP_CONTACT_NAME,
              this will be set as performer i.e. Notification Recipient
           */
            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'PREPARER_TP_CONTACT_NAME',
                                       avalue     => l_auctioneer_user_name);

            /* Set value for Role - RECIPIENT_ROLE, this will
               be set as HDE_FROM_ID i.e. Notification Sender
            */
      -- Set the sender as the current logged in user
      -- This is so that if a surrogate bid is being created,
      -- then the sender is the buyer creating the surrogate bid

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'RECIPIENT_ROLE',
                                       avalue     => fnd_global.user_name);


            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'PREPARER_TP_NAME',
                                       avalue     => l_preparer_tp_name);

            wf_engine.SetItemAttrDate (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'BID_PUBLISH_DATE',
                                       avalue     => l_bid_publish_date);

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'BIDDER_TP_NAME',
                                       avalue     => l_bidder_tp_name);

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'SUPPLIER_SITE_NAME',
                                       avalue     => l_supplier_site_name);

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'RESP_PUBLISH_SUBJECT',
                                       avalue     => l_resp_publish_sub);

             wf_engine.SetItemAttrText (itemtype  => l_itemtype,
                                itemkey  => l_itemkey,
                                aname  => 'RESPONSE_TYPE',
                                avalue  => l_response_type_name);

             wf_engine.SetItemAttrText (itemtype  => l_itemtype,
                                itemkey  => l_itemkey,
                                aname  => 'RESPONSE_URL',
                                avalue  => l_response_url);

            wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'AUCTION_ID',
                                       avalue     => l_auction_header_id);


            --SLM UI Enhancement
            PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(l_itemtype, l_itemkey, l_auction_header_id);

    -- Bug 4295915: Set the  workflow owner
            wf_engine.SetItemOwner(itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   owner    => fnd_global.user_name);

            l_progress := '100';

            wf_engine.StartProcess(itemtype => l_itemtype,
                                   itemkey  => l_itemkey );


            l_progress := 'END';

            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                         FND_LOG.string (log_level => FND_LOG.level_procedure,
                                      module => g_module || l_module_name,
                                       message  => 'Procedure Ends ' || g_module || l_module_name
                                      || ', l_progress = ' || l_progress);
            END IF;

            UNSET_SESSION_LANGUAGE;

        EXCEPTION WHEN OTHERS THEN
            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                                        FND_LOG.string (log_level => FND_LOG.level_procedure,
                                        module => g_module || l_module_name,
                                        message  => 'In Exception Block : ' || g_module || l_module_name
                                        || ', l_progress = ' || l_progress
                                        || ', l_auction_header_id = ' || l_auction_header_id);
            END IF;
            UNSET_SESSION_LANGUAGE;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END;

END SEND_RESP_NOTIF;

/*=========================================================================+
-- 12.0 Enhancement
-- SEND_MSG_SENT_NOTIF procedure will be responsible for
-- sending notification to the Buyer when a Seller sends
-- a message to Buyer or a Buyer sends an internal message
-- to other Collaboration Team Members
-- Parameter :
--          p_toFirstName       IN VARCHAR2
--          p_toLastName        IN VARCHAR2
--          p_toCompanyName     IN VARCHAR2
--          p_toCompanyId       IN NUMBER
--          p_fromFirstName     IN VARCHAR2
--          p_fromLastName      IN VARCHAR2
--          p_fromCompanyName   IN VARCHAR2
--          p_fromCompanyId     IN NUMBER
--          p_creatorCompanyId  IN NUMBER
--          p_userPartyId       IN NUMBER
--          p_entryid           IN NUMBER
--          p_message_type      IN VARCHAR2
--          x_return_status     OUT NOCOPY VARCHAR2
--
+=========================================================================*/

PROCEDURE SEND_MSG_SENT_NOTIF(
          p_toFirstName      IN VARCHAR2,
          p_toLastName       IN VARCHAR2,
          p_toCompanyName    IN VARCHAR2,
          p_toCompanyId      IN NUMBER,
          p_fromFirstName    IN VARCHAR2,
          p_fromLastName     IN VARCHAR2,
          p_fromCompanyName  IN VARCHAR2,
          p_fromCompanyId    IN NUMBER,
          p_creatorCompanyId IN NUMBER,
          p_userPartyId      IN NUMBER,
          p_entryid          IN NUMBER,
          p_message_type     IN VARCHAR2,
          x_return_status    OUT NOCOPY VARCHAR2
        )
IS  -- {

    l_module_name CONSTANT   VARCHAR2(40) := 'SEND_MSG_SENT_NOTIF';
    l_progress               VARCHAR2(3);
    l_language               VARCHAR2(60);
    l_lang_code              VARCHAR2(30);
    l_doc_number             PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
    l_auction_header_id      PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID%TYPE;
    l_auction_start_date     DATE;
    l_auction_end_date       DATE;
    l_preview_date           DATE;
    l_msg_sent_date          DATE;
    l_null_date              DATE;
    l_msg_suffix             PON_AUC_DOCTYPES.MESSAGE_SUFFIX%TYPE;
    l_auction_title          PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
    l_subject                PON_THREADS.SUBJECT%TYPE;
    l_content                PON_THREAD_ENTRIES.CONTENT%TYPE;
    l_sender_name            VARCHAR2(350);
    l_recipient_name         VARCHAR2(350);
    l_preparer_tp_name       HZ_PARTIES.PARTY_NAME%TYPE;
    l_task_name              PON_NEG_TEAM_MEMBERS.TASK_NAME%TYPE;
    l_task_target_date       DATE;
    l_task_assignment_date   DATE;
    l_msg_sent_subject       VARCHAR2(2000);
    l_timezone_disp          VARCHAR2(240);
    l_timezone_disp1         VARCHAR2(240);
    l_timezone_nodisp        VARCHAR2(240);
    l_auctioneer_user_name   VARCHAR2(244);
    l_auctioneer_tpc_id      NUMBER;
    l_person_party_id        NUMBER;
    l_sequence               NUMBER;
    l_itemtype               VARCHAR2(7);
    l_itemkey               VARCHAR2(50);
    l_user_id                NUMBER;
    l_user_name              FND_USER.USER_NAME%TYPE;
    l_sender_user            FND_USER.USER_NAME%TYPE;
    l_from_id                NUMBER;
    l_from_company_id        NUMBER;
    l_page_url               VARCHAR2(500);
    l_discussion_id          NUMBER;
    l_is_sealed_neg          VARCHAR2(1);
    l_notif_performer        VARCHAR2(10); -- BUYER or SUPPLIER
    l_staggered_cls_intrvl   NUMBER;
    l_open_auction_now_flag VARCHAR2(1);
    l_publish_auction_now_flag   VARCHAR2(1);

    --SLM UI Enhancement
    l_is_slm_document VARCHAR2(1);


    CURSOR INT_MEMBERS (p_sender_id               NUMBER,
                        p_auction_header_id       NUMBER,
                        p_discussion_id           NUMBER)
    IS
        SELECT
                hz.party_id TO_PARTY_ID,
                PON_LOCALE_PKG.get_party_display_name(hz.party_id,2, userenv('LANG')) TO_PARTY_NAME,
                hz.person_first_name FIRST_NAME,
                hz.person_last_name LAST_NAME
        FROM pon_neg_team_members  pntm,
                  HZ_PARTIES hz,
                  fnd_user fu
        WHERE hz.party_id=fu.person_party_id
        AND nvl(fu.end_date,sysdate+1) > sysdate
        AND fu.user_id=pntm.user_id
        AND fu.person_party_id <> p_sender_id
        AND pntm.auction_header_id = p_auction_header_id
        UNION
        SELECT
                distinct pte.from_id TO_PARTY_ID,
                PON_LOCALE_PKG.get_party_display_name(pte.from_id,2, userenv('LANG'))  TO_PARTY_NAME,
                pte.from_first_name FIRST_NAME, pte.from_last_name LAST_NAME
        FROM pon_threads pt,
                  pon_thread_entries pte
        WHERE pt.discussion_id = p_discussion_id
        AND pt.discussion_id = pte.discussion_id
        AND pt.thread_number = pte.thread_number
        AND pte.from_id <> p_sender_id
        AND pte.vendor_id is null;

   CURSOR EXT_MEMBER (p_auction_header_id       NUMBER,
                      p_discussion_id           NUMBER,
                      p_auctioneer_tpc_id       NUMBER)
   IS
      SELECT DISTINCT
        PBP.TRADING_PARTNER_CONTACT_ID TO_PARTY_ID,
        PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(PBP.TRADING_PARTNER_CONTACT_ID, 2 , USERENV('LANG'))||' - '||NVL(HZ.PARTY_NAME,'')  TO_PARTY_NAME,
        HZ1.PERSON_FIRST_NAME FIRST_NAME,
        HZ1.PERSON_LAST_NAME LAST_NAME,
        HZ.PARTY_ID COMPANY_ID,
        HZ.PARTY_NAME COMPANY_NAME
      FROM PON_BIDDING_PARTIES PBP,
        HZ_PARTIES HZ,
        HZ_PARTIES HZ1
      WHERE PBP.AUCTION_HEADER_ID = p_auction_header_id
        AND HZ.PARTY_ID=PBP.TRADING_PARTNER_ID
        AND HZ1.PARTY_ID= PBP.TRADING_PARTNER_CONTACT_ID
      UNION
      SELECT DISTINCT
        PBH.TRADING_PARTNER_CONTACT_ID TO_PARTY_ID,
        PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(PBH.TRADING_PARTNER_CONTACT_ID,2,USERENV('LANG'))||' - '||NVL(HZ.PARTY_NAME,'')  TO_PARTY_NAME,
        HZ1.PERSON_FIRST_NAME FIRST_NAME,
        HZ1.PERSON_LAST_NAME LAST_NAME,
        HZ.PARTY_ID COMPANY_ID,
        HZ.PARTY_NAME COMPANY_NAME
      FROM PON_BID_HEADERS PBH,
        HZ_PARTIES HZ,
        HZ_PARTIES HZ1
      WHERE PBH.AUCTION_HEADER_ID = p_auction_header_id
        AND HZ.PARTY_ID=PBH.TRADING_PARTNER_ID
        AND HZ1.PARTY_ID=PBH.TRADING_PARTNER_CONTACT_ID
        AND PBH.BID_STATUS NOT IN ('ARCHIVED','DISQUALIFIED')
        AND ( EXISTS (SELECT 1 FROM fnd_user fu WHERE
        fu.person_party_id = PBH.TRADING_PARTNER_CONTACT_ID
        AND Nvl(fu.end_date,sysdate) >=SYSDATE ) )
      UNION
      SELECT DISTINCT
        PTE.FROM_ID TO_PARTY_ID,
        PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(PTE.FROM_ID, 2,USERENV('LANG')) ||' - '||NVL(PTE.FROM_COMPANY_NAME,'')  TO_PARTY_NAME,
        PTE.FROM_FIRST_NAME FIRST_NAME,
        PTE.FROM_LAST_NAME LAST_NAME,
        PTE.FROM_COMPANY_ID COMPANY_ID,
        PTE.FROM_COMPANY_NAME COMPANY_NAME
      FROM PON_THREADS PT,
        PON_THREAD_ENTRIES PTE,
        PON_TE_RECIPIENTS PTR
      WHERE PT.DISCUSSION_ID = p_discussion_id
        AND PT.DISCUSSION_ID = PTE.DISCUSSION_ID
        AND PT.THREAD_NUMBER = PTE.THREAD_NUMBER
        AND PTE.ENTRY_ID = PTR.ENTRY_ID
        AND PTR.TO_ID = p_auctioneer_tpc_id
        AND PTE.VENDOR_ID IS NOT NULL;


            CURSOR SCORING_MEMBERS (p_sender_id               NUMBER,
                                p_auction_header_id       NUMBER,
                                p_team_id                        NUMBER)
            IS
                SELECT
                        hz.party_id TO_PARTY_ID,
                        PON_LOCALE_PKG.get_party_display_name(hz.party_id,2, userenv('LANG')) TO_PARTY_NAME,
                        hz.person_first_name FIRST_NAME,
                        hz.person_last_name LAST_NAME
                FROM pon_scoring_team_members  pntm,
                          HZ_PARTIES hz,
                          fnd_user fu
                WHERE hz.party_id=fu.person_party_id
                AND fu.user_id=pntm.user_id
                AND nvl(fu.end_date,sysdate+1) > sysdate
                AND fu.person_party_id <> p_sender_id
                AND pntm.auction_header_id = p_auction_header_id
                AND pntm.team_id = p_team_id;

            CURSOR ALL_SCORING_MEMBERS (p_sender_id               NUMBER,
                                p_auction_header_id       NUMBER)
            IS
                SELECT  distinct
                        hz.party_id TO_PARTY_ID,
                        PON_LOCALE_PKG.get_party_display_name(hz.party_id,2, userenv('LANG')) TO_PARTY_NAME,
                        hz.person_first_name FIRST_NAME,
                        hz.person_last_name LAST_NAME
                FROM pon_scoring_team_members  pntm,
                          HZ_PARTIES hz,
                          fnd_user fu
                WHERE hz.party_id=fu.person_party_id
                AND fu.user_id=pntm.user_id
                AND nvl(fu.end_date,sysdate+1) > sysdate
                AND fu.person_party_id <> p_sender_id
                AND pntm.auction_header_id = p_auction_header_id;

            CURSOR EVALUATION_MEMBERS (p_sender_id               NUMBER,
                                p_auction_header_id       NUMBER,
                                p_team_id                        NUMBER)
            IS
                SELECT
                        hz.party_id TO_PARTY_ID,
                        PON_LOCALE_PKG.get_party_display_name(hz.party_id,2, userenv('LANG')) TO_PARTY_NAME,
                        hz.person_first_name FIRST_NAME,
                        hz.person_last_name LAST_NAME
                FROM PON_EVALUATION_TEAM_MEMBERS  pntm,
                          HZ_PARTIES hz,
                          fnd_user fu
                WHERE hz.party_id=fu.person_party_id
                AND fu.user_id=pntm.user_id
                AND nvl(fu.end_date,sysdate+1) > sysdate
                AND fu.person_party_id <> p_sender_id
                AND pntm.auction_header_id = p_auction_header_id
                AND pntm.team_id = p_team_id;
            CURSOR ALL_EVALUATION_MEMBERS (p_sender_id               NUMBER,
                                p_auction_header_id       NUMBER)
            IS
                SELECT  distinct
                        hz.party_id TO_PARTY_ID,
                        PON_LOCALE_PKG.get_party_display_name(hz.party_id,2, userenv('LANG')) TO_PARTY_NAME,
                        hz.person_first_name FIRST_NAME,
                        hz.person_last_name LAST_NAME
                FROM PON_EVALUATION_TEAM_MEMBERS  pntm,
                          HZ_PARTIES hz,
                          fnd_user fu
                WHERE hz.party_id=fu.person_party_id
                AND fu.user_id=pntm.user_id
                AND nvl(fu.end_date,sysdate+1) > sysdate
                AND fu.person_party_id <> p_sender_id
                AND pntm.auction_header_id = p_auction_header_id;
            CURSOR GROUP_MEMBERS (p_sender_id NUMBER,
                                  p_entryId   NUMBER)
            IS
                SELECT ptr.to_id TO_PARTY_ID,
                       PON_LOCALE_PKG.get_party_display_name(ptr.to_id,2, userenv('LANG')) TO_PARTY_NAME,
                       ptr.to_first_name FIRST_NAME,
                       ptr.to_last_name LAST_NAME
                FROM pon_te_recipients ptr
                WHERE ptr.entry_id = p_entryId
                  AND ptr.to_id <> p_sender_id;


      --}

BEGIN --{
       x_return_status := FND_API.G_RET_STS_ERROR;

        l_progress := '000';
        l_null_date := null;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                      FND_LOG.string (log_level => FND_LOG.level_procedure,
                                   module => g_module || l_module_name,
                                   message  => 'Entering to Procedure ' || g_module || l_module_name
                                   || ', l_progress = ' || l_progress
                                   || ', p_entryid = ' || p_entryid
                                   || ', p_toFirstName = ' ||   p_toFirstName
                                   || ', p_toLastName = ' ||  p_toLastName
                                   || ', p_toCompanyName = ' || p_toCompanyName
                                   || ', p_toCompanyId  = ' || p_toCompanyId
                                   || ', p_fromFirstName = ' || p_fromFirstName
                                   || ', p_fromLastName = ' || p_fromLastName
                                   || ', p_fromCompanyName = ' || p_fromCompanyName
                                   || ', p_fromCompanyId = ' || p_fromCompanyId
                                   || ', p_creatorCompanyId = ' ||  p_creatorCompanyId
                                   || ', p_userPartyId = ' || p_userPartyId
                                   || ', p_entryid = ' || p_entryid  );
         END IF;

           l_progress := '001';
           SELECT
                auh.DOCUMENT_NUMBER,
                auh.AUCTION_HEADER_ID,
                auh.OPEN_BIDDING_DATE,
                auh.CLOSE_BIDDING_DATE,
                auh.VIEW_BY_DATE,
                pad.MESSAGE_SUFFIX,
                auh.AUCTION_TITLE,
                auh.TRADING_PARTNER_CONTACT_NAME,
                auh.TRADING_PARTNER_CONTACT_ID,
                auh.STAGGERED_CLOSING_INTERVAL,
                decode(nvl(auh.bid_visibility_code,'N'),
                          'SEALED_AUCTION','Y',
                                           'N'),
                SYSDATE,
                pt.SUBJECT,
                pte.content,
                pte.FROM_ID,
                pte.FROM_COMPANY_ID,
                pd.discussion_id,
                open_auction_now_flag,
                publish_auction_now_flag
            INTO
                  l_doc_number,
                  l_auction_header_id,
                  l_auction_start_date,
                  l_auction_end_date,
                  l_preview_date,
                  l_msg_suffix,
                  l_auction_title,
                  l_auctioneer_user_name,
                  l_auctioneer_tpc_id,
                  l_staggered_cls_intrvl,
                  l_is_sealed_neg,
                  l_msg_sent_date,
                  l_subject,
                  l_content,
                  l_from_id,
                  l_from_company_id,
                  l_discussion_id,
                  l_open_auction_now_flag ,
                  l_publish_auction_now_flag
            FROM pon_auction_headers_all auh,
                pon_auc_doctypes pad,
                pon_thread_entries pte,
                pon_threads pt,
                pon_discussions pd
            WHERE pte.entry_id = p_entryid
                AND pd.discussion_id = pte.discussion_id
                AND pt.discussion_id = pte.discussion_id
                AND pt.thread_number = pte.thread_number
                AND auh.auction_header_id = pd.pk1_value
                AND pad.doctype_id = auh.doctype_id;

          l_progress := '002';
          IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                      FND_LOG.string (log_level => FND_LOG.level_procedure,
                                   module => g_module || l_module_name,
                                   message  => 'Negotiation Data retrieved for Document Number: ' || l_doc_number);
          END IF;

          --SLM UI Enhancement
          l_is_slm_document := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(l_auction_header_id);
          IF l_is_slm_document = 'Y' THEN

            l_msg_suffix := 'Z';

          END IF;

          IF (p_toCompanyId = 0 ) THEN --{
                --
                -- Group Message / Multiselect Case
                --

                l_progress := '020';

                IF ('EXTERNAL' = p_message_type) THEN
                    l_notif_performer := 'SUPPLIER';
                ELSE
                    l_notif_performer := 'BUYER';
                END IF;


                FOR member IN  GROUP_MEMBERS(l_from_id, p_entryid)
                LOOP
                --{
                               NOTIFY_MEMBER(   p_userPartyId                => member.to_party_id,
                                                p_auctioneer_user_name       => l_auctioneer_user_name,
                                                p_auction_start_date         => l_auction_start_date,
                                                p_auction_end_date           => l_auction_end_date,
                                                p_preview_date               => l_preview_date,
                                                p_msg_sent_date              => l_msg_sent_date,
                                                p_msg_suffix                 => l_msg_suffix,
                                                p_doc_number                 => l_doc_number,
                                                p_auction_title              => l_auction_title,
                                                p_entryid                    => p_entryid,
                                                p_auction_header_id          => l_auction_header_id,
                                                p_fromFirstName              => p_fromFirstName,
                                                p_fromLastName               => p_fromLastName,
                                                p_from_id                    => l_from_id,
                                                p_notif_performer            => l_notif_performer,
                                                p_subject                    => l_subject,
                                                p_content                    => l_content,
                                                p_message_type               => p_message_type,
                                                p_fromCompanyName            => p_fromCompanyName,
                                                p_discussion_id              => l_discussion_id,
                                                p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                p_open_auction_now_flag      => l_open_auction_now_flag,
                                                p_publish_auction_now_flag   => l_publish_auction_now_flag);
                --}
                END LOOP;

          -- } End of If it is group / multiSelect message
          --
          --  If it is a point to point message then we need to send the notification
          --  to the Recipient of the message only
          --
          ELSIF (p_toCompanyId > 0 ) THEN --{
                --
                -- Point to point messaging
                --

                l_progress := '030';
                IF ( p_creatorCompanyId = l_from_company_id ) THEN
                     -- bug 6471818 ,17326048 fix
					 IF ( 'EXTERNAL' = p_message_type ) THEN
						l_notif_performer := 'SUPPLIER';
					 ELSE
						l_notif_performer := 'BUYER';
					 END IF;
                ELSE
                    l_notif_performer := 'BUYER';
                END IF;

                IF ('EXTERNAL' = p_message_type AND p_creatorCompanyId = l_from_company_id) THEN
                    --
                    -- So, this is a message to Supplier hence make the From
                    -- id to that of the Negotiation Creator
                    --
                    l_from_id := l_auctioneer_tpc_id;

                END IF;

                NOTIFY_MEMBER(                  p_userPartyId                => p_userPartyId,
                                                p_auctioneer_user_name       => l_auctioneer_user_name,
                                                p_auction_start_date         => l_auction_start_date,
                                                p_auction_end_date           => l_auction_end_date,
                                                p_preview_date               => l_preview_date,
                                                p_msg_sent_date              => l_msg_sent_date,
                                                p_msg_suffix                 => l_msg_suffix,
                                                p_doc_number                 => l_doc_number,
                                                p_auction_title              => l_auction_title,
                                                p_entryid                    => p_entryid,
                                                p_auction_header_id          => l_auction_header_id,
                                                p_fromFirstName              => p_fromFirstName,
                                                p_fromLastName               => p_fromLastName,
                                                p_from_id                    => l_from_id,
                                                p_notif_performer            => l_notif_performer,
                                                p_subject                    => l_subject,
                                                p_content                    => l_content,
                                                p_message_type               => p_message_type,
                                                p_fromCompanyName            => p_fromCompanyName,
                                                p_discussion_id              => l_discussion_id,
                                                p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                p_open_auction_now_flag      => l_open_auction_now_flag,
                                                p_publish_auction_now_flag   => l_publish_auction_now_flag);

          -- } End of If it is not a broadcast msg
          --
          -- The next block is meant for - Sealed Negotiation
          --                               And External Broadcast
          --                               And Seller initiated message
          -- Then only Buyer will get a notification from the seller
          -- and other sellers will NOT get any notification to protect
          -- the seller's identity
          --
          ELSIF ('Y' = l_is_sealed_neg
                 AND 'EXTERNAL' = p_message_type
                 AND p_toCompanyId < 0
                 AND p_creatorCompanyId <> l_from_company_id) THEN --{

                --
                -- It is the case of Sealed  External Broadcast
                -- where we will be sending point to point notification
                -- It will be always a Seller to Buyer notification
                --

                l_progress := '040';

                l_notif_performer := 'BUYER'; -- As Buyer is the only reciever of this notification

                NOTIFY_MEMBER(                  p_userPartyId                => l_auctioneer_tpc_id,
                                                p_auctioneer_user_name       => l_auctioneer_user_name,
                                                p_auction_start_date         => l_auction_start_date,
                                                p_auction_end_date           => l_auction_end_date,
                                                p_preview_date               => l_preview_date,
                                                p_msg_sent_date              => l_msg_sent_date,
                                                p_msg_suffix                 => l_msg_suffix,
                                                p_doc_number                 => l_doc_number,
                                                p_auction_title              => l_auction_title,
                                                p_entryid                    => p_entryid,
                                                p_auction_header_id          => l_auction_header_id,
                                                p_fromFirstName              => p_fromFirstName,
                                                p_fromLastName               => p_fromLastName,
                                                p_from_id                    => l_from_id,
                                                p_notif_performer            => l_notif_performer,
                                                p_subject                    => l_subject,
                                                p_content                    => l_content,
                                                p_message_type               => p_message_type,
                                                p_fromCompanyName            => p_fromCompanyName,
                                                p_discussion_id              => l_discussion_id,
                                                p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                p_open_auction_now_flag      => l_open_auction_now_flag,
                                                p_publish_auction_now_flag   => l_publish_auction_now_flag);


          ELSE  --} End of If it is not a Selaed broadcast msg
          --{
                --
                -- Broadcast messaging
                --
                l_progress := '050';
                --
                -- Check if it is the internal broadcast
                --
                IF ('INTERNAL' = p_message_type ) THEN --{
                        --
                        -- Get the list of the team members and post them the
                        -- notifications
                        --
                        l_progress := '060';

                        l_notif_performer := 'BUYER'; -- As Buyer users are the only recievers of this notification

      --
      -- Now this broadcast can be three simple varieties namely -
      --  All Team Members Broadcast          (p_toCompanyId = -2)
      --  All Scoring Team Members Broadcast  (p_toCompanyId = -3)
      --   Specific Scoring Team Broadcast     (p_toCompanyId = -X), where X is the Scoring Team Id
      --  All Evaluation Team Members Broadcast  (p_toCompanyId = -4)
      -- We, need handle those cases in the following if else blocks
      --

                        IF  (p_toCompanyId = -2) THEN  --{

                                l_progress := '062';

                          FOR member IN  INT_MEMBERS (l_from_id, l_auction_header_id,l_discussion_id)
                          LOOP
                          --{

                                NOTIFY_MEMBER(  p_userPartyId                => member.to_party_id,
                                                    p_auctioneer_user_name       => l_auctioneer_user_name,
                                                    p_auction_start_date         => l_auction_start_date,
                                                    p_auction_end_date           => l_auction_end_date,
                                                    p_preview_date               => l_preview_date,
                                                    p_msg_sent_date              => l_msg_sent_date,
                                                    p_msg_suffix                 => l_msg_suffix,
                                                    p_doc_number                 => l_doc_number,
                                                    p_auction_title              => l_auction_title,
                                                    p_entryid                    => p_entryid,
                                                    p_auction_header_id          => l_auction_header_id,
                                                    p_fromFirstName              => p_fromFirstName,
                                                    p_fromLastName               => p_fromLastName,
                                                    p_from_id                    => l_from_id,
                                                    p_notif_performer            => l_notif_performer,
                                                    p_subject                    => l_subject,
                                                    p_content                    => l_content,
                                                    p_message_type               => p_message_type,
                                                    p_fromCompanyName            => p_fromCompanyName,
                                                    p_discussion_id              => l_discussion_id,
                                                    p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                    p_open_auction_now_flag      => l_open_auction_now_flag,
                                                    p_publish_auction_now_flag   => l_publish_auction_now_flag);

                          --}
                          END LOOP;
      --}
                        ELSIF (p_toCompanyId = -3) THEN --{

        l_progress := '065';

        FOR member IN  ALL_SCORING_MEMBERS (l_from_id, l_auction_header_id)
                                LOOP
                                --{

                                        NOTIFY_MEMBER(      p_userPartyId                => member.to_party_id,
                                                            p_auctioneer_user_name       => l_auctioneer_user_name,
                                                            p_auction_start_date         => l_auction_start_date,
                                                            p_auction_end_date           => l_auction_end_date,
                                                            p_preview_date               => l_preview_date,
                                                            p_msg_sent_date              => l_msg_sent_date,
                                                            p_msg_suffix                 => l_msg_suffix,
                                                            p_doc_number                 => l_doc_number,
                                                            p_auction_title              => l_auction_title,
                                                            p_entryid                    => p_entryid,
                                                            p_auction_header_id          => l_auction_header_id,
                                                            p_fromFirstName              => p_fromFirstName,
                                                            p_fromLastName               => p_fromLastName,
                                                            p_from_id                    => l_from_id,
                                                            p_notif_performer            => l_notif_performer,
                                                            p_subject                    => l_subject,
                                                            p_content                    => l_content,
                                                            p_message_type               => p_message_type,
                                                            p_fromCompanyName            => p_fromCompanyName,
                                                            p_discussion_id              => l_discussion_id,
                                                            p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                            p_open_auction_now_flag      => l_open_auction_now_flag,
                                                            p_publish_auction_now_flag   => l_publish_auction_now_flag);

                                --}
                                END LOOP;

      --}
                        ELSIF (p_toCompanyId = -4) THEN --{
                            l_progress := '069';
                            FOR member IN  ALL_EVALUATION_MEMBERS (l_from_id, l_auction_header_id)
                                LOOP
                                --{
                                        NOTIFY_MEMBER(      p_userPartyId                => member.to_party_id,
                                                            p_auctioneer_user_name       => l_auctioneer_user_name,
                                                            p_auction_start_date         => l_auction_start_date,
                                                            p_auction_end_date           => l_auction_end_date,
                                                            p_preview_date               => l_preview_date,
                                                            p_msg_sent_date              => l_msg_sent_date,
                                                            p_msg_suffix                 => l_msg_suffix,
                                                            p_doc_number                 => l_doc_number,
                                                            p_auction_title              => l_auction_title,
                                                            p_entryid                    => p_entryid,
                                                            p_auction_header_id          => l_auction_header_id,
                                                            p_fromFirstName              => p_fromFirstName,
                                                            p_fromLastName               => p_fromLastName,
                                                            p_from_id                    => l_from_id,
                                                            p_notif_performer            => l_notif_performer,
                                                            p_subject                    => l_subject,
                                                            p_content                    => l_content,
                                                            p_message_type               => p_message_type,
                                                            p_fromCompanyName            => p_fromCompanyName,
                                                            p_discussion_id              => l_discussion_id,
                                                            p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                            p_open_auction_now_flag      => l_open_auction_now_flag,
                                                            p_publish_auction_now_flag   => l_publish_auction_now_flag);
                                --}
                                END LOOP;
      --}
      ELSIF (p_toCompanyId < -3) THEN --{

        l_progress := '067';

             FOR member IN  SCORING_MEMBERS (l_from_id, l_auction_header_id, -1*p_toCompanyId)
                                LOOP
                                --{

                                        NOTIFY_MEMBER(      p_userPartyId                => member.to_party_id,
                                                            p_auctioneer_user_name       => l_auctioneer_user_name,
                                                            p_auction_start_date         => l_auction_start_date,
                                                            p_auction_end_date           => l_auction_end_date,
                                                            p_preview_date               => l_preview_date,
                                                            p_msg_sent_date              => l_msg_sent_date,
                                                            p_msg_suffix                 => l_msg_suffix,
                                                            p_doc_number                 => l_doc_number,
                                                            p_auction_title              => l_auction_title,
                                                            p_entryid                    => p_entryid,
                                                            p_auction_header_id          => l_auction_header_id,
                                                            p_fromFirstName              => p_fromFirstName,
                                                            p_fromLastName               => p_fromLastName,
                                                            p_from_id                    => l_from_id,
                                                            p_notif_performer            => l_notif_performer,
                                                            p_subject                    => l_subject,
                                                            p_content                    => l_content,
                                                            p_message_type               => p_message_type,
                                                            p_fromCompanyName            => p_fromCompanyName,
                                                            p_discussion_id              => l_discussion_id,
                                                              p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                            p_open_auction_now_flag      => l_open_auction_now_flag,
                                                            p_publish_auction_now_flag   => l_publish_auction_now_flag);

                                --}
                                END LOOP;

      --}
      END IF;
         --}
                ELSIF ('EXTERNAL' = p_message_type ) THEN --{
                        --
                        -- So, it is an external broadcast
                        --

                        l_notif_performer := 'SUPPLIER'; -- As Supplier users are the only recievers of this notification

                        l_progress := '070';

                        FOR member IN  EXT_MEMBER (l_auction_header_id,l_discussion_id, l_from_id)
                        LOOP
                        --{

                            NOTIFY_MEMBER(      p_userPartyId                => member.to_party_id,
                                                p_auctioneer_user_name       => l_auctioneer_user_name,
                                                p_auction_start_date         => l_auction_start_date,
                                                p_auction_end_date           => l_auction_end_date,
                                                p_preview_date               => l_preview_date,
                                                p_msg_sent_date              => l_msg_sent_date,
                                                p_msg_suffix                 => l_msg_suffix,
                                                p_doc_number                 => l_doc_number,
                                                p_auction_title              => l_auction_title,
                                                p_entryid                    => p_entryid,
                                                p_auction_header_id          => l_auction_header_id,
                                                p_fromFirstName              => p_fromFirstName,
                                                p_fromLastName               => p_fromLastName,
                                                p_from_id                    => l_from_id,
                                                p_notif_performer            => l_notif_performer,
                                                p_subject                    => l_subject,
                                                p_content                    => l_content,
                                                p_message_type               => p_message_type,
                                                p_fromCompanyName            => p_fromCompanyName,
                                                p_discussion_id              => l_discussion_id,
                                                p_stagger_closing_interval   => l_staggered_cls_intrvl,
                                                p_open_auction_now_flag      => l_open_auction_now_flag,
                                                p_publish_auction_now_flag   => l_publish_auction_now_flag);

                        --}
                        END LOOP;
                END IF;
                --}
          END IF;
          --}

          l_progress := '090';

          x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
      WHEN OTHERS THEN
           WF_CORE.CONTEXT ('PONAUCT','SEND_MSG_SENT_NOTIF','Process:'||l_progress||'SQL error:' || sqlcode|| ', error message:' ||substr(sqlerrm,1,512));
           RAISE;

END SEND_MSG_SENT_NOTIF;  -- }

/*=========================================================================+
--
-- 12.0 Enhancement
-- IS_NOTIF_SUBSCRIBED  is a wrapper over the GET_NOTIF_PREFERENCE
-- of PON_WF_UTL_PKG. It will call the procedure GET_NOTIF_PREFERENCE with
-- appropriate message type and auction header id.
--
-- Parameter :
--             itemtype  IN VARCHAR2
--             itemkey   IN VARCHAR2
--             actid     IN NUMBER
--         funcmode  IN VARCHAR2
--         resultout OUT NOCOPY VARCHAR2
--
+=========================================================================*/


PROCEDURE IS_NOTIF_SUBSCRIBED(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2)
IS
     l_negotiation_id   NUMBER;
     l_wf_message_name  VARCHAR2(100);
     l_tp_type          VARCHAR2(20); -- TO indicate if it is a buyer or a seller
     l_module_name      CONSTANT VARCHAR2(30) := 'IS_NOTIF_SUBSCRIBED';
     l_change_type      NUMBER;
     l_is_event_auction VARCHAR2(1);
     l_notif_group_type VARCHAR(30);  -- Bug 8992789

BEGIN --{
          --
          -- Get the auction_header_id depending on the different itemtype possible
          --
          IF (itemtype = 'PONAPPRV' OR itemtype = 'PONAWAPR') THEN
                l_negotiation_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                                 itemkey  => itemkey,
                                                                 aname    => 'AUCTION_HEADER_ID');
          ELSE
                l_negotiation_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                                 itemkey  => itemkey,
                                                                 aname    => 'AUCTION_ID');
          END IF;

          --
          -- Get the Function Attribute for this call. It will pass the
          -- WF_MESSAGE_NAME attribute associated with a notification
          --
    l_wf_message_name := Wf_Engine.GetActivityAttrText( itemtype,
                    itemkey,
                    actid,
                    'PON_WF_MESSAGE_NAME');


    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module || l_module_name,
      message  => 'In ' || g_module || l_module_name
            || ', itemtype = ' || itemtype
            || ', itemkey = ' || itemkey
            || ', actid = ' || actid
            || ', funcmode = ' || funcmode
            || ', resultout = ' || resultout
            || ', l_negotiation_id = ' || l_negotiation_id
            || ', l_wf_message_name = ' || l_wf_message_name);
    END IF;

          --
          -- CLOSECHANGED Block, responsible for finding the exact message name for
          -- CLOSECHANGED process. The process starts with a different message name and
          -- can change the message name as the workflow progresses
          --
          IF (l_wf_message_name= 'CLOSECHANGED') THEN
              BEGIN
                   l_change_type := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                                 itemkey  => itemkey,
                                                                 aname => 'CHANGE_TYPE');
              EXCEPTION
                   WHEN OTHERS THEN
                       l_change_type := 1; -- for auctions created before version 115.20 of ponwfau1.wft this attribute did not exist
              END;


              IF (l_change_type = 1) THEN
                    --
                    -- auctioneer has extended the auction
                    --
                    l_wf_message_name := 'NEGOTIATION_EXTENDED';
              ELSE
                     --
                     -- auctioneer has shortened the auction
                     --
                    l_wf_message_name := 'NEGOTIATION_SHORTENED';
              END IF;
          END IF; -- END OF CLOSECHANGED Block

          --
          -- CALCEL Block
          --

          IF (l_wf_message_name = 'CANCEL') THEN
            l_is_event_auction := IS_EVENT_AUCTION(l_negotiation_id);

            IF (l_is_event_auction = 'Y') THEN
               l_wf_message_name := 'NEGOTIATION_CANCELED_EVENT';
            ELSE
               l_wf_message_name := 'NEGOTIATION_CANCELED';
            END IF;

          END IF;  -- END OF CANCEL Block

          --
          -- Online Discussion Message Sent Block
          --

          IF (l_wf_message_name = 'DISCUSSIONMESSAGE') THEN

            l_tp_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'TRADING_PARTNER_TYPE');

            IF (l_tp_type = 'BUYER') THEN
               l_wf_message_name := 'BUYER_DISC_MESSAGE_SENT_MSG';
            ELSE
               l_wf_message_name := 'SUPPLIER_DISC_MESSAGE_SENT_MSG';
            END IF;

          END IF;  -- END of Disc. Meg Sent Block

   -- Begin Bug 8992789
   IF (IS_INTERNAL_ONLY(l_negotiation_id)) THEN

     SELECT notifGroups.notif_group_type
     INTO l_notif_group_type
     FROM PON_NOTIF_SUBSCRIPTION_GROUPS notifGroups,
          PON_NOTIF_GROUP_MEMBERS notifMessages
     WHERE notifGroups.NOTIF_GROUP_CODE = notifMessages.NOTIF_GROUP_CODE
       AND notifMessages.NOTIF_MESSAGE_NAME = l_wf_message_name;

     IF (l_notif_group_type = 'TO_SUPPLIER') THEN
       resultout := 'N';
       RETURN;
     END IF;

   END IF;
   -- End Bug 8992789

   resultout := PON_WF_UTL_PKG.GET_NOTIF_PREFERENCE(l_wf_message_name,l_negotiation_id);

EXCEPTION  --}
      WHEN OTHERS THEN
              resultout := PON_WF_UTL_PKG.G_NO;
              IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_procedure,
          module => g_module || l_module_name,
          message  => 'Exception Block ' || g_module || l_module_name
           || ', l_negotiation_id = ' || l_negotiation_id
               || ', l_wf_message_name = ' || l_wf_message_name
                           ||', sql error code'||sqlcode);
        END IF;
      RAISE;
END IS_NOTIF_SUBSCRIBED;

PROCEDURE NOTIFY_MEMBER(p_userPartyId           IN NUMBER,
                        p_auctioneer_user_name  IN VARCHAR2,
                        p_auction_start_date    IN DATE,
                        p_auction_end_date      IN DATE,
                        p_preview_date          IN DATE,
                        p_msg_sent_date         IN DATE,
                        p_msg_suffix            IN VARCHAR2,
                        p_doc_number            IN VARCHAR2,
                        p_auction_title         IN VARCHAR2,
                        p_entryid               IN NUMBER,
                        p_auction_header_id     IN NUMBER,
                        p_fromFirstName         IN VARCHAR2,
                        p_fromLastName          IN VARCHAR2,
                        p_from_id               IN NUMBER,
                        p_notif_performer       IN VARCHAR2,
                        p_subject               IN VARCHAR2,
                        p_content               IN VARCHAR2,
                        p_message_type          IN VARCHAR2,
                        p_fromCompanyName       IN VARCHAR2,
                        p_discussion_id         IN NUMBER,
                        p_stagger_closing_interval IN NUMBER,
                        p_open_auction_now_flag  IN VARCHAR2,
                        p_publish_auction_now_flag IN VARCHAR2
                        )
IS
        l_null_date           DATE;
        l_progress            VARCHAR2(3);
        l_module_name         CONSTANT VARCHAR2(20) := '.NOTIFY_MEMBER';

        l_language            VARCHAR2(60);
        l_lang_code           VARCHAR2(30);
        l_sender_name         VARCHAR2(350);
        l_recipient_name      VARCHAR2(350);

        l_msg_sent_subject    VARCHAR2(2000);
        l_timezone_disp       VARCHAR2(240);
        l_timezone_disp1      VARCHAR2(240);
        l_timezone_nodisp     VARCHAR2(240);

        l_itemtype        VARCHAR2(7);
        l_itemkey        VARCHAR2(50);
        l_user_id             NUMBER;
        l_user_name           FND_USER.USER_NAME%TYPE;
        l_sender_user         FND_USER.USER_NAME%TYPE;
        l_page_url            VARCHAR2(500);
        l_wfm_htmlagent       VARCHAR2(500);
        l_discussion_id       NUMBER;
        l_auction_start_date  DATE;
        l_auction_end_date    DATE;
        l_preview_date        DATE;
        l_msg_sent_date       DATE;
        l_staggered_close_note VARCHAR2(1000);

        x_language_code       VARCHAR2(60);
        x_territory_code      VARCHAR2(30);

BEGIN
--{
                l_null_date := NULL;
                l_auction_start_date  := p_auction_start_date;
                l_auction_end_date   := p_auction_end_date;
                l_preview_date          := p_preview_date;
                l_msg_sent_date       := p_msg_sent_date;
                l_progress  := '010';

                BEGIN

                  BEGIN

                    SELECT
                        USER_ID,
                        USER_NAME
                    INTO
                        l_user_id,
                        l_user_name
                    FROM FND_USER
                    WHERE PERSON_PARTY_ID = p_userPartyId
                    AND NVL(END_DATE, SYSDATE+1) > SYSDATE;

                 EXCEPTION
                       WHEN TOO_MANY_ROWS THEN
                          IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
                               IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                                         FND_LOG.string(log_level => FND_LOG.level_unexpected,
                                                        module    => 'pon.plsql.pon_auction_pkg.notify_member 1',
                                                        message   => 'Multiple Users found for person_party_id:'|| p_userPartyId);
                               END IF;
                         END IF;

                     SELECT
                        USER_ID,
                        USER_NAME
                    INTO
                        l_user_id,
                        l_user_name
                    FROM FND_USER
                    WHERE PERSON_PARTY_ID = p_userPartyId
                    AND NVL(END_DATE, SYSDATE+1) > SYSDATE
                    AND ROWNUM=1;

                 END;

                 BEGIN

                    SELECT
                        USER_NAME
                    INTO
                        l_sender_user
                    FROM FND_USER
                    WHERE PERSON_PARTY_ID = p_from_id
                    AND NVL(END_DATE, SYSDATE+1) > SYSDATE;

                 EXCEPTION
                       WHEN TOO_MANY_ROWS THEN
                          IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
                               IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                                         FND_LOG.string(log_level => FND_LOG.level_unexpected,
                                                        module    => 'pon.plsql.pon_auction_pkg.notify_member 2',
                                                        message   => 'Multiple Users found for person_party_id:'|| p_from_id);
                               END IF;
                         END IF;

                    SELECT
                        USER_NAME
                    INTO
                        l_sender_user
                    FROM FND_USER
                    WHERE PERSON_PARTY_ID = p_from_id
                    AND NVL(END_DATE, SYSDATE+1) > SYSDATE
                    AND ROWNUM=1;

                 END;

                    -- Get the language of the Recipient of the message
                   l_language := fnd_profile.value_specific('ICX_LANGUAGE', l_user_id, NULL, NULL);
               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_language := 'AMERICAN';
               END;

               SELECT LANGUAGE_CODE
                       INTO l_lang_code
               FROM FND_LANGUAGES
               WHERE NLS_LANGUAGE = l_language;

                l_recipient_name := PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(p_userPartyId, 2 ,l_lang_code) ;
                l_sender_name := PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(p_from_id, 2 ,l_lang_code);

                --
                -- Subject should be retrieved from seed message
                --
                IF l_user_name is not null THEN
                        PON_PROFILE_UTIL_PKG.GET_WF_PREFERENCES(l_user_name ,x_language_code,x_territory_code);
                END IF;

                IF (x_language_code is not null) THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
                        FND_LOG.string(log_level => FND_LOG.level_statement,
                          module => g_module_prefix || 'EMAIL_LIST',
                          message  => '12. Calling SET_SESSION_LANGUAGE with x_language_code : ' || x_language_code);
                        END IF; --}
                        SET_SESSION_LANGUAGE(null, x_language_code);
                END IF;

                PON_OEX_TIMEZONE_PKG.CONVERT_DATE_TO_USER_TZ(p_person_party_id => p_userPartyId,
                                                               p_auctioneer_user_name => p_auctioneer_user_name,
                                                               x_date_value1  => l_auction_start_date,
                                                               x_date_value2  => l_auction_end_date,
                                                               x_date_value3  => l_preview_date,
                                                               x_date_value4  => l_msg_sent_date,
                                                               x_date_value5  => l_null_date,
                                                               x_timezone_disp =>l_timezone_disp);


                l_progress := '020';
                IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                              FND_LOG.string (log_level => FND_LOG.level_procedure,
                                           module => g_module || l_module_name,
                                           message  => 'Negotiation Dates are converted to destination timezone: ' || l_timezone_disp);
                END IF;

                l_msg_sent_subject :=  PON_AUCTION_PKG.getMessage(msg => 'PON_DISC_MESSAGE_SENT_MSG',
                                                                    msg_suffix => '_'|| p_msg_suffix,
                                                                    token1 => 'DOC_NUMBER',
                                                                    token1_value => p_doc_number,
                                                                    token2 => 'NEG_TITLE',
                                                                    token2_value => replaceHtmlChars(p_auction_title));


                l_progress := '030';
                IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                              FND_LOG.string (log_level => FND_LOG.level_procedure,
                                           module => g_module || l_module_name,
                                           message  => 'Disc. Message Subject: ' || l_msg_sent_subject);
                END IF;

                l_itemtype := 'PONAUCT';
                l_itemkey := p_auction_header_id||'-'|| p_entryid||'-'||p_userPartyId;

                IF (p_preview_date is not null) THEN
                        l_timezone_disp1 := l_timezone_disp;
                        l_timezone_nodisp := NULL;
                ELSE
                        l_timezone_disp1 := NULL;
                        l_timezone_nodisp := PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC');
                END IF;

                l_progress := '040';
                IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                              FND_LOG.string (log_level => FND_LOG.level_procedure,
                                           module => g_module || l_module_name,
                                           message  => 'Negotiation Preview Date is: ' || p_preview_date);
                END IF;

                l_progress := '050';
                IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string (log_level => FND_LOG.level_procedure,
                                       module => g_module || l_module_name,
                                       message  => 'This is a Point to Point Message');
                END IF;


                l_progress := '060';
                IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string (log_level => FND_LOG.level_procedure,
                                       module => g_module || l_module_name,
                                       message  => 'Fetched the Formatted To Name:'|| l_recipient_name ||' , '||'and From Name:'|| l_sender_name);
                END IF;

                IF p_notif_performer = 'BUYER' THEN
   	            l_wfm_htmlagent := pon_wf_utl_pkg.get_base_internal_buyer_url;
	        ELSE
	            l_wfm_htmlagent := pon_wf_utl_pkg.get_base_external_supplier_url;
	        END IF;

                l_page_url := pon_wf_utl_pkg.get_dest_page_url (p_dest_func => 'PON_VIEW_MESSAGE_DETAILS'
                                 ,p_notif_performer  => p_notif_performer);

                --
                -- Stagger Closing Note is to be shown for ONLY Supplier
                -- facing notification ONLY with staggered line Negotiation
                --
                l_staggered_close_note := NULL;
                IF (p_notif_performer IS NOT NULL AND
                    p_notif_performer = 'SUPPLIER' AND
                    p_stagger_closing_interval IS NOT NULL ) THEN
                         l_staggered_close_note := wf_core.newline || wf_core.newline ||
                                                   getMessage('PON_STAGGERED_CLOSE_NOTIF_MSG') ||
                                                   wf_core.newline || wf_core.newline;

                END IF;


                wf_engine.CreateProcess(itemtype => l_itemtype,
                      itemkey  => l_itemkey,
                      process  => 'DISC_MESSAGE_SENT');

                l_progress := '070';
                IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string (log_level => FND_LOG.level_procedure,
                                       module => g_module || l_module_name,
                                       message  => 'Created the DISC_MESSAGE_SENT Workflow process');
                END IF;

              SET_PREVIEW_DATE(
                        p_itemtype => l_itemtype,
                        p_itemkey   => l_itemkey,
                        p_preview_date  => l_preview_date,
                        p_publish_auction_now_flag => p_publish_auction_now_flag,
                        p_timezone_disp  => l_timezone_disp,
                        p_msg_suffix => p_msg_suffix);

              SET_OPEN_DATE(
                        p_itemtype      => l_itemtype,
                        p_itemkey      => l_itemkey,
                        p_auction_start_date  => l_auction_start_date,
                        p_open_auction_now_flag => p_open_auction_now_flag,
                        p_timezone_disp  => l_timezone_disp,
                        p_msg_suffix => p_msg_suffix);

              SET_CLOSE_DATE(
                        p_itemtype  =>l_itemtype,
                        p_itemkey    =>l_itemkey,
                        p_auction_end_date  => l_auction_end_date,
                        p_timezone_disp  => l_timezone_disp);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'DOC_NUMBER',
                           avalue     => p_doc_number);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                           itemkey    => l_itemkey,
                                           aname      => 'STAGGERED_CLOSE_NOTE',
                                           avalue     => l_staggered_close_note);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'AUCTION_TITLE',
                           avalue     => p_auction_title);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MSG_RECIPIENT_NAME',
                           avalue     => l_recipient_name);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MSG_SENDER_NAME',
                           avalue     => l_sender_name);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                 itemkey    => l_itemkey,
                                 aname      => 'VIEW_MESSAGE_URL',
                                 avalue     => l_page_url);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                 itemkey    => l_itemkey,
                                 aname      => 'MESSAGE_TYPE',
                                 avalue     => p_message_type);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MSG_SENDER_COMP_NAME',
                           avalue     => p_fromCompanyName);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MESSAGE_SENT_SUBJECT',
                           avalue     => l_msg_sent_subject);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MESSAGE_POSTED_DATE',
                           avalue     => p_msg_sent_date);

               wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MESSAGE_SUBJECT',
                           avalue     => p_subject);

               wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MESSAGE_SENT_CONTENT',
                           avalue     => p_content);
               wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'PREPARER_TP_CONTACT_NAME',
                           avalue     => l_sender_user);

               wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'RECIPIENT_ROLE',
                           avalue     => l_user_name);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'TRADING_PARTNER_TYPE',
                           avalue     => p_notif_performer);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'AUCTION_ID',
                           avalue     => p_auction_header_id);

                wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'MESSAGE_ENTRY_ID',
                           avalue     => p_entryid);

                wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'DISCUSSION_ID',
                           avalue     => p_discussion_id);

                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'ORIGIN_USER_NAME',
                           --avalue     => fnd_global.user_name);--Bug: 13609915 :set FROM as creator of doc
                           avalue     => l_sender_user);


                --SLM UI Enhancement
                PON_SLM_UTIL_PKG.SET_SLM_DOC_TYPE_ATTRIBUTE(l_itemtype, l_itemkey, p_auction_header_id);

             -- Bug 4295915: Set the  workflow owner
                wf_engine.SetItemOwner(itemtype => l_itemtype,
                                       itemkey  => l_itemkey,
                                       owner    => fnd_global.user_name);

                BEGIN

                    wf_engine.SetItemAttrText   (itemtype   => l_itemtype,
                                                 itemkey    => l_itemkey,
                                                 aname      => '#WFM_HTMLAGENT',
                                                 avalue     => l_wfm_htmlagent);
                EXCEPTION
                  WHEN OTHERS THEN
                     null;
                END;

                -- Bug 18517926 : Generate Online Discussion message body dynamically
                wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                           itemkey    => l_itemkey,
                           aname      => 'DISCUSSION_MESSAGE_BODY',
                           avalue     => 'PLSQLCLOB:PON_AUCTION_PKG.GET_DISCUSSION_MESG_BODY/'||l_itemtype ||':' ||l_itemkey );

                wf_engine.StartProcess(itemtype => l_itemtype,
                       itemkey  => l_itemkey );

                l_progress := '080';


                IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string (log_level => FND_LOG.level_procedure,
                              module => g_module || l_module_name,
                               message  => 'Procedure Ends ' || g_module || l_module_name
                              || ', l_progress = ' || l_progress);
                END IF;

EXCEPTION
      WHEN OTHERS THEN
           WF_CORE.CONTEXT ('PONAUCT','NOTIFY_MEMBER','Progress:'|| l_progress ||', SQL error:' || sqlcode|| ', error message:' ||substr(sqlerrm,1,512));
           RAISE;
--}
END NOTIFY_MEMBER;

/*=========================================================================+
--
-- 12.0 Enhancement
-- GET_MAPPED_IP_CATEGORY takes in a po category id as a parameter and
-- returns an ip category if mapping exists else returns -2
--
--
-- Parameter :
--             p_po_category_id  IN NUMBER
--
+=========================================================================*/


FUNCTION GET_MAPPED_IP_CATEGORY(p_po_category_id  IN NUMBER) return NUMBER AS

v_ip_category_id NUMBER;

BEGIN

  BEGIN
    select nvl(shopping_category_id, -2)
    into   v_ip_category_id
    from   icx_cat_purchasing_cat_map_v
    where  po_category_id = p_po_category_id and
           rownum = 1;

  EXCEPTION

    WHEN OTHERS THEN

      v_ip_category_id := -2;

  END;

  RETURN v_ip_category_id;

END GET_MAPPED_IP_CATEGORY;

/*=========================================================================+
--
-- 12.0 Enhancement
-- GET_MAPPED_PO_CATEGORY takes in an ip category id as a parameter and
-- returns a po category if mapping exists else returns -2
--
--
-- Parameter :
--             p_ip_category_id  IN NUMBER
--
+=========================================================================*/


FUNCTION GET_MAPPED_PO_CATEGORY(p_ip_category_id  IN NUMBER) return NUMBER AS

v_po_category_id NUMBER;

BEGIN

  BEGIN
    select nvl(po_category_id, -2)
    into   v_po_category_id
    from   icx_cat_shopping_cat_map_v
    where  shopping_category_id = p_ip_category_id and
           rownum = 1;

  EXCEPTION

    WHEN OTHERS THEN

      v_po_category_id := -2;

  END;

  RETURN v_po_category_id;

END GET_MAPPED_PO_CATEGORY;

PROCEDURE SET_PREVIEW_DATE(
          p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
           p_preview_date  IN DATE,
          p_publish_auction_now_flag IN VARCHAR2,
          p_timezone_disp  IN VARCHAR2,
          p_msg_suffix IN VARCHAR2) IS

BEGIN

        IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
             IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                       FND_LOG.string(log_level => FND_LOG.level_statement,
                                      module    => 'pon.plsql.pon_auction_pkg.set_preview_date',
                                      message   => 'Entered the procedure with params --- ' ||
                                                    'p_itemtype : ' || p_itemtype||
                                                    ',p_itemkey : ' ||p_itemkey||
                                                    ',p_preview_date : '||p_preview_date||
                                                    ',p_publish_auction_now_flag : '||p_publish_auction_now_flag||
                                                    ',p_timezone_disp : '||p_timezone_disp||
                                                    ',p_msg_suffix : '||p_msg_suffix);
             END IF;
       END IF;

      IF (p_publish_auction_now_flag = 'Y') THEN --if Immediately is selected

        wf_engine.SetItemAttrDate (itemtype  => p_itemtype,
                    itemkey  => p_itemkey,
                    aname  => 'PREVIEW_DATE',
                    avalue  => null);

        wf_engine.SetItemAttrText (itemtype  => p_itemtype,
                    itemkey  => p_itemkey,
                    aname  => 'TP_TIME_ZONE1',
                    avalue  => null);

        wf_engine.SetItemAttrText (itemtype  => p_itemtype,
                       itemkey  => p_itemkey,
                       aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                       avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_OPEN_IMM_AFTER_PUB',p_msg_suffix));

      ELSIF (p_preview_date is NULL) THEN --if Not specified

        wf_engine.SetItemAttrDate (itemtype  => p_itemtype,
                    itemkey  => p_itemkey,
                    aname  => 'PREVIEW_DATE',
                    avalue  => null);

        wf_engine.SetItemAttrText (itemtype  => p_itemtype,
                        itemkey  => p_itemkey,
                        aname  => 'TP_TIME_ZONE1',
                        avalue  => null);

        wf_engine.SetItemAttrText (itemtype  => p_itemtype,
                       itemkey  => p_itemkey,
                       aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                       avalue  => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));

      ELSE
        wf_engine.SetItemAttrDate (itemtype  => p_itemtype,
                    itemkey  => p_itemkey,
                    aname  => 'PREVIEW_DATE',
                    avalue  => p_preview_date);

        wf_engine.SetItemAttrText (itemtype  => p_itemtype,
                    itemkey  => p_itemkey,
                    aname  => 'TP_TIME_ZONE1',
                    avalue  => p_timezone_disp);

        wf_engine.SetItemAttrText (itemtype  => p_itemtype,
                   itemkey  => p_itemkey,
                   aname  => 'PREVIEW_DATE_NOTSPECIFIED',
                   avalue  => null);
      END IF;

      IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                     FND_LOG.string(log_level => FND_LOG.level_statement,
                                    module    => 'pon.plsql.pon_auction_pkg.set_preview_date',
                                    message   => 'Exiting the procedure');
           END IF;
     END IF;

END;

PROCEDURE SET_OPEN_DATE(
          p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
           p_auction_start_date  IN DATE,
          p_open_auction_now_flag IN VARCHAR2,
          p_timezone_disp  IN VARCHAR2,
          p_msg_suffix IN VARCHAR2) IS

BEGIN

      IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                     FND_LOG.string(log_level => FND_LOG.level_statement,
                                    module    => 'pon.plsql.pon_auction_pkg.set_open_date',
                                    message   => 'Entered the procedure with params --- ' ||
                                                  'p_itemtype : ' || p_itemtype||
                                                  ',p_itemkey : ' ||p_itemkey||
                                                  ',p_auction_start_date : '||p_auction_start_date||
                                                  ',p_open_auction_now_flag : '||p_open_auction_now_flag||
                                                  ',p_timezone_disp : '||p_timezone_disp||
                                                  ',p_msg_suffix : '||p_msg_suffix);
           END IF;
       END IF;

      IF (p_open_auction_now_flag = 'Y') THEN --if Immediately  is selected

        wf_engine.SetItemAttrDate (itemtype   => p_itemtype,
                   itemkey    => p_itemkey,
                   aname      => 'AUCTION_START_DATE',
                   avalue     => null);

        wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                   itemkey    => p_itemkey,
                   aname      => 'TP_TIME_ZONE',
                   avalue     => null);

        wf_engine.SetItemAttrText (itemtype     => p_itemtype,
                   itemkey  => p_itemkey,
                   aname    => 'OPEN_DATE_NOT_SPECIFIED',
                   avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_OPEN_IMM_AFTER_PUB',p_msg_suffix));

      ELSIF(p_auction_start_date is NULL) THEN --if not specified
        wf_engine.SetItemAttrDate (itemtype   => p_itemtype,
                   itemkey    => p_itemkey,
                   aname      => 'AUCTION_START_DATE',
                   avalue     => null);

        wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                   itemkey    => p_itemkey,
                   aname      => 'TP_TIME_ZONE',
                   avalue     => null);

        wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                   itemkey  => p_itemkey,
                   aname    => 'OPEN_DATE_NOT_SPECIFIED',
                   avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));

      ELSE
        wf_engine.SetItemAttrDate (itemtype   => p_itemtype,
                   itemkey    => p_itemkey,
                   aname      => 'AUCTION_START_DATE',
                   avalue     => p_auction_start_date);

        wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                   itemkey    => p_itemkey,
                   aname      => 'TP_TIME_ZONE',
                   avalue     => p_timezone_disp);

        wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                   itemkey  => p_itemkey,
                   aname    => 'OPEN_DATE_NOT_SPECIFIED',
                   avalue   => null);

      END IF;

      IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                     FND_LOG.string(log_level => FND_LOG.level_statement,
                                    module    => 'pon.plsql.pon_auction_pkg.set_open_date',
                                    message   => 'Exiting the procedure');
           END IF;
     END IF;

END;


PROCEDURE SET_CLOSE_DATE(
          p_itemtype      IN  VARCHAR2,
           p_itemkey      IN  VARCHAR2,
           p_auction_end_date  IN DATE,
          p_timezone_disp  IN VARCHAR2) IS

BEGIN

        IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
             IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                       FND_LOG.string(log_level => FND_LOG.level_statement,
                                      module    => 'pon.plsql.pon_auction_pkg.set_close_date',
                                      message   => 'Entered the procedure with params --- ' ||
                                                    'p_itemtype : ' || p_itemtype||
                                                    ',p_itemkey : ' ||p_itemkey||
                                                    ',p_auction_end_date : '||p_auction_end_date||
                                                    ',p_timezone_disp : '||p_timezone_disp);
             END IF;
       END IF;


       IF (p_auction_end_date is NULL) THEN --if not specified
          wf_engine.SetItemAttrDate (itemtype   => p_itemtype,
                     itemkey    => p_itemkey,
                     aname      => 'AUCTION_END_DATE',
                     avalue     => null);

          wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                     itemkey    => p_itemkey,
                     aname      => 'TP_TIME_ZONE2',
                     avalue     => null);

          wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                     itemkey  => p_itemkey,
                     aname    => 'CLOSE_DATE_NOT_SPECIFIED',
                     avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));


        ELSE
          wf_engine.SetItemAttrDate (itemtype   => p_itemtype,
                     itemkey    => p_itemkey,
                     aname      => 'AUCTION_END_DATE',
                     avalue     => p_auction_end_date);

          wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                     itemkey    => p_itemkey,
                     aname      => 'TP_TIME_ZONE2',
                     avalue     => p_timezone_disp);

          wf_engine.SetItemAttrText (itemtype     => p_itemtype,
                     itemkey  => p_itemkey,
                     aname    => 'CLOSE_DATE_NOT_SPECIFIED',
                     avalue   => null);

        END IF;


      IF (NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y') THEN
           IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                     FND_LOG.string(log_level => FND_LOG.level_statement,
                                    module    => 'pon.plsql.pon_auction_pkg.set_close_date',
                                    message   => 'Exiting the procedure');
           END IF;
     END IF;

END;

--
-- This procedure is added as part of bug fix for 4914024.
-- Some attributes were removed from the AuctionHeadersAllVO query
-- to prevent the shared memory from going higher. These attributes
-- are now obtained from this PL/SQL API instead.
--
PROCEDURE GET_NEGOTIATION_DETAILS( p_auction_header_id            NUMBER,
                                   p_user_trading_partner_id      NUMBER,
                                   x_time_left                    OUT NOCOPY VARCHAR2,
                                   x_buyer_display                OUT NOCOPY VARCHAR2,
                                   x_carrier                      OUT NOCOPY VARCHAR2,
                                   x_unlocked_by_display          OUT NOCOPY VARCHAR2,
                                   x_unsealed_by_display          OUT NOCOPY VARCHAR2,
                                   x_has_active_company_bid       OUT NOCOPY VARCHAR2,
                                   x_is_multi_site                OUT NOCOPY VARCHAR2,
                                   x_all_site_bid_on              OUT NOCOPY VARCHAR2,
                                   x_is_paused                    OUT NOCOPY VARCHAR2,
                                   x_outcome_display              OUT NOCOPY VARCHAR2,
                                   x_advances_flag                OUT NOCOPY VARCHAR2,
                                   x_retainage_flag               OUT NOCOPY VARCHAR2,
                                   x_payment_rate_rype_enabled    OUT NOCOPY VARCHAR2
                                 ) IS

v_org_id NUMBER;
v_carrier_code PON_AUCTION_HEADERS_ALL.CARRIER_CODE%TYPE;
v_sealed_unlock_tp_contact_id NUMBER;
v_sealed_unseal_tp_contact_id NUMBER;
v_is_paused VARCHAR2(1);
v_trading_partner_contact_id NUMBER;
v_staggered_closing_interval NUMBER;
v_temp NUMBER;

BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module    => g_module_prefix || '.get_negotiation_details',
      message   => 'Entered the procedure ' ||
                   'p_auction_header_id = ' || p_auction_header_id ||
                   ', p_trading_partner_contact_id = ' || p_user_trading_partner_id);
  END IF;

  SELECT
    org_id,
    carrier_code,
    decode(two_part_flag,'Y',decode(sealed_auction_status,'LOCKED',technical_unlock_tp_contact_id,sealed_unlock_tp_contact_id),sealed_unlock_tp_contact_id),
    decode(two_part_flag,'Y',decode(sealed_auction_status,'ACTIVE', sealed_unseal_tp_contact_id,technical_unseal_tp_contact_id),sealed_unseal_tp_contact_id),
    is_paused,
    staggered_closing_interval,
    trading_partner_contact_id
  INTO
    v_org_id,
    v_carrier_code,
    v_sealed_unlock_tp_contact_id,
    v_sealed_unseal_tp_contact_id,
    v_is_paused,
    v_staggered_closing_interval,
    v_trading_partner_contact_id
  FROM
    pon_auction_headers_all_v
  WHERE
    auction_header_id = p_auction_header_id;

  x_time_left            :=  TIME_REMAINING(p_auction_header_id);
  x_buyer_display        :=  PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(v_trading_partner_contact_id);
  x_carrier              :=  PON_PRINTING_PKG.GET_CARRIER_DESCRIPTION(v_org_id,v_carrier_code);
  x_unlocked_by_display  :=  PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(v_sealed_unlock_tp_contact_id);
  x_unsealed_by_display  :=  PON_LOCALE_PKG.GET_PARTY_DISPLAY_NAME(v_sealed_unseal_tp_contact_id);

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string( log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || '.get_negotiation_details',
      message  => 'x_time_left = ' || x_time_left
                  || ', x_buyer_display = ' || x_buyer_display
                  || ', x_carrier = ' || x_carrier
                  || ', x_unlocked_by_display = ' || x_unlocked_by_display
                  || ', x_unsealed_by_display = ' || x_unsealed_by_display);
  END IF;

  BEGIN
    SELECT
      a.auction_header_id
    INTO
      v_temp
    FROM
      pon_auction_headers_all a,
      pon_bid_headers b
    WHERE
      a.auction_header_id = b.auction_header_id
      and a.auction_header_id =  p_auction_header_id
      and b.trading_partner_id = p_user_trading_partner_id
      and b.bid_status = 'ACTIVE'
      AND rownum = 1;

    x_has_active_company_bid := 'Y';

    EXCEPTION WHEN NO_DATA_FOUND THEN
      x_has_active_company_bid := 'N';
  END;

  BEGIN
    SELECT
      ppbp.auction_header_id
    INTO
      v_temp
    FROM
      pon_bidding_parties ppbp
    WHERE
      ppbp.auction_header_id = p_auction_header_id
      and ppbp.trading_partner_id = p_user_trading_partner_id
      AND rownum = 1;

    x_is_multi_site := 'Y';

    EXCEPTION WHEN NO_DATA_FOUND THEN
      x_is_multi_site := 'N';
  END;

  SELECT
    DECODE(
      (SELECT
         count(distinct vendor_site_id)
       FROM
         pon_bid_headers ppbh
       WHERE
         ppbh.auction_header_id = p_auction_header_id
         and ppbh.trading_partner_id = p_user_trading_partner_id
         and ppbh.bid_status = 'ACTIVE'
         and nvl(ppbh.evaluation_flag, 'N') = 'N'    -- Added for ER: Supplier Management: Supplier Evaluation
      ),
      (SELECT
         count(pbp.auction_header_id)
       FROM
         pon_bidding_parties pbp
       WHERE
         pbp.auction_header_id = p_auction_header_id
         and pbp.trading_partner_id = p_user_trading_partner_id
      ), 'Y', 'N')
  INTO
    x_all_site_bid_on
  FROM
    DUAL;

  SELECT
    DECODE( nvl(v_is_paused, 'N'), 'Y', 'Y', nvl2(v_staggered_closing_interval, 'S', 'N'))
  INTO
    x_is_paused
  FROM
    DUAL;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || '.get_negotiation_details',
      message  => 'x_has_active_company_bid = ' || x_has_active_company_bid
        || ' x_is_multi_site = ' || x_is_multi_site
        || ' x_all_site_bid_on = ' || x_all_site_bid_on
        || ' x_is_paused = ' || x_is_paused);
  END IF;

  SELECT
    ps.display_name,
    pdsh.advances_flag,
    pdsh.retainage_flag,
    nvl2(pspay.pay_item_type , 'Y','N')
  INTO
    x_outcome_display,
    x_advances_flag,
    x_retainage_flag,
    x_payment_rate_rype_enabled
  FROM
    po_all_doc_style_lines ps,
    pon_auction_headers_all_v ah,
    po_doc_style_headers pdsh,
    po_style_enabled_pay_items pspay,
    po_lookup_codes fl_pay_item
  WHERE
    ah.auction_header_id = p_auction_header_id
    AND ah.po_style_id = ps.style_id(+)
    AND ah.contract_type = ps.document_subtype(+)
    AND USERENV('LANG') = ps.language(+)
    AND ah.po_style_id = pdsh.style_id(+)
    AND ah.po_style_id = pspay.style_id(+)
    AND pspay.pay_item_type(+) ='RATE'
    AND fl_pay_item.lookup_type(+)  =  'PAYMENT TYPE'
    AND fl_pay_item.lookup_code(+) = pspay.pay_item_type;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
       FND_LOG.string (log_level => FND_LOG.level_statement,
         module  =>  g_module_prefix || '.get_negotiation_details',
         message  => 'x_outcome_display = ' || x_outcome_display
         || ' x_advances_flag = ' || x_advances_flag
         || ' x_retainage_flag = ' || x_retainage_flag
         || ' x_payment_rate_rype_enabled = ' || x_payment_rate_rype_enabled);
  END IF;

END GET_NEGOTIATION_DETAILS;

---------------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Countdown Clock Project (adsahay)
--
--      Start of comments
--      API Name:               SHOW_COUNTDOWN
--      Function:               Given an auction id, returns "Y" if the auction is active or paused and
--                              closing within next 24 hours. Auctions that are in preview mode,
--                              cancelled or amended, or closing in more than 24 hours return "N".
--      Parameters:
--      IN:     p_auction_header_id IN NUMBER           - Auction header id
--      OUT:    x_return_status OUT NOCOPY VARCHAR2     - Return status
--              x_error_code OUT NOCOPY VARCHAR2        - Error code
--              x_error_message OUT NOCOPY VARCHAR2     - Error message
--
--      End of Comments
--      Return : l_show_countdown VARCHAR2
----------------------------------------------------------------------------------------

FUNCTION SHOW_COUNTDOWN(x_result OUT NOCOPY VARCHAR2,
                        x_error_code OUT NOCOPY VARCHAR2,
                        x_error_message OUT NOCOPY VARCHAR2,
                        p_auction_header_id IN NUMBER)
RETURN VARCHAR2
AS
v_auction_status pon_auction_headers_all.auction_status%TYPE;  -- to store auction status
v_time_remaining number;  -- to store the time remaining for auction to close
l_show_countdown varchar2(1) := 'N';    -- return value, default 'N'

BEGIN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || '.show_countdown',
                message  => 'Entered show_countdown with p_auction_header_id = ' || p_auction_header_id);
        END IF;

        x_result := FND_API.G_RET_STS_SUCCESS;

        -- adsahay: bug 6319438 - replace sysdate with last_pause_date for paused auctions,
        -- since close_bidding_date can be in the past (lesser than sysdate).
        SELECT (close_bidding_date - decode(is_paused, 'Y', last_pause_date, sysdate)), auction_status
        INTO v_time_remaining, v_auction_status
        FROM pon_auction_headers_all
        WHERE auction_header_id = p_auction_header_id
        AND open_bidding_date < sysdate;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || '.show_countdown',
        message  => 'p_auction_header_id = ' || p_auction_header_id
          || ', v_auction_status = ' || v_auction_status
          || ', v_time_remaining = ' || v_time_remaining);
        END IF;

-- v_time_remaining will be in days, 1.0 being full 24 hours.
IF (v_time_remaining > 0 AND v_time_remaining <= 1.0) then
        IF(v_auction_status = 'CANCELLED') THEN   -- auction is cancelled
                l_show_countdown := 'N';
        ELSIF (v_auction_status = 'AMENDED') THEN -- auction is amended
                l_show_countdown := 'N';
        ELSE
                l_show_countdown := 'Y';        -- looks good if reached here.
        END IF;

ELSE    -- more than 24 hours left
        l_show_countdown := 'N';
END IF;

IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || '.show_countdown',
        message  => 'Returning l_show_countdown = ' || l_show_countdown);
END IF;

-- return l_show_countdown
RETURN l_show_countdown;

EXCEPTION
  WHEN NO_DATA_FOUND THEN       -- auction is in preview mode, return 'N'
        l_show_countdown := 'N';
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || '.show_countdown',
                message  => 'Returning l_show_countdown = ' || l_show_countdown);
        END IF;
        Return l_show_countdown;

  WHEN OTHERS THEN
        x_result := FND_API.G_RET_STS_UNEXP_ERROR;
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_exception,
                module  => g_module_prefix || '.show_countdown',
                message => 'Exception occured in show_countdown'
                || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
        END IF;

END SHOW_COUNTDOWN; -- end of function definition.

-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Countdown Clock Project (adsahay)
--
--      Start of comments
--      API Name:       HAS_DISTINCT_CLOSING_LINES
--      Function:       Given an auction id, Returns 'Y' if the auction has lines
--                      closing in different times, else 'N'. This means that either the auction is
--                      staggered or has "auto extend" feature enabled such that it extends one line
--                      instead of all lines.
--
--      Parameters:
--      IN:     p_auction_header_id IN NUMBER   - The auction header id
--      OUT:    x_return_status OUT NOCOPY VARCHAR2     - Return status
--              x_error_code OUT NOCOPY VARCHAR2        - Error code
--              x_error_message OUT NOCOPY VARCHAR2     - Error message
--
--      End of Comments
--
--      Return : l_flag VARCHAR2
------------------------------------------------------------------------------------

FUNCTION HAS_DISTINCT_CLOSING_DATES(x_result OUT NOCOPY VARCHAR2,
                                x_error_code OUT NOCOPY VARCHAR2,
                                x_error_message OUT NOCOPY VARCHAR2,
                                p_auction_header_id IN NUMBER)
RETURN VARCHAR2
AS
v_time_left number;        --gets the time left for auction to close
v_is_staggered varchar2(1);     -- whether auction is staggered
v_ext_all_lines varchar2(1);    -- whether auto extend all lines
l_flag varchar2(1) := 'N';      -- Return value defaulted to 'N'
BEGIN

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || '.has_distinct_closing_dates',
                message  => 'Entered has_distinct_closing_dates with p_auction_header_id = ' || p_auction_header_id);
        END IF;

        x_result := FND_API.G_RET_STS_SUCCESS;

        -- adsahay: bug 6319438 - replace sysdate with last_pause_date for paused auctions,
        -- since close_bidding_date can be in the past (lesser than sysdate).
        SELECT (close_bidding_date-decode(is_paused, 'Y', last_pause_date, sysdate)), nvl2(staggered_closing_interval, 'Y', 'N'),
        -- if auto extend is enabled and auto extends all lines, 'N' else 'Y'
        decode(auto_extend_flag, 'Y', decode(auto_extend_all_lines_flag, 'N', 'Y', 'N'), 'N')
        INTO v_time_left, v_is_staggered, v_ext_all_lines
        FROM pon_auction_headers_all
        WHERE auction_header_id = p_auction_header_id;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || '.has_distinct_closing_dates',
        message  => 'p_auction_header_id = ' || p_auction_header_id
          || ', v_time_left = ' || v_time_left
          || ', v_is_staggered = ' || v_is_staggered
          || ', v_ext_all_lines = ' || v_ext_all_lines);
        END IF;

        -- negative time left means auction already closed
        IF (v_time_left < 0) THEN
        l_flag := 'N';
        -- staggered or auto extend allows different lines to close differently
        ELSIF (v_is_staggered = 'Y' OR v_ext_all_lines = 'Y') THEN
                l_flag := 'Y';
        ELSE
                l_flag := 'N';
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || '.has_distinct_closing_dates',
                message  => 'Returning l_flag = ' || l_flag);
        END IF;

        RETURN l_flag;

EXCEPTION
  WHEN OTHERS THEN
        x_result := FND_API.G_RET_STS_UNEXP_ERROR;
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_exception,
                module  => g_module_prefix || '.has_distinct_closing_dates',
                message => 'Exception occured in has_distinct_closing_dates'
                || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
        END IF;

END HAS_DISTINCT_CLOSING_DATES; -- end of function definition

-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Two Part RFQ Project (adsahay)
--
--      Start of comments
--      API Name:       GET_TECHNICAL_MEANING
--      Function:       Returns meaning of 'TECHNICAL' from lookups.
--
--      Parameters:
--      IN:
--      OUT:
--
--      End of Comments
--
--      Return : g_technical_meaning VARCHAR2
------------------------------------------------------------------------------------
FUNCTION get_technical_meaning
RETURN VARCHAR2 AS
BEGIN
        -- adsahay: bug 6374353 - caching should take care of language too.
        -- if cache is empty first populate the cache
        IF (g_two_part_cache.COUNT = 0) then -- {
          init_two_part_cache;
        END IF; -- }

        -- update g_tp_cache_rec from the cache
        update_cache_rec;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || '.get_technical_meaning',
                message  => 'Returning technical_meaning = ' || g_tp_cache_rec.technical_meaning);
        END IF;

        -- return technical_meaning
        return g_tp_cache_rec.technical_meaning;
EXCEPTION
  WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_exception,
                module  => g_module_prefix || '.get_technical_meaning',
                message => 'Exception occured in get_technical_meaning'
                || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
        END IF;

END get_technical_meaning;

-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Two Part RFQ Project (adsahay)
--
--      Start of comments
--      API Name:       GET_COMMERCIAL_MEANING
--      Function:       Returns meaning of 'COMMERCIAL' from lookups.
--
--      Parameters:
--      IN:
--      OUT:
--
--      End of Comments
--
--      Return : g_commercial_meaning VARCHAR2
------------------------------------------------------------------------------------
FUNCTION get_commercial_meaning
RETURN VARCHAR2 AS
BEGIN
        -- adsahay: bug 6374353 - caching should take care of language too.
        -- if cache is empty first populate the cache
        IF (g_two_part_cache.COUNT = 0) then -- {
          init_two_part_cache;
        END IF; -- }

        -- update g_tp_cache_rec from the cache
        update_cache_rec;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || '.get_commercial_meaning',
                message  => 'Returning commercial_meaning = ' || g_tp_cache_rec.commercial_meaning);
        END IF;

        -- return commercial_meaning
        return g_tp_cache_rec.commercial_meaning;
EXCEPTION
  WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_exception,
                module  => g_module_prefix || '.get_commercial_meaning',
                message => 'Exception occured in get_commercial_meaning'
                || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
        END IF;

END get_commercial_meaning;

-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Two Part RFQ Project (adsahay)
--
--      Start of comments
--      API Name:       NOTIFY_BIDDERS_TECH_COMPLETE
--      Procedure:      Notify bidders that their bids have/have not been short listed
--      in technical evaluation.
--
--      Parameters:
--      IN:        p_auction_header_id IN NUMBER - The auction header id.
--      OUT:       x_return_status OUT NOCOPY VARCHAR2     - Return status
--        This is a flag to indicate if the procedure
--                              was successful or not; It can have
--                              following values -
--                                              FND_API.G_RET_STS_SUCCESS (Success)
--                                              FND_API.G_RET_STS_ERROR  (Success with warning)
--                                              FND_API.G_RET_STS_UNEXP_ERROR (Failed due to error)
--
--                x_error_code OUT NOCOPY VARCHAR2        - Error code
--                x_error_message OUT NOCOPY VARCHAR2     - Error message
--
--      End of Comments
------------------------------------------------------------------------------------
PROCEDURE NOTIFY_BIDDERS_TECH_COMPLETE(x_return_status OUT NOCOPY VARCHAR2,
          x_error_code OUT NOCOPY VARCHAR2 ,
          x_error_message OUT NOCOPY VARCHAR2,
          p_auction_header_id IN NUMBER)
AS
  -- get list of bidders, along with the shortlist flags.
  CURSOR bidder_list IS
    SELECT bid_number, trading_partner_contact_name, nvl(shortlist_flag, 'Y') as shortlist_flag,trading_partner_contact_id
    FROM pon_bid_headers
    WHERE   auction_header_id = p_auction_header_id
      AND bid_status = 'ACTIVE'
      AND nvl(evaluation_flag, 'N') = 'N';

  -- other local variables
  x_item_key VARCHAR2(15);  -- workflow item key
  x_item_type VARCHAR2(8) := 'PONTEVAL';  -- workflow item type
  l_bidder_name pon_bid_headers.trading_partner_contact_name%TYPE;
  l_auction_title pon_auction_headers_all.auction_title%TYPE;
  l_document_number pon_auction_headers_all.document_number%TYPE;
  l_trading_partner_name pon_auction_headers_all.trading_partner_name%TYPE;
  l_tp_contact_user_name           wf_users.name%TYPE;
  x_trading_partner_contact_id pon_bid_headers.trading_partner_contact_id%TYPE;

BEGIN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || '.notify_bidders_tech_complete',
                message  => 'Entered notify_bidders_tech_complete with p_auction_header_id = ' || p_auction_header_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    -- get auction information
    SELECT   auction_title, document_number, trading_partner_name
    INTO  l_auction_title, l_document_number, l_trading_partner_name
    FROM  pon_auction_headers_all
    WHERE  auction_header_id = p_auction_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_code := SQLCODE;
      x_error_message := SUBSTR(SQLERRM, 1, 100);

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || '.notify_bidders_tech_complete',
        message => 'NO_DATA_FOUND in pon_auction_headers_all for p_auction_header_id :'
        || p_auction_header_id || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
      END IF;

    WHEN TOO_MANY_ROWS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_code := SQLCODE;
      x_error_message := SUBSTR(SQLERRM, 1, 100);

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || '.notify_bidders_tech_complete',
        message => 'TOO_MANY_ROWS in pon_auction_headers_all for p_auction_header_id :'
        || p_auction_header_id || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
      END IF;

      WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_code := SQLCODE;
      x_error_message := SUBSTR(SQLERRM, 1, 100);

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || '.notify_bidders_tech_complete',
        message => 'Exception occured in notify_bidders_tech_complete'
        || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
      END IF;
  END;

  -- for every bidder,
  FOR bidder IN bidder_list LOOP

    -- get unique item key by a combination of sequence and bid number.
    SELECT   pon_auction_wf_dqbid_s.nextval
    INTO   x_item_key
    FROM   dual;
    x_item_key := bidder.bid_number || '-' || x_item_key;

    -- bidder name: this is the person who gets the notification
    l_bidder_name := bidder.trading_partner_contact_name;

    x_trading_partner_contact_id:=bidder.trading_partner_contact_id;

    -- create workflow process
    wf_engine.CreateProcess(itemtype => x_item_type,
              itemkey => x_item_key,
          process => 'PON_TECH_SHORTLIST_NOTIFY');

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || '.notify_bidders_tech_complete',
      message  => 'Created workflow process with itemtype = ' || x_item_type || ' and itemkey = '
          || x_item_key);
    END IF;

  -- bug#16690631 for surrogate quote enhancement

    CHECK_NOTIFY_USER_INFO(l_bidder_name,
                            x_trading_partner_contact_id,
                          l_tp_contact_user_name);

    -- bidder trading party contact name
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'BIDDER_TP_CONTACT_NAME',
                  avalue => l_tp_contact_user_name);

        -- auctioneer trading party name
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'PREPARER_TP_NAME',
                  avalue => l_trading_partner_name);

        -- auction header id
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'AUCTION_ID',
                  avalue => p_auction_header_id);

        -- bid id
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'BID_ID',
                  avalue => bidder.bid_number);

        -- auction title
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'AUCTION_TITLE',
                  avalue => l_auction_title);

        -- bid technically shortlisted flag
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'BID_TECH_SHORTLISTED',
                  avalue => bidder.shortlist_flag);

        -- document number (display value)
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'DOC_NUMBER',
                  avalue => l_document_number);

        -- meaning of Technical
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'TECHNICAL',
                  avalue => get_technical_meaning);

        -- meaning of Commercial
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'COMMERCIAL',
                  avalue => get_commercial_meaning);

        -- origin user name
    wf_engine.SetItemAttrText(  itemtype => x_item_type,
                  itemkey => x_item_key,
                  aname => 'ORIGIN_USER_NAME',
                  avalue => fnd_global.user_name);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || '.notify_bidders_tech_complete',
      message  =>    ' Passed these attributes -- BIDDER_TP_CONTACT_NAME :' || l_bidder_name  ||
          ' PREPARER_TP_NAME :' || l_trading_partner_name || ' AUCTION_ID :' || p_auction_header_id ||
          ' BID_ID :' || bidder.bid_number || ' AUCTION_TITLE :' || l_auction_title ||
          ' BID_TECH_SHORTLISTED :' || bidder.shortlist_flag || ' DOC_NUMBER :' || l_document_number ||
          ' TECHNICAL :' || get_technical_meaning || ' COMMERCIAL :' || get_commercial_meaning);
    END IF;

    -- start the workflow
    wf_engine.StartProcess(  itemtype => x_item_type,
             itemkey => x_item_key);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || '.notify_bidders_tech_complete',
      message  =>  ' Workflow process started');
    END IF;

    END LOOP;

EXCEPTION
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_exception,
                module  => g_module_prefix || '.notify_bidders_tech_complete',
                message => 'Exception occured in notify_bidders_tech_complete'
                || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
        END IF;

END notify_bidders_tech_complete;

FUNCTION GET_AUCTION_STATUS_DISPLAY(
p_auction_header_id IN pon_auction_headers_all.AUCTION_HEADER_ID%TYPE,
p_user_trading_partner_id IN pon_auction_headers_all.TRADING_PARTNER_ID%TYPE)
RETURN VARCHAR2
AS

l_is_buyer BOOLEAN;
l_two_part_flag pon_auction_headers_all.TWO_PART_FLAG%type;
l_technical_lock_status pon_auction_headers_all.TECHNICAL_LOCK_STATUS%type;
l_technical_evaluation_status pon_auction_headers_all.TECHNICAL_EVALUATION_STATUS%type;
l_message VARCHAR2(100);
l_commercial_lock_status pon_auction_headers_all.sealed_auction_status%type;
l_auction_status pon_auction_headers_all.auction_status%type;
l_auction_status2 pon_auction_headers_all.auction_status%type;
l_award_status pon_auction_headers_all.award_status%type;

l_auction_trading_partner_id pon_auction_headers_all.trading_partner_id%type;
l_technical_lock_meaning VARCHAR2(30);
l_commercial_lock_meaning VARCHAR2(30);

--Bug 17270381
l_parent_auc_status pon_auction_headers_all.auction_status%TYPE;
l_parent_auc_status2 pon_auction_headers_all.auction_status%TYPE;

BEGIN

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
        message  => 'Entering the function with params -- p_auction_header_id = ' || p_auction_header_id
                    || ' p_user_trading_partner_id = ' || p_user_trading_partner_id
            );
    END IF;

    l_message := 'NO MESSAGE FORMED YET FOR THIS AUCTION';

    SELECT nvl(ah2.two_part_flag,'N'),
           nvl(ah2.technical_lock_status,''),
           nvl(ah2.technical_evaluation_status,''),
           nvl(ah2.sealed_auction_status, ''),
           decode(nvl(ah2.is_paused, 'N'), 'Y', 'NOTCLOSED',
               decode(SIGN(ah2.close_bidding_date - sysdate) , -1, 'CLOSED', 'NOTCLOSED')), --auction status
           ah2.trading_partner_id,
           ah2.auction_status,
           ah2.award_status,
           decode(nvl(ah1.is_paused, 'N'), 'Y', 'NOTCLOSED',
               decode(SIGN(ah1.close_bidding_date - sysdate) , -1, 'CLOSED', 'NOTCLOSED')),
           ah1.auction_status
    INTO
           l_two_part_flag,
           l_technical_lock_status,
           l_technical_evaluation_status,
           l_commercial_lock_status,
           l_auction_status,
           l_auction_trading_partner_id,
           l_auction_status2,
           l_award_status,
           l_parent_auc_status,
           l_parent_auc_status2
     FROM pon_auction_headers_all ah1,
          pon_auction_headers_all ah2
     WHERE ah2.auction_header_id = p_auction_header_id
     AND   ah1.auction_header_id = ah2.AUCTION_HEADER_ID_ORIG_AMEND;

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
        message  => 'l_two_part_flag = ' || l_two_part_flag
                    || ' l_technical_lock_status = ' || l_technical_lock_status
                    || ' l_technical_evaluation_status = ' || l_technical_evaluation_status
                    || ' l_commercial_lock_status = ' || l_commercial_lock_status
                    || ' l_auction_status = ' || l_auction_status
                    || ' l_auction_trading_partner_id = ' || l_auction_trading_partner_id
                    || ' l_auction_status2 = ' || l_auction_status2
                    || ' l_award_status = ' || l_award_status
                    || ' l_parent_auc_status = ' || l_parent_auc_status
                    || ' l_parent_auc_status2 = ' || l_parent_auc_status2);
    END IF;

    -- buyer or supplier?
    if p_user_trading_partner_id = l_auction_trading_partner_id then
      l_is_buyer := true;
    else l_is_buyer := false;
    end if;

    -- if it is not a two part flag,
    IF l_two_part_flag <> 'Y'
        -- or two-part rfq with technical status locked
        OR l_technical_lock_status = 'LOCKED'
        -- or two-part for supplier with commercial part not locked
        OR (not l_is_buyer and l_commercial_lock_status <> 'LOCKED')
        -- or it is not closed yet
        OR l_auction_status <> 'CLOSED'
        -- or the award scenario is saved i.e award process has started
        -- or the award status is Completed
        -- or the award status is Qualified
        -- Note: though we need not check for the QUALIFIED because it's used only
        -- for RFIs, I add it here for readability
        OR l_award_status in ('AWARDED', 'PARTIAL', 'COMPLETED', 'QUALIFIED')
        -- or if the RFQ is cancelled
        OR (l_auction_status2 in ('CANCELLED') and l_commercial_lock_status in ('ACTIVE','UNLOCKED') )
        -- Fix for bug 17270381
        OR (l_parent_auc_status IN ('CLOSED') AND l_parent_auc_status2 IN ('ACTIVE') AND l_auction_status2 IN ('DRAFT'))

    THEN --{
      -- comes here when we should show the status old style.
      -- check if it is buyer
      IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
          message  => 'Old style status has to be shown for this auction'
              );
      END IF;

      IF (l_is_buyer) THEN

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
              message  => '1. Buyer Status'
                  );
          END IF;

        DECLARE
          l_buyer_meaning fnd_lookups.meaning%type;
          l_buyer_sealed_meaning fnd_lookups.meaning%type;

        BEGIN
          SELECT fl.meaning,
                 nvl2(pav.sealed_auction_status,
                      ' (' ||
                              (select meaning
                              from fnd_lookups
                              where lookup_type = 'PON_SEALED_AUCTION_STATUS'
                              and (
                                  (nvl(pav.two_part_flag, 'N') <> 'Y' and lookup_code = pav.sealed_auction_status)
                                  or lookup_code = pav.technical_lock_status))
                       ||')', '')
          INTO l_buyer_meaning, l_buyer_sealed_meaning
          FROM fnd_lookups fl, pon_auction_headers_all_v pav
          WHERE pav.auction_header_id = p_auction_header_id
            AND fl.lookup_type = 'PON_AUCTION_STATUS'
            AND fl.lookup_code = pav.negotiation_status;

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
              message  => 'l_buyer_meaning : ' || l_buyer_meaning
                          || '; l_buyer_sealed_meaning = ' || l_buyer_sealed_meaning
                  );
          END IF;
          -- set up message
          l_message := l_buyer_meaning || l_buyer_sealed_meaning;

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
              message  => 'l_message : ' || l_message
                  );
          END IF;

        END;

      -- not a buyer, generate message for supplier
      ELSE

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
              message  => '3. Supplier Status'
                  );
          END IF;

        DECLARE
          l_supp_meaning fnd_lookups.meaning%type;
          l_supp_sealed_meaning fnd_lookups.meaning%type;

        BEGIN
          SELECT fl.meaning, nvl2(pav.sealed_auction_status,
                              ' (' || (select meaning
                              from fnd_lookups
                              where lookup_type = 'PON_SEALED_AUCTION_STATUS'
                              and (
                                  (nvl(pav.two_part_flag, 'N') <> 'Y' and lookup_code = pav.sealed_auction_status)
                                  or lookup_code = decode(pav.sealed_auction_status, 'UNLOCKED', pav.sealed_auction_status,pav.technical_lock_status)) )
                              ||')', '')
          INTO l_supp_meaning, l_supp_sealed_meaning
          FROM fnd_lookups fl, pon_auction_headers_all_v pav
          WHERE pav.auction_header_id = p_auction_header_id
            AND fl.lookup_type = 'PON_AUCTION_STATUS'
            AND fl.lookup_code = pav.suppl_negotiation_status;

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
              message  => 'l_supp_meaning : ' || l_supp_meaning
                          || '; l_supp_sealed_meaning : ' || l_supp_sealed_meaning
                  );
          END IF;

          -- set up message
          l_message := l_supp_meaning || l_supp_sealed_meaning;

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
              message  => '4. l_message : ' || l_message
                  );
          END IF;

        END;

      END IF;
    --}
    ELSE  -- it is a two part RFQ, conditions for new-style messages are met
    --{

      IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
          message  => '5. This is a Two Part RFQ'
              );
      END IF;


      -- get the meanings of the technical and commercial locks for use later
      SELECT  (SELECT meaning from fnd_lookups
       WHERE lookup_type = 'PON_SEALED_AUCTION_STATUS' and
        lookup_code = nvl(technical_lock_status,'')), --technical status
       (SELECT meaning from fnd_lookups
       WHERE lookup_type = 'PON_SEALED_AUCTION_STATUS' and
       lookup_code = nvl(sealed_auction_status,'')) --commercial status
      INTO l_technical_lock_meaning, l_commercial_lock_meaning
      FROM pon_auction_headers_all
      WHERE auction_header_id = p_auction_header_id;

      IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
          message  => 'l_technical_lock_meaning : ' || l_technical_lock_meaning
                      || ';l_commercial_lock_meaning : ' || l_commercial_lock_meaning
              );
      END IF;

      -- Bug 6445077 : If the RFQ is cancelled after technically
      --unlocking or unsealing it, then the status has to be Cancelled (Technical Unlocked)
      --or Cancelled (Technical Unsealed)
      IF (l_auction_status2 in ('CANCELLED') ) THEN

        fnd_message.set_name('PON', 'PON_TWO_PART_CANCELLED');

        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
              message  => 'The auction is cancelled after technically unlocking/unsealing it');
        END IF;

        fnd_message.set_token('LOCK_STATUS', l_technical_lock_meaning);
        fnd_message.set_token('ROUND',get_technical_meaning);

        l_message := fnd_message.get;

      ELSE

              -- check if it is buyer
              if (l_is_buyer) then

                IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.level_statement,
                    module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                    message  => '6. Buyer Status '
                        );
                END IF;


                -- if auction_status is AUCTION_CLOSED and AWARD_STATUS is NO
                -- it means round is completed
                -- show Round Completed (Unlocked/Unsealed: Technical)
                if l_auction_status2 = 'AUCTION_CLOSED' and l_award_status = 'NO' then

                  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                      message  => 'l_auction_status2 :  '|| l_auction_status2
                                  ||'l_award_status :  '|| l_award_status
                                  ||'That is Round is complete. So showing Round Completed (Unlocked/Unsealed: Technical)'
                                  ||'; l_commercial_lock_status : ' || l_commercial_lock_status
                          );
                  END IF;

                  if l_commercial_lock_status = 'LOCKED' then

                    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                      FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                        message  => 'Auction has a commercial lock on it'
                            );
                    END IF;

                    fnd_message.set_name('PON', 'PON_TWO_PART_ROUNDCOMP');
                    fnd_message.set_token('SEALED_STATUS', l_technical_lock_meaning);
                    fnd_message.set_token('ROUND',get_technical_meaning);
                    l_message := fnd_message.get;

                    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                      FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                        message  => '7. l_message : '|| l_message
                            );
                    END IF;

                  else
                       fnd_message.set_name('PON', 'PON_AUC_ROUNDCOMP');
                      l_message := fnd_message.get || ' (' || l_commercial_lock_meaning || ')';

                      IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(log_level => FND_LOG.level_statement,
                          module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                          message  => '8. l_message : '|| l_message
                              );
                      END IF;

                  end if;
                      -- if technical evaluation is complete,
                      elsif l_technical_evaluation_status = 'COMPLETED' and l_commercial_lock_status = 'LOCKED' then

                        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                            module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                            message  => 'Technical evaluation is completed and the commercial lock is still on'
                                );
                        END IF;

                        -- show Evaluation Complete: Technical
                        fnd_message.set_name('PON', 'PON_EVALUATION_COMPLETE');
                        --fnd_message.set_token('EVALUATION_COMPLETE', eval_complete_meaning);
                        fnd_message.set_token('ROUND',get_technical_meaning);
                        l_message := fnd_message.get;

                        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                            module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                            message  => '9. l_message : ' ||l_message
                                );
                        END IF;


                      -- technical evaluation is in progress, check commercial seal status
                      elsif l_commercial_lock_status = 'LOCKED' then

                        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                            module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                            message  => 'Technical evaluation is in progress  and the commercial lock is still on'
                                );
                        END IF;

                        if l_technical_lock_status = 'ACTIVE' then

                          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(log_level => FND_LOG.level_statement,
                              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                              message  => 'Technical lock status is ACTIVE'
                                  );
                          END IF;

                          -- show Evaluation in Progress: Technical (Unsealed)
                          fnd_message.set_name('PON','PON_EVALUATION_IN_PROGRESS');
                          --fnd_message.set_token('EVALUATION_IN_PROGRESS',eval_in_prog_meaning);
                          fnd_message.set_token('ROUND',get_technical_meaning);
                          --fnd_message.set_token('SEALED_AUCTION_STATUS', l_commercial_lock_meaning);
                          l_message := fnd_message.get || ' (' || l_technical_lock_meaning || ')';

                          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(log_level => FND_LOG.level_statement,
                              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                              message  => '10. l_message : ' || l_message
                                  );
                          END IF;

                        else  -- technical unlocked, commercial locked
                          -- show Evaluation in Progress: Technical
                          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(log_level => FND_LOG.level_statement,
                              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                              message  => 'Technical unclocked but commercially locked '
                                  );
                          END IF;

                          fnd_message.set_name('PON', 'PON_EVALUATION_IN_PROGRESS');
                          --fnd_message.set_token('EVALUATION_IN_PROGRESS', eval_in_prog_meaning);
                          fnd_message.set_token('ROUND',get_technical_meaning);
                          l_message := fnd_message.get;

                          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(log_level => FND_LOG.level_statement,
                              module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                              message  => '11. l_message : ' ||l_message
                                  );
                          END IF;

                        end if;

                      -- commercial part unlocked
                      elsif l_commercial_lock_status = 'UNLOCKED' then
                        -- show Evaluation in Progress: Commercial

                        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                            module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                            message  => 'commercial part unlocked'
                                );
                        END IF;

                        fnd_message.set_name('PON', 'PON_EVALUATION_IN_PROGRESS');
                        --fnd_message.set_token('EVALUATION_IN_PROGRESS', eval_in_prog_meaning);
                        fnd_message.set_token('ROUND',get_commercial_meaning);
                        l_message := fnd_message.get;

                        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                            module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                            message  => '12. l_message'
                                );
                        END IF;

                -- commercial part unsealed
                      else
                  -- if auction_status is AUCTION_CLOSED and AWARD_STATUS is NO
                  -- it means round is completed
                  -- show Round Completed (Unsealed)
                        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                            module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                            message  => 'commercial unsealed ; Auction Statuses : '||
                            'l_auction_status2 ' || l_auction_status2 || '; l_award_status : ' || l_award_status
                            );
                        END IF;

                        -- show Evaluation in Progress: Commercial (Unsealed)
                        fnd_message.set_name('PON', 'PON_EVALUATION_IN_PROGRESS');
                        --fnd_message.set_token('EVALUATION_IN_PROGRESS', eval_in_prog_meaning);
                        fnd_message.set_token('ROUND',get_commercial_meaning);
                        l_message := fnd_message.get || ' (' || l_commercial_lock_meaning || ')';

                        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                            module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                            message  => 'l_message : ' || l_message);
                        END IF;

                      end if;

              -- is a supplier
              else

                  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                      message  => '14. Supplier Status');
                  END IF;

                declare
                  l_closed_meaning VARCHAR2(30);
                begin
                  -- show Closed (Unlocked: Technical) or Closed (Unsealed: Technical)
                  fnd_message.set_name('PON','PON_AUC_CLOSED_ROUND');
                  --fnd_message.set_token('CLOSED', l_closed_meaning);
                  fnd_message.set_token('SEALED_STATUS',l_technical_lock_meaning);
                  fnd_message.set_token('ROUND',get_technical_meaning);
                  l_message := fnd_message.get;

                  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
                      message  => '15. l_message  : ' || l_message );
                  END IF;

                END;
              END IF; -- if  is_buyer
    --}
      END IF;

    END IF;

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
        message  => 'Returning l_message : ' || l_message );
    END IF;

    return l_message;

  EXCEPTION
    WHEN OTHERS THEN

      IF (FND_LOG.level_unexpected>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_unexpected,
          module  =>  g_module_prefix || 'GET_AUCTION_STATUS_DISPLAY',
          message  => 'Exception encountered for auction : ' || p_auction_header_id
                      ||'and p_user_trading_partner_id : ' || p_user_trading_partner_id
                      ||' Returning l_message : ' || l_message);
      END IF;
      return l_message;

END GET_AUCTION_STATUS_DISPLAY;


PROCEDURE GET_MONITOR_IMAGE_AND_STATUS(
      p_auction_header_id     IN NUMBER,
      p_doctype_id IN NUMBER,
      p_bid_visibility         IN VARCHAR2,
      p_sealed_auction_status  IN VARCHAR2,
      p_auctioneer_id          IN NUMBER,
      p_viewer_id              IN NUMBER,
      p_has_items              IN VARCHAR2,
      p_doc_type               IN VARCHAR2,
      p_auction_status         IN VARCHAR2,
      p_view_by_date           IN DATE,
      p_open_bidding_date      IN DATE,
      p_has_scoring_teams_flag IN VARCHAR2,
      p_user_trading_partner_id IN NUMBER,
      x_buyer_monitor_image OUT NOCOPY VARCHAR2,
      x_auction_status_display OUT NOCOPY VARCHAR2)
AS
BEGIN

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_MONITOR_IMAGE_AND_STATUS',
        message  => 'Entering the function with params --'
                    || 'p_auction_header_id = ' || p_auction_header_id
                    || ';p_doctype_id = ' || p_doctype_id
                    || ';p_bid_visibility = ' || p_bid_visibility
                    || ';p_sealed_auction_status = ' || p_sealed_auction_status
                    || ';p_auctioneer_id = ' || p_auctioneer_id
                    || ';p_viewer_id = ' || p_viewer_id
                    || ';p_has_items = ' || p_has_items
                    || ';p_doc_type = ' || p_doc_type
                    || ';p_auction_status = ' || p_auction_status
                    || ';p_view_by_date = ' || p_view_by_date
                    || ';p_open_bidding_date = ' || p_open_bidding_date
                    || ';p_has_scoring_teams_flag = ' || p_has_scoring_teams_flag
                    || ';p_user_trading_partner_id = ' || p_user_trading_partner_id
            );
    END IF;

    x_buyer_monitor_image := PON_OA_UTIL_PKG.BUYER_MONITOR_IMAGE (p_doctype_id,
              p_bid_visibility         ,
              p_sealed_auction_status  ,
              p_auctioneer_id          ,
              p_viewer_id              ,
              p_has_items              ,
              p_doc_type               ,
              p_auction_status         ,
              p_view_by_date           ,
              p_open_bidding_date      ,
              p_auction_header_id     ,
              p_has_scoring_teams_flag);


    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_MONITOR_IMAGE_AND_STATUS',
        message  => 'x_buyer_monitor_image = ' || x_buyer_monitor_image);
    END IF;

    x_auction_status_display := GET_AUCTION_STATUS_DISPLAY(p_auction_header_id,
                      p_user_trading_partner_id);

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_MONITOR_IMAGE_AND_STATUS',
        message  => 'x_auction_status_display = ' || x_auction_status_display);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      IF (FND_LOG.level_unexpected>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_unexpected,
          module  =>  g_module_prefix || 'GET_MONITOR_IMAGE_AND_STATUS',
          message  => 'Exception encountered for auction : ' || p_auction_header_id);
      END IF;

END GET_MONITOR_IMAGE_AND_STATUS;

--========================================================================
-- PROCEDURE : GET_SUPPL_NEGOTIATION_STATUS
-- PARAMETERS:
--             p_auction_status - The auction_status column
--             p_is_paused - is_paused column
--             p_view_by_date - view_by_date column
--             p_open_bidding_date - open_bidding_date column
--             p_close_bidding_date - close_bidding_date column
--
-- COMMENT   : This procedure will be used in the pon_auction_headers_all_v
--             view to get the value for the suppl_negotiation_status
--             column in the view. Prior to the use of this function the
--             same code existed as decodes in the view itself.
--========================================================================
FUNCTION GET_SUPPL_NEGOTIATION_STATUS (
  p_auction_status IN VARCHAR2,
  p_is_paused IN VARCHAR2,
  p_view_by_date IN DATE,
  p_open_bidding_date IN DATE,
  p_close_bidding_date IN DATE
) RETURN VARCHAR2 IS -- {

l_module_name VARCHAR2(40) := 'GET_SUPPL_NEGOTIATION_STATUS';
l_return_value VARCHAR2(40);

BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entered procedure with p_auction_status = ' ||
                  p_auction_status || ', p_is_paused = ' || p_is_paused
                  || ', p_view_by_date = ' || p_view_by_date ||
                  ', p_open_bidding_date = ' || p_open_bidding_date ||
                  ', p_close_bidding_date = ' || p_close_bidding_date);
  END IF; --}

  IF (p_auction_status = 'CANCELLED') THEN -- {
    l_return_value := 'CANCELLED';
  ELSIF (p_auction_status = 'AMENDED') THEN
    l_return_value := 'AMENDED';
  ELSIF (p_auction_status = 'DRAFT') THEN
    l_return_value := 'DRAFT';
  ELSIF (nvl (p_is_paused, 'N') = 'Y') THEN
    l_return_value := 'PAUSED';
  ELSIF (sign (nvl (p_view_by_date, p_open_bidding_date) - sysdate) = 1) THEN
    l_return_value := 'SUBMITTED';
  ELSIF (sign (p_open_bidding_date - sysdate) = 1) THEN
    l_return_value := 'PREVIEW';
  ELSIF (sign (p_close_bidding_date - sysdate) = 1) THEN
    l_return_value := 'ACTIVE';
  ELSE
    l_return_value := 'CLOSED';
  END IF; --}

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Returning value = ' || l_return_value);
  END IF; --}

  RETURN l_return_value;

END; -- }

--========================================================================
-- PROCEDURE : GET_NEGOTIATION_STATUS
-- PARAMETERS:
--             p_auction_status - The auction_status column
--             p_is_paused - is_paused column
--             p_view_by_date - view_by_date column
--             p_open_bidding_date - open_bidding_date column
--             p_close_bidding_date - close_bidding_date column
--             p_award_status - award_status column
--             p_award_approval_status - award_approval_status column
--             p_outcome_status - outcome_status column
--
-- COMMENT   : This procedure will be used in the pon_auction_headers_all_v
--             view to get the value for the negotiation_status
--             column in the view. Prior to the use of this function the
--             same code existed as decodes in the view itself.
--========================================================================
FUNCTION GET_NEGOTIATION_STATUS (
  p_auction_status VARCHAR2,
  p_is_paused VARCHAR2,
  p_view_by_date DATE,
  p_open_bidding_date DATE,
  p_close_bidding_date DATE,
  p_award_status VARCHAR2,
  p_award_approval_status VARCHAR2,
  p_outcome_status VARCHAR2
) RETURN VARCHAR2 IS -- {

l_module_name VARCHAR2(40) := 'GET_NEGOTIATION_STATUS';
l_return_value VARCHAR2(40);

BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entered with p_auction_status = ' || p_auction_status ||
                  ', p_is_paused = ' || p_is_paused || ', p_view_by_date = ' ||
                  p_view_by_date || ', p_open_bidding_date = ' || p_open_bidding_date
                  || ', p_close_bidding_date = ' || p_close_bidding_date ||
		  'p_award_approval_status = ' || p_award_approval_status ||
		  'p_award_status = ' || p_award_status || ', p_outcome_status = '
                  || p_outcome_status);
  END IF; --}

  IF (p_auction_status = 'CANCELLED') THEN -- {
    l_return_value :=  'CANCELLED';
  ELSIF (p_auction_status = 'AMENDED') THEN
    l_return_value :=  'AMENDED';
  ELSIF (p_auction_status = 'DRAFT') THEN
    l_return_value :=  'DRAFT';
  ELSIF (nvl (p_is_paused, 'N') = 'Y') THEN
    l_return_value :=  'PAUSED';
  ELSIF (sign (nvl (p_view_by_date, p_open_bidding_date) - sysdate) = 1) THEN
    l_return_value :=  'SUBMITTED';
  ELSIF (sign (p_open_bidding_date - sysdate) = 1) THEN
    l_return_value :=  'PREVIEW';
  ELSIF (sign (p_close_bidding_date - sysdate) = 1) THEN
    l_return_value :=  'ACTIVE';
  ELSIF (p_auction_status = 'ACTIVE') THEN
    IF (p_award_status = 'NO') THEN -- {
      IF (p_award_approval_status = 'APPROVED') THEN -- {
        l_return_value :=  'AWARD_APPROVED';
      ELSIF (p_award_approval_status = 'REJECTED') THEN
        l_return_value :=  'AWARD_REJECTED';
      ELSIF (p_award_approval_status = 'INPROCESS') THEN
        l_return_value :=  'AWARD_APPROVAL_INPROCESS';
      ELSE
        l_return_value :=  'CLOSED';
      END IF; -- }
    ELSIF (p_award_status = 'PARTIAL') THEN
      IF (p_award_approval_status = 'APPROVED') THEN -- {
        l_return_value :=  'AWARD_APPROVED';
      ELSIF (p_award_approval_status = 'REJECTED') THEN
        l_return_value :=  'AWARD_REJECTED';
      ELSIF (p_award_approval_status = 'INPROCESS') THEN
        l_return_value :=  'AWARD_APPROVAL_INPROCESS';
      ELSE
        l_return_value :=  'AWARD_IN_PROG';
      END IF; -- }
    ELSIF (p_award_status = 'AWARDED') THEN
      IF (p_award_approval_status = 'APPROVED') THEN -- {
        l_return_value :=  'AWARD_APPROVED';
      ELSIF (p_award_approval_status = 'REJECTED') THEN
        l_return_value :=  'AWARD_REJECTED';
      ELSIF (p_award_approval_status = 'INPROCESS') THEN
        l_return_value :=  'AWARD_APPROVAL_INPROCESS';
      ELSE
        l_return_value :=  'AWARD_IN_PROG';
      END IF; -- }
    END IF; -- }
  ELSIF (p_auction_status = 'AUCTION_CLOSED') THEN
    IF (p_award_status = 'NO') THEN -- {
      l_return_value :=  'ROUND_COMPLETED';
    ELSIF (p_award_status = 'QUALIFIED') THEN
      l_return_value :=  'RFI_COMPLETED';
    ELSIF (p_outcome_status = 'NOT_ALLOCATED') THEN
      l_return_value :=  'AWARD_COMPLETED';
    ELSIF (p_outcome_status = 'PARTIALLY_ALLOCATED') THEN
      l_return_value :=  'ALLOCATION_IN_PROG';
    ELSIF (p_outcome_status = 'ALLOCATED') THEN
      l_return_value :=  'ALLOCATION_IN_PROG';
    ELSIF (p_outcome_status = 'ALLOCATION_NOT_REQUIRED') THEN
      l_return_value :=  'AWARD_COMPLETED';
    ELSE
      l_return_value :=  p_outcome_status;
    END IF; -- }
  END IF; -- }

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Returning ' || l_return_value);
  END IF; --}

  RETURN l_return_value;

END; -- }

/*============================================================================================================*
 * PROCEDURE : GET_DEFAULT_TIERS_INDICATOR                                                                    *
 * PARAMETERS:                                                                                                *
 *             p_contract_type - outcome of the negotiation                                                   *
 *             p_price_breaks_enabled - to indicate if price breaks are applicable as per po style            *
 *             p_qty_price_tiers_enabled - to indicate if price tiers are applicable as per neg style         *
 *             p_doctype_id - document type id of the negotiation                                             *
 *             x_price_tiers_indicator - default price tiers indicator value.                                 *
 *                                                                                                            *
 * COMMENT   : This procedure will be used in getting the default  price tier indicator value.                *
 *             It's used in plsql routines where new negotiation created from autocreation and renegotiation. *
 *             The logic is same as AuctionHeadersAllEO.getPriceTiersPoplist. Only difference is that we      *
 *             don't have to return the poplist here. So few conditions where default values is same can be   *
 *             clubbeb together.                                                                              *
 * ===========================================================================================================*/

PROCEDURE GET_DEFAULT_TIERS_INDICATOR (
  p_contract_type                   IN VARCHAR2,
  p_price_breaks_enabled            IN VARCHAR2,
  p_qty_price_tiers_enabled         IN VARCHAR2,
  p_doctype_id                      IN NUMBER,
  x_price_tiers_indicator           OUT NOCOPY VARCHAR2
) IS -- {

l_module_name VARCHAR2(40) := 'GET_DEFAULT_TIERS_INDICATOR';
l_rfi_doctype_id   NUMBER;

BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entered with p_contract_type = ' || p_contract_type ||
                  ', p_price_breaks_enabled = ' || p_price_breaks_enabled || ', p_qty_price_tiers_enabled = ' ||
                  p_qty_price_tiers_enabled || ', p_doctype_id = ' || p_doctype_id);
  END IF; --}

  --
  -- To check if given doctype_id corresponds to a RFI we need to select doctype id for RFI from PON_AUC_DOCTYPES
  --

  SELECT doctype_id
  INTO l_rfi_doctype_id
  FROM PON_AUC_DOCTYPES
  WHERE doctype_group_name = 'REQUEST_FOR_INFORMATION';

  --
  -- Default price tiers value is Null if neg is
  -- 1. RFI  OR
  -- 2. SPO and Sourcing style does not allows quantity based tiers
  -- 3. BPA/CPA and Sourcing style doe not allows quantity based tiers and PO Flag disables price breaks
  --

  IF ( (p_doctype_id = l_rfi_doctype_id) OR (p_contract_type = 'STANDARD' and p_qty_price_tiers_enabled = 'N')
        OR (p_contract_type <> 'STANDARD' and p_qty_price_tiers_enabled = 'N' and p_price_breaks_enabled = 'N') ) THEN --{

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => '(Neg is RFI) or(SPO and Sourcing style does not allows quantity based tiers.) or ' ||
                         '(BPA/CPA and Sourcing style doe not allows quantity based tiers and PO Flag disables price breaks)');
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => ' Setting the default price tiers indicator as null.');
        END IF; --}

        x_price_tiers_indicator := null;

  -- } End of is rfi or spo ....

  --
  -- Default value is PRICE_BREAKS if
  -- 1. a BPA/CPA AND
  -- 2. PO Flag enables price breaks
  --

  ELSIF ( p_contract_type <> 'STANDARD' and p_price_breaks_enabled = 'Y') THEN --{

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => 'BPA/CPA; price breaks are enabled. Setting default value to price_breaks');
        END IF; --}

        x_price_tiers_indicator := 'PRICE_BREAKS';

  --} End of else if

  --
  -- Default value is NONE if
  -- Sourcing style allows quantity based tiers  and
  -- 1. a BPA/CPA AND PO Flag disables price breaks  OR
  -- 2. a SPO
  --

  ELSE  --{

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => 'Price tiers are enabled and ( price breaks are disabled for BPA/CPA OR is an SPO) Setting default value to none');
        END IF; --}

        x_price_tiers_indicator := 'NONE';

  END IF;   --} End of else

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Returning to the caller with  x_price_tiers_indicator as '|| x_price_tiers_indicator);
  END IF; --}

END GET_DEFAULT_TIERS_INDICATOR; -- }

-- adsahay: bug 6374353
-- populate the two part meanings' cache
procedure init_two_part_cache
as
begin
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_procedure,
        module  =>  g_module_prefix || 'init_two_part_cache',
        message  => 'Entered procedure init_two_part_cache');
    END IF; --}

    SELECT flv1.LANGUAGE, flv1.meaning AS technical_meaning, flv2.meaning AS commercial_meaning
    BULK COLLECT INTO g_two_part_cache
    FROM fnd_lookup_values flv1, fnd_lookup_values flv2
    WHERE flv1.lookup_type='PON_TWO_PART_TYPE'
    AND flv2.lookup_type=flv1.lookup_type
    AND flv1.lookup_code='TECHNICAL'
    AND flv2.lookup_code='COMMERCIAL'
    AND flv1.LANGUAGE=flv2.LANGUAGE;

    g_tp_cache_rec := g_two_part_cache(1); -- first time initialisation

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_procedure,
        module  =>  g_module_prefix || 'init_two_part_cache',
        message  => 'Exiting procedure init_two_part_cache');
    END IF; --}

end init_two_part_cache;

-- adsahay: bug 6374353
-- update record from from cache table when needed
PROCEDURE update_cache_rec
AS
BEGIN
  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'update_cache_rec',
      message  => 'Entered procedure update_cache_rec');
  END IF; --}

  IF (g_tp_cache_rec.language <> USERENV('LANG')) THEN -- {

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'update_cache_rec',
        message  => 'User session language is now ' || USERENV('LANG'));
    END IF; --}

    FOR i in 1..g_two_part_cache.COUNT LOOP
      IF (g_two_part_cache(i).language = USERENV('LANG')) THEN
        g_tp_cache_rec := g_two_part_cache(i);
        exit;        -- if we got our values, then break loop.
      END IF;
    END LOOP;
  END IF; -- }

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'update_cache_rec',
      message  => 'Exiting procedure update_cache_rec');
  END IF; --}
END update_cache_rec;

-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_PON_DSQBID_BODY
--Procedure Usage:
--  Bid Disqualification Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_PON_DSQBID_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_disqualify_reason    varchar2(2000) := '';
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_view_quote_url VARCHAR2(2000);
x_l_view_quote_url VARCHAR2(2000);
x_l_view_quote_txt VARCHAR2(2000);
x_l_view_quote_txt_hb VARCHAR2(2000);
x_disqualify_date    DATE;
x_bid_name           VARCHAR2(10);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);
x_disqualify_date_format VARCHAR2(80);
x_notification_id NUMBER;

--SLM UI Enhancement
l_neg_assess_doctype VARCHAR2(15);

BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');

  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');

  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE_BIDDER');

  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;


  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_BIDDER');

  IF(x_auction_end_date IS null)  then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;

  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');

  x_disqualify_reason := wf_engine.GetItemAttrText(itemtype => l_item_type,
	                                                itemkey  => l_item_key,
	                                                aname    => 'DISQUALIFY_REASON');

  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'BIDDER_TP_NAME');

  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'VIEW_QUOTE_URL');

    x_l_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                 itemkey  => l_item_key,
                                                 aname    => 'LOGIN_VIEW_DETAILS_URL');
    x_l_view_quote_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

  x_l_view_quote_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');

  x_disqualify_date := wf_engine.GetItemAttrDate (itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'BIDDER_DISQUALIFY_DATE');


  x_bid_name := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                          itemkey  => l_item_key,
                                          aname    => 'BID');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

 --SLM UI Enhancement
 l_neg_assess_doctype := PON_SLM_UTIL_PKG.GET_SLM_DOC_TYPE_ATTRIBUTE (p_itemtype => l_item_type,
                                                                      p_itemkey  => l_item_key);

 x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 x_disqualify_date_format:= to_char(x_disqualify_date,'Month dd, yyyy hh:mi am');

 --Added for Bug 10388725
 --Replacing &#NID in the Response Details URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_view_quote_url:=REPLACE(x_view_quote_url,'&#NID',x_notification_id);
    x_l_view_quote_url:=REPLACE(x_l_view_quote_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_view_quote_url:=regexp_replace(x_view_quote_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_disqualify_date = ' ||x_disqualify_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'VIEW_QUOTE_URL_SUPPLIER = ' ||x_view_quote_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_bid_name = ' ||x_bid_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_DSQBID_BODY',message  => 'x_disqualify_reason = ' ||x_disqualify_reason );
  END IF;

 IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_WF_AUC_DSQBID_HB');

        --SLM UI Enhancement
        fnd_message.set_token('SLM_DOC_TYPE',l_neg_assess_doctype);

        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('DISQUALIFY_DATE',x_disqualify_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('DISQUALIFY_REASON',x_disqualify_reason);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_l_view_quote_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_WF_AUC_DSQBID_TB');

        --SLM UI Enhancement
        fnd_message.set_token('SLM_DOC_TYPE',l_neg_assess_doctype);

        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('DISQUALIFY_DATE',x_disqualify_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('DISQUALIFY_REASON',x_disqualify_reason);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_l_view_quote_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_PON_DSQBID_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_PON_ARI_UNINVITED_BODY
--Procedure Usage:
-- Additional Round Invitation- Uninvited Participants Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_PON_ARI_UNINVITED_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);

x_refund_supplier     VARCHAR2(2000); --bug 8613271

BEGIN


  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));


  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');
  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;


  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');


  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');

  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;


  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                 itemkey  => l_item_key,
					                                     aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                      aname    => 'STAGGERED_CLOSE_NOTE');

  x_refund_supplier := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'REFUND_SUPPLIER');

 x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_PON_ARI_UNINVITED_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
  END IF;

 IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_NON_INV_NEW_RND_START_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_NON_INV_NEW_RND_START_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_PON_ARI_UNINVITED_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_AWARD_LINES_BODY
--Procedure Usage:
--  Awarding-WithLines Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE GEN_AWARD_LINES_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_view_quote_url VARCHAR2(2000);
x_l_view_quote_url VARCHAR2(2000);
x_l_view_quote_txt VARCHAR2(2000);
x_l_view_quote_txt_hb VARCHAR2(2000);
x_bid_name           VARCHAR2(10);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_bid_id           NUMBER;
x_bid_caps      VARCHAR2(10);
x_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE;
x_award_date PON_AUCTION_HEADERS_ALL.AWARD_DATE%TYPE;
x_number_awarded	NUMBER;
x_number_rejected	NUMBER;
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);
x_award_date_format VARCHAR2(80);
x_notification_id NUMBER;
BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));



  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
                                 				      aname      => 'PREVIEW_DATE_TZ');

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE_TZ');

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');

  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE_AUCTION');

  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                 itemkey  => l_item_key,
                                                 aname    => 'VIEW_QUOTE_URL');
  x_l_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                 itemkey  => l_item_key,
                                                 aname    => 'LOGIN_VIEW_DETAILS_URL');
    x_l_view_quote_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

  x_l_view_quote_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');


  x_bid_name := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                           itemkey  => l_item_key,
                                           aname    => 'BID');

  x_award_date:=wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                          itemkey    => l_item_key,
                                          aname      => 'AWARD_DATE_TZ');

  x_bid_id:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                        itemkey    => l_item_key,
                                        aname      => 'BID_ID');

  x_bid_caps:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'BID_CAPS');

  x_note_to_supplier:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                 itemkey    => l_item_key,
                                                 aname      => 'NOTE_TO_SUPPLIER');

  x_number_awarded:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                                 itemkey    => l_item_key,
                                                 aname      => 'NUMBER_AWARDED');

  x_number_rejected:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'NUMBER_REJECTED');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                       itemkey  => l_item_key,
                                                       aname    => 'STAGGERED_CLOSE_NOTE');

 x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 x_award_date_format := to_char(x_award_date,'Month dd, yyyy hh:mi am');

 --Added for Bug 10388725
 --Replacing &#NID in the Response Details URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_view_quote_url:=REPLACE(x_view_quote_url,'&#NID',x_notification_id);
	x_l_view_quote_url:=REPLACE(x_l_view_quote_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_view_quote_url:=regexp_replace(x_view_quote_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_award_date_format = ' ||x_award_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_bid_id = ' ||x_bid_id );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_bid_caps = ' ||x_bid_caps );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_note_to_supplier = ' ||x_note_to_supplier );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_number_rejected = ' ||x_number_rejected );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_number_awarded = ' ||x_number_awarded );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_view_quote_url = ' ||x_view_quote_url );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_l_view_quote_url = ' ||x_l_view_quote_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_LINES_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
  END IF;

 IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_AUC_WF_AWARD_L_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('NUMBER_AWARDED',x_number_awarded);
        fnd_message.set_token('NUMBER_REJECTED',x_number_rejected);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_l_view_quote_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
	fnd_message.set_name('PON','PON_AUC_WF_AWARD_L_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('NUMBER_AWARDED',x_number_awarded);
        fnd_message.set_token('NUMBER_REJECTED',x_number_rejected);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_l_view_quote_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_AWARD_LINES_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_AWARD_NOLINES_BODY
--Procedure Usage:
--  Awarding-WithoutLines Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_AWARD_NOLINES_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_view_quote_url VARCHAR2(2000);
x_l_view_quote_url VARCHAR2(2000);
x_l_view_quote_txt VARCHAR2(2000);
x_l_view_quote_txt_hb VARCHAR2(2000);
x_bid_name           VARCHAR2(10);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_bid_id           NUMBER;
x_bid_caps      VARCHAR2(10);
x_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE;
x_award_date PON_AUCTION_HEADERS_ALL.AWARD_DATE%TYPE;
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);
x_award_date_format VARCHAR2(80);
x_notification_id NUMBER;
BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));


  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');


  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');


  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');



  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE_TZ');


  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');


  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE_AUCTION');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'VIEW_QUOTE_URL');

    x_l_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                 itemkey  => l_item_key,
                                                 aname    => 'LOGIN_VIEW_DETAILS_URL');
    x_l_view_quote_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

  x_l_view_quote_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');

  x_bid_name := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                          itemkey  => l_item_key,
                                          aname    => 'BID');


  x_award_date:=wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                          itemkey    => l_item_key,
                                          aname      => 'AWARD_DATE_TZ');


  x_bid_id:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                        itemkey    => l_item_key,
                                        aname      => 'BID_ID');

  x_bid_caps:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                        itemkey    => l_item_key,
                                        aname      => 'BID_CAPS');

  x_note_to_supplier:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NOTE_TO_SUPPLIER');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

 x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 x_award_date_format := to_char(x_award_date,'Month dd, yyyy hh:mi am');


 --Added for Bug 10388725
 --Replacing &#NID in the Response Details URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_view_quote_url:=REPLACE(x_view_quote_url,'&#NID',x_notification_id);
	x_l_view_quote_url:=REPLACE(x_l_view_quote_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_view_quote_url:=regexp_replace(x_view_quote_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_award_date_format = ' ||x_award_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_bid_id = ' ||x_bid_id );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_bid_caps = ' ||x_bid_caps );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_note_to_supplier = ' ||x_note_to_supplier );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_NOLINES_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
  END IF;

 IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_AUC_WF_AWARD_NL_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_l_view_quote_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
	      fnd_message.set_name('PON','PON_AUC_WF_AWARD_NL_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_l_view_quote_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_AWARD_NOLINES_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_AWARD_EVENT_LINES_BODY
--Procedure Usage:
--  Awarding-Event WithLines Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------

PROCEDURE GEN_AWARD_EVENT_LINES_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_view_quote_url VARCHAR2(2000);
x_l_view_quote_url VARCHAR2(2000);
x_l_view_quote_txt VARCHAR2(2000);
x_l_view_quote_txt_hb VARCHAR2(2000);
x_bid_name           VARCHAR2(10);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_bid_id           NUMBER;
x_bid_caps      VARCHAR2(10);
x_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE;
x_award_date PON_AUCTION_HEADERS_ALL.AWARD_DATE%TYPE;
x_event_title       varchar2(80);
x_number_awarded	NUMBER;
x_number_rejected	NUMBER;
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);
x_award_date_format VARCHAR2(80);
x_notification_id NUMBER;
BEGIN


  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));


  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');


  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE_AUCTION');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'VIEW_QUOTE_URL');

    x_l_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                 itemkey  => l_item_key,
                                                 aname    => 'LOGIN_VIEW_DETAILS_URL');
    x_l_view_quote_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

   x_l_view_quote_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');

  x_bid_name := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                          itemkey  => l_item_key,
                                          aname    => 'BID');

  x_award_date:=wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                          itemkey    => l_item_key,
                                          aname      => 'AWARD_DATE_TZ');

  x_event_title:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                            itemkey    => l_item_key,
                                            aname      => 'EVENT_TITLE');

  x_bid_id:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'BID_ID');

  x_bid_caps:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'BID_CAPS');

  x_note_to_supplier:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                 itemkey    => l_item_key,
                                                 aname      => 'NOTE_TO_SUPPLIER');
 -- Bug 16199497
  x_number_awarded:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                                 itemkey    => l_item_key,
                                                 aname      => 'NUMBER_AWARDED');

  x_number_rejected:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'NUMBER_REJECTED');
 -- Bug 16199497 -End

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                       itemkey  => l_item_key,
                                                       aname    => 'STAGGERED_CLOSE_NOTE');

 x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 x_award_date_format := to_char(x_award_date,'Month dd, yyyy hh:mi am');

  --Added for Bug 10388725
 --Replacing &#NID in the Response Details URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_view_quote_url:=REPLACE(x_view_quote_url,'&#NID',x_notification_id);
    x_l_view_quote_url:=REPLACE(x_l_view_quote_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_view_quote_url:=regexp_replace(x_view_quote_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_award_date_format = ' ||x_award_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_auction_end_date_format = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_bid_id = ' ||x_bid_id );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_bid_caps = ' ||x_bid_caps );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_note_to_supplier = ' ||x_note_to_supplier );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_number_rejected = ' ||x_number_rejected );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_number_awarded = ' ||x_number_awarded );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_view_quote_url = ' ||x_view_quote_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_event_title = ' ||x_event_title );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_LINES_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
  END IF;

 IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_AUC_WF_AWARD_EVENT_L_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('EVENT_TITLE',x_event_title);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('NUMBER_AWARDED',x_number_awarded);
        fnd_message.set_token('NUMBER_REJECTED',x_number_rejected);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_l_view_quote_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
	fnd_message.set_name('PON','PON_AUC_WF_AWARD_EVENT_L_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('EVENT_TITLE',x_event_title);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('NUMBER_AWARDED',x_number_awarded);
        fnd_message.set_token('NUMBER_REJECTED',x_number_rejected);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_l_view_quote_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_AWARD_EVENT_LINES_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_AWARD_EVENT_NOLINES_BODY
--Procedure Usage:
--  Awarding-Event WithoutLines Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_AWARD_EVENT_NOLINES_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_view_quote_url VARCHAR2(2000);
x_l_view_quote_url VARCHAR2(2000);
x_l_view_quote_txt VARCHAR2(2000);
x_l_view_quote_txt_hb VARCHAR2(2000);
x_bid_name           VARCHAR2(10);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_bid_id           NUMBER;
x_bid_caps      VARCHAR2(10);
x_note_to_supplier PON_BID_HEADERS.NOTE_TO_SUPPLIER%TYPE;
x_award_date PON_AUCTION_HEADERS_ALL.AWARD_DATE%TYPE;
x_event_title       varchar2(80);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);
x_award_date_format VARCHAR2(80);
x_notification_id NUMBER;
BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');


  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'VIEW_QUOTE_URL');
    x_l_view_quote_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                 itemkey  => l_item_key,
                                                 aname    => 'LOGIN_VIEW_DETAILS_URL');
    x_l_view_quote_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

  x_l_view_quote_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');

  x_bid_name := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                          itemkey  => l_item_key,
                                          aname    => 'BID');

  x_award_date:=wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                          itemkey    => l_item_key,
                                          aname      => 'AWARD_DATE_TZ');

  x_bid_id:=wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                        itemkey    => l_item_key,
                                        aname      => 'BID_ID');

  x_bid_caps:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                        itemkey    => l_item_key,
                                        aname      => 'BID_CAPS');

  x_event_title:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                            itemkey    => l_item_key,
                                            aname      => 'EVENT_TITLE');

  x_note_to_supplier:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NOTE_TO_SUPPLIER');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

 x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 x_award_date_format := to_char(x_award_date,'Month dd, yyyy hh:mi am');

 --Added for Bug 10388725
 --Replacing &#NID in the Response Details URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_view_quote_url:=REPLACE(x_view_quote_url,'&#NID',x_notification_id);
	x_l_view_quote_url:=REPLACE(x_l_view_quote_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_view_quote_url:=regexp_replace(x_view_quote_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_auction_end_date = ' ||x_award_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_bid_id = ' ||x_bid_id );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_bid_caps = ' ||x_bid_caps );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_event_title = ' ||x_event_title );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_note_to_supplier = ' ||x_note_to_supplier );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AWARD_EVENT_NOLINES_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
  END IF;

IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_AUC_WF_AWARD_EVENT_NL_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('EVENT_TITLE',x_event_title);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_l_view_quote_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
	fnd_message.set_name('PON','PON_AUC_WF_AWARD_EVENT_NL_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('EVENT_TITLE',x_event_title);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('AWARD_DATE',x_award_date_format);
        fnd_message.set_token('BID_CAPS',x_bid_caps);
        fnd_message.set_token('BID_ID',x_bid_id);
        fnd_message.set_token('NOTE_TO_SUPPLIER',x_note_to_supplier);
        fnd_message.set_token('VIEW_QUOTE_URL_SUPPLIER',x_view_quote_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_l_view_quote_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_l_view_quote_url);
		END IF;
        fnd_message.set_token('BID',x_bid_name);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_AWARD_EVENT_NOLINES_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_AUC_AMEND_BODY
--Procedure Usage:
--  Amendment Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_AUC_AMEND_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_neg_summary_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone_disp VARCHAR2(240);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);

x_refund_supplier     VARCHAR2(2000); -- bug 8613271
x_notification_id number;
x_login_amend_sum_url VARCHAR2(2000);
x_login_amend_sum_txt VARCHAR2(2000);
x_login_amend_sum_txt_hb VARCHAR2(2000);

BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                    itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');

  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');
  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;


  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;

  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');

  x_neg_summary_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'NET_CHANGES_URL');

  	--14572394
  x_login_amend_sum_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NET_CHANGES_URL');

  x_login_amend_sum_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_AMEND_DTLS_TB');

  x_login_amend_sum_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_AMEND_DTLS_HB');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_refund_supplier := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'REFUND_SUPPLIER');

 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
    x_login_amend_sum_url:=REPLACE(x_login_amend_sum_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;


   IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_login_amend_sum_txt = ' ||x_login_amend_sum_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_login_amend_sum_txt = ' ||x_login_amend_sum_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY',message  => 'x_login_amend_sum_url = ' ||x_login_amend_sum_url );

  END IF;

 IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_AMENDMENT_START_HB');
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_AMEND_DTLS_HB',x_login_amend_sum_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_amend_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
	fnd_message.set_name('PON','PON_AMENDMENT_START_TB');
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_AMEND_DTLS_TB',x_login_amend_sum_txt);
        IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_amend_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_AUC_AMEND_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_INVITE_REQ_SUPP_RESP_BODY
--Procedure Usage:
--  Invite Requested suppliers response Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_INVITE_REQ_SUPP_RESP_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_ack_participation_url VARCHAR2(2000);
x_neg_summary_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);

-- Bug 9309785
x_auction_title            pon_auction_headers_all.auction_title%TYPE;
x_doc_number               pon_auction_headers_all.document_number%TYPE;
x_auction_owner_tp_name    VARCHAR2(640);
x_isp_new_supplier_reg_url VARCHAR2(500);

x_notification_id number;

x_login_neg_summary_url VARCHAR2(2000);
x_login_neg_summary_txt VARCHAR2(2000);
x_login_neg_summary_txt_hb VARCHAR2(2000);

-- Bug 17525991
x_auction_header_id     NUMBER;
x_supp_reg_qual_flag    pon_auction_headers_all.supp_reg_qual_flag%TYPE;

BEGIN


  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  -- Begin Bug 17525991
  x_auction_header_id := wf_engine.GetItemAttrNumber (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                      aname    => 'AUCTION_ID');
  BEGIN
    SELECT supp_reg_qual_flag
    INTO x_supp_reg_qual_flag
    FROM pon_auction_headers_all
    WHERE auction_header_id = x_auction_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_supp_reg_qual_flag := NULL;
  END;
  -- End Bug 17525991

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');
  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');
  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;


  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NEG_SUMMARY_URL');

	--14572394
  x_login_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_URL');

  x_login_neg_summary_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

  x_login_neg_summary_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');

  x_ack_participation_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'ACK_PARTICIPATION_URL');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
  x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
  x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');

  -- Begin Bug 9309785
  x_auction_title := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'AUCTION_TITLE');

  x_doc_number := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                             itemkey  => l_item_key,
                                             aname    => 'DOC_NUMBER');

  x_auction_owner_tp_name := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'PREPARER_TP_NAME');

  x_isp_new_supplier_reg_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                           itemkey  => l_item_key,
                                                           aname    => 'ISP_NEW_SUPPLIER_REG_URL');
  -- End Bug 9309785
  --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;

IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
    x_login_neg_summary_url:=REPLACE(x_login_neg_summary_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_ack_participation_url = ' ||x_ack_participation_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_login_neg_summary_txt = ' ||x_login_neg_summary_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_login_neg_summary_txt = ' ||x_login_neg_summary_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_REQ_SUPP_RESP_BODY',message  => 'x_login_neg_summary_url = ' ||x_login_neg_summary_url );

  END IF;

IF display_type = 'text/html' THEN
      l_disp_type:= display_type;

      -- Begin Bug 9309785
      -- Use a different body for Supplier Hub
      -- Bug 17525991
      -- Use different body only for Supplier Registration and Pre-Qualification RFI
      IF (x_supp_reg_qual_flag = 'Y') THEN
        fnd_message.set_name('PON','PON_SM_INVITE_REQ_SUPP_RESP_HB');
        fnd_message.set_token('AUCTION_TITLE', x_auction_title);
        fnd_message.set_token('DOC_NUMBER', x_doc_number);
        fnd_message.set_token('PREPARER_TP_NAME',x_auction_owner_tp_name);
        fnd_message.set_token('ISP_NEW_SUPPLIER_REG_URL',x_isp_new_supplier_reg_url);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
      ELSE
        fnd_message.set_name('PON','PON_INVITE_REQ_SUPP_RESP_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('ACK_PARTICIPATION_URL',x_ack_participation_url);
        fnd_message.set_token('NEG_SUMMARY_URL',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_login_neg_summary_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_login_neg_summary_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
      END IF;
      -- End Bug 9309785

        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  ELSE
        l_disp_type:= display_type;

      -- Begin Bug 9309785
      -- Use a different body for Supplier Hub
      -- Bug 17525991
      -- Use different body only for Supplier Registration and Pre-Qualification RFI
      IF (x_supp_reg_qual_flag = 'Y') THEN
        fnd_message.set_name('PON','PON_SM_INVITE_REQ_SUPP_RESP_TB');
        fnd_message.set_token('AUCTION_TITLE', x_auction_title);
        fnd_message.set_token('DOC_NUMBER', x_doc_number);
        fnd_message.set_token('PREPARER_TP_NAME',x_auction_owner_tp_name);
        fnd_message.set_token('ISP_NEW_SUPPLIER_REG_URL',x_isp_new_supplier_reg_url);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
      ELSE
	fnd_message.set_name('PON','PON_INVITE_REQ_SUPP_RESP_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('ACK_PARTICIPATION_URL',x_ack_participation_url);
        fnd_message.set_token('NEG_SUMMARY_URL',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_login_neg_summary_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_login_neg_summary_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
      END IF;
      -- End Bug 9309785

        l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_INVITE_REQ_SUPP_RESP_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_INVITE_CONT_RESP_BODY
--Procedure Usage:
--  Invite Supplier Contact Response Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_INVITE_CONT_RESP_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_neg_summary_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);
x_supplier_exempted_info VARCHAR2(1000);
x_notification_id number;
x_login_neg_summary_url VARCHAR2(2000);
x_login_neg_summary_txt VARCHAR2(2000);
x_login_neg_summary_txt_hb VARCHAR2(2000);

--SLM UI Enhancement
l_slm_doc_type  VARCHAR2(15);

BEGIN


  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');
  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');
  IF(x_auction_start_date IS null) then
   x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');
  IF(x_auction_end_date IS null) then
   x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;


  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NEG_SUMMARY_URL');
	--14572394
  x_login_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_URL');

x_login_neg_summary_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

x_login_neg_summary_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');


  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_supplier_exempted_info := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'SUPPLIER_EXEMPTED_INFO');

  --SLM UI Enhancement
  l_slm_doc_type := PON_SLM_UTIL_PKG.GET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => l_item_type,
                                                          p_itemkey => l_item_key);

  x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
  x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
  x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;

IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
  x_login_neg_summary_url:=REPLACE(x_login_neg_summary_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'display_type ='||display_type);
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_login_neg_summary_txt = ' ||x_login_neg_summary_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_login_neg_summary_txt = ' ||x_login_neg_summary_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_login_neg_summary_url = ' ||x_login_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_CONT_RESP_BODY',message  => 'x_supplier_exempted_info = ' ||x_supplier_exempted_info );
  END IF;

IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_INVITE_RESPONSE_HB');

        --SLM UI Enhancement
        fnd_message.set_token('SLM_DOC_TYPE',l_slm_doc_type);

        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('SUPPLIER_EXEMPTED_INFO',x_supplier_exempted_info);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
        fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_login_neg_summary_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_login_neg_summary_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
	fnd_message.set_name('PON','PON_INVITE_RESPONSE_TB');

        --SLM UI Enhancement
        fnd_message.set_token('SLM_DOC_TYPE',l_slm_doc_type);

        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('SUPPLIER_EXEMPTED_INFO',x_supplier_exempted_info);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
        fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_login_neg_summary_txt);
        IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_login_neg_summary_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_INVITE_CONT_RESP_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_INVITE_ADD_CONT_RESP_BODY
--Procedure Usage:
--  Invite Supplier Additional Contact Response Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_INVITE_ADD_CONT_RESP_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_neg_summary_url VARCHAR2(2000);
x_ack_participation_url VARCHAR2(2000);
x_isupplier_reg_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);
x_supplier_exempted_info VARCHAR2(1000);
x_notification_id number;
x_login_neg_summary_url VARCHAR2(2000);
x_login_neg_summary_txt VARCHAR2(2000);
x_login_neg_summary_txt_hb VARCHAR2(2000);

--SLM UI Enhancement
l_neg_assess_doctype VARCHAR2(1);

BEGIN
  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');
  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');
  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;


  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NEG_SUMMARY_URL');

		--14572394
  x_login_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_URL');

x_login_neg_summary_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_TB');

x_login_neg_summary_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_HB');



  x_ack_participation_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'ACK_PARTICIPATION_URL');

  x_isupplier_reg_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'ISP_SUPPLIER_REG_URL');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_supplier_exempted_info := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'SUPPLIER_EXEMPTED_INFO');

  --SLM UI Enhancement
  l_neg_assess_doctype := PON_SLM_UTIL_PKG.GET_SLM_DOC_TYPE_ATTRIBUTE (p_itemtype => l_item_type,
                                                                       p_itemkey  => l_item_key);

  x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
  x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
  x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
  --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
    x_login_neg_summary_url:=REPLACE(x_login_neg_summary_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;
  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_ack_participation_url = ' ||x_ack_participation_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_isupplier_reg_url = ' ||x_isupplier_reg_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_supplier_exempted_info = ' ||x_supplier_exempted_info );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_login_neg_summary_txt = ' ||x_login_neg_summary_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_login_neg_summary_txt = ' ||x_login_neg_summary_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INVITE_ADD_CONT_RESP_BODY',message  => 'x_login_neg_summary_url = ' ||x_login_neg_summary_url );

  END IF;

IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_INV_RESP_ADD_CONT_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('SUPPLIER_EXEMPTED_INFO',x_supplier_exempted_info);
        fnd_message.set_token('ACK_PARTICIPATION_URL',x_ack_participation_url);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
        fnd_message.set_token('LOGIN_VIEW_DETAILS_HB',x_login_neg_summary_txt_hb);

        --SLM UI Enhancement
        fnd_message.set_token(PON_SLM_UTIL_PKG.SLM_WF_ATTR, l_neg_assess_doctype);

		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_login_neg_summary_url);
		END IF;
        fnd_message.set_token('ISP_SUPPLIER_REG_URL',x_isupplier_reg_url);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
	fnd_message.set_name('PON','PON_INV_RESP_ADD_CONT_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
        fnd_message.set_token('SUPPLIER_EXEMPTED_INFO',x_supplier_exempted_info);
        fnd_message.set_token('ACK_PARTICIPATION_URL',x_ack_participation_url);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
        fnd_message.set_token('LOGIN_VIEW_DETAILS_TB',x_login_neg_summary_txt);

        --SLM UI Enhancement
        fnd_message.set_token(PON_SLM_UTIL_PKG.SLM_WF_ATTR, l_neg_assess_doctype);

        IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_DETAILS_URL',x_login_neg_summary_url);
		END IF;
        fnd_message.set_token('ISP_SUPPLIER_REG_URL',x_isupplier_reg_url);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_INVITE_ADD_CONT_RESP_BODY;
-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_INV_NEWRND_START_BODY
--Procedure Usage:
--  Invite Supplier Contact New Round Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_INV_NEWRND_START_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_neg_summary_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);

x_refund_supplier     VARCHAR2(2000); -- bug 8613271
x_notification_id number;
x_login_newrnd_sum_url VARCHAR2(2000);
x_login_newrnd_sum_txt VARCHAR2(2000);
x_login_newrnd_sum_txt_hb VARCHAR2(2000);

BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');
  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE');
  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;

  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NEG_SUMMARY_URL');

	--14572394
  x_login_newrnd_sum_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_URL');

  x_login_newrnd_sum_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NEWRND_DTLS_TB');

  x_login_newrnd_sum_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NEWRND_DTLS_HB');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_refund_supplier := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                      aname    => 'REFUND_SUPPLIER');

  x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
  x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
  x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
  --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
  IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
    x_login_newrnd_sum_url:=REPLACE(x_login_newrnd_sum_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_login_newrnd_sum_txt = ' ||x_login_newrnd_sum_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_login_newrnd_sum_txt = ' ||x_login_newrnd_sum_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_BODY',message  => 'x_login_newrnd_sum_url = ' ||x_login_newrnd_sum_url );

  END IF;

IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_INV_NEW_RND_START_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_NEWRND_DTLS_HB',x_login_newrnd_sum_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_newrnd_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  ELSE
        l_disp_type:= display_type;
	fnd_message.set_name('PON','PON_INV_NEW_RND_START_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_NEWRND_DTLS_TB',x_login_newrnd_sum_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_newrnd_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_INV_NEWRND_START_BODY;

-------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  GEN_INV_NEWRND_START_AD_BODY
--Procedure Usage:
--  Invite Supplier Additional Contact New Round Message Body is being replaced with FND Message and its tokens
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
PROCEDURE GEN_INV_NEWRND_START_AD_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_neg_summary_url VARCHAR2(2000);
x_isupplier_reg_url VARCHAR2(2000);
x_ack_participation_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);

x_refund_supplier     VARCHAR2(2000); -- bug 8613271
x_notification_id number;
x_login_newrnd_sum_url VARCHAR2(2000);
x_login_newrnd_sum_txt VARCHAR2(2000);
x_login_newrnd_sum_txt_hb VARCHAR2(2000);


BEGIN


  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');
  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');
  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;

  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NEG_SUMMARY_URL');

  	--14572394
  x_login_newrnd_sum_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_URL');

  x_login_newrnd_sum_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NEWRND_DTLS_TB');

  x_login_newrnd_sum_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NEWRND_DTLS_HB');


  x_ack_participation_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'ACK_PARTICIPATION_URL');

  x_isupplier_reg_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'ISP_SUPPLIER_REG_URL');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_refund_supplier := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'REFUND_SUPPLIER');

  x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
  x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
  x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
  --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
    x_login_newrnd_sum_url:=REPLACE(x_login_newrnd_sum_url,'&#NID',x_notification_id);

	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;


  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_ack_participation_url = ' ||x_ack_participation_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_isupplier_reg_url = ' ||x_isupplier_reg_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_login_newrnd_sum_txt = ' ||x_login_newrnd_sum_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_login_newrnd_sum_txt = ' ||x_login_newrnd_sum_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_START_AD_BODY',message  => 'x_login_newrnd_sum_url = ' ||x_login_newrnd_sum_url );

  END IF;
IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_INV_NEW_RND_START_AD_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('ACK_PARTICIPATION_URL',x_ack_participation_url);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_NEWRND_DTLS_HB',x_login_newrnd_sum_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_newrnd_sum_url);
		END IF;
        fnd_message.set_token('ISP_SUPPLIER_REG_URL',x_isupplier_reg_url);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_INV_NEW_RND_START_AD_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
	fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('ACK_PARTICIPATION_URL',x_ack_participation_url);
        fnd_message.set_token('NEG_SUMMARY_URL_SUPPLIER',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_NEWRND_DTLS_TB',x_login_newrnd_sum_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_newrnd_sum_url);
		END IF;
        fnd_message.set_token('ISP_SUPPLIER_REG_URL',x_isupplier_reg_url);
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_INV_NEWRND_START_AD_BODY;

	 -- Added for the bug#8847938 to remove the space as delimitter in user name

 	 procedure String_To_UserTable (p_UserList  in VARCHAR2,
 	                                p_UserTable out NOCOPY WF_DIRECTORY.UserTable)
 	 is

 	   c1          pls_integer;
 	   u1          pls_integer := 0;
 	   l_userList  varchar2(32000);

 	 begin
 	   if (p_UserList is not NULL) THEN
 	   l_userList := ltrim(p_UserList);
 	   p_UserTable(u1) := l_userList;
 	   end if;
 	 end String_To_UserTable;

-- Begin Bug 8992789
FUNCTION IS_INTERNAL_ONLY(p_auction_header_id NUMBER) RETURN BOOLEAN
IS

l_internal_only_flag VARCHAR2(1);

BEGIN

  SELECT internal_only_flag
  INTO l_internal_only_flag
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;

  RETURN (l_internal_only_flag = 'Y');

END IS_INTERNAL_ONLY;
-- End Bug 8992789

-- Begin Bug 9309785
-- Function to get prospective supplier registration URL
FUNCTION GET_SUPPLIER_REG_URL(p_supp_reg_id NUMBER) RETURN VARCHAR2
IS

l_reg_key    pos_supplier_registrations.reg_key%TYPE;

CURSOR l_cur IS
  SELECT reg_key
  FROM pos_supplier_registrations
  WHERE supplier_reg_id = p_supp_reg_id;

BEGIN

  OPEN l_cur;
  FETCH l_cur INTO l_reg_key;
  CLOSE l_cur;

  RETURN pos_url_pkg.get_external_url ||
         'OA_HTML/jsp/pos/suppreg/SupplierRegister.jsp?regkey=' ||
         l_reg_key;

END GET_SUPPLIER_REG_URL;
-- END Bug 9309785

-- Begin Supplier Management: Bug 9222914
PROCEDURE SYNC_BID_HEADER_ATTACHMENTS(p_auction_header_id IN NUMBER)
AS

  l_intgr_hdr_attach_flag pon_auction_headers_all.intgr_hdr_attach_flag%TYPE;
  l_bid_number            pon_bid_headers.bid_number%TYPE;
  l_vendor_id             pon_bid_headers.vendor_id%TYPE;

  CURSOR get_intgr_hdr_attach_flag IS
    SELECT intgr_hdr_attach_flag
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auction_header_id;

  CURSOR bids_cursor IS
    SELECT bid_number, vendor_id
    FROM pon_bid_headers
    WHERE auction_header_id = p_auction_header_id
      AND bid_status = 'ACTIVE'
      AND vendor_id <> -1;

BEGIN

  OPEN get_intgr_hdr_attach_flag;
  FETCH get_intgr_hdr_attach_flag INTO l_intgr_hdr_attach_flag;
  CLOSE get_intgr_hdr_attach_flag;

  IF (l_intgr_hdr_attach_flag = 'Y') THEN

    FOR bid IN bids_cursor LOOP

      fnd_attached_documents2_pkg.copy_attachments(
        X_from_entity_name => 'PON_BID_HEADERS',
        X_from_pk1_value => p_auction_header_id,
        X_from_pk2_value => bid.bid_number,
        X_to_entity_name => 'PO_VENDORS',
        X_to_pk1_value => bid.vendor_id,
        X_created_by => fnd_global.user_id,
        X_last_update_login => fnd_global.login_id);

    END LOOP;

  END IF;

END SYNC_BID_HEADER_ATTACHMENTS;
-- End Supplier Management: Bug 9222914

-- Begin Supplier Management: Bug 10075648
-- Procedure to update supplier registration status, used when publishing RFI.
PROCEDURE UPDATE_SUPPLIER_REG_STATUS(p_supp_reg_id IN NUMBER)
AS
BEGIN

  UPDATE pos_supplier_registrations
  SET registration_status = 'RIF_SUPPLIER'
  WHERE supplier_reg_id = p_supp_reg_id
    AND registration_status = 'PENDING_APPROVAL';

END UPDATE_SUPPLIER_REG_STATUS;
-- End Supplier Management: Bug 10075648

-- Begin Supplier Management: Bug 10378806 / 11071755
PROCEDURE GEN_REQ_SUPP_AUC_AMEND_BODY(p_document_id    IN VARCHAR2,
                                      display_type     IN VARCHAR2,
                                      document         IN OUT NOCOPY CLOB,
                                      document_type    IN OUT NOCOPY VARCHAR2)
IS

  l_document      VARCHAR2(32000) := '';
  l_item_type     wf_items.item_type%TYPE;
  l_item_key      wf_items.item_key%TYPE;

  l_auction_title               pon_auction_headers_all.auction_title%TYPE;
  l_doc_number                  pon_auction_headers_all.document_number%TYPE;
  l_auction_owner_tp_name       pon_auction_headers_all.trading_partner_name%TYPE;
  l_auction_end_date            DATE;
  l_auction_end_date_format     VARCHAR2(80);
  l_timezone_disp               VARCHAR2(240);
  l_isp_new_supplier_reg_url    VARCHAR2(500);

BEGIN

  l_item_type := SUBSTR(p_document_id, 1, INSTR(p_document_id, ':') - 1);
  l_item_key := SUBSTR(p_document_id, INSTR(p_document_id, ':') + 1, LENGTH(p_document_id));

  l_auction_title := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => 'AUCTION_TITLE');

  l_doc_number := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                            itemkey  => l_item_key,
                                            aname    => 'DOC_NUMBER');

  l_auction_owner_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                       itemkey  => l_item_key,
                                                       aname    => 'PREPARER_TP_NAME');

  l_timezone_disp:= wf_engine.GetItemAttrText(itemtype => l_item_type,
                                              itemkey  => l_item_key,
                                              aname    => 'TP_TIME_ZONE');

  l_auction_end_date := wf_engine.GetItemAttrDate(itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'AUCTION_END_DATE_TZ');

  IF (l_auction_end_date IS NULL) THEN
    l_auction_end_date := wf_engine.GetItemAttrDate(itemtype => l_item_type,
                                                    itemkey  => l_item_key,
                                                    aname    => 'AUCTION_END_DATE');
  END IF;

  l_auction_end_date_format := TO_CHAR(l_auction_end_date,'Month dd, yyyy hh:mi am');

  l_isp_new_supplier_reg_url := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                          itemkey  => l_item_key,
                                                          aname    => 'ISP_NEW_SUPPLIER_REG_URL');

  IF display_type = 'text/html' THEN
    fnd_message.set_name('PON','PON_SM_REQ_SUPP_AMEND_HB');
    fnd_message.set_token('AUCTION_TITLE', l_auction_title);
    fnd_message.set_token('DOC_NUMBER', l_doc_number);
    fnd_message.set_token('PREPARER_TP_NAME', l_auction_owner_tp_name);
    fnd_message.set_token('ISP_NEW_SUPPLIER_REG_URL', l_isp_new_supplier_reg_url);
    fnd_message.set_token('AUCTION_END_DATE', l_auction_end_date_format);
    fnd_message.set_token('TP_TIME_ZONE', l_timezone_disp);
    l_document := l_document || fnd_global.newline || fnd_global.newline ||
                  fnd_message.get;
    WF_NOTIFICATION.WriteToClob(document, l_document);
  ELSE
    fnd_message.set_name('PON','PON_SM_REQ_SUPP_AMEND_TB');
    fnd_message.set_token('AUCTION_TITLE', l_auction_title);
    fnd_message.set_token('DOC_NUMBER', l_doc_number);
    fnd_message.set_token('PREPARER_TP_NAME', l_auction_owner_tp_name);
    fnd_message.set_token('ISP_NEW_SUPPLIER_REG_URL', l_isp_new_supplier_reg_url);
    fnd_message.set_token('AUCTION_END_DATE', l_auction_end_date_format);
    fnd_message.set_token('TP_TIME_ZONE', l_timezone_disp);
    l_document := l_document || fnd_global.newline || fnd_global.newline ||
                  fnd_message.get;
    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;

END GEN_REQ_SUPP_AUC_AMEND_BODY;

PROCEDURE GEN_INV_REQ_SUPP_NEWRND_BODY(p_document_id    IN VARCHAR2,
                                       display_type     IN VARCHAR2,
                                       document         IN OUT NOCOPY CLOB,
                                       document_type    IN OUT NOCOPY VARCHAR2)
IS

  l_document      VARCHAR2(32000) := '';
  l_item_type     wf_items.item_type%TYPE;
  l_item_key      wf_items.item_key%TYPE;

  l_auction_title               pon_auction_headers_all.auction_title%TYPE;
  l_doc_number                  pon_auction_headers_all.document_number%TYPE;
  l_auction_owner_tp_name       pon_auction_headers_all.trading_partner_name%TYPE;
  l_auction_end_date            DATE;
  l_auction_end_date_format     VARCHAR2(80);
  l_timezone_disp               VARCHAR2(240);
  l_isp_new_supplier_reg_url    VARCHAR2(500);

BEGIN

  l_item_type := SUBSTR(p_document_id, 1, INSTR(p_document_id, ':') - 1);
  l_item_key := SUBSTR(p_document_id, INSTR(p_document_id, ':') + 1, LENGTH(p_document_id));

  l_auction_title := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname    => 'AUCTION_TITLE');

  l_doc_number := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                            itemkey  => l_item_key,
                                            aname    => 'DOC_NUMBER');

  l_auction_owner_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                       itemkey  => l_item_key,
                                                       aname    => 'PREPARER_TP_NAME');

  l_timezone_disp:= wf_engine.GetItemAttrText(itemtype => l_item_type,
                                              itemkey  => l_item_key,
                                              aname    => 'TP_TIME_ZONE');

  l_auction_end_date := wf_engine.GetItemAttrDate(itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'AUCTION_END_DATE_TZ');

  IF (l_auction_end_date IS NULL) THEN
    l_auction_end_date := wf_engine.GetItemAttrDate(itemtype => l_item_type,
                                                    itemkey  => l_item_key,
                                                    aname    => 'AUCTION_END_DATE');
  END IF;

  l_auction_end_date_format := TO_CHAR(l_auction_end_date,'Month dd, yyyy hh:mi am');

  l_isp_new_supplier_reg_url := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                          itemkey  => l_item_key,
                                                          aname    => 'ISP_NEW_SUPPLIER_REG_URL');

  IF display_type = 'text/html' THEN
    fnd_message.set_name('PON','PON_SM_INV_REQ_SUPP_NEWRND_HB');
    fnd_message.set_token('AUCTION_TITLE', l_auction_title);
    fnd_message.set_token('DOC_NUMBER', l_doc_number);
    fnd_message.set_token('PREPARER_TP_NAME', l_auction_owner_tp_name);
    fnd_message.set_token('ISP_NEW_SUPPLIER_REG_URL', l_isp_new_supplier_reg_url);
    fnd_message.set_token('AUCTION_END_DATE', l_auction_end_date_format);
    fnd_message.set_token('TP_TIME_ZONE', l_timezone_disp);
    l_document := l_document || fnd_global.newline || fnd_global.newline ||
                  fnd_message.get;
    WF_NOTIFICATION.WriteToClob(document, l_document);
  ELSE
    fnd_message.set_name('PON','PON_SM_INV_REQ_SUPP_NEWRND_TB');
    fnd_message.set_token('AUCTION_TITLE', l_auction_title);
    fnd_message.set_token('DOC_NUMBER', l_doc_number);
    fnd_message.set_token('PREPARER_TP_NAME', l_auction_owner_tp_name);
    fnd_message.set_token('ISP_NEW_SUPPLIER_REG_URL', l_isp_new_supplier_reg_url);
    fnd_message.set_token('AUCTION_END_DATE', l_auction_end_date_format);
    fnd_message.set_token('TP_TIME_ZONE', l_timezone_disp);
    l_document := l_document || fnd_global.newline || fnd_global.newline ||
                  fnd_message.get;
    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;

END GEN_INV_REQ_SUPP_NEWRND_BODY;

PROCEDURE IS_SM_ENABLED(itemtype     IN VARCHAR2,
                        itemkey      IN VARCHAR2,
                        actid        IN NUMBER,
                        funcmode     IN VARCHAR2,
                        resultout    OUT NOCOPY VARCHAR2)
IS
BEGIN

  IF FND_PROFILE.value('POS_SM_ENABLE_SPM_EXTENSION') = 'Y' THEN
    resultout := 'Y';
  ELSE
    resultout := 'N';
  END IF;

END IS_SM_ENABLED;
-- End Supplier Management: Bug 10378806 / 11071755

--Bug 16666395
FUNCTION GET_VENDOR_SITE_ADDRESS (p_vendor_site_id NUMBER) RETURN VARCHAR2
IS
x_vendor_site_address varchar2(1317):=null;
BEGIN

if (p_vendor_site_id is not null and  p_vendor_site_id <>-1 ) then

 	  select (ps.address_line1 || decode(ps.address_line1,   NULL,   NULL,   ', ')
|| ps.address_line2 || decode(ps.address_line2,   NULL,   NULL,   ', ') || ps.address_line3
|| decode(ps.address_line3,   NULL,   NULL,   ', ') || ps.address_line4 ||
decode(ps.address_line4,   NULL,   NULL,   ', ') || ps.city ||
decode(ps.city,   NULL,   NULL,   ', ') || ps.state || ' ' || ps.zip ||
decode(ps.zip,   NULL,   NULL,   decode(ps.state,   NULL,   NULL,   ', ')) ||
decode(ps.country,   NULL,   ps.province,   ps.country))  into x_vendor_site_address
 	  from po_vendor_sites_all ps
 	  where ps.vendor_site_id = p_vendor_site_id;

end if;

if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
 	        if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
 	                fnd_log.string(log_level => fnd_log.level_unexpected,
 	                module    => 'pon.plsql.pon_auction_pkg.GET_VENDOR_SITE_ADDRESS',
 	                message   => 'p_vendor_site_id:'|| p_vendor_site_id ||
 	                '   x_vendor_site_address:'||x_vendor_site_address);
 	        end if;
end if;

return x_vendor_site_address;

END;


-- bug#16690631 for surrogate quote enhancement
PROCEDURE CHECK_NOTIFY_USER_INFO(p_user_name IN VARCHAR2,
                                 p_trading_partner_contact_id IN NUMBER,
                                 x_user_name OUT NOCOPY VARCHAR2)
IS

l_vendor_id ap_suppliers.vendor_id%type;
l_person_full_name hz_parties.party_name%TYPE;
l_email_address hz_contact_points.email_address%TYPE;
l_adhoc_user  wf_users.name%TYPE;
x_language_code                VARCHAR2(30) := null;
x_nls_language                 VARCHAR2(60) := 'AMERICAN';
x_territory_code               VARCHAR2(30) := 'AMERICA';
x_nls_territory                VARCHAR2(60);

BEGIN

BEGIN

SELECT psuv.VENDOR_ID  INTO l_vendor_id
     FROM pos_supplier_users_v psuv
     WHERE psuv.user_name =p_user_name ;
EXCEPTION
WHEN OTHERS THEN
l_vendor_id:=-99;
END;



IF(Nvl(l_vendor_id,-99) > 0) THEN
x_user_name:= p_user_name;
RETURN;
END IF;

BEGIN



SELECT DISTINCT
           hp.person_last_name ||','||hp.person_first_name,
           hcpe.email_address
           INTO
           l_person_full_name,
           l_email_address
    FROM hz_parties hp,
         hz_relationships hzr,
         hz_party_usg_assignments hpua,
         hz_contact_points hcpe

    WHERE hp.party_id = hzr.subject_id
      AND hzr.relationship_type = 'CONTACT'
      AND hzr.relationship_code = 'CONTACT_OF'
      AND hzr.subject_type = 'PERSON'
      AND hzr.object_type = 'ORGANIZATION'
      AND hzr.status = 'A'
      AND NVL(hzr.end_date, SYSDATE) >= SYSDATE
      AND hpua.party_id = hp.party_id
      AND hpua.status_flag = 'A'
      AND hpua.party_usage_code = 'SUPPLIER_CONTACT'
      AND NVL(hpua.effective_end_date, SYSDATE) >= SYSDATE
      AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
      AND hcpe.owner_table_id(+) = hzr.party_id
      AND hcpe.contact_point_type(+) = 'EMAIL'
      AND hcpe.primary_flag(+) = 'Y'
      AND NVL(hcpe.status, 'A') = 'A'
      AND hp.party_id = p_trading_partner_contact_id;



    EXCEPTION
    WHEN OTHERS THEN
    l_email_address:=NULL;



    END;
IF(l_email_address IS null) then
    x_user_name:= p_user_name;
    RETURN;
END IF;


       IF(p_user_name IS NOT null) THEN

      PON_PROFILE_UTIL_PKG.GET_WF_PREFERENCES(p_user_name ,x_language_code,x_territory_code);

        begin
        select NLS_LANGUAGE into x_nls_language
         from fnd_languages
         where language_code = x_language_code;

         select nls_territory into x_nls_territory
         from   fnd_territories
         where  territory_code = x_territory_code;
           exception
        when others then
             x_nls_language := 'AMERICAN';
             x_nls_territory := 'AMERICA';
          end;
           END IF;


         l_adhoc_user := 'ADHOC_USER_' || To_Char(p_trading_partner_contact_id) || '_' ||
                      TO_CHAR(SYSDATE, 'MMDDYYYY_HH24MISS') ||
                      fnd_crypto.smallrandomnumber;


          SELECT PON_LOCALE_PKG.get_party_display_name(p_trading_partner_contact_id,2, userenv('LANG'))
                  INTO l_person_full_name FROM dual;



         WF_DIRECTORY.CreateAdHocUser(name => l_adhoc_user,
                                   display_name => l_person_full_name,
                                   notification_preference => 'MAILHTML',
                                   email_address => l_email_address,
                                   LANGUAGE => x_nls_language,
                                   territory => x_nls_territory);

          x_user_name:= l_adhoc_user;



 END CHECK_NOTIFY_USER_INFO;

 PROCEDURE GET_DISCUSSION_MESG_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )
  IS

  NL              VARCHAR2(1) := fnd_global.newline;
  l_document      VARCHAR2(32000) := '';
  l_url           VARCHAR2(3000) := '';
  l_disp_type          VARCHAR2(20) := 'text/plain';
  l_item_type wf_items.item_type%TYPE;
  l_item_key  wf_items.item_key%TYPE;

  x_preview_date   DATE;
  x_timezone1_disp VARCHAR2(240);
  x_preview_date_notspec VARCHAR2(240);
  x_auction_start_date DATE;
  x_timezone_disp VARCHAR2(240);
  x_open_date_notspec VARCHAR2(240);
  x_auction_end_date  VARCHAR2(80);
  x_timezone2_disp  VARCHAR2(240);
  x_close_date_notspec VARCHAR2(240);
  x_mesg_sender_comp_name VARCHAR2(2000);
  x_mesg_subject VARCHAR2(4000);
  x_mesg_content VARCHAR2(32000) := '';
  x_mesg_url   VARCHAR2(2000);
  x_staggard_close_note  VARCHAR2(4000);
  x_notification_id NUMBER;
  x_notif_performer VARCHAR2(50); -- BUYER or SUPPLIER
  x_attachments_cnt NUMBER;
  x_discussion_id NUMBER;
  x_entry_id NUMBER;
  l_slm_doc_type  VARCHAR2(15);

  BEGIN

    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || '.GET_DISCUSSION_MESG_BODY', 'p_document_id ' || p_document_id);
    END IF;

    l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
    l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));


    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || '.GET_DISCUSSION_MESG_BODY', 'l_item_type ' || l_item_type);
      fnd_log.string(fnd_log.level_statement, g_module_prefix || '.GET_DISCUSSION_MESG_BODY', 'l_item_key ' || l_item_key);
    END IF;

    x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                               itemkey    => l_item_key,
                                               aname      => 'PREVIEW_DATE');
    x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                     itemkey  => l_item_key,
					                                     aname    => 'TP_TIME_ZONE1');
    x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                               itemkey  => l_item_key,
      	                                       aname    => 'PREVIEW_DATE_NOTSPECIFIED');
    x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                               itemkey    => l_item_key,
                                               aname      => 'AUCTION_START_DATE');
    x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');
    x_open_date_notspec:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'OPEN_DATE_NOT_SPECIFIED');
    x_auction_end_date:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'AUCTION_END_DATE');
    x_timezone2_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE2');
    x_close_date_notspec:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'CLOSE_DATE_NOT_SPECIFIED');
    x_mesg_sender_comp_name:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'MSG_SENDER_COMP_NAME');
    x_mesg_subject:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'MESSAGE_SUBJECT');
    x_mesg_content:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'MESSAGE_SENT_CONTENT');
    x_mesg_url:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'VIEW_MESSAGE_URL');

    Begin
      SELECT notification_id  INTO x_notification_id
      FROM WF_ITEM_ACTIVITY_STATUSES
      WHERE ITEM_TYPE=l_item_type
        AND ITEM_KEY=l_item_key
        AND ASSIGNED_USER IS NOT NULL
        AND ROWNUM<=1;
    EXCEPTION
      WHEN No_Data_Found THEN
        x_notification_id:=NULL;
      WHEN OTHERS THEN
        NULL;
    END;
    IF(x_notification_id IS NOT null) THEN
	    x_mesg_url:=REPLACE(x_mesg_url,'&#NID',x_notification_id);
    END IF;

    x_staggard_close_note:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'STAGGERED_CLOSE_NOTE');
    x_notif_performer := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
                                              aname      => 'TRADING_PARTNER_TYPE');

    x_entry_id := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
                                              aname      => 'MESSAGE_ENTRY_ID');

    x_discussion_id := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
                                              aname      => 'DISCUSSION_ID');

    l_slm_doc_type := PON_SLM_UTIL_PKG.GET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype => l_item_type, p_itemkey => l_item_key);

    --IF(x_notif_performer =  'BUYER') THEN

      SELECT Count(1) INTO x_attachments_cnt FROM FND_ATTACHED_DOCUMENTS
      WHERE  ENTITY_NAME LIKE 'PON_DISCUSSIONS'
      AND PK1_VALUE = x_discussion_id
      AND PK2_VALUE = x_entry_id;

    /*ELSE

      SELECT Count(1) INTO x_attachments_cnt FROM FND_ATTACHED_DOCUMENTS
      WHERE  ENTITY_NAME LIKE 'PON_DISCUSSIONS'
      AND PK3_VALUE = x_discussion_id
      AND PK4_VALUE = x_entry_id;

    END IF;
    */

    IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      IF(x_attachments_cnt > 0) THEN
        fnd_message.set_name('PON','PON_DISC_MESG_ATTACH_BODY_HTML');
      ELSE
        fnd_message.set_name('PON','PON_DISC_MESG_BODY_HTML');
      END IF;
      fnd_message.set_token('SLM_DOC_TYPE',l_slm_doc_type);
      fnd_message.set_token('PREVIEW_DATE',x_preview_date);
      fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
      fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
      fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date);
      fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
      fnd_message.set_token('OPEN_DATE_NOT_SPECIFIED',x_open_date_notspec);
      fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date);
      fnd_message.set_token('TP_TIME_ZONE2',x_timezone2_disp);
      fnd_message.set_token('CLOSE_DATE_NOT_SPECIFIED',x_close_date_notspec);
      fnd_message.set_token('MSG_SENDER_COMP_NAME',x_mesg_sender_comp_name);
      fnd_message.set_token('MESSAGE_SUBJECT',x_mesg_subject);
      fnd_message.set_token('MESSAGE_SENT_CONTENT',x_mesg_content);
      fnd_message.set_token('URL',x_mesg_url);
      fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggard_close_note);
      l_document :=   l_document || NL || NL || fnd_message.get;
   	  WF_NOTIFICATION.WriteToClob(document, l_document);

    ELSE
      l_disp_type:= display_type;
      IF(x_attachments_cnt > 0) THEN
        fnd_message.set_name('PON','PON_DISC_MESG_ATTACH_BODY_TEXT');
      ELSE
        fnd_message.set_name('PON','PON_DISC_MESG_BODY_TEXT');
      END IF;
      fnd_message.set_token('SLM_DOC_TYPE',l_slm_doc_type);
	    fnd_message.set_token('PREVIEW_DATE',x_preview_date);
      fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
      fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
      fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date);
      fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
      fnd_message.set_token('OPEN_DATE_NOT_SPECIFIED',x_open_date_notspec);
      fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date);
      fnd_message.set_token('TP_TIME_ZONE2',x_timezone2_disp);
      fnd_message.set_token('CLOSE_DATE_NOT_SPECIFIED',x_close_date_notspec);
      fnd_message.set_token('MSG_SENDER_COMP_NAME',x_mesg_sender_comp_name);
      fnd_message.set_token('MESSAGE_SUBJECT',x_mesg_subject);
      fnd_message.set_token('MESSAGE_SENT_CONTENT',x_mesg_content);
      fnd_message.set_token('URL',x_mesg_url);
      fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggard_close_note);
      l_document :=   l_document || NL || NL || fnd_message.get;
 	    WF_NOTIFICATION.WriteToClob(document, l_document);

    END IF;

  EXCEPTION
  WHEN OTHERS THEN
      RAISE;

  END GET_DISCUSSION_MESG_BODY;

PROCEDURE GEN_AUC_AMEND_BODY_PROSP_SUPP(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_neg_summary_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone_disp VARCHAR2(240);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);

x_refund_supplier     VARCHAR2(2000); -- bug 8613271
x_notification_id number;
x_login_amend_sum_url VARCHAR2(2000);
x_login_amend_sum_txt VARCHAR2(2000);
x_login_amend_sum_txt_hb VARCHAR2(2000);

BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                    itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');

  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE_TZ');
  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;


  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE_TZ');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;

  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');

  x_neg_summary_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'NET_CHANGES_URL');

  	--14572394
  x_login_amend_sum_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NET_CHANGES_URL');

  x_login_amend_sum_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_AMEND_DTLS_TB');

  x_login_amend_sum_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_AMEND_DTLS_HB');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_refund_supplier := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'REFUND_SUPPLIER');

 x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
 x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
 --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
    IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
    x_login_amend_sum_url:=REPLACE(x_login_amend_sum_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;


   IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_login_amend_sum_txt = ' ||x_login_amend_sum_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_login_amend_sum_txt = ' ||x_login_amend_sum_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_AUC_AMEND_BODY_REQ_SUPP',message  => 'x_login_amend_sum_url = ' ||x_login_amend_sum_url );

  END IF;

 IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
      fnd_message.set_name('PON','PON_AMEND_INVITE_PROSP_SUPP_HB');
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
		fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_AMEND_DTLS_HB',x_login_amend_sum_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_amend_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
		fnd_message.set_name('PON','PON_AMEND_INVITE_PROSP_SUPP_TB');
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
		fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_AMEND_DTLS_TB',x_login_amend_sum_txt);
        IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_amend_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_AUC_AMEND_BODY_PROSP_SUPP;

PROCEDURE GEN_INV_NEWRND_BODY_PROSP_SUPP(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
x_preview_date   	   DATE;
x_preview_date_notspec VARCHAR2(240);
x_auction_start_date   DATE;
x_auction_end_date     DATE;
x_bidder_tp_name       PON_BIDDING_PARTIES.TRADING_PARTNER_NAME%TYPE;
--x_bidder_tp_addresssname PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE; bug 16666395
x_bidder_tp_addresssname VARCHAR2(1317);
x_neg_summary_url VARCHAR2(2000);
x_staggered_close_note VARCHAR2(1000);
x_timezone1_disp VARCHAR2(240);
x_timezone_disp VARCHAR2(240);
x_preview_date_format VARCHAR2(80);
x_auction_start_date_format VARCHAR2(80);
x_auction_end_date_format VARCHAR2(80);

x_refund_supplier     VARCHAR2(2000); -- bug 8613271
x_notification_id number;
x_login_newrnd_sum_url VARCHAR2(2000);
x_login_newrnd_sum_txt VARCHAR2(2000);
x_login_newrnd_sum_txt_hb VARCHAR2(2000);

BEGIN

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE_TZ');
  IF(x_preview_date IS null) then
  x_preview_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                              itemkey    => l_item_key,
					                                    aname      => 'PREVIEW_DATE');
  END IF;

  x_timezone1_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
					                                      itemkey  => l_item_key,
					                                      aname    => 'TP_TIME_ZONE1');

  x_preview_date_notspec := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
      	                                              aname    => 'PREVIEW_DATE_NOTSPECIFIED');


  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                      itemkey    => l_item_key,
                                                      aname      => 'AUCTION_START_DATE');
  IF(x_auction_start_date IS null) then
  x_auction_start_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                    itemkey    => l_item_key,
                                                    aname      => 'AUCTION_START_DATE');
  END IF;

  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  IF(x_auction_end_date IS null) then
  x_auction_end_date := wf_engine.GetItemAttrDate (itemtype   => l_item_type,
                                                  itemkey    => l_item_key,
                                                  aname      => 'AUCTION_END_DATE');
  END IF;

  x_timezone_disp:= wf_engine.GetItemAttrText (itemtype => l_item_type,
    					                                itemkey  => l_item_key,
					                                    aname    => 'TP_TIME_ZONE');


  x_bidder_tp_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => 'BIDDER_TP_NAME');


  x_bidder_tp_addresssname := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                                        itemkey  => l_item_key,
                                                        aname    => 'BIDDER_TP_ADDRESS_NAME');


  x_neg_summary_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'NEG_SUMMARY_URL');

	--14572394
  x_login_newrnd_sum_url:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_DETAILS_URL');

  x_login_newrnd_sum_txt:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NEWRND_DTLS_TB');

  x_login_newrnd_sum_txt_hb:=wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                                itemkey    => l_item_key,
                                                aname      => 'LOGIN_VIEW_NEWRND_DTLS_HB');

  x_staggered_close_note := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                     aname    => 'STAGGERED_CLOSE_NOTE');

  x_refund_supplier := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                      aname    => 'REFUND_SUPPLIER');

  x_preview_date_format := to_char(x_preview_date,'Month dd, yyyy hh:mi am');
  x_auction_start_date_format := to_char(x_auction_start_date,'Month dd, yyyy hh:mi am');
  x_auction_end_date_format := to_char(x_auction_end_date,'Month dd, yyyy hh:mi am');
  --Added for Bug 8664757
 --Replacing &#NID in the Negotiation URL with the actual Notification Id from WF_ITEM_ACTIVITY_STATUSES table
 Begin
  SELECT notification_id  INTO x_notification_id from WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE=l_item_type
  AND ITEM_KEY=l_item_key
  AND ASSIGNED_USER IS NOT NULL
  AND ROWNUM<=1;
 EXCEPTION
    WHEN No_Data_Found THEN
      x_notification_id:=NULL;
    WHEN OTHERS THEN
      NULL;
 END;
  IF(x_notification_id IS NOT null) THEN
	x_neg_summary_url:=REPLACE(x_neg_summary_url,'&#NID',x_notification_id);
    x_login_newrnd_sum_url:=REPLACE(x_login_newrnd_sum_url,'&#NID',x_notification_id);
	--Bug 11898698
	--Added code for Changing language_code to the corresponding session language during runtime
	--x_neg_summary_url:=regexp_replace(x_neg_summary_url, 'language_code=..', 'language_code='||UserEnv('LANG'));
    END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_preview_date = ' ||x_preview_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_timezone1_disp = ' ||x_timezone1_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_preview_date_notspec = ' ||x_preview_date_notspec );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_auction_start_date = ' ||x_auction_start_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_auction_end_date = ' ||x_auction_end_date_format );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_timezone_disp = ' ||x_timezone_disp );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_bidder_tp_name = ' ||x_bidder_tp_name );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_bidder_tp_addresssname = ' ||x_bidder_tp_addresssname );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_neg_summary_url = ' ||x_neg_summary_url );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_staggered_close_note = ' ||x_staggered_close_note );
	FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_login_newrnd_sum_txt = ' ||x_login_newrnd_sum_txt );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_login_newrnd_sum_txt = ' ||x_login_newrnd_sum_txt_hb );
    FND_LOG.string (log_level => FND_LOG.level_statement,module  =>  g_module_prefix || '.GEN_INV_NEWRND_BODY_PROSP_SUPP',message  => 'x_login_newrnd_sum_url = ' ||x_login_newrnd_sum_url );

  END IF;

IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
        fnd_message.set_name('PON','PON_INV_NEW_RND_PROSP_SUPP_HB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
		fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_NEWRND_DTLS_HB',x_login_newrnd_sum_txt_hb);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_newrnd_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  ELSE
        l_disp_type:= display_type;
		fnd_message.set_name('PON','PON_INV_NEW_RND_PROSP_SUPP_TB');
        fnd_message.set_token('PREVIEW_DATE',x_preview_date_format);
        fnd_message.set_token('TP_TIME_ZONE1',x_timezone1_disp);
        fnd_message.set_token('PREVIEW_DATE_NOTSPECIFIED',x_preview_date_notspec);
        fnd_message.set_token('AUCTION_START_DATE',x_auction_start_date_format);
        fnd_message.set_token('TP_TIME_ZONE',x_timezone_disp);
        fnd_message.set_token('AUCTION_END_DATE',x_auction_end_date_format);
        fnd_message.set_token('BIDDER_TP_NAME',x_bidder_tp_name);
        fnd_message.set_token('BIDDER_TP_ADDRESS_NAME',x_bidder_tp_addresssname);
		fnd_message.set_token('REFUND_SUPPLIER',x_refund_supplier);
        fnd_message.set_token('NEG_SUMMARY_URL',x_neg_summary_url);
		fnd_message.set_token('LOGIN_VIEW_NEWRND_DTLS_TB',x_login_newrnd_sum_txt);
		IF (fnd_profile.value('POS_EXTERNAL_LOGON_PATH') IS NOT NULL ) THEN
			fnd_message.set_token('LOGIN_VIEW_NET_CHANGES_URL',x_login_newrnd_sum_url);
		END IF;
        fnd_message.set_token('STAGGERED_CLOSE_NOTE',x_staggered_close_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);
  END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GEN_INV_NEWRND_BODY_PROSP_SUPP;

END PON_AUCTION_PKG;

/

  GRANT EXECUTE ON "APPS"."PON_AUCTION_PKG" TO "REPORT_TESTER";
  GRANT EXECUTE ON "APPS"."PON_AUCTION_PKG" TO "P1MSTR";
