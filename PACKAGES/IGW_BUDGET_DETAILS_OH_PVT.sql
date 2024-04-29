--------------------------------------------------------
--  DDL for Package IGW_BUDGET_DETAILS_OH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_DETAILS_OH_PVT" AUTHID CURRENT_USER as
--$Header: igwvbdos.pls 115.3 2002/11/14 18:39:19 vmedikon ship $
G_package_name   VARCHAR2(30)  := 'IGW_BUDGET_DETAILS_OH_PVT';
  procedure create_budget_line_oh
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
        ,p_budget_period_id                 NUMBER
        ,p_line_item_id                     NUMBER
        ,p_rate_class_id                    NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_apply_rate_flag                  VARCHAR2
        ,p_calculated_cost                  NUMBER     := 0
        ,p_calculated_cost_sharing          NUMBER     := 0
        ,x_rowid                        OUT NOCOPY ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


----------------------------------------------------------------------
  procedure update_budget_line_oh
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER     := NULL
	,p_version_id		            NUMBER     := NULL
        ,p_budget_period_id                 NUMBER     := NULL
        ,p_line_item_id                     NUMBER
        ,p_rate_class_id                    NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_apply_rate_flag                  VARCHAR2
        ,p_calculated_cost                  NUMBER
        ,p_calculated_cost_sharing          NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------

procedure delete_budget_line_oh
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id                  IN  NUMBER     := NULL
        ,p_version_id                   IN  NUMBER     := NULL
        ,p_budget_period_id                 NUMBER     := NULL
        ,p_line_item_id                     NUMBER
        ,p_rate_class_id                    NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


END;

 

/
