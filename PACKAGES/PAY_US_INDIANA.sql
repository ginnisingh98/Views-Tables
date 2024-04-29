--------------------------------------------------------
--  DDL for Package PAY_US_INDIANA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_INDIANA" AUTHID CURRENT_USER as
/* $Header: pyusinyb.pkh 120.0.12010000.1 2008/07/27 23:52:48 appldev ship $*/

PROCEDURE print_report_address(errbuf             OUT     NOCOPY VARCHAR2,
                               retcode            OUT     NOCOPY NUMBER);

PROCEDURE print_override_location(errbuf             OUT     NOCOPY VARCHAR2,
                                  retcode            OUT     NOCOPY NUMBER,
                                  p_business_group   IN      VARCHAR2,
                                  p_curr_year        IN      VARCHAR2);

PROCEDURE get_insert_values (  p_proc_name                VARCHAR2,
                               p_BUSINESS_GROUP_ID        VARCHAR2,
                               p_person_id                VARCHAR2,
                               p_curr_year                VARCHAR2,
                               p_gre_name          IN OUT NOCOPY VARCHAR2,
                               p_full_name         IN OUT NOCOPY VARCHAR2,
                               p_employee_number   IN OUT NOCOPY VARCHAR2);


procedure  put_into_temp_table(
                                  p_tax_unit_name in varchar2,
                                  p_emp_full_name in varchar2,
                                  p_employee_number in varchar2,
                                  p_effective_start_date in date,
                        	  p_town_or_city in varchar2,
                        	  p_region_1 in varchar2,
                        	  p_region_2 in varchar2,
                        	  p_postal_code in varchar2,
                        	  p_add_information17 in varchar2,
                        	  p_add_information18 in varchar2,
                        	  p_add_information19 in varchar2,
                        	  p_add_information20 in varchar2,
     				  p_error in varchar2
				);

procedure update_address(errbuf             OUT     NOCOPY VARCHAR2,
                         retcode            OUT     NOCOPY NUMBER,
                         p_business_group   IN      VARCHAR2,
                         p_curr_year        IN      VARCHAR2) ;

end pay_us_indiana;

/
