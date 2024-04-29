--------------------------------------------------------
--  DDL for Package PSB_SUBMIT_REVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_SUBMIT_REVISION_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVBRSS.pls 120.2.12010000.3 2009/05/04 09:57:00 rkotha ship $ */

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
);


PROCEDURE Populate_Revision
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


PROCEDURE Freeze_Revisions
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


PROCEDURE Select_Approvers
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Find_Override_Approver
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);


PROCEDURE Unfreeze_Revisions
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

PROCEDURE Set_Reviewed_Flag
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);

PROCEDURE Set_Approval_Status
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);

PROCEDURE Set_Rejection_Status
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


PROCEDURE Update_Revisions_Status
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);

PROCEDURE Post_Revisions_To_GL
(
  itemtype        IN  VARCHAR2   ,
  itemkey         IN  VARCHAR2   ,
  actid           IN  NUMBER     ,
  funcmode        IN  VARCHAR2   ,
  result          OUT  NOCOPY VARCHAR2
);

PROCEDURE Update_Baseline_Values
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
);


PROCEDURE Funds_Reservation_Update
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
);

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
);


PROCEDURE Populate_Distribute_Revision
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
);

PROCEDURE Set_Loop_Limit
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
);

PROCEDURE Find_Approver
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
);

PROCEDURE Find_Requestor
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
);

/* Budget Revison Rules Enhancement Start */

PROCEDURE Validate_Revision_Rules
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  result                      OUT  NOCOPY      VARCHAR2
);

/* Budget Revison Rules Enhancement End */

/*Bug:6281823:start*/
procedure Selector(itemtype    in varchar2,
                   itemkey     in varchar2,
                   actid       in number,
                   command     in varchar2,
                   resultout   out nocopy varchar2);
/*Bug:6281823:end*/

END PSB_Submit_Revision_PVT;

/
