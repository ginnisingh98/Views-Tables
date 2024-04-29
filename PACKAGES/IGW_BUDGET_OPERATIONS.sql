--------------------------------------------------------
--  DDL for Package IGW_BUDGET_OPERATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_OPERATIONS" AUTHID CURRENT_USER as
-- $Header: igwbuops.pls 115.11 2002/11/14 18:40:30 vmedikon ship $
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'PACKAGE IGW_BUDGET_OPERATIONS';
  G_START_PERIOD  	NUMBER(10):=1;
  G_PROPOSAL_ID   	NUMBER(15):=0;
  G_VERSION_ID    	NUMBER(4):=0;

/* duplicated procedure below to recalculate individually */

/*
  PROCEDURE recalculate_budget (p_proposal_id		NUMBER
				,p_version_id		NUMBER
				,p_activity_type_code	VARCHAR2
				,p_oh_rate_class_id	NUMBER
				,x_return_status    OUT NOCOPY	VARCHAR2
				,x_msg_data         OUT NOCOPY	VARCHAR2
				,x_msg_count	    OUT NOCOPY NUMBER);
*/

----------------------------------------------------------------------------------
  PROCEDURE copy_budget(p_proposal_id			NUMBER
			,p_target_proposal_id	  	NUMBER
			,p_version_id			NUMBER
                        ,p_copy_first_period		VARCHAR2
			,p_copy_type			VARCHAR2
			,p_budget_type_code		VARCHAR2
			,x_return_status    	OUT NOCOPY	VARCHAR2
			,x_msg_data         	OUT NOCOPY	VARCHAR2
			,x_msg_count	    	OUT NOCOPY 	NUMBER);
----------------------------------------------------------------------------------
  Function get_period_id RETURN NUMBER;
  pragma restrict_references(get_period_id, wnds, wnps);
----------------------------------------------------------------------------------
  Function get_version_id RETURN NUMBER;
  pragma restrict_references(get_version_id, wnds, wnps);
----------------------------------------------------------------------------------
  Function get_proposal_id RETURN NUMBER;
  pragma restrict_references(get_proposal_id, wnds, wnps);
----------------------------------------------------------------------------------
  Procedure set_global_variables(p_start_period 	NUMBER
				 ,p_proposal_id 	NUMBER
				 ,p_version_id  	NUMBER);
----------------------------------------------------------------------------------
  PROCEDURE recalculate_budget(p_proposal_id		      NUMBER
			       ,p_version_id		      NUMBER
                               ,p_budget_period_id            NUMBER   :=NULL
                               ,p_line_item_id                NUMBER   :=NULL
                               ,p_budget_personnel_detail_id  NUMBER   :=NULL
			       ,p_activity_type_code	      VARCHAR2 :=NULL
			       ,p_oh_rate_class_id	      NUMBER   :=NULL
			       ,x_return_status          OUT NOCOPY  VARCHAR2
			       ,x_msg_data               OUT NOCOPY  VARCHAR2
			       ,x_msg_count	         OUT NOCOPY  NUMBER);
END IGW_BUDGET_OPERATIONS;

 

/
