--------------------------------------------------------
--  DDL for Package Body PO_REQAPPROVAL_LAUNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQAPPROVAL_LAUNCH" AS
/* $Header: POXWPA5B.pls 120.5.12010000.2 2012/11/05 10:29:14 jozhong ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');


 /*=======================================================================+
 | FILENAME
 |   xxx.sql
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_REQAPPROVAL_LAUNCH
 |
 | NOTES        Ben Chihaoui Created 6/15/97
 | MODIFIED    (MM/DD/YY)
 *=======================================================================*/

-- The following are local/Private procedure that support the workflow APIs:

PROCEDURE LaunchCreatePOWF(itemtype in varchar2, itemkey in varchar2);
--

PROCEDURE CreateWFInstance(  ItemType                  varchar2,
                             ItemKey                   varchar2,
                             p_requisition_header_id   number,
                             p_emergency_po_num        varchar2);

/****************************************************************************/


procedure Launch_CreatePO_WF(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress  varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

--  x_progress := 'PO_REQAPPROVAL_LAUNCH.Launch_CreatePO_WF: 01';
--  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  LaunchCreatePOWF(itemtype, itemkey);

  --
    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_LAUNCH' , 'Launch_CreatePO_WF', itemtype, itemkey,x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_LAUNCH.LAUNCH_CREATEPO_WF');
    raise;

END Launch_CreatePO_WF;


/*****************************************************************************
* The following are local/Private procedure that support the workflow APIs:
*****************************************************************************/

PROCEDURE LaunchCreatePOWF(itemtype in varchar2, itemkey in varchar2) is

l_requisition_header_id  NUMBER;
l_emergency_po_num VARCHAR2(20);

x_progress  varchar2(100);

BEGIN

  x_progress :=  'PO_REQAPPROVAL_LAUNCH.LaunchCreatePOWF:01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  l_requisition_header_id :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  /* This is used for integration with Web Requisitions. Web requisition has
  ** a feature that allows users to get PO number, before the PO is created
  ** This can happen in emergency cases, where the vendor/provider of the
  ** service will not perform the service unless they get a PO number. The
  ** user will then get a PO#, create the requisition and submit it for
  ** approval. If the requisition is approved and we get to this point, then
  ** we pass this PO NUMBER to the CREATE_PO workflow, which will create a
  ** STANDARD PO using this PO NUMBER as SEGMENT1.
  */
  l_emergency_po_num := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMERGENCY_PO_NUMBER');


     CreateWFInstance(  ItemType,
                        ItemKey,
                        l_requisition_header_id,
                        l_emergency_po_num);


EXCEPTION

     WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_LAUNCH','LaunchCreatePOWF',
                              x_progress);
        raise;


END LaunchCreatePOWF;


--
PROCEDURE CreateWFInstance(  ItemType                  varchar2,
                             ItemKey                   varchar2,
                             p_requisition_header_id   number,
                             p_emergency_po_num        varchar2) is

x_progress              varchar2(200);

l_ItemType varchar2(8);
l_ItemKey  varchar2(80);
l_workflow_process varchar2(30);
l_dummy  varchar2(38);
l_orgid number;
l_interface_source  varchar2(30);

l_user_id number;
l_resp_id number;
l_appl_id number;

--bug 14807370:Store the session context before wf changed.
l_session_user_id number;
l_session_resp_id   number;
l_session_resp_appl_id   number;
l_session_org_id   number;

cursor C1 is
  select WF_CREATEDOC_ITEMTYPE,WF_CREATEDOC_PROCESS
  from po_document_types
  where DOCUMENT_TYPE_CODE= 'REQUISITION'
  and   DOCUMENT_SUBTYPE  = 'PURCHASE';

BEGIN


/* Get the org context */
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>

  END IF;

  l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'USER_ID');

  l_resp_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONSIBILITY_ID');

  l_appl_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPLICATION_ID');

--bug 14807370:Store the session context before wf changed.

l_session_user_id := fnd_global.user_id;
l_session_resp_id := fnd_global.resp_id;
l_session_resp_appl_id := fnd_global.resp_appl_id;
l_session_org_id := fnd_global.org_id;


  /* Since the call may be started from background engine (new seesion),
   * need to ensure the fnd context is correct
   */

  if (l_user_id is not null and
      l_resp_id is not null and
      l_appl_id is not null )then

    -- Bug 4290541
    -- replaced apps init call with set doc mgr context

    PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>
  end if;


  x_progress :=  'PO_REQAPPROVAL_LAUNCH.CreateWFInstance:01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* Create the ItemKey: Use the PO workflow sequence */
  select to_char(PO_WF_ITEMKEY_S.nextval) into l_dummy from sys.dual;


  OPEN C1;
  FETCH C1 into l_ItemType, l_workflow_process;

  IF C1%NOTFOUND THEN
    close C1;
    raise  NO_DATA_FOUND;
  END IF;

  CLOSE C1;
-- l_ItemType:= 'CREATEPO';
-- l_workflow_process := 'OVERALL_AUTOCREATE_PROCESS';

  l_ItemKey := to_char(p_requisition_header_id) || '-' || l_dummy;



  x_progress :=  'PO_REQAPPROVAL_LAUNCH.CreateWFInstance:02 ItemType=' ||
                 l_ItemType || ' ItemKey=' || l_ItemKey;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* Call the procedure that creates the WF instance and starts the process */

  /* gtummala. 8/29/97.
   * We also need to pass in the interface_source_code into the
   * start_wf_process for the create document process.
   */

  l_interface_source :=  wf_engine.GetItemAttrNumber
					(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

  PO_AUTOCREATE_DOC.start_WF_process(l_ItemType,
                                     l_ItemKey,
                                     l_workflow_process,
                                     p_requisition_header_id,
                                     p_emergency_po_num,
				     l_interface_source,
                                     l_orgid);

--bug 14807370:after invoking workflow, set back the original session context using
fnd_global.apps_initialize(l_session_user_id, l_session_resp_id , l_session_resp_appl_id);
PO_MOAC_UTILS_PVT.set_org_context(l_session_org_id) ;


EXCEPTION

     WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_LAUNCH','CreateWFInstance',
                              x_progress);
        raise;


END CreateWFInstance;

-------------------------------------------------------------------------------
--Start of Comments
--Name: POREQ_SELECTOR
--Pre-reqs:
--  None.
--Modifies:
-- Application user id
-- Application responsibility id
-- Application application id
--Locks:
--  None.
--Function:
--  This procedure sets the correct application context when a process is
--  picked up by the workflow background engine. When called in
--  TEST_CTX mode it compares workflow attribute org id with the current
--  org id and workflow attributes user id, responsibility id and
--  application id with their corresponding profile values. It returns TRUE
--  if these values match and FALSE otherwise. When called in SET_CTX mode
--  it sets the correct apps context based on workflow parameters.
--Parameters:
--IN:
--p_itemtype
--  Specifies the itemtype of the workflow process
--p_itemkey
--  Specifies the itemkey of the workflow process
--p_actid
--  activity id passed by the workflow
--p_funcmode
--  Input values can be TEST_CTX or SET_CTX (RUN not implemented)
--  TEST_CTX to test if current context is correct
--  SET_CTX to set the correct context if current context is wrong
--IN OUT:
--p_x_result
--  For TEST_CTX a TRUE value means that the context is correct and
--  SET_CTX need not be called. A FALSE value means that current context
--  is incorrect and SET_CTX need to set correct context
--Testing:
--  There is not script to test this procedure but the correct functioning
--  may be tested by verifying from the debug_message in table po_wf_debug
--  that if at any time the workflow process gets started with a wrong
--  context then the selector is called in TEST_CTX and SET_CTX modes and
--  correct context is set.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE POREQ_SELECTOR ( -- Added as a part of bug 3540107
  p_itemtype   IN VARCHAR2,
  p_itemkey    IN VARCHAR2,
  p_actid      IN NUMBER,
  p_funcmode   IN VARCHAR2,
  p_x_result   IN OUT NOCOPY VARCHAR2
) IS

  -- Context setting revamp <declare variables start>
  l_session_user_id               NUMBER;
  l_session_resp_id               NUMBER;
  l_responder_id		  NUMBER;
  l_user_id_to_set 		  NUMBER;
  l_resp_id_to_set                NUMBER;
  l_appl_id_to_set                NUMBER;
  l_progress 			  VARCHAR2(1000);
  l_preserved_ctx                 VARCHAR2(5):= 'TRUE';
  l_org_id 			  NUMBER;
  l_is_supplier_context           VARCHAR2(10); -- Bug 6144768
  -- Context setting revamp <declare variables end>

BEGIN
   --Context setting revamp <start>

-- <debug start>
   IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(
      			itemtype   => p_itemtype,
                        itemkey    => p_itemkey,
                        x_progress => 'POREQ_SELECTOR called with mode: '
			||p_funcmode||' itemtype: '||p_itemtype
			||' itemkey: '||p_itemkey);

   END IF;
-- <debug end>


   l_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber (
    					itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname    => 'ORG_ID');
   -- Bug 6144768
   l_is_supplier_context := PO_WF_UTIL_PKG.GetItemAttrText(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'IS_SUPPLIER_CONTEXT');
   --Bug 5389914
   --Fnd_Profile.Get('USER_ID',l_session_user_id);
   --Fnd_Profile.Get('RESP_ID',l_session_resp_id);
   l_session_user_id := fnd_global.user_id;
   l_session_resp_id := fnd_global.resp_id;

    IF (l_session_user_id = -1) THEN
        l_session_user_id := NULL;
    END IF;

    IF (l_session_resp_id = -1) THEN
        l_session_resp_id := NULL;
    END IF;

   l_responder_id :=  PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'RESPONDER_USER_ID');

--<debug start>
       l_progress :='010 selector fn - sess_user_id:'||l_session_user_id
       		    ||' ses_resp_id '||l_session_resp_id||' responder id '
		    ||l_responder_id;

       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
       END IF;
--<debug end>



   IF (p_funcmode = 'TEST_CTX') THEN
      -- Bug 6144768
      IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.insert_debug(itemtype   => p_itemtype,
                                    itemkey    => p_itemkey,
                                    x_progress => 'POREQ_SELECTOR: inside Test Ctx ');
       PO_WF_DEBUG_PKG.insert_debug(itemtype   => p_itemtype,
                                    itemkey    => p_itemkey,
                                    x_progress => 'l_is_supplier_context: ' || l_is_supplier_context);
      END IF;

     --<Bug 6144768 Begin>
     -- When Supplier responds from iSP then the responder should show
     -- as supplier and also supplier acknowledgement notifications
     -- should be available in the To-Do Notification full list.
     IF l_is_supplier_context = 'Y' THEN
       p_x_result := 'TRUE';
       RETURN;
     END IF;
     --<Bug 6144768 End>
   -- we cannot afford to run the wf without the session user, hence
   -- always set the ctx if session user id is null.
      if (l_session_user_id is null) then
         p_x_result := 'NOTSET';
	 return;
      else
         if (l_responder_id is not null) then
	    if (l_responder_id <> l_session_user_id) then
	        p_x_result := 'FALSE';
		return;
            else
	       if (l_session_resp_id is Null) then
	          p_x_result := 'NOTSET';
		  return;
               else
	       -- bug 5333226 : if the selector fn is called from a background ps/
	       -- notif mailer then force the session to use preparer's or responder
	       -- context. This is required since the mailer/bckgrnd ps carries the
	       -- context from the last wf processed and hence even if the context values
	       -- are present, they might not be correct.

		  if (wf_engine.preserved_context = TRUE) then
	             p_x_result := 'TRUE';
		  else
		     p_x_result:= 'NOTSET';
		  end if;

	       -- introduce an org context setting call here-
	       -- required in the case when the right resonder makes a response
	       -- from a NON-PO RESP.
		  IF l_org_id is NOT NULL THEN
       		     PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;
    		  END IF;

		  return;
               end if;
	    end if;
	 else
            -- always setting the ctx at the start of the wf
	    p_x_result := 'NOTSET';
	    return;
	 end if;
      end if;  -- l_session_user_id is null

   ELSIF (p_funcmode = 'SET_CTX') THEN
   if l_responder_id is not null then
      l_user_id_to_set := l_responder_id;
      l_resp_id_to_set :=wf_engine.GetItemAttrNumber (
        				     itemtype  => p_itemtype,
                             		      itemkey  => p_itemkey,
                                                aname  => 'RESPONDER_RESP_ID');
      l_appl_id_to_set :=wf_engine.GetItemAttrNumber (
        				     itemtype  => p_itemtype,
                             		      itemkey  => p_itemkey,
                                                aname  => 'RESPONDER_APPL_ID');
--<debug start>
      l_progress := '020 selection fn responder id not null';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
       END IF;
--<debug end>

--<debug start>
       l_progress :='030 selector fn : setting user id :'||l_responder_id
       		    ||' resp id '||l_resp_id_to_set||' l_appl id '||l_appl_id_to_set;
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
       END IF;
--<debug end>

   else
      l_user_id_to_set := wf_engine.GetItemAttrNumber (
        				     itemtype  => p_itemtype,
                             		      itemkey  => p_itemkey,
                                                aname  => 'USER_ID');
      l_resp_id_to_set :=wf_engine.GetItemAttrNumber (
        				     itemtype  => p_itemtype,
                             		      itemkey  => p_itemkey,
                                                aname  => 'RESPONSIBILITY_ID');
      l_appl_id_to_set :=wf_engine.GetItemAttrNumber (
        				     itemtype  => p_itemtype,
                             		      itemkey  => p_itemkey,
                                                aname  => 'APPLICATION_ID');
--<debug start>
      l_progress := '040 selector fn responder id null';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
       END IF;
--<debug end>

--<debug start>
      l_progress := '050 selector fn : set user '||l_user_id_to_set||' resp id '
      		    ||l_resp_id_to_set||' appl id '||l_appl_id_to_set;
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
       END IF;
--<debug end>
   end if;

   fnd_global.apps_initialize(l_user_id_to_set, l_resp_id_to_set,l_appl_id_to_set);

   -- obvious place to make such a call, since we are using an apps_initialize,
   -- this is required since the responsibility might have a different OU attached
   -- than what is required.

   IF l_org_id is NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;
   END IF;


   -- Need to set the sub ledger security also, requirement
   -- comes from bug 3571038
   igi_sls_context_pkg.set_sls_context;

   END IF;
-- Context setting revamp <end>

EXCEPTION

  WHEN OTHERS THEN

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype   => p_itemtype,
                                   itemkey    => p_itemkey,
                                   x_progress => 'Exception in Selector');
    END IF;

    WF_CORE.context('PO_REQAPPROVAL_LAUNCH',
                    'POREQ_SELECTOR',
                    p_itemtype,
                    p_itemkey,
                    p_actid,
                    p_funcmode);
    RAISE;

END POREQ_SELECTOR;

end PO_REQAPPROVAL_LAUNCH;

/
