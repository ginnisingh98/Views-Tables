--------------------------------------------------------
--  DDL for Package IGW_BUDGETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGETS_PVT" AUTHID CURRENT_USER as
--$Header: igwvbvss.pls 115.8 2002/11/14 18:38:41 vmedikon ship $
G_package_name   VARCHAR2(30)  := 'IGW_BUDGETS_PVT';

  procedure manage_budget_deletion
	(p_delete_level                     VARCHAR2
        ,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
        ,p_budget_period_id                 NUMBER    := null
        ,p_line_item_id                     NUMBER    := null
        ,p_budget_personnel_detail_id       NUMBER    := null
        ,x_return_status               OUT NOCOPY  VARCHAR2);

---------------------------------------------------------------------------------------
  PROCEDURE copy_final_to_award_budget(
                         p_proposal_id			IN	NUMBER
                        ,p_proposal_installment_id	IN	NUMBER
			,x_return_status    		OUT NOCOPY	VARCHAR2
			,x_msg_data         		OUT NOCOPY	VARCHAR2
			,x_msg_count	    		OUT NOCOPY 	NUMBER);

-------------------------------------------------------------------------------------

  procedure create_budget_version
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_start_date		            DATE       := null
  	,p_end_date		            DATE       := null
  	,p_total_cost		            NUMBER     := 0
  	,p_total_direct_cost	            NUMBER     := 0
	,p_total_indirect_cost	            NUMBER     := 0
	,p_cost_sharing_amount	            NUMBER     := 0
	,p_underrecovery_amount	            NUMBER     := 0
	,p_residual_funds	            NUMBER     := 0
	,p_total_cost_limit	            NUMBER
	,p_oh_rate_class_id	            NUMBER
        ,p_oh_rate_class_name               VARCHAR2
	,p_proposal_form_number             VARCHAR2
	,p_comments		            VARCHAR2
	,p_final_version_flag	            VARCHAR2   := 'N'
	,p_budget_type_code	            VARCHAR2   := 'PROPOSAL_BUDGET'
        ,p_enter_budget_at_period_level     VARCHAR2
        ,p_apply_inflation_setup_rates      VARCHAR2
        ,p_apply_eb_setup_rates             VARCHAR2
        ,p_apply_oh_setup_rates             VARCHAR2
	,p_attribute_category	            VARCHAR2 := null
	,p_attribute1		            VARCHAR2 := null
	,p_attribute2		            VARCHAR2 := null
	,p_attribute3		            VARCHAR2 := null
	,p_attribute4		            VARCHAR2 := null
	,p_attribute5		            VARCHAR2 := null
	,p_attribute6		            VARCHAR2 := null
	,p_attribute7		            VARCHAR2 := null
	,p_attribute8		            VARCHAR2 := null
	,p_attribute9		            VARCHAR2 := null
	,p_attribute10		            VARCHAR2 := null
	,p_attribute11		            VARCHAR2 := null
	,p_attribute12		            VARCHAR2 := null
	,p_attribute13		            VARCHAR2 := null
	,p_attribute14		            VARCHAR2 := null
	,p_attribute15  	            VARCHAR2 := null
        ,x_rowid                        OUT NOCOPY ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


----------------------------------------------------------------------
  procedure update_budget_version
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_start_date		            DATE
  	,p_end_date		            DATE
  	,p_total_cost		            NUMBER
  	,p_total_direct_cost	            NUMBER
	,p_total_indirect_cost	            NUMBER
	,p_cost_sharing_amount	            NUMBER
	,p_underrecovery_amount	            NUMBER
	,p_residual_funds	            NUMBER
	,p_total_cost_limit	            NUMBER
	,p_oh_rate_class_id	            NUMBER
        ,p_oh_rate_class_name               VARCHAR2
	,p_proposal_form_number             VARCHAR2
	,p_comments		            VARCHAR2
	,p_final_version_flag	            VARCHAR2
	,p_budget_type_code	            VARCHAR2 := 'PROPOSAL_BUDGET'
        ,p_enter_budget_at_period_level     VARCHAR2
        ,p_apply_inflation_setup_rates      VARCHAR2
        ,p_apply_eb_setup_rates             VARCHAR2
        ,p_apply_oh_setup_rates             VARCHAR2
	,p_attribute_category	            VARCHAR2 := null
	,p_attribute1		            VARCHAR2 := null
	,p_attribute2		            VARCHAR2 := null
	,p_attribute3		            VARCHAR2 := null
	,p_attribute4		            VARCHAR2 := null
	,p_attribute5		            VARCHAR2 := null
	,p_attribute6		            VARCHAR2 := null
	,p_attribute7		            VARCHAR2 := null
	,p_attribute8		            VARCHAR2 := null
	,p_attribute9		            VARCHAR2 := null
	,p_attribute10		            VARCHAR2 := null
	,p_attribute11		            VARCHAR2 := null
	,p_attribute12		            VARCHAR2 := null
	,p_attribute13		            VARCHAR2 := null
	,p_attribute14		            VARCHAR2 := null
	,p_attribute15  	            VARCHAR2 := null
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------

procedure delete_budget_version
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id                  IN  NUMBER
        ,p_version_id                   IN  NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


END IGW_BUDGETS_PVT;

 

/
