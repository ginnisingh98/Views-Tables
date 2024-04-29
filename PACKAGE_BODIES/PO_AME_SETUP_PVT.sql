--------------------------------------------------------
--  DDL for Package Body PO_AME_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AME_SETUP_PVT" AS
/* $Header: POXAMESB.pls 120.1.12010000.11 2014/04/14 10:35:00 rkandima ship $*/

g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_function_currency
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the function currency of requisition preparing org
--Parameters:
--IN:
--reqHeaderId
--  Requisition Header ID
--OUT:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_function_currency(reqHeaderId IN NUMBER)
RETURN VARCHAR2 IS
  l_currency_code gl_sets_of_books.currency_code%TYPE;

BEGIN
  SELECT gls.currency_code
  INTO l_currency_code
  FROM financials_system_params_all fsp,
       gl_sets_of_books gls,
       po_requisition_headers_all prh
  WHERE fsp.set_of_books_id = gls.set_of_books_id and
        fsp.org_id = prh.org_id and       -- <R12 MOAC>
        prh.requisition_header_id = reqHeaderId;
  RETURN l_currency_code;
EXCEPTION
  when others then
  raise;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_rate_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the default rate type of requisition preprarer.
--Parameters:
--IN:
--reqHeaderId
--  Requisition Header ID
--OUT:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_rate_type(reqHeaderId IN NUMBER)
RETURN VARCHAR2 IS
  l_user_id fnd_user.user_id%TYPE;
  l_rate_type fnd_profile_option_values.profile_option_value%TYPE;

BEGIN
  BEGIN
    SELECT fu.user_id
    INTO l_user_id
    FROM fnd_user fu, po_requisition_headers_all prh
    WHERE prh.requisition_header_id = reqHeaderId and
          prh.preparer_id = fu.employee_id;
  EXCEPTION
    when others then
      fnd_profile.get('POR_DEFAULT_RATE_TYPE', l_rate_type);
      RETURN l_rate_type;
  END;
  l_rate_type := fnd_profile.value_specific('POR_DEFAULT_RATE_TYPE', l_user_id);
  RETURN l_rate_type;
EXCEPTION
  when others then
  raise;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_accounting_flex
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the accounting flex segment's value for a distribution segment
--Parameters:
--IN:
--segmentName
--  Segment name
--distributionId
--  Requisition distribution ID
--OUT:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_accounting_flex(segmentName IN VARCHAR2, distributionId IN NUMBER)
RETURN VARCHAR2 IS

  l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
  l_result                        BOOLEAN;
  l_chart_of_accounts_id          NUMBER;
  l_num_segments                  NUMBER;
  l_segment_num                   NUMBER;
  l_segment_delimiter             VARCHAR2(1);
  l_seg_val                       VARCHAR2(50);
  l_ccid                          NUMBER;
  l_sob                           NUMBER;

BEGIN

  /* find set of book id and code combination id from distribution */

  SELECT code_combination_id, set_of_books_id
  INTO l_ccid, l_sob
  FROM po_req_distributions_all
  WHERE distribution_id= distributionId;

  /* find chart of account id from set of book */
  SELECT chart_of_accounts_id
  INTO l_chart_of_accounts_id
  FROM gl_sets_of_books
  WHERE set_of_books_id = l_sob;

  /* get the all the segment array */
  l_result := FND_FLEX_EXT.GET_SEGMENTS(
                                      'SQLGL',
                                      'GL#',
                                      l_chart_of_accounts_id,
                                      l_ccid,
                                      l_num_segments,
                                      l_segments);

  IF (NOT l_result) THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  /* get the segment number for the given segment name */
  l_result := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                    101,
                                    'GL#',
                                    l_chart_of_accounts_id,
                                    segmentName,
                                    l_segment_num);

  IF (NOT l_result) THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  l_seg_val := l_segments(l_segment_num);

  RETURN l_seg_val;
EXCEPTION
  when others then
    -- TODO: log error
  raise;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_changed_req_total
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the requisition total, which includes requester changes.
--Parameters:
--IN:
--reqHeaderId
--  Requisition Header ID
--OUT:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_changed_req_total(ReqHeaderId IN NUMBER)
RETURN NUMBER IS
  l_req_total NUMBER := 0;
  l_org_id po_requisition_headers_all.org_id%TYPE;

BEGIN
  select org_id
  into l_org_id
  from po_requisition_headers_all
  where requisition_header_id = ReqHeaderId;

  IF l_org_id is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>
  END IF;

  SELECT sum(po_calculatereqtotal_pvt.get_req_distribution_total(
              PORL.requisition_header_id,PORL.requisition_line_id,
              PORD.distribution_id))
  into l_req_total
  FROM
       PO_REQ_DISTRIBUTIONS_ALL PORD,  -- <R12 MOAC>
       PO_REQUISITION_LINES PORL
  WHERE  PORL.requisition_header_id = ReqHeaderId
         AND    PORL.requisition_line_id = PORD.requisition_line_id
         AND    nvl(PORL.cancel_flag, 'N') = 'N'
         AND    nvl(PORL.modified_by_agent_flag, 'N') = 'N';

  return l_req_total;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_new_req_header_id
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Given a requisition header ID, this function first identifies if there a working copy for this requisition
--  If yes then return the working copy's requisition header ID
--  Otherewise, return the input requisition header ID.
--Parameters:
--IN:
--oldReqHeaderId
--  Requisition Header ID
--OUT:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
function get_new_req_header_id (oldReqHeaderId IN  NUMBER) return number IS

  l_api_name varchar2(50):= 'get_new_req_header_id';
  reqNumber  po_requisition_headers.segment1%TYPE;
  orgId po_requisition_headers.org_id%TYPE;
  newReqHeaderId po_requisition_headers.requisition_header_id%TYPE;
  newReqNumber  varchar2(30);

begin
  select segment1, org_id  into reqNumber, orgId
  from po_requisition_headers_all
  where requisition_header_id =  oldReqHeaderId;

  newReqNumber := '##' || reqNumber;

  begin
    select requisition_header_id into newReqHeaderId
    from po_requisition_headers_all
    where segment1 = newReqNumber
      and org_id = orgId ;  -- <R12 MOAC>
    exception
      when NO_DATA_FOUND then
      return oldReqHeaderId;
  end;
  return newReqHeaderId;

exception
  when others then
    if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, 'icx.plsql.PO_AME_SETUP_PVT' ||
                      l_api_name || '.others_exception', sqlerrm);
      END IF;
    end if;
    raise;
end;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_system_approver_mandatory
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns value based on profile POR_SYS_GENERATED_APPROVERS_MANDATORY.
--Parameters:
--IN:
--reqHeaderId
--  Requisition Header ID
--OUT:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_system_approver_mandatory(reqHeaderId IN NUMBER)
RETURN VARCHAR2 IS
  l_user_id fnd_user.user_id%TYPE;
  l_option_value fnd_profile_option_values.profile_option_value%TYPE;

BEGIN

l_option_value:= fnd_profile.VALUE_SPECIFIC('POR_SYS_GENERATED_APPROVERS_SUPPRESS');

     if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, 'icx.plsql.PO_AME_SETUP_PVT.is_system_approver_mandatory','suppress l_option_value=' ||
                      l_option_value );
      END IF;
     END IF;

if l_option_value = 'Y' then
 RETURN 'N';
end if;

  BEGIN
    SELECT fu.user_id
    INTO l_user_id
    FROM fnd_user fu, po_requisition_headers_all prh
    WHERE prh.requisition_header_id = reqHeaderId and
          prh.preparer_id = fu.employee_id;
  EXCEPTION
    when others then
      fnd_profile.get('POR_SYS_GENERATED_APPROVERS_MANDATORY', l_option_value);
     if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, 'icx.plsql.PO_AME_SETUP_PVT.is_system_approver_mandatory',' l_option_value=' ||
                      l_option_value );
      END IF;
     END IF;

      RETURN l_option_value;

  END;
  l_option_value := fnd_profile.value_specific('POR_SYS_GENERATED_APPROVERS_MANDATORY', l_user_id);
       if g_fnd_debug = 'Y' then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.level_statement, '2 icx.plsql.PO_AME_SETUP_PVT.is_system_approver_mandatory',' l_option_value=' ||
                      l_option_value );
      END IF;
         END IF;
  RETURN l_option_value;

EXCEPTION
  when others then
  RETURN 'Y';
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: can_preparer_approve
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns 'Y' if preparer can approve requisition;
--  Returns 'N'  if  preparer cannot approve requisition;
--          based on po document set up.
--Parameters:
--IN:
--reqHeaderId
--  Requisition Header ID
--OUT:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION can_preparer_approve(reqHeaderId IN NUMBER)
RETURN VARCHAR2 IS
  l_can_approve po_document_types_all_b.can_preparer_approve_flag%TYPE;

BEGIN
  SELECT NVL(pdt.can_preparer_approve_flag, 'N')
  INTO l_can_approve
  FROM po_document_types_all_b pdt, po_requisition_headers_all prh
  WHERE prh.requisition_header_id = reqHeaderId and
          pdt.org_id = prh.org_id and        -- <R12 MOAC>
          prh.type_lookup_code = pdt.document_subtype and
          pdt.DOCUMENT_TYPE_CODE='REQUISITION';

  RETURN l_can_approve;
EXCEPTION
  when others then
    RETURN 'N';
END;

/*AME Project Start*/
--------------------------------------------------------------------------------
--Start of Comments
--Name: can_preparer_approve_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns 'Y' if preparer can approve PO;
--  Returns 'N'  if  preparer cannot approve PO;
--          based on po document set up.
--Parameters:
--IN:
--ameApprovalId
--  AME Approval ID
--OUT:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION can_preparer_approve_po(ameApprovalId IN NUMBER)
RETURN VARCHAR2 IS
  l_can_approve po_document_types_all_b.can_preparer_approve_flag%TYPE;

BEGIN
  SELECT NVL(pdt.can_preparer_approve_flag, 'N')
  INTO l_can_approve
  FROM po_document_types_all_b pdt, po_headers_merge_v phm
  WHERE phm.ame_approval_id = ameApprovalId and
          pdt.org_id = phm.org_id and        -- <R12 MOAC>
          phm.type_lookup_code = pdt.document_subtype and
          pdt.DOCUMENT_TYPE_CODE in ('PO','PA');

  RETURN l_can_approve;
EXCEPTION
  when others then
    RETURN 'N';
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_system_approver_mandatory_for_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns value based on profile POR_SYS_GENERATED_APPROVERS_MANDATORY.
--Parameters:
--IN:
--ameApprovalId
--  AME Approval ID
--OUT:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_system_app_mandatory_po(ameApprovalId IN NUMBER)
RETURN VARCHAR2 IS
  l_user_id fnd_user.user_id%TYPE;
  l_option_value fnd_profile_option_values.profile_option_value%TYPE;

BEGIN

l_option_value:= fnd_profile.VALUE_SPECIFIC('PO_SYS_GENERATED_APPROVERS_SUPPRESS');

if l_option_value = 'Y' then
 RETURN 'N';
end if;

  BEGIN
    SELECT fu.user_id
    INTO l_user_id
    FROM fnd_user fu, po_headers_merge_v phm
    WHERE phm.ame_approval_id = ameApprovalId and
          phm.agent_id = fu.employee_id;
  EXCEPTION
    when others then
      fnd_profile.get('PO_SYS_GENERATED_APPROVERS_MANDATORY', l_option_value);
      RETURN l_option_value;

  END;
  l_option_value := fnd_profile.value_specific('PO_SYS_GENERATED_APPROVERS_MANDATORY', l_user_id);

  RETURN l_option_value;

EXCEPTION
  when others then
  RETURN 'Y';
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_function_currency_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the function currency of PO preparing org
--Parameters:
--IN:
--ameApprovalId
--  AME Approval ID
--OUT:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_function_currency_po(ameApprovalId IN NUMBER)
RETURN VARCHAR2 IS
  l_currency_code gl_sets_of_books.currency_code%TYPE;

BEGIN
  SELECT gls.currency_code
  INTO l_currency_code
  FROM financials_system_params_all fsp,
       gl_sets_of_books gls,
       po_headers_merge_v phm
  WHERE fsp.set_of_books_id = gls.set_of_books_id and
        fsp.org_id = phm.org_id and       -- <R12 MOAC>
        phm.ame_approval_id = ameApprovalId;
  RETURN l_currency_code;
EXCEPTION
  when others then
  raise;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_accounting_flex_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the accounting flex segment's value for a distribution segment
--Parameters:
--IN:
--segmentName
--  Segment name
--distributionId
--  PO distribution ID
--draftId
-- PO Draft Id
--OUT:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_accounting_flex_po(segmentName IN VARCHAR2, distributionId IN NUMBER, draftId IN NUMBER)
RETURN VARCHAR2 IS

  l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
  l_result                        BOOLEAN;
  l_chart_of_accounts_id          NUMBER;
  l_num_segments                  NUMBER;
  l_segment_num                   NUMBER;
  l_segment_delimiter             VARCHAR2(1);
  l_seg_val                       VARCHAR2(50);
  l_ccid                          NUMBER;
  l_sob                           NUMBER;

 /* Bug 18438758:  For 12.1.1 draft id is default null but not -1 for non mod PO
    Need to add nvl to draft_id.
 */
  cursor c2(l_distribution_id	in NUMBER, l_draft_id in NUMBER) is SELECT code_combination_id, set_of_books_id
                FROM po_distributions_merge_v
                WHERE po_distribution_id= l_distribution_id
                AND nvl(draft_id,-1) = l_draft_id;

BEGIN

  /* find set of book id and code combination id from distribution */

  open c2(distributionId, draftId);
  fetch c2 into l_ccid, l_sob;
  close c2;

  /* find chart of account id from set of book */
  SELECT chart_of_accounts_id
  INTO l_chart_of_accounts_id
  FROM gl_sets_of_books
  WHERE set_of_books_id = l_sob;

  /* get the all the segment array */
  l_result := FND_FLEX_EXT.GET_SEGMENTS(
                                      'SQLGL',
                                      'GL#',
                                      l_chart_of_accounts_id,
                                      l_ccid,
                                      l_num_segments,
                                      l_segments);

  IF (NOT l_result) THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  /* get the segment number for the given segment name */
  l_result := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                    101,
                                    'GL#',
                                    l_chart_of_accounts_id,
                                    segmentName,
                                    l_segment_num);

  IF (NOT l_result) THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  l_seg_val := l_segments(l_segment_num);

  RETURN l_seg_val;
EXCEPTION
  when others then
    -- TODO: log error
  raise;
END get_accounting_flex_po;

/*AME Project End*/

/*Bug 16775048*/
/*Function to return the transaction requester person id*/
/*Bug 18398358: remove the codition object_type_code   = 'PO'
  as this function is used by BPA and CPA too.
 */
FUNCTION get_trans_req_person_id(ameApprovalId IN NUMBER)
RETURN NUMBER IS
  l_employee_id NUMBER;
BEGIN
  BEGIN
    SELECT employee_id
    INTO l_employee_id
    FROM po_action_history poah,
      po_headers_all poh
    WHERE poah.object_sub_type_code = poh.type_lookup_code
    AND poah.object_id            = poh.po_header_id
    AND poh.ame_approval_id       = ameApprovalId
    AND poah.object_revision_num  = poh.revision_num
    AND poah.action_code          = 'SUBMIT'
    AND poah.sequence_num         =
      (SELECT MAX(poah1.sequence_num)
      FROM po_action_history poah1
      WHERE poah1.object_type_code   = poah.object_type_code
      AND poah1.object_sub_type_code = poah.object_sub_type_code
      AND poah1.object_id            = poah.object_id
      AND poah1.object_revision_num  = poah.object_revision_num
      AND poah1.action_code          = 'SUBMIT'
      );
  EXCEPTION
  WHEN OTHERS THEN
    l_employee_id := fnd_global.employee_id;
  END;
  RETURN l_employee_id;
END get_trans_req_person_id;
/*<end> Bug 16775048*/


END PO_AME_SETUP_PVT;

/
