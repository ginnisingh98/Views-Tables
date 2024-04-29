--------------------------------------------------------
--  DDL for Package Body OE_ERROR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ERROR_WF" AS
/* $Header: OEXWERRB.pls 120.9.12000000.2 2007/10/14 15:01:45 vbkapoor ship $ */

TYPE T_NUM       IS TABLE OF NUMBER;
TYPE T_V240      IS TABLE OF VARCHAR(240);
TYPE T_V8        IS TABLE OF VARCHAR(8);
TYPE T_V30       IS TABLE OF VARCHAR(30);
TYPE T_V2000     IS TABLE OF VARCHAR(2000);

TYPE Retry_Rec_Type IS RECORD  (
    item_key                      T_V240    := T_V240(),
    activity_label                T_V30     := T_V30(),
    activity_name                 T_V30     := T_V30(),
    activity_item_type            T_V8      := T_V8(),
    process_name		  T_V30     := T_V30(),
    activity_id			  T_NUM     := T_NUM(),
    user_key                      T_V240    := T_V240(),
    parent_item_type              T_V8      := T_V8(),
    parent_item_key               T_V240    := T_V240(),
    org_id                        T_NUM     := T_NUM()
);

TYPE Msg_Rec_Type IS RECORD (
    message_text                  T_V2000   := T_V2000()

);

TYPE Count_Rec_Type IS RECORD
(   concat_segment        VARCHAR2(38)   := NULL,
    activity_display_name VARCHAR2(80)   := NULL,
    activity_name         VARCHAR2(30)   := NULL,
    activity_item_type    VARCHAR2(8)    := NULL,
    process_item_type     VARCHAR2(8)    := NULL,
    initial_count         NUMBER         := NULL,
    final_count           NUMBER         := NULL
);

TYPE Count_Tbl_Type IS TABLE OF Count_Rec_Type INDEX BY binary_integer;

TABLE_SIZE    binary_integer := 2147483646; /*Size of the above Table*/

Count_Tbl                 Count_Tbl_Type;
Count_Rec                 Count_Rec_Type;

Procedure Get_EM_Key_Info (p_itemtype  IN VARCHAR2,
                            p_itemkey  IN VARCHAR2,
                            x_order_source_id OUT NOCOPY NUMBER,
                            x_orig_sys_document_ref OUT NOCOPY VARCHAR2,
                            x_sold_to_org_id OUT NOCOPY NUMBER,
                            x_change_sequence OUT NOCOPY VARCHAR2,
                            x_header_id OUT NOCOPY NUMBER,
                            x_org_id OUT NOCOPY NUMBER);



PROCEDURE Set_blanket_Descriptor ( itemtype      IN VARCHAR2,
                                   itemkey       IN VARCHAR2,
                                   err_itemtype  IN varchar2,
                                   err_itemkey   IN varchar2
                                 )
IS
l_header_id NUMBER;
l_order_number NUMBER;
l_order_type_id NUMBER;
l_order_type_name VARCHAR2(80);
l_order_category_code VARCHAR2(30);
l_order_type_txt VARCHAR2(2000);
l_header_txt VARCHAR2(2000);
l_descriptor       VARCHAR2(2000);
--
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_salesrep                    VARCHAR2(240) := NULL;
l_salesrep_id                 NUMBER;
l_org_id                      NUMBER;
l_oper_unit_name              VARCHAR2(240) := NULL;
l_version_number              VARCHAR2(240);
l_flow_status_code            VARCHAR2(30);
l_flow_status_code_meaning    VARCHAR2(80);

l_oper_unit_name_text         VARCHAR2(2000);
l_salesrep_text               VARCHAR2(2000);

l_result_code              VARCHAR2(30);
BEGIN
  l_header_id := err_itemkey;
  SELECT order_number, order_type_id, order_category_code,
         org_id, VERSION_NUMBER, FLOW_STATUS_CODE
    into l_order_number, l_order_type_id, l_order_category_code,
         l_org_id, l_version_number, l_flow_status_code
    from oe_blanket_headers_all
   where header_id = err_itemkey;

  SELECT T.NAME
    INTO   l_order_type_name
    FROM OE_TRANSACTION_TYPES_TL T
   WHERE T.LANGUAGE = userenv('LANG')
     AND T.TRANSACTION_TYPE_ID = l_order_type_id;

  SELECT name
    INTO l_oper_unit_name
    FROM HR_OPerating_units
   WHERE ORGANIZATION_ID = l_org_id;

  IF l_flow_status_code is not NULL THEN
    SELECT MEANING
      INTO l_flow_status_code_meaning
      FROM oe_lookups
     where LOOKUP_CODE = l_flow_status_code
       AND LOOKUP_TYPE = 'FLOW_STATUS';
  END IF;

  fnd_message.set_name('ONT', 'OE_WF_ORDER_TYPE');
  fnd_message.set_token('ORDER_TYPE', l_order_type_name);
  l_order_type_txt := fnd_message.get;
  fnd_message.set_name('ONT', 'OE_BLKT_SALES_AGREEMENT');
  fnd_message.set_token('BLANKET_NUMBER', to_char(l_order_number));
  l_header_txt := fnd_message.get;

  l_descriptor := substrb(l_order_type_txt || ', ' ||
                          l_header_txt, 1, 240);

  wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_SHORT_DESCRIPTOR', l_descriptor);

  wf_engine.SetItemAttrText(itemtype,itemkey, 'OPERATING_UNIT',
                                               l_oper_unit_name);
  fnd_message.set_name ('ONT', 'OE_WF_VERSION_NUMBER');
  fnd_message.set_token('VERSION_NUMBER', l_version_number);
  wf_engine.SetItemAttrText(itemtype,itemkey, 'VERSION_NUMBER',
                                               FND_MESSAGE.GET);
  fnd_message.set_name ('ONT', 'OE_WF_FLOW_STATUS');
  fnd_message.set_token('FLOW_STATUS', l_flow_status_code_meaning);
  wf_engine.SetItemAttrText(itemtype,itemkey, 'FLOW_STATUS',
                                               FND_MESSAGE.GET);

  wf_engine.SetItemAttrNumber(itemtype,itemkey, 'HEADER_ID',
                                                 l_header_id);

  wf_engine.SetItemAttrText(itemtype,itemkey, 'TRANSACTION_DETAIL_URL', NULL);

END Set_blanket_Descriptor;
/**************************/



PROCEDURE purge_error_flow (p_item_type IN varchar2,
                            p_item_key  IN varchar2)
--   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
--   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
--   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
IS
cursor err_flow IS
 select ITEM_TYPE, ITEM_KEY, ROOT_ACTIVITY
   from wf_items
  where ITEM_TYPE IN ('OMERROR','WFERROR')
    and PARENT_ITEM_TYPE = p_item_type
    and PARENT_ITEM_KEY  = p_item_key
    and END_DATE is null;
--
 l_item_key varchar2(30);
 l_item_type varchar2(30);  -- := 'OMERROR';
 l_process_name VARCHAR2(30);

BEGIN

 -- There could be multiple error flows associated with this item key so
 -- we want to purge all of them.
 oe_debug_pub.add('Entering purge_error_flow for itemtype/itemkey:' || p_item_type || '/' || p_item_key);
 open err_flow;
 loop
   fetch err_flow into l_item_type, l_item_key, l_process_name;
   exit when err_flow%NOTFOUND;
   OE_Debug_PUB.Add('Purge Error Flow for: ' || p_item_type || '/' || p_item_key);

  /* Abort the process before it can be purged */
  wf_engine.abortprocess(itemtype => l_item_type,
                         itemkey  => l_item_key,
                         process  => l_process_name);
  /* Now purge the process */
  wf_purge.items(itemtype => l_item_type,
                 itemkey  => l_item_key,
                 force    => TRUE,
                 docommit => false);
 end loop;


 oe_debug_pub.add('Exiting purge_error_flow' );
end purge_error_flow;

PROCEDURE Initialize_Errors(     itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funcmode        VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 ) IS

  l_error_itemtype      VARCHAR2(8);
  l_error_itemkey       VARCHAR2(240);
  l_error_name          VARCHAR2(30);
  l_error_msg           VARCHAR2(2000);
  l_timeout             PLS_INTEGER;
  l_administrator       VARCHAR2(100);

BEGIN

  IF (funcmode = 'RUN') THEN

    --
    -- Get the type and the key of the process that errored out
    -- these were set in the erroring out process by Execute_Error_Process
    --
    l_error_itemkey := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_KEY' );
    l_error_itemtype := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_TYPE' );

    --
    -- Check if the workflow administrator exists
    -- If it does, then assign the notification to this role
    --

        begin
              --if this item type doesnt exist an exception is raised.
              l_administrator := WF_ENGINE.GetItemAttrText(
                                itemtype        => l_error_itemtype,
                                itemkey         => l_error_itemkey,
                                aname           => 'WF_ADMINISTRATOR' );

              /*begin
                wf_engine.AssignActivity(itemtype,itemkey,
                                         'OM_ERROR_RETRY_ONLY',
                                         l_administrator);
              exception
                when OTHERS then
                  null;
              end;*/ -- Commented for Bug# 5251478

              wf_engine.AssignActivity(itemtype,itemkey,'R_ERROR_RETRY:NOTIFY',
                                         l_administrator); -- Bug# 5251478

        exception
          when others then null;
        end;

     result := wf_engine.eng_completed;
  ELSIF (funcmode = 'CANCEL') THEN
     result := wf_engine.eng_completed;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('OE_ERROR_WF', 'Initialize_Errors',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
END Initialize_Errors;


procedure update_process_messages (itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out NOCOPY /* file.sql.39 change */ varchar2)
is

l_conc_req_id number;
err_itemtype varchar2(8);
err_itemkey varchar2(240);
l_header_id   number;
l_line_id    number;
l_activity_id number;

l_conc_msg varchar2(2000);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_conc_req_url varchar2(2000);
l_mgr_log varchar2(2000);
l_result boolean;
l_gwyuid  varchar2(32);
l_two_task varchar2(64);
l_orig_sys_document_ref    VARCHAR2(50);
l_change_sequence          VARCHAR2(50);
l_order_source_id          NUMBER;
l_sold_to_org_id           NUMBER;
l_org_id                   NUMBER;
begin
 if (funcmode = 'RUN' ) then
   err_itemtype := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                            'ERROR_ITEM_TYPE');
   err_itemkey := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                           'ERROR_ITEM_KEY');

    l_conc_req_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'CONC_REQ_ID' );
    IF err_itemtype = 'OEOH' THEN
       l_header_id := to_number(err_itemkey);
    ELSIF err_itemtype = 'OEOL' THEN
       l_line_id  := to_number(err_itemkey);
       select header_id
         into l_header_id
         from oe_order_lines_all
        where line_id = l_line_id;
    ELSIF err_itemtype IN ('OEOI','OESO','OEOA','OEXWFEDI') THEN
         -- submit it if order exists
       Get_EM_Key_Info (p_itemtype => err_itemtype,
                            p_itemkey  => err_itemkey,
                            x_order_source_id => l_order_source_id,
                            x_orig_sys_document_ref => l_orig_sys_document_ref,
                            x_sold_to_org_id => l_sold_to_org_id,
                            x_change_sequence => l_change_sequence,
                            x_header_id => l_header_id,
                            x_org_id => l_org_id);
    END IF;
    l_activity_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ACTIVITY_ID');

    oe_standard_wf.set_msg_context(l_activity_id);

    IF err_itemtype IN ('OEOI','OESO','OEOA','OEXWFEDI') THEN
       OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'ELECMSG_'||err_itemtype
          ,p_entity_id                  => err_itemkey
          ,p_header_id                  => l_header_id
          ,p_line_id                    => null
          ,p_order_source_id            => l_order_source_id
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => null
          ,p_orig_sys_shipment_ref      => null
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => null
          ,p_source_document_id         => null
          ,p_source_document_line_id    => null );

    ELSE
       oe_msg_pub.set_msg_context(
          p_header_id                  => l_header_id
         ,p_line_id                    => l_line_id);
    END IF;
    fnd_message.set_name('ONT', 'ONT_CONC_MSG');
    fnd_message.set_token('CONC_REQ_ID', l_conc_req_id);
    OE_MSG_PUB.Add;
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;

    fnd_message.set_name('ONT', 'ONT_CONC_MSG');
    fnd_message.set_token('CONC_REQ_ID', l_conc_req_id);
    l_conc_msg := fnd_message.get;
    wf_engine.SetItemAttrText(itemtype, itemkey, 'ENTITY_DESCRIPTOR_LINE1',
                                                    l_conc_msg);

 -- l_gwyuid := fnd_utilities.getenv('GWYUID');
 -- l_two_task := fnd_utilities.getenv('TWO_TASK');

 -- l_result := fnd_webfile.get_req_log_urls(
 --            request_id => l_conc_req_id,
 --            gwyuid    => l_gwyuid,
 --            two_task  => l_two_task,
 --            expire_time => null,
 --            req_log     => l_conc_req_url,
 --            mgr_log     => l_mgr_log);

--wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE1',
--                                                    l_conc_req_url);

-- oe_debug_pub.add ('l_result:' || l_result);
-- oe_debug_pub.add ('URL:' || l_conc_req_url);
-- oe_debug_pub.add ('l_mgr_log:' || l_mgr_log);


    resultout := 'COMPLETE';
    return;
 end if; -- funcmode = 'RUN'

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

end update_process_messages;




procedure Set_entity_Descriptor(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out NOCOPY /* file.sql.39 change */ varchar2)
is
--
l_header_id NUMBER;
l_order_number NUMBER;
l_order_type_id NUMBER;
l_order_type_name VARCHAR2(80);
l_order_category_code VARCHAR2(30);
l_order_type_txt VARCHAR2(2000);
l_header_txt VARCHAR2(2000);
l_descriptor       VARCHAR2(2000);
l_descriptor_line1 VARCHAR2(2000);
l_descriptor_line2 VARCHAR2(2000);
--
l_line_txt VARCHAR2(2000);
l_line_number NUMBER;
l_shipment_number NUMBER;
l_option_number NUMBER;
l_service_number NUMBER;
--
  l_itemtype varchar2(8);
  l_itemkey varchar2(240);
  err_itemtype varchar2(8);
  err_itemkey varchar2(240);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_salesrep                    VARCHAR2(240) := NULL;
l_salesrep_id                 NUMBER;
l_org_id                      NUMBER;
l_oper_unit_name              VARCHAR2(240) := NULL;
l_version_number              VARCHAR2(240);
l_flow_status_code            VARCHAR2(30);
l_flow_status_code_meaning    VARCHAR2(80);

l_oper_unit_name_text         VARCHAR2(2000);
l_salesrep_text               VARCHAR2(2000);

l_url                      VARCHAR2(1000);
l_profile_val              VARCHAR2(30);
l_result_code              VARCHAR2(30);
l_concat_line_num          VARCHAR2(30);
l_orig_sys_document_ref    VARCHAR2(50);
l_change_sequence          VARCHAR2(50);
l_order_source_id          NUMBER;
l_sold_to_org_id           NUMBER;
l_order_source             VARCHAR2(240);
l_sold_to_org              VARCHAR2(360);
l_order_exists             BOOLEAN := false;
l_cust_number              VARCHAR2(30);
begin
 if (funcmode = 'RUN' ) then
  -- Get the item key and item type of the error process

-- XXXX change this do we need this?
--FND_GLOBAL.Apps_Initialize(1318, 21623, 660);



   err_itemtype := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                            'ERROR_ITEM_TYPE');
   err_itemkey := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                           'ERROR_ITEM_KEY');

   IF err_itemtype = 'OEBH' THEN
      -- At this time we do not have the generate diagnostics for blankets.
      l_result_code := 'BYPASS_REQUEST';
      -- We use a different message for blankets.
      wf_engine.SetItemAttrText(itemtype, itemkey, 'MESSAGE_NAME', 'OMERROR_MSG_NO_URL');
   ELSE
      l_profile_val :=  FND_PROFILE.VALUE('ONT_GENERATE_DIAGNOSTICS');
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' AND G_BATCH_RETRY_FLAG = 'N' THEN
         l_result_code := 'SUBMIT_REQUEST';
      ELSE
         l_result_code := 'BYPASS_REQUEST';
      END IF;
      wf_engine.SetItemAttrText(itemtype, itemkey, 'MESSAGE_NAME', 'OMERROR_MSG');
   END IF;




   if err_itemtype = 'OEOH' OR err_itemtype = 'OENH' THEN

       l_header_id := err_itemkey;

       SELECT order_number, order_type_id, order_category_code,
              org_id, SALESREP_ID, VERSION_NUMBER, FLOW_STATUS_CODE
       into l_order_number, l_order_type_id, l_order_category_code,
            l_org_id, l_salesrep_id, l_version_number, l_flow_status_code
       from oe_order_headers_all
       where header_id = err_itemkey;

       SELECT T.NAME
       INTO   l_order_type_name
       FROM OE_TRANSACTION_TYPES_TL T
       WHERE T.LANGUAGE = userenv('LANG')
       AND T.TRANSACTION_TYPE_ID = l_order_type_id;

       SELECT name
         INTO l_oper_unit_name
        FROM HR_OPerating_units
       WHERE ORGANIZATION_ID = l_org_id;

       SELECT name
         INTO l_salesrep
         FROM ra_salesreps
        WHERE salesrep_id = l_salesrep_id;

       IF l_flow_status_code is not NULL THEN
         SELECT MEANING
           INTO l_flow_status_code_meaning
           FROM oe_lookups
          where LOOKUP_CODE = l_flow_status_code
            AND LOOKUP_TYPE = 'FLOW_STATUS';
       END IF;

       fnd_message.set_name('ONT', 'OE_WF_ORDER_TYPE');
       fnd_message.set_token('ORDER_TYPE', l_order_type_name);
       l_order_type_txt := fnd_message.get;
       IF l_order_category_code = 'RETURN' THEN
         fnd_message.set_name('ONT', 'OE_WF_RETURN_ORDER');
         fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
         l_header_txt := fnd_message.get;
       ELSE
         if err_itemtype = 'OENH' THEN
           fnd_message.set_name('ONT', 'OE_NEGO_SALES_ORDER');
           fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
         ELSE
           fnd_message.set_name('ONT', 'OE_WF_SALES_ORDER');
           fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
         END IF;
         l_header_txt := fnd_message.get;
       END IF;

--       fnd_message.set_name('ONT', 'OE_WF_OPER_UNIT');
--       fnd_message.set_token('OPER_UNIT', l_oper_unit_name);
--       l_oper_unit_name_text := fnd_message.get;

--       fnd_message.set_name('ONT', 'OE_WF_SALES_REP');
--       fnd_message.set_token('SALES_REP', l_salesrep);
--       l_salesrep_text := fnd_message.get;


       l_descriptor := substrb(l_order_type_txt || ', ' ||
                               l_header_txt, 1, 240);
--       l_descriptor_line1 := l_oper_unit_name_text;
--       l_descriptor_line2 := l_salesrep_text;


       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_SHORT_DESCRIPTOR', l_descriptor);

       wf_engine.SetItemAttrText(itemtype,itemkey, 'OPERATING_UNIT',
                                                    l_oper_unit_name);
       fnd_message.set_name ('ONT', 'OE_WF_VERSION_NUMBER');
       fnd_message.set_token('VERSION_NUMBER', l_version_number);
       wf_engine.SetItemAttrText(itemtype,itemkey, 'VERSION_NUMBER',
                                                    FND_MESSAGE.GET);
       fnd_message.set_name ('ONT', 'OE_WF_FLOW_STATUS');
       fnd_message.set_token('FLOW_STATUS', l_flow_status_code_meaning);
       wf_engine.SetItemAttrText(itemtype,itemkey, 'FLOW_STATUS',
                                                    FND_MESSAGE.GET);

--       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE1',
--                                                    l_descriptor_line1);
--       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE2',
--                                                    l_descriptor_line2);

       wf_engine.SetItemAttrNumber(itemtype,itemkey, 'HEADER_ID',
                                                    l_header_id);

    IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110506' THEN
       l_url := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/')||'/OA_HTML/OA.jsp?akRegionCode=ORDER_DETAILS_PAGE' || '&' || 'akRegionApplicationId=660' || '&' || 'HeaderId=' || l_header_id;
       wf_engine.SetItemAttrText(itemtype,itemkey, 'TRANSACTION_DETAIL_URL', l_url);
    END IF;


    resultout := 'COMPLETE:' || l_result_code;
    return;

  elsif err_itemtype = 'OEOL' THEN

   SELECT header_id, FLOW_STATUS_CODE,
          line_number, shipment_number, option_number, service_number
     into l_header_id, l_flow_status_code,
          l_line_number, l_shipment_number, l_option_number, l_service_number
     FROM oe_order_lines_all
   WHERE line_id = err_itemkey;

       SELECT order_number, order_type_id, order_category_code,
              org_id, SALESREP_ID, VERSION_NUMBER
       into l_order_number, l_order_type_id, l_order_category_code,
            l_org_id, l_salesrep_id, l_version_number
       from oe_order_headers_all
       where header_id = l_header_id;

       SELECT T.NAME
       INTO   l_order_type_name
       FROM OE_TRANSACTION_TYPES_TL T
       WHERE T.LANGUAGE = userenv('LANG')
       AND T.TRANSACTION_TYPE_ID = l_order_type_id;

       SELECT name
         INTO l_oper_unit_name
        FROM HR_OPerating_units
       WHERE ORGANIZATION_ID = l_org_id;

       SELECT name
         INTO l_salesrep
         FROM ra_salesreps
        WHERE salesrep_id = l_salesrep_id;

       IF l_flow_status_code is not NULL then
         SELECT MEANING
           INTO l_flow_status_code_meaning
           FROM oe_lookups
          where LOOKUP_CODE = l_flow_status_code
            AND LOOKUP_TYPE = 'LINE_FLOW_STATUS';
       END IF;

       IF l_order_category_code = 'RETURN' THEN
         fnd_message.set_name('ONT', 'OE_WF_RETURN_ORDER');
         fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
         l_header_txt := fnd_message.get;
       ELSE
         fnd_message.set_name('ONT', 'OE_WF_SALES_ORDER');
         fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
         l_header_txt := fnd_message.get;
       END IF;

     l_concat_line_num := OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(p_line_id => to_number(err_itemkey));

     -- Do we need this?? XXXXXX
     fnd_message.set_name('ONT', 'OE_WF_ORDER_TYPE');
     fnd_message.set_token('ORDER_TYPE', l_order_type_name);
     l_order_type_txt := fnd_message.get;

     IF l_order_category_code = 'RETURN' THEN
       fnd_message.set_name('ONT', 'OE_WF_CONCAT_RETURN_LINE');
       fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
       fnd_message.set_token('CONCAT_LINE_NUMBER', l_concat_line_num);

       l_line_txt := fnd_message.get;
     ELSE
       fnd_message.set_name('ONT', 'OE_WF_CONCAT_LINE');
       fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
       fnd_message.set_token('CONCAT_LINE_NUMBER', l_concat_line_num);

       l_line_txt := fnd_message.get;
   END IF;

--       fnd_message.set_name('ONT', 'OE_WF_OPER_UNIT');
--       fnd_message.set_token('OPER_UNIT', l_oper_unit_name);
--       l_oper_unit_name_text := fnd_message.get;

--       fnd_message.set_name('ONT', 'OE_WF_SALES_REP');
--       fnd_message.set_token('SALES_REP', l_salesrep);
--       l_salesrep_text := fnd_message.get;


--       l_descriptor_line1 := l_oper_unit_name_text;
--       l_descriptor_line2 := l_salesrep_text;

       -- Line Text
       l_descriptor := substrb(l_order_type_txt || ', ' ||
                               l_line_txt, 1, 240);


       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_SHORT_DESCRIPTOR', l_descriptor);

       wf_engine.SetItemAttrText(itemtype,itemkey, 'OPERATING_UNIT',
                                                    l_oper_unit_name);

       fnd_message.set_name ('ONT', 'OE_WF_VERSION_NUMBER');
       fnd_message.set_token('VERSION_NUMBER', l_version_number);
       wf_engine.SetItemAttrText(itemtype,itemkey, 'VERSION_NUMBER',
                                                    FND_MESSAGE.GET);
       fnd_message.set_name ('ONT', 'OE_WF_FLOW_STATUS');
       fnd_message.set_token('FLOW_STATUS', l_flow_status_code_meaning);
       wf_engine.SetItemAttrText(itemtype,itemkey, 'FLOW_STATUS',
                                                    FND_MESSAGE.GET);

--       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE1',
--                                                    l_descriptor_line1);
--       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE2',
--                                                    l_descriptor_line2);

       wf_engine.SetItemAttrNumber(itemtype,itemkey, 'HEADER_ID',
                                                    l_header_id);
    l_url := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/')||'/OA_HTML/OA.jsp?akRegionCode=ORDER_DETAILS_PAGE' || '&' || 'akRegionApplicationId=660' || '&' || 'HeaderId=' || l_header_id;
    wf_engine.SetItemAttrText(itemtype,itemkey, 'TRANSACTION_DETAIL_URL', l_url);
    resultout := 'COMPLETE:' || l_result_code;
    return;

  elsif err_itemtype IN ('OESO','OEOI','OEOA','OEXWFEDI') THEN

       -- need to derive Order Source Id, Orig Sys Document Ref,
       -- Sold To Org Id, Change Sequence
       -- and Header id etc if the order exists

       Get_EM_Key_Info (p_itemtype => err_itemtype,
                            p_itemkey  => err_itemkey,
                            x_order_source_id => l_order_source_id,
                            x_orig_sys_document_ref => l_orig_sys_document_ref,
                            x_sold_to_org_id => l_sold_to_org_id,
                            x_change_sequence => l_change_sequence,
                            x_header_id => l_header_id,
                            x_org_id => l_org_id);


       l_order_source := OE_Id_To_Value.Order_Source (p_order_source_id => l_order_source_id);
       IF l_sold_to_org_id IS NOT NULL THEN
           OE_Id_To_Value.Sold_To_Org (p_sold_to_org_id => l_sold_to_org_id,
                                   x_org => l_sold_to_org,
                                   x_customer_number => l_cust_number);
       END IF;

       FND_MESSAGE.SET_NAME ('ONT','OE_EM_KEY_INFO');
       FND_MESSAGE.SET_TOKEN ('ORDER_SOURCE', l_order_source);
       FND_MESSAGE.SET_TOKEN ('ORIG_SYS_DOCUMENT_REF', l_orig_sys_document_ref);
       FND_MESSAGE.SET_TOKEN ('CUSTOMER', l_sold_to_org);
       l_descriptor := FND_MESSAGE.GET;

       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_SHORT_DESCRIPTOR',
                                                    l_descriptor);

       IF l_org_id IS NOT NULL THEN
         SELECT name
           INTO l_oper_unit_name
          FROM HR_OPerating_units
         WHERE ORGANIZATION_ID = l_org_id;
       END IF;

       If (l_header_id IS NOT NULL) Then
           wf_engine.SetItemAttrText(itemtype, itemkey, 'MESSAGE_NAME', 'OMERROR_MSG');

         SELECT order_number, order_type_id, order_category_code,
                SALESREP_ID, VERSION_NUMBER, FLOW_STATUS_CODE
           into l_order_number, l_order_type_id, l_order_category_code,
                l_salesrep_id, l_version_number, l_flow_status_code
           from oe_order_headers_all
           where header_id = l_header_id;

      BEGIN
         SELECT T.NAME
           INTO   l_order_type_name
           FROM OE_TRANSACTION_TYPES_TL T
          WHERE T.LANGUAGE = userenv('LANG')
           AND T.TRANSACTION_TYPE_ID = l_order_type_id;
      EXCEPTION WHEN OTHERS THEN
             l_order_type_name := NULL;
      END;

      BEGIN
        SELECT MEANING
         INTO l_flow_status_code_meaning
         FROM oe_lookups
        where LOOKUP_CODE = l_flow_status_code
          AND LOOKUP_TYPE = 'FLOW_STATUS';
      EXCEPTION WHEN OTHERS THEN
             l_flow_status_code_meaning := NULL;
      END;

         fnd_message.set_name('ONT', 'OE_WF_ORDER_TYPE');
         fnd_message.set_token('ORDER_TYPE', l_order_type_name);
         l_order_type_txt := fnd_message.get;
         IF l_order_category_code = 'RETURN' THEN
            fnd_message.set_name('ONT', 'OE_WF_RETURN_ORDER');
            fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
            l_header_txt := fnd_message.get;
         ELSE
            fnd_message.set_name('ONT', 'OE_WF_SALES_ORDER');
            fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
             l_header_txt := fnd_message.get;
         END IF;

         --       fnd_message.set_name('ONT', 'OE_WF_OPER_UNIT');
         --       fnd_message.set_token('OPER_UNIT', l_oper_unit_name);
         --       l_oper_unit_name_text := fnd_message.get;

         --       fnd_message.set_name('ONT', 'OE_WF_SALES_REP');
         --       fnd_message.set_token('SALES_REP', l_salesrep);
         --       l_salesrep_text := fnd_message.get;


         l_descriptor_line2 := substrb(l_order_type_txt || ', ' ||
                               l_header_txt, 1, 240);
         --       l_descriptor_line1 := l_oper_unit_name_text;
         --       l_descriptor_line2 := l_salesrep_text;


         wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE2', l_descriptor_line2);

       fnd_message.set_name ('ONT', 'OE_WF_VERSION_NUMBER');
       fnd_message.set_token('VERSION_NUMBER', l_version_number);
       wf_engine.SetItemAttrText(itemtype,itemkey, 'VERSION_NUMBER',
                                                    FND_MESSAGE.GET);
       fnd_message.set_name ('ONT', 'OE_WF_FLOW_STATUS');
       fnd_message.set_token('FLOW_STATUS', l_flow_status_code_meaning);
       wf_engine.SetItemAttrText(itemtype,itemkey, 'FLOW_STATUS',
                                                    FND_MESSAGE.GET);

         --       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE1',
         --                                                    l_descriptor_line1);
         --       wf_engine.SetItemAttrText(itemtype,itemkey, 'ENTITY_DESCRIPTOR_LINE2',
         --                                                    l_descriptor_line2);

         IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110506' THEN
             l_url := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/')||'/OA_HTML/OA.jsp?akRegionCode=ORDER_DETAILS_PAGE' || '&' || 'akRegionApplicationId=660' || '&' || 'HeaderId=' || l_header_id;
             wf_engine.SetItemAttrText(itemtype,itemkey, 'TRANSACTION_DETAIL_URL', l_url);
         END IF;
       else -- l_header_id is null so don't submit the concurrent request
         l_result_code := 'BYPASS_REQUEST';
         wf_engine.SetItemAttrText(itemtype,itemkey, 'TRANSACTION_DETAIL_URL', NULL);
         wf_engine.SetItemAttrText(itemtype, itemkey, 'MESSAGE_NAME', 'OMERROR_MSG_NO_URL');

       end if;
       wf_engine.SetItemAttrText(itemtype,itemkey, 'OPERATING_UNIT',
                                                    l_oper_unit_name);
       wf_engine.SetItemAttrNumber(itemtype,itemkey, 'HEADER_ID',
                                                    l_header_id);

    resultout := 'COMPLETE:' || l_result_code;
    return;

  elsif err_itemtype = 'OEBH' THEN
       Set_blanket_Descriptor ( itemtype, itemkey, err_itemtype, err_itemkey);
       resultout := 'COMPLETE:' || l_result_code;
       return;

  end if; -- err_itemtype = 'OEOH'


  end if; -- funcmode = 'RUN'

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

exception
  when others then
    Wf_Core.Context('OE_STANDARD_WF', 'STANDARD_BLOCK', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Set_entity_Descriptor;


-----------------------------------------------
-- The following two APIs are copied from WF --
-----------------------------------------------
-- -------------------------------------------------------------------
-- CheckErrorActive
--   checks if an error is still active and returns TRUE/FALSE.
--   Use this in an error process to exit out of a timeout loop
-- Called by default error process.
-- -------------------------------------------------------------------
PROCEDURE Check_Error_Active(     itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 ) IS

  l_error_itemtype      VARCHAR2(8);
  l_error_itemkey       VARCHAR2(240);
  l_error_actid         NUMBER;
  status                VARCHAR2(30);

  cursor activity_status (litemtype varchar2, litemkey  varchar2, lactid number ) is
  select WIAS.ACTIVITY_STATUS
  from WF_ITEM_ACTIVITY_STATUSES WIAS
  where WIAS.ITEM_TYPE = litemtype
  and WIAS.ITEM_KEY = litemkey
  and WIAS.PROCESS_ACTIVITY = lactid;


BEGIN

  IF (funcmode = 'RUN') THEN

    --
    -- Get the type and the key of the process that errored out
    -- these were set in the erroring out process by Execute_Error_Process
    --
    l_error_itemkey := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_KEY' );
    l_error_itemtype := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_TYPE' );

    l_error_actid := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ACTIVITY_ID' );

    open activity_status(l_error_itemtype, l_error_itemkey, l_error_actid);
    fetch activity_status into status;
    close activity_status;

    if status = 'ERROR' then
       result:='TRUE';
    else
       result:='FALSE';
    end if;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('OE_STANDARD_WF', 'Check_Error_Active',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
END Check_Error_Active;


-- ResetError
--   Reset the status of an errored activity in an WFERROR process.
-- OUT NOCOPY
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   COMMAND - 'SKIP' or 'RETRY'
--        'SKIP' marks the errored activity complete and continues processing
--        'RETRY' clears the errored activity and runs it again
--   RESULT - Result code to complete the activity with if COMMAND = 'SKIP'
procedure Reset_Error(itemtype   in varchar2,
                     itemkey    in varchar2,
                     actid      in number,
                     funcmode   in varchar2,
                     resultout  in out nocopy varchar2)
is
  cmd varchar2(8);
  result varchar2(30);
  err_itemtype varchar2(8);
  err_itemkey varchar2(240);
  err_actlabel varchar2(62);
  wf_invalid_command exception;
  err_actid number;
  l_header_id number;
  l_orig_sys_document_ref    VARCHAR2(50);
  l_change_sequence          VARCHAR2(50);
  l_order_source_id          NUMBER;
  l_sold_to_org_id           NUMBER;
  l_org_id                   NUMBER;
  err_actname                VARCHAR2(30);
  err_actitemtype            VARCHAR2(8);
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.ResetError');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Get RETRY or SKIP command
  cmd := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'COMMAND');

  -- Get original errored activity info
  err_itemtype := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                            'ERROR_ITEM_TYPE');
  err_itemkey := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                           'ERROR_ITEM_KEY');
  err_actlabel := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                           'ERROR_ACTIVITY_LABEL');
  if (cmd = wf_engine.eng_retry) then
    -- Rerun activity


    err_actid := Wf_Engine.GetItemAttrNumber(itemtype, itemkey,
                                             'ERROR_ACTIVITY_ID');

    l_header_id :=  Wf_Engine.GetItemAttrNumber(itemtype, itemkey,
                                             'HEADER_ID');

    if err_itemtype = 'OEOH' THEN
       OE_MSG_PUB.Update_Status_Code(
                   p_header_id        => l_header_id,
                   p_process_activity => err_actid,
                   p_status_code => 'CLOSED');

    elsif err_itemtype = 'OEOL' THEN
       OE_MSG_PUB.Update_Status_Code(
                   p_header_id        => l_header_id,
                   p_line_id          => err_itemkey,
                   p_process_activity => err_actid,
                   p_status_code => 'CLOSED');
    elsif err_itemtype IN ('OEOA','OEOI','OESO','OEXWFEDI') THEN

      Get_EM_Key_Info (p_itemtype => err_itemtype,
                            p_itemkey  => err_itemkey,
                            x_order_source_id => l_order_source_id,
                            x_orig_sys_document_ref => l_orig_sys_document_ref,
                            x_sold_to_org_id => l_sold_to_org_id,
                            x_change_sequence => l_change_sequence,
                            x_header_id => l_header_id,
                            x_org_id => l_org_id);

       /* l_order_source_id :=  Wf_Engine.GetItemAttrNumber(itemtype, itemkey,
                                             'ORDER_SOURCE_ID');
       l_orig_sys_document_ref :=  Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                             'ORIG_SYS_DOCUMENT_REF');*/
       OE_MSG_PUB.Update_Status_Code(
                   p_order_source_id        => l_order_source_id,
                   p_orig_sys_document_ref  => l_orig_sys_document_ref,
                   p_entity_code => 'ELECMSG_'||err_itemtype,
                   p_entity_id => to_number(err_itemkey),
                   p_process_activity => err_actid,
                   p_status_code => 'CLOSED');
    end if;

    IF err_itemtype = 'OEOL' THEN
       BEGIN
         WF_Process_Activity.ActivityName (err_actid,err_actitemtype,err_actname);
       EXCEPTION
          WHEN OTHERS THEN
             err_actname := NULL;
       END;
    END IF;

    IF NOT (err_itemtype = 'OEOL' AND err_actname IS NOT NULL AND err_actname = 'SHIP_LINE'
            AND Check_Closed_Delivery_Detail (err_itemkey, err_actid)) THEN
       Wf_Engine.HandleError(err_itemtype, err_itemkey, err_actlabel,
                          cmd, '');
    END IF;

/* Disallow skip mode because it is too difficult to
   assign and validate the RESULT value
  elsif (cmd = wf_engine.eng_skip) then
    -- Get result code
    result := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid,
              'RESULT');
    -- Mark activity complete and continue processing
    Wf_Engine.HandleError(err_itemtype, err_itemkey, err_actlabel,
                          cmd, result);
*/
  else
    raise wf_invalid_command;
  end if;

  resultout := wf_engine.eng_null;
exception
  when wf_invalid_command then
    Wf_Core.Context('OE_STANDARD_WF', 'Reset_Error', itemtype,
                    itemkey, to_char(actid), funcmode);
    Wf_Core.Token('COMMAND', cmd);
    Wf_Core.Raise('WFSQL_COMMAND');
  when others then
    Wf_Core.Context('OE_STANDARD_WF', 'Reset_Error', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Reset_Error;

Procedure Get_EM_Key_Info (p_itemtype  IN VARCHAR2,
                            p_itemkey  IN VARCHAR2,
                            x_order_source_id OUT NOCOPY NUMBER,
                            x_orig_sys_document_ref OUT NOCOPY VARCHAR2,
                            x_sold_to_org_id OUT NOCOPY NUMBER,
                            x_change_sequence OUT NOCOPY VARCHAR2,
                            x_header_id OUT NOCOPY NUMBER,
                            x_org_id OUT NOCOPY NUMBER)
IS
l_customer_key_profile     VARCHAR2(1);
BEGIN
   If p_itemtype IN ('OEOI','OEOA','OESO') Then

      x_order_source_id := 20;

      if p_itemtype IN ('OESO','OEOA') then
         x_orig_sys_document_ref := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'ORIG_SYS_DOCUMENT_REF');
      else
         x_orig_sys_document_ref := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'PARAMETER2');
      end if;

      x_sold_to_org_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'PARAMETER4');

      x_change_sequence := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'PARAMETER7');

      x_org_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'ORG_ID');

      if p_itemtype = 'OESO' then
          x_header_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'HEADER_ID');
      else
          -- try to derive header id for OEOA and OEOI
          fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
          l_customer_key_profile := nvl(l_customer_key_profile, 'N');

          Begin
            Select header_id
             Into x_header_id
             From oe_order_headers_all
             Where orig_sys_document_ref = x_orig_sys_document_ref
             And decode(l_customer_key_profile, 'Y',
	     nvl(sold_to_org_id,                  -999), 1)
              = decode(l_customer_key_profile, 'Y',
             nvl(x_sold_to_org_id,                -999), 1)
             And order_source_id = x_order_source_id;

          Exception When Others Then
             x_header_id := NULL;
          End;
      end if;
   Elsif p_itemtype = 'OEXWFEDI' Then
      x_order_source_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'ORDER_SOURCE_ID');

      x_orig_sys_document_ref := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'ORIG_SYS_DOCUMENT_REF');
      x_sold_to_org_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'SOLD_TO_ORG_ID');
      x_org_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'ORG_ID');
      x_change_sequence := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'CHANGE_SEQUENCE');
      x_header_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'HEADER_ID');

   End If;



End Get_EM_Key_Info;

-- overloaded leaner version for batch retry
PROCEDURE Get_EM_Key_Info (p_itemtype  IN VARCHAR2,
                            p_itemkey  IN VARCHAR2,
                            x_order_source_id OUT NOCOPY NUMBER,
                            x_orig_sys_document_ref OUT NOCOPY VARCHAR2)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering Get_EM_Key_Info');
   END IF;

   If p_itemtype IN ('OEOI','OEOA','OESO') Then

      x_order_source_id := 20;

      if p_itemtype IN ('OESO','OEOA') then
         x_orig_sys_document_ref := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'ORIG_SYS_DOCUMENT_REF');
      else
         x_orig_sys_document_ref := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'PARAMETER2');
      end if;

   ELSIF p_itemtype = 'OEXWFEDI' Then

      x_order_source_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'ORDER_SOURCE_ID');
      x_orig_sys_document_ref := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'ORIG_SYS_DOCUMENT_REF');

   ELSIF p_itemtype = 'OEEM' THEN

      x_order_source_id := wf_engine.GetItemAttrNumber (p_itemtype, p_itemkey, 'ORDER_SOURCE_ID');
      x_orig_sys_document_ref := wf_engine.GetItemAttrText (p_itemtype, p_itemkey, 'PARTNER_DOCUMENT_NO');

   END IF;
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Exiting Get_EM_Key_Info with order_source_id: ' || x_order_source_id || ' and orig_sys_document_ref: ' || x_orig_sys_document_ref);
   END IF;
END Get_EM_Key_Info;

FUNCTION Get_Activity_Display_Name (p_activity_item_type IN VARCHAR2,
                                    p_activity_name IN VARCHAR2)
RETURN VARCHAR2
IS
l_activity_display_name VARCHAR2(80);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Entering Get_Activity_Display_Name');
    END IF;
    SELECT display_name
      INTO l_activity_display_name
      FROM WF_Activities_VL
     WHERE Name = p_activity_name
       AND Item_Type = p_activity_item_type
       AND Version = (SELECT max(version)
			FROM WF_Activities_VL
		       WHERE Name = p_activity_name
			 AND Item_Type = p_activity_item_type);
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Exiting Get_Activity_Display_Name with result: ' ||l_activity_display_name);
    END IF;
    RETURN l_activity_display_name;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Exception in Get_Activity_Display_Name, returning Activity Name instead: '||p_activity_name);
      END IF;
      RETURN p_activity_name;
END Get_Activity_Display_Name;

PROCEDURE put(p_concat_segment IN VARCHAR2,
              p_activity_item_type IN VARCHAR2,
              p_activity_name IN VARCHAR2,
              p_process_item_type IN VARCHAR2,
              p_initial_count IN NUMBER DEFAULT NULL,
              p_final_count IN NUMBER DEFAULT NULL,
              x_activity_display_name OUT NOCOPY VARCHAR2)
IS
   l_tab_index BINARY_INTEGER;
   l_stored BOOLEAN := FALSE;
   l_hash_value NUMBER;
   l_initial_count NUMBER;
   l_final_count NUMBER;
   l_activity_display_name VARCHAR2(80);
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering Put');
   END IF;

   l_initial_count := nvl(p_initial_count, 0);
   l_final_count := nvl(p_final_count, 0);

   l_tab_index := dbms_utility.get_hash_value(p_concat_segment,1,TABLE_SIZE);
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Put:hash_value:'||l_tab_index,1);
   END IF;
   IF  Count_Tbl.EXISTS(l_tab_index) THEN
       IF Count_Tbl(l_tab_index).concat_segment =  p_concat_segment THEN
          Count_Tbl(l_tab_index).initial_count := Count_Tbl(l_tab_index).initial_count + l_initial_count;
          Count_Tbl(l_tab_index).final_count := Count_Tbl(l_tab_index).final_count + l_final_count;
          l_activity_display_name := Count_Tbl(l_tab_index).activity_display_name;
          l_stored := TRUE;
          IF l_debug_level > 0 THEN
             oe_debug_pub.add(p_concat_segment || ' Initial ' ||  Count_Tbl(l_tab_index).initial_count);
             oe_debug_pub.add(p_concat_segment || ' Final ' ||  Count_Tbl(l_tab_index).final_count);
          END IF;

       ELSE
         l_hash_value := l_tab_index;
         WHILE l_tab_index < TABLE_SIZE
           AND NOT l_stored LOOP
            IF  Count_Tbl.EXISTS(l_tab_index) THEN
                IF  Count_Tbl(l_tab_index).concat_segment =  p_concat_segment THEN
                    Count_Tbl(l_tab_index).initial_count := Count_Tbl(l_tab_index).initial_count + l_initial_count;
                    Count_Tbl(l_tab_index).final_count := Count_Tbl(l_tab_index).final_count + l_final_count;
                    l_activity_display_name := Count_Tbl(l_tab_index).activity_display_name;
                    l_stored := TRUE;
                    IF l_debug_level > 0 THEN
                       oe_debug_pub.add(p_concat_segment || ' 1Initial ' ||  Count_Tbl(l_tab_index).initial_count);
                       oe_debug_pub.add(p_concat_segment || ' 1Final ' ||  Count_Tbl(l_tab_index).final_count);
                    END IF;
                 ELSE
                  l_tab_index := l_tab_index +1;
               END IF;
            ELSE
               Count_Tbl(l_tab_index).initial_count := nvl(Count_Tbl(l_tab_index).initial_count,0) + l_initial_count;
               Count_Tbl(l_tab_index).final_count := nvl(Count_Tbl(l_tab_index).final_count,0) + l_final_count;
               Count_Tbl(l_tab_index).activity_display_name := Get_Activity_Display_Name (p_activity_item_type, p_activity_name);
               l_activity_display_name := Count_Tbl(l_tab_index).activity_display_name;
               Count_Tbl(l_tab_index).activity_name := p_activity_name;
               Count_Tbl(l_tab_index).process_item_type := p_process_item_type;
               Count_Tbl(l_tab_index).concat_segment := p_concat_segment;
               IF l_debug_level > 0 THEN
                  oe_debug_pub.add(p_concat_segment || ' 2Initial ' ||  Count_Tbl(l_tab_index).initial_count);
                  oe_debug_pub.add(p_concat_segment || ' 2Final ' ||  Count_Tbl(l_tab_index).final_count);
               END IF;
               l_stored := TRUE;
            END IF;
         END LOOP;
         IF NOT l_stored THEN
            l_tab_index := 1;
            WHILE l_tab_index < l_hash_value
              AND NOT l_stored LOOP
               IF Count_Tbl.EXISTS(l_tab_index) THEN
                  IF Count_Tbl(l_tab_index).concat_segment =  p_concat_segment THEN
                     Count_Tbl(l_tab_index).initial_count := Count_Tbl(l_tab_index).initial_count + l_initial_count;
                     Count_Tbl(l_tab_index).final_count := Count_Tbl(l_tab_index).final_count + l_final_count;
                     l_activity_display_name := Count_Tbl(l_tab_index).activity_display_name;
                     l_stored := TRUE;
                     IF l_debug_level > 0 THEN
                        oe_debug_pub.add(p_concat_segment || ' 3Initial ' ||  Count_Tbl(l_tab_index).initial_count);
                        oe_debug_pub.add(p_concat_segment || ' 3Final ' ||  Count_Tbl(l_tab_index).final_count);
                     END IF;
                  ELSE
                     l_tab_index := l_tab_index +1;
                  END IF;
               ELSE
                  Count_Tbl(l_tab_index).initial_count := nvl(Count_Tbl(l_tab_index).initial_count,0) + l_initial_count;
                  Count_Tbl(l_tab_index).final_count := nvl(Count_Tbl(l_tab_index).final_count,0) + l_final_count;
                  Count_Tbl(l_tab_index).activity_display_name := Get_Activity_Display_Name (p_activity_item_type, p_activity_name);
                  l_activity_display_name := Count_Tbl(l_tab_index).activity_display_name;
                  Count_Tbl(l_tab_index).activity_name := p_activity_name;
                  Count_Tbl(l_tab_index).process_item_type := p_process_item_type;
                  Count_Tbl(l_tab_index).concat_segment := p_concat_segment;
                  IF l_debug_level > 0 THEN
                     oe_debug_pub.add(p_concat_segment || ' 4Initial ' ||  Count_Tbl(l_tab_index).initial_count);
                     oe_debug_pub.add(p_concat_segment || ' 4Final ' ||  Count_Tbl(l_tab_index).final_count);
                  END IF;
                  l_stored := TRUE;
               END IF;
            END LOOP;
         END IF;
      END IF;
   ELSE
      Count_Tbl(l_tab_index) := Count_Rec;
      Count_Tbl(l_tab_index).initial_count := nvl(Count_Tbl(l_tab_index).initial_count,0) + l_initial_count;
      Count_Tbl(l_tab_index).final_count := nvl(Count_Tbl(l_tab_index).final_count,0) + l_final_count;
      Count_Tbl(l_tab_index).activity_display_name := Get_Activity_Display_Name (p_activity_item_type, p_activity_name);
      l_activity_display_name := Count_Tbl(l_tab_index).activity_display_name;
      Count_Tbl(l_tab_index).activity_name := p_activity_name;
      Count_Tbl(l_tab_index).process_item_type := p_process_item_type;
      Count_Tbl(l_tab_index).concat_segment := p_concat_segment;
      IF l_debug_level > 0 THEN
         oe_debug_pub.add(p_concat_segment || ' 5Initial ' ||  Count_Tbl(l_tab_index).initial_count);
         oe_debug_pub.add(p_concat_segment || ' 5Final ' ||  Count_Tbl(l_tab_index).final_count);
      END IF;
      l_stored := TRUE;
   END IF;
   x_activity_display_name := l_activity_display_name;
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Exiting Put with activity display name: ' || l_activity_display_name);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Exiting Put with unexpected error: ' || SQLERRM);
      END IF;
      NULL;
END put;


FUNCTION Check_Closed_Delivery_Detail (p_item_key IN VARCHAR2,
                                       p_process_activity IN NUMBER)
RETURN BOOLEAN
IS
l_count NUMBER;
l_source_code_oe CONSTANT VARCHAR2(2) := 'OE';
l_released_status_closed CONSTANT VARCHAR2(1) := 'C';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Entering Check_Closed_Delivery_Detail');
  END IF;
  SELECT 1
    INTO l_count
    FROM wsh_delivery_details
   WHERE source_line_id = to_number(p_item_key)
     AND source_code = l_source_code_oe
     AND released_status = l_released_status_closed
     AND rownum < 2;
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Closed delivery detail exists');
  END IF;

  BEGIN
     Wf_Item_Activity_Status.Create_Status (itemtype => 'OEOL',
                                            itemkey => p_item_key,
                                            actid => p_process_activity,
                                            status => wf_engine.eng_notified,
                                            result => wf_engine.eng_null,
                                            beginning => SYSDATE,
                                            ending => null);
  EXCEPTION
     WHEN OTHERS THEN
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Unexpected error: Cound not create notified status '|| SQLERRM);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- cause rollback in caller
  END;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exiting Check_Closed_Delivery_Detail, Return True');
  END IF;
  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('Exiting Check_Closed_Delivery_Detail, Return False');
     END IF;
     RETURN FALSE;
  WHEN OTHERS THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('Exiting Check_Closed_Delivery_Detail, Return False and unexpected error '|| SQLERRM);
     END IF;
     RAISE;
END Check_Closed_Delivery_Detail;

PROCEDURE Call_OM_Selector (p_item_type IN VARCHAR2,
                            p_item_key IN VARCHAR2,
                            p_activity_id IN NUMBER,
                            p_mode IN VARCHAR2,
                            p_x_result IN OUT NOCOPY VARCHAR2)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Entering Call_OM_Selector');
       oe_debug_pub.add('Calling selector function for item type: '|| p_item_type || ' item key: ' || p_item_key || ' activity_id: ' || p_activity_id || ' mode: ' || p_mode);
    END IF;

    p_x_result := NULL;

    IF p_item_type = 'OEOH' THEN
       OE_Standard_Wf.OEOH_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OEOL' THEN
       OE_Standard_Wf.OEOL_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OEBH' THEN
       OE_Standard_Wf.OEBH_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OENH' THEN
       OE_Standard_Wf.OENH_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OEOI' THEN
       OE_Order_Import_Wf.OEOI_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OEOA' THEN
       OE_Order_Import_Wf.OEOA_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OESO' THEN
       OE_Order_Import_Wf.OESO_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OEEM' THEN
       OE_Elecmsgs_Pvt.OEEM_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    ELSIF p_item_type = 'OEXWFEDI' THEN
       OE_Update_Ack_Util.OE_Edi_Selector (p_item_type,
				     p_item_key,
				     p_activity_id,
				     p_mode, p_x_result);
    END IF;
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Exiting Call_OM_Selector with result: ' || p_x_result);
    END IF;

END;

FUNCTION Activity_In_Error (p_item_type IN VARCHAR2,
                            p_item_key IN VARCHAR2,
                            p_activity_id IN VARCHAR2)
RETURN BOOLEAN
IS
l_count NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_error_status CONSTANT VARCHAR2(5) := 'ERROR';
BEGIN
  l_count := 0;

  BEGIN
    SELECT 1
      INTO l_count
      FROM WF_ITEM_ACTIVITY_STATUSES IAS
     WHERE IAS.ITEM_TYPE = p_item_type
       AND IAS.ITEM_KEY = p_item_key
       AND IAS.PROCESS_ACTIVITY = p_activity_id
       AND IAS.ACTIVITY_STATUS = l_error_status
       AND rownum = 1;
  EXCEPTION
     WHEN OTHERS THEN
	l_count := 0;
  END;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add ('Error count of ' || l_count);
  END IF;

  RETURN (l_count <> 0);

END Activity_In_Error;


PROCEDURE Parse_User_Key (p_item_type IN VARCHAR2,
                          p_item_key IN VARCHAR2,
                          p_user_key IN VARCHAR2,
                          x_order_source_id OUT NOCOPY NUMBER,
                          x_orig_sys_document_ref OUT NOCOPY VARCHAR2)
IS
l_pos NUMBER;
l_pos2 NUMBER;
l_pos3 NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Entering Parse_User_Key');
  END IF;
  IF p_item_type IN ('OEOI', 'OESO', 'OEOA') THEN
     x_order_source_id := 20;
     l_pos := instr (p_user_key, ',');
     x_orig_sys_document_ref := substr(p_user_key, 1, l_pos-1);

  ELSIF p_item_type = 'OEXWFEDI' THEN
     x_order_source_id := wf_engine.GetItemAttrText (p_item_type,
                                                    p_item_key,
                                                    'ORDER_SOURCE_ID'
                                                    );
     l_pos := instr (p_user_key, ',');
     -- dbms_output.put_line(l_pos || ' x' || l_pos2|| ' y ' ||l_pos3);

     x_orig_sys_document_ref := substr(p_user_key, 1, l_pos-1);

  ELSIF p_item_type = 'OEEM' THEN
     l_pos := instr(p_user_key, ','); -- position of first comma
     l_pos2 := instr(p_user_key, ',',l_pos+1);  -- position of second comma
     l_pos3 := instr(p_user_key, ',',l_pos2+1); -- position of third comma
     -- dbms_output.put_line(l_pos || ' x' || l_pos2|| ' y ' ||l_pos3);
     x_order_source_id := to_number(substr(p_user_key, 1, l_pos-1));
     x_orig_sys_document_ref := substr(p_user_key, l_pos2+1, l_pos3-l_pos2-1);

  END IF;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exiting Parse_User_Key with order_source_id: '|| x_order_source_id ||
                      ' and orig_sys_document_ref : ' || x_orig_sys_document_ref);
  END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL; -- don't completely bail as we can still check the WF item attrs
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Exiting Parse_User_Key with order_source_id: '|| x_order_source_id ||
                      ' and orig_sys_document_ref : ' || x_orig_sys_document_ref || ' and unexpected error: ' || SQLERRM);
      END IF;
END Parse_User_Key;

PROCEDURE Print_Open_Messages (p_item_type VARCHAR2,
			       p_item_key VARCHAR2,
			       p_activity_id VARCHAR2,
                               p_order_source_id NUMBER,
                               p_orig_sys_document_ref VARCHAR2,
                               p_header_id NUMBER)
IS
l_msg_rec Msg_Rec_Type;
l_open CONSTANT VARCHAR2(4) := 'OPEN';
l_closed CONSTANT VARCHAR2(6) := 'CLOSED';
l_entity_code VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

CURSOR l_msg_cursor_1 IS
  SELECT tl.message_text
    FROM oe_processing_msgs msg, oe_processing_msgs_tl tl
   WHERE msg.transaction_id = tl.transaction_id
     AND msg.header_id = to_number(p_item_key)
     AND nvl(msg.message_status_code, l_open) <> l_closed
     AND tl.language = USERENV('LANG')
   ORDER BY msg.transaction_id;


CURSOR l_msg_cursor_2 IS
  SELECT tl.message_text
    FROM oe_processing_msgs msg, oe_processing_msgs_tl tl
   WHERE msg.transaction_id = tl.transaction_id
     AND msg.header_id = p_header_id
     AND msg.line_id = to_number (p_item_key)
     AND nvl(msg.message_status_code, l_open) <> l_closed
     AND tl.language = USERENV('LANG')
    ORDER BY msg.transaction_id;

CURSOR l_msg_cursor_3 IS
  SELECT tl.message_text
    FROM oe_processing_msgs msg, oe_processing_msgs_tl tl
   WHERE msg.transaction_id = tl.transaction_id
     AND msg.entity_id = to_number(p_item_key)
     AND msg.entity_code = l_entity_code
     AND nvl(msg.message_status_code, l_open) <> l_closed
     AND tl.language = USERENV('LANG')
   ORDER BY msg.transaction_id;

CURSOR l_msg_cursor_4 IS
  SELECT tl.message_text
    FROM oe_processing_msgs msg, oe_processing_msgs_tl tl
   WHERE msg.transaction_id = tl.transaction_id
     AND msg.entity_id = to_number(p_item_key)
     AND msg.entity_code = l_entity_code
     AND msg.order_source_id = p_order_source_id
     AND msg.original_sys_document_ref = p_orig_sys_document_ref
     AND nvl(msg.message_status_code, l_open) <> l_closed
     AND tl.language = USERENV('LANG')
   ORDER BY msg.transaction_id;
BEGIN
   IF p_item_type IN ('OEOH', 'OENH') THEN
      OPEN l_msg_cursor_1;
      FETCH l_msg_cursor_1 BULK COLLECT INTO
         l_msg_rec.message_text LIMIT 1000;
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Fetched ' || l_msg_rec.message_text.count || ' records from msg cursor 1 for item type ' ||p_item_type);
      END IF;
      FOR i in 1..l_msg_rec.message_text.count LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG, '      '||l_msg_rec.message_text(i));
      END LOOP;
      CLOSE l_msg_cursor_1;
   ELSIF p_item_type = 'OEOL' THEN
      OPEN l_msg_cursor_2;
      FETCH l_msg_cursor_2 BULK COLLECT INTO
         l_msg_rec.message_text LIMIT 1000;
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Fetched ' || l_msg_rec.message_text.count || ' records from msg cursor 2 for item type ' ||p_item_type);
      END IF;
      FOR i in 1..l_msg_rec.message_text.count LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG, '      '||l_msg_rec.message_text(i));
      END LOOP;
      CLOSE l_msg_cursor_2;
   ELSIF p_item_type = 'OEBH' THEN
      l_entity_code := 'BLANKET_HEADER';

      OPEN l_msg_cursor_3;
      FETCH l_msg_cursor_3 BULK COLLECT INTO
         l_msg_rec.message_text LIMIT 1000;
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Fetched ' || l_msg_rec.message_text.count || ' records from msg cursor 3 for item type ' ||p_item_type);
      END IF;
      FOR i in 1..l_msg_rec.message_text.count LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG, '      '||l_msg_rec.message_text(i));
      END LOOP;
      CLOSE l_msg_cursor_3;
   ELSIF p_item_type IN ('OEOI', 'OEOA', 'OESO', 'OEXWFEDI') THEN
      l_entity_code := 'ELECMSG_'||p_item_type;

      OPEN l_msg_cursor_4;
      FETCH l_msg_cursor_4 BULK COLLECT INTO
         l_msg_rec.message_text LIMIT 1000;
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Fetched ' || l_msg_rec.message_text.count || ' records from msg cursor 4 for item type ' ||p_item_type);
      END IF;
      FOR i in 1..l_msg_rec.message_text.count LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG, '      '||l_msg_rec.message_text(i));
      END LOOP;
      CLOSE l_msg_cursor_4;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF l_msg_cursor_1%ISOPEN THEN
         CLOSE l_msg_cursor_1;
      ELSIF l_msg_cursor_2%ISOPEN THEN
         CLOSE l_msg_cursor_2;
      ELSIF l_msg_cursor_3%ISOPEN THEN
         CLOSE l_msg_cursor_3;
      ELSIF l_msg_cursor_4%ISOPEN THEN
         CLOSE l_msg_cursor_4;
      END IF;
END Print_Open_Messages;

FUNCTION get_lock (p_item_type IN VARCHAR2,
                            p_item_key IN VARCHAR2)
RETURN BOOLEAN IS

l_ord_num NUMBER;
l_hdr_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering oe_error_wf.get_lock ');
        END IF;

        IF p_item_type in ('OEOH','OENH') THEN

           SELECT ORDER_NUMBER into l_ord_num
             FROM OE_ORDER_HEADERS_ALL
            WHERE header_id = to_number(p_item_key)
            FOR UPDATE NOWAIT;

        ELSIF p_item_type = 'OEOL' THEN

                SELECT header_id into l_hdr_id
                  FROM OE_ORDER_LINES_ALL
                 WHERE line_id = to_number(p_item_key)
                 FOR UPDATE NOWAIT;

                 SELECT order_number into l_ord_num
                   FROM OE_ORDER_HEADERS_ALL
                  WHERE header_id = l_hdr_id
                  FOR UPDATE NOWAIT;

        ELSIF p_item_type = 'OEBH' THEN

              SELECT header_id into l_hdr_id
                FROM OE_BLANKET_HEADERS_ALL
               WHERE header_id = to_number(p_item_key)
                FOR UPDATE NOWAIT;

        END IF;

        return true;

EXCEPTION
/*
        WHEN TIMEOUT_ON_RESOURCE THEN
        IF l_debug_level > 0 THEN
             oe_debug_pub.add('TIMEOUT_ON_RESOURCE Exception while locking the record in oe_errors_wf.get_lock for item ' ||p_item_type||' with key '||p_item_key);
             oe_debug_pub.add('The SQL ERROR is '||substr(SQLERRM, 1, 512));
        END IF;
             return false;
     */
        WHEN OTHERS THEN
        IF l_debug_level > 0 THEN
             oe_debug_pub.add('Exception while locking the record in oe_errors_wf.get_lock for item ' ||p_item_type||' with key '||p_item_key);
             oe_debug_pub.add('The SQL ERROR is '||substr(SQLERRM, 1, 512));
        END IF;
        return false;
        -- raise;
END get_lock;



PROCEDURE close_messages (p_item_type IN varchar2,
                          p_item_key  IN varchar2,
                          p_activity_id IN NUMBER default null,
                          p_header_id  IN NUMBER default null,
                          p_user_key   IN varchar2 default null,
                          x_order_source_id OUT NOCOPY NUMBER,
                          x_orig_sys_document_ref OUT NOCOPY varchar2
                         ) IS

l_order_source_id NUMBER;
l_orig_sys_document_ref VARCHAR2(50);


BEGIN
		IF p_item_type IN ('OEOH','OENH') THEN

		   OE_MSG_PUB.Update_Status_Code(
		       p_header_id        => to_number(p_item_key),
		       p_process_activity => p_activity_id,
		       p_status_code => 'CLOSED');

		ELSIF p_item_type = 'OEBH' THEN

		    OE_MSG_PUB.Update_Status_Code(
		       p_entity_code => 'BLANKET_HEADER',
		       p_entity_id => to_number(p_item_key),
		       p_process_activity => p_activity_id,
		       p_status_code => 'CLOSED');

		ELSIF p_item_type = 'OEOL' THEN
		   OE_MSG_PUB.Update_Status_Code(
		       p_header_id        => p_header_id,
		       p_line_id        => to_number(p_item_key),
		       p_process_activity => p_activity_id,
		       p_status_code => 'CLOSED');

		ELSIF p_item_type IN ('OEOI', 'OEOA', 'OESO', 'OEXWFEDI') THEN
		      -- first try to parse the user key string
		      -- in case we cannot derive the info from here,
		      -- go to the WF item attr (more expensive)
		     IF p_user_key IS NOT NULL THEN
			Parse_User_Key (p_item_type => p_item_type,
					p_item_key => p_item_key,
					p_user_key => p_user_key,
					x_order_source_id => l_order_source_id,
					x_orig_sys_document_ref => l_orig_sys_document_ref);
                     END IF;
                     IF l_order_source_id IS NULL or l_orig_sys_document_ref IS NULL THEN
			Get_EM_Key_Info (p_itemtype => p_item_type,
					    p_itemkey => p_item_key,
					    x_order_source_id => l_order_source_id,
					    x_orig_sys_document_ref => l_orig_sys_document_ref);
		     END IF;
                     OE_MSG_PUB.Update_Status_Code(
			       p_order_source_id        => l_order_source_id,
			       p_orig_sys_document_ref  => l_orig_sys_document_ref,
			       p_entity_code => 'ELECMSG_'||p_item_type,
			       p_entity_id => to_number(p_item_key),
			       p_process_activity => p_activity_id,
			       p_status_code => 'CLOSED');
  		ELSIF p_item_type = 'OMERROR' THEN
		     null;
		END IF;
	     x_order_source_id := l_order_source_id;
	     x_orig_sys_document_ref := l_orig_sys_document_ref;

END close_messages;

PROCEDURE Retry_Flows (
	   p_item_key                           IN  VARCHAR2 DEFAULT NULL,
	   p_item_type			        IN  VARCHAR2,
           p_item_type_display_name             IN  VARCHAR2,
	   p_activity_name		       	IN  VARCHAR2 DEFAULT NULL,
	   p_activity_error_date_from           IN  DATE DEFAULT NULL,
	   p_activity_error_date_to             IN  DATE DEFAULT NULL,
           p_mode                               IN  VARCHAR2,
           x_return_status                      OUT NOCOPY VARCHAR2)
IS
l_error_status CONSTANT VARCHAR2(5) := 'ERROR';
l_org_id CONSTANT VARCHAR2(6) := 'ORG_ID';
l_retry_count NUMBER;
l_commit_count NUMBER;
p_x_result VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_ignore_error_check BOOLEAN;
l_header_id NUMBER;
l_order_source_id NUMBER;
l_orig_sys_document_ref VARCHAR2(50);
l_activity_display_name VARCHAR2(80);
l_error_msg VARCHAR2(512);
l_last_org_id NUMBER;
l_end_total_time NUMBER;
l_start_total_time NUMBER;
l_get_lock_failed BOOLEAN := false;

CURSOR l_retry_cursor_1 IS
   SELECT IAS.ITEM_KEY, PA.INSTANCE_LABEL, PA.ACTIVITY_NAME, PA.PROCESS_NAME, IAS.PROCESS_ACTIVITY, I.USER_KEY, I.PARENT_ITEM_TYPE, I.PARENT_ITEM_KEY, PA.ACTIVITY_ITEM_TYPE, WAT.NUMBER_VALUE
     FROM WF_PROCESS_ACTIVITIES PA,
	  WF_ITEMS I,
	  WF_ITEM_ACTIVITY_STATUSES IAS,
          WF_ITEM_ATTRIBUTE_VALUES WAT,
          WF_ACTIVITIES WA
    WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
      AND IAS.ITEM_KEY = I.ITEM_KEY
      AND IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
      AND IAS.ITEM_TYPE = OE_GLOBALS.G_WFI_LIN
      AND I.PARENT_ITEM_KEY = p_item_key
      AND I.PARENT_ITEM_TYPE = OE_GLOBALS.G_WFI_HDR
      AND PA.PROCESS_ITEM_TYPE = OE_GLOBALS.G_WFI_LIN
      AND IAS.ACTIVITY_STATUS = l_error_status
      AND I.END_DATE IS NULL
      AND WAT.ITEM_TYPE = IAS.ITEM_TYPE
      AND WAT.ITEM_KEY = IAS.ITEM_KEY
      AND WAT.NAME = l_org_id
      AND WA.ITEM_TYPE = PA.ACTIVITY_ITEM_TYPE
      AND WA.NAME = PA.ACTIVITY_NAME
      AND WA.TYPE NOT IN ('PROCESS','FOLDER')
      AND I.BEGIN_DATE >= WA.BEGIN_DATE
      AND I.BEGIN_DATE < NVL(WA.END_DATE, I.BEGIN_DATE+1) --Modified for bug 6443885
      ORDER BY WAT.NUMBER_VALUE;

CURSOR l_retry_cursor_2 IS
   SELECT IAS.ITEM_KEY, PA.INSTANCE_LABEL, PA.ACTIVITY_NAME, PA.PROCESS_NAME, IAS.PROCESS_ACTIVITY, I.USER_KEY, I.PARENT_ITEM_TYPE, I.PARENT_ITEM_KEY, PA.ACTIVITY_ITEM_TYPE, WAT.NUMBER_VALUE
     FROM WF_PROCESS_ACTIVITIES PA,
	  WF_ITEMS I,
	  WF_ITEM_ACTIVITY_STATUSES IAS,
          WF_ITEM_ATTRIBUTE_VALUES WAT,
          WF_ACTIVITIES WA
    WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
      AND IAS.ITEM_KEY = I.ITEM_KEY
      AND IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
      AND IAS.ITEM_TYPE = OE_GLOBALS.G_WFI_HDR
      AND IAS.ITEM_KEY = p_item_key
      AND PA.PROCESS_ITEM_TYPE = OE_GLOBALS.G_WFI_HDR
      AND IAS.ACTIVITY_STATUS = l_error_status
      AND I.END_DATE IS NULL
      AND WAT.ITEM_TYPE = IAS.ITEM_TYPE
      AND WAT.ITEM_KEY = IAS.ITEM_KEY
      AND WAT.NAME = l_org_id
      AND WA.ITEM_TYPE = PA.ACTIVITY_ITEM_TYPE
      AND WA.NAME = PA.ACTIVITY_NAME
      AND WA.TYPE NOT IN ('PROCESS','FOLDER')
      AND I.BEGIN_DATE >= WA.BEGIN_DATE
      AND I.BEGIN_DATE < NVL(WA.END_DATE, I.BEGIN_DATE+1) --Modified for bug 6443885
      ORDER BY WAT.NUMBER_VALUE;

CURSOR l_retry_cursor_3 IS
   SELECT IAS.ITEM_KEY, PA.INSTANCE_LABEL, PA.ACTIVITY_NAME, PA.PROCESS_NAME, IAS.PROCESS_ACTIVITY, I.USER_KEY, I.PARENT_ITEM_TYPE, I.PARENT_ITEM_KEY, PA.ACTIVITY_ITEM_TYPE, WAT.NUMBER_VALUE
     FROM WF_PROCESS_ACTIVITIES PA,
	  WF_ITEMS I,
	  WF_ITEM_ACTIVITY_STATUSES IAS,
          WF_ITEM_ATTRIBUTE_VALUES WAT,
          WF_ACTIVITIES WA
    WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
      AND IAS.ITEM_KEY = I.ITEM_KEY
      AND IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
      AND IAS.ITEM_TYPE = p_item_type
      AND PA.PROCESS_ITEM_TYPE = p_item_type
      AND PA.ACTIVITY_NAME = p_activity_name
      AND IAS.ACTIVITY_STATUS = l_error_status
      AND IAS.BEGIN_DATE BETWEEN nvl(p_activity_error_date_from, IAS.BEGIN_DATE)
                             AND nvl(p_activity_error_date_to, IAS.BEGIN_DATE)
      AND I.END_DATE IS NULL
      AND WAT.ITEM_TYPE = IAS.ITEM_TYPE
      AND WAT.ITEM_KEY = IAS.ITEM_KEY
      AND WAT.NAME = l_org_id
      AND WA.ITEM_TYPE = PA.ACTIVITY_ITEM_TYPE
      AND WA.NAME = PA.ACTIVITY_NAME
      AND WA.TYPE NOT IN ('PROCESS','FOLDER')
      AND I.BEGIN_DATE >= WA.BEGIN_DATE
      AND I.BEGIN_DATE < NVL(WA.END_DATE, I.BEGIN_DATE+1) --Modified for bug 6443885
      ORDER BY WAT.NUMBER_VALUE;

CURSOR l_retry_cursor_4 IS
   SELECT IAS.ITEM_KEY, PA.INSTANCE_LABEL, PA.ACTIVITY_NAME, PA.PROCESS_NAME, IAS.PROCESS_ACTIVITY, I.USER_KEY, I.PARENT_ITEM_TYPE, I.PARENT_ITEM_KEY, PA.ACTIVITY_ITEM_TYPE, WAT.NUMBER_VALUE
     FROM WF_PROCESS_ACTIVITIES PA,
	  WF_ITEMS I,
	  WF_ITEM_ACTIVITY_STATUSES IAS,
          WF_ITEM_ATTRIBUTE_VALUES WAT,
          WF_ACTIVITIES WA
    WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
      AND IAS.ITEM_KEY = I.ITEM_KEY
      AND IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
      AND IAS.ITEM_TYPE = p_item_type
      AND PA.PROCESS_ITEM_TYPE = p_item_type
      AND IAS.ACTIVITY_STATUS = l_error_status
      AND IAS.BEGIN_DATE BETWEEN nvl(p_activity_error_date_from, IAS.BEGIN_DATE)
                             AND nvl(p_activity_error_date_to, IAS.BEGIN_DATE)
      AND I.END_DATE IS NULL
      AND WAT.ITEM_TYPE = IAS.ITEM_TYPE
      AND WAT.ITEM_KEY = IAS.ITEM_KEY
      AND WAT.NAME = l_org_id
      AND WA.ITEM_TYPE = PA.ACTIVITY_ITEM_TYPE
      AND WA.NAME = PA.ACTIVITY_NAME
      AND WA.TYPE NOT IN ('PROCESS','FOLDER')
      AND I.BEGIN_DATE >= WA.BEGIN_DATE
      AND I.BEGIN_DATE < NVL(WA.END_DATE, I.BEGIN_DATE+1) --Modified for bug 6443885
      ORDER BY WAT.NUMBER_VALUE;

CURSOR l_retry_cursor_5 IS
   SELECT IAS.ITEM_KEY, PA.INSTANCE_LABEL, PA.ACTIVITY_NAME, PA.PROCESS_NAME, IAS.PROCESS_ACTIVITY, I.USER_KEY, I.PARENT_ITEM_TYPE, I.PARENT_ITEM_KEY, PA.ACTIVITY_ITEM_TYPE, WAT.NUMBER_VALUE
     FROM WF_PROCESS_ACTIVITIES PA,
	  WF_ITEMS I,
	  WF_ITEM_ACTIVITY_STATUSES IAS,
          WF_ITEM_ATTRIBUTE_VALUES WAT,
          WF_ACTIVITIES WA
    WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
      AND IAS.ITEM_KEY = I.ITEM_KEY
      AND IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
      AND IAS.ITEM_TYPE = p_item_type
      AND PA.PROCESS_ITEM_TYPE = p_item_type
      AND PA.ACTIVITY_NAME = p_activity_name
      AND IAS.ACTIVITY_STATUS = l_error_status
      AND IAS.BEGIN_DATE BETWEEN nvl(p_activity_error_date_from, IAS.BEGIN_DATE)
                             AND nvl(p_activity_error_date_to, IAS.BEGIN_DATE)
      AND I.END_DATE IS NULL
      AND WAT.ITEM_TYPE = I.PARENT_ITEM_TYPE
      AND WAT.ITEM_KEY = I.PARENT_ITEM_KEY
      AND WAT.NAME = l_org_id
      AND WA.ITEM_TYPE = PA.ACTIVITY_ITEM_TYPE
      AND WA.NAME = PA.ACTIVITY_NAME
      AND WA.TYPE NOT IN ('PROCESS','FOLDER')
      AND I.BEGIN_DATE >= WA.BEGIN_DATE
      AND I.BEGIN_DATE < NVL(WA.END_DATE, I.BEGIN_DATE+1) --Modified for bug 6443885
      ORDER BY WAT.NUMBER_VALUE;

CURSOR l_retry_cursor_6 IS
   SELECT IAS.ITEM_KEY, PA.INSTANCE_LABEL, PA.ACTIVITY_NAME, PA.PROCESS_NAME, IAS.PROCESS_ACTIVITY, I.USER_KEY, I.PARENT_ITEM_TYPE, I.PARENT_ITEM_KEY, PA.ACTIVITY_ITEM_TYPE, WAT.NUMBER_VALUE
     FROM WF_PROCESS_ACTIVITIES PA,
	  WF_ITEMS I,
	  WF_ITEM_ACTIVITY_STATUSES IAS,
          WF_ITEM_ATTRIBUTE_VALUES WAT,
          WF_ACTIVITIES WA
    WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
      AND IAS.ITEM_KEY = I.ITEM_KEY
      AND IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
      AND IAS.ITEM_TYPE = p_item_type
      AND PA.PROCESS_ITEM_TYPE = p_item_type
      AND IAS.ACTIVITY_STATUS = l_error_status
      AND IAS.BEGIN_DATE BETWEEN nvl(p_activity_error_date_from, IAS.BEGIN_DATE)
                             AND nvl(p_activity_error_date_to, IAS.BEGIN_DATE)
      AND I.END_DATE IS NULL
      AND WAT.ITEM_TYPE = I.PARENT_ITEM_TYPE
      AND WAT.ITEM_KEY = I.PARENT_ITEM_KEY
      AND WAT.NAME = l_org_id
      AND WA.ITEM_TYPE = PA.ACTIVITY_ITEM_TYPE
      AND WA.NAME = PA.ACTIVITY_NAME
      AND WA.TYPE NOT IN ('PROCESS','FOLDER')
      AND I.BEGIN_DATE >= WA.BEGIN_DATE
      AND I.BEGIN_DATE < NVL(WA.END_DATE, I.BEGIN_DATE+1) --Modified for bug 6443885
      ORDER BY WAT.NUMBER_VALUE;

l_retry_rec Retry_Rec_Type;

BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering Retry_Flows');
   END IF;
   G_BATCH_RETRY_FLAG := 'Y';
   l_commit_count := 0;

   IF p_item_key IS NOT NULL THEN
      IF p_item_type = 'OEOL' THEN
         OPEN l_retry_cursor_1;
      ELSIF p_item_type = 'OEOH' THEN
         OPEN l_retry_cursor_2;
      END IF;
   ELSIF p_item_type = 'OMERROR' THEN
      IF p_activity_name IS NOT NULL THEN
         OPEN l_retry_cursor_5;
      ELSE
         OPEN l_retry_cursor_6;
      END IF;
   ELSIF p_activity_name IS NOT NULL THEN
      OPEN l_retry_cursor_3;
   ELSE
      OPEN l_retry_cursor_4;
   END IF;

   ----------------------------------------------------------------------------
   -- Fetch and process errored work items
   ----------------------------------------------------------------------------

   LOOP
      IF l_retry_cursor_1%ISOPEN THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add ('fetching from cursor 1');
         END IF;
         FETCH l_retry_cursor_1 BULK COLLECT INTO
            l_retry_rec.item_key,
	    l_retry_rec.activity_label,
	    l_retry_rec.activity_name,
	    l_retry_rec.process_name,
	    l_retry_rec.activity_id,
            l_retry_rec.user_key,
            l_retry_rec.parent_item_type,
            l_retry_rec.parent_item_key,
            l_retry_rec.activity_item_type,
            l_retry_rec.org_id
            LIMIT 1000;

      ELSIF l_retry_cursor_2%ISOPEN THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add ('fetching from cursor 2');
         END IF;
         FETCH l_retry_cursor_2 BULK COLLECT INTO
            l_retry_rec.item_key,
	    l_retry_rec.activity_label,
	    l_retry_rec.activity_name,
	    l_retry_rec.process_name,
	    l_retry_rec.activity_id,
            l_retry_rec.user_key,
            l_retry_rec.parent_item_type,
            l_retry_rec.parent_item_key,
            l_retry_rec.activity_item_type,
            l_retry_rec.org_id
            LIMIT 1000;

      ELSIF l_retry_cursor_3%ISOPEN THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add ('fetching from cursor 3');
         END IF;
         FETCH l_retry_cursor_3 BULK COLLECT INTO
            l_retry_rec.item_key,
	    l_retry_rec.activity_label,
	    l_retry_rec.activity_name,
	    l_retry_rec.process_name,
	    l_retry_rec.activity_id,
            l_retry_rec.user_key,
            l_retry_rec.parent_item_type,
            l_retry_rec.parent_item_key,
            l_retry_rec.activity_item_type,
            l_retry_rec.org_id
            LIMIT 1000;

      ELSIF l_retry_cursor_4%ISOPEN THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add ('fetching from cursor 4');
         END IF;
         FETCH l_retry_cursor_4 BULK COLLECT INTO
            l_retry_rec.item_key,
	    l_retry_rec.activity_label,
	    l_retry_rec.activity_name,
	    l_retry_rec.process_name,
	    l_retry_rec.activity_id,
            l_retry_rec.user_key,
            l_retry_rec.parent_item_type,
            l_retry_rec.parent_item_key,
            l_retry_rec.activity_item_type,
            l_retry_rec.org_id
            LIMIT 1000;

      ELSIF l_retry_cursor_5%ISOPEN THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add ('fetching from cursor 5');
         END IF;
         FETCH l_retry_cursor_5 BULK COLLECT INTO
            l_retry_rec.item_key,
	    l_retry_rec.activity_label,
	    l_retry_rec.activity_name,
	    l_retry_rec.process_name,
	    l_retry_rec.activity_id,
            l_retry_rec.user_key,
            l_retry_rec.parent_item_type,
            l_retry_rec.parent_item_key,
            l_retry_rec.activity_item_type,
            l_retry_rec.org_id
            LIMIT 1000;

       ELSIF l_retry_cursor_6%ISOPEN THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add ('fetching from cursor 6');
         END IF;
         FETCH l_retry_cursor_6 BULK COLLECT INTO
            l_retry_rec.item_key,
	    l_retry_rec.activity_label,
	    l_retry_rec.activity_name,
	    l_retry_rec.process_name,
	    l_retry_rec.activity_id,
            l_retry_rec.user_key,
            l_retry_rec.parent_item_type,
            l_retry_rec.parent_item_key,
            l_retry_rec.activity_item_type,
            l_retry_rec.org_id
            LIMIT 1000;

     END IF;

      l_retry_count := l_retry_rec.item_key.count;
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Number of records in this fetch: '|| l_retry_count);
      END IF;

      FOR i IN 1..l_retry_count LOOP
         BEGIN
            SAVEPOINT RETRY_FLOW_SAVEPOINT;
            IF l_debug_level > 0 THEN
               oe_debug_pub.add(' ');
	       oe_debug_pub.add('Set savepoint for ' ||l_retry_rec.item_key(i));
	    END IF;

            ----------------------------------------------------------------------------
            -- Print User Key Info
            ----------------------------------------------------------------------------
            Put (p_item_type || l_retry_rec.activity_name(i),l_retry_rec.activity_item_type(i), l_retry_rec.activity_name(i),p_item_type,1, 0, l_activity_display_name);

            FND_FILE.PUT_LINE(FND_FILE.LOG, '');
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_retry_rec.user_key(i));
            FND_MESSAGE.SET_NAME ('ONT', 'ONT_WF_ITEM_INFO');
            FND_MESSAGE.SET_TOKEN ('ITEM_TYPE', p_item_type_display_name);
            FND_MESSAGE.SET_TOKEN ('ITEM_KEY', l_retry_rec.item_key(i));
            FND_MESSAGE.SET_TOKEN ('ACTIVITY_NAME', l_activity_display_name);
            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

            ----------------------------------------------------------------------------
            -- Initialize
            ----------------------------------------------------------------------------
            l_ignore_error_check := FALSE;
            l_header_id := NULL;
            l_order_source_id := NULL;
            l_orig_sys_document_ref := NULL;

            IF p_item_type = 'OEOL' THEN
	       -- fetch header id to make sure index is used
	       SELECT header_id
		 INTO l_header_id
		 FROM OE_Order_Lines_All
		WHERE line_id = to_number(l_retry_rec.item_key(i));

	       IF l_debug_level > 0 THEN
		  oe_debug_pub.add('Fetched header id ' || l_header_id);
	       END IF;
            END IF;

            IF p_mode = 'EXECUTE' THEN
		----------------------------------------------------------------------------
		-- Call Selector function
		----------------------------------------------------------------------------

		p_x_result := NULL;

                -- only call the selector function if org_id changes
                IF nvl(l_retry_rec.org_id(i),-99) <> nvl(l_last_org_id, -99) OR l_retry_rec.org_id(i) IS NULL THEN
		    IF p_item_type = 'OMERROR' THEN
		       Call_OM_Selector(p_item_type => l_retry_rec.parent_item_type(i),
					p_item_key => l_retry_rec.parent_item_key(i),
					p_activity_id => NULL, -- this should be ok as we do not have activity
					      -- specific logic in the selector functions
					p_mode => 'TEST_CTX',
					p_x_result => p_x_result);
                       IF p_x_result = 'FALSE' THEN
			   -- call the parent selector function
			   Call_OM_Selector(p_item_type => l_retry_rec.parent_item_type(i),
					    p_item_key => l_retry_rec.parent_item_key(i),
					    p_activity_id => NULL, -- this should be ok as we do not have activity
						  -- specific logic in the selector functions
					    p_mode => 'SET_CTX',
					    p_x_result => p_x_result);
                       END IF;

		    ELSE

		       Call_OM_Selector(p_item_type => p_item_type,
					p_item_key => l_retry_rec.item_key(i),
					p_activity_id => NULL, -- this should be ok as we do not have activity
					      -- specific logic in the selector functions
					p_mode => 'TEST_CTX',
					p_x_result => p_x_result);

                       IF p_x_result = 'FALSE' THEN
			   Call_OM_Selector(p_item_type => p_item_type,
					    p_item_key => l_retry_rec.item_key(i),
					    p_activity_id => NULL, -- this should be ok as we do not have activity
						  -- specific logic in the selector functions
					    p_mode => 'SET_CTX',
					    p_x_result => p_x_result);
                       END IF;
		    END IF;
                    l_last_org_id := l_retry_rec.org_id(i);
                    IF l_debug_level > 0 THEN
                       oe_debug_pub.add('Reset last org id to: ' || l_retry_rec.org_id(i));
                    END IF;
                ELSE
                    IF l_debug_level > 0 THEN
                       oe_debug_pub.add('Org context unchanged, not calling selector function for org id: ' || l_retry_rec.org_id(i));
                    END IF;
                END IF;

		IF Activity_In_Error ( p_item_type => p_item_type,
					     p_item_key => l_retry_rec.item_key(i),
					     p_activity_id => l_retry_rec.activity_id(i)) THEN
		   IF l_debug_level > 0 THEN
		       oe_debug_pub.add('Activity still in error');
		   END IF;
		   IF NOT (p_item_type = 'OEOL' AND l_retry_rec.activity_name(i) = 'SHIP_LINE'
		      AND Check_Closed_Delivery_Detail (l_retry_rec.item_key(i), l_retry_rec.activity_id(i))) THEN
                       IF get_lock(p_item_type,l_retry_rec.item_key(i)) THEN
                        l_get_lock_failed := false;
			IF l_debug_level > 0 THEN
			    SELECT hsecs INTO l_start_total_time from v$timer;
			    oe_debug_pub.add('Calling Handleerror with item key '||l_retry_rec.item_key(i) ||
					     ' and activity ' ||  l_retry_rec.process_name(i)||':'||l_retry_rec.activity_label(i));
			END IF;
		----------------------------------------------------------------------------
		-- Close Open Messages
		----------------------------------------------------------------------------

			   close_messages (p_item_type => p_item_type,
			                   p_item_key => l_retry_rec.item_key(i),
			                   p_activity_id => l_retry_rec.activity_id(i),
			                   p_header_id => l_header_id,
			                   p_user_key => l_retry_rec.user_key(i),
			                   x_order_source_id => l_order_source_id,
			                   x_orig_sys_document_ref => l_orig_sys_document_ref);

		----------------------------------------------------------------------------
		-- Purge Error Flows
		----------------------------------------------------------------------------

			Purge_Error_Flow (p_item_type, l_retry_rec.item_key(i));

		----------------------------------------------------------------------------
		-- Ready to retry the activity
		----------------------------------------------------------------------------

			WF_ENGINE.HandleError(p_item_type,
					 l_retry_rec.item_key(i),
					 l_retry_rec.process_name(i)||':'||l_retry_rec.activity_label(i),
					  'RETRY',
					   NULL);
                       ELSE
                           l_get_lock_failed := true;
                       END IF; --IF get_lock(p_item_type,l_retry_rec.item_key(i))

		   END IF;
		   l_commit_count := l_commit_count + 1;
		   IF l_debug_level > 0 THEN
		       SELECT hsecs INTO l_end_total_time from v$timer;
		       oe_debug_pub.add('Total time taken to retry above item is (sec) '
                     ||((l_end_total_time-l_start_total_time)/100));
		       oe_debug_pub.add('Commit count '|| l_commit_count);
		   END IF;
		   IF l_commit_count > 500 THEN
		      IF l_debug_level > 0 THEN
			 oe_debug_pub.add('Committed '|| l_commit_count || ' records');
		      END IF;
		      COMMIT;
		      l_commit_count := 0;
		   END IF;
		ELSE
		   IF l_debug_level > 0 THEN
		      oe_debug_pub.add('Activity no longer in error, no retry');
		   END IF;
		   l_ignore_error_check := TRUE; -- this enables us to avoid an extra SQL
		END IF;
            END IF; -- end EXECUTE mode

	    IF (NOT l_ignore_error_check) AND Activity_In_Error ( p_item_type => p_item_type,
					 p_item_key => l_retry_rec.item_key(i),
					 p_activity_id => l_retry_rec.activity_id(i)) THEN
	       IF l_debug_level > 0 THEN
		   oe_debug_pub.add('Activity still in error, log as failure');
	       END IF;
               Put (p_item_type || l_retry_rec.activity_name(i),l_retry_rec.activity_item_type(i), l_retry_rec.activity_name(i),p_item_type,0, 1, l_activity_display_name);
               IF p_mode = 'EXECUTE' THEN
                  IF l_get_lock_failed THEN
                     FND_FILE.PUT_LINE(FND_FILE.LOG, 'The above activity is not retried because header and line records can not be locked for update. Please try later');
                  ELSE
                     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Retry of ' || l_activity_display_name || ' failed');
                  END IF;--IF l_get_lock_failed
               END IF;

               Print_Open_Messages ( p_item_type => p_item_type,
			             p_item_key => l_retry_rec.item_key(i),
			             p_activity_id => l_retry_rec.activity_id(i),
                                     p_header_id => l_header_id,
                                     p_order_source_id => l_order_source_id,
                                     p_orig_sys_document_ref => l_orig_sys_document_ref);
	    ELSE
	       IF l_debug_level > 0 THEN
		   oe_debug_pub.add('Activity no longer in error, log as success');
	       END IF;
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Retry of ' || l_activity_display_name || ' succeeded');

	    END IF;

         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK TO RETRY_FLOW_SAVEPOINT;
               l_error_msg := substr(SQLERRM, 1, 512);
               IF l_debug_level > 0 THEN
                  oe_debug_pub.add ('Error during retry, log as failure and continue with next record ' || l_error_msg);
               END IF;
               Put (p_item_type || l_retry_rec.activity_name(i),l_retry_rec.activity_item_type(i), l_retry_rec.activity_name(i),p_item_type,0, 1, l_activity_display_name);
               FND_FILE.PUT_LINE(FND_FILE.LOG, 'Retry of ' || l_activity_display_name || ' failed with unexpected error ' || l_error_msg);
         END;
      END LOOP;

      IF l_retry_cursor_1%ISOPEN THEN
         EXIT WHEN l_retry_cursor_1%NOTFOUND;
      ELSIF  l_retry_cursor_2%ISOPEN THEN
         EXIT WHEN l_retry_cursor_2%NOTFOUND;
      ELSIF  l_retry_cursor_3%ISOPEN THEN
         EXIT WHEN l_retry_cursor_3%NOTFOUND;
      ELSIF  l_retry_cursor_4%ISOPEN THEN
         EXIT WHEN l_retry_cursor_4%NOTFOUND;
      ELSIF  l_retry_cursor_5%ISOPEN THEN
         EXIT WHEN l_retry_cursor_5%NOTFOUND;
      ELSIF  l_retry_cursor_6%ISOPEN THEN
         EXIT WHEN l_retry_cursor_6%NOTFOUND;
      END IF;

   END LOOP;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF l_retry_cursor_1%ISOPEN THEN
      CLOSE l_retry_cursor_1;
   ELSIF  l_retry_cursor_2%ISOPEN THEN
      CLOSE l_retry_cursor_2;
   ELSIF  l_retry_cursor_3%ISOPEN THEN
      CLOSE l_retry_cursor_3;
   ELSIF  l_retry_cursor_4%ISOPEN THEN
      CLOSE l_retry_cursor_4;
   ELSIF  l_retry_cursor_5%ISOPEN THEN
      CLOSE l_retry_cursor_5;
   ELSIF  l_retry_cursor_6%ISOPEN THEN
      CLOSE l_retry_cursor_6;
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Exiting Retry_Flows');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Entering Retry_Flows with unexpected error '|| SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_retry_cursor_1%ISOPEN THEN
         CLOSE l_retry_cursor_1;
      ELSIF  l_retry_cursor_2%ISOPEN THEN
         CLOSE l_retry_cursor_2;
      ELSIF  l_retry_cursor_3%ISOPEN THEN
         CLOSE l_retry_cursor_3;
      ELSIF  l_retry_cursor_4%ISOPEN THEN
         CLOSE l_retry_cursor_4;
      ELSIF  l_retry_cursor_5%ISOPEN THEN
         CLOSE l_retry_cursor_5;
      ELSIF  l_retry_cursor_6%ISOPEN THEN
         CLOSE l_retry_cursor_6;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Retry_Flows;

PROCEDURE Print_Results (p_mode IN VARCHAR2, p_item_type_display_name IN VARCHAR2,  p_item_type_display_name2 IN VARCHAR2)
IS
  l_count_tbl Count_Tbl_Type;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_total NUMBER;
  l_item_type_display_name VARCHAR2(80);
  i NUMBER;
BEGIN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Entering Print_Results');
  END IF;
  l_count_tbl := Count_Tbl;
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'SUMMARY');
  fnd_file.put_line(FND_FILE.OUTPUT, '');

  l_total := 0;

  IF p_mode = 'EXECUTE' THEN
     IF l_count_tbl.count > 0 THEN
        fnd_file.put_line (FND_FILE.OUTPUT, 'Activity Name                                    Item Type              Count');
     END IF;

     i := l_count_tbl.FIRST;
     WHILE i IS NOT NULL LOOP
        IF l_count_tbl(i).process_item_type = 'OEOL'  THEN
           l_item_type_display_name := p_item_type_display_name2;
        ELSE
           l_item_type_display_name := p_item_type_display_name;
        END IF;

        fnd_file.put_line(FND_FILE.OUTPUT, rpad(l_count_tbl(i).activity_display_name,48, ' ')  || ' ' || rpad(l_item_type_display_name,22, ' ')  || ' ' || l_count_tbl(i).initial_count);
        l_total := l_total + l_count_tbl(i).initial_count;
        i:= l_count_tbl.NEXT(i);
      END LOOP;
     fnd_file.put_line(FND_FILE.OUTPUT, '');
     fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Activities in Error prior to request: ' || l_total);
     fnd_file.put_line(FND_FILE.OUTPUT, '');
  END IF;

  l_total := 0;

  IF l_count_tbl.count > 0 THEN
     fnd_file.put_line (FND_FILE.OUTPUT, 'Activity Name                                    Item Type              Count');
  END IF;
  i := l_count_tbl.FIRST;
  WHILE i IS NOT NULL LOOP
        IF l_count_tbl(i).process_item_type = 'OEOL'  THEN
           l_item_type_display_name := p_item_type_display_name2;
        ELSE
           l_item_type_display_name := p_item_type_display_name;
        END IF;

        fnd_file.put_line(FND_FILE.OUTPUT, rpad(l_count_tbl(i).activity_display_name,48, ' ')  || ' ' || rpad(l_item_type_display_name,22, ' ')  || ' ' || l_count_tbl(i).final_count);
     l_total := l_total + l_count_tbl(i).final_count;
     i:= l_count_tbl.NEXT(i);
  END LOOP;

  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Activities in Error after completion of request: ' || l_total);

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exiting Print_Results');
  END IF;

END Print_Results;

PROCEDURE EM_Batch_Retry_Conc_Pgm (
	   errbuf                               OUT NOCOPY VARCHAR,
	   retcode                              OUT NOCOPY NUMBER,
	   p_item_key                           IN  VARCHAR2,
           p_dummy1                             IN  VARCHAR2, -- this param is not used
	   p_item_type			        IN  VARCHAR2,
	   p_activity_name		       	IN  VARCHAR2,
	   p_activity_error_date_from           IN  VARCHAR2,
	   p_activity_error_date_to             IN  VARCHAR2,
           p_mode                               IN  VARCHAR2)
IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_return_status VARCHAR2(1);
  l_activity_error_date_from DATE;
  l_activity_error_date_to DATE;
  l_item_type_display_name VARCHAR2(80);
  l_item_type_display_name2 VARCHAR2(80);
   l_user_mode VARCHAR2(80);
  l_order_num NUMBER;
  l_act_display_name VARCHAR2(80);

BEGIN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Entering EM_Batch_Retry_Conc_Pgm');
  END IF;
  retcode := 0;
  l_activity_error_date_from := fnd_date.canonical_to_date(p_activity_error_date_from);
  l_activity_error_date_to := fnd_date.canonical_to_date(p_activity_error_date_to) + 1 - 1/(24*60*60);
SELECT display_name
    INTO l_item_type_display_name
    FROM wf_item_types_vl
   WHERE name = p_item_type;

if p_item_key is not null then

SELECT order_number into l_order_num
  from oe_order_headers_all
 where header_id = p_item_key;

end if;

SELECT MEANING into l_user_mode
  FROM OE_LOOKUPS
 WHERE LOOKUP_CODE= p_mode
   AND LOOKUP_TYPE='ONT_RETRY_MODE'
   AND ENABLED_FLAG='Y'
   AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE) AND NVL(END_DATE_ACTIVE,SYSDATE);

IF p_activity_name is not null then
SELECT DISPLAY_NAME into l_act_display_name FROM wf_activities_vl
 WHERE ROW_ID  IN (SELECT MAX(ROWID) FROM WF_ACTIVITIES WA
                    WHERE WA.TYPE NOT IN ('PROCESS','FOLDER')
                      AND EXISTS (SELECT ACTIVITY_NAME FROM WF_PROCESS_ACTIVITIES WPA
                                  WHERE WA.NAME = WPA.ACTIVITY_NAME
                                    AND WPA.PROCESS_ITEM_TYPE = P_ITEM_TYPE
                                    AND WA.ITEM_TYPE=WPA.ACTIVITY_ITEM_TYPE)
                      AND WA.VERSION = (SELECT MAX(WA2.VERSION) FROM WF_ACTIVITIES WA2
                                         WHERE WA2.ITEM_TYPE = WA.ITEM_TYPE
                                           AND WA2.NAME=WA.NAME)
                 GROUP BY WA.NAME)
   AND NAME = p_activity_name;
end if;


  -----------------------------------------------------------
  -- Log Output file
  -----------------------------------------------------------

  fnd_file.put_line(FND_FILE.OUTPUT, 'Retry Activities in Error Concurrent Program');
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'PARAMETERS');
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Order Number: '||l_order_num);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Item Type: '||l_item_type_display_name);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Activity in Error: '|| l_act_display_name);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Activity Error Date From: '|| l_activity_error_date_from);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Activity Error Date To: '||l_activity_error_date_to);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Mode: '||l_user_mode);
  fnd_file.put_line(FND_FILE.OUTPUT, '');


  -----------------------------------------------------------
  -- Validate Parameters
  -----------------------------------------------------------
  IF p_mode IS NULL OR p_item_type IS NULL THEN
     retcode := 0;
     errbuf := 'Required parameters Item Type and Mode cannot be null';
     fnd_file.put_line(FND_FILE.OUTPUT, '');
     fnd_file.put_line(FND_FILE.OUTPUT, errbuf);
     fnd_file.put_line(FND_FILE.OUTPUT, 'Program exited with code : '||retcode);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Exiting with retcode '||retcode || ' and errbuf ' || errbuf ) ;
     END IF;
     RETURN;
  END IF;

  -----------------------------------------------------------
  -- Initialize
  -----------------------------------------------------------

  IF p_item_key IS NOT NULL OR p_item_type = 'OEOL' THEN
     SELECT display_name
       INTO l_item_type_display_name2
       FROM wf_item_types_vl
      WHERE name = OE_GLOBALS.G_WFI_LIN;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Item Type Display Name: ' || l_item_type_display_name);
     oe_debug_pub.add('Item Type Display Name2: ' || l_item_type_display_name2);
  END IF;

  -----------------------------------------------------------
  -- Retry
  -----------------------------------------------------------
  IF p_item_key IS NOT NULL THEN

     Retry_Flows (p_item_key => p_item_key,
                  p_item_type => 'OEOL',
                  p_item_type_display_name => l_item_type_display_name2,
                  p_mode => p_mode,
                  x_return_status => l_return_status);

     Retry_Flows (p_item_key => p_item_key,
                  p_item_type => 'OEOH',
                  p_item_type_display_name => l_item_type_display_name,
                  p_mode => p_mode,
                  x_return_status => l_return_status);

  ELSE

     Retry_Flows (p_item_type => p_item_type,
                  p_activity_name => p_activity_name,
                  p_activity_error_date_from => l_activity_error_date_from,
                  p_activity_error_date_to => l_activity_error_date_to,
                  p_item_type_display_name => l_item_type_display_name,
                  p_mode => p_mode,
                  x_return_status => l_return_status);

  END IF;
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     null; -- need to handle this case
  END IF;

  -----------------------------------------------------------
  -- Print Results
  -----------------------------------------------------------
  Print_Results (p_mode => p_mode,
                 p_item_type_display_name => l_item_type_display_name,
                 p_item_type_display_name2 => l_item_type_display_name2);

  G_BATCH_RETRY_FLAG := 'N';
  retcode := 0;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Program exited normally');
  END IF;
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Program exited with code : '||retcode);
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exiting EM_Batch_Retry_Conc_Pgm');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     retcode := 2;
     errbuf  := SQLERRM;
     G_BATCH_RETRY_FLAG := 'N';
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SQLERRM: '||SQLERRM||' SQLCODE:'||SQLCODE ) ;
     END IF;
     fnd_file.put_line(FND_FILE.OUTPUT, '');
     fnd_file.put_line(FND_FILE.OUTPUT, 'Program exited with code : '||retcode);
     fnd_file.put_line(FND_FILE.OUTPUT,  'SQLERRM: '||SQLERRM||' SQLCODE:'||SQLCODE );
     IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'EM_Batch_Retry_Conc_Pgm');
     End if;

END EM_Batch_Retry_Conc_Pgm;

end OE_ERROR_WF;

/
