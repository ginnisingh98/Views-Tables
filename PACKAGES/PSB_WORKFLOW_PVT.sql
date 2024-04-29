--------------------------------------------------------
--  DDL for Package PSB_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WORKFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWKFLS.pls 120.2 2005/07/13 11:34:44 shtripat ship $ */

PROCEDURE Distribute_WS
(
  ERRBUF                      OUT  NOCOPY      VARCHAR2,
  RETCODE                     OUT  NOCOPY      VARCHAR2,
  --
  p_distribution_id           IN       NUMBER,
  p_submitter_id              IN       NUMBER,
  p_export_name               IN       VARCHAR2
);


PROCEDURE Submit_WS
(
  ERRBUF                      OUT  NOCOPY      VARCHAR2,
  RETCODE                     OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id              IN       psb_worksheets.worksheet_id%TYPE ,
  p_submitter_id              IN       NUMBER   ,
  p_operation_type            IN       VARCHAR2 ,
  p_review_group_flag         IN       VARCHAR2 := 'N' ,
  p_orig_system               IN       VARCHAR2 ,
  p_merge_to_worksheet_id     IN       psb_worksheets.worksheet_id%TYPE ,
  p_comments                  IN       VARCHAR2 ,
  p_operation_id              IN       NUMBER   ,
  p_constraint_set_id         IN       NUMBER
);

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
);

PROCEDURE Distribute_BR
(
  ERRBUF                      OUT  NOCOPY      VARCHAR2,
  RETCODE                     OUT  NOCOPY      VARCHAR2,
  --
  p_distribution_id           IN       NUMBER,
  p_submitter_id              IN       NUMBER
);

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
  p_expenditure_organization_id IN
		    psb_cost_distributions_i.expenditure_organization_id%TYPE ,
  p_chart_of_accounts_id   IN  NUMBER                                         ,
  p_description            IN  VARCHAR2 := FND_API.G_MISS_CHAR                ,
  p_code_combination_id    OUT  NOCOPY gl_code_combinations.code_combination_id%TYPE  ,
  p_error_message          OUT  NOCOPY VARCHAR2
);


PROCEDURE No_Process_Defined
(
   itemtype      IN  VARCHAR2,
   itemkey       IN  VARCHAR2,
   actid         IN  NUMBER,
   funcmode      IN  VARCHAR2,
   result        OUT  NOCOPY VARCHAR2
);

FUNCTION get_debug RETURN VARCHAR2;

END PSB_Workflow_Pvt ;

 

/
