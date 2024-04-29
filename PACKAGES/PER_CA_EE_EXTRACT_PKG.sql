--------------------------------------------------------
--  DDL for Package PER_CA_EE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CA_EE_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: pecaeerp.pkh 115.6 2003/05/22 01:54:58 ssouresr noship $ */
--
k	number := 1;
--
-- if check_gre_without_naic returns -1 then error
-- out the report mentioning the GRE name which doesn't
-- have a NAIC mentioned, else in the report we call
-- the other functions
--
TYPE tab_varchar2 IS TABLE OF VARCHAR2(100)
                  INDEX BY BINARY_INTEGER;

TYPE person_tab IS TABLE OF per_assignments_f.person_id%type
                  INDEX BY BINARY_INTEGER;
TYPE softcoding_tab IS TABLE OF per_assignments_f.soft_coding_keyflex_id%type
                  INDEX BY BINARY_INTEGER;

TYPE org_info8_tab IS TABLE OF hr_organization_information.org_information8%type
                  INDEX BY BINARY_INTEGER;
TYPE organization_id_tab IS TABLE OF hr_organization_information.organization_id%type
                  INDEX BY BINARY_INTEGER;

TYPE segment1_tab IS TABLE OF hr_soft_coding_keyflex.segment1%type
                  INDEX BY BINARY_INTEGER;
TYPE segment6_tab IS TABLE OF hr_soft_coding_keyflex.segment6%type
                  INDEX BY BINARY_INTEGER;

TYPE naic_tab IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;
TYPE naic_count_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE job_id_tab IS TABLE OF per_jobs.job_id%type
                  INDEX BY BINARY_INTEGER;
TYPE job_tab IS TABLE OF hr_lookups.meaning%type
                  INDEX BY BINARY_INTEGER;

TYPE person_type_tab IS TABLE OF per_person_types.person_type_id%type
                  INDEX BY BINARY_INTEGER;

function employee_promotions (p_assignment_id     in number,
                              p_person_id         in number,
                              p_business_group_id in number,
                              p_start_date        in date,
                              p_end_date          in date,
                              p_boolean           in varchar2)
                                return number;

function job_exists (p_job_id in number)
                                return varchar2;
--
function person_type_exists (p_person_type in number)
                                return varchar2;

function check_gre_without_naic(p_business_group_id in number,
                                p_gre_name OUT NOCOPY tab_varchar2)
                                return number;
--
function form1(p_business_group_id in number,
	       p_request_id     in number,
	       p_year           in varchar2,
               p_naic_code      in varchar2,
               p_date_all_emp	in date,
               p_date_tmp_emp   in date) return number;
--
function form2n(p_business_group_id in number,
	       p_request_id     in number,
	       p_year           in varchar2,
               p_date_tmp_emp   in date) return number;
--
function form2(p_business_group_id in number,
	       p_request_id     in number,
	       p_year           in varchar2,
               p_date_tmp_emp   in date) return number;
--
function form3(p_business_group_id in number,
	       p_request_id     in number,
	       p_year           in varchar2,
               p_date_tmp_emp   in date) return number;
--
function form4(p_business_group_id in number,
	       p_request_id     in number,
	       p_year           in varchar2,
               p_date_tmp_emp   in date) return number;
--
function form5(p_business_group_id in number,
	       p_request_id     in number,
	       p_year           in varchar2,
               p_date_tmp_emp   in date) return number;
--
function form6(p_business_group_id in number,
	       p_request_id     in number,
	       p_year           in varchar2,
               p_date_tmp_emp   in date) return number;
--
function update_rec(p_request_id number) return number;
--

end per_ca_ee_extract_pkg;

 

/
