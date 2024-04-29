--------------------------------------------------------
--  DDL for Package IGW_BUDGET_PERIODS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_PERIODS_PUB" AUTHID CURRENT_USER AS
--$Header: igwpbprs.pls 115.0 2002/12/19 22:43:46 ashkumar noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Budget_Period
   (
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_number       IN VARCHAR2,
      p_version_id            IN NUMBER,
      p_budget_period_id      IN NUMBER,
      p_start_date            IN DATE,
      p_end_date              IN DATE,
      p_total_cost_limit      IN NUMBER     := 0,
      p_total_cost            IN NUMBER     := 0,
      p_total_direct_cost     IN NUMBER     := 0,
      p_total_indirect_cost   IN NUMBER     := 0,
      p_cost_sharing_amount   IN NUMBER     := 0,
      p_underrecovery_amount  IN NUMBER     := 0,
      p_program_income        IN VARCHAR2   := 0,
      p_program_income_source IN VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Budget_Periods_Pub;

 

/
