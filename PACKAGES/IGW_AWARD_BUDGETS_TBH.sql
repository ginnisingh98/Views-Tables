--------------------------------------------------------
--  DDL for Package IGW_AWARD_BUDGETS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_AWARD_BUDGETS_TBH" AUTHID CURRENT_USER as
--$Header: igwtabts.pls 115.3 2002/11/14 18:37:59 vmedikon noship $
G_package_name   VARCHAR2(30)    := 'IGW_AWARD_BUDGETS_TBH';
  procedure INSERT_ROW (
         p_award_budget_id             NUMBER
        ,p_proposal_installment_id     NUMBER
        ,p_budget_period_id            NUMBER
        ,p_expenditure_type_cat        VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_amount               NUMBER
        ,p_indirect_flag               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_period_name                 VARCHAR2
	,p_start_date                  DATE
	,p_end_date                    DATE
	,p_transferred_flag            VARCHAR2
        ,x_rowid    	          OUT NOCOPY  VARCHAR2
        ,x_return_status          OUT NOCOPY  VARCHAR2);


----------------------------------------------------------------------
  procedure UPDATE_ROW (
  	 p_rowid    	               ROWID
        ,p_award_budget_id             NUMBER
        ,p_proposal_installment_id     NUMBER
        ,p_budget_period_id            NUMBER
        ,p_expenditure_type_cat        VARCHAR2
        ,p_expenditure_category_flag   VARCHAR2
        ,p_budget_amount               NUMBER
        ,p_indirect_flag               VARCHAR2
        ,p_project_id                  NUMBER
        ,p_task_id                     NUMBER
        ,p_period_name                 VARCHAR2
	,p_start_date                  DATE
	,p_end_date                    DATE
	,p_transferred_flag            VARCHAR2
        ,p_record_version_number       NUMBER
        ,x_return_status          OUT NOCOPY  VARCHAR2);
-----------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                       IN  ROWID
  ,p_award_budget_id             IN  NUMBER
  ,p_record_version_number       IN  NUMBER
  ,x_return_status               OUT NOCOPY VARCHAR2);


END IGW_AWARD_BUDGETS_TBH;

 

/
