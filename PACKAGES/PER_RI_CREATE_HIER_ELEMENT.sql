--------------------------------------------------------
--  DDL for Package PER_RI_CREATE_HIER_ELEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CREATE_HIER_ELEMENT" AUTHID CURRENT_USER As
/* $Header: perrihierele.pkh 120.0 2005/06/24 07:54 appldev noship $*/

Function get_line_status(p_view Varchar2,p_dp_batch_line_id Number)
Return Varchar2;

Procedure insert_batch_lines(P_BATCH_ID                     in number
			     ,P_DATA_PUMP_BATCH_LINE_ID     in number default null
			     ,P_DATA_PUMP_BUSINESS_GRP_NAME in varchar2 default null
	                     ,P_USER_SEQUENCE               in number default null
			     ,P_LINK_VALUE                  in number default null
			     ,P_EFFECTIVE_DATE              in date
			     ,P_DATE_FROM                   in date
			     ,P_VIEW_ALL_ORGS               in varchar2
			     ,P_END_OF_TIME                 in date
	                     ,P_HR_INSTALLED                in varchar2
	                     ,P_PA_INSTALLED                in varchar2
	                     ,P_POS_CONTROL_ENABLED_FLAG    in varchar2
	                     ,P_WARNING_RAISED              in varchar2
			     ,P_PARENT_ORGANIZATION_NAME    in varchar2
			     ,P_LANGUAGE_CODE               in varchar2
			     ,P_ORG_STR_VERSION_USER_KEY    in varchar2
			     ,P_CHILD_ORGANIZATION_NAME     in varchar2
			     ,P_SECURITY_PROFILE_NAME       in varchar2) ;

end per_ri_create_hier_element;

 

/
