--------------------------------------------------------
--  DDL for Package PSB_SUBMIT_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_SUBMIT_WORKSHEET_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWSSPS.pls 120.2 2005/07/13 11:38:06 shtripat ship $ */

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
  p_review_group_flag         IN       VARCHAR2 := 'N' ,
  p_orig_system               IN       VARCHAR2 ,
  p_merge_to_worksheet_id     IN       psb_worksheets.worksheet_id%TYPE ,
  p_comments                  IN       VARCHAR2 ,
  p_operation_id              IN       NUMBER   ,
  p_constraint_set_id         IN       NUMBER
);


PROCEDURE Populate_Worksheet
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Enforce_Concurrency_Check
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Perform_Validation
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Validate_Constraints
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Select_Operation
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Copy_Worksheet
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Merge_Worksheets
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Freeze_Worksheets
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Update_View_Line_Flag
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Change_Worksheet_Stage
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Perform_Review_Group_Approval
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Select_Approvers
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Set_Loop_Limit
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Create_Review_Group_Worksheet
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE New_Worksheet_Created
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Find_Approval_Option
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Unfreeze_Worksheets
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Set_Reviewed_Flag
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Send_Approval_Notification
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Update_Worksheets_Status
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Callback
(
  command           IN       VARCHAR2,
  context           IN       VARCHAR2,
  attr_name         IN       VARCHAR2,
  attr_type         IN       VARCHAR2,
  text_value        IN OUT  NOCOPY   VARCHAR2,
  number_value      IN OUT  NOCOPY   NUMBER,
  date_value        IN OUT  NOCOPY   DATE
);


PROCEDURE Check_Review_Groups
(
  p_api_version          IN     NUMBER   ,
  p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE ,
  p_commit               IN     VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status        OUT  NOCOPY    VARCHAR2 ,
  p_msg_count            OUT  NOCOPY    NUMBER   ,
  p_msg_data             OUT  NOCOPY    VARCHAR2 ,
  --
  p_worksheet_id         IN     psb_worksheets.worksheet_id%TYPE ,
  p_review_group_exists  OUT  NOCOPY    VARCHAR2
);


END PSB_Submit_Worksheet_PVT ;

 

/
