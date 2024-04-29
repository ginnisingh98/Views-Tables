--------------------------------------------------------
--  DDL for Package PER_ZA_WSP_XML_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_WSP_XML_GEN_PKG" AUTHID CURRENT_USER as
/* $Header: perzawspg.pkh 120.1.12010000.1 2008/07/28 05:54:36 appldev ship $ */
/*+======================================================================+
  |       Copyright (c) 2002 Oracle Corporation                          |
  |                           All rights reserved.                       |
  +======================================================================+
  SQL Script File name : perzaxmlg.pkh
  Description          : This sql script seeds the Package Header that
                         generates XML data for WSP report.

  Change List:
  ------------

  Name           Date        Version Bug     Text
  -------------- ----------- ------- ------  ----------------------------
  Kaladhaur      27-DEC-2006 115.0           First created
  A. Mahanty     19-FEB-2007 115.1           Removed gscc errors
 ========================================================================
*/

procedure populate_xml_data ( p_business_group_id     in number
                            , p_payroll_action_id     in varchar2
                            , p_legal_entity_id       in number
                            , p_template_name         IN VARCHAR2
                            , p_xml                   out nocopy clob);

function preprocess_value
   (
   p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
   p_legislative_parameters in pay_payroll_actions.legislative_parameters%type
   )
return varchar2;


end PER_ZA_WSP_XML_GEN_PKG;

/
