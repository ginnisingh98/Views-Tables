--------------------------------------------------------
--  DDL for Package PAY_GB_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_DRT" AUTHID CURRENT_USER AS
/* $Header: pygbdrt.pkh 120.0.12010000.1 2018/03/22 05:38:42 anmosing noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_gb_drt
 Package File Name : pygbdrt.pkh
 Description : GB localization specific package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 shekhsum      20-Mar-2018   120.0             Created
************************************************************************ */

     /*Additional Filter localization procedure that is called through
	   Core Pay package pay_drt_utils */

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



END pay_gb_drt;

/
