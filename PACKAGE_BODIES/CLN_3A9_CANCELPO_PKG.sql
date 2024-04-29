--------------------------------------------------------
--  DDL for Package Body CLN_3A9_CANCELPO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_3A9_CANCELPO_PKG" AS
/* $Header: CLN3A9PB.pls 115.6 2003/06/27 16:16:00 kkram noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

/*
-- Name
--    RAISE_CANCEL_PO_EVENT
-- Purpose
--    Raise oracle.apps.cln.po.cancelpo event
-- Arguments
--    PO Header ID
--    PO Header Type
--    PO Header Sub Type
-- Notes
--    No specific notes


PROCEDURE RAISE_CANCEL_PO_EVENT(
   p_document_id   IN VARCHAR2,
   p_hdr_type      IN VARCHAR2,
   p_hdr_sub_type  IN VARCHAR2)
IS
   l_cln_not_parameters wf_parameter_list_t;
   l_authorization_status VARCHAR2(50);
   l_cln_event_key NUMBER;
   l_error_code    NUMBER;
   l_debug_mode    VARCHAR2(255);
   l_error_msg     VARCHAR2(1000);
   l_not_msg       VARCHAR2(1000);
BEGIN
   -- Sets the debug mode to FILE
   --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

   cln_debug_pub.Add('CLN_3A9_CANCELPO_PKG.RAISE_CLN_EVENT CALLED', 2);

   -- Raise event if it is a Standard PO or Release, else return
   -- If the PO/Release is not approved then return
   l_cln_not_parameters := wf_parameter_list_t();
   IF (p_hdr_type = 'PO' AND p_hdr_sub_type = 'STANDARD') THEN -- Standard PO
      SELECT authorization_status
      INTO   l_authorization_status
      FROM   po_headers_all
      WHERE  po_header_id = p_document_id;
      IF l_authorization_status <> 'APPROVED' THEN
         RETURN;
      END IF;
      WF_EVENT.AddParameterToList('POHEADERID', p_document_id, l_cln_not_parameters);
      WF_EVENT.AddParameterToList('PORELEASEID', -1, l_cln_not_parameters);
   ELSIF (p_hdr_type = 'RELEASE' AND (p_hdr_sub_type = 'BLANKET'
                             OR p_hdr_sub_type = 'SCHEDULED')) THEN -- Release
      SELECT authorization_status
      INTO   l_authorization_status
      FROM   po_releases_all
      WHERE  po_release_id = p_document_id;
      IF l_authorization_status <> 'APPROVED' THEN
         RETURN;
      END IF;
      WF_EVENT.AddParameterToList('POHEADERID', -1, l_cln_not_parameters);
      WF_EVENT.AddParameterToList('PORELEASEID', p_document_id, l_cln_not_parameters);
   ELSE
      RETURN;
   END IF;

   SELECT cln_generic_s.nextval INTO l_cln_event_key FROM dual;

   -- Set Event Name, Event Key and Event Message Parameters.
   WF_EVENT.AddParameterToList('oracle.apps.cln.po.cancelpo', 'EVENT_NAME', l_cln_not_parameters);
   WF_EVENT.AddParameterToList(l_cln_event_key, 'EVNT_KEY', l_cln_not_parameters);
   WF_EVENT.AddParameterToList('Cancel PO', 'ECX_EVENT_MESSAGE', l_cln_not_parameters);

   -- Raise Cancel PO event
   WF_EVENT.Raise('oracle.apps.cln.po.cancelpo', 'clncpo-' || l_cln_event_key, NULL, l_cln_not_parameters, NULL);

   cln_debug_pub.Add('CLN_3A9_CANCELPO_PKG.RAISE_CLN_EVENT EXITED', 2);
EXCEPTION
   WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_msg  := SQLERRM;
      insert into cln_test(test) values('Exception ' || ':'  || l_error_code || ':' || l_error_msg);
      FND_MESSAGE.SET_NAME('CLN','CLN_3A9_EVENT_RAISE_ERROR');
      FND_MESSAGE.SET_TOKEN('POHEADERID', p_document_id);
      FND_MESSAGE.SET_TOKEN('DBERRMSG', l_error_code || ':' || l_error_msg);
      l_not_msg := FND_MESSAGE.GET;
      cln_debug_pub.Add(l_not_msg, 6);
      CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_not_msg);
      cln_debug_pub.Add('RAISE_CLN_EVENT EXITED', 2);
END RAISE_CANCEL_PO_EVENT;
*/



-- Name
--    SETATTRIBUTES
-- Purpose
--    Based on the parameters passed, query PO base tables and populate item attribute values
-- Arguments
--    PO Header ID available as Item Attribute
-- Notes
--    No specific notes


PROCEDURE SETATTRIBUTES(
  p_itemtype        IN VARCHAR2,
  p_itemkey         IN VARCHAR2,
  p_actid           IN NUMBER,
  p_funcmode        IN VARCHAR2,
  x_resultout       IN OUT NOCOPY VARCHAR2)
IS
  l_po_number        VARCHAR2(20);
  l_rel_number       NUMBER;
  l_rev_number       NUMBER;
  l_supp_ord_number  VARCHAR2(25);
  l_party_id         VARCHAR2(30);
  l_party_site_id    VARCHAR2(40);
  l_po_header_id     NUMBER;
  l_po_release_id    NUMBER;
  l_xmlg_doc_id      NUMBER;
  l_cln_event_key    NUMBER;
  l_debug_mode       VARCHAR2(255);
  l_error_code       NUMBER;
  l_error_msg        VARCHAR2(1000);
  l_not_msg          VARCHAR2(1000);
BEGIN
   -- Sets the debug mode to FILE
   --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

   IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('CLN_3A9_CANCELPO_PKG.SETATTRIBUTES CALLED', 2);
   END IF;

   l_po_header_id := TO_NUMBER(wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'POHEADERID'));
   l_po_release_id := TO_NUMBER(wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'PORELEASEID'));

   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('l_po_header_id:' || l_po_header_id, 1);
           cln_debug_pub.Add('l_po_release_id:' || l_po_release_id, 1);
   END IF;

   -- Query PO base tables/views to get PO Number, release number, revision number,
   -- and Sales Order Number based on PO Header ID or Po Release ID
   IF l_po_release_id = -1 THEN
      SELECT poh.segment1, por.release_num, poh.revision_num, poh.vendor_order_num
      INTO   l_po_number, l_rel_number, l_rev_number, l_supp_ord_number
      FROM   po_headers_all poh, po_releases_all por
      WHERE  poh.po_header_id = l_po_header_id
         AND poh.po_header_id = por.po_header_id(+);
   ELSE
      SELECT poh.po_header_id, poh.segment1, por.release_num, por.revision_num, poh.vendor_order_num
      INTO   l_po_header_id, l_po_number, l_rel_number, l_rev_number, l_supp_ord_number
      FROM   po_headers_all poh, po_releases_all por
      WHERE  por.po_release_id = l_po_release_id
         AND poh.po_header_id = por.po_header_id(+);
      wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'POHEADERID', l_po_header_id);
   END IF;

   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('l_po_header_id:' || l_po_header_id, 1);
           cln_debug_pub.Add('l_po_release_id:' || l_po_release_id, 1);
           cln_debug_pub.Add('l_po_number:' || l_po_number, 1);
           cln_debug_pub.Add('l_rel_number:' || l_rel_number, 1);
           cln_debug_pub.Add('l_rev_number:' || l_rev_number, 1);
           cln_debug_pub.Add('l_supp_ord_number:' || l_supp_ord_number, 1);
   END IF;

   /* -- This is not required since it is taken care in XMG query
   -- Upon PO cancellation, PO revision number is incremented by 1 in the PO Header table
   -- but not in the PO Header Archive table
   -- which is used in the XML Gateway Map to generate the Cancel PO XML document
   IF l_po_rev_number > 0 THEN
      l_po_rev_number := l_po_rev_number - 1;
   END IF;
   */


   -- Set the PO details
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PONUMBER', l_po_number);
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PORELEASENO', l_rel_number);
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'POREVISIONNUMBER', l_rev_number);
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'SUPPLIERORDERNUM', l_supp_ord_number);

   -- Query PO base tables/views to get Party ID and Party Site ID
   -- based on PO Header ID
   SELECT VENDOR_ID, VENDOR_SITE_ID
   INTO   l_party_id, l_party_site_id
   FROM   PO_HEADERS_ALL
   WHERE  PO_HEADER_ID = l_po_header_id;

   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('l_party_id:' || l_party_id, 1);
           cln_debug_pub.Add('l_party_site_id:' || l_party_site_id, 1);
   END IF;

   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTYID', l_party_id);
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARTYSIDEID', l_party_site_id);

   -- Set the event key
   SELECT cln_generic_s.nextval INTO l_cln_event_key FROM dual;
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'CLNEVENTKEY', l_cln_event_key);

   -- Set the XML Gateway Document ID
   SELECT cln_generic_s.nextval INTO l_xmlg_doc_id FROM dual;
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'XMLGDOCUMENTID', l_xmlg_doc_id);

   -- Set Transaction Type and Subtype
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'TRANSACTIONTYPE', 'CLN');
   wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'TRANSACTIONSUBTYPE', 'CANCELPO');

   x_resultout:='Yes';
   IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('CLN_3A9_CANCELPO_PKG.SETATTRIBUTES EXITED', 2);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_msg  := SQLERRM;
      FND_MESSAGE.SET_NAME('CLN','CLN_3A9_PO_QUERY_ERROR');
      FND_MESSAGE.SET_TOKEN('POHEADERID', l_po_header_id);
      FND_MESSAGE.SET_TOKEN('DBERRMSG', l_error_code || ':' || l_error_msg);
      l_not_msg := FND_MESSAGE.GET;
      IF (l_Debug_Level <= 6) THEN
              cln_debug_pub.Add(l_not_msg, 6);
      END IF;
      CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_not_msg);
END SETATTRIBUTES;


-- Name
--    IS_XML_CHOSEN
-- Purpose
--    Checks if XML transaction is set/enabled for this PO
-- Arguments
--    PO Header ID available as Item Attribute
--    PO Type available as Item Attribute
-- Notes
--    No specific notes

PROCEDURE IS_XML_CHOSEN(
   p_itemtype        IN VARCHAR2,
   p_itemkey         IN VARCHAR2,
   p_actid           IN NUMBER,
   p_funcmode        IN VARCHAR2,
   x_resultout       OUT NOCOPY VARCHAR2)
IS
  l_po_header_id   NUMBER;
  l_po_release_id  NUMBER;
  l_xml_flag       VARCHAR2(1);
  l_error_code     NUMBER;
  l_error_msg      VARCHAR2(1000);
  l_not_msg        VARCHAR2(1000);
BEGIN
   IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('CLN_3A9_CANCELPO_PKG.IS_XML_CHOSEN CALLED', 2);
   END IF;

   x_resultout := 'COMPLETE:F';

   l_po_header_id := TO_NUMBER(wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'POHEADERID'));
   l_po_release_id := TO_NUMBER(wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'PORELEASEID'));

   -- Query for XML flag based on PO Header ID or PO Release ID
   IF l_po_release_id = -1 THEN
      SELECT poh.xml_flag
      INTO   l_xml_flag
      FROM po_headers_all poh
      WHERE po_header_id= l_po_header_id;
   ELSE
       SELECT por.xml_flag
       INTO   l_xml_flag
       FROM   po_headers_all poh, po_releases_all por
       WHERE  poh.po_header_id = por.po_header_id
          AND por.po_release_id  = l_po_release_id;
   END IF;

   IF l_xml_flag = 'Y' THEN
      x_resultout := 'COMPLETE:T';
   END IF;

   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('l_xml_flag:' || l_xml_flag, 1);
   END IF;
   IF (l_Debug_Level <= 2) THEN
           cln_debug_pub.Add('CLN_3A9_CANCELPO_PKG.IS_XML_CHOSEN EXITED', 2);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_resultout := 'COMPLETE:F';
      l_error_code := SQLCODE;
      l_error_msg  := SQLERRM;
      FND_MESSAGE.SET_NAME('CLN','CLN_3A9_PO_QUERY_ERROR');
      FND_MESSAGE.SET_TOKEN('POHEADERID', l_po_header_id);
      FND_MESSAGE.SET_TOKEN('DBERRMSG', l_error_code || ':' || l_error_msg);
      l_not_msg := FND_MESSAGE.GET;
      IF (l_Debug_Level <= 6) THEN
              cln_debug_pub.Add(l_not_msg, 6);
      END IF;
      CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_not_msg);
   NULL;
END IS_XML_CHOSEN;


END CLN_3A9_CANCELPO_PKG;

/
