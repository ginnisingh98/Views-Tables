--------------------------------------------------------
--  DDL for Package PSB_WS_OPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_OPS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVWLOS.pls 120.2 2005/07/13 11:31:14 shtripat ship $ */


-- Record type to store a set_id and its account or position type.
TYPE account_position_set_rec_type IS RECORD
	     ( account_position_set_id
		       psb_account_position_sets.account_position_set_id%TYPE ,
	       account_or_position_type
		       psb_account_position_sets.account_or_position_type%TYPE
	     );

-- Table type to store a set_id and its account or position type.
TYPE account_position_set_tbl_type IS TABLE OF account_position_set_rec_type
     INDEX BY BINARY_INTEGER;

--
--  Table type to store Worksheet_Id
--
TYPE Worksheet_Tbl_Type IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;


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
);


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
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE  ,
  p_operation_type            IN       VARCHAR2
);


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
);


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
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE     ,
  p_budget_group_id           IN       psb_worksheets.budget_group_id%TYPE  ,
  p_worksheet_id_OUT          OUT  NOCOPY      psb_worksheets.worksheet_id%TYPE
);


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
);


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
  p_source_worksheet_id       IN       psb_worksheets.worksheet_id%TYPE  ,
  p_target_worksheet_id       IN       psb_worksheets.worksheet_id%TYPE
);


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
);


PROCEDURE Add_Worksheet_Line
(
  p_api_version               IN      NUMBER   ,
  p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY     VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY     NUMBER   ,
  p_msg_data                  OUT  NOCOPY     VARCHAR2 ,
  --
  p_worksheet_id              IN      psb_worksheets.worksheet_id%TYPE   ,
  p_account_line_id           IN      psb_ws_account_lines.account_line_id%TYPE,
  p_add_in_current_worksheet  IN      VARCHAR2 := FND_API.G_FALSE
);


PROCEDURE Add_Worksheet_Line
( p_api_version       IN      NUMBER   ,
  p_init_msg_list     IN      VARCHAR2 := FND_API.G_FALSE ,
  p_commit            IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level  IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status     OUT  NOCOPY     VARCHAR2 ,
  p_msg_count         OUT  NOCOPY     NUMBER   ,
  p_msg_data          OUT  NOCOPY     VARCHAR2 ,
  p_worksheet_id      IN      NUMBER,
  p_position_line_id  IN      NUMBER
);


PROCEDURE Add_Line_To_Worksheets
(
  p_api_version               IN      NUMBER   ,
  p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY     VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY     NUMBER   ,
  p_msg_data                  OUT  NOCOPY     VARCHAR2 ,
  --
  p_account_line_id           IN      psb_ws_account_lines.account_line_id%TYPE,
  p_worksheet_tbl             IN      Worksheet_Tbl_Type
);


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
);


PROCEDURE Add_Pos_Line_To_Worksheets
(
  p_api_version               IN    NUMBER   ,
  p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN    VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY   VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY   NUMBER   ,
  p_msg_data                  OUT  NOCOPY   VARCHAR2 ,
  --
  p_position_line_id          IN    psb_ws_position_lines.position_line_id%TYPE,
  p_worksheet_tbl             IN    Worksheet_Tbl_Type
);


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
);


PROCEDURE Change_Worksheet_Stage
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
  p_stage_seq                 IN       psb_worksheets.current_stage_seq%TYPE
				       := FND_API.G_MISS_NUM ,
  p_operation_id              IN       NUMBER := FND_API.G_MISS_NUM
);



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
);


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
);


PROCEDURE Find_Child_Worksheets
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2 ,
  p_msg_count           OUT  NOCOPY     NUMBER   ,
  p_msg_data            OUT  NOCOPY     VARCHAR2 ,
  --
  p_worksheet_id        IN      psb_worksheets.worksheet_id%TYPE ,
  p_worksheet_tbl       IN OUT  NOCOPY  Worksheet_Tbl_Type
);


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
);


PROCEDURE Delete_Worksheet_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id              IN       NUMBER  ,
  p_keep_local_copy_flag      IN       VARCHAR2
);


PROCEDURE Create_New_Position_Worksheet
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
  p_service_package_operation_id
			      IN       NUMBER := FND_API.G_MISS_NUM ,
  p_worksheet_id_OUT          OUT  NOCOPY      psb_worksheets.worksheet_id%TYPE
);


END PSB_WS_Ops_Pvt ;

 

/
