--------------------------------------------------------
--  DDL for Package IGW_BUDGET_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_INTEGRATION" AUTHID CURRENT_USER AS
-- $Header: igwbuims.pls 115.18 2004/03/25 01:52:30 vmedikon ship $
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGW_BUDGET_INTEGRATION';


  FUNCTION  get_line_item_cost (p_line_item_id 	NUMBER) return number;
  pragma restrict_references(get_line_item_cost, wnds, wnps);

  FUNCTION  get_oh_cost (p_line_item_id   	NUMBER) return number;
  pragma restrict_references(get_oh_cost, wnds, wnps);

  FUNCTION  get_eb_cost (p_line_item_id   	NUMBER) return number;
  pragma restrict_references(get_eb_cost, wnds, wnps);

  FUNCTION  get_eb_cost_personnel (p_personnel_detail_id   	NUMBER) return number;
  pragma restrict_references(get_eb_cost_personnel, wnds, wnps);

  /* _ss functions return unrounded figures */
  FUNCTION  get_oh_cost_ss (p_line_item_id   	NUMBER) return number;
  pragma restrict_references(get_oh_cost, wnds, wnps);

  /* _ss functions return unrounded figures */
  FUNCTION  get_eb_cost_ss (p_line_item_id   	NUMBER) return number;
  pragma restrict_references(get_eb_cost, wnds, wnps);

  PROCEDURE get_resource_list_entry_method ( p_project_id        	NUMBER
					    ,x_budget_entry_method_code OUT NOCOPY VARCHAR2
					    ,x_resource_list_id         OUT NOCOPY NUMBER
					    ,x_time_phased_type_code    OUT NOCOPY VARCHAR2
                                            ,x_entry_level_code         OUT NOCOPY VARCHAR2
                                            ,x_categorization_code      OUT NOCOPY VARCHAR2 --bug 3523294
	  			  	    ,x_return_status            OUT NOCOPY VARCHAR2
				  	    ,x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE get_resource_list_member_id_ss ( p_resource_list_id        		NUMBER
				  	    ,p_expenditure_type 	 	VARCHAR2
					    ,p_expenditure_category_flag	VARCHAR2
    					    ,p_categorization_code              VARCHAR2  --bug 3523294
				  	    ,x_resource_list_member_id  	OUT NOCOPY NUMBER
	  			  	    ,x_return_status            	OUT NOCOPY VARCHAR2
				  	    ,x_msg_data                 	OUT NOCOPY VARCHAR2);



  -- This procedure is called from Self-Service Application
  PROCEDURE create_award_budget( p_proposal_installment_id   IN  NUMBER
             		  	 ,x_return_status            OUT NOCOPY VARCHAR2
				 ,x_msg_count                OUT NOCOPY NUMBER
				 ,x_msg_data                 OUT NOCOPY VARCHAR2);


   FUNCTION valid_expenditure_type(p_project_id  		NUMBER
  			          ,p_expenditure_type        	VARCHAR2
  			          ,p_expenditure_category_flag	VARCHAR2) return VARCHAR2;
  pragma restrict_references(valid_expenditure_type, wnds);





 END IGW_BUDGET_INTEGRATION;

 

/
