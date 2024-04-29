--------------------------------------------------------
--  DDL for Package PAY_US_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_DRT" AUTHID CURRENT_USER AS
/* $Header: pyusdrt.pkh 120.0.12010000.7 2018/04/12 05:17:38 sjawid noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_us_drt
 Package File Name : pyusdrt.pkh
 Description : US localization specific package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 sjawid      03-Mar-2018   120.0             Created
 sjawid     13-Mar-2018    120.2            bug 27660716
 sjawid     03-Apr-2018    120.0.12010000.5 bug 27660716 Added DRC procedure(dummy)
 sjawid	    12-Apr-2018    120.0.12010000.7 bug 27849164 - Modified DRC procedure signature
************************************************************************ */

     /*Additional Filter localization procedure that is called through
	   Core Pay package pay_drt_utils */

     PROCEDURE write_log
      (message IN varchar2
       ,stage   IN varchar2);

     PROCEDURE add_to_results
	      (person_id   IN            number
	      ,entity_type IN            varchar2
	      ,status      IN            varchar2
	      ,msgcode     IN            varchar2
	      ,msgaplid    IN            number
	      ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type);


     PROCEDURE pay_final_process_check
        (p_person_id       IN         number
        ,p_legislation_code IN varchar2
       ,p_constraint_months IN number
       ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);


	PROCEDURE additional_filter(
              p_person_id NUMBER,
              p_business_group_id NUMBER,
              p_row_id VARCHAR2,
              p_table_name VARCHAR2,
              p_filter_value OUT nocopy VARCHAR2);


     /* localization specific procedure that is called through
	   Core Pay package pay_udf */


	  PROCEDURE  mask_value_udf(
                   p_person_id NUMBER,
                   p_business_group_id  NUMBER,
                   p_row_id VARCHAR2,
                   p_table_name VARCHAR2,
                   p_column_name VARCHAR2,
                   p_udf_mask_value OUT nocopy VARCHAR2 );


   PROCEDURE purge_archive_data (p_person_id NUMBER, p_legislation_code VARCHAR2);

       /* Post process procedure */
   PROCEDURE pay_us_hr_post(p_person_id NUMBER);

   PROCEDURE PAY_US_HR_DRC
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

END pay_us_drt;

/
