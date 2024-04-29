--------------------------------------------------------
--  DDL for Package PA_FC_RES_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FC_RES_MAP" AUTHID CURRENT_USER AS
-- $Header: PAFCRMPS.pls 120.1 2005/08/08 15:16:06 pbandla noship $

-- deleting the resource maps
PROCEDURE delete_res_maps_on_asgn_id
	   (p_resource_list_assignment_id  IN NUMBER,
            x_return_status                 OUT NOCOPY VARCHAR2,
            x_error_message_code        OUT NOCOPY VARCHAR2);

PROCEDURE map_trans
          ( p_project_id              		IN  NUMBER,
            p_res_list_id             		IN  NUMBER,
            p_person_id 			IN  NUMBER,
            p_job_id 				IN  NUMBER,
            p_organization_id 			IN  NUMBER,
            p_vendor_id			 	IN  NUMBER,
            p_expenditure_type 			IN  VARCHAR2,
            p_event_type 			IN  VARCHAR2,
            p_non_labor_resource 		IN  VARCHAR2,
            p_expenditure_category 		IN  VARCHAR2,
            p_revenue_category		 	IN  VARCHAR2,
            p_non_labor_resource_org_id	 	IN  NUMBER,
            p_event_type_classification 	IN  VARCHAR2,
            p_system_linkage_function 		IN  VARCHAR2 ,
            p_exptype                           IN VARCHAR2 DEFAULT NULL,
            x_resource_list_member_id		OUT NOCOPY NUMBER,
            x_return_status            		OUT NOCOPY VARCHAR2,
            x_error_message_code             	OUT NOCOPY VARCHAR2);

END PA_FC_RES_MAP;

 

/
