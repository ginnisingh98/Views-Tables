--------------------------------------------------------
--  DDL for Package PA_ADW_CUSTOM_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADW_CUSTOM_COLLECT" AUTHID CURRENT_USER AS
/* $Header: PAADWCCS.pls 115.1 99/07/16 13:21:31 porting ship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;


   FUNCTION Initialize RETURN NUMBER;

   PROCEDURE get_dimension_tables
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER,
                          x_calling_process      IN     VARCHAR2);

   PROCEDURE get_fact_tables
                         (x_project_num_from     IN     VARCHAR2,
                          x_project_num_to       IN     VARCHAR2,
                          x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER,
                          x_calling_process      IN     VARCHAR2);

END PA_ADW_CUSTOM_COLLECT;

 

/
