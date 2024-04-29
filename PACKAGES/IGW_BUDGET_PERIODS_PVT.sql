--------------------------------------------------------
--  DDL for Package IGW_BUDGET_PERIODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_PERIODS_PVT" AUTHID CURRENT_USER as
--$Header: igwvbprs.pls 115.4 2002/11/14 18:40:52 vmedikon ship $
G_package_name   VARCHAR2(30)  := 'IGW_BUDGET_PERIODS_PVT';
procedure create_budget_period
       (p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only           IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
  	,p_total_cost		       NUMBER     := 0
  	,p_total_direct_cost	       NUMBER     := 0
	,p_total_indirect_cost	       NUMBER     := 0
	,p_cost_sharing_amount	       NUMBER     := 0
	,p_underrecovery_amount	       NUMBER     := 0
	,p_total_cost_limit	       NUMBER     := 0
	,p_program_income              VARCHAR2   := 0
	,p_program_income_source       VARCHAR2
        ,x_rowid                   OUT NOCOPY ROWID
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2);


----------------------------------------------------------------------
  procedure update_budget_period
       (p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only           IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
  	,p_total_cost		       NUMBER
  	,p_total_direct_cost	       NUMBER
	,p_total_indirect_cost	       NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
	,p_total_cost_limit	       NUMBER
	,p_program_income              VARCHAR2
	,p_program_income_source       VARCHAR2
        ,p_record_version_number   IN  NUMBER
        ,p_rowid                   IN  ROWID
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------

procedure delete_budget_period
       (p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only           IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_record_version_number   IN  NUMBER
        ,p_rowid                   IN  ROWID
        ,x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2);


END IGW_BUDGET_PERIODS_PVT;

 

/
