--------------------------------------------------------
--  DDL for Package Body JTF_FM_REQUEST_GRP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_REQUEST_GRP_WF" AS
/* $Header: jtffmwfb.pls 115.5 2000/02/15 10:51:14 pkm ship     $*/
v_ItemType              VARCHAR2(30) := 'FULFILL3';
v_ItemKey               VARCHAR2(30) ;
v_ItemUserKey           VARCHAR2(80) := FND_GLOBAL.CONC_LOGIN_ID; --FND_GLOBAL.USER_ID;

l_party_id              NUMBER       := 10;
l_user_id               NUMBER       := 11;
l_order_id              NUMBER       := 0;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(1000);
l_return_status         VARCHAR2(10);
--
l_content_xml           VARCHAR2(1000);
l_request_id            NUMBER;
l_template_id           NUMBER;
outvar                  VARCHAR2(1000);

---------------------------------------------------------------------
-- PROCEDURE
--    StartFulfillProcess
--
-- PURPOSE
--    Start the fulfillment workflow process
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE StartFulfillProcess (
     l_api_version        IN NUMBER,
     l_commit             IN VARCHAR2,
     l_validation_level   IN NUMBER,
     l_content_xml        IN VARCHAR2,
     l_request_id         IN NUMBER,
     l_template_id        IN NUMBER,
     l_status	            OUT VARCHAR2,
     l_result             OUT VARCHAR2 )
IS

     x_orig_system_id     NUMBER;
     x_requester_username VARCHAR2(30);
     x_requester_disp_name VARCHAR2(30);
BEGIN
SELECT TO_CHAR(JTF_FM_WORKFLOW_S.nextval)
  INTO v_ItemKey
  FROM sys.dual;

SELECT orig_system_id
  INTO x_orig_system_id
  FROM wf_users
 WHERE name = ( SELECT user
		  FROM DUAL);

wf_engine.CreateProcess( ItemType => v_ItemType,
    ItemKey  => v_ItemKey,
    process  => 'SUB_REQ' );

 --
 -- Initialize workflow item attributes
 --
 wf_engine.SetItemAttrText (itemtype => v_ItemType,
         itemkey  => v_ItemKey,
         aname   => 'API_VERSION',
         avalue  =>  l_api_version);
 wf_engine.SetItemAttrText (itemtype => v_ItemType,
         itemkey  => v_ItemKey,
         aname   => 'COMMIT',
         avalue  =>  l_commit);
 wf_engine.SetItemAttrText (itemtype => v_ItemType,
         itemkey  => v_ItemKey,
         aname   => 'VALIDATION_LEVEL',
         avalue  =>  l_validation_level);
 wf_engine.SetItemAttrText (itemtype => v_ItemType,
         itemkey  => v_ItemKey,
         aname   => 'CONTENT_XML',
         avalue  =>  l_content_xml);
 wf_engine.SetItemAttrText (itemtype => v_ItemType,
         itemkey  => v_ItemKey,
         aname   => 'REQUEST_ID',
         avalue  =>  l_request_id);
 wf_engine.SetItemAttrText (itemtype => v_ItemType,
         itemkey  => v_ItemKey,
         aname   => 'TEMP_ID',
         avalue  =>  l_template_id);
 wf_directory.GetUserName (p_orig_system => 'PER',
         p_orig_system_id => x_orig_system_id,
         p_name => x_requester_username,
         p_display_name => x_requester_disp_name);

 wf_engine.SetItemAttrText (itemtype => v_ItemType,
         itemkey  => v_ItemKey,
         aname   => 'REQUESTER_USERNAME',
         avalue  =>  x_requester_username);

 wf_engine.StartProcess( itemtype => v_ItemType,
       itemkey  => v_ItemKey );

 wf_engine.ItemStatus(itemtype => v_ItemType,
                         itemkey  => v_ItemKey,
                         status => l_status,
                         result => l_result);

 -- DBMS_OUTPUT.PUT_LINE('Workflow: '||v_ItemType||' '||
 --                     v_ItemKey||' '||' '||
 --                     x_orig_system_id||' '||
 --                     x_requester_username||' '||
 --                     l_status||' '||l_result);

EXCEPTION
 WHEN OTHERS THEN
 WF_CORE.CONTEXT('JTF_FM_REQUEST_GRP_WF', 'StartFulfillProcess', 'SQL Error ' || sqlcode);
 RAISE;
END StartFulfillProcess;

---------------------------------------------------------------------
-- PROCEDURE
--    Submit_Request
--
-- PURPOSE
--    Calling JTF_FM_REQUEST_GRP.SUBMIT_REQUEST
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE submit_request (
    itemtype   IN VARCHAR2,
    itemkey    IN VARCHAR2,
    actid      IN NUMBER,
    funcmode   IN VARCHAR2,
    resultout  OUT VARCHAR2) IS

x_api_version      NUMBER;
x_commit           VARCHAR2(30);
x_validation_level NUMBER;
x_request_id       NUMBER;

BEGIN

IF (funcmode = 'RUN') THEN
  x_api_version := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'API_VERSION');
  x_commit := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'COMMIT');
  x_validation_level := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'VALIDATION_LEVEL');
  x_request_id := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'REQUEST_ID');

apps.JTF_FM_REQUEST_GRP.Submit_Request
(    p_api_version => x_api_version,
     p_commit => x_commit,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data,
     p_party_id => l_party_id,
     p_user_id => l_user_id,
     p_server_id => 1,
     p_content_xml => 'TEST',
     p_request_id => x_request_id
);
END IF;

    IF l_return_status = 'S' THEN
       resultout := 'COMPLETE:Y';
    ELSE
       resultout := 'COMPLETE:N';
    END IF;
   RETURN;

EXCEPTION
 WHEN OTHERS THEN
 WF_CORE.CONTEXT('JTF_FM_REQUEST_GRP_WF', 'Submit_Request', 'SQL Error ' || sqlcode);
 RAISE;
END Submit_Request;

---------------------------------------------------------------------
-- PROCEDURE
--    Resubmit_Request
--
-- PURPOSE
--    Calling JTF_FM_REQUEST_GRP.RESUBMIT_REQUEST
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE resubmit_request (
  itemtype  IN VARCHAR2,
  itemkey   IN VARCHAR2,
  actid     IN NUMBER,
  funcmode  IN VARCHAR2,
  resultout OUT VARCHAR2) IS

x_api_version      NUMBER;
x_commit           VARCHAR2(30);
x_validation_level NUMBER;
x_request_id       NUMBER;
l_party_id    number   := 101;
l_user_id     number   := 111;


BEGIN
IF (funcmode = 'RUN') THEN
  x_api_version := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'API_VERSION');
  x_commit := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'COMMIT');
  x_validation_level := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'VALIDATION_LEVEL');
  x_request_id := wf_engine.GetItemAttrNumber(
     itemtype => v_itemtype,
     itemkey  => v_itemkey,
     aname   => 'REQUEST_ID');

apps.JTF_FM_REQUEST_GRP.RESUBMIT_REQUEST
(
  p_api_version => x_api_version,
  p_commit => x_commit,
  p_validation_level => x_validation_level,
  x_return_status => l_return_status,
  x_msg_count => l_msg_count,
  x_msg_data => l_msg_data,
  p_request_id => x_request_id
    );
END IF;

IF l_return_status = 'S' THEN
   resultout := 'COMPLETE:Y';
ELSE
   resultout := 'COMPLETE:N';
END IF;
RETURN;

EXCEPTION
 WHEN OTHERS THEN
 WF_CORE.CONTEXT('JTF_FM_REQUEST_GRP_WF', 'Resubmit_Request', 'SQL Error ' || sqlcode);
 RAISE;
END Resubmit_Request;

END jtf_fm_request_grp_wf;


/
