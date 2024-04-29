--------------------------------------------------------
--  DDL for Package Body PSB_WS_OPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_OPS_PVT" AS
/* $Header: PSBVWLOB.pls 120.14.12010000.3 2009/04/26 16:34:48 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_Ops_Pvt';

/*--------------------------- Global variables -----------------------------*/
  g_current_date           DATE   := sysdate;
  g_current_user_id        NUMBER := FND_GLOBAL.USER_ID;
  g_current_login_id       NUMBER := FND_GLOBAL.LOGIN_ID;
/*----------------------- End Global variables -----------------------------*/


/*----------------------- Private Routine prototypes  -----------------------*/

  PROCEDURE Create_Local_Dist_Pvt
  (
    p_account_line_id       IN   psb_ws_lines.account_line_id%TYPE            ,
    p_new_worksheet_id      IN   psb_worksheets.worksheet_id%TYPE             ,
    p_new_position_line_id  IN   psb_ws_lines_positions.position_line_id%TYPE ,
    p_return_status         OUT  NOCOPY  VARCHAR2
  ) ;

 /*Bug:6367584:start*/
 PROCEDURE Create_Local_Pay_Dist
 (
  p_worksheet_id             IN       psb_ws_lines.worksheet_id%TYPE,
  p_new_worksheet_id         IN       psb_ws_lines.worksheet_id%TYPE,
  p_operation_type           IN       varchar2,
  p_return_status            OUT  NOCOPY VARCHAR2
 );
  /*Bug:6367584:end*/

  PROCEDURE Insert_WS_Lines_Pvt
  (
    p_worksheet_id          IN   psb_ws_lines.worksheet_id%TYPE,
    p_account_line_id       IN   psb_ws_lines.account_line_id%TYPE,
    p_freeze_flag           IN   psb_ws_lines.freeze_flag%TYPE,
    p_view_line_flag        IN   psb_ws_lines.view_line_flag%TYPE,
    p_last_update_date      IN   psb_ws_lines.last_update_date%TYPE,
    p_last_updated_by       IN   psb_ws_lines.last_updated_by%TYPE,
    p_last_update_login     IN   psb_ws_lines.last_update_login%TYPE,
    p_created_by            IN   psb_ws_lines.created_by%TYPE,
    p_creation_date         IN   psb_ws_lines.creation_date%TYPE,
    p_return_status         OUT  NOCOPY  VARCHAR2
  ) ;

  PROCEDURE Delete_Worksheet_Pvt
  (
    p_worksheet_id          IN   psb_worksheets.worksheet_id%TYPE ,
    p_budget_by_position    IN   psb_worksheets.budget_by_position%TYPE ,
    p_delete_lines_flag     IN   VARCHAR2 ,
    p_return_status         OUT  NOCOPY  VARCHAR2
  ) ;

/*------------------- End Private Routines prototypes  ----------------------*/


/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Enforce_WS_Concurrency                        |
 +===========================================================================*/
--
-- The worksheet operations may affect one or more worksheets depending on
-- the type of the operation. This API locks all the relevent worksheets
-- required for a worksheet operation.
--
PROCEDURE Enforce_WS_Concurrency
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE  ,
  p_parent_or_child_mode      IN       VARCHAR2 ,
  p_maintenance_mode          IN       VARCHAR2 := 'MAINTENANCE'
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Enforce_WS_Concurrency' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_worksheets_tab          PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;
  --
BEGIN
  --
  SAVEPOINT Enforce_WS_Concurrency_Pvt ;
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

  --
  -- First lock the current worksheet p_worksheet_id
  --
  PSB_Concurrency_Control_Pub.Enforce_Concurrency_Control
  (
     p_api_version                 => 1.0 ,
     p_init_msg_list               => FND_API.G_FALSE ,
     p_validation_level            => FND_API.G_VALID_LEVEL_NONE ,
     p_return_status               => l_return_status ,
     p_msg_count                   => l_msg_count ,
     p_msg_data                    => l_msg_data ,
     --
     p_concurrency_class           => NVL( p_maintenance_mode, 'MAINTENANCE'),
     p_concurrency_entity_name     => 'WORKSHEET',
     p_concurrency_entity_id       => p_worksheet_id
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Find parent or child worksheets depending on p_parent_or_child_mode
  -- parameter.
  --
  IF p_parent_or_child_mode = 'PARENT' THEN
    --
    PSB_WS_Ops_Pvt.Find_Parent_Worksheets
    (
       p_api_version             =>   1.0 ,
       p_init_msg_list           =>   FND_API.G_FALSE,
       p_commit                  =>   FND_API.G_FALSE,
       p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status           =>   l_return_status,
       p_msg_count               =>   l_msg_count,
       p_msg_data                =>   l_msg_data,
       --
       p_worksheet_id            =>   p_worksheet_id,
       p_worksheet_tbl           =>   l_worksheets_tab
    );
    --
  ELSIF p_parent_or_child_mode = 'CHILD' THEN
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
       p_worksheet_id       =>   p_worksheet_id,
       p_worksheet_tbl      =>   l_worksheets_tab
    );
    --
  END IF ;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  FOR i IN 1..l_worksheets_tab.COUNT
  LOOP
    --
    -- Lock parent or child worksheets retrieved in the previous step.
    --
    PSB_Concurrency_Control_Pub.Enforce_Concurrency_Control
    (
       p_api_version              => 1.0 ,
       p_init_msg_list            => FND_API.G_FALSE ,
       p_validation_level         => FND_API.G_VALID_LEVEL_NONE ,
       p_return_status            => l_return_status ,
       p_msg_count                => l_msg_count ,
       p_msg_data                 => l_msg_data ,
       --
       p_concurrency_class        => NVL( p_maintenance_mode, 'MAINTENANCE'),
       p_concurrency_entity_name  => 'WORKSHEET',
       p_concurrency_entity_id    => l_worksheets_tab(i)
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    --
  END LOOP ;

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
    -- For Bug 4337768: Commenting out Rollack.
    -- ROLLBACK TO Enforce_WS_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Enforce_WS_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Enforce_WS_Concurrency_Pvt ;
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
END Enforce_WS_Concurrency ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Check_WS_Ops_Concurrency                      |
 +===========================================================================*/
--
-- The API checks for the operation type to invoke appropriate concurrency
-- control routines.
--
PROCEDURE Check_WS_Ops_Concurrency
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
  p_operation_type            IN       VARCHAR2
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Check_WS_Ops_Concurrency';
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
BEGIN
  --
  SAVEPOINT Check_WS_Ops_Concurrency_Pvt ;
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

  IF p_operation_type IN ('VALIDATE', 'COPY') THEN
    --
    -- No locks are required for 'VALIDATE' and 'COPY' operations as
    -- these perform read-only operations on the worksheets.
    --
    NULL ;
    --
  ELSIF p_operation_type IN ('FREEZE', 'SUBMIT' ) THEN
    --
    -- Lock in 'CHILD' mode as the child worksheets also need to be frozen.
    --
    PSB_WS_Ops_Pvt.Enforce_WS_Concurrency
    (
       p_api_version              =>  1.0,
       p_init_msg_list            =>  FND_API.G_FALSE ,
       p_commit                   =>  FND_API.G_FALSE ,
       p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
       p_return_status            =>  l_return_status,
       p_msg_count                =>  l_msg_count,
       p_msg_data                 =>  l_msg_data,
       --
       p_worksheet_id             =>  p_worksheet_id ,
       p_parent_or_child_mode     =>  'CHILD' ,
       p_maintenance_mode         =>  'MAINTENANCE'
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  ELSIF p_operation_type IN ('MOVE') THEN
    --
    -- Lock in 'CHILD' mode as the child worksheets are frozen.
    --
    PSB_WS_Ops_Pvt.Enforce_WS_Concurrency
    (
       p_api_version              =>  1.0,
       p_init_msg_list            =>  FND_API.G_FALSE ,
       p_commit                   =>  FND_API.G_FALSE ,
       p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
       p_return_status            =>  l_return_status,
       p_msg_count                =>  l_msg_count,
       p_msg_data                 =>  l_msg_data,
       --
       p_worksheet_id             =>  p_worksheet_id ,
       p_parent_or_child_mode     =>  'CHILD' ,
       p_maintenance_mode         =>  'MAINTENANCE'
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

    --
    -- Also lock in 'PARENT' mode to update their view_flag as per the
    -- service package selection.
    --
    PSB_WS_Ops_Pvt.Enforce_WS_Concurrency
    (
       p_api_version              =>  1.0,
       p_init_msg_list            =>  FND_API.G_FALSE ,
       p_commit                   =>  FND_API.G_FALSE ,
       p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
       p_return_status            =>  l_return_status,
       p_msg_count                =>  l_msg_count,
       p_msg_data                 =>  l_msg_data,
       --
       p_worksheet_id             =>  p_worksheet_id ,
       p_parent_or_child_mode     =>  'PARENT' ,
       p_maintenance_mode         =>  'MAINTENANCE'
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  ELSIF p_operation_type IN ('MERGE' ) THEN
    --
    -- Lock only the target worksheet in 'PARENT' mode as the changes in
    -- the source worksheet are to be applied to the target and parent
    -- worksheets. The targer worksheet is passed as p_worksheet_id.
    --
    PSB_WS_Ops_Pvt.Enforce_WS_Concurrency
    (
       p_api_version              =>  1.0,
       p_init_msg_list            =>  FND_API.G_FALSE,
       p_commit                   =>  FND_API.G_FALSE,
       p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
       p_return_status            =>  l_return_status,
       p_msg_count                =>  l_msg_count,
       p_msg_data                 =>  l_msg_data,
       --
       p_worksheet_id             =>  p_worksheet_id ,
       p_parent_or_child_mode     =>  'PARENT'   ,
       p_maintenance_mode         =>  'MAINTENANCE'
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  ELSIF p_operation_type IN ('UNFREEZE' ) THEN
    --
    -- Lock only the current worksheet.
    --
    PSB_Concurrency_Control_Pub.Enforce_Concurrency_Control
    (
       p_api_version              =>  1.0,
       p_init_msg_list            =>  FND_API.G_FALSE,
       p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
       p_return_status            =>  l_return_status,
       p_msg_count                =>  l_msg_count,
       p_msg_data                 =>  l_msg_data,
       --
       p_concurrency_class        =>  'MAINTENANCE' ,
       p_concurrency_entity_name  =>  'WORKSHEET'   ,
       p_concurrency_entity_id    =>  p_worksheet_id
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  ELSE
    --
    Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_ARGUMENT') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
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
    -- For Bug 4337768: Commenting out Rollback.
    -- ROLLBACK TO Check_WS_Ops_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_WS_Ops_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_WS_Ops_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name );
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
END Check_WS_Ops_Concurrency ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |          PROCEDURE Create_Worksheet ( From account/position set table )   |
 +===========================================================================*/
--
-- The overloaded API creates a worksheet from a PL/SQL table of sets.
-- It also considers service packages. By default all the service packages
-- are considered. When a new worksheet needs to be created during submit
-- operation, the user can pick which service packages to be considered.
-- ( Note that we do not need to consider effective dates as the matching is
--   to be performed against the given account/position set.)
--
PROCEDURE Create_Worksheet
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE    ,
  p_budget_group_id           IN       psb_worksheets.budget_group_id%TYPE ,
  p_account_position_set_tbl  IN       account_position_set_tbl_type ,
  p_service_package_operation_id
			      IN       NUMBER := FND_API.G_MISS_NUM ,
  p_worksheet_id_OUT          OUT  NOCOPY      psb_worksheets.worksheet_id%TYPE
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Create_Worksheet(Set)' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_worksheet_name          psb_worksheets.name%TYPE ;
  l_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_worksheet_description   psb_worksheets.description%TYPE ;
  l_main_worksheet_name     psb_worksheets.name%TYPE ;
  l_main_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  l_main_budget_group_name  psb_budget_groups.name%TYPE ;
  l_main_budget_calendar_id psb_worksheets.budget_calendar_id%TYPE ;
  l_new_worksheet_id        psb_worksheets.worksheet_id%TYPE ;
  l_global_worksheet_id     psb_worksheets.worksheet_id%TYPE ;
  l_service_package_count   NUMBER ;
  --
  l_tmp_char                VARCHAR2(1) ;
  l_lines_added             NUMBER := 0 ;
  --
  CURSOR l_worksheets_csr IS
	 SELECT *
	 FROM psb_worksheets
	 WHERE worksheet_id = p_worksheet_id ;
  --
  l_worksheets_rec   l_worksheets_csr%ROWTYPE ;
  --
  CURSOR l_budget_accounts_csr
	 ( c_current_account_set_id
		    psb_account_position_sets.account_position_set_id%TYPE,
	   c_code_combination_id
		    psb_budget_accounts.code_combination_id%TYPE
	  )
	 IS
	 SELECT '1'
	 FROM   psb_budget_accounts
	 WHERE  account_position_set_id = c_current_account_set_id
	 AND    code_combination_id     = c_code_combination_id     ;
  --

  CURSOR l_budget_positions_csr
	 ( c_current_account_set_id
		    psb_account_position_sets.account_position_set_id%TYPE,
	   c_position_id
		    psb_budget_positions.position_id%TYPE
	  )
	 IS
	 SELECT '1'
	 FROM   psb_budget_positions
	 WHERE  account_position_set_id = c_current_account_set_id
	 AND    position_id             = c_position_id     ;
  --
BEGIN
  --
  SAVEPOINT Create_Worksheet_Pvt ;
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
  p_worksheet_id_OUT := 0 ;
  --

  --
  -- Validating p_budget_group_id.
  --
  SELECT '1' INTO l_tmp_char
  FROM   psb_budget_groups
  WHERE  budget_group_id = p_budget_group_id ;

  --
  -- Validating p_account_position_set_tbl table.
  --
  IF p_account_position_set_tbl.COUNT = 0 THEN
    --
    Fnd_Message.Set_Name ('PSB',     'PSB_INVALID_ARGUMENT') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;


  --
  -- Finding the worksheet information.
  --
  OPEN  l_worksheets_csr ;

  FETCH l_worksheets_csr INTO l_worksheets_rec ;

  IF ( l_worksheets_csr%NOTFOUND ) THEN
    --
    Fnd_Message.Set_Name ('PSB',     'PSB_INVALID_WORKSHEET_ID') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- l_budget_by_position defines whether worksheet contains positions or not.
  l_budget_by_position      := NVL(l_worksheets_rec.budget_by_position, 'N') ;

  l_main_worksheet_name     := l_worksheets_rec.name ;
  l_main_budget_group_id    := l_worksheets_rec.budget_group_id ;
  l_main_budget_calendar_id := l_worksheets_rec.budget_calendar_id ;

  --
  -- Finding the main budget group name.
  --
  SELECT name INTO l_main_budget_group_name
  FROM   psb_budget_groups
  WHERE  budget_group_id = l_main_budget_group_id ;

  --
  -- Get translated messages for the new worksheet.
  --
  Fnd_Message.Set_Name ( 'PSB', 'PSB_WORKSHEET_CREATION_INFO') ;
  Fnd_Message.Set_Token( 'WORKSHEET_ID',      p_worksheet_id ) ;
  Fnd_Message.Set_Token( 'BUDGET_GROUP_NAME', l_main_budget_group_name ) ;
  l_worksheet_description := Fnd_Message.Get ;

  --
  -- Find global worksheet related information, use by Create_Worksheet API.
  --
  IF NVL(l_worksheets_rec.global_worksheet_flag, 'N') = 'Y' THEN
    l_global_worksheet_id := p_worksheet_id ;
  ELSE
    l_global_worksheet_id := l_worksheets_rec.global_worksheet_id ;
  END IF ;

  --
  -- Create the new worksheet in psb_worksheets table.
  --
  PSB_Worksheet_Pvt.Create_Worksheet
  (
     p_api_version               => 1.0 ,
     p_init_msg_list             => FND_API.G_FALSE,
     p_commit                    => FND_API.G_FALSE,
     p_validation_level          => FND_API.G_VALID_LEVEL_NONE,
     p_return_status             => l_return_status,
     p_msg_count                 => l_msg_count,
     p_msg_data                  => l_msg_data ,
     --
     p_budget_group_id           => p_budget_group_id,
     p_budget_calendar_id        => l_worksheets_rec.budget_calendar_id,
     p_worksheet_type            => 'R',
     p_name                      => NULL ,
     p_description               => l_worksheet_description ,
     p_ws_creation_complete      => l_worksheets_rec.ws_creation_complete ,
     p_stage_set_id              => l_worksheets_rec.stage_set_id ,
     p_current_stage_seq         => l_worksheets_rec.current_stage_seq ,
     p_global_worksheet_id       => l_global_worksheet_id ,
     p_global_worksheet_flag     => 'N' ,
     p_global_worksheet_option   => l_worksheets_rec.global_worksheet_option,
     p_local_copy_flag           => l_worksheets_rec.local_copy_flag,
     p_copy_of_worksheet_id      => l_worksheets_rec.copy_of_worksheet_id,
     p_freeze_flag               => l_worksheets_rec.freeze_flag,
     p_budget_by_position        => l_worksheets_rec.budget_by_position,
     p_use_revised_element_rates => l_worksheets_rec.use_revised_element_rates,
     p_num_proposed_years        => l_worksheets_rec.num_proposed_years,
     p_num_years_to_allocate     => l_worksheets_rec.num_years_to_allocate,
     p_rounding_factor           => l_worksheets_rec.rounding_factor,
     p_gl_cutoff_period          => l_worksheets_rec.gl_cutoff_period,
     p_include_stat_balance      => l_worksheets_rec.include_stat_balance,
     p_include_trans_balance     => l_worksheets_rec.include_translated_balance,
     p_include_adj_period        => l_worksheets_rec.include_adjustment_periods,
     p_data_extract_id           => l_worksheets_rec.data_extract_id,
     p_parameter_set_id          => NULL,
     p_constraint_set_id         => NULL,
     p_allocrule_set_id          => NULL,
     p_date_submitted            => l_worksheets_rec.date_submitted,
     p_submitted_by              => l_worksheets_rec.submitted_by,
     p_attribute1                => l_worksheets_rec.attribute1,
     p_attribute2                => l_worksheets_rec.attribute2,
     p_attribute3                => l_worksheets_rec.attribute3,
     p_attribute4                => l_worksheets_rec.attribute4,
     p_attribute5                => l_worksheets_rec.attribute5,
     p_attribute6                => l_worksheets_rec.attribute6,
     p_attribute7                => l_worksheets_rec.attribute7,
     p_attribute8                => l_worksheets_rec.attribute8,
     p_attribute9                => l_worksheets_rec.attribute9,
     p_attribute10               => l_worksheets_rec.attribute10,
     p_context                   => l_worksheets_rec.context,
     /* Included federal_ws_flag for Bug 3157960 */
     p_federal_ws_flag           => l_worksheets_rec.federal_ws_flag,
     p_worksheet_id              => l_new_worksheet_id
  );
  --
  CLOSE l_worksheets_csr ;
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Get budget calendar related info to find all the budget groups down in the
  -- current hierarchy to get all the CCIDs for the current budget group.
  --
  IF NVL(PSB_WS_Acct1.g_budget_calendar_id, -99) <> l_main_budget_calendar_id
  THEN
    --
    PSB_WS_Acct1.Cache_Budget_Calendar
    (
       p_return_status         =>  l_return_status ,
       p_budget_calendar_id    =>  l_main_budget_calendar_id
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  --
  -- Check whether service packages were selected for the worksheet.
  -- If yes, then we need to consider only those account lines which are
  -- related to the service package selection.
  --
  SELECT count(*) INTO l_service_package_count
  FROM   psb_ws_submit_service_packages
  WHERE  worksheet_id = p_worksheet_id
  AND    operation_id = NVL( p_service_package_operation_id ,
			     FND_API.G_MISS_NUM ) ;
  FOR l_lines_rec IN
  (
     SELECT lines.* ,
	    accts.code_combination_id ,
	    accts.budget_group_id
     FROM   psb_ws_lines         lines ,
	    psb_ws_account_lines accts
     WHERE  lines.worksheet_id    = p_worksheet_id
     AND    lines.account_line_id = accts.account_line_id
     AND    ( l_service_package_count = 0
	      OR
	      accts.service_package_id IN
		      ( SELECT service_package_id
			FROM   psb_ws_submit_service_packages
			WHERE  worksheet_id = p_worksheet_id
			AND    operation_id = p_service_package_operation_id )
	    )
  )
  LOOP
    --
    -- Search l_lines_rec.code_combination_id in the
    -- p_account_position_set_tbl table.
    --
    FOR i IN 1..p_account_position_set_tbl.COUNT
    LOOP

      -- Process only account sets first.  Using GOTO as PL/SQL lacks
      -- CONTINUE statement.
      IF p_account_position_set_tbl(i).account_or_position_type = 'P' THEN
	GOTO end_account_loop ;
      END IF;

      --
      OPEN l_budget_accounts_csr
	   (  p_account_position_set_tbl(i).account_position_set_id ,
	      l_lines_rec.code_combination_id ) ;

      FETCH l_budget_accounts_csr INTO l_tmp_char;
      --
      IF ( l_budget_accounts_csr%FOUND ) THEN

	-- At least one line should get created for the worksheet.
	l_lines_added := l_lines_added + 1 ;

	--
	-- Put the CCID in the psb_ws_lines table for the new worksheet.
	--
	Insert_WS_Lines_Pvt
	(
	  p_worksheet_id       =>  l_new_worksheet_id,
	  p_account_line_id    =>  l_lines_rec.account_line_id ,
	  p_freeze_flag        =>  l_lines_rec.freeze_flag ,
	  p_view_line_flag     =>  l_lines_rec.view_line_flag ,
	  p_last_update_date   =>  g_current_date,
	  p_last_updated_by    =>  g_current_user_id,
	  p_last_update_login  =>  g_current_login_id,
	  p_created_by         =>  g_current_user_id,
	  p_creation_date      =>  g_current_date,
	  p_return_status      =>  l_return_status
	) ;
	--
	CLOSE l_budget_accounts_csr;
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
	EXIT;
	--
      ELSE
	--
	CLOSE l_budget_accounts_csr ;
      END IF;
      --
      <<end_account_loop>>
      NULL;
    END LOOP;
    --
  END LOOP;

  --
  -- Maintain psb_ws_lines_positions table if worksheet contains positions.
  --
  IF l_budget_by_position = 'Y' THEN

    --
    -- This loop gets all the position for the given worksheet. To maintain
    -- psb_ws_lines_positions matrix table for the new worksheet, we will
    -- consider all the positions falling in the given table of position sets.
    --
    FOR l_lines_pos_rec IN
    (
       SELECT pos_lines.*     ,
	      pos.position_id
       FROM   psb_ws_lines_positions   pos_lines ,
	      psb_ws_position_lines    pos
       WHERE  pos_lines.worksheet_id = p_worksheet_id
       AND    pos.position_line_id   = pos_lines.position_line_id
       AND    (
		l_service_package_count = 0
		OR
		pos_lines.position_line_id IN
		(
		  SELECT accts.position_line_id
		  FROM   psb_ws_account_lines  accts
		  WHERE  accts.position_line_id = pos_lines.position_line_id
		  AND    accts.service_package_id IN
			 (
			   SELECT sp.service_package_id
			   FROM   psb_ws_submit_service_packages  sp
			   WHERE  worksheet_id = p_worksheet_id
			   AND    operation_id = p_service_package_operation_id
			 )
		)
	      )
    )
    LOOP
      --
      -- Search l_lines_pos_rec.position_id in the p_account_position_set_tbl
      -- table.
      --
      FOR i IN 1..p_account_position_set_tbl.COUNT
      LOOP

	-- Process only position sets now.  Using GOTO as PL/SQL lacks
	-- CONTINUE statement.
	IF p_account_position_set_tbl(i).account_or_position_type = 'A' THEN
	  GOTO end_position_loop ;
	END IF;

	OPEN l_budget_positions_csr
	     (  p_account_position_set_tbl(i).account_position_set_id ,
		l_lines_pos_rec.position_id ) ;
	--
	FETCH l_budget_positions_csr INTO l_tmp_char;
	--
	IF ( l_budget_positions_csr%FOUND ) THEN

	  -- At least one line should get created for the worksheet.
	  l_lines_added := l_lines_added + 1 ;

	  --
	  -- Put the position_line in the psb_ws_lines_position table.
	  --
	  PSB_WS_Pos_Pvt.Create_Position_Matrix
	  (
	    p_api_version        =>  1.0 ,
	    p_init_msg_list      =>  FND_API.G_FALSE ,
	    p_validation_level   =>  FND_API.G_VALID_LEVEL_NONE ,
	    p_return_status      =>  l_return_status ,
	    p_msg_count          =>  l_msg_count ,
	    p_msg_data           =>  l_msg_data ,
	    --
	    p_worksheet_id       =>  l_new_worksheet_id ,
	    p_position_line_id   =>  l_lines_pos_rec.position_line_id ,
	    p_freeze_flag        =>  l_lines_pos_rec.freeze_flag ,
	    p_view_line_flag     =>  l_lines_pos_rec.view_line_flag
	  ) ;
	  --
	  CLOSE l_budget_positions_csr ;
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --

	  --
	  -- Maintain psb_ws_lines matrix for the account lines related to
	  -- current position_line_id (l_lines_pos_rec.position_line_id).
	  --
	  FOR l_lines_rec IN
	  (
	    SELECT lines.*
	    FROM   psb_ws_lines          lines,
		   psb_ws_account_lines  accts
	    WHERE  accts.position_line_id = l_lines_pos_rec.position_line_id
	    AND    lines.worksheet_id     = p_worksheet_id
	    AND    lines.account_line_id  = accts.account_line_id
	  )
	  LOOP
	    --
	    Insert_WS_Lines_Pvt
	    (
	      p_worksheet_id       =>  l_new_worksheet_id,
	      p_account_line_id    =>  l_lines_rec.account_line_id ,
	      p_freeze_flag        =>  l_lines_rec.freeze_flag ,
	      p_view_line_flag     =>  l_lines_rec.view_line_flag ,
	      p_last_update_date   =>  g_current_date,
	      p_last_updated_by    =>  g_current_user_id,
	      p_last_update_login  =>  g_current_login_id,
	      p_created_by         =>  g_current_user_id,
	      p_creation_date      =>  g_current_date,
	      p_return_status      =>  l_return_status
	    ) ;
	    --
	    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR ;
	    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	    END IF;
	    --
	  END LOOP ;

	  EXIT;
	  --
	ELSE
	  CLOSE l_budget_positions_csr ;
	END IF ;
	--
	<<end_position_loop>>
	NULL;
      END LOOP ;  --/ To process position_set table for the current position
      --
    END LOOP ;    -- /To process all the positions in the parent worksheet

  END IF ;

  --
  -- Check whether at least one line got created or not.
  --
  IF l_lines_added = 0 THEN
    p_worksheet_id_OUT := 0 ;
    ROLLBACK TO Create_Worksheet_Pvt ;
  ELSE
    p_worksheet_id_OUT := l_new_worksheet_id ;
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
    ROLLBACK TO Create_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Create_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_worksheets_csr%ISOPEN ) THEN
      CLOSE l_worksheets_csr ;
    END IF ;
    --
    IF ( l_budget_accounts_csr%ISOPEN ) THEN
      CLOSE l_budget_accounts_csr ;
    END IF ;
    --
    ROLLBACK TO Create_Worksheet_Pvt ;
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
END Create_Worksheet;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                PROCEDURE Create_Worksheet ( From a worksheet )            |
 +===========================================================================*/
--
-- This overloaded API creates a new worksheet for a given budget group.
--
PROCEDURE Create_Worksheet
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE    ,
  p_budget_group_id           IN       psb_worksheets.budget_group_id%TYPE ,
  p_worksheet_id_OUT          OUT  NOCOPY      psb_worksheets.worksheet_id%TYPE
)

IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Create_Worksheet' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_worksheet_name          psb_worksheets.name%TYPE ;
  l_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_worksheet_description   psb_worksheets.description%TYPE ;
  l_main_worksheet_name     psb_worksheets.name%TYPE ;
  l_main_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  l_main_budget_group_name  psb_budget_groups.name%TYPE ;
  l_main_budget_calendar_id psb_worksheets.budget_calendar_id%TYPE ;
  l_new_worksheet_id        psb_worksheets.worksheet_id%TYPE ;
  l_global_worksheet_id     psb_worksheets.worksheet_id%TYPE ;
  --
  l_tmp_char                VARCHAR2(1) ;
  --
  CURSOR l_worksheets_csr IS
	 SELECT *
	 FROM   psb_worksheets
	 WHERE  worksheet_id = p_worksheet_id ;
  --
  l_ws_row_type l_worksheets_csr%ROWTYPE ;
  --
BEGIN
  --
  SAVEPOINT Create_Worksheet_Pvt ;
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

  --
  -- Validating p_budget_group_id.
  --
  SELECT '1' INTO l_tmp_char
  FROM   psb_budget_groups
  WHERE  budget_group_id = p_budget_group_id ;

  --
  -- Finding the worksheet information.
  --
  OPEN  l_worksheets_csr ;

  FETCH l_worksheets_csr INTO l_ws_row_type ;

  IF ( l_worksheets_csr%NOTFOUND ) THEN
    --
    Fnd_Message.Set_Name ('PSB',     'PSB_INVALID_WORKSHEET_ID') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- l_budget_by_position defines whether worksheet contains positions or not.
  l_budget_by_position      := NVL(l_ws_row_type.budget_by_position, 'N') ;

  l_main_worksheet_name     := l_ws_row_type.name ;
  l_main_budget_group_id    := l_ws_row_type.budget_group_id ;
  l_main_budget_calendar_id := l_ws_row_type.budget_calendar_id ;

  --
  -- Finding the main budget group name.
  --
  SELECT name INTO l_main_budget_group_name
  FROM   psb_budget_groups
  WHERE  budget_group_id = l_main_budget_group_id ;

  --
  -- Get translated messages for the new worksheet.
  --
  Fnd_Message.Set_Name ( 'PSB', 'PSB_WORKSHEET_CREATION_INFO') ;
  Fnd_Message.Set_Token( 'WORKSHEET_ID',      p_worksheet_id ) ;
  Fnd_Message.Set_Token( 'BUDGET_GROUP_NAME', l_main_budget_group_name ) ;
  l_worksheet_description := Fnd_Message.Get ;

  --
  -- Find global worksheet related information, use by Create_Worksheet API.
  --
  IF NVL(l_ws_row_type.global_worksheet_flag, 'N') = 'Y' THEN
    l_global_worksheet_id := p_worksheet_id ;
  ELSE
    l_global_worksheet_id := l_ws_row_type.global_worksheet_id ;
  END IF ;

  --
  -- Create the new worksheet in psb_worksheets table.
  --
  PSB_Worksheet_Pvt.Create_Worksheet
  (
   p_api_version                 => 1.0 ,
   p_init_msg_list               => FND_API.G_FALSE,
   p_commit                      => FND_API.G_FALSE,
   p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
   p_return_status               => l_return_status,
   p_msg_count                   => l_msg_count,
   p_msg_data                    => l_msg_data ,
   --
   p_budget_group_id             => p_budget_group_id,
   p_budget_calendar_id          => l_ws_row_type.budget_calendar_id,
   p_worksheet_type              => 'O',
   p_name                        => NULL ,
   p_description                 => l_worksheet_description ,
   p_ws_creation_complete        => l_ws_row_type.ws_creation_complete ,
   p_stage_set_id                => l_ws_row_type.stage_set_id,
   p_current_stage_seq           => l_ws_row_type.current_stage_seq,
   p_global_worksheet_id         => l_global_worksheet_id ,
   p_global_worksheet_flag       => 'N' ,
   p_global_worksheet_option     => l_ws_row_type.global_worksheet_option,
   p_local_copy_flag             => l_ws_row_type.local_copy_flag,
   p_copy_of_worksheet_id        => l_ws_row_type.copy_of_worksheet_id,
   p_freeze_flag                 => l_ws_row_type.freeze_flag,
   p_budget_by_position          => l_ws_row_type.budget_by_position,
   p_use_revised_element_rates   => l_ws_row_type.use_revised_element_rates,
   p_num_proposed_years          => l_ws_row_type.num_proposed_years,
   p_num_years_to_allocate       => l_ws_row_type.num_years_to_allocate,
   p_rounding_factor             => l_ws_row_type.rounding_factor,
   p_gl_cutoff_period            => l_ws_row_type.gl_cutoff_period,
   p_include_stat_balance        => l_ws_row_type.include_stat_balance,
   p_include_trans_balance       => l_ws_row_type.include_translated_balance,
   p_include_adj_period          => l_ws_row_type.include_adjustment_periods,
   p_data_extract_id             => l_ws_row_type.data_extract_id,
   p_parameter_set_id            => NULL,
   p_constraint_set_id           => NULL,
   p_allocrule_set_id            => NULL,
   p_date_submitted              => l_ws_row_type.date_submitted,
   p_submitted_by                => l_ws_row_type.submitted_by,
   p_attribute1                  => l_ws_row_type.attribute1,
   p_attribute2                  => l_ws_row_type.attribute2,
   p_attribute3                  => l_ws_row_type.attribute3,
   p_attribute4                  => l_ws_row_type.attribute4,
   p_attribute5                  => l_ws_row_type.attribute5,
   p_attribute6                  => l_ws_row_type.attribute6,
   p_attribute7                  => l_ws_row_type.attribute7,
   p_attribute8                  => l_ws_row_type.attribute8,
   p_attribute9                  => l_ws_row_type.attribute9,
   p_attribute10                 => l_ws_row_type.attribute10,
   p_context                     => l_ws_row_type.context,
   p_worksheet_id                => l_new_worksheet_id
  );
  --
  CLOSE l_worksheets_csr ;
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  --
  -- Get budget calendar related info to find all the budget groups down in the
  -- current hierarchy to get all the CCIDs for the current budget group.
  --
  IF NVL(PSB_WS_Acct1.g_budget_calendar_id, -99) <> l_main_budget_calendar_id
  THEN
    --
    PSB_WS_Acct1.Cache_Budget_Calendar
    (
       p_return_status         =>  l_return_status ,
       p_budget_calendar_id    =>  l_main_budget_calendar_id
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  --
  -- This LOOP gets all the account_line_id for the new worksheet which will
  -- be used to maintain psb_ws_lines table.
  --
  FOR l_lines_rec IN
  (
     SELECT lines.*
     FROM   psb_ws_lines          lines ,
	    psb_ws_account_lines  accts
     WHERE  lines.worksheet_id    = p_worksheet_id
     AND    lines.account_line_id = accts.account_line_id
     /*For Bug No : 2236283 Start*/
     /*
     AND    accts.budget_group_id  IN
	       (  SELECT budget_group_id
		    FROM psb_budget_groups
		   WHERE budget_group_type = 'R'
		     AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
		     AND ((effective_end_date IS NULL)
			   OR
			  (effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
		  START WITH budget_group_id       = p_budget_group_id
		  CONNECT BY PRIOR budget_group_id = parent_budget_group_id
	       )
     */
     AND EXISTS
	       (  SELECT 1
		    FROM psb_budget_groups
		   WHERE budget_group_type = 'R'
		     AND budget_group_id = accts.budget_group_id
		     AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
		     AND ((effective_end_date IS NULL)
			   OR
			  (effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
		  START WITH budget_group_id       = p_budget_group_id
		  CONNECT BY PRIOR budget_group_id = parent_budget_group_id
	       )
     /*For Bug No : 2236283 End*/
  )
  LOOP

    --
    -- Put the CCID in the psb_ws_lines table for the new worksheet.
    --
    Insert_WS_Lines_Pvt
    (
      p_worksheet_id       =>  l_new_worksheet_id,
      p_account_line_id    =>  l_lines_rec.account_line_id ,
      p_freeze_flag        =>  l_lines_rec.freeze_flag ,
      p_view_line_flag     =>  l_lines_rec.view_line_flag ,
      p_last_update_date   =>  g_current_date,
      p_last_updated_by    =>  g_current_user_id,
      p_last_update_login  =>  g_current_login_id,
      p_created_by         =>  g_current_user_id,
      p_creation_date      =>  g_current_date,
      p_return_status      =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP;
  --

  --
  -- Maintain psb_ws_lines_positions table if worksheet contains positions.
  -- ( This also means the worksheet includes position budgeting. )
  --
  IF l_budget_by_position = 'Y' THEN

    --
    -- This loop gets all the position_line_id for the new worksheet which will
    -- be used to maintain psb_ws_lines_positions table.
    --
    FOR l_lines_rec IN
    (
       SELECT lines.*
       FROM   psb_ws_lines_positions   lines ,
	      psb_ws_position_lines    pos
       WHERE  lines.worksheet_id     = p_worksheet_id
       AND    lines.position_line_id = pos.position_line_id
       /*For Bug No : 2236283 Start*/
       /*
       AND    lines.position_line_id IN
	      (
		SELECT acct_lines.position_line_id
		FROM   psb_ws_account_lines acct_lines
		WHERE  acct_lines.budget_group_id IN
		       (
			 SELECT bg.budget_group_id
			   FROM psb_budget_groups bg
			  WHERE bg.budget_group_type = 'R'
			    AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
			    AND ((effective_end_date IS NULL)
				  OR
				 (effective_end_date >= PSB_WS_Acct1.g_enddate_cy )
			       )
			 START WITH bg.budget_group_id = p_budget_group_id
			 CONNECT BY PRIOR bg.budget_group_id =
						     bg.parent_budget_group_id
		       )
	      )
       */
       AND    EXISTS
	      (
		SELECT 1
		  FROM psb_ws_account_lines acct_lines
		 WHERE acct_lines.position_line_id = lines.position_line_id
		   AND EXISTS
		       (
			 SELECT bg.budget_group_id
			   FROM psb_budget_groups bg
			  WHERE bg.budget_group_type = 'R'
			    AND budget_group_id = acct_lines.budget_group_id
			    AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
			    AND ((effective_end_date IS NULL)
				  OR
				 (effective_end_date >= PSB_WS_Acct1.g_enddate_cy )
			       )
			 START WITH bg.budget_group_id = p_budget_group_id
			 CONNECT BY PRIOR bg.budget_group_id =
						     bg.parent_budget_group_id
		       )
	      )
     /*For Bug No : 2236283 End*/
    )
    LOOP
      --
      -- Put the position_line_id in the psb_ws_lines_positions table for
      -- the new worksheet.
      --
      PSB_WS_Pos_Pvt.Create_Position_Matrix
      (
	p_api_version        =>  1.0 ,
	p_init_msg_list      =>  FND_API.G_FALSE ,
	p_validation_level   =>  FND_API.G_VALID_LEVEL_NONE ,
	p_return_status      =>  l_return_status ,
	p_msg_count          =>  l_msg_count ,
	p_msg_data           =>  l_msg_data ,
	--
	p_worksheet_id       =>  l_new_worksheet_id ,
	p_position_line_id   =>  l_lines_rec.position_line_id ,
	p_freeze_flag        =>  l_lines_rec.freeze_flag ,
	p_view_line_flag     =>  l_lines_rec.view_line_flag
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END LOOP;

  END IF;

  p_worksheet_id_OUT := l_new_worksheet_id;

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
    ROLLBACK TO Create_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Create_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_worksheets_csr%ISOPEN ) THEN
      CLOSE l_worksheets_csr ;
    END IF ;
    --
    ROLLBACK TO Create_Worksheet_Pvt ;
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

END Create_Worksheet;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Copy_Worksheet                              |
 +===========================================================================*/
--
-- The API is to copy a given worksheet.
--
PROCEDURE Copy_Worksheet
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
  p_worksheet_id_OUT          OUT  NOCOPY      psb_worksheets.worksheet_id%TYPE
)

IS
  --
  l_api_name                      CONSTANT VARCHAR2(30)   := 'Copy_Worksheet' ;
  l_api_version                   CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status                 VARCHAR2(1) ;
  l_msg_count                     NUMBER ;
  l_msg_data                      VARCHAR2(2000) ;
  --
  l_worksheet_name                psb_worksheets.name%TYPE ;
  l_budget_by_position            psb_worksheets.budget_by_position%TYPE ;
  l_worksheet_description         psb_worksheets.description%TYPE ;
  l_main_budget_group_name        psb_budget_groups.name%TYPE ;
  l_new_worksheet_id              psb_worksheets.worksheet_id%TYPE ;
  l_new_position_line_id          psb_ws_lines_positions.position_line_id%TYPE ;
  l_new_fte_line_id               psb_ws_fte_lines.fte_line_id%TYPE ;
  l_new_element_line_id           psb_ws_element_lines.element_line_id%TYPE ;
  l_new_position_assignment_id
			psb_position_assignments.position_assignment_id%TYPE ;
  l_rowid                         VARCHAR2(2000);
  l_period_amount_tbl             PSB_WS_Acct1.g_prdamt_tbl_type ;
  l_period_fte_tbl                PSB_WS_Acct1.g_prdamt_tbl_type ;
  l_segment_values_tbl            FND_FLEX_EXT.SegmentArray ;
  --
  l_dummy_account_line_id         psb_ws_account_lines.account_line_id%TYPE ;
  --
  CURSOR l_worksheets_csr IS
	 SELECT *
	 FROM   psb_worksheets
	 WHERE  worksheet_id = p_worksheet_id ;
  --
  l_ws_row_type l_worksheets_csr%ROWTYPE ;
  --
BEGIN
  --
  SAVEPOINT Copy_Worksheet_Pvt ;
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

  --
  -- Finding the worksheet information.
  --
  OPEN  l_worksheets_csr ;

  FETCH l_worksheets_csr INTO l_ws_row_type ;

  IF ( l_worksheets_csr%NOTFOUND ) THEN
    --
    Fnd_Message.Set_Name ('PSB',     'PSB_INVALID_WORKSHEET_ID') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- l_budget_by_position defines whether worksheet contains positions or not.
  l_budget_by_position := NVL(l_ws_row_type.budget_by_position, 'N') ;

  --
  -- Only official worksheet can be made copy of.
  --
  IF l_ws_row_type.worksheet_type <> 'O'  THEN
    Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_WORKSHEET_FOR_COPY') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  --
  -- Finding the main budget group name.
  --
  SELECT name INTO l_main_budget_group_name
  FROM   psb_budget_groups
  WHERE  budget_group_id = l_ws_row_type.budget_group_id ;

  --
  -- Get worksheet description.
  --
  Fnd_Message.Set_Name ( 'PSB', 'PSB_WORKSHEET_COPIED_INFO') ;
  Fnd_Message.Set_Token( 'WORKSHEET_ID',      p_worksheet_id ) ;
  Fnd_Message.Set_Token( 'BUDGET_GROUP_NAME', l_main_budget_group_name ) ;
  l_worksheet_description := Fnd_Message.Get ;

  --
  -- Create the new worksheet in psb_worksheets table.
  --
  PSB_Worksheet_Pvt.Create_Worksheet
  (
   p_api_version                 => 1.0 ,
   p_init_msg_list               => FND_API.G_FALSE,
   p_commit                      => FND_API.G_FALSE,
   p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
   p_return_status               => l_return_status,
   p_msg_count                   => l_msg_count,
   p_msg_data                    => l_msg_data ,
   --
   p_budget_group_id             => l_ws_row_type.budget_group_id,
   p_budget_calendar_id          => l_ws_row_type.budget_calendar_id,
   p_worksheet_type              => 'L',
   p_name                        => NULL ,
   p_description                 => l_worksheet_description ,
   p_ws_creation_complete        => l_ws_row_type.ws_creation_complete ,
   p_stage_set_id                => l_ws_row_type.stage_set_id,
   p_current_stage_seq           => l_ws_row_type.current_stage_seq,
   -- Bug 4310415
   -- If this itself is a global worksheet, pass the worksheet_id.
   p_global_worksheet_id
     => NVL(l_ws_row_type.global_worksheet_id, l_ws_row_type.worksheet_id),
   p_global_worksheet_flag       => 'N',
   p_global_worksheet_option     => l_ws_row_type.global_worksheet_option,
   p_local_copy_flag             => 'Y',
   p_copy_of_worksheet_id        => p_worksheet_id,
   p_freeze_flag                 => l_ws_row_type.freeze_flag,
   p_budget_by_position          => l_ws_row_type.budget_by_position,
   p_use_revised_element_rates   => l_ws_row_type.use_revised_element_rates,
   p_num_proposed_years          => l_ws_row_type.num_proposed_years,
   p_num_years_to_allocate       => l_ws_row_type.num_years_to_allocate,
   p_rounding_factor             => l_ws_row_type.rounding_factor,
   p_gl_cutoff_period            => l_ws_row_type.gl_cutoff_period,
   p_include_stat_balance        => l_ws_row_type.include_stat_balance,
   p_include_trans_balance       => l_ws_row_type.include_translated_balance,
   p_include_adj_period          => l_ws_row_type.include_adjustment_periods,
   p_data_extract_id             => l_ws_row_type.data_extract_id,
   p_parameter_set_id            => NULL,
   p_constraint_set_id           => NULL,
   p_allocrule_set_id            => NULL,
   p_date_submitted              => l_ws_row_type.date_submitted,
   p_submitted_by                => l_ws_row_type.submitted_by,
   p_attribute1                  => l_ws_row_type.attribute1,
   p_attribute2                  => l_ws_row_type.attribute2,
   p_attribute3                  => l_ws_row_type.attribute3,
   p_attribute4                  => l_ws_row_type.attribute4,
   p_attribute5                  => l_ws_row_type.attribute5,
   p_attribute6                  => l_ws_row_type.attribute6,
   p_attribute7                  => l_ws_row_type.attribute7,
   p_attribute8                  => l_ws_row_type.attribute8,
   p_attribute9                  => l_ws_row_type.attribute9,
   p_attribute10                 => l_ws_row_type.attribute10,
   p_context                     => l_ws_row_type.context,
   p_worksheet_id                => l_new_worksheet_id
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    CLOSE l_worksheets_csr ;
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    CLOSE l_worksheets_csr ;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Get account_line related info for the current worksheet to be copied in
  -- psb_ws_lines and psb_ws_account_lines table for the target worksheet.
  -- The positon related account lines will be updated by position phase.
  --
  FOR l_lines_accts_rec IN
  (
     SELECT accts.*
     FROM   psb_ws_lines          lines ,
	    psb_ws_account_lines  accts
     WHERE  lines.worksheet_id     = p_worksheet_id
     AND    lines.account_line_id  = accts.account_line_id
     AND    accts.position_line_id IS NULL
  )
  LOOP
    --
    -- Create records in psb_ws_lines and psb_ws_account_lines for the
    -- new worksheet.
    --
    PSB_WS_Ops_Pvt.Create_Local_Dist_Pvt
    (
       p_account_line_id        =>   l_lines_accts_rec.account_line_id  ,
       p_new_worksheet_id       =>   l_new_worksheet_id                 ,
       p_new_position_line_id   =>   NULL                               ,
       /*For Bug No : 2440100 Start*/
       p_return_status          =>   l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP;

  --
  -- Copy position related information.
  --
  IF l_budget_by_position = 'Y' THEN


    /*Bug:6367584:start*/
    --
    -- Copies the worksheet specific records in PSB_POSITION_PAY_DISTRIBUTIONS
    --

      Create_Local_Pay_Dist
      (
          p_worksheet_id             => p_worksheet_id,
          p_new_worksheet_id         => l_new_worksheet_id,
	  p_operation_type           => 'COPY',
          p_return_status            => l_return_status
      );

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
    /*Bug:6367584:end*/
    --
    -- We need to find all the position_line_id for the worksheet and each of
    -- the position_line_id needs to be copied in psb_ws_position_lines table.
    -- The related rows in psb_ws_fte_lines and psb_ws_element_lines will
    -- also be copied and assigned new position_line_id as created in the
    -- psb_ws_position_lines table.
    --

    FOR l_lines_pos_rec IN
    (
       SELECT positions.*
       FROM   psb_ws_lines_positions   lines ,
	      psb_ws_position_lines    positions
       WHERE  lines.worksheet_id     = p_worksheet_id
       AND    lines.position_line_id = positions.position_line_id
    )
    LOOP

      --
      -- API creates records in psb_ws_lines_positions and
      -- psb_ws_position_lines for the new worksheet.
      --
      PSB_WS_Pos_Pvt.Create_Position_Lines
      (
	 p_api_version               =>   1.0 ,
	 p_init_msg_list             =>   FND_API.G_FALSE ,
	 p_commit                    =>   FND_API.G_FALSE ,
	 p_validation_level          =>   FND_API.G_VALID_LEVEL_FULL ,
	 p_return_status             =>   l_return_status ,
	 p_msg_count                 =>   l_msg_count ,
	 p_msg_data                  =>   l_msg_data ,
	 --
	 p_position_line_id          =>   l_new_position_line_id ,
	 p_worksheet_id              =>   l_new_worksheet_id ,
	 p_position_id               =>   l_lines_pos_rec.position_id ,
	 p_budget_group_id           =>   l_lines_pos_rec.budget_group_id ,
	 p_copy_of_position_line_id  =>   l_lines_pos_rec.position_line_id
      );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --

      --
      -- Create new account distribution for the new position_line_id by
      -- using original position_line_id related information. Note in the
      -- account phase, we did not consider position related account lines.
      --
      FOR l_accts_rec IN
      (
	 SELECT account_line_id
	 FROM   psb_ws_account_lines
	 WHERE  position_line_id  = l_lines_pos_rec.position_line_id
      )
      LOOP
	--
	PSB_WS_Ops_Pvt.Create_Local_Dist_Pvt
	(
	   p_account_line_id        =>   l_accts_rec.account_line_id  ,
	   p_new_worksheet_id       =>   l_new_worksheet_id           ,
	   p_new_position_line_id   =>   l_new_position_line_id       ,
	   p_return_status          =>   l_return_status
	) ;

	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
      END LOOP;

/*
      --
      -- Update the old position_line_id with new position_line_id in
      -- psb_ws_account_lines table.
      --
      UPDATE psb_ws_account_lines
      SET    position_line_id = l_new_position_line_id
      WHERE  position_line_id = l_lines_pos_rec.position_line_id
      AND    account_line_id IN
	     (
	       SELECT account_line_id
	       FROM   psb_ws_lines
	       WHERE  worksheet_id = l_new_worksheet_id
	     ) ;
*/

      --
      -- Copy each record in psb_ws_fte_lines table for the current
      -- l_lines_pos_rec.position_line_id. The new l_new_position_line_id
      -- will replace the position_line_id column in new created records.
      --
      FOR l_fte_rec IN
      (
	 SELECT *
	 FROM   psb_ws_fte_lines
	 WHERE  position_line_id = l_lines_pos_rec.position_line_id
      )
      LOOP

	--
	-- Populate the l_period_fte_tbl ( used by PSB_WS_Acct1 API )
	--
	l_period_fte_tbl(1)  := l_fte_rec.period1_fte ;
	l_period_fte_tbl(2)  := l_fte_rec.period2_fte ;
	l_period_fte_tbl(3)  := l_fte_rec.period3_fte ;
	l_period_fte_tbl(4)  := l_fte_rec.period4_fte ;
	l_period_fte_tbl(5)  := l_fte_rec.period5_fte ;
	l_period_fte_tbl(6)  := l_fte_rec.period6_fte ;
	l_period_fte_tbl(7)  := l_fte_rec.period7_fte ;
	l_period_fte_tbl(8)  := l_fte_rec.period8_fte ;
	l_period_fte_tbl(9)  := l_fte_rec.period9_fte ;
	l_period_fte_tbl(10) := l_fte_rec.period10_fte ;
	l_period_fte_tbl(11) := l_fte_rec.period11_fte ;
	l_period_fte_tbl(12) := l_fte_rec.period12_fte ;
	l_period_fte_tbl(13) := l_fte_rec.period13_fte ;
	l_period_fte_tbl(14) := l_fte_rec.period14_fte ;
	l_period_fte_tbl(15) := l_fte_rec.period15_fte ;
	l_period_fte_tbl(16) := l_fte_rec.period16_fte ;
	l_period_fte_tbl(17) := l_fte_rec.period17_fte ;
	l_period_fte_tbl(18) := l_fte_rec.period18_fte ;
	l_period_fte_tbl(19) := l_fte_rec.period19_fte ;
	l_period_fte_tbl(20) := l_fte_rec.period20_fte ;
	l_period_fte_tbl(21) := l_fte_rec.period21_fte ;
	l_period_fte_tbl(22) := l_fte_rec.period22_fte ;
	l_period_fte_tbl(23) := l_fte_rec.period23_fte ;
	l_period_fte_tbl(24) := l_fte_rec.period24_fte ;
	l_period_fte_tbl(25) := l_fte_rec.period25_fte ;
	l_period_fte_tbl(26) := l_fte_rec.period26_fte ;
	l_period_fte_tbl(27) := l_fte_rec.period27_fte ;
	l_period_fte_tbl(28) := l_fte_rec.period28_fte ;
	l_period_fte_tbl(29) := l_fte_rec.period29_fte ;
	l_period_fte_tbl(30) := l_fte_rec.period30_fte ;
	l_period_fte_tbl(31) := l_fte_rec.period31_fte ;
	l_period_fte_tbl(32) := l_fte_rec.period32_fte ;
	l_period_fte_tbl(33) := l_fte_rec.period33_fte ;
	l_period_fte_tbl(34) := l_fte_rec.period34_fte ;
	l_period_fte_tbl(35) := l_fte_rec.period35_fte ;
	l_period_fte_tbl(36) := l_fte_rec.period36_fte ;
	l_period_fte_tbl(37) := l_fte_rec.period37_fte ;
	l_period_fte_tbl(38) := l_fte_rec.period38_fte ;
	l_period_fte_tbl(39) := l_fte_rec.period39_fte ;
	l_period_fte_tbl(40) := l_fte_rec.period40_fte ;
	l_period_fte_tbl(41) := l_fte_rec.period41_fte ;
	l_period_fte_tbl(42) := l_fte_rec.period42_fte ;
	l_period_fte_tbl(43) := l_fte_rec.period43_fte ;
	l_period_fte_tbl(44) := l_fte_rec.period44_fte ;
	l_period_fte_tbl(45) := l_fte_rec.period45_fte ;
	l_period_fte_tbl(46) := l_fte_rec.period46_fte ;
	l_period_fte_tbl(47) := l_fte_rec.period47_fte ;
	l_period_fte_tbl(48) := l_fte_rec.period48_fte ;
	l_period_fte_tbl(49) := l_fte_rec.period49_fte ;
	l_period_fte_tbl(50) := l_fte_rec.period50_fte ;
	l_period_fte_tbl(51) := l_fte_rec.period51_fte ;
	l_period_fte_tbl(52) := l_fte_rec.period52_fte ;
	l_period_fte_tbl(53) := l_fte_rec.period53_fte ;
	l_period_fte_tbl(54) := l_fte_rec.period54_fte ;
	l_period_fte_tbl(55) := l_fte_rec.period55_fte ;
	l_period_fte_tbl(56) := l_fte_rec.period56_fte ;
	l_period_fte_tbl(57) := l_fte_rec.period57_fte ;
	l_period_fte_tbl(58) := l_fte_rec.period58_fte ;
	l_period_fte_tbl(59) := l_fte_rec.period59_fte ;
	l_period_fte_tbl(60) := l_fte_rec.period60_fte ;

	-- API to create new fte lines in psb_ws_fte_lines.
	PSB_WS_Pos_Pvt.Create_FTE_Lines
	(
	   p_api_version              =>   1.0 ,
	   p_init_msg_list            =>   FND_API.G_FALSE ,
	   p_commit                   =>   FND_API.G_FALSE ,
	   p_validation_level         =>   FND_API.G_VALID_LEVEL_FULL ,
	   p_return_status            =>   l_return_status ,
	   p_msg_count                =>   l_msg_count ,
	   p_msg_data                 =>   l_msg_data ,
	   --
	   p_fte_line_id              =>   l_new_fte_line_id ,
	   p_check_spfl_exists        =>   FND_API.G_FALSE,
	   p_worksheet_id             =>   l_new_worksheet_id ,
	   p_position_line_id         =>   l_new_position_line_id ,
	   p_budget_year_id           =>   l_fte_rec.budget_year_id ,
	   p_annual_fte               =>   l_fte_rec.annual_fte ,
	   p_service_package_id       =>   l_fte_rec.service_package_id ,
	   p_stage_set_id             =>   l_fte_rec.stage_set_id ,
	   p_start_stage_seq          =>   l_fte_rec.start_stage_seq ,
	   p_current_stage_seq        =>   l_fte_rec.current_stage_seq ,
	   p_end_stage_seq            =>   nvl(l_fte_rec.end_stage_seq, FND_API.G_MISS_NUM),
	   p_period_fte               =>   l_period_fte_tbl
	);
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
      END LOOP;   -- To process fte_lines in psb_ws_element_lines.

      --
      -- Copy each record in psb_ws_element_lines table for the current
      -- l_lines_pos_rec.position_line_id. The new l_new_position_line_id
      -- will replace the position_line_id column in new created records.
      --
      FOR l_element_rec IN
      (
	 SELECT *
	 FROM   psb_ws_element_lines
	 WHERE  position_line_id = l_lines_pos_rec.position_line_id
      )
      LOOP

	-- API to create new element lines in psb_ws_element_lines.
	PSB_WS_Pos_Pvt.Create_Element_Lines
	(
	   p_api_version              =>   1.0 ,
	   p_init_msg_list            =>   FND_API.G_FALSE ,
	   p_commit                   =>   FND_API.G_FALSE ,
	   p_validation_level         =>   FND_API.G_VALID_LEVEL_FULL ,
	   p_return_status            =>   l_return_status ,
	   p_msg_count                =>   l_msg_count ,
	   p_msg_data                 =>   l_msg_data ,
	   --
	   p_element_line_id          =>   l_new_element_line_id ,
	   p_position_line_id         =>   l_new_position_line_id ,
	   p_budget_year_id           =>   l_element_rec.budget_year_id ,
	   p_pay_element_id           =>   l_element_rec.pay_element_id ,
	   p_currency_code            =>   l_element_rec.currency_code ,
	   p_element_cost             =>   l_element_rec.element_cost ,
	   p_element_set_id           =>   l_element_rec.element_set_id ,
	   p_service_package_id       =>   l_element_rec.service_package_id ,
	   p_stage_set_id             =>   l_element_rec.stage_set_id ,
	   p_start_stage_seq          =>   l_element_rec.start_stage_seq ,
	   p_current_stage_seq        =>   l_element_rec.current_stage_seq,
	   p_end_stage_seq            =>   nvl(l_element_rec.end_stage_seq, FND_API.G_MISS_NUM)
	);
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
      END LOOP;   -- To process element_lines in psb_ws_element_lines.

      --
      -- Copy position assignment information related to the worksheet.
      -- ( Note that psb_position_assignments will have values specific to
      --   the global worksheet for the official ones.)
      --
      FOR l_asgn_rec IN
      (
	 SELECT asgn.*
	 FROM   psb_ws_position_lines    pos  ,
		psb_position_assignments asgn
	 WHERE  pos.position_line_id = l_lines_pos_rec.position_line_id
	 /*Bug:6367584:applied nvl to use l_ws_row_type.worksheet_id if global_worksheet_id is null*/
	 AND    asgn.worksheet_id    = nvl(l_ws_row_type.global_worksheet_id,l_ws_row_type.worksheet_id)
	 /*Bug:6367584:end*/
	 AND    asgn.position_id     = pos.position_id
      )
      LOOP

	--
	-- API will create new position assignments.
	--
	PSB_Positions_Pvt.Modify_Assignment
	(
	   p_api_version                 => 1.0 ,
	   p_init_msg_list               => FND_API.G_FALSE ,
	   p_commit                      => FND_API.G_FALSE ,
	   p_validation_level            => FND_API.G_VALID_LEVEL_NONE ,
	   p_return_status               => l_return_status ,
	   p_msg_count                   => l_msg_count ,
	   p_msg_data                    => l_msg_data ,
	   --
	   p_position_assignment_id      => l_new_position_assignment_id ,
	   p_element_value_type          => l_asgn_rec.element_value_type ,
	   p_data_extract_id             => l_asgn_rec.data_extract_id ,
	   p_worksheet_id                => l_new_worksheet_id ,
	   p_position_id                 => l_asgn_rec.position_id ,
	   p_assignment_type             => l_asgn_rec.assignment_type ,
	   p_attribute_id                => l_asgn_rec.attribute_id ,
	   p_attribute_value_id          => l_asgn_rec.attribute_value_id ,
	   p_attribute_value             => l_asgn_rec.attribute_value ,
	   p_pay_element_id              => l_asgn_rec.pay_element_id ,
	   p_pay_element_option_id       => l_asgn_rec.pay_element_option_id ,
	   p_effective_start_date        => l_asgn_rec.effective_start_date ,
	   p_effective_end_date          => l_asgn_rec.effective_end_date ,
	   p_element_value               => l_asgn_rec.element_value ,
	   p_global_default_flag         => l_asgn_rec.global_default_flag ,
	   p_assignment_default_rule_id  =>
				      l_asgn_rec.assignment_default_rule_id ,
	   p_modify_flag                 => l_asgn_rec.modify_flag ,
	   p_rowid                       => l_rowid ,
	   p_currency_code               => l_asgn_rec.currency_code ,
	   p_pay_basis                   => l_asgn_rec.pay_basis ,
	   p_employee_id                 => l_asgn_rec.employee_id ,
	   p_primary_employee_flag       => l_asgn_rec.primary_employee_flag ,
	   p_mode                        => 'R'
	) ;
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
      END LOOP; -- To process assignments in psb_position_assignments for
		-- current position line l_lines_pos_rec.position_line_id.

    END LOOP;   -- To process position_lines in psb_ws_position_lines.


  END IF;

  CLOSE l_worksheets_csr ;
  --
  p_worksheet_id_OUT := l_new_worksheet_id;
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
    ROLLBACK TO Copy_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Copy_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_worksheets_csr%ISOPEN ) THEN
      CLOSE l_worksheets_csr ;
    END IF ;
    --
    ROLLBACK TO Copy_Worksheet_Pvt ;
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
END Copy_Worksheet;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Merge_Worksheets                            |
 +===========================================================================*/
--
-- The API merges a local copy onto an official worksheet. The source worksheet
-- is merged onto the target worksheet.
--
PROCEDURE Merge_Worksheets
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_source_worksheet_id       IN       psb_worksheets.worksheet_id%TYPE ,
  p_target_worksheet_id       IN       psb_worksheets.worksheet_id%TYPE
)
IS
  --
  l_api_name                       CONSTANT VARCHAR2(30) := 'Merge_Worksheets';
  l_api_version                    CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status                  VARCHAR2(1) ;
  l_msg_count                      NUMBER ;
  l_msg_data                       VARCHAR2(2000) ;
  --
  l_source_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_source_copy_of_worksheet_id    psb_worksheets.budget_group_id%TYPE ;
  l_source_local_copy_flag         psb_worksheets.local_copy_flag%TYPE ;
  l_source_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_source_current_stage_seq       psb_worksheets.current_stage_seq%TYPE ;
  --
  l_target_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_target_freeze_flag             psb_worksheets.freeze_flag%TYPE ;
  l_target_local_copy_flag         psb_worksheets.local_copy_flag%TYPE ;
  l_target_current_stage_seq       psb_worksheets.current_stage_seq%TYPE ;
  l_target_account_line_id         psb_ws_account_lines.account_line_id%TYPE ;
  l_target_position_line_id        psb_ws_lines_positions.position_line_id%TYPE;
  l_target_position_id             psb_ws_position_lines.position_id%TYPE;
  --
  l_new_position_line_id           psb_ws_lines_positions.position_line_id%TYPE;
  l_new_fte_line_id                psb_ws_fte_lines.fte_line_id%TYPE ;
  l_new_element_line_id            psb_ws_element_lines.element_line_id%TYPE ;
  l_new_position_assignment_id
			psb_position_assignments.position_assignment_id%TYPE ;
  l_rowid                         VARCHAR2(2000);
  --
  l_parent_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_global_worksheet_id            psb_worksheets.worksheet_id%TYPE ;
  l_global_worksheet_flag          psb_worksheets.global_worksheet_flag%TYPE ;
  l_period_amount_tbl              PSB_WS_Acct1.g_prdamt_tbl_type ;
  l_period_fte_tbl                 PSB_WS_Acct1.g_prdamt_tbl_type ;
  l_segment_values_tbl             FND_FLEX_EXT.SegmentArray ;
  --
  CURSOR l_ws_account_lines_csr
	 (
	   c_copy_of_account_line_id
			psb_ws_account_lines.copy_of_account_line_id%TYPE
	 )
	 IS
	 SELECT account_line_id
	 FROM   psb_ws_account_lines
	 WHERE  account_line_id  = NVL( c_copy_of_account_line_id , -99)
	 AND    ROWNUM                < 2 ;
  --
  l_new_account_line_id           psb_ws_account_lines.account_line_id%TYPE ;
  --
  CURSOR l_ws_position_lines_csr
	 (
	   c_copy_of_position_line_id
			psb_ws_position_lines.copy_of_position_line_id%TYPE
	 )
	 IS
	 SELECT position_line_id, position_id
	 FROM   psb_ws_position_lines
	 WHERE  position_line_id  = NVL( c_copy_of_position_line_id , -99)
	 AND    ROWNUM                < 2 ;
  --
BEGIN
  --
  SAVEPOINT Merge_Worksheets_Pvt ;
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

  --
  -- Find information about worksheets.
  --

  SELECT budget_group_id                  ,
	 NVL( budget_by_position, 'N' )   ,
	 NVL( copy_of_worksheet_id, -99 ) ,
	 current_stage_seq
       INTO
	 l_source_budget_group_id    ,
	 l_source_budget_by_position ,
	 l_source_copy_of_worksheet_id    ,
	 l_source_current_stage_seq
  FROM   psb_worksheets
  WHERE  worksheet_id = p_source_worksheet_id ;


  SELECT budget_group_id                  ,
	 current_stage_seq                ,
	 NVL( freeze_flag , 'N' )         ,
	 global_worksheet_id              ,
	 global_worksheet_flag
       INTO
	 l_target_budget_group_id         ,
	 l_target_current_stage_seq       ,
	 l_target_freeze_flag             ,
	 l_global_worksheet_id            ,
	 l_global_worksheet_flag
  FROM   psb_worksheets
  WHERE  worksheet_id = p_target_worksheet_id ;

  --
  -- Find global worksheet information for the target worksheet, used
  -- for position budgeting.
  --
  IF NVL(l_global_worksheet_flag, 'N') = 'Y' THEN
    l_global_worksheet_id := p_target_worksheet_id ;
  ELSE
    l_global_worksheet_id := l_global_worksheet_id ;
  END IF ;

  --
  -- Check whether the p_target_worksheet_id has been frozen.
  --
  IF l_target_freeze_flag = 'Y'  THEN
    Fnd_Message.Set_Name('PSB', 'PSB_TARGET_WORKSHEET_IS_FROZEN') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  --
  -- Validating that p_source_worksheet_id is a copy of p_target_worksheet_id
  -- as merge can only be performed from a copied worksheet to the original one.
  -- Also the p_source_worksheet_id and p_target_worksheet_id worksheets must
  -- be on the same stage.
  --
  IF NOT (
	   ( l_source_copy_of_worksheet_id = p_target_worksheet_id )
	   AND (l_source_current_stage_seq = l_target_current_stage_seq )
	  )
  THEN
    Fnd_Message.Set_Name ('PSB', 'PSB_INCOMPATIBLE_WORKSHEETS') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  --
  -- Merging those account lines which are not related to positions.
  -- The positon related account lines will be updated by position phase.
  --
  /*For Bug No : 2440100 Start*/
  --added the last three filters
  FOR l_lines_accts_rec IN
  (
     SELECT accts.*
     FROM   psb_ws_lines          lines ,
	    psb_ws_account_lines  accts
     WHERE  lines.worksheet_id    = p_source_worksheet_id
     AND    lines.account_line_id = accts.account_line_id
     AND    accts.position_line_id IS NULL
     AND    accts.end_stage_seq IS NULL
     AND    accts.template_id IS NULL
     AND    accts.balance_type = 'E'
  )
  LOOP
    --
    -- Finding p_target_worksheet_id in psb_ws_account_lines.
    --
    OPEN l_ws_account_lines_csr ( l_lines_accts_rec.copy_of_account_line_id ) ;

    FETCH l_ws_account_lines_csr INTO l_target_account_line_id;

    --
    -- Populate the l_period_amount_tbl ( used by PSB_WS_Acct1 API )
    --
    l_period_amount_tbl(1)  := l_lines_accts_rec.period1_amount ;
    l_period_amount_tbl(2)  := l_lines_accts_rec.period2_amount ;
    l_period_amount_tbl(3)  := l_lines_accts_rec.period3_amount ;
    l_period_amount_tbl(4)  := l_lines_accts_rec.period4_amount ;
    l_period_amount_tbl(5)  := l_lines_accts_rec.period5_amount ;
    l_period_amount_tbl(6)  := l_lines_accts_rec.period6_amount ;
    l_period_amount_tbl(7)  := l_lines_accts_rec.period7_amount ;
    l_period_amount_tbl(8)  := l_lines_accts_rec.period8_amount ;
    l_period_amount_tbl(9)  := l_lines_accts_rec.period9_amount ;
    l_period_amount_tbl(10) := l_lines_accts_rec.period10_amount ;
    l_period_amount_tbl(11) := l_lines_accts_rec.period11_amount ;
    l_period_amount_tbl(12) := l_lines_accts_rec.period12_amount ;
    l_period_amount_tbl(13) := l_lines_accts_rec.period13_amount ;
    l_period_amount_tbl(14) := l_lines_accts_rec.period14_amount ;
    l_period_amount_tbl(15) := l_lines_accts_rec.period15_amount ;
    l_period_amount_tbl(16) := l_lines_accts_rec.period16_amount ;
    l_period_amount_tbl(17) := l_lines_accts_rec.period17_amount ;
    l_period_amount_tbl(18) := l_lines_accts_rec.period18_amount ;
    l_period_amount_tbl(19) := l_lines_accts_rec.period19_amount ;
    l_period_amount_tbl(20) := l_lines_accts_rec.period20_amount ;
    l_period_amount_tbl(21) := l_lines_accts_rec.period21_amount ;
    l_period_amount_tbl(22) := l_lines_accts_rec.period22_amount ;
    l_period_amount_tbl(23) := l_lines_accts_rec.period23_amount ;
    l_period_amount_tbl(24) := l_lines_accts_rec.period24_amount ;
    l_period_amount_tbl(25) := l_lines_accts_rec.period25_amount ;
    l_period_amount_tbl(26) := l_lines_accts_rec.period26_amount ;
    l_period_amount_tbl(27) := l_lines_accts_rec.period27_amount ;
    l_period_amount_tbl(28) := l_lines_accts_rec.period28_amount ;
    l_period_amount_tbl(29) := l_lines_accts_rec.period29_amount ;
    l_period_amount_tbl(30) := l_lines_accts_rec.period30_amount ;
    l_period_amount_tbl(31) := l_lines_accts_rec.period31_amount ;
    l_period_amount_tbl(32) := l_lines_accts_rec.period32_amount ;
    l_period_amount_tbl(33) := l_lines_accts_rec.period33_amount ;
    l_period_amount_tbl(34) := l_lines_accts_rec.period34_amount ;
    l_period_amount_tbl(35) := l_lines_accts_rec.period35_amount ;
    l_period_amount_tbl(36) := l_lines_accts_rec.period36_amount ;
    l_period_amount_tbl(37) := l_lines_accts_rec.period37_amount ;
    l_period_amount_tbl(38) := l_lines_accts_rec.period38_amount ;
    l_period_amount_tbl(39) := l_lines_accts_rec.period39_amount ;
    l_period_amount_tbl(40) := l_lines_accts_rec.period40_amount ;
    l_period_amount_tbl(41) := l_lines_accts_rec.period41_amount ;
    l_period_amount_tbl(42) := l_lines_accts_rec.period42_amount ;
    l_period_amount_tbl(43) := l_lines_accts_rec.period43_amount ;
    l_period_amount_tbl(44) := l_lines_accts_rec.period44_amount ;
    l_period_amount_tbl(45) := l_lines_accts_rec.period45_amount ;
    l_period_amount_tbl(46) := l_lines_accts_rec.period46_amount ;
    l_period_amount_tbl(47) := l_lines_accts_rec.period47_amount ;
    l_period_amount_tbl(48) := l_lines_accts_rec.period48_amount ;
    l_period_amount_tbl(49) := l_lines_accts_rec.period49_amount ;
    l_period_amount_tbl(50) := l_lines_accts_rec.period50_amount ;
    l_period_amount_tbl(51) := l_lines_accts_rec.period51_amount ;
    l_period_amount_tbl(52) := l_lines_accts_rec.period52_amount ;
    l_period_amount_tbl(53) := l_lines_accts_rec.period53_amount ;
    l_period_amount_tbl(54) := l_lines_accts_rec.period54_amount ;
    l_period_amount_tbl(55) := l_lines_accts_rec.period55_amount ;
    l_period_amount_tbl(56) := l_lines_accts_rec.period56_amount ;
    l_period_amount_tbl(57) := l_lines_accts_rec.period57_amount ;
    l_period_amount_tbl(58) := l_lines_accts_rec.period58_amount ;
    l_period_amount_tbl(59) := l_lines_accts_rec.period59_amount ;
    l_period_amount_tbl(60) := l_lines_accts_rec.period60_amount ;

    IF ( l_ws_account_lines_csr%NOTFOUND ) THEN
      --
      -- It means a new line was created in the p_source_worksheet_id.
      -- Putting this line in the p_target_worksheet_id. The PSB_WS_Acct_Pvt
      -- API will also maintain psb_ws_lines.
      --
      PSB_WS_Acct_Pvt.Create_Account_Dist
      (
	p_api_version             =>   1.0 ,
	p_init_msg_list           =>   FND_API.G_FALSE,
	p_commit                  =>   FND_API.G_FALSE,
	p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
	p_return_status           =>   l_return_status,
	p_account_line_id         =>   l_new_account_line_id,
	p_check_spal_exists        =>   FND_API.G_FALSE,
	p_msg_count               =>   l_msg_count,
	p_msg_data                =>   l_msg_data,
	--
	p_worksheet_id            =>   p_target_worksheet_id,
	p_budget_year_id          =>   l_lines_accts_rec.budget_year_id,
	p_budget_group_id         =>   l_lines_accts_rec.budget_group_id,
	p_ccid                    =>   l_lines_accts_rec.code_combination_id,
	p_template_id             =>   NVL(l_lines_accts_rec.template_id ,
					    FND_API.G_MISS_NUM ) ,
	p_currency_code           =>   l_lines_accts_rec.currency_code ,
	p_balance_type            =>   l_lines_accts_rec.balance_type ,
	p_ytd_amount              =>   l_lines_accts_rec.ytd_amount  ,
	p_distribute_flag         =>   FND_API.G_FALSE ,
	p_annual_fte              =>   NVL ( l_lines_accts_rec.annual_fte,
					     FND_API.G_MISS_NUM ) ,
	p_period_amount           =>   l_period_amount_tbl ,
	p_position_line_id        =>   NVL( l_lines_accts_rec.position_line_id,
					    FND_API.G_MISS_NUM ) ,
	p_element_set_id          =>   NVL( l_lines_accts_rec.element_set_id,
					    FND_API.G_MISS_NUM ) ,
	p_salary_account_line     =>  NVL(l_lines_accts_rec.salary_account_line,
					  FND_API.G_FALSE ) ,
	p_service_package_id      =>   l_lines_accts_rec.service_package_id ,
	p_start_stage_seq         =>   l_lines_accts_rec.start_stage_seq ,
	p_current_stage_seq       =>   l_lines_accts_rec.current_stage_seq ,
	p_end_stage_seq           =>   NVL( l_lines_accts_rec.end_stage_seq,
					    FND_API.G_MISS_NUM )
      );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      --
      -- The new_account_line_id will be null if the desired account lines are
      -- already there in the target worksheet. If not null, add the new
      -- account_line_id to all the worksheet up in the hierarchy.
      --
      IF l_new_account_line_id IS NOT NULL THEN

	--
	-- Add the account_line to all the worksheets up in the hierarchy.
	-- ( The line has already been added in the target worksheet.)
	--
	PSB_WS_Ops_Pvt.Add_Worksheet_Line
	(
	   p_api_version               => 1.0 ,
	   p_init_msg_list             => FND_API.G_FALSE,
	   p_commit                    => FND_API.G_FALSE,
	   p_validation_level          => FND_API.G_VALID_LEVEL_NONE,
	   p_return_status             => l_return_status,
	   p_msg_count                 => l_msg_count,
	   p_msg_data                  => l_msg_data ,
	   --
	   p_worksheet_id              => p_target_worksheet_id ,
	   p_account_line_id           => l_new_account_line_id ,
	   p_add_in_current_worksheet  => FND_API.G_FALSE
	) ;
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
      END IF;
      --
    ELSIF ( l_ws_account_lines_csr%FOUND ) THEN
      --
      -- It means it is not a new line, but the amount information may be
      -- different in the p_source_worksheet_id.
      --

      --
      -- Updating ytd_amount in the p_target_worksheet_id.
      --

      PSB_WS_Acct_Pvt.Create_Account_Dist
      (
	p_api_version             =>   1.0 ,
	p_init_msg_list           =>   FND_API.G_FALSE,
	p_commit                  =>   FND_API.G_FALSE,
	p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
	p_return_status           =>   l_return_status,
	p_msg_count               =>   l_msg_count,
	p_msg_data                =>   l_msg_data,
        -- comment out the following line for bug 3419241
        -- p_check_stages must be set to FND_API.G_TRUE to automatically
        -- create new Stage for the Account Line. p_check_stages is
        -- FND_API.G_TRUE by default.
	--p_check_stages            =>   FND_API.G_FALSE,
	p_worksheet_id            =>   p_target_worksheet_id,
	p_account_line_id         =>   l_target_account_line_id,
	p_ytd_amount              =>   l_lines_accts_rec.ytd_amount,
	p_period_amount           =>   l_period_amount_tbl,
	p_service_package_id      =>   l_lines_accts_rec.service_package_id,
	p_current_stage_seq       =>   l_lines_accts_rec.current_stage_seq,
	p_annual_fte              =>   l_lines_accts_rec.annual_fte
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END IF ;  -- For l_ws_account_lines_csr%NOTFOUND.
    --
    CLOSE l_ws_account_lines_csr ;
    --
  END LOOP ;


  --
  -- Merging position related information.
  --
  IF l_source_budget_by_position = 'Y' THEN

    /*Bug:6367584:start*/
    --
    -- Copies the worksheet specific records in PSB_POSITION_PAY_DISTRIBUTIONS
    --

      Create_Local_Pay_Dist
      (
          p_worksheet_id             => p_source_worksheet_id,
          p_new_worksheet_id         => p_target_worksheet_id,
	  p_operation_type           => 'MERGE',
          p_return_status            => l_return_status
      );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR ;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF;
	--
    /*Bug:6367584:end*/

    FOR l_lines_pos_rec IN
    (
       SELECT positions.*
       FROM   psb_ws_lines_positions   lines ,
	      psb_ws_position_lines    positions
       WHERE  lines.worksheet_id     = p_source_worksheet_id
       AND    lines.position_line_id = positions.position_line_id

    )
    LOOP

      --
      -- Finding p_target_worksheet_id in psb_ws_position_lines.
      --
      OPEN l_ws_position_lines_csr( l_lines_pos_rec.copy_of_position_line_id );

      FETCH l_ws_position_lines_csr INTO l_target_position_line_id ,
					 l_target_position_id ;

      IF ( l_ws_position_lines_csr%NOTFOUND ) THEN
	--
	-- It means a new line was created in the p_source_worksheet_id.
	-- Putting this line in the p_target_worksheet_id. The API will
	-- also maintain psb_ws_lines_positions.
	--
	PSB_WS_Pos_Pvt.Create_Position_Lines
	(
	   p_api_version               =>   1.0 ,
	   p_init_msg_list             =>   FND_API.G_FALSE ,
	   p_commit                    =>   FND_API.G_FALSE ,
	   p_validation_level          =>   FND_API.G_VALID_LEVEL_FULL ,
	   p_return_status             =>   l_return_status ,
	   p_msg_count                 =>   l_msg_count ,
	   p_msg_data                  =>   l_msg_data ,
	   --
	   p_position_line_id          =>   l_new_position_line_id ,
	   p_worksheet_id              =>   p_target_worksheet_id ,
	   p_position_id               =>   l_lines_pos_rec.position_id ,
	   p_budget_group_id           =>   l_lines_pos_rec.budget_group_id ,
	   p_copy_of_position_line_id  =>   NULL
	);
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;

	--
	-- Create new account distribution for the new position_line_id by
	-- using original position_line_id related information. Note in the
	-- account phase, we did not consider position related account lines.
	--
	FOR l_accts_rec IN
	(
	   SELECT account_line_id
	   FROM   psb_ws_account_lines
	   WHERE  position_line_id  = l_lines_pos_rec.position_line_id
	)
	LOOP
	  --
	  PSB_WS_Ops_Pvt.Create_Local_Dist_Pvt
	  (
	     p_account_line_id      =>   l_accts_rec.account_line_id  ,
	     p_new_worksheet_id     =>   p_target_worksheet_id        ,
	     p_new_position_line_id =>   l_new_position_line_id       ,
	     p_return_status        =>   l_return_status
	  ) ;
	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --
	END LOOP;

/*
	--
	-- Update the old position_line_id with new position_line_id in
	-- psb_ws_account_lines table.
	--
	UPDATE psb_ws_account_lines
	SET    position_line_id = l_new_position_line_id
	WHERE  position_line_id = l_lines_pos_rec.position_line_id
	AND    account_line_id IN
	       (
		 SELECT account_line_id
		 FROM   psb_ws_lines
		 WHERE  worksheet_id = p_target_worksheet_id
	       ) ;
*/

	--
	-- Add the new position line to all the worksheets up in the hierarchy.
	-- ( The line has already been added in the target worksheet.)
	--
	PSB_WS_Ops_Pvt.Add_Worksheet_Position_Line
	(
	  p_api_version               => 1.0 ,
	  p_init_msg_list             => FND_API.G_FALSE ,
	  p_commit                    => FND_API.G_FALSE ,
	  p_validation_level          => FND_API.G_VALID_LEVEL_NONE ,
	  p_return_status             => l_return_status ,
	  p_msg_count                 => l_msg_count ,
	  p_msg_data                  => l_msg_data ,
	  --
	  p_worksheet_id              => p_target_worksheet_id  ,
	  p_position_line_id          => l_new_position_line_id ,
	  p_add_in_current_worksheet  => FND_API.G_FALSE
	) ;
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;


	--
	-- Create new records in psb_ws_fte_lines table for each occurance of
	-- l_lines_pos_rec.position_line_id. The new l_new_position_line_id
	-- will replace the position_line_id column in new created records.
	--
	FOR l_fte_rec IN
	(
	   SELECT *
	   FROM   psb_ws_fte_lines
	   WHERE  position_line_id = l_lines_pos_rec.position_line_id
	)
	LOOP

	  --
	  -- Populate the l_period_amount_tbl ( used by PSB_WS_Acct1 API )
	  --
	  l_period_fte_tbl(1)  := l_fte_rec.period1_fte ;
	  l_period_fte_tbl(2)  := l_fte_rec.period2_fte ;
	  l_period_fte_tbl(3)  := l_fte_rec.period3_fte ;
	  l_period_fte_tbl(4)  := l_fte_rec.period4_fte ;
	  l_period_fte_tbl(5)  := l_fte_rec.period5_fte ;
	  l_period_fte_tbl(6)  := l_fte_rec.period6_fte ;
	  l_period_fte_tbl(7)  := l_fte_rec.period7_fte ;
	  l_period_fte_tbl(8)  := l_fte_rec.period8_fte ;
	  l_period_fte_tbl(9)  := l_fte_rec.period9_fte ;
	  l_period_fte_tbl(10) := l_fte_rec.period10_fte ;
	  l_period_fte_tbl(11) := l_fte_rec.period11_fte ;
	  l_period_fte_tbl(12) := l_fte_rec.period12_fte ;
	  l_period_fte_tbl(13) := l_fte_rec.period13_fte ;
	  l_period_fte_tbl(14) := l_fte_rec.period14_fte ;
	  l_period_fte_tbl(15) := l_fte_rec.period15_fte ;
	  l_period_fte_tbl(16) := l_fte_rec.period16_fte ;
	  l_period_fte_tbl(17) := l_fte_rec.period17_fte ;
	  l_period_fte_tbl(18) := l_fte_rec.period18_fte ;
	  l_period_fte_tbl(19) := l_fte_rec.period19_fte ;
	  l_period_fte_tbl(20) := l_fte_rec.period20_fte ;
	  l_period_fte_tbl(21) := l_fte_rec.period21_fte ;
	  l_period_fte_tbl(22) := l_fte_rec.period22_fte ;
	  l_period_fte_tbl(23) := l_fte_rec.period23_fte ;
	  l_period_fte_tbl(24) := l_fte_rec.period24_fte ;
	  l_period_fte_tbl(25) := l_fte_rec.period25_fte ;
	  l_period_fte_tbl(26) := l_fte_rec.period26_fte ;
	  l_period_fte_tbl(27) := l_fte_rec.period27_fte ;
	  l_period_fte_tbl(28) := l_fte_rec.period28_fte ;
	  l_period_fte_tbl(29) := l_fte_rec.period29_fte ;
	  l_period_fte_tbl(30) := l_fte_rec.period30_fte ;
	  l_period_fte_tbl(31) := l_fte_rec.period31_fte ;
	  l_period_fte_tbl(32) := l_fte_rec.period32_fte ;
	  l_period_fte_tbl(33) := l_fte_rec.period33_fte ;
	  l_period_fte_tbl(34) := l_fte_rec.period34_fte ;
	  l_period_fte_tbl(35) := l_fte_rec.period35_fte ;
	  l_period_fte_tbl(36) := l_fte_rec.period36_fte ;
	  l_period_fte_tbl(37) := l_fte_rec.period37_fte ;
	  l_period_fte_tbl(38) := l_fte_rec.period38_fte ;
	  l_period_fte_tbl(39) := l_fte_rec.period39_fte ;
	  l_period_fte_tbl(40) := l_fte_rec.period40_fte ;
	  l_period_fte_tbl(41) := l_fte_rec.period41_fte ;
	  l_period_fte_tbl(42) := l_fte_rec.period42_fte ;
	  l_period_fte_tbl(43) := l_fte_rec.period43_fte ;
	  l_period_fte_tbl(44) := l_fte_rec.period44_fte ;
	  l_period_fte_tbl(45) := l_fte_rec.period45_fte ;
	  l_period_fte_tbl(46) := l_fte_rec.period46_fte ;
	  l_period_fte_tbl(47) := l_fte_rec.period47_fte ;
	  l_period_fte_tbl(48) := l_fte_rec.period48_fte ;
	  l_period_fte_tbl(49) := l_fte_rec.period49_fte ;
	  l_period_fte_tbl(50) := l_fte_rec.period50_fte ;
	  l_period_fte_tbl(51) := l_fte_rec.period51_fte ;
	  l_period_fte_tbl(52) := l_fte_rec.period52_fte ;
	  l_period_fte_tbl(53) := l_fte_rec.period53_fte ;
	  l_period_fte_tbl(54) := l_fte_rec.period54_fte ;
	  l_period_fte_tbl(55) := l_fte_rec.period55_fte ;
	  l_period_fte_tbl(56) := l_fte_rec.period56_fte ;
	  l_period_fte_tbl(57) := l_fte_rec.period57_fte ;
	  l_period_fte_tbl(58) := l_fte_rec.period58_fte ;
	  l_period_fte_tbl(59) := l_fte_rec.period59_fte ;
	  l_period_fte_tbl(60) := l_fte_rec.period60_fte ;

	  -- API to create new fte lines in psb_ws_fte_lines.
	  PSB_WS_Pos_Pvt.Create_FTE_Lines
	  (
	     p_api_version              =>   1.0 ,
	     p_init_msg_list            =>   FND_API.G_FALSE ,
	     p_commit                   =>   FND_API.G_FALSE ,
	     p_validation_level         =>   FND_API.G_VALID_LEVEL_FULL ,
	     p_return_status            =>   l_return_status ,
	     p_msg_count                =>   l_msg_count ,
	     p_msg_data                 =>   l_msg_data ,
	     --
	     p_fte_line_id              =>   l_new_fte_line_id ,
	     p_check_spfl_exists        =>   FND_API.G_FALSE,
	     p_worksheet_id             =>   p_target_worksheet_id ,
	     p_position_line_id         =>   l_new_position_line_id ,
	     p_budget_year_id           =>   l_fte_rec.budget_year_id ,
	     p_annual_fte               =>   l_fte_rec.annual_fte ,
	     p_service_package_id       =>   l_fte_rec.service_package_id ,
	     p_stage_set_id             =>   l_fte_rec.stage_set_id ,
	     p_start_stage_seq          =>   l_fte_rec.start_stage_seq ,
	     p_current_stage_seq        =>   l_fte_rec.current_stage_seq ,
	     p_end_stage_seq            =>   NVL( l_fte_rec.end_stage_seq ,
						  FND_API.G_MISS_NUM),
	     p_period_fte               =>   l_period_fte_tbl
	  );
	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --
	END LOOP;   -- To process fte_lines in psb_ws_element_lines


	--
	-- Create new records in psb_ws_element_lines table for each occurance
	-- of l_lines_pos_rec.position_line_id. The new l_new_position_line_id
	-- will replace the position_line_id column in new created records.
	--
	FOR l_element_rec IN
	(
	   SELECT *
	   FROM   psb_ws_element_lines
	   WHERE  position_line_id = l_lines_pos_rec.position_line_id
	)
	LOOP

	  -- API to create new element lines in psb_ws_element_lines.
	  PSB_WS_Pos_Pvt.Create_Element_Lines
	  (
	     p_api_version              =>   1.0 ,
	     p_init_msg_list            =>   FND_API.G_FALSE ,
	     p_commit                   =>   FND_API.G_FALSE ,
	     p_validation_level         =>   FND_API.G_VALID_LEVEL_FULL ,
	     p_return_status            =>   l_return_status ,
	     p_msg_count                =>   l_msg_count ,
	     p_msg_data                 =>   l_msg_data ,
	     --
	     p_element_line_id          =>   l_new_element_line_id ,
	     p_position_line_id         =>   l_new_position_line_id ,
	     p_budget_year_id           =>   l_element_rec.budget_year_id ,
	     p_pay_element_id           =>   l_element_rec.pay_element_id ,
	     p_currency_code            =>   l_element_rec.currency_code ,
	     p_element_cost             =>   l_element_rec.element_cost ,
	     p_element_set_id           =>   l_element_rec.element_set_id ,
	     p_service_package_id       =>   l_element_rec.service_package_id ,
	     p_stage_set_id             =>   l_element_rec.stage_set_id ,
	     p_start_stage_seq          =>   l_element_rec.start_stage_seq ,
	     p_current_stage_seq        =>   l_element_rec.current_stage_seq,
	     p_end_stage_seq            =>   NVL( l_element_rec.end_stage_seq ,
						  FND_API.G_MISS_NUM )
	  );

	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --
	END LOOP;   -- To process element_lines in psb_ws_element_lines.

	--
	-- Create new records in psb_position_assignments for each occurance
	-- of l_lines_pos_rec.position_id. The global_worksheet_id
	-- will replace the worksheet_id column in new created records.
	--
	FOR l_asgn_rec IN
	(
	   SELECT *
	   FROM   psb_position_assignments
	   WHERE  position_id  = l_lines_pos_rec.position_id
	   AND    worksheet_id = p_source_worksheet_id
	)
	LOOP

	  --
	  -- API will create a new position assignments.
	  --
	  PSB_Positions_Pvt.Modify_Assignment
	  (
	     p_api_version                 => 1.0 ,
	     p_init_msg_list               => FND_API.G_FALSE ,
	     p_commit                      => FND_API.G_FALSE ,
	     p_validation_level            => FND_API.G_VALID_LEVEL_NONE ,
	     p_return_status               => l_return_status ,
	     p_msg_count                   => l_msg_count ,
	     p_msg_data                    => l_msg_data ,
	     --
	     p_position_assignment_id      => l_new_position_assignment_id ,
	     p_element_value_type          => l_asgn_rec.element_value_type ,
	     p_data_extract_id             => l_asgn_rec.data_extract_id ,
	     p_worksheet_id                => l_global_worksheet_id ,
	     p_position_id                 => l_asgn_rec.position_id ,
	     p_assignment_type             => l_asgn_rec.assignment_type ,
	     p_attribute_id                => l_asgn_rec.attribute_id ,
	     p_attribute_value_id          => l_asgn_rec.attribute_value_id ,
	     p_attribute_value             => l_asgn_rec.attribute_value ,
	     p_pay_element_id              => l_asgn_rec.pay_element_id ,
	     p_pay_element_option_id       => l_asgn_rec.pay_element_option_id ,
	     p_effective_start_date        => l_asgn_rec.effective_start_date ,
	     p_effective_end_date          => l_asgn_rec.effective_end_date ,
	     p_element_value               => l_asgn_rec.element_value ,
	     p_global_default_flag         => l_asgn_rec.global_default_flag ,
	     p_assignment_default_rule_id  =>
				       l_asgn_rec.assignment_default_rule_id ,
	     p_modify_flag                 => l_asgn_rec.modify_flag ,
	     p_rowid                       => l_rowid ,
	     p_currency_code               => l_asgn_rec.currency_code ,
	     p_pay_basis                   => l_asgn_rec.pay_basis ,
	     p_employee_id                 => l_asgn_rec.employee_id ,
	     p_primary_employee_flag       => l_asgn_rec.primary_employee_flag ,
	     p_mode                        => 'R'
	  ) ;
	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --
	END LOOP ;

      ELSIF ( l_ws_position_lines_csr%FOUND ) THEN

	--
	-- It means it is an old copied line in the source(local) worksheet,
	-- we need to overwrite information from the local worksheet.
	--

	--
	-- Update the old position_line_id with new position_line_id in
	-- psb_ws_account_lines table.
	--
	/*For Bug No : 2534088 Start*/
	--commented the following code as the complete code to be implemented
	--for inserting/updating the account lines for target worksheet

	/*
	UPDATE psb_ws_account_lines
	SET    position_line_id = l_target_position_line_id
	WHERE  position_line_id = l_lines_pos_rec.position_line_id
	AND    account_line_id IN
	       (
		 SELECT account_line_id
		 FROM   psb_ws_lines
		 WHERE  worksheet_id = p_target_worksheet_id
	       ) ;
	*/

	FOR l_lines_accts_rec IN
	(
	     SELECT accts.*
	     FROM   psb_ws_lines          lines ,
		    psb_ws_account_lines  accts
	     WHERE  lines.worksheet_id    = p_source_worksheet_id
	     AND    lines.account_line_id = accts.account_line_id
	     AND    accts.position_line_id = l_lines_pos_rec.position_line_id
	     AND    accts.end_stage_seq IS NULL
	     AND    accts.template_id IS NULL
	)
	LOOP
	--
	-- Finding p_target_worksheet_id in psb_ws_account_lines.
	--
	  OPEN l_ws_account_lines_csr ( l_lines_accts_rec.copy_of_account_line_id ) ;

	  FETCH l_ws_account_lines_csr INTO l_target_account_line_id;

	  --
	  -- Populate the l_period_amount_tbl ( used by PSB_WS_Acct1 API )
	  --
	  l_period_amount_tbl(1)  := l_lines_accts_rec.period1_amount ;
	  l_period_amount_tbl(2)  := l_lines_accts_rec.period2_amount ;
	  l_period_amount_tbl(3)  := l_lines_accts_rec.period3_amount ;
	  l_period_amount_tbl(4)  := l_lines_accts_rec.period4_amount ;
	  l_period_amount_tbl(5)  := l_lines_accts_rec.period5_amount ;
	  l_period_amount_tbl(6)  := l_lines_accts_rec.period6_amount ;
	  l_period_amount_tbl(7)  := l_lines_accts_rec.period7_amount ;
	  l_period_amount_tbl(8)  := l_lines_accts_rec.period8_amount ;
	  l_period_amount_tbl(9)  := l_lines_accts_rec.period9_amount ;
	  l_period_amount_tbl(10) := l_lines_accts_rec.period10_amount ;
	  l_period_amount_tbl(11) := l_lines_accts_rec.period11_amount ;
	  l_period_amount_tbl(12) := l_lines_accts_rec.period12_amount ;
	  l_period_amount_tbl(13) := l_lines_accts_rec.period13_amount ;
	  l_period_amount_tbl(14) := l_lines_accts_rec.period14_amount ;
	  l_period_amount_tbl(15) := l_lines_accts_rec.period15_amount ;
	  l_period_amount_tbl(16) := l_lines_accts_rec.period16_amount ;
	  l_period_amount_tbl(17) := l_lines_accts_rec.period17_amount ;
	  l_period_amount_tbl(18) := l_lines_accts_rec.period18_amount ;
	  l_period_amount_tbl(19) := l_lines_accts_rec.period19_amount ;
	  l_period_amount_tbl(20) := l_lines_accts_rec.period20_amount ;
	  l_period_amount_tbl(21) := l_lines_accts_rec.period21_amount ;
	  l_period_amount_tbl(22) := l_lines_accts_rec.period22_amount ;
	  l_period_amount_tbl(23) := l_lines_accts_rec.period23_amount ;
	  l_period_amount_tbl(24) := l_lines_accts_rec.period24_amount ;
	  l_period_amount_tbl(25) := l_lines_accts_rec.period25_amount ;
	  l_period_amount_tbl(26) := l_lines_accts_rec.period26_amount ;
	  l_period_amount_tbl(27) := l_lines_accts_rec.period27_amount ;
	  l_period_amount_tbl(28) := l_lines_accts_rec.period28_amount ;
	  l_period_amount_tbl(29) := l_lines_accts_rec.period29_amount ;
	  l_period_amount_tbl(30) := l_lines_accts_rec.period30_amount ;
	  l_period_amount_tbl(31) := l_lines_accts_rec.period31_amount ;
	  l_period_amount_tbl(32) := l_lines_accts_rec.period32_amount ;
	  l_period_amount_tbl(33) := l_lines_accts_rec.period33_amount ;
	  l_period_amount_tbl(34) := l_lines_accts_rec.period34_amount ;
	  l_period_amount_tbl(35) := l_lines_accts_rec.period35_amount ;
	  l_period_amount_tbl(36) := l_lines_accts_rec.period36_amount ;
	  l_period_amount_tbl(37) := l_lines_accts_rec.period37_amount ;
	  l_period_amount_tbl(38) := l_lines_accts_rec.period38_amount ;
	  l_period_amount_tbl(39) := l_lines_accts_rec.period39_amount ;
	  l_period_amount_tbl(40) := l_lines_accts_rec.period40_amount ;
	  l_period_amount_tbl(41) := l_lines_accts_rec.period41_amount ;
	  l_period_amount_tbl(42) := l_lines_accts_rec.period42_amount ;
	  l_period_amount_tbl(43) := l_lines_accts_rec.period43_amount ;
	  l_period_amount_tbl(44) := l_lines_accts_rec.period44_amount ;
	  l_period_amount_tbl(45) := l_lines_accts_rec.period45_amount ;
	  l_period_amount_tbl(46) := l_lines_accts_rec.period46_amount ;
	  l_period_amount_tbl(47) := l_lines_accts_rec.period47_amount ;
	  l_period_amount_tbl(48) := l_lines_accts_rec.period48_amount ;
	  l_period_amount_tbl(49) := l_lines_accts_rec.period49_amount ;
	  l_period_amount_tbl(50) := l_lines_accts_rec.period50_amount ;
	  l_period_amount_tbl(51) := l_lines_accts_rec.period51_amount ;
	  l_period_amount_tbl(52) := l_lines_accts_rec.period52_amount ;
	  l_period_amount_tbl(53) := l_lines_accts_rec.period53_amount ;
	  l_period_amount_tbl(54) := l_lines_accts_rec.period54_amount ;
	  l_period_amount_tbl(55) := l_lines_accts_rec.period55_amount ;
	  l_period_amount_tbl(56) := l_lines_accts_rec.period56_amount ;
	  l_period_amount_tbl(57) := l_lines_accts_rec.period57_amount ;
	  l_period_amount_tbl(58) := l_lines_accts_rec.period58_amount ;
	  l_period_amount_tbl(59) := l_lines_accts_rec.period59_amount ;
	  l_period_amount_tbl(60) := l_lines_accts_rec.period60_amount ;

	  IF ( l_ws_account_lines_csr%NOTFOUND ) THEN
	  --
	  -- It means a new line was created in the p_source_worksheet_id.
	  -- Putting this line in the p_target_worksheet_id. The PSB_WS_Acct_Pvt
	  -- API will also maintain psb_ws_lines.
	  --

	    PSB_WS_Acct_Pvt.Create_Account_Dist
	    (
	      p_api_version             =>   1.0 ,
	      p_init_msg_list           =>   FND_API.G_FALSE,
	      p_commit                  =>   FND_API.G_FALSE,
	      p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
	      p_return_status           =>   l_return_status,
	      p_account_line_id         =>   l_new_account_line_id,
	      p_check_spal_exists       =>   FND_API.G_FALSE,
	      p_msg_count               =>   l_msg_count,
	      p_msg_data                =>   l_msg_data,
	      --
	      p_worksheet_id            =>   p_target_worksheet_id,
	      p_budget_year_id          =>   l_lines_accts_rec.budget_year_id,
	      p_budget_group_id         =>   l_lines_accts_rec.budget_group_id,
	      p_ccid                    =>   l_lines_accts_rec.code_combination_id,
	      p_template_id             =>   NVL(l_lines_accts_rec.template_id ,
						  FND_API.G_MISS_NUM ) ,
	      p_currency_code           =>   l_lines_accts_rec.currency_code ,
	      p_balance_type            =>   l_lines_accts_rec.balance_type ,
	      p_ytd_amount              =>   l_lines_accts_rec.ytd_amount  ,
	      p_distribute_flag         =>   FND_API.G_FALSE ,
	      p_annual_fte              =>   NVL ( l_lines_accts_rec.annual_fte,
						  FND_API.G_MISS_NUM ) ,
	      p_period_amount           =>   l_period_amount_tbl ,
	      p_position_line_id        =>   l_target_position_line_id,
	      p_element_set_id          =>   NVL( l_lines_accts_rec.element_set_id,
						  FND_API.G_MISS_NUM ) ,
	      p_salary_account_line     =>   NVL(l_lines_accts_rec.salary_account_line,
						  FND_API.G_FALSE ) ,
	      p_service_package_id      =>   l_lines_accts_rec.service_package_id ,
	      p_start_stage_seq         =>   l_lines_accts_rec.start_stage_seq ,
	      p_current_stage_seq       =>   l_lines_accts_rec.current_stage_seq ,
	      p_end_stage_seq           =>   NVL( l_lines_accts_rec.end_stage_seq,
						  FND_API.G_MISS_NUM )
	    );
	    --
	    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR ;
	    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	    END IF;
	    --
	    -- The new_account_line_id will be null if the desired account lines are
	    -- already there in the target worksheet. If not null, add the new
	    -- account_line_id to all the worksheet up in the hierarchy.
	    --
	    IF l_new_account_line_id IS NOT NULL THEN
	      --
	      -- Add the account_line to all the worksheets up in the hierarchy.
	      -- ( The line has already been added in the target worksheet.)
	      --
	      PSB_WS_Ops_Pvt.Add_Worksheet_Line
	      (
		 p_api_version               => 1.0 ,
		 p_init_msg_list             => FND_API.G_FALSE,
		 p_commit                    => FND_API.G_FALSE,
		 p_validation_level          => FND_API.G_VALID_LEVEL_NONE,
		 p_return_status             => l_return_status,
		 p_msg_count                 => l_msg_count,
		 p_msg_data                  => l_msg_data ,
		 --
		 p_worksheet_id              => p_target_worksheet_id ,
		 p_account_line_id           => l_new_account_line_id ,
		 p_add_in_current_worksheet  => FND_API.G_FALSE
	      ) ;
	      --
	      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR ;
	      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	      END IF;
	      --
	    END IF;
	  --
	  ELSIF ( l_ws_account_lines_csr%FOUND ) THEN
	    --
	    -- It means it is not a new line, but the amount information may be
	    -- different in the p_source_worksheet_id.
	    --
	      -- Updating ytd_amount in the p_target_worksheet_id.
	    --

	    PSB_WS_Acct_Pvt.Create_Account_Dist
	     (
		p_api_version             =>   1.0 ,
		p_init_msg_list           =>   FND_API.G_FALSE,
		p_commit                  =>   FND_API.G_FALSE,
		p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
		p_return_status           =>   l_return_status,
		p_msg_count               =>   l_msg_count,
		p_msg_data                =>   l_msg_data,
                -- comment out the following line for bug 3419241
                -- p_check_stages must be set to FND_API.G_TRUE to
                -- automatically create new Stage for the Account Line.
                -- p_check_stages is FND_API.G_TRUE by default.
		--p_check_stages            =>   FND_API.G_FALSE,
		p_worksheet_id            =>   p_target_worksheet_id,
		p_account_line_id         =>   l_target_account_line_id,
		p_ytd_amount              =>   l_lines_accts_rec.ytd_amount,
		p_period_amount           =>   l_period_amount_tbl,
		p_service_package_id      =>   l_lines_accts_rec.service_package_id,
		p_current_stage_seq       =>   l_lines_accts_rec.current_stage_seq,
		p_annual_fte              =>   l_lines_accts_rec.annual_fte
	      ) ;

	      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR ;
	      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	      END IF;
	  --
	  END IF ;  -- For l_ws_account_lines_csr%NOTFOUND.
	--
	CLOSE l_ws_account_lines_csr ;
	--
	END LOOP ;
	/*For Bug No : 2534088 End*/

	--
	-- Wipe out records in psb_ws_fte_lines related to the original line
	-- l_target_position_line_id and create new records from the local
	-- l_lines_pos_rec.position_line_id . The l_target_position_line_id
	-- will replace the position_line_id column in new created records.
	--

	DELETE psb_ws_fte_lines
	WHERE  position_line_id = l_target_position_line_id ;

	FOR l_fte_rec IN
	(
	   SELECT *
	   FROM   psb_ws_fte_lines
	   WHERE  position_line_id = l_lines_pos_rec.position_line_id
	)
	LOOP

	  --
	  -- Populate the l_period_amount_tbl ( used by PSB_WS_Acct1 API )
	  --
	  l_period_fte_tbl(1)  := l_fte_rec.period1_fte ;
	  l_period_fte_tbl(2)  := l_fte_rec.period2_fte ;
	  l_period_fte_tbl(3)  := l_fte_rec.period3_fte ;
	  l_period_fte_tbl(4)  := l_fte_rec.period4_fte ;
	  l_period_fte_tbl(5)  := l_fte_rec.period5_fte ;
	  l_period_fte_tbl(6)  := l_fte_rec.period6_fte ;
	  l_period_fte_tbl(7)  := l_fte_rec.period7_fte ;
	  l_period_fte_tbl(8)  := l_fte_rec.period8_fte ;
	  l_period_fte_tbl(9)  := l_fte_rec.period9_fte ;
	  l_period_fte_tbl(10) := l_fte_rec.period10_fte ;
	  l_period_fte_tbl(11) := l_fte_rec.period11_fte ;
	  l_period_fte_tbl(12) := l_fte_rec.period12_fte ;
	  l_period_fte_tbl(13) := l_fte_rec.period13_fte ;
	  l_period_fte_tbl(14) := l_fte_rec.period14_fte ;
	  l_period_fte_tbl(15) := l_fte_rec.period15_fte ;
	  l_period_fte_tbl(16) := l_fte_rec.period16_fte ;
	  l_period_fte_tbl(17) := l_fte_rec.period17_fte ;
	  l_period_fte_tbl(18) := l_fte_rec.period18_fte ;
	  l_period_fte_tbl(19) := l_fte_rec.period19_fte ;
	  l_period_fte_tbl(20) := l_fte_rec.period20_fte ;
	  l_period_fte_tbl(21) := l_fte_rec.period21_fte ;
	  l_period_fte_tbl(22) := l_fte_rec.period22_fte ;
	  l_period_fte_tbl(23) := l_fte_rec.period23_fte ;
	  l_period_fte_tbl(24) := l_fte_rec.period24_fte ;
	  l_period_fte_tbl(25) := l_fte_rec.period25_fte ;
	  l_period_fte_tbl(26) := l_fte_rec.period26_fte ;
	  l_period_fte_tbl(27) := l_fte_rec.period27_fte ;
	  l_period_fte_tbl(28) := l_fte_rec.period28_fte ;
	  l_period_fte_tbl(29) := l_fte_rec.period29_fte ;
	  l_period_fte_tbl(30) := l_fte_rec.period30_fte ;
	  l_period_fte_tbl(31) := l_fte_rec.period31_fte ;
	  l_period_fte_tbl(32) := l_fte_rec.period32_fte ;
	  l_period_fte_tbl(33) := l_fte_rec.period33_fte ;
	  l_period_fte_tbl(34) := l_fte_rec.period34_fte ;
	  l_period_fte_tbl(35) := l_fte_rec.period35_fte ;
	  l_period_fte_tbl(36) := l_fte_rec.period36_fte ;
	  l_period_fte_tbl(37) := l_fte_rec.period37_fte ;
	  l_period_fte_tbl(38) := l_fte_rec.period38_fte ;
	  l_period_fte_tbl(39) := l_fte_rec.period39_fte ;
	  l_period_fte_tbl(40) := l_fte_rec.period40_fte ;
	  l_period_fte_tbl(41) := l_fte_rec.period41_fte ;
	  l_period_fte_tbl(42) := l_fte_rec.period42_fte ;
	  l_period_fte_tbl(43) := l_fte_rec.period43_fte ;
	  l_period_fte_tbl(44) := l_fte_rec.period44_fte ;
	  l_period_fte_tbl(45) := l_fte_rec.period45_fte ;
	  l_period_fte_tbl(46) := l_fte_rec.period46_fte ;
	  l_period_fte_tbl(47) := l_fte_rec.period47_fte ;
	  l_period_fte_tbl(48) := l_fte_rec.period48_fte ;
	  l_period_fte_tbl(49) := l_fte_rec.period49_fte ;
	  l_period_fte_tbl(50) := l_fte_rec.period50_fte ;
	  l_period_fte_tbl(51) := l_fte_rec.period51_fte ;
	  l_period_fte_tbl(52) := l_fte_rec.period52_fte ;
	  l_period_fte_tbl(53) := l_fte_rec.period53_fte ;
	  l_period_fte_tbl(54) := l_fte_rec.period54_fte ;
	  l_period_fte_tbl(55) := l_fte_rec.period55_fte ;
	  l_period_fte_tbl(56) := l_fte_rec.period56_fte ;
	  l_period_fte_tbl(57) := l_fte_rec.period57_fte ;
	  l_period_fte_tbl(58) := l_fte_rec.period58_fte ;
	  l_period_fte_tbl(59) := l_fte_rec.period59_fte ;
	  l_period_fte_tbl(60) := l_fte_rec.period60_fte ;

	  -- API to create new fte lines in psb_ws_fte_lines.
	  PSB_WS_Pos_Pvt.Create_FTE_Lines
	  (
	     p_api_version              =>   1.0 ,
	     p_init_msg_list            =>   FND_API.G_FALSE ,
	     p_commit                   =>   FND_API.G_FALSE ,
	     p_validation_level         =>   FND_API.G_VALID_LEVEL_FULL ,
	     p_return_status            =>   l_return_status ,
	     p_msg_count                =>   l_msg_count ,
	     p_msg_data                 =>   l_msg_data ,
	     --
	     p_fte_line_id              =>   l_new_fte_line_id ,
	     p_check_spfl_exists        =>   FND_API.G_FALSE,
	     p_worksheet_id             =>   p_target_worksheet_id ,
	     p_position_line_id         =>   l_target_position_line_id ,
	     p_budget_year_id           =>   l_fte_rec.budget_year_id ,
	     p_annual_fte               =>   l_fte_rec.annual_fte ,
	     p_service_package_id       =>   l_fte_rec.service_package_id ,
	     p_stage_set_id             =>   l_fte_rec.stage_set_id ,
	     p_start_stage_seq          =>   l_fte_rec.start_stage_seq ,
	     p_current_stage_seq        =>   l_fte_rec.current_stage_seq  ,
	     p_end_stage_seq            =>   NVL( l_fte_rec.end_stage_seq ,
						  FND_API.G_MISS_NUM ),
	     p_period_fte               =>   l_period_fte_tbl
	  );

	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --

	END LOOP;   -- To process fte_lines in psb_ws_element_lines.


	--
	-- Wipe out records in psb_ws_element_lines related to the original line
	-- l_target_position_line_id and create new records from the local
	-- l_lines_pos_rec.position_line_id . The l_target_position_line_id
	-- will replace the position_line_id column in new created records.
	--

	DELETE psb_ws_element_lines
	WHERE  position_line_id = l_target_position_line_id ;

	FOR l_element_rec IN
	(
	   SELECT *
	   FROM   psb_ws_element_lines
	   WHERE  position_line_id = l_lines_pos_rec.position_line_id
	)
	LOOP

	  -- API to create new element lines in psb_ws_element_lines.
	  PSB_WS_Pos_Pvt.Create_Element_Lines
	  (
	     p_api_version              =>   1.0 ,
	     p_init_msg_list            =>   FND_API.G_FALSE ,
	     p_commit                   =>   FND_API.G_FALSE ,
	     p_validation_level         =>   FND_API.G_VALID_LEVEL_FULL ,
	     p_return_status            =>   l_return_status ,
	     p_msg_count                =>   l_msg_count ,
	     p_msg_data                 =>   l_msg_data ,
	     --
	     p_element_line_id          =>   l_new_element_line_id ,
	     p_position_line_id         =>   l_target_position_line_id ,
	     p_budget_year_id           =>   l_element_rec.budget_year_id ,
	     p_pay_element_id           =>   l_element_rec.pay_element_id ,
	     p_currency_code            =>   l_element_rec.currency_code ,
	     p_element_cost             =>   l_element_rec.element_cost ,
	     p_element_set_id           =>   l_element_rec.element_set_id ,
	     p_service_package_id       =>   l_element_rec.service_package_id ,
	     p_stage_set_id             =>   l_element_rec.stage_set_id ,
	     p_start_stage_seq          =>   l_element_rec.start_stage_seq ,
	     p_current_stage_seq        =>   l_element_rec.current_stage_seq,
	     p_end_stage_seq            =>   NVL( l_element_rec.end_stage_seq,
						  FND_API.G_MISS_NUM )
	  );

	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --
	END LOOP;   -- To process element_lines in psb_ws_element_lines.

	--
	-- Wipe out records in psb_position_assignments related to the original
	-- l_target_position_id and create new records from the
	-- local l_lines_pos_rec.position_id. The global_worksheet_id will
	-- replace the worksheet_id column in new created records.
	--
	DELETE psb_position_assignments
	WHERE  position_id  = l_target_position_id
	AND    worksheet_id = l_global_worksheet_id ;

	--
	-- Create new records in psb_position_assignments for each occurance
	-- of l_lines_pos_rec.position_id. The global_worksheet_id
	-- will replace the worksheet_id column in new created records.
	--
	FOR l_asgn_rec IN
	(
	   SELECT *
	   FROM   psb_position_assignments
	   WHERE  position_id  = l_lines_pos_rec.position_id
	   AND    worksheet_id = p_source_worksheet_id
	)
	LOOP

	  --
	  -- API will create a new position assignments.
	  --
	  PSB_Positions_Pvt.Modify_Assignment
	  (
	     p_api_version                 => 1.0 ,
	     p_init_msg_list               => FND_API.G_FALSE ,
	     p_commit                      => FND_API.G_FALSE ,
	     p_validation_level            => FND_API.G_VALID_LEVEL_NONE ,
	     p_return_status               => l_return_status ,
	     p_msg_count                   => l_msg_count ,
	     p_msg_data                    => l_msg_data ,
	     --
	     p_position_assignment_id      => l_new_position_assignment_id ,
	     p_element_value_type          => l_asgn_rec.element_value_type ,
	     p_data_extract_id             => l_asgn_rec.data_extract_id ,
	     p_worksheet_id                => l_global_worksheet_id ,
	     p_position_id                 => l_asgn_rec.position_id ,
	     p_assignment_type             => l_asgn_rec.assignment_type ,
	     p_attribute_id                => l_asgn_rec.attribute_id ,
	     p_attribute_value_id          => l_asgn_rec.attribute_value_id ,
	     p_attribute_value             => l_asgn_rec.attribute_value ,
	     p_pay_element_id              => l_asgn_rec.pay_element_id ,
	     p_pay_element_option_id       => l_asgn_rec.pay_element_option_id ,
	     p_effective_start_date        => l_asgn_rec.effective_start_date ,
	     p_effective_end_date          => l_asgn_rec.effective_end_date ,
	     p_element_value               => l_asgn_rec.element_value ,
	     p_global_default_flag         => l_asgn_rec.global_default_flag ,
	     p_assignment_default_rule_id  =>
				       l_asgn_rec.assignment_default_rule_id ,
	     p_modify_flag                 => l_asgn_rec.modify_flag ,
	     p_rowid                       => l_rowid ,
	     p_currency_code               => l_asgn_rec.currency_code ,
	     p_pay_basis                   => l_asgn_rec.pay_basis ,
	     p_employee_id                 => l_asgn_rec.employee_id ,
	     p_primary_employee_flag       => l_asgn_rec.primary_employee_flag ,
	     p_mode                        => 'R'
	  ) ;
	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --
	END LOOP ;  -- To process position assignments.

      END IF ;  -- For l_ws_position_lines_csr%NOTFOUND
      --
      CLOSE l_ws_position_lines_csr ;
      --
    END LOOP ;

  END IF ;  -- l_source_budget_by_position = 'Y' THEN

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
    ROLLBACK TO Merge_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Merge_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_ws_account_lines_csr%ISOPEN ) THEN
      CLOSE l_ws_account_lines_csr ;
    END IF ;
    --
    ROLLBACK TO Merge_Worksheets_Pvt ;
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
END Merge_Worksheets;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Delete_Worksheet                            |
 +===========================================================================*/
--
-- The API This API deletes a local or global worksheet.
--
PROCEDURE Delete_Worksheet
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
  p_keep_local_copy_flag      IN       VARCHAR2 := 'N'
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Worksheet' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_local_copy_flag         psb_worksheets.local_copy_flag%TYPE ;
  l_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_global_worksheet_flag   psb_worksheets.global_worksheet_flag%TYPE ;
  l_worksheets_tab          PSB_WS_Ops_Pvt.Worksheet_Tbl_Type ;
  --
BEGIN
  --
  SAVEPOINT Delete_Worksheet ;
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

  SELECT NVL( global_worksheet_flag, 'N') ,
	 NVL( local_copy_flag, 'N')       ,
	 NVL( budget_by_position, 'N')
       INTO
	 l_global_worksheet_flag ,
	 l_local_copy_flag ,
	 l_budget_by_position
  FROM   psb_worksheets
  WHERE  worksheet_id = p_worksheet_id ;

  --
  -- Take action bases on the type of the worksheet.
  --
  IF l_global_worksheet_flag = 'Y' THEN
    --
    -- ( It means it is a global worksheet.)
    -- Lock all the child official, review group and local worksheets.
    -- You have to lock local worksheets either for deletion or for updation
    -- depening on p_keep_local_copy_flag parameter.
    --

    -- Find all related worksheets.
    FOR l_worksheet_rec IN
    (
       SELECT worksheet_id
       FROM   psb_worksheets
       WHERE  global_worksheet_id               = p_worksheet_id
       AND    NVL( global_worksheet_flag, 'N' ) = 'N'
    )
    LOOP
      --
      PSB_Concurrency_Control_Pub.Enforce_Concurrency_Control
      (
	 p_api_version              => 1.0 ,
	 p_init_msg_list            => FND_API.G_FALSE ,
	 p_validation_level         => FND_API.G_VALID_LEVEL_NONE ,
	 p_return_status            => l_return_status ,
	 p_msg_count                => l_msg_count ,
	 p_msg_data                 => l_msg_data  ,
	 --
	 p_concurrency_class        => 'MAINTENANCE' ,
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => l_worksheet_rec.worksheet_id
      );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END LOOP ;  -- Lock child official, review group and local worksheets.

    -- Delete all the child official worksheets.
    FOR l_worksheet_rec IN
    (
       SELECT worksheet_id, budget_by_position
       FROM   psb_worksheets
       WHERE  global_worksheet_id    = p_worksheet_id
       AND    NVL( global_worksheet_flag, 'N' ) = 'N'
       AND    NVL( local_copy_flag,       'N' ) = 'N'
    )
    LOOP
      --
      Delete_Worksheet_Pvt
      (
	 p_worksheet_id        =>  l_worksheet_rec.worksheet_id       ,
	 p_budget_by_position  =>  l_worksheet_rec.budget_by_position ,
	 p_delete_lines_flag   =>  'N'                                ,
	 p_return_status       =>  l_return_status
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END LOOP;

    -- Delete or update all the child local worksheets.
    FOR l_worksheet_rec IN
    (
       SELECT worksheet_id, budget_by_position
       FROM   psb_worksheets
       WHERE  global_worksheet_id    = p_worksheet_id
       AND    NVL( global_worksheet_flag, 'N' ) = 'N'
       AND    NVL( local_copy_flag,       'N' ) = 'Y'
    )
    LOOP
      --
      IF p_keep_local_copy_flag = 'N' THEN
	--
	Delete_Worksheet_Pvt
	(
	   p_worksheet_id        =>  l_worksheet_rec.worksheet_id       ,
	   p_budget_by_position  =>  l_worksheet_rec.budget_by_position ,
	   p_delete_lines_flag   =>  'Y'                                ,
	   p_return_status       =>  l_return_status
	) ;
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
      ELSE
	--
	-- As global worksheet is being deleted, set global_worksheet_id
	-- column to null in the local worksheet.
	--
	PSB_Worksheet_Pvt.Update_Worksheet
	(
	  p_api_version           => 1.0 ,
	  p_init_msg_list         => FND_API.G_FALSE ,
	  p_commit                => FND_API.G_FALSE ,
	  p_validation_level      => FND_API.G_VALID_LEVEL_NONE ,
	  p_return_status         => l_return_status ,
	  p_msg_count             => l_msg_count ,
	  p_msg_data              => l_msg_data ,
	  --
	  p_worksheet_id          => l_worksheet_rec.worksheet_id ,
	  p_global_worksheet_id   => NULL
	) ;
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--
      END IF ;   -- if p_keep_local_copy_flag is 'Y'.
      --
    END LOOP ;   -- Delete or update all child local worksheets.
    --

    -- Delete the global worksheet now.
    Delete_Worksheet_Pvt
    (
       p_worksheet_id        =>  p_worksheet_id        ,
       p_budget_by_position  =>  l_budget_by_position  ,
       p_delete_lines_flag   =>  'Y'                   ,
       p_return_status       =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

  ELSIF l_local_copy_flag = 'Y' THEN

    --
    -- It Means it is a local worksheet.
    --
    Delete_Worksheet_Pvt
    (
       p_worksheet_id        =>  p_worksheet_id         ,
       p_budget_by_position  =>  l_budget_by_position   ,
       p_delete_lines_flag   =>  'Y'                    ,
       p_return_status       =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

  ELSE

    --
    -- ( It means it is either an official or review group worksheet. )
    -- We need to delete all child worksheets. Also their local copies if
    -- p_keep_local_copy_flag parameter is 'N'.
    --

    -- Find all the child worksheets.
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
       p_worksheet_id       =>   p_worksheet_id,
       p_worksheet_tbl      =>   l_worksheets_tab
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

    -- Adding the current worksheet in the table as it has to go through
    -- the same processing
    l_worksheets_tab(0) := p_worksheet_id ;

    --
    -- Process the current and all the child worksheets for locking.
    -- (Use 0 and COUNT-1 now).
    --
    FOR i IN 0..l_worksheets_tab.COUNT-1
    LOOP

      -- Lock the current worksheet.
      PSB_Concurrency_Control_Pub.Enforce_Concurrency_Control
      (
	 p_api_version              => 1.0 ,
	 p_init_msg_list            => FND_API.G_FALSE ,
	 p_validation_level         => FND_API.G_VALID_LEVEL_NONE ,
	 p_return_status            => l_return_status ,
	 p_msg_count                => l_msg_count ,
	 p_msg_data                 => l_msg_data  ,
	 --
	 p_concurrency_class        => 'MAINTENANCE' ,
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => l_worksheets_tab(i)
      );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --

      -- Lock local copies of the current worksheet as per the parameter.
      IF p_keep_local_copy_flag = 'N' THEN

	FOR l_local_ws_rec IN
	(
	   SELECT worksheet_id
	   FROM   psb_worksheets
	   WHERE  copy_of_worksheet_id = l_worksheets_tab(i)
	)
	LOOP

	  -- Lock the current worksheet.
	  PSB_Concurrency_Control_Pub.Enforce_Concurrency_Control
	  (
	     p_api_version              => 1.0 ,
	     p_init_msg_list            => FND_API.G_FALSE ,
	     p_validation_level         => FND_API.G_VALID_LEVEL_NONE ,
	     p_return_status            => l_return_status ,
	     p_msg_count                => l_msg_count ,
	     p_msg_data                 => l_msg_data  ,
	     --
	     p_concurrency_class        => 'MAINTENANCE' ,
	     p_concurrency_entity_name  => 'WORKSHEET',
	     p_concurrency_entity_id    => l_local_ws_rec.worksheet_id
	  );
	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;
	  --

	END LOOP ;

      END IF; -- FOR p_keep_local_copy_flag = 'N' clause.

    END LOOP; -- For locking phase.

    --
    -- Process the current and all the child worksheets for deletion.
    -- (Use 0 and COUNT-1 now).
    --
    FOR i IN 0..l_worksheets_tab.COUNT-1
    LOOP

      -- Delete the current worksheet.
      Delete_Worksheet_Pvt
      (
	 p_worksheet_id        =>  l_worksheets_tab(i)      ,
	 p_budget_by_position  =>  l_budget_by_position     ,
	 p_delete_lines_flag   =>  'N'                      ,
	 p_return_status       =>  l_return_status
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      -- Delete local copies of the current worksheet as per the parameter.
      IF p_keep_local_copy_flag = 'N' THEN

	FOR l_local_ws_rec IN
	(
	   SELECT worksheet_id
	   FROM   psb_worksheets
	   WHERE  copy_of_worksheet_id = l_worksheets_tab(i)
	)
	LOOP

	  Delete_Worksheet_Pvt
	  (
	     p_worksheet_id        =>  l_local_ws_rec.worksheet_id  ,
	     p_budget_by_position  =>  l_budget_by_position         ,
	     p_delete_lines_flag   =>  'Y'                          ,
	     p_return_status       =>  l_return_status
	  ) ;
	  --
	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

	END LOOP ;

      END IF; -- FOR p_keep_local_copy_flag = 'N' clause.

    END LOOP; -- For deletion phase.

  END IF; -- For the main IF statement.

  IF  FND_API.To_Boolean ( p_commit ) THEN
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
  /*For Bug No : 2266309 Start*/
    --ROLLBACK TO Delete_Worksheet ;
    ROLLBACK;
  /*For Bug No : 2266309 End*/
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
  /*For Bug No : 2266309 Start*/
    --ROLLBACK TO Delete_Worksheet ;
    ROLLBACK;
  /*For Bug No : 2266309 End*/
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
  /*For Bug No : 2266309 Start*/
    --ROLLBACK TO Delete_Worksheet ;
    ROLLBACK;
  /*For Bug No : 2266309 End*/
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
END Delete_Worksheet ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Add_Worksheet_Line                          |
 +===========================================================================*/
--
-- This API adds a given account line to a worksheet. The addition is
-- propagated to all the higher worksheets. The operation is performed only
-- on the psb_ws_lines table.
--
PROCEDURE Add_Worksheet_Line
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN      psb_worksheets.worksheet_id%TYPE   ,
  p_account_line_id           IN      psb_ws_account_lines.account_line_id%TYPE,
  p_add_in_current_worksheet  IN      VARCHAR2 := FND_API.G_FALSE
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)  := 'Add_Worksheet_Line' ;
  l_api_version             CONSTANT NUMBER        :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  CURSOR l_ws_lines_csr
	 IS
	 SELECT *
	 FROM   psb_ws_lines
	 WHERE  account_line_id = p_account_line_id ;
  --
  l_ws_lines_row_type l_ws_lines_csr%ROWTYPE ;
  --
  l_current_worksheet_id    psb_worksheets.worksheet_id%TYPE ;
  l_current_budget_group_id psb_worksheets.budget_group_id%TYPE ;
  l_budget_group_id         psb_worksheets.budget_group_id%TYPE ;
  l_parent_budget_group_id  psb_worksheets.budget_group_id%TYPE ;
  l_parent_worksheet_id     psb_worksheets.worksheet_id%TYPE ;
  l_distribution_id         psb_ws_distribution_details.distribution_id%TYPE ;

BEGIN
  --
  SAVEPOINT Add_Worksheet_Line_Pvt ;
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
  -- Finding the account line information.
  --

  OPEN l_ws_lines_csr ;

  FETCH l_ws_lines_csr INTO l_ws_lines_row_type ;

  IF ( l_ws_lines_csr%NOTFOUND ) THEN
    --
    CLOSE l_ws_lines_csr ;
    Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_ACCOUNT_LINE_ID') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  l_current_worksheet_id := p_worksheet_id ;

  -- Updating the current worksheet (the one which is passed).
  IF p_add_in_current_worksheet = FND_API.G_TRUE THEN

    --
    -- Add the new account line to the current worksheet. All we need to do
    -- is make an entry in the account-line matrix.
    --
    Insert_WS_Lines_Pvt
    (
      p_worksheet_id       =>  l_current_worksheet_id ,
      p_account_line_id    =>  p_account_line_id ,
      p_freeze_flag        =>  l_ws_lines_row_type.freeze_flag ,
      p_view_line_flag     =>  l_ws_lines_row_type.view_line_flag ,
      p_last_update_date   =>  g_current_date,
      p_last_updated_by    =>  g_current_user_id,
      p_last_update_login  =>  g_current_login_id,
      p_created_by         =>  g_current_user_id,
      p_creation_date      =>  g_current_date,
      p_return_status      =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  --
  -- Updating the top worksheets in the hierarchy.
  --
  LOOP
    --
    PSB_WS_Ops_Pvt.Find_Parent_Worksheet
    (
      p_api_version             => 1.0 ,
      p_init_msg_list           => FND_API.G_FALSE,
      p_commit                  => FND_API.G_FALSE,
      p_validation_level        => FND_API.G_VALID_LEVEL_NONE,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data ,
      --
      p_worksheet_id            => l_current_worksheet_id ,
      p_worksheet_id_OUT        => l_parent_worksheet_id
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF l_parent_worksheet_id = 0 THEN
      -- It means all the top worksheets have been processed.
      EXIT ;
    END IF ;

    l_current_worksheet_id := l_parent_worksheet_id ;

    --
    -- Add the new account line to the current worksheet. All we need to do
    -- is make an entry in the account-line matrix.
    --
    Insert_WS_Lines_Pvt
    (
      p_worksheet_id       =>  l_current_worksheet_id ,
      p_account_line_id    =>  p_account_line_id ,
      p_freeze_flag        =>  l_ws_lines_row_type.freeze_flag ,
      p_view_line_flag     =>  l_ws_lines_row_type.view_line_flag ,
      p_last_update_date   =>  g_current_date,
      p_last_updated_by    =>  g_current_user_id,
      p_last_update_login  =>  g_current_login_id,
      p_created_by         =>  g_current_user_id,
      p_creation_date      =>  g_current_date,
      p_return_status      =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP;
  --
  CLOSE l_ws_lines_csr ;
  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Add_Worksheet_Line_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Add_Worksheet_Line_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_ws_lines_csr%ISOPEN ) THEN
      CLOSE l_ws_lines_csr ;
    END IF ;
    --
    ROLLBACK TO Add_Worksheet_Line_Pvt ;
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
END Add_Worksheet_Line;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Add_Worksheet_Line                          |
 +===========================================================================*/
--
-- This API propagates all account lines for a Position instance to all the
-- higher worksheets. The operation is performed only on the psb_ws_lines table.
--
PROCEDURE Add_Worksheet_Line
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER
)
IS

  l_api_name          CONSTANT VARCHAR2(30)  := 'Add_Worksheet_Line';
  l_api_version       CONSTANT NUMBER        :=  1.0;

  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  cursor c_WL is
    select b.account_line_id,
	   a.view_line_flag,
	   a.freeze_flag
      from psb_ws_lines         a,
	   psb_ws_account_lines b
     where a.account_line_id  = b.account_line_id
       and a.worksheet_id     = p_worksheet_id
       and b.position_line_id = p_position_line_id;

BEGIN

  SAVEPOINT Add_Worksheet_Line_Pvt;

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.To_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  --
  -- Loop to find out all the account_line_id(s) which are associated with
  -- the p_position_line_id.
  --
  for c_WL_Rec in c_WL loop

    --
    -- Each account_line_id related to the p_position_line_id needs to be
    -- added to all the worksheets up in the hierarchy.
    -- ( The line has already been added in the target worksheet.)
    --
    PSB_WS_Ops_Pvt.Add_Worksheet_Line
    (
      p_api_version               => 1.0 ,
      p_init_msg_list             => FND_API.G_FALSE,
      p_commit                    => FND_API.G_FALSE,
      p_validation_level          => FND_API.G_VALID_LEVEL_NONE,
      p_return_status             => l_return_status,
      p_msg_count                 => l_msg_count,
      p_msg_data                  => l_msg_data ,
      --
      p_worksheet_id              => p_worksheet_id ,
      p_account_line_id           => c_WL_Rec.account_line_id,
      p_add_in_current_worksheet  => FND_API.G_FALSE
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

  END LOOP; -- End finding the account_line_id(s).

  --
  IF  FND_API.To_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Add_Worksheet_Line_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Add_Worksheet_Line_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Add_Worksheet_Line_Pvt ;
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
END Add_Worksheet_Line;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Add_Line_To_Worksheets                      |
 +===========================================================================*/
--
-- This API adds a line to a set of worksheets.
--
PROCEDURE Add_Line_To_Worksheets
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_account_line_id           IN      psb_ws_account_lines.account_line_id%TYPE,
  p_worksheet_tbl             IN      Worksheet_Tbl_Type
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Add_Line_To_Worksheets';
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_current_worksheet_id    psb_worksheets.worksheet_id%TYPE ;
  --
  CURSOR l_ws_lines_csr
	 IS
	 SELECT *
	 FROM   psb_ws_lines
	 WHERE  account_line_id = p_account_line_id ;
  --
  l_ws_lines_row_type l_ws_lines_csr%ROWTYPE ;
  --
BEGIN
  --
  SAVEPOINT Add_Line_To_Worksheets_Pvt ;
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

  OPEN l_ws_lines_csr ;

  FETCH l_ws_lines_csr INTO l_ws_lines_row_type ;

  IF ( l_ws_lines_csr%NOTFOUND ) THEN
    --
    CLOSE l_ws_lines_csr ;
    Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_ACCOUNT_LINE_ID') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- Process all the worksheets in the table.
  FOR i IN 1..p_worksheet_tbl.COUNT
  LOOP
    --
    -- API to add line to the current worksheet only.
    --
    Insert_WS_Lines_Pvt
    (
       p_worksheet_id       =>  p_worksheet_tbl(i) ,
       p_account_line_id    =>  p_account_line_id ,
       p_freeze_flag        =>  l_ws_lines_row_type.freeze_flag ,
       p_view_line_flag     =>  l_ws_lines_row_type.view_line_flag ,
       p_last_update_date   =>  g_current_date,
       p_last_updated_by    =>  g_current_user_id,
       p_last_update_login  =>  g_current_login_id,
       p_created_by         =>  g_current_user_id,
       p_creation_date      =>  g_current_date,
       p_return_status      =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP;

  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Add_Line_To_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Add_Line_To_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Add_Line_To_Worksheets_Pvt ;
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
END Add_Line_To_Worksheets ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Add_Worksheet_Position_Line                 |
 +===========================================================================*/
--
-- This API adds a given position line to a worksheet. The addition is
-- propagated to all the higher worksheets. The operation is performed only
-- on the psb_ws_lines_positions table.
--
PROCEDURE Add_Worksheet_Position_Line
(
  p_api_version               IN    NUMBER   ,
  p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN    VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY   VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY   NUMBER   ,
  p_msg_data                  OUT  NOCOPY   VARCHAR2 ,
  --
  p_worksheet_id              IN    psb_worksheets.worksheet_id%TYPE   ,
  p_position_line_id          IN    psb_ws_position_lines.position_line_id%TYPE,
  p_add_in_current_worksheet  IN    VARCHAR2 := FND_API.G_FALSE
)
IS
  --
  l_api_name          CONSTANT VARCHAR2(30)  := 'Add_Worksheet_Position_Line' ;
  l_api_version       CONSTANT NUMBER        :=  1.0 ;
  --
  l_return_status     VARCHAR2(1) ;
  l_msg_count         NUMBER ;
  l_msg_data          VARCHAR2(2000) ;
  --
  CURSOR l_ws_lines_positions_csr
	 IS
	 SELECT *
	 FROM   psb_ws_lines_positions
	 WHERE  position_line_id = p_position_line_id ;
  --
  l_ws_lines_positions_row_type
			      l_ws_lines_positions_csr%ROWTYPE ;
  --
  l_current_worksheet_id      psb_worksheets.worksheet_id%TYPE ;
  l_current_budget_group_id   psb_worksheets.budget_group_id%TYPE ;
  l_budget_group_id           psb_worksheets.budget_group_id%TYPE ;
  l_parent_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  l_parent_worksheet_id       psb_worksheets.worksheet_id%TYPE ;
  l_distribution_id           psb_ws_distribution_details.distribution_id%TYPE;

BEGIN
  --
  SAVEPOINT Add_Worksheet_Pos_Line_Pvt ;
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
  -- Finding the account line information.
  --

  OPEN l_ws_lines_positions_csr ;

  FETCH l_ws_lines_positions_csr INTO l_ws_lines_positions_row_type ;

  IF ( l_ws_lines_positions_csr%NOTFOUND ) THEN
    --
    CLOSE l_ws_lines_positions_csr ;
    Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_POSITION_LINE_ID') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  l_current_worksheet_id := p_worksheet_id ;

  -- Updating the current worksheet (the one which is passed).
  IF p_add_in_current_worksheet = FND_API.G_TRUE THEN

    --
    -- Add the new position line to the current worksheet. All we need to do
    -- is make an entry in the position matrix.
    --
    PSB_WS_Pos_Pvt.Create_Position_Matrix
    (
       p_api_version        =>  1.0 ,
       p_init_msg_list      =>  FND_API.G_FALSE ,
       p_validation_level   =>  FND_API.G_VALID_LEVEL_NONE ,
       p_return_status      =>  l_return_status ,
       p_msg_count          =>  l_msg_count ,
       p_msg_data           =>  l_msg_data ,
       --
       p_worksheet_id       =>  l_current_worksheet_id ,
       p_position_line_id   =>  p_position_line_id ,
       p_freeze_flag        =>  l_ws_lines_positions_row_type.freeze_flag ,
       p_view_line_flag     =>  l_ws_lines_positions_row_type.view_line_flag
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  --
  -- Updating the top worksheets in the hierarchy.
  --
  LOOP
    --
    PSB_WS_Ops_Pvt.Find_Parent_Worksheet
    (
      p_api_version             => 1.0 ,
      p_init_msg_list           => FND_API.G_FALSE,
      p_commit                  => FND_API.G_FALSE,
      p_validation_level        => FND_API.G_VALID_LEVEL_NONE,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data ,
      --
      p_worksheet_id            => l_current_worksheet_id ,
      p_worksheet_id_OUT        => l_parent_worksheet_id
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF l_parent_worksheet_id = 0 THEN
      -- It means all the top worksheets have been processed.
      EXIT ;
    END IF ;

    l_current_worksheet_id := l_parent_worksheet_id ;

    --
    -- Add the new position line to the current worksheet.
    --
    PSB_WS_Pos_Pvt.Create_Position_Matrix
    (
       p_api_version        =>  1.0 ,
       p_init_msg_list      =>  FND_API.G_FALSE ,
       p_validation_level   =>  FND_API.G_VALID_LEVEL_NONE ,
       p_return_status      =>  l_return_status ,
       p_msg_count          =>  l_msg_count ,
       p_msg_data           =>  l_msg_data ,
       --
       p_worksheet_id       =>  l_current_worksheet_id ,
       p_position_line_id   =>  p_position_line_id ,
       p_freeze_flag        =>  l_ws_lines_positions_row_type.freeze_flag ,
       p_view_line_flag     =>  l_ws_lines_positions_row_type.view_line_flag
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP;
  --
  CLOSE l_ws_lines_positions_csr ;

  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Add_Worksheet_Pos_Line_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Add_Worksheet_Pos_Line_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_ws_lines_positions_csr%ISOPEN ) THEN
      CLOSE l_ws_lines_positions_csr ;
    END IF ;
    --
    ROLLBACK TO Add_Worksheet_Pos_Line_Pvt ;
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
END Add_Worksheet_Position_Line ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Add_Pos_Line_To_Worksheets                  |
 +===========================================================================*/
--
-- This API adds a line to a set of worksheets.
--
PROCEDURE Add_Pos_Line_To_Worksheets
(
  p_api_version               IN   NUMBER   ,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY  VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY  NUMBER   ,
  p_msg_data                  OUT  NOCOPY  VARCHAR2 ,
  --
  p_position_line_id          IN   psb_ws_position_lines.position_line_id%TYPE,
  p_worksheet_tbl             IN   Worksheet_Tbl_Type
)
IS
  --
  l_api_name              CONSTANT VARCHAR2(30) := 'Add_Pos_Line_To_Worksheets';
  l_api_version           CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status         VARCHAR2(1) ;
  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000) ;
  --
  l_current_worksheet_id psb_worksheets.worksheet_id%TYPE ;
  --
  CURSOR l_ws_lines_positions_csr
	 IS
	 SELECT *
	 FROM   psb_ws_lines_positions
	 WHERE  position_line_id = p_position_line_id ;
  --
  l_ws_lines_positions_row_type   l_ws_lines_positions_csr%ROWTYPE ;
  --
BEGIN
  --
  SAVEPOINT Add_Pos_Line_To_Worksheets_Pvt ;
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

  OPEN l_ws_lines_positions_csr ;

  FETCH l_ws_lines_positions_csr INTO l_ws_lines_positions_row_type ;

  IF ( l_ws_lines_positions_csr%NOTFOUND ) THEN
    --
    CLOSE l_ws_lines_positions_csr ;
    Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_POSITION_LINE_ID') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- Process all the worksheets in the table.
  FOR i IN 1..p_worksheet_tbl.COUNT
  LOOP
    --
    -- API to add line to the current worksheet only.
    --
    PSB_WS_Pos_Pvt.Create_Position_Matrix
    (
       p_api_version        =>  1.0 ,
       p_init_msg_list      =>  FND_API.G_FALSE ,
       p_validation_level   =>  FND_API.G_VALID_LEVEL_NONE ,
       p_return_status      =>  l_return_status ,
       p_msg_count          =>  l_msg_count ,
       p_msg_data           =>  l_msg_data ,
       --
       p_worksheet_id       =>  p_worksheet_tbl(i) ,
       p_position_line_id   =>  p_position_line_id ,
       p_freeze_flag        =>  l_ws_lines_positions_row_type.freeze_flag ,
       p_view_line_flag     =>  l_ws_lines_positions_row_type.view_line_flag
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP;

  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Add_Pos_Line_To_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Add_Pos_Line_To_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Add_Pos_Line_To_Worksheets_Pvt ;
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
END Add_Pos_Line_To_Worksheets ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Freeze_Worksheet                          |
 +===========================================================================*/
--
-- This API freezes a given worksheet.
--
PROCEDURE Freeze_Worksheet
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
  p_freeze_flag               IN       psb_ws_lines.freeze_flag%TYPE
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)  := 'Freeze_Worksheet' ;
  l_api_version             CONSTANT NUMBER        :=  1.0 ;
  --
  l_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_parent_worksheet_id     psb_worksheets.worksheet_id%TYPE ;
  l_parent_freeze_flag      psb_worksheets.freeze_flag%TYPE ;
  l_worksheet_type          VARCHAR2(1);
  --

  -- bug start 3970347
  l_global_worksheet_flag	psb_worksheets.global_worksheet_flag%TYPE;
  l_gl_cutoff_period		psb_worksheets.gl_cutoff_period%TYPE := NULL;
  -- bug end   3970347

BEGIN
  --
  SAVEPOINT Freeze_Worksheet_Pvt ;
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
  /* Bug 3664027 Start */
  -- A worksheet(other than local worksheet) can only be unfrozen
  -- if the parent worksheet is not frozen, if exists( p_freeze_flag = 'N'
  -- identifies an unfreeze operation). Local worksheet can be
  -- freezed/unfreezed without any check since it has no relation
  -- with the parent worksheet.
  --

  SELECT NVL(worksheet_type, '9'),
  -- bug start 3970347
  -- get the global worksheet flag from psb_worksheet table
         global_worksheet_flag
  -- bug end 3970347
  INTO l_worksheet_type,
  -- bug start 3970347
       l_global_worksheet_flag
  -- bug end 3970347
  FROM psb_worksheets
  WHERE worksheet_id = p_worksheet_id;

  IF p_freeze_flag = 'N' AND l_worksheet_type <> 'L' THEN
  /* Bug 3664027 End */

    -- Find parent worksheet, if exists.
    PSB_WS_Ops_Pvt.Find_Parent_Worksheet
    (
      p_api_version             => 1.0 ,
      p_init_msg_list           => FND_API.G_FALSE,
      p_commit                  => FND_API.G_FALSE,
      p_validation_level        => FND_API.G_VALID_LEVEL_NONE,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data ,
      --
      p_worksheet_id            => p_worksheet_id ,
      p_worksheet_id_OUT        => l_parent_worksheet_id
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Check the freeze_flag for the parent worksheet.
    IF l_parent_worksheet_id <> 0 THEN

      SELECT NVL(freeze_flag, 'N') INTO l_parent_freeze_flag
      FROM   psb_worksheets
      WHERE  worksheet_id = l_parent_worksheet_id ;

      IF l_parent_freeze_flag = 'Y' THEN

	Fnd_Message.Set_Name('PSB','PSB_CANNOT_UNFREEZE_WORKSHEET') ;
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR ;

      END IF ;

    END IF ;

  END IF ;
  -- End validating the parent worksheet for unfreeze operation.

  --
  -- Update freeze_flag in psb_worksheets.
  --

  /* bug start 3970347 */
  -- check if the worksheet is global worksheet. If global, then
  -- pass the gl cutoff date otherwise pass null
  IF l_global_worksheet_flag = 'Y' THEN
    FOR l_gl_cutoff_period_rec IN (SELECT gl_cutoff_period
    						   FROM   psb_worksheets
    						   WHERE  worksheet_id = p_worksheet_id)
    LOOP
      l_gl_cutoff_period := l_gl_cutoff_period_rec.gl_cutoff_period;
    END LOOP;
  END IF;
  /* bug end 3970347 */

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
     p_worksheet_id                => p_worksheet_id ,
     p_freeze_flag                 => p_freeze_flag ,
     -- bug start 3970347
     -- pass the gl cutoff period to the update_worksheet API
     p_gl_cutoff_period 		   => l_gl_cutoff_period
     -- bug end 3970347
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --


  -- Update freeze_flag in psb_ws_lines.
  UPDATE psb_ws_lines
  SET    freeze_flag  = p_freeze_flag
  WHERE  worksheet_id = p_worksheet_id;


  -- Get position budgeting flag.
  SELECT NVL(budget_by_position, 'N')  INTO l_budget_by_position
  FROM   psb_worksheets
  WHERE  worksheet_id = p_worksheet_id ;


  IF l_budget_by_position = 'Y' THEN
    --
    -- Update freeze_flag in psb_ws_lines_positions.
    --
    UPDATE psb_ws_lines_positions
    SET    freeze_flag  = p_freeze_flag
    WHERE  worksheet_id = p_worksheet_id;
    --
  END IF;

  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Freeze_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Freeze_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Freeze_Worksheet_Pvt ;
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
END Freeze_Worksheet ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Change_Worksheet_Stage                    |
 +===========================================================================*/
--
-- This API moves a worksheet to its next stage (version).
--
PROCEDURE Change_Worksheet_Stage
(
  p_api_version           IN           NUMBER   ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status         OUT  NOCOPY  VARCHAR2 ,
  p_msg_count             OUT  NOCOPY  NUMBER   ,
  p_msg_data              OUT  NOCOPY  VARCHAR2 ,
  --
  p_worksheet_id          IN           psb_worksheets.worksheet_id%TYPE  ,
  p_stage_seq             IN           psb_worksheets.current_stage_seq%TYPE
				       := FND_API.G_MISS_NUM ,
  p_operation_id          IN           NUMBER := FND_API.G_MISS_NUM
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Change_Worksheet_Stage' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER      ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_stage_set_id            psb_worksheets.stage_set_id%TYPE ;
  l_target_stage_seq        psb_worksheets.current_stage_seq%TYPE ;
  l_current_stage_seq       psb_worksheets.current_stage_seq%TYPE ;
  l_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_service_package_count   NUMBER ;
  --

  -- bug start 3970347
  l_global_worksheet_flag	psb_worksheets.global_worksheet_flag%TYPE;
  l_gl_cutoff_period		psb_worksheets.gl_cutoff_period%TYPE;
  -- bug end 3970347

BEGIN
  --
  SAVEPOINT Change_Worksheet_Stage_Pvt ;
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

  -- Get position budgeting flag.

  SELECT NVL( budget_by_position, 'N') ,
  /* bug start 3970347 */
  -- get the global worksheet flag from psb_worksheets table
         global_worksheet_flag
  /* bug end 3970347 */
  INTO l_budget_by_position ,
  /* bug start 3970347 */
       l_global_worksheet_flag
  /* bug end 3970347 */
  FROM   psb_worksheets
  WHERE  worksheet_id = p_worksheet_id ;

  IF ( p_stage_seq = FND_API.G_MISS_NUM ) OR ( p_stage_seq IS NULL) THEN

    --
    -- Find next stage_id for the worksheet.
    --
    SELECT stage_set_id                  ,
	   current_stage_seq
       INTO
	   l_stage_set_id                ,
	   l_current_stage_seq
    FROM   psb_worksheets
    WHERE  worksheet_id = p_worksheet_id ;

    SELECT MIN (sequence_number) INTO l_target_stage_seq
    FROM   psb_budget_stages
    WHERE  budget_stage_set_id = l_stage_set_id
    AND    sequence_number     > l_current_stage_seq
    ORDER  BY sequence_number ;

  ELSE
    l_target_stage_seq := p_stage_seq ;
  END IF ;

  --
  -- If l_target_stage_seq is NULL means the worksheet is already at
  -- its highest stage. Simply return back.
  --
  IF l_target_stage_seq IS NULL THEN
    RETURN ;
  END IF ;

  --
  -- Updating the psb_worksheets.
  --

  /* bug start 3970347 */
  -- check if the worksheet is global worksheet. If global, then
  -- pass the gl cutoff date.
  IF l_global_worksheet_flag = 'Y' THEN
    FOR l_gl_cutoff_period_rec IN (SELECT gl_cutoff_period
    						   FROM   psb_worksheets
    						   WHERE  worksheet_id = p_worksheet_id)
    LOOP
      l_gl_cutoff_period := l_gl_cutoff_period_rec.gl_cutoff_period;
    END LOOP;
  END IF;
  /* bug end 3970347 */

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
    p_worksheet_id          => p_worksheet_id,
    p_current_stage_seq     => l_target_stage_seq ,
    -- bug start 3970347
    p_gl_cutoff_period 		=> l_gl_cutoff_period
    -- bug end 3970347
  ) ;
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Check whether service packages were selected for the worksheet.
  -- If yes, then we need to move only those account lines which are
  -- related to the service package selection.
  --
  SELECT COUNT(*) INTO l_service_package_count
  FROM   dual
  WHERE  EXISTS
         ( SELECT 1
           FROM   psb_ws_submit_service_packages
           WHERE  worksheet_id = p_worksheet_id
           AND    operation_id = p_operation_id ) ;

  IF l_service_package_count = 0 THEN

    --
    -- Update all the lines in psb_ws_account_lines as no service package
    -- selection exists.
    --
    UPDATE psb_ws_account_lines
    SET    current_stage_seq = l_target_stage_seq
    WHERE  l_target_stage_seq > current_stage_seq
    AND    end_stage_seq is null
    AND    account_line_id IN
			 ( SELECT account_line_id
			   FROM   psb_ws_lines
			   WHERE  worksheet_id = p_worksheet_id ) ;

    IF l_budget_by_position = 'Y' THEN
      --
      -- Update all the lines in psb_ws_fte_lines as no service package
      -- selection exists.
      --
      UPDATE psb_ws_fte_lines
      SET    current_stage_seq = l_target_stage_seq
      WHERE  l_target_stage_seq > current_stage_seq
      AND    end_stage_seq is null
      AND    position_line_id IN
		       ( SELECT position_line_id
			 FROM   psb_ws_lines_positions
			 WHERE  worksheet_id = p_worksheet_id ) ;

      --
      -- Update all the lines in psb_ws_element_lines as no service package
      -- selection exists.
      --
      UPDATE psb_ws_element_lines
      SET    current_stage_seq = l_target_stage_seq
      WHERE  l_target_stage_seq > current_stage_seq
      AND    end_stage_seq is null
      AND    position_line_id IN
		       ( SELECT position_line_id
			 FROM   psb_ws_lines_positions
			 WHERE  worksheet_id = p_worksheet_id ) ;
      --
    END IF;

  ELSE

    --
    -- Update psb_ws_account_lines as per the service package selection.
    --
    UPDATE psb_ws_account_lines
    SET    current_stage_seq = l_target_stage_seq
    WHERE  l_target_stage_seq > current_stage_seq
    AND    end_stage_seq is null
    AND    account_line_id IN
		     (  SELECT account_line_id
			FROM   psb_ws_lines
			WHERE  worksheet_id = p_worksheet_id
		      )
    AND    service_package_id IN
		     (  SELECT service_package_id
			FROM   psb_ws_submit_service_packages
			WHERE  worksheet_id = p_worksheet_id
			AND    operation_id = p_operation_id
		      ) ;
    --
    IF l_budget_by_position = 'Y' THEN

      --
      -- Update psb_ws_fte_lines as per the service package selection.
      --
      UPDATE psb_ws_fte_lines
      SET    current_stage_seq = l_target_stage_seq
      WHERE  l_target_stage_seq > current_stage_seq
      AND    end_stage_seq is null
      AND    position_line_id IN
		       (  SELECT position_line_id
			  FROM   psb_ws_lines_positions
			  WHERE  worksheet_id = p_worksheet_id
			)
      AND    service_package_id IN
		       (  SELECT service_package_id
			  FROM   psb_ws_submit_service_packages
			  WHERE  worksheet_id = p_worksheet_id
			  AND    operation_id = p_operation_id
			) ;

      --
      -- Update psb_ws_element_lines as per the service package selection.
      --
      UPDATE psb_ws_element_lines
      SET    current_stage_seq = l_target_stage_seq
      WHERE  l_target_stage_seq > current_stage_seq
      AND    end_stage_seq is null
      AND    position_line_id IN
		       (  SELECT position_line_id
			  FROM   psb_ws_lines_positions
			  WHERE  worksheet_id = p_worksheet_id
			)
      AND    service_package_id IN
		       (  SELECT service_package_id
			  FROM   psb_ws_submit_service_packages
			  WHERE  worksheet_id = p_worksheet_id
			  AND    operation_id = p_operation_id
			) ;
      --
    END IF;
    --
  END IF ;

  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Change_Worksheet_Stage_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Change_Worksheet_Stage_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Change_Worksheet_Stage_Pvt ;
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
END Change_Worksheet_Stage ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Find_Parent_Worksheet                         |
 +===========================================================================*/
--
-- The API finds parent worksheet of a given worksheet.
--
PROCEDURE Find_Parent_Worksheet
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
  p_worksheet_id_OUT          OUT  NOCOPY      psb_worksheets.worksheet_id%TYPE
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30) := 'Find_Parent_Worksheet' ;
  l_api_version               CONSTANT NUMBER       :=  1.0 ;
  l_return_status             VARCHAR2(1) ;
  l_msg_count                 NUMBER      ;
  l_msg_data                  VARCHAR2(2000) ;
  --
  l_global_worksheet_id       psb_worksheets.global_worksheet_id%TYPE ;
  l_global_worksheet_flag     psb_worksheets.global_worksheet_flag%TYPE ;
  l_budget_group_id           psb_worksheets.budget_group_id%TYPE ;
  l_global_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  --
  l_parent_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  --
BEGIN
  --
  SAVEPOINT Find_Parent_Worksheet_Pvt ;
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
  p_return_status    := FND_API.G_RET_STS_SUCCESS ;
  p_worksheet_id_OUT := -99 ;
  --

  --
  -- Finding the worksheet information.
  --
  SELECT ws.budget_group_id         ,
	 ws.global_worksheet_id     ,
	 ws.global_worksheet_flag   ,
	 bg.parent_budget_group_id
      INTO
	 l_budget_group_id          ,
	 l_global_worksheet_id      ,
	 l_global_worksheet_flag    ,
	 l_parent_budget_group_id
  FROM   psb_worksheets    ws,
	 psb_budget_groups bg
  WHERE  ws.worksheet_id    = p_worksheet_id
  AND    ws.budget_group_id = bg.budget_group_id ;

  IF (l_global_worksheet_flag = 'Y') OR (l_parent_budget_group_id IS NULL) THEN
    --
/*  Commenting as this message is not required. The p_worksheet_id_OUT
    parameter should be used to determine whether parent worksheet exists.

    Fnd_Message.Set_Name('PSB','PSB_NO_PARENT_WORKSHEET' ) ;
    FND_MSG_PUB.Add;
*/
    p_worksheet_id_OUT := 0 ;
    RETURN ;
  END IF ;

  --
  -- Find global budget_group_id for the global worksheet.
  --
  SELECT budget_group_id INTO l_global_budget_group_id
  FROM   psb_worksheets
  WHERE  worksheet_id = l_global_worksheet_id ;

  --
  -- If parent budget group for the current worksheet is same as the budget
  -- group for the global worksheet, then the global worksheet is the parent
  -- worksheet for the given worksheet.
  --
  IF l_global_budget_group_id = l_parent_budget_group_id THEN
    p_worksheet_id_OUT := l_global_worksheet_id ;
    RETURN ;
  END IF ;


  --
  -- Get the desired parent worksheet at the l_parent_budget_group_id level.
  --
  BEGIN

    --
    -- New way to find if a worksheet has been created for a budget group.
    -- ( Bug#2832148 )
    --
    SELECT worksheet_id INTO p_worksheet_id_OUT
    FROM   psb_worksheets
    WHERE  global_worksheet_id = l_global_worksheet_id
    AND    budget_group_id     = l_parent_budget_group_id
    AND    worksheet_type      = 'O' ;

    /*
    SELECT DISTINCT child_worksheet_id
      INTO p_worksheet_id_OUT
      FROM psb_ws_distribution_details details, psb_ws_distributions distr
     WHERE distr.worksheet_id = details.worksheet_id
    -- Bug No 2297742 Start
    --    AND    distr.distribution_option_flag   = 'W'
       AND nvl(distr.distribution_option_flag, 'W') = 'W'
    -- Bug No 2297742 End
       AND global_worksheet_id = l_global_worksheet_id
       AND child_budget_group_id = l_parent_budget_group_id;
    */
    --
  EXCEPTION
    WHEN no_data_found THEN
      --
      -- Cannot use FND_API.G_MISS_NUM as worksheet_id is NUMBER(20) only.
      --
      p_worksheet_id_OUT := 0 ;
    --
  END ;

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
    ROLLBACK TO Find_Parent_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Find_Parent_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Find_Parent_Worksheet_Pvt ;
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
END Find_Parent_Worksheet ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Find_Parent_Worksheets                        |
 +===========================================================================*/
--
-- The API finds parent worksheets of a given worksheet in a PL/SQL table.
--
PROCEDURE Find_Parent_Worksheets
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
  p_worksheet_tbl             IN OUT  NOCOPY   Worksheet_Tbl_Type
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30) := 'Find_Parent_Worksheets';
  l_api_version               CONSTANT NUMBER       :=  1.0 ;
  l_return_status             VARCHAR2(1) ;
  l_msg_count                 NUMBER      ;
  l_msg_data                  VARCHAR2(2000) ;
  --
  l_current_worksheet_id      psb_worksheets.global_worksheet_id%TYPE ;
  l_parent_worksheet_id       psb_worksheets.global_worksheet_id%TYPE ;
  --
  l_count                     NUMBER ;
  --
BEGIN
  --
  SAVEPOINT Find_Parent_Worksheets_Pvt ;
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

  --
  -- Perform initialization
  --
  l_count := 0 ;
  p_worksheet_tbl.DELETE ;
  l_current_worksheet_id := p_worksheet_id ;

  LOOP
    --
    -- Find the parent worksheet for the current worksheet.
    --
    PSB_WS_Ops_Pvt.Find_Parent_Worksheet
    (
       p_api_version             =>   1.0 ,
       p_init_msg_list           =>   FND_API.G_FALSE,
       p_commit                  =>   FND_API.G_FALSE,
       p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status           =>   l_return_status,
       p_msg_count               =>   l_msg_count,
       p_msg_data                =>   l_msg_data,
       --
       p_worksheet_id            =>   l_current_worksheet_id ,
       p_worksheet_id_OUT        =>   l_parent_worksheet_id
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
    IF l_parent_worksheet_id = 0 THEN

      -- It means all the parent worksheets has been retrieved.
      EXIT ;
      --
    ELSE
      --
      -- Insert the worksheet in the table.
      --
      l_count                  := l_count + 1 ;
      p_worksheet_tbl(l_count) := l_parent_worksheet_id ;
      l_current_worksheet_id   := l_parent_worksheet_id ;
    END IF ;
    --
  END LOOP ;

  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Find_Parent_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Find_Parent_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Find_Parent_Worksheets_Pvt ;
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
END Find_Parent_Worksheets ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Find_Child_Worksheets                         |
 +===========================================================================*/
--
-- The API finds all the child worksheets of a worksheet in a PL/SQL table.
--
PROCEDURE Find_Child_Worksheets
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
  p_worksheet_tbl             IN OUT  NOCOPY   Worksheet_Tbl_Type
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30) := 'Find_Child_Worksheets';
  l_api_version               CONSTANT NUMBER       :=  1.0 ;
  l_return_status             VARCHAR2(1) ;
  l_msg_count                 NUMBER      ;
  l_msg_data                  VARCHAR2(2000) ;
  --
  l_child_worksheet_id        psb_worksheets.global_worksheet_id%TYPE ;
  l_global_worksheet_id       psb_worksheets.global_worksheet_id%TYPE ;
  l_global_worksheet_flag     psb_worksheets.global_worksheet_flag%TYPE ;
  l_budget_group_id           psb_worksheets.budget_group_id%TYPE ;
  l_budget_calendar_id        psb_worksheets.budget_calendar_id%TYPE ;
  --
  l_count                     NUMBER ;
  --
BEGIN
  --
  SAVEPOINT Find_Child_Worksheets_Pvt ;
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

  --
  -- Perform initialization
  --
  l_count := 0 ;
  p_worksheet_tbl.DELETE ;
  --

  --
  -- Get worksheet information for the p_worksheet_id .
  --
  SELECT budget_group_id                       ,
	 budget_calendar_id                    ,
	 global_worksheet_id                   ,
	 NVL( global_worksheet_flag ,  'N' )
    INTO
	 l_budget_group_id                     ,
	 l_budget_calendar_id                  ,
	 l_global_worksheet_id                 ,
	 l_global_worksheet_flag
  FROM   psb_worksheets
  WHERE  worksheet_id = p_worksheet_id ;

  IF l_global_worksheet_flag = 'Y' THEN
    l_global_worksheet_id := p_worksheet_id ;
  END IF ;

  --
  -- Use budget calendar related info to find all the budget groups down
  -- in the current hierarchy .
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
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  l_count  := 0 ;

  --
  -- Porcess all the lower level budget groups to fine worksheets.
  --
  FOR l_budget_group_rec IN
  (
     SELECT budget_group_id
       FROM psb_budget_groups
      WHERE budget_group_type          = 'R'
	AND effective_start_date       <= PSB_WS_Acct1.g_startdate_pp
	AND ((effective_end_date IS NULL)
	      OR
	     (effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
     START WITH budget_group_id       = l_budget_group_id
     CONNECT BY PRIOR budget_group_id = parent_budget_group_id
  )
  LOOP

    --
    -- The hierarchial query will also return the l_budget_group_id.
    -- Do not consider it.
    --
    IF l_budget_group_rec.budget_group_id <> l_budget_group_id THEN

      l_child_worksheet_id := NULL ;

      --
      -- Get the worksheet_id at the current budget_group_level.
      --
      BEGIN

        --
        -- New way to find if a worksheet has been created for a budget group.
        -- ( Bug#2832148 )
        --
        SELECT worksheet_id INTO l_child_worksheet_id
        FROM   psb_worksheets
        WHERE  global_worksheet_id = l_global_worksheet_id
        AND    budget_group_id     = l_budget_group_rec.budget_group_id
        AND    worksheet_type      = 'O' ;

        /*
	SELECT child_worksheet_id
	  INTO l_child_worksheet_id
	FROM psb_ws_distribution_details details, psb_ws_distributions distr
	WHERE distr.worksheet_id = details.worksheet_id
             -- Bug No 2297742 Start
        --    AND    distr.distribution_option_flag   = 'W'
	   AND nvl(distr.distribution_option_flag, 'W') = 'W'
        -- Bug No 2297742 End
	   AND global_worksheet_id = l_global_worksheet_id
	   AND child_budget_group_id = l_budget_group_rec.budget_group_id
	   AND ROWNUM < 2 ;
        */

      EXCEPTION
	WHEN no_data_found THEN
	  --
	  -- Means the worksheet has not been distributed to this level.
	  -- Simply ignore it.
	  --
	  NULL ;
      END ;

      --
      -- Insert the worksheet in the p_worksheet_tbl table
      --
      IF l_child_worksheet_id IS NOT NULL THEN
	l_count := l_count + 1 ;
	p_worksheet_tbl( l_count ) := l_child_worksheet_id ;
      END IF ;

    END IF ;

  END LOOP ;

  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Find_Child_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Find_Child_Worksheets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Find_Child_Worksheets_Pvt ;
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
END Find_Child_Worksheets ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Update_Worksheet                            |
 +===========================================================================*/
--
-- The API takes 2 worksheets, source and target. It updates target worksheet
-- by adding new account or position lines if they are their in the source
-- worksheet and not in the target worksheet. It also updates the worksheet
-- submission related columns in the source worksheet.
--
PROCEDURE Update_Worksheet
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_source_worksheet_id       IN       psb_worksheets.worksheet_id%TYPE  ,
  p_target_worksheet_id       IN       psb_worksheets.worksheet_id%TYPE
)
IS
  --
  l_api_name                     CONSTANT VARCHAR2(30) := 'Update_Worksheet' ;
  l_api_version                  CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status                VARCHAR2(1) ;
  l_msg_count                    NUMBER ;
  l_msg_data                     VARCHAR2(2000) ;
  --
  l_source_budget_group_id       psb_worksheets.budget_group_id%TYPE ;
  l_source_local_copy_flag       psb_worksheets.local_copy_flag%TYPE ;
  l_source_global_worksheet_id   psb_worksheets.worksheet_id%TYPE ;
  l_source_global_worksheet_flag psb_worksheets.global_worksheet_flag%TYPE ;
  l_source_budget_by_position    psb_worksheets.budget_by_position%TYPE ;
  --
  l_target_budget_group_id       psb_worksheets.budget_group_id%TYPE ;
  l_target_local_copy_flag       psb_worksheets.local_copy_flag%TYPE ;
  l_target_global_worksheet_id   psb_worksheets.worksheet_id%TYPE ;
  --
  l_budget_calendar_id           psb_worksheets.budget_calendar_id%TYPE ;
  l_ws_lines_rec                 psb_ws_lines%ROWTYPE ;
  l_ws_lines_positions_rec       psb_ws_lines_positions%ROWTYPE ;
/* Bug No 2378285 Start */
  l_gl_cutoff_period             DATE;
/* Bug No 2378285 End */

BEGIN
  --
  SAVEPOINT Update_Worksheet_Pvt ;
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

  --
  -- Find the source worksheet information.
  --
  SELECT budget_group_id                      ,
	 global_worksheet_id                  ,
	 NVL( global_worksheet_flag ,  'N' )  ,
	 NVL( local_copy_flag ,        'N' )  ,
	 NVL( budget_by_position ,     'N' ),
/* Bug No 2378285 Start */
	 gl_cutoff_period
/* Bug No 2378285 End */
       INTO
	 l_source_budget_group_id             ,
	 l_source_global_worksheet_id         ,
	 l_source_global_worksheet_flag       ,
	 l_source_local_copy_flag             ,
	 l_source_budget_by_position,
/* Bug No 2378285 Start */
	 l_gl_cutoff_period
/* Bug No 2378285 End */
  FROM   psb_worksheets
  WHERE  worksheet_id = p_source_worksheet_id ;

  IF l_source_global_worksheet_flag = 'Y' THEN
    l_source_global_worksheet_id := p_source_worksheet_id ;
  END IF ;

/* Bug No 2378285 Start */
-- Moved the 'update_worksheet' after the select statement
-- and added gl_cutoff_period as another input parameter

  --
  -- Update worksheet submission related columns in the target worksheet.
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
     p_worksheet_id                => p_target_worksheet_id ,
     p_gl_cutoff_period            => l_gl_cutoff_period,
     p_date_submitted              => NULL ,
     p_submitted_by                => NULL
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

/* Bug No 2378285 End */

  --
  -- Find the target worksheet information. The target worksheet will
  -- never be the top worksheet i.e. global_worksheet_flag is always 'N'.
  --
  SELECT budget_group_id         ,
	 global_worksheet_id     ,
	 NVL( local_copy_flag ,  'N' )
      INTO
	 l_target_budget_group_id    ,
	 l_target_global_worksheet_id       ,
	 l_target_local_copy_flag
  FROM   psb_worksheets
  WHERE  worksheet_id = p_target_worksheet_id ;

  --
  -- The source and target worksheet must be part of same global worksheet.
  -- Both should be non-global worksheets also.
  --
  IF NOT (
	   (l_source_local_copy_flag='N') AND ( l_target_local_copy_flag='N')
	   AND ( l_source_global_worksheet_id = l_target_global_worksheet_id )
	  )
  THEN
    Fnd_Message.Set_Name ('PSB', 'PSB_INCOMPATIBLE_WORKSHEETS') ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  --
  -- Get budget calendar for the global worksheet.
  --
  SELECT budget_calendar_id INTO l_budget_calendar_id
  FROM   psb_worksheets
  WHERE  worksheet_id = l_source_global_worksheet_id ;

  --
  -- Get budget calendar related info to find all the budget groups down in
  -- the current hierarchy to get all the CCIDs for the current budget group.
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
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  --
  -- Find account_line_id to be inserted into target worksheet.
  -- ( The hierarchial query will select lines falling in the subtreee, the
  --   target worksheet belongs. We will not consider other lines. )
  --
  FOR l_account_line_id_rec IN
  (
     SELECT lines.account_line_id
     FROM   psb_ws_lines         lines ,
	    psb_ws_account_lines accts
     WHERE  lines.worksheet_id    = p_source_worksheet_id
     AND    lines.account_line_id = accts.account_line_id
     /*For Bug No : 2236283 Start*/
     /*
     AND    accts.budget_group_id  IN
	       (  SELECT budget_group_id
		    FROM psb_budget_groups
		   WHERE budget_group_type = 'R'
		     AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
		     AND ((effective_end_date IS NULL)
			   OR
			  (effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
		  START WITH budget_group_id       = l_target_budget_group_id
		  CONNECT BY PRIOR budget_group_id = parent_budget_group_id
	       )
     */
     AND EXISTS
	       (  SELECT 1
		    FROM psb_budget_groups
		   WHERE budget_group_type = 'R'
		     AND budget_group_id = accts.budget_group_id
		     AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
		     AND ((effective_end_date IS NULL)
			   OR
			  (effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
		  START WITH budget_group_id       = l_target_budget_group_id
		  CONNECT BY PRIOR budget_group_id = parent_budget_group_id
	       )
     /*For Bug No : 2236283 End*/
     MINUS
     SELECT lines.account_line_id
     FROM   psb_ws_lines lines
     WHERE  worksheet_id = p_target_worksheet_id
  )
  LOOP

    SELECT * INTO l_ws_lines_rec
    FROM   psb_ws_lines
    WHERE  worksheet_id    = p_source_worksheet_id
    AND    account_line_id = l_account_line_id_rec.account_line_id ;

    --
    -- Each account_line_id found is the account_line_id missing in the
    -- target worksheet. Add the account_line_id to the target worksheet.
    --
    Insert_WS_Lines_Pvt
    (
       p_worksheet_id       =>  p_target_worksheet_id,
       p_account_line_id    =>  l_ws_lines_rec.account_line_id ,
       p_freeze_flag        =>  l_ws_lines_rec.freeze_flag ,
       p_view_line_flag     =>  l_ws_lines_rec.view_line_flag ,
       p_last_update_date   =>  g_current_date,
       p_last_updated_by    =>  g_current_user_id,
       p_last_update_login  =>  g_current_login_id,
       p_created_by         =>  g_current_user_id,
       p_creation_date      =>  g_current_date,
       p_return_status      =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP ;

  --
  -- Find position_line_id to be inserted into target worksheet.
  -- ( The hierarchial query will select lines falling in the sub-tree,
  --   the target worksheet belongs. We will not consider other lines. )
  --
  IF l_source_budget_by_position = 'Y' THEN
    --
    FOR l_lines_pos_rec IN
    (
       SELECT lines.position_line_id
       FROM   psb_ws_lines_positions lines ,
	      psb_ws_position_lines  pos
       WHERE  lines.worksheet_id     = p_source_worksheet_id
       AND    lines.position_line_id = pos.position_line_id
       /*For Bug No : 2236283 Start*/
       /*
       AND    lines.position_line_id IN
	      (
		SELECT acct_lines.position_line_id
		FROM   psb_ws_account_lines acct_lines
		WHERE  acct_lines.budget_group_id IN
		       (
			 SELECT bg.budget_group_id
			   FROM psb_budget_groups bg
			  WHERE bg.budget_group_type = 'R'
			    AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
			    AND ((effective_end_date IS NULL)
				  OR
				 (effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
			 START WITH bg.budget_group_id = l_target_budget_group_id
			 CONNECT BY PRIOR bg.budget_group_id = bg.parent_budget_group_id
		       )
	      )
       */
       AND    EXISTS
	      (
		SELECT 1
		  FROM psb_ws_account_lines acct_lines
		 WHERE acct_lines.position_line_id = lines.position_line_id
		   AND EXISTS
		       (
			 SELECT 1
			   FROM psb_budget_groups bg
			  WHERE bg.budget_group_type = 'R'
			    AND bg.budget_group_id = acct_lines.budget_group_id
			    AND effective_start_date <= PSB_WS_Acct1.g_startdate_pp
			    AND ((effective_end_date IS NULL)
				  OR
				 (effective_end_date >= PSB_WS_Acct1.g_enddate_cy))
			 START WITH bg.budget_group_id = l_target_budget_group_id
			 CONNECT BY PRIOR bg.budget_group_id = bg.parent_budget_group_id
		       )
	      )
       /*For Bug No : 2236283 End*/
       MINUS
       SELECT position_line_id
       FROM   psb_ws_lines_positions
       WHERE  worksheet_id = p_target_worksheet_id
    )
    LOOP

      SELECT * INTO l_ws_lines_positions_rec
      FROM   psb_ws_lines_positions
      WHERE  worksheet_id     = p_source_worksheet_id
      AND    position_line_id = l_lines_pos_rec.position_line_id ;

      --
      -- Each position_line_id found is the one missing in the target
      -- worksheet. Add it to the target worksheet.
      --
      PSB_WS_Pos_Pvt.Create_Position_Matrix
      (
	 p_api_version        =>  1.0 ,
	 p_init_msg_list      =>  FND_API.G_FALSE ,
	 p_validation_level   =>  FND_API.G_VALID_LEVEL_NONE ,
	 p_return_status      =>  l_return_status ,
	 p_msg_count          =>  l_msg_count ,
	 p_msg_data           =>  l_msg_data ,
	 --
	 p_worksheet_id       =>  p_target_worksheet_id ,
	 p_position_line_id   =>  l_ws_lines_positions_rec.position_line_id ,
	 p_freeze_flag        =>  l_ws_lines_positions_rec.freeze_flag ,
	 p_view_line_flag     =>  l_ws_lines_positions_rec.view_line_flag
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END LOOP ;

  END IF ;

  --
  IF  FND_API.To_Boolean ( p_commit ) THEN
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
    ROLLBACK TO Update_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Update_Worksheet_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Update_Worksheet_Pvt ;
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
END Update_Worksheet ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |               PROCEDURE Create_Local_Dist_Pvt (Private)                   |
 +===========================================================================*/
--
-- Private procedure to print debug info. The name is tried to keep as
-- short as possible for better documentaion.
--
PROCEDURE Create_Local_Dist_Pvt
(
  p_account_line_id        IN   psb_ws_lines.account_line_id%TYPE            ,
  p_new_worksheet_id       IN   psb_worksheets.worksheet_id%TYPE             ,
  p_new_position_line_id   IN   psb_ws_lines_positions.position_line_id%TYPE ,
  p_return_status          OUT  NOCOPY  VARCHAR2
 )
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Local_Dist' ;
  --
  l_return_status             VARCHAR2(1) ;
  l_msg_count                 NUMBER ;
  l_msg_data                  VARCHAR2(2000) ;
  --
  l_dummy_account_line_id       psb_ws_account_lines.account_line_id%TYPE ;
  l_period_amount_tbl         PSB_WS_Acct1.g_prdamt_tbl_type ;
  --
BEGIN

  SAVEPOINT Create_Local_Dist_Pvt ;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  FOR l_accts_rec IN
  (
     SELECT *
     FROM   psb_ws_account_lines
     WHERE  account_line_id  = p_account_line_id
  )
  LOOP
    --
    -- Populate the l_period_amount_tbl ( used by PSB_WS_Acct1 API )
    --
    l_period_amount_tbl(1)  := l_accts_rec.period1_amount ;
    l_period_amount_tbl(2)  := l_accts_rec.period2_amount ;
    l_period_amount_tbl(3)  := l_accts_rec.period3_amount ;
    l_period_amount_tbl(4)  := l_accts_rec.period4_amount ;
    l_period_amount_tbl(5)  := l_accts_rec.period5_amount ;
    l_period_amount_tbl(6)  := l_accts_rec.period6_amount ;
    l_period_amount_tbl(7)  := l_accts_rec.period7_amount ;
    l_period_amount_tbl(8)  := l_accts_rec.period8_amount ;
    l_period_amount_tbl(9)  := l_accts_rec.period9_amount ;
    l_period_amount_tbl(10) := l_accts_rec.period10_amount ;
    l_period_amount_tbl(11) := l_accts_rec.period11_amount ;
    l_period_amount_tbl(12) := l_accts_rec.period12_amount ;
    l_period_amount_tbl(13) := l_accts_rec.period13_amount ;
    l_period_amount_tbl(14) := l_accts_rec.period14_amount ;
    l_period_amount_tbl(15) := l_accts_rec.period15_amount ;
    l_period_amount_tbl(16) := l_accts_rec.period16_amount ;
    l_period_amount_tbl(17) := l_accts_rec.period17_amount ;
    l_period_amount_tbl(18) := l_accts_rec.period18_amount ;
    l_period_amount_tbl(19) := l_accts_rec.period19_amount ;
    l_period_amount_tbl(20) := l_accts_rec.period20_amount ;
    l_period_amount_tbl(21) := l_accts_rec.period21_amount ;
    l_period_amount_tbl(22) := l_accts_rec.period22_amount ;
    l_period_amount_tbl(23) := l_accts_rec.period23_amount ;
    l_period_amount_tbl(24) := l_accts_rec.period24_amount ;
    l_period_amount_tbl(25) := l_accts_rec.period25_amount ;
    l_period_amount_tbl(26) := l_accts_rec.period26_amount ;
    l_period_amount_tbl(27) := l_accts_rec.period27_amount ;
    l_period_amount_tbl(28) := l_accts_rec.period28_amount ;
    l_period_amount_tbl(29) := l_accts_rec.period29_amount ;
    l_period_amount_tbl(30) := l_accts_rec.period30_amount ;
    l_period_amount_tbl(31) := l_accts_rec.period31_amount ;
    l_period_amount_tbl(32) := l_accts_rec.period32_amount ;
    l_period_amount_tbl(33) := l_accts_rec.period33_amount ;
    l_period_amount_tbl(34) := l_accts_rec.period34_amount ;
    l_period_amount_tbl(35) := l_accts_rec.period35_amount ;
    l_period_amount_tbl(36) := l_accts_rec.period36_amount ;
    l_period_amount_tbl(37) := l_accts_rec.period37_amount ;
    l_period_amount_tbl(38) := l_accts_rec.period38_amount ;
    l_period_amount_tbl(39) := l_accts_rec.period39_amount ;
    l_period_amount_tbl(40) := l_accts_rec.period40_amount ;
    l_period_amount_tbl(41) := l_accts_rec.period41_amount ;
    l_period_amount_tbl(42) := l_accts_rec.period42_amount ;
    l_period_amount_tbl(43) := l_accts_rec.period43_amount ;
    l_period_amount_tbl(44) := l_accts_rec.period44_amount ;
    l_period_amount_tbl(45) := l_accts_rec.period45_amount ;
    l_period_amount_tbl(46) := l_accts_rec.period46_amount ;
    l_period_amount_tbl(47) := l_accts_rec.period47_amount ;
    l_period_amount_tbl(48) := l_accts_rec.period48_amount ;
    l_period_amount_tbl(49) := l_accts_rec.period49_amount ;
    l_period_amount_tbl(50) := l_accts_rec.period50_amount ;
    l_period_amount_tbl(51) := l_accts_rec.period51_amount ;
    l_period_amount_tbl(52) := l_accts_rec.period52_amount ;
    l_period_amount_tbl(53) := l_accts_rec.period53_amount ;
    l_period_amount_tbl(54) := l_accts_rec.period54_amount ;
    l_period_amount_tbl(55) := l_accts_rec.period55_amount ;
    l_period_amount_tbl(56) := l_accts_rec.period56_amount ;
    l_period_amount_tbl(57) := l_accts_rec.period57_amount ;
    l_period_amount_tbl(58) := l_accts_rec.period58_amount ;
    l_period_amount_tbl(59) := l_accts_rec.period59_amount ;
    l_period_amount_tbl(60) := l_accts_rec.period60_amount ;

    --
    -- Create records in psb_ws_lines and psb_ws_account_lines for the
    -- new worksheet.
    --
    PSB_WS_Acct_Pvt.Create_Account_Dist
    (
      p_api_version             =>   1.0 ,
      p_init_msg_list           =>   FND_API.G_FALSE,
      p_commit                  =>   FND_API.G_FALSE,
      p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
      p_return_status           =>   l_return_status,
      p_account_line_id         =>   l_dummy_account_line_id,
      p_msg_count               =>   l_msg_count,
      p_msg_data                =>   l_msg_data,
      --
      p_worksheet_id            =>   p_new_worksheet_id,
      p_budget_year_id          =>   l_accts_rec.budget_year_id,
      p_budget_group_id         =>   l_accts_rec.budget_group_id,
      p_ccid                    =>   l_accts_rec.code_combination_id,
      p_template_id             =>   NVL(l_accts_rec.template_id ,
					  FND_API.G_MISS_NUM ) ,
      p_currency_code           =>   l_accts_rec.currency_code ,
      p_balance_type            =>   l_accts_rec.balance_type ,
      p_ytd_amount              =>   l_accts_rec.ytd_amount  ,
      p_distribute_flag         =>   FND_API.G_FALSE ,
      p_annual_fte              =>   NVL ( l_accts_rec.annual_fte,
					   FND_API.G_MISS_NUM ) ,
      p_period_amount           =>   l_period_amount_tbl ,
      p_position_line_id        =>   NVL( p_new_position_line_id ,
					  FND_API.G_MISS_NUM ) ,
      p_element_set_id          =>   NVL( l_accts_rec.element_set_id,
					  FND_API.G_MISS_NUM ) ,
      p_salary_account_line     =>   NVL( l_accts_rec.salary_account_line,
					  FND_API.G_FALSE ) ,
      p_service_package_id      =>   l_accts_rec.service_package_id ,
      p_start_stage_seq         =>   l_accts_rec.start_stage_seq ,
      p_current_stage_seq       =>   l_accts_rec.current_stage_seq ,
      p_end_stage_seq           =>   NVL( l_accts_rec.end_stage_seq,
					  FND_API.G_MISS_NUM ) ,
      p_copy_of_account_line_id =>   l_accts_rec.account_line_id
    );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --
      ROLLBACK TO Create_Local_Dist_Pvt ;
      p_return_status := l_return_status ;
      --
    END IF;
    --
  END LOOP;

EXCEPTION
  --
 WHEN OTHERS THEN
    --
    ROLLBACK TO Create_Local_Dist_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 l_api_name );
    END IF;
    --
END Create_Local_Dist_Pvt ;
/*---------------------------------------------------------------------------*/

 /*Bug:6367584:start*/
/*===========================================================================+
 |                 PROCEDURE Create_Local_Pay_Dist ( Private )                 |
 +===========================================================================*/
--
-- The private procedure inserts a new record in PSB_POSITION_PAY_DISTRIBUTIONS table.
--
PROCEDURE Create_Local_Pay_Dist
(
  p_worksheet_id             IN       psb_ws_lines.worksheet_id%TYPE,
  p_new_worksheet_id         IN       psb_ws_lines.worksheet_id%TYPE,
  p_operation_type           IN       VARCHAR2,
  p_return_status            OUT  NOCOPY VARCHAR2
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Local_Pay_Dist' ;
  --
  l_global_worksheet_id     NUMBER;
  l_worksheet_id            NUMBER;
  --
  l_msg_count               NUMBER;
  l_return_status           VARCHAR2(100);
  l_msg_data                VARCHAR2(2000);
  l_rowid                   VARCHAR2(100);
  l_distribution_id         NUMBER;
  l_target_worksheet_id     NUMBER;  --For merge operation
  l_dist_rec_exists         VARCHAR2(1);

  --
  CURSOR l_worksheets_csr(wks_id NUMBER) IS
  SELECT *
  FROM   psb_worksheets
  WHERE  worksheet_id = wks_id;

  CURSOR l_pay_dist_csr IS
  SELECT *
  FROM PSB_POSITION_PAY_DISTRIBUTIONS
  WHERE worksheet_id = l_worksheet_id;

  cursor c_Seq is
  select psb_position_pay_distr_s.nextval DistID
   from dual;
BEGIN
  --
 SAVEPOINT Create_Local_Pay_Dist;
  --
 IF p_operation_type = 'COPY' THEN

   FOR l_worksheets_rec IN l_worksheets_csr(p_worksheet_id) LOOP

     IF l_worksheets_rec.global_worksheet_id IS NOT NULL THEN
        l_worksheet_id := l_worksheets_rec.global_worksheet_id;
     ELSE
        l_worksheet_id := l_worksheets_rec.worksheet_id;
     END IF;

   END LOOP;

  FOR l_pay_dist_rec IN l_pay_dist_csr LOOP

      for c_Seq_Rec in c_Seq loop
         l_distribution_id := c_Seq_Rec.DistID;
      end loop;

      PSB_POSITION_PAY_DISTR_PVT.Insert_Row
      (p_api_version => 1.0,
       p_return_status => l_return_status,
       p_msg_count => l_msg_count,
       p_msg_data => l_msg_data,
       p_rowid => l_rowid,
       p_distribution_id => l_distribution_id,
       p_position_id => l_pay_dist_rec.position_id,
       p_data_extract_id => l_pay_dist_rec.data_extract_id,
       p_worksheet_id => p_new_worksheet_id,
       p_effective_start_date             => l_pay_dist_rec.effective_start_date,
       p_effective_end_date               => l_pay_dist_rec.effective_end_date,
       p_chart_of_accounts_id             => l_pay_dist_rec.chart_of_accounts_id,
       p_code_combination_id              => l_pay_dist_rec.code_combination_id,
       p_distribution_percent             => l_pay_dist_rec.distribution_percent,
       p_global_default_flag              => l_pay_dist_rec.global_default_flag,
       p_distribution_default_rule_id     => l_pay_dist_rec.distribution_default_rule_id,
       p_project_id                       => l_pay_dist_rec.project_id,
       p_task_id                          => l_pay_dist_rec.task_id,
       p_award_id                         => l_pay_dist_rec.award_id,
       p_expenditure_type                 => l_pay_dist_rec.expenditure_type,
       p_expenditure_organization_id      => l_pay_dist_rec.expenditure_organization_id,
       p_description                      => l_pay_dist_rec.description
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
      end if;

  END LOOP; -- FOR l_pay_dist_rec IN l_pay_dist_csr LOOP

 ELSIF p_operation_type = 'MERGE' THEN

  l_worksheet_id := p_worksheet_id;

 FOR l_worksheets_rec IN l_worksheets_csr(p_new_worksheet_id) LOOP

   IF l_worksheets_rec.global_worksheet_id IS NOT NULL THEN
      l_target_worksheet_id := l_worksheets_rec.global_worksheet_id;
   ELSE
      l_target_worksheet_id := l_worksheets_rec.worksheet_id;
   END IF;
 END LOOP;

  FOR l_pay_dist_rec IN l_pay_dist_csr LOOP

   PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution
  (
    p_api_version                      => 1.0,
    p_return_status                    => l_return_status,
    p_msg_count                        => l_msg_count,
    p_msg_data                         => l_msg_data,
    p_rowid                            => l_rowid,
    p_distribution_id                  => l_distribution_id,
    p_position_id                      => l_pay_dist_rec.position_id,
    p_data_extract_id                  => l_pay_dist_rec.data_extract_id,
    p_worksheet_id                     => l_target_worksheet_id,
    p_effective_start_date             => l_pay_dist_rec.effective_start_date,
    p_effective_end_date               => l_pay_dist_rec.effective_end_date,
    p_chart_of_accounts_id             => l_pay_dist_rec.chart_of_accounts_id,
    p_code_combination_id              => l_pay_dist_rec.code_combination_id,
    p_distribution_percent             => l_pay_dist_rec.distribution_percent,
    p_global_default_flag              => l_pay_dist_rec.global_default_flag,
    p_distribution_default_rule_id     => l_pay_dist_rec.distribution_default_rule_id,
    p_project_id                       => l_pay_dist_rec.project_id,
    p_task_id                          => l_pay_dist_rec.task_id,
    p_award_id                         => l_pay_dist_rec.award_id,
    p_expenditure_type                 => l_pay_dist_rec.expenditure_type,
    p_expenditure_organization_id      => l_pay_dist_rec.expenditure_organization_id,
    p_description                      => l_pay_dist_rec.description
   );
   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
   end if;

  END LOOP;

  /* Deletes the distribution records in parent worksheet which were
     deleted in local (copy) worksheet.*/

 FOR l_dist_rec IN (select *
                    from   PSB_POSITION_PAY_DISTRIBUTIONS
		    where  worksheet_id = l_target_worksheet_id) LOOP
    l_dist_rec_exists := 'N';
   FOR l_target_dist_rec IN (select *
                             from  PSB_POSITION_PAY_DISTRIBUTIONS
                	     where  worksheet_id = l_worksheet_id
			     and    position_id = l_dist_rec.position_id
			     and    effective_start_date = l_dist_rec.effective_start_date
			     and    code_combination_id = l_dist_rec.code_combination_id) LOOP
    l_dist_rec_exists := 'Y';
   END LOOP;

   IF l_dist_rec_exists = 'N' THEN
    PSB_POSITION_PAY_DISTR_PVT.DELETE_ROW
    (
      p_api_version         => 1.0,
      p_return_status       => l_return_status,
      p_msg_count           => l_msg_count,
      p_msg_data            => l_msg_data,
      p_distribution_id     => l_dist_rec.distribution_id
     );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
   end if;

   END IF;  --IF l_dist_rec_exists = 'N' THEN

  END LOOP;


 END IF; --IF p_operation_type

  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
			     p_data  => l_msg_data);
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR then
     ROLLBACK TO Create_Local_Pay_Dist;
     p_return_status := FND_API.G_RET_STS_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 l_api_name );
    END IF;
    --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Create_Local_Pay_Dist;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 l_api_name );
    END IF;
    --
END Create_Local_Pay_Dist;
/*---------------------------------------------------------------------------*/

 /*Bug:6367584:end*/

/*===========================================================================+
 |                 PROCEDURE Insert_WS_Lines_Pvt ( Private )                 |
 +===========================================================================*/
--
-- The private procedure inserts a new record in psb_ws_lines table.
--
PROCEDURE Insert_WS_Lines_Pvt
(
  p_worksheet_id              IN       psb_ws_lines.worksheet_id%TYPE,
  p_account_line_id           IN       psb_ws_lines.account_line_id%TYPE,
  p_freeze_flag               IN       psb_ws_lines.freeze_flag%TYPE,
  p_view_line_flag            IN       psb_ws_lines.view_line_flag%TYPE,
  p_last_update_date          IN       psb_ws_lines.last_update_date%TYPE,
  p_last_updated_by           IN       psb_ws_lines.last_updated_by%TYPE,
  p_last_update_login         IN       psb_ws_lines.last_update_login%TYPE,
  p_created_by                IN       psb_ws_lines.created_by%TYPE,
  p_creation_date             IN       psb_ws_lines.creation_date%TYPE,
  p_return_status             OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30) := 'Insert_WS_Lines_Pvt' ;
  --
BEGIN
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  update psb_ws_lines
     set freeze_flag       = p_freeze_flag,
	 view_line_flag    = p_view_line_flag,
	 last_update_date  = g_current_date,
	 last_updated_by   = g_current_user_id,
	 last_update_login = g_current_login_id
   where account_line_id   = p_account_line_id
     and worksheet_id      = p_worksheet_id;

  IF SQL%NOTFOUND THEN

    INSERT INTO psb_ws_lines
	   (
	     worksheet_id,
	     account_line_id,
	     freeze_flag,
	     view_line_flag,
	     last_update_date,
	     last_updated_by,
	     last_update_login,
	     created_by,
	     creation_date
	   )
	 VALUES
	   ( p_worksheet_id,
	     p_account_line_id,
	     p_freeze_flag,
	     p_view_line_flag,
	     g_current_date,
	     g_current_user_id,
	     g_current_login_id,
	     g_current_user_id,
	     g_current_date
	   );

  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 l_api_name );
    END IF;
    --
END Insert_WS_Lines_Pvt ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                 PROCEDURE Delete_Worksheet_Pvt ( Private )                |
 +===========================================================================*/
--
-- This API deletes an official worksheet by performing deletes on
-- psb_worksheets and matrix tables (psb_ws_lines and psb_ws_lines_positions).
-- It also deletes worksheet related data from other tables.
--
PROCEDURE Delete_Worksheet_Pvt
(
  p_worksheet_id              IN      psb_worksheets.worksheet_id%TYPE       ,
  p_budget_by_position        IN      psb_worksheets.budget_by_position%TYPE ,
  p_delete_lines_flag         IN      VARCHAR2 ,
  p_return_status             OUT  NOCOPY     VARCHAR2
)
IS
  --
  l_api_name              CONSTANT    VARCHAR2(30)  := 'Delete_Worksheet_Pvt' ;
  --
  l_account_line_id       psb_ws_lines.account_line_id%TYPE;
  l_position_line_id      psb_ws_lines_positions.position_line_id%TYPE ;
  l_local_copy_flag       psb_worksheets.local_copy_flag%TYPE;
  l_budget_by_position    psb_worksheets.budget_by_position%TYPE ;
  l_return_status         VARCHAR2(1) ;
  /*For Bug No : 2266309 Start*/
  l_record_ctr            NUMBER := 0;
  /*For Bug No : 2266309 End*/

  --
  CURSOR l_ws_account_lines_csr
    IS
    SELECT account_line_id
    FROM   psb_ws_lines
    WHERE  worksheet_id = p_worksheet_id;

  CURSOR l_ws_position_lines_csr
    IS
    SELECT position_line_id
    FROM   psb_ws_lines_positions
    WHERE  worksheet_id = p_worksheet_id;

BEGIN
  /*For Bug No : 2266309 Start*/
  SAVEPOINT Delete_Worksheet_Pvt ;
  /*For Bug No : 2266309 Start*/
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  -- p_delete_lines_flag specifies whether psb_ws_account_lines and
  -- psb_ws_position_lines related tables will be deleted or not.
  --
  IF p_delete_lines_flag = 'Y' THEN

    --
    -- Deleting account related information.
    --
    OPEN l_ws_account_lines_csr;

    LOOP
      --
      FETCH l_ws_account_lines_csr INTO l_account_line_id;

      IF (l_ws_account_lines_csr%NOTFOUND) THEN
	EXIT;
      END IF;

      --Deleting records from psb_ws_account_lines.
      DELETE psb_ws_account_lines
      WHERE  account_line_id = l_account_line_id;
      --
      /*For Bug No : 2266309 Start*/
      l_record_ctr := l_record_ctr + 1;
      IF l_record_ctr = PSB_WS_ACCT1.g_checkpoint_save THEN
	COMMIT WORK;
	l_record_ctr := 0;
	SAVEPOINT Delete_Worksheet_Pvt;
      END IF;
      /*For Bug No : 2266309 End*/

    END LOOP;

    CLOSE l_ws_account_lines_csr;

    --
    -- Deleting position related information.
    --

    IF ( p_budget_by_position = 'Y' ) THEN
      --
      OPEN l_ws_position_lines_csr ;

      LOOP
	--
	FETCH l_ws_position_lines_csr INTO l_position_line_id;

	IF ( l_ws_position_lines_csr%NOTFOUND ) THEN
	  EXIT;
	END IF;

	-- Deleting records from psb_ws_position_lines.
	DELETE psb_ws_position_lines
	WHERE  position_line_id = l_position_line_id;

	-- Deleting records from psb_ws_fte_lines.
	DELETE psb_ws_fte_lines
	WHERE  position_line_id = l_position_line_id;

	-- Deleting records from psb_ws_element_lines.
	DELETE psb_ws_element_lines
	WHERE  position_line_id = l_position_line_id;

	/*For Bug No : 2266309 Start*/
	l_record_ctr := l_record_ctr + 3;
	IF l_record_ctr >= PSB_WS_ACCT1.g_checkpoint_save THEN
	  COMMIT WORK;
	  l_record_ctr := 0;
	  SAVEPOINT Delete_Worksheet_Pvt;
	END IF;
	/*For Bug No : 2266309 End*/

      END LOOP;

      CLOSE l_ws_position_lines_csr ;

    END IF ;    -- if p_budget_by_position is 'Y'.
    --
  END IF;       -- if p_delete_lines_flag is 'Y'.

  /*For Bug No : 2266309 Start*/
  IF l_record_ctr > 0 THEN
    COMMIT WORK;
    SAVEPOINT Delete_Worksheet_Pvt;
  END IF;
  /*For Bug No : 2266309 End*/

  --
  -- Delete worksheet related account lines from psb_ws_lines ( Account Matrix).
  --
  DELETE psb_ws_lines
  WHERE  worksheet_id = p_worksheet_id ;

  /*For Bug No : 2266309 Start*/
  COMMIT WORK;
  SAVEPOINT Delete_Worksheet_Pvt;
  /*For Bug No : 2266309 End*/

  --
  -- Delete worksheet related position lines from psb_ws_lines_positions
  -- ( Position Matrix).
  --
  IF p_budget_by_position = 'Y' THEN
    --
    DELETE psb_ws_lines_positions
    WHERE  worksheet_id = p_worksheet_id ;
    --
    /*For Bug No : 2266309 Start*/
    COMMIT WORK;
    SAVEPOINT Delete_Worksheet_Pvt;
    /*For Bug No : 2266309 End*/

  END IF;

  -- Delete from psb_ws_distribution_details.
  DELETE psb_ws_distribution_details
  WHERE  child_worksheet_id = p_worksheet_id ;

  -- Delete from psb_workflow_processes.
  DELETE psb_workflow_processes
  WHERE  worksheet_id = p_worksheet_id ;

  -- Delete from psb_ws_distributions.
  DELETE psb_ws_distributions
  WHERE  worksheet_id = p_worksheet_id ;

  -- Delete from psb_ws_submit_service_packages.
  DELETE psb_ws_submit_service_packages
  WHERE  worksheet_id = p_worksheet_id ;

  -- Delete from psb_ws_user_profiles.
  DELETE psb_ws_user_profiles
  WHERE  worksheet_id = p_worksheet_id ;

  -- Delete from psb_position_assignments.
  DELETE psb_position_assignments
  WHERE  worksheet_id = p_worksheet_id ;

  -- Delete from psb_pay_element_rates.
  DELETE psb_pay_element_rates
  WHERE  worksheet_id = p_worksheet_id ;

  -- Delete from psb_ws_submit_comments.
  DELETE psb_ws_submit_comments
  WHERE  worksheet_id = p_worksheet_id ;

  -- Delete from psb_worksheets.
  DELETE psb_worksheets
  WHERE  worksheet_id = p_worksheet_id ;

  /*For Bug No : 2613269 Start*/
  fnd_attached_documents2_pkg.delete_attachments
             (X_entity_name => 'PSB_WORKSHEETS',
              X_pk1_value => p_worksheet_id,
              X_delete_document_flag => 'Y'
             );
  /*For Bug No : 2613269 End*/

  /*For Bug No : 2266309 Start*/
  COMMIT WORK;
  /*For Bug No : 2266309 End*/
  --
EXCEPTION
  --
 WHEN OTHERS THEN
    --
    /*For Bug No : 2266309 Start*/
    ROLLBACK TO Delete_Worksheet_Pvt ;
    /*For Bug No : 2266309 End*/
  --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 l_api_name );
    END IF;
    --
END Delete_Worksheet_Pvt ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Delete_Worksheet_CP                        |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Maintain Budget
-- Account Codes'.
--
PROCEDURE Delete_Worksheet_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id              IN       NUMBER  ,
  p_keep_local_copy_flag      IN       VARCHAR2
)
IS
  --
  l_api_name         CONSTANT VARCHAR2(30)   := 'Delete_Worksheet_CP' ;
  l_api_version      CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status             VARCHAR2(1) ;
  l_msg_count                 NUMBER ;
  l_msg_data                  VARCHAR2(2000) ;
  --
BEGIN
  --
  SAVEPOINT Delete_Worksheet_CP_Pvt ;
  --
  PSB_WS_Ops_Pvt.Delete_Worksheet
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_TRUE,
   /*For Bug No : 2266309 Start*/
     --p_commit                =>   FND_API.G_FALSE,
     p_commit                  =>   FND_API.G_TRUE,
   /*For Bug No : 2266309 End*/
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_worksheet_id            =>   p_worksheet_id,
     p_keep_local_copy_flag    =>   p_keep_local_copy_flag
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

  --
  retcode := 0 ;
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
  /*For Bug No : 2266309 Start*/
    --ROLLBACK TO Delete_Worksheet_CP_Pvt ;
    ROLLBACK;
  /*For Bug No : 2266309 End*/
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
  /*For Bug No : 2266309 Start*/
    --ROLLBACK TO Delete_Worksheet_CP_Pvt ;
    ROLLBACK;
  /*For Bug No : 2266309 End*/
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
  /*For Bug No : 2266309 Start*/
    --ROLLBACK TO Delete_Worksheet_CP_Pvt ;
    ROLLBACK;
  /*For Bug No : 2266309 End*/
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Delete_Worksheet_CP ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE  Create_New_Position_Worksheet                |
 +===========================================================================*/
--
-- The API creates a worksheet from a given worksheet while cosidering only
-- new positions in the given worksheet.
--
PROCEDURE Create_New_Position_Worksheet
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE    ,
  p_budget_group_id           IN       psb_worksheets.budget_group_id%TYPE ,
  p_service_package_operation_id
			      IN       NUMBER := FND_API.G_MISS_NUM ,
  p_worksheet_id_OUT          OUT  NOCOPY      psb_worksheets.worksheet_id%TYPE
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30) := 'Create_New_Position_Worksheet' ;
  l_api_version    CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_worksheet_name          psb_worksheets.name%TYPE ;
  l_budget_by_position      psb_worksheets.budget_by_position%TYPE ;
  l_worksheet_description   psb_worksheets.description%TYPE ;
  l_main_budget_group_id    psb_worksheets.budget_group_id%TYPE ;
  l_main_budget_group_name  psb_budget_groups.name%TYPE ;
  l_main_budget_calendar_id psb_worksheets.budget_calendar_id%TYPE ;
  l_new_worksheet_id        psb_worksheets.worksheet_id%TYPE ;
  l_global_worksheet_id     psb_worksheets.worksheet_id%TYPE ;
  l_service_package_count   NUMBER ;
  --
  l_tmp_char                VARCHAR2(1) ;
  l_lines_added             NUMBER := 0 ;
  --
  CURSOR l_worksheets_csr IS
	 SELECT *
	 FROM psb_worksheets
	 WHERE worksheet_id = p_worksheet_id ;
  --
  l_worksheets_rec   l_worksheets_csr%ROWTYPE ;
  --
BEGIN
  --
  SAVEPOINT Create_New_Position_WS_Pvt ;
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
  p_worksheet_id_OUT := 0 ;

  --
  -- Finding the worksheet information.
  --
  OPEN  l_worksheets_csr ;
  FETCH l_worksheets_csr INTO l_worksheets_rec ;
  CLOSE l_worksheets_csr ;

  IF ( l_worksheets_rec.worksheet_Id IS NULL ) THEN
    --
    Fnd_Message.Set_Name ('PSB',     'PSB_INVALID_WORKSHEET_ID') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- l_budget_by_position defines whether worksheet contains positions or not.
  l_budget_by_position := NVL(l_worksheets_rec.budget_by_position, 'N') ;

  l_main_budget_group_id      := l_worksheets_rec.budget_group_id ;
  l_main_budget_calendar_id   := l_worksheets_rec.budget_calendar_id ;

  --
  -- Finding the budget group name for the worksheet.
  --
  SELECT name INTO l_main_budget_group_name
  FROM   psb_budget_groups
  WHERE  budget_group_id = l_main_budget_group_id ;

  --
  -- Get translated messages for the new worksheet.
  --
  Fnd_Message.Set_Name ( 'PSB', 'PSB_WORKSHEET_CREATION_INFO') ;
  Fnd_Message.Set_Token( 'WORKSHEET_ID',      p_worksheet_id ) ;
  Fnd_Message.Set_Token( 'BUDGET_GROUP_NAME', l_main_budget_group_name ) ;
  l_worksheet_description := Fnd_Message.Get ;

  --
  -- Find global worksheet related information, use by Create_Worksheet API.
  --
  IF NVL(l_worksheets_rec.global_worksheet_flag, 'N') = 'Y' THEN
    l_global_worksheet_id := p_worksheet_id ;
  ELSE
    l_global_worksheet_id := l_worksheets_rec.global_worksheet_id ;
  END IF ;

  --
  -- Create the new worksheet in psb_worksheets table.
  --
  PSB_Worksheet_Pvt.Create_Worksheet
  (
     p_api_version               => 1.0 ,
     p_init_msg_list             => FND_API.G_FALSE,
     p_commit                    => FND_API.G_FALSE,
     p_validation_level          => FND_API.G_VALID_LEVEL_NONE,
     p_return_status             => l_return_status,
     p_msg_count                 => l_msg_count,
     p_msg_data                  => l_msg_data ,
     --
     p_budget_group_id           => p_budget_group_id,
     p_budget_calendar_id        => l_worksheets_rec.budget_calendar_id,
     p_worksheet_type            => 'R',
     p_name                      => NULL ,
     p_description               => l_worksheet_description ,
     p_ws_creation_complete      => l_worksheets_rec.ws_creation_complete ,
     p_stage_set_id              => l_worksheets_rec.stage_set_id ,
     p_current_stage_seq         => l_worksheets_rec.current_stage_seq ,
     p_global_worksheet_id       => l_global_worksheet_id ,
     p_global_worksheet_flag     => 'N' ,
     p_global_worksheet_option   => l_worksheets_rec.global_worksheet_option,
     p_local_copy_flag           => l_worksheets_rec.local_copy_flag,
     p_copy_of_worksheet_id      => l_worksheets_rec.copy_of_worksheet_id,
     p_freeze_flag               => l_worksheets_rec.freeze_flag,
     p_budget_by_position        => l_worksheets_rec.budget_by_position,
     p_use_revised_element_rates => l_worksheets_rec.use_revised_element_rates,
     p_num_proposed_years        => l_worksheets_rec.num_proposed_years,
     p_num_years_to_allocate     => l_worksheets_rec.num_years_to_allocate,
     p_rounding_factor           => l_worksheets_rec.rounding_factor,
     p_gl_cutoff_period          => l_worksheets_rec.gl_cutoff_period,
     p_include_stat_balance      => l_worksheets_rec.include_stat_balance,
     p_include_trans_balance     => l_worksheets_rec.include_translated_balance,
     p_include_adj_period        => l_worksheets_rec.include_adjustment_periods,
     p_data_extract_id           => l_worksheets_rec.data_extract_id,
     p_parameter_set_id          => NULL,
     p_constraint_set_id         => NULL,
     p_allocrule_set_id          => NULL,
     p_date_submitted            => l_worksheets_rec.date_submitted,
     p_submitted_by              => l_worksheets_rec.submitted_by,
     p_attribute1                => l_worksheets_rec.attribute1,
     p_attribute2                => l_worksheets_rec.attribute2,
     p_attribute3                => l_worksheets_rec.attribute3,
     p_attribute4                => l_worksheets_rec.attribute4,
     p_attribute5                => l_worksheets_rec.attribute5,
     p_attribute6                => l_worksheets_rec.attribute6,
     p_attribute7                => l_worksheets_rec.attribute7,
     p_attribute8                => l_worksheets_rec.attribute8,
     p_attribute9                => l_worksheets_rec.attribute9,
     p_attribute10               => l_worksheets_rec.attribute10,
     p_context                   => l_worksheets_rec.context,
     p_worksheet_id              => l_new_worksheet_id
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Get budget calendar related info to find all the budget groups down in the
  -- current hierarchy to get all the CCIDs for the current budget group.
  --
  IF NVL(PSB_WS_Acct1.g_budget_calendar_id, -99) <> l_main_budget_calendar_id
  THEN
    --
    PSB_WS_Acct1.Cache_Budget_Calendar
    (
       p_return_status         =>  l_return_status ,
       p_budget_calendar_id    =>  l_main_budget_calendar_id
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  --
  -- Check whether service packages were selected for the worksheet.
  -- If yes, then we need to consider only those account lines which are
  -- related to the service package selection.
  --
  SELECT count(*) INTO l_service_package_count
  FROM   psb_ws_submit_service_packages
  WHERE  worksheet_id = p_worksheet_id
  AND    operation_id = NVL( p_service_package_operation_id ,
			     FND_API.G_MISS_NUM ) ;
  --
  -- Maintain psb_ws_lines_positions table if worksheet contains positions.
  --
  IF l_budget_by_position = 'Y' THEN

    --
    -- This loop gets all the newly created position for the given worksheet.
    -- belonging to the given budget group.
    --
    FOR l_lines_pos_rec IN
    (
       SELECT pos_lines.*     ,
	      pos.position_id
       FROM   psb_ws_lines_positions   pos_lines ,
	      psb_ws_position_lines    pos       ,
	      psb_positions            positions
       WHERE  pos_lines.worksheet_id = p_worksheet_id
       AND    pos.position_line_id   = pos_lines.position_line_id
       AND    positions.position_id  = pos.position_id
       --AND    positions.hr_position_id IS NULL
       AND    positions.new_position_flag = 'Y'
       AND    (
		l_service_package_count = 0
		OR
		pos_lines.position_line_id IN
		(
		  SELECT accts.position_line_id
		  FROM   psb_ws_account_lines  accts
		  WHERE  accts.position_line_id = pos_lines.position_line_id
		  AND    accts.service_package_id IN
			 (
			   SELECT sp.service_package_id
			   FROM   psb_ws_submit_service_packages sp
			   WHERE  worksheet_id = p_worksheet_id
			   AND    operation_id = p_service_package_operation_id
			 )
		)
	      )
    )
    LOOP

      -- At least one line should get created for the worksheet.
      l_lines_added := l_lines_added + 1 ;

      --
      -- Put the position_line in the psb_ws_lines_position table.
      --
      PSB_WS_Pos_Pvt.Create_Position_Matrix
      (
	p_api_version        =>  1.0 ,
	p_init_msg_list      =>  FND_API.G_FALSE ,
	p_validation_level   =>  FND_API.G_VALID_LEVEL_NONE ,
	p_return_status      =>  l_return_status ,
	p_msg_count          =>  l_msg_count ,
	p_msg_data           =>  l_msg_data ,
	--
	p_worksheet_id       =>  l_new_worksheet_id ,
	p_position_line_id   =>  l_lines_pos_rec.position_line_id ,
	p_freeze_flag        =>  l_lines_pos_rec.freeze_flag ,
	p_view_line_flag     =>  l_lines_pos_rec.view_line_flag
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --

      --
      -- Maintain psb_ws_lines matrix for the account lines related to
      -- current position_line_id (l_lines_pos_rec.position_line_id).
      --
      FOR l_lines_rec IN
      (
	SELECT lines.*
	FROM   psb_ws_lines          lines,
	       psb_ws_account_lines  accts
	WHERE  accts.position_line_id = l_lines_pos_rec.position_line_id
	AND    lines.worksheet_id     = p_worksheet_id
	AND    lines.account_line_id  = accts.account_line_id
      )
      LOOP
	--
	Insert_WS_Lines_Pvt
	(
	  p_worksheet_id       =>  l_new_worksheet_id,
	  p_account_line_id    =>  l_lines_rec.account_line_id ,
	  p_freeze_flag        =>  l_lines_rec.freeze_flag ,
	  p_view_line_flag     =>  l_lines_rec.view_line_flag ,
	  p_last_update_date   =>  g_current_date,
	  p_last_updated_by    =>  g_current_user_id,
	  p_last_update_login  =>  g_current_login_id,
	  p_created_by         =>  g_current_user_id,
	  p_creation_date      =>  g_current_date,
	  p_return_status      =>  l_return_status
	) ;
	--
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
	--

      END LOOP ;    --/ Maintain position_line_id related account lines.

    END LOOP ;    --/ To process all new positions in the worksheet.

  END IF ;  --/ Check for l_budget_by_position = 'Y'

  --
  -- Check whether at least one line got created or not.
  --
  IF l_lines_added = 0 THEN
    p_worksheet_id_OUT := 0 ;
    ROLLBACK TO Create_New_Position_WS_Pvt ;
  ELSE
    p_worksheet_id_OUT := l_new_worksheet_id ;
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
    ROLLBACK TO Create_New_Position_WS_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Create_New_Position_WS_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_worksheets_csr%ISOPEN ) THEN
      CLOSE l_worksheets_csr ;
    END IF ;
    --
    ROLLBACK TO Create_New_Position_WS_Pvt ;
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
END Create_New_Position_Worksheet ;
/*---------------------------------------------------------------------------*/


END PSB_WS_Ops_Pvt ;

/
