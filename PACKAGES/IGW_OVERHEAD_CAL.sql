--------------------------------------------------------
--  DDL for Package IGW_OVERHEAD_CAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_OVERHEAD_CAL" AUTHID CURRENT_USER as
-- $Header: igwbuovs.pls 115.12 2002/11/14 18:48:13 vmedikon ship $
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGW_OVERHEAD_CAL';


  PROCEDURE get_date_details(	p_input_date		 DATE
				,x_fiscal_year	     OUT NOCOPY NUMBER
				,x_fiscal_start_date OUT NOCOPY DATE
				,x_fiscal_end_date   OUT NOCOPY DATE
				,x_return_status     OUT NOCOPY VARCHAR2
				,x_msg_data	     OUT NOCOPY VARCHAR2);


  PROCEDURE get_rate_id    (p_expenditure_type 		VARCHAR2
			   ,p_expenditure_category_flag VARCHAR2
			   ,p_rate_class_type	 	VARCHAR2
			   ,x_rate_class_id    IN OUT NOCOPY	NUMBER
			   ,x_rate_type_id     OUT NOCOPY	NUMBER
			   ,x_return_status    OUT NOCOPY	VARCHAR2
			   ,x_msg_data         OUT NOCOPY	VARCHAR2);


  PROCEDURE get_rate (	p_proposal_id		NUMBER
			,p_version_id		NUMBER
			,p_fiscal_year 		NUMBER
			,p_activity_type_code   VARCHAR2
			,p_location_code 	VARCHAR2
			,p_rate_class_id 	NUMBER
			,p_rate_type_id 	NUMBER
			,x_rate            OUT NOCOPY  NUMBER
			,x_rate_ov         OUT NOCOPY  NUMBER
			,x_start_date	   OUT NOCOPY	DATE
			,x_return_status   OUT NOCOPY	VARCHAR2
		        ,x_msg_data        OUT NOCOPY  VARCHAR2);

  FUNCTION get_applicable_rate (
                               p_proposal_id            number
                               ,p_version_id            number
                               ,p_rate_class_id         number
                               ,p_rate_type_id          number
			       ,p_activity_type_code    varchar2
                               ,p_location_code         varchar2
                               ,p_fiscal_year           number) RETURN NUMBER;


  PROCEDURE calc_oh (	p_proposal_id		NUMBER
			,p_version_id		NUMBER
			,p_base_amount 		NUMBER
			,p_budget_start_date 	DATE
			,p_budget_end_date  	DATE
                        ,x_oh_value 	    OUT NOCOPY	NUMBER
                        ,x_oh_value_ov 	    OUT NOCOPY	NUMBER
			,p_activity_type_code 	VARCHAR2
			,p_location_code 	VARCHAR2
			,p_rate_class_id 	NUMBER
			,p_rate_type_id 	NUMBER
			,x_return_status    OUT NOCOPY	VARCHAR2
			,x_msg_data         OUT NOCOPY	VARCHAR2
			,x_msg_count	    OUT NOCOPY NUMBER);


  PROCEDURE calc_oh_eb( p_proposal_id		NUMBER
			,p_version_id		NUMBER
			,p_base_amount 		NUMBER
			,p_budget_start_date 	DATE
			,p_budget_end_date  	DATE
                        ,x_oh_value 	    OUT NOCOPY	NUMBER
                        ,x_oh_value_ov 	    OUT NOCOPY	NUMBER
                        ,x_eb_value 	    OUT NOCOPY	NUMBER
                        ,x_eb_value_ov 	    OUT NOCOPY	NUMBER
			,p_activity_type_code 	VARCHAR2
			,p_location_code 	VARCHAR2
			,p_rate_class_id_oh	NUMBER
			,p_rate_type_id_oh 	NUMBER
			,p_rate_class_id_eb	NUMBER
			,p_rate_type_id_eb	NUMBER
			,x_return_status    OUT NOCOPY	VARCHAR2
			,x_msg_data         OUT NOCOPY	VARCHAR2
			,x_msg_count	    OUT NOCOPY NUMBER);

  PROCEDURE calc_inflation(p_proposal_id		NUMBER
			   ,p_version_id		NUMBER
			   ,p_base_amount 		NUMBER
			   ,p_budget_start_date 	DATE
			   ,p_budget_end_date  	        DATE
                           ,x_inflated_amt	  OUT NOCOPY	NUMBER
			   ,p_activity_type_code 	VARCHAR2
			   ,p_location_code 		VARCHAR2
			   ,p_rate_class_id_inf		NUMBER
			   ,p_rate_type_id_inf 		NUMBER
			   ,x_return_status       OUT NOCOPY	VARCHAR2
			   ,x_msg_data            OUT NOCOPY	VARCHAR2
			   ,x_msg_count	          OUT NOCOPY   NUMBER);

  PROCEDURE calc_sal_between_months(p_end_date		 DATE
				    ,p_start_date	 DATE
				    ,p_base_amount	 NUMBER
				    ,x_final_sal     OUT NOCOPY NUMBER
				    ,x_return_status OUT NOCOPY VARCHAR2
				    ,x_msg_data	     OUT NOCOPY VARCHAR2);


  PROCEDURE calc_salary(p_proposal_id			NUMBER
			,p_version_id			NUMBER
			,p_base_amount 			NUMBER
			,p_effective_date		DATE
			,p_appointment_type		VARCHAR2
			,p_line_start_date 		DATE
			,p_line_end_date  		DATE
                        ,x_inflated_salary    	OUT NOCOPY	NUMBER
                        ,x_inflated_salary_ov 	OUT NOCOPY	NUMBER
			,p_expenditure_type 		VARCHAR2
			,p_expenditure_category_flag	VARCHAR2
			,p_activity_type_code 		VARCHAR2
			,p_location_code 		VARCHAR2
			,x_return_status    	OUT NOCOPY	VARCHAR2
			,x_msg_data         	OUT NOCOPY	VARCHAR2
			,x_msg_count	    	OUT NOCOPY 	NUMBER);


END IGW_OVERHEAD_CAL;

 

/
