--------------------------------------------------------
--  DDL for Package Body OKL_SSC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SSC_WF" as
/* $Header: OKLSSWFB.pls 120.21.12010000.6 2010/01/21 05:43:15 nikshah ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
    G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_SSC_WF';
    G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
    L_MODULE VARCHAR2(40) := 'LEASE.SETUP.FUNCTIONS';
    L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    L_LEVEL_PROCEDURE NUMBER;
    IS_DEBUG_PROCEDURE_ON BOOLEAN;

--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

     -- START: Sameer Added on 30-Sep-2002 to handle Raise Event call from Asset BC4Js
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - Start
  -- Modified signature to accept parameters of location change
  -- Set the paramaters required by the workflow and raise event
procedure raise_assets_update_event ( p_event_name   in varchar2 ,
                                      parent_line_id in varchar2,
                                      requestorId  in varchar2,
                                      new_site_id1 in varchar2,
                                      new_site_id2 in varchar2,
                                      old_site_id1 in varchar2,
                                      old_site_id2 in varchar2,
                                      trx_date     in date
                                      )
                                                   IS

x_return_status VARCHAR2(1);
l_api_version   NUMBER:=1.0;
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(4000);
l_parameter_list wf_parameter_list_t;

begin

-- pass the parameters to the event
wf_event.addparametertolist('SSCREQUESTORID'
                            ,requestorId
                            ,l_parameter_list);
wf_event.addparametertolist('ASSETID'
                            ,parent_line_id
                            ,l_parameter_list);

wf_event.addparametertolist('NEWSITEID1'
                            ,new_site_id1
                            ,l_parameter_list);

wf_event.addparametertolist('NEWSITEID2'
                            ,new_site_id2
                            ,l_parameter_list);
wf_event.addparametertolist('OLDSITE1'
                            ,old_site_id1
                            ,l_parameter_list);
wf_event.addparametertolist('OLDSITE2'
                            ,old_site_id2
                            ,l_parameter_list);
wf_event.addparametertolist('TRX_DATE'
                            ,fnd_date.date_to_canonical(trx_date)
                            ,l_parameter_list);


okl_wf_pvt.raise_event(p_api_version   =>            l_api_version
                      ,p_init_msg_list =>            'T'
                      ,x_return_status =>            x_return_status
                      ,x_msg_count     =>            x_msg_count
                      ,x_msg_data      =>            x_msg_data
                      ,p_event_name    =>            p_event_name
                      ,p_parameters    =>            l_parameter_list);

end  raise_assets_update_event;
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - End
  -- END: Sameer Added on 30-Sep-2002 to handle Raise Event call from Asset BC4Js

-- START: Zhendi added the following procedures

----------------------------------ASSET RETURN--------------------------------------------------------

procedure  getAssetReturnMessage  (itemtype in varchar2,
                                 itemkey in varchar2,
                                 actid in number,
                                 funcmode in varchar2,
                                 resultout out nocopy varchar2 )

IS

CURSOR user_info(p_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_id;


CURSOR approver_cur(respKey varchar2) IS
SELECT responsibility_id
FROM fnd_responsibility
WHERE responsibility_key = respKey
AND application_id = 540;





requestor_info_rec user_info%rowtype;


p_requestor_id NUMBER;
p_resp_key varchar2(30);

l_requestor_name varchar2(100);
l_approver_name  varchar2(100);
l_respString VARCHAR2(15) := 'FND_RESP540:';
l_approver_id varchar2(20);
l_doc_attr  varchar2(20) := 'SSCRTASTDOC';


BEGIN

if ( funcmode = 'RUN' ) then

p_requestor_id:=to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID'));

open user_info(p_requestor_id);
fetch user_info into requestor_info_rec;
l_requestor_name := requestor_info_rec.user_name;
close user_info;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTOR', l_requestor_name);


p_resp_key := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCAPPROVERRESPONSIBILITYKEY');

open approver_cur(p_resp_key);
fetch approver_cur into l_approver_id;
close approver_cur;
l_approver_name := l_respString||l_approver_id;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCAPPROVER', l_approver_name);



--get the global variables transaction id and transaction type


wf_engine.SetItemAttrText (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => l_doc_attr,
                                   avalue     => 'PLSQLCLOB:OKL_SSC_WF.getAssetReturnDocument/'||
                                                 itemtype ||':'||itemkey||':&#NID');



resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('OKL_SSC_WF', 'getAssetReturnMessage', itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;



end getAssetReturnMessage;


Procedure  getAssetReturnDocument
            (      document_id    in      varchar2,
                   display_type   in      varchar2,
                   --document       in out  varchar2,
                   document       in out nocopy  clob,
                   document_type  in out nocopy  varchar2
                 )

IS



CURSOR returned_assets(p_tas_id NUMBER, p_tal_type varchar2) IS
select asset_number from okl_txl_assets_b
where tas_id = p_tas_id
and tal_type = p_tal_type
;

first_index             number;
second_index              number;
third_index             number;

l_tas_id              number;
l_tal_type              varchar2(100);
l_itemtype              varchar2(100);
l_itemkey             varchar2(100);

l_document                        varchar2(32000);
NL                                VARCHAR2(1) := fnd_global.newline;


    BEGIN

    --the document_id is in the form of
    --'PLSQLCLOB:OKL_SSC_WF.getAssetReturnDocument/itemtyp:itemkey:#NID'
    --we need to get itemtype and itemkey

    first_index := instr(document_id, '/', 1, 1);  --index of the slash '/'
    second_index := instr(document_id, ':', 1,1);  --index of first colon ':'
    third_index := instr(document_id, ':', 1, 2);  --index of the second colon ':'

    l_itemtype := substr(document_id, first_index+1, second_index-first_index-1);
    l_itemkey := substr(document_id, second_index+1, third_index-second_index-1);

    l_tas_id := to_number(WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTASID'));
    l_tal_type := WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTALTYPE');


        IF (display_type = 'text/html') THEN

            --first generate the header
            l_document :=   '<BR>' || NL;
            l_document :=   l_document ||
                            '<table cellpadding="3" cellspacing="3" border="3" summary="">' || NL;
      l_document :=   l_document ||
                  '<tr<th>Asset Number</th></tr>' || NL;
            --loop through the record, and generate line by line


            FOR returned_assets_rec in returned_assets(l_tas_id, l_tal_type)
            LOOP
                    l_document :=   l_document ||
                  '<tr><td>' ||returned_assets_rec.asset_number || '</td></tr>' || NL;

            END LOOP;

      l_document :=   l_document || '</table>';
        END IF;-- end to 'text/html' display type

        --document := l_document;
        wf_notification.WriteToClob( document, l_document);


    EXCEPTION

  when others then
  WF_CORE.CONTEXT ('OKL_SSC_WF', 'getAssetReturnDocument', l_itemtype, l_itemkey);
  raise;

END getAssetReturnDocument;


---------------------------MASK CREDIT CARD------------------------------------------------------------
FUNCTION mask_cc
  ( cc_number IN varchar2)
  RETURN  varchar2 IS

   l_mask_string varchar2(4);
   masked_cc varchar2(20);
   l_result varchar2(20);
BEGIN
    l_mask_string := '*';
    select decode(fnd_profile.value('AR_MASK_BANK_ACCOUNT_NUMBERS'),'F',rpad(substr(cc_number,1,4),length(cc_number),l_mask_string),'L',lpad(substr(cc_number,length(cc_number)-3),length(cc_number),l_mask_string),'N','N')
    into l_result
    from dual;
    if l_result='N' then
      masked_cc := cc_number;
    else
      masked_cc := l_result;
    end if;
    RETURN masked_cc ;
END;
----------------------------UPDATE SERIAL NUMBERS------------------------------------------------------

procedure  getSerialNumMessage  (itemtype in varchar2,
                                 itemkey in varchar2,
                                 actid in number,
                                 funcmode in varchar2,
                                 resultout out nocopy varchar2 )

IS

CURSOR user_info(p_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_id;

CURSOR approver_cur(respKey varchar2) IS
SELECT responsibility_id
FROM fnd_responsibility
WHERE responsibility_key = respKey
AND application_id = 540;

requestor_info_rec user_info%rowtype;

p_requestor_id NUMBER;
p_resp_key varchar2(30);

l_requestor_name varchar2(100);
l_approver_name  varchar2(100);
l_respString VARCHAR2(15) := 'FND_RESP540:';
l_approver_id varchar2(20);

l_doc_attr  varchar2(20) := 'SSCUPASNDOC';


BEGIN

if ( funcmode = 'RUN' ) then

p_requestor_id:=to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID'));
open user_info(p_requestor_id);
fetch user_info into requestor_info_rec;
l_requestor_name := requestor_info_rec.user_name;
close user_info;



WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTOR', l_requestor_name);

p_resp_key := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCAPPROVERRESPONSIBILITYKEY');

open approver_cur(p_resp_key);
fetch approver_cur into l_approver_id;
close approver_cur;
l_approver_name := l_respString||l_approver_id;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCAPPROVER', l_approver_name);


wf_engine.SetItemAttrText (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => l_doc_attr,
                                   avalue     => 'PLSQLCLOB:OKL_SSC_WF.getSerialNumDocument/'||
                                                 itemtype ||':'||itemkey||':&#NID');

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'getSerialNumMessage', itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;



end getSerialNumMessage;


Procedure  getSerialNumDocument
            (      document_id    in      varchar2,
                   display_type   in      varchar2,
                   document       in out nocopy  clob,
                   document_type  in out nocopy  varchar2
                 )

IS



CURSOR serial_nums(p_tas_id NUMBER, p_tal_type varchar2) IS
SELECT
DISTINCT ASX.ASSET_NUMBER,
INX.SERIAL_NUMBER
FROM   OKL_TXL_ITM_INSTS INX, OKL_TXL_ASSETS_B ASX
WHERE  INX.TAS_ID  = p_tas_id
AND INX.TAL_TYPE = p_tal_type
AND ASX.KLE_ID = INX.DNZ_CLE_ID
;

first_index             number;
second_index              number;
third_index             number;

l_tas_id              number;
l_tal_type              varchar2(100);
l_itemtype              varchar2(100);
l_itemkey             varchar2(100);

l_document                        varchar2(32000);
NL                                VARCHAR2(1) := fnd_global.newline;

    BEGIN

    --the document_id is in the form of
    --'PLSQLCLOB:OKL_SSC_WF.getAssetReturnDocument/itemtyp:itemkey:#NID'
    --we need to get itemtype and itemkey

    first_index := instr(document_id, '/', 1, 1);  --index of the slash '/'
    second_index := instr(document_id, ':', 1,1);  --index of first colon ':'
    third_index := instr(document_id, ':', 1, 2);  --index of the second colon ':'

    l_itemtype := substr(document_id, first_index+1, second_index-first_index-1);
    l_itemkey := substr(document_id, second_index+1, third_index-second_index-1);

    l_tas_id := to_number(WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTASID'));
    l_tal_type := WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTALTYPE');


        IF (display_type = 'text/html') THEN

            --first generate the header
            l_document :=   '<BR>' || NL;
            l_document :=   l_document ||
                            '<table cellpadding="3" cellspacing="3" border="3" summary="">' || NL;
      l_document :=   l_document ||
                  '<tr><th>Asset Number</th><th>Serial Number</th></tr>' || NL;
            --loop through the record, and generate line by line


            FOR serial_nums_rec in serial_nums(l_tas_id, l_tal_type)
            LOOP
                    l_document  :=   l_document ||
                  '<tr><td>' ||serial_nums_rec.ASSET_NUMBER || '</td>';

              l_document :=   l_document ||
                  '<td>' ||serial_nums_rec.SERIAL_NUMBER || '</td></tr>' || NL;

            END LOOP;

      l_document :=   l_document || '</table>';
        END IF;-- end to 'text/html' display type

        wf_notification.WriteToClob( document, l_document);


  EXCEPTION

  when others then
  WF_CORE.CONTEXT ('OKL_SSC_WF', 'getSerialNumDocument', l_itemtype, l_itemkey);
  raise;

END getSerialNumDocument;




procedure update_serial_fnc (itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             funcmode in varchar2,
                             resultout out nocopy varchar2 ) is

x_return_status varchar2(1);
x_msg_count number;
l_msg_data varchar2(2000);
l_tas_id number;

l_admin   VARCHAR2(120)  := 'SYSADMIN';

error_updating_serial_numbers EXCEPTION;

begin


-- assign variable to attribute
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'WF_ADMINISTRATOR',l_admin);


if ( funcmode = 'RUN' ) then


l_tas_id :=  to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCTASID'));

update_serial_number(p_api_version    => 1.0,
                     p_init_msg_list     => OKC_API.G_FALSE,
                     p_tas_id           => l_tas_id,
                     x_return_status    => x_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => l_msg_data);

--check the update result
IF x_return_status <> 'S' THEN
        RAISE error_updating_serial_numbers;
ELSE
        resultout := 'COMPLETE';
        return;
END IF;


end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'update_serial_fnc:'||l_msg_data, itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;

end update_serial_fnc;




----------------------------UPDATE ASSET LOCATION------------------------------------------------------

procedure  getLocationMessage  (itemtype in varchar2,
                                 itemkey in varchar2,
                                 actid in number,
                                 funcmode in varchar2,
                                 resultout out nocopy varchar2 )

IS

CURSOR user_info(p_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_id;

CURSOR approver_cur(respKey varchar2) IS
SELECT responsibility_id
FROM fnd_responsibility
WHERE responsibility_key = respKey
AND application_id = 540;

requestor_info_rec user_info%rowtype;
approver_info_rec user_info%rowtype;

p_requestor_id NUMBER;
p_resp_key varchar2(30);

l_requestor_name varchar2(100);
l_approver_name  varchar2(100);
l_respString VARCHAR2(15) := 'FND_RESP540:';
l_approver_id varchar2(20);

l_doc_attr varchar2(20) := 'SSCUPASLDOC';

BEGIN

if ( funcmode = 'RUN' ) then

p_requestor_id:=to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID'));

open user_info(p_requestor_id);
fetch user_info into requestor_info_rec;
l_requestor_name := requestor_info_rec.user_name;
close user_info;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTOR', l_requestor_name);

p_resp_key := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCAPPROVERRESPONSIBILITYKEY');

open approver_cur(p_resp_key);
fetch approver_cur into l_approver_id;
close approver_cur;
l_approver_name := l_respString||l_approver_id;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCAPPROVER', l_approver_name);

wf_engine.SetItemAttrText (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => l_doc_attr,
                                   avalue     => 'PLSQLCLOB:OKL_SSC_WF.getLocationDocument/'||
                                                 itemtype ||':'||itemkey||':&#NID');

resultout := 'COMPLETE';

return;
end if;

if ( funcmode = 'CANCEL' ) then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('OKL_SSC_WF', 'getLocationMessage', itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;



end getLocationMessage;


Procedure  getLocationDocument
            (      document_id    in      varchar2,
                   display_type   in      varchar2,
                   document       in out nocopy  clob,
                   document_type  in out nocopy  varchar2
                 )

IS
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - Start
 -- Commented cursor
/*
CURSOR asset_locations(p_tas_id number, p_tal_type varchar2) IS
select
distinct
ASX.ASSET_NUMBER,
PSU1.DESCRIPTION        OLD_LOCATION,
PSU2.DESCRIPTION        NEW_LOCATION,
TRX.DATE_TRANS_OCCURRED EFFECTIVE_DATE
from OKL_TXL_ITM_INSTS INX,
OKX_PARTY_SITE_USES_V  PSU1,
OKX_PARTY_SITE_USES_V  PSU2,
OKL_TXL_ASSETS_B       ASX,
OKL_TRX_ASSETS         TRX
where
    INX.TAS_ID   = p_tas_id
AND INX.TAL_TYPE = p_tal_type
AND ASX.KLE_ID   = INX.DNZ_CLE_ID
AND PSU1.ID1 (+) = INX.OBJECT_ID1_OLD
AND PSU1.ID2 (+) = INX.OBJECT_ID2_OLD
AND PSU2.ID1     = INX.OBJECT_ID1_NEW
AND PSU2.ID2     = INX.OBJECT_ID2_NEW
AND TRX.ID       = INX.TAS_ID
;

*/
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - End
first_index             number;
second_index              number;
third_index             number;

l_tas_id              number;
l_tal_type              varchar2(100);
l_itemtype              varchar2(100);
l_itemkey             varchar2(100);

l_document                        varchar2(32000);
NL                                VARCHAR2(1) := fnd_global.newline;

 -- Bug#4274575 - smadhava - 28-Sep-2005 - Added - Start
l_old_location_id1  VARCHAR2(100);
l_new_location_id1  VARCHAR2(100);
l_old_location_id2  VARCHAR2(100);
l_new_location_id2  VARCHAR2(100);
l_trx_date          DATE;
l_asset_id          VARCHAR2(100);
l_asset_number      OKC_K_LINES_V.NAME%TYPE;
l_old_location      OKX_PARTY_SITE_USES_V.DESCRIPTION%TYPE;
l_new_location      OKX_PARTY_SITE_USES_V.DESCRIPTION%TYPE;

  CURSOR c_get_location(cp_id1 IN OKL_TXL_ITM_INSTS.OBJECT_ID1_NEW%TYPE,
                        cp_id2 IN OKL_TXL_ITM_INSTS.OBJECT_ID2_NEW%TYPE) IS
   SELECT PSU.DESCRIPTION
     FROM OKX_PARTY_SITE_USES_V PSU
    WHERE PSU.ID1 = cp_id1
      AND PSU.ID2 = cp_id2;

  CURSOR c_get_asset_dtls(cp_kle_id IN OKC_K_LINES_V.ID%TYPE) IS
  SELECT NAME
    FROM OKC_K_LINES_V
   WHERE ID = cp_kle_id;
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Added - End


 l_user_id NUMBER;  -- added for Bug 7538507
 l_trx_date_text VARCHAR2(60); -- added for Bug 7538507

 -- Added for Bug 7538507
 CURSOR get_user_id_csr IS
 SELECT user_id
 FROM   FND_USER
 WHERE  User_Name = FND_GLOBAL.user_name;

 	 disptype VARCHAR2(30); -- Bug 8974540

    BEGIN

    --the document_id is in the form of
    --'PLSQLCLOB:OKL_SSC_WF.getAssetReturnDocument/itemtyp:itemkey:#NID'
    --we need to get itemtype and itemkey

    first_index := instr(document_id, '/', 1, 1);  --index of the slash '/'
    second_index := instr(document_id, ':', 1,1);  --index of first colon ':'
    third_index := instr(document_id, ':', 1, 2);  --index of the second colon ':'

    l_itemtype := substr(document_id, first_index+1, second_index-first_index-1);
    l_itemkey := substr(document_id, second_index+1, third_index-second_index-1);

   -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - Start
    /*
    l_tas_id := to_number(WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTASID'));
    l_tal_type := WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTALTYPE');
    */

    -- have to fetch the location names for the Ids
    l_new_location_id1 := wf_engine.GetItemAttrText(l_itemtype, l_itemkey, 'NEWSITEID1');
    l_old_location_id1 := wf_engine.GetItemAttrText(l_itemtype, l_itemkey, 'OLDSITE1');
    l_new_location_id2 := wf_engine.GetItemAttrText(l_itemtype, l_itemkey, 'NEWSITEID2');
    l_old_location_id2 := wf_engine.GetItemAttrText(l_itemtype, l_itemkey, 'OLDSITE2');
    l_trx_date         := wf_engine.GetItemAttrDate(l_itemtype, l_itemkey, 'TRX_DATE');
    l_asset_id         := wf_engine.GetItemAttrText(l_itemtype, l_itemkey, 'ASSETID');

    OPEN c_get_location(l_old_location_id1,l_old_location_id2);
      FETCH c_get_location INTO l_old_location;
    CLOSE c_get_location;

    OPEN c_get_location(l_new_location_id1,l_new_location_id2);
      FETCH c_get_location INTO l_new_location;
    CLOSE c_get_location;

    OPEN c_get_asset_dtls(l_asset_id);
      FETCH c_get_asset_dtls INTO l_asset_number;
    CLOSE c_get_asset_dtls;

        IF (display_type = 'text/html') THEN


-- added for Bug 7538507 start
            IF (FND_RELEASE.MAJOR_VERSION = 12 AND FND_RELEASE.minor_version >= 1 AND FND_RELEASE.POINT_VERSION >= 1 )
                 OR (FND_RELEASE.MAJOR_VERSION > 12) THEN

              OPEN get_user_id_csr;
              FETCH get_user_id_csr INTO l_user_id;
              CLOSE get_user_id_csr;

              IF l_user_id IS NULL THEN
                 l_user_id := to_number(null);
              END IF;

              if (disptype=wf_notification.doc_html) then -- bug 8974540
                -- For html notification in Hijrah calendar, the MMM date format would be displayed correctly only when <BDO> tag is used.
                -- Use NVL for NLS_CALENDAR
                l_trx_date_text := '<BDO DIR="LTR">' ||
                                 to_char(l_trx_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''')
                                 || '</BDO>';

              else
                -- Use NVL for NLS_CALENDAR
                l_trx_date_text := to_char(l_trx_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''');

              end if;

            ELSE

              l_trx_date_text := to_char(l_trx_date);

            END IF;
-- added for Bug 7538507 End

            --first generate the header
            l_document :=   '<BR><BR>' || NL;
            l_document :=   l_document ||
                            '<table cellpadding="3" cellspacing="3" border="3" summary="">' || NL;
            l_document :=   l_document ||
                  '<tr><th>Asset Number</th><th>Current Asset Location</th><th>New Asset Location Requested</th><th>Effective Date</th></tr>' || NL;
            --loop through the record, and generate line by line


            /*FOR asset_locations_rec in asset_locations(l_tas_id, l_tal_type)
            LOOP*/
                    l_document :=   l_document ||
                  '<tr><td>' ||
                  l_asset_number ||
                   --asset_locations_rec.ASSET_NUMBER ||
                   '</td>';

                        l_document :=   l_document ||
                  '<td>' ||
                  l_old_location ||
                  --asset_locations_rec.OLD_LOCATION ||
                  '</td>' || NL;

                                        l_document :=   l_document ||
                  '<td>' ||
                  l_new_location ||
                  --asset_locations_rec.NEW_LOCATION ||
                  '</td>' || NL;

                        l_document :=   l_document ||
                  '<td>' ||
                  --asset_locations_rec.EFFECTIVE_DATE ||
                  l_trx_date_text ||
                  '</td></tr>' || NL;  -- modified for Bug 7538507


           -- END LOOP;
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - End

      l_document :=   l_document || '</table>';
        END IF;-- end to 'text/html' display type

        --document := l_document;
        wf_notification.WriteToClob( document, l_document);


  EXCEPTION

  when others then
  WF_CORE.CONTEXT ('okl_ssc_wf', 'getLocationDocument', l_itemtype, l_itemkey);
  raise;

END getLocationDocument;




procedure update_location_fnc (itemtype in varchar2,
                                    itemkey in varchar2,
                                    actid in number,
                                    funcmode in varchar2,
                                    resultout out nocopy varchar2 ) is

l_tas_id number;
x_return_status varchar2(1);
x_msg_count number;
l_msg_data varchar2(2000);

l_admin   VARCHAR2(120)  := 'SYSADMIN';

error_updating_asset_locations EXCEPTION;

 -- Bug#4274575 - smadhava - 28-Sep-2005 - Added - Start
l_new_location_id1 VARCHAR2(100);
l_new_location_id2 VARCHAR2(100);
l_old_location_id1 VARCHAR2(100);
l_old_location_id2 VARCHAR2(100);
l_trx_date         OKL_TRX_ASSETS.DATE_TRANS_OCCURRED%TYPE;
l_asset_id         OKC_K_LINES_V.ID%TYPE;
l_party_site_id    okx_party_site_uses_v.PARTY_SITE_ID%TYPE;
l_location_id      okx_party_site_uses_v.LOCATION_ID%TYPE;

l_loc_rec OKL_BLK_AST_UPD_PUB.blk_rec_type;
    l_trxv_rec        OKL_TRX_ASSETS_PUB.thpv_rec_type;
    x_trxv_rec        OKL_TRX_ASSETS_PUB.thpv_rec_type;

CURSOR okl_loc_csr (p_id1 IN OKL_TXL_ITM_INSTS.OBJECT_ID1_NEW%TYPE, p_id2 IN OKL_TXL_ITM_INSTS.OBJECT_ID2_NEW%TYPE) IS
    SELECT
           PARTY_SITE_ID,
           LOCATION_ID
    FROM   okx_party_site_uses_v
    WHERE  ID1  = p_id1 AND ID2  = p_id2;

 -- Bug#4274575 - smadhava - 28-Sep-2005 - Added - End

--For bug 8933908 by NIKSHAH : START
CURSOR c_get_org_id (p_kle_id IN OKC_K_LINES_B.CLE_ID%TYPE)
IS
select chr.org_id
from   okc_k_headers_all_b chr,
       okc_k_lines_b cle
where  chr.id = cle.dnz_chr_id
  and  cle.cle_id = p_kle_id
  and  rownum = 1;

l_org_id NUMBER;
l_orig_access_mode VARCHAR2(3);
l_orig_org_id NUMBER;
--For bug 8933908 by NIKSHAH : END

begin

  --For bug 8933908 by NIKSHAH : START
  l_orig_org_id :=  MO_GLOBAL.GET_CURRENT_ORG_ID;
  l_orig_access_mode := MO_GLOBAL.GET_ACCESS_MODE;
  --For bug 8933908 by NIKSHAH : END

-- assign variable to attribute
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'WF_ADMINISTRATOR',l_admin);


if ( funcmode = 'RUN' ) then
/*
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - Start
    l_new_location_id1 := wf_engine.GetItemAttrText(itemtype, itemkey, 'NEWSITEID1');
    l_new_location_id2 := wf_engine.GetItemAttrText(itemtype, itemkey, 'NEWSITEID2');
    l_old_location_id1 := wf_engine.GetItemAttrText(itemtype, itemkey, 'OLDSITE1');
    l_old_location_id2 := wf_engine.GetItemAttrText(itemtype, itemkey, 'OLDSITE2');
    l_trx_date         := wf_engine.GetItemAttrDate(itemtype, itemkey, 'TRX_DATE');
    l_asset_id         := wf_engine.GetItemAttrText(itemtype, itemkey, 'ASSETID');

    OPEN okl_loc_csr(l_new_location_id1, l_new_location_id2);
      FETCH okl_loc_csr INTO l_party_site_id, l_location_id;
    CLOSE okl_loc_csr;

    l_loc_rec.parent_line_id := l_asset_id;
    l_loc_rec.loc_id         := l_location_id;
    l_loc_rec.party_site_id  := l_party_site_id;
    l_loc_rec.newsite_id1    := l_new_location_id1;
    l_loc_rec.newsite_id2    := l_new_location_id2;
    l_loc_rec.oldsite_id1    := l_old_location_id1;
    l_loc_rec.oldsite_id2    := l_old_location_id2;
    l_loc_rec.date_from      := l_trx_date;

    OKL_BLK_AST_UPD_PUB.update_location(
               p_api_version    => 1.0,
               p_init_msg_list  => OKL_API.G_FALSE,
               p_loc_rec        => l_loc_rec,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => l_msg_data);

    l_tas_id :=  to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCTASID'));


    update_location(p_api_version   => 1.0,
                p_init_msg_list     => OKC_API.G_FALSE,
                     p_tas_id           => l_tas_id,
                     x_return_status    => x_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => l_msg_data);
*/
 -- Bug#4274575 - smadhava - 28-Sep-2005 - Modified - end
--check the update result
    --asawanka ebtax changes start

   l_asset_id         := wf_engine.GetItemAttrText(itemtype, itemkey, 'ASSETID');

      --For bug 8933908 by NIKSHAH : START
      IF l_orig_org_id IS NULL THEN
        OPEN c_get_org_id(l_asset_id);
        FETCH c_get_org_id INTO l_org_id;
        CLOSE c_get_org_id;
      END IF;
      IF l_org_id IS NOT NULL THEN
        MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);
      END IF;
      --For bug 8933908 by NIKSHAH : END



      OKL_BLK_AST_UPD_PVT.process_update_location(
         p_api_version                    => 1.0,
         p_init_msg_list                  => 'T',
         p_kle_id                         => l_asset_id,
         x_return_status                  => x_return_status,
         x_msg_count                      => x_msg_count,
         x_msg_data                       => l_msg_data);

      --For bug 8933908 by NIKSHAH
       MO_GLOBAL.SET_POLICY_CONTEXT(l_orig_access_mode,l_orig_org_id);

    IF x_return_status <> 'S' THEN
      RAISE error_updating_asset_locations;
    END IF;

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
  --For bug 8933908 by NIKSHAH
  MO_GLOBAL.SET_POLICY_CONTEXT(l_orig_access_mode,l_orig_org_id);

WF_CORE.CONTEXT ('OKL_SSC_WF', 'update_location_fnc:'||l_msg_data, itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
raise;


end update_location_fnc;
-- END: procedures added by Zhendi

---------------------Manu's Procedures-----------------------------------

PROCEDURE get_trx_rec
           (p_api_version                  IN  NUMBER,
            p_init_msg_list                IN  VARCHAR2,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            p_cle_id                       IN  NUMBER,
            p_transaction_type             IN  VARCHAR2,
            x_trx_rec                      OUT NOCOPY CSI_DATASTRUCTURES_PUB.transaction_rec) IS

     l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_TRX_REC';
     l_api_version           CONSTANT NUMBER    := 1.0;

  --Following cursor assumes that a transaction type called
  --'OKL LINE ACTIVATION' and 'OKL SPLIT ASSET' will be seeded in IB
     Cursor okl_trx_type_curs(p_transaction_type IN VARCHAR2)is
            select transaction_type_id
            from   CS_TRANSACTION_TYPES_V
            where  Name = p_transaction_type;
     l_trx_type_id NUMBER;
  begin
     open okl_trx_type_curs(p_transaction_type);
        Fetch okl_trx_type_curs
        into  l_trx_type_id;
        If okl_trx_type_curs%NotFound Then
           --OKL LINE ACTIVATION not seeded as a source transaction in IB
           Raise OKC_API.G_EXCEPTION_ERROR;
        End If;
     close okl_trx_type_curs;
     --Assign transaction Type id to seeded value in cs_lookups
     x_trx_rec.transaction_type_id := l_trx_type_id;
     --Assign Source Line Ref id to contract line id of IB instance line
     x_trx_rec.source_line_ref_id := p_cle_id;
     x_trx_rec.transaction_date := sysdate;
     x_trx_rec.source_transaction_date := sysdate;
    Exception
    When OKC_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
   );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END get_trx_rec;



 PROCEDURE update_serial_number(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2,
                            p_tas_id                         IN  NUMBER,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2)
  AS

    CURSOR okl_itiv_csr (p_tas_id     IN NUMBER) IS
    SELECT
           KLE_ID,
           SERIAL_NUMBER,
           instance_number_ib,
           INVENTORY_ITEM_ID
    FROM   OKL_TXL_ITM_INSTS
    WHERE  TAS_ID  = p_tas_id;

    CURSOR okl_inst_csr (p_kle_id     IN NUMBER) IS
    SELECT
           KIT.OBJECT1_ID1
    FROM   OKC_K_ITEMS KIT
    WHERE  KIT.CLE_ID = (SELECT KLB.ID FROM OKC_K_LINES_B KLB WHERE
                         KLB.ID = p_kle_id);

    l_tas_id                   NUMBER;
    l_kle_id                   NUMBER;
    l_object_version_number    NUMBER;

    SUBTYPE instance_rec             IS CSI_DATASTRUCTURES_PUB.instance_rec;
    SUBTYPE extend_attrib_values_tbl IS CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
    SUBTYPE party_tbl                IS CSI_DATASTRUCTURES_PUB.party_tbl;
    SUBTYPE account_tbl              IS CSI_DATASTRUCTURES_PUB.party_account_tbl;
    SUBTYPE pricing_attribs_tbl      IS CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
    SUBTYPE organization_units_tbl   IS CSI_DATASTRUCTURES_PUB.organization_units_tbl;
    SUBTYPE instance_asset_tbl       IS CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
    SUBTYPE transaction_rec          IS CSI_DATASTRUCTURES_PUB.transaction_rec;
    SUBTYPE id_tbl                   IS CSI_DATASTRUCTURES_PUB.id_tbl;

    l_instance_rec_type      instance_rec;
    l_ext_attrib_values_tbl  extend_attrib_values_tbl;
    l_party_tbl              party_tbl;
    l_account_tbl            account_tbl;
    l_pricing_attrib_tbl     pricing_attribs_tbl;
    l_org_assignments_tbl    organization_units_tbl;
    l_asset_assignment_tbl   instance_asset_tbl;
    l_txn_rec                transaction_rec;
    l_instance_id_lst        id_tbl;


  BEGIN

    If p_tas_id is not null  Then
      l_tas_id     := p_tas_id;
    ELSE
      l_tas_id     := -9999;
    END IF;

    FOR csr_1 in okl_itiv_csr(l_tas_id)
    loop

      l_kle_id                               := csr_1.KLE_ID;
      l_instance_rec_type.SERIAL_NUMBER      := csr_1.SERIAL_NUMBER;
    --  l_instance_rec_type.INSTANCE_NUMBER    := csr_1.instance_number_ib;
    --  l_instance_rec_type.INVENTORY_ITEM_ID  := csr_1.INVENTORY_ITEM_ID;
      FOR csr_2 in okl_inst_csr(l_kle_id)
      loop
        l_instance_rec_type.INSTANCE_ID  := csr_2.OBJECT1_ID1;
      end loop;
      select object_version_number into l_object_version_number from
      csi_item_instances
      where instance_id = l_instance_rec_type.INSTANCE_ID;

      l_instance_rec_type.object_version_number  := l_object_version_number;
      l_instance_rec_type.MFG_SERIAL_NUMBER_FLAG := 'N';

      get_trx_rec(p_api_version          => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_cle_id           => NULL,
                      p_transaction_type => 'New',
                      x_trx_rec          => l_txn_rec);

      l_txn_rec.transaction_id := FND_API.G_MISS_NUM;
      csi_item_instance_pub.update_item_instance(p_api_version           =>  p_api_version,
                                                 p_commit                =>  fnd_api.g_false,
                                                 p_init_msg_list         =>  p_init_msg_list,
                                                 p_validation_level      =>  fnd_api.g_valid_level_full,
                                                 p_instance_rec          =>  l_instance_rec_type,
                                                 p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                 p_party_tbl             =>  l_party_tbl,
                                                 p_account_tbl           =>  l_account_tbl,
                                                 p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                 p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                 p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                 p_txn_rec               =>  l_txn_rec,
                                                 x_instance_id_lst       =>  l_instance_id_lst,
                                                 x_return_status         =>  x_return_status,
                                                 x_msg_count             =>  x_msg_count,
                                                 x_msg_data              =>  x_msg_data);

      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
    end loop;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SSC_ASST_LOC_SERNUM_PUB','Update_Serial_Number');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END update_serial_number;

 PROCEDURE update_location(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2,
                            p_tas_id                         IN  NUMBER,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2)
  AS

    CURSOR okl_itiv_csr (p_tas_id     IN NUMBER) IS
    SELECT
           KLE_ID,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           instance_number_ib,
           INVENTORY_ITEM_ID
    FROM   OKL_TXL_ITM_INSTS
    WHERE  TAS_ID  = p_tas_id;

    CURSOR okl_loc_csr (p_id1 IN OKL_TXL_ITM_INSTS.OBJECT_ID1_NEW%TYPE, p_id2 IN OKL_TXL_ITM_INSTS.OBJECT_ID2_NEW%TYPE) IS
    SELECT
           PARTY_SITE_ID,
           LOCATION_ID
    FROM   okx_party_site_uses_v
    WHERE  ID1  = p_id1 AND ID2  = p_id2;

    CURSOR okl_inst_csr (p_kle_id     IN OKL_TXL_ITM_INSTS.KLE_ID%TYPE) IS
    SELECT
           KIT.OBJECT1_ID1
    FROM   OKC_K_ITEMS KIT
    WHERE  KIT.CLE_ID = (SELECT KLB.ID FROM OKC_K_LINES_B KLB WHERE
                         KLB.ID = p_kle_id);


    SUBTYPE instance_rec             IS CSI_DATASTRUCTURES_PUB.instance_rec;
    SUBTYPE extend_attrib_values_tbl IS CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
    SUBTYPE party_tbl                IS CSI_DATASTRUCTURES_PUB.party_tbl;
    SUBTYPE account_tbl              IS CSI_DATASTRUCTURES_PUB.party_account_tbl;
    SUBTYPE pricing_attribs_tbl      IS CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
    SUBTYPE organization_units_tbl   IS CSI_DATASTRUCTURES_PUB.organization_units_tbl;
    SUBTYPE instance_asset_tbl       IS CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
    SUBTYPE transaction_rec          IS CSI_DATASTRUCTURES_PUB.transaction_rec;
    SUBTYPE id_tbl                   IS CSI_DATASTRUCTURES_PUB.id_tbl;

    l_instance_rec_type      instance_rec;
    l_ext_attrib_values_tbl  extend_attrib_values_tbl;
    l_party_tbl              party_tbl;
    l_account_tbl            account_tbl;
    l_pricing_attrib_tbl     pricing_attribs_tbl;
    l_org_assignments_tbl    organization_units_tbl;
    l_asset_assignment_tbl   instance_asset_tbl;
    l_txn_rec                transaction_rec;
    l_instance_id_lst        id_tbl;


    l_tas_id                   OKL_TXL_ITM_INSTS.TAS_ID%TYPE;
    l_kle_id                   OKL_TXL_ITM_INSTS.KLE_ID%TYPE;
    l_id1_id                   OKL_TXL_ITM_INSTS.OBJECT_ID1_NEW%TYPE;
    l_id2_id                   OKL_TXL_ITM_INSTS.OBJECT_ID2_NEW%TYPE;
    l_object_version_number    OKL_TXL_ITM_INSTS.object_version_number%TYPE;
  BEGIN

    If p_tas_id is not null  Then
      l_tas_id     := p_tas_id;
    ELSE
      l_tas_id     := -9999;
    END IF;
    FOR csr_1 in okl_itiv_csr(l_tas_id)
    loop

      l_kle_id                               := csr_1.KLE_ID;
      l_id1_id                               := csr_1.OBJECT_ID1_NEW;
      l_id2_id                               := csr_1.OBJECT_ID2_NEW;

      FOR csr_2 in okl_inst_csr(l_kle_id)
      loop
        l_instance_rec_type.INSTANCE_ID  := TO_NUMBER(csr_2.OBJECT1_ID1);
      end loop;

     -- l_instance_rec_type.INSTANCE_NUMBER    := csr_1.instance_number_ib;

      FOR csr_3 in okl_loc_csr(l_id1_id, l_id2_id)
      loop
        l_instance_rec_type.LOCATION_ID                 := TO_NUMBER(csr_3.LOCATION_ID);
        l_instance_rec_type.INSTALL_LOCATION_ID         := TO_NUMBER(csr_3.PARTY_SITE_ID);
        l_instance_rec_type.INSTALL_LOCATION_TYPE_CODE  := 'HZ_PARTY_SITES';
      end loop;

      select object_version_number into l_object_version_number from
      csi_item_instances
      where instance_id = l_instance_rec_type.INSTANCE_ID;

      l_instance_rec_type.object_version_number  := l_object_version_number;

      get_trx_rec(p_api_version          => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_cle_id           => NULL,
                      p_transaction_type => 'New',
                      x_trx_rec          => l_txn_rec);

      l_txn_rec.transaction_id := FND_API.G_MISS_NUM;

      csi_item_instance_pub.update_item_instance(p_api_version           =>  p_api_version,
                                                 p_commit                =>  fnd_api.g_false,
                                                 p_init_msg_list         =>  p_init_msg_list,
                                                 p_validation_level      =>  fnd_api.g_valid_level_full,
                                                 p_instance_rec          =>  l_instance_rec_type,
                                                 p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                 p_party_tbl             =>  l_party_tbl,
                                                 p_account_tbl           =>  l_account_tbl,
                                                 p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                 p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                 p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                 p_txn_rec               =>  l_txn_rec,
                                                 x_instance_id_lst       =>  l_instance_id_lst,
                                                 x_return_status         =>  x_return_status,
                                                 x_msg_count             =>  x_msg_count,
                                                 x_msg_data              =>  x_msg_data);

      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

    end loop;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SSC_ASST_LOC_SERNUM_PUB','Update_Location');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END update_location;

  PROCEDURE get_assets_for_transaction(
     p_tas_id                       IN  NUMBER,
     x_talv_rec                     OUT NOCOPY OKL_TXL_ASSETS_PVT.tlvv_tbl_type)
     IS

    CURSOR okl_tax_csr (p_tas_id     IN NUMBER) IS
    SELECT
            ID,
            KLE_ID,
            DNZ_KHR_ID,
            ASSET_NUMBER,
            DESCRIPTION
     FROM   OKL_TXL_ASSETS_V
     WHERE  nvl(OKL_TXL_ASSETS_V.TAS_ID,-9999)     = p_tas_id;
     Type r_rec is record(     ID NUMBER,
            KLE_ID NUMBER,
            DNZ_KHR_ID NUMBER,
            ASSET_NUMBER VARCHAR2(30),
            DESCRIPTION VARCHAR2(1995));
    i                          NUMBER default 1;
    l_tas_id NUMBER;
   BEGIN
     If p_tas_id is not null  Then
       l_tas_id     := p_tas_id;
     ELSE
       l_tas_id     := -9999;
     END IF;
     FOR csr_1 in okl_tax_csr(l_tas_id)
     loop
              x_talv_rec(i).ID := csr_1.id;
              x_talv_rec(i).KLE_ID := csr_1.kle_id;
              x_talv_rec(i).DNZ_KHR_ID := csr_1.dnz_khr_id;
              x_talv_rec(i).ASSET_NUMBER := csr_1.asset_number;
              x_talv_rec(i).DESCRIPTION  := csr_1.description;
        i := i + 1;
     end loop;
   END get_assets_for_transaction;

-- END: Zhendi added the following procedures

--- Added by DKHANDEL

FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------------------------------
 -- Return 'Y' if there are some active subscription for the given event
 -- Otherwise it returns 'N'
 -----------------------------------------------------------------------
 IS
  CURSOR cu0 IS
   SELECT 'Y'
     FROM wf_event_subscriptions a,
          wf_events b
    WHERE a.event_filter_guid = b.guid
      AND a.status = 'ENABLED'
      AND b.name   = p_event_name
      AND rownum   = 1;
  l_yn  VARCHAR2(1);
 BEGIN
  OPEN cu0;
   FETCH cu0 INTO l_yn;
   IF cu0%NOTFOUND THEN
      l_yn := 'N';
   END IF;
  CLOSE cu0;
  RETURN l_yn;
 END;
-----------------------------------------------------------------------

procedure submit_third_party_ins_wrapper(
           provider_id in number   ,
           site_id in number ,
           policy_number in varchar2,
           policy_start_date in date,
           policy_end_date in date,
           coverage_amount in number ,
           deductible in number ,
           lessor_insured in varchar2 ,
           lessor_payee in varchar2 ,
           contract_id in number,
           requestor_id in number,
           provider_name in varchar2,
           address1 in varchar2,
           address2 in varchar2 ,
           address3 in varchar2 ,
           address4 in varchar2 ,
           city in varchar2,
           state in varchar2,
           province in varchar2 ,
           county in varchar2 ,
           zip in varchar2,
           country in varchar2,
           telephone in varchar2,
           email in varchar2) IS

l_params wf_parameter_list_t;
l_event_key NUMBER;

CURSOR event_number IS
SELECT OKLSSC_WFITEMKEY_S.nextval from dual;


begin

 open event_number;
 fetch event_number into l_event_key;
 close event_number;


 WF_EVENT.AddParameterToList('SSCKID',to_char(contract_id),l_params);
 WF_EVENT.AddParameterToList('SSCINSPROVIDERID',to_char(provider_id),l_params);
 WF_EVENT.AddParameterToList('SSCSITEID',to_char(site_id),l_params);
 WF_EVENT.AddParameterToList('SSCPOLICYNUMBER',policy_number,l_params);
 WF_EVENT.AddParameterToList('SSCSTARTDATE',to_char(policy_start_date),l_params);
 WF_EVENT.AddParameterToList('SSCENDDATE',to_char(policy_end_date),l_params);
 WF_EVENT.AddParameterToList('SSCCOVERAGEAMOUNT',to_char(coverage_amount),l_params);
 WF_EVENT.AddParameterToList('SSCDEDUCTIBLE',to_char(deductible),l_params);
 WF_EVENT.AddParameterToList('SSCLESSORINSURED',lessor_insured,l_params);
 WF_EVENT.AddParameterToList('SSCLESSORPAYEE',lessor_payee,l_params);
 WF_EVENT.AddParameterToList('REQUESTOR',to_char(requestor_id),l_params);

 if (provider_id IS NOT null) then --existing provider workflow

 WF_EVENT.raise('oracle.apps.okl.ssc.submitthirdpartyinsurance',
    l_event_key,
    null,
    l_params);
 else

 WF_EVENT.AddParameterToList('SSCNEWPROVIDERNAME',provider_name,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERADDRESS1',address1,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERADDRESS2',address2,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERADDRESS3',address3,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERADDRESS4',address4,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERCITY',city,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERSTATECODE',state,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERCOUNTRY',country,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERCOUNTY',county,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERPROVINCE',province,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERZIPCODE',zip,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDERPHONENUMBER',telephone,l_params);
 WF_EVENT.AddParameterToList('SSCPROVIDEREMAILADDRESS',email,l_params);

 WF_EVENT.raise('oracle.apps.okl.ssc.createandsubmitthirdpartyinsurance',
    l_event_key,
    null,
    l_params);


 end if;
end submit_third_party_ins_wrapper;

procedure set_ins_provider_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 ) is

CURSOR provider_info(provider_name VARCHAR2) IS
SELECT party_id from hz_parties
WHERE party_number = provider_name;

CURSOR site_id_cur(p_party_id NUMBER) IS
SELECT site_id from OKL_INS_PARTYSITES_V
WHERE party_id = p_party_id;

l_provider_name VARCHAR2(120);
l_provider_id NUMBER;
l_site_id NUMBER;

begin

if ( funcmode = 'RUN' ) then

--Read attributes from WorkFlow
l_provider_name:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCNEWINSURANCEPROVIDERNUMBER');

open provider_info(l_provider_name);
fetch provider_info into l_provider_id;
close provider_info;



WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCINSPROVIDERID',to_char(l_provider_id));

open site_id_cur(l_provider_id);
fetch site_id_cur into l_site_id;
close site_id_cur;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCSITEID',to_char(l_site_id));

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'set_ins_provider_wf', itemtype, itemkey,actid,funcmode);
raise;
end set_ins_provider_wf;


procedure submit_ins_set_notif_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 ) is

l_respString VARCHAR2(15);
l_respId NUMBER;
l_resp_key VARCHAR2(30);


begin
l_respString:='FND_RESP540:';
l_resp_key :=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCRESPONSIBILITYKEYFORNEWPROV');

if ( funcmode = 'RUN' ) then



SELECT responsibility_id
INTO l_respId
FROM fnd_responsibility
WHERE responsibility_key = l_resp_key
AND application_id = 540;

wf_engine.SetItemAttrText (itemtype   => itemtype,
                            itemkey    => itemkey,
                            aname      => 'SSC_NTFRECIPIENT_ITMATTR2',
                            avalue     => l_respString || l_respId);



resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'submit_ins_set_notif_wf',itemtype, itemkey,actid,funcmode);
raise;
end submit_ins_set_notif_wf;



procedure submit_insurance_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 ) is
l_providerid NUMBER;
l_knum VARCHAR2(120);
l_policynum VARCHAR2(120);
l_start_date DATE;
l_end_date DATE;
l_coverage_amount NUMBER;
l_deductible NUMBER;
l_lessor_insured VARCHAR2(1);
l_lessor_payee VARCHAR2(1);
l_chrid NUMBER;
l_siteid NUMBER;
l_requestor_userid NUMBER;
l_policy_rec okl_insurance_policies_pub.ipyv_rec_type;
lx_return_status VARCHAR2(1);
lx_msg_count NUMBER;
lx_msg_data VARCHAR2(100);
lx_policy_rec okl_insurance_policies_pub.ipyv_rec_type;
api_exception exception;
l_respString VARCHAR2(15);
l_respId NUMBER;
l_resp_key VARCHAR2(30);
l_admin   VARCHAR2(120)  := 'SYSADMIN';
begin
l_respString:='FND_RESP540:';

if ( funcmode = 'RUN' ) then



l_resp_key:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCRESPONSIBILITYKEY');


SELECT responsibility_id
INTO l_respId
FROM fnd_responsibility
WHERE responsibility_key = l_resp_key
AND application_id = 540;

wf_engine.SetItemAttrText (itemtype   => itemtype,
                            itemkey    => itemkey,
                            aname      => 'SSC_NTFRECIPIENT_ITMATTR',
                            avalue     => l_respString || l_respId);



--Read attributes from WorkFlow
--Read attributes from WorkFlow
l_providerid:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCINSPROVIDERID');
l_siteid := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCSITEID');
l_chrid:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCKID');
l_coverage_amount:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCCOVERAGEAMOUNT');
l_deductible:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCDEDUCTIBLE');
l_requestor_userid:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'REQUESTOR');

l_policynum:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCPOLICYNUMBER');
l_lessor_insured:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCLESSORINSURED');
l_lessor_payee:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCLESSORPAYEE');

l_start_date:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCSTARTDATE');
l_end_date:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCENDDATE');

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'WF_ADMINISTRATOR',l_admin);


--get contract number for notification
SELECT contract_number
INTO l_knum
FROM okc_k_headers_v
WHERE id = l_chrid;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCONTRACTNUMBER',l_knum);


--Set attributes in record
l_policy_rec.policy_number := l_policynum;
l_policy_rec.covered_amount:= l_coverage_amount;
l_policy_rec.lessor_insured_yn := l_lessor_insured;
l_policy_rec.lessor_payee_yn := l_lessor_payee;
l_policy_rec.deductible := l_deductible;
l_policy_rec.date_to := l_end_date;
l_policy_rec.date_from := l_start_date;
l_policy_rec.isu_id := l_providerid;
l_policy_rec.khr_id := l_chrid;
l_policy_rec.sfwt_flag := 'T';
l_policy_rec.iss_code := null;
l_policy_rec.quote_yn := 'N';
l_policy_rec.agent_yn := 'N';
l_policy_rec.ipy_type := 'THIRD_PARTY_POLICY';
l_policy_rec.agency_site_id := l_siteid;

--call api
OKL_INS_POLICIES_PUB.insert_ins_policies(1.0,
            FND_API.G_FALSE,
                  lx_return_status,
                        lx_msg_count,
                        lx_msg_data,
                  l_policy_rec,
            lx_policy_rec);


if (lx_return_status = 'E') then
raise api_exception;
end if;

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
/*when api_exception then
    FND_MSG_PUB.Count_And_Get (
        p_encoded =>   FND_API.G_FALSE,
              p_count   =>   lx_msg_count,
              p_data    =>   lx_msg_data);*/
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'submit_ins_wf',itemtype, itemkey,actid,funcmode);
raise;
end submit_insurance_wf;

procedure req_renewal_quote_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 ) is

CURSOR contract_info(p_id NUMBER) IS
SELECT contract_number from okc_k_headers_b
WHERE id = p_id;

CURSOR user_info(p_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_id;

user_info_rec user_info%rowtype;


l_knum  VARCHAR2(120);
l_username VARCHAR2(100);
p_chrid NUMBER;
p_requestor_userid NUMBER;
l_respString VARCHAR2(15);
l_respId NUMBER;
l_resp_key VARCHAR2(30);

begin
l_respString:='FND_RESP540:';


if ( funcmode = 'RUN' ) then
p_chrid:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCKID');
p_requestor_userid:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'REQUESTOR');
l_resp_key :=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCRESPONSIBILITYKEY');

open contract_info(p_chrid);
fetch contract_info into l_knum;
close contract_info;

open user_info(p_requestor_userid);
fetch user_info into l_username;
close user_info;

SELECT responsibility_id
INTO l_respId
FROM fnd_responsibility
WHERE responsibility_key = l_resp_key
AND application_id = 540;

 wf_engine.SetItemAttrText (itemtype   => itemtype,
                            itemkey    => itemkey,
                            aname      => 'SSC_NTFRECIPIENT_ITMATTR',
                            avalue     => l_respString || l_respId);

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCKNUM',l_knum);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTOR',l_username);
resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'req_renewal_quote_wf',itemtype, itemkey,actid,funcmode);
raise;
end req_renewal_quote_wf;


-- added by padmaja
-- this procedure sets attribute values in the WF
PROCEDURE set_invoice_format_attributes (itemtype in varchar2,
                                        itemkey in varchar2,
                                        actid in number,
                                        funcmode in varchar2,
                                        resultout out nocopy varchar2 )
IS


l_chr_id   NUMBER;
l_contract_number  VARCHAR2(250);
l_current_format   VARCHAR2(150);
l_new_format       VARCHAR2(150);
l_format_id        NUMBER;
l_requestor        VARCHAR2(100);
l_approver         VARCHAR2(100);
l_admin         VARCHAR2(100) := 'SYSADMIN';
l_requestor_id     NUMBER;
l_approver_id      NUMBER;
l_resp_key         VARCHAR2(30);
l_respString VARCHAR2(15) := 'FND_RESP540:';
l_org_info okc_k_headers_all_b.org_id%type;
CURSOR contract_cur(l_chr_id NUMBER)
IS
SELECT CONTRACT_NUMBER ,org_id
FROM OKC_K_HEADERS_all_b --modified by rajnisku for getting org_id
WHERE id = l_chr_id;

CURSOR user_info(l_user_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = l_user_id;

CURSOR format_cur(l_format_id NUMBER) IS
SELECT name
FROM okl_invoice_formats_v
WHERE id = l_format_id;

CURSOR old_format_cur(l_chr_id NUMBER) IS
SELECT rule_information1
FROM okc_rules_b
WHERE rule_information_category = 'LAINVD'
AND dnz_chr_id = l_chr_id;

CURSOR approver_cur (l_resp_key VARCHAR2)IS
SELECT responsibility_id
FROM fnd_responsibility
WHERE responsibility_key = l_resp_key
AND application_id = 540;

begin

if ( funcmode = 'RUN' ) then

  l_chr_id:=to_number( WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCKID'));
  l_format_id:=to_number( WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCINVFORID'));
  l_requestor_id:=to_number( WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID'));
  l_resp_key := ( WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCAPPROVERRESPONSIBILITYKEY'));

  open contract_cur(l_chr_id);
  fetch contract_cur into l_contract_number,l_org_info;
  close contract_cur;

MO_GLOBAL.set_policy_context('S',l_org_info);

  open user_info(l_requestor_id);
  fetch user_info into l_requestor;
  close user_info;

  open approver_cur(l_resp_key);
  fetch approver_cur into l_approver_id;
  close approver_cur;

  open format_cur(l_format_id);
  fetch format_cur into l_new_format;
  close format_cur;

  open old_format_cur(l_chr_id);
  fetch old_format_cur into l_current_format;
  close old_format_cur;

  l_approver := l_respString||l_approver_id;

  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCKNUM',l_contract_number);
  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTOR',l_requestor);
  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCAPPROVER',l_approver);
  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCNEWINVFOR',l_new_format);
  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCURINVFOR',l_current_format);
  -- the error notification goes to the l_admin through WF default error processing
  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'WF_ADMINISTRATOR',l_admin);
  resultout := 'COMPLETE';

  return;
end if;


  if ( funcmode = 'CANCEL' ) then
    resultout := 'COMPLETE';
    return;
  end if;
  if ( funcmode = 'RESPOND') then
    resultout := 'COMPLETE';
    return;
  end if;
  if ( funcmode = 'FORWARD') then
    resultout := 'COMPLETE';
    return;
  end if;
  if ( funcmode = 'TRANSFER') then
    resultout := 'COMPLETE';
    return;
  end if;
  if ( funcmode = 'TIMEOUT' ) then
    resultout := 'COMPLETE';
  else
    resultout := wf_engine.eng_timedout;
  return;
  end if;

exception
when others then
-- default wf error handling
  WF_CORE.CONTEXT ('okl_ssc_wf'
  , 'set_invoice_format_attributes'
  , itemtype
  , itemkey
  , actid
  , funcmode);
  RAISE;

end set_invoice_format_attributes;

-- added by pnayani
-- Updates the invoice format
PROCEDURE invoice_format_change_wf(itemtype in varchar2,
                itemkey in varchar2,
                actid in number,
                funcmode in varchar2,
                resultout out nocopy varchar2 )
IS

CURSOR rule_id_cur( p_chr_id IN NUMBER)
IS
SELECT rl.id,
       rl.rgp_id
FROM   okc_rule_groups_v rg,
       okc_rules_v rl
WHERE rl.rgp_id = rg.id
AND   rl.dnz_chr_id = rg.dnz_chr_id
AND   rg.chr_id  = rl.dnz_chr_id
AND   rg.cle_id is null
AND   rg.rgd_code ='LABILL'
AND   rl.rule_information_category = 'LAINVD'
AND   rg.dnz_chr_id = p_chr_id;
CURSOR  org_info(p_contract_id NUMBER) IS --added by rajnisku for retrieving orginfo
select org_id from okc_k_headers_all_b
where id=p_contract_id;
l_org_info okc_k_headers_all_b.org_id%type;
rule_id_rec rule_id_cur%ROWTYPE;
l_rule_id  NUMBER;
l_rgp_id   NUMBER;
l_contract_id  NUMBER;
l_contract_number VARCHAR2(150);
l_invoice_format   VARCHAR2(150);
l_counter NUMBER := 1;
l_rule_tbl   l_rule_tbl_type;
l_return_status VARCHAR2(1);
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(250);
l_api_version NUMBER :=1.0;
cus_bank_acc_id number;

error_updating_invoice_format  EXCEPTION;

begin


  -- get attribute values from WF
  l_contract_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCKID');
  l_contract_number:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCKNUM');
  l_invoice_format:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCINVFORID'); --SSCNEWINVFOR -> Changed for bug 8933871 by nikshah
  open org_info(l_contract_id);
fetch org_info into l_org_info;
close org_info ;
MO_GLOBAL.set_policy_context('S',l_org_info);

   OPEN rule_id_cur(l_contract_id);
   FETCH rule_id_cur INTO rule_id_rec;
   l_rule_id := rule_id_rec.id;
   l_rgp_id := rule_id_rec.rgp_id;
   CLOSE rule_id_cur;

  l_rule_tbl(l_counter).rgd_code                  := 'LABILL';
  l_rule_tbl(l_counter).rule_id                   := l_rule_id;
  l_rule_tbl(l_counter).rgp_id                    := l_rgp_id;
  l_rule_tbl(l_counter).dnz_chr_id                := l_contract_id;
  l_rule_tbl(l_counter).sfwt_flag                 := 'N';
  l_rule_tbl(l_counter).std_template_yn           := 'N';
  l_rule_tbl(l_counter).warn_yn                   := 'N';
  l_rule_tbl(l_counter).created_by                := OKC_API.G_MISS_NUM;
  l_rule_tbl(l_counter).CREATION_DATE             := OKC_API.G_MISS_DATE;
  l_rule_tbl(l_counter).LAST_UPDATED_BY           := OKC_API.G_MISS_NUM;
  l_rule_tbl(l_counter).LAST_UPDATE_DATE          := OKC_API.G_MISS_DATE;
  l_rule_tbl(l_counter).LAST_UPDATE_LOGIN         := OKC_API.G_MISS_NUM;
  l_rule_tbl(l_counter).rule_information_category := 'LAINVD';
  l_rule_tbl(l_counter).rule_information1         := l_invoice_format;

     OKL_RGRP_RULES_PROCESS_PUB.process_rule_group_rules(
            p_api_version      => l_api_version
            ,p_init_msg_list    => 'T'
            ,x_return_status   => l_return_status
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data
            ,p_chr_id          => l_contract_id
            ,p_line_id         => -1
            ,p_cpl_id         => -1
            ,p_rrd_id         => -1
            ,p_rgr_tbl         => l_rule_tbl);

    IF l_return_status <> 'S' THEN
          RAISE error_updating_invoice_format;
      END IF;


EXCEPTION

  when others then
  -- default wf error handling
    WF_CORE.CONTEXT ('okl_ssc_wf'
                    , 'invoice_format_change_wf'
                    , itemtype
                    , itemkey,actid,funcmode);
       RAISE;
END;


/* procedure added by Vishal */
procedure req_billinf_change_getdata_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 ) is
CURSOR  org_info(p_contract_id NUMBER) IS
select org_id from okc_k_headers_all_b
where id=p_contract_id; --added by rajnisku for retrieving orginfo
l_org_info okc_k_headers_all_b.org_id%type;

--rkuttiya commented the below cursor for bug #6523600
/*CURSOR current_billing_info(p_contract_id NUMBER) IS
SELECT contract.contract_number contract_number,
       site.name bill_to_site,
       site.description bill_to_address
FROM   okx_cust_site_uses_v site ,
       okc_k_headers_all_b contract
WHERE  contract.id = p_contract_id
  AND  site.id1 = contract.bill_to_site_use_id; */

--rkuttiya added the below cursor for bug#6523600
  CURSOR current_billing_info(p_contract_id IN NUMBER) IS
  SELECT contract.contract_number contract_number,
         cs.location bill_to_site,
         ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,L.ADDRESS1,L.ADDRESS2,L.ADDRESS3,
         L.ADDRESS4,L.CITY,L.COUNTY,L.STATE,L.PROVINCE,L.POSTAL_CODE,NULL,L.COUNTRY,NULL,
         NULL,NULL,NULL,NULL,NULL,NULL,'N','N',300,1,1) bill_to_address
  FROM  hz_cust_site_uses_all cs,
        hz_cust_acct_sites_all ca,
        hz_party_sites ps,
        hz_locations l,
        okc_k_headers_all_b contract
  WHERE cs.cust_acct_site_id = ca.cust_acct_site_id
  AND   ca.party_site_id = ps.party_site_id
  AND   ps.location_id = l.location_id
  AND   l.content_source_type = 'USER_ENTERED'
  AND   cs.site_use_id = contract.bill_to_site_use_id
  AND   contract.id = p_contract_id;


current_billing_info_rec current_billing_info%rowtype;

-- parameters set in the procedure
l_contract_number okc_k_headers_b.contract_number%type;
l_current_billing_site okx_cust_site_uses_v.name%type;
l_current_billing_address okx_cust_site_uses_v.description%type;
l_new_billing_site okx_cust_site_uses_v.name%type;
l_new_billing_address okx_cust_site_uses_v.description%type;
l_username fnd_user.user_name%type;
l_respString VARCHAR2(50);
l_respId NUMBER;
l_resp_key VARCHAR2(30);

-- parameters getting passed
p_requestor_userid NUMBER;
p_new_billing_site_id NUMBER;
p_chrid NUMBER;

-- declare variable
l_admin   VARCHAR2(120) ;

--rkuttiya commented for bug #6523600
/*CURSOR new_billing_info(p_billing_site_id NUMBER) IS
select name bill_to_site, description bill_to_address
from okx_cust_site_uses_v
where id1= p_billing_site_id; */

CURSOR new_billing_info(p_billing_site_id IN VARCHAR2) IS
SELECT CS.LOCATION BILL_TO_SITE,
       ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,L.ADDRESS1,L.ADDRESS2,L.ADDRESS3,
L.ADDRESS4,L.CITY,L.COUNTY,L.STATE,L.PROVINCE,L.POSTAL_CODE,NULL,L.COUNTRY,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,'N','N',300,1,1) BILL_TO_ADDRESS
FROM HZ_CUST_SITE_USES_ALL CS,
     HZ_CUST_ACCT_SITES_ALL CA,
     HZ_PARTY_SITES  PS,
     HZ_LOCATIONS L
WHERE CS.CUST_ACCT_SITE_ID = CA.CUST_ACCT_SITE_ID
AND CA.PARTY_SITE_ID = PS.PARTY_SITE_ID
AND PS.LOCATION_ID = L.LOCATION_ID
AND L.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
AND CS.site_use_id = p_billing_site_id;

new_billing_info_rec new_billing_info%rowtype;

CURSOR user_info(l_user_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = l_user_id;
user_info_rec user_info%rowtype;

begin



if ( funcmode = 'RUN' ) then

l_admin := 'SYSADMIN';
-- assign variable to attribute
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'WF_ADMINISTRATOR',l_admin);

-- retrieve attributes from workflow engine
p_chrid:=to_number( WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCKID'));
p_requestor_userid:=to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID'));
p_new_billing_site_id:=to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCNEWBILLSITEID'));
l_resp_key :=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCAPPROVERRESPONSIBILITYKEY');
open org_info(p_chrid);
fetch org_info into l_org_info;
close org_info ;
MO_GLOBAL.set_policy_context('S',l_org_info);

--populate other attributes
open current_billing_info(p_chrid);
fetch current_billing_info into current_billing_info_rec;
l_contract_number := current_billing_info_rec.contract_number;
l_current_billing_site := current_billing_info_rec.bill_to_site;
l_current_billing_address := current_billing_info_rec.bill_to_address;
close current_billing_info;

open user_info(p_requestor_userid);
fetch user_info into user_info_rec;
l_username := user_info_rec.user_name;
close user_info;


open new_billing_info(p_new_billing_site_id);
fetch new_billing_info into new_billing_info_rec;
l_new_billing_site := new_billing_info_rec.bill_to_site;
l_new_billing_address := new_billing_info_rec.bill_to_address;
close new_billing_info;



l_respString := 'FND_RESP540:';

SELECT responsibility_id
INTO      l_respId
FROM    fnd_responsibility
WHERE  responsibility_key = l_resp_key -- This example is for 'Lease Center Agent' responsibility
AND       application_id = 540;

wf_engine.SetItemAttrText (itemtype   => itemtype ,
                                          itemkey    => itemkey ,
                                          aname      => 'SSC_NTFRECIPIENT_ITMATTR',
                                          avalue     => l_respString || l_respId);



WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCKNUM', l_contract_number );
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTOR', l_username);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCURBILLSITEADDRESS', l_current_billing_address );
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCURBILLSITE',l_current_billing_site);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCNEWBILLSITE',l_new_billing_site);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCNEWBILLSITEADDRESS',l_new_billing_address);

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'req_billinf_change_getdata_wf', itemtype, itemkey,actid,funcmode);
raise;
end req_billinf_change_getdata_wf;



/* procedure added by Vishal */
procedure req_billinf_change_wrapper_wf (itemtype in varchar2,
        itemkey in varchar2,
        actid in number,
        funcmode in varchar2,
        resultout out nocopy varchar2 ) is


l_contract_id  NUMBER ;
l_billing_site_id   NUMBER;
l_counter NUMBER := 1;
l_return_status VARCHAR2(1);
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(250);
l_api_version NUMBER;


l_chrv_rec OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE;
l_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
x_chrv_rec OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE;
x_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

api_exception  EXCEPTION;
-- declare variable
l_admin   VARCHAR2(120) ;
l_org_id  NUMBER;

begin

if ( funcmode = 'RUN' ) then

l_admin := 'SYSADMIN';
-- assign variable to attribute
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'WF_ADMINISTRATOR',l_admin);


--retrieve from the workflow engine
l_contract_id := to_number( WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCKID'));
l_billing_site_id := to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCNEWBILLSITEID'));
l_org_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORG_ID');
l_chrv_rec.ID := l_contract_id;
/* Bug 3292221 SPILLAIP changed l_khrv_rec.khr_id to id */
l_khrv_rec.ID := l_contract_id;
l_chrv_rec.bill_to_site_use_id := l_billing_site_id;

--rkuttiya modified for bug 6523600
--setting the org context to the contract org before updating the contract
--mo_global.init('OKL');
MO_GLOBAL.set_policy_context('S',l_org_id);

-- call the API to update billing information
     okl_contract_pub.update_contract_header(
            p_api_version      => '1.0'
            ,p_init_msg_list    => 'T'
            ,x_return_status   => l_return_status
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data
            ,p_restricted_update => OKL_API.G_FALSE
            ,p_chrv_rec => l_chrv_rec
            ,p_khrv_rec => l_khrv_rec
            ,x_chrv_rec => x_chrv_rec
            ,x_khrv_rec => x_khrv_rec);

    IF l_return_status <> 'S' THEN

          RAISE api_exception;
      END IF;


resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

  EXCEPTION

  when api_exception then
    FND_MSG_PUB.Count_And_Get (
          p_encoded =>   FND_API.G_FALSE,
          p_count   =>   l_msg_count,
          p_data    =>   l_msg_data);

    WF_CORE.CONTEXT ('okl_ssc_wf'
                    , 'req_billinf_change_wrapper_wf'
                    , itemtype, itemkey, actid, funcmode);

          raise;
  when others then
    WF_CORE.CONTEXT ('okl_ssc_wf'
                    , 'req_billinf_change_wrapper_wf'
                    , itemtype, itemkey, actid, funcmode);

       raise;
END req_billinf_change_wrapper_wf;


-- Vishal Added on 19-Sep-2002 to handle integration from EO
procedure raise_inv_format_chg_event ( contract_id in varchar2 ,
                                                   user_id in varchar2,
                                                   invoice_format_id in varchar2)

                                                   IS
CURSOR item_key_seq IS
SELECT OKLSSC_WFITEMKEY_S.nextval  key from dual;

item_key_rec item_key_seq%rowtype;

item_key varchar2(100) ;
begin


OPEN item_key_seq;
FETCH item_key_seq INTO item_key_rec;
item_key := to_char( item_key_rec.key);
CLOSE item_key_seq;

WF_EVENT.raise2( 'oracle.apps.okl.ssc.requestinvoiceformatchange',item_key, null, 'SSCKID', contract_id , 'SSCREQUESTORID', user_id, 'SSCINVFORID', invoice_format_id ) ;



end  raise_inv_format_chg_event;



-- Vishal Added on 20-Sep-2002 to handle integration from EO
--rkuttiya modified to add org id to set the org context
procedure raise_billinf_change_event ( contract_id in varchar2 ,
                                                   user_id in varchar2,
                                                   bill_site_id in varchar2)

                                                   IS
CURSOR item_key_seq IS
SELECT OKLSSC_WFITEMKEY_S.nextval  key from dual;

CURSOR c_get_khr_org(p_contract_id IN NUMBER) IS
select authoring_org_id
from okc_k_headers_all_b
where id = p_contract_id;

item_key_rec item_key_seq%rowtype;

item_key varchar2(100) ;
l_org_id NUMBER;
begin


OPEN item_key_seq;
FETCH item_key_seq INTO item_key_rec;
item_key := 'x' || to_char( item_key_rec.key);
CLOSE item_key_seq;

OPEN c_get_khr_org(contract_id);
FETCH c_get_khr_org INTO l_org_id;
CLOSE c_get_khr_org;


mo_global.init('OKL');
MO_GLOBAL.set_policy_context('S',l_org_id);

WF_EVENT.raise2('oracle.apps.okl.ssc.requestbillinginfochange',item_key, null, 'SSCKID', contract_id , 'SSCREQUESTORID', user_id, 'SSCNEWBILLSITEID', bill_site_id,'ORG_ID',l_org_id) ;


end  raise_billinf_change_event;

--Cancel Insurance Event function to set attributes
PROCEDURE cancel_ins_set_attr_wf
               (itemtype in varchar2,
                itemkey in varchar2,
                actid in number,
                funcmode in varchar2,
                resultout out nocopy varchar2 )
IS

CURSOR contract_info_cur( p_chr_id IN NUMBER) IS
SELECT contract_number from okc_k_headers_b
WHERE id = p_chr_id;

CURSOR policy_info_cur(p_pol_id IN NUMBER) IS
SELECT policy_number, iss_code, cancellation_date, khr_id
from OKL_INS_POLICIES_B
WHERE  id = p_pol_id;

CURSOR requestor_info_cur(p_requestor_id IN NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_requestor_id;

CURSOR fnd_lookup_cur(p_code IN VARCHAR2, p_type IN VARCHAR2) IS
SELECT meaning from fnd_lookups
WHERE lookup_type = p_type
 AND  lookup_code = p_code;

CURSOR policy_info_tl_cur(p_pol_id IN NUMBER) IS
SELECT cancellation_comment
FROM OKL_INS_POLICIES_TL
WHERE id = p_pol_id;

l_chr_id       VARCHAR2(40);
l_pol_id       VARCHAR2(40);
l_requestor_id VARCHAR2(40);
l_chr_number   VARCHAR2(120);
l_pol_number   VARCHAR2(20);
l_iss_code     VARCHAR2(30);
l_pol_status   VARCHAR2(80);
l_cancel_date  DATE;
l_user_name    VARCHAR2(100);
l_comments     VARCHAR2(240);
l_resp_id      VARCHAR2(15);
l_resp_key     VARCHAR2(30);
l_performer    VARCHAR2(27);
l_respString   VARCHAR2(12):='FND_RESP540:';

api_exception  EXCEPTION;

begin

if ( funcmode = 'RUN' ) then

--Read attributes from WorkFlow
l_pol_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCINSPOLID');
l_requestor_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID');
l_resp_key:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCRESPONSIBILITYKEY');

--Read from table
open policy_info_cur(l_pol_id);
fetch policy_info_cur into l_pol_number,l_iss_code, l_cancel_date,l_chr_id ;
close policy_info_cur;

open contract_info_cur(l_chr_id);
fetch contract_info_cur into l_chr_number;
close contract_info_cur;

open requestor_info_cur(l_requestor_id);
fetch requestor_info_cur into l_user_name;
close requestor_info_cur;

open fnd_lookup_cur(l_iss_code, 'OKL_INSURANCE_STATUS');
fetch fnd_lookup_cur into l_pol_status;
close fnd_lookup_cur;

open policy_info_tl_cur(l_pol_id);
fetch  policy_info_tl_cur into l_comments;
close policy_info_tl_cur;


SELECT responsibility_id
into   l_resp_id
FROM   fnd_responsibility
WHERE  responsibility_key = l_resp_key
AND    application_id = 540;


WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCONTRACTNUMBER', l_chr_number );
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTORNAME', l_user_name);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPOLNUMBER', l_pol_number);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPOLSTATUS', l_pol_status);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCANCELDATE', l_cancel_date);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCOMMENTS', l_comments);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPERFORMER', l_respString||l_resp_id);

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('OKL_SSC_WF', 'cancel_ins_set_attr_wf', itemtype, itemkey,'c','d');
raise;
END cancel_ins_set_attr_wf;

--Cancel Insurance PL/SQL wrapper
PROCEDURE cancel_ins_wrapper_wf
            (p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2,
             p_polid                          IN number,
             p_cancelcomment                  IN varchar2,
             p_canceldate                     IN date,
             p_canrsn_code                    IN varchar2,
             p_userid                      IN  NUMBER,
             x_return_status                OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2
             )
IS
    l_ipyv_rec  ipyv_rec_type;
    lx_ipyv_rec  ipyv_rec_type;
    l_iss_code   VARCHAR2(30);
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    l_message   VARCHAR2(2000);
    l_seq        NUMBER;
    l_event_name varchar2(240) := 'oracle.apps.okl.ssc.cancelInsurance';
    l_yn        VARCHAR2(1);

   CURSOR policy_info_cur(p_polid IN NUMBER) IS
   SELECT iss_code
   FROM OKL_INS_POLICIES_B
   WHERE  id = p_polid;

   CURSOR wf_seq IS
   SELECT OKLSSC_WFITEMKEY_S.nextval
   FROM  dual;


    api_exception  EXCEPTION;
begin

 SAVEPOINT cancel_insurance;

 l_return_status := OKC_API.G_RET_STS_SUCCESS ;
 -- Test if there are any active subscritions
 -- if it is the case then execute the subscriptions
 l_yn := exist_subscription(l_event_name);

 IF l_yn = 'Y' THEN

  open policy_info_cur(p_polid);
  fetch policy_info_cur into l_iss_code;
  close policy_info_cur;

  open wf_seq;
  fetch wf_seq into l_seq;
  close wf_seq;

  l_ipyv_rec.id := p_polid;
  l_ipyv_rec.crx_code :=p_canrsn_code;
  l_ipyv_rec.cancellation_comment := p_cancelcomment;
  l_ipyv_rec.cancellation_date := p_canceldate;

  if (l_iss_code='PENDING' OR l_iss_code='ACCEPTED') THEN
      OKL_INSURANCE_POLICIES_PUB.delete_policy(
                                 p_api_version,
                                 p_init_msg_list => l_init_msg_list,
                                 x_return_status => l_return_status,
                                 x_msg_count => l_msg_count,
                                 x_msg_data => l_msg_data,
                                 p_ipyv_rec => l_ipyv_rec,
                                 x_ipyv_rec => lx_ipyv_rec);
  ELSE
      OKL_INSURANCE_POLICIES_PUB.cancel_policy(
                                 p_api_version,
                                 p_init_msg_list => l_init_msg_list,
                                 x_return_status => l_return_status,
                                 x_msg_count => l_msg_count,
                                 x_msg_data => l_msg_data,
                                 p_ipyv_rec => l_ipyv_rec,
                                 x_ipyv_rec => lx_ipyv_rec);

  END IF;


    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
 IF (l_return_status='S') THEN
    WF_EVENT.raise2('oracle.apps.okl.ssc.cancelInsurance'
                     ,l_event_name||l_seq, null
                     ,'SSCINSPOLID', p_polid
                     ,'SSCREQUESTORID',p_userid);
 END IF;

ELSE
  FND_MESSAGE.SET_NAME('OKL', 'OKL_NO_EVENT');
  FND_MSG_PUB.ADD;
  l_return_status :=   OKC_API.G_RET_STS_ERROR ;

  x_return_status := l_return_status ;
  x_msg_count := l_msg_count ;
  x_msg_data := l_msg_data ;

END IF;

 return;
 EXCEPTION
   when api_exception then
    x_return_status := l_return_status;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    FND_MSG_PUB.Count_And_Get (
          p_encoded =>   FND_API.G_FALSE,
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data);


   WHEN OTHERS THEN
    x_return_status := l_return_status;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    --FND_MSG_PUB.ADD_EXC_MSG( 'OKL_SSC_WF' ,   'cancel_ins_wrapper_wf', itemtype, itemkey, 'c','d');
    FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
  ROLLBACK TO cancel_insurance;
END cancel_ins_wrapper_wf;

------------------------------------------------------------------------------------
---------- Calim Notification ---------------------------------------------------
PROCEDURE set_claim_receiver
  (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2)
 IS



 CURSOR receiver_cur(respKey varchar2) IS
 SELECT responsibility_id
 FROM fnd_responsibility
 WHERE responsibility_key = respKey
 AND application_id = 540;


 CURSOR claim_info(claim_id VARCHAR2) IS
SELECT IPYB.POLICY_NUMBER , ICMB.CLAIM_NUMBER
 FROM OKL_INS_POLICIES_B IPYB,  OKL_INS_CLAIMS_B ICMB
 WHERE IPYB.ID = ICMB.IPY_ID
 AND ICMB.ID = claim_id;


 l_claim_number  VARCHAR2(15);
 l_policy_number VARCHAR2(20);
 p_claim_id  VARCHAR2(50);
 p_resp_key varchar2(30) := 'OKLCS';
 l_respString VARCHAR2(15) := 'FND_RESP540:';
 l_approver_name VARCHAR2(200) := 'FND_RESP540:0' ;
 l_approver_id   NUMBER := 0  ;

api_exception  EXCEPTION;

 BEGIN

 if ( funcmode = 'RUN' ) then

   p_resp_key:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCRESPONSIBILITYKEY');
   p_claim_id := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'CLAIM_ID');


  -- SET RECEIVER
   open receiver_cur(p_resp_key);
   fetch receiver_cur into l_approver_id;
   close receiver_cur;
   l_approver_name := l_respString||TO_CHAR(l_approver_id);

   WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSC_NTFRECIPIENT_ITMATTR', l_approver_name);

   -- SET CLAIM NUMBER
      open claim_info(p_claim_id);
      fetch claim_info into l_policy_number,l_claim_number ;

       IF (claim_info%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME('OKL', 'OKL_INVALID_VALUE');
          FND_MSG_PUB.ADD;
          raise api_exception;
       END IF ;

       WF_ENGINE.SetItemAttrText(itemtype,itemkey,'POLICY_NUMBER', l_policy_number);
       WF_ENGINE.SetItemAttrText(itemtype,itemkey,'CLAIM_NUMBER', l_claim_number);



      close claim_info;



   resultout := 'COMPLETE';

   return;
 end if;


 if ( funcmode = 'CANCEL' ) then

   resultout := 'COMPLETE';
   return;
 end if;
 if ( funcmode = 'RESPOND') then
   resultout := 'COMPLETE';
   return;
 end if;
 if ( funcmode = 'FORWARD') then
   resultout := 'COMPLETE';
   return;
 end if;
 if ( funcmode = 'TRANSFER') then
   resultout := 'COMPLETE';
   return;
 end if;
 if ( funcmode = 'TIMEOUT' ) then
  resultout := 'COMPLETE';
 else
  resultout := wf_engine.eng_timedout;
  return;
 end if;

 exception
 when others then
   WF_CORE.CONTEXT ('OKL_SSC_WF', 'set_claim_receiver', itemtype, itemkey,actid,funcmode);
   resultout := 'ERROR';
   raise;

end set_claim_receiver;

--- Added by DKHANDEL
PROCEDURE create_claim_event
( p_claim_id   IN NUMBER,
  x_retrun_status OUT NOCOPY VARCHAR2)
IS
 l_parameter_list wf_parameter_list_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.okl.ssc.createinsuranceclaim';
 l_seq NUMBER ;
BEGIN

 SAVEPOINT create_claim_event;

x_retrun_status := OKC_API.G_RET_STS_SUCCESS ;
 -- Test if there are any active subscritions
 -- if it is the case then execute the subscriptions
 l_yn := exist_subscription(l_event_name);
 IF l_yn = 'Y' THEN

   --Get the item key
  select OKLSSC_WFITEMKEY_S.nextval INTO l_seq FROM DUAL ;
   l_key := l_event_name ||l_seq ;

   --Set Parameters
   wf_event.AddParameterToList('CLAIM_ID',TO_CHAR(p_claim_id),l_parameter_list);

 -- Call it again if you have more than one parameter
-- Keep data type (text) only

   -- Raise Event
   -- It is overloaded function so use according to requirement
   wf_event.raise(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_parameter_list);
   l_parameter_list.DELETE;

ELSE
  FND_MESSAGE.SET_NAME('OKL', 'OKL_NO_EVENT');
  FND_MSG_PUB.ADD;
  x_retrun_status :=   OKC_API.G_RET_STS_ERROR ;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_claim_event;
 x_retrun_status :=   OKC_API.G_RET_STS_UNEXP_ERROR ;

END create_claim_event;

-- Start of comments
--
-- Procedure Name  : load_mess
-- Description     : Private procedure to load messages into attributes
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  procedure load_mess(  itemtype  in varchar2,
        itemkey   in varchar2) is
  i integer;
  j integer;
 begin
  j := NVL(FND_MSG_PUB.Count_Msg,0);
  if (j=0) then return; end if;
  if (j>9) then j:=9; end if;
  FOR I IN 1..J LOOP
    wf_engine.SetItemAttrText (itemtype   => itemtype,
              itemkey   => itemkey,
                aname   => 'MESSAGE'||i,
                    avalue  => FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
  END LOOP;
end;


-- Start of comments
--
-- Procedure Name  : accept_renewal_quote
-- Description     : Public procedure to accept a renewal quote
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure accept_renewal_quote(quote_id in number,
                               contract_id in number,
                               user_id in number,
        x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2) IS

l_currency_code VARCHAR2(3);
chrvrec1 okl_okc_migration_pvt.chrv_rec_type;
chrvrec2 okl_contract_pub.khrv_rec_type;
xchrvrec1 okl_okc_migration_pvt.chrv_rec_type;
xchrvrec2 okl_contract_pub.khrv_rec_type;
api_exception EXCEPTION;
l_obj_vers_number NUMBER;
x_trqv_rec okl_trx_requests_pub.trqv_rec_type;
p_trqv_rec okl_trx_requests_pub.trqv_rec_type;

CURSOR contract_info(p_id NUMBER) IS
SELECT object_version_number, currency_code from okc_k_headers_b
WHERE id = p_id;

CURSOR user_info(p_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_id;



begin

open contract_info(contract_id);
fetch contract_info into l_obj_vers_number, l_currency_code;
close contract_info;

p_trqv_rec.id := quote_id;
p_trqv_rec.request_status_code := 'ACCEPTED';
p_trqv_rec.dnz_khr_id := contract_id;
p_trqv_rec.currency_code := l_currency_code;

--OKL_CS_LEASE_RENEWAL_PUB.update_trx_request(
OKL_CS_LEASE_RENEWAL_PUB.update_lrnw_request(1.0,
                                          OKL_API.G_FALSE,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data,
                                          p_trqv_rec,
                                          x_trqv_rec);

 if (x_return_status <> 'S') then
    raise api_exception;
 end if;



chrvrec1.id := contract_id;
chrvrec1.object_version_number := l_obj_vers_number;
chrvrec1.sts_code := 'ABANDONED';

OKL_CONTRACT_PUB.update_contract_header(1.0,
                                        FND_API.G_FALSE,
                                        x_return_status,
                                        x_msg_count,
                                        x_msg_data,
                                        null,
                                        chrvrec1,
                                        chrvrec2,
                                        xchrvrec1,
                                        xchrvrec2);

 if (x_return_status <> 'S') then
    raise api_exception;
 end if;

 okl_cs_wf.raise_lease_renewal_event(quote_id);

EXCEPTION

  when api_exception then

    FND_MSG_PUB.Count_And_Get (
          p_encoded =>   FND_API.G_FALSE,
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data);
          raise;
end accept_renewal_quote;

--Zhendi Added the procedure process_renewal_quote

-- Start of comments
--
-- Procedure Name  : process_renewal_quote
-- Description     : Public procedure to accept or reject a renewal quote
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure process_renewal_quote(quote_id in number,
                                contract_id in number,
                                user_id in number,
                                                                status_mode in varchar2,
                                                        x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2) IS

l_currency_code VARCHAR2(3);
chrvrec1 okl_okc_migration_pvt.chrv_rec_type;
chrvrec2 okl_contract_pub.khrv_rec_type;
xchrvrec1 okl_okc_migration_pvt.chrv_rec_type;
xchrvrec2 okl_contract_pub.khrv_rec_type;
api_exception EXCEPTION;
l_obj_vers_number NUMBER;
x_trqv_rec okl_trx_requests_pub.trqv_rec_type;
p_trqv_rec okl_trx_requests_pub.trqv_rec_type;

CURSOR contract_info(p_id NUMBER) IS
SELECT object_version_number, currency_code from okc_k_headers_b
WHERE id = p_id;

CURSOR user_info(p_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_id;



begin

open contract_info(contract_id);
fetch contract_info into l_obj_vers_number, l_currency_code;
close contract_info;

p_trqv_rec.id := quote_id;
p_trqv_rec.request_status_code := status_mode; --'ACCEPTED' or 'REJECTED';
p_trqv_rec.dnz_khr_id := contract_id;
p_trqv_rec.currency_code := l_currency_code;

--OKL_CS_LEASE_RENEWAL_PUB.update_trx_request(
OKL_CS_LEASE_RENEWAL_PUB.update_lrnw_request(1.0,
                                          OKL_API.G_FALSE,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data,
                                          p_trqv_rec,
                                          x_trqv_rec);

 if (x_return_status <> 'S') then
    raise api_exception;
 end if;



chrvrec1.id := contract_id;
chrvrec1.object_version_number := l_obj_vers_number;
chrvrec1.sts_code := 'ABANDONED';

OKL_CONTRACT_PUB.update_contract_header(1.0,
                                        FND_API.G_FALSE,
                                        x_return_status,
                                        x_msg_count,
                                        x_msg_data,
                                        null,
                                        chrvrec1,
                                        chrvrec2,
                                        xchrvrec1,
                                        xchrvrec2);

 if (x_return_status <> 'S') then
    raise api_exception;
 end if;

 okl_cs_wf.raise_lease_renewal_event(quote_id);

EXCEPTION

  when api_exception then

    FND_MSG_PUB.Count_And_Get (
          p_encoded =>   FND_API.G_FALSE,
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data);
          raise;
end process_renewal_quote;

--End of procedure process_renewal_quote added by Zhendi

-- Make payment PL/SQL wrapper
PROCEDURE make_payment_wrapper_wf
            (p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2,
             p_invid                        IN NUMBER DEFAULT NULL,
             p_paymentamount                IN NUMBER,
             p_paymentcurrency              IN VARCHAR2,
             p_cctype                       IN VARCHAR2 DEFAULT NULL,
             p_expdate                      IN DATE DEFAULT NULL,
             p_ccnum                        IN VARCHAR2 DEFAULT NULL,
             p_ccname                       IN VARCHAR2 DEFAULT NULL,
             p_userid                       IN NUMBER,
             p_custid                       IN VARCHAR2 DEFAULT NULL, -- smoduga 4055222
             x_return_status                OUT NOCOPY VARCHAR2,
             x_payment_ref_number           OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2,
             p_paymentdate                  IN DATE,
             p_conInv                       IN VARCHAR2 DEFAULT NULL,
	     -- Begin - Additional Parameters included by Varangan- for Oracle Payments Uptake
	     p_customer_trx_id		    IN NUMBER,
 	     p_customer_id		    IN NUMBER,
	     p_customer_site_use_id         IN NUMBER,
	     p_payment_trxn_extension_id    IN NUMBER,
	     x_cash_receipt_id              OUT NOCOPY NUMBER
	     -- End - Payments Uptake
             )
IS
-------------------------------------------------------------------------------------
pl_init_msg_list        VARCHAR2(1) := Okc_Api.g_false;
xl_return_status        VARCHAR2(1) := 'U';
xl_msg_count            NUMBER;
xl_msg_data                 VARCHAR2(2000);
pl_cons_bill_id         NUMBER;
pl_cons_bill_num        VARCHAR2(90) default null;
pl_currency_code        VARCHAR2(30);
pl_irm_id                        NUMBER DEFAULT NULL;
pl_rcpt_amount          NUMBER;
pl_customer_id          NUMBER;
pl_commit                  VARCHAR2(1);
pl_payment_amount          NUMBER DEFAULT pl_rcpt_amount;
pl_payment_date            DATE DEFAULT TRUNC(SYSDATE);
pl_payment_instrument      VARCHAR2(15) DEFAULT 'CREDIT_CARD';
--START: Fixed Bug 5697488
pl_customer_bank_acct_id   IBY_EXT_BANK_ACCOUNTS.EXT_BANK_ACCOUNT_ID%TYPE DEFAULT NULL;
--END: Fixed Bug 5697488
pl_account_holder_name     VARCHAR2(15);
pl_account_type            VARCHAR2(15) default null;
pl_expiration_date         DATE;
xl_payment_ref_number      AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE DEFAULT NULL;
l_cust_id                      NUMBER;

 -- Begin - Varangan- for Oracle Payments Uptake
pl_customer_trx_id        NUMBER;
pl_customer_site_use_id   NUMBER;
pl_payment_trxn_extension_id    NUMBER;
xl_cash_receipt_id        NUMBER;
l_org_id       NUMBER := mo_global.get_current_org_id();

 -- Get receipt method id
	CURSOR c_get_irm(lorg_id Number) IS
	SELECT ccard_remittance_id rm_id
	FROM okl_system_params_all
	WHERE org_id = lorg_id ;
-- Get site use id
	Cursor c_get_site_use (l_inv_id Number)
	IS
	Select bill_to_site_use_id site_use_id
	from ra_customer_trx
	where customer_Trx_id = l_inv_id;

-- End - Payments Uptake
------------------------------------------------------------------------------------
make_payment_error  EXCEPTION;

begin
SAVEPOINT make_payment;

	 -- Commented for Make Payment change
	 /*
	  select cust_account_id INTO l_cust_id
	  from HZ_CUST_ACCOUNTS
	  where account_number = p_custid;--Smoduga removed char conversion
					  --as p_cust_id is of type varchar2.4055222
	  --modified by akrangan on 28.7.06 MOAC Changes
	   pl_irm_id := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_CCARD_REMITTANCE_ID) ; */

  For K In c_get_irm(l_org_id)
  Loop
     pl_irm_id:=K.rm_id;
  End Loop;

  pl_currency_code := p_paymentcurrency ;
  pl_cons_bill_id := p_invid ;
  pl_payment_amount := p_paymentamount;
  pl_payment_date := p_paymentdate;
  pl_account_holder_name := p_ccname;
  pl_expiration_date := p_expdate;
  pl_cons_bill_num := p_conInv;

 -- Begin - Varangan- for Oracle Payments Uptake
	pl_customer_trx_id:=p_customer_trx_id;
	pl_customer_id :=p_customer_id;
	pl_customer_site_use_id :=p_customer_site_use_id;
	If pl_customer_site_use_id Is Null Then
		FOR I In c_get_site_use(pl_customer_trx_id)
		Loop
			pl_customer_site_use_id := I.site_use_id;
		End Loop;
        End If;
	pl_payment_trxn_extension_id :=	p_payment_trxn_extension_id;
-- End - Payments Uptake

 --  Call to OKL_PAYMENT_PUB.CREATEPAYMENTS From OKL_SSC_WF Start

  -- Start of wraper code generated automatically by Debug code generator for okl_setupfunctions_pvt.get_rec
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLSSWFB.pls call OKL_PAYMENT_PUB.CREATE_PAYMENTS ');
    END;
  END IF;
  --commented out the call to eliminate receipt dependency by dkagrawa
-- Begin - Make Payment - varangan
 /*  okl_payment_pub.CREATE_PAYMENTS(
	   p_api_version    => p_api_version,
	   p_init_msg_list  => pl_init_msg_list,
	   p_commit         => pl_commit,
	   x_return_status  => xl_return_status,
	   x_msg_count      => xl_msg_count,
	   x_msg_data       => xl_msg_data,
	   p_currency_code  => p_paymentcurrency,
	   p_irm_id         => pl_irm_id,
	   p_payment_amount => p_paymentamount,
	   p_customer_id    => pl_customer_id,
	   p_payment_date   => p_paymentdate,
	   x_payment_ref_number => xl_payment_ref_number,
	   p_customer_trx_id =>pl_customer_trx_id,
	   p_customer_site_use_id =>pl_customer_site_use_id,
	   p_payment_trxn_extension_id =>pl_payment_trxn_extension_id,
	   x_cash_receipt_id  => xl_cash_receipt_id
   ); */

-- End - Make Payment - varangan

 --  Call to OKL_PAYMENT_PUB.CREATEPAYMENTS From OKL_SSC_WF End

  xl_return_status := nvl(xl_return_status,OKL_API.G_RET_STS_UNEXP_ERROR);

   IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLSSWFB.pls call OKL_PAYMENT_PUB.CREATE_PAYMENTS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupfunctions_pvt.get_rec
   -- check for errors
  IF xl_return_status <> OKL_API.G_RET_STS_SUCCESS then
   xl_msg_data := 'OKL_PAYMENT_CREATE_FAILED';
  RAISE make_payment_error;

 END IF;

 -- Return the Payment Reference Number to display in the Make Payment
 -- confirmation page
 -- Assign value to OUT variables

 x_payment_ref_number := xl_payment_ref_number;
 x_return_status := xl_return_status;
 x_cash_receipt_id :=xl_cash_receipt_id;
 x_msg_count :=xl_msg_count;
 x_msg_data :=xl_msg_data;
 return;

 EXCEPTION
   when make_payment_error then
    x_return_status :=  OKL_API.G_RET_STS_UNEXP_ERROR;
END make_payment_wrapper_wf;


--Make Payment Event function to set attributes

PROCEDURE make_payment_set_attr_wf
               (itemtype in varchar2,
                itemkey in varchar2,
                actid in number,
                funcmode in varchar2,
                resultout out nocopy varchar2 )
IS

CURSOR cust_id_info_cur(p_payment_id IN NUMBER) IS
SELECT pay_from_customer cust_account_id
FROM ar_cash_receipts_all
WHERE  cash_receipt_id = p_payment_id;

CURSOR cust_name_info_cur(p_cust_id IN NUMBER) IS
SELECT account_name
FROM hz_cust_accounts
WHERE  cust_account_id = p_cust_id;

CURSOR requestor_info_cur(p_requestor_id IN NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_requestor_id;


l_payment_id         VARCHAR2(40);
l_inv_number         VARCHAR2(80);
l_cust_id            VARCHAR2(40);
l_cust_name          VARCHAR2(100);
l_payment_number     VARCHAR2(80);
l_requestor_id       VARCHAR2(40);
l_payee_role         VARCHAR2(30);
l_resp_id            NUMBER;
l_respString         VARCHAR2(15) := 'FND_RESP540:';
l_payment_ref_number VARCHAR2(30);


api_exception  EXCEPTION;

begin

if ( funcmode = 'RUN' ) then

--Read attributes from WorkFlow
l_payment_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCPAYMENTID');
l_requestor_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID');
l_payment_number:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCPAYMENTREFNUMBER');


--Read from table
open cust_id_info_cur(l_payment_id);
fetch cust_id_info_cur into l_cust_id;
close cust_id_info_cur;

open cust_name_info_cur(l_cust_id);
fetch cust_name_info_cur into l_cust_name;
close cust_name_info_cur;


l_payee_role := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCPAYEEROLE');

SELECT responsibility_id
into   l_resp_id
FROM   fnd_responsibility
WHERE  responsibility_key = l_payee_role
AND    application_id = 540;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCACCOUNTNAME', l_cust_name );
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPAYMENTNUM', l_payment_number);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPAYEEPERFORMER', l_respString || l_resp_id );

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
when others then
WF_CORE.CONTEXT ('OKL_SSC_WF', 'make_payment_set_attr_wf', itemtype, itemkey,'actid','funcmode');
raise;
END make_payment_set_attr_wf;

--IBYON added on OCT-01-2002 wrapper to call party api and validate parties for termination quote
--IBYON added on OCT-10-2002 x_cpl_id and x_email_address just in case there are no recipient
PROCEDURE validate_recipient_term_quote
            (p_api_version                  IN NUMBER,
             p_init_msg_list                IN VARCHAR2,
             p_khrid                        IN number,
             p_qrs_code                     IN VARCHAR2,
             p_qtp_code                     IN VARCHAR2,
             p_comments                     IN VARCHAR2,
             x_vendor_flag                  OUT NOCOPY VARCHAR2,
             x_lessee_flag                  OUT NOCOPY VARCHAR2,
             x_cpl_id                       OUT NOCOPY VARCHAR2,
             x_email_address                OUT NOCOPY VARCHAR2,
             x_return_status                OUT NOCOPY VARCHAR2,
             x_msg_count                    OUT NOCOPY NUMBER,
             x_msg_data                     OUT NOCOPY VARCHAR2
             )
IS
  l_qtev_rec    qtev_rec_type;
  l_qpyv_tbl    qpyv_tbl_type;
  l_q_party_uv_tbl  q_party_uv_tbl_type;
  l_record_count    NUMBER;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_recipient_exist_flag VARCHAR2(1) :='N';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_msg_count   NUMBER    := OKL_API.G_MISS_NUM;
  l_msg_data    VARCHAR2(2000);
  i                       NUMBER;
  api_exception           EXCEPTION;
  --Fixed Bug # 5484903
  CURSOR cpl_id_cur( p_khr_id IN NUMBER) IS
  --Fixed Bug 5484309
 select id from okc_k_party_roles_b
  where dnz_chr_id = p_khr_id
  AND chr_id = dnz_chr_id
  and rle_code='LESSEE';

  CURSOR email_address_cur(p_user_id IN NUMBER) IS
  SELECT email_address from fnd_user
  WHERE  user_id = p_user_id;

begin

    l_qtev_rec.khr_id := p_khrid;
    l_qtev_rec.qrs_code := p_qrs_code;
    l_qtev_rec.qtp_code := p_qtp_code;
    l_qtev_rec.comments := p_comments;

    x_vendor_flag := 'N';
    x_lessee_flag := 'N';
    OKL_AM_PARTIES_PVT.fetch_rule_quote_parties( p_api_version,
                    p_init_msg_list,
                    l_msg_count,
                    l_msg_data,
                    l_return_status,
                    l_qtev_rec,
                    l_qpyv_tbl,
                    l_q_party_uv_tbl,
                    l_record_count);

-- Validate whether one of the party is vendor
   IF l_qpyv_tbl IS NOT NULL THEN
     IF l_qpyv_tbl.count > 0 THEN
       FOR i IN l_qpyv_tbl.first..l_qpyv_tbl.last LOOP
          IF l_qpyv_tbl(i).qpt_code = 'RECIPIENT' OR
             l_qpyv_tbl(i).qpt_code = 'RECIPIENT_ADDITIONAL' THEN
             l_recipient_exist_flag :='Y';
             IF l_q_party_uv_tbl(i).kp_role_code = 'OKL_VENDOR' THEN
                 x_vendor_flag := 'Y';
             END IF;
             IF l_q_party_uv_tbl(i).kp_role_code = 'LESSEE' THEN
                 x_lessee_flag := 'Y';
             END IF;
          END IF;
       END LOOP;
    END IF;
  END IF;

-- If there is no recipient in parties then we need to return party id and
-- email address of requestor

  IF l_recipient_exist_flag = 'N' THEN
     open cpl_id_cur(p_khrid);
     fetch cpl_id_cur into x_cpl_id;
     close cpl_id_cur;

     open email_address_cur(FND_GLOBAL.USER_ID);
     fetch email_address_cur into x_email_address;
     close email_address_cur;
  END IF;


  x_return_status := l_return_status;
  x_msg_count := l_msg_count ;
  x_msg_data := l_msg_data ;

 EXCEPTION
   when api_exception then
    x_return_status := l_return_status;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    FND_MSG_PUB.Count_And_Get (
          p_encoded =>   FND_API.G_FALSE,
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data);


   WHEN OTHERS THEN
    x_return_status := l_return_status;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

END validate_recipient_term_quote;

-- IBYON added on 01-OCT-2002 to raise event for termination quote
PROCEDURE create_termqt_raise_event_wf
            (p_qte_id            IN NUMBER,
             p_user_id           IN VARCHAR2,
             x_return_status     OUT NOCOPY VARCHAR2,
             x_msg_count         OUT NOCOPY NUMBER,
             x_msg_data          OUT NOCOPY VARCHAR2)
  IS
    l_yn    VARCHAR2(1);
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_event_name varchar2(240) := 'oracle.apps.okl.ssc.createterminationquote';
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    l_message   VARCHAR2(2000);
    l_seq        NUMBER;
    api_exception EXCEPTION;
  begin
    l_yn := exist_subscription(l_event_name);
    SELECT OKLSSC_WFITEMKEY_S.nextval into l_seq
    FROM  dual;

   IF l_yn = 'N' THEN
      FND_MESSAGE.SET_NAME('OKL', 'OKL_NO_EVENT');
      FND_MSG_PUB.ADD;
      l_return_status := OKC_API.G_RET_STS_ERROR;
      raise api_exception;
   ELSE
      WF_EVENT.raise2(l_event_name,
                      l_event_name||l_seq,
                      null,
                      'SSCQUOTEID', p_qte_id,
                      'SSCREQUESTORID',p_user_id);
     END IF;
     x_return_status :=l_return_status;
     x_msg_count:=l_msg_count;
     x_msg_data := l_msg_data;
 EXCEPTION
   when api_exception then
    x_return_status := l_return_status;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    FND_MSG_PUB.Count_And_Get (
          p_encoded =>   FND_API.G_FALSE,
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data);


   WHEN OTHERS THEN
    x_return_status := l_return_status;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

END create_termqt_raise_event_wf;


-- IBYON added on 01-OCT-2002 to set attributes for termination quote notification
PROCEDURE create_termqt_set_attr_wf
           (itemtype in varchar2,
            itemkey in varchar2,
            actid in number,
            funcmode in varchar2,
            resultout out nocopy varchar2 )
IS

CURSOR contract_info_cur( p_khr_id IN NUMBER) IS
SELECT contract_number from okc_k_headers_b
WHERE id = p_khr_id;

CURSOR quote_info_cur(p_qte_id IN NUMBER) IS
SELECT quote_number, quote_type_description,
       quote_reason_description, comments, khr_id
from okl_am_quotes_uv
WHERE  id = p_qte_id;

CURSOR requestor_info_cur(p_requestor_id IN NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_requestor_id;


l_chr_id       VARCHAR2(40);
l_qte_id       VARCHAR2(40);
l_requestor_id VARCHAR2(40);
l_chr_number   VARCHAR2(120);
l_qte_number   VARCHAR2(20);
l_qtp          VARCHAR2(80);
l_qrs          VARCHAR2(80);
l_user_name    VARCHAR2(100);
l_comments     VARCHAR2(1995);
l_resp_id      VARCHAR2(15);
l_resp_key     VARCHAR2(30);
l_performer    VARCHAR2(27);
l_respString   VARCHAR2(12):='FND_RESP540:';

api_exception  EXCEPTION;

begin

if ( funcmode = 'RUN' ) then

--Read attributes from WorkFlow
l_qte_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCQUOTEID');
l_requestor_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID');
l_resp_key:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCRESPONSIBILITYKEY');


--Read from table
open quote_info_cur(l_qte_id);
fetch quote_info_cur into l_qte_number,l_qtp, l_qrs, l_comments,l_chr_id ;
close quote_info_cur;

open contract_info_cur(l_chr_id);
fetch contract_info_cur into l_chr_number;
close contract_info_cur;

open requestor_info_cur(l_requestor_id);
fetch requestor_info_cur into l_user_name;
close requestor_info_cur;


SELECT responsibility_id into   l_resp_id
FROM   fnd_responsibility
WHERE  responsibility_key = l_resp_key
AND    application_id = 540;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCONTRACTNUMBER', l_chr_number );
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTORNAME', l_user_name);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCQUOTENUMBER', l_qte_number);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCQTP', l_qtp);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCQRS', l_qrs);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCCOMMENTS', l_comments);
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPERFORMER', l_respString||l_resp_id);

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;

exception
   when others then
    WF_CORE.CONTEXT (G_PKG_NAME, 'create_termqt_set_attr_wf', itemtype, itemkey);
   raise;
END create_termqt_set_attr_wf;

-- procedure : raise_assets_return_event
-- Comments: Raises the assets return event
-- Created by: viselvar
-- version :1
-- Fix for bug 4754894
procedure raise_assets_return_event ( p_event_name   in varchar2 ,
                                      requestId in varchar2,
                                      requestorId  in varchar2,
                                      requestType in varchar2
                                      ) IS

x_return_status VARCHAR2(1);
l_api_version   NUMBER:=1.0;
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(4000);
l_parameter_list wf_parameter_list_t;
l_api_name      VARCHAR2(40):= 'okl_ssc_wf';

begin

-- pass the parameters to the event
wf_event.addparametertolist('SSCREQUESTORID'
                            ,requestorId
                            ,l_parameter_list);
wf_event.addparametertolist('SSCTASID'
                            ,requestId
                            ,l_parameter_list);

wf_event.addparametertolist('SSCTALTYPE'
                            ,requestType
                            ,l_parameter_list);


okl_wf_pvt.raise_event(p_api_version   =>            l_api_version
                      ,p_init_msg_list =>            'T'
                      ,x_return_status =>            x_return_status
                      ,x_msg_count     =>            x_msg_count
                      ,x_msg_data      =>            x_msg_data
                      ,p_event_name    =>            p_event_name
                      ,p_parameters    =>            l_parameter_list);

exception
  WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        ''
      );
end  raise_assets_return_event;

--Bug 6018784 start
-- Start of comments
-- Procedure Name  : raise_ser_num_update_event
-- Description     : Private procedure to handle asset serial number update event
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure raise_ser_num_update_event ( p_event_name  in varchar2 ,
                                      requestId   in varchar2,
                                      requestorId in varchar2,
                                      requestType in varchar2
                                      )
                                                   IS

x_return_status VARCHAR2(1);
l_api_version   NUMBER:=1.0;
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(4000);
l_parameter_list wf_parameter_list_t;

CURSOR assets_key_seq IS
SELECT OKLSSC_WFITEMKEY_S.nextval  key from dual;

assets_key_rec assets_key_seq%rowtype;
assets_key varchar2(100) ;

begin

OPEN assets_key_seq;
FETCH assets_key_seq INTO assets_key_rec;
assets_key := to_char( assets_key_rec.key);
CLOSE assets_key_seq;
-- pass the parameters to the event
wf_event.addparametertolist('SSCREQUESTORID'
                            ,requestorId
                            ,l_parameter_list);
wf_event.addparametertolist('SSCTASID'
                            ,requestId
                            ,l_parameter_list);
wf_event.addparametertolist('SSCTALTYPE'
                            ,requestType
                            ,l_parameter_list);

okl_wf_pvt.raise_event(p_api_version   =>            l_api_version
                      ,p_init_msg_list =>            'T'
                      ,x_return_status =>            x_return_status
                      ,x_msg_count     =>            x_msg_count
                      ,x_msg_data      =>            x_msg_data
                      ,p_event_name    =>            p_event_name
                      ,p_event_key     =>            assets_key
                      ,p_parameters    =>            l_parameter_list);

end  raise_ser_num_update_event;
--Bug 6018784 end

END okl_ssc_wf;

/
