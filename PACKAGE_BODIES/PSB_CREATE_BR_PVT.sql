--------------------------------------------------------
--  DDL for Package Body PSB_CREATE_BR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_CREATE_BR_PVT" AS
/* $Header: PSBVCBRB.pls 115.26 2003/04/21 20:10:28 srawat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Create_BR_Pvt';


/*--------------------------- Global variables -----------------------------*/

  -- The flag determines whether to print debug information or not.
  g_debug_flag           VARCHAR2(1) := 'N' ;

  --
  -- WHO columns variables
  --

  g_current_date           DATE   := sysdate;
  g_current_user_id        NUMBER := FND_GLOBAL.USER_ID;
  g_current_login_id       NUMBER := FND_GLOBAL.LOGIN_ID;
  g_budget_by_position     NUMBER;

/*----------------------- End Global variables -----------------------------*/


/* ---------------------- Private Routine prototypes  -----------------------*/


  PROCEDURE Insert_BR_Lines_Pvt
  (
    p_budget_revision_id            IN  NUMBER,
    p_budget_revision_acct_line_id  IN  NUMBER,
    p_freeze_flag                   IN  VARCHAR2,
    p_view_line_flag                IN  VARCHAR2,
    p_last_update_date              IN  DATE,
    p_last_updated_by               IN  NUMBER,
    p_last_update_login             IN  NUMBER,
    p_created_by                    IN  NUMBER,
    p_creation_date                 IN  DATE,
    p_return_status                 OUT  NOCOPY VARCHAR2
  ) ;

  PROCEDURE Insert_BR_Pos_Lines_Pvt
  (
    p_budget_revision_id            IN  NUMBER,
    p_budget_revision_pos_line_id   IN  NUMBER,
    p_freeze_flag                   IN  VARCHAR2,
    p_view_line_flag                IN  VARCHAR2,
    p_last_update_date              IN  DATE,
    p_last_updated_by               IN  NUMBER,
    p_last_update_login             IN  NUMBER,
    p_created_by                    IN  NUMBER,
    p_creation_date                 IN  DATE,
    p_return_status                 OUT  NOCOPY VARCHAR2
  ) ;

  PROCEDURE  debug
  (
    p_message               IN   VARCHAR2
  ) ;

/* ------------------ End Private Routines prototypes  ----------------------*/

/*===========================================================================+
 |                   PROCEDURE Enforce_BR_Concurrency                        |
 +===========================================================================*/
--
-- The budget revision operations may affect one or more budget revisions
-- depending on the type of the operation. This API locks all the relevent
-- budget revisions required for a budget revision operation.
--
PROCEDURE Enforce_BR_Concurrency
(
  p_api_version               IN    NUMBER   ,
  p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN    VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY   VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY   NUMBER   ,
  p_msg_data                  OUT  NOCOPY   VARCHAR2 ,
  --
  p_budget_revision_id        IN    NUMBER,
  p_parent_or_child_mode      IN    VARCHAR2 ,
  p_maintenance_mode          IN    VARCHAR2 := 'MAINTENANCE'
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Enforce_BR_Concurrency' ;
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_budget_revision_tab     PSB_Create_BR_Pvt.Budget_Revision_Tbl_Type ;
  --
BEGIN
  --
  SAVEPOINT Enforce_BR_Concurrency_Pvt ;
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
  -- First lock the current budget revision p_budget_revision_id
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
     p_concurrency_class           => nvl(p_maintenance_mode,'MAINTENANCE'),
     p_concurrency_entity_name     => 'BUDGET_REVISION',
     p_concurrency_entity_id       => p_budget_revision_id
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Find parent or child budget revisions depending on p_parent_or_child_mode
  -- parameter.
  --
  IF p_parent_or_child_mode = 'PARENT' THEN
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
       p_budget_revision_id      =>   p_budget_revision_id,
       p_budget_revision_tbl     =>   l_budget_revision_tab
    );
    --
  ELSIF p_parent_or_child_mode = 'CHILD' THEN
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
       p_budget_revision_id   =>   p_budget_revision_id,
       p_budget_revision_tbl  =>   l_budget_revision_tab
    );
    --
  END IF ;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  FOR i IN 1..l_budget_revision_tab.COUNT
  LOOP
    --
    -- Lock parent or child budget revisions retrieved in the previous step.
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
       p_concurrency_class        => nvl(p_maintenance_mode,'MAINTENANCE'),
       p_concurrency_entity_name  => 'BUDGET_REVISION',
       p_concurrency_entity_id    => l_budget_revision_tab(i)
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
    ROLLBACK TO Enforce_BR_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Enforce_BR_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Enforce_BR_Concurrency_Pvt ;
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
END Enforce_BR_Concurrency ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                   PROCEDURE Check_BR_Ops_Concurrency                      |
 +===========================================================================*/
--
-- The API checks for the operation type to invoke appropriate concurrency
-- control routines.
--
PROCEDURE Check_BR_Ops_Concurrency
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_budget_revision_id        IN       NUMBER,
  p_operation_type            IN       VARCHAR2
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Check_BR_Ops_Concurrency';
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
BEGIN
  --
  SAVEPOINT Check_BR_Ops_Concurrency_Pvt ;
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

  IF p_operation_type IN ('FREEZE_REVISION', 'SUBMIT_REVISION' ) THEN
    --
    -- Lock in 'CHILD' mode as the child Revisions also need to be frozen.
    --
    PSB_Create_BR_PVT.Enforce_BR_Concurrency
    (
       p_api_version              =>  1.0,
       p_init_msg_list            =>  FND_API.G_FALSE ,
       p_commit                   =>  FND_API.G_FALSE ,
       p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
       p_return_status            =>  l_return_status,
       p_msg_count                =>  l_msg_count,
       p_msg_data                 =>  l_msg_data,
       --
       p_budget_revision_id       =>  p_budget_revision_id ,
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
  ELSIF p_operation_type IN ('UNFREEZE_REVISION' ) THEN
    --
    -- Lock only the current Revision.
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
       p_concurrency_entity_name  =>  'BUDGET_REVISION' ,
       p_concurrency_entity_id    =>  p_budget_revision_id
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
    ROLLBACK TO Check_BR_Ops_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_BR_Ops_Concurrency_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_BR_Ops_Concurrency_Pvt ;
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
END Check_BR_Ops_Concurrency ;

/*===========================================================================+
 |                PROCEDURE Create_Budget_Revision                           |
 +===========================================================================*/
--
-- This overloaded API creates a new budget revision for a given budget group.
--
PROCEDURE Create_Budget_Revision
(
  p_api_version               IN   NUMBER   ,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY  VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY  NUMBER   ,
  p_msg_data                  OUT  NOCOPY  VARCHAR2 ,
  --
  p_budget_revision_id        IN   NUMBER,
  p_revision_option_flag      IN   VARCHAR2,
  p_budget_group_id           IN   NUMBER,
  p_budget_revision_id_out    OUT  NOCOPY  NUMBER
)

IS
  --
  l_api_name                CONSTANT VARCHAR2(30) := 'Create_Budget_Revision';
  l_api_version             CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_revision_justification     psb_budget_revisions.justification%TYPE ;
  l_main_budget_group_id       psb_budget_revisions.budget_group_id%TYPE ;
  l_main_budget_group_name     psb_budget_groups.name%TYPE ;
  l_new_budget_revision_id     psb_budget_revisions.budget_revision_id%TYPE ;
  l_global_budget_revision_id  psb_budget_revisions.budget_revision_id%TYPE ;
  --
  l_tmp_char                VARCHAR2(1) ;
  l_freeze_flag             VARCHAR2(1) ;
  --
  CURSOR l_budget_revisions_csr IS
	 SELECT *
	 FROM   psb_budget_revisions
	 WHERE  budget_revision_id = p_budget_revision_id;

  CURSOR l_budget_by_position_csr IS
	 SELECT count(*)
	 FROM   psb_budget_revision_pos_lines lines,
		psb_budget_revisions rev
	 WHERE  rev.budget_revision_id = p_budget_revision_id
	   AND  rev.budget_revision_id = lines.budget_revision_id;

  --CURSOR l_seq IS
  --      SELECT psb_budget_revisions_s.nextval budget_revision_id
  --       FROM   DUAL;
  --
  l_br_row_type l_budget_revisions_csr%ROWTYPE ;
  --
BEGIN
  --
  SAVEPOINT Create_Budget_Revision_Pvt ;
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
  OPEN  l_budget_revisions_csr;

  FETCH l_budget_revisions_csr INTO l_br_row_type;

  IF ( l_budget_revisions_csr%NOTFOUND ) THEN
    --
    Fnd_Message.Set_Name ('PSB','PSB_INVALID_BUDGET_REVISION_ID') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

  -- l_budget_by_position defines whether budget revision contains positions
  -- or not.

  l_main_budget_group_id    := l_br_row_type.budget_group_id ;
  --
  -- Finding the main budget group name.
  --
  SELECT name INTO l_main_budget_group_name
  FROM   psb_budget_groups
  WHERE  budget_group_id = l_main_budget_group_id;

  --
  -- Get translated messages for the new budget revision.
  --
  Fnd_Message.Set_Name ( 'PSB', 'PSB_BUDGET_REVISION_INFO') ;
  Fnd_Message.Set_Token( 'BUDGET_REVISION_ID', p_budget_revision_id ) ;
  Fnd_Message.Set_Token( 'BUDGET_GROUP_NAME', l_main_budget_group_name ) ;
  l_revision_justification := Fnd_Message.Get ;

  --
  -- Find global budget revision related information,
  -- use by Create_Budget_Revision API.
  --
  IF NVL(l_br_row_type.global_budget_revision, 'N') = 'Y' THEN
    l_global_budget_revision_id := p_budget_revision_id;
  ELSE
    l_global_budget_revision_id := l_br_row_type.global_budget_revision_id;
  END IF ;

  --
  -- Create the new budget revision in psb_budget_revisions table.
  --
  if ((p_revision_option_flag is not null ) and (p_revision_option_flag = 'N'))
then
     l_freeze_flag := 'Y';
  else
     l_freeze_flag := l_br_row_type.freeze_flag;
  end if;


  PSB_Budget_Revisions_Pvt.Create_Budget_Revision
  (
   p_api_version                    => 1.0 ,
   p_init_msg_list                  => FND_API.G_FALSE,
   p_commit                         => FND_API.G_FALSE,
   p_validation_level               => FND_API.G_VALID_LEVEL_NONE,
   p_return_status                  => l_return_status,
   p_msg_count                      => l_msg_count,
   p_msg_data                       => l_msg_data ,
   --
   p_justification                  => l_br_row_type.justification,
   p_budget_group_id                => p_budget_group_id,
   p_gl_budget_set_id               => l_br_row_type.gl_budget_set_id,
   p_hr_budget_id                   => l_br_row_type.hr_budget_id,
   p_from_gl_period_name            => l_br_row_type.from_gl_period_name,
   p_to_gl_period_name              => l_br_row_type.to_gl_period_name,
   p_currency_code                  => l_br_row_type.currency_code,
   p_effective_start_date           => l_br_row_type.effective_start_date,
   p_effective_end_date             => l_br_row_type.effective_end_date,
   p_budget_revision_type           => l_br_row_type.budget_revision_type,
   p_transaction_type               => l_br_row_type.transaction_type,
   p_permanent_revision             => l_br_row_type.permanent_revision,
   p_revise_by_position             => l_br_row_type.revise_by_position,
   p_balance_type                   => l_br_row_type.balance_type,
   p_requestor                      => l_br_row_type.requestor,
   p_parameter_set_id               => l_br_row_type.parameter_set_id,
   p_constraint_set_id              => l_br_row_type.constraint_set_id,
   p_submission_date                => l_br_row_type.submission_date,
   p_submission_status              => l_br_row_type.submission_status,
   p_approval_override_by           => l_br_row_type.approval_override_by,
   p_freeze_flag                    => l_freeze_flag,
   p_base_line_revision             => l_br_row_type.base_line_revision,
   p_global_budget_revision         => 'N',
   p_global_budget_revision_id      => l_global_budget_revision_id,
   p_attribute1                     => l_br_row_type.attribute1,
   p_attribute2                     => l_br_row_type.attribute2,
   p_attribute3                     => l_br_row_type.attribute3,
   p_attribute4                     => l_br_row_type.attribute4,
   p_attribute5                     => l_br_row_type.attribute5,
   p_attribute6                     => l_br_row_type.attribute6,
   p_attribute7                     => l_br_row_type.attribute7,
   p_attribute8                     => l_br_row_type.attribute8,
   p_attribute9                     => l_br_row_type.attribute9,
   p_attribute10                    => l_br_row_type.attribute10,
   p_attribute11                    => l_br_row_type.attribute11,
   p_attribute12                    => l_br_row_type.attribute12,
   p_attribute13                    => l_br_row_type.attribute13,
   p_attribute14                    => l_br_row_type.attribute14,
   p_attribute15                    => l_br_row_type.attribute15,
   p_attribute16                    => l_br_row_type.attribute16,
   p_attribute17                    => l_br_row_type.attribute17,
   p_attribute18                    => l_br_row_type.attribute18,
   p_attribute19                    => l_br_row_type.attribute19,
   p_attribute20                    => l_br_row_type.attribute20,
   p_attribute21                    => l_br_row_type.attribute21,
   p_attribute22                    => l_br_row_type.attribute22,
   p_attribute23                    => l_br_row_type.attribute23,
   p_attribute24                    => l_br_row_type.attribute24,
   p_attribute25                    => l_br_row_type.attribute25,
   p_attribute26                    => l_br_row_type.attribute26,
   p_attribute27                    => l_br_row_type.attribute27,
   p_attribute28                    => l_br_row_type.attribute28,
   p_attribute29                    => l_br_row_type.attribute29,
   p_attribute30                    => l_br_row_type.attribute30,
   p_context                        => l_br_row_type.context,
   p_budget_revision_id             => l_new_budget_revision_id
  );

  --
  CLOSE l_budget_revisions_csr ;
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --
  --
  -- This LOOP gets all the account_line_id for the new budget revision
  -- which will be used to maintain psb_budget_revision_lines table.
  --
  FOR l_lines_rec IN
  (
    SELECT lines.*
    FROM   psb_budget_revision_lines     lines,
	   psb_budget_revision_accounts  acct
    WHERE  lines.budget_revision_id    = p_budget_revision_id
    AND    lines.budget_revision_acct_line_id =
				       acct.budget_revision_acct_line_id
    AND      acct.budget_group_id in
	       (  SELECT budget_group_id
		    FROM psb_budget_groups
		   WHERE budget_group_type = 'R'
		     AND effective_start_date <= sysdate
		     AND ((effective_end_date IS NULL)
			   OR
			  (effective_end_date >= sysdate))
		  START WITH budget_group_id = p_budget_group_id
		  CONNECT BY PRIOR budget_group_id = parent_budget_group_id
	       )
  )
  LOOP

    debug('Budget Revision Account line id '||
				      l_lines_rec.budget_revision_acct_line_id);
    --
    -- Put the account line ids in the psb_budget_revision_lines table
    -- for the new budget revision.
    --
    Insert_BR_Lines_Pvt
    ( p_budget_revision_id           => l_new_budget_revision_id,
      p_budget_revision_acct_line_id =>
				     l_lines_rec.budget_revision_acct_line_id,
      p_freeze_flag                  => l_lines_rec.freeze_flag,
      p_view_line_flag               => l_lines_rec.view_line_flag,
      p_last_update_date             => g_current_date,
      p_last_updated_by              => g_current_user_id,
      p_last_update_login            => g_current_login_id,
      p_created_by                   => g_current_user_id,
      p_creation_date                => g_current_date,
      p_return_status                => l_return_status
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
  -- Maintain psb_budget_revision_pos_lines if budget revision
  -- contains positions.(This also means the budget revision includes
  -- position budgeting.)
  --
  OPEN  l_budget_by_position_csr;
  FETCH l_budget_by_position_csr INTO g_budget_by_position;
  CLOSE l_budget_by_position_csr;

  IF g_budget_by_position IS NOT NULL THEN

    debug('l_budget_by_position loop');

    --
    -- This loop gets all the position_line_id for the new worksheet which will
    -- be used to maintain psb_ws_lines_positions table.
    --
    FOR l_lines_rec IN
    (
      SELECT lines.*
      FROM   psb_budget_revision_pos_lines   lines ,
	     psb_budget_revision_positions   pos
      WHERE  lines.budget_revision_id      = p_budget_revision_id
      AND    lines.budget_revision_pos_line_id
					   = pos.budget_revision_pos_line_id
      AND    pos.budget_group_id in
		       (
			 SELECT bg.budget_group_id
			   FROM psb_budget_groups bg
			  WHERE budget_group_type = 'R'
			    AND effective_start_date <= sysdate
			    AND ((effective_end_date IS NULL)
				  OR
				 (effective_end_date >= sysdate))
			 START WITH bg.budget_group_id = p_budget_group_id
			 CONNECT BY PRIOR bg.budget_group_id =
						     bg.parent_budget_group_id
			)
    )
    LOOP
      --
      debug('Budget Revision Position line id '||
				      l_lines_rec.budget_revision_pos_line_id);

      -- Put the budget_revision_pos_line_id in the
      -- psb_budget_revision_pos_lines
      -- table for the new budget revision.

      Insert_BR_Pos_Lines_Pvt
      ( p_budget_revision_id           => l_new_budget_revision_id,
	p_budget_revision_pos_line_id =>
				     l_lines_rec.budget_revision_pos_line_id,
	p_freeze_flag                  => l_lines_rec.freeze_flag,
	p_view_line_flag               => l_lines_rec.view_line_flag,
	p_last_update_date             => g_current_date,
	p_last_updated_by              => g_current_user_id,
	p_last_update_login            => g_current_login_id,
	p_created_by                   => g_current_user_id,
	p_creation_date                => g_current_date,
	p_return_status                => l_return_status
      );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
      --
      --
    END LOOP;

  END IF; -- end of check for g_budget_by_position

  p_budget_revision_id_out := l_new_budget_revision_id;

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
    ROLLBACK TO Create_Budget_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Create_Budget_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_budget_revisions_csr%ISOPEN ) THEN
      CLOSE l_budget_revisions_csr ;
    END IF ;
    --
    ROLLBACK TO Create_Budget_Revision_Pvt ;
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

END Create_Budget_Revision;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                       PROCEDURE Freeze_Budget_Revision                    |
 +===========================================================================*/
--
-- This API freezes a given budget revision.
--
PROCEDURE Freeze_Budget_Revision
(
  p_api_version            IN       NUMBER   ,
  p_init_msg_list          IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                 IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level       IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status          OUT  NOCOPY      VARCHAR2 ,
  p_msg_count              OUT  NOCOPY      NUMBER   ,
  p_msg_data               OUT  NOCOPY      VARCHAR2 ,
  --
  p_budget_revision_id     IN       NUMBER,
  p_freeze_flag            IN       VARCHAR2
)
IS
  --
  l_api_name                     CONSTANT VARCHAR2(30)  := 'Freeze_Budget_Revision' ;
  l_api_version                  CONSTANT NUMBER        :=  1.0 ;
  --
  l_return_status                VARCHAR2(1) ;
  l_msg_count                    NUMBER ;
  l_msg_data                     VARCHAR2(2000) ;
  --
  l_parent_budget_revision_id    psb_budget_revisions.budget_revision_id%TYPE ;
  l_budget_revision_id           psb_budget_revisions.budget_revision_id%TYPE ;
  l_parent_freeze_flag           psb_budget_revisions.freeze_flag%TYPE ;
  --
BEGIN
  --
  SAVEPOINT Freeze_Budget_Revision_Pvt ;
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
  -- A budget revision can only be unfrozen if the parent budget revision is not
  -- frozen ( p_freeze_flag = 'N' identifies an unfreeze operation).
  --
  IF p_freeze_flag = 'N' THEN

    -- Find parent budget revision, if exists.

    Find_Parent_Budget_Revision
    (
      p_api_version             => 1.0 ,
      p_init_msg_list           => FND_API.G_FALSE,
      p_commit                  => FND_API.G_FALSE,
      p_validation_level        => FND_API.G_VALID_LEVEL_NONE,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data ,
      --
      p_budget_revision_id      => p_budget_revision_id ,
      p_budget_revision_id_OUT  => l_parent_budget_revision_id
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Check the freeze_flag for the parent worksheet.
    IF l_parent_budget_revision_id <> 0 THEN

      SELECT NVL(freeze_flag, 'N') INTO l_parent_freeze_flag
      FROM   psb_budget_revisions
      WHERE  budget_revision_id = l_parent_budget_revision_id;

      IF l_parent_freeze_flag = 'Y' THEN

	Fnd_Message.Set_Name('PSB','PSB_CANNOT_UNFREEZE_REVISION') ;
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR ;

      END IF ;

    END IF ;

  END IF ; -- For p_freeze_flag = 'N' condition.

  --
  -- Update freeze_flag in psb_budget_revisions.
  --
  l_budget_revision_id := p_budget_revision_id;


  /* Code split into 2 conditions if and elsif to make request_id
     null in case of unfreeze. Changed by Siva on 07/17/00 to resolve bug 1303434 */
  IF p_freeze_flag = 'Y' THEN
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
     p_freeze_flag                 => p_freeze_flag
     );
  ELSIF p_freeze_flag = 'N' THEN

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
     p_freeze_flag                 => p_freeze_flag,
     p_request_id                  => NULL
     );

  END IF;
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --
  -- Update freeze_flag in psb_budget_revision_lines.

  UPDATE psb_budget_revision_lines
  SET    freeze_flag  = p_freeze_flag
  WHERE  budget_revision_id = p_budget_revision_id;

  IF g_budget_by_position IS NOT NULL THEN
    --
    -- Update freeze_flag in psb_budget_revision_pos_lines.
    --
    UPDATE psb_budget_revision_pos_lines
    SET    freeze_flag  = p_freeze_flag
    WHERE  budget_revision_id = p_budget_revision_id;
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
    ROLLBACK TO Freeze_Budget_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Freeze_Budget_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Freeze_Budget_Revision_Pvt ;
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
END Freeze_Budget_Revision;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                   PROCEDURE Find_Parent_Budget_Revision                   |
 +===========================================================================*/
--
-- The API finds parent budget revision of a given budget revision.
--
PROCEDURE Find_Parent_Budget_Revision
(
  p_api_version             IN       NUMBER,
  p_init_msg_list           IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status           OUT  NOCOPY      VARCHAR2,
  p_msg_count               OUT  NOCOPY      NUMBER,
  p_msg_data                OUT  NOCOPY      VARCHAR2,
  --
  p_budget_revision_id      IN       NUMBER,
  p_budget_revision_id_OUT  OUT  NOCOPY      NUMBER
)
IS
  --
  l_api_name                      CONSTANT VARCHAR2(30)
					    := 'Find_Parent_Budget_Revision';
  l_api_version                   CONSTANT NUMBER :=  1.0;
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  --
  l_global_budget_revision_id     NUMBER;
  l_global_budget_revision        VARCHAR2(1);
  l_budget_group_id               NUMBER;
  l_global_budget_group_id        NUMBER;
  --
  l_parent_budget_group_id  NUMBER;
  --
BEGIN
  --
  SAVEPOINT Find_Parent_Revision_Pvt ;
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
  p_budget_revision_id_OUT := -99 ;
  --
  --
  -- Finding the budget revision information.
  --
  SELECT br.budget_group_id,
	 br.global_budget_revision_id,
	 br.global_budget_revision,
	 bg.parent_budget_group_id
      INTO
	 l_budget_group_id,
	 l_global_budget_revision_id,
	 l_global_budget_revision,
	 l_parent_budget_group_id
  FROM   psb_budget_revisions    br,
	 psb_budget_groups       bg
  WHERE  br.budget_revision_id  = p_budget_revision_id
  AND    br.budget_group_id = bg.budget_group_id ;

  IF (l_global_budget_revision = 'Y') OR
				       (l_parent_budget_group_id IS NULL) THEN
    --
    p_budget_revision_id_OUT := 0 ;
    RETURN ;
  END IF ;

  --
  -- Find global budget_group_id for the global budget revision.
  --
  SELECT budget_group_id INTO l_global_budget_group_id
  FROM   psb_budget_revisions
  WHERE  budget_revision_id = l_global_budget_revision_id;

  --
  -- If parent budget group for the current budget revision is same as the budget
  -- group for the global budget revision, then the global budget revision
  -- is the parent budget revision for the given budget revision.
  --
  IF l_global_budget_group_id = l_parent_budget_group_id THEN
    p_budget_revision_id_OUT := l_global_budget_revision_id ;
    RETURN ;
  END IF ;
  --
  -- Get the desired parent budget revision at the
  -- l_parent_budget_group_id level.
  --
  BEGIN

    --
    -- New way to find if a revision has been created for a budget group.
    -- ( Bug#2832148 )
    --
    SELECT budget_revision_id INTO p_budget_revision_id_OUT
    FROM   psb_budget_revisions
    WHERE  global_budget_revision_id = l_global_budget_revision_id
    AND    budget_group_id           = l_parent_budget_group_id ;

    /*
    SELECT DISTINCT child_worksheet_id INTO p_budget_revision_id_OUT
    FROM   psb_ws_distribution_details details, psb_ws_distributions distr
    WHERE  distr.worksheet_id               = p_budget_revision_id
    AND    distr.distribution_option_flag   = 'R'
    AND    details.global_worksheet_id      = l_global_budget_revision_id
    AND    details.child_budget_group_id    = l_parent_budget_group_id;
    */

  --
  --
  EXCEPTION
    WHEN no_data_found THEN
      --
      -- Cannot use FND_API.G_MISS_NUM as budget_revision_id is NUMBER(20) only.
      --
      p_budget_revision_id_OUT := 0 ;
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
    ROLLBACK TO Find_Parent_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Find_Parent_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Find_Parent_Revision_Pvt ;
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
END Find_Parent_Budget_Revision;
/*---------------------------------------------------------------------------*/
/*===========================================================================+
 |                   PROCEDURE Find_Parent_Budget_Revisions                  |
 +===========================================================================*/
--
-- The API finds parent budget revisions of a given budget revision
-- in a PL/SQL table.
--
PROCEDURE Find_Parent_Budget_Revisions
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_budget_revision_id        IN       NUMBER,
  p_budget_revision_tbl       IN OUT  NOCOPY   Budget_Revision_Tbl_Type
)
IS
  --
  l_api_name                           CONSTANT VARCHAR2(30) :=
					       'Find_Parent_Budget_Revisions';
  l_api_version                        CONSTANT NUMBER :=  1.0;
  l_return_status                      VARCHAR2(1);
  l_msg_count                          NUMBER;
  l_msg_data                           VARCHAR2(2000);
  --
  l_current_budget_revision_id         NUMBER;
  l_parent_budget_revision_id          NUMBER;
  --
  l_count                              NUMBER;
  --
BEGIN
  --
  SAVEPOINT Find_Parent_Revisions_Pvt;
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
  p_budget_revision_tbl.DELETE;
  l_current_budget_revision_id := p_budget_revision_id ;

  LOOP
    --
    -- Find the parent budget revision for the current budget revision.
    --
    PSB_Create_BR_Pvt.Find_Parent_Budget_Revision
    (
       p_api_version             =>   1.0,
       p_init_msg_list           =>   FND_API.G_FALSE,
       p_commit                  =>   FND_API.G_FALSE,
       p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status           =>   l_return_status,
       p_msg_count               =>   l_msg_count,
       p_msg_data                =>   l_msg_data,
       --
       p_budget_revision_id      =>   l_current_budget_revision_id,
       p_budget_revision_id_OUT  =>   l_parent_budget_revision_id
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    IF l_parent_budget_revision_id = 0 THEN

      -- It means all the parent budget revisions has been retrieved.
      EXIT ;
      --
    ELSE
      --
      -- Insert the budget revision in the table.
      --
      l_count                        := l_count + 1;
      p_budget_revision_tbl(l_count) := l_parent_budget_revision_id;
      l_current_budget_revision_id   := l_parent_budget_revision_id;
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
    ROLLBACK TO Find_Parent_Revisions_Pvt;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Find_Parent_Revisions_Pvt;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Find_Parent_Revisions_Pvt;
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
END Find_Parent_Budget_Revisions;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                   PROCEDURE Find_Child_Budget_Revisions                   |
 +===========================================================================*/
--
-- The API finds all the child budget revisions of a
-- budget revision in a PL/SQL table.
--
PROCEDURE Find_Child_Budget_Revisions
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_budget_revision_id        IN       NUMBER,
  p_budget_revision_tbl       IN OUT  NOCOPY   Budget_Revision_Tbl_Type
)
IS
  --
  l_api_name                        CONSTANT VARCHAR2(30)
					    := 'Find_Child_Budget_Revisions';
  l_api_version                     CONSTANT NUMBER :=  1.0 ;
  l_return_status                   VARCHAR2(1);
  l_msg_count                       NUMBER;
  l_msg_data                        VARCHAR2(2000);
  --
  l_child_budget_revision_id        NUMBER;
  l_global_budget_revision_id       NUMBER;
  l_global_budget_revision          VARCHAR2(1);
  l_budget_group_id                 NUMBER;
  l_budget_calendar_id              NUMBER;
  --
  l_count                           NUMBER ;
  --
BEGIN
  --
  SAVEPOINT Find_Child_Revisions_Pvt;
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
  p_budget_revision_tbl.DELETE ;
  --

  --
  -- Get budget revision information for the p_budget_revision_id .
  --
  SELECT budget_group_id                       ,
	 global_budget_revision_id                   ,
	 NVL( global_budget_revision ,  'N' )
    INTO
	 l_budget_group_id                     ,
	 l_global_budget_revision_id                 ,
	 l_global_budget_revision
  FROM   psb_budget_revisions
  WHERE  budget_revision_id = p_budget_revision_id ;

  IF l_global_budget_revision = 'Y' THEN
    l_global_budget_revision_id := p_budget_revision_id ;
  END IF ;
  --
  l_count  := 0 ;

  --
  -- Process all the lower level budget groups to fine budget revisions.
  --
  FOR l_budget_group_rec IN
  (
     SELECT budget_group_id
       FROM psb_budget_groups
      WHERE budget_group_type          = 'R'
	AND effective_start_date <= sysdate
	AND ((effective_end_date IS NULL)
	     OR
	     (effective_end_date >= sysdate))
     START WITH budget_group_id       = l_budget_group_id
     CONNECT BY PRIOR budget_group_id = parent_budget_group_id
  )
  LOOP

    --
    -- The hierarchial query will also return the l_budget_group_id.
    -- Do not consider it.
    --
    IF l_budget_group_rec.budget_group_id <> l_budget_group_id THEN

      l_child_budget_revision_id := NULL ;

      --
      -- Get the budget_revision_id at the current budget_group_level.
      --
      BEGIN

        --
        -- New way to find if a revision has been created for a budget group.
        -- ( Bug#2832148 )
        --
        SELECT budget_revision_id INTO l_child_budget_revision_id
        FROM   psb_budget_revisions
        WHERE  global_budget_revision_id = l_global_budget_revision_id
        AND    budget_group_id           = l_budget_group_rec.budget_group_id ;

        /*
	SELECT child_worksheet_id INTO l_child_budget_revision_id
	FROM   psb_ws_distribution_details details, psb_ws_distributions distr
	WHERE  distr.worksheet_id               = p_budget_revision_id
	AND    distr.distribution_option_flag   = 'R'
	AND    details.global_worksheet_id   = l_global_budget_revision_id
	AND    details.child_budget_group_id =
					l_budget_group_rec.budget_group_id
	AND    ROWNUM < 2 ;
        */

      EXCEPTION
	WHEN no_data_found THEN
	  --
	  -- Means the budget revision has not been distributed to this level.
	  -- Simply ignore it.
	  --
	  NULL ;
      END ;

      debug( 'BG id ' || l_budget_group_rec.budget_group_id ||
	  ' BR id ' || l_child_budget_revision_id ) ;

      --
      -- Insert the budget revision in the p_budget_revision_tbl table
      --
      IF l_child_budget_revision_id IS NOT NULL THEN
	l_count := l_count + 1 ;
	p_budget_revision_tbl( l_count ) := l_child_budget_revision_id ;
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
    ROLLBACK TO Find_Child_Revisions_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Find_Child_Revisions_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Find_Child_Revisions_Pvt ;
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
END Find_Child_Budget_Revisions ;
/*---------------------------------------------------------------------------*/
/*===========================================================================+
 |                     PROCEDURE Update_Target_Budget_Revision               |
 +===========================================================================*/
--
-- The API takes 2 budget revisions, source and target. It updates target
-- budget revision by adding new account or position lines if they are their
-- in the source budget revision and not in the target budget revision.
-- It also updates the budget revision submission related columns in
-- the source budget revision.
--
PROCEDURE Update_Target_Budget_Revision
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_source_budget_revision_id IN       NUMBER,
  p_revision_option_flag      IN       VARCHAR2,
  p_target_budget_revision_id IN       NUMBER
)
IS
  --
  l_api_name                           CONSTANT VARCHAR2(30)
						:= 'Update_Target_Budget Revision' ;
  l_api_version                        CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status                      VARCHAR2(1) ;
  l_msg_count                          NUMBER ;
  l_msg_data                           VARCHAR2(2000) ;
  --
  l_source_budget_group_id             NUMBER;
  l_source_local_copy_flag             VARCHAR2(1);
  l_source_global_budget_rev_id        NUMBER;
  l_source_global_budget_rev           VARCHAR(1);
  l_freeze_flag                        VARCHAR(1);
  l_source_budget_by_position          NUMBER;
  --
  l_target_budget_group_id             NUMBER;
  l_target_budget_revision_id          NUMBER;
  l_target_global_budget_rev_id        NUMBER;
  --
  l_budget_calendar_id                 NUMBER;
  l_br_lines_rec                       psb_budget_revision_lines%ROWTYPE;
  l_br_lines_pos_rec                   psb_budget_revision_pos_lines%ROWTYPE;

  CURSOR l_budget_by_position_csr IS
	 SELECT count(*)
	 FROM   psb_budget_revision_pos_lines lines,
		psb_budget_revisions rev
	 WHERE  rev.budget_revision_id = p_source_budget_revision_id
	   AND  rev.budget_revision_id = lines.budget_revision_id;

BEGIN
  --
  SAVEPOINT Update_Target_Revision_Pvt ;
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
  -- Update budget revision submission related columns in the target
  -- budget revision.
  --
  l_target_budget_revision_id := p_target_budget_revision_id;

   if ((p_revision_option_flag is not null ) and (p_revision_option_flag = 'N')) then
     l_freeze_flag := 'Y';
  end if;

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
     p_freeze_flag                 => l_freeze_flag,
     p_budget_revision_id          => l_target_budget_revision_id
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --
  -- Find the source budget revision information.
  --
  SELECT budget_group_id,
	 global_budget_revision_id,
	 NVL( global_budget_revision,  'N' )
       INTO
	 l_source_budget_group_id,
	 l_source_global_budget_rev_id,
	 l_source_global_budget_rev
  FROM   psb_budget_revisions
  WHERE  budget_revision_id = p_source_budget_revision_id ;

  IF l_source_global_budget_rev = 'Y' THEN
    l_source_global_budget_rev_id := p_source_budget_revision_id ;
  END IF ;

  --
  -- Find the target budget revision information. The target budget revision
  -- will never be the top budget revision i.e. global_budget_revision
  -- is always 'N'.
  --
  SELECT budget_group_id,
	 global_budget_revision_id
      INTO
	 l_target_budget_group_id,
	 l_target_global_budget_rev_id
  FROM   psb_budget_revisions
  WHERE  budget_revision_id = p_target_budget_revision_id ;
  --
  --
  --
  -- Find account_line_id to be inserted into target budget revision.
  -- ( The hierarchial query will select lines falling in the subtreee, the
  --   target budget revision belongs. We will not consider other lines. )
  --
  FOR l_account_line_id_rec IN
  (
    SELECT lines.budget_revision_acct_line_id
    FROM   psb_budget_revision_lines     lines,
	   psb_budget_revision_accounts  acct
    WHERE  lines.budget_revision_id               = p_source_budget_revision_id
    AND    lines.budget_revision_acct_line_id
						  =
					   acct.budget_revision_acct_line_id
    AND    acct.budget_group_id in
	       (  SELECT budget_group_id
		    FROM psb_budget_groups
		   WHERE budget_group_type = 'R'
		     AND effective_start_date <= sysdate
		     AND ((effective_end_date IS NULL)
			   OR
			  (effective_end_date >= sysdate))
		  START WITH budget_group_id       = l_target_budget_group_id
		  CONNECT BY PRIOR budget_group_id = parent_budget_group_id
	       )
     MINUS
     SELECT lines.budget_revision_acct_line_id
     FROM   psb_budget_revision_lines lines
     WHERE  budget_revision_id = p_target_budget_revision_id
  )
  LOOP

    SELECT * INTO l_br_lines_rec
    FROM   psb_budget_revision_lines
    WHERE  budget_revision_id    = p_source_budget_revision_id
    AND    budget_revision_acct_line_id =
			   l_account_line_id_rec.budget_revision_acct_line_id ;

    --
    -- Each account_line_id found is the account_line_id missing in the
    -- target budget revision. Add the account_line_id to the
    -- target budget revision.
    --
    Insert_BR_Lines_Pvt
    (
       p_budget_revision_id           =>  p_target_budget_revision_id,
       p_budget_revision_acct_line_id =>
			  l_br_lines_rec.budget_revision_acct_line_id,
       p_freeze_flag                  => l_br_lines_rec.freeze_flag,
       p_view_line_flag               => l_br_lines_rec.view_line_flag,
       p_last_update_date             => g_current_date,
       p_last_updated_by              => g_current_user_id,
       p_last_update_login            => g_current_login_id,
       p_created_by                   => g_current_user_id,
       p_creation_date                => g_current_date,
       p_return_status                => l_return_status
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
  -- Find budget_revision_pos_line_id to be inserted into
  -- target budget revision.
  -- ( The hierarchial query will select lines falling in the sub-tree,
  -- the target budget revision belongs. We will not consider other lines. )
  --
  OPEN l_budget_by_position_csr;
  FETCH l_budget_by_position_csr INTO l_source_budget_by_position;
  CLOSE l_budget_by_position_csr;

  IF l_source_budget_by_position IS NOT NULL THEN
    --
    FOR l_lines_pos_rec IN
    (
      SELECT lines.budget_revision_pos_line_id
      FROM   psb_budget_revision_pos_lines   lines ,
	     psb_budget_revision_positions   pos
      WHERE  lines.budget_revision_id = p_source_budget_revision_id
      AND    lines.budget_revision_pos_line_id
					 = pos.budget_revision_pos_line_id
      AND    pos.budget_group_id in
		     (
		       SELECT bg.budget_group_id
			 FROM psb_budget_groups bg
			WHERE bg.budget_group_type = 'R'
			  AND effective_start_date <= sysdate
			  AND ((effective_end_date IS NULL)
				OR
			       (effective_end_date >= sysdate))
		       START WITH bg.budget_group_id = l_target_budget_group_id
		       CONNECT BY PRIOR bg.budget_group_id =
						   bg.parent_budget_group_id
		      )
       MINUS
       SELECT budget_revision_pos_line_id
       FROM   psb_budget_revision_pos_lines
       WHERE  budget_revision_id = p_target_budget_revision_id
    )
    LOOP

      SELECT * INTO l_br_lines_pos_rec
      FROM   psb_budget_revision_pos_lines
      WHERE  budget_revision_id     = p_source_budget_revision_id
      AND    budget_revision_pos_line_id
			       = l_lines_pos_rec.budget_revision_pos_line_id ;

      --
      -- Each budget_revision_pos_line_id found is the one missing in the target
      -- budget revision. Add it to the target budget revision.
      --
      Insert_BR_Pos_Lines_Pvt
      ( p_budget_revision_id           => p_target_budget_revision_id,
	p_budget_revision_pos_line_id =>
			       l_br_lines_pos_rec.budget_revision_pos_line_id,
	p_freeze_flag                  => l_br_lines_pos_rec.freeze_flag,
	p_view_line_flag               => l_br_lines_pos_rec.view_line_flag,
	p_last_update_date             => g_current_date,
	p_last_updated_by              => g_current_user_id,
	p_last_update_login            => g_current_login_id,
	p_created_by                   => g_current_user_id,
	p_creation_date                => g_current_date,
	p_return_status                => l_return_status
      );
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
    ROLLBACK TO Update_Target_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Update_Target_Revision_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Update_Target_Revision_Pvt ;
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
END Update_Target_Budget_Revision ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                 PROCEDURE Insert_BR_Lines_Pvt ( Private )                 |
 +===========================================================================*/
--
-- The private procedure inserts a new record in psb_ws_lines table.
--
PROCEDURE Insert_BR_Lines_Pvt
(
  p_budget_revision_id            IN  NUMBER,
  p_budget_revision_acct_line_id  IN  NUMBER,
  p_freeze_flag                   IN  VARCHAR2,
  p_view_line_flag                IN  VARCHAR2,
  p_last_update_date              IN  DATE,
  p_last_updated_by               IN  NUMBER,
  p_last_update_login             IN  NUMBER,
  p_created_by                    IN  NUMBER,
  p_creation_date                 IN  DATE,
  p_return_status                 OUT  NOCOPY VARCHAR2
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30) := 'Insert_BR_Lines_Pvt' ;
  --
BEGIN
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  update psb_budget_revision_lines
     set freeze_flag       = p_freeze_flag,
	 view_line_flag    = p_view_line_flag,
	 last_update_date  = g_current_date,
	 last_updated_by   = g_current_user_id,
	 last_update_login = g_current_login_id
   where budget_revision_acct_line_id   = p_budget_revision_acct_line_id
     and budget_revision_id      = p_budget_revision_id;

  IF SQL%NOTFOUND THEN

    INSERT INTO psb_budget_revision_lines
	   (
	     budget_revision_id,
	     budget_revision_acct_line_id,
	     freeze_flag,
	     view_line_flag,
	     last_update_date,
	     last_updated_by,
	     last_update_login,
	     created_by,
	     creation_date
	   )
	 VALUES
	   (
	     p_budget_revision_id,
	     p_budget_revision_acct_line_id,
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
END Insert_BR_Lines_Pvt ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                 PROCEDURE Insert_BR_Pos_Lines_Pvt ( Private )             |
 +===========================================================================*/
--
-- The private procedure inserts a new record in
-- psb_budget_revision_pos_lines table.
--
PROCEDURE Insert_BR_Pos_Lines_Pvt
(
  p_budget_revision_id             IN  NUMBER,
  p_budget_revision_pos_line_id    IN  NUMBER,
  p_freeze_flag                    IN  VARCHAR2,
  p_view_line_flag                 IN  VARCHAR2,
  p_last_update_date               IN  DATE,
  p_last_updated_by                IN  NUMBER,
  p_last_update_login              IN  NUMBER,
  p_created_by                     IN  NUMBER,
  p_creation_date                  IN  DATE,
  p_return_status                  OUT  NOCOPY VARCHAR2
)
IS
  --
  l_api_name                 CONSTANT VARCHAR2(30) := 'Insert_BR_Pos_Lines_Pvt' ;
  --
BEGIN
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  update psb_budget_revision_pos_lines
     set freeze_flag       = p_freeze_flag,
	 view_line_flag    = p_view_line_flag,
	 last_update_date  = g_current_date,
	 last_updated_by   = g_current_user_id,
	 last_update_login = g_current_login_id
   where budget_revision_pos_line_id   = p_budget_revision_pos_line_id
     and budget_revision_id      = p_budget_revision_id;

  IF SQL%NOTFOUND THEN

    INSERT INTO psb_budget_revision_pos_lines
	   (
	     budget_revision_id,
	     budget_revision_pos_line_id,
	     freeze_flag,
	     view_line_flag,
	     last_update_date,
	     last_updated_by,
	     last_update_login,
	     created_by,
	     creation_date
	   )
	 VALUES
	   (
	     p_budget_revision_id,
	     p_budget_revision_pos_line_id,
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
END Insert_BR_Pos_Lines_Pvt ;
/*---------------------------------------------------------------------------*/
/*===========================================================================+
 |                     PROCEDURE pd (Private)                                |
 +===========================================================================*/
--
-- Private procedure to print debug info. The name is tried to keep as
-- short as possible for better documentaion.
--
PROCEDURE debug
(
   p_message                   IN   VARCHAR2
)
IS
--
BEGIN

  IF g_debug_flag = 'Y' THEN
    null;
--  DBMS_OUTPUT.Put_Line(p_message) ;
  END IF;

END debug ;
/*---------------------------------------------------------------------------*/


END PSB_Create_BR_Pvt ;

/
