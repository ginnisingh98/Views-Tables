--------------------------------------------------------
--  DDL for Package PAY_CN_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_DRT" AUTHID CURRENT_USER AS
/* $Header: pycndrt.pkh 120.0.12010000.3 2018/03/23 10:34:46 dduvvuri noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_cn_drt
 Package File Name : pycndrt.pkh
 Description : CN Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 dduvvuri    14-Mar-2018   120.0             Created
************************************************************************ */


  PROCEDURE additional_filter(p_person_id IN NUMBER,
                               p_business_group_id IN NUMBER,
                               p_row_id IN VARCHAR2,
                               p_table_name IN VARCHAR2,
                               p_filter_value OUT NOCOPY VARCHAR2);

  PROCEDURE mask_value_udf(p_person_id IN NUMBER,
                             p_business_group_id IN NUMBER,
                             p_row_id IN VARCHAR2,
                             p_table_name IN VARCHAR2,
                             p_column_name IN VARCHAR2,
                             p_udf_mask_value OUT NOCOPY VARCHAR2);


END pay_cn_drt;

/
