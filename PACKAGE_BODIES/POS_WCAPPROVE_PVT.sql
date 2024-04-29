--------------------------------------------------------
--  DDL for Package Body POS_WCAPPROVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_WCAPPROVE_PVT" AS
/* $Header: POSVWCAB.pls 120.19.12010000.19 2014/07/22 11:50:02 nchundur ship $ */
--
-- Purpose: APIs called from the receiving processor to approve WCR document.
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- pparthas    02/15/05 Created Package
--
--

G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'POS_WCAPPROVE_PVT';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POSVWCAS.pls';
g_module_prefix CONSTANT VARCHAR2(50) := 'pos.plsql.' || g_pkg_name || '.';

g_asn_debug         VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

procedure debug_log(p_level in number,
                    p_api_name in varchar2,
                    p_msg in varchar2);

procedure debug_log(p_level in number,
                    p_api_name in varchar2,
                    p_msg in varchar2)
IS
l_module varchar2(2000);
BEGIN
/* Taken from Package FND_LOG
   LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
   LEVEL_ERROR      CONSTANT NUMBER  := 5;
   LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
   LEVEL_EVENT      CONSTANT NUMBER  := 3;
   LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
   LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
*/

l_module := 'pos.plsql.pos_wcapprove_pvt.'||p_api_name;
        IF(g_asn_debug = 'Y')THEN
        IF ( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.string(LOG_LEVEL => p_level,
                         MODULE => l_module,
                         MESSAGE => p_msg);
        END IF;

    END IF;
END debug_log;

procedure CloseOldNotif(p_itemtype varchar2,
			p_itemkey varchar2);

procedure UpdateWorkflowInfo
(
p_itemtype        in varchar2,
p_itemkey         in varchar2,
p_shipment_header_id in varchar2);

PROCEDURE Upd_ActionHistory_Submit (p_object_id            IN NUMBER,
                                 p_object_type_code     IN VARCHAR2,
                                 p_employee_id      IN NUMBER,
                                 p_sequence_num         IN NUMBER,
                                 p_action_code          IN VARCHAR2,
                                 p_user_id              IN NUMBER,
                                 p_login_id             IN NUMBER);

/* Start_Wf_Process
**  Starts a Document Approval workflow process.
** Parameters:
** IN:
** ItemType
**  Item Type of the workflow to be started;
** ItemKey
**  Item Key for starting the workflow; if NULL, we will construct a new key
**  from the sequence
** DocumentID
** Shipment_header_id from rcv_shipment_header for the Work Confirmation
** Document.
**PreparerID
**   buyer who created the complex work PO
*/


PROCEDURE Start_WF_Process ( p_itemtype   IN              VARCHAR2,
                             p_itemkey    IN OUT NOCOPY   VARCHAR2,
			     p_workflow_process IN        VARCHAR2,
                             p_work_confirmation_id IN    NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2) IS
l_progress varchar2(300);
l_seq_for_item_key varchar2(6) :=null;
l_itemkey varchar2(60);
l_wf_created number;
l_work_confirmation_number varchar2(30);
l_api_name varchar2(50) := p_itemkey || ' start_wf_process';
l_responsibility_id     number;
l_user_id               number;
l_application_id        number;
l_orgid	number;
l_po_header_id	number;

begin
	l_progress := 'POS_WCAPPROVE_PVT.start_wf_progress: 01';

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'Enter  Start_wf_process ' || l_progress);
        END IF;

	If (p_itemkey is NULL) then

		select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
		into l_seq_for_item_key
		from sys.dual;

		l_itemkey := to_char(p_work_confirmation_id) || '-' ||
					 l_seq_for_item_key;
	else
		l_itemkey := p_itemkey;
	end if;

	/* Check to see if process has already been created.
	 * If so, dont create again.
	*/

	l_progress := 'POS_WCAPPROVE_PVT.start_wf_process: 02';
	If ((p_itemtype is not null) and (l_itemkey is not null) and
		(p_work_confirmation_id is not null)) then --{

		begin
			select count(*)
			into   l_wf_created
			from   wf_items
			where  item_type = p_itemtype
			and    item_key  = l_itemkey;

		exception
		   when others then
			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception to check process '
				 || l_progress);
			END IF;
			raise;
		end;


	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_wf_created ' || l_wf_created);
	END IF;

	if l_wf_created = 0 then
		wf_engine.CreateProcess(
				 ItemType => p_itemtype,
                                 ItemKey  => l_itemkey,
                                 process  => p_workflow_process );
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Workflow process created ' );
		END IF;
       end if;


	/* Initialize workflow item attributes */
	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Initialize workflow attributes ' );
	END IF;

	wf_engine.SetItemAttrNumber (   itemtype   => p_itemtype,
                                        itemkey    => l_itemkey,
                                        aname      => 'WORK_CONFIRMATION_ID',
                                        avalue     => p_work_confirmation_id);


	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'p_work_confirmation_id '||p_work_confirmation_id );
	END IF;

	select shipment_num
	into l_work_confirmation_number
	from rcv_shipment_headers
	where shipment_header_id = p_work_confirmation_id
	and nvl(asn_type,'STD') = 'WC';

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_work_confirmation_number '
				||l_work_confirmation_number );

	END IF;

	wf_engine.SetItemAttrText (   itemtype   => p_itemtype,
                                      itemkey    => l_itemkey,
                                      aname      => 'WORK_CONFIRMATION_NUMBER',
                                      avalue     => l_work_confirmation_number);


	l_progress := 'POS_WCAPPROVE_PVT.start_wf_process: 03.';
        select max(po_header_id)
        into l_po_header_id
        from rcv_shipment_lines
        where shipment_header_id = p_work_confirmation_id;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_po_header_id ' || l_po_header_id);        END IF;

	wf_engine.SetItemAttrNumber (   itemtype   => p_itemtype,
                                        itemkey    => l_itemkey,
                                        aname      => 'PO_DOCUMENT_ID',
                                        avalue     => l_po_header_id);

	POS_WCAPPROVE_PVT.get_multiorg_context(l_po_header_id,l_orgid);
	IF l_orgid is NOT NULL THEN

        PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

          /* Set the Org_id item attribute. We will use it to get
	   * the context for every activity
	  */
          wf_engine.SetItemAttrNumber (   itemtype        => p_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'ORG_ID',
                                          avalue          => l_orgid);

        END IF;

       if (l_wf_created = 0) then
        FND_PROFILE.GET('USER_ID', l_user_id);
        FND_PROFILE.GET('RESP_ID', l_responsibility_id);
        FND_PROFILE.GET('RESP_APPL_ID', l_application_id);
        /* l_application_id := 201; */
        --
        wf_engine.SetItemAttrNumber ( itemtype        => p_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'USER_ID',
                                      avalue          =>  l_user_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => p_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'APPLICATION_ID',
                                      avalue          =>  l_application_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => p_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'RESPONSIBILITY_ID',
                                      avalue          =>  l_responsibility_id);

        /* Set the context for the doc manager */
        fnd_global.APPS_INITIALIZE (l_user_id, l_responsibility_id, l_application_id);
       end if;

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Start process ' );
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'itemtype '||p_itemtype );
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_itemkey '||l_itemkey );
	END IF;
	wf_engine.StartProcess(itemtype        => p_itemtype,
                               itemkey         => l_itemkey );

	end if; --} itemtype, itemkey and work_confirmation_id not null

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Leave start_wf_process ' );
	End if;
Exception
	when others then
	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Start_wf_process ' || l_progress);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	raise;
End Start_wf_process;

/*
** Close_old_notifications
** IN
**   itemtype  --   itemkey  --   actid   --   funcmode
** OUT
**   Resultout
**
** Update the old notifications to closed status for this document.
*/
procedure Close_old_notif
(
p_itemtype        in varchar2,
p_itemkey         in varchar2,
p_actid           in number,
p_funcmode        in varchar2,
x_resultout       out NOCOPY varchar2 ) IS

l_work_confirmation_id  Number;
l_wf_itemkey  Varchar2(280);
l_progress     varchar2(300);

cursor ship_header_cursor(p_header_id number) is
select wf_item_key
from rcv_shipment_headers
where shipment_header_id = p_header_id;

l_api_name varchar2(50) := p_itemkey || ' close_old_notif';

begin

	l_progress := 'POS_WCAPPROVE_PVT.close_old_notifications: 01';

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter close_old_notif ' || l_progress);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'p_itemtype ' || p_itemtype);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'p_itemkey ' || p_itemkey);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
		x_resultout := wf_engine.eng_null;
		return;
	end if;


	l_work_confirmation_id :=
			  wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_work_confirmation_id ' ||
			l_work_confirmation_id);
        END IF;
	/* If the document has been previously submitted to workflow,
	 * and did not complete because of some error then notifications
	 * may have been  issued to users. We need to remove those
	 * notifications once we submit the document to a new workflow run,
	 * so that the user is not confused.
	*/

	open ship_header_cursor(l_work_confirmation_id);
	fetch ship_header_cursor into l_wf_itemkey;
	close ship_header_cursor;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_wf_itemkey ' || l_wf_itemkey);
        END IF;

	if (l_wf_itemkey is not null) then

		CloseOldNotif(p_itemtype,l_wf_itemkey);

	end if;

	x_resultout := wf_engine.eng_completed ;

	l_progress := 'POS_WCAPPROVE_PVT.close_old_notif: 02.';

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Leave close_old_notif ' || l_progress);
        END IF;

exception
	when others then
	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in close_old_notif ' || l_progress);
        END IF;
	raise;
end Close_old_notif;

procedure Set_Startup_Values(   p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2    ) is
l_work_confirmation_id number;
l_work_confirmation_number varchar2(30);
l_po_number   varchar2(30);
l_po_header_id number;
l_po_preparer_id number;
l_wc_preparer_id number;
l_wc_preparer_name varchar2(100);
l_wc_preparer_display_name varchar2(240);
l_po_preparer_name varchar2(100);
l_po_preparer_display_name varchar2(240);
l_progress varchar2(200);
l_api_name varchar2(50) := p_itemkey || ' set_startup_Values';
l_view_wc_lines_detail_url varchar2(1000);
l_respond_to_wc_url varchar2(1000);
l_employee_id NUMBER;

begin
	l_progress := 'POS_WCAPPROVE_PVT.set_startup_values: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in set_startup_values ' || l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
		x_resultout := wf_engine.eng_null;
		return;
	end if;

	l_work_confirmation_id :=
		wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');


        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_work_confirmation_id ' ||
			l_work_confirmation_id);
        END IF;

	l_progress := 'POS_WCAPPROVE_PVT.set_startup_values: 02.';
	select created_by
	into l_wc_preparer_id
	from rcv_shipment_headers
	where shipment_header_id= l_work_confirmation_id;


	select employee_id
	into l_employee_id
	from fnd_user
	where user_id = l_wc_preparer_id;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_wc_preparer_id ' ||
			l_wc_preparer_id);
        END IF;

	wf_engine.SetItemAttrNumber (   itemtype        => p_itemtype,
                                        itemkey         => p_itemkey,
                                        aname           => 'WC_PREPARER_ID',
                                        avalue          => l_wc_preparer_id);

	l_progress := 'POS_WCAPPROVE_PVT.set_startup_values: 03.';
	if (l_employee_id is not null) then
	get_user_name('PER',l_employee_id, l_wc_preparer_name,
			l_wc_preparer_display_name);
	else
	get_user_name('FND_USR',l_wc_preparer_id, l_wc_preparer_name,
			l_wc_preparer_display_name);
	end if;


        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_wc_preparer_name ' || l_wc_preparer_name);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_wc_preparer_display_name ' ||
			 l_wc_preparer_display_name);
        END IF;
	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'WC_PREPARER_NAME' ,
                              avalue     => l_wc_preparer_name);

	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'WC_PREPARER_DISPLAY_NAME' ,
                              avalue     => l_wc_preparer_display_name);

	l_progress := 'POS_WCAPPROVE_PVT.set_startup_values: 04.';
	l_po_header_id :=
			  wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'PO_DOCUMENT_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_po_header_id ' || l_po_header_id);
        END IF;

	/* We need doc_status only if the document is rejected.
	 * This is to show the status of the lines in the
	 * notification screen. So set the default to NOTREJECTED.
	 * We set it to REJECTED in reject_doc.
	*/
	wf_engine.SetItemAttrText (   itemtype   => p_itemtype,
                                      itemkey    => p_itemkey,
                                      aname      => 'DOC_STATUS',
                                      avalue     => 'NOTREJECTED');

	l_progress := 'POS_WCAPPROVE_PVT.set_startup_values: 05.';
	select poh.segment1,
	       poh.agent_id
	into l_po_number,
	     l_po_preparer_id
	from po_headers_all poh
	where po_header_id = l_po_header_id;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_po_number ' || l_po_number);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_preparer_id ' || l_po_preparer_id);
        END IF;

	wf_engine.SetItemAttrNumber (   itemtype        => p_itemtype,
                                        itemkey         => p_itemkey,
                                        aname           => 'PO_PREPARER_ID',
                                        avalue          => l_po_preparer_id);

	l_progress := 'POS_WCAPPROVE_PVT.set_startup_values: 06.';
	get_user_name('PER',l_po_preparer_id, l_po_preparer_name,
			l_po_preparer_display_name);

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_po_preparer_name ' || l_po_preparer_name);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_po_preparer_display_name ' ||
			 l_po_preparer_display_name);
        END IF;
	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'PO_PREPARER_NAME' ,
                              avalue     => l_po_preparer_name);

	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'PO_PREPARER_DISPLAY_NAME' ,
                              avalue     => l_po_preparer_display_name);

	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'AME_TRANSACTION_TYPE' ,
                              avalue     => 'WCAPPROVE');

	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'DEFAULT_APPROVER' ,
                              avalue     => 'NONE');

	/* Since we are starting a fresh one, we need to clear the
	 * transaction approval status state. This happens only when
	 * the document is sent through the workflow for the first time
	 * or when the document is rejected and then sent again.
	*/

	ame_api2.clearAllApprovals( applicationIdIn  => 201,
                                     transactionIdIn => l_work_confirmation_id,
                                     transactionTypeIn => 'WCAPPROVE'
                                   );

	l_work_confirmation_number :=
				wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_NUMBER');


	-- bug 10012891 - encoding value of work confirmation number as per http standards
	l_view_wc_lines_detail_url :=
		'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pos/wc/webui/WcDetailsPG' || '&' ||
                            --'WcStatus=PENDING APPROVAL' || '&' ||
                            'PoHeaderId=' || to_char(l_po_header_id) || '&' ||
                            'WcHeaderId=' || to_char(l_work_confirmation_id) || '&' ||
                            'WcNum=' || (wfa_html.encode_url(l_work_confirmation_number)) || '&' ||
                            --'ReadOnly=Y'  || '&' ||
                            'addBreadCrumb=Y';

	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'VIEW_WC_LINES_DETAIL_URL' ,
                              avalue     => l_view_wc_lines_detail_url);

	-- bug 10012891 - encoding value of work confirmation number as per http standards
	l_respond_to_wc_url :=
                            'JSP:/OA_HTML/OA.jsp?OAFunc=POS_WC_RESPOND_NTFN' || '&' ||
			                      'SrcPage=DetailsInternalPG' || '&' ||
                            'WcStatus=PENDING APPROVAL' || '&' ||
                            'PoHeaderId=' || to_char(l_po_header_id) || '&' ||
                            'WcHeaderId=' || to_char(l_work_confirmation_id) || '&' ||
                            'WcNum=' || (wfa_html.encode_url(l_work_confirmation_number)) || '&' ||
                            'addBreadCrumb=Y';

	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'RESPOND_TO_WC_URL' ,
                              avalue     => l_respond_to_wc_url);

	x_resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

	l_progress := 'POS_WCAPPROVE_PVT.set_startup_values: 06.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Leave set_startup_values '
			|| l_progress);
        END IF;
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in set_startup_values '
			|| l_progress);
        END IF;
        raise;
end set_startup_values;


procedure update_workflow_info( p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2) is
l_shipment_header_id number;
l_progress varchar2(300);
l_api_name varchar2(50) := p_itemkey || ' update_workflow_info';
begin

	l_progress := 'POS_WCAPPROVE_PVT.update_workflow_info: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in update_workflow_info ' || l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
	      x_resultout := wf_engine.eng_null;
	      return;
	 end if;


	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

	l_progress := 'POS_WCAPPROVE_PVT.update_workflow_info: 02.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_shipment_header_id ' || l_shipment_header_id);
        END IF;

	UpdateWorkflowInfo(p_itemtype,p_itemkey,l_shipment_header_id);

	x_resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

	l_progress := 'POS_WCAPPROVE_PVT.update_workflow_info: 02.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Leave update_workflow_info ' || l_progress);
        END IF;

exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in update_workflow_info '
			|| l_progress);
        END IF;
        raise;
end update_workflow_info;

procedure Get_WC_Attributes( p_itemtype        in varchar2,
                             p_itemkey         in varchar2,
                             p_actid           in number,
                             p_funcmode        in varchar2,
                             x_resultout       out NOCOPY varchar2)is

cursor get_attachments(l_shipment_header_id number) is
select pk1_value
from fnd_attached_documents
where entity_name='RCV_LINES'
and pk1_value in (select shipment_line_id
		  from rcv_shipment_lines
		  where shipment_header_id=l_shipment_header_id);

l_shipment_header_id number;
l_shipment_line_id number;
l_document_id number;
l_attach_count number := 0;
l_attachment_id number;
l_progress varchar2(300);
l_api_name varchar2(50) := p_itemkey || ' get_wc_attributes';
begin
	l_progress := 'POS_WCAPPROVE_PVT.get_wc_attributes: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in get_wc_attributes '
			|| l_progress);
	end if;

	if (p_funcmode <> wf_engine.eng_run) then
	      x_resultout := wf_engine.eng_null;
	      return;
	 end if;


	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_shipment_header_id '|| l_shipment_header_id);
	end if;

	/* See if atleast one shipment have  attachments*/

/*
	l_progress := 'POS_WCAPPROVE_PVT.get_wc_attributes: 02.';
	select count(*)
	into l_attach_count
	from fnd_attached_documents
	where entity_name =' RCV_LINES'
	and pk1_value in (select shipment_line_id
			  from rcv_shipment_lines
			  where shipment_header_id=l_shipment_header_id);

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_attach_count '||
			l_attach_count);
	end if;


	If (l_attach_count > 0) then--{
	   open get_attachments(l_shipment_header_id);

	   --l_document_id= 'FND:entity=RCV_LINES';
	   loop
		fetch get_attachments into l_shipment_line_id;
		exit when get_attachments%notfound;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_shipment_line_id '||
				l_shipment_line_id);
		end if;


	   end loop;
	   If get_attachments%isopen then
		   close get_attachments;
	   end if;
	end if;--}
*/
	x_resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Get_WC_Attributes '
			|| l_progress);
        END IF;
        raise;
end Get_WC_Attributes;


/* Insert a submit action  row in po_action_history to signal the
 * submisinon of the document for Approval. Also insert an
 * additional row with a NULL ACTION_CODE to simulate a
 * forward-to. We need to do this for each shipment line in this
 * document.
*/
procedure Ins_actionhist_submit(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2)is
l_progress varchar2(200);
l_shipment_header_id number;
l_shipment_line_id number;
l_wc_preparer_id number;
l_sequence_num number;
l_action_code po_action_history.object_type_code%type;
l_api_name varchar2(50) := p_itemkey || ' ins_actionhist_submit';
l_supplier_id number;
l_employee_id number;

/*
cursor get_shipment_lines(l_shipment_header_id number) is
select shipment_line_id
from rcv_shipment_lines
where shipment_header_id=l_shipment_header_id;
*/

cursor action_hist_cursor (l_shipment_header_id number) is
select max(sequence_num)
from po_action_history
where object_id=l_shipment_header_id
and object_type_code = 'WC';

cursor action_hist_code_cursor(l_shipment_header_id number,l_seq_num number) is
select action_code
from po_action_history
where object_id = l_shipment_header_id
and object_type_code='WC'
and sequence_num = l_seq_num;
BEGIN

	l_progress := 'POS_WCAPPROVE_PVT.Ins_Actionhist_submit: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in Ins_Actionhist_submit '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
	      x_resultout := wf_engine.eng_null;
	      return;
	 end if;

	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

        SELECT CREATED_BY into l_supplier_id FROM RCV_SHIPMENT_HEADERS RSH where RSH.SHIPMENT_HEADER_ID =  l_shipment_header_id and ASN_TYPE = 'WC';
        SELECT EMPLOYEE_ID into l_employee_id  FROM fnd_user WHERE user_id = l_supplier_id;



        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_shipment_header_id ' || l_shipment_header_id);
        END IF;

	l_progress := 'POS_WCAPPROVE_PVT.Ins_Actionhist_submit: 02.';
	l_wc_preparer_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WC_PREPARER_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_wc_preparer_id ' || l_wc_preparer_id);
        END IF;


	l_progress := 'POS_WCAPPROVE_PVT.Ins_Actionhist_submit: 03.';

		l_progress := 'POS_WCAPPROVE_PVT.Ins_Actionhist_submit: 04.';


		/* Check if this document had been submitted to workflow at
		 * some point and somehow kicked out. If that's the case, the
		 * sequence number needs to be incremented by one. Otherwise
		 * start at zero.
		*/
		l_progress := 'POS_WCAPPROVE_PVT.Ins_Actionhist_submit: 05.';

		Open action_hist_cursor(l_shipment_header_id  );
		Fetch action_hist_cursor into l_sequence_num;
		close action_hist_cursor;


		IF l_sequence_num is NULL THEN
			l_sequence_num := 0;
		ELSE
			Open action_hist_code_cursor(l_shipment_header_id ,
							l_sequence_num);
			Fetch action_hist_code_cursor into l_action_code;
			close action_hist_code_cursor;
			l_sequence_num := l_sequence_num +1;
		END IF;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_sequence_num ' ||
				l_sequence_num);
		END IF;

		l_progress := 'POS_WCAPPROVE_PVT.Ins_Actionhist_submit: 06.';

		IF ((l_sequence_num = 0)
		OR
	       (l_sequence_num > 0 and l_action_code is NOT NULL)) THEN --{


		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'before call to InsertPOActionHistory ' ||
				l_sequence_num);
		END IF;

		/* Only Supplier will be able to do a SUBMIT. Do not
		 * send in the employee_id.
		*/
			      InsertPOActionHistory(
				   p_object_id => l_shipment_header_id,
				   p_object_type_code=>'WC',
                                   p_object_sub_type_code => NULL,
                                   p_sequence_num =>l_sequence_num ,
                                   p_action_code =>'SUBMIT' ,
                                   p_action_date =>sysdate ,
                                   p_employee_id => l_employee_id, --l_wc_preparer_id forsupplier
                                   p_approval_path_id  => NULL ,
                                   p_note => NULL,
                                   p_object_revision_num => NULL,
                                   p_offline_code =>  '',
                                   p_request_id =>  0,
                                   p_program_application_id => 0,
                                   p_program_id =>0 ,
                                   p_program_date => sysdate ,
                                   p_user_id => fnd_global.user_id  ,
                                   p_login_id => fnd_global.login_id);

		ELSE --}{
			l_sequence_num := l_sequence_num - 1;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'before call to Upd_ActionHistory_Submit ' ||
				l_sequence_num);
		END IF;


                              Upd_ActionHistory_Submit
				(p_object_id =>l_shipment_header_id,
                                 p_object_type_code =>'WC',
                                 p_employee_id   => l_employee_id, --l_wc_preparer_id,
                                 p_sequence_num => l_sequence_num,
                                 p_action_code => 'SUBMIT',
                                 p_user_id   => fnd_global.user_id  ,
                                 p_login_id   =>fnd_global.login_id );

		END IF; --}

		/* Insert the null action code*/
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'insert null action_code ' ||
				l_sequence_num);
		END IF;


		      /*InsertPOActionHistory(
			   p_object_id => l_shipment_header_id,
			   p_object_type_code=>'WC',
			   p_object_sub_type_code => NULL,
			   p_sequence_num =>l_sequence_num+1 ,
			   p_action_code =>NULL ,
			   p_action_date =>sysdate ,
			   p_employee_id => null,--l_wc_preparer_id for supplier
			   p_approval_path_id  => NULL ,
			   p_note => NULL,
			   p_object_revision_num => NULL,
			   p_offline_code =>  '',
			   p_request_id =>  0,
			   p_program_application_id => 0,
			   p_program_id =>0 ,
			   p_program_date => sysdate ,
			   p_user_id => fnd_global.user_id  ,
			   p_login_id => fnd_global.login_id);             */





	x_resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

	l_progress := 'POS_WCAPPROVE_PVT.Ins_Actionhist_submit: 07.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Leave Ins_Actionhist_submit ' || l_progress);
        END IF;
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Ins_Actionhist_submit '
			|| l_progress);
        END IF;
        raise;
end Ins_Actionhist_Submit;

procedure Get_Next_Approver(p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) IS
l_api_name varchar2(50) :=  p_itemkey || ' get_next_approver';
l_application_id number := 201; -- use PO application id.
l_shipment_header_id number;
l_po_header_id number;
l_transaction_type varchar2(100);
l_insertion_type            VARCHAR2(30);
l_work_confirmation_number varchar2(30);
l_authority_type            VARCHAR2(30);
l_forward_from_user_name varchar2(100);
l_wc_preparer_name varchar2(100);
l_progress varchar2(300);
approver_exception   exception;
l_next_approver_id number;
l_next_approver_name per_employees_current_x.full_name%TYPE;
l_next_approver_user_name   VARCHAR2(100);
l_next_approver_disp_name   VARCHAR2(240);
l_orig_system               VARCHAR2(48);
l_completeYNO varchar2(100);
l_next_approver             ame_util.approversTable2;
l_rule_id             ame_util.idList;
l_po_preparer_id number;
l_respond_to_wc_url varchar2(1000);
l_default_approver varchar2(30);
BEGIN

	l_progress := 'POS_WCAPPROVE_PVT.get_next_approver: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in get_next_approver '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'funcmode in get_next_approver '
			|| l_progress);
        END IF;

              x_resultout := wf_engine.eng_null;
              return;
         end if;

	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_shipment_header_id ' || l_shipment_header_id);
        END IF;

	l_po_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'PO_DOCUMENT_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_po_header_id ' || l_po_header_id);
        END IF;

	l_work_confirmation_number :=
                                wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_NUMBER');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_work_confirmation_number ' || l_work_confirmation_number);
        END IF;

	l_transaction_type := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'AME_TRANSACTION_TYPE');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_transaction_type ' || l_transaction_type);
        END IF;
	l_progress := 'POS_WCAPPROVE_PVT.get_next_approver: 02.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'in get_next_approver '
			|| l_progress);
	End if;

	/* Set the Preparer name as the forward_from_user_name the
	 * first time. After that approver_user_name would have
	 * the name of the last approver. Forward_from_user_name
	 * is used to set the #FROM_ROLE in the notifications
	 * message.
	*/
	l_forward_from_user_name :=
			wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'APPROVER_USER_NAME');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_forward_from_user_name '
			|| nvl(l_forward_from_user_name,'NONAME'));
	End if;
	If (l_forward_from_user_name is null) then
		l_wc_preparer_name :=
			wf_engine.GetItemAttrText (itemtype => p_itemtype,
					 itemkey  => p_itemkey,
					 aname    => 'WC_PREPARER_NAME');

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'l_wc_preparer_name  '
				|| nvl(l_wc_preparer_name ,'NONAME'));
		End if;

		wf_engine.SetItemAttrText( itemtype   => p_itemType,
				      itemkey    => p_itemkey,
				      aname      => 'FORWARD_FROM_USER_NAME' ,
				      avalue     => l_wc_preparer_name);

	else
		wf_engine.SetItemAttrText( itemtype   => p_itemType,
				      itemkey    => p_itemkey,
				      aname      => 'FORWARD_FROM_USER_NAME' ,
				      avalue     => l_forward_from_user_name);

	end if;

	-- bug 10012891 - encoding value of work confirmation number as per http standards
        l_respond_to_wc_url :=
                            'JSP:/OA_HTML/OA.jsp?OAFunc=POS_WC_RESPOND_NTFN' || '&' ||
                            'SrcPage=DetailsInternalPG' || '&' ||
                            'WcStatus=PENDING APPROVAL' || '&' ||
                            'PoHeaderId=' || to_char(l_po_header_id) || '&' ||
                            'WcHeaderId='||to_char(l_shipment_header_id)||'&' ||
                            'WcNum=' || (wfa_html.encode_url(l_work_confirmation_number)) || '&' ||
                            'addBreadCrumb=Y';

        wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'RESPOND_TO_WC_URL' ,
                              avalue     => l_respond_to_wc_url);

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'before call to applicablerule ');
	End if;
	ame_api3.getApplicableRules1(applicationIdIn=>l_application_Id,
				     transactionIdIn=>l_shipment_header_id,
				     transactionTypeIn=> l_transaction_type,
				     ruleIdsOut => l_rule_id);
	/* If there are no rules , then this will
	 * return 0.
	 * Check whether the workflow attribute DEFAULT_APPROVER
	 * is BUYER. If it is, then this is already been approved
	 * by him. So send NO_NEXT_APPROVER.
	 * If the value is no BUYER then set the attribute with this
	 * value.
	*/
        if (l_rule_id.count = 0 ) then --{
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'no rule is setup ');
		End if;
		l_default_approver :=
			wf_engine.GetItemAttrText (itemtype => p_itemtype,
				 itemkey  => p_itemkey,
				 aname    => 'DEFAULT_APPROVER');

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_default_approver '
			|| l_default_approver);
	        END IF;

		If l_default_approver = 'BUYER' then --{

			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'already approved by buyer ');
			End if;

			x_resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
		       return;
		elsif(l_default_approver= 'NONE') then --}{
			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'Send buyer as default approver ');
			End if;

			wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'DEFAULT_APPROVER' ,
                              avalue     => 'BUYER');

		l_po_preparer_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'PO_PREPARER_ID');

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_po_preparer_id '
			|| l_po_preparer_id);
		end if;

			l_next_approver(1).orig_system := 'PER';
			l_next_approver(1).orig_system_id := l_po_preparer_id;

		end if; --}


	else --}{

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'call ame api  ');
		End if;

		ame_api2.getNextApprovers4(applicationIdIn=>l_application_Id,
                            transactionIdIn=>l_shipment_header_id,
                            transactionTypeIn=> l_transaction_type,
                            approvalProcessCompleteYNOut=>l_completeYNO,
                            nextApproversOut=>l_next_approver);

	end if; --}

        if (l_next_approver.count > 1) then -- {
                x_resultout:='COMPLETE:'||'INVALID_APPROVER';
                raise approver_exception  ;
        elsif (l_next_approver.count = 0 ) then --}{
                x_resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
               return;
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'no_next_approver  ');
        End if;
                return;
        ELSE --}{

           if (l_next_approver(1).orig_system = 'PER') then --{
                l_next_approver_id := l_next_approver(1).orig_system_id;
           elsif (l_next_approver(1).orig_system = 'POS') then --}{
                begin
                    -- find the persondid from the position_id
                    SELECT person_id, full_name
                    into l_next_approver_id,l_next_approver_name
                     FROM (
                       SELECT person.person_id, person.full_name
                       FROM per_all_people_f person, per_all_assignments_f asg
                       WHERE asg.position_id = l_next_approver(1).orig_system_id
                       and trunc(sysdate) between person.effective_start_date
                       and nvl(person.effective_end_date, trunc(sysdate))
                       and person.person_id = asg.person_id
                       and asg.primary_flag = 'Y'
                       and asg.assignment_type in ('E','C')
                       and ( person.current_employee_flag = 'Y'
                                or person.current_npw_flag = 'Y' )
                       and asg.assignment_status_type_id not in
                         (
                          SELECT assignment_status_type_id
                                FROM per_assignment_status_types
                                WHERE per_system_status = 'TERM_ASSIGN'
                         )
                        and trunc(sysdate) between asg.effective_start_date
                                        and asg.effective_end_date
                        order by person.last_name
                       ) where rownum = 1;
               exception
                WHEN NO_DATA_FOUND THEN
                 RAISE;
               END;

           elsif (l_next_approver(1).orig_system = 'FND') then --}{
                SELECT employee_id
                into l_next_approver_id
                FROM fnd_user
                WHERE user_id = l_next_approver(1).orig_system_id
                and trunc(sysdate) between start_date and nvl(end_date, sysdate+1);
           end if; --}


        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'person_id ' || l_next_approver_id);
        END IF;

                IF (g_asn_debug = 'Y') THEN
                    debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_next_approver_id '
                                || l_next_approver_id);
                    debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_insertion_type '
                                || l_insertion_type);
                    debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_authority_type '
                                || l_authority_type);
                END IF;

                wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey => p_itemkey,
                                      aname  => 'AME_APPROVER_TYPE' ,
                                      avalue => l_next_approver(1).orig_system);
                wf_engine.SetItemAttrNumber ( itemtype   => p_itemType,
                                           itemkey    => p_itemkey,
                                           aname      => 'APPROVER_EMPID',
                                           avalue     => l_next_approver_id);


                wf_engine.SetItemAttrNumber ( itemtype   => p_itemType,
                                           itemkey    => p_itemkey,
                                           aname      => 'FORWARD_TO_ID',
                                           avalue     => l_next_approver_id);

                wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'AME_INSERTION_TYPE' ,
                                      avalue     => l_insertion_type);

                wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'AME_AUTHORITY_TYPE' ,
                                      avalue     => l_authority_type);

                l_orig_system:= 'PER';
                l_progress := 'POS_WCAPPROVE_PVT.get_next_approver: 03.';

                WF_DIRECTORY.GetUserName(l_orig_system,
                                    l_next_approver_id,
                                    l_next_approver_user_name,
                                    l_next_approver_disp_name);

                IF (g_asn_debug = 'Y') THEN
                    debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_next_approver_user_name '
                                || l_next_approver_user_name);
                    debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'l_next_approver_disp_name '
                                || l_next_approver_disp_name);
                end if;
                wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'APPROVER_USER_NAME' ,
                                      avalue     => l_next_approver_user_name);

                wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'APPROVER_DISPLAY_NAME' ,
                                      avalue     => l_next_approver_disp_name);

                wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'FORWARD_TO_USERNAME' ,
                                      avalue     => l_next_approver_user_name);

                wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                                      avalue     => l_next_approver_disp_name);

                /*Start code changes for bug16176242*/
	     IF (l_next_approver(1).approver_category = ame_util.fyiapprovercategory)
	     THEN
            	 wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'IS_FYI_APPROVER' ,
                                      avalue     => 'Y');

             	wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'RESPOND_TO_WC_URL' ,
                              avalue     => null);

             ELSE
              	wf_engine.SetItemAttrText( itemtype   => p_itemType,
                                      itemkey    => p_itemkey,
                                      aname      => 'IS_FYI_APPROVER' ,
                                      avalue     => 'N');

             END IF;
              /*End code changes for bug16176242*/

                x_resultout:='COMPLETE:'||'VALID_APPROVER';
                return;
           END IF; --}


Exception
        when approver_exception then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,
				'Exception in ame_util.getNextApprove '
				|| l_progress);
        END IF;
	raise;
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in get_next_approve '
			|| l_progress);
        END IF;
        raise;
end get_next_approver;


procedure Insert_Action_History(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2) is

l_progress varchar2(200);
l_approver_id number;
l_shipment_header_id number;
l_shipment_line_id number;
l_count number;
l_sequence_num number;
l_api_name varchar2(50) := p_itemkey || ' Insert_Action_History';

/*
cursor get_shipment_lines(l_shipment_header_id number) is
select shipment_line_id
from rcv_shipment_lines
where shipment_header_id=l_shipment_header_id;
*/

CURSOR get_action_history IS
  SELECT  object_id,
          object_type_code,
          object_sub_type_code,
          sequence_num,
          object_revision_num,
          request_id,
          program_application_id,
          program_date,
          program_id,
          last_update_date,
          employee_id
    FROM  PO_ACTION_HISTORY
   WHERE  object_type_code = 'WC'
     AND  object_id  = l_shipment_header_id
     AND  sequence_num = l_sequence_num;

   Recinfo get_action_history%ROWTYPE;

invalid_data exception;
invalid_action exception;

BEGIN


	if (p_funcmode <> wf_engine.eng_run) then
		x_resultout := wf_engine.eng_null;
		return;
	end if;




	l_progress := 'POS_WCAPPROVE_PVT.Insert_Action_History: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in Insert_Action_History '
			|| l_progress);
        END IF;



	l_approver_id := wf_engine.GetItemAttrNumber(itemtype=>p_itemtype,
						 itemkey=>p_itemkey,
						 aname=>'APPROVER_EMPID');
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_approver_id '
			|| l_approver_id);
        END IF;

	l_shipment_header_id:= wf_engine.GetItemAttrNumber(itemtype=>p_itemtype,
						 itemkey=>p_itemkey,
						 aname=>'WORK_CONFIRMATION_ID');
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_shipment_header_id '
			|| l_shipment_header_id);
        END IF;



 --       loop --{
                l_progress := 'POS_WCAPPROVE_PVT.Insert_Action_History: 04.';

		SELECT count(*)
		INTO l_count
		FROM PO_ACTION_HISTORY
		WHERE object_type_code = 'WC'
		AND object_id   = l_shipment_header_id
		AND action_code IS NULL;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'l_count '
				|| l_count);
		END IF;


		IF (l_count > 1) THEN --{

			RAISE invalid_action;

		ELSE --}{

			SELECT max(sequence_num)
			INTO l_sequence_num
			FROM PO_ACTION_HISTORY
			WHERE object_type_code = 'WC'
			AND object_id = l_shipment_header_id;

			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_STATEMENT,
						l_api_name,'l_sequence_num '
					|| l_sequence_num);
			END IF;

			OPEN get_action_history;

			FETCH get_action_history INTO Recinfo;

			IF (get_action_history%NOTFOUND) then
				IF (g_asn_debug = 'Y') THEN
				    debug_log(FND_LOG.LEVEL_STATEMENT,
							l_api_name,
							'no_data_round ' );
				END IF;

				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE get_action_history;

			/*
			** if it is the first call and it gets here
			** it means there is an implicit forward.  We
			** want to update the first NULL row in POAH
			** with FORWARD action
			*/


			If l_count = 1 then


				IF (g_asn_debug = 'Y') THEN
				    debug_log(FND_LOG.LEVEL_STATEMENT,
							l_api_name,
						'update Action history ' );
				END IF;

				UpdatePOActionHistory(
                                p_object_id => Recinfo.object_id,
                                p_object_type_code => Recinfo.object_type_code,
                                p_employee_id => Recinfo.employee_id,
                                p_action_code => 'FORWARD',
                                p_note => NULL,
                                p_user_id => fnd_global.user_id,
                                p_login_id => fnd_global.login_id);


			End if;


			If l_approver_id is null then --{
				raise invalid_data;

			Else --}{
				IF (g_asn_debug = 'Y') THEN
				    debug_log(FND_LOG.LEVEL_STATEMENT,
							l_api_name,
						'Insert Action history ' );
				END IF;



			      InsertPOActionHistory(
				   p_object_id => Recinfo.object_id,
				   p_object_type_code=>Recinfo.object_type_code,
                                   p_object_sub_type_code => NULL,
                                   p_sequence_num => Recinfo.sequence_num+1 ,
                                   p_action_code =>NULL ,
                                   p_action_date =>NULL ,
                                   p_employee_id => l_approver_id,
                                   p_approval_path_id  => NULL ,
                                   p_note => NULL,
                                   p_object_revision_num => NULL,
                                   p_offline_code =>  NULL,
                                   p_request_id =>  Recinfo.request_id,
                                   p_program_application_id => Recinfo.program_application_id,
                                   p_program_id =>Recinfo.program_id ,
                                   p_program_date => Recinfo.program_date ,
                                   p_user_id => fnd_global.user_id  ,
                                   p_login_id => fnd_global.login_id);

			End if;--}


		END If; --}



	--end loop;--}
	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
			'Exit Insert Action history ' );
	END IF;

exception
        when invalid_action then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_EXCEPTION,
			l_api_name,'invalid_action in Insert_Action_History '
			|| l_progress);
        END IF;
        raise;
        when invalid_data then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_EXCEPTION,
			l_api_name,'invalid_data in Insert_Action_History '
			|| l_progress);
        END IF;
        raise;
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Insert_Action_History '
			|| l_progress);
        END IF;
        raise;
end Insert_Action_History;

/* This procedure will be called when the approver approves the
 * document directly from the notification. This means that
 * he wants to approve all the shipment lines at one shot.
 * So set the approval status of all the shipment lines to
 * APPROVED.
*/
procedure Approve_shipment_lines(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2) is
l_progress varchar2(200);
l_shipment_header_id number;
l_api_name varchar2(50) :=  p_itemkey || ' Approve_shipment_lines';
l_note  po_action_history.note%type;
l_result varchar2(3);

l_notification_id number;
CURSOR c_group_id (p_itemtype VARCHAR2,
                   p_itemkey VARCHAR2,
                   p_activity_name VARCHAR2) IS
    SELECT notification_id
    FROM   wf_item_activity_statuses_v
    WHERE  item_type = p_itemtype
    AND    item_key = p_itemkey
    AND    activity_name =  p_activity_name
    ORDER BY activity_end_date DESC;

BEGIN

	l_progress := 'POS_WCAPPROVE_PVT.Approve_shipment_lines: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in Approve_shipment_lines '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

	OPEN c_group_id(p_itemtype, p_itemkey, 'WC_APPROVE');

        FETCH c_group_id INTO l_notification_id;
        CLOSE c_group_id;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,
                                ' l_notification_id ' || l_notification_id);
        END IF;


	If (l_notification_id is not null) then
		SELECT attribute_value
		into l_note
		FROM   wf_notification_attr_resp_v
		WHERE  group_id = l_notification_id
		AND    attribute_name = 'NOTE';
	end if;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,
                                ' l_note ' || l_note);
        END IF;

	update_approval_status(p_shipment_header_id => l_shipment_header_id,
                               p_note => l_note,
                               p_approval_status => 'APPROVED',
			       p_level => 'LINES',
                               x_resultout => l_result);



        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_shipment_header_id ' || l_shipment_header_id);
        END IF;
	x_resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Approve_shipment_lines '
			|| l_progress);
        END IF;
        raise;
end Approve_shipment_lines;


/* This procedure will be called when the approver rejects the
 * document directly from the notification. This means that
 * he wants to approve all the shipment lines at one shot.
 * So set the approval status of all the shipment lines to
 * REJECTED.
*/
procedure Reject_shipment_lines(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2) is
l_progress varchar2(200);
l_shipment_header_id number;
l_api_name varchar2(50) :=  p_itemkey || ' Reject_shipment_lines';
l_note po_action_history.note%type;
l_result varchar2(3);

l_notification_id number;
CURSOR c_group_id (p_itemtype VARCHAR2,
                   p_itemkey VARCHAR2,
                   p_activity_name VARCHAR2) IS
    SELECT notification_id
    FROM   wf_item_activity_statuses_v
    WHERE  item_type = p_itemtype
    AND    item_key = p_itemkey
    AND    activity_name =  p_activity_name
    ORDER BY activity_end_date DESC;

BEGIN

	l_progress := 'POS_WCAPPROVE_PVT Reject_shipment_lines: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in Reject_shipment_lines '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

	OPEN c_group_id(p_itemtype, p_itemkey, 'WC_APPROVE');

        FETCH c_group_id INTO l_notification_id;
        CLOSE c_group_id;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,
                                ' l_notification_id ' || l_notification_id);
        END IF;


	If l_notification_id is not null then
		SELECT attribute_value
		into l_note
		FROM   wf_notification_attr_resp_v
		WHERE  group_id = l_notification_id
		AND    attribute_name = 'NOTE';
	end if;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,
                                ' l_note ' || l_note);
        END IF;



	update_approval_status(p_shipment_header_id => l_shipment_header_id,
                               p_note => l_note,
                               p_approval_status => 'REJECTED',
			       p_level => 'LINES',
                               x_resultout => l_result);



        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_shipment_header_id ' || l_shipment_header_id);
        END IF;
	x_resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Reject_shipment_lines '
			|| l_progress);
        END IF;
        raise;
end Reject_shipment_lines;


/* Get the status of all the lines of the Work Confirmation.
 * Even if one is rejected.
*/
procedure Approve_OR_Reject(p_itemtype        in varchar2,
                                p_itemkey         in varchar2,
                                p_actid           in number,
                                p_funcmode        in varchar2,
                                x_resultout       out NOCOPY varchar2) is

l_progress varchar2(200);
l_shipment_header_id number;
l_reject_lines number;
l_api_name varchar2(50) := p_itemkey || ' approve_or_reject';

BEGIN

	l_progress := 'POS_WCAPPROVE_PVT.Approve_OR_Reject: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in Approve_OR_Reject '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_shipment_header_id ' || l_shipment_header_id);
        END IF;


	select count(*)
	into l_reject_lines
	from rcv_shipment_lines
	where shipment_header_id = l_shipment_header_id
	and approval_status = 'REJECTED';

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_reject_lines ' || l_reject_lines);
        END IF;

	If (l_reject_lines > 0) then
		x_resultout := wf_engine.eng_completed || ':' ||
					'REJECT';
	else
		x_resultout := wf_engine.eng_completed || ':' ||
					'APPROVE';

	end if;


exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Approve_OR_Reject '
			|| l_progress);
        END IF;
        raise;
end Approve_OR_Reject;

procedure Update_Approval_List_Response
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) IS

CURSOR c_group_id (p_itemtype VARCHAR2,
		   p_itemkey VARCHAR2,
		   p_activity_name VARCHAR2) IS
    SELECT notification_id
    FROM   wf_item_activity_statuses_v
    WHERE  item_type = p_itemtype
    AND    item_key = p_itemkey
    AND    activity_name =  p_activity_name
    ORDER BY activity_end_date DESC;

CURSOR c_canceled_notif (p_notif_id number) IS
    SELECT '1'
     FROM   WF_NOTIFICATIONS
    WHERE   notification_id = p_notif_id
      AND   status = 'CANCELED';

  CURSOR c_response(p_group_id number) IS
    SELECT recipient_role, attribute_value
    FROM   wf_notification_attr_resp_v
    WHERE  group_id = p_group_id
    AND    attribute_name = 'RESULT';

  CURSOR c_response_note(p_group_id number) IS
    SELECT attribute_value
    FROM   wf_notification_attr_resp_v
    WHERE  group_id = p_group_id
    AND    attribute_name = 'NOTE';

  CURSOR c_responderid(p_responder VARCHAR2) IS
    SELECT nvl((wfu.orig_system_id), -9996)
    FROM   wf_users wfu
    WHERE  wfu.name = p_responder
    AND    wfu.orig_system not in ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

  l_api_name varchar2(50) := p_itemkey || ' update_approval_list_response';
  l_responder                 wf_notifications.responder%TYPE;
  l_recipient_role            wf_notifications.recipient_role%TYPE;

  l_group_id                  NUMBER;
  l_role                      wf_notifications.recipient_role%TYPE;
  l_response                     VARCHAR2(2000);

  l_approver_id               NUMBER := NULL;
  l_orig_system               wf_users.orig_system%TYPE;
  l_responder_user_name       wf_users.name%TYPE;
  l_responder_disp_name       wf_users.display_name%TYPE;

  is_notif_canceled    VARCHAR2(2);
  l_doc_string varchar2(200);
  l_preparer_user_name wf_users.name%TYPE;
  l_response_end_date date;
  l_responder_id number;
  l_progress varchar2(300);
  l_insertion_type            VARCHAR2(30);
  l_authority_type            VARCHAR2(30);
  l_forward_to_id             NUMBER := NULL;
  l_transaction_type varchar2(100);
  l_shipment_header_id number;
  l_application_id number := '201'; -- use PO application id.
  l_current_approver ame_util.approverRecord2;
  l_approver_type varchar2(10);
  l_default_approver varchar2(30);
  l_next_approver_disp_name varchar2(100);
  l_reject_lines number;


begin
	l_progress := 'POS_WCAPPROVE_PVT.Update_Approval_List_Response: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in Update_Approval_List_Response '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;


	wf_engine.SetItemAttrNumber ( itemtype   => p_itemType,
                                itemkey    => p_itemkey,
                                aname      => 'RESPONDER_USER_ID',
                                avalue     => fnd_global.USER_ID);

	wf_engine.SetItemAttrNumber ( itemtype   => p_itemType,
				itemkey    => p_itemkey,
				aname      => 'RESPONDER_RESP_ID',
				avalue     => fnd_global.RESP_ID);

	wf_engine.SetItemAttrNumber ( itemtype   => p_itemType,
				itemkey    => p_itemkey,
				aname      => 'RESPONDER_APPL_ID',
				avalue     => fnd_global.RESP_APPL_ID);

	OPEN c_group_id(p_itemtype, p_itemkey, 'WC_APPROVE');

	FETCH c_group_id INTO l_group_id;
	CLOSE c_group_id;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_group_id ' || l_group_id);
        END IF;


	  IF l_group_id is NOT NULL THEN --{
		OPEN c_response(l_group_id);
		FETCH c_response INTO l_role, l_response;
		CLOSE c_response;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_role ' || l_role);
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_response '
					|| substr(l_response,1,50));
		END IF;

		l_progress := 'POS_WCAPPROVE_PVT.Update_Approval_List_Response'
					|| ': 02.';


		SELECT wfn.responder, wfn.recipient_role, wfn.end_date
		INTO l_responder, l_recipient_role, l_response_end_date
		FROM   wf_notifications wfn
		WHERE  wfn.notification_id = l_group_id;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_responder ' || l_responder);
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_recipient_role '
					 || l_recipient_role);
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_response_end_date '
				|| to_char(l_response_end_date,'DD-MON-YYYY'));
		end if;

		OPEN c_responderid(l_responder);
		FETCH c_responderid INTO l_responder_id;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_responder_id ' || l_responder_id);
		end if;

		IF c_responderid%NOTFOUND THEN --{

		  CLOSE c_responderid;
		  OPEN c_responderid(l_recipient_role);
		  FETCH c_responderid INTO l_responder_id;
		  CLOSE c_responderid;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_responder_id1 ' || l_responder_id);
		end if;
		End if;--}


		IF (c_responderid%ISOPEN) THEN
		  CLOSE c_responderid;
		END IF;

		l_progress := 'POS_WCAPPROVE_PVT.Update_Approval_List_Response'
				|| ':02.';
	      wf_engine.SetItemAttrNumber(itemtype   => p_itemType,
					     itemkey => p_itemkey,
					     aname   => 'RESPONDER_ID',
					     avalue  => l_responder_id);

	      l_orig_system:= 'PER';

	      WF_DIRECTORY.GetUserName(l_orig_system,
				       l_responder_Id,
				       l_responder_user_name,
				       l_responder_disp_name);

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_responder_user_name '
					|| l_responder_user_name);
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_responder_disp_name '
					|| l_responder_disp_name);
		end if;

		l_progress := 'POS_WCAPPROVE_PVT.Update_Approval_List_Response'
				|| ': 03.';
	      wf_engine.SetItemAttrText( itemtype => p_itemType,
				      itemkey    => p_itemkey,
				      aname      => 'RESPONDER_USER_NAME' ,
				      avalue     => l_responder_user_name);

	      wf_engine.SetItemAttrText( itemtype => p_itemType,
				      itemkey    => p_itemkey,
				      aname      => 'RESPONDER_DISPLAY_NAME' ,
				      avalue     => l_responder_disp_name);

		l_progress := 'POS_WCAPPROVE_PVT.Update_Approval_List_Response'
					|| ': 04.';

		/* We cannot have response as forward. Need to remove it later
		IF (INSTR(l_response, 'FORWARD') > 0) THEN
		l_forward_to_id :=
			wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
						 itemkey  => p_itemkey,
						 aname    => 'FORWARD_TO_ID');
		END IF;
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					' l_forward_to_id '
					|| l_forward_to_id);
		END IF;
		*/

		l_progress := 'POS_WCAPPROVE_PVT.Update_Approval_List_Response'
					|| ': 05.';

	  END IF; -- }c_group_id


	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
					 itemkey  => p_itemkey,
					 aname    => 'WORK_CONFIRMATION_ID');

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_shipment_header_id '
				|| l_shipment_header_id);
	END IF;

	l_approver_id := wf_engine.GetItemAttrNumber(itemtype=>p_itemtype,
						 itemkey=>p_itemkey,
						 aname=>'APPROVER_EMPID');

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_approver_id '
				|| l_approver_id);
	END IF;

	l_insertion_type := wf_engine.GetItemAttrText(itemtype => p_itemtype,
					 itemkey  => p_itemkey,
					 aname    => 'AME_INSERTION_TYPE');

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_insertion_type '
				|| l_insertion_type);
	END IF;

	l_authority_type := wf_engine.GetItemAttrText(itemtype => p_itemtype,
					 itemkey  => p_itemkey,
					 aname    => 'AME_AUTHORITY_TYPE');

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_authority_type '
				|| l_authority_type);
	END IF;

	l_transaction_type := wf_engine.GetItemAttrText (itemtype => p_itemtype,
					 itemkey  => p_itemkey,
					 aname    => 'AME_TRANSACTION_TYPE');

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_transaction_type '
				|| l_transaction_type);
	END IF;

        l_approver_type := po_wf_util_pkg.GetItemAttrText
                                              (itemtype => p_itemtype,
                                               itemkey  => p_itemkey,
                                               aname    => 'AME_APPROVER_TYPE');
	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_approver_type '
				|| l_approver_type);
	END IF;

	l_default_approver :=
		wf_engine.GetItemAttrText (itemtype => p_itemtype,
			 itemkey  => p_itemkey,
			 aname    => 'DEFAULT_APPROVER');

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
			l_api_name,'l_default_approver '
		|| l_default_approver);
	END IF;

	If l_default_approver = 'BUYER' then --{
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Approved by buyer. Dont call ame api ');
		END IF;
		x_resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
		return;

	end if; --}

        if (l_approver_type = 'POS') then
                l_current_approver.orig_system := 'POS';
        elsif (l_approver_type = 'FND') then
                l_current_approver.orig_system := 'FND';
        else
                l_current_approver.orig_system := 'PER';
        end if;

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' orig_system '
				|| l_current_approver.orig_system);
	END IF;

        l_current_approver.orig_system_id := l_approver_id;

        if( l_response = 'APPROVE') then
                l_current_approver.approval_status := ame_util.approvedStatus;
        elsif( l_response = 'REJECT') then
                l_current_approver.approval_status := ame_util.rejectStatus;
        elsif( l_response = 'TIMEOUT') then
                l_current_approver.approval_status := ame_util.noResponseStatus;
	else /* Can be approved/rejected from iSP UI */
		select count(*)
		into l_reject_lines
		from rcv_shipment_lines
		where shipment_header_id = l_shipment_header_id
		and approval_status = 'REJECTED';

		If (l_reject_lines > 0) then
		   l_current_approver.approval_status := ame_util.rejectStatus;
		else
		   l_current_approver.approval_status := ame_util.approvedStatus;
		end if;


        end if;


        /*
	Bug 7120431 , To get the user name from wf_users we need to pass orig_system as 'PER' irresepective of
	whether we user Employee-Supervisor hierarchy or Positional hierarchy .
	So passing 'PER' while in the below call.
	*/

        WF_DIRECTORY.GetUserName('PER',
                                    l_current_approver.orig_system_id,
                                    l_current_approver.name,
                                    l_next_approver_disp_name);



	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' name '
				|| l_current_approver.name);
	END IF;

        IF l_current_approver.name IS NULL THEN
                 raise_application_error(-20001,
                 'Record Not Found in WF_ROLES for the orig_system_id :' ||
                                          l_current_approver.orig_system_id || ' -- orig_system :' || l_current_approver.orig_system );
    END IF;


                ame_api2.updateApprovalStatus(applicationIdIn=>l_application_Id,                            transactionIdIn=>l_shipment_header_id,
                            approverIn=>l_current_approver,
                            transactionTypeIn=>l_transaction_type);


	x_resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
	RETURN;
Exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in update_approval_list_response '
			|| l_progress);
        END IF;
        raise;
end Update_Approval_List_Response;

procedure Update_Action_History_Approve
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) IS
l_progress varchar2(300);
l_api_name varchar2(50) := p_itemkey || ' update_action_history_approve';
begin
	l_progress := 'POS_WCAPPROVE_PVT.Update_Approval_History_Approve: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in Update_Action_History_Approve '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	Update_Action_History(p_itemtype => p_itemtype,
			      p_itemkey => p_itemkey,
			      p_action_code => 'APPROVE');

	x_resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Leave in Update_Action_History_Approve '
			|| l_progress);
        END IF;

	return;


Exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in update_action_history_approve '
			|| l_progress);
        END IF;
        raise;
end Update_Action_History_Approve;

procedure Update_Action_History_Reject
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) IS
l_progress varchar2(300);
l_api_name varchar2(50) := p_itemkey || ' update_action_history_Reject';
begin
	l_progress := 'POS_WCAPPROVE_PVT.Update_action_history_reject: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in Update_Action_History_Reject '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	Update_Action_History(p_itemtype => p_itemtype,
			      p_itemkey => p_itemkey,
			      p_action_code => 'REJECT');

	x_resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Leave in Update_Action_History_Reject '
			|| l_progress);
        END IF;

	return;


Exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in update_action_history_Reject '
			|| l_progress);
        END IF;
        raise;
end Update_Action_History_REJECT;



procedure Update_Action_History
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_action_code     in  varchar2) IS

CURSOR c_responderid(l_responder VARCHAR2) IS
    SELECT nvl((wfu.orig_system_id), -9996)
    FROM   wf_users wfu
    WHERE  wfu.name = l_responder
    AND    wfu.orig_system not in ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');


/*
cursor get_shipment_lines(l_shipment_header_id number) is
select rsl.shipment_line_id ,
nvl(rsl.comments,rsh.comments),
rsl.approval_status
from rcv_shipment_lines rsl,
rcv_shipment_headers rsh
where rsh.shipment_header_id = l_shipment_header_id
and rsh.shipment_header_id= rsl.shipment_header_id;
*/

l_api_name varchar2(50) := p_itemkey || ' update_action_history';
l_shipment_header_id number;
l_shipment_line_id number;
l_progress varchar2(300);
l_notification_id number;
l_comments varchar2(240) := null;
l_original_recipient_id     number;
l_original_recipient        wf_notifications.original_recipient%TYPE;
l_recipient_role            wf_notifications.recipient_role%TYPE;
l_more_info_role wf_notifications.more_info_role%TYPE;
l_responder_id number;
l_more_origsys              wf_roles.orig_system%TYPE;
l_more_origsysid            wf_roles.orig_system_id%TYPE := null;
l_responder                 wf_notifications.responder%TYPE;


begin
	l_progress := 'POS_WCAPPROVE_PVT.Update_Action_history: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in Update_Action_History '
			|| l_progress);
        END IF;


	l_shipment_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
					 itemkey  => p_itemkey,
					 aname    => 'WORK_CONFIRMATION_ID');

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_shipment_header_id '
				|| l_shipment_header_id);
	END IF;


	l_progress := 'POS_WCAPPROVE_PVT.Update_Action_history: 02.';
	SELECT nvl(max(wf.notification_id), -9995)
	into    l_notification_id
	FROM    wf_notifications wf,
	wf_item_activity_statuses wias
	WHERE  wias.item_type = p_itemtype
	and wias.item_key = p_itemkey
	and wias.notification_id = wf.group_id;

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_notification_id '
				|| l_notification_id);
	END IF;


	l_progress := 'POS_WCAPPROVE_PVT.Update_Action_history: 03.';
	SELECT wfn.responder, wfn.recipient_role,
               wfn.original_recipient, wfn.more_info_role
        INTO l_responder, l_recipient_role,
             l_original_recipient, l_more_info_role
        FROM   wf_notifications wfn
        WHERE  wfn.notification_id = l_notification_id;

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_responder ' || l_responder);
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_recipient_role ' || l_recipient_role);
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_original_recipient '||l_original_recipient);
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				' l_more_info_role ' || l_more_info_role);
	END IF;


	OPEN c_responderid(l_responder);
	FETCH c_responderid INTO l_responder_id;


	IF c_responderid%NOTFOUND THEN

	CLOSE c_responderid;
	OPEN c_responderid(l_recipient_role);
	FETCH c_responderid INTO l_responder_id;
	CLOSE c_responderid;

	END IF;

	IF (c_responderid%ISOPEN) THEN
	CLOSE c_responderid;
	END IF;


	OPEN c_responderid(l_original_recipient);
	FETCH c_responderid INTO l_original_recipient_id;

	IF c_responderid%NOTFOUND THEN--{

	CLOSE c_responderid;

	SELECT wfu.orig_system_id
	INTO l_original_recipient_id
	FROM wf_roles wfu
	WHERE wfu.name = l_original_recipient
	AND wfu.orig_system NOT IN ('POS', 'ENG_LIST', 'CUST_CONT');

	END IF; --}

	IF (c_responderid%ISOPEN) THEN
	CLOSE c_responderid;
	END IF;

	if (l_more_info_role is not null) then
		Wf_Directory.GetRoleOrigSysInfo
				(l_more_info_role,
				 l_more_origsys,
				 l_more_origsysid);
	end if;

	--loop --{
		l_progress := 'POS_WCAPPROVE_PVT.update_approval_history: 04.';


		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_comments ' ||
				l_comments);
		END IF;


		    UpdateActionHistory(l_more_origsysid,
                        l_original_recipient_id,
                        l_responder_id,
			FALSE,
                        p_action_code,
                        l_comments,
                        l_shipment_header_id);

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'After updateactionhistory' ||
				l_shipment_header_id);
		end if;
	--end loop; --}

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
			l_api_name,'Leave update_action_history' );
	end if;

	return;

EXCEPTION
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
			l_api_name,'Exception in Update_Action_History '
			|| l_progress);
        END IF;
        raise;

END Update_Action_History;

PROCEDURE UpdateActionHistory(p_more_info_id           IN NUMBER,
                              p_original_recipient_id  IN NUMBER,
                              p_responder_id           IN NUMBER,
			      p_last_approver          IN BOOLEAN,
                              p_action_code            IN VARCHAR2,
                              p_comments               IN VARCHAR2,
                              p_shipment_header_id     IN NUMBER)
IS

-- pragma AUTONOMOUS_TRANSACTION;
l_api_name varchar2(50) := 'UpdateActionHistory';
l_progress varchar2(300);
l_sequence_num number;
l_note VARCHAR2(4000);

  CURSOR get_action_history(l_sequence_num number) IS
  SELECT  ph.action_code action_code ,
          ph.object_type_code object_type_code ,
          ph.sequence_num sequence_num,
          ph.approval_path_id approval_path_id,
          ph.request_id request_id ,
          ph.program_application_id program_application_id,
          ph.program_date program_date ,
          ph.program_id program_id ,
          ph.last_update_date last_update_date,
          ph.object_id object_id,
	  ph.employee_id employee_id
  FROM
     rcv_shipment_headers rsh,
     po_action_history ph
  WHERE rsh.shipment_header_id = ph.object_id
     and rsh.shipment_header_id=p_shipment_header_id
     and ph.sequence_num = l_sequence_num;

   Recinfo get_action_history%ROWTYPE;

BEGIN

	l_progress := 'POS_WCAPPROVE_PVT.UpdateActionHistory: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in UpdateActionHistory '
			|| l_progress);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'p_shipment_header_id '
			|| p_shipment_header_id);
        END IF;


	SELECT max(sequence_num)
	INTO l_sequence_num
	FROM PO_ACTION_HISTORY
	WHERE object_type_code = 'WC'
	AND object_id = p_shipment_header_id;

	OPEN get_action_history(l_sequence_num);

	FETCH get_action_history INTO Recinfo;

	IF (get_action_history%NOTFOUND) then
	RAISE NO_DATA_FOUND;
	END IF;

	CLOSE get_action_history;


	if ( (Recinfo.action_code is not null) and
	     (p_action_code not in ('APPROVE','REJECT'))) then --{

		/* Add a blank line if the last line is not blank.
		*/
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
				 'Before call to InsertPOActionHistory ');
		End if;


		      InsertPOActionHistory(
			   p_object_id => Recinfo.object_id,
			   p_object_type_code=>Recinfo.object_type_code,
			   p_object_sub_type_code => NULL,
			   p_sequence_num => Recinfo.sequence_num+1 ,
			   p_action_code =>NULL ,
			   p_action_date =>NULL ,
			   p_employee_id => p_original_recipient_id,
			   p_approval_path_id  => NULL ,
			   p_note => NULL,
			   p_object_revision_num => NULL,
			   p_offline_code =>  NULL,
			   p_request_id =>  Recinfo.request_id,
			   p_program_application_id => Recinfo.program_application_id,
			   p_program_id =>Recinfo.program_id ,
			   p_program_date => Recinfo.program_date ,
			   p_user_id => fnd_global.user_id  ,
			   p_login_id => fnd_global.login_id);


	end if; --}

	IF (p_responder_id <> -9996) THEN--{

		/** the logic to handle re-assignment is in
		 ** post notification function  so that the update
		 ** to action history can be viewed at the moment of
		 ** reassignment. The following code is used to handle
		 ** request for more info:
		 ** 1. at the moment an approver requests for more info,
		 **    action history is updated (performed within post
		 ** notification)
		 ** 2. if the approver approve/reject the requisition
		 **      before the more info request is responded
		 **    then we need to update the action history
		 **      to reflect 'no action' from the more info
		*/
		IF (p_more_info_id is not null) THEN --{


			/*
			** update the original NULL row for the
			** original approver with
			** action code of 'NO ACTION'
			*/


			UpdatePOActionHistory(
			p_object_id => Recinfo.object_id,
			p_object_type_code => Recinfo.object_type_code,
			p_employee_id => p_more_info_id,
			p_action_code => 'NO ACTION',
			p_note => NULL,
			p_user_id => fnd_global.user_id,
			p_login_id => fnd_global.login_id);



			/*
			** insert a new NULL row into PO_ACTION_HISTORY  for
			** the new approver
			*/


		      InsertPOActionHistory(
			   p_object_id => Recinfo.object_id,
			   p_object_type_code=>Recinfo.object_type_code,
			   p_object_sub_type_code => NULL,
			   p_sequence_num => Recinfo.sequence_num+1 ,
			   p_action_code =>NULL ,
			   p_action_date =>NULL ,
			   p_employee_id => p_responder_id,
			   p_approval_path_id  => NULL ,
			   p_note => NULL,
			   p_object_revision_num => NULL,
			   p_offline_code =>  NULL,
			   p_request_id =>  Recinfo.request_id,
			   p_program_application_id => Recinfo.program_application_id,
			   p_program_id =>Recinfo.program_id ,
			   p_program_date => Recinfo.program_date ,
			   p_user_id => fnd_global.user_id  ,
			   p_login_id => fnd_global.login_id);


		end if; --}


	end if; --}

	l_progress := 'POS_WCAPPROVE_PVT.UpdateActionHistory: 02.';

	IF (not p_last_approver) THEN

	/**
	** update pending row of action history with approval action
	*/
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
				 'Before call to UpdatePOActionHistory '
			||l_progress);
		End if;

		UpdatePOActionHistory(
		p_object_id => Recinfo.object_id,
		p_object_type_code => Recinfo.object_type_code,
		p_employee_id => Recinfo.employee_id,
		p_action_code => p_action_code,
		p_note =>substrb(p_comments,1,4000),
		p_user_id => fnd_global.user_id,
		p_login_id => fnd_global.login_id);


	END IF;


EXCEPTION
        when no_data_found then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,
				'No data found in UpdateActionHistory '
			|| l_progress);
        END IF;
        raise;

        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in UpdateActionHistory '
			|| l_progress);
        END IF;
        raise;

END UpdateActionHistory;

PROCEDURE get_user_name(p_orig_system IN Varchar2,
			p_employee_id IN number,
			x_username OUT NOCOPY varchar2,
                        x_user_display_name OUT NOCOPY varchar2) is

l_progress varchar2(200);
l_api_name varchar2(50) :=  ' get_user_name';

BEGIN

	l_progress := 'POS_WCAPPROVE_PVT.get_user_name: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in get_user_name '
			|| l_progress);
        END IF;

	WF_DIRECTORY.GetUserName(p_orig_system,
                           p_employee_id,
                           x_username,
                           x_user_display_name);

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'x_username '
			|| x_username);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'x_user_display_name '
			|| x_user_display_name);
        END IF;
EXCEPTION
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in get_user_name '
			|| l_progress);
        END IF;
        raise;

END get_user_name;


PROCEDURE UpdatePOActionHistory (p_object_id            IN NUMBER,
                                 p_object_type_code     IN VARCHAR2,
                                 p_employee_id      IN NUMBER,
                                 p_action_code          IN VARCHAR2,
                                 p_note                 IN VARCHAR2,
                                 p_user_id              IN NUMBER,
                                 p_login_id             IN NUMBER)
IS
        l_progress      VARCHAR2(250) := '';
        l_employee_id   NUMBER ;
	invalid_action exception;
	l_api_name varchar2(50) := ' UpdatePOActionHistory';
	l_note po_action_history.note%type;

BEGIN
	l_progress := 'POS_WCAPPROVE_PVT.UpdatePOActionHistory: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in UpdatePOActionHistory '
			|| l_progress);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'object_id '||p_object_id
			|| 'object_type_code '|| p_object_type_code
			|| 'p_employee_id '|| nvl(p_employee_id,-9999)
			|| 'p_action_code '|| nvl(p_action_code,'NO ACTION')
			|| 'p_note '|| nvl(p_note,'NO NOTE')
			|| 'p_user_id '|| p_user_id
			|| 'p_login_id '|| p_login_id);
        END IF;

    IF (p_object_id IS NOT NULL AND
        p_object_type_code IS NOT NULL) THEN --{

	/* Employee id should belong to the id of the corresponding
	 * user taking the action, not the employee id to
	 * which the work confirmation was forwarded to.
	*/
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'ohject_id and  '
				|| 'object_type_code not null');
		END IF;

/*
        If (p_old_employee_id is NULL) then
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'p_employee_id is null '
				|| l_progress);
		END IF;

                SELECT HR.EMPLOYEE_ID
                INTO   l_employee_id
                FROM   FND_USER FND, HR_EMPLOYEES_CURRENT_V HR
                WHERE  FND.USER_ID = NVL(p_user_id, fnd_global.user_id)
                AND    FND.EMPLOYEE_ID = HR.EMPLOYEE_ID;
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'l_employee_id '
				|| l_employee_id);
		END IF;

        end if;

	l_progress := 'POS_WCAPPROVE_PVT.UpdatePOActionHistory: 02.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Before Update '
			|| l_progress);
        END IF;
*/


        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_note '
			|| l_note);
	end if;


 	begin
			if (p_action_code = 'APPROVE' OR p_action_code ='REJECT') then
				select comments
					into l_note
				from rcv_shipment_headers
				where shipment_header_id=p_object_id;
			end if;
		exception
			when others then
			l_note := null;
		end;

        UPDATE PO_ACTION_HISTORY
        SET     last_update_date = sysdate,
                last_updated_by = p_user_id,
                last_update_login = p_login_id,
                employee_id = p_employee_id,
                --employee_id = NVL(l_employee_id, employee_id),
                action_date = sysdate,
                action_code = p_action_code,
                note = nvl(p_note,l_note)
        WHERE   object_id = p_object_id
        AND     object_type_code = p_object_type_code
        AND     action_code IS NULL;
	--employee_id = NVL(p_old_employee_id, employee_id)

    ELSE --}{
	l_progress := 'POS_WCAPPROVE_PVT.UpdatePOActionHistory: 02.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Either  object id or code is null '
			|| l_progress);
        END IF;
		raise invalid_action;
    END IF; --}

EXCEPTION
        when invalid_action then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_EXCEPTION,
			l_api_name,'invalid_action in UpdatePOActionHistory '
			|| l_progress);
        END IF;
        raise;
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in UpdatePOActionHistory '
			|| l_progress);
        END IF;
        raise;

END UpdatePOActionHistory;


PROCEDURE InsertPOActionHistory (p_object_id                    IN  NUMBER,
                                  p_object_type_code           IN  VARCHAR2,
                                   p_object_sub_type_code       IN  VARCHAR2,
                                   p_sequence_num               IN  NUMBER,
                                   p_action_code                IN  VARCHAR2,
                                   p_action_date                IN  DATE,
                                   p_employee_id                IN  NUMBER,
                                   p_approval_path_id           IN  NUMBER,
                                   p_note                       IN  VARCHAR2,
                                   p_object_revision_num        IN  NUMBER,
                                   p_offline_code               IN  VARCHAR2,
                                   p_request_id                 IN  NUMBER,
                                   p_program_application_id     IN  NUMBER,
                                   p_program_id                 IN  NUMBER,
                                   p_program_date               IN  DATE,
                                   p_user_id                    IN  NUMBER,
                                   p_login_id                   IN  NUMBER)
IS
-- pragma AUTONOMOUS_TRANSACTION;
        l_progress           VARCHAR2(240) ;
        l_sequence_num    PO_ACTION_HISTORY.sequence_num%TYPE := NULL;
	l_api_name varchar2(50) := ' InsertPOActionHistory';
	l_note po_action_history.note%type;

BEGIN



	l_progress := 'POS_WCAPPROVE_PVT.InsertPOActionHistory: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Enter in InsertPOActionHistory '
			|| l_progress);
        END IF;

   l_sequence_num := p_sequence_num;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_sequence_num '
			|| l_sequence_num);
        END IF;

   IF (l_sequence_num is NULL ) THEN --{


	l_progress := 'POS_WCAPPROVE_PVT.InsertPOActionHistory: 02.';

	SELECT MAX(sequence_num)
	INTO  l_sequence_num
	FROM  PO_ACTION_HISTORY
	WHERE object_id           = p_object_id
	AND   object_type_code    = p_object_type_code;

	l_progress := 'POS_WCAPPROVE_PVT.InsertPOActionHistory: 03.';

	IF (l_sequence_num IS NULL) THEN
		l_progress := 'POS_WCAPPROVE_PVT.InsertPOActionHistory: 04.';
		l_sequence_num := 0;
	ELSE
		l_progress := 'POS_WCAPPROVE_PVT.InsertPOActionHistory: 05.';
		 l_sequence_num := l_sequence_num + 1;
	END IF;

	l_progress := 'POS_WCAPPROVE_PVT.InsertPOActionHistory: 06.';


    END IF; --}

    l_progress := 'POS_WCAPPROVE_PVT.InsertPOActionHistory: 07.';

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_sequence_num before insert '
			|| l_sequence_num);
        END IF;



    INSERT INTO PO_ACTION_HISTORY
                (object_id,
                object_type_code,
                object_sub_type_code,
                sequence_num,
                last_update_date,
                last_updated_by,
                employee_id,
                action_code,
                action_date,
                note,
                object_revision_num,
                last_update_login,
                creation_date,
                created_by,
                request_id,
                program_application_id,
                program_id,
                program_date,
                approval_path_id,
                offline_code,
                program_update_date)
    VALUES (p_object_id,
                'WC',
                'WC',
                l_sequence_num,
                sysdate,
                p_user_id,
                p_employee_id,
                p_action_code,
                p_action_date,
                l_note,
                p_object_revision_num,
                p_login_id,
                sysdate,
                p_user_id,
                p_request_id,
                p_program_application_id,
                p_program_id,
                p_program_date,
                p_approval_path_id,
                p_offline_code,
                sysdate);


EXCEPTION
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in InsertPOActionHistory '
			|| l_progress);
        END IF;
        raise;

END InsertPOActionHistory;


procedure post_approval_notif (p_itemtype        in varchar2,
                               p_itemkey         in varchar2,
                               p_actid           in number,
                               p_funcmode        in varchar2,
                               x_resultout       out NOCOPY varchar2) IS

l_api_name                         varchar2(50) := p_itemkey || ' post_approval_notif';
l_notification_id                  number;
l_forwardTo                        varchar2(240);
l_result                           varchar2(100);
l_forward_to_username_response     varchar2(240) :='';
l_action                           po_action_history.action_code%TYPE;
l_new_recipient_id                 wf_roles.orig_system_id%TYPE;
l_origsys                          wf_roles.orig_system%TYPE;
l_shipment_line_id                 number;
l_shipment_header_id               number;
l_sequence_num                     number;



-- Bug 8479430 - START
-- Declare following context setting variables.
l_responder_id       fnd_user.user_id%TYPE;
l_session_user_id    NUMBER;
l_session_resp_id    NUMBER;
l_session_appl_id    NUMBER;
l_preparer_resp_id   NUMBER;
l_preparer_appl_id   NUMBER;
l_progress           VARCHAR2(1000);
l_preserved_ctx      VARCHAR2(5);
-- Bug 8479430 - END

/*
cursor get_shipment_lines(l_shipment_header_id number) is
select rsl.shipment_line_id
from rcv_shipment_lines rsl
where rsl.shipment_header_id = l_shipment_header_id;
*/

CURSOR get_action_history IS
SELECT  object_id,
        object_type_code,
        object_sub_type_code,
        sequence_num,
        object_revision_num,
        request_id,
        program_application_id,
        program_date,
        program_id,
        last_update_date,
        employee_id
FROM    PO_ACTION_HISTORY
WHERE   object_type_code = 'WC'
        AND  object_id  = l_shipment_header_id
        AND  sequence_num = l_sequence_num;

Recinfo get_action_history%ROWTYPE;

BEGIN

  l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 01.';
  IF (g_asn_debug = 'Y') THEN
    debug_log(FND_LOG.LEVEL_STATEMENT, l_api_name, 'Enter in post_approval_notif ' || l_progress);
    debug_log(FND_LOG.LEVEL_STATEMENT, l_api_name, 'p_itemtype ' || p_itemtype);
    debug_log(FND_LOG.LEVEL_STATEMENT, l_api_name, 'p_itemkey ' || p_itemkey);
    debug_log(FND_LOG.LEVEL_STATEMENT, l_api_name, 'p_actid ' || p_actid);
    debug_log(FND_LOG.LEVEL_STATEMENT, l_api_name, 'p_funcmode ' || p_funcmode);
  END IF;

  if (p_funcmode IN  ('FORWARD', 'QUESTION', 'ANSWER')) THEN
    if (p_funcmode = 'FORWARD') then
      l_action := 'DELEGATE';
    elsif (p_funcmode = 'QUESTION') then
      l_action := 'QUESTION';
    elsif (p_funcmode = 'ANSWER') then
      l_action := 'ANSWER';
    end if;

    l_shipment_header_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                        itemkey  => p_itemkey,
                                                        aname    => 'WORK_CONFIRMATION_ID');
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_shipment_header_id ' ||l_shipment_header_id);
    END IF;

    Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_NEW_ROLE, l_origsys, l_new_recipient_id);

    l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 02.';

    select max(sequence_num)
    into   l_sequence_num
    from   po_action_history
    where  object_type_code ='WC'
           and object_id = l_shipment_header_id;

    OPEN get_action_history;
    FETCH get_action_history INTO Recinfo;
      IF (get_action_history%NOTFOUND) then
        IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'no_data_round');
        END IF;
        RAISE NO_DATA_FOUND;
      END IF;
    CLOSE get_action_history;


    UpdatePOActionHistory( p_object_id => Recinfo.object_id,
                           p_object_type_code => Recinfo.object_type_code,
                           p_employee_id => Recinfo.employee_id,
                           p_action_code => l_action,
                           p_note => wf_engine.context_user_comment,
                           p_user_id => fnd_global.user_id,
                           p_login_id => fnd_global.login_id);


    InsertPOActionHistory( p_object_id => Recinfo.object_id,
                           p_object_type_code=>Recinfo.object_type_code,
                           p_object_sub_type_code => NULL,
                           p_sequence_num => Recinfo.sequence_num+1 ,
                           p_action_code =>NULL ,
                           p_action_date =>NULL ,
                           p_employee_id => l_new_recipient_id,
                           p_approval_path_id  => NULL ,
                           p_note => NULL,
                           p_object_revision_num => NULL,
                           p_offline_code =>  NULL,
                           p_request_id =>  Recinfo.request_id,
                           p_program_application_id => Recinfo.program_application_id,
                           p_program_id =>Recinfo.program_id ,
                           p_program_date => Recinfo.program_date ,
                           p_user_id => fnd_global.user_id  ,
                           p_login_id => fnd_global.login_id);

    x_resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
    return;
  end if;

  if (p_funcmode = 'RESPOND') then
    l_notification_id := WF_ENGINE.context_nid;
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT, l_api_name, 'l_notification_id '||l_notification_id );
    END IF;

    l_result := wf_notification.GetAttrText(l_notification_id, 'RESULT');

    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT, l_api_name, 'l_result '||l_result );
    END IF;

    if (l_result = 'FORWARD') THEN

      l_forwardTo := wf_notification.GetAttrText(l_notification_id, 'FORWARD_TO_USERNAME_RESPONSE');
      l_forward_to_username_response := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                                   itemkey  => p_itemkey,
                                                                   aname    => 'FORWARD_TO_USERNAME_RESPONSE');

      if(l_forwardTo is null) then
        fnd_message.set_name('ICX', 'ICX_POR_WF_NOTIF_NO_USER');
        app_exception.raise_exception;
      end if;
    end if;


    /* Bug 8479430 - START
       Set the user context properly before launching the concurrent request*/

    if (wf_engine.preserved_context = TRUE) then
      l_preserved_ctx := 'TRUE';
    else
      l_preserved_ctx := 'FALSE';
    end if;

    l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 03.' ;

    -- <debug start>
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_progress ' ||l_progress);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_preserved_ctx ' ||l_preserved_ctx);
    END IF;
    -- <debug end>


    SELECT fu.USER_ID
    INTO   l_responder_id
    FROM   fnd_user fu,
           wf_notifications wfn
    WHERE  wfn.notification_id = l_notification_id
           AND wfn.original_recipient = fu.user_name;

    l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 04.' ;

    -- <debug start>
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_progress ' ||l_progress);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_responder_id ' ||l_responder_id);
    END IF;
    -- <debug end>

    l_session_user_id := fnd_global.user_id;
    l_session_resp_id := fnd_global.resp_id;
    l_session_appl_id := fnd_global.resp_appl_id;

    -- <debug start>
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_session_user_id ' ||l_session_user_id);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_session_resp_id ' ||l_session_resp_id);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_session_appl_id ' ||l_session_appl_id);
    END IF;
    -- <debug end>

    IF (l_session_user_id = -1) THEN
      l_session_user_id := NULL;
    END IF;

    IF (l_session_resp_id = -1) THEN
      l_session_resp_id := NULL;
    END IF;

    IF (l_session_appl_id = -1) THEN
      l_session_appl_id := NULL;
    END IF;

    -- <debug start>
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_session_user_id ' ||l_session_user_id);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_session_resp_id ' ||l_session_resp_id);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_session_appl_id ' ||l_session_appl_id);
    END IF;
    -- <debug end>

    l_preparer_resp_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                      itemkey  => p_itemkey,
                                                      aname   => 'RESPONSIBILITY_ID');
    l_preparer_appl_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                      itemkey  => p_itemkey,
                                                      aname   => 'APPLICATION_ID');

    l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 05.' ;

    -- <debug start>
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_progress ' ||l_progress);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_preparer_resp_id ' ||l_preparer_resp_id);
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_preparer_appl_id ' ||l_preparer_appl_id);
    END IF;
    -- <debug end>

    if (l_responder_id is not null) then
      if (l_responder_id <> l_session_user_id) then
        /* possible in 2 scenarios :
           1. when the response is made from email using guest user feature
	         2. When the response is made from sysadmin login
        */

        l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 06.' ;

        -- <debug start>
        IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_progress ' ||l_progress || 'When the response is made from email using guest user feature');
        END IF;
        -- <debug end>

        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_USER_ID',
                                    avalue  => l_responder_id);
        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_RESP_ID',
                                    avalue  => l_preparer_resp_id);
        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_APPL_ID',
                                    avalue  => l_preparer_appl_id);
      ELSE
        l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 07.' ;

        -- <debug start>
        IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_progress ' ||l_progress || 'When the response is made from sysadmin login');
        END IF;
        -- <debug end>

        if (l_session_resp_id is null) THEN
	        /* possible when the response is made from the default worklist
	           without choosing a valid responsibility */
          l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 08.' ;

          -- <debug start>
          IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_progress ' ||l_progress || 'When the response is made from the default worklist');
          END IF;
          -- <debug end>

          wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_USER_ID',
                                      avalue  => l_responder_id);
          wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_RESP_ID',
                                      avalue  => l_preparer_resp_id);
          wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_APPL_ID',
                                      avalue  => l_preparer_appl_id);
        else
	  /* All values available - possible when the response is made after choosing a correct responsibility */
          /* If the values of responsibility_id and application
	           id are available but are incorrect. This may happen when a response is made
	           through the email or the background process picks the wf up.
	           This may happen due to the fact that the mailer / background process
	           carries the context set by the notification /wf it processed last */

          l_progress := 'POS_WCAPPROVE_PVT.post_approval_notif: 09.' ;

          -- <debug start>
          IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,'l_progress ' ||l_progress || 'When the response is made after choosing a correct responsibility');
          END IF;
          -- <debug end>


          if ( l_preserved_ctx = 'TRUE') then
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_USER_ID',
                                        avalue  => l_responder_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_RESP_ID',
                                        avalue  => l_session_resp_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_APPL_ID',
                                        avalue  => l_session_appl_id);
          else
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_USER_ID',
                                        avalue  => l_responder_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_RESP_ID',
                                        avalue  => l_preparer_resp_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_APPL_ID',
                                        avalue  => l_preparer_appl_id);
          end if;
        end if;
      end if;
    end if;

    -- Bug 8479430 - END

    x_resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
    return;
  end if;


EXCEPTION
  when no_data_found then
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_UNEXPECTED, l_api_name, 'No data found in post_approval_notif ' || l_progress);
    END IF;
    raise;

  when others then
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_UNEXPECTED, l_api_name,'Exception in post_approval_notif ' || l_progress);
    END IF;
    raise;
END post_approval_notif;

procedure reject_doc
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) IS

l_progress varchar2(300);
l_api_name varchar2(50) :=  p_itemkey ||' reject_doc';
l_approval_status rcv_shipment_headers.approval_status%type := 'REJECTED';
l_result varchar2(3);
l_shipment_header_id number;
l_po_header_id number;
l_work_confirmation_number varchar2(30);
l_note varchar2(4000);
l_view_wc_lines_detail_url varchar2(1000);
begin
	l_progress := 'POS_WCAPPROVE_PVT.reject_doc: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in reject_doc '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	l_progress := 'POS_WCAPPROVE_PVT.reject_doc: 02.';
	l_shipment_header_id := wf_engine.GetItemAttrNumber
                                (itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'WORK_CONFIRMATION_ID');



	update_approval_status(p_shipment_header_id => l_shipment_header_id,
                               p_note => null,
                               p_approval_status => l_approval_status,
			       p_level => 'HEADER',
                               x_resultout => l_result);


	l_progress := 'POS_WCAPPROVE_PVT.reject_doc: 03.';
	IF (l_result = 'N') THEN

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					'Could not Reject the document '
				|| l_progress);
		END IF;
		x_resultout := wf_engine.eng_completed || ':' || 'N';
	END IF;

	IF (l_result = 'Y') THEN

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					'Rejected the document '
				|| l_progress);
		END IF;
	wf_engine.SetItemAttrText (   itemtype   => p_itemtype,
                                      itemkey    => p_itemkey,
                                      aname      => 'DOC_STATUS',
                                      avalue     => 'REJECTED');


	l_po_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'PO_DOCUMENT_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_po_header_id ' || l_po_header_id);
        END IF;

	l_work_confirmation_number :=
                                wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_NUMBER');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_work_confirmation_number ' || l_work_confirmation_number);
        END IF;

	-- bug 10012891 - encoding value of work confirmation number as per http standards
        l_view_wc_lines_detail_url :=
                'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pos/wc/webui/WcDetailsPG' || '&' ||
                            'WcStatus=REJECTED' || '&' ||
                            'PoHeaderId=' || to_char(l_po_header_id) || '&' ||
                            'WcHeaderId=' || to_char(l_shipment_header_id) || '&' ||
                            'WcNum=' || (wfa_html.encode_url(l_work_confirmation_number)) || '&' ||
                           -- 'ReadOnly=Y'  || '&' ||
                            'addBreadCrumb=Y';

        wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'VIEW_WC_LINES_DETAIL_URL' ,
                              avalue     => l_view_wc_lines_detail_url);
		x_resultout := wf_engine.eng_completed || ':' || 'Y';
	END IF;
EXCEPTION
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in reject_doc '
			|| l_progress);
        END IF;
        raise;

END reject_doc;

procedure Approve_doc
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) IS

l_progress varchar2(300);
l_api_name varchar2(50) := p_itemkey || ' Approve_doc';
l_approval_status rcv_shipment_headers.approval_status%type := 'APPROVED';
l_result varchar2(3);
l_shipment_header_id number;
l_po_header_id number;
l_note varchar2(4000);
l_view_wc_lines_detail_url varchar2(1000);
l_work_confirmation_number varchar2(30);
begin
	l_progress := 'POS_WCAPPROVE_PVT.Approve_doc: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in Approve_doc '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	l_progress := 'POS_WCAPPROVE_PVT.Approve_doc: 02.';
	l_shipment_header_id := wf_engine.GetItemAttrNumber
                                (itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'WORK_CONFIRMATION_ID');


	update_approval_status(p_shipment_header_id => l_shipment_header_id,
			       p_note => null,
			       p_approval_status => l_approval_status,
			       p_level => 'HEADER',
			       x_resultout => l_result);

	l_progress := 'POS_WCAPPROVE_PVT.Approve_doc: 03.';
	IF (l_result = 'N') THEN

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					'Could not Reject the document '
				|| l_progress);
		END IF;
		x_resultout := wf_engine.eng_completed || ':' || 'N';
	END IF;

	IF (l_result = 'Y') THEN

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,
					'Approved the document '
				|| l_progress);
		END IF;
	wf_engine.SetItemAttrText (   itemtype   => p_itemtype,
                                      itemkey    => p_itemkey,
                                      aname      => 'DOC_STATUS',
                                      avalue     => 'APPROVED');

	l_po_header_id := wf_engine.GetItemAttrNumber
					(itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'PO_DOCUMENT_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_po_header_id ' || l_po_header_id);
        END IF;

	l_work_confirmation_number :=
                                wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => 'WORK_CONFIRMATION_NUMBER');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'l_work_confirmation_number ' || l_work_confirmation_number);
        END IF;

	-- bug 10012891 - encoding value of work confirmation number as per http standards
        l_view_wc_lines_detail_url :=
                'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pos/wc/webui/WcDetailsPG' || '&' ||
                            'WcStatus=APPROVED' || '&' ||
                            'PoHeaderId=' || to_char(l_po_header_id) || '&' ||
                            'WcHeaderId=' || to_char(l_shipment_header_id) || '&' ||
                            'WcNum=' || (wfa_html.encode_url(l_work_confirmation_number)) || '&' ||
                            --'ReadOnly=Y'  || '&' ||
                            'addBreadCrumb=Y';

        wf_engine.SetItemAttrText ( itemtype   => p_itemType,
                              itemkey    => p_itemkey,
                              aname      => 'VIEW_WC_LINES_DETAIL_URL' ,
                              avalue     => l_view_wc_lines_detail_url);

		x_resultout := wf_engine.eng_completed || ':' || 'Y';
	END IF;
EXCEPTION
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Approve_doc '
			|| l_progress);
        END IF;
        raise;

END Approve_doc;

procedure update_approval_status
			   (p_shipment_header_id in number,
                            p_note         in varchar2,
                            p_approval_status in varchar2,
			    p_level           in varchar2,
                            x_resultout       out NOCOPY varchar2) IS

cursor lock_rsh(l_shipment_header_id number) is
select null
from rcv_shipment_headers
where shipment_header_id  = l_shipment_header_id
for update of shipment_header_id nowait;

resource_busy_exc   EXCEPTION;
-- pragma EXCEPTION_INIT(resource_busy_exc, -00054);

l_locked_doc        BOOLEAN := FALSE;
l_shipment_header_id number;
l_progress varchar2(300);
l_api_name varchar2(50) := ' update_approval_status';
l_note po_action_history.note%type;
begin
	l_progress := 'POS_WCAPPROVE_PVT.update_approval_status: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in update_approval_status '
			|| l_progress);
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'p_note '
			|| p_note);
        END IF;




	If (p_level = 'HEADER') then
		for i in 1..1000
		loop
		begin
			/* Opening the cursor will lock the row */
			Open lock_rsh(p_shipment_header_id);
			Close lock_rsh;

			l_locked_doc := TRUE;

			  EXIT;

		EXCEPTION
		  WHEN resource_busy_exc THEN
		    NULL;
		END;

		end loop;

		IF (NOT l_locked_doc) THEN

			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_STATEMENT,
						l_api_name,'Could not lock row '
					|| l_progress);
			END IF;
			ROLLBACK;
			x_resultout :=  'N';
			return;

		END IF;

		update rcv_shipment_headers
		set approval_status = p_approval_status,
		    comments = nvl(p_note,comments)
		where shipment_header_id = p_shipment_header_id;
	end if;


	If (p_level = 'LINES') then
		/* If p_level is lines, then it can
		 * come directly from notificatiion.
		 * So update the header with the comments.
		*/
		update rcv_shipment_lines
		set approval_status = p_approval_status
		where shipment_header_id=p_shipment_header_id ;

		update rcv_shipment_headers
		set comments = nvl(p_note,comments)
		where shipment_header_id = p_shipment_header_id;
	end if;

	x_resultout :=  'Y';
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in update_approval_status '
			|| l_progress);
        END IF;
        raise;

END update_approval_status;

procedure insert_into_rti(p_itemtype in varchar2,
							p_itemkey  in varchar2,
							p_actid    in number,
							p_funcmode in varchar2,
							x_resultout out NOCOPY varchar2) IS

l_progress varchar2(300);
l_api_name varchar2(50) := p_itemkey || ' insert_into_rti';
l_shipment_header_id  number;

Cursor get_wcr_info(l_shipment_header_id number) is
SELECT rsl.po_line_location_id,
pll.unit_meas_lookup_code,
rsl.unit_of_measure unit_of_measure,
rsl.unit_of_measure primary_unit_of_measure,
rsl.unit_of_measure source_doc_unit_of_measure,
NVL(pll.promised_date, pll.need_by_date) promised_date,
rsl.to_organization_id ship_to_organization_id,
null quantity_ordered,
null amount_ordered,
NVL(pll.price_override, pl.unit_price) po_unit_price,
pll.match_option,
rsl.category_id,
rsl.item_description,
pl.po_line_id,
ph.currency_code,
ph.rate_type currency_conversion_type,
ph.segment1 document_num,
null po_distribution_id, --pod.po_distribution_id,
rsl.req_distribution_id,
rsl.requisition_line_id,
rsl.deliver_to_location_id deliver_to_location_id,
rsl.deliver_to_location_id location_id,
rsl.deliver_to_person_id,
null currency_conversion_date, --pod.rate_date currency_conversion_date,
null currency_conversion_rate, --pod.rate currency_conversion_rate,
rsl.destination_type_code destination_type_code,
rsl.destination_type_code destination_context,
null charge_account_id, --pod.code_combination_id ,
null destination_organization_id, --pod.destination_organization_id,
null subinventory, --pod.destination_subinventory ,
rsl.ship_to_location_id,
rsl.comments,
rsl.attribute_category attribute_category,
rsl.attribute1 attribute1,
rsl.attribute2 attribute2,
rsl.attribute3 attribute3,
rsl.attribute4 attribute4,
rsl.attribute5 attribute5,
rsl.attribute6 attribute6,
rsl.attribute7 attribute7,
rsl.attribute8 attribute8,
rsl.attribute9 attribute9,
rsl.attribute10 attribute10,
rsl.attribute11 attribute11,
rsl.attribute12 attribute12,
rsl.attribute13 attribute13,
rsl.attribute14 attribute14,
rsl.attribute15 attribute15,
NVL(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code,
rsl.shipment_line_id,
rsl.item_id,
rsl.item_revision,
rsh.vendor_id,
rsh.shipment_num,
rsh.freight_carrier_code,
rsh.bill_of_lading,
rsh.packing_slip,
rsh.shipped_date,
rsh.expected_receipt_date,
rsh.waybill_airbill_num ,
rsh.vendor_site_id,
rsl.to_organization_id,
rsl.routing_header_id,
rsl.vendor_item_num,
rsl.vendor_lot_num,
rsl.ussgl_transaction_code,
rsl.government_context,
pll.po_header_id,
ph.revision_num po_revision_num,
pl.line_num document_line_num,
pll.shipment_num document_shipment_line_num,
null document_distribution_num , --pod.distribution_num
pll.po_release_id,
pl.job_id,
ph.org_id,
rsl.amount_shipped amount,
rsl.quantity_shipped  quantity,
rsl.quantity_shipped  source_doc_quantity,
rsl.quantity_shipped  primary_quantity,
rsl.quantity_shipped  quantity_shipped,
rsl.amount_shipped amount_shipped,
rsl.requested_amount requested_amount,
rsl.material_stored_amount material_stored_amount,
pll.matching_basis,
NULL project_id,
NULL task_id
FROM
--po_distributions_all pod,
po_line_locations_all pll,
po_lines_all pl,
po_headers_all ph,
rcv_shipment_lines rsl,
rcv_shipment_headers rsh
WHERE
rsh.shipment_header_id = l_shipment_header_id
and rsl.shipment_header_id =  rsh.shipment_header_id
and rsl.po_header_id =  ph.po_header_id
--and pod.po_header_id = ph.po_header_id
--and pod.line_location_id = pll.line_location_id
and rsl.po_line_id =  pl.po_line_id
and rsl.po_line_location_id =  pll.line_location_id
and rsh.receipt_source_code = 'VENDOR'
and pll.po_line_id = pl.po_line_id
AND NVL(pll.approved_flag, 'N') = 'Y'
AND NVL(pll.cancel_flag, 'N') = 'N'
AND pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED','PREPAYMENT');


wcr_line_info get_wcr_info%rowtype;

/* Bug 6709928 -- Added columns destination_type_code,destination_type_code
   to the cursor get_dist_info*/
cursor get_dist_info(l_line_location_id number) is
select pod.po_distribution_id,
pod.rate_date currency_conversion_date,
pod.rate currency_conversion_rate,
pod.code_combination_id charge_account_id,
pod.destination_organization_id,
pod.destination_subinventory subinventory,
pod.distribution_num document_distribution_num,
pod.quantity_ordered,
pod.amount_ordered,
pod.destination_type_code destination_type_code,
pod.destination_type_code destination_context,
pod.project_id project_id,
pod.task_id
from po_distributions_all pod
where pod.line_location_id = l_line_location_id
order by pod.distribution_num;

/* Bug 11869822 */

cursor get_shipment_lines(l_shipment_header_id number) is
select rsl.shipment_line_id
from rcv_shipment_lines rsl
where rsl.shipment_header_id = l_shipment_header_id;


X_emp_id number;
X_emp_name per_employees_current_x.full_name%TYPE;
X_location_id number;
X_location_code hr_locations_all.location_code%TYPE;
X_is_buyer BOOLEAN;
X_emp_flag  BOOLEAN;
l_emp_ok  BOOLEAN;
l_uom_code mtl_units_of_measure.uom_code%type;
l_row_id varchar2(40);
l_interface_id number;
l_group_id number;
l_vendor_id number;
l_vendor_site_id number;
l_ship_to_org_id number;
l_ship_to_location_id number;
l_header_interface_id number;
l_expected_receipt_date date;
l_shipment_num varchar2(50);
l_receipt_num varchar2(50);
l_matching_basis varchar2(35);
l_remaining_amount number;
l_old_remaining_amount number;
l_transacted_amount number;
l_interface_amount number;
l_available_amount number;
l_remaining_quantity number;
l_old_remaining_quantity number;
l_transacted_quantity number;
l_interface_quantity number;
l_available_quantity number;
--l_first_time boolean := TRUE;
l_insert_into_rti boolean := TRUE;
l_max_dist NUMBER;
l_dist_count NUMBER;
l_carry_over_amount NUMBER;
l_carry_over_quantity NUMBER;

-- added for wc correction ER - bug 9414650
l_req_amount_inserted BOOLEAN := FALSE;
l_mat_stored_inserted BOOLEAN := FALSE;

l_primary_quantity_in NUMBER;

/* Added for the Bug #: 13924722 */
l_currency_conversion_rate  po_distributions_all.rate%TYPE;
l_currency_conversion_date  po_distributions_all.rate_date%TYPE;
x_sob_Id NUMBER;
/* End of Bug #: 13924722  */

begin
    l_progress := 'POS_WCAPPROVE_PVT.insert_into_rti: 01.';
    IF (g_asn_debug = 'Y') THEN
    	debug_log(FND_LOG.LEVEL_STATEMENT,
		l_api_name,
		'Enter in insert_into_rti '
		|| l_progress);
    END IF;

	if (p_funcmode <> wf_engine.eng_run) then
        x_resultout := wf_engine.eng_null;
        return;
    end if;

	l_shipment_header_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
								itemkey  => p_itemkey,
								aname    => 'WORK_CONFIRMATION_ID');


	SELECT rcv_headers_interface_s.NEXTVAL
	INTO l_header_interface_id
	FROM SYS.DUAL;

	select rcv_interface_groups_s.nextval
	into l_group_id
	from dual;

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_header_interface_id ' ||
				l_header_interface_id ||
				' l_group_id ' || l_group_id);
	END IF;

	wf_engine.SetItemAttrNumber (itemtype   => p_itemtype,
                                 itemkey    => p_itemkey,
                                 aname      => 'INTERFACE_GROUP_ID',
                                 avalue     => l_group_id);

	l_emp_ok := po_employees_sv.get_employee (X_emp_id,
	X_emp_name, X_location_id, X_location_code,
	X_is_buyer, X_emp_flag );

	IF (g_asn_debug = 'Y') THEN
		debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'x_emp_id ' ||
				x_emp_id);
	END IF;

	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'before cursor open');
	END IF;

	/* ******************************************************************
	Bug 8810238 - enabling over receiving functionality during creation of
	                           work confirmations for complex Purchase orders.

	Modified the earlier logic used to insert data in RTI tables, since it was not populating data correctly in the RTI tables.
	Removed the earlier commented code to incorporate the new logic.
	Please refer to comments and detailed technical resolution data in bug 88100238 BCT for more information

	******************************************************************** */

	-- opening the work confirmation cursor at pay item level
	open get_wcr_info(l_shipment_header_id);
	-- looping through the pay items associated with the current work confirmation
	loop --{

		l_progress := 'POS_WCAPPROVE_PVT.insert_into_rti:02.';

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
		    l_api_name,'before cursor fetch');
		END IF;

		fetch get_wcr_info into wcr_line_info;
		exit when get_wcr_info%notfound;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
		    l_api_name,'l_shipment_line_id ' ||
		    wcr_line_info.shipment_line_id);
		END IF;

		If (wcr_line_info.unit_of_measure is not null) then
			select  muom.uom_code
			into l_uom_code
			from mtl_units_of_measure muom
			WHERE  muom.unit_of_measure = wcr_line_info.unit_of_measure;

			IF (g_asn_debug = 'Y') THEN
				debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'l_uom_code ' ||
					l_uom_code);
			END IF;

		end if;

		IF (g_asn_debug = 'Y') THEN
			debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'before cursor open');
		END IF;

		l_matching_basis:= wcr_line_info.matching_basis;

		If (l_matching_basis = 'AMOUNT') then
			l_remaining_amount:= wcr_line_info.amount_shipped;
		end if;

		If (l_matching_basis = 'QUANTITY') then
			l_remaining_quantity:= wcr_line_info.quantity_shipped;
		end if;

		-- getting the number of distributions associated at the current pay item level
		SELECT Count(*)
    		INTO l_max_dist
    		FROM po_distributions_all pod
    		where pod.line_location_id = wcr_line_info.po_line_location_id;

    		l_dist_count := 0;

    -- added for wc correction ER - bug 9414650
    -- the following two attributes take care that the requested amount and material stored values get updated only for the
    -- first distribution, and for the subsequent distributions they are entered as null.
    -- ( should these be entered as null or zero ?)
    -- entering them as null since for amount, quantity we insert null value for unpopulated distributions

    l_req_amount_inserted := FALSE;
    l_mat_stored_inserted := FALSE;

    -- opening the cursor for fetching distribution level information into the wcr record to be inserted into RTI
		open get_dist_info(wcr_line_info.po_line_location_id);

		-- looping through the distributions cursor to insert data in RTI
    		loop --{
			l_progress := 'POS_WCAPPROVE_PVT.insert_into_rti:03.';

			IF (g_asn_debug = 'Y') THEN
				debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'before cursor fetch');
			END IF;

			/* Bug 6709928 ,getting the destination_type_code,destination_type_context*/
			fetch get_dist_info into
				wcr_line_info.po_distribution_id,
				wcr_line_info.currency_conversion_date,
				wcr_line_info.currency_conversion_rate,
				wcr_line_info.charge_account_id,
				wcr_line_info.destination_organization_id,
				wcr_line_info.subinventory,
				wcr_line_info.document_distribution_num,
				wcr_line_info.quantity_ordered,
				wcr_line_info.amount_ordered,
        		wcr_line_info.destination_type_code,
        		wcr_line_info.destination_context,
				wcr_line_info.project_id,
				wcr_line_info.task_id;
				exit when get_dist_info%notfound or
				(l_matching_basis = 'AMOUNT' and l_remaining_amount <= 0)
				or
				(l_matching_basis = 'QUANTITY' and l_remaining_quantity <= 0);

      			l_dist_count := l_dist_count + 1;

      			IF (g_asn_debug = 'Y') THEN
        			debug_log(FND_LOG.LEVEL_STATEMENT,
                 			l_api_name,'l_distribution_id ' ||
				        wcr_line_info.po_distribution_id);
      			END IF;

			IF (g_asn_debug = 'Y') THEN
				debug_log(FND_LOG.LEVEL_STATEMENT,
					l_api_name,'matching_basis '||l_matching_basis  );
			END IF;

			-- set the work confirmation variables for service based lines
			If (l_matching_basis = 'AMOUNT') then--{

				/* l_transacted_amount = amount which was transacted earlier than the submission of
				current work confirmation for this payitem / distribution */
				select nvl(sum(amount),0)
				into l_transacted_amount
				from rcv_transactions
				where po_distribution_id= wcr_line_info.po_distribution_id
				and destination_type_code = 'RECEIVING';

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
						l_api_name,'l_transacted_amount '||
						l_transacted_amount  );
				END IF;

				/* l_interface_amount = amount which is in the interface tables /pending to be approved / rejected before the submission of
				current work confirmation for this payitem / distribution */
				select nvl(sum(amount),0)
				into l_interface_amount
				from rcv_transactions_interface
				where po_distribution_id= wcr_line_info.po_distribution_id
				and processing_status_code='PENDING'
				and transaction_status_code = 'PENDING'
				and transaction_type = 'RECEIVE';

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
						l_api_name,'l_interface_amount '||
						l_interface_amount  );
				END IF;

				/* l_available_amount = actual amount left to be transacted for the current pay item */
				l_available_amount := wcr_line_info.amount_ordered - (l_transacted_amount + l_interface_amount);

        			/* l_carry_over_amount = actual amount left to be transacted over to the next distribution
				for the current pay item after the current distribution is considered */
				l_carry_over_amount := l_remaining_amount - l_available_amount;

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
							l_api_name,'l_available_amount '||
							l_available_amount  );
				END IF;

        			-- check if this is the last distribution for the pay item
			    	IF (l_dist_count >= l_max_dist) THEN
					-- last distribution for pay item, insert the l_remaining_amount completely
				    	wcr_line_info.amount := l_remaining_amount;
				    	l_remaining_amount := 0;

              -- added this code to correct the population of requested_amount and
              -- material stored amount correctly in the RTI table
              -- earlier all the distributions were getting populated with same value
              -- now only the first distribution which is accessed by the above logic is populated with
              -- these two values

              IF(l_req_amount_inserted) THEN
                wcr_line_info.requested_amount := null;
              END IF;

              IF(l_mat_stored_inserted) THEN
                wcr_line_info.material_stored_amount := null;
              END IF;

              l_req_amount_inserted := TRUE;
              l_mat_stored_inserted := TRUE;
				    	l_insert_into_rti := TRUE;

			    	ELSE
				    	-- not the last distribution for the pay item, check if we need to insert or not
				    	IF(l_available_amount > 0) THEN
					    	-- this distribution is not yet completely filled,
					    	-- so we "need to insert" depending on l_remaining_amount and l_available_amount
					    	IF(l_carry_over_amount > 0) THEN
							-- the shipped amount is greater than the l_available_amount
							wcr_line_info.amount := l_available_amount;
						    	l_remaining_amount := l_remaining_amount - l_available_amount;


					    	ELSE
							-- the shipped amount is lesser than the l_available_amount
						    	wcr_line_info.amount := l_remaining_amount;
						    	l_remaining_amount := 0;



					    	END IF;

                -- added this code to correct the population of requested_amount and
                -- material stored amount correctly in the RTI table
                -- earlier all the distributions were getting populated with same value
                -- now only the first distribution which is accessed by the above logic is populated with
                -- these two values
                IF(l_req_amount_inserted) THEN
                  wcr_line_info.requested_amount := null;
                END IF;

                IF(l_mat_stored_inserted) THEN
                  wcr_line_info.material_stored_amount := null;
                END IF;

                l_req_amount_inserted := TRUE;
                l_mat_stored_inserted := TRUE;

				        l_insert_into_rti := TRUE;

            ELSE

					  -- l_available_amount < 0, so "no need to insert"
            l_insert_into_rti := FALSE;

					  END IF;

				END IF;

			-- set the work confirmation variables for quantity based lines
			elsif (l_matching_basis = 'QUANTITY') then --}{

				/* l_transacted_quantity = quantity which was transacted earlier than the submission of
				current work confirmation for this payitem / distribution */
				select nvl(sum(quantity),0)
				into l_transacted_quantity
				from rcv_transactions
				where po_distribution_id= wcr_line_info.po_distribution_id
				and destination_type_code = 'RECEIVING';

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
						l_api_name,'l_transacted_quantity '||
						l_transacted_quantity  );
				END IF;

				/* l_interface_quantity = quantity which is in the interface tables /pending to be approved / rejected before the submission of
				current work confirmation for this payitem / distribution */
				select nvl(sum(quantity),0)
				into l_interface_quantity
				from rcv_transactions_interface
				where po_distribution_id= wcr_line_info.po_distribution_id
				and processing_status_code='PENDING'
				and transaction_status_code = 'PENDING'
				and transaction_type = 'RECEIVE';

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
						l_api_name,'l_interface_quantity '||
						l_interface_quantity  );
				END IF;

				/* l_available_quantity = actual quantity left to be transacted for the current pay item */
				l_available_quantity := wcr_line_info.quantity_ordered - (l_transacted_quantity + l_interface_quantity);

				/* l_carry_over_quantity = actual quantity left to be transacted over to the next distribution
				for the current pay item after the current distribution is considered */
        l_carry_over_quantity := l_remaining_quantity - l_available_quantity;

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
						l_api_name,'l_available_quantity '||
						l_available_quantity  );
				END IF;

        -- check if this is the last distribution for the pay item
        IF (l_dist_count >= l_max_dist) THEN
        -- last distribution for pay item, insert the l_remaining_quantity completely
          wcr_line_info.quantity := l_remaining_quantity;
          l_remaining_quantity := 0;
          l_insert_into_rti := TRUE;

        ELSE
          				-- not the last distribution for the pay item, check if we need to insert or not
          				IF(l_available_quantity > 0) THEN
            					-- this distribution is not yet completely filled,
            					-- so we "need to insert" depending on l_remaining_quantity and l_available_quantity
            					IF(l_carry_over_quantity > 0) THEN
              						-- the shipped quantity is greater than the l_available_quantity
              						wcr_line_info.quantity := l_available_quantity;
              						l_remaining_quantity := l_remaining_quantity - l_available_quantity;

            					ELSE
              						-- the shipped quantity is lesser than the l_available_quantity
              						wcr_line_info.quantity := l_remaining_quantity;
              						l_remaining_quantity := 0;

						END IF;

            					l_insert_into_rti := TRUE;

          				ELSE
            					-- l_available_amount < 0, so "no need to insert"
            					l_insert_into_rti := FALSE;

					END IF;

        			END IF;

			end if;	--}

			/* end of code changes for bug 8810238 */

			If (l_insert_into_rti) then --{
				select rcv_transactions_interface_s.nextval
				into l_interface_id
				from dual;

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
							l_api_name,'l_interface_id ' || l_interface_id);
				END IF;

        IF(wcr_line_info.matching_basis = 'QUANTITY') THEN

          po_uom_s.uom_convert(from_quantity => wcr_line_info.quantity,
                               from_uom      => wcr_line_info.unit_of_measure,
                               item_id       => wcr_line_info.item_id,
                               to_uom        => wcr_line_info.primary_unit_of_measure,
                               to_quantity   => l_primary_quantity_in);

          wcr_line_info.primary_quantity := l_primary_quantity_in;

        END IF;

		        /*Added for the Bug #: 13924722 */
			IF(wcr_line_info.match_option = 'R') THEN
                IF (wcr_line_info.currency_conversion_type = 'User') THEN
                   l_currency_conversion_date := SYSDATE;
                   l_currency_conversion_rate  := wcr_line_info.currency_conversion_rate;
                ELSE
                   SELECT set_of_books_id
                                INTO   x_sob_Id
                                FROM   financials_system_parameters WHERE org_id = wcr_line_info.org_id;

                    l_currency_conversion_rate := gl_currency_api.get_rate(x_sob_Id,wcr_line_info.currency_code,sysdate,wcr_line_info.currency_conversion_type);
                    l_currency_conversion_rate := round(l_currency_conversion_rate,28);
					l_currency_conversion_date := SYSDATE;
                END IF;
            ELSIF (wcr_line_info.match_option = 'P') THEN
                l_currency_conversion_rate  := wcr_line_info.currency_conversion_rate;
                l_currency_conversion_date  := wcr_line_info.currency_conversion_date;
            END IF;

		    /* End of changes for Bug #: 13924722 */

				rcv_asn_interface_trx_ins_pkg.insert_row
			    (l_row_id,
			     l_interface_id,--interface_id
			     l_group_id, --group_id
			     sysdate, --last_updated_date
			     fnd_global.user_id, --last_updated_by,
			     sysdate, --creation_date,
			     fnd_global.login_id, --created_by,
			     fnd_global.login_id, -- last_update_login,
			     NULL, --request_id,
			     null, --program_application_id,
			     null, --program_id,
			     null, --program_update_date,
			     'RECEIVE', --transaction_type,
			     sysdate, --transaction_date,
			     'PENDING', --processing_status_code,
			     'IMMEDIATE', --processing_mode_code,
			     --'BATCH',
			     null, --processing_request_id,
			     'PENDING', --.transaction_status_code,
			     wcr_line_info.category_id,
			     wcr_line_info.quantity, --quantity
			     wcr_line_info.unit_of_measure,
			     'ISP', --.interface_source_code,
			     NULL, --.interface_source_line_id,
			     NULL, --.inv_transaction_id,
			     wcr_line_info.item_id,
			     wcr_line_info.item_description,
			     wcr_line_info.item_revision,
			     l_uom_code, --uom_code,
			     x_emp_id, --employee_id,
			     'DELIVER', --auto_transact_code,
			     l_shipment_header_id, --l_shipment_header_id
			     wcr_line_info.shipment_line_id,
			     wcr_line_info.ship_to_location_id,
			     wcr_line_info.primary_quantity,
			     wcr_line_info.primary_unit_of_measure,
			     'VENDOR', --.receipt_source_code,
			     wcr_line_info.vendor_id,
			     wcr_line_info.vendor_site_id,
			     NULL, --from_organization_id,
			     NULL, --from_subinventory,
			     wcr_line_info.to_organization_id,
			     NULL, --.intransit_owning_org_id,
			     wcr_line_info.routing_header_id,
			     NULL, --.routing_step_id,
			     'PO', --source_document_code,
			     NULL, --.parent_transaction_id,
			     wcr_line_info.po_header_id,
			     wcr_line_info.po_revision_num,
			     wcr_line_info.po_release_id,
			     wcr_line_info.po_line_id,
			     wcr_line_info.po_line_location_id,
			     wcr_line_info.po_unit_price,
			     wcr_line_info.currency_code,
			     wcr_line_info.currency_conversion_type,
				 l_currency_conversion_rate, --Bug #: 13924722 wcr_line_info.currency_conversion_rate
			     l_currency_conversion_date, --Bug #: 13924722 wcr_line_info.currency_conversion_date
			     wcr_line_info.po_distribution_id,
			     wcr_line_info.requisition_line_id,
			     wcr_line_info.req_distribution_id,
			     wcr_line_info.charge_account_id,
			     NULL, --.substitute_unordered_code,
			     NULL, --.receipt_exception_flag,
			     NULL, --.accrual_status_code,
			     'NOT INSPECTED' ,--.inspection_status_code,
			     NULL, --.inspection_quality_code,
			     wcr_line_info.destination_type_code,
			     wcr_line_info.deliver_to_person_id,
			     wcr_line_info.location_id,
			     wcr_line_info.deliver_to_location_id,
			     NULL, --.subinventory,
			     NULL, --.locator_id,
			     NULL, --.wip_entity_id,
			     NULL, --.wip_line_id,
			     NULL, --.department_code,
			     NULL, --.wip_repetitive_schedule_id,
			     NULL, --.wip_operation_seq_num,
			     NULL, --.wip_resource_seq_num,
			     NULL, --.bom_resource_id,
			     wcr_line_info.shipment_num,
			     wcr_line_info.freight_carrier_code,
			     wcr_line_info.bill_of_lading,
			     wcr_line_info.packing_slip,
			     wcr_line_info.shipped_date,
			     wcr_line_info.expected_receipt_date,
			     NULL, --.actual_cost,
			     NULL, --.transfer_cost,
			     NULL, --.transportation_cost,
			     NULL, --.transportation_account_id,
			     NULL, --.num_of_containers,
			     wcr_line_info.waybill_airbill_num,
			     wcr_line_info.vendor_item_num,
			     wcr_line_info.vendor_lot_num,
			     NULL,--.rma_reference,
			     wcr_line_info.comments,
			     wcr_line_info.attribute_category,
			     wcr_line_info.attribute1,
			     wcr_line_info.attribute2,
			     wcr_line_info.attribute3,
			     wcr_line_info.attribute4,
			     wcr_line_info.attribute5,
			     wcr_line_info.attribute6,
			     wcr_line_info.attribute7,
			     wcr_line_info.attribute8,
			     wcr_line_info.attribute9,
			     wcr_line_info.attribute10,
			     wcr_line_info.attribute11,
			     wcr_line_info.attribute12,
			     wcr_line_info.attribute13,
			     wcr_line_info.attribute14,
			     wcr_line_info.attribute15,
			     NULL, --.ship_head_attribute_category,
			     NULL, --.ship_head_attribute1,
			     NULL, --.ship_head_attribute2,
			     NULL, --.ship_head_attribute3,
			     NULL, --.ship_head_attribute4,
			     NULL, --.ship_head_attribute5,
			     NULL, --.ship_head_attribute6,
			     NULL, --.ship_head_attribute7,
			     NULL, --.ship_head_attribute8,
			     NULL, --.ship_head_attribute9,
			     NULL, --.ship_head_attribute10,
			     NULL, --.ship_head_attribute11,
			     NULL, --.ship_head_attribute12,
			     NULL, --.ship_head_attribute13,
			     NULL, --.ship_head_attribute14,
			     NULL, --.ship_head_attribute15,
			     NULL, --.ship_line_attribute_category,
			     NULL, --.ship_line_attribute1,
			     NULL, --.ship_line_attribute2,
			     NULL, --.ship_line_attribute3,
			     NULL, --.ship_line_attribute4,
			     NULL, --.ship_line_attribute5,
			     NULL, --.ship_line_attribute6,
			     NULL, --.ship_line_attribute7,
			     NULL, --.ship_line_attribute8,
			     NULL, --.ship_line_attribute9,
			     NULL, --.ship_line_attribute10,
			     NULL, --.ship_line_attribute11,
			     NULL, --.ship_line_attribute12,
			     NULL, --.ship_line_attribute13,
			     NULL, --.ship_line_attribute14,
			     NULL, --.ship_line_attribute15,
			     wcr_line_info.ussgl_transaction_code,
			     wcr_line_info.government_context,
			     NULL, --.reason_id,
			     wcr_line_info.destination_context,
			     wcr_line_info.source_doc_quantity,
			     wcr_line_info.source_doc_unit_of_measure,
			     NULL, --.movement_id,
			     NULL, --l_header_interface_id, --.header_interface_id,
			     NULL, --.vendor_cum_shipped_qty,
			     NULL, --.item_num,
			     wcr_line_info.document_num,
			     wcr_line_info.document_line_num,
			     NULL, --.truck_num,
			     NULL, --.ship_to_location_code,
			     NULL, --.container_num,
			     NULL, --.substitute_item_num,
			     NULL, --.notice_unit_price,
			     NULL, --.item_category,
			     NULL, --.location_code,
			     NULL, --.vendor_name,
			     NULL, --.vendor_num,
			     NULL, --.vendor_site_code,
			     NULL, --.from_organization_code,
			     NULL, --.to_organization_code,
			     NULL, --.intransit_owning_org_code,
			     NULL, --.routing_code,
			     NULL, --.routing_step,
			     NULL, --.release_num,
			     wcr_line_info.document_shipment_line_num,
			     wcr_line_info.document_distribution_num,
			     NULL, --.deliver_to_person_name,
			     NULL, --.deliver_to_location_code,
			     NULL, --.use_mtl_lot,
			     NULL, --.use_mtl_serial,
			     NULL, --.LOCATOR,
			     NULL, --.reason_name,
			     NULL, --.validation_flag,
           NULL, --.substitute_item_id,
			     NULL, --.quantity_shipped,
			     NULL, --.quantity_invoiced,
			     NULL, --.tax_name,
			     NULL, --.tax_amount,
			     NULL, --.req_num,
			     NULL, --.req_line_num,
			     NULL, --.req_distribution_num,
			     NULL, --.wip_entity_name,
			     NULL, --.wip_line_code,
			     NULL, --.resource_code,
			     NULL, --.shipment_line_status_code,
			     NULL, --.barcode_label,
			     NULL, --.country_of_origin_code,
			     NULL, --.from_locator_id, --WMS Change
			     NULL, --.qa_collection_id,
			     NULL, --.oe_order_header_id,
			     NULL, --.oe_order_line_id,
			     NULL, --.customer_id,
			     NULL, --.customer_site_id,
			     NULL, --.customer_item_num,
			     NULL, --.create_debit_memo_flag,
			     NULL, --.put_away_rule_id,
			     NULL, --.put_away_strategy_id,
			     NULL, --.lpn_id,
			     NULL, --.transfer_lpn_id,
			     NULL, --.cost_group_id,
			     NULL, --.mobile_txn,
			     NULL, --.mmtt_temp_id,
			     NULL, --.transfer_cost_group_id,
			     NULL, --.secondary_quantity,
			     NULL, --.secondary_unit_of_measure,
			     NULL, --.secondary_uom_code,
			     NULL, --.qc_grade,
			     NULL, --.oe_order_num,
			     NULL, --.oe_order_line_num,
			     NULL, --.customer_account_number,
			     NULL, --.customer_party_name,
			     NULL, --.source_transaction_num,
			     NULL, --.parent_source_transaction_num,
			     NULL, --.parent_interface_txn_id,
			     NULL, --.customer_item_id,
			     NULL, --.interface_available_qty,
			     NULL, --.interface_transaction_qty,
			     NULL, --.from_locator,
			     NULL, --.lpn_group_id,
			     NULL, --.order_transaction_id,
			     NULL, --.license_plate_number,
			     NULL, --.transfer_license_plate_number,
			     wcr_line_info.amount,
			     wcr_line_info.job_id,
			     wcr_line_info.project_id, --.project_id,
			     wcr_line_info.task_id, --.task_id,
			     NULL, --.asn_attach_id,
			     NULL, --.timecard_id,
			     NULL, --.timecard_ovn,
			     NULL, --.interface_available_amt,
			     NULL, --.interface_transaction_amt
			     wcr_line_info.org_id,  --<R12 MOAC>
			     wcr_line_info.matching_basis,
			     NULL, --wcr_line_info.amount_shipped, --amount_shipped
			     wcr_line_info.requested_amount,
			     wcr_line_info.material_stored_amount
				);

				IF (g_asn_debug = 'Y') THEN
					debug_log(FND_LOG.LEVEL_STATEMENT,
							l_api_name,'After insert '  );

				END IF;

			END IF; --}

		end loop; --}

		If get_dist_info%isopen then
			Close get_dist_info;
		end if;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Going to fetch the next shipment line if it exists '  );
		END IF;

	end loop; --}

	If get_wcr_info%isopen then
		Close get_wcr_info;
	end if;

	GenReceiptNum(l_shipment_header_id,l_receipt_num);
	IF (g_asn_debug = 'Y') THEN
	    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_receipt_num '||l_receipt_num);
	END IF;

	update rcv_shipment_headers
	set receipt_num= l_receipt_num,
	    employee_id = x_emp_id,
	    last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
	where shipment_header_id = l_shipment_header_id;

	IF (g_asn_debug = 'Y') THEN
		debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'Leave insert_into_rti '  );
	END IF;

	x_resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

	return;

exception

	when others then
        IF (g_asn_debug = 'Y') THEN
			debug_log(FND_LOG.LEVEL_UNEXPECTED,
					l_api_name,'Exception in insert_into_rti '
					|| l_progress);
		END IF;
    raise;

END insert_into_rti;



procedure Launch_RTP_Immediate
			   (p_itemtype        in varchar2,
                            p_itemkey         in varchar2,
                            p_actid           in number,
                            p_funcmode        in varchar2,
                            x_resultout       out NOCOPY varchar2) IS

l_progress varchar2(300);
l_result_id number;
l_group_id number;
l_api_name varchar2(50) := p_itemkey || ' Launch_RTP_Immediate';
begin
	l_progress := 'POS_WCAPPROVE_PVT.Launch_RTP_Immediate: 01.';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'Enter in Launch_RTP_Immediate '
			|| l_progress);
        END IF;

	if (p_funcmode <> wf_engine.eng_run) then
              x_resultout := wf_engine.eng_null;
              return;
         end if;

	l_group_id := wf_engine.GetItemAttrNumber
				(itemtype => p_itemtype,
				 itemkey  => p_itemkey,
				 aname    => 'INTERFACE_GROUP_ID');

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,
				'l_group_id '
			|| l_group_id);
        END IF;
	l_result_id :=
                fnd_request.submit_request('PO',
                'RVCTP',
                null,
                null,
                false,
                'IMMEDIATE',
		--'BATCH',
		l_group_id,
                --fnd_char.local_chr(0),
		NULL, -- Modified as part of P1 Bug #:16208460
                NULL,
                NULL,
                NULL,
                NULL,
                NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,

                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name, 'l_result_id '
			|| l_result_id);
        END IF;
	if (l_result_id <= 0 or l_result_id is null) then


		UPDATE rcv_transactions_interface
		set transaction_status_code = 'ERROR'
		 where group_id = l_group_id;



	end if;

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name, 'Leave RTP launch ' );
        END IF;
	x_resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
	return;

exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
				l_api_name,'Exception in Launch_RTP_Immediate '
			|| l_progress);
        END IF;
        raise;

END Launch_RTP_Immediate;

procedure CloseOldNotif
(
p_itemtype        in varchar2,
p_itemkey         in varchar2) IS
-- pragma AUTONOMOUS_TRANSACTION;
l_api_name varchar2(50) := p_itemkey || ' CloseOldNotif';
l_progress varchar2(300);
begin

	l_progress := 'POS_WCAPPROVE_PVT.CloseOldNotif: 01';

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Enter in CloseOldNotif ' || l_progress);
        END IF;
	update wf_notifications set status = 'CLOSED'
        where notification_id in (
           select ias.notification_id
             from wf_item_activity_statuses ias,
                  wf_notifications ntf
            where ias.item_type = p_itemtype
              and ias.item_key  = p_itemkey
              and ntf.notification_id  = ias.notification_id);


exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Exception in CloseOldNotif ' || l_progress);
        END IF;
        raise;
end CloseOldNotif;

procedure UpdateWorkflowInfo
(
p_itemtype        in varchar2,
p_itemkey         in varchar2,
p_shipment_header_id in varchar2) IS
-- pragma AUTONOMOUS_TRANSACTION;

l_api_name varchar2(50) := p_itemkey || ' UpdateWorkflowInfo';
l_progress varchar2(300);
begin

	l_progress := 'POS_WCAPPROVE_PVT.UpdateWorkflowInfo: 01';

        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'Enter in UpdateWorkflowInfo ' || l_progress);
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'p_itemtype ' || p_itemtype);
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'p_itemkey ' || p_itemkey);
            debug_log(FND_LOG.LEVEL_STATEMENT,
		l_api_name,'p_shipment_header_id ' || p_shipment_header_id);
        END IF;

        UPDATE rcv_shipment_headers
        SET WF_ITEM_TYPE = p_itemtype,
            WF_ITEM_KEY  = p_itemkey,
            last_updated_by         = fnd_global.user_id,
            last_update_login       = fnd_global.login_id,
            last_update_date        = sysdate
        WHERE  shipment_header_id = p_shipment_header_id;



            debug_log(FND_LOG.LEVEL_STATEMENT,
		l_api_name,'do i see this now? ' || p_shipment_header_id);
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Exception in UpdateWorkflowInfo ' || l_progress);
        END IF;
        raise;
end UpdateWorkflowInfo;

PROCEDURE Upd_ActionHistory_Submit (p_object_id            IN NUMBER,
                                 p_object_type_code     IN VARCHAR2,
                                 p_employee_id      IN NUMBER,
                                 p_sequence_num         IN NUMBER,
                                 p_action_code          IN VARCHAR2,
                                 p_user_id              IN NUMBER,
                                 p_login_id             IN NUMBER)
IS
-- pragma AUTONOMOUS_TRANSACTION;
l_api_name varchar2(50) :=  ' Upd_ActionHistory_Submit';
l_progress varchar2(280);
begin

	l_progress := 'POS_WCAPPROVE_PVT.Upd_ActionHistory_Submit: 01';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Enter in Upd_ActionHistory_Submit '
				|| l_progress);
        END IF;

                        UPDATE PO_ACTION_HISTORY
                          set object_id = p_object_id,
                              object_type_code = p_object_type_code,
                              sequence_num = p_sequence_num,
                              last_update_date = sysdate,
                              last_updated_by = p_user_id,
                              creation_date = sysdate,
                              created_by = p_user_id,
                              action_code = p_action_code,
                              action_date =  sysdate,
                              employee_id = p_employee_id,
                              last_update_login = p_login_id,
                              request_id = 0,
                              program_application_id = 0,
                              program_id = 0,
                              program_update_date = '',
                              offline_code = ''
                              WHERE
                              object_id= p_object_id and
                              object_type_code = p_object_type_code and
                              sequence_num = p_sequence_num;
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Exception in Upd_ActionHistory_Submit ' || l_progress);
        END IF;
        raise;
end Upd_ActionHistory_Submit;


PROCEDURE get_multiorg_context(p_document_id number,
                               x_orgid IN OUT NOCOPY number) IS
cursor get_po_orgid is
  select org_id
  from po_headers_all
  where po_header_id = p_document_id;

l_progress varchar2(300);
l_api_name varchar2(50) := ' get_multiorg_context';
begin
	l_progress := 'POS_WCAPPROVE_PVT.get_multiorg_context: 01';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,
                                l_api_name,'Enter in get_multiorg_context '
				|| l_progress);
        END IF;

	OPEN get_po_orgid;
	FETCH get_po_orgid into x_orgid;
	CLOSE get_po_orgid;
exception
        when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Exception in get_multiorg_context ' || l_progress);
        END IF;
        raise;
end get_multiorg_context;


FUNCTION Get_Approver_Name(p_approver_id IN NUMBER)
RETURN VARCHAR2 IS
    l_value  VARCHAR2(1000) := '';
  begin
    select distinct full_name
    into   l_value
    from   per_all_people_f hre
    where  hre.person_id = p_approver_id
    and trunc(sysdate) BETWEEN effective_start_date
        and effective_end_date;

    if l_value is null then
	l_value := null;
    end if;
    return l_value;
  exception
     when others then
        return null;

end Get_Approver_Name;

FUNCTION Get_PoHeaderId(p_shipment_header_id IN NUMBER)
RETURN NUMBER IS
l_progress varchar2(500);
l_po_header_id number;
l_api_name varchar2(50) := 'get_PoHeaderId';
begin
	l_progress := 'POS_WCAPPROVE_PVT.get_PoHeaderId: 01';
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Enter in get_PoHeaderId ' || l_progress);
        END IF;

        select max(po_header_id)
        into l_po_header_id
        from rcv_shipment_lines
        where shipment_header_id = p_shipment_header_id;

	return l_po_header_id;

  exception
     when others then
        IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_UNEXPECTED,
                                l_api_name,'Exception in get_PoHeaderId ' || l_progress);
        END IF;
        raise;

end Get_PoHeaderId;

   PROCEDURE GenReceiptNum(
	p_shipment_header_id IN number,
	x_receipt_num IN OUT nocopy Varchar2
   ) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
l_count number;
l_ship_to_org_id number;
l_api_name varchar2(50) := ' GenReceiptNum';
   BEGIN

		select ship_to_org_id
		into l_ship_to_org_id
		from rcv_shipment_headers
		where shipment_header_id=p_shipment_header_id;

		 IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,
				l_api_name,'l_ship_to_org_id '
				||l_ship_to_org_id);
		 END IF;

		BEGIN
		 SELECT        (next_receipt_num + 1)
		 INTO          x_receipt_num
		 FROM          rcv_parameters
		 WHERE         organization_id = l_ship_to_org_id
		 FOR UPDATE OF next_receipt_num;

		 LOOP
		    SELECT COUNT(*)
		    INTO   l_count
		    FROM   rcv_shipment_headers
		    WHERE  receipt_num = x_receipt_num
		    AND    ship_to_org_id = l_ship_to_org_id;

		    IF l_count = 0 THEN
		       UPDATE rcv_parameters
			  SET next_receipt_num = x_receipt_num
			WHERE organization_id = l_ship_to_org_id;

		       EXIT;
		    ELSE
		       x_receipt_num  := TO_CHAR(TO_NUMBER(x_receipt_num) + 1);
		    END IF;
		 END LOOP;

		 COMMIT;
	      EXCEPTION
		 WHEN OTHERS THEN
		    ROLLBACK;
	      END;
	End GenReceiptNum;


FUNCTION GET_PAY_ITEM_PROGRESS (p_wc_id       IN NUMBER,
                                p_wc_stage    IN VARCHAR2)
RETURN NUMBER
IS

l_return_status varchar2(1);
l_return_msg    varchar2(2000);
l_progress number;
begin

        POS_WC_CREATE_UPDATE_PVT.GET_PAY_ITEM_PROGRESS
                                (p_wc_id,
                                 p_wc_stage,
                                 l_progress,
                                 l_return_status,
                                 l_return_msg);

        if (l_return_status = FND_API.G_RET_STS_SUCCESS ) then
                return l_progress;
        else
                /* Some error. So return -999 */
                l_progress := -999;
                return l_progress;
        end if;

END GET_PAY_ITEM_PROGRESS;

FUNCTION GET_AWARD_NUM (p_wc_id       IN NUMBER)
RETURN VARCHAR2 IS
l_count number;
l_award_number gms_awards_all.award_number%type;
begin

	select count(*)
	into l_count
	from gms_awards_all awd,
	gms_award_distributions adl,
	po_distributions_all pod
	where adl.award_id     = awd.award_id
	and adl.adl_line_num = 1
	and adl.po_distribution_id =pod.po_distribution_id
	and adl.award_set_id = pod.award_id
	and pod.po_distribution_id = p_wc_id;

	If (l_count = 0) then
		return to_char(null);
	else
		select awd.award_number
		into l_award_number
		from gms_awards_all awd,
		gms_award_distributions adl,
		po_distributions_all pod
		where adl.award_id     = awd.award_id
		and adl.adl_line_num = 1
		and adl.po_distribution_id =pod.po_distribution_id
		and adl.award_set_id = pod.award_id
		and pod.po_header_id = p_wc_id;

		return l_award_number;
	end if;
end GET_AWARD_NUM;


FUNCTION GET_DELIVER_TO_LOCATION (p_wc_id       IN NUMBER)
RETURN VARCHAR2 IS
l_count number;
l_deliver_to_location hr_locations_all_tl.location_code%type;
begin

	select count(*)
	into l_count
	from hr_locations_all_tl hl,
	po_distributions_all pod
	where pod.deliver_to_location_id = hl.location_id and
	hl.language (+) =userenv('LANG') and
	pod.po_distribution_id = p_wc_id;


	If (l_count = 0) then
		return to_char(null);
	else
		select hl.location_code
		into l_deliver_to_location
		from hr_locations_all_tl hl,
		po_distributions_all pod
		where pod.deliver_to_location_id = hl.location_id and
		hl.language (+) =userenv('LANG') and
		pod.po_distribution_id = p_wc_id;


		return l_deliver_to_location;
	end if;
end GET_DELIVER_TO_LOCATION;

FUNCTION GET_ORDERED_AMOUNT (p_wc_id       IN NUMBER)
RETURN number IS
l_count number;
l_amount po_line_locations_all.amount%type;
begin

	select count(*)
	into l_count
	from po_line_locations_all poll
	where poll.line_location_id = p_wc_id
	and nvl(poll.matching_basis,'QUANTITY')='AMOUNT';


	If (l_count = 0) then
		return to_number(null);
	else

		select poll.amount
		into l_amount
		from po_line_locations_all poll
		where poll.line_location_id = p_wc_id
		and nvl(poll.matching_basis,'QUANTITY')='AMOUNT';


		return l_amount;
	end if;
end GET_ORDERED_AMOUNT;


FUNCTION GET_ORDERED_QUANTITY (p_wc_id       IN NUMBER)
RETURN number IS
l_count number;
l_quantity po_line_locations_all.quantity%type;
begin

	select count(*)
	into l_count
	from po_line_locations_all poll
	where poll.line_location_id = p_wc_id
	and nvl(poll.matching_basis,'QUANTITY')='QUANTITY';


	If (l_count = 0) then
		return to_number(null);
	else

		select poll.quantity
		into l_quantity
		from po_line_locations_all poll
		where poll.line_location_id = p_wc_id
		and nvl(poll.matching_basis,'QUANTITY')='QUANTITY';


		return l_quantity;
	end if;
end GET_ORDERED_QUANTITY;


FUNCTION GET_PROJECT_NAME (p_wc_id       IN NUMBER)
RETURN VARCHAR2 IS
l_count number;
l_project_name pa_projects_all.name%type;
begin

	select count(*)
	into l_count
	from pa_projects_all pa,
	po_distributions_all pod
	where pod.project_id = pa.project_id and
	pod.po_distribution_id = p_wc_id;


	If (l_count = 0) then
		return to_char(null);
	else

		select pa.name
		into l_project_name
		from pa_projects_all pa,
		po_distributions_all pod
		where pod.project_id = pa.project_id and
		pod.po_distribution_id = p_wc_id;


		return l_project_name;
	end if;
end GET_PROJECT_NAME;

FUNCTION GET_TASK_NAME (p_wc_id       IN NUMBER)
RETURN VARCHAR2 IS
l_count number;
l_task_name pa_tasks.task_name%type;
begin

	select count(*)
	into l_count
	from pa_tasks pa,
	po_distributions_all pod
	where pod.task_id = pa.task_id and
	pod.po_distribution_id = p_wc_id;


	If (l_count = 0) then
		return to_char(null);
	else

		select pa.task_name
		into l_task_name
		from pa_tasks pa,
		po_distributions_all pod
		where pod.task_id = pa.task_id and
		pod.po_distribution_id = p_wc_id;

		return l_task_name;
	end if;
end GET_TASK_NAME;

FUNCTION GET_CHARGE_ACCOUNT (p_wc_id       IN NUMBER)
RETURN VARCHAR2 IS
l_count number;
l_segments GL_CODE_COMBINATIONS_KFV.concatenated_segments%type;
begin

	select count(*)
	into l_count
	from gl_code_combinations_kfv glc,
	po_distributions_all pod
	where pod.code_combination_id = glc.code_combination_id and
	pod.po_distribution_id = p_wc_id;


	If (l_count = 0) then
		return to_char(null);
	else

		select glc.concatenated_segments
		into l_segments
		from gl_code_combinations_kfv glc,
		po_distributions_all pod
		where pod.code_combination_id = glc.code_combination_id and
		pod.po_distribution_id = p_wc_id;

		return l_segments;
	end if;
end GET_CHARGE_ACCOUNT;

FUNCTION GET_EXPENDITURE_ORG (p_wc_id       IN NUMBER)
RETURN VARCHAR2 IS
l_count number;
l_org_name org_organization_definitions.organization_name%type;
begin

	select count(*)
	into l_count
	from org_organization_definitions ood,
	po_distributions_all pod
	where pod.expenditure_organization_id = ood.organization_id
	and pod.po_distribution_id = p_wc_id;


	If (l_count = 0) then
		return to_char(null);
	else

		select ood.organization_name
		into l_org_name
		from org_organization_definitions ood,
		po_distributions_all pod
		where pod.expenditure_organization_id = ood.organization_id
		and pod.po_distribution_id = p_wc_id;

		return l_org_name;
	end if;
end GET_EXPENDITURE_ORG;

/* Bug 8479430.
   Added the procedure POWC_SELECTOR to set the user context properly before
   launching the concurrent request */
-------------------------------------------------------------------------------
-- Start of Comments
-- Name: POWC_SELECTOR
-- Pre-reqs: None.
-- Modifies:
--   Application user id
--   Application responsibility id
--   Application application id
-- Locks: None.
-- Function:
--   This procedure sets the correct application context when a process is
--   picked up by the workflow background engine. When called in
--   TEST_CTX mode it compares workflow attribute org id with the current
--   org id and workflow attributes user id, responsibility id and
--   application id with their corresponding profile values. It returns TRUE
--   if these values match and FALSE otherwise. When called in SET_CTX mode
--   it sets the correct apps context based on workflow parameters.
-- Parameters:
-- IN:
--   p_itemtype
--     Specifies the itemtype of the workflow process
--   p_itemkey
--     Specifies the itemkey of the workflow process
--   p_actid
--     activity id passed by the workflow
--   p_funcmode
--     Input values can be TEST_CTX or SET_CTX (RUN not implemented)
--     TEST_CTX to test if current context is correct
--     SET_CTX to set the correct context if current context is wrong
-- IN OUT:
--   p_x_result
--     For TEST_CTX a TRUE value means that the context is correct and
--     SET_CTX need not be called. A FALSE value means that current context
--     is incorrect and SET_CTX need to set correct context
-- Testing:
--   There is not script to test this procedure but the correct functioning
--   may be tested by verifying from the debug_message in table po_wf_debug
--   that if at any time the workflow process gets started with a wrong
--   context then the selector is called in TEST_CTX and SET_CTX modes and
--   correct context is set.
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE POWC_SELECTOR ( p_itemtype   IN VARCHAR2,
                          p_itemkey    IN VARCHAR2,
                          p_actid      IN NUMBER,
                          p_funcmode   IN VARCHAR2,
                          p_x_result   IN OUT NOCOPY VARCHAR2) IS

-- Declare context setting variables start
l_session_user_id         NUMBER;
l_session_resp_id         NUMBER;
l_responder_id            NUMBER;
l_user_id_to_set          NUMBER;
l_resp_id_to_set          NUMBER;
l_appl_id_to_set          NUMBER;
l_progress                VARCHAR2(1000);
l_preserved_ctx           VARCHAR2(5):= 'TRUE';
l_org_id                  NUMBER;
-- Declare context setting variables End

BEGIN

  -- <debug start>
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','Inside POWC_SELECTOR procedure');
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','p_itemtype : '||p_itemtype);
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','p_itemkey : '||p_itemkey);
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','p_actid : '||p_actid);
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','p_funcmode : '||p_funcmode);
  END IF;
  -- <debug end>


  l_org_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                           itemkey  => p_itemkey,
                                           aname    => 'ORG_ID');
  l_session_user_id := fnd_global.user_id;
  l_session_resp_id := fnd_global.resp_id;

  IF (l_session_user_id = -1) THEN
    l_session_user_id := NULL;
  END IF;

  IF (l_session_resp_id = -1) THEN
    l_session_resp_id := NULL;
  END IF;

  l_responder_id :=  wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                 itemkey  => p_itemkey,
                                                 aname    => 'RESPONDER_USER_ID');

  --<debug start>
  l_progress :='010 - ses_user_id:'||l_session_user_id ||' ses_resp_id :'||l_session_resp_id||' responder id:' ||l_responder_id||' org id :'||l_org_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','l_progress1 : '||l_progress);
  END IF;
  --<debug end>

  IF (p_funcmode = 'TEST_CTX') THEN
    -- wf shouldn't run without the session user, hence always set the ctx if session user id is null.
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
            -- If the selector fn is called from a background ps
            -- notif mailer then force the session to use preparer's or responder
            -- context. This is required since the mailer/bckgrnd ps carries the
            -- context from the last wf processed and hence even if the context values
            -- are present, they might not be correct.

            if (wf_engine.preserved_context = TRUE) then
              p_x_result := 'TRUE';
            else
              p_x_result:= 'NOTSET';
            end if;

            -- introduce an org context setting call here
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

      l_resp_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONDER_RESP_ID');
      l_appl_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONDER_APPL_ID');
      --<debug start>
      l_progress := '020 selection fn responder id not null';

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','l_progress2 : '||l_progress);
      END IF;
      --<debug end>

      --<debug start>
      l_progress :='030 selector fn : setting user id :'||l_responder_id ||' resp id '||l_resp_id_to_set||' l_appl id '||l_appl_id_to_set;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','l_progress3 : '||l_progress);
      END IF;
      --<debug end>
    else
      l_user_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'USER_ID');
      l_resp_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONSIBILITY_ID');
      l_appl_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'APPLICATION_ID');
      --<debug start>
      l_progress := '040 selector fn responder id null';

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','l_progress4 : '||l_progress);
      END IF;
      --<debug end>

      --<debug start>
      l_progress := '050 selector fn : set user '||l_user_id_to_set||' resp id ' ||l_resp_id_to_set||' appl id '||l_appl_id_to_set;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','l_progress4 : '||l_progress);
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

  END IF;

EXCEPTION WHEN OTHERS THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.POS_WCAPPROVE_PVT.POWC_SELECTOR.invoked','Exception in Selector Procedure');
  END IF;

  WF_CORE.context('POS_WCAPPROVE_PVT', 'POWC_SELECTOR', p_itemtype, p_itemkey, p_actid, p_funcmode);
  RAISE;

END POWC_SELECTOR;

END POS_WCAPPROVE_PVT;

/
