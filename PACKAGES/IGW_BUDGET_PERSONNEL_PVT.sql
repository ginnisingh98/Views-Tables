--------------------------------------------------------
--  DDL for Package IGW_BUDGET_PERSONNEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_PERSONNEL_PVT" AUTHID CURRENT_USER as
--$Header: igwvbpds.pls 120.3 2005/10/30 05:50:40 appldev ship $
G_package_name   VARCHAR2(30)  := 'IGW_BUDGET_PERSONNEL_PVT';
   procedure create_personnel_line
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
        ,p_budget_period_id                 NUMBER
        ,p_line_item_id                     NUMBER
        ,p_budget_personnel_detail_id       NUMBER     := NULL
        ,p_person_id                        NUMBER
        ,p_party_id	                    NUMBER
        ,p_person_name                      VARCHAR2
  	,p_start_date		            DATE
  	,p_end_date		            DATE
        ,p_period_type_code                 VARCHAR2
        ,p_period_type                      VARCHAR2
        ,p_appointment_type_code            VARCHAR2
        ,p_appointment_type                 VARCHAR2
        ,p_salary_requested                 NUMBER
        ,p_percent_charged                  NUMBER
        ,p_percent_effort                   NUMBER
        ,p_cost_sharing_percent             NUMBER
	,p_cost_sharing_amount	            NUMBER     := 0
	,p_underrecovery_amount	            NUMBER     := 0
        ,x_rowid                        OUT NOCOPY ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


----------------------------------------------------------------------
  procedure update_personnel_line
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
        ,p_budget_period_id                 NUMBER
        ,p_line_item_id                     NUMBER
        ,p_budget_personnel_detail_id       NUMBER
        ,p_person_id                        NUMBER
        ,p_party_id	                    NUMBER
        ,p_person_name                      VARCHAR2
  	,p_start_date		            DATE
  	,p_end_date		            DATE
        ,p_period_type_code                 VARCHAR2
        ,p_period_type                      VARCHAR2
        ,p_appointment_type_code            VARCHAR2
        ,p_appointment_type                 VARCHAR2
        ,p_salary_requested                 NUMBER
        ,p_percent_charged                  NUMBER
        ,p_percent_effort                   NUMBER
        ,p_cost_sharing_percent             NUMBER
	,p_cost_sharing_amount	            NUMBER
	,p_underrecovery_amount	            NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------

procedure delete_personnel_line
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_budget_personnel_detail_id       NUMBER
        ,p_proposal_id                  IN  NUMBER     := null
        ,p_version_id                   IN  NUMBER     := null
        ,p_budget_period_id             IN  NUMBER     := null
        ,p_line_item_id                     NUMBER     := null
        ,p_person_id                        NUMBER     := null
        ,p_party_id	                    NUMBER     := null
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


END;

 

/
