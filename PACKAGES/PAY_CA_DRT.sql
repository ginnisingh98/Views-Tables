--------------------------------------------------------
--  DDL for Package PAY_CA_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_DRT" AUTHID CURRENT_USER AS
/* $Header: pycadrt.pkh 120.0.12010000.5 2018/04/12 05:19:59 sjawid noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_ca_drt
 Package File Name : pycadrt.pkh
 Description : Canada localization specific package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 sjawid      03-Mar-2018   120.0             Created
 sjawid      03-Mar-2018   120.0.12010000.4  bug 27660716 Added DRC procedure
 sjawid	     12-Apr-2018   120.0.12010000.5  bug 27849164 - Modified DRC procedure signature
************************************************************************ */

     PROCEDURE write_log
      (message IN varchar2
       ,stage   IN varchar2);

     /*Additional Filter localization procedure that is called through
	   Core Pay package pay_drt_utils */

	PROCEDURE additional_filter(
              p_person_id IN NUMBER,
              p_business_group_id IN NUMBER,
              p_row_id IN VARCHAR2,
              p_table_name IN VARCHAR2,
              p_filter_value OUT nocopy VARCHAR2);


     /* localization specific procedure that is called through
	   Core Pay package pay_udf */


	  PROCEDURE  mask_value_udf(
                   p_person_id IN NUMBER,
                   p_business_group_id IN NUMBER,
                   p_row_id IN VARCHAR2,
                   p_table_name IN VARCHAR2,
                   p_column_name IN VARCHAR2,
                   p_udf_mask_value OUT nocopy VARCHAR2 );


   PROCEDURE pay_ca_hr_post(p_person_id NUMBER);

   PROCEDURE PAY_CA_HR_DRC
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

END pay_ca_drt;

/
