--------------------------------------------------------
--  DDL for Package Body PO_CONTERMS_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CONTERMS_WF_PVT" AS
/* $Header: POXVWCTB.pls 120.4.12010000.2 2011/10/20 13:38:18 ssindhe ship $ */

--< CONTERMS FPJ Start>
 -- Get profile option that enables/disables the debug log for workflow
g_po_wf_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
 -- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_CONTEMRS_WF_PVT';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';

-------------------------------------------------------------------------------
--Start of Comments
--Name: show_error
--Pre-reqs:
-- None
--Modifies:
-- None
--Locks:
-- None
--Function:
-- Put messages in workflow debuf if contracts call failed
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--p_api_name
-- Name of the Contracts API called
--p_return_status
-- Staus returned by called API
--Notes:
-- None
--Testing:
-- Test this API by failing contract API call
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE show_error (itemtype IN VARCHAR2,
                      itemkey  IN VARCHAR2,
                      p_api_name IN VARCHAR2,
                      p_return_status IN  VARCHAR2) IS

l_count   number:= FND_MSG_PUB.Count_Msg;
BEGIN
   PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
            '10: Start show error');
   PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
            '20:Return status for '||p_api_name||':'||p_return_status);
   FOR i IN 1..l_count LOOP
      PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
            (20+i)||':Error-'||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
   END LOOP;
   PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
            '100: End show error');
END show_error;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_wf_params
--Pre-reqs:
-- None
--Modifies:
-- None
--Locks:
-- None
--Function:
-- Get values for attributes needed for contract call
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--OUT:
--x_po_header_id
-- header id of the po being approved in this wf process
--x_po_doc_type
-- Main document type of the po being approved in this wf process
--x_po_doc_subtype
-- Sub document type of the po being approved in this wf process
--Notes:
-- None
--Testing:
-- Test this procedure by checking debug
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_wf_params(itemtype IN VARCHAR2,
                        itemkey  IN VARCHAR2,
                        x_po_header_id  OUT NOCOPY  NUMBER,
                        x_po_doc_type  OUT NOCOPY  VARCHAR2,
                        x_po_doc_subtype OUT NOCOPY  VARCHAR2) IS

BEGIN

    IF (g_po_wf_debug = 'Y') THEN
	    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                      '10:Start get_wf_params ');
    END IF;
    x_po_header_id   := PO_wf_Util_Pkg.GetItemAttrNumber(
                                      itemtype => itemtype,
  					                  itemkey  => itemkey,
				    	              aname    => 'DOCUMENT_ID');

    x_po_doc_type    := PO_wf_Util_Pkg.GetItemAttrText(
                                      itemtype => itemtype,
  					                  itemkey  => itemkey,
				    	              aname    => 'DOCUMENT_TYPE');

    x_po_doc_subtype := PO_wf_Util_Pkg.GetItemAttrText(
                                      itemtype => itemtype,
  					                  itemkey  => itemkey,
				    	              aname    => 'DOCUMENT_SUBTYPE');

    IF (g_po_wf_debug = 'Y') THEN
	    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                      '30:po_header_id = '|| to_char(x_po_header_id));
	    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                     '40:po doc type= '|| x_po_doc_type);
	    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                     '50:po sub type= '|| x_po_doc_subtype);
        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                     '100:End get_wf_params ');
   END IF;
END get_wf_params;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_DELIVERABLE_EVENTS
--Pre-reqs:
-- None
--Modifies:
-- None
--Locks:
-- None
--Function:
-- Returns the deliverable date based event codes and their dates on sent in  po-header_id
--Parameters:
--IN:
--p_po_header_id
-- Header id of the PO
--p_action_code
-- action for which event codes are needed.
--  'U'- Action code is update deliverables
--  'A'- Action code is activate deliverables.Called from here(Update Contract Terms) and QA
--OUT:
--x_event_tbl
-- the event table code
--Notes:
-- None
--Testing:
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_DELIVERABLE_EVENTS (p_po_header_id IN NUMBER,
                                  p_action_code IN VARCHAR2,
                                  p_doc_subtype IN VARCHAR2,
                                  x_event_tbl   OUT NOCOPY EVENT_TBL_TYPE) IS

   l_po_revision_num      PO_HEADERS_ALL.REVISION_NUM%TYPE;
   l_po_start_date        PO_HEADERS_ALL.START_DATE%TYPE;
   l_po_end_date          PO_HEADERS_ALL.END_DATE%TYPE;
   l_archive_start_date   PO_HEADERS_ALL.START_DATE%TYPE;
   l_archive_end_date     PO_HEADERS_ALL.END_DATE%TYPE;

BEGIN
    IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||'Get_DELIVERABLE_EVENTS',
                              MESSAGE  =>'10: Start: Get_DELIVERABLE_EVENTS');
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||'Get_DELIVERABLE_EVENTS',
                              MESSAGE  =>'15: Action Code: Doc subtype'||p_action_code||': '||p_doc_subtype);
               END IF;
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||'Get_DELIVERABLE_EVENTS',
                              MESSAGE  =>'20: Count in Event table'||x_event_tbl.count);
              END IF;

    END IF;
    -- The event codes and dates will be sent only for BPA or CPA
    -- and not for SPO as currently there are no date based events
    -- for SPO seeded. Change the if below , in case this changes
    IF (p_doc_subtype IN ('BLANKET','CONTRACT') ) THEN
        --SQL WHAT: Selects items needed to call contracts events
        --SQL WHY: These values are used in deciding activation and update
        --         of contract deliverables
        --SQl Join:None
        SELECT start_date,
           end_date,
           revision_num
        INTO
           l_po_start_date,
           l_po_end_date,
           l_po_revision_num

        FROM po_headers_all
        WHERE po_header_id = p_po_header_id;

        IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||'Get_DELIVERABLE_EVENTS',
                              MESSAGE  =>'30: After Select.po found');
               END IF;

        END IF;

        IF (p_action_code = 'A') then --if call is for activation of deliverables
                 x_event_tbl(1).event_code := 'PO_START_DATE';
                 x_event_tbl(1).event_date := l_po_start_date;
                 x_event_tbl(2).event_code := 'PO_END_DATE';
                 x_event_tbl(2).event_date := l_po_end_date;


        ELSIF (p_action_code = 'U') then -- If call is for update of deliverables
              --SQL WHAT: Selects start date and end date from archive table for
              --          last but one archival since this is always called after
              --          archive of PO, the latest will have same value as working copy
              --SQL WHY: These values are used to send changed dates for update deliverables
              --SQl Join:None
              SELECT start_date,
                     end_date
              INTO
                   l_archive_start_date,
                   l_archive_end_date
              FROM po_headers_archive_all
              WHERE po_header_id = p_po_header_id
               AND  revision_num = (l_po_revision_num-1);

              -- If start date changed since last revision, then
              -- send the event code and date to update Deliverables
              IF (nvl(l_archive_start_date,FND_API.G_MISS_DATE) <>
                     nvl(l_po_start_date,FND_API.G_MISS_DATE)) THEN

                     x_event_tbl(1).event_code := 'PO_START_DATE';
                     x_event_tbl(1).event_date := l_po_start_date;
              END IF;
              -- If end date changed since last revision, then
              -- send the event code and date to update Deliverables
              IF (nvl(l_archive_end_date,FND_API.G_MISS_DATE) <>
                     nvl(l_po_end_date,FND_API.G_MISS_DATE)) THEN

                     x_event_tbl(2).event_code := 'PO_END_DATE';
                     x_event_tbl(2).event_date := l_po_end_date;
              END IF;
        END IF;--action_code=A or U
    END IF;--doc subtype code

    IF g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||'Get_DELIVERABLE_EVENTS',
                              MESSAGE  =>'90: Count in Event table'||x_event_tbl.count);
                 END IF;
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||'Get_DELIVERABLE_EVENTS',
                              MESSAGE  =>'100: End Get_DELIVERABLE_EVENTS');
                 END IF;

   END IF;
END GET_DELIVERABLE_EVENTS;
-------------------------------------------------------------------------------
--Start of Comments
--Name: CONTRACT_TERMS_CHANGED
--Pre-reqs:
-- Contracts package stubs should be there
-- Runtime poxwfpoa.wft 115.91( Conterms_exist_flag attribute defined)
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by approval workflow to determine if
-- Contract terms have changed or not in this revision
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--Return:
-- Y- Yes Contract terms were changed in this revision
-- N- No Contract terms were not changed in this revision
--Notes:
-- None
--Testing:
-- Test this API by Changing contract terms, by not changing Contract terms
-- and for POs which are not Procurement Contract.
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
FUNCTION CONTRACT_TERMS_CHANGED(itemtype	in varchar2,
                                Itemkey      IN VARCHAR2)

return VARCHAR2       IS
  l_changed         VARCHAR2(1) := 'N';
  l_k_terms_changed VARCHAR2(30);
  l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N';

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;

  l_po_header_id    PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  l_po_doc_type     PO_Document_Types_all_B.Document_type_code%Type;
  l_po_doc_subtype  PO_Document_Types_all_B.Document_subtype%Type;
  l_archived_conterms_flag PO_headers_all.conterms_exist_Flag%Type :='N';

  l_contracts_call_exception   exception;
  l_api_name        VARCHAR2(100);
BEGIN
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
      '10: Start function contract_terms_Changed ');
  END IF;


  l_conterms_yn    := PO_wf_Util_Pkg.GetItemAttrText(
                                      itemtype => itemtype,
  			              itemkey  => itemkey,
			              aname    =>  'CONTERMS_EXIST_FLAG');

  -- get other needed values from attribs
  get_wf_params(itemtype         =>itemtype,
                itemkey          =>itemkey,
                x_po_header_id   =>l_po_header_id,
                x_po_doc_type    =>l_po_doc_type,
                x_po_doc_subtype =>l_po_doc_subtype);

   -- Migrate PO
   -- Now that conterms can be added at any revision of the PO
   -- We need to check if the conterms flag has changed before
   -- checking the contract amendments

   l_archived_conterms_flag := PO_CONTERMS_UTL_GRP.get_archive_conterms_flag (
                                             p_po_header_id => l_po_header_id);

   IF  nvl(l_conterms_yn,'N') = 'Y' AND
       nvl(l_archived_conterms_flag,'N') = 'N' THEN

     IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                             '120:Previous version does not have terms');
     END IF;
     l_changed:='Y';

   ELSIF (l_conterms_yn = 'Y')  then

     -- Call contracts to find out if contract terms changed
     -- Bug 4100563: OKC has provided a new API contract_terms_amended to check if
     -- the primary contract document has changed. We are
     -- calling this new API as an additional check here.
     -- Start bug 4100563
     l_api_name := 'OKC_TERMS_UTIL_GRP.CONTRACT_TERMS_AMENDED';

     IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                 '130: Return status before the call'||l_return_status);
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                 '132: Call OKC_TERMS_UTIL_GRP.contract_terms_amended');
     END IF;

     l_k_terms_changed := OKC_TERMS_UTIL_GRP.CONTRACT_TERMS_AMENDED(
                                 p_api_version   => 1.0,
                                 p_doc_id        => l_po_header_id,
                                 p_doc_type      => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                                 x_return_status => l_return_status,
                                 x_msg_data      => l_msg_data,
                                 x_msg_count     => l_msg_count);

     IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
              '135: Return status  after call to CONTRACT_TERMS_AMENDED'||l_return_status);

     END IF;

     -- Check l_return_status for CONTRACT_TERMS_AMENDED
     IF l_return_status = FND_API.G_RET_STS_SUCCESS then

       -- Check return value from CONTRACT_TERMS_AMENDED
       IF (l_k_terms_changed = 'NONE') THEN
         IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                              '138: K contract terms changed: N'||l_k_terms_changed);
         END IF;

         --End Bug 4100563

         --Call contracts to find out if contract terms changed
         l_api_name := 'OKC_TERMS_UTIl_GRP.IS_ARTICLE_AMENDED';
         IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                    '140: Return status Before the call'||l_return_status);
           PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                            '142:  Call OKC_TERMS_UTIl_GRP.IS_ARTICLE_AMENDED');
         END IF;

         l_k_terms_changed :=OKC_TERMS_UTIl_GRP.IS_ARTICLE_AMENDED(
                             p_api_version    => 1.0,
                             p_doc_id         => l_po_header_id,
                             p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                             x_return_status  => l_return_status,
                             x_msg_data       => l_msg_data,
                             x_msg_count      => l_msg_count);

         IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                '150: Return status  after call to IS_ARTICLE_AMENDED'||l_return_status);

         END IF;

         IF l_return_status = FND_API.G_RET_STS_SUCCESS then

           IF (l_k_terms_changed = 'NONE') THEN
             IF (g_po_wf_debug = 'Y') THEN
               PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                       '155: K Articles changed: N'||l_k_terms_changed);
               PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                       '160:  Call OKC_TERMS_UTIl_GRP.Is_Deliverable_Amended');
               PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                       '162: Return status Before the call'||l_return_status);
             END IF;

             l_api_name := 'OKC_TERMS_UTIl_GRP.Is_Deliverable_Amended';
             l_k_terms_changed :=OKC_TERMS_UTIl_GRP.Is_Deliverable_Amended(
                        p_api_version    => 1.0,
                        p_doc_id         => l_po_header_id,
                        p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                        x_return_status  => l_return_status,
                        x_msg_data       => l_msg_data,
                        x_msg_count      => l_msg_count);

             IF (g_po_wf_debug = 'Y') THEN
               PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                       '165: Return status  after call to Is_Deliverable_Amended'||l_return_status);

             END IF;

             IF l_return_status = FND_API.G_RET_STS_SUCCESS then
               IF (l_k_terms_changed = 'NONE') THEN
                 IF (g_po_wf_debug = 'Y') THEN
                   PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                           '170: K Deliverables changed: N'||l_k_terms_changed);
                 END IF;
                 l_changed:='N';

               ELSE -- if deliverables changed
                 IF (g_po_wf_debug = 'Y') THEN
                   PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                          '175:K deliverables Changed: Y'||l_k_terms_changed);
                 END IF;
                 l_changed:='Y';

               END IF; -- if deliverables changed
             ELSE
               RAISE l_Contracts_call_exception;
             END IF; -- Return status for is_deliverables_amended

           ELSE -- if articles changed
             IF (g_po_wf_debug = 'Y') THEN
               PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '180:K Terms Changed: Y'||l_k_terms_changed);
             END IF;
             l_changed:='Y';

           END IF; -- if articles changed

         ELSE
           RAISE l_Contracts_call_exception;
         END IF; -- Return status for is_articles_amended


       -- Start bug 4100563
       ELSE  -- if contract terms changed

         IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                          '190:K Contract terms Changed: Y'||l_k_terms_changed);
         END IF;
         l_changed:='Y';

       END IF; -- if contract terms changed
     ELSE
       RAISE l_Contracts_call_exception;
     END IF; -- Return status for contract_terms_amended

     -- End bug 4100563

   ELSE  -- if no conterms
     IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '120:Not a Procurement contract');
     END IF;
     l_changed:='N';
   END IF; -- if conterms exist

   IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		'200 End:  contract_terms_Changed ');
   END IF;


   return(l_changed);

EXCEPTION
-- Handle Exceptions and re raise
WHEN l_contracts_call_exception then
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
        '250: End contracts_call_exception: contract_terms_Changed ');

    show_error(itemtype        => itemtype,
               itemkey         => itemkey,
               p_api_name      => l_api_name,
               p_return_status => l_return_status);
  END IF;
  wf_core.context('PO_CONTERMS_WF_PVT', 'CONTRACT_TERMS_CHANGED', 'l_contracts_call_Exception');
  RAISE;
WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
         '300: End IN Exception: contract_terms_Changed ');
  END IF;
  wf_core.context('PO_CONTERMS_WF_PVT', 'CONTRACT_TERMS_CHANGED', 'Exception');
  RAISE;

END CONTRACT_TERMS_CHANGED;

-------------------------------------------------------------------------------
--Start of Comments
--Name: UPDATE_CONTERMS_DATES
--Pre-reqs:
-- Contracts package stubs should be there
-- popo.odf 115.54
--Modifies:
-- None
--Locks:
-- None
--Function:
-- returns the last update date for deliverables and articles
-- These dates need to be synced up when PO is approved and cannot
-- be changed for current revision
--Parameters:
--IN:
--p_po_header_id
-- po_header_id of the po
--p_po_doc_type
-- Document type of the PO (PO/PA)
--p_po_doc_subtype
-- Document subtype- (STANDARD,BLANKET,CONTRACT)
--p_conterms_exist_flag
-- If this po is a procurement contract
--OUT:
--x_return_status
-- Return status of the call
--X_msg_data
-- error message from Contract if x_return_status is not S
--x_msg_count
-- Number of error messages returned
--Notes:
-- None
--Testing:
-- For details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE UPDATE_CONTERMS_DATES(p_po_header_id        IN NUMBER,
                             p_po_doc_type         IN VARCHAR2,
                             p_po_doc_subtype      IN VARCHAR2,
                             p_conterms_exist_flag IN VARCHAR2,
    		                 x_return_status       OUT NOCOPY VARCHAR2,
                             x_msg_data            OUT NOCOPY VARCHAR2,
                             x_msg_count           OUT NOCOPY NUMBER
                             ) IS

   l_articles_upd_date   DATE;
   l_deliv_upd_date      DATE;

   l_k_api_name           VARCHAR2(60);
   l_api_name          CONSTANT VARCHAR(30) := 'UPDATE_CONTERMS_DATES';

   l_Contracts_call_exception  EXCEPTION;
BEGIN
    IF g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'10: Start UPDATE_CONTERMS_DATES');
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'15: p_conterms_exist_flag'||p_conterms_exist_flag);
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'18: p_po_doc_type '||p_po_doc_type );
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'20: p_po_doc_subtype'||p_po_doc_subtype);
       END IF;
    End if;
    IF p_conterms_exist_flag = 'Y' then
          IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'50: It is a procurement Contract');
               END IF;
          End if;
         l_k_api_name:='OKC_TERMS_UTIl_GRP.Get_Last_Update_Date';
         IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'70: Before call to OKC_TERMS_UTIl_GRP.Get_Last_Update_Date');
               END IF;
          End if;
         OKC_TERMS_UTIl_GRP.Get_Last_Update_Date(
                          p_api_version              => 1.0,
                          p_doc_id                   => p_po_header_id,
                          p_doc_type                 => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(p_po_doc_subtype),
                          x_deliverable_changed_date => l_deliv_upd_date,
                          x_terms_changed_date       => l_articles_upd_date,
                          x_return_status            => x_return_status,
                          x_msg_data                 => x_msg_data,
                          x_msg_count                => x_msg_count);
          IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'80: After call to OKC_...Get_Last_Update_Date. Status'||x_return_status);
               END IF;
          End if;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
                 RAISE l_Contracts_call_exception;
          END IF; -- Return status from contracts
    ELSE
         -- There might be some value in these populated when user clicked the
         -- Author button in forms but might have never actually attached a template
         -- So null these fields as they make sense only for a procurement contract
        l_articles_upd_date := null;
        l_deliv_upd_date    := null;
    END IF;

      IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'100: Articles Upd Date'||l_articles_upd_date);
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'100: Deliverables Upd Date'||l_deliv_upd_date);
               END IF;
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'120: Before update of dates in po headers'||l_deliv_upd_date);
              END IF;
       END IF;
     -- SQL What:Updates PO_HEADERS_ALL table and sets the contract terms dates
     -- SQL Why :After PO is Approved, sync up contract terms dates.
     -- SQL Join:none
       UPDATE PO_HEADERS_ALL
          SET conterms_articles_upd_date      = l_articles_upd_date,
              conterms_deliv_upd_date         = l_deliv_upd_date,
              last_updated_by                 = FND_GLOBAL.user_id,
              last_update_login               = FND_GLOBAL.login_id,
              last_update_date                = sysdate
        WHERE po_header_id = p_po_header_id;
       IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'200: End: UPDATE_CONTERMS_DATES');
               END IF;

       END IF;


EXCEPTION
  WHEN l_Contracts_call_exception then
       IF g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'300: End Update_conTerms_dates.In Exception l_Contracts_call_exception');
              END IF;

       END IF;
       -- Show one error message atleast
       IF x_msg_data is null and FND_MSG_PUB.Count_Msg >0 then
          x_msg_data := FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );
       ELSE
          Fnd_message.set_name('PO','PO_API_ERROR');
          Fnd_message.set_token( token  => 'PROC_CALLER'
                                   , VALUE => 'PO_CONTERMS_WF_PVT.UPDATE_CONTERMS_DATES');
          Fnd_message.set_token( token  => 'PROC_CALLED'
                                   , VALUE => l_k_api_name);
          FND_MSG_PUB.Add;
          x_msg_data := FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );

       END IF;
       IF g_fnd_debug = 'Y' then
           FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>':Errors in stack-'||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
               END IF;
          END LOOP;

       END IF;
  WHEN OTHERS THEN
     IF g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                             MODULE   =>g_module_prefix||l_api_name,
                             MESSAGE  =>'400: End Update_conTerms_dates.In Exception OTHERS');
              END IF;

    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
        	   (p_pkg_name       => 'PO_CONTERMS_WF_PVT',
		        p_procedure_name  =>'UPDATE_CONTERMS_DATES');

   END IF;   --msg level
   FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
    -- show one error message at least
   IF x_msg_data is null and FND_MSG_PUB.Count_Msg >0 then
          x_msg_data := FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );
          IF x_msg_data is null then
              x_msg_data := SQLCODE||':'||SQLERRM;
          END IF;
   END IF;
   IF g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                                MODULE   =>g_module_prefix||l_api_name,
                                MESSAGE  =>'410: x_msg_data:'||x_msg_data);
                 END IF;
   END IF;
END UPDATE_CONTERMS_DATES;

-------------------------------------------------------------------------------
--Start of Comments
--Name: UPDATE_CONTRACT_TERMS
--Pre-reqs:
-- Contracts package stubs should be there
-- popo.odf 115.54
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API informs Contracts about signing/approval of new doc revision
-- This API will be called from PO archival, po acceptances
-- Also. this API is called from po_signature_pvt.update_po_details
--Parameters:
--IN:
--p_po_header_id
-- po_header_id of the po
--p_po_signed_date
-- Date PO is signed
--OUT:
--x_return_status
-- Return status of the call
--X_msg_data
-- error message from Contract if x_return_status is not S
--x_msg_count
-- Number of error messages returned
--Notes:
-- None
--Testing:
-- For details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE UPDATE_CONTRACT_TERMS(p_po_header_id        IN NUMBER,
                                p_signed_date         IN DATE,
    		                    x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER) IS

   l_conterms_exist_flag  PO_HEADERS_ALL.CONTERMS_EXIST_FLAG%TYPE;
   l_po_doc_subtype       PO_DOCUMENT_TYPES_ALL_B.DOCUMENT_SUBTYPE%TYPE;
   l_po_revision_num      PO_HEADERS_ALL.REVISION_NUM%TYPE;
   l_event_tbl            EVENT_TBL_TYPE;
   l_k_api_name           VARCHAR2(100);
   l_cancel_flag          PO_HEADERS_ALL.CANCEL_FLAG%TYPE;
   l_po_doc_type          VARCHAR2(2);

   l_i                    BINARY_INTEGER;
   l_Contracts_call_exception  EXCEPTION;
   l_api_name          CONSTANT VARCHAR(30) := 'UPDATE_CONTRACT_TERMS';

   -- Bug 3652222 START
   l_last_signed_revision PO_HEADERS_ALL.REVISION_NUM%TYPE;
   l_signed_records       VARCHAR2(1);
   -- Bug 3652222 END
BEGIN
      IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'10: Start: UPDATE_CONTRACT_TERMS');
               END IF;

     END IF;
    --SQL WHAT: Selects items needed to call contracts API
    --SQL WHY: These values are used in deciding activation and update
    --         of contract deliverables
    --SQl Join:None
    SELECT conterms_exist_flag,
           type_lookup_code,
           revision_num,
           cancel_flag,
           DECODE(type_lookup_code, 'STANDARD', 'PO', 'BLANKET', 'PA', 'CONTRACT', 'PA', NULL)
    INTO   l_conterms_exist_flag,
           l_po_doc_subtype,
           l_po_revision_num,
           l_cancel_flag,
           l_po_doc_type
    FROM po_headers_all
    WHERE po_header_id = p_po_header_id;

    IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'30: After Select. Conterms Exist'||l_conterms_exist_flag);
               END IF;

    END IF;
    IF l_conterms_exist_flag = 'Y' then

          IF g_fnd_debug = 'Y' then
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'50: Doc type'||l_po_doc_subtype);
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'51: po headerid'||p_po_header_id);
               END IF;
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'54: p_po_revision_num'||l_po_revision_num);
               END IF;
           END IF;

          -- activate deliverables created in this revision
          Get_DELIVERABLE_EVENTS(p_po_header_id => p_po_header_id,
                                 p_action_code  => 'A',
                                 p_doc_subtype  => l_po_doc_subtype,
                                 x_event_tbl    => l_event_tbl);
          l_k_api_name:='OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables';
          IF g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'60: event codes passed for OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables');
                 END IF;
                 IF (l_event_tbl.count>0) THEN
	                 FOR l_event in l_event_tbl.FIRST..l_event_tbl.LAST LOOP
                       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                      MODULE   =>g_module_prefix||l_api_name,
                                      MESSAGE  =>'event_code'||l_event||' '||l_event_tbl(l_event).event_code
				                         ||l_event_tbl(l_event).event_date);
                       END IF;

		             END LOOP;
                 END IF;--(l_event_tbl.count>0)
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'70: Before call to OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables');
                 END IF;

          END IF;--debug on
          OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables (
               p_api_version                 => 1.0,
               p_bus_doc_id                  => p_po_header_id,
               p_bus_doc_type                => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
               p_bus_doc_version             => l_po_revision_num,
               p_event_code                  => 'PO_SIGNED',
               p_event_date                  => p_signed_date,
               p_sync_flag                   => FND_API.G_TRUE,
               p_bus_doc_date_events_tbl     => l_event_tbl,
               x_msg_data                    => x_msg_data,
               x_msg_count                   => x_msg_count,
               x_return_status               => x_return_status);
          IF g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'80: After call to OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables');
                 END IF;
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'90: return status'||x_return_status);
                 END IF;

          END IF;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
                 RAISE l_Contracts_call_exception;
          END IF; -- Return status from contracts
          IF  (l_po_revision_num > 0) then --Reresolution will only happen if revision num is greater than 0
               -- update resolved deliverables with changed date
               -- Since already resolved deliverables for last revision's
               -- signed date  should not be reresolved
               -- We should just update the deliverables based on po start or end date
               Get_DELIVERABLE_EVENTS(p_po_header_id => p_po_header_id,
                                    p_action_code  => 'U',
                                    p_doc_subtype  => l_po_doc_subtype,
                                    x_event_tbl    => l_event_tbl);
               l_k_api_name:='OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables';
               IF g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'100:Count-event codes passed for OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables:'||l_event_tbl.count);
                 END IF;
               END IF;
               IF (l_event_tbl.count>0) THEN
                  IF g_fnd_debug = 'Y' then
	                  FOR l_event in l_event_tbl.FIRST..l_event_tbl.LAST LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                          MODULE   =>g_module_prefix||l_api_name,
                                          MESSAGE  =>'event_code'||l_event||' '||l_event_tbl(l_event).event_code
				                         ||l_event_tbl(l_event).event_date);
                           END IF;

		             END LOOP;
                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                    MODULE   =>g_module_prefix||l_api_name,
                                    MESSAGE  =>'110: Before call to OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables');
                     END IF;

                  END IF;-- fnd debug
                  OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables (
                      p_api_version                 => 1.0,
                      p_bus_doc_id                  => p_po_header_id,
                      p_bus_doc_type                => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                      p_bus_doc_version             => l_po_revision_num,
                      p_bus_doc_date_events_tbl     => l_event_tbl,
                      x_msg_data                    => x_msg_data,
                      x_msg_count                   => x_msg_count,
                      x_return_status               => x_return_status);
                  IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                   MODULE   =>g_module_prefix||l_api_name,
                                   MESSAGE  =>'120: After call to OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables');
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                   MODULE   =>g_module_prefix||l_api_name,
                                   MESSAGE  =>'130: Return Status'|| x_return_status);
                    END IF;

                  END IF;--debug
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
                    RAISE l_Contracts_call_exception;
                  END IF; -- Return status from contracts
               END IF;--l_event_tbl.count>0

              --For Bug 13083911
	      --Deliverables attached to document were duplicating when
	      --PDOI is ran for multiple batches.This piece of code getting last
	      --signed revision fails as PDOI does not track action updates to
	      --PO_ACTION_HISTORY table.Instead of checking the revision at PO
	      --and disabling the deliverables at OKC,by this fix trying to disable
	      --the deliverables which are for those document revisions which is less
	      --than the current revision number -1.
	      /*
	       -- Bug 3652222 START
               IF g_fnd_debug = 'Y' then
                 PO_DEBUG.debug_stmt(g_module_prefix||l_api_name, '133',
		    'Before call Get_Last_Signed_Revision');
               END IF;

               --  Migrate PO:
               --  Replaced the pvt api with the grp one as this one checks if the
               --  previous revision has conterms in the first place as this is possible
               --  now with migrate PO
               PO_CONTERMS_UTL_GRP.Get_Last_Signed_Revision(
                            p_api_version         =>  1.0,
                            p_init_msg_list       =>  FND_API.G_FALSE,
	                    p_header_id           =>  p_po_header_id,
	                    p_revision_num        =>  l_po_revision_num,
	                    x_signed_revision_num =>  l_last_signed_revision,
	                    x_signed_records      =>  l_signed_records,
	                    x_return_status       =>  x_return_status,
                            x_msg_data            =>  x_msg_data,
                            x_msg_count           =>  x_msg_count);

               IF g_fnd_debug = 'Y' then
                 PO_DEBUG.debug_stmt(g_module_prefix||l_api_name, '135',
		    'l_last_signed_revision: ' || l_last_signed_revision ||
		    ', l_signed_records: ' || l_signed_records);
               END IF;

               IF (l_signed_records = 'Y' AND l_last_signed_revision >= 0) THEN
               -- Bug 3652222 END
              */
                 -- Disable the deliverables attached to previous revision of PO
                 IF g_fnd_debug = 'Y' then
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                     FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                MODULE   =>g_module_prefix||l_api_name,
                                MESSAGE  =>'140: Before call to OKC_MANAGE_DELIVERABLES_GRP.DisableDeliverables');
                   END IF;

                 END IF;

		 --For Bug 13083911
		 FOR i IN 0..l_po_revision_num-1
                 LOOP

                 OKC_MANAGE_DELIVERABLES_GRP.disableDeliverables (
                    p_api_version                 => 1.0,
                    p_bus_doc_id                  => p_po_header_id,
                    p_bus_doc_type                => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
		    -- Bug 3652222, should pass last signed revision
                    -- p_bus_doc_version          => (l_po_revision_num -1),
		    --For bug 13083911
                    --p_bus_doc_version             => l_last_signed_revision,
                    p_bus_doc_version             => i,
                    x_msg_data                    => x_msg_data,
                    x_msg_count                   => x_msg_count,
                    x_return_status               => x_return_status);
                 IF g_fnd_debug = 'Y' then
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                     FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                MODULE   =>g_module_prefix||l_api_name,
                                MESSAGE  =>'150: After call to OKC_MANAGE_DELIVERABLES_GRP.DisableDeliverables');
                   END IF;
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                     FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                MODULE   =>g_module_prefix||l_api_name,
                                MESSAGE  =>'170: return status'||x_return_status);
                   END IF;

                 END IF;
                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
                     RAISE l_Contracts_call_exception;
                 END IF; -- Return status from contracts

		 --For bug 13083911
		 END LOOP;

               --Commented enf if for bug 13083911
	       -- Bug 3652222 START
               --END IF; /* IF (l_signed_records = 'Y' AND l_last_signed_revision >= 0) */
               -- Bug 3652222 END

               -- cancel deliverables only if po is being archived after cancel
               IF (UPPER(NVL(l_cancel_flag, 'N'))='Y') THEN

                   IF g_fnd_debug = 'Y' then
                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                  MODULE     =>g_module_prefix||l_api_name,
                                  MESSAGE    =>'180: Before call to wrapper procedure to Cancel Deliverables');
                     END IF;

                   END IF;

                   cancel_deliverables(p_bus_doc_id           => p_po_header_id
                                        ,p_bus_doc_type         => l_po_doc_type
                                        ,p_bus_doc_subtype      => l_po_doc_subtype
                                        ,p_bus_doc_version      => l_po_revision_num
                                        ,p_event_code           => 'PO_CANCEL'
                                        ,p_event_date           => SYSDATE
                                        ,p_busdocdates_tbl      => l_event_tbl
                                        ,x_return_status        => x_return_status);
                   IF g_fnd_debug = 'Y' then
                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                  MODULE     =>g_module_prefix||l_api_name,
                                  MESSAGE    =>'190: After call to wrapper procedure to Cancel Deliverables');
                     END IF;

                   END IF;

                   IF g_fnd_debug = 'Y' then
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                     FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                MODULE     =>g_module_prefix||l_api_name,
                                MESSAGE    =>'200: return status '||x_return_status);
                   END IF;

                   END IF;
                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
                     RAISE l_Contracts_call_exception;
                   END IF; -- Return status from contracts


               END IF; -- if the PO is cancelled

          END IF;-- If po revision>0

    END IF; -- if conterms exist
    IF g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'210: End Update Contract Terms');
                 END IF;

   END IF;
EXCEPTION
  WHEN l_Contracts_call_exception then
       IF g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'300: End Update_contract Terms.In Exception l_Contracts_call_exception');
              END IF;
       END IF;
       -- Show one error message atleast
       IF x_msg_data is null and FND_MSG_PUB.Count_Msg >0 then
          x_msg_data := FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );
       ELSE
          Fnd_message.set_name('PO','PO_API_ERROR');
          Fnd_message.set_token( token  => 'PROC_CALLER'
                                   , VALUE => 'PO_CONTERMS_WF_PVT.UPDATE_CONTRACT_TERMS');
          Fnd_message.set_token( token  => 'PROC_CALLED'
                                   , VALUE => l_k_api_name);
          FND_MSG_PUB.Add;
          x_msg_data := FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );

       END IF;
       IF g_fnd_debug = 'Y' then
           FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                 FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>':Errors in stack-'||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
               END IF;
          END LOOP;

       END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
        	   (p_pkg_name       => 'PO_CONTERMS_WF_PVT',
		        p_procedure_name  =>'UPDATE_CONTRACT_TERMS');

   END IF;   --msg level
   FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );

   IF g_fnd_debug = 'Y' then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'400: End Update_contract_terms.In Exception others');
              END IF;
   END IF;
       -- show one error message at least
   IF x_msg_data is null and FND_MSG_PUB.Count_Msg >0 then
          x_msg_data := FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' );
          IF x_msg_data is null then
              x_msg_data := SQLCODE||':'||SQLERRM;
          END IF;
   END IF;
   IF g_fnd_debug = 'Y' then
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                                MODULE   =>g_module_prefix||l_api_name,
                                MESSAGE  =>'410: sql error:'||SQLCODE||':'||SQLERRM);
                 END IF;
                 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                   FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                                MODULE   =>g_module_prefix||l_api_name,
                                MESSAGE  =>'420: x_msg_data:'||x_msg_data);
                 END IF;
   END IF;
END UPDATE_CONTRACT_TERMS;
-------------------------------------------------------------------------------
--Start of Comments
--Name: IS_STANDARD_CONTRACT
--Pre-reqs:
-- Contracts package stubs should be there
-- Runtime poxwfpoa.wft 115.91( Conterms_exist_flag attribute defined)
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by approval workflow Function IS_STANDARD_CONTRACT
-- to determine if  Contract terms have changed from what were defaulted
-- on Contract template
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--actid
-- Standard workflow parameter
--funcmode
-- Standard workflow parameter
--OUT:
--Result
-- Result of the call
-- Possible Return Values:
--  NO_CHANGE
--  There is not change in Contract terms from Standard Contract template
--  ARTICLES_CHANGED
--  Articles are changed from Contract terms in Standard Contract template
--  DELIVERABLES_CHANGED
--  Deliverables are changed from Contract terms in Standard Contract template
--  ALL_CHANGED
--  Deliverables and Articles are changed from Contract terms in
--  Standard Contract template
--Notes:
-- None
--Testing:
-- Test this API by Changing contract terms, by not changing Contract terms
-- and for POs which are not Procurement Contract.
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_STANDARD_CONTRACT (itemtype IN VARCHAR2,
    		                   itemkey  IN VARCHAR2,
    		                   actid    IN NUMBER,
    		                   funcmode IN VARCHAR2,
    		                   result   OUT NOCOPY VARCHAR2) IS

  l_po_header_id    PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N';
  l_po_doc_type     PO_Document_Types_all_B.Document_type_code%Type;
  l_po_doc_subtype  PO_Document_Types_all_B.Document_subtype%Type;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;

  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        VARCHAR2(100);

  l_contracts_call_exception   exception;
 BEGIN
       IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                 '10: Start function IS_STANDARD_CONTRACT ');
       END IF;
       -- Do nothing in cancel or timeout mode
       IF (funcmode <> WF_ENGINE.eng_run) then
            result  := WF_ENGINE.eng_null;
            return;
       END IF;
       result := 'NO_CHANGE';
       l_conterms_yn    := PO_wf_Util_Pkg.GetItemAttrText(
                                      itemtype => itemtype,
  			              itemkey  => itemkey,
			              aname    =>  'CONTERMS_EXIST_FLAG');
       IF (l_conterms_yn = 'Y')  then

           -- get other needed values from attribs
           get_wf_params(itemtype         =>itemtype,
                        itemkey          =>itemkey,
                        x_po_header_id   =>l_po_header_id,
                        x_po_doc_type    =>l_po_doc_type,
                        x_po_doc_subtype =>l_po_doc_subtype);

            --Call contracts to find out if contract terms deviated from standard template

          result :=OKC_TERMS_UTIL_GRP.Deviation_From_Standard(
                                  p_api_version    => 1.0,
                                  p_doc_id         => l_po_header_id,
                                  p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                                  x_return_status  => l_return_status,
                                  x_msg_data       => l_msg_data,
                                  x_msg_count      => l_msg_count);
          IF l_return_status = FND_API.G_RET_STS_SUCCESS then

                  IF (g_po_wf_debug = 'Y') THEN
                        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '100: returned value from Contracts'||result);
                  END IF;

         ELSE
                 RAISE l_Contracts_call_exception;
         END IF; -- Return status from contracts


     ELSE  -- if no conterms
          IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '140:Not a Procurement contract');
          END IF;
     END IF; -- if conterms exist

     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		'200 End:  IS_STANDARD_CONTRACT ');
     END IF;


EXCEPTION
      -- Handle Exceptions and re raise
      WHEN l_contracts_call_exception then
           IF (g_po_wf_debug = 'Y') THEN
                    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  '250: End contracts_call_exception: IS_STANDARD_CONTRACT ');
                     show_error(itemtype        => itemtype,
  					            itemkey         => itemkey,
                                p_api_name      =>'OKC_TERMS_UTIl_GRP.DEVIATION_FROM_STANDARD',
                                p_return_status => l_return_status);
           END IF;
           l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
           l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
           wf_core.context('PO_CONTERMS_WF_PVT', 'IS_STANDARD_CONTRACT', 'l_contracts_call_Exception');

           PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' ),
                     'PO_CONTERMS_WF_PVT.IS_STANDARD_CONTRACT');
           RAISE;

      WHEN OTHERS THEN
         IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		         '300: End IN Exception: IS_STANDARD_CONTRACT ');
         END IF;
         l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
         l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
         wf_core.context('PO_CONTERMS_WF_PVT', 'IS_STANDARD_CONTRACT', 'l_contracts_call_Exception');

         PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, sqlerrm,
                     'PO_CONTERMS_WF_PVT.IS_STANDARD_CONTRACT');
         RAISE;

END IS_STANDARD_CONTRACT;
-------------------------------------------------------------------------------
--Start of Comments
--Name: IS_CONTRACT_TEMPLATE_EXPIRED
--Pre-reqs:
-- Contracts package stubs should be there
-- Runtime poxwfpoa.wft 115.91( Conterms_exist_flag attribute defined)
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by approval workflow Function IS_CONTRACT_TEMPLATE_EXPIRED
-- to determine if  Contract terms template being used has expired or not
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--actid
-- Standard workflow parameter
--funcmode
-- Standard workflow parameter
--OUT:
--Result
-- Result of the call
-- Possible Return Values:
--  Y
--  Yes- The template has expired
--  N
--  No- The template is not expired
--Notes:
-- None
--Testing:
-- Test this API by using expired and effective templates
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_CONTRACT_TEMPLATE_EXPIRED(itemtype IN VARCHAR2,
    		                   itemkey  IN VARCHAR2,
    		                   actid    IN NUMBER,
    		                   funcmode IN VARCHAR2,
    		                   result   OUT NOCOPY VARCHAR2) IS

  l_po_header_id    PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N';
  l_po_doc_type     PO_Document_Types_all_B.Document_type_code%Type;
  l_po_doc_subtype  PO_Document_Types_all_B.Document_subtype%Type;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;

  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        VARCHAR2(100);

  l_contracts_call_exception   exception;
 BEGIN
       IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                 '10: Start function IS_CONTRACT_TEMPLATE_EXPIRED ');
       END IF;
       -- Do nothing in cancel or timeout mode
       IF (funcmode <> WF_ENGINE.eng_run) then
            result  := WF_ENGINE.eng_null;
            return;
       END IF;
       result := 'N';
       l_conterms_yn    := PO_wf_Util_Pkg.GetItemAttrText(
                                      itemtype => itemtype,
  		                      itemkey  => itemkey,
				      aname    =>  'CONTERMS_EXIST_FLAG');
       IF (l_conterms_yn = 'Y')  then

           -- get other needed values from attribs
           get_wf_params(itemtype         =>itemtype,
                        itemkey          =>itemkey,
                        x_po_header_id   =>l_po_header_id,
                        x_po_doc_type    =>l_po_doc_type,
                        x_po_doc_subtype =>l_po_doc_subtype);

          --Call contracts to find out if contract template expired
          result :=OKC_TERMS_UTIl_GRP.IS_TEMPLATE_EXPIRED(
                                  p_api_version    => 1.0,
                                  p_doc_id         => l_po_header_id,
                                  p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                                  x_return_status  => l_return_status,
                                  x_msg_data       => l_msg_data,
                                  x_msg_count      => l_msg_count);
          IF l_return_status = FND_API.G_RET_STS_SUCCESS then

                  IF (g_po_wf_debug = 'Y') THEN
                        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '100: returned value from Contracts'||result);
                  END IF;

         ELSE
                 RAISE l_Contracts_call_exception;
         END IF; -- Return status from contracts


     ELSE  -- if no conterms
          IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '140:Not a Procurement contract');
          END IF;
     END IF; -- if conterms exist

     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		'200 End:  IS_CONTRACT_TEMPLATE_EXPIRED ');
     END IF;


EXCEPTION
      -- Handle Exceptions and re raise
      WHEN l_contracts_call_exception then
           IF (g_po_wf_debug = 'Y') THEN
                    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  '250: End contracts_call_exception: IS_CONTRACT_TEMPLATE_EXPIRED ');
                     show_error(itemtype        => itemtype,
  					            itemkey         => itemkey,
                                p_api_name      =>'OKC_TERMS_UTIl_GRP.IS_CONTRACT_TEMPLATE_EXPIRED',
                                p_return_status => l_return_status);
           END IF;
           l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
           l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
           wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_TEMPLATE_EXPIRED', 'l_contracts_call_Exception');

           PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' ),
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_TEMPLATE_EXPIRED');
           RAISE;

      WHEN OTHERS THEN
         IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		         '300: End IN Exception: IS_CONTRACT_TEMPLATE_EXPIRED ');
         END IF;
         l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
         l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
         wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_TEMPLATE_EXPIRED', 'l_contracts_call_Exception');

         PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, sqlerrm,
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_TEMPLATE_EXPIRED');
         RAISE;

END IS_CONTRACT_TEMPLATE_EXPIRED;

-------------------------------------------------------------------------------
--Start of Comments
--Name: IS_CONTRACT_ARTICLES_EXIST
--Pre-reqs:
-- Contracts package stubs should be there
-- Runtime poxwfpoa.wft 115.91( Conterms_exist_flag attribute defined)
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by approval workflow Function IS_CONTRACT_ARTICLES_EXIST
-- to determine if  Contract terms have articles attached to Purchase Order
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--actid
-- Standard workflow parameter
--funcmode
-- Standard workflow parameter
--OUT:
--Result
-- Result of the call
-- Possible Return Values:
--  NONE
--  There are no articles attached to this purchase order
--  ONLY_STANDARD
--  Only standard Articles exist on this purchase order
--  NON_STANDARD
--  Standard as well as non standard Articles exist on this purchase order
--Notes:
-- None
--Testing:
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_CONTRACT_ARTICLES_EXIST (itemtype IN VARCHAR2,
    		                   itemkey  IN VARCHAR2,
    		                   actid    IN NUMBER,
    		                   funcmode IN VARCHAR2,
    		                   result   OUT NOCOPY VARCHAR2) IS

  l_po_header_id    PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N';
  l_po_doc_type     PO_Document_Types_all_B.Document_type_code%Type;
  l_po_doc_subtype  PO_Document_Types_all_B.Document_subtype%Type;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;

  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        VARCHAR2(100);

  l_contracts_call_exception   exception;
 BEGIN
       IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                 '10: Start function IS_CONTRACT_ARTICLES_EXIST ');
       END IF;
       -- Do nothing in cancel or timeout mode
       IF (funcmode <> WF_ENGINE.eng_run) then
            result  := WF_ENGINE.eng_null;
            return;
       END IF;
       result := 'NONE';
       l_conterms_yn    := PO_wf_Util_Pkg.GetItemAttrText(
                                      itemtype => itemtype,
  			              itemkey  => itemkey,
				      aname    =>  'CONTERMS_EXIST_FLAG');
       IF (l_conterms_yn = 'Y')  then

          -- get other needed values from attribs
          get_wf_params(itemtype         =>itemtype,
                        itemkey          =>itemkey,
                        x_po_header_id   =>l_po_header_id,
                        x_po_doc_type    =>l_po_doc_type,
                        x_po_doc_subtype =>l_po_doc_subtype);

          --Call contracts to find out if contract articles attached
          result :=OKC_TERMS_UTIl_GRP.IS_ARTICLE_EXIST(
                                  p_api_version    => 1.0,
                                  p_doc_id         => l_po_header_id,
                                  p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                                  x_return_status  => l_return_status,
                                  x_msg_data       => l_msg_data,
                                  x_msg_count      => l_msg_count);
          IF l_return_status = FND_API.G_RET_STS_SUCCESS then

                  IF (g_po_wf_debug = 'Y') THEN
                        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '100: returned value from Contracts'||result);
                  END IF;

         ELSE
                 RAISE l_Contracts_call_exception;
         END IF; -- Return status from contracts


     ELSE  -- if no conterms
          IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '140:Not a Procurement contract');
          END IF;
     END IF; -- if conterms exist

     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		'200 End:  IS_CONTRACT_ARTICLES_EXIST ');
     END IF;


EXCEPTION
      -- Handle Exceptions and re raise
      WHEN l_contracts_call_exception then
           IF (g_po_wf_debug = 'Y') THEN
                    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  '250: End contracts_call_exception: IS_CONTRACT_ARTICLES_EXIST ');
                     show_error(itemtype        => itemtype,
  					            itemkey         => itemkey,
                                p_api_name      =>'OKC_TERMS_UTIl_GRP.IS_ARTICLE_EXIST',
                                p_return_status => l_return_status);
           END IF;
           l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
           l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
           wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_ARTICLES_EXIST', 'l_contracts_call_Exception');

           PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' ),
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_ARTICLES_EXIST');
           RAISE;

      WHEN OTHERS THEN
         IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		         '300: End IN Exception: IS_CONTRACT_ARTICLES_EXIST ');
         END IF;
         l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
         l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
         wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_ARTICLES_EXIST', 'l_contracts_call_Exception');

         PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, sqlerrm,
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_ARTICLES_EXIST');
         RAISE;


END IS_CONTRACT_ARTICLES_EXIST;

-------------------------------------------------------------------------------
--Start of Comments
--Name: IS_CONTRACT_ARTICLES_AMENDED
--Pre-reqs:
-- Contracts package stubs should be there
-- Runtime poxwfpoa.wft 115.91( Conterms_exist_flag attribute defined)
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by approval workflow Function IS_CONTRACT_ARTICLES_AMENDED
-- to determine if  contract articles were amended in this revision
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--actid
-- Standard workflow parameter
--funcmode
-- Standard workflow parameter
--OUT:
--Result
-- Result of the call
-- Possible Return Values:
--  NONE
--  No articles were amended in this revision of purchase order
--  ONLY_STANDARD
--  Only standard Articles were amended in this revision of purchase order
--  NON_STANDARD
--  Standard as well as non standard Articles were amended in this revision of purchase order
--Notes:
-- None
--Testing:
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_CONTRACT_ARTICLES_AMENDED(itemtype IN VARCHAR2,
    		                   itemkey  IN VARCHAR2,
    		                   actid    IN NUMBER,
    		                   funcmode IN VARCHAR2,
    		                   result   OUT NOCOPY VARCHAR2) IS

  l_po_header_id    PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N';
  l_po_doc_type     PO_Document_Types_all_B.Document_type_code%Type;
  l_po_doc_subtype  PO_Document_Types_all_B.Document_subtype%Type;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;

  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        VARCHAR2(100);

  l_contracts_call_exception   exception;
 BEGIN
       IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                 '10: Start function IS_CONTRACT_ARTICLES_AMENDED');
       END IF;
       -- Do nothing in cancel or timeout mode
       IF (funcmode <> WF_ENGINE.eng_run) then
            result  := WF_ENGINE.eng_null;
            return;
       END IF;
       result := 'NON_STANDARD';
       l_conterms_yn    := PO_wf_Util_Pkg.GetItemAttrText(
                                      itemtype => itemtype,
  				      itemkey  => itemkey,
				      aname    =>  'CONTERMS_EXIST_FLAG');
       IF (l_conterms_yn = 'Y')  then

          -- get other needed values from attribs
          get_wf_params(itemtype         =>itemtype,
                        itemkey          =>itemkey,
                        x_po_header_id   =>l_po_header_id,
                        x_po_doc_type    =>l_po_doc_type,
                        x_po_doc_subtype =>l_po_doc_subtype);

          --Call contracts to find out if contract articles were amended in this revision
          result :=OKC_TERMS_UTIl_GRP.IS_ARTICLE_AMENDED(
                                  p_api_version    => 1.0,
                                  p_doc_id         => l_po_header_id,
                                  p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                                  x_return_status  => l_return_status,
                                  x_msg_data       => l_msg_data,
                                  x_msg_count      => l_msg_count);
          IF l_return_status = FND_API.G_RET_STS_SUCCESS then

                  IF (g_po_wf_debug = 'Y') THEN
                        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '100: returned value from Contracts'||result);
                  END IF;

         ELSE
                 RAISE l_Contracts_call_exception;
         END IF; -- Return status from contracts


     ELSE  -- if no conterms
          IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '140:Not a Procurement contract');
          END IF;
     END IF; -- if conterms exist

     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		'200 End:  IS_CONTRACT_ARTICLES_AMENDED ');
     END IF;


EXCEPTION
      -- Handle Exceptions and re raise
      WHEN l_contracts_call_exception then
           IF (g_po_wf_debug = 'Y') THEN
                    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  '250: End contracts_call_exception: IS_CONTRACT_ARTICLES_AMENDED ');
                     show_error(itemtype        => itemtype,
  					            itemkey         => itemkey,
                                p_api_name      =>'OKC_TERMS_UTIl_GRP.IS_ARTICLE_AMENDED',
                                p_return_status => l_return_status);
           END IF;
           l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
           l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
           wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_ARTICLES_AMENDED', 'l_contracts_call_Exception');

           PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' ),
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_ARTICLES_AMENDED');
           RAISE;

      WHEN OTHERS THEN
         IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		         '300: End IN Exception: IS_CONTRACT_ARTICLES_AMENDED ');
         END IF;
         l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
         l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
         wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_ARTICLES_AMENDED', 'l_contracts_call_Exception');

         PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, sqlerrm,
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_ARTICLES_AMENDED');
         RAISE;


END IS_CONTRACT_ARTICLES_AMENDED;


-------------------------------------------------------------------------------
--Start of Comments
--Name: IS_CONTRACT_DELIVRABLS_EXIST
--Pre-reqs:
-- Contracts package stubs should be there
-- Runtime poxwfpoa.wft 115.91( Conterms_exist_flag attribute defined)
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by approval workflow Function IS_CONTRACT_DELIVRABLS_EXIST
-- to determine if  contract deliverables are attached to PO
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--actid
-- Standard workflow parameter
--funcmode
-- Standard workflow parameter
--OUT:
--Result
-- Result of the call
-- Possible Return Values:
--  NONE
--  No deliverables are attached
--  CONTRACTUAL
--  Only contractual deliverables are attached
--  INTERNAL
--  Only Internal deliverables are attached
--  ALL
--  Contractual as well as Internal deliverables are attached
--Notes:
-- None
--Testing:
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_CONTRACT_DELIVRABLS_EXIST(itemtype IN VARCHAR2,
    		                   itemkey  IN VARCHAR2,
    		                   actid    IN NUMBER,
    		                   funcmode IN VARCHAR2,
    		                   result   OUT NOCOPY VARCHAR2) IS

  l_po_header_id    PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N';
  l_po_doc_type     PO_Document_Types_all_B.Document_type_code%Type;
  l_po_doc_subtype  PO_Document_Types_all_B.Document_subtype%Type;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;

  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        VARCHAR2(100);

  l_contracts_call_exception   exception;
 BEGIN
       IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                 '10: Start function IS_CONTRACT_DELIVRABLS_EXIST');
       END IF;
       -- Do nothing in cancel or timeout mode
       IF (funcmode <> WF_ENGINE.eng_run) then
            result  := WF_ENGINE.eng_null;
            return;
       END IF;
       result := 'ALL';
       l_conterms_yn    := PO_wf_Util_Pkg.GetItemAttrText(
                      itemtype => itemtype,
  				      itemkey  => itemkey,
				      aname    =>  'CONTERMS_EXIST_FLAG');
       IF (l_conterms_yn = 'Y')  then

          -- get other needed values from attribs
          get_wf_params(itemtype         =>itemtype,
                        itemkey          =>itemkey,
                        x_po_header_id   =>l_po_header_id,
                        x_po_doc_type    =>l_po_doc_type,
                        x_po_doc_subtype =>l_po_doc_subtype);

          --Call contracts to find out if contract deliverables were amended in this revision
          result :=OKC_TERMS_UTIL_GRP.Is_Deliverable_Exist(
                                  p_api_version    => 1.0,
                                  p_doc_id         => l_po_header_id,
                                  p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                                  x_return_status  => l_return_status,
                                  x_msg_data       => l_msg_data,
                                  x_msg_count      => l_msg_count);
          IF l_return_status = FND_API.G_RET_STS_SUCCESS then
                  IF (result = 'CONTRACTUAL_AND_INTERNAL') THEN
                      result := 'ALL';
                  END IF;
                  IF (g_po_wf_debug = 'Y') THEN
                        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '100: returned value from Contracts'||result);
                  END IF;

         ELSE
                 RAISE l_Contracts_call_exception;
         END IF; -- Return status from contracts


     ELSE  -- if no conterms
          IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '140:Not a Procurement contract');
          END IF;
     END IF; -- if conterms exist

     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		'200 End:  IS_CONTRACT_DELIVRABLS_EXIST ');
     END IF;


EXCEPTION
      -- Handle Exceptions and re raise
      WHEN l_contracts_call_exception then
           IF (g_po_wf_debug = 'Y') THEN
                    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  '250: End contracts_call_exception: IS_CONTRACT_DELIVRABLS_EXIST ');
                     show_error(itemtype        => itemtype,
  					            itemkey         => itemkey,
                                p_api_name      =>'OKC_TERMS_UTIl_GRP.Is_Deliverable_Exist',
                                p_return_status => l_return_status);
           END IF;
           l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
           l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
           wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_DELIVRABLS_EXIST', 'l_contracts_call_Exception');

           PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' ),
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_DELIVRABLS_EXIST');
           RAISE;

      WHEN OTHERS THEN
         IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		         '300: End IN Exception: IS_CONTRACT_DELIVRABLS_EXIST ');
         END IF;
         l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
         l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
         wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_DELIVRABLS_EXIST', 'l_contracts_call_Exception');

         PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, sqlerrm,
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_DELIVRABLS_EXIST');
         RAISE;


END IS_CONTRACT_DELIVRABLS_EXIST;

-------------------------------------------------------------------------------
--Start of Comments
--Name: IS_CONTRACT_DELIVRABLS_AMENDED
--Pre-reqs:
-- Contracts package stubs should be there
-- Runtime poxwfpoa.wft 115.91( Conterms_exist_flag attribute defined)
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by approval workflow Function IS_CONTRACT_DELIVRABLS_AMENDED
-- to determine if  contract deliverables were amended in this revision
--Parameters:
--IN:
--itemtype
-- Standard workflow Parameter.
--itemkey
-- Standard workflow parameter
--actid
-- Standard workflow parameter
--funcmode
-- Standard workflow parameter
--OUT:
--Result
-- Result of the call
-- Possible Return Values:
--  NONE
--  No deliverables were amended in this revision of purchase order
--  CONTRACTUAL
--  Only contractual deliverables were amended in this revision of purchase order
--  INTERNAL
--  Only Internal deliverables were amended in this revision of purchase order
--  ALL
--  Contractual as well as Internal deliverables were amended in this revision of purchase order
--Notes:
-- None
--Testing:
-- For more details refer to UT test scripts in DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_CONTRACT_DELIVRABLS_AMENDED(itemtype IN VARCHAR2,
    		                   itemkey  IN VARCHAR2,
    		                   actid    IN NUMBER,
    		                   funcmode IN VARCHAR2,
    		                   result   OUT NOCOPY VARCHAR2) IS

  l_po_header_id    PO_HEADERS_ALL.PO_HEADER_ID%TYPE;
  l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N';
  l_po_doc_type     PO_Document_Types_all_B.Document_type_code%Type;
  l_po_doc_subtype  PO_Document_Types_all_B.Document_subtype%Type;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;

  l_doc_string                VARCHAR2(200);
  l_preparer_user_name        VARCHAR2(100);

  l_contracts_call_exception   exception;
 BEGIN
       IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                 '10: Start function IS_CONTRACT_ARTICLES_AMENDED');
       END IF;
       -- Do nothing in cancel or timeout mode
       IF (funcmode <> WF_ENGINE.eng_run) then
            result  := WF_ENGINE.eng_null;
            return;
       END IF;
       result := 'ALL';
       l_conterms_yn    := PO_wf_Util_Pkg.GetItemAttrText(
                      itemtype => itemtype,
  				      itemkey  => itemkey,
				      aname    =>  'CONTERMS_EXIST_FLAG');
       IF (l_conterms_yn = 'Y')  then

          -- get other needed values from attribs
          get_wf_params(itemtype         =>itemtype,
                        itemkey          =>itemkey,
                        x_po_header_id   =>l_po_header_id,
                        x_po_doc_type    =>l_po_doc_type,
                        x_po_doc_subtype =>l_po_doc_subtype);

          --Call contracts to find out if contract deliverables were amended in this revision
          result :=OKC_TERMS_UTIL_GRP.Is_Deliverable_Amended(
                                  p_api_version    => 1.0,
                                  p_doc_id         => l_po_header_id,
                                  p_doc_type       => PO_CONTERMS_UTL_GRP.Get_Po_Contract_Doctype(l_po_doc_subtype),
                                  x_return_status  => l_return_status,
                                  x_msg_data       => l_msg_data,
                                  x_msg_count      => l_msg_count);
          IF l_return_status = FND_API.G_RET_STS_SUCCESS then
                  IF (result = 'CONTRACTUAL_AND_INTERNAL') THEN
                      result := 'ALL';
                  END IF;
                  IF (g_po_wf_debug = 'Y') THEN
                        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '100: returned value from Contracts'||result);
                  END IF;

         ELSE
                 RAISE l_Contracts_call_exception;
         END IF; -- Return status from contracts


     ELSE  -- if no conterms
          IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
                                 '140:Not a Procurement contract');
          END IF;
     END IF; -- if conterms exist

     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		'200 End:  IS_CONTRACT_DELIVRABLS_AMENDED ');
     END IF;


EXCEPTION
      -- Handle Exceptions and re raise
      WHEN l_contracts_call_exception then
           IF (g_po_wf_debug = 'Y') THEN
                    PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		                  '250: End contracts_call_exception: IS_CONTRACT_DELIVRABLS_AMENDED ');
                     show_error(itemtype        => itemtype,
  					            itemkey         => itemkey,
                                p_api_name      =>'OKC_TERMS_UTIl_GRP.IS_DELIVERABLE_AMENDED',
                                p_return_status => l_return_status);
           END IF;
           l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
           l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
           wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_DELIVRABLS_AMENDED', 'l_contracts_call_Exception');

           PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, FND_MSG_PUB.Get(p_msg_index=>1,p_encoded =>'F' ),
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_DELIVRABLS_AMENDED');
           RAISE;

      WHEN OTHERS THEN
         IF (g_po_wf_debug = 'Y') THEN
             PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE, ITEMKEY,
  		         '300: End IN Exception: IS_CONTRACT_DELIVRABLS_AMENDED ');
         END IF;
         l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
         l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
         wf_core.context('PO_CONTERMS_WF_PVT', 'IS_CONTRACT_DELIVRABLS_AMENDED', 'l_contracts_call_Exception');

         PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
                    l_doc_string, sqlerrm,
                     'PO_CONTERMS_WF_PVT.IS_CONTRACT_DELIVRABLS_AMENDED');
         RAISE;


END IS_CONTRACT_DELIVRABLS_AMENDED;




-------------------------------------------------------------------------------
--Start of Comments
--Name: cancel_deliverables
--Pre-reqs:
--  None.
--Modifies:
--  Cancels deliverables recorded in the OKC schema, on the Purchasing document
--Locks:
--  None.
--Function:
--  A wrapper procedure to call Contracts API to cancel deliverables on a PO CONTRACT
--Parameters:
--IN:
--p_bus_doc_id
--  PO header id
--p_bus_doc_type
--  PA - Purchase Agreement
--  PO - Purchase Order
--p_bus_doc_subtype
--  STANDARD
--  BALNKET
--  CONTRACT
--p_bus_doc_version
--  Document revision number
--p_event_code
--  One of the seeded PO Contracts event
--  PO_CLOSE      - Finally Close PO
--  PO_CANCEL     - Cancel PO
--p_event_date
--  Date on which the PO Contract event occurred. Default is SYSDATE
--p_busdocdates_tbl
--  OKC_MANAGE_DELIVERABLES_GRP.busdocdates_tbl_type table type
--  is a table of dates based events on the PO to resolve deliverables
--  that are based on PO dates (ex. Start date).
--OUT:
--x_return_status
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected/other error
--  FND_API.G_RET_STS_SUCCESS - for successful execution of the API
--Testing:
--
--Notes:
--  This procedure should be called when it is needed to cancel deliverables
--  on the Purchasing document. It should be called instead of calling the OKC
--  API directly.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE cancel_deliverables (
            p_bus_doc_id                IN NUMBER
           ,p_bus_doc_type              IN VARCHAR2
           ,p_bus_doc_subtype           IN VARCHAR2
           ,p_bus_doc_version           IN NUMBER
           ,p_event_code                IN VARCHAR2
           ,p_event_date                IN DATE
           ,p_busdocdates_tbl           IN EVENT_TBL_TYPE
           ,x_return_status             OUT NOCOPY VARCHAR2
           ) IS

       l_bus_doc_version PO_HEADERS_ALL.revision_num%TYPE;
       l_contracts_document_type VARCHAR2(150);

       l_api_name         VARCHAR2(30) := 'cancel_deliverables';
       l_msg_data         VARCHAR2(2000);
       l_msg_count        NUMBER;
       l_return_status    VARCHAR2(1);

BEGIN
       -- initialize return status
       x_return_status := FND_API.G_RET_STS_SUCCESS;


       -- select the business document version if passed null
       IF (p_bus_doc_version IS NULL) THEN
            -- SQL what: select the document version
            -- SQL why : to cancel deliverables on the current version
            -- SQL join: po_header_id
            SELECT revision_num
            INTO   l_bus_doc_version
            FROM   po_headers_all
            WHERE  po_header_id = p_bus_doc_id;
       ELSE
            l_bus_doc_version := p_bus_doc_version;
       END IF;

       l_contracts_document_type := p_bus_doc_type||'_'||p_bus_doc_subtype;

       IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
             FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE
                         ,module   => g_module_prefix || l_api_name
                         ,message  => 'Before calling contracts API to cancel deliverables');
           END IF;
       END IF;

       -- call to the actual API
       OKC_MANAGE_DELIVERABLES_GRP.cancelDeliverables(
           p_api_version                => 1.0
           ,p_init_msg_list             => FND_API.G_FALSE
           ,p_commit                    => FND_API.G_FALSE
           ,p_bus_doc_id                => p_bus_doc_id
           ,p_bus_doc_type              => l_contracts_document_type
           ,p_bus_doc_version           => l_bus_doc_version
           ,p_event_code                => p_event_code
           ,p_event_date                => p_event_date
           ,p_bus_doc_date_events_tbl   => p_busdocdates_tbl
           ,x_msg_data                  => l_msg_data
           ,x_msg_count                 => l_msg_count
           ,x_return_status             => l_return_status);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
             FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE
                         ,module   => g_module_prefix || l_api_name
                         ,message  => 'Deliverables cancelled successfully');
           END IF;
       END IF;

EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
                FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE
                            ,module   => g_module_prefix || l_api_name
                            ,message  => l_msg_data);
              END IF;
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       WHEN OTHERS THEN
           ROLLBACK;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
                FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE
                             ,module   => g_module_prefix || l_api_name
                             ,message  => 'Others Exception');
              END IF;
           END IF;

END cancel_deliverables;

/* CONTERMS FPJ END */
--<CONTERMS FPJ END>
End PO_CONTERMS_WF_PVT;

/
