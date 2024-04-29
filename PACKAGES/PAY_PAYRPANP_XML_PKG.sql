--------------------------------------------------------
--  DDL for Package PAY_PAYRPANP_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYRPANP_XML_PKG" AUTHID CURRENT_USER AS
/* $Header: pyxmlanp.pkh 120.0 2005/10/05 09:38 mkataria noship $ */



procedure actions_not_processed
(
  p_start_date_char       in varchar2
 ,p_end_date_char         in varchar2
 ,p_payroll_id            in number    default null
 ,p_consolidation_set_id  in number    default null
 ,p_report_name           in varchar2
 ,p_mode                  in varchar2
 ,p_business_group_id     in varchar2
 ,p_session_date_char     in varchar2
 ,p_template_name         in varchar2
 ,p_xml                   out nocopy clob
) ;

end PAY_PAYRPANP_XML_PKG;

 

/
