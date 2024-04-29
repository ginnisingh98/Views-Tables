--------------------------------------------------------
--  DDL for Package Body PSB_SUBMIT_REVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_SUBMIT_REVISION_PVT" AS
/* $Header: PSBVBRSB.pls 120.10.12010000.3 2009/05/04 10:10:55 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30)  := 'PSB_Submit_Revision_PVT';


/*--------------------------- Global variables -----------------------------*/

  --
  -- CALLBACK procedure related global information.
  --

  g_budget_revision_id     psb_budget_revisions.budget_revision_id%TYPE ;
  g_budgetgroup_name       psb_budget_groups.name%TYPE ;
  g_requestor_name         VARCHAR2(100);
  g_itemtype               VARCHAR2(2000) ;
  g_itemkey                VARCHAR2(2000) ;

  -- For Bug 4475288: Changed approver_name, approver_display_name lenghts.
  TYPE g_approver_rec_type IS RECORD
       (approver_name         wf_roles.name%TYPE,
        approver_display_name wf_roles.display_name%TYPE,
        item_key              VARCHAR2(240),
        sequence              number);

  TYPE g_approver_tbl_type IS TABLE OF g_approver_rec_type
      INDEX BY BINARY_INTEGER;

  g_approvers           g_approver_tbl_type;
  g_num_approvers       NUMBER := 0;


  --
  -- WHO columns variables
  --

  g_current_date           DATE   := sysdate                       ;
  g_current_user_id        NUMBER := NVL( Fnd_Global.User_Id  , 0) ;
  g_current_login_id       NUMBER := NVL( Fnd_Global.Login_Id , 0) ;
  g_user_name              VARCHAR2(100);

/*----------------------- End Global variables -----------------------------*/



/*===========================================================================+
 |                        PROCEDURE Start_Process                            |
 +===========================================================================*/
--
-- The API creates an instance of the item type 'PSBBR' and starts the workflow
-- process 'Submit Budget Revision'.
--
PROCEDURE Start_Process
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_item_key                  IN       VARCHAR2 ,
  p_submitter_id              IN       NUMBER   ,
  p_submitter_name            IN       VARCHAR2 ,
  p_operation_type            IN       VARCHAR2 ,
  p_orig_system               IN       VARCHAR2 ,
  p_comments                  IN       VARCHAR2 ,
  p_operation_id              IN       NUMBER   ,
  p_constraint_set_id         IN       NUMBER
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Start_Process' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_ItemType                VARCHAR2(100) := 'PSBBR';
  l_ItemKey                 VARCHAR2(240) := p_item_key;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_comments                VARCHAR2(2000) ;
  l_requestor_name          VARCHAR2(100);
  l_justification           VARCHAR2(240);

  Cursor C_Requestor is
    Select requestor,user_name
      from psb_budget_revisions pbr,
           fnd_user  fu
     where budget_revision_id = l_budget_revision_id
       and requestor = user_id;
  --
 Cursor C_Justification is
   Select justification
      from psb_budget_revisions
     where budget_revision_id = l_budget_revision_id;
  --
BEGIN
  --
  --

  /* Bug 2576222 Start */
  g_user_name := fnd_global.user_name;
  /* Bug 2576222 End */

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  -- Get p_item_key related information.
  --
  SELECT worksheet_id INTO l_budget_revision_id
  FROM   psb_workflow_processes
  WHERE  item_key = p_item_key
    AND  document_type = 'BR';


  wf_engine.CreateProcess ( ItemType => l_ItemType,
                            ItemKey  => l_ItemKey,
                            Process  => 'SUBMIT_REVISION' );

  --
  -- Set budget_revision_id as the Item User Key for the process.
  --

  WF_Engine.SetItemUserKey
  (
     ItemType => l_ItemType        ,
     ItemKey  => l_ItemKey         ,
     UserKey  => l_budget_revision_id
  );

  --
  -- Populate item type.
  --
  wf_engine.SetItemAttrNumber( ItemType => l_ItemType,
                               ItemKey  => l_itemkey,
                               aname    => 'BUDGET_REVISION_ID',
                               avalue   => l_budget_revision_id );
  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
                             ItemKey  => l_itemkey,
                             aname    => 'SUBMITTER_ID',
                             avalue   => p_submitter_id );
  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
                             ItemKey  => l_itemkey,
                             aname    => 'SUBMITTER_NAME',
                             avalue   => p_submitter_name );

  /* Bug 2576222 Start */
  wf_engine.SetItemAttrtext( ItemType => l_ItemType,
			       ItemKey  => l_itemkey,
			       aname    => 'FROM_ROLE',
			       avalue   => g_user_name );
  /* Bug 2576222 End */
  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
                             ItemKey  => l_itemkey,
                             aname    => 'OPERATION_TYPE',
                             avalue   => p_operation_type );

   --
  wf_engine.SetItemAttrNumber( ItemType => l_ItemType,
                               ItemKey  => l_itemkey,
                               aname    => 'LOOP_VISITED_COUNTER',
                               avalue   => 0 );

  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
                             ItemKey  => l_itemkey,
                             aname    => 'ORIG_SYSTEM',
                             avalue   => p_orig_system );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
                               ItemKey  => l_itemkey,
                               aname    => 'OPERATION_ID',
                               avalue   => p_operation_id  );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
                               ItemKey  => l_itemkey,
                               aname    => 'CONSTRAINT_SET_ID',
                               avalue   => p_constraint_set_id  );

/*Bug:6281823:start*/

  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
			       ItemKey  => l_itemkey,
			       aname    => 'OWNER_ID',
			       avalue   => p_submitter_id  );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
			       ItemKey  => l_itemkey,
			       aname    => 'RESP_ID',
			       avalue   => fnd_global.resp_id  );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
			       ItemKey  => l_itemkey,
			       aname    => 'RESP_APPL_ID',
			       avalue   => fnd_global.resp_appl_id  );

  --
/*Bug:6281823:end*/
  --

  --
  -- Populate comments.
  --
  IF p_comments = 'Y' THEN

    -- Retrieve the comments.
    SELECT comments INTO l_comments
    FROM   psb_ws_submit_comments
    WHERE  operation_id = p_operation_id;
    --
    wf_engine.SetItemAttrText( ItemType => l_itemtype,
                               ItemKey  => l_itemkey,
                               aname    => 'COMMENTS',
                               avalue   => l_comments );
  END IF;


  For C_Justification_Rec in C_Justification
  Loop
   l_justification := C_Justification_Rec.justification;
  End Loop;

  wf_engine.SetItemAttrText( ItemType => l_itemtype,
                               ItemKey  => l_itemkey,
                               aname    => 'JUSTIFICATION',
                               avalue   => l_justification );

  For C_Requestor_Rec in C_Requestor
  Loop
   l_requestor_name := C_Requestor_Rec.user_name;
  End Loop;


  g_requestor_name := l_requestor_name;

  wf_engine.SetItemAttrText( ItemType => l_itemtype,
                             ItemKey  => l_itemkey,
                             aname    => 'REQUESTOR_NAME',
                             avalue   => l_requestor_name );
  --
  -- Start the process
  --
  wf_engine.StartProcess ( ItemType => l_ItemType,
                           ItemKey  => l_ItemKey   );

  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    RAISE ;

END Start_Process ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Populate_Revision                        |
 +===========================================================================*/
--
-- The API populates the item attribues  of the item type 'PSBBR'.
-- ( The SUBMITTER_NAME is populated by the interface API 'PSBWKFLB.pls'.)
--
PROCEDURE Populate_Revision
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_budget_revision_id psb_budget_revisions.budget_revision_id%TYPE ;
  l_budget_group_name  psb_budget_groups.name%TYPE ;
  l_submitter_name     VARCHAR2(80);
  --
  l_orig_system        VARCHAR2(8) ;
  l_submitter_id       NUMBER ;
  l_tmp_char           VARCHAR2(200) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'BUDGET_REVISION_ID');

  --
  -- Finding Budget Revision information.
  --
  SELECT budget_group_name
       INTO
         l_budget_group_name
  FROM   psb_budget_revisions_v
  WHERE  budget_revision_id = l_budget_revision_id;

  --
  wf_engine.SetItemAttrText ( itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'BUDGET_GROUP_NAME',
                              avalue   => l_budget_group_name );
  --
  result := 'COMPLETE' ;
END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  result := 'COMPLETE' ;
END IF;
--

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  result := '' ;
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Populate_Revision',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Populate_Revision ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Enforce_Concurrency_Check                |
 +===========================================================================*/
--
-- The activity implements Enforce_Concurrency_Check workflow activity.
--
PROCEDURE Enforce_Concurrency_Check
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_operation_type          VARCHAR2(20) ;
  --
BEGIN

l_return_status := FND_API.G_RET_STS_SUCCESS ;

IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get operation_type item_attribute.
  --
  l_budget_revision_id   := wf_engine.GetItemAttrNumber
                      (  itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'BUDGET_REVISION_ID' );

  l_operation_type := wf_engine.GetItemAttrText
                      (  itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'OPERATION_TYPE' );
  --
  -- API to perform Revision related concurrency control.
  --
  PSB_Create_BR_Pvt.Check_BR_Ops_Concurrency
  (
     p_api_version              =>  1.0,
     p_init_msg_list            =>  FND_API.G_FALSE ,
     p_commit                   =>  FND_API.G_FALSE ,
     p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
     p_return_status            =>  l_return_status,
     p_msg_count                =>  l_msg_count,
     p_msg_data                 =>  l_msg_data,
     --
     p_budget_revision_id       =>  l_budget_revision_id ,
     p_operation_type           =>  l_operation_type
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- (TBD) Need to specify why it failed (?).
    result := 'COMPLETE:NO' ;
  ELSE
    result := 'COMPLETE:YES' ;
  END IF ;
  --
END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  result := 'COMPLETE' ;
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Enforce_Concurrency_Check',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Enforce_Concurrency_Check ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Validate_Constraints                     |
 +===========================================================================*/
--
-- The API calls Revision validation API. If the validation fails, the
-- workflow process terminates and a notification is sent to the submitter.
--
PROCEDURE Validate_Constraints
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status              VARCHAR2(1) ;
  l_msg_count                  NUMBER ;
  l_msg_data                   VARCHAR2(2000) ;
  --
  l_budget_revision_id         psb_budget_revisions.budget_revision_id%TYPE ;
  l_validation_status          VARCHAR2(1) ;
  l_operation_type             VARCHAR2(20) ;
  l_constraint_set_id          NUMBER ;
  --
BEGIN

IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'BUDGET_REVISION_ID');

  l_operation_type := wf_engine.GetItemAttrText
                      (  itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'OPERATION_TYPE' );

  --
  -- Find constraint_set_id optionally needed for validation.
  --
  l_constraint_set_id := wf_engine.GetItemAttrNumber
                         (  itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CONSTRAINT_SET_ID' );

  --
  -- Call the API to validate the Revision.
  --
  PSB_Budget_Revisions_Pvt.Apply_Constraints
  (
     p_api_version             =>   1.0 ,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL ,
     p_return_status           =>   l_return_status ,
     p_validation_status       =>   l_validation_status ,
     --
     p_budget_revision_id      =>   l_budget_revision_id ,
     p_constraint_set_id       =>   l_constraint_set_id
  ) ;
  --
  IF l_validation_status = 'F' THEN
    result := 'COMPLETE:FAIL' ;
  ELSE
    result := 'COMPLETE:SUCCESS' ;
  END IF ;
  -- */

  -- /* For testing. */
  -- result := 'COMPLETE:SUCCESS' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Validate_Constraints',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Validate_Constraints ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Select_Operation                         |
 +===========================================================================*/
--
-- The API selects the operation to be performed on the Revision. The
-- appropriate branch on the process is selected accordingly.
--
PROCEDURE Select_Operation
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_budget_revision_id       psb_budget_revisions.budget_revision_id%TYPE ;
  l_operation_type     VARCHAR2(20) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'BUDGET_REVISION_ID');
  --
  l_operation_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'OPERATION_TYPE');
  --
  -- Operation_type item attribute determines what operation is to
  -- be performed on the Revision.
  --
  IF l_operation_type = 'VALIDATE_REVISION' THEN
    --
    result := 'COMPLETE:VALIDATE_REVISION' ;
    --
  ELSIF l_operation_type = 'FREEZE_REVISION' THEN
    --
    result := 'COMPLETE:FREEZE_REVISION' ;
    --
  ELSIF l_operation_type = 'UNFREEZE_REVISION' THEN
    --
    result := 'COMPLETE:UNFREEZE_REVISION' ;
    --
  ELSIF l_operation_type = 'SUBMIT_REVISION' THEN
    --
    result := 'COMPLETE:SUBMIT_REVISION' ;
    --
  END IF ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Select_Operation',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Select_Operation ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                        PROCEDURE Freeze_Revisions                         |
 +===========================================================================*/
--
-- The API freezes the submitted Budget Revision and
-- all its lower Budget Revisions.
--
PROCEDURE Freeze_Revisions
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_budget_group_id         psb_budget_revisions.budget_group_id%TYPE ;
  l_current_freeze_flag     psb_budget_revisions.freeze_flag%TYPE ;
  l_budget_revisions_tab    PSB_Create_BR_Pvt.Budget_Revision_Tbl_Type ;

  --
  l_notification_id    NUMBER ;
  l_submitter_name     VARCHAR2(80);
  l_operation_type     VARCHAR2(20) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item attribute.
  --
  l_budget_revision_id  := wf_engine.GetItemAttrNumber
                        (itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'BUDGET_REVISION_ID');
  --
  l_submitter_name := wf_engine.GetItemAttrText
                      (  itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'SUBMITTER_NAME' );
  --
  l_operation_type := wf_engine.GetItemAttrText
                      (  itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'OPERATION_TYPE' );

  --
  -- Setting context for the CALLBACK procedure.
  --
  SELECT budget_group_name INTO g_budgetgroup_name
  FROM   psb_budget_revisions_v
  WHERE  budget_revision_id  = l_budget_revision_id ;

  g_budget_revision_id     := l_budget_revision_id ;
  g_itemtype               := itemtype ;
  g_itemkey                := itemkey ;

  --
  -- Freeze the top level worksheet.
  --
  PSB_Create_BR_Pvt.Freeze_Budget_Revision
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_FALSE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_budget_revision_id      =>   l_budget_revision_id ,
     p_freeze_flag             =>   'Y'
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  --
  -- Send 'NOTIFY_OF_FREEZE_COMPLETION' notification to the top level budget
  -- group users. To be done for operation_type  'SUBMIT'.
  --
  IF l_operation_type = 'SUBMIT_REVISION' THEN
    --
    l_notification_id :=
               WF_Notification.SendGroup
               (  role     => l_submitter_name                          ,
                  msg_type => 'PSBBR'                                   ,
                  msg_name => 'NOTIFY_OF_FREEZE_COMPLETION'             ,
                  context  => itemtype ||':'|| itemkey ||':'|| actid    ,
                  callback => 'PSB_Submit_Revision_PVT.Callback'
                ) ;
  END IF ;

  --
  -- Call API to find all lower level worksheets.
  --

   PSB_Create_BR_Pvt.Find_Child_Budget_Revisions
    (
       p_api_version          =>   1.0 ,
       p_init_msg_list        =>   FND_API.G_FALSE,
       p_commit               =>   FND_API.G_FALSE,
       p_validation_level     =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status        =>   l_return_status,
       p_msg_count            =>   l_msg_count,
       p_msg_data             =>   l_msg_data,
       --
       p_budget_revision_id   =>   l_budget_revision_id,
       p_budget_revision_tbl  =>   l_budget_revisions_tab
    );
    --

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  --
  -- Freeze all lower level revisions
  --
  FOR i IN 1..l_budget_revisions_tab.COUNT
  LOOP
    --
    -- Check whether the current Revision is already frozen or not.
    -- If already frozen, do not have to do anything.
    --
    SELECT NVL(freeze_flag, 'N')  INTO l_current_freeze_flag
    FROM   psb_budget_revisions
    WHERE  budget_revision_id = l_budget_revisions_tab(i) ;

    IF l_current_freeze_flag = 'N' THEN
      --
      PSB_Create_BR_Pvt.Freeze_Budget_Revision
      (
         p_api_version             =>   1.0 ,
         p_init_msg_list           =>   FND_API.G_FALSE,
         p_commit                  =>   FND_API.G_FALSE,
         p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
         p_return_status           =>   l_return_status,
         p_msg_count               =>   l_msg_count,
         p_msg_data                =>   l_msg_data,
         --
         p_budget_revision_id      =>   l_budget_revisions_tab(i) ,
         p_freeze_flag             =>   'Y'
      );
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;
      --

      --
      -- Find budget_group_id and budget_group_name for the Revision to find
      -- workflow roles and to set up context info for the CALLBACK procedure.
      --
      SELECT budget_group_id   ,
             budget_group_name
        INTO
             l_budget_group_id   ,
             g_budgetgroup_name
      FROM   psb_budget_revisions_v
      WHERE  budget_revision_id = l_budget_revisions_tab(i) ;

      g_budget_revision_id := l_budget_revisions_tab(i) ;

      --
      -- Send notifications to the budget group roles.
      --
      FOR l_role_rec IN
      (
         SELECT wf_role_name
         FROM   psb_budget_groups     bg ,
                psb_budget_group_resp resp
         WHERE  resp.responsibility_type  = 'N'
         AND    bg.budget_group_id        = l_budget_group_id
         AND    bg.budget_group_id        = resp.budget_group_id
      )
      LOOP
        --
        l_notification_id :=
                   WF_Notification.SendGroup
                   (  role     => l_role_rec.wf_role_name                 ,
                      msg_type => 'PSBBR'                                 ,
                      msg_name => 'NOTIFY_OF_FREEZE_COMPLETION'           ,
                      context  => itemtype ||':'|| itemkey ||':'|| actid  ,
                      callback => 'PSB_Submit_Revision_PVT.Callback'
                    ) ;
      END LOOP ;
      --
    END IF ;
    --
  END LOOP ;

  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Freeze_Revisions',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Freeze_Revisions ;

/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                     PROCEDURE Post_Revisons_To_GL                         |
 +===========================================================================*/
--
-- The API Posts the transactions of the global budget revision to GL
--
PROCEDURE Post_Revisions_To_GL
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_error_code              VARCHAR2(50); -- bug# 4341619
  l_subject                 VARCHAR2(2000);  -- bug# 4341619
  l_body                    VARCHAR2(2000);  -- bug# 4341619

  -- commented for bug 4341619
  /* Cursor C_global_revision is
    Select global_budget_revision
      from psb_budget_revisions
     where budget_revision_id = l_budget_revision_id;*/

BEGIN

  IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'BUDGET_REVISION_ID');
 -- commented for bug 4341619
 /*For C_global_revision_rec in C_global_revision
 Loop
  if ((C_global_revision_rec.global_budget_revision is not null) and
      (C_global_revision_rec.global_budget_revision = 'Y')) then */

  PSB_GL_Interface_Pvt.Create_Revision_Journal
  ( p_api_version       => 1.0,
    p_return_status     => l_return_status,
    p_msg_count         => l_msg_count,
    p_msg_data          => l_msg_data,
     --
    p_budget_revision_id  => l_budget_revision_id,
    p_order_by1           => null,
    p_order_by2           => null,
    p_order_by3           => null,
    p_error_code          => l_error_code -- bug 4341619
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  /* start bug # 4341619 */
  if(l_error_code = 'NO_ERR') then
    result := 'COMPLETE:YES';

  elsif(l_error_code = 'ACCOUNT_OVERLAP_ERR') then

    fnd_message.set_name('PSB','PSB_BR_ACCT_OVERLAP_SUBJ');
    fnd_message.set_token('BUDGET_REVISION_ID',l_budget_revision_id);
    l_subject := fnd_message.get;

    fnd_message.set_name('PSB','PSB_BR_ACCT_OVERLAP_BODY');
    l_body := fnd_message.get;

    result := 'COMPLETE:NO';

  elsif(l_error_code = 'GL_BUDGET_PERIOD_NOT_OPEN_ERR') then

    fnd_message.set_name('PSB','PSB_BR_GL_PERIOD_NOT_OPEN_SUBJ');
    fnd_message.set_token('BUDGET_REVISION_ID',l_budget_revision_id);
    l_subject := fnd_message.get;

    fnd_message.set_name('PSB','PSB_BR_GL_PERIOD_NOT_OPEN_BODY');
    l_body := fnd_message.get;

    result := 'COMPLETE:NO';

  elsif(l_error_code = 'NO_FUNDING_BUDGET_ERR') then

    fnd_message.set_name('PSB','PSB_BR_NO_FUNDING_BUDGET_SUBJ');
    fnd_message.set_token('BUDGET_REVISION_ID',l_budget_revision_id);
    l_subject := fnd_message.get;

    fnd_message.set_name('PSB','PSB_BR_NO_FUNDING_BUDGET_BODY');
    l_body := fnd_message.get;

    result := 'COMPLETE:NO';

  end if;

  if(l_error_code <> 'NO_ERR') then
  wf_engine.SetItemAttrText( ItemType => itemtype,
                             ItemKey  => itemkey,
                             aname    => 'NOTIFICATION_SUBJECT',
                             avalue   => l_subject );

  wf_engine.SetItemAttrText( ItemType => itemtype,
                             ItemKey  => itemkey,
                             aname    => 'NOTIFICATION_BODY',
                             avalue   => l_body );
  end if;
  /* end bug # 4341619 */


 -- commented for bug 4341619
 /*  result := 'COMPLETE:YES' ;
  else
   result := 'COMPLETE:NO' ;
 end if;

 End loop; */


  END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Post_Revisions_To_GL',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

End Post_Revisions_To_GL;

/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                     PROCEDURE Update_View_Line_Flag                       |
 +===========================================================================*/
--
-- The API updates view_line flag for the parent revisions of the submittted
-- revision.
--
PROCEDURE Update_View_Line_Flag
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_budget_revisions_tab    PSB_Create_BR_Pvt.Budget_Revision_Tbl_Type ;
  l_operation_id            NUMBER ;
  --

BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'BUDGET_REVISION_ID');

  l_operation_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'OPERATION_ID');

  --
  -- Find all the parent worksheets to update thier view_line_flag.
  --
  PSB_Create_BR_Pvt.Find_Parent_Budget_Revisions
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_FALSE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_budget_revision_id      =>   l_budget_revision_id,
     p_budget_revision_tbl     =>   l_budget_revisions_tab
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  --
  -- Update view_line_flag for the parent revisions
  --
  FOR i IN 1..l_budget_revisions_tab.COUNT
  LOOP

    --
    -- Update view_line_flags in matrixes for all the lines to 'Y'.
    -- Later we will set the flag to 'N' as per the selection.
    --

    UPDATE psb_budget_revision_lines
    SET    view_line_flag =  'Y'
    WHERE  budget_revision_id   =  l_budget_revisions_tab(i) ;

    UPDATE psb_budget_revision_pos_lines
    SET    view_line_flag     = 'Y'
    WHERE  budget_revision_id = l_budget_revisions_tab(i) ;


  END LOOP ;

  result := 'COMPLETE:YES' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Update_View_Line_Flag',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Update_View_Line_Flag;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Find_Override_Approver                      |
 +===========================================================================*/
--
-- The API finds the  Override_Approver for a Revision.
--
PROCEDURE Find_Override_Approver
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_override_approver         psb_budget_revisions.approval_override_by%TYPE;
  -- For Bug 4475288: Changed l_approver_name length.
  l_approver_name             psb_budget_group_resp.wf_role_name%TYPE;
  l_budget_revision_id        psb_budget_revisions.budget_revision_id%TYPE ;
  l_notification_group_id     NUMBER ;
  -- Added the following variable for bug 3394080
  -- For Bug 4475288: Changed l_approver_display_name length.
  l_approver_display_name     wf_roles.display_name%TYPE;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'BUDGET_REVISION_ID');

   -- Bug#3259142: Use display_name instead of name from wf dir.
   SELECT br.approval_override_by, wr.name,wr.display_name
          INTO
          l_override_approver    , l_approver_name,l_approver_display_name
   FROM   psb_budget_revisions br,
          wf_roles             wr
   WHERE  br.budget_revision_id    = l_budget_revision_id
   AND    br.approval_orig_system  = orig_system(+)
   AND    br.approval_override_by  = orig_system_id(+) ;

 --
  if (l_override_approver is null) then
    result := 'COMPLETE:NO' ;
  ELSE
    result := 'COMPLETE:YES' ;

    wf_engine.SetItemAttrText( ItemType => itemtype,
                               ItemKey  => itemkey,
                               aname    => 'OVERRIDE_APPROVER',
                               avalue   => l_override_approver );

    wf_engine.SetItemAttrText( ItemType => itemtype,
                               ItemKey  => itemkey,
                               aname    => 'APPROVER_NAME',
                               avalue   => l_approver_name );

    -- Added for bug 3394080
    wf_engine.SetItemAttrText( ItemType => itemtype,
                               ItemKey  => itemkey,
                               aname    => 'APPROVER_DISPLAY_NAME',
                               avalue   => l_approver_display_name );
  END IF ;
  --

 END IF ;
 --
 IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;

  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Find_Override_Approver',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Find_Override_Approver;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                        PROCEDURE Send_Approval_Notification               |
 +===========================================================================*/
--
-- The activity finds out whether 'Revision Approved' related notification
-- will be sent to the submitter or not.
--
PROCEDURE Send_Approval_Notification
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_reviewed_flag           VARCHAR2(1) ;
  --
BEGIN

IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get reviewed_flag item_attribute.
  --
  l_reviewed_flag   := wf_engine.GetItemAttrText
                       (  itemtype => itemtype,
                          itemkey  => itemkey,
                          aname    => 'REVIEWED_FLAG' );

  --
  IF NVL( l_reviewed_flag, 'N') = 'N' THEN
    result := 'COMPLETE:NO' ;
  ELSE
    result := 'COMPLETE:YES' ;
  END IF ;
  --

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  result := 'COMPLETE' ;
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Send_Approval_Notification',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Send_Approval_Notification ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Update_Revisions_Status                 |
 +===========================================================================*/
--
-- The API updates submission related information in the submitted revision
-- and all its lower revisions.
--
PROCEDURE Update_Revisions_Status
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_submitter_id            NUMBER ;
  l_submission_status       VARCHAR2(1);
  l_budget_group_id         psb_budget_revisions.budget_group_id%TYPE ;
  l_budget_revisions_tab    PSB_Create_BR_Pvt.Budget_Revision_Tbl_Type ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'BUDGET_REVISION_ID');
  --
  l_submitter_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'SUBMITTER_ID');

  l_submission_status := wf_engine.GetItemAttrText( itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'SUBMISSION_STATUS');
  --
  -- Call API to find all lower level worksheets.
  --
    PSB_Budget_Revisions_Pvt.Create_Budget_Revision
    (
       p_api_version                 => 1.0 ,
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
       p_return_status               => l_return_status,
       p_msg_count                   => l_msg_count,
       p_msg_data                    => l_msg_data ,
       --
       p_budget_revision_id          => l_budget_revision_id,
       p_submission_date             => SYSDATE ,
       p_submission_status           => l_submission_status,
       p_requestor                   => l_submitter_id
    );

    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;

  /*PSB_Create_BR_Pvt.Find_Child_Budget_Revisions
  (
     p_api_version       =>   1.0 ,
     p_init_msg_list     =>   FND_API.G_FALSE,
     p_commit            =>   FND_API.G_FALSE,
     p_validation_level  =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status     =>   l_return_status,
     p_msg_count         =>   l_msg_count,
     p_msg_data          =>   l_msg_data,
     --
     p_budget_revision_id   =>   l_budget_revision_id ,
     p_budget_revision_tbl  =>   l_budget_revisions_tab
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  l_budget_revisions_tab(0) := l_budget_revision_id ;

  --
  -- Processing all lower level Revisions for updation
  --
  FOR i IN 0..l_budget_revisions_tab.COUNT
  LOOP
    --
    -- Update Distribution related information in psb_budget_revisions.
    --
    PSB_Budget_Revisions_Pvt.Create_Budget_Revision
    (
       p_api_version                 => 1.0 ,
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
       p_return_status               => l_return_status,
       p_msg_count                   => l_msg_count,
       p_msg_data                    => l_msg_data ,
       --
       p_budget_revision_id          => l_budget_revisions_tab(i),
       p_submission_date             => SYSDATE ,
       p_submission_status           => l_submission_status,
       p_requestor                   => l_submitter_id
    );

    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --
  END LOOP ; */

  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Update_Revisions_Status',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Update_Revisions_Status ;

/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                     PROCEDURE Update_Baseline_Values                      |
 +===========================================================================*/
--
-- This API updates the base value of the position ftes, position costs and
-- position account distributions after the revision is approved.
--

PROCEDURE Update_Baseline_Values
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_currency_code           VARCHAR2(15);
  --

  -- added cursor for bug 4341619
  Cursor C_global_revision is
    Select global_budget_revision,
           currency_code  -- Bug 3029168
      from psb_budget_revisions
     where budget_revision_id = l_budget_revision_id;

BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'BUDGET_REVISION_ID');
  --
  -- Update the baseline values in Position Control Tables
  -- with the revised value
  -- for the positions.

    /* start bug 4341619 */
    For C_global_revision_rec in C_global_revision
    Loop
      l_currency_code := c_global_revision_rec.currency_code;
      if ((C_global_revision_rec.global_budget_revision is not null) and
          (C_global_revision_rec.global_budget_revision = 'Y')) then
             result := 'COMPLETE:YES' ;
      else
             result := 'COMPLETE:NO' ;
      end if;
    End loop;
    /*  end bug 4341619 */

    IF l_currency_code <> 'STAT' THEN -- Bug 3029168
    PSB_Budget_Revisions_Pvt.Update_Baseline_Values
    (
       p_api_version                 => 1.0 ,
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
       p_return_status               => l_return_status,
       p_msg_count                   => l_msg_count,
       p_msg_data                    => l_msg_data ,
       --
       p_budget_revision_id          => l_budget_revision_id
    );

    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    END IF;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Update_Baseline_Values',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Update_Baseline_Values ;

/*===========================================================================+
 |                     PROCEDURE Funds_Reservation_Update                    |
 +===========================================================================*/
--
-- This API does a funds reservation for each of the accounts affected
-- by the current budget revision
--

PROCEDURE Funds_Reservation_Update
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_fund_check_failures     NUMBER; -- bug#4341619

  l_operation_type          VARCHAR2(20);
  l_called_from             VARCHAR2(8) := 'PSBBGRVS';
  l_currency_code           VARCHAR2(15);
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'BUDGET_REVISION_ID');

  SELECT currency_code INTO l_currency_code
    FROM psb_budget_revisions
   WHERE budget_revision_id = l_budget_revision_id; -- Bug 3029168


 --
 --
  -- Bug#4310411 Start
  l_operation_type := wf_engine.GetItemAttrText
                      (itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'OPERATION_TYPE'
		      );

  IF l_operation_type = 'SUBMIT_REVISION' THEN
    -- Called for Revision Submission.
    l_called_from := 'PSBBR';
  ELSIF l_operation_type = 'VALIDATE_REVISION' THEN
    -- Called from Budget Revision Form to validate
    l_called_from := 'PSBBGRVS';
  ELSIF l_operation_type = 'FREEZE_REVISION' THEN
    -- Called for Budget Revision Form to freeze
    l_called_from := 'PSBBGRVS';
  ELSIF l_operation_type = 'UNFREEZE_REVISION' THEN
    -- Called for Budget Revision Form to unfreeze
    l_called_from := 'PSBBGRVS';
  END IF;
  -- Bug#4310411 End

  -- Bug 3029168 added the following IF condition
  -- funds check should not be called for STAT
  IF l_currency_code <> 'STAT' THEN  -- Bug 3029168

    PSB_Budget_Revisions_Pvt.Budget_Revision_Funds_Check
    (
       p_api_version                 => 1.0 ,
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
       p_return_status               => l_return_status,
       p_msg_count                   => l_msg_count,
       p_msg_data                    => l_msg_data ,
       --
       p_funds_reserve_flag          => 'Y',
       p_budget_revision_id          => l_budget_revision_id ,
       p_fund_check_failures         => l_fund_check_failures, -- Bug4341619
       p_called_from                 => l_called_from          -- Bug#4310411
    );

    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --

    /* start bug 4341619 */
    IF (l_fund_check_failures > 0) THEN
       result := 'COMPLETE:NO' ;
    ELSE
       result := 'COMPLETE:YES' ;
    END IF;
    /* end bug 4341619 */

  ELSE
    result := 'COMPLETE:YES' ;
  END IF;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Funds_Reservation_Update',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Funds_Reservation_Update ;

/*===========================================================================+
 |                     PROCEDURE Select_Approvers                            |
 +===========================================================================*/
--
-- The API finds Approvers for the REvision and then sends notifications
-- to them.
--
PROCEDURE Select_Approvers
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_budget_revision_id        psb_budget_revisions.budget_revision_id%TYPE ;
  l_approver_name             VARCHAR2(80) ;
  l_parent_budget_group_id    psb_budget_revisions.budget_group_id%TYPE ;
  l_notification_group_id     NUMBER ;
  --

BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'BUDGET_REVISION_ID');
  --
  -- Setting context for the CALLBACK procedure.
  --

  g_itemtype             := itemtype ;
  g_itemkey              := itemkey ;
  g_budget_revision_id   := l_budget_revision_id ;

  g_budgetgroup_name := wf_engine.GetItemAttrText
                        (  itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'BUDGET_GROUP_NAME'
                         );

  --
  -- Find the approver role.
  --
  -- Modified the query for bug 3394080
  SELECT nvl(bg.parent_budget_group_id,bg.budget_group_id)
      INTO
         l_parent_budget_group_id
  FROM   psb_budget_revisions  br,
         psb_budget_groups bg
  WHERE  br.budget_revision_id    = l_budget_revision_id
  AND    br.budget_group_id = bg.budget_group_id ;



  FOR l_role_rec IN
  (
     SELECT wf_role_name
     FROM   psb_budget_groups     bg ,
            psb_budget_group_resp resp
     WHERE  bg.budget_group_id       = l_parent_budget_group_id
     AND    resp.responsibility_type = 'N'
     AND    bg.budget_group_id       = resp.budget_group_id
  )
  LOOP
    --
    l_notification_group_id :=
                  WF_Notification.SendGroup
                  (
                     role     => l_role_rec.wf_role_name                  ,
                     msg_type => 'PSBBR'                                  ,
                     msg_name => 'NOTIFY_APPROVERS_OF_SUBMISSION'         ,
                     context  => itemtype ||':'|| itemkey || ':'|| actid  ,
                     callback => 'PSB_Submit_Revision_PVT.Callback'
                  ) ;
  END LOOP ;

  --
END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Select_Approvers',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Select_Approvers ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Unfreeze_Revisions                       |
 +===========================================================================*/
--
-- This API unfreezes the submitted revision. Note that the lower revision
-- are not unfrozen, even though they were frozen during Freeze operation.
--
PROCEDURE Unfreeze_Revisions
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_notification_id         NUMBER ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'BUDGET_REVISION_ID');
  --
  -- Unfreeze only the current worksheet.
  --
  PSB_Create_BR_Pvt.Freeze_Budget_Revision
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_FALSE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_budget_revision_id      =>   l_budget_revision_id,
     p_freeze_flag             =>   'N'
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  result := 'COMPLETE' ;

END IF ;


IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Unfreeze_Revisions',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Unfreeze_Revisions ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                       PROCEDURE Set_Loop_Limit                   |
 +===========================================================================*/
--
-- The API sets 'Loop Limit' attribute for the special 'Loop Counter' activity.
--
PROCEDURE Set_Loop_Limit
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1);
  --
  l_budget_revision_id          psb_budget_revisions.budget_revision_id%TYPE;
  l_budget_group_id             psb_budget_revisions.budget_group_id%TYPE ;
  l_parent_budget_group_id      psb_budget_revisions.budget_group_id%TYPE ;
  l_count                       NUMBER;
  l_init_index                  NUMBER;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id    := wf_engine.GetItemAttrNumber
                       (  itemtype => itemtype,
                          itemkey  => itemkey,
                          aname    => 'BUDGET_REVISION_ID'
                       );

  --
  -- Get budget_group, parent budget group info  for the Revision.
  --

  -- Modified the query for bug 3394080
  SELECT nvl(bg.parent_budget_group_id,bg.budget_group_id)
      INTO
         l_parent_budget_group_id
  FROM   psb_budget_revisions  br,
         psb_budget_groups bg
  WHERE  br.budget_revision_id    = l_budget_revision_id
  AND    br.budget_group_id = bg.budget_group_id ;



 g_num_approvers := 0;

 SELECT count(*)
   INTO g_num_approvers
   FROM psb_budget_group_resp resp
  WHERE resp.budget_group_id in
       (select budget_group_id from psb_budget_groups bg
         start with bg.budget_group_id = l_parent_budget_group_id
        connect by prior bg.parent_budget_group_id = bg.budget_group_id)
    AND resp.responsibility_type = 'N';

  --
  -- Committing as the users on_exit settings may be ROLLBACK.
  --
  COMMIT ;

  wf_engine.SetItemAttrNumber( ItemType => itemtype,
                               ItemKey  => itemkey,
                               aname    => 'LOOP_SET_COUNTER',
                               avalue   => g_num_approvers );
  --
  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Set_Loop_Limit',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Set_Loop_Limit;

PROCEDURE Find_Approver
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2)
IS
  l_return_status           VARCHAR2(1) ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE;
  l_parent_budget_group_id  psb_budget_revisions.budget_group_id%TYPE ;
  l_count                   NUMBER;
  l_loop_visited_counter    NUMBER := 0;
  -- For Bug 4475288: Changed l_approver_name length.
  l_approver_name           VARCHAR2(320);
  -- Added the following variable for bug 3394080
  -- For Bug 4475288: Changed l_approver_display_name length.
  l_approver_display_name   wf_roles.display_name%TYPE;
  l_init_index              NUMBER ;

BEGIN

IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id    := wf_engine.GetItemAttrNumber
                       (  itemtype => itemtype,
                          itemkey  => itemkey,
                          aname    => 'BUDGET_REVISION_ID'
                       );

  l_count              := wf_engine.GetItemAttrNumber
                       (  itemtype => itemtype,
                          itemkey  => itemkey,
                          aname    => 'LOOP_SET_COUNTER'
                       );


  l_loop_visited_counter  :=  wf_engine.GetItemAttrNumber
                              (  itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'LOOP_VISITED_COUNTER'
                              );

   for l_init_index in 1..g_approvers.Count loop
    g_approvers(l_init_index).item_key := null;
    g_approvers(l_init_index).approver_name := null;
    g_approvers(l_init_index).approver_display_name := null;
    g_approvers(l_init_index).sequence := null;
   end loop;

   g_num_approvers := 0;

   -- Modified the query for bug 3394080
   SELECT nvl(bg.parent_budget_group_id,bg.budget_group_id)
     INTO l_parent_budget_group_id
     FROM psb_budget_revisions  br,
          psb_budget_groups bg
    WHERE br.budget_revision_id = l_budget_revision_id
      AND br.budget_group_id = bg.budget_group_id;



   -- Bug#3259142: Use display_name instead of name from wf dir.
   For l_role_rec in
   (
     SELECT bg.bglevel                ,
            resp.budget_group_resp_id ,
            resp.wf_role_name         ,
            wfr.name  name            ,
            wfr.display_name display_name
     FROM   psb_budget_group_resp resp,
            wf_roles               wfr,
            ( SELECT level    bglevel,
                     budget_group_id
              FROM   psb_budget_groups
              START WITH budget_group_id              = l_parent_budget_group_id              CONNECT BY PRIOR parent_budget_group_id = budget_group_id
            )                     bg
      WHERE bg.budget_group_id       = resp.budget_group_id
      AND   resp.responsibility_type = 'N'
      AND   wfr.orig_system          = resp.wf_role_orig_system
      AND   wfr.orig_system_id       = resp.wf_role_orig_system_id
      ORDER BY 1,2
   )
  Loop
  g_num_approvers                            := g_num_approvers + 1;
  g_approvers(g_num_approvers).item_key      := itemkey;
  g_approvers(g_num_approvers).approver_name := l_role_rec.name;
  g_approvers(g_num_approvers).approver_display_name := l_role_rec.display_name;
  g_approvers(g_num_approvers).sequence      := g_num_approvers;
  End loop;

  l_loop_visited_counter := l_loop_visited_counter + 1;

  if ((g_approvers(l_loop_visited_counter).item_key = itemkey) and
      (g_approvers(l_loop_visited_counter).sequence = l_loop_visited_counter))then
  l_approver_name := g_approvers(l_loop_visited_counter).approver_name;
  l_approver_display_name := g_approvers(l_loop_visited_counter).approver_display_name;

  IF l_approver_name IS NULL THEN
    RAISE NO_DATA_FOUND;
  End If;

  wf_engine.SetItemAttrText( ItemType => itemtype,
                               ItemKey  => itemkey,
                               aname    => 'APPROVER_NAME',
                               avalue   => l_approver_name );

  -- Added for bug 3394080
  wf_engine.SetItemAttrText( ItemType => itemtype,
                               ItemKey  => itemkey,
                               aname    => 'APPROVER_DISPLAY_NAME',
                               avalue   => l_approver_display_name );
  end if;


  wf_engine.SetItemAttrNumber( ItemType => ItemType,
                               ItemKey  => ItemKey,
                               aname    => 'LOOP_VISITED_COUNTER',
                               avalue   => l_loop_visited_counter );
  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;


EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    wf_core.context('PSBBR',   'Find_Approver',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Find_Approver',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Find_Approver ;

/*===========================================================================+
 |                        PROCEDURE Set_Reviewed_Flag                        |
 +===========================================================================*/
--
-- The API sets the attribute 'REVIWED_FLAG' to 'Y' as the Approver has
-- reviewed the Revision by now.
--
PROCEDURE Set_Reviewed_Flag
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
BEGIN

IF ( funcmode = 'RUN'  ) THEN

  wf_engine.SetItemAttrText( ItemType => itemtype,
                             ItemKey  => itemkey,
                             aname    => 'REVIEWED_FLAG',
                             avalue   => 'Y' );

  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Set_Reviewed_Flag',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Set_Reviewed_Flag ;

/*===========================================================================+
 |                        PROCEDURE Callback                                 |
 +===========================================================================*/
--
-- The callback API.
--
PROCEDURE Callback
(
  command           IN       VARCHAR2,
  context           IN       VARCHAR2,
  attr_name         IN       VARCHAR2,
  attr_type         IN       VARCHAR2,
  text_value        IN OUT  NOCOPY   VARCHAR2,
  number_value      IN OUT  NOCOPY   NUMBER,
  date_value        IN OUT  NOCOPY   DATE
)
IS
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  --
  l_notification_id    NUMBER ;
  /*For Bug No : 2127425 Start*/
  Cursor C_Justification IS
   SELECT justification
     FROM psb_budget_revisions
    WHERE budget_revision_id = g_budget_revision_id;
  /*For Bug No : 2127425 End*/

BEGIN
--
IF ( command = 'GET'  ) THEN
  --
  IF attr_name = 'BUDGET_REVISION_ID' THEN

    number_value := g_budget_revision_id ;

  ELSIF attr_name = 'BUDGET_GROUP_NAME' THEN

    text_value := g_budgetgroup_name ;

  ELSIF attr_name = 'REQUESTOR_NAME' THEN

    text_value := g_requestor_name ;
  /*For Bug No : 2127425 Start*/
  ELSIF ((attr_name = 'JUSTIFICATION') AND (g_budget_revision_id IS NOT NULL)) THEN

    For C_Justification_Rec in C_Justification Loop
      text_value := C_Justification_Rec.justification;
    End Loop;
  /*For Bug No : 2127425 End*/

  ELSIF attr_name = 'FROM_ROLE' THEN -- bug 2576222

    text_value := nvl(g_user_name,fnd_global.user_name) ;

  END IF ;
  --
END IF ;

/*
IF ( command = 'SET'  ) THEN
  --
  IF attr_name = 'REPLY' THEN
  wf_engine.SetItemAttrText( ItemType => g_itemtype,
                             ItemKey  => g_itemkey,
                             aname    => 'OPERATION_TYPE',
                             avalue   => 'XXX' );

    text_value := 'REPLY' ;
  END IF ;
  --
END IF ;

IF ( command = 'COMPLETE'  ) THEN
  NULL ;
END IF ;
*/

EXCEPTION
  --
  WHEN OTHERS THEN
    RAISE ;

END Callback ;


/*===========================================================================+
 |                        PROCEDURE Start_Distribution_Process                            |
 +===========================================================================*/
--
-- The API creates an instance of the item type 'PSBBR' and start the workflow
-- process 'Distribute Budget Revision'.
--
PROCEDURE Start_Distribution_Process
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_item_key                  IN       NUMBER   ,
  p_distribution_instructions IN       VARCHAR2 ,
  p_recipient_name            IN       VARCHAR2
)
IS
  --
  l_api_name         CONSTANT VARCHAR2(30)   := 'Start_Distribution_Process' ;
  l_api_version      CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_ItemType                VARCHAR2(100) := 'PSBBR' ;
  l_ItemKey                 VARCHAR2(100) := p_item_key ;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;

BEGIN
  --
  SAVEPOINT Start_Distribution_Process_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  WF_Engine.CreateProcess
  (
     ItemType => l_ItemType,
     ItemKey  => l_ItemKey,
     Process  => 'DISTRIBUTE_REVISION'
  );

  --
  -- Get p_item_key related information.
  --
  SELECT worksheet_id INTO l_budget_revision_id
  FROM   psb_workflow_processes
  WHERE  item_key = p_item_key
    AND  document_type  = 'BR';

  --
  -- Set budget_revision_id as the Item User Key for the process.
  --
  WF_Engine.SetItemUserKey
  (
     ItemType => l_ItemType        ,
     ItemKey  => l_ItemKey         ,
     UserKey  => l_budget_revision_id
  );

  --
  WF_Engine.SetItemAttrNumber
  (
     ItemType => l_ItemType,
     ItemKey  => l_itemkey,
     aname    => 'BUDGET_REVISION_ID',
     avalue   => l_budget_revision_id
  );

  --
  WF_Engine.SetItemAttrText
  (
     ItemType => l_ItemType,
     ItemKey  => l_itemkey,
     aname    => 'DISTRIBUTION_INSTRUCTIONS',
     avalue   => p_distribution_instructions
  );

  --
  WF_Engine.SetItemAttrText
  (
     ItemType => l_ItemType,
     ItemKey  => l_itemkey,
     aname    => 'RECIPIENT_NAME',
     avalue   => p_recipient_name
  );

/*Bug:6281823:start*/


  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
			       ItemKey  => l_itemkey,
			       aname    => 'OWNER_ID',
			       avalue   => fnd_global.user_id  );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
			       ItemKey  => l_itemkey,
			       aname    => 'RESP_ID',
			       avalue   => fnd_global.resp_id  );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
			       ItemKey  => l_itemkey,
			       aname    => 'RESP_APPL_ID',
			       avalue   => fnd_global.resp_appl_id  );

  --
/*Bug:6281823:end*/

  --
  WF_Engine.StartProcess
  (
     ItemType => l_ItemType,
     ItemKey  => l_ItemKey
  );

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Start_Distribution_Process_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Start_Distribution_Process_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Start_Distribution_Process_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
     --
END Start_Distribution_Process ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Find_Requestor                           |
 +===========================================================================*/
--
-- The API finds out if the requestor is different from submitter (submitter
-- indicates the set of users assigned to the role associated to the
-- budget group .
--
PROCEDURE Find_Requestor
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)

IS

 l_requestor_name            VARCHAR2(100);
 l_submitter_name            VARCHAR2(80);

BEGIN

IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get Requestor Name item_attribute.
  --
  l_requestor_name := WF_Engine.GetItemAttrNumber
                    (
                       itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'REQUESTOR_NAME'
                    );

  l_submitter_name := WF_Engine.GetItemAttrNumber
                    (
                       itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'SUBMITTER_NAME'
                    );

  if (l_requestor_name = l_submitter_name) then
    result := 'COMPLETE:NO' ;
  else
    result := 'COMPLETE:YES' ;
  end if;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Find Requestor',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

End Find_Requestor;

/*===========================================================================+
 |                        PROCEDURE Populate_Distribute_Revision             |
 +===========================================================================*/
--
-- The API populates the item attribues of the item type 'PSBBR'.
--
PROCEDURE Populate_Distribute_Revision
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_budget_revision_id psb_budget_revisions.budget_revision_id%TYPE ;
  l_budget_group_name  psb_budget_groups.name%TYPE ;
  l_recipient_name     VARCHAR2(2000);
  l_user_name          VARCHAR2(100);
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN

  /* Bug 2576222 Start */
  l_user_name := fnd_global.user_name;
  /* Bug 2576222 End */
  --
  -- Get budget_revision_id item_attribute.
  --
  l_budget_revision_id := WF_Engine.GetItemAttrNumber
                    (
                       itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'BUDGET_REVISION_ID'
                    );

  --
  -- Finding Revision information.
  --
  SELECT budget_group_name
    INTO l_budget_group_name
    FROM psb_budget_revisions_v
   WHERE budget_revision_id = l_budget_revision_id;

  --
  WF_Engine.SetItemAttrText
  (
     itemtype => itemtype,
     itemkey  => itemkey,
     aname    => 'BUDGET_GROUP_NAME',
     avalue   => l_budget_group_name
  );

  /* Bug 2576222 Start */
  wf_engine.SetItemAttrtext( ItemType => ItemType,
			       ItemKey  => Itemkey,
			       aname    => 'FROM_ROLE',
			       avalue   => l_user_name );
  /* Bug 2576222 End */

  result := 'COMPLETE' ;

END IF ;
--

IF ( funcmode = 'CANCEL' ) THEN
  result := 'COMPLETE' ;
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  result := '' ;
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Populate_Distribute_Revision',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Populate_Distribute_Revision ;


PROCEDURE Set_Approval_Status
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
)
IS
BEGIN

IF ( funcmode = 'RUN'  ) THEN

  wf_engine.SetItemAttrText( ItemType => itemtype,
                             ItemKey  => itemkey,
                             aname    => 'SUBMISSION_STATUS',
                             avalue   => 'A' );
  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Set_Approval_status',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Set_Approval_Status;

PROCEDURE Set_Rejection_Status
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
)
IS
BEGIN

IF ( funcmode = 'RUN'  ) THEN

  wf_engine.SetItemAttrText( ItemType => itemtype,
                             ItemKey  => itemkey,
                             aname    => 'SUBMISSION_STATUS',
                             avalue   => 'R' );
  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

--
-- In future implementations, appropriate code is to be inserted here.
--
IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
  --
  result := '' ;
  --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',   'Set_Rejaection_Status',
                     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Set_Rejection_Status ;

/*===========================================================================+
 |                        PROCEDURE Validate_Revision_Rules                   |
 +===========================================================================*/
-- Used for Validating budget revision rules
--
PROCEDURE Validate_Revision_Rules
(
  itemtype          IN    VARCHAR2,
  itemkey           IN    VARCHAR2,
  actid             IN    NUMBER,
  funcmode          IN    VARCHAR2,
  result            OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  --
  l_budget_revision_id          NUMBER(20);
  l_validation_status           VARCHAR2(1);
  l_operation_type              VARCHAR2(20);
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  l_budget_revision_id := wf_engine.GetItemAttrNumber
                                (
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'BUDGET_REVISION_ID'
                                );

  l_operation_type := wf_engine.GetItemAttrText
                                (
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'OPERATION_TYPE'
                                );


  PSB_Budget_Revisions_PVT.Apply_Revision_Rules
  (
    p_api_version             =>   1.0,
    p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
    p_return_status           =>   l_return_status,
    p_validation_status       =>   l_validation_status,
    p_budget_revision_id      =>   l_budget_revision_id
  );
  --

  IF l_validation_status = 'F' THEN
  --
    result := 'COMPLETE:FAIL' ;
  --
  ELSE
  --
    result := 'COMPLETE:SUCCESS' ;
  --
  END IF ;

ELSIF (funcmode = 'CANCEL' ) THEN
--
 result := 'COMPLETE' ;
 --
ELSIF (funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
--
 result := '' ;
 --
END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    wf_core.context('PSBBR',
                    'Validate_Revision_Rules',
                     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE;

END Validate_Revision_Rules;


/*Bug:6281823:start*/

procedure Selector(itemtype    in  varchar2,
                   itemkey     in  varchar2,
                   actid       in  number,
                   command     in  varchar2,
                   resultout   out nocopy varchar2)
IS

ownerID     number;
respID      number;
respAppID   number;

BEGIN



IF (command = 'SET_CTX') THEN

  ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                                         Itemkey => ItemKey,
                                         aname => 'OWNER_ID');

  respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                                        Itemkey => ItemKey,
                                        aname => 'RESP_ID');

  respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                                           Itemkey => ItemKey,
                                           aname => 'RESP_APPL_ID');


  fnd_global.apps_initialize(ownerID, respID, RespAppId);

  resultout := 'COMPLETE';
  return;

ELSIF(command = 'TEST_CTX') THEN

  ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                                         Itemkey => ItemKey,
                                         aname => 'OWNER_ID');

  respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                                        Itemkey => ItemKey,
                                        aname => 'RESP_ID');

  respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                                           Itemkey => ItemKey,
                                           aname => 'RESP_APPL_ID');

  fnd_global.apps_initialize(ownerID, respID, RespAppId);

  return;

ELSE

 resultout := 'COMPLETE';
 return;

END IF;
EXCEPTION
   when others then
     WF_CORE.CONTEXT('PSB_Submit_Revision_PVT.Selector', itemtype, itemkey,
         to_char(actid), command);
     raise;
end Selector;

/*Bug:6281823:end*/


/*---------------------------------------------------------------------------*/

END PSB_Submit_Revision_PVT;

/
