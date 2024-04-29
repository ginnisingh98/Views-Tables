--------------------------------------------------------
--  DDL for Package Body OKE_CHG_REQUESTS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CHG_REQUESTS_WF" AS
/* $Header: OKEWCRQB.pls 120.0 2005/05/25 17:58:27 appldev noship $ */

--
-- Private Functions and Procedures
--
FUNCTION Emp_To_UserName ( Emp_ID  NUMBER )
RETURN VARCHAR2 IS

CURSOR c IS
  SELECT User_Name
  FROM   fnd_user
  WHERE  employee_id = Emp_ID;
UserName  VARCHAR2(80);

BEGIN

  OPEN c;
  FETCH c INTO UserName;
  CLOSE c;

  RETURN ( UserName );

END Emp_To_UserName;


FUNCTION Default_Chg_Status ( StsTypeCode  VARCHAR2 )
RETURN VARCHAR2 IS

CURSOR c IS
  SELECT Chg_Status_Code
  FROM   oke_chg_statuses_b
  WHERE  Chg_Status_Type_Code = StsTypeCode
  AND    Default_Status = 'Y';
Status   VARCHAR2(30);

BEGIN

  OPEN c;
  FETCH c INTO Status;
  CLOSE c;

  RETURN ( Status );

END Default_Chg_Status;

--
-- Public Functions and Procedures
--

--
--  Name          : Initialize
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure initializes the remaining of the item
--                  attributes not set during launch
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

  CURSOR sts ( C_Chg_Status_Code  VARCHAR2 ) IS
    SELECT chg_status_name
    FROM   oke_chg_statuses_vl
    WHERE  chg_status_code = C_Chg_Status_Code;

  CURSOR lu
  ( C_Lookup_Type   VARCHAR2
  , C_Lookup_Code   VARCHAR2
  , C_View_Appl_ID  NUMBER ) IS
    SELECT meaning
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type         = C_Lookup_Type
    AND    lookup_code         = C_Lookup_Code
    AND    view_application_id = C_View_Appl_ID;

--  CURSOR kadmin ( C_Header_ID  NUMBER ) IS
--  SELECT R.NAME
--    FROM   oke_k_all_access_v A, wf_roles R
--    WHERE  A.k_header_id = C_Header_ID
--    AND    A.role_id = 701 /* Contract Administrator */
--    AND    OKE_K_SECURITY_PKG.GET_ASSIGNMENT_DATE BETWEEN A.START_DATE_ACTIVE AND NVL(A.END_DATE_ACTIVE , OKE_K_SECURITY_PKG.GET_ASSIGNMENT_DATE + 1)
--    AND    R.ORIG_SYSTEM='PER'
--    AND    R.ORIG_SYSTEM_ID=A.PERSON_ID
--    ORDER BY DECODE( assignment_level , 'SITE' , 0 , 'OKE_PROGRAMS' , 1 , 2 ) DESC;

  ChgReason     VARCHAR2(80);
  ChgType       VARCHAR2(80);
  NewStatus     VARCHAR2(80);
  OldStatus     VARCHAR2(80);
  AdminID       NUMBER;
  AdminName     VARCHAR2(240);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    OPEN sts ( WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'OLD_STATUS_CODE') );
    FETCH sts INTO OldStatus;
    CLOSE sts;

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'OLD_STATUS'
                             , avalue   => OldStatus );

    OPEN sts ( WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'NEW_STATUS_CODE') );
    FETCH sts INTO NewStatus;
    CLOSE sts;

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'NEW_STATUS'
                             , avalue   => NewStatus );

    OPEN lu ( 'CHANGE_TYPE'
            , WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'CHG_TYPE_CODE')
            , 777);
    FETCH lu INTO ChgType;
    CLOSE lu;

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'CHG_TYPE'
                             , avalue   => ChgType );

    OPEN lu ( 'CHANGE_REASON'
            , WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'CHG_REASON_CODE')
            , 777);
    FETCH lu INTO ChgReason;
    CLOSE lu;

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'CHG_REASON'
                             , avalue   => ChgReason );

--    OPEN kadmin ( WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'K_HEADER_ID') );
--    FETCH kadmin INTO AdminName;
--    CLOSE kadmin;

      AdminName := OKE_UTILS.Retrieve_WF_Role_Name(WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'K_HEADER_ID'),701);

--    AdminName := Emp_To_UserName( AdminID );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'ADMINISTRATOR'
                             , avalue   => AdminName );

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'INITIALIZE'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Initialize;


--
--  Name          : Select_Next_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the next approver for
--                  the change request.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Select_Next_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

LastAppr       VARCHAR2(240) := NULL;
NextAppr       VARCHAR2(240) := NULL;
Requestor      VARCHAR2(240) := NULL;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN
    --
    -- Get Last Approver Information from Workflow
    --
    LastAppr := WF_Engine.GetItemAttrText
                   (ItemType , ItemKey , 'NEXT_APPROVER');

    IF ( LastAppr IS NULL ) THEN

      Requestor := WF_Engine.GetItemAttrText
                      (ItemType , ItemKey , 'REQUESTOR');
      NextAppr := WF_Engine.GetItemAttrText
                     (ItemType , ItemKey , 'ADMINISTRATOR');

      IF ( NextAppr = Requestor ) THEN
        NextAppr := NULL;
      ELSE
        NextAppr := WF_Engine.GetItemAttrText
                       (ItemType , ItemKey , 'ADMINISTRATOR');
      END IF;

    ELSE

      WF_Engine.SetItemAttrText
         (ItemType , ItemKey , 'PREV_PERFORMER' , LastAppr);
      NextAppr := NULL;

    END IF;

    IF ( NextAppr IS NULL ) THEN
      ResultOut := 'COMPLETE:F';
    ELSE
      WF_Engine.SetItemAttrText
         (ItemType , ItemKey , 'NEXT_APPROVER' , NextAppr);
      ResultOut := 'COMPLETE:T';
    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'SELECT_NEXT_APPROVER'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Select_Next_Approver;


--
--  Name          : Select_Next_Informed
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the next recipient of
--                  workflow notifications.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Select_Next_Informed
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

LastInformed       VARCHAR2(240) := NULL;
NextInformed       VARCHAR2(240) := NULL;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    LastInformed := WF_Engine.GetItemAttrText
                       (ItemType , ItemKey , 'NEXT_INFORMED');

    IF ( LastInformed IS NULL ) THEN

      NextInformed := WF_Engine.GetItemAttrText
                         (ItemType , ItemKey , 'REQUESTOR');

    ELSE

      NextInformed := NULL;

    END IF;

    IF ( NextInformed IS NULL ) THEN
      ResultOut := 'COMPLETE:F';
    ELSE
      WF_Engine.SetItemAttrText
         (ItemType , ItemKey , 'NEXT_INFORMED' , NextInformed );
      ResultOut := 'COMPLETE:T';
    END IF;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'SELECT_NEXT_INFORMED'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Select_Next_Informed;


--
--  Name          : Rej_Note_Filled
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure verifies that the note is filled if
--                  the change request was rejected.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Rej_Note_Filled
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    IF ( WF_Engine.GetItemAttrText(ItemType , ItemKey , 'WF_NOTE') IS NULL ) THEN
      ResultOut := 'COMPLETE:F';
    ELSE
      ResultOut := 'COMPLETE:T';
    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'REJ_NOTE_FILLED'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Rej_Note_Filled;


--
--  Name          : Impact_Funding
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure checks whether the change request
--                  impacts funding or not.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Impact_Funding
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    IF ( WF_Engine.GetItemAttrText(ItemType , ItemKey , 'IMPACT_FUNDING_FLAG') = 'Y' ) THEN
      ResultOut := 'COMPLETE:T';
    ELSE
      ResultOut := 'COMPLETE:F';
    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'IMPACT_FUNDING'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Impact_Funding;


--
--  Name          : Set_Approved_Status
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure sets the status of the change request
--                  to Approved.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Set_Approved_Status
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

L_Chg_Request_ID  NUMBER;
L_Approved_Status VARCHAR2(30);

BEGIN
  L_Approved_Status := Default_Chg_Status('APPROVED');

  IF ( FuncMode = 'RUN' ) THEN

    IF ( L_Approved_Status IS NULL ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    L_Chg_Request_ID := WF_ENGINE.GetItemAttrNumber
                        ( itemtype => ItemType
                        , ItemKey  => ItemKey
                        , AName    => 'CHG_REQUEST_ID' );

    UPDATE oke_chg_requests
    SET    chg_status_code = L_Approved_Status
    ,      last_update_date = sysdate
    WHERE  chg_request_id  = L_Chg_Request_ID;

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  ResultOut := 'ERROR:';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT'
  , AValue => FND_MESSAGE.Get_String('OKE' , 'OKE_CHGREQ_NODEF_APPR_STS') );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'SET_APPROVED_STATUS'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'SET_APPROVED_STATUS'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Set_Approved_Status;


--
--  Name          : Set_Rejected_Status
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure sets the status of the change request
--                  to Rejected.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Set_Rejected_Status
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

L_Chg_Request_ID  NUMBER;
L_Rejected_Status VARCHAR2(30);

BEGIN
  L_Rejected_Status := Default_Chg_Status('REJECTED');

  IF ( FuncMode = 'RUN' ) THEN

    IF ( L_Rejected_Status IS NULL ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    L_Chg_Request_ID := WF_ENGINE.GetItemAttrNumber
                        ( itemtype => ItemType
                        , ItemKey  => ItemKey
                        , AName    => 'CHG_REQUEST_ID' );

    UPDATE oke_chg_requests
    SET    chg_status_code = L_Rejected_Status
    ,      last_update_date = sysdate
    WHERE  chg_request_id  = L_Chg_Request_ID;

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  ResultOut := 'ERROR:';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT'
  , AValue => FND_MESSAGE.Get_String('OKE' , 'OKE_CHGREQ_NODEF_REJ_STS') );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'SET_APPROVED_STATUS'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

WHEN OTHERS THEN
  ResultOut := 'ERROR';
  WF_Engine.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_Core.Context( 'OKE_CHG_REQUESTS_WF'
                 , 'SET_REJECTED_STATUS'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Set_Rejected_Status;


END OKE_CHG_REQUESTS_WF;

/
