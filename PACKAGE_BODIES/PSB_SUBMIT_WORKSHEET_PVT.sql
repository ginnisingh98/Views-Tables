--------------------------------------------------------
--  DDL for Package Body PSB_SUBMIT_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_SUBMIT_WORKSHEET_PVT" AS
/* $Header: PSBWSSPB.pls 120.8.12010000.4 2010/02/15 12:29:07 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30)  := 'PSB_Submit_Worksheet_PVT';

/*--------------------------- Global variables -----------------------------*/

  --
  -- CALLBACK procedure related global information.
  --
  g_worksheet_id           psb_worksheets.worksheet_id%TYPE ;
  g_worksheet_name         psb_worksheets.name%TYPE ;
  g_budget_group_name      psb_budget_groups.name%TYPE ;
  g_itemtype               VARCHAR2(2000) ;
  g_itemkey                VARCHAR2(2000) ;

  -- WHO columns variables
  g_current_date           DATE   := sysdate                       ;
  g_current_user_id        NUMBER := NVL( Fnd_Global.User_Id  , 0) ;
  g_current_login_id       NUMBER := NVL( Fnd_Global.Login_Id , 0) ;
  g_user_name              VARCHAR2(100);

/*----------------------- End Global variables -----------------------------*/


/*===========================================================================+
 |                        PROCEDURE Start_Process                            |
 +===========================================================================*/
--
-- The API creates an instance of the item type 'PSBWS' and starts the workflow
-- process 'Submit Worksheet'.
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
  p_review_group_flag         IN       VARCHAR2 := 'N',
  p_orig_system               IN       VARCHAR2 ,
  p_merge_to_worksheet_id     IN       psb_worksheets.worksheet_id%TYPE ,
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
  l_ItemType                VARCHAR2(100) := 'PSBWS';
  l_ItemKey                 VARCHAR2(240) := p_item_key;
  --
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_comments                VARCHAR2(2000) ;
  --
BEGIN
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
  SELECT worksheet_id INTO l_worksheet_id
  FROM   psb_workflow_processes
  WHERE  item_key = p_item_key ;


  wf_engine.CreateProcess ( ItemType => l_ItemType,
			    ItemKey  => l_ItemKey,
			    Process  => 'SUBMIT_WORKSHEET' );

  --
  -- Set worksheet_id as the Item User Key for the process.
  --
  WF_Engine.SetItemUserKey
  (
     ItemType => l_ItemType        ,
     ItemKey  => l_ItemKey         ,
     UserKey  => l_worksheet_id
  );

  --
  -- Populate item type.
  --
  wf_engine.SetItemAttrNumber( ItemType => l_ItemType,
			       ItemKey  => l_itemkey,
			       aname    => 'WORKSHEET_ID',
			       avalue   => l_worksheet_id );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_ItemType,
			       ItemKey  => l_itemkey,
			       aname    => 'LOOP_VISITED_COUNTER',
			       avalue   => 0 );
  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
			     ItemKey  => l_itemkey,
			     aname    => 'SUBMITTER_ID',
			     avalue   => p_submitter_id );

  /* Bug 2576222 Start */
  wf_engine.SetItemAttrtext( ItemType => l_ItemType,
			       ItemKey  => l_itemkey,
			       aname    => 'FROM_ROLE',
			       avalue   => g_user_name );
  /* Bug 2576222 End */

  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
			     ItemKey  => l_itemkey,
			     aname    => 'SUBMITTER_NAME',
			     avalue   => p_submitter_name );
  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
			     ItemKey  => l_itemkey,
			     aname    => 'OPERATION_TYPE',
			     avalue   => p_operation_type );
  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
			     ItemKey  => l_itemkey,
			     aname    => 'REVIEW_GROUP_FLAG',
			     avalue   => p_review_group_flag );
  --
  wf_engine.SetItemAttrText( ItemType => l_itemtype,
			     ItemKey  => l_itemkey,
			     aname    => 'ORIG_SYSTEM',
			     avalue   => p_orig_system );
  --
  wf_engine.SetItemAttrNumber( ItemType => l_itemtype,
			       ItemKey  => l_itemkey,
			       aname    => 'MERGE_TO_WORKSHEET_ID',
			       avalue   => p_merge_to_worksheet_id );
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
 |                        PROCEDURE Populate_Worksheet                       |
 +===========================================================================*/
--
-- The API populates the item attribues  of the item type 'PSBWS'.
-- ( The SUBMITTER_NAME is populated by the interface API 'PSBWKFLB.pls'.)
--
PROCEDURE Populate_Worksheet
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_worksheet_id       psb_worksheets.worksheet_id%TYPE ;
  l_worksheet_name     psb_worksheets.name%TYPE ;
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
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');

  --
  -- Finding worksheet information.
  --
  SELECT name ,
	 budget_group_name
       INTO
	 l_worksheet_name ,
	 l_budget_group_name
  FROM   psb_worksheets_v
  WHERE  worksheet_id = l_worksheet_id;

  --
  wf_engine.SetItemAttrText ( itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'WORKSHEET_NAME',
			      avalue   => l_worksheet_name  );
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
    wf_core.context('PSBWS',   'Populate_Worksheet',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Populate_Worksheet ;
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
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_operation_type          VARCHAR2(20) ;
  --
BEGIN

l_return_status := FND_API.G_RET_STS_SUCCESS ;

IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get operation_type item_attribute.
  --
  l_worksheet_id   := wf_engine.GetItemAttrNumber
		      (  itemtype => itemtype,
			 itemkey  => itemkey,
			 aname    => 'WORKSHEET_ID' );

  l_operation_type := wf_engine.GetItemAttrText
		      (  itemtype => itemtype,
			 itemkey  => itemkey,
			 aname    => 'OPERATION_TYPE' );
  --
  -- API to perform worksheet related concurrency control.
  --
  PSB_WS_Ops_Pvt.Check_WS_Ops_Concurrency
  (
     p_api_version              =>  1.0,
     p_init_msg_list            =>  FND_API.G_FALSE ,
     p_commit                   =>  FND_API.G_FALSE ,
     p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
     p_return_status            =>  l_return_status,
     p_msg_count                =>  l_msg_count,
     p_msg_data                 =>  l_msg_data,
     --
     p_worksheet_id             =>  l_worksheet_id ,
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
    wf_core.context('PSBWS',   'Enforce_Concurrency_Check',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Enforce_Concurrency_Check ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Perform_Validation                       |
 +===========================================================================*/
--
-- The API checks whether worksheet validation is required or not.
--
PROCEDURE Perform_Validation
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_operation_type          VARCHAR2(20) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get operation_type item_attribute.
  --
  l_operation_type := wf_engine.GetItemAttrText
		      (  itemtype => itemtype,
			 itemkey  => itemkey,
			 aname    => 'OPERATION_TYPE' );

  IF l_operation_type IN ('COPY', 'MERGE') THEN
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
    wf_core.context('PSBWS',   'Perform_Validation',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Perform_Validation ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Validate_Constraints                     |
 +===========================================================================*/
--
-- The API calls worksheet validation API. If the validation fails, the
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
  l_worksheet_id               psb_worksheets.worksheet_id%TYPE ;
  l_validation_status          VARCHAR2(1) ;
  l_operation_type             VARCHAR2(20) ;
  l_constraint_set_id          NUMBER ;
  --
BEGIN

IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');

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

 /*Bug:5983416: Added 'FREEZE', 'UNFREEZE' in the below condition.
   Hence, Constraints will not get applied during freeze and
   unfreeze operations */

  IF l_operation_type IN ('COPY', 'MERGE', 'FREEZE','UNFREEZE') THEN
    --
    result := 'COMPLETE:SUCCESS' ;
    RETURN ;
    --
  END IF ;

  -- /* **** For testing.

  --
  -- Call the API to validate the worksheet.
  --
  PSB_Worksheet_Pvt.Apply_Constraints
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_FALSE ,
     p_commit                  =>   FND_API.G_FALSE ,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL ,
     p_return_status           =>   l_return_status ,
     p_validation_status       =>   l_validation_status ,
     p_msg_count               =>   l_msg_count ,
     p_msg_data                =>   l_msg_data ,
     --
     p_worksheet_id            =>   l_worksheet_id ,
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
    wf_core.context('PSBWS',   'Validate_Constraints',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Validate_Constraints ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Select_Operation                         |
 +===========================================================================*/
--
-- The API selects the operation to be performed on the worksheet. The
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
  l_worksheet_id       psb_worksheets.worksheet_id%TYPE ;
  l_operation_type     VARCHAR2(20) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');
  --
  l_operation_type := wf_engine.GetItemAttrText( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'OPERATION_TYPE');
  --
  -- Operation_type item attribute determines what operation is to
  -- be performed on the worksheet.
  --
  IF l_operation_type = 'COPY' THEN
    --
    result := 'COMPLETE:COPY' ;
    --
  ELSIF l_operation_type = 'MERGE' THEN
    --
    result := 'COMPLETE:MERGE' ;
    --
  ELSIF l_operation_type = 'VALIDATE' THEN
    --
    result := 'COMPLETE:VALIDATE' ;
    --
  ELSIF l_operation_type = 'FREEZE' THEN
    --
    result := 'COMPLETE:FREEZE' ;
    --
  ELSIF l_operation_type = 'UNFREEZE' THEN
    --
    result := 'COMPLETE:UNFREEZE' ;
    --
  ELSIF l_operation_type = 'MOVE' THEN
    --
    result := 'COMPLETE:MOVE' ;
    --
  ELSIF l_operation_type = 'SUBMIT' THEN
    --
    result := 'COMPLETE:SUBMIT' ;
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
    wf_core.context('PSBWS',   'Select_Operation',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Select_Operation ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Copy_Worksheet                           |
 +===========================================================================*/
--
-- The API calls a program to make a copy of the submitted worksheet.
--
PROCEDURE Copy_Worksheet
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
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_new_worksheet_id        psb_worksheets.worksheet_id%TYPE ;
  l_worksheet_name          psb_worksheets.name%TYPE ;
  l_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_current_freeze_flag     psb_worksheets.freeze_flag%TYPE ;
  l_worksheets_tab          PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;

  --
  l_notification_id    NUMBER ;
  l_submitter_name     VARCHAR2(80);
  l_operation_type     VARCHAR2(20) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');

  --
  -- Call the API.
  --
  PSB_WS_Ops_Pvt.Copy_Worksheet
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_TRUE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_worksheet_id            =>   l_worksheet_id,
     p_worksheet_id_OUT        =>   l_new_worksheet_id
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  --
  -- Set COPY_WORKSHEET_ID item attribute.
  --
  wf_engine.SetItemAttrNumber( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'COPY_WORKSHEET_ID',
			       avalue   => l_new_worksheet_id   );
  --

  result := 'COMPLETE' ;

END IF ;

IF ( funcmode = 'CANCEL' ) THEN
  --
  result := 'COMPLETE' ;
  --
END IF;

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
    wf_core.context('PSBWS',   'Copy_Worksheet',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Copy_Worksheet ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Merge_Worksheets                         |
 +===========================================================================*/
--
-- The API calls a program to merge the given worksheets.
--
PROCEDURE Merge_Worksheets
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
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_merge_to_worksheet_id   psb_worksheets.worksheet_id%TYPE ;
  l_worksheet_name          psb_worksheets.name%TYPE ;
  l_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_current_freeze_flag     psb_worksheets.freeze_flag%TYPE ;
  l_worksheets_tab          PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;

  --
  l_notification_id    NUMBER ;
  l_submitter_name     VARCHAR2(80);
  l_operation_type     VARCHAR2(20) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber
		    (
		       itemtype => itemtype,
		       itemkey  => itemkey,
		       aname    => 'WORKSHEET_ID'
		    );
  --
  l_merge_to_worksheet_id := wf_engine.GetItemAttrNumber
			     (
				itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'MERGE_TO_WORKSHEET_ID'
			     );
  --

  --
  -- Call the API.
  --
  PSB_WS_Ops_Pvt.Merge_Worksheets
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_TRUE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_source_worksheet_id     =>   l_worksheet_id,
     p_target_worksheet_id     =>   l_merge_to_worksheet_id
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
    wf_core.context('PSBWS',   'Merge_Worksheets',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Merge_Worksheets ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Freeze_Worksheets                        |
 +===========================================================================*/
--
-- The API freezes the submitted worksheet and all its lower worksheets.
--
PROCEDURE Freeze_Worksheets
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
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_worksheet_name          psb_worksheets.name%TYPE ;
  l_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_current_freeze_flag     psb_worksheets.freeze_flag%TYPE ;
  l_worksheets_tab          PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;

  --
  l_notification_id    NUMBER ;
  l_submitter_name     VARCHAR2(80);
  l_operation_type     VARCHAR2(20) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item attribute.
  --
  l_worksheet_id   := wf_engine.GetItemAttrNumber
		      (  itemtype => itemtype,
			 itemkey  => itemkey,
			 aname    => 'WORKSHEET_ID');
  --
  g_worksheet_name := wf_engine.GetItemAttrText
		      (  itemtype => itemtype,
			 itemkey  => itemkey,
			 aname    => 'WORKSHEET_NAME');
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
  /*Bug:6937191:modified query*/
  SELECT budget_group_name,name INTO
         g_budget_group_name, g_worksheet_name
  FROM   psb_worksheets_v
  WHERE  worksheet_id = l_worksheet_id ;

  g_worksheet_id     := l_worksheet_id ;
  g_itemtype         := itemtype ;
  g_itemkey          := itemkey ;

  --
  -- Freeze the top level worksheet.
  --
  PSB_WS_Ops_Pvt.Freeze_Worksheet
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_FALSE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_worksheet_id            =>   l_worksheet_id ,
     p_freeze_flag             =>   'Y'
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  --
  -- Send 'NOTIFY_OF_FREEZE_COMPLETION' notification to the top level budget
  -- group users. To be done for operation_type 'MOVE' and 'SUBMIT'.
  --
  IF l_operation_type IN ('MOVE', 'SUBMIT') THEN
    --
    l_notification_id :=
	       WF_Notification.SendGroup
	       (  role     => l_submitter_name                          ,
		  msg_type => 'PSBWS'                                   ,
		  msg_name => 'NOTIFY_OF_FREEZE_COMPLETION'             ,
		  context  => itemtype ||':'|| itemkey ||':'|| actid    ,
		  callback => 'PSB_Submit_Worksheet_PVT.Callback'
		) ;
  END IF ;

  --
  -- Call API to find all lower level worksheets.
  --
  PSB_WS_Ops_Pvt.Find_Child_Worksheets
  (
     p_api_version        =>   1.0 ,
     p_init_msg_list      =>   FND_API.G_FALSE,
     p_commit             =>   FND_API.G_FALSE,
     p_validation_level   =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status      =>   l_return_status,
     p_msg_count          =>   l_msg_count,
     p_msg_data           =>   l_msg_data,
     --
     p_worksheet_id       =>   l_worksheet_id,
     p_worksheet_tbl      =>   l_worksheets_tab
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  --
  -- Freeze all lower level worksheets
  --
  FOR i IN 1..l_worksheets_tab.COUNT
  LOOP
    --
    -- Check whether the current worksheet is already frozen or not.
    -- If already frozen, do not have to do anything.
    --
    SELECT NVL(freeze_flag, 'N')  INTO l_current_freeze_flag
    FROM   psb_worksheets
    WHERE  worksheet_id = l_worksheets_tab(i) ;

    IF l_current_freeze_flag = 'N' THEN
      --
      PSB_WS_Ops_Pvt.Freeze_Worksheet
      (
	 p_api_version             =>   1.0 ,
	 p_init_msg_list           =>   FND_API.G_FALSE,
	 p_commit                  =>   FND_API.G_FALSE,
	 p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
	 p_return_status           =>   l_return_status,
	 p_msg_count               =>   l_msg_count,
	 p_msg_data                =>   l_msg_data,
	 --
	 p_worksheet_id            =>   l_worksheets_tab(i) ,
	 p_freeze_flag             =>   'Y'
      );
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;
      --

      --
      -- Find budget_group_id and worksheet_name for the worksheet to find
      -- workflow roles and to set up context info for the CALLBACK procedure.
      --
      SELECT budget_group_id   ,
	     budget_group_name ,
	     name
	INTO
	     l_budget_group_id   ,
	     g_budget_group_name ,
	     g_worksheet_name
      FROM   psb_worksheets_v
      WHERE  worksheet_id = l_worksheets_tab(i) ;

      g_worksheet_id := l_worksheets_tab(i) ;

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
		      msg_type => 'PSBWS'                                 ,
		      msg_name => 'NOTIFY_OF_FREEZE_COMPLETION'           ,
		      context  => itemtype ||':'|| itemkey ||':'|| actid  ,
		      callback => 'PSB_Submit_Worksheet_PVT.Callback'
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
    wf_core.context('PSBWS',   'Freeze_Worksheets',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Freeze_Worksheets ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Update_View_Line_Flag                       |
 +===========================================================================*/
--
-- API updates view_line flag for all parent worksheets of the submittted
-- worksheet as per the service package selection.
--
PROCEDURE Update_View_Line_Flag
(
  itemtype                    IN         VARCHAR2,
  itemkey                     IN         VARCHAR2,
  actid                       IN         NUMBER,
  funcmode                    IN         VARCHAR2,
  result                      OUT NOCOPY VARCHAR2
)
IS
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_worksheets_tab          PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;
  l_operation_id            NUMBER ;
  l_service_package_count   NUMBER ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');

  l_operation_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'OPERATION_ID');

  -- Check if this is a position worksheet.
  SELECT NVL( budget_by_position, 'N') INTO l_budget_by_position
  FROM   psb_worksheets
  WHERE  worksheet_id = l_worksheet_id ;

  -- Note when a user starts submission process without clickin on service
  -- package button, this means all service packages are being selected
  -- even though psb_ws_submit_service_packages will have no records in it.
  SELECT COUNT(*) INTO l_service_package_count
  FROM   dual
  WHERE  EXISTS
         ( SELECT 1
           FROM   psb_ws_submit_service_packages
           WHERE  worksheet_id = l_worksheet_id
           AND    operation_id = l_operation_id ) ;

  -- Get all parent worksheets for the selected worksheet.
  PSB_WS_Ops_Pvt.Find_Parent_Worksheets
  (
     p_api_version        =>   1.0 ,
     p_init_msg_list      =>   FND_API.G_FALSE,
     p_commit             =>   FND_API.G_FALSE,
     p_validation_level   =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status      =>   l_return_status,
     p_msg_count          =>   l_msg_count,
     p_msg_data           =>   l_msg_data,
     --
     p_worksheet_id       =>   l_worksheet_id,
     p_worksheet_tbl      =>   l_worksheets_tab
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  --
  -- Update view_line_flag for all parent worksheets.
  --
  FOR i IN 1..l_worksheets_tab.COUNT
  LOOP

    -- Bug#3124025: Update view_line_flag for the current parent worksheet in
    -- line matrix table as per service package selection. Note using COUNT
    -- is fine as it will always return either 0 or 1.
    UPDATE psb_ws_lines lines
    SET    lines.view_line_flag =
                      ( SELECT DECODE( COUNT(*), 0, 'N', 'Y' )
                        FROM   psb_ws_account_lines accts
                        WHERE  accts.account_line_id = lines.account_line_id
                        AND    ( l_service_package_count = 0
                                 OR
                                 accts.service_package_id IN
                                 (
                                   SELECT ssp.service_package_id
                                   FROM   psb_ws_submit_service_packages ssp
                                   WHERE  ssp.worksheet_id = l_worksheet_id
                                   AND    ssp.operation_id = l_operation_id
                                 )
                               )
                      )
    WHERE  lines.worksheet_id = l_worksheets_tab(i)
    AND    EXISTS
           ( SELECT 1
             FROM   psb_ws_lines pwl
             WHERE  pwl.account_line_id = lines.account_line_id
             AND    pwl.worksheet_id    = l_worksheet_id
           ) ;

    /*
    -- Bug#3124025: Commenting and now using prior query.
    UPDATE psb_ws_lines lines
    SET    lines.view_line_flag = 'N'
    WHERE  lines.worksheet_id   = l_worksheets_tab(i)
    AND    EXISTS
           (
             SELECT accts.account_line_id
	     FROM   psb_ws_account_lines accts
	     WHERE  accts.account_line_id = lines.account_line_id
	     AND    accts.service_package_id NOT IN
	            (
                      SELECT service_package_id
                      FROM   psb_ws_submit_service_packages
                      WHERE  worksheet_id = l_worksheet_id
                      AND    operation_id = l_operation_id
	            )
           ) ;
    */

    -- Bug#3124025: Update view_line_flag for the current parent worksheet in
    -- position matrix table as per service package selection.
    IF l_budget_by_position = 'Y' THEN

      --
      -- Bug#3124025: The positions are always associated with BASE service
      -- package. Now when a worksheet is submitted, the BASE is always
      -- selected. This means psb_ws_lines_positions.view_line_flag has got
      -- to be always "Y". Using this defensive (fixing) query. We may comment
      -- out this query later on.
      --
      UPDATE psb_ws_lines_positions lines
      SET    lines.view_line_flag =  'Y'
      WHERE  lines.worksheet_id   =  l_worksheets_tab(i)
      AND    ( lines.view_line_flag IS NULL OR lines.view_line_flag = 'N' )
      AND    EXISTS
             ( SELECT 1
               FROM   psb_ws_lines_positions pwl
               WHERE  pwl.position_line_id = lines.position_line_id
               AND    pwl.worksheet_id     = l_worksheet_id
             ) ;

      /*
      -- Bug#3124025: Commenting the potential new query and using prior query.
      UPDATE psb_ws_lines_positions lines
      SET    lines.view_line_flag =
             ( DECODE ( ( SELECT COUNT(*)
                          FROM   psb_ws_account_lines accts
                          WHERE  accts.position_line_id = lines.position_line_id
                          AND    ( l_service_package_count = 0
                                   OR
                                   accts.service_package_id IN
                                   (
                                     SELECT ssp.service_package_id
                                     FROM   psb_ws_submit_service_packages ssp
                                     WHERE  ssp.worksheet_id = l_worksheet_id
                                     AND    ssp.operation_id = l_operation_id
                                   )
                                 )
                        ),
                        0, 'N', 'Y'
                      )
             )
      WHERE  lines.worksheet_id = l_worksheets_tab(i)
      AND    EXISTS
             ( SELECT 1
               FROM   psb_ws_lines_positions pwl
               WHERE  pwl.position_line_id = lines.position_line_id
               AND    pwl.worksheet_id     = l_worksheet_id
             ) ;

      -- Bug#3124025: Commenting the original query and now using prior query.
      UPDATE psb_ws_lines_positions lines
      SET    view_line_flag     = 'N'
      WHERE  lines.worksheet_id = l_worksheets_tab(i)
      AND    lines.position_line_id IN
	     (
	       SELECT accts.position_line_id
	       FROM   psb_ws_lines          lines ,
		      psb_ws_account_lines  accts
	       WHERE  lines.worksheet_id    = l_worksheets_tab(i)
	       AND    lines.account_line_id = accts.account_line_id
	       AND    accts.service_package_id NOT IN
		      (
                        SELECT ssp.service_package_id
                        FROM   psb_ws_submit_service_packages  ssp
                        WHERE  ssp.worksheet_id = l_worksheet_id
                        AND    ssp.operation_id = l_operation_id
                      )
             ) ;
      */
      --
    END IF ;
    -- End updating view_line_flag for the current parent worksheet in
    -- position matrix table as per service package selection.

  END LOOP ;
  -- End updating view_line_flag for all parent worksheets.

  result := 'COMPLETE:YES' ;

END IF ;

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
    wf_core.context('PSBWS',   'Update_View_Line_Flag',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;
    --
END Update_View_Line_Flag;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Change_Worksheet_Stage                   |
 +===========================================================================*/
--
-- The API changes the stage of a worksheet and all its lower worksheets.
--
PROCEDURE Change_Worksheet_Stage
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
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_worksheets_tab          PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;
  --
  l_notification_id         NUMBER ;
  l_stage_set_id            psb_worksheets.stage_set_id%TYPE ;
  l_target_stage_seq        psb_worksheets.current_stage_seq%TYPE ;
  l_current_stage_seq       psb_worksheets.current_stage_seq%TYPE ;
  l_operation_id            NUMBER ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');

  l_operation_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'OPERATION_ID');
  --
  -- Setting context for the CALLBACK procedure.
  --
  g_itemtype         := itemtype ;
  g_itemkey          := itemkey ;

  --
  -- Find next stage_id for the given worksheet l_target_stage_seq.
  --
  SELECT stage_set_id ,
	 current_stage_seq
     INTO
	 l_stage_set_id ,
	 l_current_stage_seq
  FROM   psb_worksheets
  WHERE  worksheet_id = l_worksheet_id ;

  SELECT MIN (sequence_number) INTO l_target_stage_seq
  FROM   psb_budget_stages
  WHERE  budget_stage_set_id = l_stage_set_id
  AND    sequence_number     > l_current_stage_seq
  ORDER  BY sequence_number ;

  --
  -- If l_target_stage_seq is NULL means the worksheet is already at
  -- its highest stage. Simply return with status 'COMPLETE'.
  --
  IF l_target_stage_seq IS NULL THEN
    result := 'COMPLETE' ;
    RETURN ;
  END IF ;

  --
  -- Change the stage of the current worksheet.
  --
  PSB_WS_Ops_Pvt.Change_Worksheet_Stage
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_FALSE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_worksheet_id            =>   l_worksheet_id ,
     p_stage_seq               =>   l_target_stage_seq ,
     p_operation_id            =>   l_operation_id
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  --
  -- Find all the child worksheets as they may also be advanced to
  -- next stages depening on their current stage.
  --
  PSB_WS_Ops_Pvt.Find_Child_Worksheets
  (
     p_api_version        =>   1.0 ,
     p_init_msg_list      =>   FND_API.G_FALSE,
     p_commit             =>   FND_API.G_FALSE,
     p_validation_level   =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status      =>   l_return_status,
     p_msg_count          =>   l_msg_count,
     p_msg_data           =>   l_msg_data,
     --
     p_worksheet_id       =>   l_worksheet_id,
     p_worksheet_tbl      =>   l_worksheets_tab
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  --
  -- Processing all lower level worksheets
  --
  FOR i IN 1..l_worksheets_tab.COUNT
  LOOP
    --
    -- Find current_stage_seq for the current worksheet.
    --
    SELECT current_stage_seq INTO l_current_stage_seq
    FROM   psb_worksheets
    WHERE  worksheet_id = l_worksheets_tab(i) ;

    --
    -- Advance the current worksheet to its next stage only when it is
    -- at the lower stage.
    --
    IF l_target_stage_seq > l_current_stage_seq THEN
      --
      PSB_Worksheet_Pvt.Update_Worksheet
      (
	p_api_version           => 1.0 ,
	p_init_msg_list         => FND_API.G_FALSE,
	p_commit                => FND_API.G_FALSE,
	p_validation_level      => FND_API.G_VALID_LEVEL_NONE,
	p_return_status         => l_return_status,
	p_msg_count             => l_msg_count,
	p_msg_data              => l_msg_data,
	--
	p_worksheet_id          => l_worksheets_tab(i) ,
	p_current_stage_seq     => l_target_stage_seq
      ) ;
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;
      --

      --
      -- Find budget_group_id,budget_group_name and worksheet_name for the worksheet to find
      -- workflow roles and to set up context info for the CALLBACK procedure.
      --
      /*bug:6937191:modified query to fetch budget_group_name */
      SELECT budget_group_id ,
             budget_group_name,
	     name
	INTO
	     l_budget_group_id ,
	     g_budget_group_name,
	     g_worksheet_name
      FROM   psb_worksheets_v
      WHERE  worksheet_id = l_worksheets_tab(i) ;

      g_worksheet_id := l_worksheets_tab(i) ; --bug:6937191

      --
      -- Send 'Worksheet Stage Moved' related notifications to the budget
      -- group users.
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
		   (  role     => l_role_rec.wf_role_name                   ,
		      msg_type => 'PSBWS'                                   ,
		      msg_name => 'NOTIFY_OF_WS_MOVE_COMPLETION'            ,
		      context  => itemtype ||':'|| itemkey ||':'|| actid    ,
		      callback => 'PSB_Submit_Worksheet_PVT.Callback'
		    ) ;
      END LOOP ;
      --
    END IF ;

  END LOOP ;

  result := 'COMPLETE' ;

END IF ;

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
    wf_core.context('PSBWS',   'Change_Worksheet_Stage',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Change_Worksheet_Stage ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Perform_Review_Group_Approval                 |
 +===========================================================================*/
--
-- The API checks whether review group approval is needed or not.
--
PROCEDURE Perform_Review_Group_Approval
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_review_group_flag   VARCHAR2(1) ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get value of l_review_group_flag attribute to find whether Review Group
  -- approval is needed or not.
  --
  l_review_group_flag := wf_engine.GetItemAttrText
			 ( itemtype => itemtype,
			   itemkey  => itemkey,
			   aname    => 'REVIEW_GROUP_FLAG') ;
  --
  IF NVL( l_review_group_flag, 'N') = 'N' THEN
    result := 'COMPLETE:NO' ;
  ELSE
    result := 'COMPLETE:YES' ;
  END IF ;
  --

  /* For testing */
  -- result := 'COMPLETE:NO' ;
  -- result := 'COMPLETE:YES' ;

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
    wf_core.context('PSBWS',   'Perform_Review_Group_Approval',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Perform_Review_Group_Approval ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Set_Loop_Limit                            |
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
  l_return_status           VARCHAR2(1) ;
  --
  l_worksheet_id                psb_worksheets.worksheet_id%TYPE ;
  l_budget_group_id             psb_worksheets.budget_group_id%TYPE ;
  l_budget_calendar_id          psb_worksheets.budget_calendar_id%TYPE ;
  l_root_budget_group_id        psb_budget_groups.root_budget_group_id%TYPE ;
  l_count                       NUMBER ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id    := wf_engine.GetItemAttrNumber
		       (  itemtype => itemtype,
			  itemkey  => itemkey,
			  aname    => 'WORKSHEET_ID'
		       );

  --
  -- Get budget_group, root budget group and calendar indo for the worksheet.
  --
  SELECT ws.budget_group_id      ,
	 ws.budget_calendar_id   ,
	 bg.root_budget_group_id
      INTO
	 l_budget_group_id       ,
	 l_budget_calendar_id    ,
	 l_root_budget_group_id
  FROM   psb_worksheets     ws ,
	 psb_budget_groups  bg
  WHERE  worksheet_id       = l_worksheet_id
  AND    ws.budget_group_id = bg.budget_group_id ;


  --
  -- Get budget calendar related info to find whether the review groups is
  -- active in the current budget group hierarchy or not.
  --
  IF NVL(PSB_WS_Acct1.g_budget_calendar_id, -99) <> l_budget_calendar_id
  THEN
    --
    PSB_WS_Acct1.Cache_Budget_Calendar
    (
       p_return_status         =>  l_return_status ,
       p_budget_calendar_id    =>  l_budget_calendar_id
    );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --
  END IF ;

  --
  -- Find review groups for the worksheet and populate psb_wf_review_groups
  -- table with this information. Consider whether the review_group is
  -- active in the current budget group hierarchy. If not, do not select
  -- such a budget workflow rule.
  --
  INSERT INTO psb_wf_review_groups
	      ( item_key, budget_workflow_rule_id,       sequence )
	 SELECT itemkey,  rules.budget_workflow_rule_id, ROWNUM
	 FROM   psb_budget_group_categories  cats ,
		psb_budget_workflow_rules    rules ,
		psb_budget_groups            bg
	 WHERE  cats.budget_group_id  = l_budget_group_id
	 AND    rules.budget_group_id = l_root_budget_group_id
	 AND    rules.stage_id        = cats.stage_id
	 AND    bg.budget_group_id    = rules.review_budget_group_id
	 AND    bg.effective_start_date <= PSB_WS_Acct1.g_startdate_pp
	 AND    ( ( bg.effective_end_date IS NULL)
		  OR
		  ( bg.effective_end_date >= PSB_WS_Acct1.g_enddate_cy )
		 ) ;

  --
  -- Count total number of review groups to set the Loop Counter Activity.
  --
  l_count := SQL%ROWCOUNT ;

  --
  -- Committing as the users on_exit settings may be ROLLBACK.
  --
  COMMIT ;

  /* For testing */
  -- l_count := 2 ;

  wf_engine.SetItemAttrNumber( ItemType => itemtype,
			       ItemKey  => itemkey,
			       aname    => 'LOOP_SET_COUNTER',
			       avalue   => l_count );
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
    wf_core.context('PSBWS',   'Set_Loop_Limit',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Set_Loop_Limit ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                    PROCEDURE Create_Review_Group_Worksheet                |
 +===========================================================================*/
--
-- The API creates a worksheet for a Review Group.
--
PROCEDURE Create_Review_Group_Worksheet
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_return_status               VARCHAR2(1) ;
  l_msg_count                   NUMBER ;
  l_msg_data                    VARCHAR2(2000) ;
  --
  l_worksheet_id                psb_worksheets.worksheet_id%TYPE ;
  l_new_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_new_worksheet_name          psb_worksheets.name%TYPE ;
  l_budget_group_id             psb_worksheets.budget_group_id%TYPE ;
  l_budget_workflow_rule_id     NUMBER ;
  l_account_or_position_type    VARCHAR2(1) ;
  l_approval_option             VARCHAR2(1) ;
  l_review_budget_group_id      NUMBER ;
  l_review_budget_group_name    psb_budget_workflow_rules.name%TYPE ;
  l_set_tbl                     PSB_WS_Ops_Pvt.account_position_set_tbl_type ;
  l_wf_role_name                psb_budget_group_resp.wf_role_name%TYPE ;
  --For Bug#4475288: Modifying width of l_review_group_approver_name from VARCHAR2(80)
  l_review_group_approver_name  psb_budget_group_resp.wf_role_name%TYPE ;
  l_operation_id                NUMBER ;
  --
  l_count                       NUMBER ;
  l_loop_visited_counter        NUMBER ;
  --
BEGIN
--

IF ( funcmode = 'RUN'  ) THEN


  /* ******
  -- Start testing.
  l_review_group_approver_name := 'PSBTEST' ;

  l_loop_visited_counter  :=  wf_engine.GetItemAttrNumber
			      (  itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'LOOP_VISITED_COUNTER'
			      );

  l_loop_visited_counter := l_loop_visited_counter + 1 ;

  wf_engine.SetItemAttrNumber( ItemType => ItemType,
			       ItemKey  => ItemKey,
			       aname    => 'LOOP_VISITED_COUNTER',
			       avalue   => l_loop_visited_counter );

  IF l_loop_visited_counter = 1 THEN

    wf_engine.SetItemAttrText( ItemType => ItemType,
			       ItemKey  => ItemKey,
			       aname    => 'APPROVAL_OPTION',
			       avalue   => 'N' );
  ELSE

    wf_engine.SetItemAttrText( ItemType => ItemType,
			       ItemKey  => ItemKey,
			       aname    => 'APPROVAL_OPTION',
			       avalue   => 'Y' );
  END IF ;

  -- Set approver_name item attribute.
  wf_engine.SetItemAttrText( ItemType => itemtype,
			     ItemKey  => itemkey,
			     aname    => 'REVIEW_GROUP_APPROVER_NAME',
			     avalue   => l_review_group_approver_name );

  --
  result := 'COMPLETE' ;
  return ;

  -- End testing.
  ***** */

  --
  -- Get item related attribute values.
  --

  l_worksheet_id  :=  wf_engine.GetItemAttrNumber
		      (  itemtype => itemtype,
			 itemkey  => itemkey,
			 aname    => 'WORKSHEET_ID'
		      );
  --
  l_operation_id := wf_engine.GetItemAttrNumber
		    (  itemtype => itemtype,
		       itemkey  => itemkey,
		       aname    => 'OPERATION_ID'
		    );
  --
  l_loop_visited_counter  :=  wf_engine.GetItemAttrNumber
			     (  itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'LOOP_VISITED_COUNTER'
			     );

  --
  -- Get budget_group_id for the current worksheet.
  --
  SELECT budget_group_id INTO l_budget_group_id
  FROM   psb_worksheets
  WHERE  worksheet_id = l_worksheet_id ;

  l_loop_visited_counter := l_loop_visited_counter + 1 ;

  --
  -- Get the current review group to be processed.
  --
  SELECT wrg.budget_workflow_rule_id  ,
	 rules.approval_option        ,
	 rules.review_budget_group_id
     INTO
	 l_budget_workflow_rule_id    ,
	 l_approval_option            ,
	 l_review_budget_group_id
  FROM   psb_wf_review_groups      wrg ,
	 psb_budget_workflow_rules rules
  WHERE  item_key                      = itemkey
  AND    sequence                      = l_loop_visited_counter
  AND    rules.budget_workflow_rule_id = wrg.budget_workflow_rule_id ;

  --
  -- Get the current review group name to update 'REVIEW_GROUP_NAME' attribute.
  --
  SELECT name INTO l_review_budget_group_name
  FROM   psb_budget_groups
  WHERE  budget_group_id = l_review_budget_group_id ;

  --
  -- Update 'LOOP_VISITED_COUNTER', 'APPROVAL_OPTION' and
  -- 'REVIEW_GROUP_NAME' item attributes.
  --

  wf_engine.SetItemAttrNumber( ItemType => ItemType,
			       ItemKey  => ItemKey,
			       aname    => 'LOOP_VISITED_COUNTER',
			       avalue   => l_loop_visited_counter );

  wf_engine.SetItemAttrText( ItemType => ItemType,
			     ItemKey  => ItemKey,
			     aname    => 'APPROVAL_OPTION',
			     avalue   => l_approval_option );

  wf_engine.SetItemAttrText( ItemType => ItemType,
			     ItemKey  => ItemKey,
			     aname    => 'REVIEW_GROUP_NAME',
			     avalue   => l_review_budget_group_name );

  --
  -- For the current review group, we have to create a new worksheet for each
  -- review group rules. For rule type 'A' (Account) or 'P' (Position), we need
  -- to find the sets associated with the rule and call Create_Worksheet API.
  -- IF the review group rule is for 'New Positions' and call the appropriate
  -- Create_New_Position_Worksheet API.
  --

  -- Check whether the budget workflow rule is for 'New Positions'.
  SELECT account_or_position_type INTO l_account_or_position_type
  FROM   psb_budget_workflow_rules
  WHERE  budget_workflow_rule_id = l_budget_workflow_rule_id ;

  IF l_account_or_position_type IN ( 'A', 'P') THEN

    l_count := 0 ;
    l_set_tbl.DELETE ;

    FOR l_set_rec IN
    (
       SELECT account_position_set_id,
	      account_or_position_type
       FROM   psb_budget_workflow_rules   rules ,
	      psb_set_relations           relations
       WHERE  rules.budget_workflow_rule_id     = l_budget_workflow_rule_id
       AND    relations.budget_workflow_rule_id = rules.budget_workflow_rule_id
    )
    LOOP
      l_count := l_count + 1;
      l_set_tbl(l_count).account_position_set_id
				      := l_set_rec.account_position_set_id  ;
      l_set_tbl(l_count).account_or_position_type
				      := l_set_rec.account_or_position_type ;
    END LOOP;

    --
    -- Create a new worksheet for the current review group.
    -- ( Rule type 'Account' or 'Positions' )
    --
    PSB_WS_Ops_Pvt.Create_Worksheet
    (
      p_api_version                  =>   1.0 ,
      p_init_msg_list                =>   FND_API.G_TRUE ,
      p_commit                       =>   FND_API.G_FALSE ,
      p_validation_level             =>   FND_API.G_VALID_LEVEL_FULL ,
      p_return_status                =>   l_return_status ,
      p_msg_count                    =>   l_msg_count ,
      p_msg_data                     =>   l_msg_data ,
      --
      p_worksheet_id                 =>   l_worksheet_id           ,
      p_budget_group_id              =>   l_review_budget_group_id ,
      p_account_position_set_tbl     =>   l_set_tbl                ,
      p_service_package_operation_id =>   l_operation_id           ,
      p_worksheet_id_OUT             =>   l_new_worksheet_id
    );

  ELSIF l_account_or_position_type = 'N' THEN

    --
    -- Create a new worksheet for the current review group.
    -- ( Rule type 'New Positions' )
    --
    PSB_WS_Ops_Pvt.Create_New_Position_Worksheet
    (
      p_api_version                  =>   1.0 ,
      p_init_msg_list                =>   FND_API.G_TRUE ,
      p_commit                       =>   FND_API.G_FALSE ,
      p_validation_level             =>   FND_API.G_VALID_LEVEL_FULL ,
      p_return_status                =>   l_return_status ,
      p_msg_count                    =>   l_msg_count ,
      p_msg_data                     =>   l_msg_data ,
      --
      p_worksheet_id                 =>   l_worksheet_id ,
      p_budget_group_id              =>   l_review_budget_group_id ,
      p_service_package_operation_id =>   l_operation_id ,
      p_worksheet_id_OUT             =>   l_new_worksheet_id
    );
    --

  END IF;

  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  --
  -- Get new worksheet related information.
  --
  IF l_new_worksheet_id <> 0 THEN

    -- Find new worksheet name.
    SELECT name INTO l_new_worksheet_name
    FROM   psb_worksheets
    WHERE  worksheet_id = l_new_worksheet_id ;

    -- Find approvers for the current review group.
    SELECT wf_role_name INTO l_review_group_approver_name
    FROM   psb_budget_groups     bg ,
	   psb_budget_group_resp resp
    WHERE  resp.responsibility_type = 'N'
    AND    bg.budget_group_id       = l_review_budget_group_id
    AND    bg.budget_group_id       = resp.budget_group_id
    AND    ROWNUM                   < 2 ;

  ELSE

    l_new_worksheet_name         := NULL ;
    l_review_group_approver_name := NULL ;

  END IF ;

  --
  -- Set item attributes related to the new worksheet.
  --

  wf_engine.SetItemAttrNumber( ItemType => itemtype,
			       ItemKey  => itemkey,
			       aname    => 'NEW_WORKSHEET_ID' ,
			       avalue   => l_new_worksheet_id  );

  wf_engine.SetItemAttrText( ItemType => itemtype,
			     ItemKey  => itemkey,
			     aname    => 'NEW_WORKSHEET_NAME' ,
			     avalue   => l_new_worksheet_name  );

  wf_engine.SetItemAttrText( ItemType => itemtype,
			     ItemKey  => itemkey,
			     aname    => 'REVIEW_GROUP_APPROVER_NAME',
			     avalue   => l_review_group_approver_name );
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
    wf_core.context('PSBWS',   'Create_Review_Group_Worksheet',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Create_Review_Group_Worksheet ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE New_Worksheet_Created                       |
 +===========================================================================*/
--
-- The API checks whether the new worksheet for the review group was created
-- or not. A worksheet may have not been created if it did not have relevant
-- account/position sets (from which the new worksheet gets created).
--
PROCEDURE New_Worksheet_Created
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_new_worksheet_id          psb_worksheets.worksheet_id%TYPE ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get value of 'NEW_WORKSHEET_ID' attribute to find whether a new
  -- worksheet was created or not.
  --
  l_new_worksheet_id := wf_engine.GetItemAttrNumber
			( itemtype => itemtype,
			  itemkey  => itemkey,
			  aname    => 'NEW_WORKSHEET_ID'
			) ;
  --
  IF NVL( l_new_worksheet_id, 0 ) = 0 THEN
    result := 'COMPLETE:NO' ;
  ELSE
    result := 'COMPLETE:YES' ;
  END IF ;
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
    wf_core.context('PSBWS',   'New_Worksheet_Created',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END New_Worksheet_Created;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Find_Approval_Option                        |
 +===========================================================================*/
--
-- The API finds the  approval option for a worksheet. The approval  option
-- tells you whether the approval is required for a worksheet or it is just
-- for review group approvers' information.
--
PROCEDURE Find_Approval_Option
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_approval_option           psb_budget_workflow_rules.approval_option%TYPE ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get value of 'APPROVAL_OPTION' attribute to find whether Review Group
  -- approval is needed or not.
  --
  l_approval_option := wf_engine.GetItemAttrText
		       ( itemtype => itemtype,
			 itemkey  => itemkey,
			 aname    => 'APPROVAL_OPTION') ;
  --
  IF NVL( l_approval_option, 'N') = 'N' THEN
    result := 'COMPLETE:NO' ;
  ELSE
    result := 'COMPLETE:YES' ;
  END IF ;
  --

  /* For testing */
  --result := 'COMPLETE:NO' ;
  --result := 'COMPLETE:YES' ;

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
    wf_core.context('PSBWS',   'Find_Approval_Option',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Find_Approval_Option ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Set_Reviewed_Flag                        |
 +===========================================================================*/
--
-- The API sets the attribute 'REVIWED_FLAG' to 'Y' as the review group has
-- reviewed the worksheet by now.
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
    wf_core.context('PSBWS',   'Set_Reviewed_Flag',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Set_Reviewed_Flag ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Send_Approval_Notification               |
 +===========================================================================*/
--
-- The activity finds out whether 'Worksheet Approved' related notification
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
    wf_core.context('PSBWS',   'Send_Approval_Notification',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Send_Approval_Notification ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Update_Worksheets_Status                 |
 +===========================================================================*/
--
-- The API updates submission related information in the submitted worksheet
-- and all its lower worksheets.
--
PROCEDURE Update_Worksheets_Status
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
  l_worksheet_id       psb_worksheets.worksheet_id%TYPE ;
  l_worksheet_name     psb_worksheets.name%TYPE ;
  l_submitter_id       NUMBER ;
  l_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  l_worksheets_tab     PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');
  --
  l_submitter_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'SUBMITTER_ID');

  --
  -- Call API to find all lower level worksheets.
  --
  PSB_WS_Ops_Pvt.Find_Child_Worksheets
  (
     p_api_version       =>   1.0 ,
     p_init_msg_list     =>   FND_API.G_FALSE,
     p_commit            =>   FND_API.G_FALSE,
     p_validation_level  =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status     =>   l_return_status,
     p_msg_count         =>   l_msg_count,
     p_msg_data          =>   l_msg_data,
     --
     p_worksheet_id      =>   l_worksheet_id,
     p_worksheet_tbl     =>   l_worksheets_tab
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --

  l_worksheets_tab(0) := l_worksheet_id ;

  --
  -- Processing all lower level worksheets for updation
  --
  FOR i IN 0..l_worksheets_tab.COUNT-1
  LOOP
    --
    -- Update Distribution related information in psb_worksheets.
    --
    PSB_Worksheet_Pvt.Update_Worksheet
    (
       p_api_version                 => 1.0 ,
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
       p_return_status               => l_return_status,
       p_msg_count                   => l_msg_count,
       p_msg_data                    => l_msg_data ,
       --
       p_worksheet_id                => l_worksheet_id ,
       p_date_submitted              => SYSDATE ,
       p_submitted_by                => l_submitter_id
    );

    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
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
    wf_core.context('PSBWS',   'Update_Worksheets_Status',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Update_Worksheets_Status ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Select_Approvers                            |
 +===========================================================================*/
--
-- The API finds Approvers for the worksheet and then sends notifications
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
  l_worksheet_id              psb_worksheets.worksheet_id%TYPE ;
  l_approver_name             VARCHAR2(80) ;
  l_parent_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  l_notification_group_id     NUMBER ;
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');
  --
  -- Setting context for the CALLBACK procedure.
  --

  g_itemtype         := itemtype ;
  g_itemkey          := itemkey ;
  g_worksheet_id   := l_worksheet_id ;

  g_budget_group_name := wf_engine.GetItemAttrText
			(  itemtype => itemtype,
			   itemkey  => itemkey,
			   aname    => 'BUDGET_GROUP_NAME'
			 );

  g_worksheet_name := wf_engine.GetItemAttrText
		      ( itemtype => itemtype,
			itemkey  => itemkey,
			aname    => 'WORKSHEET_NAME'
		      );

  --
  -- Find the approver role.
  --
  SELECT bg.parent_budget_group_id
      INTO
	 l_parent_budget_group_id
  FROM   psb_worksheets    ws,
	 psb_budget_groups bg
  WHERE  ws.worksheet_id    = l_worksheet_id
  AND    ws.budget_group_id = bg.budget_group_id ;


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
		     msg_type => 'PSBWS'                                  ,
		     msg_name => 'NOTIFY_APPROVERS_OF_SUBMISSION'         ,
		     context  => itemtype ||':'|| itemkey || ':'|| actid  ,
		     callback => 'PSB_Submit_Worksheet_PVT.Callback'
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
    wf_core.context('PSBWS',   'Select_Approvers',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Select_Approvers ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Unfreeze_Worksheets                      |
 +===========================================================================*/
--
-- This API unfreezes the submitted worksheet. Note that the lower worksheets
-- are not unfrozen, even though they were frozen during Freeze operation.
--
PROCEDURE Unfreeze_Worksheets
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_worksheet_name          psb_worksheets.name%TYPE ;
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
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'WORKSHEET_ID');
  --
  -- Unfreeze only the current worksheet.
  --
  PSB_WS_Ops_Pvt.Freeze_Worksheet
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_FALSE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_worksheet_id            =>   l_worksheet_id,
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
    wf_core.context('PSBWS',   'Unfreeze_Worksheets',
		     PSB_Message_S.Get_Error_Stack(l_msg_count) );
    RAISE ;

END Unfreeze_Worksheets ;
/*---------------------------------------------------------------------------*/


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
  l_worksheet_id       psb_worksheets.worksheet_id%TYPE ;
  l_worksheet_name     psb_worksheets.name%TYPE ;
  --
  l_notification_id    NUMBER ;

BEGIN
--
IF ( command = 'GET'  ) THEN

  g_user_name := fnd_global.user_name; -- bug 2576222

  IF attr_name = 'WORKSHEET_ID' THEN

    number_value := g_worksheet_id ;

  ELSIF attr_name = 'WORKSHEET_NAME' THEN

    text_value := g_worksheet_name ;

  ELSIF attr_name = 'BUDGET_GROUP_NAME' THEN

    text_value := g_budget_group_name ;

  ELSIF attr_name = 'FROM_ROLE' THEN  -- bug 2576222

    text_value := g_user_name ;

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
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                    PROCEDURE Check_Review_Groups                          |
 +===========================================================================*/
--
-- Checks whether review groups exist for a worksheet. This is a normal API
-- and it does not follow Workflow API structure.
--
PROCEDURE Check_Review_Groups
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE ,
  p_review_group_exists       OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Check_Review_Groups' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_budget_calendar_id      psb_worksheets.budget_calendar_id%TYPE ;
  l_root_budget_group_id    psb_budget_groups.root_budget_group_id%TYPE ;
  l_count                   NUMBER ;
  --
  l_exists                  VARCHAR2(10);

BEGIN
  --
  SAVEPOINT Check_Review_Groups_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.To_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --

  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_review_group_exists := FND_API.G_FALSE ;
  --

  --
  -- Get budget_group_id for the worksheet
  --
  SELECT ws.budget_group_id      ,
	 ws.budget_calendar_id   ,
	 bg.root_budget_group_id
       INTO
	 l_budget_group_id       ,
	 l_budget_calendar_id    ,
	 l_root_budget_group_id
  FROM   psb_worksheets    ws ,
	 psb_budget_groups bg
  WHERE  worksheet_id       = p_worksheet_id
  AND    ws.budget_group_id = bg.budget_group_id ;

  l_count := 0 ;

  --
  -- Get budget calendar related info to find whether the review groups is
  -- active in the current budget group hierarchy or not.
  --
  IF NVL(PSB_WS_Acct1.g_budget_calendar_id, -99) <> l_budget_calendar_id
  THEN
    --
    PSB_WS_Acct1.Cache_Budget_Calendar
    (
       p_return_status         =>  l_return_status ,
       p_budget_calendar_id    =>  l_budget_calendar_id
    );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --
  END IF ;

  l_exists := null;
  --
  -- Checking for review group existence for account sets.
  --
  BEGIN

  /*For Bug No 2115869 Start */
  --Fine tuned the following sql by adding the rownum < 2 restriction in sub query
  --Also moved the psb_budget_accounts from subquery to main query
  SELECT 'Exists' INTO l_exists FROM dual
   WHERE EXISTS
	(SELECT 1
	   FROM psb_budget_group_categories cats,
		psb_budget_workflow_rules   rules,
		psb_budget_groups           bg,
		psb_set_relations           relations,
		psb_budget_accounts         ba
	  WHERE cats.budget_group_id = l_budget_group_id
	    AND rules.budget_group_id = l_root_budget_group_id
	    AND bg.budget_group_id = rules.review_budget_group_id
	    AND bg.effective_start_date <= PSB_WS_Acct1.g_startdate_pp
	    AND (( bg.effective_end_date IS NULL)
		 OR( bg.effective_end_date >= PSB_WS_Acct1.g_enddate_cy ))
	    AND  rules.stage_id = cats.stage_id
	    AND  relations.budget_workflow_rule_id = rules.budget_workflow_rule_id
	    AND  relations.account_position_set_id = ba.account_position_set_id
	    AND  EXISTS
	    (
	    SELECT 1
	      FROM psb_ws_lines         lines ,
		   psb_ws_account_lines accts
	     WHERE lines.worksheet_id    = p_worksheet_id
	       AND lines.account_line_id = accts.account_line_id
	       AND accts.code_combination_id = ba.code_combination_id
	       AND ROWNUM < 2
	    ));
/*For Bug No 2115869 End */
  EXCEPTION
    when NO_DATA_FOUND then
      l_exists := null;
  END;

  IF l_exists = 'Exists' THEN

    p_review_group_exists := FND_API.G_TRUE ;

  ELSE

    l_exists := null;
    --
    --  Checking for review group existence for position sets.
    --
    BEGIN

  /*For Bug No 2115869 Start */
  --Fine tuned the following sql by adding the rownum < 2 restriction in sub query
  --Also moved the psb_budget_positions from subquery to main query

    SELECT 'Exists' INTO l_exists FROM dual
     WHERE EXISTS
	  (SELECT 1
	     FROM psb_budget_group_categories cats,
		  psb_budget_workflow_rules   rules,
		  psb_budget_groups           bg,
		  psb_set_relations           relations,
		  psb_budget_positions        bp
	    WHERE cats.budget_group_id = l_budget_group_id
	      AND rules.budget_group_id = l_root_budget_group_id
	      AND bg.budget_group_id = rules.review_budget_group_id
	      AND bg.effective_start_date <= PSB_WS_Acct1.g_startdate_pp
	      AND (( bg.effective_end_date IS NULL)
		   OR( bg.effective_end_date >= PSB_WS_Acct1.g_enddate_cy ))
	      AND rules.stage_id = cats.stage_id
	      AND relations.budget_workflow_rule_id = rules.budget_workflow_rule_id
	      AND relations.account_position_set_id = bp.account_position_set_id
	      AND EXISTS
	      (
	      SELECT 1
		FROM psb_ws_lines_positions   lines ,
		     psb_ws_position_lines    pos
	       WHERE lines.worksheet_id = p_worksheet_id
		 AND lines.position_line_id = pos.position_line_id
		 AND pos.position_id = bp.position_id
		 AND ROWNUM < 2
	      ));
  /*For Bug No 2115869 End */
  EXCEPTION
    when NO_DATA_FOUND then
      l_exists := null;
  END;
    --
    IF l_exists = 'Exists' THEN
      p_review_group_exists := FND_API.G_TRUE ;
    ELSE

      /* Bug 3641566 Start */
      --p_review_group_exists := FND_API.G_FALSE ;
      l_exists := NULL;
      BEGIN
        SELECT 'Exists' INTO l_exists
          FROM DUAL
          WHERE EXISTS
            (SELECT 1
               FROM PSB_BUDGET_GROUP_CATEGORIES cats,
                    PSB_BUDGET_WORKFLOW_RULES   rules,
                    PSB_BUDGET_GROUPS           bgrp
               WHERE cats.budget_group_id      = l_budget_group_id
                 AND rules.stage_id            = cats.stage_id
                 AND rules.budget_group_id     = l_root_budget_group_id
                 AND bgrp.budget_group_id      = rules.review_budget_group_id
                 AND bgrp.effective_start_date <= PSB_WS_Acct1.g_startdate_pp
                 AND (( bgrp.effective_end_date IS NULL )
                   OR( bgrp.effective_end_date >= PSB_WS_Acct1.g_enddate_cy ))
                 AND EXISTS
                   (SELECT 1
                      FROM PSB_POSITIONS          ppos,
                           PSB_WS_LINES_POSITIONS lines,
                           PSB_WS_POSITION_LINES wspos
                      WHERE ppos.position_id       = wspos.position_id
                        AND ppos.new_position_flag = 'Y'
                        AND lines.worksheet_id     = p_worksheet_id
                        AND wspos.position_line_id = lines.position_line_id
                   )
            );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exists := NULL;
      END;
      IF l_exists = 'Exists' THEN
        p_review_group_exists := FND_API.G_TRUE;
      ELSE
        p_review_group_exists := FND_API.G_FALSE ;
      END IF ;
      /* Bug 3641566 End */
    END IF ;
    --
  END IF ;

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
    ROLLBACK TO Check_Review_Groups_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_Review_Groups_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_Review_Groups_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name  );
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
END Check_Review_Groups;
/*---------------------------------------------------------------------------*/


END PSB_Submit_Worksheet_PVT ;

/
