--------------------------------------------------------
--  DDL for Package MRP_GET_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GET_PROJECT" AUTHID CURRENT_USER AS
	/* $Header: MRPGPRJS.pls 120.0 2005/05/24 17:36:20 appldev noship $ */

	FUNCTION project(arg_project_id IN NUMBER) return varchar2;

	FUNCTION task(arg_task_id IN NUMBER) return varchar2;

	FUNCTION planning_group(arg_project_id IN NUMBER) return varchar2;

        FUNCTION lookup_fnd(arg_lookup_type IN varchar2,
                            arg_lookup_code IN varchar2) return fnd_lookups.meaning%type;

        FUNCTION lookup_meaning(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER) return varchar2;

        FUNCTION org_code(arg_org_id IN NUMBER) return varchar2;

        FUNCTION item_name(arg_org_id IN NUMBER,
                       arg_item_id IN NUMBER) return varchar2;

        FUNCTION item_desc(arg_org_id IN NUMBER,
                       arg_item_id IN NUMBER) return varchar2;

        FUNCTION category_desc(arg_cat_set_id IN NUMBER,
                       arg_cat_id IN NUMBER) return varchar2;

        FUNCTION category_name(arg_cat_id IN NUMBER) return varchar2;

        FUNCTION customer_name(arg_cust_id IN NUMBER) return varchar2;

        FUNCTION ship_to_address(arg_site_id IN NUMBER) return varchar2;

        FUNCTION vendor_site_code(arg_org_id IN NUMBER,
                                  arg_vendor_site_id IN NUMBER) return varchar2;

	PRAGMA RESTRICT_REFERENCES (project, WNDS,WNPS);
  	PRAGMA RESTRICT_REFERENCES (task, WNDS,WNPS);
  	PRAGMA RESTRICT_REFERENCES (planning_group, WNDS,WNPS);
end MRP_GET_PROJECT;
 

/
