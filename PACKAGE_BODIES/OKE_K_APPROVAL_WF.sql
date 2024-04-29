--------------------------------------------------------
--  DDL for Package Body OKE_K_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_APPROVAL_WF" AS
/* $Header: OKEWKAPB.pls 120.1.12000000.3 2007/03/17 11:57:27 nnadahal ship $ */

--
-- Global Variables
--
G_K_Header_ID      NUMBER;
G_K_Number         VARCHAR2(240);
G_K_Type_Code      VARCHAR2(30);
G_K_Type           VARCHAR2(80);
G_Type_Class       VARCHAR2(30);
G_Intent           VARCHAR2(30);
G_Requestor        VARCHAR2(80);
G_Aprv_Path        NUMBER;
G_Aprv_Seq         NUMBER;

--
-- Private Functions and Procedures
--

--
-- Load_Globals loads commonly used WF item attributes into PL/SQL globals
--
PROCEDURE Load_Globals
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
) IS

BEGIN

  G_K_Header_ID := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'CONTRACT_ID');
  G_K_Number    := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'K_NUMBER');
  G_K_Type_Code := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'K_TYPE_CODE');
  G_K_Type      := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'K_TYPE');
  G_Type_Class  := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'K_TYPE_CLASS');
  G_Intent      := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'INTENT');
  G_Requestor   := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'REQUESTOR');
  G_Aprv_Path   := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'APPROVAL_PATH_ID');
  G_Aprv_Seq    := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'APPROVAL_SEQUENCE');

END Load_Globals;


--
-- KRole_To_WFRole maps a contract role into WF role based on contract security
-- assignments
--
FUNCTION KRole_To_WFRole ( K_Role_ID  NUMBER )
RETURN VARCHAR2 IS

--CURSOR c IS
--  SELECT R.Name
--  FROM   oke_k_all_access_basic_v A , wf_roles R
--  WHERE  A.k_header_id = G_K_Header_ID
--  AND    A.role_id = K_Role_ID
--  AND    SYSDATE BETWEEN A.Start_date_Active AND nvl(A.End_Date_Active , SYSDATE + 1 )
--  AND    R.orig_system_id = A.person_id
--  AND    R.orig_system = 'PER'
--  ORDER BY decode( A.assignment_level , 'SITE' , 0 , 'OKE_PROGRAMS' , 1 , 2 ) desc;

UserName  VARCHAR2(80);

BEGIN

--  OPEN c;
--  FETCH c INTO UserName;
--  CLOSE c;
  UserName := OKE_UTILS.Retrieve_WF_Role_Name(G_K_Header_ID,K_Role_ID);

  RETURN ( UserName );

END KRole_To_WFRole;


--
-- K_Role_Name returns the name of the contract role
--
FUNCTION K_Role_Name ( K_Role_ID  NUMBER )
RETURN VARCHAR2 IS

CURSOR c IS
  SELECT name
  FROM   oke_k_roles_v
  WHERE  role_id = K_Role_ID;

RoleName  VARCHAR2(80);

BEGIN

  OPEN c;
  FETCH c INTO RoleName;
  CLOSE c;

  RETURN ( RoleName );

END K_Role_Name;


--
-- Add_To_History adds an entry into the approval history
--
PROCEDURE Add_To_History
( PerformerName       IN      VARCHAR2
, ActionCode          IN      VARCHAR2
, ActionDate          IN      DATE
, ApprovalPathID      IN      NUMBER
, ApprovalSeq         IN      NUMBER
, ApproverRoleID      IN      NUMBER
, NoteText            IN      VARCHAR2
) IS

CURSOR c IS
  SELECT nvl(max(action_sequence) , 0) + 1
  FROM   oke_approval_history
  WHERE  k_header_id = G_K_Header_ID
  AND    chg_request_id is null;
NextSeq NUMBER;

BEGIN

  OPEN c;
  FETCH c INTO NextSeq;
  CLOSE c;

  INSERT INTO oke_approval_history
  ( k_header_id
  , action_sequence
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , action_code
  , action_date
  , performer
  , approver_role_id
  , approval_path_id
  , approval_sequence
  , note )
  VALUES
  ( G_K_Header_ID
  , NextSeq
  , sysdate
  , FND_GLOBAL.user_id
  , sysdate
  , FND_GLOBAL.user_id
  , -1
  , ActionCode
  , ActionDate
  , PerformerName
  , ApproverRoleID
  , ApprovalPathID
  , ApprovalSeq
  , NoteText
  );

END Add_To_History;

FUNCTION UrlEncode( URL VARCHAR2 ) RETURN VARCHAR2 IS
 BEGIN
  RETURN Replace(WF_Mail.UrlEncode(url),'','%5C'); --workarround for backslash because of a bug in wf_mail.urlencode
END UrlEncode;

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
--  OUT           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

  CURSOR k ( C_K_Header_ID  NUMBER ) IS
    SELECT k.k_number_disp
    ,      k.k_type_code
    ,      kt.k_type_name
    ,      kt.type_class_code
    ,      k.buy_or_sell
    ,      k.currency_code
    ,      k.k_value
    ,      k.short_description
    ,      k.description
    ,      k.authoring_org_id
    ,      k.status_code
    ,      ks.ste_code
    FROM   oke_k_headers_v k
    ,      oke_k_types_vl kt
    ,      okc_statuses_b ks
    WHERE  k.k_header_id = C_K_Header_ID
    AND    kt.k_type_code = k.k_type_code
    AND    ks.code = k.status_code;
  krec k%rowtype;

  tx_k_number     VARCHAR2(400);
  c_txn_vlu       VARCHAR2(400);
  c_new_vlu       VARCHAR2(400);
  n_pos           NUMBER;

  P_FLOWDOWN_LINK VARCHAR2(4000);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    G_K_Header_ID := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'CONTRACT_ID');

    OPEN k ( G_K_Header_ID );
    FETCH k INTO krec;
    CLOSE k;

    SELECT owner_role
    INTO   G_Requestor
    FROM   wf_items
    WHERE  item_type = ItemType
    AND    item_key = ItemKey;

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'K_NUMBER'
                             , avalue   => krec.k_number_disp );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'K_TYPE_CODE'
                             , avalue   => krec.k_type_code );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'K_TYPE'
                             , avalue   => krec.k_type_name );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'K_TYPE_CLASS'
                             , avalue   => krec.type_class_code );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'INTENT'
                             , avalue   => krec.buy_or_sell );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'CURRENCY_CODE'
                             , avalue   => krec.currency_code );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'CONTRACT_VALUE'
                             , avalue   =>
                                 to_char( krec.k_value
                                        , FND_CURRENCY.get_format_mask( krec.currency_code , 38 ) ) );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'SHORT_DESCRIPTION'
                             , avalue   => krec.short_description );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'DESCRIPTION'
                             , avalue   => krec.description );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'STS_CODE'
                             , avalue   => krec.status_code );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'STE_CODE'
                             , avalue   => krec.ste_code );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'REQUESTOR'
                             , avalue   => FND_GLOBAL.User_Name );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'APPROVAL_SEQUENCE'
                               , avalue   => 0 );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'ORG_ID'
                               , avalue   => krec.authoring_org_id );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'K_NUMBER_LINK'
                             , avalue   => 'PLSQL:OKE_K_APPROVAL_WF2.CONTRACT_NUMBER_LINK/'
                                           || ItemType || ':' || ItemKey );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'APPROVAL_HISTORY'
                             , avalue   => 'PLSQL:OKE_K_APPROVAL_WF2.SHOW_APPROVAL_HISTORY/'
                                           || ItemType || ':' || ItemKey );

    P_FLOWDOWN_LINK := 'OA.jsp?akRegionCode=KHEADERPAGE'
               ||'&akRegionApplicationId=777'
	       ||'&OAFunc=OKEFLDVH'
	       ||'&p_ba=APPROVAL'
	       ||'&p_k_header_id='
	       ||TO_CHAR(G_K_Header_ID)
	       ||'&p_k_line_id='
	       ||'&p_project_id='
	       ||'&p_task_id='
	       ||'&p_k_number='
	       ||UrlEncode(krec.k_number_disp)
	       ||'&addBreadCrumb=Y';



    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'FLOWDOWN_LINK'
                             , avalue   => P_FLOWDOWN_LINK );

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
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'INITIALIZE'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Initialize;


--
--  Name          : Is_BOA_Approved
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the master agreement
--                  has been approved or not.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_BOA_Approved
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

CURSOR k ( C_K_Header_ID  NUMBER ) IS
  SELECT ks.ste_code
  FROM   okc_k_headers_b boa
  ,      oke_k_headers   k
  ,      okc_statuses_b  ks
  WHERE  k.k_header_id = C_K_Header_ID
  AND    boa.id = k.boa_id
  AND    ks.code = boa.sts_code;
  krec k%rowtype;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Load_Globals( ItemType , ItemKey );

    OPEN k ( G_K_Header_ID );
    FETCH k INTO krec;
    CLOSE k;

    IF ( krec.ste_code IN ( 'SIGNED' , 'ACTIVE' ) ) THEN
      ResultOut := 'COMPLETE:Y';
    ELSE
      ResultOut := 'COMPLETE:N';
      FND_MESSAGE.Set_Name('OKE' , 'OKE_APRV_ABT_BOA_NOT_APPROVED');
      WF_ENGINE.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'MESSAGE1'
      , AValue   => FND_MESSAGE.Get );
    END IF;
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'IS_BOA_APPROVED'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Is_BOA_Approved;


--
--  Name          : Is_Doc_Approved
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the contract document
--                  has already been approved or not.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Doc_Approved
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

ste_code   VARCHAR2(30);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    ste_code := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'STE_CODE');

    IF ( ste_code IN ( 'ENTERED' , 'CANCELED' ) ) THEN
      ResultOut := 'COMPLETE:N';
    ELSE
      ResultOut := 'COMPLETE:Y';
      FND_MESSAGE.Set_Name('OKE' , 'OKE_APRV_ABT_APPROVED');
      WF_ENGINE.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'MESSAGE1'
      , AValue   => FND_MESSAGE.Get );
    END IF;
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'IS_DOC_APPROVED'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Is_Doc_Approved;


--
--  Name          : Is_Doc_Delv_Order
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the contract document
--                  is a delivery order.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Doc_Delv_Order
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

ste_code   VARCHAR2(30);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    IF ( WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'K_TYPE_CLASS') = 'DO' ) THEN
      ResultOut := 'COMPLETE:Y';
    ELSE
      ResultOut := 'COMPLETE:N';
    END IF;
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'IS_DOC_DELV_ORDER'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Is_Doc_Delv_Order;


--
--  Name          : Is_Doc_Inactive
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the contract document
--                  is currently inactive (Canceled, Expired, Terminated)
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Doc_Inactive
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

ste_code   VARCHAR2(30);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    ste_code := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'STE_CODE');

    IF ( ste_code in ( 'CANCELED' , 'TERMINATED' , 'EXPIRED' ) ) THEN
      ResultOut := 'COMPLETE:Y';
      FND_MESSAGE.Set_Name('OKE' , 'OKE_APRV_ABT_INACTIVE');
      WF_ENGINE.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'MESSAGE1'
      , AValue   => FND_MESSAGE.Get );
    ELSE
      ResultOut := 'COMPLETE:N';
    END IF;
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'IS_DOC_INACTIVE'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Is_Doc_Inactive;


--
--  Name          : Is_Final_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the last approver
--                  is the final approver based to the approval
--                  hierarchy.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Final_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

ApprovalSeq    NUMBER;
ApprovalSteps  VARCHAR2(4000);
NextApprRoleID NUMBER;
NextApprSeq    NUMBER;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Load_Globals( ItemType , ItemKey );

    ApprovalSteps := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'APPROVAL_STEPS');
    ApprovalSeq   := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'APPROVAL_SEQUENCE');

    OKE_APPROVAL_PATHS_PKG.Next_Approval_Step( ApprovalSteps , ApprovalSeq , NextApprSeq , NextApprRoleID );

    IF ( NextApprRoleID IS NULL ) THEN
      ResultOut := 'COMPLETE:Y';
    ELSE
      ResultOut := 'COMPLETE:N';
    END IF;
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'IS_FINAL_APPROVER'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Is_Final_Approver;


--
--  Name          : Is_Requestor_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure checks wheter the approver happens
--                  to be also the requestor.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Requestor_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

Approver    VARCHAR2(240);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Load_Globals( ItemType , ItemKey );

    Approver := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'APPROVER');

    IF ( Approver = G_Requestor ) THEN
      --
      -- If approver is the requestor, there is no need to seek approval.
      -- Add to Approval History directly and move on.
      --
      Add_To_History
      ( PerformerName  => Approver
      , ActionCode     => 'APPROVED'
      , ActionDate     => sysdate
      , ApprovalPathID => G_Aprv_Path
      , ApprovalSeq    => G_Aprv_Seq
      , ApproverRoleID => NULL
      , NoteText       => NULL
      );

      ResultOut := 'COMPLETE:Y';

    ELSE

      ResultOut := 'COMPLETE:N';

    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'IS_REQUESTOR_APPROVER'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Is_Requestor_Approver;


--
--  Name          : Is_Signature_Required
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure checks whether signature is required
--                  based on the approval hierarchy
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Is_Signature_Required
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    IF ( WF_ENGINE.GetItemAttrText( ItemType , ItemKey , 'SIGNATURE_REQUIRED' ) = 'Y' ) THEN
      ResultOut := 'COMPLETE:Y';
    ELSE
      ResultOut := 'COMPLETE:N';
    END IF;
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'IS_SIGNATURE_REQUIRED'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Is_Signature_Required;


--
--  Name          : Rej_Note_Filled
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure verifies that the note is filled if
--                  the contract was rejected.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_YES_NO )
--
--  Returns       : None
--
PROCEDURE Rej_Note_Filled
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    IF ( WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'NOTE') IS NULL
       AND WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'WF_NOTE') IS NULL ) THEN
      ResultOut := 'COMPLETE:N';
    ELSE
      ResultOut := 'COMPLETE:Y';
    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'REJ_NOTE_FILLED'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Rej_Note_Filled;


--
--  Name          : Select_Next_Approver
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the next approver for
--                  the contract based on the approval hierarchy.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_BOOLEAN )
--
--  Returns       : None
--
PROCEDURE Select_Next_Approver
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

ApprovalSeq    NUMBER;
ApprovalPath   NUMBER;
ApprovalSteps  VARCHAR2(4000);
NextAppr       VARCHAR2(240);
NextApprRole   VARCHAR2(240);
NextApprRoleID NUMBER;
NextApprSeq    NUMBER;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Load_Globals( ItemType , ItemKey );

    ApprovalSteps := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'APPROVAL_STEPS');
    ApprovalPath  := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'APPROVAL_PATH_ID');
    ApprovalSeq   := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'APPROVAL_SEQUENCE');

    OKE_APPROVAL_PATHS_PKG.Next_Approval_Step( ApprovalSteps , ApprovalSeq , NextApprSeq , NextApprRoleID );

    IF ( NextApprRoleID IS NULL ) THEN
      --
      -- This is a strange condition; it should have been trapped by
      -- the IS_FINAL_APPROVER check
      --
      -- Ideally, we need to pass this back to IS_FINAL_APPROVER activity.
      -- But for now, we are failing this.
      --
      ResultOut := 'COMPLETE:F';
      RETURN;
    END IF;

    --
    -- Now that we find the next approver role, we need to find the next
    -- approver based on the role.
    --
    NextApprRole := K_Role_Name( NextApprRoleID );
    NextAppr := KRole_To_WFRole( NextApprRoleID );

    --
    -- Push previous approver to the PREV_APPROVER% attributes
    --
    WF_ENGINE.SetItemAttrText
       ( ItemType , ItemKey , 'PREV_APPROVER'
       , WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'APPROVER') );
    WF_ENGINE.SetItemAttrText
       ( ItemType , ItemKey , 'PREV_APPROVER_ROLE'
       , WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'APPROVER_ROLE') );
    WF_ENGINE.SetItemAttrNumber
       ( ItemType , ItemKey , 'PREV_APPROVER_ROLE_ID'
       , WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'APPROVER_ROLE_ID') );

    WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'APPROVER' , NextAppr );
    WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'APPROVER_ROLE' , NextApprRole );
    WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'APPROVER_ROLE_ID' , NextApprRoleID );
    WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'APPROVAL_SEQUENCE' , NextApprSeq );
    --
    -- Erase note text
    --
    WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'NOTE' , NULL );
    WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'WF_NOTE' , NULL );

    IF ( NextAppr IS NULL ) THEN
      ResultOut := 'COMPLETE:F';
    ELSE
      --
      -- Write Approval History
      --
      Add_To_History
      ( PerformerName  => NextAppr
      , ActionCode     => 'ASSIGNED'
      , ActionDate     => sysdate
      , ApprovalPathID => ApprovalPath
      , ApprovalSeq    => NextApprSeq
      , ApproverRoleID => NextApprRoleID
      , NoteText       => NULL
      );

      ResultOut := 'COMPLETE:T';

    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'SELECT_NEXT_APPROVER'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Select_Next_Approver;


--
--  Name          : Select_Signatory
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines the signatory for
--                  the contract based on the approval hierarchy
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_BOOLEAN )
--
--  Returns       : None
--
PROCEDURE Select_Signatory
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

SignatoryRole  NUMBER;
Signatory      VARCHAR2(240);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Load_Globals( ItemType , ItemKey );

    SignatoryRole := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'SIGNATORY_ROLE_ID');
    Signatory := KRole_To_WFRole( SignatoryRole );

    IF ( Signatory IS NULL ) THEN
      ResultOut := 'COMPLETE:F';
    ELSE

      WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'SIGNATORY' , Signatory );

      --
      -- Erase note text
      --
      WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'NOTE' , NULL );
      WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'WF_NOTE' , NULL );

      --
      -- Write Approval History
      --
      Add_To_History
      ( PerformerName  => Signatory
      , ActionCode     => 'ASSIGNED_SIGNATURE'
      , ActionDate     => sysdate
      , ApprovalPathID => G_Aprv_Path
      , ApprovalSeq    => G_Aprv_Seq
      , ApproverRoleID => SignatoryRole
      , NoteText       => NULL
      );

      ResultOut := 'COMPLETE:T';

    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'SELECT_SIGNATORY'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Select_Signatory;


--
--  Name          : Set_Approval_History
--  Pre-reqs      : Must be called from WF activity
--  Function      : This post-notification procedure records the approval
--                  history based on the notification response
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Set_Approval_History
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

CURSOR NtfDtls IS
  SELECT message_name
  ,      recipient_role
  ,      responder
  FROM   wf_notifications
  WHERE  notification_id = WF_ENGINE.CONTEXT_NID;
NtfDtlRec NtfDtls%rowtype;

Performer  VARCHAR2(320);
ActionCode VARCHAR2(30);

--
-- The following is an exception to detect invalid forward-to
-- recipient
--
INVALID_FORWARD_TO    EXCEPTION;

BEGIN
  ActionCode := 'UNKNOWN';

  IF ( FuncMode IN ( 'FORWARD' , 'TRANSFER' , 'RESPOND' ) ) THEN

    Load_Globals( ItemType , ItemKey );

    --
    -- In order to write approval history, we need several notification
    -- details, such as the message_name (to determine if it is for
    -- approval or signature) and the final recipient
    --
    OPEN NtfDtls;
    FETCH NtfDtls INTO NtfDtlRec;
    CLOSE NtfDtls;

    --
    -- Write Approval History
    --
    IF ( FuncMode IN ( 'FORWARD' , 'TRANSFER' ) ) THEN

      Performer := WF_ENGINE.CONTEXT_TEXT;
      ActionCode := FuncMode;

    ELSE

      Performer := NtfDtlRec.Recipient_Role;

      WF_ENGINE.SetItemAttrText( ItemType , ItemKey , 'APPROVER' , Performer );

      IF ( NtfDtlRec.Message_Name = 'MSG_APPROVAL' ) THEN

        ActionCode := WF_NOTIFICATION.GetAttrText( nid => WF_ENGINE.CONTEXT_NID , aname => 'RESULT' );

      ELSIF ( NtfDtlRec.Message_Name = 'MSG_SIGNATURE' ) THEN

        IF ( WF_NOTIFICATION.GetAttrText( nid => WF_ENGINE.CONTEXT_NID , aname => 'RESULT' ) = 'Y' ) THEN
          ActionCode := 'SIGNED';
        ELSE
          ActionCode := 'DID_NOT_SIGN';
        END IF;

      END IF;

    END IF;

    Add_To_History
    ( PerformerName  => Performer
    , ActionCode     => ActionCode
    , ActionDate     => sysdate
    , ApprovalPathID => G_Aprv_Path
    , ApprovalSeq    => G_Aprv_Seq
    , ApproverRoleID => NULL
--    , NoteText       => WF_NOTIFICATION.GetAttrText( nid => WF_ENGINE.CONTEXT_NID , aname => 'NOTE' )
    , NoteText       => WF_NOTIFICATION.GetAttrText( nid => WF_ENGINE.CONTEXT_NID , aname => 'WF_NOTE' )
    );

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

EXCEPTION
WHEN INVALID_FORWARD_TO THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT'
  , AValue => fnd_message.get_string('OKE' , 'OKE_APRV_INVALID_FORWARDTO') );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'SET_APPROVAL_HISTORY'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'SET_APPROVAL_HISTORY'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Set_Approval_History;


--
--  Name          : Validate_Approval_Path
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure validates the approval hierarchy
--                  associated with the contract document type.
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut ( WFSTD_BOOLEAN )
--
--  Returns       : None
--
PROCEDURE Validate_Approval_Path
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS

CURSOR c IS
  SELECT KT.approval_path_id
  ,      AP.name approval_path
  ,      AP.signature_required_flag
  ,      AP.signatory_role_id
  FROM   oke_approval_paths_v  AP
  ,      oke_k_types_b         KT
  WHERE  KT.k_type_code = G_K_Type_Code
  AND    AP.approval_path_id = KT.approval_path_id;
crec   c%rowtype;

ApprovalSteps VARCHAR2(4000);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Load_Globals( ItemType , ItemKey );

    OPEN c;
    FETCH c INTO crec;
    CLOSE c;

    ApprovalSteps := OKE_APPROVAL_PATHS_PKG.Approval_Steps( crec.approval_path_id );

    IF ( ApprovalSteps <> ';' ) THEN

      WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                                 , itemkey  => ItemKey
                                 , aname    => 'APPROVAL_PATH_ID'
                                 , avalue   => crec.Approval_Path_ID );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'APPROVAL_PATH'
                               , avalue   => crec.Approval_Path );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'APPROVAL_STEPS'
                               , avalue   => ApprovalSteps );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'SIGNATURE_REQUIRED'
                               , avalue   => crec.Signature_Required_Flag );

      WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                                 , itemkey  => ItemKey
                                 , aname    => 'SIGNATORY_ROLE_ID'
                                 , avalue   => crec.Signatory_Role_ID );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'SIGNATORY_ROLE'
                               , avalue   => K_Role_Name( crec.Signatory_Role_ID ) );

      --
      -- All set to go, write Approval History to record submission of approval process
      --
      Add_To_History
      ( PerformerName  => G_Requestor
      , ActionCode     => 'SUBMITTED'
      , ActionDate     => sysdate
      , ApprovalPathID => crec.Approval_Path_ID
      , ApprovalSeq    => 0
      , ApproverRoleID => NULL
      , NoteText       => NULL
      );

      ResultOut := 'COMPLETE:T';
    ELSE
      ResultOut := 'COMPLETE:F';
    END IF;
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := WF_ENGINE.ENG_NULL;
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR:';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                 , 'VALIDATE_APPROVAL_PATH'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Validate_Approval_Path;

--bug#5846706
--
--  Name          : Erase_Approved
--  Pre-reqs      : Must be called from WF activity
--  Function      : It erases approved date when signatory rejects the contract
--
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Erase_Approved
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY VARCHAR2
) IS
 L_CONTRACT_ID number;
 x_return_status varchar2(1);
 BEGIN
           IF ( FuncMode = 'RUN' ) THEN

          L_CONTRACT_ID := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'CONTRACT_ID');
   --bug#5933768
          IF(mo_global.is_mo_init_done = 'N') then
             mo_global.init('OKE');
             okc_context.set_okc_org_context(p_chr_id => L_CONTRACT_ID);
          End IF;
   --ends
           OKE_CONTRACT_APPROVAL_PUB.k_erase_approved(
                                    p_contract_id => L_CONTRACT_ID,
                                     x_return_status =>  x_return_status);
            IF (x_return_status = OKC_API.G_RET_STS_SUCCESS)
             THEN
               ResultOut := 'COMPLETE:T';
               RETURN;
            ELSE
               ResultOut := 'COMPLETE:F';
               RETURN;
             END IF;
           END IF;

     IF ( FuncMode = 'CANCEL' ) THEN

       ResultOut := WF_ENGINE.ENG_NULL;
       RETURN;

     END IF;

     IF ( FuncMode = 'TIMEOUT' ) THEN

       ResultOut :=WF_ENGINE.ENG_NULL;
       RETURN;

     END IF;

   EXCEPTION
   WHEN OTHERS THEN
     ResultOut := 'ERROR:';
     WF_ENGINE.SetItemAttrText
     ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
     WF_CORE.Context( 'OKE_K_APPROVAL_WF'
                    , 'Erase_Approved'
                    , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
     RAISE;

   END Erase_Approved;



END OKE_K_APPROVAL_WF;

/
