--------------------------------------------------------
--  DDL for Package Body PSB_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WORKFLOW_PVT" AS
/* $Header: PSBWKFLB.pls 115.29 2003/04/21 20:08:36 srawat ship $ */

  G_PKG_NAME     CONSTANT           VARCHAR2(30)  := 'PSB_Workflow_Pvt';

  g_chr10 CONSTANT VARCHAR2(1) := FND_GLOBAL.Newline;

  G_DBUG                            VARCHAR2(32767):= '!!';

/*--------------------------- Global variables -------------------------*/
  -- The flag determines whether to print debug information or not.
  g_debug_flag           VARCHAR2(1) := 'N' ;


  --
  -- WHO columns variables. Instantiation will be done by local API as
  -- these APIs are concurrent program execution files.
  --
  g_current_date                 DATE   ;
  g_current_user_id              NUMBER ;
  g_current_login_id             NUMBER ;
  --
  g_distribution_instructions
		    psb_ws_distributions.distribution_instructions%TYPE ;

/*-------------------- End Global variables ---------------------------*/



/*---------------------  Private Variables   --------------------------*/
  PROCEDURE Create_Worksheet
  (
     p_worksheet_id            IN       NUMBER ,
     p_global_worksheet_id     IN       NUMBER ,
     p_budget_group_id         IN       NUMBER ,
     p_distribution_id         IN       NUMBER ,
     p_created_worksheet_id    OUT  NOCOPY      NUMBER,
     p_return_status           OUT  NOCOPY      VARCHAR2
  );

  PROCEDURE Distribute_Budget_Revision
  (
     p_budget_revision_id          IN       NUMBER ,
     p_global_budget_revision_id   IN       NUMBER ,
     p_budget_group_id             IN       NUMBER ,
     p_distribution_id             IN       NUMBER ,
     p_created_budget_revision_id  OUT  NOCOPY      NUMBER,
     p_return_status               OUT  NOCOPY      VARCHAR2
  );

  PROCEDURE Add_Debug_Info
  (
     p_string            IN       VARCHAR2
  );

  PROCEDURE  pd
  (
    p_message               IN   VARCHAR2
  ) ;


/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Distribute_WS                            |
 +==========================================================================*/
--
-- The API sets up context information for the workflow distribute process
-- for a given worksheet and starts the workflow process
-- 'Distribute Worksheet' (It is basically an Concurrent Program API).
--
PROCEDURE Distribute_WS
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_distribution_id           IN       NUMBER,
  p_submitter_id              IN       NUMBER,
  p_export_name               IN       VARCHAR2
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Distribute_WS' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_worksheet_id            psb_ws_distributions.worksheet_id%TYPE ;
  l_created_worksheet_id    psb_worksheets.worksheet_id%TYPE ;
  l_budget_calendar_id      psb_worksheets.budget_calendar_id%TYPE ;
  l_global_worksheet_id     psb_worksheets.global_worksheet_id%TYPE ;
  l_distribution_rule_id    psb_ws_distributions.distribution_rule_id%TYPE ;
  l_distribution_option_flag
			psb_ws_distributions.distribution_option_flag%TYPE ;
  --
  l_export_name             VARCHAR2(80);
  --
BEGIN

  --
  -- Re-instatiate global variable as the concurrent manager does not do it
  -- for the same session.
  --
  g_current_date     := SYSDATE                       ;
  g_current_user_id  := NVL( Fnd_Global.User_Id  , 0) ;
  g_current_login_id := NVL( Fnd_Global.Login_Id , 0) ;
  --

  SAVEPOINT Distribute_WS_Pvt ;

  --
  -- Get distribution information.
  --
  SELECT worksheet_id                 ,
	 distribution_rule_id         ,
	 distribution_instructions    ,
	 distribution_option_flag
     INTO
	 l_worksheet_id               ,
	 l_distribution_rule_id       ,
	 g_distribution_instructions  ,
	 l_distribution_option_flag
  FROM   psb_ws_distributions
  WHERE  distribution_id = p_distribution_id ;

  --
  -- The Budget Revision functionality introduced the new flag called
  -- distribution_option_flag which determines whether the distribution is
  -- being done for a worksheet or a budget revision document. Currently this
  -- API will take care of worksheet distribution only.
  -- ( "W" means Worksheet, "R" means Budget Revision for the flag )
  --
  IF NVL( l_distribution_option_flag, 'W') = 'R' THEN
    RETURN ;
  END IF;

  --
  -- Find global_worksheet_id for the l_worksheet_id. If global_worksheet_id
  -- is NULL, then the l_worksheet_id is the global worksheet.
  --
  SELECT NVL( global_worksheet_id, l_worksheet_id ) ,
	 budget_calendar_id
    INTO
	 l_global_worksheet_id ,
	 l_budget_calendar_id
  FROM   psb_worksheets
  WHERE  worksheet_id = l_worksheet_id ;

  --
  -- Get budget calendar related info to find all the budget groups down in
  -- the current hierarchy.
  --
  IF NVL(PSB_WS_Acct1.g_budget_calendar_id, -99) <> l_budget_calendar_id
  THEN
    --
    PSB_WS_Acct1.Cache_Budget_Calendar
    (
      p_return_status       => l_return_status,
      p_budget_calendar_id  => l_budget_calendar_id
    );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MSG_PUB.Add_Exc_Msg( 'PSB_WS_Acct1', 'Cache_Budget_Calendar') ;
      RAISE FND_API.G_EXC_ERROR ;
    END IF ;
    --
  END IF ;

  FOR l_budget_groups_rec IN
  (
     SELECT a.budget_group_id ,b.short_name short_name,
	    NVL( distribute_all_level_flag, 'N') distribute_all_level_flag,
	    NVL( download_flag, 'N') download_flag,
	    NVL( download_all_level_flag, 'N') download_all_level_flag
     FROM   psb_ws_distribution_rule_lines a, psb_budget_groups b
     WHERE  distribution_rule_id  = l_distribution_rule_id
       AND  a.budget_group_id = b.budget_group_id
  )
  LOOP

    Add_Debug_Info('download flag is ' || l_budget_groups_rec.download_flag );
    Add_Debug_Info('download ALL LEVEL flag is ' ||
		     l_budget_groups_rec.download_all_level_flag) ;
    --
    IF l_budget_groups_rec.distribute_all_level_flag = 'N' THEN
      --
      -- Create worksheet for the given budget group only.
      --
      Create_Worksheet
      (  p_worksheet_id         => l_worksheet_id,
	 p_global_worksheet_id  => l_global_worksheet_id,
	 p_budget_group_id      => l_budget_groups_rec.budget_group_id,
	 p_distribution_id      => p_distribution_id,
	 p_created_worksheet_id => l_created_worksheet_id,
	 p_return_status        => l_return_status
      );
     --
     Add_Debug_Info('1- WS for BG '||
		    to_char(l_budget_groups_rec.budget_group_id) ||
		    ' Status '||l_return_status) ;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR ;
     END IF ;
     --

     -- download flag

     IF l_budget_groups_rec.download_flag = 'Y'  AND
	p_export_name IS NOT NULL THEN

	l_export_name := p_export_name || '_' || l_budget_groups_rec.short_name;

	Add_Debug_Info('TOP Export name is ' || l_export_name) ;

	PSB_EXCEL_PVT.Move_To_Interface
	   (
	     p_api_version       =>   l_api_version   ,
	     p_init_msg_list     =>   FND_API.G_FALSE ,
	     p_commit            =>   FND_API.G_FALSE ,
	     p_validation_level  =>   FND_API.G_VALID_LEVEL_FULL ,
	     p_return_status     =>   l_return_status ,
	     p_msg_count         =>   l_msg_count   ,
	     p_msg_data          =>   l_msg_data ,
	     --
	     p_export_name       =>   l_export_name,
	     p_worksheet_id      =>   l_created_worksheet_id
	   );

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   RAISE FND_API.G_EXC_ERROR ;
	END IF ;
	--

	Add_Debug_Info('After download ' || ' Status ' || l_return_status)  ;

     END IF;




   ELSIF l_budget_groups_rec.distribute_all_level_flag = 'Y' THEN

     --
     -- Create worksheet for the given budget group and its child budget groups.
     --
     FOR l_child_bgs_rec IN
     (
	SELECT budget_group_id, short_name short_name
	  FROM psb_budget_groups
	 WHERE budget_group_type = 'R'
	   AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
	   AND ((effective_end_date IS NULL)
		 OR
		(effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
	START WITH budget_group_id       = l_budget_groups_rec.budget_group_id
	CONNECT BY PRIOR budget_group_id = parent_budget_group_id
     )
     LOOP
       --
       Create_Worksheet
       (  p_worksheet_id         => l_worksheet_id,
	  p_global_worksheet_id  => l_global_worksheet_id,
	  p_budget_group_id      => l_child_bgs_rec.budget_group_id,
	  p_distribution_id      => p_distribution_id,
	  p_created_worksheet_id => l_created_worksheet_id,
	  p_return_status        => l_return_status
       );
       --

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 RAISE FND_API.G_EXC_ERROR ;
       END IF ;
       --

       IF   l_budget_groups_rec.download_flag = 'Y'   AND
	    p_export_name IS NOT NULL                 AND
	  (
	    ( l_budget_groups_rec.download_all_level_flag = 'Y') OR
	    ( l_budget_groups_rec.download_all_level_flag = 'N' AND
	      l_budget_groups_rec.budget_group_id =
	      l_child_bgs_rec.budget_group_id )
	  )  THEN

	  l_export_name := p_export_name || '_' || l_child_bgs_rec.short_name ;
	  Add_Debug_Info('Child Export name is ' || l_export_name ) ;


	  PSB_EXCEL_PVT. Move_To_Interface
		(
		  p_api_version       =>   l_api_version   ,
		  p_init_msg_list     =>   FND_API.G_FALSE ,
		  p_commit            =>   FND_API.G_FALSE ,
		  p_validation_level  =>   FND_API.G_VALID_LEVEL_FULL ,
		  p_return_status     =>   l_return_status ,
		  p_msg_count         =>   l_msg_count   ,
		  p_msg_data          =>   l_msg_data ,
		  --
		  p_export_name       =>   l_export_name,
		  p_worksheet_id      =>   l_created_worksheet_id
	  );

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR ;
	  END IF ;

	  Add_Debug_Info('After download ' || ' Status '||l_return_status) ;

       END IF;

	  -- end ...
     END LOOP ; -- To process all the child bgs for the current worksheet.
     --
    END IF; -- To check distribute_all_level_flag
    --
  END LOOP ; -- To process all the bgs for the current distribution_id.
  --

  retcode := 0 ;
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
  /*For Bug No : 2236283 Start*/
  --ROLLBACK to statements are commented and blind ROLLBACKs are implemented
  --since COMMIT is performed in child procedure and
  --SAVEPOINT will never be established

    --ROLLBACK TO Distribute_WS_Pvt ;
    ROLLBACK;
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    --ROLLBACK TO Distribute_WS_Pvt ;
    ROLLBACK;
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    --ROLLBACK TO Distribute_WS_Pvt ;
    ROLLBACK;
  /*For Bug No : 2236283 End*/
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Distribute_WS ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Submit_WS                                |
 +===========================================================================*/
--
-- The API sets up context information for the workflow submit process for a
-- given worksheet and starts the workflow process 'Submit Worksheet'.
--
PROCEDURE Submit_WS
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE ,
  p_submitter_id              IN       NUMBER   ,
  p_operation_type            IN       VARCHAR2 ,
  p_review_group_flag         IN       VARCHAR2 := 'N' ,
  p_orig_system               IN       VARCHAR2 ,
  p_merge_to_worksheet_id     IN       psb_worksheets.worksheet_id%TYPE  ,
  p_comments                  IN       VARCHAR2 ,
  p_operation_id              IN       NUMBER   ,
  p_constraint_set_id         IN       NUMBER
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Submit_WS' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
  l_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_wf_role_name            psb_budget_group_resp.wf_role_name%TYPE ;
  --
  l_lock_worksheet_id       psb_worksheets.worksheet_id%TYPE ;
  l_tmp_number              NUMBER ;
  l_item_key                VARCHAR2(240) ;
  /*For Bug No : 2115869 Start*/
  l_review_group_exists     VARCHAR2(1);
  /*For Bug No : 2115869 End*/
  --
BEGIN

  --
  -- Call Concurrency control API.
  --

  IF p_operation_type = 'MERGE' THEN
    l_lock_worksheet_id := p_merge_to_worksheet_id ;
  /*For Bug No : 2115869 Start*/
  ELSIF p_operation_type = 'SUBMIT' THEN
    IF p_review_group_flag <> 'Y' THEN
      PSB_Submit_Worksheet_PVT.Check_Review_Groups
      (
	 p_api_version             =>   1.0 ,
	 p_init_msg_list            =>  FND_API.G_TRUE,
	 p_commit                   =>  FND_API.G_FALSE,
	 p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
	 p_return_status           =>   l_return_status,
	 p_msg_count               =>   l_msg_count,
	 p_msg_data                =>   l_msg_data,
	 --
	 p_worksheet_id            =>   p_worksheet_id,
	 p_review_group_exists     =>   l_review_group_exists
      );
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_ERROR ;
      END IF ;
      --
      IF l_review_group_exists = 'T' THEN
	 l_review_group_exists := 'Y';
      ELSE
	 l_review_group_exists := 'N';
      END IF;

    ELSE
      l_review_group_exists := 'N';
    END IF;
    l_lock_worksheet_id := p_worksheet_id ;
  /*For Bug No : 2115869 End*/
  ELSE
    l_lock_worksheet_id := p_worksheet_id ;
  END IF ;

  PSB_WS_Ops_Pvt.Check_WS_Ops_Concurrency
  (
     p_api_version              => 1.0 ,
     p_init_msg_list            => FND_API.G_FALSE ,
     p_validation_level         => FND_API.G_VALID_LEVEL_NONE ,
     p_return_status            => l_return_status ,
     p_msg_count                => l_msg_count ,
     p_msg_data                 => l_msg_data ,
     --
     p_worksheet_id             => p_worksheet_id ,
     p_operation_type           => p_operation_type
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MSG_PUB.Add_Exc_Msg( 'PSB_WS_Ops_Pvt', 'Check_WS_Ops_Concurrency') ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
  --

  --
  -- Find budget_group_id for the worksheet.
  --
  SELECT budget_group_id INTO l_budget_group_id
  FROM   psb_worksheets
  WHERE  worksheet_id = p_worksheet_id ;

  --
  -- Find budget_group users information.
  --
  SELECT min(wf_role_name) INTO l_wf_role_name
  FROM   psb_budget_groups     bg ,
	 psb_budget_group_resp resp
  WHERE  bg.budget_group_id       = l_budget_group_id
  AND    resp.responsibility_type = 'N'
  AND    bg.budget_group_id       = resp.budget_group_id ;

  --
  -- Create an itemtype in psb_workflow_processes, to be used by the
  -- Workflow 'Submit Process'.
  --
  SELECT psb_workflow_processes_s.nextval INTO l_item_key
  FROM   dual ;

  INSERT INTO psb_workflow_processes
	      (  item_key ,
		 process_type ,
		 worksheet_id ,
		 process_date,
		 document_type
	      )
      VALUES
	      (  l_item_key       ,
		 p_operation_type ,
		 p_worksheet_id   ,
		 SYSDATE,
		 'BP'
	      );


  --
  -- Start the Workflow 'Submit Process'.
  --
  PSB_Submit_Worksheet_PVT.Start_Process
  (  p_api_version           =>  1.0   ,
     p_init_msg_list         =>  FND_API.G_FALSE,
     p_commit                =>  FND_API.G_FALSE,
     p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
     p_return_status         =>  l_return_status         ,
     p_msg_count             =>  l_msg_count             ,
     p_msg_data              =>  l_msg_data              ,
     --
     p_item_key              =>  l_item_key              ,
     p_submitter_id          =>  p_submitter_id          ,
     p_submitter_name        =>  l_wf_role_name          ,
     p_operation_type        =>  p_operation_type        ,
     /*For Bug No : 2115869 Start*/
     --p_review_group_flag     =>  p_review_group_flag     ,
     p_review_group_flag     =>  l_review_group_exists     ,
     /*For Bug No : 2115869 End*/
     p_orig_system           =>  '-99'                   ,
     p_merge_to_worksheet_id =>  p_merge_to_worksheet_id ,
     p_comments              =>  p_comments              ,
     p_operation_id          =>  p_operation_id          ,
     p_constraint_set_id     =>  p_constraint_set_id
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
  --
  retcode := 0 ;
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Submit_WS ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                      PROCEDURE Create_Worksheet  (Private)                |
 +===========================================================================*/
PROCEDURE Create_Worksheet
(
  p_worksheet_id              IN       NUMBER ,
  p_global_worksheet_id       IN       NUMBER ,
  p_budget_group_id           IN       NUMBER ,
  p_distribution_id           IN       NUMBER ,
  p_created_worksheet_id      OUT  NOCOPY      NUMBER ,
  p_return_status             OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_child_worksheet_id       psb_worksheets.worksheet_id%TYPE ;
  l_dist_wf_role_name        psb_budget_group_resp.wf_role_name%TYPE ;
  l_budget_group_resp_id     psb_budget_group_resp.budget_group_resp_id%TYPE;
  l_return_status            VARCHAR2(1) ;
  l_msg_count                NUMBER ;
  l_msg_data                 VARCHAR2(2000) ;
  --
  l_item_key                 NUMBER ;
  l_freeze_flag              VARCHAR2(1) ;
  --
  /*For Bug No : 2239422 Start*/
   l_bg_short_name           VARCHAR2(20);
  --To find the BG short name
  CURSOR c_bg_name IS
       SELECT short_name
	 FROM psb_budget_groups
	WHERE budget_group_id = p_budget_group_id;
  /*For Bug No : 2239422 End*/

  --
  -- New way to find if a worksheet has been created for a budget group.
  -- ( Bug#2832148 )
  --
  CURSOR l_child_worksheet_csr IS
  SELECT worksheet_id
  FROM   psb_worksheets
  WHERE  global_worksheet_id = p_global_worksheet_id
  AND    budget_group_id     = p_budget_group_id
  AND    worksheet_type      = 'O' ;

  /*
  CURSOR l_child_worksheet_csr IS
	 SELECT child_worksheet_id
	 FROM psb_ws_distribution_details details, psb_ws_distributions distr
  -- Bug No 2297742 Start
  --     WHERE distr.worksheet_id = p_worksheet_id
	 WHERE distr.worksheet_id = details.worksheet_id
	 AND   distr.distribution_id = p_distribution_id
  --     AND   distr.distribution_option_flag   = 'W'
	 AND   nvl(distr.distribution_option_flag, 'W') = 'W'
  -- Bug No 2297742 End
	 AND   global_worksheet_id = p_global_worksheet_id
	 AND   child_budget_group_id = p_budget_group_id ;
  */

  -- Find the approver role name for the budget group.
  CURSOR l_role_csr IS
       SELECT wf_role_name, budget_group_resp_id
       FROM   psb_budget_groups     bg ,
	      psb_budget_group_resp resp
       WHERE  bg.budget_group_id       = p_budget_group_id
       AND    resp.responsibility_type = 'N'
       AND    bg.budget_group_id       = resp.budget_group_id;

  -- To find if the worksheet is frozen.
  CURSOR l_ws_csr IS
	SELECT freeze_flag
	FROM   psb_worksheets
	WHERE  worksheet_id = l_child_worksheet_id ;
  --
BEGIN

  --
  -- Check whether it is a re-distribution or not.
  --
  OPEN  l_child_worksheet_csr ;
  FETCH l_child_worksheet_csr INTO l_child_worksheet_id ;
  CLOSE l_child_worksheet_csr ;


  IF l_child_worksheet_id IS NULL THEN

    -- It means it is a first time distribution. Create an official
    -- worksheet for distribution.
    --
    PSB_WS_Ops_Pvt.Create_Worksheet
    (
       p_api_version          => 1.0 ,
       p_init_msg_list        => FND_API.G_TRUE,
       /*For Bug no : 2236283 Start*/
       --p_commit               => FND_API.G_FALSE,
       p_commit               => FND_API.G_TRUE,
       /*For Bug no : 2236283 End*/
       p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
       p_return_status        => l_return_status,
       p_msg_count            => l_msg_count,
       p_msg_data             => l_msg_data ,
       --
       p_worksheet_id         => p_worksheet_id ,
       p_budget_group_id      => p_budget_group_id,
       p_worksheet_id_OUT     => l_child_worksheet_id
    ) ;
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --
  ELSIF l_child_worksheet_id IS NOT NULL THEN
    --
    -- It means it is a re-distribution. Update l_child_worksheet_id
    -- with the p_worksheet_id .
    --
    PSB_WS_Ops_Pvt.Update_Worksheet
    (
       p_api_version             =>   1.0 ,
       p_init_msg_list           =>   FND_API.G_TRUE,
       p_commit                  =>   FND_API.G_FALSE,
       p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status           =>   l_return_status,
       p_msg_count               =>   l_msg_count,
       p_msg_data                =>   l_msg_data,
       --
       p_source_worksheet_id     =>   p_worksheet_id ,
       p_target_worksheet_id     =>   l_child_worksheet_id
     );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --

    OPEN  l_ws_csr ;
    FETCH l_ws_csr INTO l_freeze_flag ;
    CLOSE l_ws_csr ;

    --
    --  If the worksheet is frozen then unfreeze it.
    --
    IF NVL(l_freeze_flag, 'N' ) = 'Y' THEN
      --
      PSB_WS_Ops_Pvt.Freeze_Worksheet
      (
	 p_api_version          =>   1.0 ,
	 p_init_msg_list        =>   FND_API.G_FALSE,
	 p_commit               =>   FND_API.G_FALSE,
	 p_validation_level     =>   FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        =>   l_return_status,
	 p_msg_count            =>   l_msg_count,
	 p_msg_data             =>   l_msg_data,
	 --
	 p_worksheet_id         =>   l_child_worksheet_id ,
	 p_freeze_flag          =>   'N'
      );
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;
      --
    END IF;
    --
  END IF ;

  --
  p_created_worksheet_id := l_child_worksheet_id ;
  --
  Add_Debug_Info( 'child ws id is ' || to_char(l_child_worksheet_id) ) ;
  --

  /*---2. DISTRIBUTION -------------------------------------------*/

  --
  -- Update psb_ws_distribution_details table.
  --
  OPEN  l_role_csr ;
  FETCH l_role_csr INTO l_dist_wf_role_name, l_budget_group_resp_id ;

  IF l_role_csr%NOTFOUND THEN

    /*For Bug No : 2239422 Start*/
    FOR c_bg_name_rec IN c_bg_name LOOP
      l_bg_short_name := c_bg_name_rec.short_name;
    END LOOP;
    /*For Bug No : 2239422 End*/

    FND_MESSAGE.SET_NAME ('PSB',    'PSB_DISTRIBUTION_NO_ROLE');

    /*For Bug No : 2239422 Start*/
    --commented since bg_short_name has to be displayed
    --FND_MESSAGE.SET_TOKEN('BGROUP', p_budget_group_id);
    FND_MESSAGE.SET_TOKEN('BGROUP', l_bg_short_name);
    /*For Bug No : 2239422 End*/

    FND_MSG_PUB.Add ;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  CLOSE l_role_csr ;


  INSERT INTO psb_ws_distribution_details
	      (
		distribution_id ,
		worksheet_id ,
		global_worksheet_id ,
		child_worksheet_id ,
		child_budget_group_id ,
		budget_group_resp_id
	      )
   VALUES
	      ( p_distribution_id ,
		p_worksheet_id ,
		p_global_worksheet_id ,
		l_child_worksheet_id ,
		p_budget_group_id ,
		l_budget_group_resp_id
	      ) ;

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

   -- Update distributions table
  UPDATE psb_ws_distributions
  SET distribution_date  = g_current_date,
      distributed_flag   = 'Y',
      last_update_date   = g_current_date,
      last_updated_by    = g_current_user_id,
      last_update_login  = g_current_login_id
  WHERE distribution_id  = p_distribution_id ;

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  /*---3. WORKFLOW-----------------------------------------------*/
  --
  -- Create an itemtype in psb_workflow_processes, to be used by the
  -- Workflow 'Distribute Process'.
  --

  SELECT psb_workflow_processes_s.nextval INTO l_item_key
  FROM   dual ;

  INSERT INTO psb_workflow_processes
	      (  item_key      ,
		 process_type  ,
		 worksheet_id  ,
		 process_date,
		 document_type
	      )
      VALUES
	      (  l_item_key ,
		 'DISTRIBUTE' ,
		 l_child_worksheet_id ,
		 SYSDATE,
		 'BP'
	      );

  IF (SQL%NOTFOUND ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Start the Workflow 'Distribution Process'.
  --

  PSB_Distribute_Worksheet_PVT.Start_Process
  (  p_api_version                =>  1.0   ,
     p_init_msg_list              =>  FND_API.G_FALSE,
     p_commit                     =>  FND_API.G_FALSE,
     p_validation_level           =>  FND_API.G_VALID_LEVEL_FULL,
     p_return_status              =>  l_return_status ,
     p_msg_count                  =>  l_msg_count     ,
     p_msg_data                   =>  l_msg_data      ,
     --
     p_item_key                   =>  l_item_key ,
     p_distribution_instructions  =>  g_distribution_instructions ,
     p_recipient_name             =>  l_dist_wf_role_name
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
			       'Create_Worksheet (Private)' );
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
END Create_Worksheet;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                      PROCEDURE Generate_Account                           |
 +===========================================================================*/
PROCEDURE Generate_Account
(
  p_api_version            IN  NUMBER ,
  p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status          OUT  NOCOPY VARCHAR2 ,
  p_msg_count              OUT  NOCOPY NUMBER   ,
  p_msg_data               OUT  NOCOPY VARCHAR2 ,
  --
  p_project_id             IN  psb_cost_distributions_i.project_id%TYPE       ,
  p_task_id                IN  psb_cost_distributions_i.task_id%TYPE          ,
  p_award_id               IN  psb_cost_distributions_i.award_id%TYPE         ,
  p_expenditure_type       IN  psb_cost_distributions_i.expenditure_type%TYPE ,
  p_expenditure_organization_id
			   IN
		    psb_cost_distributions_i.expenditure_organization_id%TYPE ,
  p_chart_of_accounts_id   IN  NUMBER,
  p_description            IN  VARCHAR2 := FND_API.G_MISS_CHAR                ,
  p_code_combination_id    OUT  NOCOPY gl_code_combinations.code_combination_id%TYPE  ,
  p_error_message          OUT  NOCOPY VARCHAR2
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Generate_Account' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_description             VARCHAR2(2000);
  l_project_number          VARCHAR2(30);
  l_task_number             VARCHAR2(30);
  l_award_number            VARCHAR2(30);
  --UTF8 changes for Bug No : 2615261
  l_expenditure_org_name    hr_all_organization_units.name%TYPE;
  --
  l_itemtype                CONSTANT VARCHAR2(30) := 'PSBLDMAG';
  l_itemkey                 VARCHAR2(30);
  l_result                  BOOLEAN;
  l_concat_segs             VARCHAR2(200);
  l_concat_ids              VARCHAR2(200);
  l_concat_descrs           VARCHAR2(500);
  l_error_message           VARCHAR2(100);
  l_return_ccid             gl_code_combinations.code_combination_id%TYPE;
  l_new_combination         BOOLEAN;
  --
BEGIN
  --
  SAVEPOINT Generate_Account_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.To_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  pd('Calling initialize with coa_id : ' || p_chart_of_accounts_id);

  -- Used for debuggin only.
  -- fnd_flex_workflow.debug_on ;

  l_itemkey := fnd_flex_workflow.initialize
	       (
		 appl_short_name => 'SQLGL',
		 code            => 'GL#',
		 num             => p_chart_of_accounts_id,
		 itemtype        => l_itemtype
	       );

  -----------------------------------------------------------
  -- Initialize the workflow item attributes
  -----------------------------------------------------------

  wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
			       itemkey    => l_itemkey,
			       aname      => 'PROJECT_ID',
			       avalue     => p_project_id);

  wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
			       itemkey    => l_itemkey,
			       aname      => 'TASK_ID',
			       avalue     => p_task_id);


  wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
			       itemkey    => l_itemkey,
			       aname      => 'AWARD_ID',
			       avalue     => p_award_id);

  wf_engine.SetItemAttrText  ( itemtype   => l_itemtype,
			       itemkey    => l_itemkey,
			       aname      => 'EXPENDITURE_TYPE',
			       avalue     => p_expenditure_type);

  wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
			       itemkey    => l_itemkey,
			       aname      => 'EXPENDITURE_ORGANIZATION_ID',
			       avalue     => p_expenditure_organization_id);

  -----------------------------------------------------------
  -- Populate item attributes based on POETA internal codes.
  -----------------------------------------------------------

  -- Resolve optional parameters.
  IF p_description = FND_API.G_MISS_CHAR THEN
    l_description := NULL;
  ELSE
    l_description := p_description ;
  END IF;

  -- Populate description related variables.
  IF l_description IS NOT NULL THEN

    l_project_number := SUBSTR(l_description,3,instr(l_description,'#;',1,2)-3);

    l_task_number := SUBSTR(l_description, instr(l_description,'#;',1,2)+2,
       (instr(l_description,'#;',1,3)-4) - instr(l_description,'#;',1,2)+2) ;

    l_award_number := SUBSTR(l_description,instr(l_description,'#;',1,3)+2,
	 (instr(l_description,'#;',1,4)-4)-instr(l_description,'#;',1,3)+2) ;

    l_expenditure_org_name :=
      SUBSTR(l_description,instr(l_description,'#;',1,4)+2,
      (instr(l_description,'#;',1,5)-4)-instr(l_description,'#;',1,4)+2) ;

  END IF ;

  wf_engine.SetItemAttrText( itemtype   => l_itemtype,
			     itemkey    => l_itemkey,
			     aname      => 'PROJECT_NUMBER',
			     avalue     => l_project_number );

  wf_engine.SetItemAttrText( itemtype   => l_itemtype,
			     itemkey    => l_itemkey,
			     aname      => 'TASK_NUMBER',
			     avalue     => l_task_number );

  wf_engine.SetItemAttrText( itemtype   => l_itemtype,
			     itemkey    => l_itemkey,
			     aname      => 'AWARD_NUMBER',
			     avalue     => l_award_number );

  wf_engine.SetItemAttrText( itemtype   => l_itemtype,
			     itemkey    => l_itemkey,
			     aname      => 'EXPENDITURE_ORG_NAME',
			     avalue     => l_expenditure_org_name );

  -----------------------------------------------------------
  -- Call the workflow Generate function to trigger off the
  -- workflow account generation
  -----------------------------------------------------------

  p_error_message := NULL ;

  l_result := fnd_flex_workflow.generate
	      (
		itemtype        => l_itemtype        ,
		itemkey         => l_itemkey         ,
		insert_if_new   => TRUE              ,
		ccid            => l_return_ccid     ,
		concat_segs     => l_concat_segs     ,
		concat_ids      => l_concat_ids      ,
		concat_descrs   => l_concat_descrs   ,
		error_message   => l_error_message   ,
		new_combination => l_new_combination
	      );

  ------------------------------------------------------------------
  -- Return the code_combination_id or the error message.
  ------------------------------------------------------------------
  IF l_return_ccid <> 0 THEN
    p_code_combination_id := l_return_ccid ;
  ELSE
    p_code_combination_id := NULL ;
    p_error_message       := l_error_message ;
  END IF;

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
    ROLLBACK TO Generate_Account_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Generate_Account_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Generate_Account_Pvt ;
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
END Generate_Account ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                        PROCEDURE Distribute_BR                            |
 +==========================================================================*/
--
-- The API sets up context information for the budget revision distribute
-- process for a given budget revision and starts the workflow process
-- 'Distribute Budget Revision' (It is basically an Concurrent Program API).
--
PROCEDURE Distribute_BR
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_distribution_id           IN       NUMBER,
  p_submitter_id              IN       NUMBER
)
IS
  --
  l_api_name                      CONSTANT VARCHAR2(30)   := 'Distribute_BR' ;
  l_api_version                   CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name                VARCHAR2(2000);
  l_return_status                 VARCHAR2(1) ;
  l_msg_count                     NUMBER ;
  l_msg_data                      VARCHAR2(2000) ;
  --
  l_budget_revision_id            NUMBER;
  l_created_budget_revision_id    NUMBER;
  l_global_budget_revision_id     NUMBER;
  l_distribution_rule_id          NUMBER;
  --
BEGIN

  --
  -- Re-instatiate global variable as the concurrent manager does not do it
  -- for the same session.
  --
  g_current_date     := SYSDATE                       ;
  g_current_user_id  := NVL( Fnd_Global.User_Id  , 0) ;
  g_current_login_id := NVL( Fnd_Global.Login_Id , 0) ;
  --

  SAVEPOINT Distribute_BR_Pvt ;

  --
  -- Get distribution information.
  -- The distribution_option_flag specifies whether
  -- it is a worksheet or budget revision

  SELECT worksheet_id                 ,
	 distribution_rule_id         ,
	 distribution_instructions
     INTO
	 l_budget_revision_id         ,
	 l_distribution_rule_id       ,
	 g_distribution_instructions
  FROM   psb_ws_distributions
  WHERE  distribution_id = p_distribution_id
  AND    distribution_option_flag = 'R'; --for budget revision

  --
  -- Find global_budget_revision_id for the
  -- l_budget_revision_id(budget_revision_id in this scenario)
  -- If global_budget_revision_id is NULL, then the l_budget_revision_id
  -- is the global budget revision.
  --
  SELECT NVL( global_budget_revision_id, l_budget_revision_id )
    INTO l_global_budget_revision_id
  FROM   psb_budget_revisions
  WHERE  budget_revision_id = l_budget_revision_id ;

  --
  FOR l_budget_groups_rec IN
  (
     SELECT a.budget_group_id ,b.short_name short_name,
	    NVL( distribute_all_level_flag, 'N') distribute_all_level_flag,
	    NVL( download_flag, 'N') download_flag,
	    NVL( download_all_level_flag, 'N') download_all_level_flag
     FROM   psb_ws_distribution_rule_lines a, psb_budget_groups b
     WHERE  distribution_rule_id  = l_distribution_rule_id
       AND  a.budget_group_id = b.budget_group_id
  )
  LOOP

    Add_Debug_Info('download flag is ' || l_budget_groups_rec.download_flag );
    Add_Debug_Info('download ALL LEVEL flag is ' ||
		     l_budget_groups_rec.download_all_level_flag) ;
    --
    IF l_budget_groups_rec.distribute_all_level_flag = 'N' THEN
      --
      -- Create Revision for the given budget group only.
      --
      Distribute_Budget_Revision
      (  p_budget_revision_id           => l_budget_revision_id,
	 p_global_budget_revision_id    => l_global_budget_revision_id,
	 p_budget_group_id              => l_budget_groups_rec.budget_group_id,
	 p_distribution_id              => p_distribution_id,
	 p_created_budget_revision_id   => l_created_budget_revision_id,
	 p_return_status                => l_return_status
      );
     --
     Add_Debug_Info('1- WS for BG '||
		    to_char(l_budget_groups_rec.budget_group_id) ||
		    ' Status '||l_return_status) ;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR ;
     END IF ;
     --

   ELSIF l_budget_groups_rec.distribute_all_level_flag = 'Y' THEN

     --
     -- Create Revisions for the given budget group and its child budget groups.
     --
     FOR l_child_bgs_rec IN
     (
	SELECT budget_group_id, short_name short_name
	  FROM psb_budget_groups
	 WHERE budget_group_type = 'R'
	START WITH budget_group_id       = l_budget_groups_rec.budget_group_id
	CONNECT BY PRIOR budget_group_id = parent_budget_group_id
     )
     LOOP
       --

       Distribute_Budget_Revision
       (  p_budget_revision_id         => l_budget_revision_id,
	  p_global_budget_revision_id  => l_global_budget_revision_id,
	  p_budget_group_id            => l_child_bgs_rec.budget_group_id,
	  p_distribution_id            => p_distribution_id,
	  p_created_budget_revision_id => l_created_budget_revision_id,
	  p_return_status              => l_return_status
       );
       --

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 RAISE FND_API.G_EXC_ERROR ;
       END IF ;
       --

     END LOOP ; -- To process all the child bgs for the current worksheet.
     --
    END IF; -- To check distribute_all_level_flag
    --
  END LOOP ; -- To process all the bgs for the current distribution_id.
  --

  retcode := 0 ;
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Distribute_BR_Pvt ;
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Distribute_BR_Pvt ;
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Distribute_BR_Pvt ;
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Distribute_BR ;
/*===========================================================================+
 |                      PROCEDURE Distribute_Budget_Revision (Private)       |
 +===========================================================================*/
-- The Private API is called by Distribute_BR or the concurrent process API
-- It creates budget revisions for parent, child budget revisions as part
-- of the distribution process and creates an item type for workflow process
--

PROCEDURE Distribute_Budget_Revision
(
  p_budget_revision_id              IN       NUMBER ,
  p_global_budget_revision_id       IN       NUMBER ,
  p_budget_group_id                 IN       NUMBER ,
  p_distribution_id                 IN       NUMBER ,
  p_created_budget_revision_id      OUT  NOCOPY      NUMBER ,
  p_return_status                   OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_child_budget_revision_id   psb_budget_revisions.budget_revision_id%TYPE ;
  l_dist_wf_role_name          psb_budget_group_resp.wf_role_name%TYPE ;
  l_budget_group_resp_id       psb_budget_group_resp.budget_group_resp_id%TYPE;
  l_return_status              VARCHAR2(1) ;
  l_msg_count                  NUMBER ;
  l_msg_data                   VARCHAR2(2000) ;
  --
  l_item_key                   NUMBER ;
  l_freeze_flag                VARCHAR2(1) ;
  l_revision_option_flag       VARCHAR2(1) ;
  --
  /*For Bug No : 2239422 Start*/
   l_bg_short_name           VARCHAR2(20);
  --To find the BG short name
  CURSOR c_bg_name IS
       SELECT short_name
	 FROM psb_budget_groups
	WHERE budget_group_id = p_budget_group_id;
  /*For Bug No : 2239422 End*/

  --
  -- New way to find if a revision has been created for a budget group.
  -- ( Bug#2832148 )
  --
  CURSOR l_child_budget_rev_csr IS
  SELECT budget_revision_id
  FROM   psb_budget_revisions
  WHERE  global_budget_revision_id = p_global_budget_revision_id
  AND    budget_group_id           = p_budget_group_id ;

  /*
  -- To find whether a budget revision been created for the budget group.
  CURSOR l_child_budget_rev_csr IS
	 SELECT child_worksheet_id
	 FROM   psb_ws_distribution_details details, psb_ws_distributions distr
	 WHERE  distr.worksheet_id               = p_budget_revision_id
	 AND    distr.distribution_id            = p_distribution_id
	 AND    distr.distribution_option_flag   = 'R'
	 AND    global_worksheet_id              = p_global_budget_revision_id
	 AND    child_budget_group_id            = p_budget_group_id;
  */

  CURSOR l_revision_option_csr IS
	SELECT revision_option_flag
	  FROM PSB_WS_DISTRIBUTIONS
	 WHERE distribution_id            = p_distribution_id
	   AND distribution_option_flag   = 'R';

  -- Find the approver role name for the budget group.
  CURSOR l_role_csr IS
       SELECT wf_role_name, budget_group_resp_id
       FROM   psb_budget_groups     bg ,
	      psb_budget_group_resp resp
       WHERE  bg.budget_group_id       = p_budget_group_id
       AND    resp.responsibility_type = 'N'
       AND    bg.budget_group_id       = resp.budget_group_id;

  -- To find if the budget revision is frozen.

  CURSOR l_br_csr IS
	SELECT freeze_flag
	FROM   psb_budget_revisions
	WHERE  budget_revision_id = l_child_budget_revision_id;
  --
BEGIN

  --
  -- Check whether it is a re-distribution or not.
  --
  OPEN  l_revision_option_csr;
  FETCH l_revision_option_csr INTO l_revision_option_flag ;
  CLOSE l_revision_option_csr ;

  OPEN  l_child_budget_rev_csr ;
  FETCH l_child_budget_rev_csr INTO l_child_budget_revision_id ;
  CLOSE l_child_budget_rev_csr ;


  IF l_child_budget_revision_id IS NULL THEN

    -- It means it is a first time distribution. Create an official
    -- budget revision for distribution.
    --
    PSB_Create_BR_Pvt.Create_Budget_Revision
    (
       p_api_version            => 1.0 ,
       p_init_msg_list          => FND_API.G_TRUE,
       p_commit                 => FND_API.G_FALSE,
       p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
       p_return_status          => l_return_status,
       p_msg_count              => l_msg_count,
       p_msg_data               => l_msg_data ,
       --
       p_budget_revision_id     => p_budget_revision_id ,
       p_budget_group_id        => p_budget_group_id,
       p_revision_option_flag   => l_revision_option_flag,
       p_budget_revision_id_out => l_child_budget_revision_id
    ) ;
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --
  ELSIF l_child_budget_revision_id IS NOT NULL THEN
    --
    -- It means it is a re-distribution. Update l_child_budget_revision_id
    -- with the p_budget_revision_id.
    --
    PSB_Create_BR_Pvt.Update_Target_Budget_Revision
    (
       p_api_version                =>   1.0 ,
       p_init_msg_list              =>   FND_API.G_TRUE,
       p_commit                     =>   FND_API.G_FALSE,
       p_validation_level           =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status              =>   l_return_status,
       p_msg_count                  =>   l_msg_count,
       p_msg_data                   =>   l_msg_data,
       --
       p_source_budget_revision_id  =>   p_budget_revision_id ,
       p_revision_option_flag       =>   l_revision_option_flag,
       p_target_budget_revision_id  =>   l_child_budget_revision_id
     );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --


   if ((l_revision_option_flag is not null) and (l_revision_option_flag <> 'N'))   then

    OPEN  l_br_csr ;
    FETCH l_br_csr INTO l_freeze_flag ;
    CLOSE l_br_csr ;

    --
    --  If the budget revision is frozen then unfreeze it.
    --
    IF NVL(l_freeze_flag, 'N' ) = 'Y' THEN
      --
      PSB_Create_BR_Pvt.Freeze_Budget_Revision
      (
	 p_api_version         =>   1.0 ,
	 p_init_msg_list       =>   FND_API.G_FALSE,
	 p_commit              =>   FND_API.G_FALSE,
	 p_validation_level    =>   FND_API.G_VALID_LEVEL_FULL,
	 p_return_status       =>   l_return_status,
	 p_msg_count           =>   l_msg_count,
	 p_msg_data            =>   l_msg_data,
	 --
	 p_budget_revision_id  =>   l_child_budget_revision_id,
	 p_freeze_flag         =>   'N'
      );
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;
      --
    END IF;
    --
  END IF ;
  END IF ;

  --
  p_created_budget_revision_id := l_child_budget_revision_id ;
  --
  Add_Debug_Info( 'child bg id is ' || to_char(l_child_budget_revision_id) ) ;
  --

  /*---2. DISTRIBUTION -------------------------------------------*/

  --
  -- Update psb_ws_distribution_details table.
  --
  OPEN  l_role_csr ;
  FETCH l_role_csr INTO l_dist_wf_role_name, l_budget_group_resp_id ;

  IF l_role_csr%NOTFOUND THEN

    /*For Bug No : 2239422 Start*/
    FOR c_bg_name_rec IN c_bg_name LOOP
      l_bg_short_name := c_bg_name_rec.short_name;
    END LOOP;
    /*For Bug No : 2239422 End*/

    FND_MESSAGE.SET_NAME ('PSB',    'PSB_DISTRIBUTION_NO_ROLE');

    /*For Bug No : 2239422 Start*/
    --commented since bg_short_name has to be displayed
    --FND_MESSAGE.SET_TOKEN('BGROUP', p_budget_group_id);
    FND_MESSAGE.SET_TOKEN('BGROUP', l_bg_short_name);
    /*For Bug No : 2239422 End*/

    FND_MSG_PUB.Add ;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  CLOSE l_role_csr ;


  INSERT INTO psb_ws_distribution_details
	      (
		distribution_id ,
		worksheet_id ,
		global_worksheet_id ,
		child_worksheet_id ,
		child_budget_group_id ,
		budget_group_resp_id
	      )
   VALUES
	      ( p_distribution_id ,
		p_budget_revision_id ,
		p_global_budget_revision_id ,
		l_child_budget_revision_id ,
		p_budget_group_id ,
		l_budget_group_resp_id
	      ) ;

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

   -- Update distributions table
  UPDATE psb_ws_distributions
  SET distribution_date  = g_current_date,
      distributed_flag   = 'Y',
      last_update_date   = g_current_date,
      last_updated_by    = g_current_user_id,
      last_update_login  = g_current_login_id
  WHERE distribution_id  = p_distribution_id ;

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  /*---3. WORKFLOW-----------------------------------------------*/
  --
  -- Create an itemtype in psb_workflow_processes, to be used by the
  -- Workflow 'Distribute Process'.
  --

  SELECT psb_workflow_processes_s.nextval INTO l_item_key
  FROM   dual ;

  INSERT INTO psb_workflow_processes
	      (  item_key      ,
		 process_type  ,
		 worksheet_id  ,
		 process_date  ,
		 document_type
	      )
      VALUES
	      (  l_item_key ,
		 'DISTRIBUTE_REVISION' ,
		 l_child_budget_revision_id ,
		 SYSDATE,
		 'BR'
	      );

  IF (SQL%NOTFOUND ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Start the Workflow 'Distribution Process'.
  --

  PSB_Submit_Revision_Pvt.Start_Distribution_Process
  (  p_api_version                =>  1.0   ,
     p_init_msg_list              =>  FND_API.G_FALSE,
     p_commit                     =>  FND_API.G_FALSE,
     p_validation_level           =>  FND_API.G_VALID_LEVEL_FULL,
     p_return_status              =>  l_return_status ,
     p_msg_count                  =>  l_msg_count     ,
     p_msg_data                   =>  l_msg_data      ,
     --
     p_item_key                   =>  l_item_key ,
     p_distribution_instructions  =>  g_distribution_instructions ,
     p_recipient_name             =>  l_dist_wf_role_name
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
			       'Distribute_Budget_Revision (Private)' );
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
END Distribute_Budget_Revision;


/*===========================================================================+
 |                        PROCEDURE Submit_BR                                |
 +===========================================================================*/
--
-- The API sets up context information for the workflow submit
-- process for a given Budget Revision and starts the workflow process
--'Submit Budget Revision'.

PROCEDURE Submit_BR
(
  errbuf                 OUT  NOCOPY VARCHAR2,
  retcode                OUT  NOCOPY VARCHAR2,
  --
  p_budget_revision_id   IN  psb_budget_revisions.budget_revision_id%type,
  p_submitter_id         IN  NUMBER   ,
  p_operation_type       IN  VARCHAR2 ,
  p_orig_system          IN  VARCHAR2 ,
  p_comments             IN  VARCHAR2 ,
  p_operation_id         IN  NUMBER   ,
  p_constraint_set_id    IN  NUMBER
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Submit_BR' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
  l_budget_revision_id      psb_budget_revisions.budget_revision_id%TYPE ;
  l_budget_group_id         psb_budget_revisions.budget_group_id%TYPE ;
  l_wf_role_name            psb_budget_group_resp.wf_role_name%TYPE ;
  --
  l_tmp_number              NUMBER ;
  l_item_key                VARCHAR2(240) ;
  --
BEGIN

  --
  -- Call Concurrency control API.
  --

  /*PSB_Create_BR_Pvt.Check_BR_Ops_Concurrency
  (
     p_api_version              => 1.0 ,
     p_init_msg_list            => FND_API.G_FALSE ,
     p_validation_level         => FND_API.G_VALID_LEVEL_NONE ,
     p_return_status            => l_return_status ,
     p_msg_count                => l_msg_count ,
     p_msg_data                 => l_msg_data ,
     --
     p_budget_revision_id       => p_budget_revision_id ,
     p_operation_type           => p_operation_type
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MSG_PUB.Add_Exc_Msg( 'PSB_BR_Ops_Pvt', 'Check_BR_Ops_Concurrency') ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ; */
  --

  --
  -- Find budget_group_id for the worksheet.
  --
  SELECT budget_group_id INTO l_budget_group_id
  FROM   psb_budget_revisions
  WHERE  budget_revision_id = p_budget_revision_id ;

  --
  -- Find budget_group users information.
  --
  SELECT min(wf_role_name) INTO l_wf_role_name
  FROM   psb_budget_groups     bg ,
	 psb_budget_group_resp resp
  WHERE  bg.budget_group_id       = l_budget_group_id
  AND    resp.responsibility_type = 'N'
  AND    bg.budget_group_id       = resp.budget_group_id ;

  --
  -- Create an itemtype in psb_workflow_processes, to be used by the
  -- Workflow 'Submit Process'.
  --
  SELECT psb_workflow_processes_s.nextval INTO l_item_key
  FROM   dual ;


  INSERT INTO psb_workflow_processes
	      (  item_key ,
		 process_type ,
		 worksheet_id ,
		 process_date,
		 document_type
	      )
      VALUES
	      (  l_item_key       ,
		 p_operation_type ,
		 p_budget_revision_id  ,
		 SYSDATE,
		 'BR'
	      );


  --
  -- Start the Workflow 'Submit Process'.
  --

  PSB_Submit_Revision_PVT.Start_Process
  (  p_api_version           =>  1.0   ,
     p_init_msg_list         =>  FND_API.G_FALSE,
     p_commit                =>  FND_API.G_FALSE,
     p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
     p_return_status         =>  l_return_status         ,
     p_msg_count             =>  l_msg_count             ,
     p_msg_data              =>  l_msg_data              ,
     --
     p_item_key              =>  l_item_key              ,
     p_submitter_id          =>  p_submitter_id          ,
     p_submitter_name        =>  l_wf_role_name          ,
     p_operation_type        =>  p_operation_type        ,
     p_orig_system           =>  '-99'                   ,
     p_comments              =>  p_comments              ,
     p_operation_id          =>  p_operation_id          ,
     p_constraint_set_id     =>  p_constraint_set_id
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
  --
  retcode := 0 ;

  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Submit_BR ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                      PROCEDURE No_Process_Defined                         |
 +===========================================================================*/
--
-- This API is called from the PSB default account generator process. This
-- API simply returns an error message specifying that the default process is
-- being used without proper customization.
--
PROCEDURE No_Process_Defined
(
   itemtype      IN  VARCHAR2,
   itemkey       IN  VARCHAR2,
   actid         IN  NUMBER,
   funcmode      IN  VARCHAR2,
   result        OUT  NOCOPY VARCHAR2
)
IS
  --
  l_error_msg         VARCHAR2(2000);
  --
BEGIN

  IF funcmode <> 'RUN' THEN
    result := null;
    RETURN;
  END IF;

  fnd_message.set_name('PSB', 'PSB_POETA_AG_PROCESS_UNDEFINED') ;
  l_error_msg := fnd_message.get_encoded ;

  wf_engine.SetItemAttrText( itemtype     => itemtype,
			     itemkey      => itemkey,
			     aname        => 'ERROR_MESSAGE',
			     avalue       => l_error_msg
			   );

  result := 'COMPLETE:FAILURE';
  RETURN;

EXCEPTION

  WHEN OTHERS THEN
    --
    -- Error message routine for debugging.
    --
    wf_core.context( pkg_name   => 'PSB_Workflow_Pvt '                 ,
		     proc_name  => 'No_Process_Defined'                ,
		     arg1       => 'Error: No valid process defined.'  ,
		     arg2       => null                                ,
		     arg3       => null                                ,
		     arg4       => null                                ,
		     arg5       => null
		    );
    RAISE;
    --
END No_Process_Defined ;
/*---------------------------------------------------------------------------*/



/*---------------------------DEBUG INFORMATION-------------------------------*/
PROCEDURE Add_Debug_Info
(
  p_string            IN       VARCHAR2
)
IS
BEGIN
  -- Add to g_dbug only if there is no overflow.
  IF length(g_dbug || g_chr10 || p_string) <= 32767 THEN
    g_dbug := g_dbug || g_chr10 || p_string ;
  END IF;
END Add_Debug_Info;


-- This Module is used to retrieve Debug Information.
FUNCTION get_debug RETURN VARCHAR2
IS
BEGIN
  RETURN (g_dbug);
END get_debug;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE pd (Private)                                |
 +===========================================================================*/
--
-- Private procedure to print debug info. The name is tried to keep as
-- short as possible for better documentaion.
--
PROCEDURE pd
(
   p_message  IN   VARCHAR2
)
IS
--
BEGIN

  IF g_debug_flag = 'Y' THEN
    NULL;
    -- DBMS_OUTPUT.Put_Line('PSBWKFLB : ' || p_message) ;
  END IF;

END pd ;
/*---------------------------------------------------------------------------*/


END PSB_Workflow_Pvt ;

/
