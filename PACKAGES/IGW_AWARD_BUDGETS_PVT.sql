--------------------------------------------------------
--  DDL for Package IGW_AWARD_BUDGETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_AWARD_BUDGETS_PVT" AUTHID CURRENT_USER as
--$Header: igwvabts.pls 115.7 2004/03/25 01:52:46 vmedikon ship $
G_package_name   VARCHAR2(30)  := 'IGW_AWARD_BUDGETS_PVT';

  procedure create_award_budget
        (p_init_msg_list                IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN    VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id		        IN    NUMBER
	,p_proposal_installment_id      IN    NUMBER     := NULL
        ,p_budget_period_id             IN    NUMBER
        ,p_expenditure_type_cat         IN    VARCHAR2
        ,p_expenditure_category_flag    IN    VARCHAR2
        ,p_budget_amount                IN    NUMBER     := 0
        ,p_indirect_flag                IN    VARCHAR2
        ,p_project_id                   IN    NUMBER     :=NULL
	,p_project_number               IN    VARCHAR2
        ,p_task_id                      IN    NUMBER     :=NULL
	,p_task_number                  IN    VARCHAR2
        ,p_award_id                     IN    NUMBER     :=NULL
	,p_award_number                 IN    VARCHAR2
	,p_period_name                  IN    VARCHAR2
        ,p_start_date                   IN    DATE
        ,p_end_date                     IN    DATE
        ,p_transferred_flag		IN    VARCHAR2
	,x_award_budget_id              OUT NOCOPY   NUMBER
        ,x_rowid                        OUT NOCOPY   ROWID
        ,x_return_status                OUT NOCOPY   VARCHAR2
        ,x_msg_count                    OUT NOCOPY   NUMBER
        ,x_msg_data                     OUT NOCOPY   VARCHAR2);


----------------------------------------------------------------------
  procedure update_award_budget
        (p_init_msg_list                IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN    VARCHAR2   := FND_API.G_TRUE
        ,p_award_budget_id              IN    NUMBER
        ,p_proposal_id		        IN    NUMBER     := NULL
	,p_proposal_installment_id	IN    NUMBER     := NULL
        ,p_budget_period_id             IN    NUMBER     := NULL
        ,p_expenditure_type_cat         IN    VARCHAR2
        ,p_expenditure_category_flag    IN    VARCHAR2
        ,p_budget_amount                IN    NUMBER     := 0
        ,p_indirect_flag                IN    VARCHAR2
        ,p_project_id                   IN    NUMBER
	,p_project_number               IN    VARCHAR2
        ,p_task_id                      IN    NUMBER
	,p_task_number                  IN    VARCHAR2
        ,p_award_id                     IN    NUMBER
	,p_award_number                 IN    VARCHAR2
	,p_period_name                  IN    VARCHAR2
        ,p_start_date                   IN    DATE
        ,p_end_date                     IN    DATE
        ,p_transferred_flag	        IN    VARCHAR2
        ,p_record_version_number        IN    NUMBER
        ,p_rowid                        IN    ROWID
        ,x_return_status                OUT NOCOPY   VARCHAR2
        ,x_msg_count                    OUT NOCOPY   NUMBER
        ,x_msg_data                     OUT NOCOPY   VARCHAR2);

-----------------------------------------------------------------------

procedure delete_award_budget
        (p_init_msg_list                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_award_budget_id              IN  NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------
procedure apply_project_award
        (p_award_budget_id              IN  NUMBER
        ,p_proposal_installment_id      IN  NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------
procedure get_time_phased_type_code
	(p_proposal_installment_id      IN  NUMBER
        ,x_time_phased_type_code	OUT NOCOPY VARCHAR2
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------
FUNCTION get_current_budget(p_award_id	IN	NUMBER
   			      ,p_project_id  	IN	NUMBER
  			      ,p_task_id  	IN	NUMBER) return NUMBER;
  pragma restrict_references(get_current_budget, wnds);
----------------------------------------------------------------------------
 FUNCTION get_additional_budget(p_proposal_installment_id	IN	NUMBER
   			       ,p_project_id  			IN	NUMBER
  			       ,p_task_id  			IN	NUMBER) return NUMBER;
 -----------------------------------------------------------------------------------------
 FUNCTION get_award_created_flag(p_proposal_award_id	IN      NUMBER) return VARCHAR2;
 pragma restrict_references(get_award_created_flag, wnds);
-----------------------------------------------------------------------------------------
 FUNCTION get_installment_created_flag(p_proposal_award_id	IN      NUMBER) return VARCHAR2 ;
 pragma restrict_references(get_installment_created_flag, wnds);
 ------------------------------------------------------------------------------------------------------
 FUNCTION get_award_budget_created_flag(p_proposal_installment_id	IN      NUMBER) return VARCHAR2;
 pragma restrict_references(get_award_budget_created_flag, wnds);
 ------------------------------------------------------------------------------------------------------
 FUNCTION get_award_budget_creation_date(p_proposal_installment_id	IN      NUMBER) return DATE;
 pragma restrict_references(get_award_budget_creation_date, wnds);
 ------------------------------------------------------------------------------------------------------
 FUNCTION get_award_number(p_proposal_award_id	IN      NUMBER) return VARCHAR2;
 pragma restrict_references(get_award_number, wnds);

 procedure get_boundary_dates(p_project_id          in number
                              ,p_award_id           in number
                       	      ,x_budget_start_date  out NOCOPY date
			      ,x_budget_end_date    out NOCOPY date);

END;

 

/
