--------------------------------------------------------
--  DDL for Package HXC_PROJ_MANAGER_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_PROJ_MANAGER_APPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcpamgrapr.pkh 120.1 2005/10/04 05:41:08 sechandr noship $ */

TYPE rec_project_id is RECORD(
project_id Pa_projects_all.project_id%TYPE,
Manager_id per_all_people_f.person_id%TYPE
);

TYPE tab_project_id IS TABLE OF
rec_project_id
INDEX BY BINARY_INTEGER;


/*
PROCEDURE categorize_project_managers
		        (errbuf              out NOCOPY varchar2
		       ,retcode             out NOCOPY number
		       ,p_default_approval_mechanism in varchar2 default 'AUTO_APPROVE'
		       ,p_Is_selected in varchar2 default null
		       ,p_mechanism_id in varchar2 default null );

*/
PROCEDURE create_time_cat(p_project_id in number,
			p_approval_style_id in number,
			p_parent_comp_id in number,
			p_parent_object_version_number in number,
			p_default_approval_mechanism in varchar2 default null,
			p_mechanism_id in number default null ,
			p_wf_name  in varchar2 default null,
			p_wf_item_type  in varchar2 default null,
			p_manager_id out NOCOPY number);



PROCEDURE replace_projman_by_spl_ela( p_tab_project_id in out NOCOPY tab_project_id ,
				   p_new_spl_ela_style_id out NOCOPY number
					);

END hxc_proj_manager_approval_pkg ;


 

/
