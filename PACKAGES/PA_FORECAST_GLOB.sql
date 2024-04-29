--------------------------------------------------------
--  DDL for Package PA_FORECAST_GLOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_GLOB" AUTHID CURRENT_USER as
--/* $Header: PARFGLBS.pls 120.0 2005/05/30 01:17:28 appldev noship $ */

TYPE WeekDatesRangeRecordFc IS RECORD (
                               week_start_date              DATE,
                               week_end_date                DATE);

TYPE WeekDatesRangeFcTabTyp IS TABLE OF WeekDatesRangeRecordFc
        INDEX BY BINARY_INTEGER;

TYPE AsgnDtlRecord IS RECORD ( assignment_id                NUMBER,
                               assignment_type              VARCHAR2(30),
                               status_code                  VARCHAR2(30),
                               start_date                   DATE,
                               end_date                     DATE,
                               source_assignment_id         NUMBER,
                               project_id                   NUMBER,
                               resource_id                  NUMBER,
                               work_type_id                 NUMBER,
                               expenditure_org_id           NUMBER,
                               expenditure_organization_id  NUMBER,
                               expenditure_type             VARCHAR2(30),
                               expenditure_type_class       VARCHAR2(30),
                               fcst_tp_amount_type          VARCHAR2(30));

TYPE FIDayRecord IS RECORD  ( forecast_item_id       NUMBER,
                              item_date              DATE,
                              item_quantity          NUMBER,
                              status_code            VARCHAR2(30),
                              project_org_id         NUMBER,
                              expenditure_org_id     NUMBER,
                              project_id             NUMBER,
                              expenditure_organization_id NUMBER,
                              resource_id            NUMBER,
                              work_type_id           NUMBER,
                              person_billable_flag   VARCHAR2(1),
                              provisional_flag       VARCHAR2(1),
                              tp_amount_type         VARCHAR2(30),
                              include_in_forecast    VARCHAR2(1),
                              error_flag             VARCHAR2(1),
                              action_flag            VARCHAR2(3),
                              asgmt_sys_status_code           VARCHAR2(30),
                              asgmt_confirmed_quantity        NUMBER,
                              asgmt_provisional_quantity        NUMBER,
                              capacity_quantity               NUMBER,
                              overcommitment_quantity         NUMBER,
                              availability_quantity           NUMBER,
                              overcommitment_flag             VARCHAR2(1),
                              availability_flag               VARCHAR2(1),
                              OVERCOMMITMENT_QTY             NUMBER,
                              OVERPROVISIONAL_QTY             NUMBER,
                              OVER_PROV_CONF_QTY              NUMBER,
                              CONFIRMED_QTY                   NUMBER,
                              PROVISIONAL_QTY                 NUMBER,
                              JOB_ID                          NUMBER);



TYPE FIDayTabTyp IS TABLE OF FIDayRecord INDEX BY BINARY_INTEGER;

TYPE FIHdrRecord  IS RECORD  (forecast_item_id                NUMBER,
                              forecast_item_type              VARCHAR2(30),
                              project_org_id                  NUMBER,
                              expenditure_org_id              NUMBER,
                              expenditure_organization_id     NUMBER,
                              project_organization_id         NUMBER,
                              project_id                      NUMBER,
                              project_type_class              VARCHAR2(30),
                              person_id                       NUMBER,
                              resource_id                     NUMBER,
                              borrowed_flag                   VARCHAR2(1),
                              assignment_id                   NUMBER,
                              item_date                       DATE,
                              item_uom                        VARCHAR2(30),
                              item_quantity                   NUMBER,
                              pvdr_period_set_name            VARCHAR2(30),
                              pvdr_pa_period_name             VARCHAR2(30),
                              pvdr_gl_period_name             VARCHAR2(30),
                              rcvr_period_set_name            VARCHAR2(30),
                              rcvr_pa_period_name             VARCHAR2(30),
                              rcvr_gl_period_name             VARCHAR2(30),
                              global_exp_period_end_date      DATE,
                              expenditure_type                VARCHAR2(30),
                              expenditure_type_class          VARCHAR2(30),
                              cost_rejection_code             VARCHAR2(30),
                              rev_rejection_code              VARCHAR2(30),
                              tp_rejection_code               VARCHAR2(30),
                              burden_rejection_code           VARCHAR2(30),
                              other_rejection_code            VARCHAR2(30),
                              delete_flag                     VARCHAR2(1),
                              error_flag                      VARCHAR2(1),
                              provisional_flag                VARCHAR2(1),
                              asgmt_sys_status_code           VARCHAR2(30),
                              capacity_quantity               NUMBER,
                              overcommitment_quantity         NUMBER,
                              availability_quantity           NUMBER,
                              overcommitment_flag             VARCHAR2(1),
                              availability_flag               VARCHAR2(1),
                              creation_date                   DATE,
                              created_by                      NUMBER,
                              last_update_date                DATE,
                              last_updated_by                 NUMBER,
                              last_update_login               NUMBER,
                              request_id                      NUMBER,
                              program_application_id          NUMBER,
                              program_id                      NUMBER,
                              program_update_date             DATE,
                              OVERPROVISIONAL_QTY             NUMBER,
                              OVER_PROV_CONF_QTY              NUMBER,
                              CONFIRMED_QTY                   NUMBER,
                              PROVISIONAL_QTY                 NUMBER,
                              JOB_ID                          NUMBER,
                              TP_AMOUNT_TYPE                  VARCHAR2(30),
                              OVERCOMMITMENT_QTY              NUMBER
                              );

TYPE FIHdrTabTyp IS TABLE OF FIHdrRecord INDEX BY BINARY_INTEGER;

TYPE FIDtlRecord  IS RECORD  (forecast_item_id             NUMBER,
                              amount_type_id               NUMBER,
                              line_num                     NUMBER,
                              resource_type_code           VARCHAR2(30),
                              person_billable_flag         VARCHAR2(1),
                              item_date                    DATE,
                              item_uom                     VARCHAR2(30),
                              item_quantity                NUMBER,
                              expenditure_org_id           NUMBER,
                              project_org_id               NUMBER,
                              pvdr_acct_curr_code          VARCHAR2(15),
                              pvdr_acct_amount             NUMBER,
                              rcvr_acct_curr_code          VARCHAR2(15),
                              rcvr_acct_amount             NUMBER,
                              proj_currency_code           VARCHAR2(15),
                              proj_amount                  NUMBER,
                              denom_currency_code          VARCHAR2(15),
                              denom_amount                 NUMBER,
                              tp_amount_type               VARCHAR2(30),
                              billable_flag                VARCHAR2(1),
                              forecast_summarized_code     VARCHAR2(30),
                              util_summarized_code         VARCHAR2(30),
                              work_type_id                 NUMBER,
                              resource_util_category_id    NUMBER,
                              org_util_category_id         NUMBER,
                              resource_util_weighted       NUMBER,
                              org_util_weighted            NUMBER,
                              provisional_flag             VARCHAR2(1),
                              reversed_flag                VARCHAR2(1),
                              net_zero_flag                VARCHAR2(1),
                              reduce_capacity_flag         VARCHAR2(1),
                              line_num_reversed            NUMBER,
                              CAPACITY_QUANTITY            NUMBER,
                              OVERCOMMITMENT_QTY           NUMBER,
                              OVERPROVISIONAL_QTY          NUMBER,
                              OVER_PROV_CONF_QTY           NUMBER,
                              CONFIRMED_QTY                NUMBER,
                              PROVISIONAL_QTY              NUMBER,
                              JOB_ID                       NUMBER,
                              PROJECT_ID                   NUMBER,
                              RESOURCE_ID                  NUMBER,
                              EXPENDITURE_ORGANIZATION_ID  NUMBER,
                              PJI_SUMMARIZED_FLAG          VARCHAR2(1)
                            );


TYPE FIDtlTabTyp IS TABLE OF FIDtlRecord INDEX BY BINARY_INTEGER;

TYPE VC1TabTyp IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE VC15TabTyp IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
/*Commented the below code for the bug 3864340
TYPE VCTabTyp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;*/
/*Added the below for the bug 3864340*/
TYPE VCTabTyp IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE datetabtyp IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE PeriodNameTabTyp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE NumberTabTyp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE ScheduleRecord IS RECORD

                        (status_code            VARCHAR2(30),
                         start_date             DATE,
                         end_date               DATE,
                         monday_hours           NUMBER,
                         tuesday_hours          NUMBER,
                         wednesday_hours        NUMBER,
                         thursday_hours         NUMBER,
                         friday_hours           NUMBER,
                         saturday_hours         NUMBER,
                         sunday_hours           NUMBER,
                         forecast_txn_version_number  NUMBER,
                         forecast_txn_generated_flag    VARCHAR(1),
                         schedule_id            NUMBER,
                         system_status_code     VARCHAR2(30)) ;

TYPE ScheduleTabTyp IS TABLE OF ScheduleRecord INDEX BY BINARY_INTEGER;


END PA_FORECAST_GLOB;

 

/
