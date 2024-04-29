--------------------------------------------------------
--  DDL for Package PAY_PAYRPENP_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYRPENP_XML_PKG" AUTHID CURRENT_USER as
/* $Header: pyxmlenp.pkh 120.0 2005/10/05 09:40 mkataria noship $ */


procedure emp_asg_not_processed
(
  p_start_date_char       in varchar2
 ,p_end_date_char         in varchar2
 ,p_payroll_id            in number    default null
 ,p_consolidation_set_id  in number
 ,p_organization_id       in number    default null
 ,p_location_id           in number    default null
 ,p_sort_option_one       in varchar2  default null
 ,p_sort_option_two       in varchar2  default null
 ,p_sort_option_three     in varchar2  default null
 ,p_business_group_id     in varchar2  default null
 ,p_session_date_char     in varchar2  default null
 ,p_template_name         in varchar2
 ,p_xml                   out nocopy clob
) ;

end PAY_PAYRPENP_XML_PKG;

 

/
