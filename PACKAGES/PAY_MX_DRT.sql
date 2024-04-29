--------------------------------------------------------
--  DDL for Package PAY_MX_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_DRT" AUTHID CURRENT_USER AS
/* $Header: pymxdrt.pkh 120.0.12010000.5 2018/05/11 07:03:51 nvelaga noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_mx_drt
 Package File Name : pymxdrt.pkh
 Description : Canada localization specific package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 sjawid      27-Mar-2018   120.0             Created
 sjawid      29-Mar-2018   120.0.12010000.3  bug 27660716 Added DRC procedure(dummy)
 sjawid	     12-Apr-2018   120.0.12010000.4  bug 27849164 - Modified DRC procedure signature
 nvelaga     11-May-2018   120.0.12010000.5  Bug 27980337 - Added overwrite_dis_reg_id
************************************************************************ */

   PROCEDURE pay_mx_hr_post(p_person_id NUMBER);

   PROCEDURE PAY_MX_HR_DRC
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

   FUNCTION overwrite_dis_reg_id(rid IN ROWID,
                                 table_name IN VARCHAR2,
                                 column_name IN VARCHAR2,
                                 person_id IN NUMBER
                                )
   RETURN VARCHAR2;

END pay_mx_drt;

/
