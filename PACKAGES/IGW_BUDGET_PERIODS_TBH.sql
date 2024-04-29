--------------------------------------------------------
--  DDL for Package IGW_BUDGET_PERIODS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_PERIODS_TBH" AUTHID CURRENT_USER as
-- $Header: igwtbprs.pls 115.3 2002/11/14 18:41:13 vmedikon ship $
G_package_name   VARCHAR2(30)    := 'IGW_BUDGET_PERIODS_TBH';
  procedure INSERT_ROW (
        p_proposal_id		       NUMBER
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
        ,x_rowid    	          OUT NOCOPY  VARCHAR2
        ,x_return_status          OUT NOCOPY  VARCHAR2);


----------------------------------------------------------------------
  procedure UPDATE_ROW (
  	p_rowid    	               ROWID
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
        ,p_record_version_number       NUMBER
        ,x_return_status          OUT NOCOPY  VARCHAR2);
-----------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                        IN  ROWID
  ,p_proposal_id                  IN  NUMBER
  ,p_version_id                   IN  NUMBER
  ,p_budget_period_id             IN  NUMBER
  ,p_record_version_number        IN  NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2);


END IGW_BUDGET_PERIODS_TBH;

 

/
