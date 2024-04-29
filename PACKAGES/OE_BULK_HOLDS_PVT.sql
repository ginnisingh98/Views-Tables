--------------------------------------------------------
--  DDL for Package OE_BULK_HOLDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_HOLDS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEBVHLDS.pls 120.0.12010000.11 2011/12/27 14:55:53 sujithku ship $ */


-----------------------------------------------------------------
-- DATA TYPES (RECORD/TABLE TYPES)
-----------------------------------------------------------------

/*ER#7479609 start
TYPE Hold_Tbl IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;
ER#7479609 end*/

--ER#7479609 start
TYPE Hold_Tbl IS TABLE OF OE_HOLD_SOURCES_ALL.HOLD_ENTITY_ID%TYPE
     INDEX BY VARCHAR2(250);
-- OE_HOLD_SOURCES_ALL.HOLD_ENTITY_ID%TYPE; -- Modified INDEX BY TO VARCHAR2 for bug 7589328
--ER#7479609 end

/*ER#7479609 start
TYPE Hold_Entity_Rec IS RECORD
(Entity_Id1         NUMBER,
 Entity_Id2         NUMBER,
 Hold_Source_Id     NUMBER,
 Activity_name      VARCHAR2(30)
);
ER#7479609 end*/

--ER#7479609 start
TYPE Hold_Entity_Rec IS RECORD
(Entity_Id1         OE_HOLD_SOURCES_ALL.HOLD_ENTITY_ID%TYPE,
 Entity_Id2         OE_HOLD_SOURCES_ALL.HOLD_ENTITY_ID2%TYPE,
 Hold_Source_Id     NUMBER,
 Activity_name      VARCHAR2(30),
 Hold_id            NUMBER --ER# 3667551
);
--ER#7479609 end
TYPE Hold_Entity_Tbl IS TABLE OF Hold_Entity_Rec
     INDEX BY VARCHAR2(250);

TYPE Line_Holds_Rec IS RECORD
(On_Generic_Hold    VARCHAR2(1),
 On_Scheduling_Hold   VARCHAR2(1),
 Any_ato_line_on_hold VARCHAR2(1),
 Any_SMC_Line_on_hold VARCHAR2(1),
 Hold_II_FLAG         VARCHAR2(1)
);

TYPE Line_Holds_Tbl IS TABLE OF Line_Holds_Rec
     INDEX BY VARCHAR2(250);

---------------------------------------------------------------------
-- GLOBAL RECORDS/TABLES
---------------------------------------------------------------------

G_Line_Holds_Tbl            Line_Holds_Tbl;

Customer_Pointer            Hold_Tbl;
Item_Pointer                Hold_Tbl;
ship_to_Pointer             Hold_Tbl;
bill_to_Pointer             Hold_Tbl;
Warehouse_Pointer           Hold_Tbl;
--ER#7479609 start
PriceList_Pointer           Hold_Tbl;
OrderType_Pointer           Hold_Tbl;
CreationDate_Pointer        Hold_Tbl;
SalesChannel_Pointer        Hold_Tbl;
PaymentType_Pointer         Hold_Tbl;
ShipMethod_Pointer          Hold_Tbl;
deliver_to_Pointer          Hold_Tbl;
--ER#7479609 end

Item_Customer_Pointer       Hold_Tbl;
Item_shipto_Pointer         Hold_Tbl;
Item_Billto_Pointer         Hold_Tbl;
Item_Warehouse_Pointer      Hold_Tbl;
--ER#7479609 Start
Item_ShipMethod_Pointer     Hold_Tbl;
Item_Deliverto_Pointer      Hold_Tbl;
Item_PriceList_Pointer      Hold_Tbl;
Item_SourceType_Pointer     Hold_Tbl;
Item_LineType_Pointer       Hold_Tbl;
--ER#7479609 End

Warehouse_Customer_Pointer  Hold_Tbl;
Warehouse_shipto_Pointer    Hold_Tbl;
Warehouse_Billto_Pointer    Hold_Tbl;
--ER#7479609 Start
Warehouse_LineType_Pointer    Hold_Tbl;
Warehouse_ShipMethod_Pointer  Hold_Tbl;
Warehouse_Deliverto_Pointer   Hold_Tbl;
Warehouse_SourceType_Pointer  Hold_Tbl;
--ER#7479609 End

--ER#7479609 start
Cust_SourceType_Pointer       Hold_Tbl;
Cust_Billto_Pointer           Hold_Tbl;
Cust_Shipto_Pointer           Hold_Tbl;
Cust_Deliverto_Pointer        Hold_Tbl;
Cust_PriceList_Pointer        Hold_Tbl;
Cust_LineType_Pointer         Hold_Tbl;
Cust_PayTerm_Pointer          Hold_Tbl;
Cust_OrderType_Pointer        Hold_Tbl;
Cust_PaymentType_Pointer      Hold_Tbl;
Cust_Curr_Pointer             Hold_Tbl;
Cust_SalesChannel_Pointer     Hold_Tbl;


PriceList_Curr_Pointer        Hold_Tbl;

OrderType_Curr_Pointer        Hold_Tbl;
OrderType_LineType_Pointer    Hold_Tbl;

CreDate_CreBy_Pointer         Hold_Tbl;
--ER#7479609 End


Customer_Hold               Hold_Entity_Tbl;
Item_Hold                   Hold_Entity_Tbl;
ship_to_Hold                Hold_Entity_Tbl;
bill_to_Hold                Hold_Entity_Tbl;
Warehouse_Hold              Hold_Entity_Tbl;
--ER#7479609 start
PriceList_Hold              Hold_Entity_Tbl;
OrderType_Hold              Hold_Entity_Tbl;
CreationDate_Hold           Hold_Entity_Tbl;
SalesChannel_Hold           Hold_Entity_Tbl;
PaymentType_Hold            Hold_Entity_Tbl;
ShipMethod_Hold             Hold_Entity_Tbl;
deliver_to_Hold             Hold_Entity_Tbl;
--ER#7479609 end

Item_Customer_Hold          Hold_Entity_Tbl;
Item_shipto_Hold            Hold_Entity_Tbl;
Item_Billto_Hold            Hold_Entity_Tbl;
Item_Warehouse_Hold         Hold_Entity_Tbl;
--ER#7479609 start
Item_ShipMethod_Hold        Hold_Entity_Tbl;
Item_Deliverto_Hold         Hold_Entity_Tbl;
Item_PriceList_Hold         Hold_Entity_Tbl;
Item_SourceType_Hold        Hold_Entity_Tbl;
Item_LineType_Hold          Hold_Entity_Tbl;
--ER#7479609 end

Warehouse_Customer_Hold     Hold_Entity_Tbl;
Warehouse_shipto_Hold       Hold_Entity_Tbl;
Warehouse_Billto_Hold       Hold_Entity_Tbl;
--ER#7479609 start
Warehouse_LineType_Hold     Hold_Entity_Tbl;
Warehouse_ShipMethod_Hold   Hold_Entity_Tbl;
Warehouse_Deliverto_Hold    Hold_Entity_Tbl;
Warehouse_SourceType_Hold   Hold_Entity_Tbl;
--ER#7479609 end

--ER#7479609 start
Cust_SourceType_Hold        Hold_Entity_Tbl;
Cust_Billto_Hold            Hold_Entity_Tbl;
Cust_Shipto_Hold            Hold_Entity_Tbl;
Cust_Deliverto_Hold         Hold_Entity_Tbl;
Cust_PriceList_Hold         Hold_Entity_Tbl;
Cust_LineType_Hold          Hold_Entity_Tbl;
Cust_PayTerm_Hold           Hold_Entity_Tbl;
Cust_OrderType_Hold         Hold_Entity_Tbl;
Cust_PaymentType_Hold       Hold_Entity_Tbl;
Cust_Curr_Hold              Hold_Entity_Tbl;
Cust_SalesChannel_Hold      Hold_Entity_Tbl;

--ER#7479609 end

PriceList_Curr_Hold         Hold_Entity_Tbl;

OrderType_Curr_Hold         Hold_Entity_Tbl;
OrderType_LineType_Hold     Hold_Entity_Tbl;

CreDate_CreBy_Hold          Hold_Entity_Tbl;
--ER#7479609 end

--ER# 12571983 start added for 'EC'
EndCust_Pointer                  Hold_Tbl;
Item_EndCust_Pointer             Hold_Tbl;
Warehouse_EndCust_Pointer        Hold_Tbl;
EndCust_SourceType_Pointer       Hold_Tbl;
EndCust_Billto_Pointer           Hold_Tbl;
EndCust_Shipto_Pointer           Hold_Tbl;
EndCust_Deliverto_Pointer        Hold_Tbl;
EndCust_PriceList_Pointer        Hold_Tbl;
EndCust_LineType_Pointer         Hold_Tbl;
EndCust_PayTerm_Pointer          Hold_Tbl;
EndCust_OrderType_Pointer        Hold_Tbl;
EndCust_PaymentType_Pointer      Hold_Tbl;
EndCust_Curr_Pointer             Hold_Tbl;
EndCust_SalesChannel_Pointer     Hold_Tbl;
EndCust_EndCustLoc_Pointer       Hold_Tbl;

EndCust_Hold                   Hold_Entity_Tbl;
Item_EndCust_Hold              Hold_Entity_Tbl;
Warehouse_EndCust_Hold         Hold_Entity_Tbl;
EndCust_SourceType_Hold        Hold_Entity_Tbl;
EndCust_Billto_Hold            Hold_Entity_Tbl;
EndCust_Shipto_Hold            Hold_Entity_Tbl;
EndCust_Deliverto_Hold         Hold_Entity_Tbl;
EndCust_PriceList_Hold         Hold_Entity_Tbl;
EndCust_LineType_Hold          Hold_Entity_Tbl;
EndCust_PayTerm_Hold           Hold_Entity_Tbl;
EndCust_OrderType_Hold         Hold_Entity_Tbl;
EndCust_PaymentType_Hold       Hold_Entity_Tbl;
EndCust_Curr_Hold              Hold_Entity_Tbl;
EndCust_SalesChannel_Hold      Hold_Entity_Tbl;
EndCust_EndCustLoc_Hold        Hold_Entity_Tbl;

--ER# 12571983 end added for 'EC'

--ER# 13331078 start added for 'IC'

ItemCat_Pointer                Hold_Tbl;
ItemCat_Customer_Pointer       Hold_Tbl;
ItemCat_shipto_Pointer         Hold_Tbl;
ItemCat_Billto_Pointer         Hold_Tbl;
ItemCat_Warehouse_Pointer      Hold_Tbl;
ItemCat_ShipMethod_Pointer     Hold_Tbl;
ItemCat_Deliverto_Pointer      Hold_Tbl;
ItemCat_PriceList_Pointer      Hold_Tbl;
ItemCat_SourceType_Pointer     Hold_Tbl;
ItemCat_LineType_Pointer       Hold_Tbl;
ItemCat_EndCust_Pointer        Hold_Tbl;

ItemCat_Hold                   Hold_Entity_Tbl;
ItemCat_Customer_Hold          Hold_Entity_Tbl;
ItemCat_shipto_Hold            Hold_Entity_Tbl;
ItemCat_Billto_Hold            Hold_Entity_Tbl;
ItemCat_Warehouse_Hold         Hold_Entity_Tbl;
ItemCat_ShipMethod_Hold        Hold_Entity_Tbl;
ItemCat_Deliverto_Hold         Hold_Entity_Tbl;
ItemCat_PriceList_Hold         Hold_Entity_Tbl;
ItemCat_SourceType_Hold        Hold_Entity_Tbl;
ItemCat_LineType_Hold          Hold_Entity_Tbl;
ItemCat_EndCust_Hold           Hold_Entity_Tbl;

--ER# 13331078 end added for 'IC'

g_hold_header_id        OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
g_hold_line_id          OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
g_hold_Source_Id        OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
g_hold_ship_set         OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30();
g_hold_arrival_set      OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30();
g_hold_top_model_line_id  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
g_hold_activity_name    OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30();

g_header_index   NUMBER;

TYPE Hold_Source_Rec IS RECORD
(
HOLD_ID                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM(),
HOLD_SOURCE_ID         OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM(),
HOLD_ENTITY_CODE       OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30(),
HOLD_ENTITY_ID         OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM(),
HOLD_UNTIL_DATE        OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE(),
RELEASED_FLAG          OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1(),
HOLD_COMMENT           OE_WSH_BULK_GRP.T_V2000 := OE_WSH_BULK_GRP.T_V2000(),
ORG_ID                 OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM(),
HOLD_RELEASE_ID        OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM(),
HOLD_ENTITY_CODE2      OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30(),
HOLD_ENTITY_ID2        OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM(),
HEADER_ID              OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM(),
LINE_ID                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
);

g_hold_source_rec  Hold_Source_Rec;
-----------------------------------------------------------------------
-- PROCEDURES/FUNCTIONS
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- PROCEDURE Load_Hold_Sources
--
-- This API caches existing hold sources in global tables:
-- Customer_Pointer etc. It is called from order import main package
-- (OEBVIMNB.pls) at the beginning of each order import request.
-----------------------------------------------------------------------

PROCEDURE Load_Hold_Sources;

-----------------------------------------------------------------------
-- PROCEDURE Initialize_Holds_Tbl
--
-- This API initializes the globals that store hold records for
-- a batch.
-----------------------------------------------------------------------

PROCEDURE Initialize_Holds_Tbl;

-----------------------------------------------------------------------
-- PROCEDURE Evaluate_Holds
--
-- This procedure is used to evaluate holds on the order or line being
-- processed in BULK order import.
--
-- If order or line attributes passed to this API (sold_to_org_id,
-- inventory_item_id etc.) match the hold source(s) criteria, this API
-- would mark that hold(s) needs to be applied by adding to the global
-- holds table.
--
-- In addition, it also populates OUT parameters to indicate the type
-- of hold (if any) that will be applied on this order or line.
-- Current BULK code needs to check for generic, booking or scheduling
-- holds only so there are 3 OUT parameters which will be set to TRUE
-- depending on types of holds that were applied.
-----------------------------------------------------------------------

PROCEDURE Evaluate_Holds(
p_header_id         IN NUMBER,
p_line_id           IN NUMBER,
p_line_number       IN NUMBER,
p_sold_to_org_id    IN NUMBER,
p_inventory_item_id IN NUMBER,
p_ship_from_org_id  IN NUMBER,
p_invoice_to_org_id IN NUMBER,
p_ship_to_org_id    IN NUMBER,
p_top_model_line_id IN NUMBER,
p_ship_set_name     IN VARCHAR2,
p_arrival_set_name  IN VARCHAR2,
p_check_only_warehouse_holds IN BOOLEAN := FALSE,
p_on_generic_hold   OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
p_on_booking_hold   OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
p_on_scheduling_hold   OUT NOCOPY /* file.sql.39 change */ BOOLEAN
);


--ER#7479609 start
-----------------------------------------------------------------------
-- PROCEDURE Evaluate_Holds
--
-- This procedure is used to evaluate holds on the order or line being
-- processed in BULK order import.
--
-- If order or line attributes passed to this API (sold_to_org_id,
-- inventory_item_id etc.) match the hold source(s) criteria, this API
-- would mark that hold(s) needs to be applied by adding to the global
-- holds table.
--
-- In addition, it also populates OUT parameters to indicate the type
-- of hold (if any) that will be applied on this order or line.
-- Current BULK code needs to check for generic, booking or scheduling
-- holds only so there are 3 OUT parameters which will be set to TRUE
-- depending on types of holds that were applied.
-----------------------------------------------------------------------

PROCEDURE Evaluate_Holds(
p_header_rec        IN OE_Order_PUB.Header_Rec_Type,
p_line_rec           IN OE_Order_PUB.Line_Rec_Type,
p_check_only_warehouse_holds IN BOOLEAN := FALSE,
p_on_generic_hold   OUT NOCOPY BOOLEAN,
p_on_booking_hold   OUT NOCOPY BOOLEAN,
p_on_scheduling_hold   OUT NOCOPY BOOLEAN
);
--ER#7479609 end

-----------------------------------------------------------------------
-- PROCEDURE Create_Holds
--
-- This API BULK inserts hold records into the database for orders
-- or lines processed in a single bulk order import batch. It uses
-- global hold records to create these records.
-----------------------------------------------------------------------

PROCEDURE Create_Holds;


------------------------------------------------------------------------
--PROCEDURE Mark_Hols
--This for marking lines to hold in the memory.
------------------------------------------------------------------------
PROCEDURE Mark_Hold(p_header_id IN NUMBER,
                    p_line_id IN NUMBER,
                    p_line_number IN NUMBER,
                    p_hold_source_id IN NUMBER,
                    p_ship_set_name IN VARCHAR2,
                    p_arrival_set_name IN VARCHAR2,
                    p_activity_name IN VARCHAR2,
                    p_attribute IN VARCHAR2,
                    p_top_model_line_id IN NUMBER
                    );

PROCEDURE Apply_GSA_Hold(p_header_id IN NUMBER,
                    p_line_id IN NUMBER,
                    p_line_number IN NUMBER,
                    p_hold_id IN NUMBER,
                    p_ship_set_name IN VARCHAR2,
                    p_arrival_set_name IN VARCHAR2,
                    p_activity_name IN VARCHAR2,
                    p_attribute IN VARCHAR2,
                    p_top_model_line_id IN NUMBER,
                    x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2   --bug 3735141
                    );

------------------------------------------------------------------------
-- FUNCTION Check_for_Holds
-- This API is called by scheduling
------------------------------------------------------------------------
FUNCTION Check_For_Holds(p_header_id IN NUMBER,
                         p_line_id IN NUMBER,
                         p_line_index IN NUMBER,
                         p_header_index IN NUMBER,
                         p_top_model_line_index IN NUMBER,
                         p_ship_model_complete_flag IN VARCHAR2,
                         p_ato_line_index IN NUMBER,
                         p_ii_parent_line_index IN NUMBER
                        ) RETURN BOOLEAN;

------------------------------------------------------------------------
----ER# 3667551  new Function added to return Customer Account ID
----for the Site ID passed in
------------------------------------------------------------------------
FUNCTION CustAcctID_func
  (
    p_in_site_id IN NUMBER,
    p_out_IDfound OUT NOCOPY VARCHAR2)	RETURN NUMBER;

END OE_Bulk_Holds_PVT;


/
