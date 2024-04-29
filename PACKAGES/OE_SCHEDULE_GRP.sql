--------------------------------------------------------
--  DDL for Package OE_SCHEDULE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SCHEDULE_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXGSCHS.pls 120.2.12010000.2 2008/11/21 14:18:55 vbkapoor ship $ */

-- This new global is introduced as part of IR ISO CMS Project.
-- This global will indicate that the call is from Planning and
-- an internal sales order is updated from them. This global will
-- be read in Process Order API code while to trigger/not to
-- trigger scheduling (for Undemand/Unschedule/Unreserve) for
-- update of ordered quantity to 0, i.e. cancelling the internal
-- order line from Planning workbench or by DRP
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc
-- or Refer to bug #7576948
--
G_ISO_Planning_Update BOOLEAN := FALSE;


TYPE sch_rec_type IS RECORD
(line_id                    Number, -- Line id from the line.
 Org_id			            Number, -- Org Id the line belongs to
 Header_id			        Number, -- Order Header information.
 Inventory_item_id          Number, -- Inventory Item Id ER 6110708
 Ship_from_org_id  		    Number, -- Warehouse
 Schedule_ship_date 	    Date,   -- Ship date
 Schedule_arrival_date	    Date,   -- Arrival Date
 Earliest_ship_date         Date,   -- Earliest available date
 Delivery_lead_time		    Number, -- Lead time between ship and Arrival.
 Shipping_Method_Code 	    Varchar2(30), -- Method used to ship the line.
 Ordered_Quantity           Number,  -- Is the quantity updated.
-- Ordered Qty is added as part of IR ISO CMS project. Refer Bug #7576948
 Firm_Demand_Flag           Varchar2(1),  -- Is the line firmed or not.
 Source_type_code           Varchar2(30), -- Internal/External
 Attribute_char1            Varchar2(30), -- New char attr
 Attribute_num1             Number,       -- New Number attr
 Orig_Inventory_item_id     Number, -- Original Inventory Item Id ER 6110708
 Orig_Schedule_Ship_Date    Date,   -- Original Schedule Ship date on the SO
 Orig_Schedule_Arrival_Date Date,   -- Original Schedule Arr date on the SO
 Orig_Ship_from_org_id      Number,   -- Original Waresouse on the SO
 Orig_Shipping_Method_Code  Varchar2(30), -- Origl Shipping Method on the SO
 Orig_ordered_quantity      Number,   -- Original Ordered Qty on the SO
 Orig_Earliest_Ship_date    Date,   -- Original ESD on the SO
 x_override_atp_date_code   Varchar2(1),  -- Was it a overridden line.
 x_line_number              Varchar2(30), -- Line number
 x_return_status        	Varchar2(1));  -- Return status of the line..

TYPE Sch_Tbl_Type IS TABLE OF Sch_rec_type
INDEX BY BINARY_INTEGER;

Procedure Update_Scheduling_Results
(p_x_sch_tbl 	 IN OUT NOCOPY sch_tbl_type,
 p_request_id    IN  Number,
 x_return_status OUT NOCOPY Varchar2);

END OE_SCHEDULE_GRP;

/
