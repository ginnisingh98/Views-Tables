--------------------------------------------------------
--  DDL for Package PAY_US_LOC_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_LOC_CHANGE" AUTHID CURRENT_USER as
/* $Header: pyuslocu.pkh 120.0.12010000.1 2008/07/27 23:53:09 appldev ship $ */
procedure cnt_print_report;
procedure get_insert_values ( p_proc_name varchar2,
                              p_assignment_id number,
                               p_location_id number,
                               p_gre_name IN OUT NOCOPY varchar2,
                               p_full_name IN OUT NOCOPY varchar2,
                               p_assignment_number IN OUT NOCOPY varchar2,
                               p_location_code IN OUT  NOCOPY varchar2);


procedure put_into_temp_table(
                                  p_tax_unit_name varchar2,
                                  p_location_code varchar2,
                                  p_emp_full_name varchar2,
                                  p_assignment_number varchar2,
                                  p_effective_start_date date,
                                  p_effective_end_date  date,
				  p_error varchar2
                                  );

procedure update_tax(errbuf     OUT    NOCOPY VARCHAR2,
                     retcode    OUT    NOCOPY NUMBER,
                     p_location_id in number);

end pay_us_loc_change;

/
