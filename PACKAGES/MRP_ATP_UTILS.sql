--------------------------------------------------------
--  DDL for Package MRP_ATP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ATP_UTILS" AUTHID CURRENT_USER AS
/* $Header: MRPUATPS.pls 120.0 2005/05/25 03:44:18 appldev noship $  */

TYPE number_arr IS TABLE OF number;
TYPE char3_arr IS TABLE OF varchar2(3);
TYPE char7_arr IS TABLE OF varchar2(7);
TYPE char10_arr IS TABLE of varchar2(10);
TYPE char18_arr IS TABLE of varchar2(18);
TYPE char25_arr IS TABLE of varchar2(25);
TYPE char30_arr IS TABLE of varchar2(30);
TYPE char40_arr IS TABLE of varchar2(40);
TYPE char50_arr IS TABLE of varchar2(50);
TYPE char240_arr IS TABLE of varchar2(240);
TYPE char255_arr IS TABLE of varchar2(255);--3991728
TYPE date_arr IS TABLE OF date;
TYPE SchedCurTyp IS REF CURSOR;

-- cchen: add the following two types to replace mrp_atp_schedule_temp%ROWTYPE
-- and mrp_atp_details_temp%ROWTYPE since they don't work for distributed atp
-- if the table definitions are not the same.

TYPE Details_Temp is RECORD
 (SESSION_ID NUMBER
 ,ORDER_LINE_ID NUMBER
 ,PEGGING_ID NUMBER
 ,PARENT_PEGGING_ID NUMBER
 ,ATP_LEVEL NUMBER
 ,REQUEST_ITEM_ID NUMBER
 ,INVENTORY_ITEM_ID NUMBER
 ,INVENTORY_ITEM_NAME VARCHAR2(40)
 ,ORGANIZATION_ID NUMBER
 ,ORGANIZATION_CODE VARCHAR2(7)
 ,DEPARTMENT_ID NUMBER
 ,DEPARTMENT_CODE VARCHAR2(10)
 ,RESOURCE_ID NUMBER
 ,RESOURCE_CODE VARCHAR2(10)
 ,SUPPLIER_ID NUMBER
 ,SUPPLIER_NAME VARCHAR2(80)
 ,SUPPLIER_SITE_ID NUMBER
 ,SUPPLIER_SITE_NAME VARCHAR2(15)
 ,FROM_ORGANIZATION_ID NUMBER
 ,FROM_ORGANIZATION_CODE VARCHAR2(3)
 ,FROM_LOCATION_ID NUMBER
 ,FROM_LOCATION_CODE VARCHAR2(20)
 ,TO_ORGANIZATION_ID NUMBER
 ,TO_ORGANIZATION_CODE VARCHAR2(3)
 ,TO_LOCATION_ID NUMBER
 ,TO_LOCATION_CODE VARCHAR2(20)
 ,SHIP_METHOD VARCHAR2(30)
 ,UOM_CODE VARCHAR2(3)
 ,IDENTIFIER1 NUMBER
 ,IDENTIFIER2 NUMBER
 ,IDENTIFIER3 NUMBER
 ,IDENTIFIER4 NUMBER
 ,SUPPLY_DEMAND_TYPE NUMBER
 ,SUPPLY_DEMAND_DATE DATE
 ,SUPPLY_DEMAND_QUANTITY NUMBER
 ,SUPPLY_DEMAND_SOURCE_TYPE NUMBER
 ,ALLOCATED_QUANTITY NUMBER
 ,SOURCE_TYPE NUMBER
 ,RECORD_TYPE NUMBER
 ,TOTAL_SUPPLY_QUANTITY NUMBER
 ,TOTAL_DEMAND_QUANTITY NUMBER
 ,PERIOD_START_DATE DATE
 ,PERIOD_QUANTITY NUMBER
 ,CUMULATIVE_QUANTITY NUMBER
 ,WEIGHT_CAPACITY NUMBER
 ,VOLUME_CAPACITY NUMBER
 ,WEIGHT_UOM VARCHAR2(3)
 ,VOLUME_UOM VARCHAR2(3)
 ,PERIOD_END_DATE DATE
 ,SCENARIO_ID NUMBER
 ,DISPOSITION_TYPE NUMBER
 ,DISPOSITION_NAME VARCHAR2(80)
 ,REQUEST_ITEM_NAME VARCHAR2(40)
 ,SUPPLY_DEMAND_SOURCE_TYPE_NAME VARCHAR2(80)
 ,END_PEGGING_ID NUMBER
 );

TYPE Schedule_Temp is RECORD
 (ACTION NUMBER
 ,CALLING_MODULE NUMBER
 ,SESSION_ID NUMBER
 ,ORDER_HEADER_ID NUMBER
 ,ORDER_LINE_ID NUMBER
 ,INVENTORY_ITEM_ID NUMBER
 ,ORGANIZATION_ID NUMBER
 ,SR_INSTANCE_ID NUMBER
 ,ORGANIZATION_CODE VARCHAR2(7)
 ,ORDER_NUMBER NUMBER
 ,SOURCE_ORGANIZATION_ID NUMBER
 ,CUSTOMER_ID NUMBER
 ,CUSTOMER_SITE_ID NUMBER
 ,DESTINATION_TIME_ZONE VARCHAR2(30)
 ,QUANTITY_ORDERED NUMBER
 ,UOM_CODE VARCHAR2(3)
 ,REQUESTED_SHIP_DATE DATE
 ,REQUESTED_ARRIVAL_DATE DATE
 ,LATEST_ACCEPTABLE_DATE DATE
 ,DELIVERY_LEAD_TIME NUMBER
 ,FREIGHT_CARRIER VARCHAR2(30)
 ,SHIP_METHOD VARCHAR2(30)
 ,DEMAND_CLASS VARCHAR2(30)
 ,SHIP_SET_NAME VARCHAR2(30)
 ,SHIP_SET_ID NUMBER
 ,ARRIVAL_SET_NAME VARCHAR2(30)
 ,ARRIVAL_SET_ID NUMBER
 ,OVERRIDE_FLAG VARCHAR2(1)
 ,SCHEDULED_SHIP_DATE DATE
 ,SCHEDULED_ARRIVAL_DATE DATE
 ,AVAILABLE_QUANTITY NUMBER
 ,REQUESTED_DATE_QUANTITY NUMBER
 ,GROUP_SHIP_DATE DATE
 ,GROUP_ARRIVAL_DATE DATE
 ,VENDOR_ID NUMBER
 ,VENDOR_SITE_ID NUMBER
 ,INSERT_FLAG NUMBER
 ,ERROR_CODE VARCHAR2(240)
 ,ERROR_MESSAGE VARCHAR2(240)
 ,SEQUENCE_NUMBER NUMBER
 ,FIRM_FLAG NUMBER
 ,INVENTORY_ITEM_NAME VARCHAR2(40)
 ,SOURCE_ORGANIZATION_CODE VARCHAR2(7)
 ,INSTANCE_ID1 NUMBER
 ,ORDER_LINE_NUMBER NUMBER
 ,SHIPMENT_NUMBER NUMBER
 ,OPTION_NUMBER NUMBER
 ,PROMISE_DATE DATE
 --,CUSTOMER_NAME VARCHAR2(50)
 ,CUSTOMER_NAME VARCHAR2(255) --3991728
 ,CUSTOMER_LOCATION VARCHAR2(40)
 ,OLD_LINE_SCHEDULE_DATE DATE
 ,OLD_SOURCE_ORGANIZATION_CODE VARCHAR2(7)
 ,SCENARIO_ID NUMBER
 ,VENDOR_NAME VARCHAR2(80)
 ,VENDOR_SITE_NAME VARCHAR2(240)
 ,STATUS_FLAG NUMBER
 ,MDI_ROWID VARCHAR2(30)
 ,DEMAND_SOURCE_TYPE NUMBER
 ,DEMAND_SOURCE_DELIVERY VARCHAR2(30)
 ,ATP_LEAD_TIME NUMBER
 ,OE_FLAG VARCHAR2(1)
 ,ITEM_DESC VARCHAR2(240)
 ,INTRANSIT_LEAD_TIME NUMBER
 ,SHIP_METHOD_TEXT VARCHAR2(240)
 ,END_PEGGING_ID NUMBER
 ,PROJECT_ID NUMBER
 ,TASK_ID NUMBER
 ,PROJECT_NUMBER VARCHAR2(25)
 ,TASK_NUMBER VARCHAR2(25)
 ,OLD_SOURCE_ORGANIZATION_ID  NUMBER
 ,OLD_DEMAND_CLASS VARCHAR2(30)
 ,EXCEPTION1 NUMBER
 ,EXCEPTION2 NUMBER
 ,EXCEPTION3 NUMBER
 ,EXCEPTION4 NUMBER
 ,EXCEPTION5 NUMBER
 ,EXCEPTION6 NUMBER
 ,EXCEPTION7 NUMBER
 ,EXCEPTION8 NUMBER
 ,EXCEPTION9 NUMBER
 ,EXCEPTION10 NUMBER
 ,EXCEPTION11 NUMBER
 ,EXCEPTION12 NUMBER
 ,EXCEPTION13 NUMBER
 ,EXCEPTION14 NUMBER
 ,EXCEPTION15 NUMBER
 ,ATTRIBUTE_06 VARCHAR2(1)
 ,SUBSTITUTION_TYP_CODE             NUMBER
 ,REQ_ITEM_DETAIL_FLAG              NUMBER
 ,OLD_INVENTORY_ITEM_ID             NUMBER
 ,REQUEST_ITEM_ID                   NUMBER
 ,REQUEST_ITEM_NAME                 VARCHAR2(40)
 ,REQ_ITEM_AVAILABLE_DATE           DATE
 ,REQ_ITEM_AVAILABLE_DATE_QTY       NUMBER
 ,REQ_ITEM_REQ_DATE_QTY             NUMBER
 ,SALES_REP                         VARCHAR2(255)
 ,CUSTOMER_CONTACT                  VARCHAR2(255)
 ,SUBST_FLAG                        NUMBER
--diag-atp
 ,diagnostic_atp_flag               NUMBER
 ,internal_org_id                   NUMBER --3409286
 );

SYS_YES                      CONSTANT NUMBER := 1;
SYS_NO                       CONSTANT NUMBER := 2;
REQUEST_MODE                 CONSTANT NUMBER := 1;
RESULTS_MODE                 CONSTANT NUMBER := 2;

TYPE ATP_Period_String_typ is Record
  (
   Total_Supply_Quantity	   number_arr := number_arr(),
   Total_Demand_Quantity	   number_arr := number_arr(),
   Period_Start_Date               date_arr := date_arr(),
   Period_End_Date                 date_arr := date_arr(),
   Period_Quantity                 number_arr := number_arr(),
   Cumulative_Quantity             number_arr := number_arr()
   );

TYPE mrp_atp_schedule_temp_typ IS RECORD
  (
   rowid_char                char18_arr := char18_arr(),
   sequence_number           number_arr := number_arr(),
   firm_flag                 number_arr := number_arr(),
   order_line_number         number_arr := number_arr(),
   option_number             number_arr := number_arr(),
   shipment_number           number_arr := number_arr(),
   item_desc                 char240_arr := char240_arr(),
   --customer_name             char50_arr := char50_arr(),
   customer_name             char255_arr := char255_arr(), --3991728
   customer_location         char40_arr := char40_arr(),
   ship_set_name             char30_arr := char30_arr(),
   arrival_set_name          char30_arr := char30_arr(),
   requested_ship_date       date_arr := date_arr(),
   -- when firming, we put the firm date here for the api
   requested_arrival_date    date_arr := date_arr(),
   -- we need to write the correct one back from the table.
   old_line_schedule_date    date_arr := date_arr(),
   old_source_organization_code    char7_arr := char7_arr(),
   firm_source_org_id        number_arr := number_arr(),
   firm_source_org_code      char7_arr := char7_arr(),
   firm_ship_date            date_arr := date_arr(),
   firm_arrival_date         date_arr := date_arr(),
   ship_method_text          char240_arr := char240_arr(),
   ship_set_id               number_arr := number_arr(),
   arrival_set_id            number_arr := number_arr(),
   PROJECT_ID                number_arr := number_arr(),
   TASK_ID                   number_arr := number_arr(),
   PROJECT_NUMBER            char25_arr := char25_arr(),
   TASK_NUMBER               char25_arr := char25_arr()
   );


PROCEDURE put_into_temp_table
  (
   x_dblink		IN   VARCHAR2,
   x_session_id         IN   NUMBER,
   x_atp_rec            IN   MRP_ATP_PUB.atp_rec_typ,
   x_atp_supply_demand  IN   MRP_ATP_PUB.ATP_Supply_Demand_Typ,
   x_atp_period         IN   MRP_ATP_PUB.ATP_Period_Typ,
   x_atp_details        IN   MRP_ATP_PUB.ATP_Details_Typ,
   x_mode               IN   NUMBER,
   x_return_status      OUT   NoCopy VARCHAR2,
   x_msg_data           OUT   NoCopy VARCHAR2,
   x_msg_count          OUT   NoCopy NUMBER
   );

PROCEDURE get_from_temp_table
  (
   x_dblink		IN   VARCHAR2,
   x_session_id         IN   NUMBER,
   x_atp_rec            OUT   NoCopy MRP_ATP_PUB.atp_rec_typ,
   x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
   x_atp_period         OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
   x_atp_details        OUT   NoCopy MRP_ATP_PUB.ATP_Details_Typ,
   x_mode               IN   NUMBER,
   x_return_status      OUT   NoCopy VARCHAR2,
   x_msg_data           OUT   NoCopy VARCHAR2,
   x_msg_count          OUT   NoCopy NUMBER
   );

FUNCTION Call_ATP_11(
		     p_group_id      NUMBER,
		     p_session_id    NUMBER,
		     p_insert_flag   NUMBER,
		     p_partial_flag  NUMBER,
		     p_err_message   IN OUT NoCopy VARCHAR2) RETURN NUMBER;


PROCEDURE extend_mast
  (
   mast_rec      IN OUT NoCopy mrp_atp_schedule_temp_typ,
   x_ret_code    OUT NoCopy varchar2,
   x_ret_status  OUT NoCopy varchar2);

PROCEDURE trim_mast( mast_rec     IN OUT  NoCopy mrp_atp_schedule_temp_typ,
		     x_ret_code   OUT NoCopy varchar2,
		     x_ret_status OUT NoCopy varchar2);
PROCEDURE test(x_session_id NUMBER);


END MRP_ATP_UTILS;

 

/
