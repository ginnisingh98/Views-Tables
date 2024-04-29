--------------------------------------------------------
--  DDL for Package PA_BUDGET_INTG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_INTG_WF" AUTHID CURRENT_USER AS
/* $Header: PAWFBUIS.pls 120.1 2005/08/19 17:07:27 mwasowic noship $ */

PROCEDURE Start_Budget_Intg_WF
          (p_draft_version_id         IN   NUMBER
          , p_project_id              IN   NUMBER
          , p_budget_type_code        IN   VARCHAR2
          , p_mark_as_original        IN   VARCHAR2
          , p_budget_wf_flag          IN   VARCHAR2
          , p_bgt_intg_flag           IN   VARCHAR2
          , p_fck_req_flag            IN   VARCHAR2
          , x_msg_count               OUT  NOCOPY NUMBER  --File.Sql.39 bug 4440895
          , x_msg_data                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          , x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          );


PROCEDURE Process_Bgt_Intg
          (itemtype   IN  VARCHAR2
          , itemkey   IN  VARCHAR2
          , actid     IN  NUMBER
          , funcmode  IN  VARCHAR2
          , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          );

END pa_budget_intg_wf;


 

/
