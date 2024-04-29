--------------------------------------------------------
--  DDL for Package IGW_BUDGET_DETAILS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_DETAILS_TBH" AUTHID CURRENT_USER as
--$Header: igwtbdts.pls 115.3 2002/11/14 18:39:52 vmedikon ship $
G_package_name   VARCHAR2(30)    := 'IGW_BUDGET_DETAILS_TBH';
  procedure INSERT_ROW (
        p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_line_item_id                NUMBER
        ,p_expenditure_type            VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_category_code        VARCHAR2
        ,p_line_item_description       VARCHAR2
        ,p_based_on_line_item          NUMBER
        ,p_line_item_cost              NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,p_apply_inflation_flag        VARCHAR2
        ,p_budget_justification        LONG
        ,p_location_code               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_award_id                    NUMBER
        ,x_rowid    	          OUT NOCOPY  VARCHAR2
        ,x_return_status          OUT NOCOPY  VARCHAR2);


----------------------------------------------------------------------
  procedure UPDATE_ROW (
  	p_rowid    	               ROWID
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_line_item_id                NUMBER
        ,p_expenditure_type            VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_category_code        VARCHAR2
        ,p_line_item_description       VARCHAR2
        ,p_based_on_line_item          NUMBER
        ,p_line_item_cost              NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,p_apply_inflation_flag        VARCHAR2
        ,p_budget_justification        LONG
        ,p_location_code               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_award_id                    NUMBER
        ,p_record_version_number       NUMBER
        ,x_return_status          OUT NOCOPY  VARCHAR2);
-----------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                        IN  ROWID
  ,p_proposal_id                  IN  NUMBER
  ,p_version_id                   IN  NUMBER
  ,p_budget_period_id             IN  NUMBER
  ,p_line_item_id                     NUMBER
  ,p_record_version_number        IN  NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2);


END IGW_BUDGET_DETAILS_TBH;

 

/
