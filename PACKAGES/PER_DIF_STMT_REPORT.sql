--------------------------------------------------------
--  DDL for Package PER_DIF_STMT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DIF_STMT_REPORT" AUTHID CURRENT_USER AS
/* $Header: perfrdif.pkh 120.0 2006/04/11 23:12:19 nmuthusa noship $ */
--
-- Declare XML table
TYPE xml_rec IS RECORD(
tag_name VARCHAR2(1000),
tag_value VARCHAR2(1000));

TYPE xml_table_type IS TABLE OF xml_rec INDEX BY BINARY_INTEGER;
xml_table xml_table_type;
--
-- Main procedure for building XML string
PROCEDURE dif_main_fill_table(p_business_group_id NUMBER,
                              p_estab_id          NUMBER DEFAULT NULL,
			      p_accrual_plan_id   NUMBER ,
			      p_start_year        VARCHAR2,
			      p_start_month       NUMBER,
			      p_date_from         VARCHAR2,
			      p_end_year          VARCHAR2,
			      p_end_month         NUMBER,
			      p_date_to           VARCHAR2,
			      p_emp_id            NUMBER DEFAULT NULL,
			      p_sort_order        VARCHAR2,
			      p_template_name     VARCHAR2,
			      p_xml    OUT NOCOPY CLOB);
--
-- procedure for fetching employee, estab and accrual details
-- for each employee
PROCEDURE dif_emp_acc_details(p_business_group_id NUMBER,
                              p_estab_id          NUMBER ,
		              p_accrual_plan_id   NUMBER,
	                      p_emp_id            NUMBER,
		              p_date_from         DATE,
		              p_date_to           DATE);
--
-- procedure for writing to clob
PROCEDURE write_to_clob(p_xfdf_clob out nocopy clob);
--
END;

 

/
