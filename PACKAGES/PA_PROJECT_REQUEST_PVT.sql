--------------------------------------------------------
--  DDL for Package PA_PROJECT_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_REQUEST_PVT" AUTHID CURRENT_USER as
/* $Header: PAYRPVTS.pls 120.1 2005/08/19 17:25:13 mwasowic noship $ */

-- This procedure will validate the status of project request for project creation.
-- Users are not allowed to create a project from a project request having system
-- Status of 'PROJ_REQ_CLOSED' OR 'PROJ_REQ_CANCELED'.
--
-- Input parameters
-- Parameters                   Type
-- p_request_sys_status         pa_project_statuses.project_system_status_code%TYPE
--

PROCEDURE create_project_validation
	       (p_request_sys_status IN pa_project_statuses.project_system_status_code%TYPE,
		      x_return_status      OUT    	NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
		      x_msg_count          OUT    	NOCOPY NUMBER,  --File.Sql.39 bug 4440895
		      x_msg_data           OUT    	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
-- Procedure     : get_object_info
-- Purpose       : Get all the attributes of an object.
--
--
PROCEDURE get_object_info
(       p_object_type                IN VARCHAR2    ,
	      p_object_id1                 IN VARCHAR2    ,
        p_object_id2                 IN VARCHAR2    ,
				p_object_id3                 IN VARCHAR2    ,
				p_object_id4                 IN VARCHAR2    ,
				p_object_id5                 IN VARCHAR2    ,
			  x_object_name                OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_object_number              OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_object_type_name           OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
        x_object_subtype             OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_status_name                OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_description                OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : populate_associations_temp
-- Purpose       : Insert data into PA_PROJ_REQ_ASSOCIATIONS_TEMP that is used to display
--                 the associations on the Relationships page.
--
--
PROCEDURE populate_associations_temp
(       p_object_type_from                 IN VARCHAR2,
        p_object_id_from1                  IN VARCHAR2,
				p_object_id_from2                  IN VARCHAR2,
        p_object_id_from3                  IN VARCHAR2,
        p_object_id_from4                  IN VARCHAR2,
        p_object_id_from5                  IN VARCHAR2,
        x_return_status              OUT  NOCOPY VARCHAR2            , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER              , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE debug(p_msg IN VARCHAR2);

PROCEDURE close_project_request
	 (p_request_id       	 IN     	pa_project_requests.request_id%TYPE,
		x_return_status      OUT    	NOCOPY VARCHAR2,   --File.Sql.39 bug 4440895
		x_msg_count          OUT    	NOCOPY NUMBER,   --File.Sql.39 bug 4440895
		x_msg_data           OUT    	NOCOPY VARCHAR2);   --File.Sql.39 bug 4440895

--Procedure: get_quick_entry_defaults
--Purpose:   Defaults the quick entry, when create a project from a selected request.
--Note: In parameter template_id is not used currently

PROCEDURE get_quick_entry_defaults (
                p_request_id      		IN      NUMBER,
                p_template_id     		IN      NUMBER,
                x_field_names   		  OUT 	  NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE,  --File.Sql.39 bug 4440895
                x_field_values 		    OUT 	  NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,  --File.Sql.39 bug 4440895
                x_field_types 		    OUT 	  NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE,  --File.Sql.39 bug 4440895
                x_return_status  		  OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                x_msg_count      		  OUT     NOCOPY NUMBER,  --File.Sql.39 bug 4440895
                x_msg_data       		  OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Procedure: manage_project_requests
--Purpose:   This procedure is called by concurrent program. It calls
--Procedure create_project_requests and update_projects.

PROCEDURE manage_project_requests
          (p_run_mode                      IN     VARCHAR2,
           p_source_application_id         IN     NUMBER,
           p_request_type         	       IN     VARCHAR2,
           p_probability_from     	       IN     NUMBER,
           p_probability_to       	       IN     NUMBER,
	         p_closed_date_within_days       IN 	  NUMBER,
	         p_status		     	  	           IN     VARCHAR2,
	         p_sales_stage_id        	       IN 	  NUMBER,
	         p_value_from		  	             IN	    NUMBER,
	         p_value_to  		  	             IN     NUMBER,
	         p_currency_code        	       IN 	  VARCHAR2,
	         p_classification 	  	         IN     VARCHAR2,
              p_calling_module 	  	         IN     VARCHAR2,  -- added 3632760
           p_update_probability       	   IN     VARCHAR2,
	         p_update_value             	   IN     VARCHAR2,
           p_update_exp_appr_date  	       IN     VARCHAR2,
           x_return_status        	       OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
           x_msg_count            	       OUT    NOCOPY NUMBER,  --File.Sql.39 bug 4440895
           x_msg_data                      OUT    NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

--Procedure: create_project_requests
--Purpose:   This procedure is called by manage_project_requests.
--           It creats the project requests for the user specified
--           opportunities

PROCEDURE create_project_requests
	    (p_source_application_id   	    IN     NUMBER,
       p_request_type         	      IN     VARCHAR2,
       p_probability_from     	      IN     NUMBER,
	     p_probability_to       	      IN     NUMBER,
	     p_closed_date_within_days      IN 	   NUMBER,
	     p_status		     	  	          IN     VARCHAR2,
	     p_sales_stage_id       	      IN 	   NUMBER,
	     p_value_from		  	            IN	   NUMBER,
	     p_value_to  		  	            IN	   NUMBER,
	     p_currency_code        	      IN 	   VARCHAR2,
	     p_classification 	  	        IN     VARCHAR2,
          p_is_profile_defined             IN       VARCHAR2,   -- added 3632760
       x_return_status           	    OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
       x_msg_count            	      OUT    NOCOPY NUMBER,  --File.Sql.39 bug 4440895
       x_msg_data             	      OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--Procedure: update_projects
--Purpose:   This procedure is called by manage_project_requests.
--           It updates the opportunity related project specified
--           by users.

PROCEDURE update_projects
	    (p_source_application_id         IN     NUMBER,
          p_request_type         	       IN     VARCHAR2,
          p_probability_from     	       IN     NUMBER,
          p_probability_to       	       IN     NUMBER,
          p_closed_date_within_days       IN     NUMBER,
          p_status		     	  	  IN     VARCHAR2,
          p_sales_stage_id       	       IN     NUMBER,
          p_value_from		  	       IN	    NUMBER,
          p_value_to  		  	       IN     NUMBER,
          p_currency_code        	       IN     VARCHAR2,
          p_classification 	  	       IN     VARCHAR2,
          p_is_profile_defined            IN     VARCHAR2,  -- added 3632760
          p_update_probability            IN     VARCHAR2,
          p_update_value             	  IN     VARCHAR2,
          p_update_exp_appr_date  	       IN     VARCHAR2,
          x_return_status        	       OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
          x_msg_count            	       OUT    NOCOPY NUMBER,  --File.Sql.39 bug 4440895
          x_msg_data                      OUT    NOCOPY VARCHAR2);   --File.Sql.39 bug 4440895

--Procedure: post_create_project
--Purpose:   This procedure is to build the two ways relationship
--           between the project request and the project created.
--           And close the project request after the project is created.


PROCEDURE post_create_project
	  (p_request_id        	IN     	pa_project_requests.request_id%TYPE,
     p_project_id         IN      pa_projects_all.project_id%TYPE,
	   x_return_status      OUT    	NOCOPY VARCHAR2,    --File.Sql.39 bug 4440895
	   x_msg_count          OUT    	NOCOPY NUMBER,    --File.Sql.39 bug 4440895
	   x_msg_data           OUT    	NOCOPY VARCHAR2);    --File.Sql.39 bug 4440895

PROCEDURE Req_Name_Duplicate
    (p_request_name       IN      VARCHAR2,
     x_return_status      OUT    	NOCOPY VARCHAR2,    --File.Sql.39 bug 4440895
	   x_msg_count          OUT    	NOCOPY NUMBER,    --File.Sql.39 bug 4440895
	   x_msg_data           OUT    	NOCOPY VARCHAR2);    --File.Sql.39 bug 4440895

G_ORG_ID     pa_projects_all.org_id%type ;  -- Added for bug#3807805

END PA_PROJECT_REQUEST_PVT;

 

/
