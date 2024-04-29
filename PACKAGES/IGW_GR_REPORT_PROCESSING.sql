--------------------------------------------------------
--  DDL for Package IGW_GR_REPORT_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_GR_REPORT_PROCESSING" AUTHID CURRENT_USER as
-- $Header: igwgrrpprs.pls 120.0 2005/06/16 23:01:35 vmedikon ship $

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGW_REPORT_PROCESSING';

  G_INSTALLATION_MODE CONSTANT VARCHAR2(30) := fnd_profile.value_wnps('IGW_PROPOSAL_INSTALLATION_MODE');

 FUNCTION get_last_first_middle_name(p_party_id      in        number,
                                                        p_proposal_id     in     number) return varchar2;

 FUNCTION get_job_title(p_party_id      in        number,
                                    p_proposal_id     in     number) return varchar2;

 FUNCTION get_person_organization(p_party_id      in        number) return varchar2;

 FUNCTION get_phone_number(p_party_id      in        number,
                                              p_proposal_id     in     number) return varchar2;

 FUNCTION get_fax_number(p_party_id      in        number,
                                         p_proposal_id      in      number) return varchar2;

 FUNCTION get_email_address(p_party_id      in        number,
                                             p_proposal_id       in     number) return varchar2;

  FUNCTION get_person_address(p_party_id  	in 	number,
                                                p_proposal_id      in        number) return  varchar2;

FUNCTION does_special_research (p_proposal_id      in          number,
                                                   p_special_review_code    in     number) return  varchar2;

FUNCTION animal_approval_date (p_proposal_id      in          number) return  date;

FUNCTION format_address
         ( i_address_line1 varchar2,
           i_address_line2 varchar2,
           i_address_line3 varchar2,
           i_town_or_city  varchar2,
           i_region_1      varchar2,
           i_region_2      varchar2,
           i_region_3      varchar2,
           i_postal_code   varchar2 ) RETURN varchar2;

FUNCTION format_address_multiline
         ( i_address_line1 varchar2,
           i_address_line2 varchar2,
           i_address_line3 varchar2,
           i_town_or_city  varchar2,
           i_region_1      varchar2,
           i_region_2      varchar2,
           i_region_3      varchar2,
           i_postal_code   varchar2 ) RETURN varchar2;

FUNCTION get_category_period_amount(p_proposal_id NUMBER,
						p_budget_category_code VARCHAR2,
						p_budget_period_id NUMBER) RETURN NUMBER;

FUNCTION get_category_period_desc(p_proposal_id NUMBER,
				       p_budget_category_code VARCHAR2,
			                   p_budget_period_id NUMBER)  RETURN VARCHAR2;

FUNCTION get_period_distr_dc(p_proposal_id NUMBER,
		                     p_budget_period_id NUMBER) return number;

FUNCTION get_period_distr_ic(p_proposal_id NUMBER,
		                     p_budget_period_id NUMBER) return number;

FUNCTION get_total_distr_dc(p_proposal_id NUMBER) return number;

FUNCTION get_total_distr_ic(p_proposal_id NUMBER) return number;

FUNCTION get_salary_requested(p_proposal_id 		NUMBER,
				p_party_id 		NUMBER,
		                        p_budget_period_id 	NUMBER) RETURN NUMBER;

FUNCTION get_employee_benefits(p_proposal_id 		NUMBER,
				 p_party_id 		NUMBER,
		                         p_budget_period_id 	NUMBER) RETURN NUMBER;

FUNCTION get_budget_percent_effort(p_proposal_id 		NUMBER,
				      p_party_id 			NUMBER,
		                              p_budget_period_id 		NUMBER) RETURN NUMBER;

FUNCTION get_budget_justification(p_proposal_id NUMBER,
				  p_budget_category_code VARCHAR2)  RETURN CLOB;


FUNCTION get_other_support_commitment(p_prop_person_support_id      NUMBER)  RETURN VARCHAR2;

FUNCTION get_person_effort(p_proposal_id      in         number,
                                          p_party_id           in         number) RETURN NUMBER;
 /*
 FUNCTION  get_org_party_name(p_party_id in number, p_org_id in number) RETURN VARCHAR2;
 pragma restrict_references(get_org_party_name, wnds, wnps);
*/

FUNCTION get_person_appt(p_proposal_id      in         number,
                         p_party_id         in         number) RETURN NUMBER;

END IGW_GR_REPORT_PROCESSING;

 

/
