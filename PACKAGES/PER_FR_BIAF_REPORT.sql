--------------------------------------------------------
--  DDL for Package PER_FR_BIAF_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_BIAF_REPORT" AUTHID CURRENT_USER as
/* $Header: pefrbiaf.pkh 120.5 2006/02/19 21:58 sbairagi noship $ */
TYPE XMLRec IS RECORD(
TagName VARCHAR2(1000),
TagValue VARCHAR2(1000));

TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;

PROCEDURE fill_table (p_employee_number IN varchar2,p_bg_id IN NUMBER ,p_asg_id NUMBER,p_effective_date date);
FUNCTION  get_contract_start_date(f_person_id IN number) return date;
FUNCTION  get_contract_end_date(f_person_id IN number) return date;
FUNCTION get_emp_total (lp_effective_date    IN DATE,
                        lp_est_id            IN NUMBER ,
                       -- lp_ent_id            IN NUMBER ,
                       -- lp_sex               IN VARCHAR2,
                        lp_udt_column        IN VARCHAR2
                        --lp_include_suspended IN VARCHAR2
			) RETURN NUMBER ;

PROCEDURE POPULATE_REPORT_DATA(p_employee_number IN varchar2,p_bg_id IN NUMBER ,p_asg_id NUMBER,p_asg_emp varchar2 ,p_effective_date varchar2 ,p_xfdf_blob OUT NOCOPY BLOB);
PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob);
PROCEDURE clob_to_blob (p_clob clob,
                        p_blob IN OUT NOCOPY Blob);



END PER_FR_BIAF_REPORT;

 

/
