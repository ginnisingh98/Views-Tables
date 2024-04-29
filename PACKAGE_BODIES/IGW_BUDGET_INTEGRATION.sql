--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_INTEGRATION" as
-- $Header: igwbuimb.pls 120.10 2006/02/22 23:22:38 dsadhukh ship $

  FUNCTION draft_budget_exists(	p_project_id		NUMBER
				,l_award_id     	NUMBER
				,x_err_code      OUT NOCOPY 	VARCHAR2
				,x_err_stage     OUT NOCOPY 	VARCHAR2)  RETURN BOOLEAN
  IS

   BEGIN
    	  RETURN null;
   END draft_budget_exists;
-----------------------------------------------------------------------------------------
   PROCEDURE draft_budget_line_exists(p_project_id		NUMBER
				     ,p_award_id		NUMBER
				     ,p_task_id     		NUMBER
				     ,p_resource_list_member_id	NUMBER
				     ,p_period_name		VARCHAR2
                                     ,x_burdened_cost	OUT NOCOPY	NUMBER
				     ,x_err_code      	OUT NOCOPY 	VARCHAR2
				     ,x_err_stage        OUT NOCOPY 	VARCHAR2)
  IS
   BEGIN
    null;
   END draft_budget_line_exists;
--------------------------------------------------------------------------------------
   PROCEDURE draft_budget_line_exists_dr(p_project_id		NUMBER
				    ,p_award_id			NUMBER
				    ,p_task_id     		NUMBER
				    ,p_resource_list_member_id	NUMBER
				    ,p_start_date		DATE
				    ,p_end_date			DATE
                                    ,x_burdened_cost	OUT NOCOPY	NUMBER
				    ,x_err_code      	OUT NOCOPY 	VARCHAR2
				    ,x_err_stage        OUT NOCOPY 	VARCHAR2)
  IS
      BEGIN

  null;
   END draft_budget_line_exists_dr;

-------------------------------------------------------------------------------------
  FUNCTION project_funding_exists(p_project_id		NUMBER
				  ,p_award_id	        NUMBER
				  ,x_err_code      OUT NOCOPY 	VARCHAR2
				  ,x_err_stage     OUT NOCOPY 	VARCHAR2)  RETURN BOOLEAN
  IS
   BEGIN
	RETURN null;
   END project_funding_exists;

--------------------------------------------------------------------------------------
 PROCEDURE get_resource_list_entry_method ( p_project_id        	NUMBER
					    ,x_budget_entry_method_code OUT NOCOPY VARCHAR2
					    ,x_resource_list_id         OUT NOCOPY NUMBER
					    ,x_time_phased_type_code    OUT NOCOPY VARCHAR2
                                            ,x_entry_level_code         OUT NOCOPY VARCHAR2
                                            ,x_categorization_code      OUT NOCOPY VARCHAR2 --bug 3523294
	  			  	    ,x_return_status            OUT NOCOPY VARCHAR2
				  	    ,x_msg_data                 OUT NOCOPY VARCHAR2)
 IS
 BEGIN
     NULL;
 END get_resource_list_entry_method;
-----------------------------------------------------------------------------------------------
 /* This procedure is used for the self service version of applications and it
    reflects the fact that we no longer have unmatched expenditure category,
    unmatched expenditure category flag, overhead expenditure category and
    overhead expenditure category flag in the setups. We make sure that the
    expenditure category is not unmatched by introducing validations in the front
    end itself. Also the overhead expenditure category is defined in the front end
    the same way we define the expenditure category for the direct costs */

  PROCEDURE get_resource_list_member_id_ss ( p_resource_list_id        		NUMBER
				  	         ,p_expenditure_type 	 	VARCHAR2
					         ,p_expenditure_category_flag	VARCHAR2
                                                                     ,p_categorization_code              VARCHAR2  --bug 3523294
				  	         ,x_resource_list_member_id  	OUT NOCOPY NUMBER
	  			  	         ,x_return_status            	OUT NOCOPY VARCHAR2
				  	         ,x_msg_data                 	OUT NOCOPY VARCHAR2)
 IS

  BEGIN
     NULL;
  END get_resource_list_member_id_ss;
-----------------------------------------------------------------------------------------------

   FUNCTION get_line_item_cost(p_line_item_id number) return number as
    begin
       RETURN NULL;
   end get_line_item_cost;
-----------------------------------------------------------------------------------------------
   FUNCTION get_eb_cost(p_line_item_id number) return number as
      begin
          RETURN NULL;
   end get_eb_cost;
----------------------------------------------------------------------------------------------
   FUNCTION get_eb_cost_personnel(p_personnel_detail_id number) return number as
   begin
           RETURN NULL;
   end get_eb_cost_personnel;
-----------------------------------------------------------------------------------------
   FUNCTION get_oh_cost(p_line_item_id number) return number as
   begin
          RETURN NULL;
   end get_oh_cost;

-----------------------------------------------------------------------------------------
   /* _ss functions return unrounded figures */
   FUNCTION get_eb_cost_ss(p_line_item_id number) return number as
    begin
         RETURN NULL;
   end get_eb_cost_ss;
----------------------------------------------------------------------------------------------
   /* _ss functions return unrounded figures */
   FUNCTION get_oh_cost_ss(p_line_item_id number) return number as
   begin
           RETURN NULL;
   end get_oh_cost_ss;

-----------------------------------------------------------------------------------------


    -- This procedure is to be called from Self-Service Applications. This validates
    -- whether the expenditure type belongs to the resource list associated with the
    -- project selected
  FUNCTION valid_expenditure_type(p_project_id  		IN	NUMBER
  			         ,p_expenditure_type        	IN	VARCHAR2
  			         ,p_expenditure_category_flag	IN	VARCHAR2) return VARCHAR2 IS


   BEGIN
        return NULL;
   END valid_expenditure_type;

  ------------------------------------------------------------------------------------------------
  --  The procedure below has been modified by Debashis to account for changes in structure to table igw_award_budgets
  --  and the fact that we are only dealing with a single award during budget transfer (previously we were transfering
  --  lines for multiple awards at the same time). Also we no longer have unmatched expenditure type and overhead type
  --  defined in the setup. We transfer indirect cost in the same way as direct cost.

  -- This procedure is to be called from Self-Service Applications
  PROCEDURE create_award_budget( p_proposal_installment_id  IN	NUMBER
             		  	,x_return_status            OUT NOCOPY VARCHAR2
				,x_msg_count                OUT NOCOPY NUMBER
				,x_msg_data                 OUT NOCOPY VARCHAR2) is



  BEGIN
      NULL;
  END CREATE_AWARD_BUDGET;
  -------------------------------------------------------------------------------------------------------

 END IGW_BUDGET_INTEGRATION;

/
