--------------------------------------------------------
--  DDL for Package XXAH_BPA_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_BPA_APPROVAL_WF_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_BPA_APPROVAL_WF_PKG.pks 49 2014-12-10 15:52:58Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the approval workflow.
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 21-JAN-2011 Richard Velden    Initial version
 *
 *************************************************************************/

  PROCEDURE launch_child_flow
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  );


  PROCEDURE complete_activity
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  );


  PROCEDURE is_approval_complete ( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 );

  PROCEDURE has_next_approvers( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 );

  PROCEDURE create_addhoc_role( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 );

  PROCEDURE add_approvers_to_role( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 );


  PROCEDURE PostNtfFunction(    p_itemtype   IN varchar2,
                                p_itemkey    IN varchar2,
                                p_actid      IN number,
                                p_funcmode   IN varchar2,
                                p_resultout  IN OUT NOCOPY varchar2);

  PROCEDURE update_action_history_reject(itemtype  IN VARCHAR2
                                        ,itemkey   IN VARCHAR2
                                        ,actid     IN NUMBER
                                        ,funcmode  IN VARCHAR2
                                        ,resultout OUT NOCOPY VARCHAR2);


  PROCEDURE reset_approval( p_itemtype   IN   VARCHAR2
    , p_itemkey    IN   VARCHAR2
    , p_actid      IN   NUMBER
    , p_funcmode   IN   VARCHAR2
    , p_resultout  OUT  VARCHAR2
  );

  PROCEDURE set_transaction_details ( document_id    IN      varchar2
    , display_type   IN      varchar2
    , DOCUMENT       IN OUT  NOCOPY varchar2
    , document_type  IN OUT  NOCOPY varchar2
  );

  PROCEDURE set_transaction_details ( document_id    IN      varchar2
    , display_type   IN      varchar2
    , DOCUMENT       IN OUT  NOCOPY CLOB
    , document_type  IN OUT  NOCOPY varchar2
  );

  PROCEDURE get_attachment
  (
    document_id   IN VARCHAR2
   ,display_type  IN VARCHAR2
   ,DOCUMENT      IN OUT BLOB
   ,document_type IN OUT VARCHAR2
  );


  PROCEDURE set_attachments
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  );

  PROCEDURE check_combined
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  );

  PROCEDURE remove_hold
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  );

  /*
   * cursors needed for combined flow as well.
   */
  CURSOR c_header(b_header_id  po_headers_all.po_header_id%TYPE) IS
    SELECT h.start_date
    ,      h.end_date
    ,      h.BLANKET_TOTAL_AMOUNT
    ,      h.comments  project_description
    ,      papf.full_name buyer
    ,      P.party_name customer
    ,      h.segment1 segment1
    FROM  po_headers_all h
        , per_all_people_f papf
        , hz_parties P
        , po_vendors s
    WHERE  h.po_header_id = b_header_id
    AND    papf.person_id = h.agent_id
    AND    SYSDATE BETWEEN NVL(papf.effective_start_date, SYSDATE)
           AND NVL(papf.effective_end_date, SYSDATE+1)
    AND h.vendor_id = s.vendor_id
    AND s.party_id = p.party_id
    ;
  CURSOR c_header_details(b_header_id po_headers_all.po_header_id%TYPE) IS
    SELECT distinct h.po_header_id
                   ,h.currency_code currency
                   ,at.name payment_term
                   ,P.party_name customer
                   ,s.attribute8 vendor_check_advice
                   ,to_date(s.attribute5, 'YYYY/MM/DD HH24:MI:SS') vendor_check_date
                   ,h_from.segment1 related_contract
                   ,ppa.name || ' ' || ppa.description project_description
                   ,papf.full_name buyer
                   ,h.attribute10 unit
                   ,NVL(l.amount, l.unit_price) va_value
                   ,  (SELECT --A.pk1_value  header_id, A.entity_name
                              --,s.short_text management_sum
                              rtrim(xmlagg(xmlelement(e, s.short_text || chr(10)))
                                   .extract('//text()').extract('//text()'),
                                   ',') management_sum
                       -- aggregrates multiple elements into 1 line + chr(10) which is a newline
                       FROM fnd_attached_documents   A
                           ,fnd_documents            d
                           ,fnd_documents_short_text s
                       WHERE A.entity_name = 'PO_HEADERS'
                       AND   d.document_id = A.document_id
                       AND   d.media_id    = s.media_id
                       AND   A.pk1_value   = to_char(h.po_header_id)) management_sum
                    ,h.Attribute13 committed_value_fixed
                    ,h.Attribute6 committed_value_linear
                    ,h.Attribute15 payment_terms_days
                    ,h.Attribute14 payment_terms_percentage
                    ,hprev.segment1 previous_contract
                    ,hmoth.segment1 related_mother_contract
                    ,hdfv.foreign_currency
                    ,hdfv.amount_in_foreign_currency
    FROM po_headers_all     h
        ,po_headers_all_dfv hdfv
        ,po_headers_all     hprev
        ,po_headers_all     hmoth
        ,po_headers_all     h_from
        ,per_all_people_f   papf
        ,ap_terms           at
        ,pa_projects_all    ppa
        ,po_lines_all       l
        ,hz_parties         P
        ,ap_suppliers       s
    WHERE h.po_header_id          = b_header_id
      AND to_number(h.Attribute7) = hprev.po_header_id(+)
      AND to_number(h.Attribute9) = hmoth.po_header_id(+)
      AND h.po_header_id          = l.po_header_id
      AND h.vendor_id             = s.vendor_id
      AND papf.person_id          = h.agent_id
      AND h_from.po_header_id(+)  = h.from_header_id
      AND h.terms_id              = at.term_id
      AND l.project_id            = ppa.project_id(+)
      and l.line_num = (select max(pla.line_num)
                        from   po_lines_all pla
                        where  pla.po_header_id = h.po_header_id)
      AND s.party_id(+) = P.party_id
      AND hdfv.rowid = h.rowid
      ;
    CURSOR c_savings(b_header_id IN xxah_po_blanket_info.po_header_id%TYPE) IS
    SELECT pll.line_num line_num
    ,      savings_type||'-'||(SELECT fval.description
                               FROM   fnd_flex_value_sets fset
                               ,      fnd_flex_values_vl fval
                               WHERE  fval.flex_value_set_id = fset.flex_value_set_id
                               AND    fset.flex_value_set_name = 'XXAH_SAVING_TYPES'
                               AND    fval.flex_value = xbi.savings_type) savings_type
    ,      opco opco
    ,      year year
    ,      SUM(estimated_savings) estimated_savings
    , (SELECT CATEGORY_CONCAT_SEGMENTS
        FROM MTL_CATEGORY_SET_VALID_CATS_V
        WHERE CATEGORY_SET_name='PO Item Category'
        AND category_id = pll.category_id
      ) category
    FROM xxah_po_blanket_info xbi
    ,    po_lines_all pll
    ,   po_headers_all ph
    WHERE pll.po_header_id = xbi.po_header_id
    AND  ph.po_header_id = pll.po_header_id
    AND   pll.po_line_id = xbi.po_line_id
    AND   xbi.po_header_id = b_header_id
    GROUP BY GROUPING SETS ( (pll.line_num, pll.category_id, savings_type, opco, year), (savings_type) )
    ORDER BY xbi.savings_type, pll.category_id, xbi.opco, xbi.year
    ;

END XXAH_BPA_APPROVAL_WF_PKG;

/
