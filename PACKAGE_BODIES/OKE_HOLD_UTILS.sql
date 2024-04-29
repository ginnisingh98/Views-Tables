--------------------------------------------------------
--  DDL for Package Body OKE_HOLD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_HOLD_UTILS" AS
/* $Header: OKEHLDUB.pls 120.2 2005/06/30 14:08:05 ausmani noship $ */
--
--  Name          : Status_Change
--  Pre-reqs      : None
--  Function      : This procedure performs utility functions during
--                  a change request status change.
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : None
--

PROCEDURE Status_Change
( P_Hold_ID          IN  NUMBER
, P_K_Header_ID      IN  NUMBER
, P_K_Line_ID        IN  NUMBER
, P_DTS_ID           IN  NUMBER
, P_Hold_Type_Code   IN  VARCHAR2
, P_Hold_Reason_Code IN  VARCHAR2
, P_Remove_Reason_Code IN  VARCHAR2
, P_Old_Status_Code  IN  VARCHAR2
, P_New_Status_Code  IN  VARCHAR2
, P_Updated_By       IN  NUMBER
, P_Update_Date      IN  DATE
, P_Login_ID         IN  NUMBER
) IS

  CURSOR sts IS
    SELECT wf_item_type
    ,      wf_process
    ,      hold_status_name
    FROM   oke_hold_statuses_vl
    WHERE  hold_status_code = P_New_Status_Code;

  CURSOR old_sts IS
    SELECT hold_status_name
    FROM   oke_hold_statuses_vl
    WHERE  hold_status_code = P_Old_Status_Code;

  CURSOR hold_reason IS
    SELECT meaning
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type      = 'APPLY_HOLD_REASON'
      AND  lookup_code      = P_Hold_reason_Code;

  CURSOR remove_reason IS
    SELECT meaning
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type      = 'REMOVE_HOLD_REASON'
      AND  lookup_code      = P_Remove_reason_Code;

  CURSOR hold_type IS
    SELECT meaning
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type      = 'HOLD_TYPE'
      AND  lookup_code      = P_Hold_type_Code;

  CURSOR o IS
    SELECT user_name
    FROM   fnd_user
    WHERE  user_id = P_Updated_By;

  CURSOR kh IS
    SELECT H.k_number_disp    k_number
    ,      T.k_type_name      k_type
    ,      hdr.org_id           org_id
    FROM   oke_k_headers        H
    ,      oke_k_types_vl       T
    ,      okc_k_headers_all_B    HDR
    WHERE  H.k_header_id = P_K_Header_ID
    AND    T.k_type_code = H.k_type_code
    AND    H.k_header_id = HDR.ID;

  CURSOR kl IS
    SELECT L.line_number
    FROM   okc_k_lines_b L
    WHERE  L.id = P_K_Line_ID;

  CURSOR kd IS
    SELECT D.deliverable_num
    FROM   oke_k_deliverables_b D
    ,      okc_k_lines_b L
    WHERE  D.deliverable_id = P_dts_ID
    AND    L.id = D.K_Line_ID;

--  CURSOR kadmin IS
--    SELECT R.name
--    FROM   oke_k_all_access_v A
--    ,      wf_roles R
--    WHERE  A.k_header_id = P_K_Header_ID
--    AND    A.role_id = 701 /* Contract Administrator */
--    AND    sysdate BETWEEN A.START_DATE_ACTIVE AND NVL(A.END_DATE_ACTIVE , sysdate + 1)
--    AND    R.ORIG_SYSTEM = 'PER'
--    AND    R.ORIG_SYSTEM_ID = A.PERSON_ID
--    ORDER BY DECODE( assignment_level , 'SITE' , 0 , 'OKE_PROGRAMS' , 1 , 2 ) DESC;

  l_wf_item_type   VARCHAR2(8)   := NULL;
  l_wf_process     VARCHAR2(30)  := NULL;
  l_wf_item_key    VARCHAR2(240) := NULL;
  l_wf_user_key    VARCHAR2(240) := NULL;
  l_wf_threshold   NUMBER;
  l_org_id   NUMBER;
  l_user_name      VARCHAR2(30);
  l_admin_name     VARCHAR2(30);
  l_contract_num   VARCHAR2(150);
  l_line_num       VARCHAR2(150);
  l_dts_num        VARCHAR2(150);
  l_k_type         VARCHAR2(150);
  l_new_status     VARCHAR2(150);
  l_old_status     VARCHAR2(150);
  l_hold_reason    VARCHAR2(150);
  l_remove_reason  VARCHAR2(150);
  l_hold_type      VARCHAR2(150);

BEGIN

  OPEN sts;
  FETCH sts INTO l_wf_item_type , l_wf_process , l_new_status;
  CLOSE sts;

  IF ( l_wf_item_type IS NOT NULL and l_wf_process IS NOT NULL) THEN

    OPEN old_sts;
    FETCH old_sts INTO l_old_status;
    CLOSE old_sts;

    OPEN hold_reason;
    FETCH hold_reason INTO l_hold_reason;
    CLOSE hold_reason;

    OPEN remove_reason;
    FETCH remove_reason INTO l_remove_reason;
    CLOSE remove_reason;

    OPEN hold_type;
    FETCH hold_type INTO l_hold_type;
    CLOSE hold_type;

    OPEN o;
    FETCH o INTO l_user_name;
    CLOSE o;

    OPEN kh;
    FETCH kh INTO l_contract_num , l_k_type,l_org_id;
    CLOSE kh;

    IF ( P_K_Line_ID IS NOT NULL ) THEN
      OPEN kl;
      FETCH kl INTO l_line_num;
      CLOSE kl;
    END IF;

    IF ( P_DTS_ID IS NOT NULL ) THEN
      OPEN kd;
      FETCH kd INTO l_dts_num;
      CLOSE kd;
    END IF;

--    OPEN kadmin;
--    FETCH kadmin INTO l_admin_name;
--    CLOSE kadmin;
    l_admin_name := OKE_UTILS.Retrieve_WF_Role_Name(P_K_Header_ID,701);

    l_wf_item_key := P_Hold_ID || '-' ||
                     P_New_Status_Code || '-' ||
                     TO_CHAR(sysdate,'YYYYMMDDHH24MISS');

    l_wf_user_key := l_Contract_Num || '-' ||
                     P_Hold_ID || '-' ||
                     P_New_Status_Code || '-' ||
                     TO_CHAR(sysdate,'YYYYMMDDHH24MISS');

    WF_ENGINE.CreateProcess( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , process  => l_wf_process );

    WF_ENGINE.SetItemOwner ( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , owner    => l_user_name );

    WF_ENGINE.SetItemUserKey( itemtype => l_wf_item_type
                            , itemkey  => l_wf_item_key
                            , userkey  => l_wf_user_key );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_TYPE'
                             , avalue   => l_k_type );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_NUMBER'
                             , avalue   => l_Contract_Num );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'LINE_NUMBER'
                             , avalue   => l_Line_Num );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DTS_NUMBER'
                             , avalue   => l_DTS_Num );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'HOLD_TYPE'
                             , avalue   => l_Hold_Type );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'HOLD_REASON'
                             , avalue   => l_Hold_Reason );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'REMOVE_REASON'
                             , avalue   => l_Remove_Reason );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'OLD_STATUS'
                             , avalue   => l_old_status );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'NEW_STATUS'
                             , avalue   => l_new_status );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'NEW_STATUS_CODE'
                             , avalue   => P_New_Status_Code );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'OLD_STATUS_CODE'
                             , avalue   => P_Old_Status_Code );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'K_HEADER_ID'
                             , avalue   => P_K_Header_ID );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'K_LINE_ID'
                             , avalue   => P_K_Line_ID );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DTS_ID'
                             , avalue   => P_DTS_ID );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'HOLD_ID'
                             , avalue   => P_Hold_ID );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'LAST_UPDATED_BY'
                             , avalue   => P_Updated_by );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'REQUESTOR'
                             , avalue   => l_user_name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ADMINISTRATOR'
                             , avalue   => l_admin_name );

    WF_ENGINE.SetItemAttrNumber( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ORG_ID'
                             , avalue   => l_org_id );

    WF_ENGINE.StartProcess( itemtype => l_wf_item_type
                          , itemkey  => l_wf_item_key );

  END IF;

END Status_Change;


END OKE_HOLD_UTILS;

/
