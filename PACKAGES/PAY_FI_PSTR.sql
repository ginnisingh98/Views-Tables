--------------------------------------------------------
--  DDL for Package PAY_FI_PSTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_PSTR" AUTHID CURRENT_USER AS
/* $Header: pyfipstr.pkh 120.0.12000000.1 2007/04/26 12:12:16 dbehera noship $ */
type xml_rec_type is record (
      tagname    varchar2 (240),
      tagvalue   varchar2 (240)
   );

   type xml_tab_type is table of xml_rec_type
      index by binary_integer;

   xml_tab                   xml_tab_type;

   procedure populate_details (
      p_business_group_id   in              number,
      p_payroll_action_id   in              varchar2,
      p_template_name       in              varchar2,
      p_xml                 out nocopy      clob
   );

   procedure writetoclob (
      p_xfdf_clob   out nocopy   clob
   );
 END PAY_FI_PSTR;

 

/
