--------------------------------------------------------
--  DDL for Package Body OKE_CHG_REQ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CHG_REQ_UTILS" AS
/* $Header: OKECRQUB.pls 120.1 2005/06/24 10:40:36 ausmani noship $ */
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
( P_Calling_Mode         IN  VARCHAR2
, P_K_Header_ID          IN  NUMBER
, P_Chg_Request_ID       IN  NUMBER
, P_Chg_Request_Num      IN  VARCHAR2
, P_Requested_By         IN  NUMBER
, P_Effective_Date       IN  DATE
, P_Old_Status_Code      IN  VARCHAR2
, P_New_Status_Code      IN  VARCHAR2
, P_Chg_Type_Code        IN  VARCHAR2
, P_Chg_Reason_Code      IN  VARCHAR2
, P_Impact_Funding_flag  IN  VARCHAR2
, P_Description          IN  VARCHAR2
, P_Chg_Text             IN  VARCHAR2
, P_Updated_By           IN  NUMBER
, P_Update_Date          IN  DATE
, P_Login_ID             IN  NUMBER
, X_Chg_Log_ID           IN OUT NOCOPY NUMBER
, X_Approve_Date         IN OUT NOCOPY DATE
, X_Implement_Date       IN OUT NOCOPY DATE
) IS

  CURSOR sts IS
    SELECT wf_item_type
    ,      wf_process
    FROM   oke_chg_statuses_b
    WHERE  chg_status_code = P_New_Status_Code;

  CURSOR kh IS
    SELECT k.k_number_disp
    ,      k.k_type_code
    ,      kt.k_type_name
    ,      k.authoring_org_id
    FROM   oke_k_headers_v k
    ,      oke_k_types_vl kt
    WHERE  k_header_id = P_K_Header_ID
    AND    kt.k_type_code = k.k_type_code;

  CURSOR req IS
    SELECT u.user_name
    FROM   per_all_people_f p
    ,      fnd_user u
    WHERE  person_id = P_Requested_By
    AND    u.employee_id = p.person_id;

  CURSOR cs ( C_Status_Code VARCHAR2 ) IS
    SELECT chg_status_type_code
    FROM   oke_chg_statuses_b
    WHERE  chg_status_code = C_Status_Code;

  l_wf_item_type   VARCHAR2(8)   := NULL;
  l_wf_process     VARCHAR2(30)  := NULL;
  l_wf_item_key    VARCHAR2(240) := NULL;
  l_wf_user_key    VARCHAR2(240) := NULL;
  l_contract_num   VARCHAR2(240);
  l_k_type         VARCHAR2(80);
  l_k_type_code    VARCHAR2(30);
  l_requestor_name VARCHAR2(240);
  l_old_ststype    VARCHAR2(30);
  l_new_ststype    VARCHAR2(30);
  l_org_id         NUMBER(10);

BEGIN
  --
  -- Fetch Workflow information from Change Status
  --
  OPEN sts;
  FETCH sts INTO l_wf_item_type , l_wf_process;
  CLOSE sts;

  --
  -- Get the change log ID; this also serves as the WF Item Key
  --
  SELECT oke_chg_logs_s.nextval
  INTO   X_Chg_Log_ID
  FROM   dual;

  IF ( l_wf_item_type IS NOT NULL and l_wf_process IS NOT NULL) THEN
    --
    -- Fetch relevant information
    --
    OPEN kh;
    FETCH kh INTO l_contract_num , l_k_type_code , l_k_type,l_org_id;
    CLOSE kh;

    OPEN req;
    FETCH req INTO l_requestor_name;
    CLOSE req;

    l_wf_item_key := X_Chg_Log_ID;

    l_wf_user_key := l_Contract_Num || '-' ||
                     P_Chg_Request_Num || '-' ||
                     P_New_Status_Code || '-' ||
                     TO_CHAR(sysdate,'YYMMDD:HH24MISS');

    WF_ENGINE.CreateProcess( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , process  => l_wf_process );

    WF_ENGINE.SetItemOwner ( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , owner    => FND_GLOBAL.User_Name );

    WF_ENGINE.SetItemUserKey( itemtype => l_wf_item_type
                            , itemkey  => l_wf_item_key
                            , userkey  => l_wf_user_key );

    --
    -- Setting various Workflow Item Attributes
    --
    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_TYPE'
                             , avalue   => l_k_type );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_TYPE_CODE'
                             , avalue   => l_k_type_code );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_NUMBER'
                             , avalue   => l_Contract_Num );

    WF_ENGINE.SetItemAttrNumber( itemtype => l_wf_item_type
                               , itemkey  => l_wf_item_key
                               , aname    => 'CHG_REQUEST_ID'
                               , avalue   => P_Chg_Request_ID );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'CHG_REQUEST_NUM'
                             , avalue   => P_Chg_Request_Num );

    WF_ENGINE.SetItemAttrNumber( itemtype => l_wf_item_type
                               , itemkey  => l_wf_item_key
                               , aname    => 'ORG_ID'
                               , avalue   => l_org_id );

    WF_ENGINE.SetItemAttrDate( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'EFFECTIVE_DATE'
                             , avalue   => P_Effective_Date );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'IMPACT_FUNDING_FLAG'
                             , avalue   => P_Impact_Funding_flag );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'CHG_TYPE_CODE'
                             , avalue   => P_Chg_Type_Code );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'CHG_REASON_CODE'
                             , avalue   => P_Chg_Reason_Code );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'NEW_STATUS_CODE'
                             , avalue   => P_New_Status_Code );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'OLD_STATUS_CODE'
                             , avalue   => P_Old_Status_Code );

    WF_ENGINE.SetItemAttrNumber( itemtype => l_wf_item_type
                               , itemkey  => l_wf_item_key
                               , aname    => 'K_HEADER_ID'
                               , avalue   => P_K_Header_ID );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'LAST_UPDATED_BY'
                             , avalue   => P_Updated_by );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'REQUESTOR'
                             , avalue   => L_requestor_name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DESCRIPTION'
                             , avalue   => P_Description );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'CHG_TEXT'
                             , avalue   => P_Chg_Text );

    --
    -- Start the Workflow Process if not called from trigger
    --
    IF ( P_Calling_Mode <> 'TRIGGER' ) THEN
      WF_ENGINE.StartProcess( itemtype => l_wf_item_type
                            , itemkey  => l_wf_item_key );
    END IF;
  END IF;

  --
  -- Write record into Change Status History
  --
  INSERT INTO oke_chg_logs
  ( chg_log_id
  , chg_request_id
  , chg_status_code
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , wf_item_type
  , wf_process
  , wf_item_key )
  VALUES
  ( X_Chg_Log_ID
  , P_Chg_Request_ID
  , P_New_Status_Code
  , P_Update_Date
  , P_Updated_By
  , P_Update_Date
  , P_Updated_By
  , P_Login_ID
  , l_wf_item_type
  , l_wf_process
  , l_wf_item_key
  );

  --
  -- Setting Approval and Implement Dates if applicable
  --
  OPEN cs ( P_Old_Status_Code );
  FETCH cs INTO l_Old_StsType;
  CLOSE cs;

  OPEN cs ( P_New_Status_Code );
  FETCH cs INTO l_New_StsType;
  CLOSE cs;

  IF ( l_Old_StsType <> l_New_StsType ) THEN
    IF (   l_Old_StsType = 'SUBMITTED'
       AND l_New_StsType = 'APPROVED' ) THEN
      X_Approve_Date := P_Update_Date;
    ELSIF (   l_Old_StsType = 'IN PROGRESS'
          AND l_New_StsType = 'COMPLETED' ) THEN
      X_Implement_Date := P_Update_Date;
    END IF;
  END IF;

END Status_Change;


--
--  Name          : Get_Process_Status
--  Pre-reqs      : None
--  Function      : This procedure returns the Workflow status of
--                  a status change as stored in the history.
--
--
--  Parameters    :
--  IN            : P_CHG_LOG_ID     NUMBER
--  OUT           : X_STATUS         VARCHAR2
--                  X_RESULT         VARCHAR2
--
--  Returns       : None
--
PROCEDURE Get_Process_Status
( P_Chg_Log_ID       IN  NUMBER
, X_Status           OUT NOCOPY VARCHAR2
, X_Result           OUT NOCOPY VARCHAR2
) IS

CURSOR c IS
  SELECT WF_Item_Type
  ,      WF_Item_Key
  FROM   OKE_Chg_Logs
  WHERE  Chg_Log_ID = P_Chg_Log_ID;
crec   c%rowtype;

BEGIN
  OPEN c;
  FETCH c INTO crec;
  CLOSE c;

  IF ( crec.WF_Item_Key IS NOT NULL ) THEN

    WF_ENGINE.ItemStatus( itemtype => crec.WF_Item_Type
                        , itemkey  => crec.WF_Item_Key
                        , status   => X_Status
                        , result   => X_Result
                        );

  ELSE

    X_Status := NULL;
    X_Result := NULL;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  X_Status := NULL;
  X_Result := NULL;
END Get_Process_Status;


--
--  Name          : Update_Process
--  Pre-reqs      : None
--  Function      : This procedure suspend/resume/abort an existing
--                  workflow process
--
--
--  Parameters    :
--  IN            : P_CHG_LOG_ID     NUMBER
--                  P_MODE           VARCHAR2
--                                   - SUSPEND
--                                   - RESUME
--                                   - ABORT
--  OUT           : None
--
--  Returns       : None
--
PROCEDURE Update_Process
( P_Chg_Log_ID       IN  NUMBER
, P_Mode             IN  VARCHAR2
) IS

  CURSOR wf IS
    SELECT wf_item_type
    ,      wf_item_key
    FROM   oke_chg_logs
    WHERE  chg_log_id = P_Chg_Log_ID;
  wfrec  wf%rowtype;

  --
  -- Making this procedure as AUTONOMOUS transaction.
  --
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  OPEN wf;
  FETCH wf INTO wfrec;
  CLOSE wf;

  IF ( wfrec.wf_item_key IS NOT NULL ) THEN

    IF ( P_Mode = 'ABORT' ) THEN

      WF_ENGINE.AbortProcess( itemtype => wfrec.wf_item_type
                            , itemkey  => wfrec.wf_item_key
                            , process  => NULL
                            , result   => '#FORCE' );

    ELSIF ( P_Mode = 'SUSPEND' ) THEN

      WF_ENGINE.SuspendProcess( itemtype => wfrec.wf_item_type
                              , itemkey  => wfrec.wf_item_key
                              , process  => NULL );

    ELSIF ( P_Mode = 'RESUME' ) THEN

      WF_ENGINE.ResumeProcess( itemtype => wfrec.wf_item_type
                             , itemkey  => wfrec.wf_item_key
                             , process  => NULL );

    END IF;

  END IF;

  COMMIT;

END Update_Process;


--
--  Name          : OK_To_Implement
--  Pre-reqs      : None
--  Function      : This function checks whether there is another
--                  approved change request currently in progress
--                  or unapproved change request with an earlier
--                  effective date
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID     NUMBER
--                : X_CHG_REQUEST_ID  NUMBER
--  OUT NOCOPY           : None
--
--  Returns       : VARCHAR2
--                   Y - OK to implement
--                   W - give user warning message
--                   N - Cannot proceed
--
FUNCTION OK_To_Implement
( X_Chg_Request_ID   IN  NUMBER
) RETURN VARCHAR2 IS

  CURSOR crq IS
    SELECT CRQ2.Chg_Request_Num
    ,      CS.Chg_Status_Type_Code
    FROM   oke_chg_requests CRQ1
    ,      oke_chg_requests CRQ2
    ,      oke_chg_statuses_b CS
    WHERE  CRQ1.Chg_Request_ID = X_Chg_Request_ID
    AND    CRQ2.K_Header_ID = CRQ1.K_Header_ID
    AND    CRQ2.Chg_Request_ID <> CRQ1.Chg_Request_ID
    AND    CS.Chg_Status_Code = CRQ2.Chg_Status_Code
    AND (  CS.Chg_Status_Type_Code = 'IN PROGRESS'
        OR (   CS.Chg_Status_Type_Code NOT IN ( 'COMPLETED'
                                              , 'CANCELED' )
           AND CRQ2.Effective_Date < CRQ1.Effective_Date
           )
        )
    ORDER BY DECODE(CS.Chg_Status_Type_Code, 'IN PROGRESS' , 1 , 2);

  crqrec  crq%rowtype;

BEGIN

  OPEN crq;
  FETCH crq INTO crqrec;

  IF ( crq%notfound ) THEN
    CLOSE crq;
    RETURN ( 'Y' );
  END IF;

  CLOSE crq;

  IF ( crqrec.Chg_Status_Type_Code = 'IN PROGRESS' ) THEN
    --
    -- Another change request is in progress; cannot proceed
    --
    FND_MESSAGE.SET_NAME('OKE' , 'OKE_CHGREQ_OTHER_CRQ_IMPL');
    FND_MESSAGE.SET_TOKEN('REQNUM' , crqrec.Chg_Request_Num);
    RETURN ( 'N' );
  ELSE
    --
    -- Earlier change request exists, warn
    --
    FND_MESSAGE.SET_NAME('OKE' , 'OKE_CHGREQ_EARLY_CRQ_EXISTS');
    RETURN ( 'W' );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKE' , 'OKE_CHGREQ_IMPLCHK_ERROR');
  FND_MESSAGE.SET_TOKEN('ERROR' , sqlerrm);
  RETURN ( 'N' );

END OK_To_Implement;

--
--  Name          : OK_To_Undo
--  Pre-reqs      : None
--  Function      : This function checks whether there is another
--                  completed or in progress change request with a
--                  later effective date
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID     NUMBER
--                : X_CHG_REQUEST_ID  NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--                   Y - OK to undo
--                   W - give user warning message
--                   N - Cannot proceed
--
FUNCTION OK_To_Undo
( X_Chg_Request_ID   IN  NUMBER
) RETURN VARCHAR2 IS

  CURSOR crq IS
    SELECT COUNT(CRQ2.Chg_Request_Num) ChgReq_Count
    FROM   oke_chg_requests CRQ1
    ,      oke_chg_requests CRQ2
    ,      oke_chg_statuses_b CS
    WHERE  CRQ1.Chg_Request_ID = X_Chg_Request_ID
    AND    CRQ2.K_Header_ID = CRQ1.K_Header_ID
    AND    CRQ2.Chg_Request_ID <> CRQ1.Chg_Request_ID
    AND    CS.Chg_Status_Code = CRQ2.Chg_Status_Code
    AND    CS.Chg_Status_Type_Code IN ( 'IN PROGRESS' , 'COMPLETED' )
    AND    CRQ2.Effective_Date > CRQ1.Effective_Date;

  crqrec  crq%rowtype;

BEGIN

  OPEN crq;
  FETCH crq INTO crqrec;
  CLOSE crq;

  IF ( crqrec.ChgReq_Count = 0 ) THEN
    RETURN ( 'Y' );
  ELSE
    --
    -- Later completed change request exists, cannot proceed
    --
    FND_MESSAGE.SET_NAME('OKE' , 'OKE_CHGREQ_OTHER_CRQ_COMP');
    FND_MESSAGE.SET_TOKEN('COUNT' , crqrec.ChgReq_Count);
    RETURN ( 'N' );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKE' , 'OKE_CHGREQ_UNDOCHK_ERROR');
  FND_MESSAGE.SET_TOKEN('ERROR' , sqlerrm);
  RETURN ( 'N' );

END OK_To_Undo;


--
--  Name          : Get_Chg_Request
--  Pre-reqs      : None
--  Function      : This function returns the related Change Request
--                  Number and Change Status for the given contract
--		    either for the current version or a specific
--		    major version.
--
--
--  Parameters    :
--  IN            : X_K_Header_ID           NUMBER
--                  X_Major_Version         NUMBER
--                  X_Current_Only          VARCHAR2 DEFAULT Y
--                  X_Curr_Indicator        VARCHAR2 DEFAULT N
--  OUT           : X_Change_Request	    VARCHAR2
--		    X_Change_Status	    VARCHAR2
--  IN 	          : X_History_Use           VARCHAR2 DEFAULT N
--

PROCEDURE Get_Chg_Request
( X_K_Header_ID           IN     NUMBER
, X_Major_Version         IN     NUMBER
, X_Change_Request        OUT NOCOPY    VARCHAR2
, X_Change_Status         OUT NOCOPY    VARCHAR2
, X_History_Use           IN     VARCHAR2
) IS

L_Version_Reason_Code            OKE_K_VERS_NUMBERS_H.Version_Reason_Code%TYPE;

CURSOR c IS
  SELECT CR.Chg_Request_Num
  ,      CS.Chg_Status_Name
  ,      H.Version_Reason_Code
  FROM   oke_k_vers_numbers_h H
  ,      oke_chg_requests CR
  ,      oke_chg_statuses_tl CS
  ,    ( SELECT K_Header_ID
         ,      Chg_Request_ID
         ,      max(Major_Version) Last_Version
         FROM oke_k_vers_numbers_h
         GROUP BY K_Header_ID , Chg_Request_ID ) V
  WHERE  V.K_Header_ID = X_K_Header_ID
  AND    H.K_Header_ID = V.K_Header_ID
  AND    H.Major_Version = V.Last_Version
  AND  ( X_Major_Version IS NULL
       OR H.Major_Version <= X_Major_Version )
  AND    H.Version_Reason_Code <> 'CHGREQ_REVERT'
  AND    CR.Chg_Request_ID = H.Chg_Request_ID
  AND    CS.Chg_Status_Code = CR.Chg_Status_Code
  AND    CS.Language = userenv('LANG')
  ORDER BY H.Major_Version DESC;

BEGIN

  OPEN c;
  FETCH c INTO X_Change_Request , X_Change_Status , L_Version_Reason_Code;
  CLOSE c;

  IF (X_History_Use = 'Y' AND L_Version_Reason_Code <> 'CHGREQ_COMPLETE') THEN
    X_Change_Request := NULL;
    X_Change_Status  := NULL;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF ( c%isopen ) THEN
    CLOSE c;
  END IF;

END Get_Chg_Request;

END OKE_CHG_REQ_UTILS;

/
