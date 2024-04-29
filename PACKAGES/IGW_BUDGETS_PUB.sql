--------------------------------------------------------
--  DDL for Package IGW_BUDGETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGETS_PUB" AUTHID CURRENT_USER AS
--$Header: igwpbvss.pls 115.0 2002/12/19 22:43:50 ashkumar noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Budget_Version
   (
      p_validate_only                IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                       IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_number              IN VARCHAR2,
      p_start_date                   IN DATE,
      p_end_date                     IN DATE,
      p_oh_rate_class_name           IN VARCHAR2,
      p_proposal_form_number         IN VARCHAR2,
      p_total_cost_limit             IN NUMBER,
      p_total_cost                   IN NUMBER     := 0,
      p_total_direct_cost            IN NUMBER     := 0,
      p_total_indirect_cost          IN NUMBER     := 0,
      p_cost_sharing_amount          IN NUMBER     := 0,
      p_underrecovery_amount         IN NUMBER     := 0,
      p_residual_funds               IN NUMBER     := 0,
      p_final_version_flag           IN VARCHAR2   := 'N',
      p_enter_budget_at_period_level IN VARCHAR2   := 'N',
      p_apply_inflation_setup_rates  IN VARCHAR2   := 'Y',
      p_apply_eb_setup_rates         IN VARCHAR2   := 'Y',
      p_apply_oh_setup_rates         IN VARCHAR2   := 'Y',
      p_comments                     IN VARCHAR2   := null,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Budgets_Pub;

 

/
