--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_DETAILS_PVT" AS
--$Header: igwvbdtb.pls 120.4 2006/02/22 23:21:56 dsadhukh ship $
PROCEDURE VALIDATE_EXPENDITURE_TYPE
(p_expenditure_type_category	 IN  VARCHAR2
 ,x_expenditure_type_category    OUT NOCOPY VARCHAR2
 ,x_expenditure_category_flag    OUT NOCOPY VARCHAR2
 ,x_budget_category_code         OUT NOCOPY VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_error_msg_code               OUT NOCOPY VARCHAR2) is


BEGIN
  null;
END; --VALIDATE_EXPENDITURE_TYPE

--------------------------------------------------------------------------------------------
  Procedure validate_expenditure_level(
   p_proposal_id                      VARCHAR2
   ,p_version_id                      VARCHAR2
   ,p_budget_period_id                VARCHAR2
   ,p_expenditure_type                VARCHAR2
   ,p_expenditure_category_flag       VARCHAR2
   ,p_line_item_id                    NUMBER
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_error_msg_code               OUT NOCOPY VARCHAR2) is

   Begin
    null;
  End validate_expenditure_level;

--------------------------------------------------------------------------------------------
  function get_personnel_attached_flag(p_expenditure_type              IN VARCHAR2
                                        ,p_expenditure_category_flag   IN VARCHAR2) RETURN VARCHAR2 IS
  begin
   RETURN null;
  end;
-----------------------------------------------------------------------------------------
function get_budget_justification(p_line_item_id     NUMBER) RETURN VARCHAR2 is
 begin
    RETURN null;
 end;
-----------------------------------------------------------------------------------------
  procedure create_budget_line
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
        ,p_budget_period_id                 NUMBER
        ,p_line_item_id                     NUMBER     := NULL
        ,p_expenditure_type                 VARCHAR2
        ,p_expenditure_category_flag        VARCHAR2
        ,p_budget_category_code             VARCHAR2
        ,p_budget_category                  VARCHAR2
        ,p_line_item_description            VARCHAR2
        ,p_based_on_line_item               NUMBER     := NULL
        ,p_line_item_cost                   NUMBER     := 0
	,p_cost_sharing_amount	            NUMBER     := 0
	,p_underrecovery_amount	            NUMBER     := 0
        ,p_apply_inflation_flag             VARCHAR2
        ,p_budget_justification             LONG
        ,p_location_code                    VARCHAR2
        ,p_location                         VARCHAR2
        ,p_project_id                       NUMBER     :=NULL
	,p_project_number                   VARCHAR2
        ,p_task_id                          NUMBER     :=NULL
	,p_task_number                      VARCHAR2
        ,p_award_id                         NUMBER     :=NULL
	,p_award_number                     VARCHAR2
        ,x_line_item_id                 OUT NOCOPY NUMBER
        ,x_rowid                        OUT NOCOPY ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS



BEGIN
    NULL;
END; --CREATE BUDGET LINE


------------------------------------------------------------------------------------------
  procedure update_budget_line
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER     := NULL
	,p_version_id		            NUMBER     := NULL
        ,p_budget_period_id                 NUMBER     := NULL
        ,p_line_item_id                     NUMBER
        ,p_expenditure_type                 VARCHAR2
        ,p_expenditure_category_flag        VARCHAR2
        ,p_budget_category_code             VARCHAR2
        ,p_budget_category                  VARCHAR2
        ,p_line_item_description            VARCHAR2
        ,p_based_on_line_item               NUMBER     := NULL
        ,p_line_item_cost                   NUMBER
	,p_cost_sharing_amount	            NUMBER
	,p_underrecovery_amount	            NUMBER     := 0
        ,p_apply_inflation_flag             VARCHAR2
        ,p_budget_justification             LONG
        ,p_location_code                    VARCHAR2
        ,p_location                         VARCHAR2
        ,p_project_id                       NUMBER
	,p_project_number                   VARCHAR2
        ,p_task_id                          NUMBER
	,p_task_number                      VARCHAR2
        ,p_award_id                         NUMBER
	,p_award_number                     VARCHAR2
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS

  BEGIN
   NULL;

END; --UPDATE BUDGET LINE

-------------------------------------------------------------------------------------------

procedure delete_budget_line
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id                  IN  NUMBER     := NULL
        ,p_version_id                   IN  NUMBER     := NULL
        ,p_budget_period_id                 NUMBER     := NULL
        ,p_line_item_id                     NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2)  is


BEGIN
   NULL;
END; --DELETE BUDGET LINE


END;

/
