--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: pyeledpm.pkh 115.2 2003/04/03 06:49:59 sdhole noship $ */

Function user_key_to_id(p_user_key_value in varchar2)
return number;
--
Function get_balancing_keyflex_id
  (p_balancing_keyflex_user_key in varchar2
  )
return number;
--
Function get_element_set_id
  (p_business_group_id number
  ,p_element_set_name  varchar2
  )
return number;
--
Function get_element_link_ovn
  (p_element_link_user_key in varchar2
  ,p_effective_date        in date
  )
return number;
--
Function get_link_input_value_id
  (p_element_link_user_key in varchar2
  ,p_input_value_name      in varchar
  ,p_element_name          in varchar2
  ,p_business_group_id     in number
  ,p_language_code         in varchar2
  ,p_effective_date        in date
  )
return number;
--
Function get_link_input_value_ovn
  (p_element_link_user_key in varchar2
  ,p_input_value_name      in varchar
  ,p_element_name          in varchar2
  ,p_business_group_id     in number
  ,p_language_code         in varchar2
  ,p_effective_date        in date
  )
return number;
--
Function get_classification_id
                       ( p_classification_name varchar2,
 			 p_business_group_id   number
                       ) RETURN NUMBER ;
--
Function get_formula_id( p_formula_Name      in varchar2,
  	  	         p_business_group_id in  number,
                         p_effective_date    in date
                       ) RETURN NUMBER ;
--
Function get_benefit_classification_id
         	      ( p_benefit_classification_name  in varchar2,
		        p_business_group_id 	       in  number
      		      ) RETURN NUMBER ;
--
Function get_iterative_formula_id
	              ( p_iterative_formula_name in varchar2,
	                p_business_group_id      in number ,
	                p_effective_date         in date
                      ) RETURN NUMBER ;
--
Function get_retro_summ_ele_id
	              ( p_retro_summ_element_name in varchar2,
 		        p_business_group_id       in number ,
		        p_effective_date          in date
		      ) RETURN NUMBER ;
--
Function get_proration_group_id
                      ( p_event_group_name   	in varchar2,
	        	p_business_group_id 	in number
	              ) RETURN NUMBER ;
--
Function get_proration_formula_id
	             ( p_proration_formula_Name in  varchar2,
 	               p_business_group_id      in  number,
	               p_effective_date         in  date
	             ) RETURN NUMBER ;
--
Function get_recalc_event_group_id
	             ( p_recalc_event_group_name in varchar2,
	               p_business_group_id       in number
	             ) RETURN NUMBER ;
--
Function get_element_type_ovn
                     ( p_element_type_user_key in varchar2,
                       p_effective_date        in date
                     ) return number ;
--
Function get_input_value_ovn ( p_element_type_user_key in varchar2,
                               p_existing_input_name   in varchar2,
                               p_business_group_id in number,
                               p_effective_date    in date,
                               p_language_code     in varchar2
                             ) return number ;
--
Function get_element_type_id
                     ( p_element_type_user_key in varchar2
                     ) return number ;
--
Function  get_input_value_formula_id
                     ( p_input_formula_name in varchar2,
 	               p_business_group_id  in number,
                       p_effective_date     in date
                     ) return number ;
--
Function get_input_value_id (p_element_type_user_key in varchar2,
                             p_existing_input_name   in varchar2,
                             p_business_group_id in number,
                             p_effective_date    in date,
                             p_language_code     in varchar2
                            ) return number;
--
END pay_element_data_pump ;

 

/
