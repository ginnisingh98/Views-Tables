--------------------------------------------------------
--  DDL for Package Body PA_MULTI_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MULTI_ORG" AS
/* $Header: PAMORGB.pls 115.1 99/07/16 15:08:11 porting ship  $ */

  PROCEDURE copy_seed_data ( x_rec_count  OUT NUMBER
                           , x_err_text   OUT VARCHAR2 )
  IS
    x_org_id     NUMBER(15);
    x_user       NUMBER(15) := 1;
    x_login      NUMBER(15) := 0;
    l_rec_count  NUMBER := 0;
    x_stage      VARCHAR2(100);

  BEGIN
    -- Get operating unit ORG_ID
    x_stage := 'SELECT ORG_ID FROM PA_IMPLEMENTATIONS';
    SELECT  org_id
      INTO  x_org_id
      FROM  pa_implementations;

    -- Copy Function Transactions
    x_stage := 'INSERT INTO PA_FUNCTION_TRANSACTIONS';
    INSERT INTO pa_function_transactions(
       application_id
    ,  function_code
    ,  function_transaction_code
    ,  function_transaction_name
    ,  last_update_date
    ,  last_updated_by
    ,  creation_date
    ,  created_by
    ,  last_update_login
    ,  enabled_flag
    ,  description
    ,  org_id )
    SELECT
     	    ft.application_id
    ,       ft.function_code
    ,       ft.function_transaction_code
    ,       ft.function_transaction_name
    ,       sysdate
    ,       x_user
    ,       sysdate
    ,       x_user
    ,       x_login
    ,       ft.enabled_flag
    ,       ft.description
    ,       x_org_id
      FROM  pa_function_transactions_all ft
     WHERE  org_id = -3113
    AND NOT EXISTS (
       SELECT NULL
         FROM pa_function_transactions
        WHERE org_id = x_org_id
          AND application_id = ft.application_id
          AND function_code = ft.function_code
          AND function_transaction_code = ft.function_transaction_code );

    l_rec_count := l_rec_count + SQL%ROWCOUNT;

    -- Copy Billing Assignments
    x_stage := 'INSERT INTO PA_BILLING_ASSIGNMENTS';
    INSERT INTO pa_billing_assignments(
       billing_assignment_id
    ,  billing_extension_id
    ,  project_type
    ,  project_id
    ,  top_task_id
    ,  amount
    ,  percentage
    ,  active_flag
    ,  last_update_date
    ,  last_updated_by
    ,  creation_date
    ,  created_by
    ,  last_update_login
    ,  distribution_rule
    ,  org_id )
    SELECT
            pa_billing_assignments_s.NEXTVAL
    ,       ba.billing_extension_id
    ,       ba.project_type
    ,       ba.project_id
    ,       ba.top_task_id
    ,       ba.amount
    ,       ba.percentage
    ,       ba.active_flag
    ,       sysdate
    ,       x_user
    ,       sysdate
    ,       x_user
    ,       x_login
    ,       ba.distribution_rule
    ,       x_org_id
      FROM  pa_billing_assignments_all ba
     WHERE  org_id = -3113
    AND NOT EXISTS (
       SELECT NULL
         FROM pa_billing_assignments
        WHERE org_id = x_org_id
          AND distribution_rule = ba.distribution_rule
          AND billing_extension_id = ba.billing_extension_id
          AND project_type = ba.project_type
          AND project_id = ba.project_id
          AND top_task_id = ba.top_task_id );

    l_rec_count := l_rec_count + SQL%ROWCOUNT;

    IF ( l_rec_count > 0 ) THEN
      COMMIT;
    END IF;

    x_rec_count := l_rec_count;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      x_rec_count := -1403;
      x_err_text :=  x_stage || ' - ' || SQLERRM(-1403);
    WHEN  OTHERS  THEN
      x_rec_count := SQLCODE;
      x_err_text :=  x_stage || ' - ' || SQLERRM(SQLCODE);

  END copy_seed_data;

END pa_multi_org;

/
