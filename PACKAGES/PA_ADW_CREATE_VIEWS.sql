--------------------------------------------------------
--  DDL for Package PA_ADW_CREATE_VIEWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADW_CREATE_VIEWS" AUTHID CURRENT_USER AS
/* $Header: PAADWVWS.pls 115.0 99/07/16 13:22:38 porting ship $ */

   -- Standard who
   x_last_updated_by             NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date            NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by                  NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login           NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id                  NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id      NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id                  NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   -- Variable to store the dimension statuses

   dim_project			 VARCHAR2(1);
   dim_resource			 VARCHAR2(1);
   dim_project_org		 VARCHAR2(1);
   dim_exp_org  		 VARCHAR2(1);
   dim_srvc_type		 VARCHAR2(1);
   dim_time			 VARCHAR2(1);
   dim_bgt_type			 VARCHAR2(1);
   dim_exp_type 		 VARCHAR2(1);
   dim_operating_unit		 VARCHAR2(1);

   -- PL/SQL array and its index for storing View Definition

   view_act_cmt			 dbms_sql.varchar2s;
   view_ref_act_cmt		 dbms_sql.varchar2s;
   view_ref_ser_type_act_cmt	 dbms_sql.varchar2s;
   view_budget_lines		 dbms_sql.varchar2s;
   view_ref_budget_lines	 dbms_sql.varchar2s;

   view_idx_act_cmt		 BINARY_INTEGER;
   view_idx_ref_act_cmt		 BINARY_INTEGER;
   view_idx_ref_ser_type_act_cmt BINARY_INTEGER;
   view_idx_budget_lines	 BINARY_INTEGER;
   view_idx_ref_budget_lines	 BINARY_INTEGER;

   -- Values for unused dimensions
   -- These values will replace actual values, for unused dimensions

   disabled_dim_value_number 	 NUMBER := -1;
   disabled_dim_value_char   	 VARCHAR2(20) := '''Unknown''';

   FUNCTION Initialize RETURN NUMBER;

   PROCEDURE get_dimension_status
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE generate_collection_views
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE create_collection_views
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE output_collection_views
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

END PA_ADW_CREATE_VIEWS;

 

/
