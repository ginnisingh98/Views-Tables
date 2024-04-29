--------------------------------------------------------
--  DDL for Package WSH_BULK_TYPES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_BULK_TYPES_GRP" AUTHID CURRENT_USER as
/* $Header: WSHBTGPS.pls 120.0 2005/05/26 18:03:56 appldev noship $ */


--===================
-- PUBLIC VARS
--===================


TYPE action_parameters_rectype IS RECORD (
   Caller      	      VARCHAR2(50),
   Entity	      VARCHAR2(50),
   Phase	      NUMBER,
   action_code	      VARCHAR2(50),
   Org_id	      NUMBER,
   shipment_header_id NUMBER,
   ib_txn_history_id NUMBER,
   ship_from_location_id   NUMBER   -- IB-Phase-2
        );


TYPE Bulk_process_out_rec_type IS RECORD (
 	dummy                      NUMBER
);

Type  char1_Nested_Tab_Type IS TABLE OF VARCHAR2(1);
Type  char150_Nested_Tab_Type IS TABLE OF VARCHAR2(150);
Type  char30_Nested_Tab_Type IS TABLE OF VARCHAR2(30);
Type  date_Nested_Tab_Type IS TABLE OF DATE;
Type  number_Nested_Tab_Type IS TABLE OF NUMBER;

Type  char3_Nested_Tab_Type IS TABLE OF VARCHAR2(3);   -- J-IB-NPARIKH


--HVOP: ITS heali
    TYPE tbl_num        is table of number              INDEX BY BINARY_INTEGER;
    TYPE tbl_num1       is table of number(1)           INDEX BY BINARY_INTEGER;
    TYPE tbl_v1         is table of varchar2(1)         INDEX BY BINARY_INTEGER;
    TYPE tbl_v3         is table of varchar2(3)         INDEX BY BINARY_INTEGER;
    TYPE tbl_v10        is table of varchar2(10)        INDEX BY BINARY_INTEGER;
    TYPE tbl_v20        is table of varchar2(20)        INDEX BY BINARY_INTEGER;
    TYPE tbl_v25        is table of varchar2(25)        INDEX BY BINARY_INTEGER;
    TYPE tbl_v30        is table of varchar2(30)        INDEX BY BINARY_INTEGER;
    TYPE tbl_v32        is table of varchar2(32)        INDEX BY BINARY_INTEGER;
    TYPE tbl_v40        is table of varchar2(40)        INDEX BY BINARY_INTEGER;
    TYPE tbl_v50        is table of varchar2(50)        INDEX BY BINARY_INTEGER;   -- J-IB-NPARIKH
-- HW OPMCONV. New length for lot of 80
    TYPE tbl_v80        is table of varchar2(80)        INDEX BY BINARY_INTEGER;
    TYPE tbl_v150       is table of varchar2(150)       INDEX BY BINARY_INTEGER;
    TYPE tbl_v240       is table of varchar2(240)       INDEX BY BINARY_INTEGER;
    TYPE tbl_v2000      is table of varchar2(2000)      INDEX BY BINARY_INTEGER;
    TYPE tbl_date       is table of date                INDEX BY BINARY_INTEGER;
--HVOP: ITS heali


END WSH_BULK_TYPES_GRP;

 

/
