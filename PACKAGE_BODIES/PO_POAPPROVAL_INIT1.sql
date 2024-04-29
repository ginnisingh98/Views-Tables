--------------------------------------------------------
--  DDL for Package Body PO_POAPPROVAL_INIT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POAPPROVAL_INIT1" AS
/* $Header: POXWPA2B.pls 120.7.12010000.20 2014/07/01 06:43:05 shindeng ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on; --< Bug 3554754 >

g_pkg_name           CONSTANT VARCHAR2(30) := 'PO_POAPPROVAL_INIT1';
g_module_prefix      CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

 /*=======================================================================+
 | FILENAME
 |   POXWPA2B.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_POAPPROVAL_INIT1
 |
 | NOTES        Ben Chihaoui Created 6/15/97
 | MODIFIED    (MM/DD/YY)
 | Eric Ma      04/13/2009    Add code for PO notification of Indian Localization
 | Eric Ma      07/31/2009    Remove code addition  of bug 8291565 for bug 8743852
 *=======================================================================*/
--

Cursor GetPOHdr_csr(p_po_header_id NUMBER) RETURN POHdrRecord is
  select PO_HEADER_ID,COMMENTS,AUTHORIZATION_STATUS,
         TYPE_LOOKUP_CODE,AGENT_ID,SEGMENT1,CLOSED_CODE,CURRENCY_CODE
  from po_headers_all
  where PO_HEADER_ID = p_po_header_id;

Cursor GetRelHdr_csr(p_rel_header_id NUMBER) RETURN RelHdrRecord is
  select PORL.PO_RELEASE_ID,PORL.PO_HEADER_ID,PORL.AUTHORIZATION_STATUS,
         PORL.RELEASE_TYPE,PORL.AGENT_ID,PORL.RELEASE_NUM,PORL.CLOSED_CODE,
         POH.SEGMENT1, POH.CURRENCY_CODE, POH.COMMENTS
         -- Bug 10140786 Selected comments to set PO_DESCRIPTION in release workflow.
  from po_releases_all PORL, po_headers_all POH
  where  PORL.PO_RELEASE_ID = p_rel_header_id
  and    PORL.po_header_id  = POH.po_header_id;

-- The following are local/Private procedure that support the workflow APIs:

procedure getPOAttributes(p_po_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2);
--
procedure SetPOHdrAttributes(itemtype in varchar2, itemkey in varchar2);

--
procedure getRelAttributes(p_rel_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2);
--
procedure SetRelHdrAttributes(itemtype in varchar2, itemkey in varchar2);

--
-- Get_PO_Attributes
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure Get_PO_Attributes(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_orgid        NUMBER;
l_po_header_id NUMBER;
l_doc_type     VARCHAR2(25);
l_authorization_status VARCHAR2(25);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_po_revision_num_curr NUMBER;
l_po_revision_num_orig NUMBER;

BEGIN

  x_progress := 'PO_POAPPROVAL_INIT1.Get_PO_Attributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2353153
  ** Setting application context
  */

  -- Context Setting Revamp
  /* PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey); */


  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_po_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  IF l_doc_type IN ('PO','PA') THEN


     GetPOAttributes(l_po_header_id,itemtype,itemkey);

  ELSE

     GetRelAttributes(l_po_header_id,itemtype,itemkey);

  END IF;

  -- code added for bug 8291565
  -- for blocking FYI notification to web supplier users when there is no change in the revision number of the PO

  l_po_revision_num_curr := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'REVISION_NUMBER');

  IF l_doc_type IN ('PO', 'PA') THEN

  	SELECT (Nvl (comm_rev_num, -1))
	INTO l_po_revision_num_orig
	FROM po_headers_all
	WHERE po_header_id = l_po_header_id;

  -- added for bug 9072034 (to check revision number for releases.)
  ELSIF l_doc_type in ('RELEASE') THEN

  	SELECT (Nvl (comm_rev_num, -1))
	INTO l_po_revision_num_orig
	FROM po_releases_all
	WHERE po_release_id = l_po_header_id;

  END IF;

  --Bug 10627841 Using  PO_WF_UTIL_PKG instead of wf_engine to set attributes.
  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey => itemkey,
                            aname => 'OLD_PO_REVISION_NUM',
                            AVALUE => l_po_revision_num_orig);

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                            itemkey => itemkey,
                            aname => 'NEW_PO_REVISION_NUM',
                            AVALUE => l_po_revision_num_curr);

  IF (l_po_revision_num_orig >= 0 ) THEN

    IF l_po_revision_num_curr = l_po_revision_num_orig THEN

      PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'HAS_REVISION_NUM_INCREMENTED',
                                avalue => 'N');

    ELSE

      PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'HAS_REVISION_NUM_INCREMENTED',
                                avalue => 'Y');

    END IF;

  ELSE

      PO_WF_UTIL_PKG.SetItemAttrText(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'HAS_REVISION_NUM_INCREMENTED',
                                avalue => 'Y');

  END IF;

  -- end of code added for bug 8291565

     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --
  x_progress :=  'PO_POAPPROVAL_INIT1.Get_PO_Attributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_POAPPROVAL_INIT1','Get_PO_Attributes',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_POAPPROVAL_INIT1.GET_PO_ATTRIBUTES');
    raise;

END Get_PO_Attributes;


--
-- Is_this_new_doc
--  Is this a new document or is this a change order.
--
procedure Is_this_new_doc(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_doc_status varchar2(25);
l_approved_date DATE;
l_doc_id     NUMBER;
l_doc_type   VARCHAR2(25);
l_orgid        NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_is_new_document VARCHAR2(1); -- <SVC_NOTIFICATIONS FPJ>
l_proc_name VARCHAR2(30) := 'is_this_new_doc';
l_return_status VARCHAR2(1);    --< Bug 3554754 >

BEGIN

  x_progress := 'PO_POAPPROVAL_INIT1.Is_this_new_doc: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;


  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  --< Bug 3554754 Start >
  get_approved_date( p_doc_type      => l_doc_type
                   , p_doc_id        => l_doc_id
                   , x_return_status => l_return_status
                   , x_approved_date => l_approved_date
                   );
  IF (l_return_status <> FND_API.g_ret_sts_success) THEN
      RAISE FND_API.g_exc_unexpected_error;
  END IF;
  --< Bug 3554754 End >

  /* If the doc does not have an approved date, then it's new */
  IF l_approved_date IS NULL THEN
     l_is_new_document := 'Y'; -- <SVC_NOTIFICATIONS FPJ>
  ELSE
     l_is_new_document := 'N'; -- <SVC_NOTIFICATIONS FPJ>
  END IF;

  -- <SVC_NOTIFICATIONS FPJ START>
  po_wf_util_pkg.SetItemAttrText ( itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'IS_NEW_DOCUMENT',
                                   avalue => l_is_new_document );

  resultout := wf_engine.eng_completed || ':' || l_is_new_document;
  -- <SVC_NOTIFICATIONS FPJ END>

  x_progress := 'PO_POAPPROVAL_INIT1.Is_this_new_doc: 02: ' || l_is_new_document;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_POAPPROVAL_INIT1','Is_this_new_doc',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_POAPPROVAL_INIT1.IS_THIS_NEW_DOC');
    raise;

END Is_this_new_doc;

-- Is_Acceptance_Required
--   Is Acceptance required on this Document
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--

procedure Is_Acceptance_Required(      itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is


l_orgid        NUMBER;
l_po_header_id NUMBER;
l_doc_type     VARCHAR2(25);
l_acceptance_required VARCHAR2(1);
l_acceptance_due_date DATE;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_POAPPROVAL_INIT1.Is_Acceptance_Required: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;


  l_po_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  IF l_doc_type IN ('PO','PA') THEN

     select acceptance_required_flag,acceptance_due_date
         into l_acceptance_required, l_acceptance_due_date
     from po_headers
     where po_header_id= l_po_header_id;

  ELSIF l_doc_type='RELEASE' THEN

     select acceptance_required_flag,acceptance_due_date
         into l_acceptance_required, l_acceptance_due_date
     from po_releases
     where po_release_id= l_po_header_id;

  END IF;

  IF NVL(l_acceptance_required,'N') = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'Y';

  ELSE

    resultout := wf_engine.eng_completed || ':' ||  'N';

  END IF;

  x_progress := 'PO_POAPPROVAL_INIT1.Is_Acceptance_Required: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_POAPPROVAL_INIT1','Is_Acceptance_Required',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_POAPPROVAL_INIT1.IS_ACCEPTANCE_REQUIRED');
    raise;

END Is_Acceptance_Required;

/****************************************************************************
* The Following are the supporting APIs to the workflow functions.
* These API's are Private (Not declared in the Package specs).
****************************************************************************/

procedure GetPOAttributes(p_po_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2) is

x_progress varchar2(100) := '000';

counter NUMBER:=0;
BEGIN

  x_progress := 'PO_POAPPROVAL_INIT1.GetPOAttributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* Fetch the PO Header, then set the attributes.  */
  open GetPOHdr_csr(p_po_header_id);
  FETCH GetPOHdr_csr into POHdr_rec;
  close GetPOHdr_csr;

  x_progress := 'PO_POAPPROVAL_INIT1.GetPOAttributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  SetPOHdrAttributes(itemtype, itemkey);

  x_progress := 'PO_POAPPROVAL_INIT1.GetPOAttributes: 03';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_POAPPROVAL_INIT1','GetPOAttributes',x_progress);
    raise;

end GetPOAttributes;
--
procedure SetPOHdrAttributes(itemtype in varchar2, itemkey in varchar2) is

l_po_amount         number;
l_po_amount_disp    varchar2(30);
l_tax_amount        number;
l_tax_amount_disp   varchar2(30);
l_total_amount      number;
l_total_amount_disp varchar2(30);
l_doc_id            number;
x_progress          varchar2(100) := '000';

l_auth_stat  varchar2(80);
l_closed_code varchar2(80);
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_doc_type_disp varchar2(240); /* Bug# 2616433 */
-- l_doc_subtype_disp varchar2(80);
l_ga_flag   varchar2(1) := null;  -- FPI GA

/* Start Bug# 3972475 */
X_precision        number;
X_ext_precision    number;
X_min_acct_unit    number;
/* End Bug# 3972475*/

--Added by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
-------------------------------------------------------------------------------------
ln_jai_excl_nr_tax   number;              --exclusive non-recoverable tax
lv_tax_region        varchar2(30);        --tax region code
-------------------------------------------------------------------------------------
--Added by Eric Ma for IL PO Notification on Apr-13,2009 ,End
cursor c1(p_auth_stat varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='AUTHORIZATION STATUS'
  and lookup_code = p_auth_stat;

cursor c2(p_closed_code varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT STATE'
  and lookup_code = p_closed_code;

/* Bug# 2616433: kagarwal
** Desc: We will get the document type display value from
** po document types.
*/

cursor c3(p_doc_type varchar2, p_doc_subtype varchar2) is
select type_name
from po_document_types
where document_type_code = p_doc_type
and document_subtype = p_doc_subtype;

/*
cursor c3(p_doc_type varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT TYPE'
  and lookup_code = p_doc_type;

cursor c4(p_doc_subtype varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT SUBTYPE'
  and lookup_code = p_doc_subtype;
*/

BEGIN

  x_progress := 'PO_POAPPROVAL_INIT1.SetPOHdrAttributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'DOCUMENT_NUMBER',
                                  avalue     =>  POHdr_rec.segment1);
  --
/* Bug# 2423635: kagarwal
** Desc: There is no need to set the DOCUMENT_ID again as
** it is set at the time of startup.
*/

/*
  wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'DOCUMENT_ID',
                                  avalue     => POHdr_rec.po_header_id);
*/
  --
  wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'AUTHORIZATION_STATUS',
                                  avalue     =>  POHdr_rec.authorization_status);
  --
  wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'CLOSED_CODE',
                                  avalue     =>  POHdr_rec.closed_code);

  --
  wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'FUNCTIONAL_CURRENCY',
                                  avalue     =>  POHdr_rec.currency_code);
  --
  wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'PO_DESCRIPTION',
                                  avalue     =>  POHdr_rec.comments);


   l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

   /* Get the translated values for the DOC_TYPE, DOC_SUBTYPE, AUTH_STATUS and
   ** CLOSED_CODE. These will be displayed in the notifications.
   */
  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

   OPEN C1(POHdr_rec.authorization_status);
   FETCH C1 into l_auth_stat;
   CLOSE C1;

   OPEN C2(POHdr_rec.closed_code);
   FETCH C2 into l_closed_code;
   CLOSE C2;

/* Bug# 2616433 */
--<R12 STYLES PHASE II START>
   if l_doc_type = 'PA' AND l_doc_subtype IN ('BLANKET','CONTRACT') OR
      l_doc_type = 'PO' AND l_doc_subtype = 'STANDARD'  then

      l_doc_type_disp:= PO_DOC_STYLE_PVT.GET_STYLE_DISPLAY_NAME(l_doc_id);
  else

      OPEN C3(l_doc_type, l_doc_subtype);
       FETCH C3 into l_doc_type_disp;
       CLOSE C3;
  end if;
--<R12 STYLES PHASE II END>

/*
   OPEN C4(l_doc_subtype);
   FETCH C4 into l_doc_subtype_disp;
   CLOSE C4;
*/

   --
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'AUTHORIZATION_STATUS_DISP',
                                   avalue     =>  l_auth_stat);
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CLOSED_CODE_DISP',
                                   avalue      =>  l_closed_code);

   --<R12 STYLES PHASE II>
   -- Removed FPI GA Modifications to get PO_GA_TYPE Message for GA

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_TYPE_DISP',
                                   avalue      =>  l_doc_type_disp);
   --

/* Bug# 2616433: kagarwal
** Desc: We will only be using one display attribute for type and
** subtype - DOCUMENT_TYPE_DISP, hence commenting the code below
*/

/*
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_SUBTYPE_DISP',
                                   avalue      =>  l_doc_subtype_disp);

*/
  x_progress := 'SetPOHdrAttributes: 02. Values= ' || l_doc_type;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

   /* Bug 979454 */

   l_po_amount := po_notifications_sv3.get_doc_total(l_doc_subtype, l_doc_id);

   --bug 12396408  --bug 14007360
    PO_WF_UTIL_PKG.SetItemAttrNumber (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'PO_AMOUNT_DSP_NUMERIC',
                                   avalue      =>  l_po_amount);

   l_po_amount_disp := TO_CHAR(l_po_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       POHdr_rec.currency_code,30));

   PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'PO_AMOUNT_DSP',
                                   avalue      =>  l_po_amount_disp);

/*Start Bug# 3972475 - replaced the below sql to get the tax amount
  to account for canceled QTY. Also accounted for new order types introduced
  in 11i10 that use amount instead of quantity (where quantity_ordered is null).

  Since we are performing divide and multiply by operations we need rounding
  logic based on the currency.

  If we are using minimum accountable unit we apply:
   rounded tax = round(tax/mau)*mau, otherwise
   rounded tax = round(tax, precision)

   Old tax select:
   select nvl(sum(NONRECOVERABLE_TAX),0)
     into l_tax_amount
     from po_distributions
     where po_header_id = POHdr_rec.po_header_id;
*/

   --Modified by Eric Ma for IL PO Notification on Apr-13,2009,Begin
   ------------------------------------------------------------------------------------
   lv_tax_region      := JAI_PO_WF_UTIL_PUB.get_tax_region
                         ( pv_document_type => JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE
                         , pn_document_id   => l_doc_id
                         );

   IF(lv_tax_region ='JAI')
   THEN
     --Indian localization tax calc code
     JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE
	                                   , pn_document_id        => l_doc_id
	                                   , xn_excl_tax_amount    => l_tax_amount
	                                   , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
                                           );
   ELSE
     --original tax calc code
     fnd_currency.get_info( POHdr_rec.currency_code,
                            X_precision,
                            X_ext_precision,
                            X_min_acct_unit);

     BEGIN
     IF (x_min_acct_unit IS NOT NULL) AND
         (x_min_acct_unit <> 0)
     THEN
   -- Bug 14651103 : Changed sqls to calculate tax on basis of POLL.matching_basis rather than relying qunatity_ordered
    SELECT nvl(sum( round (nvl(POD.nonrecoverable_tax,0) *
                       decode(POLL.matching_basis,
                              'AMOUNT',
							  --Bug16222308 Handling the quantity zero on distribution
                              (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / Decode ( nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ),
                              (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / Decode ( nvl(POD.quantity_ordered, 1),0,1,nvl(POD.quantity_ordered, 1) )
                             ) / X_min_acct_unit
                       ) * X_min_acct_unit
              ),0)
    INTO l_tax_amount
    FROM po_distributions_all POD,
	     po_line_locations_all POLL
    WHERE POD.po_header_id = POHdr_rec.po_header_id
    AND POD.line_location_id=POLL.line_location_id
    AND POD.po_header_id=POLL.po_header_id
    AND Nvl(POD.distribution_type,'STANDARD') NOT IN ('PREPAYMENT')  --11876122
    AND POD.line_location_id IS NOT NULL; -- 13887381
    /* Bug 11876122: Adding condition on distribution_type as in case of
       complex PO's PREPAYMENT type distributions should not be considered
       for calculating the tax amount to be shown in approver's window.
    */

     ELSE
   -- Bug 14651103 : Changed sqls to calculate tax on basis of POLL.matching_basis rather than relying qunatity_ordered
    SELECT nvl(sum( round (nvl(POD.nonrecoverable_tax,0) *
                       decode(POLL.matching_basis,
                              'AMOUNT',
							  --Bug16222308 Handling the quantity zero on distribution
                              (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / Decode ( nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ),
                              (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / Decode ( nvl(POD.quantity_ordered, 1),0,1,nvl(POD.quantity_ordered, 1) )
                             ),
                       X_precision
                      )
              ),0)
    INTO l_tax_amount
    FROM po_distributions_all POD,
	     po_line_locations_all POLL
    WHERE POD.po_header_id = POHdr_rec.po_header_id
	AND POD.line_location_id=POLL.line_location_id
    AND POD.po_header_id=POLL.po_header_id
    AND Nvl(distribution_type,'STANDARD') NOT IN ('PREPAYMENT') -- 11876122
    AND POD.line_location_id IS NOT NULL; -- 13887381
     END IF;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	l_tax_amount :=0;
    END;
     /*End Bug# 3972475 */
   END IF; --(lv_tax_region ='JAI')
   ---------------------------------------------------------------------------
   --Modified by Eric Ma for IL PO Notification on Apr-13,2009,End

   l_tax_amount_disp := TO_CHAR(l_tax_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       POHdr_rec.currency_code,30));
   --bug 12396408		--bug 14007360
   PO_WF_UTIL_PKG.SetItemAttrNumber (   itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_DSP_NUMERIC',
                                   avalue      => l_tax_amount );
   PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_DSP',
                                   avalue      => l_tax_amount_disp );

   l_total_amount := l_po_amount + l_tax_amount;

   l_total_amount_disp := TO_CHAR(l_total_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       POHdr_rec.currency_code,30));

   PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TOTAL_AMOUNT_DSP',
                                   avalue      => l_total_amount_disp);

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_POAPPROVAL_INIT1','SetPOHdrAttributes',x_progress);
        raise;


end SetPOHdrAttributes;

--
procedure GetRelAttributes(p_rel_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2) is

x_progress varchar2(100) := '000';

counter NUMBER:=0;
BEGIN


  x_progress := 'PO_POAPPROVAL_INIT1.GetRelAttributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* Fetch the Release Header, then set the attributes.  */
  open GetRelHdr_csr(p_rel_header_id);
  FETCH GetRelHdr_csr into RelHdr_rec;
  close GetRelHdr_csr;

  x_progress := 'PO_POAPPROVAL_INIT1.GetRelAttributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  SetRelHdrAttributes(itemtype, itemkey);

  x_progress := 'PO_POAPPROVAL_INIT1.GetReLattributes: 03';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE GetRelHdr_csr;

    wf_core.context('PO_POAPPROVAL_INIT1','GetRelAttributes',x_progress);
        raise;

end GetRelAttributes;

--
procedure SetRelHdrAttributes(itemtype in varchar2, itemkey in varchar2) is

l_po_amount         number;
l_po_amount_disp    varchar2(30);
l_tax_amount        number;
l_tax_amount_disp   varchar2(30);
l_total_amount      number;
l_total_amount_disp varchar2(30);
l_doc_id      number;
x_progress    varchar2(100) := '000';

l_auth_stat  varchar2(80);
l_closed_code varchar2(80);
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_doc_type_disp varchar2(240); /* Bug# 2616433 */
-- l_doc_subtype_disp varchar2(80);

/* Start Bug# 3972475 */
X_precision        number;
X_ext_precision    number;
X_min_acct_unit    number;
/* End Bug# 3972475*/

--Added by Eric Ma for IL PO Notification on Apr-13,2009,Begin
------------------------------------------------------------------------------------
ln_jai_excl_nr_tax   number;              --exclusive non-recoverable tax
lv_tax_region        varchar2(30);        --tax region code
-------------------------------------------------------------------------------------
--Added by Eric Ma for IL PO Notification on Apr-13,2009,End
cursor c1(p_auth_stat varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='AUTHORIZATION STATUS'
  and lookup_code = p_auth_stat;

/*
cursor c2(p_closed_code varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT STATE'
  and lookup_code = p_closed_code;
*/

/* Bug# 2616433: kagarwal
** Desc: We will get the document type display value from
** po document types.
*/

cursor c3(p_doc_type varchar2, p_doc_subtype varchar2) is
select type_name
from po_document_types
where document_type_code = p_doc_type
and document_subtype = p_doc_subtype;

/*
cursor c3(p_doc_type varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT TYPE'
  and lookup_code = p_doc_type;

cursor c4(p_doc_subtype varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT SUBTYPE'
  and lookup_code = p_doc_subtype;
*/

BEGIN

  x_progress :=  'PO_POAPPROVAL_INIT1.SetPOHdrAttributes : 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'RELEASE_TYPE',
                                        avalue     =>  RelHdr_rec.Release_Type);
        --
        wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'RELEASE_NUM',
                                        avalue     => RelHdr_rec.Release_num);
        --

        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'AUTHORIZATION_STATUS',
                                        avalue     =>  RelHdr_rec.authorization_status);
        --
        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'CLOSED_CODE',
                                        avalue     =>  RelHdr_rec.closed_code);
        --
        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'DOCUMENT_NUMBER',
                                        avalue     =>  RelHdr_rec.po_number);
        --
        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'FUNCTIONAL_CURRENCY',
                                        avalue     =>  RelHdr_rec.currency_code);
        --
        wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'RELEASE_NUM_DASH',
                                        avalue     =>  '-');

        --Bug 10140786 - Setting the PO_DESCRIPTION
 	         wf_engine.SetItemAttrText (     itemtype   => itemtype,
 	                                         itemkey    => itemkey,
 	                                         aname      => 'PO_DESCRIPTION',
 	                                         avalue     =>  RelHdr_rec.comments);

   OPEN C1(RelHdr_rec.authorization_status);
   FETCH C1 into l_auth_stat;
   CLOSE C1;

/*
   OPEN C2(RelHdr_rec.closed_code);
   FETCH C2 into l_closed_code;
   CLOSE C2;
*/

/* Bug# 2616433 */

   OPEN C3('RELEASE', RelHdr_rec.Release_Type);
   FETCH C3 into l_doc_type_disp;
   CLOSE C3;

/*
   OPEN C4(RelHdr_rec.Release_Type);
   FETCH C4 into l_doc_subtype_disp;
   CLOSE C4;
*/

   --
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'AUTHORIZATION_STATUS_DISP',
                                   avalue     =>  l_auth_stat);
   --
/* Not using this currently
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CLOSED_CODE_DISP',
                                   avalue      =>  l_closed_code);
*/
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_TYPE_DISP',
                                   avalue      =>  l_doc_type_disp);
   --

/* Bug# 2616433: kagarwal
** Desc: We will only be using one display attribute for type and
** subtype - DOCUMENT_TYPE_DISP, hence commenting the code below
*/

/*
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_SUBTYPE_DISP',
                                   avalue      =>  l_doc_subtype_disp);
*/

   l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

   l_po_amount := po_notifications_sv3.get_doc_total('RELEASE', l_doc_id);

   --bug 12396408   --bug 14007360
   PO_WF_UTIL_PKG.SetItemAttrNumber (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'PO_AMOUNT_DSP_NUMERIC',
                                   avalue      =>  l_po_amount);


   l_po_amount_disp := TO_CHAR(l_po_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       RelHdr_rec.currency_code,30));

   PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'PO_AMOUNT_DSP',
                                   avalue      =>  l_po_amount_disp);

/*Start Bug# 3972475 - replaced the below sql to get the tax amount
   taking canceled release lines into account. Also accounted for new order
   types introduced in 11i10 that use amount instead of quantity
   (where quantity_ordered is null).

  Since we are performing divide and multiply by operations we need rounding
  logic based on the currency.

  If we are using minimum accountable unit we apply:
   rounded tax = round(tax/mau)*mau, otherwise
   rounded tax = round(tax, precision)

   Old tax select:
   select nvl(sum(NONRECOVERABLE_TAX),0)
     into l_tax_amount
     from po_distributions
    where po_release_id = RelHdr_rec.Po_Release_id;
  */

  --Modified by Eric Ma for IL PO Notification on Apr-13,2009,Begin
  ------------------------------------------------------------------------------------
  lv_tax_region   := JAI_PO_WF_UTIL_PUB.get_tax_region
                     ( pv_document_type => JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE
                     , pn_document_id   => l_doc_id
                     );
  IF(lv_tax_region ='JAI')
  THEN
    --Indian localization tax calc code
    JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE
                                         , pn_document_id        => RelHdr_rec.PO_RELEASE_ID
                                         , xn_excl_tax_amount    => l_tax_amount
                                         , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
                                         );
  ELSE
    --original tax calc code
   fnd_currency.get_info( RelHdr_rec.currency_code,
                          X_precision,
                          X_ext_precision,
                          X_min_acct_unit);

   IF (x_min_acct_unit IS NOT NULL) AND
      (x_min_acct_unit <> 0)
   THEN
     SELECT nvl(sum( round (POD.nonrecoverable_tax *
                        decode(quantity_ordered,
                               NULL,
							   --Bug16222308 Handling the quantity zero on distribution
                               (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / Decode ( nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ),
                               (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / Decode ( nvl(POD.quantity_ordered, 1),0,1,nvl(POD.quantity_ordered, 1) )
                              ) / X_min_acct_unit
                        ) * X_min_acct_unit
               ),0)
     INTO l_tax_amount
     FROM po_distributions_all POD
     WHERE po_release_id = RelHdr_rec.po_release_id;
   ELSE
     SELECT nvl(sum( round (POD.nonrecoverable_tax *
                        decode(quantity_ordered,
                               NULL,
							   --Bug16222308 Handling the quantity zero on distribution
                               (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / Decode ( nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ),
                               (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / Decode ( nvl(POD.quantity_ordered, 1),0,1,nvl(POD.quantity_ordered, 1) )
                              ),
          	        X_precision
                       )
               ),0)
     INTO l_tax_amount
     FROM po_distributions_all POD
     WHERE po_release_id = RelHdr_rec.po_release_id;
   END IF;

/*End Bug# 3972475 */
  END IF;--(lv_tax_region ='JAI')
  ------------------------------------------------------------------------------------
  --Modified by Eric Ma for IL PO Notification on Apr-13,2009,End

   --bug 12396408   --bug 14007360
   PO_WF_UTIL_PKG.SetItemAttrNumber (   itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_DSP_NUMERIC',
                                   avalue      => l_tax_amount );

   l_tax_amount_disp := TO_CHAR(l_tax_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       RelHdr_rec.currency_code,30));

   PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_DSP',
                                   avalue      => l_tax_amount_disp );

   l_total_amount := l_po_amount + l_tax_amount;


   l_total_amount_disp := TO_CHAR(l_total_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       RelHdr_rec.currency_code,30));

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TOTAL_AMOUNT_DSP',
                                   avalue      => l_total_amount_disp);

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_POAPPROVAL_INIT1','SetRelHdrAttributes',x_progress);
        raise;


end SetRelHdrAttributes;
--

/****************************************************************************
*
*	Function Reserve_Unreserve_Check(...)
*
*	Specifications:
*
*	     If action = UNRESERVE then
*		If doc_status in ('REJECTED', 'CANCELLED') then return FALSE.
*		If any distribution is UNRESERVED (encumbered_flag = 'N') then
*		return TRUE else return FALSE.
*	     If action = RESERVE then
*		If doc_status =  'CANCELLED' then return FALSE.
*		If any distribution is RESERVED (encumbered_flag = 'Y') then
*		return TRUE else  return FALSE.
*
****************************************************************************/
-- <ENCUMBRANCE FPJ START>
-- Rewriting the following procedure to use the encumbrance APIs

function Reserve_Unreserve_Check (action VARCHAR2, doc_header_id NUMBER,
				  doc_type_code VARCHAR2, doc_status VARCHAR2,
				  doc_cancel_flag VARCHAR2)
return BOOLEAN
is
l_progress               varchar2(200);
l_doc_subtype            po_headers_all.type_lookup_code%TYPE;
p_return_status          varchar2(1);
p_action_flag            varchar2(1);

begin

   l_progress := '000';

   /* If the document has been cancelled, then we need to disable Reserve
   ** and Unreserve.
   */
   IF ( NVL(doc_cancel_flag,'N') = 'Y' ) THEN

      return FALSE;
   END IF;

   l_progress := '001';

   -- Get the doc subtype
   IF (doc_type_code IN ('PO', 'PA')) THEN

       SELECT type_lookup_code
       INTO   l_doc_subtype
       FROM   po_headers
       WHERE  po_header_id = doc_header_id;

   ELSIF (doc_type_code = 'RELEASE') THEN
       SELECT shipment_type
       INTO   l_doc_subtype
       FROM   po_line_locations
       WHERE  po_release_id = doc_header_id
       AND    ROWNUM = 1;

    ELSIF (doc_type_code = 'REQUISITION') THEN
       SELECT type_lookup_code
       INTO   l_doc_subtype
       FROM   po_requisition_headers
       WHERE  requisition_header_id = doc_header_id;

   ELSE
        wf_core.context('PO_POAPPROVAL_INIT1',
                         'Reserve_Unreserve_Check - Invalid doctype', '004');
        app_exception.Raise_Exception;

   END IF;

   l_progress := '020';

   IF (action = 'UNRESERVE') THEN

       PO_DOCUMENT_FUNDS_PVT.is_unreservable(
         x_return_status     =>   p_return_status
      ,  p_doc_type          =>   doc_type_code
      ,  p_doc_subtype       =>   l_doc_subtype
      ,  p_doc_level         =>   PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
      ,  p_doc_level_id      =>   doc_header_id
      ,  x_unreservable_flag =>   p_action_flag);

        l_progress := '030';

        IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_progress := '040';

        IF p_action_flag = PO_DOCUMENT_FUNDS_PVT.g_parameter_YES THEN
           RETURN TRUE;
        ELSE
           RETURN FALSE;
        END IF;

   ELSIF (action = 'RESERVE') THEN

      PO_DOCUMENT_FUNDS_PVT.is_reservable(
         x_return_status    =>   p_return_status
      ,  p_doc_type         =>   doc_type_code
      ,  p_doc_subtype      =>   l_doc_subtype
      ,  p_doc_level        =>   PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
      ,  p_doc_level_id     =>   doc_header_id
      ,  x_reservable_flag  =>   p_action_flag);

        l_progress := '050';

        IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_progress := '060';

        IF p_action_flag = PO_DOCUMENT_FUNDS_PVT.g_parameter_YES THEN
           RETURN TRUE;
        ELSE
           RETURN FALSE;
        END IF;

   ELSE
	wf_core.context('PO_POAPPROVAL_INIT1',
                         'Reserve_Unreserve_Check - Invalid action', '004');
	app_exception.Raise_Exception;

   END IF;

   l_progress := '100';

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_POAPPROVAL_INIT1','Reserve_Unreserve_Check',l_progress);
    raise;

end Reserve_Unreserve_Check;

-- <ENCUMBRANCE FPJ END>

-- <SVC_NOTIFICATIONS FPJ START>

-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Formatted_Address
--Pre-reqs:
--    None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Given a location ID, concatenates fields from the hr_locations into an
-- address using different fields and formats for different countries and
-- address types.
--Parameters:
--IN:
--in_location_id
--  Location ID
--RETURNS:
--  Concatenated address as a VARCHAR2
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Get_Formatted_Address(p_location_id in NUMBER)
RETURN VARCHAR2 IS

l_address varchar2(2000);

begin
  --SQL What: Concatenate fields from hr_locations
  --SQL Why: To return an address
  SELECT substrb ( part1 || decode(part2, NULL, '', part2 || ' ') || part3,
                   1, 2000)
  INTO l_address
  FROM
    (SELECT hrl.address_line_1 || ', '
              || decode(hrl.address_line_2, null, '', hrl.address_line_2||', ')
              || decode(hrl.address_line_3, null, '', hrl.address_line_3||', ')
              || decode(hr_general.decode_lookup(hrl.country||'_PROVINCE',hrl.town_or_city ),
                        NULL, decode(hrl.town_or_city, null, '', hrl.town_or_city ||', '),
                        hr_general.decode_lookup(hrl.country||'_PROVINCE',hrl.town_or_city ) || ', ')
              AS part1,
            nvl(decode(hrl.region_1,
                       null, hrl.region_2,
                       decode(flv1.meaning,
                              null, decode(flv2.meaning,
                                           null, flv3.meaning,
                                           flv2.lookup_code),
                              flv1.lookup_code) ),
                hrl.region_2)
              AS part2,
            decode(hrl.postal_code, null, '', hrl.postal_code || ', ')
              || ftv.territory_short_name
              AS part3
      FROM hr_locations hrl,
           fnd_territories_vl ftv,
           fnd_lookup_values_vl flv1,
           fnd_lookup_values_vl flv2,
           fnd_lookup_values_vl flv3
      WHERE hrl.region_1 = flv1.lookup_code (+) and
            hrl.country || '_PROVINCE' = flv1.lookup_type (+) and
            decode(flv1.lookup_code, NULL, '1', flv1.security_group_id) =
                   decode(flv1.lookup_code, NULL, '1',
                        FND_GLOBAL.lookup_security_group(flv1.lookup_type, flv1.view_application_id)) and
            decode(flv1.lookup_code, NULL, '1', flv1.view_application_id) =
                   decode(flv1.lookup_code, NULL, '1', 3) and
            hrl.region_2 = flv2.lookup_code (+) and
            hrl.country || '_STATE' = flv2.lookup_type (+) and
            decode(flv2.lookup_code, NULL, '1', flv2.security_group_id) =
                   decode(flv2.lookup_code, NULL, '1',
                        FND_GLOBAL.lookup_security_group(flv2.lookup_type, flv2.view_application_id)) and
            decode(flv2.lookup_code, NULL, '1', flv2.view_application_id) =
                   decode(flv2.lookup_code, NULL, '1', 3) and
            hrl.region_1 = flv3.lookup_code (+) and
            hrl.country || '_COUNTY' = flv3.lookup_type (+) and
            decode(flv3.lookup_code, NULL, '1', flv3.security_group_id) =
                   decode(flv3.lookup_code, NULL, '1',
                         FND_GLOBAL.lookup_security_group(flv3.lookup_type, flv3.view_application_id)) and
            decode(flv3.lookup_code, NULL, '1', flv3.view_application_id) =
                   decode(flv3.lookup_code, NULL, '1', 3) and
            hrl.country = ftv.territory_code (+) and
            hrl.location_id = p_location_id);

  RETURN l_address;

end Get_Formatted_Address;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Formatted_Full_Name
--Pre-reqs:
--    None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Given a first and last name, returns a concatenated full name.
--Parameters:
--IN:
--in_first_name
--  First Name
--in_last_name
--  Last Name
--RETURNS:
--  Concatenated full name as a VARCHAR2
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Get_Formatted_Full_Name(p_first_name in VARCHAR2,
                                 p_last_name in VARCHAR2)
RETURN VARCHAR2 IS

  l_optional_space VARCHAR2(1);

BEGIN
  if(p_first_name is not null and p_last_name is not null) then
      l_optional_space := ' ';
  else
      l_optional_space := '';
  end if;

  return (p_first_name || l_optional_space || p_last_name);

end Get_Formatted_Full_Name;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_temp_labor_requester
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the employee_id of the requester for the given Temp Labor PO line,
--  based on a series of rules.
--Parameters:
--IN:
--p_po_line_id
--  Temp Labor PO line that we are retrieving the requester for.
--OUT:
--x_requester_id
--  employee_id of the requester
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_temp_labor_requester (
  p_po_line_id         IN PO_LINES_ALL.po_line_id%TYPE,
  x_requester_id       OUT NOCOPY PO_REQUISITION_LINES.to_person_id%TYPE
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'get_temp_labor_requester';
  l_progress    VARCHAR2(3) := '000';

  CURSOR l_line_req_requester_csr (
    p_po_line_id PO_LINES.po_line_id%TYPE
  ) IS
    -- SQL What: Retrieves the requester from the backing requisition of the
    --           PO line, if available.
    -- SQL Why:  To determine the recipient of the Temp Labor notification.
    --
    -- <Complex Work R12>:
    --    o   Added ORDER BY clause so that, if there are multiple
    --        pay items on a line, we will pull the requisition from the first
    --        line location.
    -- Bug 5004284: Restored the outer join that was removed in 120.4. This
    -- is necessary because even if no backing requisition lines were found,
    -- we still want to return POH.agent_id.
    SELECT PRL.to_person_id, POH.agent_id
    FROM po_lines POL,
         po_line_locations PLL,
         -- For Shared Procurement, the destination OU may be different from
         -- the Purchasing OU:
         po_requisition_lines_all PRL,
         po_headers POH
    WHERE POL.po_line_id = p_po_line_id
    AND   POL.po_line_id = PLL.po_line_id                  -- JOIN
    AND   PLL.line_location_id = PRL.line_location_id (+)  -- JOIN
    AND   POH.po_header_id = POL.po_header_id              -- JOIN
    ORDER BY PLL.shipment_num;

  CURSOR l_line_dist_requesters_csr (
    p_po_line_id PO_LINES.po_line_id%TYPE
  ) IS
    -- SQL What: For the given PO line, retrieves the requesters from the
    --           distributions, starting with the first distribution that has a
    --           requester.
    -- SQL Why:  To determine the recipient of the Temp Labor notification.
    --
    -- <Complex Work R12>: Added join to po_line_locations and shipment_num
    -- to the ORDER BY clause so we will get the first distribution on the
    -- first pay item that has a deliver-to-person, in the case of a complex
    -- work PO that has multiple pay items on a fixed-price temp labor line.
    -- Changed po_distributions to po_distributions_all to only have a single
    -- secured synonym in the query.
    SELECT POD.deliver_to_person_id
    FROM po_distributions_all POD
       , po_line_locations PLL   -- <Complex Work R12>
    WHERE POD.line_location_id = PLL.line_location_id
    AND   PLL.po_line_id = p_po_line_id
    AND   POD.deliver_to_person_id IS NOT NULL
    AND   PLL.shipment_type <> 'PREPAYMENT'
    ORDER BY PLL.shipment_num, POD.distribution_num ASC;

  l_requester_id PO_REQUISITION_LINES.to_person_id%TYPE := null;
  l_agent_id     PO_HEADERS.agent_id%TYPE;
  l_po_header_id PO_HEADERS.po_header_id%TYPE;
BEGIN
  -- Determine the recipient of this notification using the 3 rules below:

  -- Rule 1. If the PO line has a backing requisition, use the requester
  -- on the requisition.
  OPEN l_line_req_requester_csr (p_po_line_id);
  FETCH l_line_req_requester_csr INTO l_requester_id, l_agent_id;
  CLOSE l_line_req_requester_csr;

  l_progress := '010';
  IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
      FND_LOG.string (
      log_level => FND_LOG.LEVEL_EVENT,
      module => g_module_prefix || l_proc_name,
      message => '1. Requester on backing requisition: '||l_requester_id );
    END IF;
  END IF;

  -- Rule 2. Otherwise, use the requester on the first distribution of
  -- the PO, if available.
  -- Bug 5004284: Changed the condition from l_line_req_requester_csr%NOTFOUND
  -- (introduced in 120.4) back to l_requester_id IS NULL. Even if there are no
  -- backing reqs, the cursor should always return a row (with the agent_id).
  IF (l_requester_id IS NULL) THEN
    OPEN l_line_dist_requesters_csr (p_po_line_id);
    FETCH l_line_dist_requesters_csr INTO l_requester_id;

    l_progress := '020';
    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
        FND_LOG.string (
        log_level => FND_LOG.LEVEL_EVENT,
        module => g_module_prefix || l_proc_name,
        message => '2. Requester on PO distribution: '||l_requester_id );
      END IF;
    END IF;

    -- Rule 3. Otherwise, use the buyer on the PO.
    IF (l_line_dist_requesters_csr%NOTFOUND) THEN
      l_requester_id := l_agent_id;

      l_progress := '030';
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
          FND_LOG.string (
          log_level => FND_LOG.LEVEL_EVENT,
          module => g_module_prefix || l_proc_name,
          message => '3. Using the buyer on the PO as the requester: '||l_requester_id );
        END IF;
      END IF;
    END IF;

    CLOSE l_line_dist_requesters_csr;

  END IF; -- l_requester_id IS NULL

  x_requester_id := l_requester_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (l_line_req_requester_csr%ISOPEN) THEN
      CLOSE l_line_req_requester_csr;
    END IF;

    IF (l_line_dist_requesters_csr%ISOPEN) THEN
      CLOSE l_line_dist_requesters_csr;
    END IF;

    wf_core.context( g_pkg_name, l_proc_name, l_progress );
    RAISE;

END get_temp_labor_requester;

-------------------------------------------------------------------------------
--Start of Comments
--Name: launch_notify_tl_requesters
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  For each new Temp Labor line (i.e. line that has not been approved before)
--  on a standard PO, starts the Notify Temp Labor Requester process to send
--  a PO Approval notification to the requester.
--Parameters:
--IN:
--itemtype
--  Workflow Item Type.
--itemkey
--  Workflow Item Key.
--actid
--  Identifies the Workflow activity that is calling this procedure.
--funcmode
--  Workflow mode that this procedure is being called in: Run, Cancel, etc.
--OUT:
--resultout
--  Standard result returned to Workflow: COMPLETED, ERROR, etc.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE launch_notify_tl_requesters (
  itemtype  IN VARCHAR2,
  itemkey   IN VARCHAR2,
  actid     IN NUMBER,
  funcmode  IN VARCHAR2,
  resultout OUT NOCOPY VARCHAR2
) IS
  l_proc_name VARCHAR2(30) := 'launch_notify_tl_requesters';
  l_progress    VARCHAR2(3) := '000';

  CURSOR l_temp_labor_lines_csr (
    p_po_header_id    PO_HEADERS.po_header_id%TYPE,
    p_is_new_document VARCHAR2
  ) IS
    -- SQL What: Retrieves the Temp Labor lines of the given PO.
    --           We retrieve all lines if this is a new PO, or just the
    --           new lines if this is an existing PO.
    -- SQL Why:  To send a notification to the requester of each line.
    SELECT POL.po_line_id,
           POL.contractor_first_name,
           POL.contractor_last_name,
           PJ.name job_name
    FROM po_headers POH,
         po_lines POL,
         per_jobs_vl PJ
    WHERE POH.po_header_id = p_po_header_id
    AND   POH.po_header_id = POL.po_header_id -- JOIN
    AND   POL.purchase_basis = 'TEMP LABOR'
    AND   PJ.job_id = POL.job_id -- JOIN
    AND   -- For a new document, we want all of the lines.
          ((p_is_new_document = 'Y') OR

           -- For an existing document, we only want the new lines - i.e.
           -- the lines that do not have any older archived revisions.
           NOT EXISTS
           (SELECT 1
            FROM po_lines_archive PLA
            WHERE PLA.po_line_id = POL.po_line_id -- JOIN
            AND   PLA.revision_num <> POH.revision_num));

  l_tl_line_rec l_temp_labor_lines_csr%ROWTYPE;

  l_document_id       PO_HEADERS.po_header_id%TYPE;
  l_document_type     PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE;
  l_document_subtype  PO_DOCUMENT_TYPES_ALL_B.document_subtype%TYPE;
  l_is_new_document   VARCHAR2(1);
  l_contractor_or_job VARCHAR2(500);
  l_requester_id      PO_REQUISITION_LINES.to_person_id%TYPE;
  l_approver_user_name WF_USERS.name%TYPE;
  l_item_key          WF_ITEMS.item_key%TYPE;
  l_item_key_seq      NUMBER;
BEGIN
  -- Do nothing if the Workflow mode is Cancel or Timeout.
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  l_document_type := po_wf_util_pkg.GetItemAttrText (
                       itemtype => itemtype,
                       itemkey => itemkey,
                       aname => 'DOCUMENT_TYPE');

  l_document_subtype := po_wf_util_pkg.GetItemAttrText (
                          itemtype => itemtype,
                          itemkey => itemkey,
                          aname => 'DOCUMENT_SUBTYPE');

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug ( itemtype, itemkey,
      g_pkg_name||'.'||l_proc_name||': document type: ' || l_document_type
      || ', document subtype: ' || l_document_subtype );
  END IF;

  -- This notification should only be sent for standard POs.
  IF (l_document_type = 'PO') AND (l_document_subtype = 'STANDARD') THEN

    l_progress := '010';

    l_document_id := po_wf_util_pkg.GetItemAttrNumber (
                       itemtype => itemtype,
                       itemkey => itemkey,
                       aname => 'DOCUMENT_ID' );

    l_is_new_document := po_wf_util_pkg.GetItemAttrText (
                           itemtype => itemtype,
                           itemkey => itemkey,
                           aname => 'IS_NEW_DOCUMENT');

    l_approver_user_name := po_wf_util_pkg.GetItemAttrText (
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'APPROVER_USER_NAME');

    -- Loop through the Temp Labor lines of this PO.
    FOR l_tl_line_rec
      IN l_temp_labor_lines_csr (l_document_id, l_is_new_document ) LOOP

      l_progress := '020';

      -- Determine the requester for this Temp Labor PO line.
      get_temp_labor_requester (
        p_po_line_id => l_tl_line_rec.po_line_id,
        x_requester_id => l_requester_id );

      -- For the subject of the notification, use the contractor name,
      -- if available, or otherwise the job name.
      IF (l_tl_line_rec.contractor_first_name IS NOT NULL)
         OR (l_tl_line_rec.contractor_last_name IS NOT NULL) THEN
        l_contractor_or_job :=
          get_formatted_full_name( l_tl_line_rec.contractor_first_name,
                                   l_tl_line_rec.contractor_last_name );
      ELSE
        l_contractor_or_job := l_tl_line_rec.job_name;
      END IF;

      -- Get a unique value from the sequence.
      SELECT PO_WF_ITEMKEY_S.nextval
      INTO l_item_key_seq
      FROM dual;

      -- Generate the item key from the PO line ID and the sequence value.
      l_item_key := l_tl_line_rec.po_line_id || '-' || l_item_key_seq;

      l_progress := '030';

      -- Start a child process to send a notification for this PO line.
      start_po_line_wf_process (
        p_item_type          => ItemType,
        p_item_key           => l_item_key,
        p_process            => 'NOTIFY_TEMP_LABOR_REQUESTER',
        p_parent_item_type   => ItemType,
        p_parent_item_key    => ItemKey,
        p_po_line_id         => l_tl_line_rec.po_line_id,
        p_requester_id       => l_requester_id,
        p_contractor_or_job  => l_contractor_or_job,
        p_approver_user_name => l_approver_user_name
      );

    END LOOP; -- l_temp_labor_requesters_csr

  END IF; -- Standard PO

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context( g_pkg_name, l_proc_name, l_progress );
    RAISE;
END launch_notify_tl_requesters;

-------------------------------------------------------------------------------
--Start of Comments
--Name: start_po_line_wf_process
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Starts a child workflow process for the given PO line.
--Parameters:
--IN:
--p_item_type
--  Workflow Item Type of the child process.
--p_item_key
--  Workflow Item Key of the child process.
--p_process
--  Name of the child process.
--p_parent_item_type
--  Workflow Item Type of the parent process.
--p_parent_item_key
--  Workflow Item Key of the parent process.
--p_po_line_id
--  PO line for the child process
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE start_po_line_wf_process (
  p_item_type           IN VARCHAR2,
  p_item_key            IN VARCHAR2,
  p_process             IN VARCHAR2,
  p_parent_item_type    IN VARCHAR2,
  p_parent_item_key     IN VARCHAR2,
  p_po_line_id          IN NUMBER,
  p_requester_id        IN NUMBER,
  p_contractor_or_job   IN VARCHAR2,
  p_approver_user_name  IN VARCHAR2
) IS
  l_proc_name           VARCHAR2(30) := 'start_po_line_wf_process';
  l_progress            VARCHAR2(3) := '000';
  l_requester_user_name WF_USERS.name%TYPE;
  l_requester_disp_name WF_USERS.display_name%TYPE;
  l_po_header_id        PO_HEADERS_ALL.po_header_id%TYPE;
  l_req_header_id       PO_REQUISITION_HEADERS_ALL.requisition_header_id%TYPE;
  l_document_number     PO_HEADERS_ALL.segment1%TYPE;
  l_create_cwk_url      VARCHAR2(500);
BEGIN
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug ( p_item_type, p_item_key,
      substrb (
        g_pkg_name||'.'||l_proc_name||': p_item_type: '||p_item_type
        ||', p_item_key: '||p_item_key||', p_process: '||p_process
        ||', p_po_line_id: '||p_po_line_id,
        1, 1000 ) );
  END IF;

  PO_REQAPPROVAL_INIT1.get_user_name (
    p_employee_id => p_requester_id,
    x_username => l_requester_user_name,
    x_user_display_name => l_requester_disp_name );

  l_progress := '010';

  -- Create the child process.
  wf_engine.CreateProcess(itemtype => p_item_type,
                          itemkey  => p_item_key,
                          process  => p_process );

  l_progress := '020';

  -- Set some workflow item attributes.
  po_wf_util_pkg.SetItemAttrNumber (itemtype => p_item_type,
                                    itemkey  => p_item_key,
                                    aname    => 'PO_LINE_ID',
                                    avalue   => p_po_line_id);

  po_wf_util_pkg.SetItemAttrNumber (itemtype => p_item_type,
                                    itemkey  => p_item_key,
                                    aname    => 'REQUESTER_ID',
                                    avalue   => p_requester_id);

  po_wf_util_pkg.SetItemAttrText ( ItemType => p_item_type,
                                   ItemKey  => p_item_key,
                                   aname    => 'REQUESTER_USER_NAME',
                                   avalue   => l_requester_user_name );

  po_wf_util_pkg.SetItemAttrText (itemtype => p_item_type,
                                  itemkey => p_item_key,
                                  aname => 'CONTRACTOR_OR_JOB',
                                  avalue => p_contractor_or_job);

  po_wf_util_pkg.SetItemAttrText (itemtype => p_item_type,
                                  itemkey => p_item_key,
                                  aname => 'APPROVER_USER_NAME',
                                  avalue => p_approver_user_name);

  -- Bug 3441007 START
  -- For BLAF Compliance, we are now showing the links in the Related
  -- Applications section, so we need to set the URL attributes.

  -- SQL What: Retrieve the PO_HEADER_ID and REQUISITION_HEADER_ID for the
  --           Temp Labor PO line.
  SELECT POH.po_header_id,
         POH.segment1,
         PRL.requisition_header_id
  INTO l_po_header_id,
       l_document_number,
       l_req_header_id
  FROM po_lines POL,
       po_headers POH,
       po_line_locations PLL,
       po_requisition_lines_all PRL
  WHERE POL.po_line_id = p_po_line_id
  AND   POL.po_header_id = POH.po_header_id -- JOIN
  AND   POL.po_line_id = PLL.po_line_id -- JOIN
  AND   PLL.line_location_id = PRL.line_location_id (+); -- JOIN

  po_wf_util_pkg.SetItemAttrText ( ItemType => p_item_type,
                                   ItemKey  => p_item_key,
                                   aname    => 'DOCUMENT_NUMBER',
                                   avalue   => l_document_number );

  -- Show the 'View Purchase Order' link.
  po_wf_util_pkg.SetItemAttrText ( ItemType => p_item_type,
                                   ItemKey  => p_item_key,
                                   aname    => 'VIEW_PO_URL',
                                   avalue   =>
    'OA.jsp?OAFunc=POS_VIEW_ORDER&PoHeaderId='||l_po_header_id );

  -- Show the 'View Requisition' link if there is a backing requisition.
  IF (l_req_header_id IS NOT NULL) THEN

    po_wf_util_pkg.SetItemAttrText ( ItemType => p_item_type,
                                     ItemKey  => p_item_key,
                                     aname    => 'VIEW_REQ_URL',
                                     avalue   =>
      'OA.jsp?OAFunc=ICX_POR_LAUNCH_IP&porMode=viewReq'
      ||'&porReqHeaderId='||l_req_header_id
      ||'&currNid=-&#NID-'); --bug 16515181

  END IF; -- l_req_header_id

  -- Show the 'Create Contractor Assignment' link if the required version of
  -- HR Self Service is installed.
  HR_PO_INFO.get_url_place_cwk ( p_po_line_id => p_po_line_id,
                                 p_destination => l_create_cwk_url );

  IF (l_create_cwk_url IS NOT NULL) THEN
    po_wf_util_pkg.SetItemAttrText ( ItemType => p_item_type,
                                     ItemKey  => p_item_key,
                                     aname    => 'CREATE_CWK_ASSIGNMENT_URL',
                                     avalue   => l_create_cwk_url );
  END IF;
  -- Bug 3441007 END

  l_progress := '030';

  -- Set the parent-child relationship between the 2 processes.
  wf_engine.SetItemParent (itemtype        => p_item_type,
                           itemkey         => p_item_key,
                           parent_itemtype => p_parent_item_type,
                           parent_itemkey  => p_parent_item_key,
                           parent_context  => NULL);

  l_progress := '040';

  -- Start the child process.
  wf_engine.StartProcess (itemtype => p_item_type,
                          itemkey  => p_item_key );

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context( g_pkg_name, l_proc_name, l_progress );
    RAISE;
END start_po_line_wf_process;
-- <SVC_NOTIFICATIONS FPJ END>

--< Bug 3554754 Start >
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_approved_date
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Returns the approved date from the document header based upon p_doc_type and
--  p_doc_id.
--Parameters:
--IN:
--p_doc_type
--  'PO', 'PA', or 'RELEASE'.
--p_doc_id
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - on success
--  FND_API.g_ret_sts_error - when p_doc_type is not 'PO', 'PA', or 'RELEASE'.
--  FND_API.g_ret_sts_unexp_error - unexpected error
--x_approved_date
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_approved_date
    ( p_doc_type      IN  VARCHAR2
    , p_doc_id        IN  VARCHAR2
    , x_return_status OUT NOCOPY VARCHAR2
    , x_approved_date OUT NOCOPY DATE
    )
IS
BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Validate the input parameters
    IF (p_doc_type NOT IN ('PO','PA','RELEASE')) OR
       (p_doc_id IS NULL)
    THEN
        RAISE FND_API.g_exc_error;
    END IF;

    IF (p_doc_type = 'RELEASE') THEN
        SELECT approved_date
          INTO x_approved_date
          FROM po_releases_all
         WHERE po_release_id = p_doc_id;
    ELSE
        SELECT approved_date
          INTO x_approved_date
          FROM po_headers_all
         WHERE po_header_id= p_doc_id;
    END IF;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var(g_module_prefix||'get_approved_date','END','x_approved_date',x_approved_date);
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(g_module_prefix||'get_approved_date','ERROR','Invalid input params');
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        PO_DEBUG.handle_unexp_error( p_pkg_name  => g_pkg_name
                                   , p_proc_name => 'get_approved_date'
                                   );
END get_approved_date;
--< Bug 3554754 End >

--
end PO_POAPPROVAL_INIT1;

/
