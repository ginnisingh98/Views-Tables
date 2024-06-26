--------------------------------------------------------
--  DDL for Package MSC_ATPUI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATPUI_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCATPUS.pls 120.1 2005/06/17 13:21:46 appldev  $ */

TYPE number_arr IS TABLE OF number;
TYPE char1_arr IS TABLE of varchar2(1);
TYPE char3_arr IS TABLE OF varchar2(3);
TYPE char7_arr IS TABLE OF varchar2(7);
TYPE char10_arr IS TABLE OF varchar2(10);
TYPE char15_arr IS TABLE of varchar2(15);
TYPE char20_arr  IS TABLE of varchar2(20);
TYPE char30_arr IS TABLE OF varchar2(30);
TYPE char40_arr IS TABLE OF varchar2(40);
TYPE char60_arr IS TABLE OF varchar2(60);
TYPE char80_arr IS TABLE of varchar2(80);
TYPE char255_arr IS TABLE of varchar2(255);
TYPE char2000_arr IS TABLE of varchar2(2000);
TYPE date_arr IS TABLE OF date;

--mrp_atp_schedule_temp table struct
TYPE ATP_SCHEDULE_TEMP_TYP is RECORD (
 ACTION                                   number_arr := number_arr(),
 CALLING_MODULE                           number_arr := number_arr(),
 SESSION_ID				  number_arr := number_arr(),
 ORDER_HEADER_ID                          number_arr := number_arr(),
 ORDER_LINE_ID                            number_arr := number_arr(),
 INVENTORY_ITEM_ID			  number_arr := number_arr(),
 ORGANIZATION_ID                          number_arr := number_arr(),
 SR_INSTANCE_ID                           number_arr := number_arr(),
 ORGANIZATION_CODE                        char7_arr := char7_arr(),
 ORDER_NUMBER				  number_arr := number_arr(),
 SOURCE_ORGANIZATION_ID                   number_arr := number_arr(),
 CUSTOMER_ID                              number_arr := number_arr(),
 CUSTOMER_SITE_ID                         number_arr := number_arr(),
 DESTINATION_TIME_ZONE                    char30_arr := char30_arr(),
 QUANTITY_ORDERED                         number_arr := number_arr(),
 UOM_CODE                                 char3_arr := char3_arr(),
 REQUESTED_SHIP_DATE                      date_arr := date_arr(),
 REQUESTED_ARRIVAL_DATE                   date_arr := date_arr(),
 LATEST_ACCEPTABLE_DATE                   date_arr := date_arr(),
 DELIVERY_LEAD_TIME                       number_arr := number_arr(),
 FREIGHT_CARRIER                          char30_arr := char30_arr(),
 SHIP_METHOD                              char30_arr := char30_arr(),
 DEMAND_CLASS                             char30_arr := char30_arr(),
 SHIP_SET_NAME                            char30_arr := char30_arr(),
 ARRIVAL_SET_NAME                         char30_arr := char30_arr(),
 OVERRIDE_FLAG                            char1_arr := char1_arr(),
 SCHEDULED_SHIP_DATE                      date_arr := date_arr(),
 SCHEDULED_ARRIVAL_DATE                   date_arr := date_arr(),
 AVAILABLE_QUANTITY                       number_arr := number_arr(),
 REQUESTED_DATE_QUANTITY                  number_arr := number_arr(),
 GROUP_SHIP_DATE                          date_arr := date_arr(),
 GROUP_ARRIVAL_DATE                       date_arr := date_arr(),
 VENDOR_ID                                number_arr := number_arr(),
 VENDOR_SITE_ID                           number_arr := number_arr(),
 INSERT_FLAG                              number_arr := number_arr(),
 ERROR_CODE                               char255_arr := char255_arr(),
 ERROR_MESSAGE                            char255_arr := char255_arr(),
 SEQUENCE_NUMBER                          number_arr := number_arr(),
 FIRM_FLAG                                number_arr := number_arr(),
 INVENTORY_ITEM_NAME                      char255_arr := char255_arr(),
 SOURCE_ORGANIZATION_CODE                 char7_arr := char7_arr(),
 INSTANCE_ID1                             number_arr := number_arr(),
 ORDER_LINE_NUMBER                        number_arr := number_arr(),
 PROMISE_DATE                             date_arr := date_arr(),
 CUSTOMER_NAME                            char255_arr := char255_arr(),
 CUSTOMER_LOCATION                        char40_arr := char40_arr(),
 OLD_LINE_SCHEDULE_DATE                   date_arr := date_arr(),
 OLD_SOURCE_ORGANIZATION_CODE             char7_arr := char7_arr(),
 SCENARIO_ID                              number_arr := number_arr(),
 VENDOR_NAME                              char80_arr := char80_arr(),
 VENDOR_SITE_NAME                         char255_arr := char255_arr(),
 STATUS_FLAG                              number_arr := number_arr(),
 MDI_ROWID                                char30_arr := char30_arr(),
 DEMAND_SOURCE_TYPE                       number_arr := number_arr(),
 DEMAND_SOURCE_DELIVERY                   char30_arr := char30_arr(),
 ATP_LEAD_TIME                            number_arr := number_arr(),
 OE_FLAG                                  char1_arr := char1_arr(),
 ITEM_DESC                                char255_arr := char255_arr(),
 INTRANSIT_LEAD_TIME                      number_arr := number_arr(),
 SHIP_METHOD_TEXT                         char255_arr := char255_arr(),
 END_PEGGING_ID                           number_arr := number_arr(),
 SHIP_SET_ID                              number_arr := number_arr(),
 ARRIVAL_SET_ID                           number_arr := number_arr(),
 SHIPMENT_NUMBER                          number_arr := number_arr(),
 OPTION_NUMBER                            number_arr := number_arr(),
 PROJECT_ID                               number_arr := number_arr(),
 TASK_ID                                  number_arr := number_arr(),
 PROJECT_NUMBER                           char30_arr := char30_arr(),
 TASK_NUMBER                              char30_arr := char30_arr(),
 EXCEPTION1                               number_arr := number_arr(),
 EXCEPTION2                               number_arr := number_arr(),
 EXCEPTION3                               number_arr := number_arr(),
 EXCEPTION4                               number_arr := number_arr(),
 EXCEPTION5                               number_arr := number_arr(),
 EXCEPTION6                               number_arr := number_arr(),
 EXCEPTION7                               number_arr := number_arr(),
 EXCEPTION8                               number_arr := number_arr(),
 EXCEPTION9                               number_arr := number_arr(),
 EXCEPTION10                              number_arr := number_arr(),
 EXCEPTION11                              number_arr := number_arr(),
 EXCEPTION12                              number_arr := number_arr(),
 EXCEPTION13                              number_arr := number_arr(),
 EXCEPTION14                              number_arr := number_arr(),
 EXCEPTION15                              number_arr := number_arr(),
 FIRM_SOURCE_ORG_ID                       number_arr := number_arr(),
 FIRM_SOURCE_ORG_CODE                     char7_arr := char7_arr(),
 FIRM_SHIP_DATE                           date_arr := date_arr(),
 FIRM_ARRIVAL_DATE                        date_arr := date_arr(),
 OLD_SOURCE_ORGANIZATION_ID               number_arr := number_arr(),
 OLD_DEMAND_CLASS                         char30_arr := char30_arr(),
 ATTRIBUTE_06                             char30_arr := char30_arr(),
 REQUEST_ITEM_ID                          number_arr := number_arr(),
 REQUEST_ITEM_NAME                        char255_arr := char255_arr(),
 REQ_ITEM_AVAILABLE_DATE                  date_arr := date_arr(),
 REQ_ITEM_AVAILABLE_DATE_QTY              number_arr := number_arr(),
 REQ_ITEM_REQ_DATE_QTY                    number_arr := number_arr(),
 SALES_REP                                char255_arr := char255_arr(),
 CUSTOMER_CONTACT                         char255_arr := char255_arr(),
 SUBST_FLAG                               number_arr := number_arr(),
 SUBSTITUTION_TYP_CODE                    number_arr := number_arr(),
 REQ_ITEM_DETAIL_FLAG                     number_arr := number_arr(),
 OLD_INVENTORY_ITEM_ID                    number_arr := number_arr(),
 COMPILE_DESIGNATOR                       char10_arr := char10_arr(),
 CREATION_DATE                            date_arr := date_arr(),
 CREATED_BY                               number_arr := number_arr(),
 LAST_UPDATE_DATE                         date_arr := date_arr(),
 LAST_UPDATED_BY                          number_arr := number_arr(),
 LAST_UPDATE_LOGIN                        number_arr := number_arr(),
 FLOW_STATUS_CODE                         char30_arr := char30_arr(),
 ASSIGNMENT_SET_ID                        number_arr := number_arr(),
 DIAGNOSTIC_ATP_FLAG                      number_arr := number_arr() );

--the mrp_atp_details_temp struct
TYPE ATP_details_rec_type is RECORD (
SESSION_ID                            number_arr := number_arr(),
ORDER_LINE_ID                         number_arr := number_arr(),
PEGGING_ID                            number_arr := number_arr(),
PARENT_PEGGING_ID                     number_arr := number_arr(),
ATP_LEVEL                             number_arr := number_arr(),
REQUEST_ITEM_ID                       number_arr := number_arr(),
INVENTORY_ITEM_ID                     number_arr := number_arr(),
INVENTORY_ITEM_NAME                   char255_arr := char255_arr(),
ORGANIZATION_ID                       number_arr := number_arr(),
ORGANIZATION_CODE                     char7_arr := char7_arr(),
DEPARTMENT_ID                         number_arr := number_arr(),
DEPARTMENT_CODE                       char10_arr := char10_arr(),
RESOURCE_ID                           number_arr := number_arr(),
RESOURCE_CODE                         char10_arr := char10_arr(),
SUPPLIER_ID                           number_arr := number_arr(),
SUPPLIER_NAME                         char80_arr := char80_arr(),
SUPPLIER_SITE_ID                      number_arr := number_arr(),
SUPPLIER_SITE_NAME                    char15_arr := char15_arr(),
FROM_ORGANIZATION_ID                  number_arr := number_arr(),
FROM_ORGANIZATION_CODE                char3_arr := char3_arr(),
FROM_LOCATION_ID                      number_arr := number_arr(),
FROM_LOCATION_CODE                    char20_arr := char20_arr(),
TO_ORGANIZATION_ID                    number_arr := number_arr(),
TO_ORGANIZATION_CODE                  char3_arr := char3_arr(),
TO_LOCATION_ID                        number_arr := number_arr(),
TO_LOCATION_CODE                      char20_arr := char20_arr(),
SHIP_METHOD                           char30_arr := char30_arr(),
UOM_CODE                              char3_arr := char3_arr(),
IDENTIFIER1                           number_arr := number_arr(),
IDENTIFIER2                           number_arr := number_arr(),
IDENTIFIER3                           number_arr := number_arr(),
IDENTIFIER4                           number_arr := number_arr(),
SUPPLY_DEMAND_TYPE                    number_arr := number_arr(),
SUPPLY_DEMAND_DATE                    date_arr   := date_arr(),
SUPPLY_DEMAND_QUANTITY                number_arr := number_arr(),
SUPPLY_DEMAND_SOURCE_TYPE             number_arr := number_arr(),
ALLOCATED_QUANTITY                    number_arr := number_arr(),
SOURCE_TYPE                           number_arr := number_arr(),
RECORD_TYPE                           number_arr := number_arr(),
TOTAL_SUPPLY_QUANTITY                 number_arr := number_arr(),
TOTAL_DEMAND_QUANTITY                 number_arr := number_arr(),
PERIOD_START_DATE                     date_arr   := date_arr(),
PERIOD_QUANTITY                       number_arr := number_arr(),
CUMULATIVE_QUANTITY                   number_arr := number_arr(),
WEIGHT_CAPACITY                       number_arr := number_arr(),
VOLUME_CAPACITY                       number_arr := number_arr(),
WEIGHT_UOM                            char3_arr := char3_arr(),
VOLUME_UOM                            char3_arr := char3_arr(),
PERIOD_END_DATE                       date_arr   := date_arr(),
SCENARIO_ID                           number_arr := number_arr(),
DISPOSITION_TYPE                      number_arr := number_arr(),
DISPOSITION_NAME                      char80_arr := char80_arr(),
REQUEST_ITEM_NAME                     char255_arr := char255_arr(),
SUPPLY_DEMAND_SOURCE_TYPE_NAME        char80_arr := char80_arr(),
END_PEGGING_ID                        number_arr := number_arr(),
CONSTRAINT_FLAG                       char1_arr := char1_arr(),
NUMBER1                               number_arr := number_arr(),
CHAR1                                 char40_arr := char40_arr(),
COMPONENT_IDENTIFIER                  number_arr := number_arr(),
BATCHABLE_FLAG                        number_arr := number_arr(),
DEST_INV_ITEM_ID                      number_arr := number_arr(),
SUPPLIER_ATP_DATE                     date_arr   := date_arr(),
SUMMARY_FLAG                          char1_arr := char1_arr(),
PTF_DATE                              date_arr   := date_arr(),
CREATION_DATE                         date_arr   := date_arr(),
CREATED_BY                            number_arr := number_arr(),
LAST_UPDATE_DATE                      date_arr   := date_arr(),
LAST_UPDATED_BY                       number_arr := number_arr(),
LAST_UPDATE_LOGIN                     number_arr := number_arr(),
FIXED_LEAD_TIME                       number_arr := number_arr(),
VARIABLE_LEAD_TIME                    number_arr := number_arr(),
PREPROCESSING_LEAD_TIME               number_arr := number_arr(),
PROCESSING_LEAD_TIME                  number_arr := number_arr(),
POSTPROCESSING_LEAD_TIME              number_arr := number_arr(),
INTRANSIT_LEAD_TIME                   number_arr := number_arr(),
ATP_RULE                              char80_arr := char80_arr(),
ALLOCATION_RULE                       char80_arr := char80_arr(),
INFINITE_TIME_FENCE                   date_arr   := date_arr(),
INFINITE_TIME_FENCE_TYPE              number_arr := number_arr(),
SUBSTITUTION_WINDOW                   number_arr := number_arr(),
REQUIRED_QUANTITY                     number_arr := number_arr(),
ROUNDING_CONTROL                      number_arr := number_arr(),
ATP_FLAG                              char1_arr := char1_arr(),
ATP_COMPONENT_FLAG                    char1_arr := char1_arr(),
REQUIRED_DATE                         date_arr   := date_arr(),
OPERATION_SEQUENCE_ID                 number_arr := number_arr(),
SOURCING_RULE_NAME                    char30_arr := char30_arr(),
OFFSET                                number_arr := number_arr(),
EFFICIENCY                            number_arr := number_arr(),
OWNING_DEPARTMENT_ID                  number_arr := number_arr(),
REVERSE_CUM_YIELD                     number_arr := number_arr(),
BASIS_TYPE                            number_arr := number_arr(),
BATCH_FLAG                            char255_arr := char255_arr(),
USAGE                                 number_arr := number_arr(),
CONSTRAINT_TYPE                       number_arr := number_arr(),
CONSTRAINT_DATE                       date_arr   := date_arr(),
CRITICAL_PATH                         number_arr := number_arr(),
PEGGING_TYPE                          number_arr := number_arr(),
ASSIGNED_UNITS                        number_arr := number_arr(),
UTILIZATION                           number_arr := number_arr(),
ATP_RULE_ID                           number_arr := number_arr(),
OWNING_DEPARTMENT                     char10_arr := char10_arr(),
ATP_RULE_NAME                         char80_arr := char80_arr(),
PLAN_NAME                             char80_arr := char80_arr(),
CONSTRAINED_PATH                      number_arr := number_arr(),
PLAN_ID                               number_arr := number_arr(),
DEMAND_CLASS                          char80_arr := char80_arr(),
CLASS                                 char80_arr := char80_arr(),
CUSTOMER_NAME                         char80_arr := char80_arr(),
CUSTOMER_SITE_NAME                    char80_arr := char80_arr(),
ALLOCATED_SUPPLY_QUANTITY             number_arr := number_arr(),
SUPPLY_ADJUSTMENT_QUANTITY            number_arr := number_arr(),
BACKWARD_FORWARD_QUANTITY             number_arr := number_arr(),
BACKWARD_QUANTITY                     number_arr := number_arr(),
DEMAND_ADJUSTMENT_QUANTITY            number_arr := number_arr(),
ADJUSTED_AVAILABILITY_QUANTITY        number_arr := number_arr(),
ALLOCATION_PERCENT                    number_arr := number_arr(),
ACTUAL_ALLOCATION_PERCENT             number_arr := number_arr(),
ADJUSTED_CUM_QUANTITY                 number_arr := number_arr(),
CUSTOMER_ID                           number_arr := number_arr(),
CUSTOMER_SITE_ID                      number_arr := number_arr()
);

PROCEDURE populate_schedule_temp_table(p_atp_schedule_temp IN MSC_ATPUI_UTIL.ATP_SCHEDULE_TEMP_TYP,
				p_return_status out nocopy VARCHAR2,
				p_error_message out nocopy VARCHAR2);
PROCEDURE get_schedule_temp_rows(p_session_id in NUMBER,
				p_return_status out nocopy VARCHAR2,
				p_error_message out nocopy VARCHAR2);

PROCEDURE populate_details_temp_table(p_atp_details_temp IN MSC_ATPUI_UTIL.ATP_details_rec_type,
				p_return_status out nocopy VARCHAR2,
				p_error_message out nocopy VARCHAR2);
PROCEDURE get_details_temp_rows(p_atp_details_temp IN OUT NoCopy MSC_ATPUI_UTIL.ATP_details_rec_type,
                                p_session_id in NUMBER,
				p_return_status out nocopy VARCHAR2,
				p_error_message out nocopy VARCHAR2);

PROCEDURE populate_mrp_atp_temp_tables(p_session_id in NUMBER,
				p_return_status out nocopy VARCHAR2,
				p_error_message out nocopy VARCHAR2);


END MSC_ATPUI_UTIL;

 

/
