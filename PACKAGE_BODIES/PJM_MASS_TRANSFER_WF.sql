--------------------------------------------------------
--  DDL for Package Body PJM_MASS_TRANSFER_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_MASS_TRANSFER_WF" AS
/* $Header: PJMWMXFB.pls 115.8 2004/02/23 18:20:20 yliou noship $ */

--
-- Global Variables
--
Requestor  VARCHAR2(80);

--
-- Private Functions and Procedures
--
PROCEDURE Apps_Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
) IS

UserID      NUMBER;
RespID      NUMBER;
RespApplID  NUMBER;

BEGIN

  FND_GLOBAL.apps_initialize
  ( WF_ENGINE.GetItemAttrNumber( ItemType , ItemKey , 'USER_ID' )
  , WF_ENGINE.GetItemAttrNumber( ItemType , ItemKey , 'RESP_ID' )
  , WF_ENGINE.GetItemAttrNumber( ItemType , ItemKey , 'RESP_APPL_ID' )
  );

END Apps_Initialize;


FUNCTION Find_Proj_Mgr
( X_Project_ID  NUMBER
, X_Requestor   VARCHAR2 )
RETURN VARCHAR2 IS

CURSOR c IS
  SELECT R.name
  FROM   pa_project_players P , wf_roles R
  WHERE  P.project_role_type = 'PROJECT MANAGER'
  AND    P.project_id = X_Project_ID
  AND    sysdate BETWEEN P.start_date_active AND nvl(P.end_date_active , sysdate + 1)
  AND    R.orig_system_id = P.person_id
  AND    R.orig_system = 'PER'
  ORDER BY decode(R.name , X_Requestor , 0 , 1) , R.name;

RoleName  VARCHAR2(80);

BEGIN

  OPEN c;
  FETCH c INTO RoleName;
  CLOSE c;

  RETURN ( RoleName );

END Find_Proj_Mgr;


FUNCTION Is_Project_Seiban ( X_Project_ID  NUMBER )
RETURN VARCHAR2 IS

CURSOR c IS
  SELECT 'Y'
  FROM   pjm_seiban_numbers
  WHERE  project_id = X_Project_ID;

Result   VARCHAR2(1);

BEGIN

  OPEN c;
  FETCH c INTO Result;
  IF ( c%notfound ) THEN
    CLOSE c;
    RETURN ( 'N' );
  ELSE
    CLOSE c;
    RETURN ( 'Y' );
  END IF;

END Is_Project_Seiban;


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
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

CURSOR c ( X_Transfer_ID  NUMBER ) IS
  SELECT p.organization_id
  ,      mp.organization_code
  ,      org.name organization_name
  ,      p.from_project_id
  ,      p.to_project_id
  ,      p.transfer_date
  ,      p.transfer_mode
  ,      p.inventory_item_id
  ,      p.category_set_id
  ,      p.category_id
  ,      r.reason_name transfer_reason
  ,      p.transfer_reference
  FROM   pjm_mass_transfers p
  ,      mtl_parameters mp
  ,      hr_all_organization_units_tl org
  ,      mtl_transaction_reasons r
  WHERE  p.mass_transfer_id = X_Transfer_ID
  AND    mp.organization_id = p.organization_id
  AND    org.organization_id = mp.organization_id
  AND    org.language = userenv('LANG')
  AND    r.reason_id (+) = p.transfer_reason_id
  ;

crec       c%rowtype;

CURSOR p ( X_Project_ID  NUMBER ) IS
  SELECT segment1 project_num , name project_name , description project_desc
  FROM   pa_projects_all
  WHERE  project_id = X_Project_ID
  UNION ALL
  SELECT project_number , project_name , project_name
  FROM   pjm_seiban_numbers
  WHERE  project_id = X_Project_ID;

prec       p%rowtype;

CURSOR ic ( X_Transfer_Mode   NUMBER
          , X_Organization_ID NUMBER
          , X_Item_ID         NUMBER
          , X_Category_ID     NUMBER ) IS
  SELECT concatenated_segments , description
  FROM   mtl_system_items_b_kfv
  WHERE  organization_id = X_Organization_ID
  AND    inventory_item_id = X_Item_ID
  AND    X_Transfer_Mode = PJM_MASS_TRANSFER_PUB.G_TXFR_MODE_ONE_ITEM
  UNION ALL
  SELECT concatenated_segments , description
  FROM   mtl_categories_b_kfv
  WHERE  category_id = X_Category_ID
  AND    X_Transfer_Mode = PJM_MASS_TRANSFER_PUB.G_TXFR_MODE_CATEGORY;

icrec      ic%rowtype;

ItemCat    VARCHAR2(2000);

ProjMgr    VARCHAR2(80);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Requestor := WF_ENGINE.GetItemAttrText( ItemType , ItemKey , 'REQUESTOR' );

    OPEN c ( to_number( ItemKey ) );
    FETCH c INTO crec;
    CLOSE c;

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'TRANSFER_ID'
                             , avalue   => ItemKey );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'ORGANIZATION_ID'
                               , avalue   => crec.organization_id );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'ORGANIZATION_CODE'
                             , avalue   => crec.organization_code );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'ORGANIZATION_NAME'
                             , avalue   => crec.organization_name );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'FROM_PROJECT_ID'
                               , avalue   => crec.from_project_id );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'TO_PROJECT_ID'
                               , avalue   => crec.to_project_id );

    WF_ENGINE.SetItemAttrDate( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'TRANSFER_DATE'
                             , avalue   => crec.transfer_date );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'TRANSFER_MODE'
                             , avalue   => crec.transfer_mode );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'TRANSFER_REASON'
                             , avalue   => crec.transfer_reason );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'REFERENCE'
                             , avalue   => crec.transfer_reference );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'DETAILS'
                             , avalue   => 'PLSQL:PJM_MASS_TRANSFER_WF.TRANSFER_DETAILS/'
                                           || ItemType || ':' || ItemKey );

    --
    -- Get Details of From Project
    --
    OPEN p ( crec.from_project_id );
    FETCH p INTO prec;
    CLOSE p;

    ProjMgr := Find_Proj_Mgr( crec.from_project_id , Requestor );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'FROM_PROJECT_NUM'
                             , avalue   => prec.project_num );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'FROM_PROJECT_NAME'
                             , avalue   => prec.project_name );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'FROM_PROJECT_DESC'
                             , avalue   => prec.project_desc );

    WF_ENGINE.SetItemAttrText( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'FROM_PROJECT_MGR'
                             , avalue   => ProjMgr );

    --
    -- Get Details of To Project
    --
    IF ( crec.to_project_id IS NOT NULL ) THEN

      OPEN p ( crec.to_project_id );
      FETCH p INTO prec;
      CLOSE p;

      ProjMgr := Find_Proj_Mgr( crec.to_project_id , Requestor );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'TO_PROJECT_NUM'
                               , avalue   => prec.project_num );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'TO_PROJECT_NAME'
                               , avalue   => prec.project_name );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'TO_PROJECT_DESC'
                               , avalue   => prec.project_desc );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'TO_PROJECT_MGR'
                               , avalue   => ProjMgr );

    END IF;

    --
    -- Get Displayable info for item / category
    --
    IF ( crec.transfer_mode in ( PJM_MASS_TRANSFER_PUB.G_TXFR_MODE_ONE_ITEM
                               , PJM_MASS_TRANSFER_PUB.G_TXFR_MODE_CATEGORY ) ) THEN

      OPEN ic ( crec.transfer_mode , crec.organization_id , crec.inventory_item_id , crec.category_id );
      FETCH ic INTO icrec;
      CLOSE ic;

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'ITEMCAT'
                               , avalue   => icrec.concatenated_segments );

      WF_ENGINE.SetItemAttrText( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'ITEMCAT_DESC'
                               , avalue   => icrec.description );

    END IF;

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
  WF_CORE.Context( 'PJM_MASS_TRANSFER_WF'
                 , 'INITIALIZE'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Initialize;


--
--  Name          : Approval_Required_F
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the requestor is also
--                  the project manager of the From Project
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
PROCEDURE Approval_Required_F
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

ProjectID  NUMBER;
ProjMgr    VARCHAR2(80);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    ResultOut := 'COMPLETE:Y';

    Requestor := WF_ENGINE.GetItemAttrText( ItemType , ItemKey , 'REQUESTOR' );

    --
    -- Approval not required if From Project is a Seiban
    --
    ProjectID := WF_ENGINE.GetItemAttrNumber( ItemType , ItemKey , 'FROM_PROJECT_ID' );
    IF ( Is_Project_Seiban( ProjectID ) = 'Y' ) THEN
      ResultOut := 'COMPLETE:N';
      RETURN;
    END IF;

    --
    -- Approval not required if Requestor is also the From Project Manager
    --
    ProjMgr   := WF_ENGINE.GetItemAttrText( ItemType , ItemKey , 'FROM_PROJECT_MGR' );
    IF ( Requestor = ProjMgr ) THEN
      ResultOut := 'COMPLETE:N';
      RETURN;
    END IF;

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
  WF_CORE.Context( 'PJM_MASS_TRANSFER_WF'
                 , 'APPROVAL_REQUIRED_F'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Approval_Required_F;


--
--  Name          : Approval_Required_T
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure determines if the requestor is also
--                  the project manager of the To Project
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
PROCEDURE Approval_Required_T
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

ProjectID  NUMBER;
ProjMgr    VARCHAR2(80);
FProjMgr   VARCHAR2(80);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    ResultOut := 'COMPLETE:Y';

    Requestor := WF_ENGINE.GetItemAttrText( ItemType , ItemKey , 'REQUESTOR' );

    ProjectID := WF_ENGINE.GetItemAttrNumber( ItemType , ItemKey , 'TO_PROJECT_ID' );
    --
    -- Transfer to Common does not require approval
    --
    IF ( ProjectID IS NULL ) THEN
      ResultOut := 'COMPLETE:N';
      RETURN;
    END IF;

    --
    -- Transfer to Seiban does not require approval
    --
    IF ( Is_Project_Seiban( ProjectID ) = 'Y' ) THEN
      ResultOut := 'COMPLETE:N';
      RETURN;
    END IF;

    --
    -- Approval not required if Requestor is also the To Project Manager
    --
    ProjMgr   := WF_ENGINE.GetItemAttrText( ItemType , ItemKey , 'TO_PROJECT_MGR' );
    IF ( Requestor = ProjMgr ) THEN
      ResultOut := 'COMPLETE:N';
      RETURN;
    END IF;

    --
    -- Approval not required to To Project Manager is the same as From Project Manager
    -- Approval will be obtained from the "From Project" side only
    --
    FProjMgr  := WF_ENGINE.GetItemAttrText( ItemType , ItemKey , 'FROM_PROJECT_MGR' );
    IF ( ProjMgr = FProjMgr ) THEN
      ResultOut := 'COMPLETE:N';
      RETURN;
    END IF;

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
  WF_CORE.Context( 'PJM_MASS_TRANSFER_WF'
                 , 'APPROVAL_REQUIRED_T'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Approval_Required_T;


--
--  Name          : Execute
--  Pre-reqs      : Must be called from WF activity
--  Function      : This procedure executes the mass transfer by
--                  invoking the mass transfer process
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
PROCEDURE Execute
( ItemType            IN             VARCHAR2
, ItemKey             IN             VARCHAR2
, ActID               IN             NUMBER
, FuncMode            IN             VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

Return_Status   VARCHAR2(1);
Msg_Count       NUMBER;
Msg_Data        VARCHAR2(2000);
Txn_Count       NUMBER;
Txn_Header_ID   NUMBER;
Request_ID      NUMBER;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    Apps_Initialize( itemtype => ItemType , itemkey => ItemKey );

    PJM_MASS_TRANSFER_PUB.Mass_Transfer
    ( P_api_version      => 1.0
    , P_init_msg_list    => FND_API.G_TRUE
    , P_commit           => FND_API.G_FALSE
    , X_Return_Status    => Return_Status
    , X_Msg_Count        => Msg_Count
    , X_Msg_Data         => Msg_Data
    , P_Transfer_ID      => to_number(ItemKey)
    , X_Txn_Header_ID    => Txn_Header_ID
    , X_Txn_Count        => Txn_Count
    , X_Request_ID       => Request_ID
    );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'CONC_REQUEST_ID'
                               , avalue   => Request_ID );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'TXN_HEADER_ID'
                               , avalue   => Txn_Header_ID );

    WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                               , itemkey  => ItemKey
                               , aname    => 'TXN_COUNT'
                               , avalue   => Txn_Count );

    ResultOut := 'COMPLETE:Y';
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
  ResultOut := 'COMPLETE:N';
  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType , ItemKey => ItemKey , AName => 'ERRORTEXT' , AValue => sqlerrm );
  WF_CORE.Context( 'PJM_MASS_TRANSFER_WF'
                 , 'EXECUTE'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Execute;


--
--  Name          : Transfer_Details
--  Pre-reqs      : Must be called from WF activity
--  Function      : This PL/SQL document procedure returns the transfer
--                  details for use in various notifications
--
--  Parameters    :
--  IN            : Document_ID ( ItemType:ItemKey )
--                  Display_Type
--                  Document_Type
--  OUT           : Document
--                  Document_Type
--
--  Returns       : None
--
PROCEDURE Transfer_Details
( Document_ID         IN             VARCHAR2
, Display_Type        IN             VARCHAR2
, Document            OUT NOCOPY     VARCHAR2
, Document_Type       IN OUT NOCOPY  VARCHAR2
) IS

CURSOR c ( X_Transfer_ID  NUMBER ) IS
SELECT from_task_id
,      to_task_id
FROM   pjm_mass_transfer_tasks
WHERE  mass_transfer_id = X_Transfer_ID;

crec           c%rowtype;

CURSOR t ( X_Task_ID  NUMBER ) IS
SELECT task_number
,      task_name
FROM   pa_tasks
WHERE  task_id = X_Task_ID;

trec           t%rowtype;

ItemType       WF_ITEMS.item_type%TYPE;
ItemKey        WF_ITEMS.item_key%TYPE;
DocOut         VARCHAR2(32767);

CR             VARCHAR2(10) := FND_GLOBAL.newline;
BS             VARCHAR2(10) := '&nbsp;';

BEGIN

  ItemType := substr( Document_ID , 1 , instr(Document_ID , ':') - 1 );
  ItemKey  := substr( Document_ID , instr(Document_ID , ':') + 1
                    , length(Document_ID) - 2);

  IF ( Display_Type = 'text/plain' ) THEN

    Document := '';

  ELSE

    DocOut := CR || CR || '<!-- TRANSFER_DETAILS -->' || CR || CR;
    --
    -- Section Header
    --
    DocOut := DocOut
           || '<table border=0 cellspacing=2 cellpadding=2 width=100%>'
           || '<tr><td class=OraHeader>' || fnd_message.get_string('PJM' , 'MXFR-TRANSFER DETAILS')
           || '</td></tr>' || CR
           || '<tr><td class=OraBGAccentDark></td></tr>' || CR;

    --
    -- Table Header
    --
    DocOut := DocOut || '<tr><td>' || CR;
    DocOut := DocOut
           || '<table class=OraTable border=0 cellspacing=2 cellpadding=2 width=100%>' || CR || '<tr>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=20%>'
           || fnd_message.get_string('PJM' , 'MXFR-FROM TASK NUM')
           || '</th>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=30%>'
           || fnd_message.get_string('PJM' , 'MXFR-FROM TASK NAME')
           || '</th>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=20%>'
           || fnd_message.get_string('PJM' , 'MXFR-TO TASK NUM')
           || '</th>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=30%>'
           || fnd_message.get_string('PJM' , 'MXFR-TO TASK NAME')
           || '</th>' || CR || '</tr>' || CR;

    FOR crec IN c ( to_number(ItemKey) ) LOOP

      DocOut := DocOut || '<tr>' || CR;

      IF ( crec.from_task_id > 0 ) THEN

        OPEN t ( crec.from_task_id );
        FETCH t INTO trec;
        CLOSE t;

        DocOut := DocOut
               || '<td class=OraTableCellText>'
               || trec.task_number
               || '</td>' || CR;
        DocOut := DocOut
               || '<td class=OraTableCellText>'
               || trec.task_name
               || '</td>' || CR;

      ELSE

        DocOut := DocOut
               || '<td colspan=2 class=OraTableCellText>'
               || FND_MESSAGE.get_string('PJM' , 'MXFR-PROJECT LEVEL')
               || '</td>' || CR;

      END IF;

      IF ( crec.to_task_id > 0 ) THEN

        OPEN t ( crec.to_task_id );
        FETCH t INTO trec;
        CLOSE t;

        DocOut := DocOut
               || '<td class=OraTableCellText>'
               || trec.task_number
               || '</td>' || CR;
        DocOut := DocOut
               || '<td class=OraTableCellText>'
               || trec.task_name
               || '</td>' || CR || '</tr>' || CR;

      ELSE

        DocOut := DocOut
               || '<td colspan=2 class=OraTableCellText>'
               || FND_MESSAGE.get_string('PJM' , 'MXFR-PROJECT LEVEL')
               || '</td>' || CR || '</tr>' || CR;

      END IF;

    END LOOP;

    DocOut := DocOut
           || '</td></tr></table>' || CR
           || '</table>' || CR || '<p>' || CR;

    Document := DocOut;
    Document_Type := 'text/html';

  END IF;

END Transfer_Details;


--
--  Name          : Start_Process
--  Pre-reqs      : None
--  Function      : This PL/SQL procedure starts the specified WF process
--
--  Parameters    :
--  IN            : ItemType
--                  Process
--                  ItemKey
--  OUT           : None
--
--  Returns       : None
--
PROCEDURE Start_Process
( ItemType            IN      VARCHAR2
, Process             IN      VARCHAR2
, ItemKey             IN      VARCHAR2
) IS

BEGIN

  WF_ENGINE.CreateProcess( itemtype => ItemType
                         , process  => Process
                         , itemkey  => ItemKey );

  WF_ENGINE.SetItemUserKey( itemtype => ItemType
                          , itemkey  => ItemKey
                          , userkey  => ItemKey );

  WF_ENGINE.SetItemOwner( itemtype => ItemType
                        , itemkey  => ItemKey
                        , owner    => FND_GLOBAL.User_Name );

  WF_ENGINE.SetItemAttrText( itemtype => ItemType
                           , itemkey  => ItemKey
                           , aname    => 'REQUESTOR'
                           , avalue   => FND_GLOBAL.User_Name );

  WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'USER_ID'
                             , avalue   => FND_GLOBAL.User_ID );

  WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'RESP_APPL_ID'
                             , avalue   => FND_GLOBAL.Resp_Appl_ID );

  WF_ENGINE.SetItemAttrNumber( itemtype => ItemType
                             , itemkey  => ItemKey
                             , aname    => 'RESP_ID'
                             , avalue   => FND_GLOBAL.Resp_ID );

  WF_ENGINE.StartProcess( itemtype => ItemType
                        , itemkey  => ItemKey );

EXCEPTION
WHEN OTHERS THEN
  RAISE;
END Start_Process;


END PJM_MASS_TRANSFER_WF;

/
