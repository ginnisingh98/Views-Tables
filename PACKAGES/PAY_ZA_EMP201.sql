--------------------------------------------------------
--  DDL for Package PAY_ZA_EMP201
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_EMP201" AUTHID CURRENT_USER AS
/* $Header: pyzae201.pkh 120.0.12010000.2 2009/06/25 12:08:29 rbabla noship $ */
/* Copyright (c) Oracle Corporation 2005. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation EMP201 Package

   NAME
      pay_za_emp201.pkb

   DESCRIPTION
      This is the ZA EMP201 package.  It contains
      functions and procedures used by EMP201 Report.

   MODIFICATION HISTORY
   Person    Date       Version      Bug     Comments
   --------- ---------- ----------- ------- --------------------------------
   R Babla  10/06/2009 115.0       8512751   Initial Version

*/

 l_package_name CONSTANT VARCHAR2(30) := 'pay_za_emp201';

 --
 -- -----------------------------------------------------------------------------
 -- Data Types
 -- -----------------------------------------------------------------------------
 --

 TYPE t_xml_element_rec IS RECORD
     (tagname  VARCHAR2(100)
     ,tagvalue VARCHAR2(500)
     );

 TYPE t_xml_element_table IS TABLE OF t_xml_element_rec INDEX BY BINARY_INTEGER;

 --
 -- -----------------------------------------------------------------------------
 -- Global Variables
 -- -----------------------------------------------------------------------------
 --
 g_xml_element_table     t_xml_element_table;
 g_payroll_action_id     NUMBER;

 --
 -- -----------------------------------------------------------------------------
 -- Procedures
 -- -----------------------------------------------------------------------------
 --
   procedure range_cursor
   (
     pactid in  number,
     sqlstr out nocopy varchar2
   ) ;

   procedure archinit
   (
      p_payroll_action_id in number
   ) ;

   procedure action_creation
   (
      pactid    in number,
      stperson  in number,
      endperson in number,
      chunk     in number
   ) ;

   procedure archive_data
   (
      p_assactid       in number,
      p_archive_effective_date in date
   ) ;

 PROCEDURE get_emp201_xml
    (business_group_id  number
    ,calendar_month   varchar2
    ,calendar_month_hidden   varchar2
    ,EMP201_FILE_PREPROCESS   varchar2
    ,p_detail_flag   varchar2
    ,p_template_name     IN VARCHAR2
    ,p_xml               OUT NOCOPY CLOB) ;

function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2;


function formatted_canonical(
    canonical varchar2)
return varchar2;


END  PAY_ZA_EMP201 ;

/
