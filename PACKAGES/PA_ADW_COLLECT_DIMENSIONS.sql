--------------------------------------------------------
--  DDL for Package PA_ADW_COLLECT_DIMENSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADW_COLLECT_DIMENSIONS" AUTHID CURRENT_USER AS
/* $Header: PAADWCDS.pls 115.0 99/07/16 13:21:41 porting ship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;


   FUNCTION Initialize RETURN NUMBER;

   PROCEDURE get_dim_status
			( x_dimension_code       IN     VARCHAR2,
			  x_dimension_status     IN OUT VARCHAR2,
			  x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_tasks
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_projects
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_project_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_expenditure_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_project_classes
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_class_categories
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_class_codes
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_resources
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_resource_lists
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_budget_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_periods
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_service_types
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_organizations
			( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

END PA_ADW_COLLECT_DIMENSIONS;

 

/
