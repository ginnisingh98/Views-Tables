--------------------------------------------------------
--  DDL for Package GMS_RES_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_RES_MAP" AUTHID CURRENT_USER AS
-- $Header: gmsfcrms.pls 115.7 2002/11/26 22:35:47 jmuthuku ship $
   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   TYPE resource_list_asgn_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE resource_list_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE member_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE member_level_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE resource_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE person_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE job_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE organization_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE vendor_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE expenditure_type_tabtype IS TABLE OF
        pa_txn_accum.expenditure_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE event_type_tabtype IS TABLE OF
        pa_txn_accum.event_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE non_labor_resource_tabtype IS TABLE OF
        pa_txn_accum.non_labor_resource%TYPE INDEX BY BINARY_INTEGER;
   TYPE expenditure_category_tabtype IS TABLE OF
        pa_txn_accum.expenditure_category%TYPE INDEX BY BINARY_INTEGER;
   TYPE revenue_category_tabtype IS TABLE OF
        pa_txn_accum.revenue_category%TYPE INDEX BY BINARY_INTEGER;
   TYPE nlr_org_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE event_type_class_tabtype IS TABLE OF
        pa_txn_accum.event_type_classification%TYPE INDEX BY BINARY_INTEGER;
   TYPE system_linkage_tabtype IS TABLE OF
        pa_txn_accum.system_linkage_function%TYPE INDEX BY BINARY_INTEGER;
   TYPE resource_format_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE resource_type_code_tabtype IS TABLE OF
        pa_resource_types.resource_type_code%TYPE INDEX BY BINARY_INTEGER;

   FUNCTION Initialize RETURN NUMBER;

   PROCEDURE get_resource_map
	   (x_resource_list_id             IN NUMBER,
	    x_resource_list_assignment_id  IN NUMBER,
	    x_person_id                    IN NUMBER,
	    x_job_id                       IN NUMBER,
	    x_organization_id              IN NUMBER,
	    x_vendor_id                    IN NUMBER,
	    x_expenditure_type             IN VARCHAR2,
	    x_event_type                   IN VARCHAR2,
	    x_non_labor_resource           IN VARCHAR2,
	    x_expenditure_category         IN VARCHAR2,
	    x_revenue_category             IN VARCHAR2,
	    x_non_labor_resource_org_id    IN NUMBER,
	    x_event_type_classification    IN VARCHAR2,
	    x_system_linkage_function      IN VARCHAR2,
	    x_resource_list_member_id   IN OUT NOCOPY NUMBER,
	    x_resource_id               IN OUT NOCOPY NUMBER,
	    x_resource_map_found        IN OUT NOCOPY BOOLEAN,
            x_err_stage                 IN OUT NOCOPY VARCHAR2,
            x_err_code                  IN OUT NOCOPY NUMBER);

   -- deleting the resource maps

   PROCEDURE delete_res_maps_on_asgn_id
	   (x_resource_list_assignment_id  IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2,
            x_err_code                  IN OUT NOCOPY NUMBER);

   PROCEDURE delete_res_maps_on_prj_id
	   (x_project_id                   IN NUMBER,
	    x_resource_list_id             IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2,
            x_err_code                  IN OUT NOCOPY NUMBER);

   -- the function given below creates a resource map

   PROCEDURE create_resource_map
	   (x_resource_list_id            IN NUMBER,
	    x_resource_list_assignment_id IN NUMBER,
	    x_resource_list_member_id     IN NUMBER,
	    x_resource_id                 IN NUMBER,
	    x_person_id                   IN NUMBER,
	    x_job_id                      IN NUMBER,
	    x_organization_id             IN NUMBER,
	    x_vendor_id                   IN NUMBER,
	    x_expenditure_type            IN VARCHAR2,
	    x_event_type                  IN VARCHAR2,
	    x_non_labor_resource          IN VARCHAR2,
	    x_expenditure_category        IN VARCHAR2,
	    x_revenue_category            IN VARCHAR2,
	    x_non_labor_resource_org_id   IN NUMBER,
	    x_event_type_classification   IN VARCHAR2,
	    x_system_linkage_function     IN VARCHAR2,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER);

   -- change resource list assignment

   PROCEDURE change_resource_list_status
           (x_resource_list_assignment_id IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER);

   FUNCTION get_resource_list_status
          (x_resource_list_assignment_id IN NUMBER)
          RETURN VARCHAR2 ;

   FUNCTION get_resource_rank
          (x_resource_format_id IN NUMBER,
	   x_txn_class_code     IN VARCHAR2)
          RETURN NUMBER ;

   FUNCTION get_group_resource_type_code
          (x_resource_list_id IN NUMBER)
          RETURN VARCHAR2 ;

   PROCEDURE create_resource_accum_details
	   (x_resource_list_id            IN NUMBER,
	    x_resource_list_assignment_id IN NUMBER,
	    x_resource_list_member_id     IN NUMBER,
	    x_resource_id                 IN NUMBER,
	    x_txn_accum_id                IN NUMBER,
	    x_project_id                  IN NUMBER,
	    x_task_id                     IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER);

   PROCEDURE delete_resource_accum_details
	   (x_resource_list_assignment_id IN NUMBER,
	    x_resource_list_id            IN NUMBER,
	    x_project_id                  IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER);

   PROCEDURE get_mappable_resources
           (x_project_id                     IN  NUMBER,
	    x_res_list_id                    IN  NUMBER,
	    x_resource_list_id            IN OUT NOCOPY resource_list_id_tabtype,
	    x_resource_list_assignment_id IN OUT NOCOPY resource_list_asgn_id_tabtype,
	    x_resource_list_member_id     IN OUT NOCOPY member_id_tabtype,
	    x_resource_id                 IN OUT NOCOPY resource_id_tabtype,
	    x_member_level                IN OUT NOCOPY member_level_tabtype,
	    x_person_id                   IN OUT NOCOPY person_id_tabtype,
	    x_job_id                      IN OUT NOCOPY job_id_tabtype,
	    x_organization_id             IN OUT NOCOPY organization_id_tabtype,
	    x_vendor_id                   IN OUT NOCOPY vendor_id_tabtype,
	    x_expenditure_type            IN OUT NOCOPY expenditure_type_tabtype,
	    x_event_type                  IN OUT NOCOPY event_type_tabtype,
	    x_non_labor_resource          IN OUT NOCOPY non_labor_resource_tabtype,
	    x_expenditure_category        IN OUT NOCOPY expenditure_category_tabtype,
	    x_revenue_category            IN OUT NOCOPY revenue_category_tabtype,
	    x_non_labor_resource_org_id   IN OUT NOCOPY nlr_org_id_tabtype,
	    x_event_type_classification   IN OUT NOCOPY event_type_class_tabtype,
	    x_system_linkage_function     IN OUT NOCOPY system_linkage_tabtype,
	    x_resource_format_id          IN OUT NOCOPY resource_format_id_tabtype,
	    x_resource_type_code          IN OUT NOCOPY resource_type_code_tabtype,
	    x_no_of_resources             IN OUT NOCOPY BINARY_INTEGER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER,
            x_exp_type                    IN VARCHAR2 DEFAULT NULL);

PROCEDURE map_trans
          ( x_project_id              		IN  NUMBER,
            x_res_list_id             		IN  NUMBER,
            x_person_id 			IN  NUMBER,
            x_job_id 				IN  NUMBER,
            x_organization_id 			IN  NUMBER,
            x_vendor_id			 	IN  NUMBER,
            x_expenditure_type 			IN  VARCHAR2,
            x_event_type 			IN  VARCHAR2,
            x_non_labor_resource 		IN  VARCHAR2,
            x_expenditure_category 		IN  VARCHAR2,
            x_revenue_category		 	IN  VARCHAR2,
            x_non_labor_resource_org_id	 	IN  NUMBER,
            x_event_type_classification 	IN  VARCHAR2,
            x_system_linkage_function 		IN  VARCHAR2 ,
            x_exptype                           IN VARCHAR2 DEFAULT NULL,
            x_resource_list_member_id		IN OUT NOCOPY NUMBER,
            x_err_stage            		IN OUT NOCOPY VARCHAR2,
            x_err_code             		IN OUT NOCOPY NUMBER);

 /* -------------------------------------------------------------------
|| Procedure MAP_RESOURCES is the new API for resource mapping
|| All codes calling this API must define a plsql table of type
|| "resource_type_table" defined below...
|| K.Biju -  27 march 2001
 --------------------------------------------------------------------- */

 Type resource_type_table is TABLE of VARCHAR2(60) INDEX by binary_integer;

 Procedure map_resources(x_document_type              IN varchar2,
                        x_document_header_id         IN number default NULL,
                        x_document_distribution_id   IN number default NULL,
                        x_expenditure_type           IN varchar2 default NULL,
                        x_expenditure_org_id         IN number default NULL,
                        x_categorization_code        IN varchar2 default NULL,
                        x_resource_list_id           IN number default NULL,
                        x_event_type                 IN varchar2 default NULL,
                        x_prev_list_processed        IN OUT NOCOPY number,
                        x_group_resource_type_id     IN OUT NOCOPY number,
                        x_group_resource_type_name   IN OUT NOCOPY varchar2,
                        resource_type_tab            IN OUT NOCOPY gms_res_map.resource_type_table,
                        x_resource_list_member_id    OUT NOCOPY number,
                        x_error_code                 OUT NOCOPY number,
                        x_error_buff                 OUT NOCOPY varchar2);


Procedure map_resources_group(x_document_type         IN varchar2,
                        x_expenditure_type           IN varchar2 default NULL,
                        x_expenditure_org_id         IN number default NULL,
                        x_person_id                  IN number  default NULL,
                        x_job_id                     IN number  default NULL,
                        x_vendor_id                  IN number  default NULL,
                        x_expenditure_category       IN varchar2 default NULL,
                        x_revenue_category           IN varchar2 default NULL,
                        x_categorization_code        IN varchar2 default NULL,
                        x_resource_list_id           IN number default NULL,
                        x_event_type                 IN varchar2 default NULL,
                        x_prev_list_processed        IN OUT NOCOPY number,
                        x_group_resource_type_id     IN OUT NOCOPY number,
                        x_group_resource_type_name   IN OUT NOCOPY varchar2,
                        resource_type_tab            IN OUT NOCOPY gms_res_map.resource_type_table,
                        x_resource_list_member_id    OUT NOCOPY number,
                        x_error_code                 OUT NOCOPY number,
                        x_error_buff                 OUT NOCOPY varchar2);


END GMS_RES_MAP;

 

/
