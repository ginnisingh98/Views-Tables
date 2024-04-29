--------------------------------------------------------
--  DDL for Package Body XXAH_OKC_CONTRACT_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_OKC_CONTRACT_CHECK_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_OKC_CONTRACT_CHECK_PKG.plb 01 2010-04-13 10:33:00Z kbouwmee $
 * DESCRIPTION  : <Description of purpose in life for package>
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 13-APR-2010 Kevin Bouwmeester Genesis
 *************************************************************************/

-- ----------------------------------------------------------------------
-- Private types
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Private constants
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Private variables
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Private cursors
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Private exceptions
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Forward declarations
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Private subprograms
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Public subprograms
-- ----------------------------------------------------------------------
  PROCEDURE check_contract
  ( p_itemtype  IN VARCHAR2
  , p_itemkey   IN VARCHAR2
  , p_actid     IN NUMBER
  , p_funcmode  IN VARCHAR2
  , p_resultout IN OUT NOCOPY VARCHAR2
  ) AS

    CURSOR c_contract_parties
    ( b_contract_id OKC_REP_CONTRACTS_ALL.contract_id%TYPE
    , b_contract_version OKC_REP_CONTRACTS_ALL.CONTRACT_VERSION_NUM%TYPE)
    IS
    SELECT   c.contract_id
    ,        COUNT(p.party_id) parties
    FROM     OKC_REP_CONTRACTS_ALL c
    LEFT OUTER
    JOIN     okc_rep_contract_parties p ON (c.contract_id = p.contract_id)
    WHERE    c.contract_id          = b_contract_id
    AND      c.contract_version_num = b_contract_version
    GROUP BY c.contract_id
    ;

    CURSOR c_contract_risks
    ( b_contract_id OKC_REP_CONTRACTS_ALL.contract_id%TYPE
    , b_contract_version OKC_REP_CONTRACTS_ALL.CONTRACT_VERSION_NUM%TYPE)
    IS
    SELECT   c.contract_id
    ,        COUNT(r.risk_event_id) risks
    FROM     OKC_REP_CONTRACTS_ALL c
    LEFT OUTER
    JOIN     OKC_CONTRACT_RISKS r ON (c.contract_id = r.business_document_id
                                  AND c.contract_version_num = DECODE(r.business_document_version, -99, c.contract_version_num, r.business_document_version))
    WHERE    c.contract_id = b_contract_id
    AND      c.contract_version_num = b_contract_version
    GROUP BY c.contract_id
    ;

    CURSOR c_contract_docs
    ( b_contract_id      OKC_REP_CONTRACTS_ALL.contract_id%TYPE
    , b_contract_version OKC_REP_CONTRACTS_ALL.CONTRACT_VERSION_NUM%TYPE)
    IS
    SELECT   c.contract_id
    ,        COUNT(d.attached_document_id) docs
    FROM     OKC_REP_CONTRACTS_ALL c
    LEFT OUTER
    JOIN     okc_contract_docs d ON (c.contract_id = d.business_document_id
                                 AND c.contract_version_num = DECODE(d.business_document_version, -99, c.contract_version_num, d.business_document_version))
    WHERE    c.contract_id          = b_contract_id
    AND      c.contract_version_num = b_contract_version
    GROUP BY c.contract_id
    ;

    -- record types for cursors
    r_contract_parties c_contract_parties%ROWTYPE;
    r_contract_risks c_contract_risks%ROWTYPE;
    r_contract_docs c_contract_docs%ROWTYPE;

    l_contract_id    NUMBER;
    l_version_num    NUMBER;
    l_result_parties BOOLEAN := TRUE;
    l_result_risks   BOOLEAN := TRUE;
    l_result_docs    BOOLEAN := TRUE;

    l_notification_text VARCHAR2(240);

    gc_true  CONSTANT VARCHAR2(3) := 'T';
    gc_false CONSTANT VARCHAR2(3) := 'F';

  BEGIN
    l_contract_id := wf_engine.GetActivityAttrNumber(itemtype      => p_itemtype
                                                 , itemkey          => p_itemkey
                                                 , actid            => p_actid
                                                 , aname            => 'XXAH_CONTRACT_ID'
                                                 , ignore_notfound  => TRUE);

    l_version_num := wf_engine.GetActivityAttrNumber(itemtype      => p_itemtype
                                                 , itemkey          => p_itemkey
                                                 , actid            => p_actid
                                                 , aname            => 'XXAH_CONTRACT_VERSION'
                                                 , ignore_notfound  => TRUE);

    -- Check A: number of parties
    OPEN  c_contract_parties(l_contract_id, l_version_num);
    FETCH c_contract_parties INTO r_contract_parties;
    CLOSE c_contract_parties;

    IF r_contract_parties.parties < 3 THEN
      l_notification_text := l_notification_text || '* At least 3 parties : FAILED (found: ' ||  r_contract_parties.parties || ')' || chr(10);
      l_result_parties  := FALSE;
    ELSE
      l_notification_text := l_notification_text || '* At least 3 parties : OK' || chr(10);
    END IF;

    -- Check B: number of risks
    OPEN  c_contract_risks(l_contract_id, l_version_num);
    FETCH c_contract_risks INTO r_contract_risks;
    CLOSE c_contract_risks;

    IF r_contract_risks.risks < 1 THEN
      l_notification_text := l_notification_text || '* At least 1 risks : FAILED (found: ' ||  r_contract_risks.risks || ')' || chr(10);
      l_result_risks  := FALSE;
    ELSE
      l_notification_text := l_notification_text || '* At least 1 risks : OK' || chr(10);
    END IF;

    -- Check C: number of PDF attachments
    OPEN  c_contract_docs(l_contract_id, l_version_num);
    FETCH c_contract_docs INTO r_contract_docs;
    CLOSE c_contract_docs;

    IF r_contract_docs.docs < 1 THEN
      l_notification_text := l_notification_text || '* At least 1 PDF document : FAILED (found: ' ||  r_contract_docs.docs || ')' || chr(10);
      l_result_docs  := FALSE;
    ELSE
      l_notification_text := l_notification_text || '* At least 1 PDF document : OK' || chr(10);
    END IF;

    -- return result boolean
    IF NOT l_result_parties
    OR NOT l_result_risks
    OR NOT l_result_docs
    THEN
      -- fill notification text
      wf_engine.SetItemAttrText( itemtype => p_itemtype
                               , itemkey  => p_itemkey
                               , aname    => 'XXAH_NOTIFICATION_TEXT'
                               , avalue   => l_notification_text);

      p_resultout := gc_false;
    ELSE
      p_resultout := gc_true;
    END IF;

  END check_contract;

END XXAH_OKC_CONTRACT_CHECK_PKG;

/
