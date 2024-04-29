--------------------------------------------------------
--  DDL for Package Body PO_SIGNATURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SIGNATURE_PVT" AS
/* $Header: POXVSIGB.pls 120.10.12010000.13 2013/10/25 09:23:02 swvyamas ship $ */

-- Read the profile option that enables/disables the debug log
  g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

c_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_SIGNATURE_PVT.';
g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_SIGNATURE_PVT';     -- <BUG 3607009>
g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- Read the profile option that determines whether the promise date will be defaulted with need-by date or not
g_default_promise_date VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('POS_DEFAULT_PROMISE_DATE_ACK'),'N');


--Cursor to select the PO details to be used in the notification message bodies
  -- SQL What:selects the PO details and the vendor details from
  --          po_headers_all and po_vendors
  -- SQL Why :To show the details in the Notifications of the Document
  --          Signature Process.
  -- SQL Join: PO_HEADER_ID, VENDOR_ID

-- Bug#5527795
CURSOR po_hdr_csr(p_po_header_id IN NUMBER) IS
SELECT PHA.segment1,
       PHA.revision_num,
       PHA.comments,
       VO.vendor_name,
       PHA.type_lookup_code,
       PHA.po_header_id,
       HRL_B.location_code bill_to_location,
       HRL_S.location_code ship_to_location,
       DECODE(PHA.vendor_contact_id, NULL, NULL,
         VC.last_name||', '||VC.first_name) vendor_contact,
       PHA.blanket_total_amount
  FROM PO_HEADERS_ALL   PHA,
       PO_VENDORS     VO,
       PO_VENDOR_CONTACTS VC,
       HR_LOCATIONS_ALL_TL HRL_S,
       HR_LOCATIONS_ALL_TL HRL_B
 WHERE PHA.po_header_id =  p_po_header_id
   AND PHA.vendor_id    =  VO.vendor_id
   AND  VC.vendor_contact_id (+) = PHA.vendor_contact_id
   AND  HRL_S.location_id (+) = PHA.ship_to_location_id
   AND  HRL_S.language(+) = USERENV('LANG')
   AND  HRL_B.location_id (+) = PHA.bill_to_location_id
   AND  HRL_B.language(+) = USERENV('LANG');
-------------------------------------------------------------------------------
--Start of Comments
--Name: Set_Startup_Values
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Sets the initial attributes required for the Document Signature Process.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Set_Startup_Values (itemtype        IN VARCHAR2,
                              itemkey         IN VARCHAR2,
                              actid           IN NUMBER,
                              funcmode        IN VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2) IS

  l_document_number    PO_HEADERS_ALL.segment1%TYPE;
  l_document_type      PO_DOCUMENT_TYPES.document_type_code%TYPE;
  l_document_subtype   PO_HEADERS_ALL.type_lookup_code%TYPE;
  l_document_id        PO_HEADERS_ALL.po_header_id%TYPE;
  l_doc_display_name   PO_DOCUMENT_TYPES.type_name%TYPE;
  l_revision           PO_HEADERS_ALL.revision_num%TYPE;
  l_orgid              PO_HEADERS_ALL.org_id%TYPE;
  l_preparer_id        PO_HEADERS_ALL.agent_id%TYPE;
  l_username           FND_USER.user_name%TYPE;
  l_user_display_name  FND_USER.description%TYPE;
  l_progress           VARCHAR2(300);
  l_vendor_name        PO_VENDORS.vendor_name%TYPE;
  l_doc_string         VARCHAR2(200);
  l_preparer_user_name WF_USERS.name%TYPE;
  l_binding_exception  EXCEPTION;
  -- Forward port of bug 3897526. Display PDF attachment even when PO
  -- has no terms
  l_conterms_exist PO_HEADERS_ALL.conterms_exist_flag%type;
  l_sign_attachments_value VARCHAR2(300);
  l_po_itemkey         PO_HEADERS_ALL.wf_item_key%TYPE;
  l_esigner_exists     VARCHAR2(1);
BEGIN

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.Set_Startup_Values: 01';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  --  Set the multi-org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'ORG_ID');

  l_preparer_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'BUYER_EMPLOYEE_ID');

  PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'PREPARER_ID',
                                     avalue     => l_preparer_id);

  PO_REQAPPROVAL_INIT1.get_user_name(p_employee_id       => l_preparer_id,
                                     x_username          => l_username,
                                     x_user_display_name => l_user_display_name);

  WF_ENGINE.SetItemOwner (itemtype => itemtype,
                          itemkey  => itemkey,
                          owner    => l_username);

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'BUYER_USER_NAME',
                                   avalue     => l_username);

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'BUYER_DISPLAY_NAME',
                                   avalue     => l_user_display_name);

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_ID');

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype   => itemtype,
                                 itemkey	=> itemkey,
                                 aname  	=> 'DOCUMENT_NUMBER');

  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_TYPE');

  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_SUBTYPE');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_REVISION_NUM');

   BEGIN
       SELECT type_name
         INTO l_doc_display_name
         FROM PO_DOCUMENT_TYPES
        WHERE document_type_code = l_document_type
          AND document_subtype = l_document_subtype;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           RAISE l_binding_exception;
   END;

   IF (l_document_type = 'PA' AND l_document_subtype IN ('BLANKET','CONTRACT')) OR
      (l_document_type = 'PO' AND l_document_subtype = 'STANDARD')  THEN

        l_doc_display_name := PO_DOC_STYLE_PVT.GET_STYLE_DISPLAY_NAME(l_document_id);

   END IF;

   PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DOCUMENT_DISPLAY_NAME',
                                   avalue   => l_doc_display_name);

   --  Sets the subject of the Supplier signature notification
   FND_MESSAGE.set_name( 'PO', 'PO_SUP_SIGNATURE_MSG_SUB');
   FND_MESSAGE.set_token(token	=> 'DOC_TYPE',
                         value	=> l_doc_display_name);
   FND_MESSAGE.set_token(token	=> 'DOC_NUM',
                         value	=> (l_document_number ||','||l_revision));

   PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PO_SUP_SIGNATURE_MSG_SUB',
                                  avalue   => fnd_message.get);

   -- <Contract Dev. Report 11.5.10+>: Limit signature attachments to
   -- category CONTRACT.  See Bug 3897511.
   -- <Bug 3897526 Start>: Signature notification should show the PDF document
   -- for PO without contract terms as well

   BEGIN
     SELECT NVL(poh.conterms_exist_flag,'N'), wf_item_key
     INTO l_conterms_exist, l_po_itemkey
     FROM po_headers_all poh
     WHERE poh.po_header_id = l_document_id;
   EXCEPTION
     WHEN others THEN
       null; --In case of any exception, document from OKC_CONTRACT_DOCS
             --will be attached consistent with earlier behaviour
   END;


   IF (l_conterms_exist = 'N') THEN

       l_sign_attachments_value :='FND:entity=PO_HEAD&pk1name=BusinessDocumentId&pk1value='
                         ||l_document_id
                         ||'&pk2name=BusinessDocumentVersion&pk2value='
                         ||l_revision;

   ELSE

       l_sign_attachments_value :='FND:entity=OKC_CONTRACT_DOCS&pk1name=BusinessDocumentType&pk1value='
                         ||l_document_type||'_'||l_document_subtype
                         ||'&pk2name=BusinessDocumentId&pk2value='||l_document_id
                         ||'&pk3name=BusinessDocumentVersion&pk3value='|| l_revision
                         ||'&categories=OKC_REPO_CONTRACT';

   END IF;  -- if (l_conterms_exist = 'N')

   PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PO_SIGN_ATTACHMENTS',
                                  avalue   => l_sign_attachments_value);

   -- <Bug 3897526 End>


   PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'PO_SUP_SIGNATURE_MSG_BODY',
                                  avalue   =>
                'PLSQLCLOB:PO_SIGNATURE_PVT.get_signature_notfn_body /'|| l_document_id ||':'||itemtype||':'||itemkey);
  -- PO AME Project : Changes made for Multiple E-signatures

   l_esigner_exists := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype, itemkey => l_po_itemkey, aname => 'E_SIGNER_EXISTS');
   PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype, itemkey => itemkey, aname => 'E_SIGNER_EXISTS', avalue => l_esigner_exists);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.Set_Startup_Values: 02 with E_SIGNER_EXISTS '|| l_esigner_exists;
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION
  WHEN l_binding_exception then
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemtype, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemtype, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','Set_Startup_Values',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemtype, itemkey, l_preparer_user_name, l_doc_string, 'l_binding_exception - '||sqlerrm, 'PO_SIGNATURE_PVT.SET_STARTUP_VALUES');
    RAISE;

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','Set_Startup_Values',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.SET_STARTUP_VALUES');
    RAISE;

END SET_STARTUP_VALUES;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_signature_notfn_body
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Builds the message body of the Signature Notification for
--  Supplier/Buyer.
--  Called from the Document Signature Process of the PO Approval workflow
--Parameters:
--IN:
--document_id
--  Standard parameter to be used in the procedure for creating PLSQL clob
--display_type
--  Standard parameter to be used in the procedure for creating PLSQL clob
--IN OUT:
--document
--  Standard parameter to be used in the procedure for creating PLSQL clob
--document_type
--  Standard parameter to be used in the procedure for creating PLSQL clob
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_signature_notfn_body (document_id    IN VARCHAR2,
                                    display_type   IN VARCHAR2,
                                    document       IN OUT NOCOPY CLOB,
                                    document_type  IN OUT NOCOPY VARCHAR2) IS

  l_msgbody              VARCHAR2(32000);
  l_document_id          PO_HEADERS_ALL.po_header_id%TYPE;
  l_buyer_name           FND_USER.user_name%TYPE;
  l_msgtext              FND_NEW_MESSAGES.message_text%TYPE;
  l_supplier_response	 VARCHAR2(20);
  l_item_type            WF_ITEMS.item_type%TYPE;
  l_item_key             WF_ITEMS.item_key%TYPE;
  l_firstcolon           NUMBER;
  l_secondcolon          NUMBER;
  l_amount               NUMBER;
  l_buyer_org            HR_LEGAL_ENTITIES.name%TYPE;
  l_orgid                PO_HEADERS_ALL.org_id%TYPE;
  l_doc_string           VARCHAR2(200);
  l_preparer_user_name   WF_USERS.name%TYPE;
  l_progress             VARCHAR2(300);
  l_doc_display_name     PO_DOCUMENT_TYPES.type_name%TYPE;
  l_binding_exception    EXCEPTION;
  /* Added for the bug 6358219 to fetch the legal_entity name */
  l_legal_entity_id NUMBER;
  x_legalentity_info  xle_utilities_grp.LegalEntity_Rec;
  x_return_status	VARCHAR2(20) ;
  x_msg_count    NUMBER ;
  x_msg_data    VARCHAR2(4000) ;
BEGIN

  l_firstcolon := instr(document_id, ':');
  l_secondcolon := instr(document_id, ':', 1,2);
  l_document_id := to_number(substr(document_id, 1, l_firstcolon - 1));
  l_item_type := substr(document_id, l_firstcolon + 1, l_secondcolon - l_firstcolon - 1);
  l_item_key := substr(document_id, l_secondcolon+1,length(document_id) - l_secondcolon);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_signature_notfn_body: 01';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

  l_buyer_name := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => l_item_type,
                                                  itemkey  => l_item_key,
                                                  aname    => 'BUYER_DISPLAY_NAME');

  l_supplier_response := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => l_item_type,
                                   		                 itemkey  => l_item_key,
                            	 	                     aname    => 'SUPPLIER_RESPONSE');

  l_doc_display_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'DOCUMENT_DISPLAY_NAME');

  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                         itemtype => l_item_type,
                                         itemkey  => l_item_key,
                                         aname    => 'ORG_ID');

  /* Added for the bug 6358219 to fetch the legal_entity name */

  l_legal_entity_id :=  PO_CORE_S.get_default_legal_entity_id(l_orgid);

  IF l_orgid IS NOT NULL THEN
      BEGIN

      XLE_UTILITIES_GRP.Get_LegalEntity_Info(
         		              x_return_status,
           	     	      x_msg_count,
         		              x_msg_data,
                 	              null,
                 	              l_legal_entity_id,
             	              x_legalentity_info);

          /* SELECT HRL.name
            INTO l_buyer_org
            FROM HR_OPERATING_UNITS HRO,
                 HR_LEGAL_ENTITIES HRL
           WHERE HRO.default_legal_context_id = HRL.organization_id -- Bug#5527795
             AND HRO.organization_id = l_orgid; */
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              RAISE l_binding_exception;
      END;
  ELSE
      l_buyer_org := Null;
  END IF;

  FOR po_rec IN po_hdr_csr(l_document_id)
  LOOP
       l_msgbody := '<html>
       <style> .tableHeaderCell { font-family: Arial; font-size: 10pt;}
               .tableDataCell { font-family: Arial; font-size: 10pt; font-weight: bold; }
       </style>
      <body class="tableHeaderCell">
       <table>
        <tr>
         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_DOCTYPE')||' : </td>
         <td width="40%" class="tableDataCell"> ' || l_doc_display_name || ' </td>

         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_PO_NUMBER') ||': </td>
         <td class="tableDataCell"> ' || po_rec.segment1 ||','|| po_rec.revision_num || ' </td>
        </tr>

        <tr>
         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_SUPPLIER')||' : </td>';

         IF l_buyer_org IS NOT NULL THEN

             l_msgbody := l_msgbody || '<td width="40%" class="tableDataCell"> ' || po_rec.vendor_name || ' </td>
                                        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_ORG') ||': </td>
                                        <td class="tableDataCell"> ' || l_buyer_org || ' </td>';
         ELSE
             l_msgbody := l_msgbody || '<td COLSPAN="3" class="tableDataCell"> ' || po_rec.vendor_name || ' </td>';
         END IF;

        l_msgbody := l_msgbody || '</tr>

       <tr>
        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_CONTACT') ||': </td>
        <td width="40%" class="tableDataCell">' || po_rec.vendor_contact || ' </td>

        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_BUYER') ||': </td>
        <td class="tableDataCell"> ' || l_buyer_name || ' </td>
       </tr>

        <tr>
          <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_DESC')||' :</td>
          <td COLSPAN="3" class="tableDataCell">' || po_rec.comments || ' </td>
        </tr>
     </table>';
  END LOOP;

  IF l_supplier_response IS NULL THEN
     fnd_message.set_name ('PO','PO_WF_NOTIF_SUPP_REQUIRE_SIGN');
  ELSE
     fnd_message.set_name ('PO', 'PO_WF_NOTIF_BUYER_REQUIRE_SIGN');
  END IF;

  l_msgtext := fnd_message.get;

  l_msgbody := l_msgbody || '<p class="tableHeaderCell">'||l_msgtext ||'</p>';

  l_msgbody := l_msgbody || '</body></html>';

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_signature_notfn_body: 02';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

  WF_NOTIFICATION.WriteToClob(document, l_msgbody);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_signature_notfn_body: 03';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

EXCEPTION
  WHEN l_binding_exception then
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(l_item_type, l_item_key);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(l_item_type, l_item_key);
    WF_CORE.context('PO_SIGNATURE_PVT','Get_Signature_Notfn_Body',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(l_item_type, l_item_key, l_preparer_user_name, l_doc_string, 'l_binding_exception - '||sqlerrm, 'PO_SIGNATURE_PVT.GET_SIGNATURE_NOTFN_BODY');
    RAISE;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(l_item_type, l_item_key);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(l_item_type, l_item_key);
    WF_CORE.context('PO_SIGNATURE_PVT','Get_Signature_Notfn_Body',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(l_item_type, l_item_key, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.GET_SIGNATURE_NOTFN_BODY');
    RAISE;

END GET_SIGNATURE_NOTFN_BODY;

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_erecord
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calls the APIs given by eRecords product team to store the signature
--  notification as an eRecord
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_erecord (itemtype        IN VARCHAR2,
                          itemkey         IN VARCHAR2,
                          actid           IN NUMBER,
                          funcmode        IN VARCHAR2,
                          resultout       OUT NOCOPY VARCHAR2) IS

   l_signature_id       NUMBER;
   l_evidence_store_id	NUMBER;
   l_notif_id 	        NUMBER;
   l_erecord_id 	    NUMBER;
   l_doc_parameters	    PO_ERECORDS_PVT.Params_tbl_type;
   l_sig_parameters	    PO_ERECORDS_PVT.Params_tbl_type;
   l_po_header_id 	    PO_HEADERS.po_header_id%TYPE;
   l_user_name 	        FND_USER.user_name%TYPE;
   l_requester 	        FND_USER.user_name%TYPE;
   l_buyer_response	    VARCHAR2(20);
   l_response	        VARCHAR2(20);
   l_supplier_response	VARCHAR2(20);
   l_event_name         VARCHAR2(50);
   l_acceptance_note	PO_ACCEPTANCES.note%TYPE;
   l_document_number    PO_HEADERS_ALL.segment1%TYPE;
   l_orgid              PO_HEADERS_ALL.org_id%TYPE;
   l_revision           PO_HEADERS_ALL.revision_num%TYPE;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_progress           VARCHAR2(300);
   l_doc_string         VARCHAR2(200);
   l_preparer_user_name WF_USERS.name%TYPE;
   l_trans_status       VARCHAR2(10);
   l_response_code      FND_LOOKUP_VALUES.meaning%TYPE;
   l_reason_code        FND_LOOKUP_VALUES.meaning%TYPE;
   l_signer_type        FND_LOOKUP_VALUES.meaning%TYPE;
   l_signer             VARCHAR2(10);
   l_erecords_exception EXCEPTION;
BEGIN
  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.Create_Erecord: 01';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_po_header_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
	                                                 itemkey  => itemkey,
		                                             aname    => 'PO_HEADER_ID');

  l_acceptance_note := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         		       itemkey  => itemkey,
                                	 	               aname    => 'SIGNATURE_COMMENTS');

  l_supplier_response := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                           		         itemkey  => itemkey,
                            	 	                     aname    => 'SUPPLIER_RESPONSE');

  l_buyer_response := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                   		              itemkey  => itemkey,
                            	 	                  aname    => 'BUYER_RESPONSE');

  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'ORG_ID');

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(itemtype   => itemtype,
                                                      itemkey	 => itemkey,
                                                      aname  	 => 'DOCUMENT_NUMBER');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'PO_REVISION_NUM');

  --  If the BUYER_RESPONSE attribute is Null then this procedure is called for Supplier Signature
  --  notification, otherwise it is called for the Buyer Signature Notification

  IF l_buyer_response IS NULL THEN
     l_response := l_supplier_response;

     l_signer := 'SUPPLIER';

     l_event_name := 'oracle.apps.po.suppliersignature';

     l_user_name := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'SUPPLIER_USER_NAME');

     l_requester := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'BUYER_USER_NAME');

     --Get the Notification Id of the recent Signature Notification into l_notif_id.
     l_notif_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'NOTIFICATION_ID');
  ELSE
     l_response := l_buyer_response;

     l_signer := 'BUYER';

     l_event_name := 'oracle.apps.po.buyersignature';


     -- bug3668978
     -- We should pass the current login user to eRecord API rather than
     -- the buyer because the notification may have been routed to
     -- somebody else
     l_user_name := FND_GLOBAL.user_name;

     l_requester := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'SUPPLIER_USER_NAME');

     --Get the Notification Id of the recent Signature Notification into l_notif_id.
     l_notif_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'NOTIFICATION_ID');
  END IF;

  BEGIN
      SELECT displayed_field
        INTO l_response_code
        FROM Po_Lookup_Codes
       WHERE Lookup_Type = 'ERECORD_RESPONSE'
         AND Lookup_Code = l_response;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_response_code := NULL;
  END;

  BEGIN
      SELECT displayed_field
        INTO l_reason_code
        FROM Po_Lookup_Codes
       WHERE Lookup_Type = 'ERECORD_REASON'
         AND Lookup_Code = 'ERES_REASON';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_reason_code := NULL;
  END;

  BEGIN
      SELECT displayed_field
        INTO l_signer_type
        FROM Po_Lookup_Codes
       WHERE Lookup_Type = 'ERECORD_SIGNER_TYPE'
         AND Lookup_Code = Decode(l_signer,'SUPPLIER','SUPPLIER','BUYER','CUSTOMER');
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_signer_type := NULL;
  END;


  l_evidence_store_id := wf_notification.GetAttrText(l_notif_id, '#WF_SIG_ID');

  l_doc_parameters(1).Param_Name := 'PSIG_USER_KEY_LABEL';
  l_doc_parameters(1).Param_Value := fnd_message.get_string('PO', 'PO_EREC_PARAM_KEYVALUE');
  l_doc_parameters(1).Param_displayname := 'PSIG_USER_KEY_LABEL';
  l_doc_parameters(2).Param_Name := 'PSIG_USER_KEY_VALUE';
  l_doc_parameters(2).Param_Value :=    l_document_number;
  l_doc_parameters(2).Param_displayname := 'PSIG_USER_KEY_VALUE';

  l_sig_parameters(1).Param_Name := 'SIGNERS_COMMENT';
  l_sig_parameters(1).Param_Value := l_acceptance_note;
  l_sig_parameters(1).Param_displayname := 'Signer Comment';
  l_sig_parameters(2).Param_Name := 'REASON_CODE';
  l_sig_parameters(2).Param_Value := l_reason_code;
  l_sig_parameters(2).Param_displayname := '';
  l_sig_parameters(3).Param_Name := 'WF_SIGNER_TYPE';
  l_sig_parameters(3).Param_Value := l_signer_type;
  l_sig_parameters(3).Param_displayname := '';

  IF (g_po_wf_debug = 'Y') THEN
      l_progress := 'PO_SIGNATURE_PVT.Create_Erecord: 02';
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

    -- Calling capture_signature API to store the eRecord
  PO_ERECORDS_PVT.capture_signature (
 	        p_api_version		 => 1.0,
	        p_init_msg_list		 => FND_API.G_FALSE,
	        p_commit		     => FND_API.G_FALSE,
	        x_return_status		 => l_return_status,
	        x_msg_count		     => l_msg_count,
	        x_msg_data		     => l_msg_data,
	        p_psig_xml		     => NULL,
	        p_psig_document		 => NULL,
	        p_psig_docFormat	 => NULL,
	        p_psig_requester	 => l_requester,
	        p_psig_source		 => 'SSWA',
	        p_event_name		 => l_event_name,
	        p_event_key		     => (l_document_number||'-'||l_revision),
	        p_wf_notif_id		 => l_notif_id,
	        x_document_id		 => l_erecord_id,
	        p_doc_parameters_tbl => l_doc_parameters,
	        p_user_name		     => l_user_name,
	        p_original_recipient => NULL,
	        p_overriding_comment => NULL,
	        x_signature_id		 => l_signature_id,
	        p_evidenceStore_id	 => l_evidence_store_id,
	        p_user_response		 => l_response_code,
	        p_sig_parameters_tbl => l_sig_parameters);


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
        RAISE l_erecords_exception;
  END IF;

  IF l_erecord_id IS NULL THEN
      l_trans_status := 'ERROR';
  ELSE
      l_trans_status := 'SUCCESS';
  END IF;

  PO_ERECORDS_PVT.send_ackn
          ( p_api_version        => 1.0,
            p_init_msg_list	     => FND_API.G_FALSE,
            x_return_status	     => l_return_status,
            x_msg_count		     => l_msg_count,
            x_msg_data		     => l_msg_data,
            p_event_name         => l_event_name,
            p_event_key          => (l_document_number||'-'||l_revision),
            p_erecord_id	     => l_erecord_id,
            p_trans_status	     => l_trans_status,
            p_ackn_by            => l_user_name,
            p_ackn_note	         => l_acceptance_note,
            p_autonomous_commit	 => FND_API.G_FALSE);

  IF (g_po_wf_debug = 'Y') THEN
      l_progress := 'PO_SIGNATURE_PVT.Create_Erecord: 03';
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  IF l_return_status <> 'S' THEN
      RAISE l_erecords_exception;
  END IF;

  PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'ERECORD_ID',
                                    avalue   => l_erecord_id);

  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SIG_ID',
                                   avalue   => l_signature_id);
EXCEPTION
    WHEN l_erecords_exception then
      IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(itemtype, itemkey,
  		                  'End erecords_exception:PO_SIGNATURE_PVT.CREATE_ERECORD ');
             PO_WF_DEBUG_PKG.INSERT_DEBUG(itemtype, itemkey,
  		                  'ERROR RETURNED '||l_msg_data);
      END IF;
      l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemtype, itemkey);
      l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemtype, itemkey);
      wf_core.context('PO_SIGNATURE_PVT', 'Create_Erecord', 'l_erecords_exception');

      PO_REQAPPROVAL_INIT1.send_error_notif(itemtype, itemkey, l_preparer_user_name,
                    l_doc_string, l_msg_data,'PO_SIGNATURE_PVT.Create_Erecord');
      RAISE;
END CREATE_ERECORD;

-------------------------------------------------------------------------------
--Start of Comments
--Name: post_signature
--Pre-reqs:
--  None.
--Modifies:
--  PO_ACCEPTANCES
--  PO_HEADERS_ALL
--  PO_LINE_LOCATIONS_ALL
--  PO_ACTION_HISTORY
--Locks:
--  None.
--Function:
--  This procedure updates the relavant PO tables after the suppliers
--  signature response and buyers signature response.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE post_signature(itemtype	    IN  VARCHAR2,
                         itemkey  	    IN  VARCHAR2,
                         actid	        IN  NUMBER,
                         funcmode	    IN  VARCHAR2,
                         resultout      OUT NOCOPY VARCHAR2) IS

   l_document_id	           PO_HEADERS_ALL.po_header_id%TYPE;
   l_document_type_code	       PO_DOCUMENT_TYPES.document_type_code%TYPE;
   l_document_sub_type_code	   PO_DOCUMENT_TYPES.document_subtype%TYPE;
   l_erecord_id	               PO_ACCEPTANCES.erecord_id%TYPE;
   l_revision_num	           PO_HEADERS_ALL.revision_num%TYPE;
   l_employee_id	           PO_ACCEPTANCES.employee_id%TYPE;
   l_user_id                       NUMBER;
   l_acceptance_note	       PO_ACCEPTANCES.note%TYPE;
   l_role                      PO_ACCEPTANCES.role%TYPE;
   l_supplier_response	       VARCHAR2(20);
   l_buyer_response	           VARCHAR2(20);
   l_action_code	           VARCHAR2(20);
   l_response	               VARCHAR2(20);
   l_accepted_flag             PO_ACCEPTANCES.accepted_flag%TYPE;
   l_accepting_party	       PO_ACCEPTANCES.accepting_party%TYPE;
   l_acceptance_id             PO_ACCEPTANCES.acceptance_id%TYPE;
   l_last_update_date          PO_ACCEPTANCES.last_update_date%TYPE;
   l_last_updated_by           PO_ACCEPTANCES.last_updated_by%TYPE;
   l_last_update_login         PO_ACCEPTANCES.last_update_login%TYPE;
   l_rowid                     ROWID;
   l_progress                  VARCHAR2(300);
   l_doc_string                VARCHAR2(200);
   l_preparer_user_name        WF_USERS.name%TYPE;
   l_result                    VARCHAR2(1);
   l_po_itemtype               WF_ITEMS.item_type%TYPE;
   l_po_itemkey                WF_ITEMS.item_key%TYPE;
   l_response_code             FND_LOOKUP_VALUES.meaning%TYPE;
   l_binding_exception         EXCEPTION;

   --<CONTERMS FPJ START>
   l_acceptance_date   DATE := sysdate;
   l_return_status     VARCHAR2(1);
   l_msg_data          VARCHAR2(2000);
   l_msg_count         NUMBER;
   l_contracts_call_exception   EXCEPTION;
   --<CONTERMS FPJ END>
BEGIN

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.Post_Signature: 01';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_acceptance_note := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                           		       itemkey  => itemkey,
                            	 	                   aname    => 'SIGNATURE_COMMENTS');

  l_supplier_response := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                               		     itemkey  => itemkey,
                            	 	                     aname    => 'SUPPLIER_RESPONSE');

  l_buyer_response := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                   		              itemkey  => itemkey,
                            	 	                  aname    => 'BUYER_RESPONSE');



  -- If the l_buyer_response is NULL then this procedure is called for Suppliers response
  -- otherwise it is called for Buyers response. Since the buyer always signs after the supplier signs.
  IF l_buyer_response IS NULL THEN
     l_employee_id := Null;
     l_accepting_party := 'S';
     l_response := l_supplier_response;

     BEGIN
         SELECT HP.person_title
           INTO l_role
           FROM FND_USER FU,
                HZ_PARTIES HP
          WHERE HP.party_id = FU.customer_id
            AND FU.user_id = fnd_global.user_id;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
             l_role := Null;
     END;
  ELSE

     -- bug3668978
     -- employee id should reflect the person who responds to the notification rather
     -- then the buyer on the document.
     l_employee_id := FND_GLOBAL.employee_id;

/*
      l_employee_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                        		            itemkey  => itemkey,
                             	 	                    aname    => 'BUYER_EMPLOYEE_ID');
*/


     l_accepting_party := 'B';
     l_response := l_buyer_response;
     l_role := Null;
  END IF;

  -- To set the accepted_flag as 'Y' or 'N' based on supplier/buyers response
  IF l_response = 'ACCEPTED' THEN
     l_accepted_flag := 'Y';
  ELSIF l_response = 'REJECTED' THEN
     l_accepted_flag := 'N';
  END IF;

  l_revision_num := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                            		  itemkey  => itemkey,
                            	 	                  aname    => 'PO_REVISION_NUM');

  l_erecord_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                      		        itemkey  => itemkey,
                            	 	                aname    => 'ERECORD_ID');

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                            		 itemkey  => itemkey,
                                            	 	 aname    => 'DOCUMENT_ID');

  l_document_type_code := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                            		      itemkey  => itemkey,
                                            	 	      aname    => 'DOCUMENT_TYPE');

  l_document_sub_type_code := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                   		                      itemkey  => itemkey,
                            	 	                          aname    => 'DOCUMENT_SUBTYPE');

  SELECT wf_item_type,
         wf_item_key
    INTO l_po_itemtype,
         l_po_itemkey
    FROM PO_HEADERS_ALL
   WHERE po_header_id = l_document_id;

  -- Bug 4417522: Removed this profile option
  -- Get the Profile value for the PO: Auto-approve PO after buyer's eSignature
  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.Post_Signature: 02'||'Before calling Acceptance rowhandler';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  BEGIN
      SELECT displayed_field
        INTO l_response_code
        FROM Po_Lookup_Codes
       WHERE Lookup_Type = 'ERECORD_RESPONSE'
         AND Lookup_Code = l_response;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RAISE l_binding_exception;
  END;

  l_user_id := FND_GLOBAL.USER_ID;

 -- Default Promised date with Need-by-Date  only when the profile option is set
   IF( g_default_promise_date = 'Y') THEN
      IF(l_supplier_response = 'ACCEPTED' AND l_buyer_response = 'ACCEPTED') THEN
         POS_ACK_PO.Acknowledge_promise_date(null,l_document_id,null,l_revision_num,l_user_id);
      END IF;
   END IF;


  PO_ACCEPTANCES_INS_PVT.insert_row(
           x_rowid	                        => l_rowid,
           x_acceptance_id		            => l_acceptance_id,
           p_creation_date		            => sysdate,
           p_created_by		                => fnd_global.user_id,
           p_po_header_id		            => l_document_id,
           p_po_release_id		            => Null,
           p_action		                    => l_response_code,
           p_action_date		            => l_acceptance_date,-- CONTERMS FPJ
           p_employee_id		            => l_employee_id,
           p_revision_num		            => l_revision_num,
           p_accepted_flag		            => l_accepted_flag,
           p_acceptance_lookup_code	        => Null,
           p_note		                    => l_acceptance_note,
           p_accepting_party                => l_accepting_party,
           p_signature_flag                 => 'Y',
           p_erecord_id                     => l_erecord_id,
           p_role                           => l_role,
           x_last_update_date               => l_last_update_date,
           x_last_updated_by                => l_last_updated_by,
           x_last_update_login              => l_last_update_login);

  IF l_supplier_response = 'REJECTED' OR l_buyer_response = 'REJECTED' THEN

      IF l_supplier_response = 'REJECTED' THEN
          l_action_code := 'SUPPLIER REJECTED';
      ELSE
          l_action_code := 'BUYER REJECTED';
      END IF;

      Update_Po_Details(p_po_header_id        => l_document_id,
                        p_status              => 'REJECTED',
                        p_action_code         => l_action_code,
                        p_object_type_code    => l_document_type_code,
                        p_object_subtype_code => l_document_sub_type_code,
                        p_employee_id         => l_employee_id,
                        p_revision_num        => l_revision_num);

      -- Completes the Blocked Activities in the PO Approval Process
      Complete_Block_Activities(p_itemkey => l_po_itemkey,
                                p_status  => 'N',
                                x_result  => l_result);

  --  If Profile Auto-approve PO after buyer's e-signature is set to 'Y' then set the document status to
  --  'APPROVED' after accepted by supplier and buyer
  ELSIF l_supplier_response = 'ACCEPTED' AND
        l_buyer_response = 'ACCEPTED' THEN -- Bug 4417522: Removed 'Auto-approve after buyer signature' profile option

      Update_Po_Details(p_po_header_id        => l_document_id,
                        p_status              => 'APPROVED',
                        p_action_code         => 'SIGNED',
                        p_object_type_code    => l_document_type_code,
                        p_object_subtype_code => l_document_sub_type_code,
                        p_employee_id         => l_employee_id,
                        p_revision_num        => l_revision_num);

      --<CONTERMS FPJ START>
      --The control should come here only if po status was successfully
      -- changed to Approved in Update_PO_Details
      -- Inform Contracts to activate deliverable, now that PO is successfully
      -- Changed status to approved
      PO_CONTERMS_WF_PVT.UPDATE_CONTRACT_TERMS(
                p_po_header_id      => l_document_id,
                p_signed_date       => l_acceptance_date,
    	        x_return_status     => l_return_status,
                x_msg_data          => l_msg_data,
                x_msg_count         => l_msg_count);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
            RAISE l_Contracts_call_exception;
      END IF; -- Return status from contracts
      --<CONTERMS FPJ END>

      -- Completes the Blocked Activities in the PO Approval process
      Complete_Block_Activities(p_itemkey => l_po_itemkey,
                                p_status  => 'Y',
                                x_result  => l_result);
  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.Post_Signature: 03'||'Updated PO tables';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  END IF;

  -- Resets the Signature comments attribute to Null
  PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'SIGNATURE_COMMENTS',
                                  avalue   => '');

EXCEPTION
--<CONTERMS FPJ START>
-- Handle contract Exceptions and re raise
WHEN l_contracts_call_exception then
      IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  'End contracts_call_exception:PO_SIGNATURE_PVT.POST_SIGNATURE ');
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  'ERROR RETURNED '||l_msg_data);
      END IF;
      l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
      l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
      wf_core.context('PO_SIGNATURE_PVT', 'Post_Signature', 'l_contracts_call_Exception');

      PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, l_msg_data,'PO_SIGNATURE_PVT.Post_Signature');
      RAISE;
--<CONTERMS FPJ END>
WHEN l_binding_exception then
      IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(itemtype, itemkey,
  		                  'End binding_exception:PO_SIGNATURE_PVT.POST_SIGNATURE ');
             PO_WF_DEBUG_PKG.INSERT_DEBUG(itemtype, itemkey,
  		                  'ERROR RETURNED '||l_msg_data);
      END IF;
      l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemtype, itemkey);
      l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemtype, itemkey);
      wf_core.context('PO_SIGNATURE_PVT', 'Post_Signature', 'l_binding_exception');

      PO_REQAPPROVAL_INIT1.send_error_notif(itemtype, itemkey, l_preparer_user_name,
                    l_doc_string, l_msg_data,'PO_SIGNATURE_PVT.Post_Signature');
      RAISE;

WHEN others THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','Post_Signature',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.POST_SIGNATURE');
    RAISE;
END POST_SIGNATURE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: set_accepted_supplier_response
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Sets the SUPPLIER_RESPONSE workflow attribute to ACCEPTED.
--  Called from PO Approval workflow
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_accepted_supplier_response(itemtype	  IN  VARCHAR2,
                                         itemkey      IN  VARCHAR2,
                                         actid	      IN  NUMBER,
                                         funcmode	  IN  VARCHAR2,
                                         resultout    OUT NOCOPY VARCHAR2) IS

  l_document_id 	          PO_HEADERS_ALL.po_header_id%TYPE;
  l_document_number 	      PO_HEADERS_ALL.segment1%TYPE;
  l_progress                  VARCHAR2(300);
  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        WF_USERS.name%TYPE;
  l_doc_display_name          FND_NEW_MESSAGES.message_text%TYPE;
  l_revision                  PO_HEADERS_ALL.revision_num%TYPE;
  l_po_itemkey                PO_HEADERS_ALL.wf_item_key%TYPE;

BEGIN

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_accepted_supplier_response: 01';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_ID');

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey	=> itemkey,
                                 aname  	=> 'DOCUMENT_NUMBER');

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUPPLIER_RESPONSE',
                                 avalue   => 'ACCEPTED');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_REVISION_NUM');

  l_doc_display_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_DISPLAY_NAME');

  --  Sets the subject of the Buyer signature notification
  FND_MESSAGE.set_name( 'PO', 'PO_BUY_SIGNATURE_MSG_SUB');
  FND_MESSAGE.set_token(token	=> 'DOC_TYPE',
                        value	=> l_doc_display_name);
  FND_MESSAGE.set_token(token	=> 'DOC_NUM',
                        value	=> (l_document_number ||','||l_revision));

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_BUY_SIGNATURE_MSG_SUB',
                                 avalue   => fnd_message.get);

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_BUY_SIGNATURE_MSG_BODY',
                                 avalue   =>
                         'PLSQLCLOB:PO_SIGNATURE_PVT.get_signature_notfn_body/'|| l_document_id ||':'||itemtype||':'||itemkey);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_accepted_supplier_response: 02';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- PO AME Project : Changes made for Multiple E-signatures
  SELECT wf_item_key
  INTO  l_po_itemkey
  FROM po_headers_all poh
  WHERE poh.po_header_id = l_document_id;

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype, itemkey => l_po_itemkey, aname => 'SUPPLIER_RESPONSE', avalue =>  'ACCEPTED');

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_rejected_supplier_response: 03';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION
WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','set_accepted_supplier_response',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.SET_ACCEPTED_SUPPLIER_RESPONSE');
    RAISE;
END SET_ACCEPTED_SUPPLIER_RESPONSE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: set_rejected_supplier_response
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Sets the SUPPLIER_RESPONSE workflow attribute to REJECTED.
--  Called from PO Approval workflow
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_rejected_supplier_response(itemtype  IN  VARCHAR2,
                                         itemkey   IN  VARCHAR2,
                                         actid	   IN  NUMBER,
                                         funcmode  IN  VARCHAR2,
                                         resultout OUT NOCOPY VARCHAR2) IS

  l_document_id 	          PO_HEADERS_ALL.po_header_id%TYPE;
  l_document_number 	      PO_HEADERS_ALL.segment1%TYPE;
  l_progress                  VARCHAR2(300);
  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        WF_USERS.name%TYPE;
  l_doc_display_name          FND_NEW_MESSAGES.message_text%TYPE;
  l_revision                  PO_HEADERS_ALL.revision_num%TYPE;
  l_po_itemkey                PO_HEADERS_ALL.wf_item_key%TYPE;

BEGIN

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_rejected_supplier_response: 01';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_ID');

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype   => itemtype,
                                 itemkey	=> itemkey,
                                 aname  	=> 'DOCUMENT_NUMBER');

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUPPLIER_RESPONSE',
                                 avalue   => 'REJECTED');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_REVISION_NUM');

  l_doc_display_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_DISPLAY_NAME');

  --  Sets the subject of the Supplier Rejection notification to Buyer
  FND_MESSAGE.set_name( 'PO', 'PO_SUP_REJECTION_MSG_SUB');
  FND_MESSAGE.set_token(token	=> 'DOC_TYPE',
                        value	=> l_doc_display_name);
  FND_MESSAGE.set_token(token	=> 'DOC_NUM',
                        value	=> (l_document_number ||','||l_revision));

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_BUY_INFO_MSG_SUB',
                                 avalue   => fnd_message.get);

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_BUY_INFO_MSG_BODY',
                                 avalue   =>
                         'PLSQLCLOB:PO_SIGNATURE_PVT.get_buyer_info_notfn_body/'|| l_document_id ||':'||itemtype||':'||itemkey);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_rejected_supplier_response: 02';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- PO AME Project : Changes made for Multiple E-signatures
  SELECT wf_item_key
  INTO  l_po_itemkey
  FROM po_headers_all poh
  WHERE poh.po_header_id = l_document_id;

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype, itemkey => l_po_itemkey, aname => 'SUPPLIER_RESPONSE', avalue =>  'REJECTED');

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_rejected_supplier_response: 03';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION
WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','set_rejected_supplier_response',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.SET_REJECTED_SUPPLIER_RESPONSE');
    RAISE;
END SET_REJECTED_SUPPLIER_RESPONSE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_buyer_info_notfn_body
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Builds the message body of the Supplier Rejection Notification sent to buyer
--  Called from the Document Signature Process of the PO Approval workflow
--Parameters:
--IN:
--document_id
--  Standard parameter to be used in the procedure for creating PLSQL clob
--display_type
--  Standard parameter to be used in the procedure for creating PLSQL clob
--IN OUT:
--document
--  Standard parameter to be used in the procedure for creating PLSQL clob
--document_type
--  Standard parameter to be used in the procedure for creating PLSQL clob
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_buyer_info_notfn_body (document_id      IN VARCHAR2,
                                     display_type     IN VARCHAR2,
                                     document         IN OUT NOCOPY CLOB,
                                     document_type    IN OUT NOCOPY VARCHAR2) IS

  l_msgbody              VARCHAR2(32000);
  l_document_id          PO_HEADERS_ALL.po_header_id%TYPE;
  l_buyer_name           FND_USER.user_name%TYPE;
  l_msgtext              FND_NEW_MESSAGES.message_text%TYPE;
  l_item_type            WF_ITEMS.item_type%TYPE;
  l_item_key             WF_ITEMS.item_key%TYPE;
  l_firstcolon           NUMBER;
  l_secondcolon          NUMBER;
  l_amount               NUMBER;
  l_document_number      PO_HEADERS_ALL.segment1%TYPE;
  l_doc_display_name     FND_NEW_MESSAGES.message_text%TYPE;
  l_revision             PO_HEADERS_ALL.revision_num%TYPE;
  l_supplier_displayname WF_LOCAL_ROLES.display_name%TYPE;
  l_supplier_username    WF_LOCAL_ROLES.name%TYPE;
  l_supplier_org         PO_VENDORS.vendor_name%TYPE;
  l_supplier_userid      WF_LOCAL_ROLES.orig_system_id%TYPE;
  l_buyer_org            HR_LEGAL_ENTITIES.name%TYPE;
  l_orgid                PO_HEADERS_ALL.org_id%TYPE;
  l_doc_string           VARCHAR2(200);
  l_preparer_user_name   WF_USERS.name%TYPE;
  l_progress             VARCHAR2(300);
  l_binding_exception    EXCEPTION;
  l_acceptance_note	     PO_ACCEPTANCES.note%TYPE;
  l_notif_id 	         NUMBER;
  /* Added for the bug 6358219 to fetch the legal_entity name */
  l_legal_entity_id NUMBER;
  x_legalentity_info  xle_utilities_grp.LegalEntity_Rec;
  x_return_status	VARCHAR2(20) ;
  x_msg_count    NUMBER ;
  x_msg_data    VARCHAR2(4000) ;

BEGIN

  l_firstcolon := instr(document_id, ':');
  l_secondcolon := instr(document_id, ':', 1,2);
  l_document_id := to_number(substr(document_id, 1, l_firstcolon - 1));
  l_item_type := substr(document_id, l_firstcolon + 1, l_secondcolon - l_firstcolon - 1);
  l_item_key := substr(document_id, l_secondcolon+1,length(document_id) - l_secondcolon);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_buyer_info_notfn_body: 01';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

  l_buyer_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                  itemtype => l_item_type,
                                  itemkey  => l_item_key,
                                  aname    => 'BUYER_DISPLAY_NAME');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'PO_REVISION_NUM');

  l_notif_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'NOTIFICATION_ID');

  l_acceptance_note := wf_notification.GetAttrText(l_notif_id, 'SIGNATURE_COMMENTS');

  l_supplier_userid := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'SUPPLIER_USER_ID');

  WF_DIRECTORY.GetUserName(  'FND_USR',
                             l_supplier_userid,
                             l_supplier_username,
                             l_supplier_displayname);

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'DOCUMENT_NUMBER');

  l_doc_display_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'DOCUMENT_DISPLAY_NAME');

  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                         itemtype => l_item_type,
                                         itemkey  => l_item_key,
                                         aname    => 'ORG_ID');

  /* Added for the bug 6358219 to fetch the legal_entity name */

  l_legal_entity_id :=  PO_CORE_S.get_default_legal_entity_id(l_orgid);

  IF l_orgid IS NOT NULL THEN
      BEGIN

      XLE_UTILITIES_GRP.Get_LegalEntity_Info(
         		              x_return_status,
           	     	      x_msg_count,
         		              x_msg_data,
                 	              null,
                 	              l_legal_entity_id,
             	              x_legalentity_info);
          /* SELECT HRL.name
            INTO l_buyer_org
            FROM HR_OPERATING_UNITS HRO,
                 HR_LEGAL_ENTITIES HRL
           WHERE HRO.default_legal_context_id = HRL.organization_id -- Bug#5527795
             AND HRO.organization_id = l_orgid; */
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              RAISE l_binding_exception;
      END;
  ELSE
      l_buyer_org := Null;
  END IF;

  FOR po_rec IN po_hdr_csr(l_document_id)
  LOOP
       l_msgbody := '<html>
       <style> .tableHeaderCell { font-family: Arial; font-size: 10pt;}
               .tableDataCell { font-family: Arial; font-size: 10pt; font-weight: bold; }
       </style>
      <body class="tableHeaderCell">
       <table>
        <tr>
         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_DOCTYPE')||' : </td>
         <td width="40%" class="tableDataCell"> ' || l_doc_display_name || ' </td>

         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_PO_NUMBER') ||': </td>
         <td class="tableDataCell"> ' || po_rec.segment1 ||','|| po_rec.revision_num || ' </td>
        </tr>

        <tr>
         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_SUPPLIER')||' : </td>';

         IF l_buyer_org IS NOT NULL THEN

             l_msgbody := l_msgbody || '<td width="40%" class="tableDataCell"> ' || po_rec.vendor_name || ' </td>
                                        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_ORG') ||': </td>
                                        <td class="tableDataCell"> ' || l_buyer_org || ' </td>';
         ELSE
             l_msgbody := l_msgbody || '<td COLSPAN="3" class="tableDataCell"> ' || po_rec.vendor_name || ' </td>';
         END IF;

        l_msgbody := l_msgbody || '</tr>

       <tr>
        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_CONTACT') ||': </td>
        <td width="40%" class="tableDataCell">' || po_rec.vendor_contact || ' </td>

        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_BUYER') ||': </td>
        <td class="tableDataCell"> ' || l_buyer_name || ' </td>
       </tr>

        <tr>
          <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_DESC')||' :</td>
          <td COLSPAN="3" class="tableDataCell">' || po_rec.comments || ' </td>
        </tr>
     </table>';

     l_supplier_org := po_rec.vendor_name;

  END LOOP;

  FND_MESSAGE.set_name ('PO','PO_WF_NOTIF_SUPPLIER_REJECTED');
  FND_MESSAGE.set_token(token	=> 'DOC_TYPE',
                        value	=> l_doc_display_name);
  FND_MESSAGE.set_token(token	=> 'DOC_NUM',
                        value	=> (l_document_number ||','||l_revision));
  FND_MESSAGE.set_token(token	=> 'SUPPLIER_NAME',
                        value	=> l_supplier_displayname);
  FND_MESSAGE.set_token(token	=> 'SUPPLIER_ORG',
                        value	=> l_supplier_org);
  FND_MESSAGE.set_token(token	=> 'ACTION_DATE',
                        value	=> sysdate);


  l_msgtext := fnd_message.get;

  l_msgbody := l_msgbody ||  '<p class="tableHeaderCell">'||l_msgtext ||'</p>';

  --  SEED DATA for 'PO_WF_NOTIF_SUPPLIER_REJECTED' should indicate that the Supplier Rejected the document

  l_msgbody := l_msgbody ||  '<table> <tr> <td class="tableHeaderCell">'
                         ||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_COMMENTS')
                         ||': </td>'||'<td class="tableDataCell">'
                         ||l_acceptance_note||'</td> </tr> </table>';

  l_msgbody := l_msgbody || '</body></html>';

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_buyer_info_notfn_body: 02';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

  WF_NOTIFICATION.WriteToClob(document, l_msgbody);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_buyer_info_notfn_body: 03';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

EXCEPTION
  WHEN l_binding_exception then
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(l_item_type, l_item_key);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(l_item_type, l_item_key);
    WF_CORE.context('PO_SIGNATURE_PVT','get_buyer_info_notfn_body',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(l_item_type, l_item_key, l_preparer_user_name, l_doc_string, 'l_binding_exception'||sqlerrm, 'PO_SIGNATURE_PVT.GET_BUYER_INFO_NOTFN_BODY');
    RAISE;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(l_item_type, l_item_key);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(l_item_type, l_item_key);
    WF_CORE.context('PO_SIGNATURE_PVT','get_buyer_info_notfn_body',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(l_item_type, l_item_key, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.GET_BUYER_INFO_NOTFN_BODY');
    RAISE;
END GET_BUYER_INFO_NOTFN_BODY;

-------------------------------------------------------------------------------
--Start of Comments
--Name: set_accepted_buyer_response
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Sets the BUYER_RESPONSE workflow attribute to ACCEPTED.
--  Called from PO Approval workflow.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_accepted_buyer_response(itemtype	IN  VARCHAR2,
                                      itemkey  	IN  VARCHAR2,
                                      actid	    IN  NUMBER,
                                      funcmode	IN  VARCHAR2,
                                      resultout OUT NOCOPY VARCHAR2) IS

  l_document_id 	          PO_HEADERS_ALL.po_header_id%TYPE;
  l_document_number 	      PO_HEADERS_ALL.segment1%TYPE;
  l_progress                  VARCHAR2(300);
  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        WF_USERS.name%TYPE;
  l_doc_display_name          FND_NEW_MESSAGES.message_text%TYPE;
  l_revision                  PO_HEADERS_ALL.revision_num%TYPE;

BEGIN

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_accepted_buyer_response: 01';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_ID');

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype   => itemtype,
                                 itemkey	=> itemkey,
                                 aname  	=> 'DOCUMENT_NUMBER');


  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'BUYER_RESPONSE',
                                 avalue   => 'ACCEPTED');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_REVISION_NUM');

  l_doc_display_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_DISPLAY_NAME');

  --  Sets the subject of the Buyer Acceptance notification sent to the Supplier
  FND_MESSAGE.SET_NAME( 'PO', 'PO_BUY_ACCEPTANCE_MSG_SUB');
  FND_MESSAGE.set_token(token	=> 'DOC_TYPE',
                        value	=> l_doc_display_name);
  FND_MESSAGE.set_token(token	=> 'DOC_NUM',
                        value	=> (l_document_number ||','||l_revision));

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_SUP_INFO_MSG_SUB',
                                 avalue   => fnd_message.get);

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_SUP_INFO_MSG_BODY',
                                 avalue   =>
                         'PLSQLCLOB:PO_SIGNATURE_PVT.get_supplier_info_notfn_body/'|| l_document_id ||':'||itemtype||':'||itemkey);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_accepted_buyer_response: 02';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION
WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','set_accepted_buyer_response',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.SET_ACCEPTED_BUYER_RESPONSE');
    RAISE;
END SET_ACCEPTED_BUYER_RESPONSE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_supplier_info_notfn_body
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Builds the message body of the Buyer Acceptance/ Rejection
--  Notification sent to supplier.
--  Called from the Document Signature Process of the PO Approval workflow.
--Parameters:
--IN:
--document_id
--  Standard parameter to be used in the procedure for creating PLSQL clob
--display_type
--  Standard parameter to be used in the procedure for creating PLSQL clob
--IN OUT:
--document
--  Standard parameter to be used in the procedure for creating PLSQL clob
--document_type
--  Standard parameter to be used in the procedure for creating PLSQL clob
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_supplier_info_notfn_body (document_id    IN VARCHAR2,
                                        display_type   IN VARCHAR2,
                                        document       IN OUT NOCOPY CLOB,
                                        document_type  IN OUT NOCOPY VARCHAR2) IS

  l_msgbody             VARCHAR2(32000);
  l_document_id         PO_HEADERS_ALL.po_header_id%TYPE;
  l_buyer_name          FND_USER.user_name%TYPE;
  l_msgtext             FND_NEW_MESSAGES.message_text%TYPE;
  l_buyer_response	    VARCHAR2(20);
  l_item_type           WF_ITEMS.item_type%TYPE;
  l_item_key            WF_ITEMS.item_key%TYPE;
  l_firstcolon          NUMBER;
  l_secondcolon         NUMBER;
  l_amount              NUMBER;
  l_document_number     PO_HEADERS_ALL.segment1%TYPE;
  l_doc_display_name    FND_NEW_MESSAGES.message_text%TYPE;
  l_revision            PO_HEADERS_ALL.revision_num%TYPE;
  l_supplier_name       FND_USER.user_name%TYPE;
  l_buyer_org           HR_LEGAL_ENTITIES.name%TYPE;
  l_orgid               PO_HEADERS_ALL.org_id%TYPE;
  l_doc_string          VARCHAR2(200);
  l_preparer_user_name  WF_USERS.name%TYPE;
  l_progress            VARCHAR2(300);
  l_binding_exception   EXCEPTION;
  l_acceptance_note	    PO_ACCEPTANCES.note%TYPE;
  l_notif_id 	        NUMBER;
  /* Added for the bug 6358219 to fetch the legal_entity name */
  l_legal_entity_id NUMBER;
  x_legalentity_info  xle_utilities_grp.LegalEntity_Rec;
  x_return_status	VARCHAR2(20) ;
  x_msg_count    NUMBER ;
  x_msg_data    VARCHAR2(4000) ;
BEGIN

  l_firstcolon := instr(document_id, ':');
  l_secondcolon := instr(document_id, ':', 1,2);
  l_document_id := to_number(substr(document_id, 1, l_firstcolon - 1));
  l_item_type := substr(document_id, l_firstcolon + 1, l_secondcolon - l_firstcolon - 1);
  l_item_key := substr(document_id, l_secondcolon+1,length(document_id) - l_secondcolon);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_supplier_info_notfn_body: 01';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

  l_buyer_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                         itemtype => l_item_type,
                                         itemkey  => l_item_key,
                                         aname    => 'BUYER_DISPLAY_NAME');

  l_buyer_response := PO_WF_UTIL_PKG.GetItemAttrText(
                                         itemtype => l_item_type,
                                         itemkey  => l_item_key,
                                         aname    => 'BUYER_RESPONSE');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'PO_REVISION_NUM');

  l_notif_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'NOTIFICATION_ID');

  l_acceptance_note := wf_notification.GetAttrText(l_notif_id, 'SIGNATURE_COMMENTS');

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'DOCUMENT_NUMBER');

  l_doc_display_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => l_item_type,
                                 itemkey  => l_item_key,
                                 aname    => 'DOCUMENT_DISPLAY_NAME');

  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                         itemtype => l_item_type,
                                         itemkey  => l_item_key,
                                         aname    => 'ORG_ID');

  /* Added for the bug 6358219 to fetch the legal_entity name */

  l_legal_entity_id :=  PO_CORE_S.get_default_legal_entity_id(l_orgid);
  IF l_orgid IS NOT NULL THEN
      BEGIN
      XLE_UTILITIES_GRP.Get_LegalEntity_Info(
         		              x_return_status,
           	     	      x_msg_count,
         		              x_msg_data,
                 	              null,
                 	              l_legal_entity_id,
             	              x_legalentity_info);
         /* SELECT HRL.name
            INTO l_buyer_org
            FROM HR_OPERATING_UNITS HRO,
                 HR_LEGAL_ENTITIES HRL
           WHERE HRO.default_legal_context_id = HRL.organization_id -- Bug#5527795
             AND HRO.organization_id = l_orgid;*/
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              RAISE l_binding_exception;
      END;
  ELSE
      l_buyer_org := Null;
  END IF;

  FOR po_rec IN po_hdr_csr(l_document_id)
  LOOP
       l_msgbody := '<html>
       <style> .tableHeaderCell { font-family: Arial; font-size: 10pt;}
               .tableDataCell { font-family: Arial; font-size: 10pt; font-weight: bold; }
       </style>
      <body class="tableHeaderCell">
       <table>
        <tr>
         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_DOCTYPE')||' : </td>
         <td width="40%" class="tableDataCell"> ' || l_doc_display_name || ' </td>

         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_PO_NUMBER') ||': </td>
         <td class="tableDataCell"> ' || po_rec.segment1 ||','|| po_rec.revision_num || ' </td>
        </tr>

        <tr>
         <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_SUPPLIER')||' : </td>';

         IF l_buyer_org IS NOT NULL THEN

             l_msgbody := l_msgbody || '<td width="40%" class="tableDataCell"> ' || po_rec.vendor_name || ' </td>
                                        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_ORG') ||': </td>
                                        <td class="tableDataCell"> ' || l_buyer_org || ' </td>';
         ELSE
             l_msgbody := l_msgbody || '<td COLSPAN="3" class="tableDataCell"> ' || po_rec.vendor_name || ' </td>';
         END IF;

        l_msgbody := l_msgbody || '</tr>

       <tr>
        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_CONTACT') ||': </td>
        <td width="40%" class="tableDataCell">' || po_rec.vendor_contact || ' </td>

        <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_BUYER') ||': </td>
        <td class="tableDataCell"> ' || l_buyer_name || ' </td>
       </tr>

        <tr>
          <td class="tableHeaderCell" align="right"> '||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_DESC')||' :</td>
          <td COLSPAN="3" class="tableDataCell">' || po_rec.comments || ' </td>
        </tr>
     </table>';
  END LOOP;

  IF l_buyer_response = 'ACCEPTED' THEN
      FND_MESSAGE.set_name ('PO','PO_WF_NOTIF_BUYER_ACCEPTED');
  ELSIF l_buyer_response = 'REJECTED' THEN
      FND_MESSAGE.set_name ('PO','PO_WF_NOTIF_BUYER_REJECTED');
  END IF;

  FND_MESSAGE.set_token(token	=> 'DOC_TYPE',
                        value	=> l_doc_display_name);
  FND_MESSAGE.set_token(token	=> 'DOC_NUM',
                        value	=> (l_document_number ||','||l_revision));
  FND_MESSAGE.set_token(token	=> 'BUYER_NAME',
                        value	=> l_buyer_name);
  FND_MESSAGE.set_token(token	=> 'BUYER_ORG',
                        value	=> l_buyer_org);
  FND_MESSAGE.set_token(token	=> 'ACTION_DATE',
                        value	=> sysdate);

  l_msgtext := fnd_message.get;
  l_msgbody := l_msgbody ||  '<p class="tableHeaderCell">'||l_msgtext ||'</p>';

  --  SEED DATA for 'PO_WF_NOTIF_BUYER_ACCEPTED' should indicate that the Buyer Accepted the document
  --  SEED DATA for 'PO_WF_NOTIF_BUYER_REJECTED' should indicate that the Buyer Rejected the document

  l_msgbody := l_msgbody ||  '<table> <tr> <td class="tableHeaderCell">'
                         ||fnd_message.get_string('PO', 'PO_WF_SIGN_NOTIF_COMMENTS')
                         ||': </td>'||'<td class="tableDataCell">'
                         ||l_acceptance_note||'</td> </tr> </table>';

  l_msgbody := l_msgbody || '</body></html>';

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_supplier_info_notfn_body: 02';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

  WF_NOTIFICATION.WriteToClob(document, l_msgbody);

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.get_supplier_info_notfn_body: 03';
     PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
  END IF;

EXCEPTION
  WHEN l_binding_exception then
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(l_item_type, l_item_key);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(l_item_type, l_item_key);
    WF_CORE.context('PO_SIGNATURE_PVT','get_supplier_info_notfn_body',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(l_item_type, l_item_key, l_preparer_user_name, l_doc_string, 'l_binding_exception'||sqlerrm, 'PO_SIGNATURE_PVT.GET_SUPPLIER_INFO_NOTFN_BODY');
    RAISE;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(l_item_type, l_item_key);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(l_item_type, l_item_key);
    WF_CORE.context('PO_SIGNATURE_PVT','get_supplier_info_notfn_body',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(l_item_type, l_item_key, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.GET_SUPPLIER_INFO_NOTFN_BODY');
    RAISE;

END GET_SUPPLIER_INFO_NOTFN_BODY;

-------------------------------------------------------------------------------
--Start of Comments
--Name: set_rejected_buyer_response
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Sets the BUYER_RESPONSE workflow attribute to REJECTED.
--  Called from PO Approval workflow.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_rejected_buyer_response(itemtype	IN  VARCHAR2,
                                      itemkey  	IN  VARCHAR2,
                                      actid	    IN  NUMBER,
                                      funcmode	IN  VARCHAR2,
                                      resultout OUT NOCOPY VARCHAR2) IS

  l_document_id 	          PO_HEADERS_ALL.po_header_id%TYPE;
  l_document_number 	      PO_HEADERS_ALL.segment1%TYPE;
  l_progress                  VARCHAR2(300);
  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        WF_USERS.name%TYPE;
  l_doc_display_name          FND_NEW_MESSAGES.message_text%TYPE;
  l_revision                  PO_HEADERS_ALL.revision_num%TYPE;

BEGIN

  IF (g_po_wf_debug = 'Y') THEN
     l_progress := 'PO_SIGNATURE_PVT.set_rejected_buyer_response: 01';
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_ID');

  l_document_number := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype   => itemtype,
                                 itemkey	=> itemkey,
                                 aname  	=> 'DOCUMENT_NUMBER');


  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'BUYER_RESPONSE',
                                 avalue   => 'REJECTED');

  l_revision := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_REVISION_NUM');

  l_doc_display_name := PO_WF_UTIL_PKG.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'DOCUMENT_DISPLAY_NAME');

  -- Sets the subject of the Buyer Rejection notification sent to the Supplier
  FND_MESSAGE.set_name( 'PO', 'PO_BUY_REJECTION_MSG_SUB');
  FND_MESSAGE.set_token(token	=> 'DOC_TYPE',
                        value	=> l_doc_display_name);
  FND_MESSAGE.set_token(token	=> 'DOC_NUM',
                        value	=> (l_document_number ||','||l_revision));

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_SUP_INFO_MSG_SUB',
                                 avalue   => fnd_message.get);

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PO_SUP_INFO_MSG_BODY',
                                 avalue   =>
                         'PLSQLCLOB:PO_SIGNATURE_PVT.get_supplier_info_notfn_body/'|| l_document_id ||':'||itemtype||':'||itemkey);


EXCEPTION
WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','set_rejected_buyer_response',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.SET_REJECTED_BUYER_RESPONSE');
    RAISE;
END SET_REJECTED_BUYER_RESPONSE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Is_Signature_Required
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Checks if the Signature is required for the document.
--  Called from PO Approval workflow.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Is_Signature_Required(itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2) IS

  l_req_signature             VARCHAR2(1);
  l_acceptance_flag           PO_HEADERS_ALL.acceptance_required_flag%TYPE := 'N';
  l_document_type             PO_DOCUMENT_TYPES.document_type_code%TYPE;
  l_document_id               PO_HEADERS_ALL.po_header_id%TYPE;
  l_progress                  VARCHAR2(300);
  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        WF_USERS.name%TYPE;

BEGIN

  IF (g_po_wf_debug = 'Y') THEN
      l_progress := 'PO_SIGNATURE_PVT.Is_Signature_Required: 01';
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> WF_ENGINE.eng_run) then
      resultout := WF_ENGINE.eng_null;
      return;
  END if;

    -- <BUG 3607009 START>
    --
    IF ( is_signature_required(itemtype,itemkey) )
    THEN
        l_req_signature := 'Y';
    ELSE
        l_req_signature := 'N';
    END IF;
    --
    -- <BUG 3607009 END>

  resultout := WF_ENGINE.eng_completed || ':' || l_req_signature ;

  IF (g_po_wf_debug = 'Y') THEN
      l_progress := 'PO_SIGNATURE_PVT.Is_Signature_Required: 02. Result= ' || l_req_signature;
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','is_signature_required',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.IS_SIGNATURE_REQUIRED');
    RAISE;
END IS_SIGNATURE_REQUIRED;


------------------------------------------------------------------<BUG 3607009>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_signature_required
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Checks if the signature is required for the document.
--Parameters:
--IN:
--p_itemtype
--  Standard parameter to be used in a workflow procedure
--p_itemkey
--  Standard parameter to be used in a workflow procedure
--Returns:
--  A BOOLEAN TRUE if document signature is required. FALSE otherwise.
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_signature_required
(
    p_itemtype         IN   VARCHAR2
,   p_itemkey          IN   VARCHAR2
)
RETURN BOOLEAN
IS
    l_api_name             VARCHAR2(30) := 'is_signature_required';
    l_log_head             VARCHAR2(100) := g_pkg_name || '.' || l_api_name;
    l_progress             VARCHAR2(3);

    l_document_type        PO_DOCUMENT_TYPES.document_type_code%TYPE;
    l_document_id          PO_HEADERS_ALL.po_header_id%TYPE;
    l_signature_required   BOOLEAN;
    l_acceptance_flag      PO_HEADERS_ALL.acceptance_required_flag%TYPE := 'N';

BEGIN

l_progress:='000'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress);

    -- Get the Document Type and ID from the Workflow Attributes.
    --
    l_document_type := PO_WF_UTIL_PKG.GetItemAttrText
                       (   itemtype => p_itemtype
                       ,   itemkey  => p_itemkey
                       ,   aname    => 'DOCUMENT_TYPE'
                       );
    l_document_id :=   PO_WF_UTIL_PKG.GetItemAttrNumber
                       (   itemtype => p_itemtype
                       ,   itemkey  => p_itemkey
                       ,   aname    => 'DOCUMENT_ID'
                       );
l_progress:='010'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||' Document Type = '||l_document_type);
l_progress:='020'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||' Document ID = '||l_document_id);

    -- If the document is not a Release, then the get the value of the
    -- Acceptance Required Flag.
    --
    IF ( l_document_type <> 'RELEASE' )
    THEN
        SELECT acceptance_required_flag
        INTO   l_acceptance_flag
        FROM   po_headers_all
        WHERE  po_header_id = l_document_id;
    END IF;

l_progress:='030'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||' Acceptance Required Flag = '||l_acceptance_flag);

    -- If the Acceptance Required Flag is 'S',
    -- then a Signature is required; else, no Signature is required.
    --
    IF ( l_acceptance_flag = 'S' )
    THEN
        l_signature_required := TRUE;
l_progress:='040'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||' Signature Required = TRUE');
    ELSE
        l_signature_required := FALSE;
l_progress:='050'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||' Signature Required = FALSE');
    END IF;

    return (l_signature_required);

EXCEPTION

    WHEN OTHERS THEN
        PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||SQLERRM);
        RAISE;

END is_signature_required;


-------------------------------------------------------------------------------
--Start of Comments
--Name: Was_Signature_Required
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This function checks if there is atleast one signed revision
--  from the supplier
--Parameters:
--IN:
--p_document_id
--  NUMBER - po header id
--Returns:
--  A boolean. TRUE if the document was signed atleast once
--  FALSE if the document was nnever signed.
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Was_Signature_Required(p_document_id IN NUMBER) return BOOLEAN is

  l_signatures VARCHAR2(1) := 'N';

BEGIN

/*  -- SQL What:Checks if there is any record in the PO_ACTION_HISTORY with the
  --          action code as 'SIGNED'
  -- SQL Why :To find out if the document was ever signed

      /*SELECT 'Y'
        INTO l_signatures
        FROM dual
       WHERE EXISTS (SELECT 1
                       FROM PO_ACTION_HISTORY
                      WHERE object_id = p_document_id
                        AND object_type_code IN ('PO','PA')
                        AND action_code = 'SIGNED'); */

-- Bug 14601938 : Verify signauture exists on the basis of record in po_acceptances table for SUPPLIER siganture
-- to avoid confusion between e-signature and supplier signature when using AME.
       SELECT 'Y'
       INTO l_signatures
       FROM dual
       WHERE EXISTS  (SELECT 1
                         FROM PO_ACCEPTANCES
                       WHERE po_header_id = p_document_id
                        -- AND accepting_party ='S'   -- bug#17442526
                        -- AND action = 'Accepted'    -- bug#17442526
                     )
          AND EXISTS (SELECT 1
                        FROM PO_HEADERS_ARCHIVE_ALL
                      WHERE po_header_id = p_document_id
                        AND latest_external_flag = 'Y'
                        AND acceptance_required_flag  ='S'
                     );        -- bug#17442526: add above condition

  IF l_signatures = 'Y' THEN
     Return TRUE;
  ELSE
     Return FALSE;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Return FALSE;
END WAS_SIGNATURE_REQUIRED;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Set_Supplier_Notification_Id
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Sets the Supplier Notification Id attribute of the Signature Notification
--  Called from PO Approval workflow.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Set_Supplier_Notification_Id(itemtype        IN VARCHAR2,
                                       itemkey         IN VARCHAR2,
                                       actid           IN NUMBER,
                                       funcmode        IN VARCHAR2,
                                       resultout       OUT NOCOPY VARCHAR2) IS
  l_notification_id           NUMBER;
  l_progress                  VARCHAR2(300);
  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        WF_USERS.name%TYPE;

BEGIN
  IF (funcmode = 'RESPOND') THEN
      l_notification_id := WF_ENGINE.context_nid;

      PO_WF_UTIL_PKG.SetItemAttrNumber(
                                 itemtype   => itemtype,
                                 itemkey	=> itemkey,
                                 aname  	=> 'NOTIFICATION_ID',
                                 avalue  	=> l_notification_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','set_supplier_notification_id',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.SET_SUPPLIER_NOTIFICATION_ID');
    RAISE;
END SET_SUPPLIER_NOTIFICATION_ID;


-------------------------------------------------------------------------------
--Start of Comments
--Name: Set_Buyer_Notification_Id
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Sets the Buyer Notification Id attribute of the Signature Notification
--  Called from PO Approval workflow.
--Parameters:
--IN:
--itemtype
--  Standard parameter to be used in a workflow procedure
--itemkey
--  Standard parameter to be used in a workflow procedure
--actid
--  Standard parameter to be used in a workflow procedure
--funcmode
--  Standard parameter to be used in a workflow procedure
--OUT:
--resultout
--  Standard parameter to be used in a workflow procedure
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Set_Buyer_Notification_Id(itemtype        IN VARCHAR2,
                                    itemkey         IN VARCHAR2,
                                    actid           IN NUMBER,
                                    funcmode        IN VARCHAR2,
                                    resultout       OUT NOCOPY VARCHAR2) IS

  l_notification_id           NUMBER;
  l_progress                  VARCHAR2(300);
  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        WF_USERS.name%TYPE;

BEGIN

  IF (funcmode = 'RESPOND') THEN
      l_notification_id := WF_ENGINE.context_nid;

      PO_WF_UTIL_PKG.SetItemAttrNumber(
                                 itemtype   => itemtype,
                                 itemkey	=> itemkey,
                                 aname  	=> 'NOTIFICATION_ID',
                                 avalue  	=> l_notification_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_SIGNATURE_PVT','set_buyer_notification_id',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_SIGNATURE_PVT.SET_BUYER_NOTIFICATION_ID');
    RAISE;
END SET_BUYER_NOTIFICATION_ID;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Po_Details
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Updates PO tables
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_status
--  Indicates if the Document is 'ACCEPTED' or 'REJECTED' while signing
--p_action_code
--  Action code to be inserted in PO_ACTION_HISTORY table.
--  Valid values 'SIGNED', 'BUYER REJECTED', 'SUPPLIER REJECTED'
--p_object_type_code
--  Document type - 'PO', 'PA' etc
--p_object_subtype_code
--  Document Subtype - 'STANDARD', 'CONTRACT', 'BLANKET' etc
--p_employee_id
--  Employee Id of the Buyer
--p_revision_num
--  Revision Number of the document
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Update_Po_Details(p_po_header_id        IN NUMBER,
                            p_status              IN VARCHAR2,
                            p_action_code         IN VARCHAR2,
                            p_object_type_code    IN VARCHAR2,
                            p_object_subtype_code IN VARCHAR2,
                            p_employee_id         IN NUMBER,
                            p_revision_num        IN NUMBER
                            ) IS

  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_PO_DETAILS'; -- Bug 3602512

  l_approved_flag    PO_HEADERS_ALL.approved_flag%TYPE;
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_ret_sts          VARCHAR2(1);  --bug 13507482
  l_supply_action    VARCHAR2(40); --bug 13507482
  l_bool_ret_sts     BOOLEAN;  --bug 13507482
  l_err_msg	     VARCHAR2(200); --bug 13507482
  d_module CONSTANT  VARCHAR2(70) := 'po.plsql.PO_SIGNATURE_PVT.UPDATE_PO_DETAILS';
  d_pos NUMBER := 0;

BEGIN
    IF (PO_LOG.d_proc) THEN
        PO_LOG.proc_begin(d_module,'p_po_header_id',p_po_header_id);
	PO_LOG.proc_begin(d_module,'p_action_code',p_action_code);
    END IF;

    IF (p_status = 'REJECTED') THEN
        l_approved_flag := 'F';
    ELSIF (p_status = 'APPROVED') THEN
        l_approved_flag := 'Y';

        --call the PO_UPDATE_DATE_PKG to update the promised date based on BPA lead time.
        PO_UPDATE_DATE_PKG.update_promised_date_lead_time (p_po_header_id);

        -- SQL What:Updates PO_LINE_LOCATIONS_ALL table and sets the Approved_Flag to Y
        -- SQL Why :To indicate that the shipments are now available for execution

        -- Bug 7494807 START
        /*Added NVL condition for approved_flag to update the value after buyer signed the
        document.*/

        UPDATE PO_LINE_LOCATIONS_ALL
           SET approved_flag = 'Y',
               approved_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id,
               last_update_date = sysdate
         WHERE po_header_id = p_po_header_id
           AND NVL(cancel_flag,'N') = 'N'
           AND NVL(closed_code,'OPEN') <> 'FINALLY CLOSED'
           -- <Complex Work R12>: Include PREPAYMENT shipment_type
           AND shipment_type IN ('STANDARD','BLANKET','SCHEDULED','PREPAYMENT')
           AND NVL(approved_flag,'N') <> 'Y';

        -- Bug 7494807 END

        -- Bug 3616320 START
        -- Don't call clear_amendment here, move the call to
        -- PO_DOCUMENT_REVISION_GRP.Check_New_Revision()
        /*
        -- Calls Contracts API to clear Amendment related columns
        OKC_TERMS_VERSION_GRP.clear_amendment(
                                p_api_version   => 1.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_commit        => FND_API.G_FALSE,
                                x_return_status => l_return_status,
                                x_msg_data      => l_msg_data,
                                x_msg_count     => l_msg_count,
                                p_doc_type      => (p_object_type_code ||'_'||p_object_subtype_code),
                                p_doc_id        => p_po_header_id);
        */
        -- Bug 3616320 END
    END IF;

  -- SQL What:Updates PO_HEADERS_ALL table and sets the Authorization status
  --          to 'APPROVED' or 'REJECTED'
  -- SQL Why :To move the document from the PRE-APPROVED status
  -- SQL Join:po_header_id

    UPDATE PO_HEADERS_ALL
       SET authorization_status      = p_status,
           approved_flag             = l_approved_flag,
           approved_date = decode(l_approved_flag, 'Y', sysdate, null), --Bug 16990321
           pending_signature_flag    = 'N',
           acceptance_required_flag  = 'N',
           acceptance_due_date       = Null,
           last_updated_by           = FND_GLOBAL.user_id,
           last_update_login         = FND_GLOBAL.login_id,
           last_update_date          = sysdate
     WHERE po_header_id = p_po_header_id;

     --  Insert a record in the PO_ACTION_HISTORY table with the Signature details

-- bug 3568077
-- Replaced PO_FORWARD_SV1.insert_action_history
-- with PO_ACTION_HISTORY_SV.insert_action_history.

-- bug3738420
-- We should pass p_employee_id to insert_action_history isntead of deriving
-- it from PO_ACCEPTANCES table because the person who is logged in accetpance table may
-- not be the one who performs the action.

PO_ACTION_HISTORY_SV.insert_action_history(
   p_doc_id_tbl            => po_tbl_number(p_po_header_id)
,  p_doc_type_tbl          => po_tbl_varchar30(p_object_type_code)
,  p_doc_subtype_tbl       => po_tbl_varchar30(p_object_subtype_code)
,  p_doc_revision_num_tbl  => po_tbl_number(p_revision_num)
,  p_action_code_tbl       => po_tbl_varchar30(p_action_code)
,  p_employee_id           => p_employee_id -- bug3738420
);

  --Bug 16990321 START
  IF ('Y' = l_approved_flag)
     AND ('PA' = p_object_type_code)
     AND ('BLANKET' = p_object_subtype_code)
  THEN
    PO_CATALOG_INDEX_PVT.rebuild_index (
                p_type          => PO_CATALOG_INDEX_PVT.TYPE_BLANKET,
         	p_po_header_id  => p_po_header_id);
  END IF;
  --Bug 16990321 END

  -- Bug 3602512 START
  -- If we are setting the standard PO's status to Approved, call the FTE API
  -- to update the Inbound Logistics delivery records.

  d_pos := 10;
  IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module,d_pos,'p_object_type_code',p_object_type_code);
     PO_LOG.stmt(d_module,d_pos,'p_object_subtype_code',p_object_subtype_code);
  END IF;

  IF (p_status = 'APPROVED')
     AND ((p_object_type_code = 'PO')
          AND (p_object_subtype_code = 'STANDARD')) THEN
    -- Note: Signatures are not supported for blanket releases.

    --Start of code changes for the bug 13507482. Inserting MTL_SUPPLY record when the Buyer/Supplier Accepts the PO.
    BEGIN

	PO_DOCUMENT_ACTION_AUTH.get_supply_action_name(
		p_action           => PO_DOCUMENT_ACTION_PVT.g_doc_action_APPROVE
	,  p_document_type    => p_object_type_code
	,  p_document_subtype => p_object_subtype_code
	,  x_return_status    => l_ret_sts
	,  x_supply_action    => l_supply_action
	);

	IF (l_ret_sts <> 'S')
	THEN
		d_pos := 20;
		l_err_msg := 'get_supply_action_name not successful';
		RAISE PO_CORE_S.g_early_return_exc;
	END IF;

	d_pos := 30;
	IF (PO_LOG.d_stmt) THEN
	PO_LOG.stmt(d_module,d_pos,'l_supply_action',l_supply_action);
	END IF;

	l_bool_ret_sts :=
			PO_SUPPLY.po_req_supply(
			p_docid          => p_po_header_id
			,  p_lineid         => NULL
			,  p_shipid         => NULL
			,  p_action         => l_supply_action
			,  p_recreate_flag  => FALSE
			,  p_qty            => NULL
			,  p_receipt_date   => NULL
			);

	IF (NOT l_bool_ret_sts)
	THEN
		d_pos := 40;
		l_err_msg := 'po_req_supply returned false';
		RAISE PO_CORE_S.g_early_return_exc;
	END IF;

    EXCEPTION
	WHEN PO_CORE_S.g_early_return_exc THEN
 	  IF (PO_LOG.d_exc) THEN
		PO_LOG.exc(d_module, d_pos, l_err_msg);
	  END IF;
    END;
    --End of code changes for the bug 13507482

    PO_DELREC_PVT.create_update_delrec (
      p_api_version => 1.0,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_action => 'APPROVE',
      p_doc_type => p_object_type_code,
      p_doc_subtype => p_object_subtype_code,
      p_doc_id => p_po_header_id,
      p_line_id => NULL,
      p_line_location_id => NULL
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;
  -- Bug 3602512 END

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  -- Bug 3602512 START
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (g_debug_unexp) THEN
      FOR i IN 1..FND_MSG_PUB.count_msg LOOP
        PO_DEBUG.debug_unexp (
          p_log_head => c_log_head||l_api_name,
          p_progress => NULL,
          p_message => FND_MSG_PUB.get ( p_msg_index => i,
                                         p_encoded => FND_API.G_FALSE ) );
      END LOOP;
    END IF;
    RAISE;
  -- Bug 3602512 END
  WHEN OTHERS THEN
    RAISE;
END UPDATE_PO_DETAILS;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_ITEM_KEY
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Creates and Returns item key for the Document Signature Process
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--p_document_type
--  Document type - 'PO', 'PA' etc
--OUT:
--x_itemkey
--  Item key of the Document Signature Process
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_Item_Key(p_po_header_id  IN  NUMBER,
                       p_revision_num  IN  NUMBER,
                       p_document_type IN  VARCHAR2,
                       x_itemkey       OUT NOCOPY VARCHAR2,
                       x_result        OUT NOCOPY VARCHAR2)
IS
  l_itemkey            WF_ITEMS.item_key%TYPE := NULL;
  l_seq_for_item_key   VARCHAR2(25)  := null; --Bug14305923

BEGIN

    SELECT to_char(PO_WF_ITEMKEY_S.NEXTVAL)
    INTO l_seq_for_item_key
    FROM sys.dual;

    l_itemkey := 'PO_DOC_BIND_'||p_po_header_id||'_'||p_revision_num||'_'
                 ||p_document_type || '_' ||l_seq_for_item_key;

    x_itemkey := l_itemkey;
    x_result := 'S';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_result := 'E';
END GET_ITEM_KEY;

-------------------------------------------------------------------------------
--Start of Comments
--Name: FIND_ITEM_KEY
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Returns item key of the active Document Signature Process
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--p_document_type
--  Document type - 'PO', 'PA' etc
--OUT:
--x_itemkey
--  Item key of the active Document Signature Process
--x_result
--  Returns 'S' for success and 'E' for Error
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Find_Item_Key(p_po_header_id  IN  NUMBER,
                        p_revision_num  IN  NUMBER,
                        p_document_type IN  VARCHAR2,
                        x_itemkey       OUT NOCOPY VARCHAR2,
                        x_result        OUT NOCOPY VARCHAR2)
IS
  l_itemkey         WF_ITEMS.item_key%TYPE := NULL;
  l_itemkey_like    VARCHAR2(240);
BEGIN

    l_itemkey_like := 'PO_DOC_BIND_'||p_po_header_id||'_'||p_revision_num||'_'||p_document_type||'%';

    SELECT item_key
      INTO l_itemkey
      FROM WF_ITEMS
     WHERE item_type = 'POAPPRV'
       AND item_key LIKE l_itemkey_like
       AND end_date IS NULL;

    x_result := 'S';
    x_itemkey := l_itemkey;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_itemkey := l_itemkey;
        x_result := 'S';
    WHEN TOO_MANY_ROWS THEN
        x_result := 'E';
END FIND_ITEM_KEY;


-------------------------------------------------------------------------------
--Start of Comments
--Name: Abort_Doc_Sign_Process
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Once signatures are complete aborts the Document Signature Process
--Parameters:
--IN:
--p_itemkey
--  Item key of the PO Approval workflow Document Signature Process
--OUT:
--x_result
--  Returns 'S' for success and 'E' for Error
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Abort_Doc_Sign_Process(p_itemkey IN  VARCHAR2,
                                 x_result  OUT NOCOPY VARCHAR2)
IS
  l_itemkey  WF_ITEMS.item_key%TYPE;
BEGIN
    SELECT item_key
      INTO l_itemkey
      FROM WF_ITEMS
     WHERE item_type = 'POAPPRV'
       AND item_key = p_itemkey
       AND end_date IS NULL;

    IF l_itemkey IS NOT NULL THEN
         WF_ENGINE.AbortProcess(itemtype    => 'POAPPRV',
                                itemkey     => l_itemkey,
                                process     => '',
                                result      => WF_ENGINE.eng_force);
    END IF;
    x_result := 'S';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_result := 'S';
END ABORT_DOC_SIGN_PROCESS;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Complete_Block_Activities
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Once signatures are done completes the Blocked activities in the
--  PO Approval workflow
--Parameters:
--IN:
--p_itemkey
--  Item key of the PO Approval workflow
--p_status
--  Indicates if the Block activity should take 'Y' path - Document Approved
--  or 'N' path - Document Rejected
--OUT:
--x_result
--  Returns 'S' for success
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Complete_Block_Activities(p_itemkey IN         VARCHAR2,
                                    p_status  IN         VARCHAR2,
                                    x_result  OUT NOCOPY VARCHAR2)
IS
  l_activity_name  WF_PROCESS_ACTIVITIES.activity_name%TYPE;
BEGIN
    BEGIN
        -- SQL What:Selects the Block Activity that is in the NOTIFIED state in the PO Approval workflow
        -- SQL Why :To find out the name of the Block activity that needs to be completed
        SELECT WPA.activity_name
          INTO l_activity_name
          FROM WF_PROCESS_ACTIVITIES WPA,
               WF_ITEM_ACTIVITY_STATUSES WIA
         WHERE WIA.item_type        = 'POAPPRV'
           AND WIA.item_key         = p_itemkey
           AND WIA.process_activity = WPA.INSTANCE_ID
           AND WPA.activity_name   IN ('BLOCK_PREAPP','BLOCK_CHGAPP')
           AND WIA.activity_status  = 'NOTIFIED';

        x_result := 'S';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_activity_name := NULL;
            x_result := 'S';
    END;

    IF l_activity_name IS NOT NULL THEN
        WF_ENGINE.CompleteActivity('POAPPRV', p_itemkey, l_activity_name, p_status);
    END IF;
END COMPLETE_BLOCK_ACTIVITIES;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_LAST_SIGNED_REVISION
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Gets last Signed revision number
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--OUT:
--x_signed_revision_num
--  Returns the last Signed revision or Last Approved revision that
--  does not need signature
--x_signed_records
--  Returns 'Y' if there are any signed or accepted revisions. Otherwise returns 'N'
--x_return_status
--  Returns 'S' for Success and 'E' for unexpected error
--Testing:
--  Testing to be done based on the test cases in Communication DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_Last_Signed_Revision(p_po_header_id        IN NUMBER,
                                   p_revision_num        IN NUMBER,
                                   x_signed_revision_num OUT NOCOPY NUMBER,
                                   x_signed_records      OUT NOCOPY VARCHAR2,
                                   x_return_status       OUT NOCOPY VARCHAR2)
IS

    -- Bug 3632074
    -- Changed cursor SQL so that it is more understandable
    -- And also so that there is no need for a cursor loop.
    -- SQL: find highest revision number that is either
    -- 1) signed or 2) approved, but not rejected
    -- #2 is necessary for the acceptances not required cases.

    CURSOR po_amd_csr(p_po_header_id NUMBER, p_revision_num NUMBER) IS
        SELECT object_revision_num
          FROM PO_ACTION_HISTORY PAH
         WHERE PAH.object_id = p_po_header_id
           AND PAH.object_type_code IN ('PO','PA')
           AND (
                (PAH.action_code = 'SIGNED')
                            OR
                (PAH.action_code = 'APPROVE'
                     and
                   not exists (
                      SELECT 1
                        FROM PO_ACTION_HISTORY PAH1
                       WHERE PAH1.object_id = PAH.object_id
                         AND PAH1.object_type_code = pah.object_type_code
                         AND PAH1.action_code IN ('BUYER REJECTED','SUPPLIER REJECTED')
                         AND PAH1.object_revision_num = PAH.object_revision_num
                   )
                 )
               )
           AND PAH.object_revision_num < p_revision_num
      ORDER BY object_revision_num DESC;

  l_po_amd_csr_rec  po_amd_csr%ROWTYPE;

BEGIN

    x_signed_records := 'Y';
    x_return_status := 'S';

    IF p_revision_num <> 0 THEN

      -- START Bug 3632074

      OPEN po_amd_csr(p_po_header_id, p_revision_num);
      FETCH  po_amd_csr INTO l_po_amd_csr_rec;

      IF po_amd_csr%NOTFOUND THEN
        CLOSE po_amd_csr;
        x_signed_records := 'N';
        x_signed_revision_num := NULL;
        RETURN;
      END IF;

      x_signed_records := 'Y';
      x_signed_revision_num := l_po_amd_csr_rec.object_revision_num;
      CLOSE po_amd_csr;

      -- END Bug 3632074

    ELSE
        -- If the revision number is zero, then there are no previously signed
        -- records as this is the initial revision
        x_signed_revision_num := NULL;
        x_signed_records := 'N';
    END IF;

EXCEPTION
  WHEN OTHERS THEN

    -- Bug 3632074: Close cursor if open
    IF po_amd_csr%ISOPEN THEN
       CLOSE po_amd_csr;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;

END GET_LAST_SIGNED_REVISION;

-------------------------------------------------------------------------------
--Start of Comments
--Name: DOES_ERECORD_EXIST
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Queries PO tables to find out if eRecord exist
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--OUT:
--x_erecord_exist
--  Returns 'Y' if eRecord exists. Else returns 'N'
--Testing:
--  Testing to be done based on the test cases in Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Does_Erecord_Exist(p_po_header_id           IN  NUMBER,
                             p_revision_num           IN  NUMBER,
                             x_erecord_exist          OUT NOCOPY VARCHAR2,
                             x_pending_signature      OUT NOCOPY VARCHAR2)
IS
  l_current_org             PO_HEADERS_ALL.org_id%TYPE;
  l_doc_org                 PO_HEADERS_ALL.org_id%TYPE;
BEGIN

    l_current_org := PO_GA_PVT.get_current_org;
    l_doc_org := PO_GA_PVT.get_org_id(p_po_header_id);

    -- If the current org and the Document org are not same then the
    -- Aceptances form should be opend in the view only mode
    IF (l_current_org = l_doc_org) THEN

        --  If the document is not 'release' and if the pending_signature_flag is 'Y',
        --  PO_SIGNATURE parameter should be set to 'Y' which allows inserts in the
        -- Aceptances form. Otherwise Acceptances form is called in the view only mode
        BEGIN
            -- SQL What: Selects the Pending_Signature_Flag from the PO_HEADERS_ALL table
            -- SQL Why : To find out if the document has pending signatures or not
            -- SQL Join: PO_HEADER_ID

            -- Bug 3677988: inserts in acceptances form should not be allowed for PO on hold
            -- This is facilitated by checking for user_hold_flag <> 'Y'.

            SELECT NVL(pending_signature_flag,'N')
              INTO x_pending_signature
              FROM PO_HEADERS_ALL
             WHERE po_header_id = p_po_header_id
               AND nvl(user_hold_flag, 'N') <> 'Y';

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_pending_signature := 'N';
        END;

        BEGIN
            -- SQL What: Selects Y if there are any electronically signed
            --           signature records for the current revision number
            -- SQL Why : To determine if we should allow manual signatures
            --           in the Acceptances form
            -- SQL Join: PO_HEADER_ID, REVISION_NUM, SIGNATURE_FLAG, ERECORD_ID

            SELECT 'Y'
              INTO x_erecord_exist
              FROM dual
             WHERE EXISTS (SELECT 1
                             FROM PO_ACCEPTANCES
                            WHERE po_header_id = p_po_header_id
                              AND revision_num = p_revision_num
                              AND signature_flag = 'Y'
                              AND erecord_id IS NOT NULL);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_erecord_exist := 'N';
        END;
    ELSE
        x_pending_signature := 'N';
        x_erecord_exist := 'N';
    END IF;

END DOES_ERECORD_EXIST;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Post_Forms_Commit
--Pre-reqs:
--  None.
--Modifies:
--  PO_HEADERS_ALL, PO_LINE_LOCATIONS_ALL, PO_ACTION_HISTORY
--Locks:
--  None.
--Function:
--  Checks the logic for completion of signatures and updates PO tables
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--OUT:
--x_result
--  Returns 'E' - for Errors
--  Returns 'A' - If the document is Approved
--  Returns 'R' - If the document is Rejected
--x_error_msg
--  Returns the Error Message Code
--x_msg_data
--  Returns Error Message Data for Contract Terms
--Testing:
--  Testing to be done based on the test cases in Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Post_Forms_Commit( p_po_header_id           IN  NUMBER,
                             p_revision_num           IN  NUMBER,
                             x_result                 OUT NOCOPY VARCHAR2,
                             x_error_msg              OUT NOCOPY VARCHAR2,
                             x_msg_data               OUT NOCOPY VARCHAR2)
IS
  l_buyer_accepted_count    PLS_INTEGER := 0;
  l_buyer_rejected_count    PLS_INTEGER := 0;
  l_supplier_accepted_count PLS_INTEGER := 0;
  l_supplier_rejected_count PLS_INTEGER := 0;
  l_type_lookup_code        PO_HEADERS_ALL.type_lookup_code%TYPE;
  l_agent_id                PO_HEADERS_ALL.agent_id%TYPE;
  l_object_code             PO_ACTION_HISTORY.object_type_code%TYPE := NULL;
  l_po_itemkey              WF_ITEMS.item_key%TYPE;
  l_po_itemtype             WF_ITEMS.item_type%TYPE;
  l_itemkey                 WF_ITEMS.item_key%TYPE;
  l_result                  VARCHAR2(1);

--<CONTERMS FPJ START>
   l_acceptance_date        DATE;
   l_return_status          VARCHAR2(1);
   l_msg_data               VARCHAR2(2000);
   l_msg_count              NUMBER;
--<CONTERMS FPJ END>

   l_employee_id            FND_USER.employee_id%TYPE;  -- bug3738420

   l_binding_exception     EXCEPTION;
BEGIN
    BEGIN
      -- SQL What :selects the count of number of times Buer Accepted, Buyer Rejected,
      --           Supplier Accepted, Supplier Rejected the document
      -- SQL Why  :To identify if the Signatures are completely captured or not and
      --           to set the PO status from PRE-APPROVED to APPROVED Or REJECTED
      -- SQL Join :PO_HEADER_ID, REVISION_NUM, SIGNATURE_FLAG

      SELECT SUM(Decode(Accepting_Party,'B',Decode(Accepted_Flag,'Y',1,0))) Buyer_Accepted,
             SUM(Decode(Accepting_Party,'B',Decode(Accepted_Flag,'Y',0,1))) Buyer_Rejected,
             SUM(Decode(Accepting_Party,'S',Decode(Accepted_Flag,'Y',1,0))) Supplier_Accepted,
             SUM(Decode(Accepting_Party,'S',Decode(Accepted_Flag,'Y',0,1))) Supplier_Rejected
        INTO l_buyer_accepted_count,
             l_buyer_rejected_count,
             l_supplier_accepted_count,
             l_supplier_rejected_count
        FROM PO_ACCEPTANCES
       WHERE Po_Header_Id = p_po_header_id
         AND Revision_Num = p_revision_num
         AND Signature_Flag = 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           Null;
    END;

    BEGIN
      -- SQL What :selects the type_lookup_code and agent_id from PO_HEADERS_ALL
      -- SQL Why  :To pass it po_action_history row handler for inserting a row
      -- SQL Join :PO_HEADER_ID

      -- bug 3568077
      -- PO_ACTION_HISTORY.object_type_code is:
      --   PA for Contracts and BPAs
      --   PO for Standard/Planned POs

      SELECT
         Type_Lookup_Code
      ,  DECODE(  type_lookup_code
               ,  PO_CONSTANTS_SV.BLANKET, PO_CONSTANTS_SV.PA
               ,  PO_CONSTANTS_SV.CONTRACT, PO_CONSTANTS_SV.PA
               ,  PO_CONSTANTS_SV.PO
               )
      ,  Agent_Id,
             wf_item_type,
             wf_item_key
        INTO l_type_lookup_code,
             l_object_code,
             l_agent_id,
             l_po_itemtype,
             l_po_itemkey
        FROM PO_HEADERS_ALL
       WHERE Po_Header_Id = p_po_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           RAISE l_binding_exception;
    END;

    l_employee_id := FND_GLOBAL.employee_id;  -- bug3738420

    -- If either Supplier or Buyer rejected the document then the PO status
    -- should be set to REJECTED from PRE-APPROVED

    IF ((nvl(l_supplier_rejected_count,0) > 0) OR
        (nvl(l_buyer_rejected_count,0) > 0)) THEN

        -- bug3738420
        -- pass in current emp id instead of agent id of the document

        update_po_details(
                  p_po_header_id        => p_po_header_id,
                  p_status              => 'REJECTED',
                  p_action_code         => 'BUYER REJECTED',
                  p_object_type_code    => l_object_code,
                  p_object_subtype_code => l_type_lookup_code,
                  p_employee_id         => l_employee_id,    -- bug3738420
                  p_revision_num        => p_revision_num);

        -- Abort Document Signature process if active
        find_item_key(
                  p_po_header_id  => p_po_header_id,
                  p_revision_num  => p_revision_num,
                  p_document_type => l_object_code,
                  x_itemkey       => l_itemkey,
                  x_result        => l_result);

        IF l_result = 'S' AND
           l_itemkey IS NOT NULL THEN

            abort_doc_sign_process(p_itemkey => l_itemkey,
                                   x_result  => l_result);
        ELSIF l_result = 'E' THEN
            x_error_msg := 'PO_MANY_SIGN_PROCESSES';
            RAISE l_binding_exception;
        END IF;

        -- Complete the Block Activity in the PO Approval Process so that
        -- rest of the process is continued
        IF l_po_itemtype = 'POAPPRV' THEN
            Complete_Block_Activities(p_itemkey => l_po_itemkey,
                                      p_status  => 'N' ,
                                      x_result  => l_result);
        END IF;

        x_result := 'R';

    -- If there is no signature entry in the Acceptances table for either the
    -- buyer or supplier, an error message should be displayed indicating that
    -- all the required signatures are not captured
    ELSIF (nvl(l_buyer_accepted_count,0) = 0 AND
           nvl(l_buyer_rejected_count,0) = 0 AND
           nvl(l_supplier_accepted_count,0) = 0 AND
           nvl(l_supplier_rejected_count,0) = 0) THEN

         x_error_msg := 'PO_INCOMPLETE_SIGNATURES';
         RAISE l_binding_exception;

    -- If both the Supplier and Buyer accepted the document then the PO status
    -- should be set to ACCEPTED from PRE-APPROVED
    ELSIF (nvl(l_buyer_accepted_count,0) > 0) OR
          (nvl(l_supplier_accepted_count,0) > 0) THEN

        -- bug3738420
        -- pass in current emp id instead of agent id of the document
        update_po_details(
                  p_po_header_id        => p_po_header_id,
                  p_status              => 'APPROVED',
                  p_action_code         => 'SIGNED',
                  p_object_type_code    => l_object_code,
                  p_object_subtype_code => l_type_lookup_code,
                  p_employee_id         => l_employee_id,   -- bug3738420
                  p_revision_num        => p_revision_num);

        --<CONTERMS FPJ START>
        -- Now that the PO status is being Changed to approved, notify Contracts
        --Deliverables about the signing event so that deliverables can be
        -- activated for current revision

         -- SQL What :selects the latest date for ACCEPTED ACTION for the current revision
         -- SQL Why  :To inform contract deliverables for the signed date
         -- SQL Join :NONE

          SELECT max(action_date)
          INTO l_acceptance_date
          FROM PO_ACCEPTANCES
          WHERE Po_Header_Id = p_po_header_id
            AND Revision_Num = p_revision_num
            AND Signature_Flag = 'Y'
            AND ACCEPTING_PARTY IN ('B','S')
            AND ACCEPTED_FLAG= 'Y';

      --The control should come here only if po status was successfully
      -- changed to Approved in Update_PO_Details
      -- Inform Contracts to activate deliverable, now that PO is successfully
      -- Changed status to approved
      PO_CONTERMS_WF_PVT.UPDATE_CONTRACT_TERMS(
                p_po_header_id      => p_po_header_id,
                p_signed_date       => l_acceptance_date,
    		    x_return_status     => l_return_status,
                x_msg_data          => l_msg_data,
                x_msg_count         => l_msg_count);
      IF l_return_status <> 'S' then
         x_msg_data := l_msg_data;
         RAISE l_binding_exception;
      END IF; -- Return status from contracts

       --<CONTERMS FPJ END>

        -- Abort Document Signature process if active
        find_item_key(
                  p_po_header_id  => p_po_header_id,
                  p_revision_num  => p_revision_num,
                  p_document_type => l_object_code,
                  x_itemkey       => l_itemkey,
                  x_result        => l_result);

        IF l_result = 'S' AND
           l_itemkey IS NOT NULL THEN

            abort_doc_sign_process(p_itemkey => l_itemkey,
                                   x_result  => l_result);
        ELSIF l_result = 'E' THEN
            x_error_msg := 'PO_MANY_SIGN_PROCESSES';
            RAISE l_binding_exception;
        END IF;

        -- Complete the Block Activity in the PO Approval Process so that
        -- rest of the process is continued
        IF l_po_itemtype = 'POAPPRV' THEN
            Complete_Block_Activities(p_itemkey => l_po_itemkey,
                                      p_status  => 'Y' ,
                                      x_result  => l_result);
        END IF;

        x_result := 'A';
    END IF;

EXCEPTION
    WHEN l_binding_exception THEN
        x_result := 'E';
    WHEN OTHERS THEN
        x_result := 'E';
END POST_FORMS_COMMIT;


-------------------------------------------------------------------------------
--Start of Comments
--Name: Check_For_Multiple_Entries
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Checks if there are more than one signature records exist in the
--  PO_ACCEPTANCES table.
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--OUT:
--x_result
--  Returns 'E' - for Errors
--x_error_msg
--  Returns the Error Message Code
--Testing:
--  Testing to be done based on the test cases in Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Check_For_Multiple_Entries(p_po_header_id        IN  NUMBER,
                                     p_revision_num        IN  NUMBER,
                                     x_result              OUT NOCOPY VARCHAR2,
                                     x_error_msg           OUT NOCOPY VARCHAR2)
IS
   l_no_signatures           NUMBER := 0;
   l_binding_exception       EXCEPTION;
BEGIN

    BEGIN
        -- SQL What :selects the number of signature entries for the document revision
        -- SQL Why  : To show an error if there are more than one entry for
        --            signatures for manual signatures entry
        -- SQL Join :PO_HEADER_ID, REVISION_NUM, SIGNATURE_FLAG, ERECORD_ID

        SELECT Count(Signature_Flag)
          INTO l_no_signatures
          FROM PO_ACCEPTANCES
         WHERE po_header_id = p_po_header_id
           AND revision_num = p_revision_num
           AND signature_flag = 'Y'
           AND accepting_party = 'B' --bug 3420562
           AND erecord_id IS NULL;

        IF nvl(l_no_signatures,0) > 1 THEN
           x_error_msg := 'PO_MULTIPLE_SIGNATURES';
           RAISE l_binding_exception;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_result := 'S';
    END;

    BEGIN
        l_no_signatures := 0;

        -- SQL What : Selects the number of eloctronically signed signature
        --            entries for the document revision
        -- SQL Why  : To make sure that if Supplier Signed electronically then
        --            Buyer should also sign electonically
        -- SQL Join :PO_HEADER_ID, REVISION_NUM, SIGNATURE_FLAG, ERECORD_ID

        SELECT Count(Signature_Flag)
          INTO l_no_signatures
          FROM PO_ACCEPTANCES
         WHERE po_header_id = p_po_header_id
           AND revision_num = p_revision_num
           AND signature_flag = 'Y'
           AND erecord_id IS NOT NULL;

        IF nvl(l_no_signatures,0) = 1 THEN
           x_error_msg := 'PO_INCOMPLETE_ESIGNATURE';
           RAISE l_binding_exception;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_result := 'S';
    END;

EXCEPTION
    WHEN l_binding_exception THEN
        x_result := 'E';
    WHEN OTHERS THEN
        x_result := 'E';
END CHECK_FOR_MULTIPLE_ENTRIES;


-- <BUG 3751927 START>

-- get_rejection_type:
-- Gets rejection type of document that requires signatures
-- Inputs:
-- p_po_header_id: document must be a PO or PA
-- p_revision_num: document revision num
-- Returns:
-- Supplier rejected (implies no buyer activity)
-- x_buyer_rejected = NULL, x_supplier_rejeced = 'Y'
-- Supplier accepts, but buyer rejects
-- x_buyer_rejected = 'Y', x_supplier_rejected = 'N'
-- Buyer rejected (before any supplier activity):
-- x_buyer_rejected = 'Y', x_supplier_rejeced = NULL
-- Otherwise: both variables return NULL

PROCEDURE get_rejection_type (  p_po_header_id      IN   NUMBER
                              , p_revision_num      IN   NUMBER
                              , x_buyer_rejected    OUT NOCOPY VARCHAR2
                              , x_supplier_rejected OUT NOCOPY VARCHAR2
                            )
IS

BEGIN

  x_buyer_rejected := NULL;
  x_supplier_rejected := NULL;

  BEGIN
    SELECT DECODE(accepted_flag, 'N', 'Y', 'N')
    INTO x_supplier_rejected
    FROM po_acceptances
    WHERE po_header_id = p_po_header_id
      AND revision_num = p_revision_num
      AND accepting_party = 'S'
      AND signature_flag = 'Y';
  EXCEPTION
    WHEN others THEN
      x_supplier_rejected := NULL;
  END;

  -- if supplier rejects
  -- then document is rejected before buyer can reject it?
  IF (NVL(x_supplier_rejected, 'X') = 'Y')
  THEN
    return;
  END IF;

  BEGIN
    SELECT 'Y'
    INTO x_buyer_rejected
    FROM po_acceptances
    WHERE po_header_id = p_po_header_id
      AND revision_num = p_revision_num
      AND accepting_party = 'B'
      AND accepted_flag = 'N'
      AND signature_flag= 'Y';
  EXCEPTION
    WHEN others THEN
      x_buyer_rejected := NULL;
  END;


EXCEPTION

  WHEN others THEN
    x_buyer_rejected := NULL;
    x_supplier_rejected := NULL;
    return;

END get_rejection_type;
  -- <BUG 3751927 END>

--<Bug#5013783 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: if_was_sign_reqd_set_acc_flag
--Pre-reqs:
--  This code should be called when we have already revised the document and
--  updated the revision_num and revised_date field.
--Modifies:
--  PO_HEADERS_ALL
--Locks:
--  None.
--Function:
--  This function checks if there is atleast one signed revision
--  from the supplier and updates the Aceptance_required_field
--  to 'S'
--Parameters:
--IN:
--p_document_id
--  NUMBER - po header id
--OUT:
--x_if_acc_flag_updated
--  VARCHAR2 - indicates if the Acceptance Reqd Flag was updated
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE if_was_sign_reqd_set_acc_flag(p_document_id IN NUMBER,
                                        x_if_acc_flag_updated  OUT NOCOPY VARCHAR2)
IS
  l_was_sign_reqd boolean := FALSE;
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_SIGNATURE_PVT.if_was_sign_reqd_set_acc_flag';
  d_pos NUMBER := 0;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module,'p_document_id',p_document_id);
  END IF;
  x_if_acc_flag_updated := 'N';
  l_was_sign_reqd := was_signature_required(p_document_id);
  d_pos := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_was_sign_reqd',l_was_sign_reqd);
  END IF;

  IF l_was_sign_reqd THEN
    UPDATE PO_HEADERS_ALL POH
    SET POH.acceptance_required_flag = 'S'
    WHERE POH.po_header_id = p_document_id;
    x_if_acc_flag_updated := 'Y';
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
    PO_LOG.proc_end(d_module, 'x_if_acc_flag_updated', x_if_acc_flag_updated);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END if_was_sign_reqd_set_acc_flag;
--<Bug#5013783 End>

-- Bug 5216351
-------------------------------------------------------------------------------
--Start of Comments
--Name: if_rev_and_signed_set_acc_flag
--Pre-reqs:
--  None.
--Modifies:
--  PO_HEADERS_ALL
--Locks:
--  None.
--Function:
--  Updates the acceptance_required_field to 'S' if the revision number in the
--  database has changed and at least one of the previous revisions was signed.
--Parameters:
--IN:
--p_document_id
--  po header id
--p_old_revision_num
--  the original revision number of the document, before the draft-to-transaction
--  transfer program was called
--OUT:
--x_if_acc_flag_updated
--  indicates if the Acceptance Reqd Flag was updated
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE if_rev_and_signed_set_acc_flag (
            p_document_id         IN NUMBER,
            p_old_revision_num    IN NUMBER,
            x_if_acc_flag_updated OUT NOCOPY VARCHAR2)
IS
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_SIGNATURE_PVT.if_rev_and_signed_set_acc_flag';
  d_pos NUMBER := 0;
  l_revision_num PO_HEADERS_ALL.revision_num%TYPE;
BEGIN
  SELECT revision_num
  INTO l_revision_num
  FROM po_headers_all
  WHERE po_header_id = p_document_id;

  d_pos := 10;

  IF (NVL(l_revision_num,0) <> NVL(p_old_revision_num,0)) THEN
    if_was_sign_reqd_set_acc_flag(
      p_document_id => p_document_id,
      x_if_acc_flag_updated => x_if_acc_flag_updated);
  ELSE
    x_if_acc_flag_updated := 'N';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END if_rev_and_signed_set_acc_flag;

END PO_SIGNATURE_PVT;

/
