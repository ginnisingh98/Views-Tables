--------------------------------------------------------
--  DDL for Package Body PA_ADW_CUSTOM_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADW_CUSTOM_COLLECT" AS
/* $Header: PAADWCCB.pls 115.1 99/07/16 13:21:26 porting ship $ */

   FUNCTION Initialize RETURN NUMBER IS
   BEGIN
        NULL;
   END Initialize;

   -- Procedure to collect custom dimension tables

   PROCEDURE get_dimension_tables
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER,
                          x_calling_process      IN     VARCHAR2)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Custom Dimension Tables';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dimension_tables';

     pa_debug.debug(x_err_stage);


     -- Insert procedure calls to collect all custom dimensions

     x_err_stack := x_old_err_stack;
     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_dimension_tables;

   -- Procedure to collect custom fact tables

   PROCEDURE get_fact_tables
                         (x_project_num_from     IN     VARCHAR2,
                          x_project_num_to       IN     VARCHAR2,
                          x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER,
                          x_calling_process      IN     VARCHAR2)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Custom Fact Tables';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_fact_tables';

     pa_debug.debug(x_err_stage);

     -- Insert procedure calls to collect all custom fact tables

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_fact_tables;

END PA_ADW_CUSTOM_COLLECT;

/
