--------------------------------------------------------
--  DDL for Package IGW_GENERATE_PERIODS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_GENERATE_PERIODS" AUTHID CURRENT_USER as
--$Header: igwbugps.pls 115.13 2002/11/19 23:47:47 vmedikon ship $
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGW_GENERATE_PERIODS';

  PROCEDURE create_budget_detail(
    l_proposal_id 		IGW_budget_periods.proposal_id%TYPE
    ,l_version_id  		IGW_budget_periods.version_id%TYPE
    ,l_budget_period_id		IGW_budget_periods.budget_period_id%TYPE
    ,l_line_item_id	 	IGW_budget_details.line_item_id%TYPE
    ,l_expenditure_type		IGW_budget_details.expenditure_type%TYPE
    ,l_budget_category_code     IGW_budget_details.budget_category_code%TYPE
    ,l_expenditure_category_flag IGW_budget_details.expenditure_category_flag%TYPE
    ,l_line_item_description	IGW_budget_details.line_item_description%TYPE
    ,l_based_on_line_item	IGW_budget_details.based_on_line_item%TYPE
    ,l_line_item_cost		NUMBER
    ,l_cost_sharing_amount	NUMBER
    ,l_underrecovery_amount	NUMBER
    ,l_apply_inflation_flag	VARCHAR2
    ,l_budget_justification	IGW_budget_details.budget_justification%TYPE
    ,l_location_code		VARCHAR2);



  PROCEDURE create_budget_personnel_amts (
    l_budget_personnel_detail_id  NUMBER
    ,l_rate_class_id  		  NUMBER
    ,l_rate_type_id		  NUMBER
    ,l_apply_rate_flag	 	  VARCHAR2
    ,l_calculated_cost		  NUMBER
    ,l_calculated_cost_sharing	  NUMBER);

  PROCEDURE create_budget_detail_amts (p_proposal_id			NUMBER
					,p_version_id			NUMBER
					,p_budget_period_id		NUMBER
					,p_line_item_id			NUMBER
					,p_rate_class_id		NUMBER
					,p_rate_type_id			NUMBER
					,p_apply_rate_flag		VARCHAR2
					,p_calculated_cost		NUMBER
					,p_calculated_cost_sharing	NUMBER);



  PROCEDURE generate_lines    (	p_proposal_id		NUMBER
				,p_version_id	 	NUMBER
				,p_budget_period_id	NUMBER
				,p_activity_type_code	VARCHAR2
				,p_oh_rate_class_id	NUMBER
				,x_return_status    OUT NOCOPY	VARCHAR2
				,x_msg_data         OUT NOCOPY	VARCHAR2
				,x_msg_count	    OUT NOCOPY NUMBER);

  PROCEDURE apply_future_periods(p_proposal_id		NUMBER
				,p_version_id	 	NUMBER
				,p_budget_period_id	NUMBER
				,p_line_item_id		NUMBER
				,p_activity_type_code	VARCHAR2
				,p_oh_rate_class_id	NUMBER
				,x_return_status    OUT NOCOPY	VARCHAR2
				,x_msg_data         OUT NOCOPY	VARCHAR2
				,x_msg_count	    OUT NOCOPY NUMBER);


  PROCEDURE sync_to_cost_limit( p_proposal_id			NUMBER
				,p_version_id	 		NUMBER
				,p_budget_period_id		NUMBER
				,p_line_item_id			NUMBER
				,p_activity_type_code		VARCHAR2
				,p_line_item_cost		NUMBER
				,p_total_cost_limit		NUMBER
				,x_line_item_cost   	   OUT NOCOPY	NUMBER
                                ,x_calculated_cost  	   OUT NOCOPY	NUMBER
				,x_return_status           OUT NOCOPY	VARCHAR2
				,x_msg_data                OUT NOCOPY	VARCHAR2
				,x_msg_count	           OUT NOCOPY  NUMBER);

  PROCEDURE sync_to_cost_limit_wrap(
				p_line_item_id			NUMBER
				,p_line_item_cost		NUMBER
				,x_return_status           OUT NOCOPY	VARCHAR2
				,x_msg_data                OUT NOCOPY	VARCHAR2
				,x_msg_count	           OUT NOCOPY  NUMBER);

  PROCEDURE sync_to_cost_limit_wrap_2(
				p_line_item_id			NUMBER
				,p_line_item_cost		NUMBER
				,x_return_status           OUT NOCOPY	VARCHAR2
				,x_msg_data                OUT NOCOPY	VARCHAR2
				,x_msg_count	           OUT NOCOPY  NUMBER);


END IGW_GENERATE_PERIODS;

 

/
