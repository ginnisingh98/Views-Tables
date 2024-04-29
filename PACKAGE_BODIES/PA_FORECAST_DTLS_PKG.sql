--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_DTLS_PKG" as
--/* $Header: PARFFIDB.pls 120.1 2005/08/19 16:51:13 mwasowic noship $ */

  l_empty_tab_record  EXCEPTION;  --  Variable to raise the exception if  the passing table of records is empty

-- This procedure will insert the record in pa_forecast_items  table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Forecast_Dtls_Tab   FIDtlTabTyp      YES       It contains the forecast items record for details
--

PROCEDURE insert_rows ( p_forecast_dtls_tab                   IN  PA_FORECAST_GLOB.FIDtlTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

 l_forecast_item_id                 PA_PLSQL_DATATYPES.IdTabTyp;
 l_amount_type_id                   PA_PLSQL_DATATYPES.IdTabTyp;
 l_line_num                         PA_PLSQL_DATATYPES.NumTabTyp;
 l_resource_type_code               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_person_billable_flag             PA_PLSQL_DATATYPES.Char1TabTyp;
 l_item_date                        PA_PLSQL_DATATYPES.DateTabTyp;
 l_item_uom                         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_item_quantity                    PA_PLSQL_DATATYPES.NumTabTyp;
 l_expenditure_org_id               PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_org_id                   PA_PLSQL_DATATYPES.IdTabTyp;
 l_PJI_SUMMARIZED_FLAG              PA_PLSQL_DATATYPES.Char1TabTyp;
 l_CAPACITY_QUANTITY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVERCOMMITMENT_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVERPROVISIONAL_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVER_PROV_CONF_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_CONFIRMED_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROVISIONAL_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_JOB_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROJECT_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_RESOURCE_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_EXPENDITURE_ORGANIZATION_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_pvdr_acct_curr_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_pvdr_acct_amount                 PA_PLSQL_DATATYPES.NumTabTyp;
 l_rcvr_acct_curr_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_acct_amount                 PA_PLSQL_DATATYPES.NumTabTyp;
 l_proj_currency_code               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_proj_amount                      PA_PLSQL_DATATYPES.NumTabTyp;
 l_denom_currency_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_denom_amount                     PA_PLSQL_DATATYPES.NumTabTyp;
 l_tp_amount_type                   PA_PLSQL_DATATYPES.Char30TabTyp;
 l_billable_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_forecast_summarized_code         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_util_summarized_code             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_work_type_id                     PA_PLSQL_DATATYPES.IdTabTyp;
 l_resource_util_category_id        PA_PLSQL_DATATYPES.IdTabTyp;
 l_org_util_category_id             PA_PLSQL_DATATYPES.IdTabTyp;
 l_resource_util_weighted           PA_PLSQL_DATATYPES.NumTabTyp;
 l_org_util_weighted                PA_PLSQL_DATATYPES.NumTabTyp;
 l_provisional_flag                 PA_PLSQL_DATATYPES.Char1TabTyp;
 l_reversed_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_net_zero_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_reduce_capacity_flag             PA_PLSQL_DATATYPES.Char1TabTyp;
 l_line_num_reversed                PA_PLSQL_DATATYPES.NumTabTyp;


BEGIN
PA_DEBUG.Init_err_stack( 'PA_FORECAST_DTLS_PKG.Insert_Rows');
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Checking for the empty table of record */
  IF (p_forecast_dtls_tab.count = 0 ) THEN
    PA_FORECAST_ITEMS_UTILS.log_message('count 0 ... before return ... ');
    RAISE l_empty_tab_record;
  END IF;

  PA_FORECAST_ITEMS_UTILS.log_message('start of the forecast inser row .... ');

FOR l_J IN p_forecast_dtls_tab.FIRST..p_forecast_dtls_tab.LAST LOOP
        l_forecast_item_id(l_j)                 := p_forecast_dtls_tab(l_j).forecast_item_id;
        l_amount_type_id(l_j)                   := p_forecast_dtls_tab(l_j).amount_type_id;
        l_line_num(l_j)                         := p_forecast_dtls_tab(l_j).line_num;
        l_resource_type_code(l_j)               := p_forecast_dtls_tab(l_j).resource_type_code;
        l_person_billable_flag(l_j)             := p_forecast_dtls_tab(l_j).person_billable_flag;
        l_item_uom(l_j)                         := p_forecast_dtls_tab(l_j).item_uom;
        l_item_date(l_j)                        := p_forecast_dtls_tab(l_j).item_date;
        l_item_quantity(l_j)                    := p_forecast_dtls_tab(l_j).item_quantity;
        l_expenditure_org_id(l_j)               := p_forecast_dtls_tab(l_j).expenditure_org_id;
        l_project_org_id(l_j)                   := p_forecast_dtls_tab(l_j).project_org_id;
        l_PJI_SUMMARIZED_FLAG(l_j)              := p_forecast_dtls_tab(l_j).PJI_SUMMARIZED_FLAG;
        l_CAPACITY_QUANTITY(l_j)              := p_forecast_dtls_tab(l_j).CAPACITY_QUANTITY;
        l_OVERCOMMITMENT_QTY(l_j)              := p_forecast_dtls_tab(l_j).OVERCOMMITMENT_QTY;
        l_OVERPROVISIONAL_QTY(l_j)              := p_forecast_dtls_tab(l_j).OVERPROVISIONAL_QTY;
        l_OVER_PROV_CONF_QTY(l_j)              := p_forecast_dtls_tab(l_j).OVER_PROV_CONF_QTY;
        l_CONFIRMED_QTY(l_j)              := p_forecast_dtls_tab(l_j).CONFIRMED_QTY;
        l_PROVISIONAL_QTY(l_j)              := p_forecast_dtls_tab(l_j).PROVISIONAL_QTY;
        l_JOB_ID(l_j)              := p_forecast_dtls_tab(l_j).JOB_ID;
        l_PROJECT_ID(l_j)              := p_forecast_dtls_tab(l_j).PROJECT_ID;
        l_RESOURCE_ID(l_j)              := p_forecast_dtls_tab(l_j).RESOURCE_ID;
        l_EXPENDITURE_ORGANIZATION_ID(l_j)              := p_forecast_dtls_tab(l_j).EXPENDITURE_ORGANIZATION_ID;
        l_pvdr_acct_curr_code(l_j)              := p_forecast_dtls_tab(l_j).pvdr_acct_curr_code;
        l_pvdr_acct_amount(l_j)                 := p_forecast_dtls_tab(l_j).pvdr_acct_amount;
        l_rcvr_acct_curr_code(l_j)              := p_forecast_dtls_tab(l_j).rcvr_acct_curr_code;
        l_rcvr_acct_amount(l_j)                 := p_forecast_dtls_tab(l_j).rcvr_acct_amount;
        l_proj_currency_code(l_j)               := p_forecast_dtls_tab(l_j).proj_currency_code;
        l_proj_amount(l_j)                      := p_forecast_dtls_tab(l_j).proj_amount;
        l_denom_currency_code(l_j)              := p_forecast_dtls_tab(l_j).denom_currency_code;
        l_denom_amount(l_j)                     := p_forecast_dtls_tab(l_j).denom_amount;
        l_tp_amount_type(l_j)                   := p_forecast_dtls_tab(l_j).tp_amount_type;
        l_billable_flag(l_j)                    := p_forecast_dtls_tab(l_j).billable_flag;
        l_forecast_summarized_code(l_j)         := p_forecast_dtls_tab(l_j).forecast_summarized_code;
        l_util_summarized_code(l_j)             := p_forecast_dtls_tab(l_j).util_summarized_code;
        l_work_type_id(l_j)                     := p_forecast_dtls_tab(l_j).work_type_id;
        l_resource_util_category_id(l_j)        := p_forecast_dtls_tab(l_j).resource_util_category_id;
        l_org_util_category_id(l_j)             := p_forecast_dtls_tab(l_j).org_util_category_id;
        l_resource_util_weighted(l_j)           := p_forecast_dtls_tab(l_j).resource_util_weighted;
        l_org_util_weighted(l_j)                := p_forecast_dtls_tab(l_j).org_util_weighted;
        l_provisional_flag(l_j)                 := p_forecast_dtls_tab(l_j).provisional_flag;
        l_reversed_flag(l_j)                    := p_forecast_dtls_tab(l_j).reversed_flag;
        l_net_zero_flag(l_j)                    := p_forecast_dtls_tab(l_j).net_zero_flag;
        l_reduce_capacity_flag(l_j)             := p_forecast_dtls_tab(l_j).reduce_capacity_flag;
        l_line_num_reversed(l_j)                := p_forecast_dtls_tab(l_j).line_num_reversed;

END LOOP;

FORALL l_J IN p_forecast_dtls_tab.FIRST..p_forecast_dtls_tab.LAST
 INSERT INTO PA_FORECAST_ITEM_DETAILS
      (
        forecast_item_id                    ,
        amount_type_id                      ,
        line_num                            ,
        resource_type_code                  ,
        person_billable_flag                ,
        item_uom                            ,
        item_date                           ,
        item_quantity                       ,
        expenditure_org_id                  ,
        project_org_id                      ,
        PJI_SUMMARIZED_FLAG                 ,
        CAPACITY_QUANTITY                 ,
        OVERCOMMITMENT_QTY                 ,
        OVERPROVISIONAL_QTY                 ,
        OVER_PROV_CONF_QTY                 ,
        CONFIRMED_QTY                 ,
        PROVISIONAL_QTY                 ,
        JOB_ID                 ,
        PROJECT_ID                 ,
        RESOURCE_ID                 ,
        EXPENDITURE_ORGANIZATION_ID                 ,
        pvdr_acct_curr_code                 ,
        pvdr_acct_amount                    ,
        rcvr_acct_curr_code                 ,
        rcvr_acct_amount                    ,
        proj_currency_code                  ,
        proj_amount                         ,
        denom_currency_code                 ,
        denom_amount                        ,
        tp_amount_type                      ,
        billable_flag                       ,
        forecast_summarized_code            ,
        util_summarized_code                ,
        work_type_id                        ,
        resource_util_category_id           ,
        org_util_category_id                ,
        resource_util_weighted              ,
        org_util_weighted                   ,
        provisional_flag                    ,
        reversed_flag                       ,
        net_zero_flag                       ,
        reduce_capacity_flag                ,
        line_num_reversed                   ,
        creation_date                       ,
        created_by                          ,
        last_update_date                    ,
        last_updated_by                     ,
        last_update_login                   ,
        request_id                          ,
        program_application_id              ,
        program_id                          ,
        program_update_date              )
-- Start Bug 2592045: Need to select expenditure_organization_id from pa_forecast_items table
select
-- End Bug 2592045
        l_forecast_item_id(l_j)                 ,
        l_amount_type_id(l_j)                   ,
        l_line_num(l_j)                         ,
        l_resource_type_code(l_j)               ,
        l_person_billable_flag(l_j)             ,
        l_item_uom(l_j)                         ,
        l_item_date(l_j)                        ,
        l_item_quantity(l_j)                    ,
        l_expenditure_org_id(l_j)               ,
        l_project_org_id(l_j)                   ,
        l_PJI_SUMMARIZED_FLAG(l_j)        ,
        l_CAPACITY_QUANTITY(l_j)        ,
        l_OVERCOMMITMENT_QTY(l_j)        ,
        l_OVERPROVISIONAL_QTY(l_j)        ,
        l_OVER_PROV_CONF_QTY(l_j)        ,
        l_CONFIRMED_QTY(l_j)        ,
        l_PROVISIONAL_QTY(l_j)        ,
        l_JOB_ID(l_j)        ,
        l_PROJECT_ID(l_j)        ,
        l_RESOURCE_ID(l_j)        ,
-- Start Bug 2592045: Need to select expenditure_organization_id from pa_forecast_items table
        expenditure_organization_id,
        --l_EXPENDITURE_ORGANIZATION_ID(l_j)        ,
 -- End Bug 2592045
        l_pvdr_acct_curr_code(l_j)              ,
        l_pvdr_acct_amount(l_j)                 ,
        l_rcvr_acct_curr_code(l_j)              ,
        l_rcvr_acct_amount(l_j)                 ,
        l_proj_currency_code(l_j)               ,
        l_proj_amount(l_j)                      ,
        l_denom_currency_code(l_j)              ,
        l_denom_amount(l_j)                     ,
        l_tp_amount_type(l_j)                   ,
        l_billable_flag(l_j)                    ,
        l_forecast_summarized_code(l_j)         ,
        l_util_summarized_code(l_j)             ,
        l_work_type_id(l_j)                     ,
        l_resource_util_category_id(l_j)        ,
        l_org_util_category_id(l_j)             ,
        l_resource_util_weighted(l_j)           ,
        l_org_util_weighted(l_j)                ,
        l_provisional_flag(l_j)                 ,
        l_reversed_flag(l_j)                    ,
        l_net_zero_flag(l_j)                    ,
        l_reduce_capacity_flag(l_j)             ,
        l_line_num_reversed(l_j)                ,
        sysdate                                 ,
        fnd_global.user_id                      ,
        sysdate                                 ,
        fnd_global.user_id                      ,
        fnd_global.login_id                     ,
        fnd_global.conc_request_id()            ,
        fnd_global.prog_appl_id   ()            ,
        fnd_global.conc_program_id()            ,
        trunc(sysdate)
-- Start Bug 2592045: Finish select statement.
    from pa_forecast_items fi
    where fi.forecast_item_id = l_forecast_item_id(l_j);
-- End Bug 2592045

PA_FORECAST_ITEMS_UTILS.log_message('start of the forecast inser row .... ');
PA_DEBUG.Reset_Err_Stack;
EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_msg_count := 1;
  x_msg_data  := SQLERRM;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg
       (p_pkg_name   => 'PA_FORECAST_DTLS_PKG.Insert_Rows',
        p_procedure_name => PA_DEBUG.G_Err_Stack);

  RAISE;

 PA_FORECAST_ITEMS_UTILS.log_message('ERROR ....'||sqlerrm);
END insert_rows;

-- This procedure will update  the record in pa_forecast_items table
-- Input parameters
-- Parameters                Type                Required  Description
-- P_Forecast_Dtls_Tab       FIHDRTABTYP         YES       It contains the forecast items record for details
--
PROCEDURE update_rows ( p_forecast_dtls_tab                   IN  PA_FORECAST_GLOB.FIDtlTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
 l_forecast_item_id                 PA_PLSQL_DATATYPES.IdTabTyp;
 l_amount_type_id                   PA_PLSQL_DATATYPES.IdTabTyp;
 l_line_num                         PA_PLSQL_DATATYPES.NumTabTyp;
 l_resource_type_code               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_person_billable_flag             PA_PLSQL_DATATYPES.Char1TabTyp;
 l_item_uom                         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_item_date                        PA_PLSQL_DATATYPES.DateTabTyp;
 l_item_quantity                    PA_PLSQL_DATATYPES.NumTabTyp;
 l_expenditure_org_id               PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_org_id                   PA_PLSQL_DATATYPES.IdTabTyp;
 l_PJI_SUMMARIZED_FLAG              PA_PLSQL_DATATYPES.Char1TabTyp;
 l_CAPACITY_QUANTITY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVERCOMMITMENT_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVERPROVISIONAL_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVER_PROV_CONF_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_CONFIRMED_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROVISIONAL_QTY              PA_PLSQL_DATATYPES.NumTabTyp;
 l_JOB_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROJECT_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_RESOURCE_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_EXPENDITURE_ORGANIZATION_ID              PA_PLSQL_DATATYPES.NumTabTyp;
 l_pvdr_acct_curr_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_pvdr_acct_amount                 PA_PLSQL_DATATYPES.NumTabTyp;
 l_rcvr_acct_curr_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_acct_amount                 PA_PLSQL_DATATYPES.NumTabTyp;
 l_proj_currency_code               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_proj_amount                      PA_PLSQL_DATATYPES.NumTabTyp;
 l_denom_currency_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_denom_amount                     PA_PLSQL_DATATYPES.NumTabTyp;
 l_tp_amount_type                   PA_PLSQL_DATATYPES.Char30TabTyp;
 l_billable_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_forecast_summarized_code         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_util_summarized_code             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_work_type_id                     PA_PLSQL_DATATYPES.IdTabTyp;
 l_resource_util_category_id        PA_PLSQL_DATATYPES.IdTabTyp;
 l_org_util_category_id             PA_PLSQL_DATATYPES.IdTabTyp;
 l_resource_util_weighted           PA_PLSQL_DATATYPES.NumTabTyp;
 l_org_util_weighted                PA_PLSQL_DATATYPES.NumTabTyp;
 l_provisional_flag                 PA_PLSQL_DATATYPES.Char1TabTyp;
 l_reversed_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_net_zero_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_reduce_capacity_flag             PA_PLSQL_DATATYPES.Char1TabTyp;
 l_line_num_reversed                PA_PLSQL_DATATYPES.NumTabTyp;


BEGIN

PA_DEBUG.Init_err_stack( 'PA_FORECAST_DTLS_PKG.Update_Rows');
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Checking for the empty table of record */
  IF (p_forecast_dtls_tab.count = 0 ) THEN
    PA_FORECAST_ITEMS_UTILS.log_message('count 0 ... before return ... ');
    RAISE l_empty_tab_record;
  END IF;

  PA_FORECAST_ITEMS_UTILS.log_message('start of the forecast inser row .... ');

FOR l_j IN p_forecast_dtls_tab.FIRST..p_forecast_dtls_tab.LAST LOOP
        l_forecast_item_id(l_j)                 := p_forecast_dtls_tab(l_j).forecast_item_id;
        l_amount_type_id(l_j)                   := p_forecast_dtls_tab(l_j).amount_type_id;
        l_line_num(l_j)                         := p_forecast_dtls_tab(l_j).line_num;
        l_resource_type_code(l_j)               := p_forecast_dtls_tab(l_j).resource_type_code;
        l_person_billable_flag(l_j)             := p_forecast_dtls_tab(l_j).person_billable_flag;
        l_item_uom(l_j)                         := p_forecast_dtls_tab(l_j).item_uom;
        l_item_date(l_j)                        := p_forecast_dtls_tab(l_j).item_date;
        l_item_quantity(l_j)                    := p_forecast_dtls_tab(l_j).item_quantity;
        l_expenditure_org_id(l_j)               := p_forecast_dtls_tab(l_j).expenditure_org_id;
        l_project_org_id(l_j)                   := p_forecast_dtls_tab(l_j).project_org_id;
        l_PJI_SUMMARIZED_FLAG(l_j)              := p_forecast_dtls_tab(l_j).PJI_SUMMARIZED_FLAG;
        l_CAPACITY_QUANTITY(l_j)              := p_forecast_dtls_tab(l_j).CAPACITY_QUANTITY;
        l_OVERCOMMITMENT_QTY(l_j)              := p_forecast_dtls_tab(l_j).OVERCOMMITMENT_QTY;
        l_OVERPROVISIONAL_QTY(l_j)              := p_forecast_dtls_tab(l_j).OVERPROVISIONAL_QTY;
        l_OVER_PROV_CONF_QTY(l_j)              := p_forecast_dtls_tab(l_j).OVER_PROV_CONF_QTY;
        l_CONFIRMED_QTY(l_j)              := p_forecast_dtls_tab(l_j).CONFIRMED_QTY;
        l_PROVISIONAL_QTY(l_j)              := p_forecast_dtls_tab(l_j).PROVISIONAL_QTY;
        l_JOB_ID(l_j)              := p_forecast_dtls_tab(l_j).JOB_ID;
        l_PROJECT_ID(l_j)              := p_forecast_dtls_tab(l_j).PROJECT_ID;
        l_RESOURCE_ID(l_j)              := p_forecast_dtls_tab(l_j).RESOURCE_ID;
        l_EXPENDITURE_ORGANIZATION_ID(l_j)              := p_forecast_dtls_tab(l_j).EXPENDITURE_ORGANIZATION_ID;
        l_pvdr_acct_curr_code(l_j)              := p_forecast_dtls_tab(l_j).pvdr_acct_curr_code;
        l_pvdr_acct_amount(l_j)                 := p_forecast_dtls_tab(l_j).pvdr_acct_amount;
        l_rcvr_acct_curr_code(l_j)              := p_forecast_dtls_tab(l_j).rcvr_acct_curr_code;
        l_rcvr_acct_amount(l_j)                 := p_forecast_dtls_tab(l_j).rcvr_acct_amount;
        l_proj_currency_code(l_j)               := p_forecast_dtls_tab(l_j).proj_currency_code;
        l_proj_amount(l_j)                      := p_forecast_dtls_tab(l_j).proj_amount;
        l_denom_currency_code(l_j)              := p_forecast_dtls_tab(l_j).denom_currency_code;
        l_denom_amount(l_j)                     := p_forecast_dtls_tab(l_j).denom_amount;
        l_tp_amount_type(l_j)                   := p_forecast_dtls_tab(l_j).tp_amount_type;
        l_billable_flag(l_j)                    := p_forecast_dtls_tab(l_j).billable_flag;
        l_forecast_summarized_code(l_j)         := p_forecast_dtls_tab(l_j).forecast_summarized_code;
        l_util_summarized_code(l_j)             := p_forecast_dtls_tab(l_j).util_summarized_code;
        l_work_type_id(l_j)                     := p_forecast_dtls_tab(l_j).work_type_id;
        l_resource_util_category_id(l_j)        := p_forecast_dtls_tab(l_j).resource_util_category_id;
        l_org_util_category_id(l_j)             := p_forecast_dtls_tab(l_j).org_util_category_id;
        l_resource_util_weighted(l_j)           := p_forecast_dtls_tab(l_j).resource_util_weighted;
        l_org_util_weighted(l_j)                := p_forecast_dtls_tab(l_j).org_util_weighted;
        l_provisional_flag(l_j)                 := p_forecast_dtls_tab(l_j).provisional_flag;
        l_reversed_flag(l_j)                    := p_forecast_dtls_tab(l_j).reversed_flag;
        l_net_zero_flag(l_j)                    := p_forecast_dtls_tab(l_j).net_zero_flag;
        l_reduce_capacity_flag(l_j)             := p_forecast_dtls_tab(l_j).reduce_capacity_flag;
        l_line_num_reversed(l_j)                := p_forecast_dtls_tab(l_j).line_num_reversed;

END LOOP;

FORALL l_J IN p_forecast_dtls_tab.FIRST..p_forecast_dtls_tab.LAST
 UPDATE PA_FORECAST_ITEM_DETAILS
 SET
        forecast_item_id                 = l_forecast_item_id(l_j)        ,
        amount_type_id                   = l_amount_type_id(l_j)          ,
        line_num                         = l_line_num(l_j)                ,
        resource_type_code               = l_resource_type_code(l_j)      ,
        person_billable_flag             = l_person_billable_flag(l_j)    ,
        item_uom                         = l_item_uom(l_j)                ,
        item_date                        = l_item_date(l_j)               ,
        item_quantity                    = l_item_quantity(l_j)           ,
        expenditure_org_id               = l_expenditure_org_id(l_j)      ,
        project_org_id                   = l_project_org_id(l_j)          ,
        PJI_SUMMARIZED_FLAG              = l_PJI_SUMMARIZED_FLAG(l_j)     ,
        CAPACITY_QUANTITY              = l_CAPACITY_QUANTITY(l_j)     ,
        OVERCOMMITMENT_QTY              = l_OVERCOMMITMENT_QTY(l_j)     ,
        OVERPROVISIONAL_QTY              = l_OVERPROVISIONAL_QTY(l_j)     ,
        OVER_PROV_CONF_QTY              = l_OVER_PROV_CONF_QTY(l_j)     ,
        CONFIRMED_QTY              = l_CONFIRMED_QTY(l_j)     ,
        PROVISIONAL_QTY              = l_PROVISIONAL_QTY(l_j)     ,
        JOB_ID              = l_JOB_ID(l_j)     ,
        PROJECT_ID              = l_PROJECT_ID(l_j)     ,
        RESOURCE_ID              = l_RESOURCE_ID(l_j)     ,
-- Start Bug 2592045
        --EXPENDITURE_ORGANIZATION_ID              = l_EXPENDITURE_ORGANIZATION_ID(l_j)     ,
        EXPENDITURE_ORGANIZATION_ID              =
           (select expenditure_organization_id from pa_forecast_items fi
            where fi.forecast_item_id = l_forecast_item_id(l_j)),
 -- End Bug 2592045
        pvdr_acct_curr_code              = l_pvdr_acct_curr_code(l_j)     ,
        pvdr_acct_amount                 = l_pvdr_acct_amount(l_j)        ,
        rcvr_acct_curr_code              = l_rcvr_acct_curr_code(l_j)     ,
        rcvr_acct_amount                 = l_rcvr_acct_amount(l_j)        ,
        proj_currency_code               = l_proj_currency_code(l_j)      ,
        proj_amount                      = l_proj_amount(l_j)             ,
        denom_currency_code              = l_denom_currency_code(l_j)     ,
        denom_amount                     = l_denom_amount(l_j)            ,
        tp_amount_type                   = l_tp_amount_type(l_j)          ,
        billable_flag                    = l_billable_flag(l_j)           ,
        forecast_summarized_code         = l_forecast_summarized_code(l_j),
        util_summarized_code             = l_util_summarized_code(l_j)    ,
        work_type_id                     = l_work_type_id(l_j)            ,
        resource_util_category_id        = l_resource_util_category_id(l_j),
        org_util_category_id             = l_org_util_category_id(l_j)     ,
        resource_util_weighted           = l_resource_util_weighted(l_j)   ,
        org_util_weighted                = l_org_util_weighted(l_j)        ,
        provisional_flag                 = l_provisional_flag(l_j)        ,
        reversed_flag                    = l_reversed_flag(l_j)           ,
        reduce_capacity_flag             = l_reduce_capacity_flag(l_j)    ,
        net_zero_flag                    = l_net_zero_flag(l_j)           ,
        line_num_reversed                = l_line_num_reversed(l_j)       ,
        last_update_date                 = sysdate 			,
        last_updated_by                  = fnd_global.user_id		,
        last_update_login                = fnd_global.login_id
 WHERE  forecast_item_id                 = l_forecast_item_id(l_j)
 AND    line_num                         = l_line_num(l_j);

 PA_FORECAST_ITEMS_UTILS.log_message('end of update row .... ');
PA_DEBUG.Reset_Err_Stack;
EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_msg_count := 1;
  x_msg_data  := SQLERRM;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg
       (p_pkg_name   => 'PA_FORECAST_DTLS_PKG.Update_Rows',
        p_procedure_name => PA_DEBUG.G_Err_Stack);
  RAISE;

 PA_FORECAST_ITEMS_UTILS.log_message('ERROR in update row '||sqlerrm);
END update_rows;

END PA_FORECAST_DTLS_PKG;

/
