--------------------------------------------------------
--  DDL for Package Body IGW_GR_REPORT_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_GR_REPORT_PROCESSING" as
-- $Header: igwgrrpprb.pls 120.1 2005/09/12 22:01:18 ashkumar ship $

--G_INSTALLATION_MODE	VARCHAR2(30) := fnd_profile.value_wnps('IGW_PROPOSAL_INSTALLATION_MODE');
--------------------------------------------------------------------------------------------------
FUNCTION get_last_first_middle_name(p_party_id      in        number,
                                                       p_proposal_id     in    number) return varchar2 is
begin
   return null;
end get_last_first_middle_name;
--------------------------------------------------------------
FUNCTION get_job_title(p_party_id      in        number,
                                  p_proposal_id      in    number) return varchar2 is
begin
   return null;
end get_job_title;

--------------------------------------------------------------
FUNCTION get_person_organization(p_party_id      in        number) return varchar2 is
begin
   return  null;
end get_person_organization;
-------------------------------------------------------------------
FUNCTION get_phone_number(p_party_id      in        number,
                                            p_proposal_id       in      number) return varchar2 is
begin
   return null;
end get_phone_number;
---------------------------------------------------------------------

FUNCTION get_fax_number(p_party_id      in        number,
                                        p_proposal_id      in    number) return varchar2 is
begin
   return null;
end get_fax_number;
---------------------------------------------------------------------
FUNCTION get_email_address(p_party_id      in        number,
                                            p_proposal_id    in     number) return varchar2 is
begin
   return null;
end get_email_address;
-----------------------------------------------------------------------
FUNCTION get_person_address(p_party_id  	in 	number,
                                              p_proposal_id      in          number) return  varchar2 is
begin
	return null;
end get_person_address;
------------------------------------------------------------------
FUNCTION does_special_research (p_proposal_id      in          number,
                                                   p_special_review_code     in     number)   return  varchar2 is
begin
		return null;
end does_special_research;
--------------------------------------------------------------------------
FUNCTION animal_approval_date (p_proposal_id      in          number) return  date is
begin
		return null;
end animal_approval_date;
----------------------------------------------------------------------------
FUNCTION format_address
         ( i_address_line1 varchar2,
           i_address_line2 varchar2,
           i_address_line3 varchar2,
           i_town_or_city  varchar2,
           i_region_1      varchar2,
           i_region_2      varchar2,
           i_region_3      varchar2,
           i_postal_code   varchar2 )
RETURN varchar2 IS
BEGIN
   return null;
END;

FUNCTION format_address_multiline
         ( i_address_line1 varchar2,
           i_address_line2 varchar2,
           i_address_line3 varchar2,
           i_town_or_city  varchar2,
           i_region_1      varchar2,
           i_region_2      varchar2,
           i_region_3      varchar2,
           i_postal_code   varchar2 )
RETURN varchar2 IS
BEGIN
   return null;
END;

FUNCTION get_category_period_amount(p_proposal_id NUMBER,
						p_budget_category_code VARCHAR2,
						p_budget_period_id NUMBER)
RETURN NUMBER IS
BEGIN
            return null;
END get_category_period_amount;

---------------------------------------------------------------------------
FUNCTION get_category_period_desc(p_proposal_id NUMBER,
				       p_budget_category_code VARCHAR2,
		                               p_budget_period_id NUMBER)
RETURN VARCHAR2 IS
begin
           return null;
end get_category_period_desc;

---------------------------------------------------------------------
FUNCTION get_period_distr_dc(p_proposal_id NUMBER,
		                     p_budget_period_id NUMBER) return number is
begin
         return null;
end get_period_distr_dc;

--------------------------------------------------------------------
FUNCTION get_total_distr_dc(p_proposal_id NUMBER) return number is
begin
         return null;
end get_total_distr_dc;

--------------------------------------------------------------------
FUNCTION get_total_distr_ic(p_proposal_id NUMBER) return number is
begin
         return null;
end get_total_distr_ic;
-----------------------------------------------------------------
FUNCTION get_period_distr_ic(p_proposal_id NUMBER,
		                    p_budget_period_id NUMBER) return number is
begin
         return null;
end get_period_distr_ic;
--------------------------------------------------------------------
FUNCTION get_salary_requested(p_proposal_id 		NUMBER,
				p_party_id 		NUMBER,
		                        p_budget_period_id 	NUMBER) RETURN NUMBER IS
begin
         return null;
end get_salary_requested;

--------------------------------------------------------------
FUNCTION get_employee_benefits(p_proposal_id 		NUMBER,
				 p_party_id 		NUMBER,
		                         p_budget_period_id 	NUMBER) RETURN NUMBER IS
begin
         return null;
end get_employee_benefits;

-------------------------------------------------------
FUNCTION get_budget_percent_effort(p_proposal_id 		NUMBER,
				      p_party_id 			NUMBER,
		                              p_budget_period_id 		NUMBER) RETURN NUMBER IS
begin
          return null;
end get_budget_percent_effort;
------------------------------------------------------
FUNCTION get_budget_justification(p_proposal_id NUMBER,
			              p_budget_category_code VARCHAR2)
RETURN CLOB IS
BEGIN
    RETURN null;
END get_budget_justification;

---------------------------------------------------------------------------
FUNCTION get_other_support_commitment(p_prop_person_support_id      NUMBER)
RETURN VARCHAR2 IS
begin
           return null;
end get_other_support_commitment;
-----------------------------------------------------------------------------------
FUNCTION get_person_effort(p_proposal_id      in         number,
                                          p_party_id           in         number)
RETURN NUMBER IS
begin
           return null;
end get_person_effort;

------------------------------------------------------------------------------------
FUNCTION get_person_appt(p_proposal_id      in         number,
                         p_party_id         in         number)
RETURN NUMBER IS
BEGIN
   return null;
END get_person_appt;
END IGW_GR_REPORT_PROCESSING;

/
