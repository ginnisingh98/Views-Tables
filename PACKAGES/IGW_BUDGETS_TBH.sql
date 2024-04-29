--------------------------------------------------------
--  DDL for Package IGW_BUDGETS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGETS_TBH" AUTHID CURRENT_USER as
-- $Header: igwtbvss.pls 115.4 2002/11/14 18:39:01 vmedikon ship $
G_package_name   VARCHAR2(30)    := 'IGW_BUDGETS_TBH';
  procedure INSERT_ROW (
        p_proposal_id		NUMBER
	,p_version_id		NUMBER
  	,p_start_date		DATE
  	,p_end_date		DATE
  	,p_total_cost		NUMBER
  	,p_total_direct_cost	NUMBER
	,p_total_indirect_cost	NUMBER
	,p_cost_sharing_amount	NUMBER
	,p_underrecovery_amount	NUMBER
	,p_residual_funds	NUMBER
	,p_total_cost_limit	NUMBER
	,p_oh_rate_class_id	NUMBER
	,p_proposal_form_number VARCHAR2
	,p_comments		VARCHAR2
	,p_final_version_flag	VARCHAR2
	,p_budget_type_code	VARCHAR2
        ,p_enter_budget_at_period_level   VARCHAR2
        ,p_apply_inflation_setup_rates    VARCHAR2
        ,p_apply_eb_setup_rates VARCHAR2
        ,p_apply_oh_setup_rates VARCHAR2
	,p_attribute_category	VARCHAR2
	,p_attribute1		VARCHAR2
	,p_attribute2		VARCHAR2
	,p_attribute3		VARCHAR2
	,p_attribute4		VARCHAR2
	,p_attribute5		VARCHAR2
	,p_attribute6		VARCHAR2
	,p_attribute7		VARCHAR2
	,p_attribute8		VARCHAR2
	,p_attribute9		VARCHAR2
	,p_attribute10		VARCHAR2
	,p_attribute11		VARCHAR2
	,p_attribute12		VARCHAR2
	,p_attribute13		VARCHAR2
	,p_attribute14		VARCHAR2
	,p_attribute15  	VARCHAR2
	,x_rowid    	        OUT NOCOPY  VARCHAR2
        ,x_return_status        OUT NOCOPY  VARCHAR2);


----------------------------------------------------------------------
  procedure UPDATE_ROW (
  	p_rowid    	        VARCHAR2
	,p_proposal_id		NUMBER
	,p_version_id		NUMBER
  	,p_start_date		DATE
  	,p_end_date		DATE
  	,p_total_cost		NUMBER
  	,p_total_direct_cost	NUMBER
	,p_total_indirect_cost	NUMBER
	,p_cost_sharing_amount	NUMBER
	,p_underrecovery_amount	NUMBER
	,p_residual_funds	NUMBER
	,p_total_cost_limit	NUMBER
	,p_oh_rate_class_id	NUMBER
	,p_proposal_form_number VARCHAR2
	,p_comments		VARCHAR2
	,p_final_version_flag	VARCHAR2
	,p_budget_type_code	VARCHAR2
        ,p_enter_budget_at_period_level   VARCHAR2
        ,p_apply_inflation_setup_rates    VARCHAR2
        ,p_apply_eb_setup_rates VARCHAR2
        ,p_apply_oh_setup_rates VARCHAR2
	,p_attribute_category	VARCHAR2
	,p_attribute1		VARCHAR2
	,p_attribute2		VARCHAR2
	,p_attribute3		VARCHAR2
	,p_attribute4		VARCHAR2
	,p_attribute5		VARCHAR2
	,p_attribute6		VARCHAR2
	,p_attribute7		VARCHAR2
	,p_attribute8		VARCHAR2
	,p_attribute9		VARCHAR2
	,p_attribute10		VARCHAR2
	,p_attribute11		VARCHAR2
	,p_attribute12		VARCHAR2
	,p_attribute13		VARCHAR2
	,p_attribute14		VARCHAR2
	,p_attribute15  	VARCHAR2
        ,p_record_version_number NUMBER
        ,x_return_status   OUT NOCOPY  VARCHAR2);
-----------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                        IN ROWID
  ,p_proposal_id                  IN NUMBER
  ,p_version_id                   IN NUMBER
  ,p_record_version_number        IN NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2);


END IGW_BUDGETS_TBH;

 

/
