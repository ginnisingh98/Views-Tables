--------------------------------------------------------
--  DDL for Package Body POR_CANCEL_NOTIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_CANCEL_NOTIF_PVT" AS
/* $Header: PORCNNTB.pls 115.3 2004/05/08 00:23:58 mahmad noship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_pkg_name CONSTANT VARCHAR2(50) := 'POR_CANCEL_NOTIF_PVT';
g_module_prefix CONSTANT VARCHAR2(50) := 'por.plsql.' || g_pkg_name || '.';

/*==========================================================================*
 *  Starts Contractor Requisition Cancellation WF                           *
 *==========================================================================*/
FUNCTION Start_WF_Process(reqLineId NUMBER, contractorStatus VARCHAR2)
RETURN VARCHAR2 IS

  l_itemtype   wf_items.item_type%TYPE := 'PORCNWF';
  l_itemkey    wf_items.item_key%TYPE;
  l_wf_created NUMBER := 0;
  l_wf_process varchar2(100) := 'POR_CONT_CANCEL_WF';
  l_user_id NUMBER := 0;
  l_responsibility_id NUMBER := 0;
  l_application_id NUMBER := 0;
  l_progress varchar2(200) := '';
  l_api_name varchar2(50) := 'START_WF_PROCESS';
BEGIN

  IF (reqLineId IS NOT NULL) THEN

    -- set item key
    SELECT to_char(reqLineId) || '-' || to_char(POR_CANCEL_NOTIF_ITEMKEY_S.nextval)
    INTO l_itemkey
    FROM dual;

    l_progress := 'POR_CANCEL_NOTIFICATION_PKG.Start_WF_Process: 01';

    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,g_module_prefix || l_api_name || l_progress);
    END IF;

    -- Check if any process created before with the same wf item type and
    -- wf item key
    SELECT count(*)
    INTO l_wf_created
    FROM wf_items
    WHERE
      item_type=l_itemtype AND
      item_key = l_itemkey;

    IF (l_wf_created = 0) THEN

      l_progress := 'POR_CANCEL_NOTIFICATION_PKG.Start_WF_Process: 02';
      IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,g_module_prefix || l_api_name || l_progress);
      END IF;
      wf_engine.CreateProcess( ItemType => l_itemtype,
                               ItemKey  => l_itemkey,
                               process  => l_wf_process );

      wf_engine.SetItemAttrNumber (   itemtype   => l_itemtype,
                                        itemkey    => l_itemkey,
                                        aname      => 'REQ_LINE_ID',
                                        avalue     => reqLineId);

      wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                 itemkey    => l_itemkey,
                                 aname      => 'CONTRACTOR_STATUS',
                                 avalue     => contractorStatus);

      wf_engine.StartProcess(ItemType => l_itemtype,
                             ItemKey  => l_itemkey);

      RETURN 'Y';

    ELSE

      RETURN 'N';

    END IF;

  END IF;

END Start_WF_Process;


/*==========================================================================*
 *  Checks whether suppliers of the corresponding requisition               *
 *  has been notified before by Supplier Notification                       *
 *==========================================================================*/
PROCEDURE Is_any_supplier_notified(itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out NOCOPY varchar2)
IS

  l_progress              varchar2(200);
  l_supplier_notified_flag po_requisition_headers.supplier_notified_flag%type;
  l_req_line_id NUMBER;
  l_contractor_status po_requisition_lines.contractor_status%type;
  l_api_name varchar2(50) := 'IS_ANY_SUPPLIER_NOTIFIED';
BEGIN

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.Is_any_supplier_notified: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,g_module_prefix || l_api_name || l_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_req_line_id := wf_engine.GetItemAttrNumber
                                       (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REQ_LINE_ID');

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.Is_any_supplier_notified: 02';

  select nvl(prh.supplier_notified_flag, 'N'), prl.contractor_status
  into l_supplier_notified_flag, l_contractor_status
  from
    po_requisition_headers_all prh,
    po_requisition_lines_all prl
  where
    prh.requisition_header_id = prl.requisition_header_id and
    requisition_line_id = l_req_line_id;

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.Is_any_supplier_notified: 03';

--  if (l_supplier_notified_flag = 'Y' and
--      (l_contractor_status = 'ASSIGNED' or l_contractor_status = 'PENDING')) then
  if (l_supplier_notified_flag = 'Y') then
    resultout := wf_engine.eng_completed || ':' || 'Y' ;
  else
    resultout := wf_engine.eng_completed || ':' || 'N' ;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('POR_CANCEL_NOTIF_PVT','Is_any_supplier_notified',l_progress);
    raise;

END Is_any_supplier_notified;


/*==========================================================================*
 *   Returns the company name                                               *
 *==========================================================================*/
FUNCTION get_company_name return varchar2 IS

  party_name VARCHAR2(100) := '';
  exception_msg VARCHAR2(100) := '';
  status VARCHAR2(100) := '';

BEGIN

  POS_ENTERPRISE_UTIL_PKG.GET_ENTERPRISE_PARTY_NAME(party_name, exception_msg, status);

  IF (status = 'S') THEN
    RETURN party_name;
  END IF;

  RETURN '';

END get_company_name;

/*==========================================================================*
 *   Returns user name who cancel the requisition line                      *
 *==========================================================================*/
FUNCTION get_user_name return varchar2 IS

  l_user_name VARCHAR2(100) := '';
  l_user_id varchar2(100) := '';

BEGIN

  FND_PROFILE.GET('USER_ID', l_user_id);

  select user_name
  into l_user_name
  from fnd_user
  where user_id = to_number(l_user_id);

  RETURN l_user_name;

EXCEPTION

  WHEN OTHERS THEN
    RETURN '';

END get_user_name;


/*==========================================================================*
 *   Initialize notification message attributes before it is sent           *
 *==========================================================================*/
PROCEDURE set_notification_attributes(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2)
IS

  l_progress         varchar2(200);
  l_req_line_id      NUMBER;
  l_job_name         po_job_associations_tl.JOB_DESCRIPTION%TYPE;
  l_contact_info     PO_REQUISITION_LINES.CONTACT_INFORMATION%TYPE;
  l_start_date       DATE;
  l_req_info         VARCHAR2(100) := '';
  l_cont_status      PO_REQUISITION_LINES.CONTRACTOR_STATUS%TYPE;
  l_api_name         varchar2(50) := 'SET_NOTIFICATION_ATTRIBUTES';
BEGIN

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_notification_attributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,g_module_prefix || l_api_name || l_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_req_line_id := wf_engine.GetItemAttrNumber
                                       (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'REQ_LINE_ID');

  l_cont_status := wf_engine.GetItemAttrText
                                       (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'CONTRACTOR_STATUS');

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_notification_attributes: 02';

  SELECT pja.job_description, prl.contact_information,
    prl.assignment_start_date, prh.segment1 || ' / ' || to_char(prl.line_num)
  INTO l_job_name, l_contact_info, l_start_date, l_req_info
  FROM
    po_requisition_headers_all prh,
    po_requisition_lines_all prl,
    po_job_associations pja
  WHERE prl.requisition_line_id = l_req_line_id AND
    prl.job_id = pja.job_id AND
    prh.requisition_header_id = prl.requisition_header_id;

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_notification_attributes: 03';

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,g_module_prefix || l_api_name || l_progress);
  END IF;

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_notification_attributes: 05';

  -- Set Subject attributes
  wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'JOB_NAME',
                                 avalue   => l_job_name);

  wf_engine.SetItemAttrDate (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'START_DATE',
                                 avalue   => l_start_date);

  -- Set Notification Header attributes
  wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'FORWARD_FROM_USER_NAME',
                              avalue   => get_user_name());

  wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REQ_LINE_INFO',
                              avalue   => l_req_info);

  wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'COMPANY_NAME',
                              avalue   => get_company_name());

  -- set attributes for message body
  wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'CONTACT_INFO',
                              avalue   => l_contact_info);


  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,g_module_prefix || l_api_name || l_progress || l_cont_status);
  END IF;

  IF (l_cont_status = 'PENDING') THEN
    update po_requisition_suppliers
    set SUPPLIER_NOTIFIED_FLAG = 'N'
    where requisition_line_id = l_req_line_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('POR_CANCEL_NOTIF_PVT','set_notification_attributes',l_progress);
    raise;

END set_notification_attributes;

/*==========================================================================*
 *  Sets supplier and supplier role                                         *
 *==========================================================================*/
PROCEDURE set_supplier(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2)
IS

  l_progress              varchar2(200);
  l_api_name  varchar2(50) := 'SET_SUPPLIER';
  l_req_line_id NUMBER := 0;
  l_cont_status po_requisition_lines.CONTRACTOR_STATUS%type;
  l_requisition_supplier_id NUMBER := 0;
  l_performer WF_USER_ROLES.ROLE_NAME%TYPE;
  l_supplier_exists VARCHAR2(50);

BEGIN

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,g_module_prefix || l_api_name || l_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
   end if;

  l_req_line_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'REQ_LINE_ID');

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 02';


  l_cont_status := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CONTRACTOR_STATUS');

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 03';


  IF (l_cont_status = 'PENDING') THEN

    SELECT max(requisition_supplier_id)
    INTO l_requisition_supplier_id
    FROM po_requisition_suppliers
    WHERE
      requisition_line_id = l_req_line_id AND
      nvl(supplier_notified_flag, 'N') = 'N';

    l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 04';

    IF (l_requisition_supplier_id is NULL) THEN
      l_supplier_exists := 'NO_SUPPLIER';
    ELSE
      PO_REQAPPROVAL_INIT1.LOCATE_NOTIFIER(l_requisition_supplier_id, 'RS', l_performer);

      l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 05';

      IF g_po_wf_debug = 'Y' THEN
 	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	    g_module_prefix || l_api_name || 'PERFORMER: ' ||  l_performer);
      END IF;

      IF (l_performer IS NULL) THEN
        l_performer := POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE(l_requisition_supplier_id, null, itemtype, itemkey);

        l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 06';

        IF g_po_wf_debug = 'Y' THEN
 	  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	    g_module_prefix || l_api_name || 'PERFORMER: ' ||  l_performer);
        END IF;
      END IF;

      IF (l_performer is not null) THEN
        wf_engine.SetItemAttrText (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_ROLE',
	                     avalue   => l_performer);
      END IF;

      wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUPPLIER_ID',
                                 avalue   => l_requisition_supplier_id);
      l_supplier_exists := 'SUPPLIER_EXIST';
    END IF;

  ELSIF (l_cont_status = 'ASSIGNED') THEN -- only one supplier

    SELECT max(vendor_id)
    INTO l_requisition_supplier_id
    FROM po_requisition_lines
    WHERE
      requisition_line_id = l_req_line_id AND
      nvl(supplier_notified_for_cancel, 'N')='N';

    l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 07';

    IF (l_requisition_supplier_id is NULL) THEN
      l_supplier_exists := 'NO_SUPPLIER';
    ELSE
      PO_REQAPPROVAL_INIT1.LOCATE_NOTIFIER(l_req_line_id, 'RQ', l_performer);
      l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 08';

      IF g_po_wf_debug = 'Y' THEN
 	PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	    g_module_prefix || l_api_name || 'PERFORMER: ' ||  l_performer);
      END IF;

      IF (l_performer IS NULL) THEN
        l_performer := POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE(null, l_req_line_id, itemtype, itemkey);

        l_progress := 'POR_CANCEL_NOTIFICATION_PVT.set_supplier: 09';

        IF g_po_wf_debug = 'Y' THEN
 	  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	    g_module_prefix || l_api_name || 'PERFORMER: ' ||  l_performer);
        END IF;
      END IF;

      IF (l_performer is not null) THEN
        wf_engine.SetItemAttrText (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_ROLE',
	                     avalue   => l_performer);
      END IF;

      wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUPPLIER_ID',
                                 avalue   => l_requisition_supplier_id);
      l_supplier_exists := 'SUPPLIER_EXIST';
    END IF;

  END IF;

  resultout := WF_ENGINE.ENG_COMPLETED || ':' ||  l_supplier_exists;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('POR_CANCEL_NOTIF_PVT','set_supplier',l_progress);
    raise;

END set_supplier;


/*==========================================================================*
 *  Updates SUPPLIER_NOTIFIED_FOR_CANCEL flag in po_requisition_lines       *
 *==========================================================================*/
PROCEDURE post_notification_process(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2)
IS

  l_progress              varchar2(200);
  l_req_line_id NUMBER := 0;
  l_supplier_id NUMBER := 0;
  l_cont_status po_requisition_lines.contractor_status%type;
  l_api_name varchar2(50) := 'POST_NOTIFICATION_PROCESS';

BEGIN

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.post_notification_process: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,g_module_prefix || l_api_name || l_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
   end if;

  l_req_line_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'REQ_LINE_ID');

  l_progress := 'POR_CANCEL_NOTIFICATION_PVT.post_notification_process: 02';

  UPDATE po_requisition_lines_all
  SET supplier_notified_for_cancel ='Y'
  WHERE requisition_line_id = l_req_line_id;

  l_cont_status := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CONTRACTOR_STATUS');

  IF (l_cont_status = 'PENDING') THEN

    l_supplier_id := wf_engine.GetItemAttrNumber
                                       (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'SUPPLIER_ID');

    UPDATE po_requisition_suppliers
    SET supplier_notified_flag='Y'
    WHERE requisition_supplier_id = l_supplier_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('POR_CANCEL_NOTIF_PVT','post_notification_process',l_progress);
    raise;

END post_notification_process;


end por_cancel_notif_pvt;

/
