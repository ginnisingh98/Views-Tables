--------------------------------------------------------
--  DDL for Package IGW_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGETS_PKG" AUTHID CURRENT_USER as
-- $Header: igwbuths.pls 115.9 2002/03/28 19:13:09 pkm ship    $
  procedure INSERT_ROW (
	x_rowid		IN OUT  VARCHAR2
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
	,p_attribute15  	VARCHAR2);

  procedure lock_row(
        x_rowid			VARCHAR2
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
	,p_attribute15  	VARCHAR2);

  procedure update_row(
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
	,p_attribute15  	VARCHAR2);

END IGW_BUDGETS_PKG;

 

/
