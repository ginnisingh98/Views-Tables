--------------------------------------------------------
--  DDL for Package PER_US_EEO4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_EEO4_PKG" AUTHID CURRENT_USER AS
/* $Header: peruseeo4.pkh 120.0.12000000.1 2007/02/06 14:47:36 appldev noship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : PER_US_EEO4_PKG

    Package File Name   : peruseeo4.pkh

    Description         : This package is used by 'EEO4 Report (XML)'
                          concurrent program.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   27-JUN-2006  rpasumar    115.0           Created.
   19-JUL-2006  rpasumar    115.1           Fixed GSCC Errors.
   28-JUL-2006  rpasumar    115.2  5409988  Added the function check_function.
                                   5415136  Added the function get_function_number.
   31-JUL-2006  rpasumar    115.6  5414756  Added p_dynamic_where parameter to
                                            the procedure generate_sql to handle
					    the salaries more than 70000 per annum.
   ========================================================================*/

  TYPE  emp_rec IS RECORD (job_function                VARCHAR2(280)
                           ,lookup_code                VARCHAR2(30)
                           ,salary_range               VARCHAR2(30)
                           ,cons_total_category_emps   NUMBER
                           ,no_cons_wmale_emps         NUMBER
                           ,no_cons_bmale_emps         NUMBER
                           ,no_cons_hmale_emps         NUMBER
                           ,no_cons_amale_emps         NUMBER
                           ,no_cons_imale_emps         NUMBER
                           ,no_cons_wfemale_emps       NUMBER
                           ,no_cons_bfemale_emps       NUMBER
                           ,no_cons_hfemale_emps       NUMBER
                           ,no_cons_afemale_emps       NUMBER
                           ,no_cons_ifemale_emps       NUMBER);

  TYPE func_rec IS RECORD (job_function VARCHAR2(30)
                           ,description VARCHAR2(80));

  TYPE function_data IS TABLE OF func_rec
       INDEX BY BINARY_INTEGER;

  TYPE full_time_emp_data IS TABLE OF emp_rec
       INDEX BY BINARY_INTEGER;
  TYPE other_full_time_emp_data IS TABLE OF emp_rec
       INDEX BY BINARY_INTEGER;
  TYPE new_hire_emp_data IS TABLE OF emp_rec
       INDEX BY BINARY_INTEGER;

  PROCEDURE generate_xml_data(errbuf                    OUT NOCOPY VARCHAR2
                              ,retcode                  OUT NOCOPY NUMBER
                              ,p_reporting_year         IN NUMBER
                              ,p_add_message1           IN VARCHAR2
                              ,p_add_message2           IN VARCHAR2
                              ,p_add_message3           IN VARCHAR2
                              ,p_add_message4           IN VARCHAR2
                              ,p_add_message5           IN VARCHAR2
                              ,p_add_message6           IN VARCHAR2
                              ,p_add_message7           IN VARCHAR2
                              ,p_business_group_id      IN VARCHAR2
                              ,p_full_time_emp_count    IN NUMBER
                              ,p_emp_count_for_function IN NUMBER
                             );
  -- Bug# 5414756
  PROCEDURE generate_sql(p_job_codes IN VARCHAR2 , p_dynamic_where IN VARCHAR2);

  PROCEDURE populate_ft_emp_data(p_function_code IN VARCHAR2);
  PROCEDURE populate_oft_emp_data(p_function_code IN VARCHAR2);
  PROCEDURE populate_nh_emp_data(p_function_code IN VARCHAR2);

  PROCEDURE generate_header_xml_data;
  PROCEDURE generate_juris_cert_xml_data;
  PROCEDURE create_xml(p_current_function IN VARCHAR2);
  PROCEDURE generate_footer_xml_data;

  PROCEDURE create_report(report_type NUMBER);


  PROCEDURE generate_ft_xml_data(p_function_code IN VARCHAR2);
  PROCEDURE generate_oft_xml_data(p_function_code IN VARCHAR2);
  PROCEDURE generate_nh_xml_data(p_function_code IN VARCHAR2);

  FUNCTION convert_into_xml( p_name  IN VARCHAR2
                             ,p_value IN VARCHAR2
                             ,p_type  IN char)
  RETURN VARCHAR2;

  FUNCTION get_lookup_meaning(p_emp_category IN NUMBER, p_lookup_code IN NUMBER)
  RETURN VARCHAR2;

  PROCEDURE write_to_concurrent_out(p_text IN varchar2);

  -- Bug# 5409988
  PROCEDURE check_function(p_function_code IN NUMBER);

  -- Bug# 5415136
  FUNCTION get_function_number(p_function_code IN NUMBER)
  RETURN NUMBER;

END PER_US_EEO4_PKG;


 

/
