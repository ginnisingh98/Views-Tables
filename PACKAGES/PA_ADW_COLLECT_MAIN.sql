--------------------------------------------------------
--  DDL for Package PA_ADW_COLLECT_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADW_COLLECT_MAIN" AUTHID CURRENT_USER AS
/* $Header: PAADWCMS.pls 115.2 99/07/16 13:22:06 porting shi $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   -- Variable to store the dimension statuses

   dim_project		VARCHAR2(1);
   dim_resource		VARCHAR2(1);
   dim_project_org	VARCHAR2(1);
   dim_exp_org	        VARCHAR2(1);
   dim_srvc_type	VARCHAR2(1);
   dim_time		VARCHAR2(1);
   dim_bgt_type		VARCHAR2(1);
   dim_exp_type	        VARCHAR2(1);
   dim_operating_unit	VARCHAR2(1);

   -- profile option for collecting top level tasks

   collect_top_tasks_flag     VARCHAR2(1);
   collect_lowest_tasks_flag  VARCHAR2(1);
   license_status	      VARCHAR2(1);
   install_status	      VARCHAR2(1);

   FUNCTION Initialize RETURN NUMBER;

   PROCEDURE prepare_src_table_for_refresh
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE purge_interface_tables
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE purge_interface_tables_OADW
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE purge_it_OADW
                        ( x_table_name           IN VARCHAR2,
                          x_wh_update_date       IN DATE);

   PROCEDURE clear_interface_tables
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dimension_status
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE get_dim_and_fact_main
                        ( x_collect_dim_tables   IN     VARCHAR2,
                          x_dimension_table      IN     VARCHAR2,
                          x_collect_fact_tables  IN     VARCHAR2,
                          x_fact_table           IN     VARCHAR2,
                          x_project_num_from     IN     VARCHAR2,
                          x_project_num_to       IN     VARCHAR2,
                          x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

   PROCEDURE ref_dim_and_fact_main
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER);

END PA_ADW_COLLECT_MAIN;

 

/
