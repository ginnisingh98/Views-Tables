--------------------------------------------------------
--  DDL for Package Body PSB_DISTRIBUTE_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_DISTRIBUTE_WORKSHEET_PVT" AS
/* $Header: PSBWSDPB.pls 120.3 2005/08/25 10:52:34 matthoma ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'PSB_Distribute_Worksheet_PVT';


/*--------------------------- Global variables -----------------------------*/

  -- WHO columns variables
  g_current_date           DATE   := sysdate                       ;
  g_current_user_id        NUMBER := NVL( Fnd_Global.User_Id  , 0) ;
  g_current_login_id       NUMBER := NVL( Fnd_Global.Login_Id , 0) ;

/*----------------------- End Global variables -----------------------------*/



/*===========================================================================+
 |                        PROCEDURE Start_Process                            |
 +===========================================================================*/
--
-- The API creates an instance of the item type 'PSBWS' and start the workflow
-- process 'Distribute Worksheet'.
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
  p_item_key                  IN       NUMBER   ,
  p_distribution_instructions IN       VARCHAR2 ,
  p_recipient_name            IN       VARCHAR2
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
  l_ItemType                VARCHAR2(100) := 'PSBWS' ;
  l_ItemKey                 VARCHAR2(100) := p_item_key ;
  --
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_user_name               VARCHAR2(100);
BEGIN
  --
  SAVEPOINT Start_Process_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  /* Bug 2576222 Start */
  l_user_name := fnd_global.user_name;
  /* Bug 2576222 End */

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
     Process  => 'DISTRIBUTE_WORKSHEET'
  );

  --
  -- Get p_item_key related information.
  --
  SELECT worksheet_id INTO l_worksheet_id
  FROM   psb_workflow_processes
  WHERE  item_key = p_item_key ;

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
  WF_Engine.SetItemAttrNumber
  (
     ItemType => l_ItemType,
     ItemKey  => l_itemkey,
     aname    => 'WORKSHEET_ID',
     avalue   => l_worksheet_id
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



  /* Bug 2576222 Start */
  wf_engine.SetItemAttrtext( ItemType => l_ItemType,
			       ItemKey  => l_itemkey,
			       aname    => 'FROM_ROLE',
			       avalue   => l_user_name );
  /* Bug 2576222 End */

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
    ROLLBACK TO Start_Process_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Start_Process_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Start_Process_Pvt ;
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
END Start_Process ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Populate_Worksheet                       |
 +===========================================================================*/
--
-- The API populates the item attribues of the item type 'PSBWS'.
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
  l_recipient_name     VARCHAR2(2000);
  --
BEGIN
--
IF ( funcmode = 'RUN'  ) THEN
  --
  -- Get worksheet_id item_attribute.
  --
  l_worksheet_id := WF_Engine.GetItemAttrNumber
		    (
		       itemtype => itemtype,
		       itemkey  => itemkey,
		       aname    => 'WORKSHEET_ID'
		    );

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
  WF_Engine.SetItemAttrText
  (
     itemtype => itemtype,
     itemkey  => itemkey,
     aname    => 'WORKSHEET_NAME',
     avalue   => l_worksheet_name
  );

  --
  WF_Engine.SetItemAttrText
  (
     itemtype => itemtype,
     itemkey  => itemkey,
     aname    => 'BUDGET_GROUP_NAME',
     avalue   => l_budget_group_name
  );

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
    wf_core.context('PSBWS',   'Populate_Worksheet',
		     itemtype, itemkey, to_char(actid), funcmode);
    RAISE ;

END Populate_Worksheet ;
/*---------------------------------------------------------------------------*/


END PSB_Distribute_Worksheet_PVT ;

/
