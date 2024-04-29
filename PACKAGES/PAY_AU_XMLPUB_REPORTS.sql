--------------------------------------------------------
--  DDL for Package PAY_AU_XMLPUB_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_XMLPUB_REPORTS" AUTHID CURRENT_USER as
/* $Header: pyaurxml.pkh 120.1 2006/04/17 23:31:54 avenkatk noship $*/
/*
*** ------------------------------------------------------------------------+
*** Program:     PAY_AU_XMLPUB_REPORTS (Package Specification)
*** This package is used for all XML Publisher replated API's for Australia
*** Reports.
***
*** Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
***  7 Jul 05  avenkatk    1.0     3891577  Initial Version
***  6 Dec 05  avenkatk    1.2     4859876  Modified procedure submit_xml_reports
***                                         definition.
*** ------------------------------------------------------------------------+
*** R12 VERSIONS Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
*** 18 APR 06  avenkatk    12.1    4903621  Copy of Version 115.2, R12 Fix for
***                                         Bug 4859876
*** ------------------------------------------------------------------------+
*/

procedure submit_xml_reports
( p_conc_request_id in number,
  p_template_type in varchar2,
  p_template_name in xdo_templates_b.template_code%type);

function get_request_details
(p_conc_request_id in number)
return varchar2;


end  pay_au_xmlpub_reports;

 

/
