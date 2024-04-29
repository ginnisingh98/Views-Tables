--------------------------------------------------------
--  DDL for Package RRS_HIERARCHY_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_HIERARCHY_INFO" AUTHID CURRENT_USER AS
/* $Header: RRSGHDTS.pls 120.1.12010000.4 2009/08/08 17:39:29 nlal noship $ */


G_RET_STS_SUCCESS	CONSTANT VARCHAR2(1):='S';
G_RET_STS_ERROR         CONSTANT VARCHAR2(1):='E';
G_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1):='U';
G_RET_STS_WARNING       CONSTANT VARCHAR2(1):='W';

e_no_hierarchy_found		EXCEPTION;
e_no_parent_member_found	EXCEPTION;


------------------------
--Get Hierarchy Header--
------------------------

Procedure Get_Hierarchy_Header(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_return_status                 OUT NOCOPY	varchar2
       ,x_msg_count                     OUT NOCOPY	number
       ,x_msg_data                      OUT NOCOPY	varchar2
);

Procedure Get_Hierarchy_Header(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_return_status                 OUT NOCOPY	varchar2
       ,x_msg_count                     OUT NOCOPY	number
       ,x_msg_data                      OUT NOCOPY	varchar2
);

Procedure Get_Hierarchy_Header(
	p_api_version              	IN         	number
       ,p_hier_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_return_status                 OUT NOCOPY	varchar2
       ,x_msg_count                     OUT NOCOPY	number
       ,x_msg_data                      OUT NOCOPY	varchar2
);

-------------------------
--Get Hierarchy Members--
-------------------------

Procedure Get_Hierarchy_Members(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,p_parent_member_type		IN		varchar2
       ,p_parent_member_id_num		IN		varchar2
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

Procedure Get_Hierarchy_Members(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,p_parent_member_type		IN		varchar2
       ,p_parent_member_id_num		IN		varchar2
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

Procedure Get_Hierarchy_Members(
	p_api_version			IN		number
       ,p_hier_name			IN		varchar2
       ,p_hier_version_number		IN		number
       ,p_parent_member_type		IN		varchar2
       ,p_parent_member_id_num		IN		varchar2
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

----------------------------
--Get Hierarchy Attributes--
----------------------------

Procedure Get_Hierarchy_Attributes(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

Procedure Get_Hierarchy_Attributes(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

Procedure Get_Hierarchy_Attributes(
	p_api_version			IN		number
       ,p_hier_name			IN		varchar2
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

----------------------------------
--Get Hierarchy Complete Details--
----------------------------------

Procedure Get_Complete_Hierarchy_Details(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

Procedure Get_Complete_Hierarchy_Details(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);

Procedure Get_Complete_Hierarchy_Details(
	p_api_version			IN		number
       ,p_hier_name			IN		varchar2
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
);


/**
 ** Test Methods
 **
 *
Procedure Get_Hierarchy_Header_Test;
Procedure Get_Hierarchy_Members_Test;
Procedure Get_Hierarchy_Attributes_Test;
Procedure Get_Comp_Hier_Details_Test;
*/

END RRS_HIERARCHY_INFO;

/
