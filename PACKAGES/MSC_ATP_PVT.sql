--------------------------------------------------------
--  DDL for Package MSC_ATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_PVT" AUTHID CURRENT_USER AS
/* $Header: MSCGATPS.pls 120.5.12010000.2 2009/08/24 06:51:44 sbnaik ship $  */

INFINITE_NUMBER         CONSTANT NUMBER := 1.0e+10;
-- single level stealing
SL_STEALING             CONSTANT NUMBER := -12345;
-- order type
ATP                     CONSTANT INTEGER := 100;
SOURCE11i		CONSTANT NUMBER := 3;

--3720018
-- This record structure will be used to store records at request level.
-- These will be used to call remove_invalid_sd_rec() and delete_row()
-- procedures at request level in case of ATP_Inquiry

TYPE REMOVE_REQUEST_LEVEL_REC IS RECORD (
REMOVE_PEGGING_ID_REQUEST                       MRP_ATP_PUB.NUMBER_ARR := MRP_ATP_PUB.number_arr(),
REMOVE_PLAN_ID_REQUEST                          MRP_ATP_PUB.NUMBER_ARR := MRP_ATP_PUB.number_arr(),
REMOVE_DC_ATP_FLAG_REQUEST                      MRP_ATP_PUB.NUMBER_ARR := MRP_ATP_PUB.number_arr()
);

--3720018, new record type for returning records from  call_delete_row .
TYPE DELETE_ATP_REC IS RECORD (
time_phased_set                 VARCHAR2(1),
error_code                      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
attribute_07                    MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
old_plan_id                     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
del_demand_ids                  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
del_inv_item_ids                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
del_plan_ids                    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
del_identifiers                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
del_demand_source_type          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
del_copy_demand_ids             mrp_atp_pub.number_arr := MRP_ATP_PUB.number_arr(),
del_copy_demand_plan_ids        mrp_atp_pub.number_arr := MRP_ATP_PUB.number_arr(),
del_atp_peg_items               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
del_atp_peg_demands             MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
del_atp_peg_supplies            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
del_atp_peg_res_reqs            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
atp_peg_demands_plan_ids        MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
atp_peg_supplies_plan_ids       MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
atp_peg_res_reqs_plan_ids       MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
off_demand_instance_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
off_supply_instance_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
off_res_instance_id             MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(),
del_ods_demand_ids              MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(), --3720018, added for support of rescheduling in ODS
del_ods_inv_item_ids            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(), --3720018, added for support of rescheduling in ODS
del_ods_demand_src_type         MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(), --3720018, added for support of rescheduling in ODS
del_ods_cto_demand_ids          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(), --3720018, added for support of rescheduling in ODS
del_ods_cto_inv_item_ids        MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(), --3720018, added for support of rescheduling in ODS
del_ods_cto_dem_src_type        MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(), --3720018, added for support of rescheduling in ODS
del_ods_atp_refresh_no          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr(), --3720018, added for support of rescheduling in ODS
del_ods_cto_atp_refresh_no      MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.number_arr()  --3720018, added for support of rescheduling in ODS
);
----3720018

TYPE item_attribute_rec IS RECORD (
       instance_id            NUMBER,
       organization_id        NUMBER,
       sr_inv_item_id         NUMBER,
       atp_flag               varchar2(1),
       atp_comp_flag          varchar2(1),
       pre_pro_lt             number,
       post_pro_lt            number,
       fixed_lt               number,
       variable_lt            number,
       substitution_window    number,
       create_supply_flag     number,
       dest_inv_item_id       number,
       item_name              varchar2(40), -- Rewind to 40 Bug 2408159
       atp_rule_id            number,	-- To accomodate Bug 1510853
       rounding_control_type  number,   -- For Forward Stealing
       cto_source_org_id      number,   -- For a CTO line item, stores the source org
       unit_volume            number,
       unit_weight            number,
       volume_uom             varchar2(3),
       weight_uom             varchar2(3),
       uom_code               VARCHAR2(3), -- added by rajjain 12/10/2002
       inventory_item_id      NUMBER, -- added by rajjain 12/10/2002
       processing_lt          number, -- processing lead time, full_lead_time.
       --s_cto_rearch
       parent_repl_ord_flag   varchar2(1),
       parent_bom_item_type   number,
       parent_comp_flag       varchar2(1),
       parent_atp_flag        varchar2(1),
       parent_item_id         number,
       replenish_to_ord_flag  varchar2(1),
       bom_item_type          number,
       base_item_id           number,
       parent_pegging_id      number,
       --atf_date               date,   -- For time_phased_atp
       atf_days               number, -- For time_phased_atp
       product_family_id      number,  -- For time_phased_atp
       --bug 3917625: Store plan id as well
       plan_id                number,
       lowest_level_src       number   -- For ATP4drp
        );
       -- For Supplier Capacity and Lead Time (SCLT) changes.
       -- New fields introduced are processing_lt.
/* ship_rec_cal
TYPE Supplier_Info_rec IS RECORD(
      base_item_id   number,
      bom_item_type  number,
      rep_ord_flag   varchar2(1));*/

TYPE org_attribute_rec IS RECORD(
       instance_id            NUMBER,
       organization_id        NUMBER,
       default_atp_rule_id    NUMBER,
       cal_code               VARCHAR2(14),
       cal_exception_set_id   NUMBER,
       default_demand_class   VARCHAR2(34),
       org_code               VARCHAR2(7),
       org_type               NUMBER, --OPM fix bug 2865389 (ssurendr)
       network_scheduling_method     NUMBER, --bug3601223
       use_phantom_routings   NUMBER --4570421
     );
-- New record  plan_info_rec defined for bug 2392456
TYPE plan_info_rec IS RECORD(
        plan_id                 NUMBER,
        plan_name               VARCHAR2(10),
        assignment_set_id       NUMBER,
        plan_start_date         DATE,  -- for future use
        plan_cutoff_date        DATE,  -- for future use
        summary_flag            number,  -- 24x7 atp
        subst_flag              number, -- 24x7
        copy_plan_id            number,  -- 24x7 atp
        sr_instance_id          NUMBER,
        organization_id         NUMBER,  -- Owning organization for plan.
        curr_cutoff_date        DATE,
        optimized_plan          NUMBER,-- 1 for constrained plan, 2 else -- 2859130
        schedule_by_date_type   NUMBER,--for identifying request type
	enforce_pur_lead_time   NUMBER,	 -- Ship_Rec_Cal
	enforce_sup_capacity	NUMBER,	 -- Ship_Rec_Cal
        plan_type               NUMBER,   -- ATP4drp
        itf_horiz_days          NUMBER    -- ATP4drp
        );
-- Additional Fields for Supplier Capacity and Lead Time (SCLT) Project.
-- Additional Fields are sr_instance_id and organization_id and curr_cutoff_date.
-- Existing fields now used are plan_start_date and plan_cutoff_date.

/* changes for ship_rec_cal begin */
TYPE ship_arrival_date_rec_typ IS RECORD(
       scheduled_arrival_date	DATE,
        latest_acceptable_date	DATE,
	order_date_type		NUMBER,
	demand_id		NUMBER,
	instance_id		NUMBER,
	plan_id			NUMBER,
	ship_set_name		VARCHAR2(30),
	arrival_set_name	VARCHAR2(30),
	atp_override_flag	VARCHAR2(1),
	request_arrival_date	DATE
        );

G_SHIP_CAPACITY			CONSTANT INTEGER := 1;
G_DOCK_CAPACITY			CONSTANT INTEGER := 2;
G_USE_SHIP_REC_CAL              VARCHAR2(1) := NVL(FND_PROFILE.value('MSC_USE_SHIP_REC_CAL'),'N'); --Bug 3593394
/* changes for ship_rec_cal end */

-- global variables
G_ITEM_INFO_REC         item_attribute_rec;
G_ORG_INFO_REC          org_attribute_rec;

--3720018
G_REMOVE_REQUEST_LEVEL_REC  remove_request_level_rec;

-- global variable for plan introduced as a part of
-- Supplier Capacity Lead Time (SCLT)  project.
G_PLAN_INFO_REC         plan_info_rec;

G_FIND_FUTURE_DATE      VARCHAR2(1) := 'N';
G_PEGGING_FOR_SET       MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
G_DEMAND_CLASS_ATP_FLAG     MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
G_REQ_ATP_DATE	        MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
G_REQ_DATE_QTY          MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
G_INV_CTP               NUMBER := FND_PROFILE.value('INV_CTP') ;
G_SUB_COMP              VARCHAR2(1) := NVL(FND_PROFILE.value('MRP_ATP_SUB_COMP'), 'N');
G_ALLOCATED_ATP         VARCHAR2(1) := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
-- ATP4drp use original profile to restore value after DRP to non-DRP plan switch.
G_ORIG_ALLOC_ATP        VARCHAR2(1) := G_ALLOCATED_ATP;
-- End ATP4drp
G_RES_CONSUME           VARCHAR2(1) := 'Y';
G_ASSEMBLY_LINE_ID       NUMBER;
G_HIERARCHY_PROFILE     NUMBER := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);
G_PARTNER_ID            NUMBER;
G_PARTNER_SITE_ID       NUMBER;
G_SR_PARTY_SITE_ID      NUMBER;        --2814895
G_SR_CUSTOMER_COUNTRY   VARCHAR2(60);  --2814895
G_OPTIMIZED_PLAN        PLS_INTEGER := 2;
G_SESSION_ID            NUMBER;
G_ORDER_LINE_ID         NUMBER;
G_DEMAND_PEGGING_ID     NUMBER;
G_COMP_LINE_ID          NUMBER;
G_MOV_PAST_DUE_SYSDATE_PROF VARCHAR2(1) := NVL(FND_PROFILE.value('MSC_MOVE_PAST_DUE_TO_SYSDATE'), 'Y'); --6316476

-- dsting default to 3 (11i source) since we don't read msc_apps_instances for non-distributed case
G_APPS_VER              NUMBER := SOURCE11i; -- 2300767
G_SUMMARY_FLAG          VARCHAR2(1) := NVL(FND_PROFILE.VALUE('MSC_ENABLE_ATP_SUMMARY'), 'N');
G_SUMMARY_SQL           VARCHAR2(1); -- For summary enhancement

--optional_fw
G_OPTIONAL_FW              NUMBER := 1; --This global variable is Null for the first pass and not null for remain passes.
G_ATP_COMP_FLAG            VARCHAR2(1) := 'Y';
                                        --This variable @ first pass on top level.
G_REQUESTED_SHIP_DATE      DATE;        --User entered value
G_FW_PEGGING_ID            NUMBER;      --Points to the ATP supply line pegging added during subsequent passes.
G_FW_CTP_PEGGING_ID        MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
                                        --Points to the PO supply line pegging  added during subsequent passes.
G_FW_STEAL_PEGGING_ID      MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
                                        --Points to the Stealing line in forward pass.
G_FORWARD_ATP              VARCHAR2(1) := NVL(FND_PROFILE.value('MSC_ENHANCED_FORWARD_ATP'), 'N');
                                        --Profile to control which f/w pass we choose.
G_DEMAND_ID                NUMBER;      --5158454
G_NUMBER_OF_ITERATIONS     NUMBER;         --5211558
G_LOOP_COUNT               NUMBER; --5211558
-- Bug 2877340, 2746213
-- Create new global variable for Infinite Time Fence Pad
-- Workaround to match ASCP and ATP output.
-- Round the days in case user erroneously
-- sets fraction Number as profile calue. If user sets profile
-- value to be -ve,Consider it to be 0.
G_INF_SUP_TF_PAD        NUMBER := GREATEST(CEIL(NVL(FND_PROFILE.value('MSC_ATP_INFINITE_TF_PAD'),0)),0);
---diag_atp
G_DIAGNOSTIC_ATP        NUMBER;
G_SUBSTITUTION_FLAG     VARCHAR2(1);
G_PLAN_SUBST_FLAG       NUMBER;
G_HAVE_MAKE_BUY_PARENT	NUMBER := 0;
G_SUBST_GOOD_PEGGING	NUMBER;

BACKWARD_SCHEDULING     CONSTANT INTEGER := 1;
FORWARD_SCHEDULING      CONSTANT INTEGER := 2;
/************ Bug 1510853 ATP Rule Check ************/
G_ATP_RULE_FLAG         VARCHAR2(1); -- to capture the presence of a rule

-- savirine added global variables G_SR_PARTNER_SITE_ID on Aug 27, 2001
G_SR_PARTNER_SITE_ID  NUMBER;

-- ngoel 9/24/2001, added to identify if current line is MATO line
G_CTO_LINE  		VARCHAR2(1);
-- For bug 2259824, G_END_OF_DAY represents number of seconds in a day - 1.
--G_END_OF_DAY		NUMBER := 86399/86400; Bug 3343359 - changed to last minute of the day
G_END_OF_DAY		NUMBER := 1439/1440;
--- Enhance CTO Phase 1 Req #17
-- New global to deal with forward stealing for CTO components.
-- Used to store/track the Demand Pegging ID.
G_CTO_FORWARD_DMD_PEG   NUMBER;
-- For bug 2974324. Store the calling_module in global variable.
G_CALLING_MODULE	NUMBER;

G_INSTANCE_ID           NUMBER; -- this variable contains value of instance id
                                --with which call is made
--plan by request date
G_HP_DEMAND_BUCKETING_PREF    NUMBER := NVL(FND_PROFILE.VALUE('MSC_HP_DMD_BKT_PRF'), 1);
-- Action code
G_ZERO_ALLOCATION_PERC  VARCHAR2(1) := NVL(FND_PROFILE.value('MSC_ZERO_ALLOC_PERC'),'N');--6359986

ATPQUERY                CONSTANT INTEGER := 100;
DEMANDADD               CONSTANT INTEGER := 110;
DEMANDMODIFY            CONSTANT INTEGER := 120;
RSVADD                  CONSTANT INTEGER := 130;
RSVMODIFY               CONSTANT INTEGER := 140;
DMDRSVADD               CONSTANT INTEGER := 150;
DMDRSVXFER              CONSTANT INTEGER := 160;
FORCERSVADD             CONSTANT INTEGER := 170;

-- Existing error code
ALLSUCCESS              CONSTANT INTEGER := 0;
NOREQ_DATE              CONSTANT INTEGER := 20;

DEM_NOT_FOUND           CONSTANT INTEGER := 9;
GROUPEL_ERROR           CONSTANT INTEGER := 19;
DUPLICATE_DMD           CONSTANT INTEGER := 42;
ATP_NO_GROUP_DATE       CONSTANT INTEGER := 50;
ATP_NO_REQUESTS         CONSTANT INTEGER := 51;
ATP_REQ_QTY_FAIL        CONSTANT INTEGER := 52;
ATP_ACCEPT_FAIL         CONSTANT INTEGER := 53;
ATP_EXCEED_SIZE         CONSTANT INTEGER := 54;
ATP_NO_CALENDAR         CONSTANT INTEGER := 55;
ATP_MULTI_CALENDARS     CONSTANT INTEGER := 56;
ATP_BAD_RULE            CONSTANT INTEGER := 57;
ATP_REQ_QTY_FAIL_RES    CONSTANT INTEGER := 58;
ATP_REQ_QTY_FAIL_BOTH   CONSTANT INTEGER := 59;
BAD_EXPLOSION           CONSTANT INTEGER := 60;
ATP_NOT_APPL            CONSTANT INTEGER := 61;
ATP_SHORT_CAL           CONSTANT INTEGER := 62;
ATP_LEAD_TIME_FAIL      CONSTANT INTEGER := 63;

-- new error code we need to add
ATP_MULTI_REQ_DATES     CONSTANT INTEGER := 70;
ATP_NO_SOURCES          CONSTANT INTEGER := 80;
ATP_ITEM_NOT_COLLECTED   CONSTANT INTEGER := 85;
ATP_NO_ASSIGN_SET       CONSTANT INTEGER := 90;
ATP_REQ_DATE_FAIL       CONSTANT INTEGER := 100;
ATP_PASS_INFINITE_DATE  CONSTANT INTEGER := 110;
ATP_INVALID_DATE        CONSTANT INTEGER := 99;
PLAN_NOT_FOUND          CONSTANT INTEGER := 120;
TRY_ATP_LATER           CONSTANT INTEGER := 130;
NO_ASSIGNMENT_SET       CONSTANT INTEGER := 135;
NO_MATCHING_CAL_DATE    CONSTANT INTEGER := 47;
SUMM_CONC_PROG_RUNNING  CONSTANT INTEGER := 160;
-- 2152184
PF_MEMBER_ITEM_NOT_ATPABLE CONSTANT INTEGER := 180;
RUN_POST_PLAN_ALLOC     CONSTANT INTEGER := 200;
-- 1873918
PDS_TO_ODS_SWITCH       CONSTANT INTEGER := 150;

-- search

--Error Handling Changes krajan
ATP_INVALID_OBJECTS     CONSTANT INTEGER := 220;
ATP_PROCESSING_ERROR    CONSTANT INTEGER := 23;

---diag_atp
DIAGNOSTIC_ATP_ENABLED  CONSTANT INTEGER := 260;

-- 2368426 starts
INV_CTP_NOT_IN_SYNC     CONSTANT INTEGER := 230;
USE_SHIP_REC_NOT_IN_SYNC CONSTANT INTEGER := 231; --bug3593394
ASSIGN_SET_NOT_IN_SYNC     CONSTANT INTEGER := 240;
G_INV_CTP_SOURCE        NUMBER ;
G_SR_ASSIGN_SET         NUMBER ;
-- 2368426 ends

-- ATP Override rajjain begin
ATP_MULTI_OVERRIDE_DATES	CONSTANT INTEGER := 250;
ATP_OVERRIDE_DATE_FAIL		CONSTANT INTEGER := 251;
-- ATP Override rajjain end

-- rajjain 02/03/2003 Bug 2766713
INVALID_ITEM_ORG_COMBINATION	CONSTANT INTEGER := 270;

-- rajjain 02/20/2003 Bug 2813095
INVALID_ALLOC_PROFILE_SETUP     CONSTANT INTEGER := 280;
INVALID_INV_CTP_PROFILE_SETUP   CONSTANT INTEGER := 281;
INVALID_ALLOC_ATP_OFF           CONSTANT INTEGER := 282;

PLAN_DOWN_TIME                  CONSTANT INTEGER := 300;

MUTUALLY_EXCLUSIVE_OSS     CONSTANT NUMBER := 350;
OSS_ERROR_AT_LOWER_LEVEL   CONSTANT NUMBER := 360;
OSS_ERROR_AT_THIS_LEVEL    CONSTANT NUMBER := 370;
OSS_SOURCING_ERROR             CONSTANT NUMBER := 310;
ERROR_WHILE_MATCHING       CONSTANT NUMBER := 320;
INVALID_OSS_WAREHOUSE      CONSTANT NUMBER := 330;

CTO_OSS_ERROR              CONSTANT VARCHAR2(10) := 'CTO_Err';

-- rajjain bug 2951786 05/13/2003
NO_SUPPLY_DEMAND                CONSTANT INTEGER := 175;

DEPTH                   CONSTANT INTEGER := 1;
BREADTH                 CONSTANT INTEGER := 2;

-- source type
TRANSFER                CONSTANT INTEGER := 1;
MAKE                    CONSTANT INTEGER := 2;
BUY                     CONSTANT INTEGER := 3;

-- action for pegging
UNDO                    CONSTANT INTEGER := 1;
INVALID                 CONSTANT INTEGER := 2;

--4570421
DISCRETE_ORG            CONSTANT INTEGER := 1;
OPM_ORG                 CONSTANT INTEGER := 2;

-- 2400614: krajan:
-- Returned by ATP_Check.
-- Indicates a source mismatch
G_ATO_SRC_MISMATCH      VARCHAR2(1) := 'G';
G_ATO_UNCOLL_ITEM       VARCHAR2(1) := 'A'; -- krajan 2752705
G_NO_PLAN_FOUND         VARCHAR2(1) := 'P'; -- dsting 2764213


--- bug 1905037. The following variable is added so
--- we can return the inventory_item_id which is not collected
--- to schedule procedure
G_SR_INVENTORY_ITEM_ID number;
G_PLAN_COPRODUCTS VARCHAR(1) := FND_Profile.value('MSC_PLAN_COPRODUCTS');
G_DATABASE_LINK          VARCHAR2(128);
--bug 2178544
--G_PTF_FLAG               NUMBER; -- This flag indicates that plan is constrained by PTF or not
G_MSO_LEAD_TIME_FACTOR  NUMBER := NVL(FND_PROFILE.value('MSO_SCO_LEAD_TIME_FACTOR'),0);
G_FUTURE_ORDER_DATE     DATE;
G_FUTURE_START_DATE     DATE;
G_PTF_DATE              DATE;
G_PTF_DATE_THIS_LEVEL   DATE;
G_ALLOCATION_METHOD     NUMBER := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'), 2);
G_FUTURE_PEGGING_ID     NUMBER;

G_REFRESH_NUMBER        NUMBER;
--G_CREATE_TIME_FENCE     VARCHAR(1) := NVL(FND_Profile.value('MRP_FIRM_ORDER_TF'),'N');

-- krajan: 2408902
-- Variable to store Demand Class passed in for ATO models.
G_ATP_DEMAND_CLASS      VARCHAR2(34);

-- krajan: 2408696
-- Variable to store Phantom Profile option value
G_EXPLODE_PHANTOM         VARCHAR(1) := NVL(FND_Profile.value('MSC_ENABLE_PHANT_COMP'), 'N');

-- 24x7 Support : Synchronization in progress flag
G_SYNC_ATP_CHECK        VARCHAR2(1);
--Set in case msc_item_id_lid has no records 4091487
G_ITEM_ID_NULL          VARCHAR2(1) := 'F';
--Set in case item is not collected 4091487
G_ITEM_NOT_COLL          VARCHAR2(1) := 'C';

-- Set if we ever encounter downtime
G_DOWNTIME_HIT          VARCHAR2(1);

---- Exceptions
NO_MATCHING_DATE_IN_CAL  Exception;
/************ Bug 1510853 ATP Rule Check ************/
EXC_NO_ATP_RULE          Exception;

-- Bug 2400614: krajan
G_ATO_SOURCING_MISMATCH Exception;

-- dsting 2764213
EXC_NO_PLAN_FOUND       Exception;

-- krajan : 2752705
G_EXC_UNCOLLECTED_ITEM Exception;

-- rajjain 02/20/2002 Bug 2813095
ALLOC_ATP_INVALID_PROFILE Exception;

--s_cto_rearch
INVALID_OSS_SOURCE Exception;

--diag_atp
G_ALLOCATION_RULE_NAME VARCHAR2(30);
ORG_DEMAND             CONSTANT NUMBER := 1;
SUPPLIER_DEMAND        CONSTANT NUMBER := 2;
ATP_SUPPLY             CONSTANT NUMBER := 3;
MAKE_SUPPLY            CONSTANT NUMBER := 4;
BUY_SUPPLY             CONSTANT NUMBER := 5;
TRANSFER_SUPPLY        CONSTANT NUMBER := 6;
ATP_SUPPLIER           CONSTANT NUMBER := 7;
RESOURCE_DEMAND        CONSTANT NUMBER := 8;
RESOURCE_SUPPLY        CONSTANT NUMBER := 9;

-- For summary enhancement
G_COPY_DEMAND_ID        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
G_COPY_DEMAND_PLAN_ID   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
--Global Variable Defined at this level just to avoid hardcoding for
--enhancment for Plan by request Date
G_SCHEDULE_SHIP_DATE_LEGEND  	CONSTANT  NUMBER :=1;
G_SCHEDULE_ARRIVAL_DATE_LEGEND  CONSTANT  NUMBER :=2;
G_REQUEST_SHIP_DATE_LEGEND      CONSTANT  NUMBER :=3;
G_REQUEST_ARRIVAL_DATE_LEGEND   CONSTANT  NUMBER :=4;
G_PROMISE_SHIP_DATE_LEGEND      CONSTANT  NUMBER :=5;
G_PROMISE_ARRIVAL_DATE_LEGEND   CONSTANT  NUMBER :=6;

-- For new allocation logic for time_phased_atp
G_MEM_RULE_WITHIN_ATF           VARCHAR2(1);
G_PF_RULE_OUTSIDE_ATF           VARCHAR2(1);

-- To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
G_TIME_PHASED_PF_ENABLED        VARCHAR2(1);
-- CTO_PF_PRJ changes for CTO PF Cross Project Impacts
G_CTO_PF_ATP                    VARCHAR2(1);

--4279623 4333596
YES                     CONSTANT NUMBER := 1;
NO                      CONSTANT NUMBER := 2;
CHECK_ORG_IN_PLAN    	CONSTANT NUMBER := 3;
--4279623 4333596
G_ATP_CHECK_ISO					NUMBER := NVL(FND_PROFILE.VALUE('MSC_ATP_CHECK_INT_SALES_ORDERS'),NO); --6485306

--bug 4358596
G_RETAIN_TIME_NON_ATP    VARCHAR(1) := NVL(FND_Profile.value('MSC_RETAIN_TIME_NON_ATP_ITEM'), 'Y');
G_ATP_ITEM_PRESENT_IN_SET VARCHAR(1) :='N'; --4460369



PROCEDURE Schedule (
               p_atp_table          IN    MRP_ATP_PUB.ATP_Rec_Typ,
               p_instance_id	    IN 	  NUMBER,
               p_assign_set_id      IN    NUMBER,
               p_refresh_number     IN    NUMBER,
               x_atp_table          OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
               x_return_status      OUT   NoCopy VARCHAR2,
               x_msg_data           OUT   NoCopy VARCHAR2,
               x_msg_count          OUT   NoCopy NUMBER,
	       x_atp_supply_demand  OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period         OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
               x_atp_details        OUT NOCOPY MRP_ATP_PUB.ATP_Details_Typ
);

PROCEDURE ATP_Check (p_atp_record    		IN OUT   NoCopy MRP_ATP_PVT.AtpRec,
               p_plan_id             		IN       NUMBER,
               p_level	             		IN       NUMBER,
               p_scenario_id	     		IN       NUMBER,
               p_search              		IN       NUMBER,
               p_refresh_number      		IN       NUMBER,
	       p_parent_pegging_id   		IN       NUMBER,
               p_assign_set_id       		IN       NUMBER,
               x_atp_period          		OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
               x_atp_supply_demand   		OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_return_status       		OUT      NoCopy VARCHAR2,
               p_pre_processing_lead_time	IN       NUMBER :=0
);


PROCEDURE Call_Schedule (
               p_session_id             IN    NUMBER,
               p_atp_table              IN    MRP_ATP_PUB.ATP_Rec_Typ,
               p_instance_id        	IN    NUMBER,
               p_assign_set_id          IN    NUMBER,
               p_refresh_number         IN    NUMBER,
               x_atp_table          	OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
               x_return_status      	OUT   NoCopy VARCHAR2,
               x_msg_data           	OUT   NoCopy VARCHAR2,
               x_msg_count          	OUT   NoCopy NUMBER,
               x_atp_supply_demand  	OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period         	OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
               x_atp_details        	OUT NOCOPY MRP_ATP_PUB.ATP_Details_Typ
);

-- p_inv_ctp added in argument of call_schedule_remote
-- for bug 2368426 to match source and destination INV_CTP

--bug3940999 commenting the agruments for passing profiles
PROCEDURE Call_Schedule_Remote (
               p_session_id         IN    NUMBER,
               p_instance_id        IN    NUMBER,
               p_assign_set_id      IN    NUMBER,
               p_refresh_number     IN    NUMBER,
--               p_inv_ctp            IN    NUMBER := -1,                     --bug3940999
               p_def_assign_set_id  IN    NUMBER := -1,
               -- We are passing debug mode as parameter so that debug could be set as soon as we enter procedure.
               p_atp_debug_flag     IN    VARCHAR2 := NULL,
               --ATP Debug Workflow
               x_session_loc_des    OUT NOCOPY  VARCHAR2,
               x_spid_des           OUT NOCOPY  NUMBER,
               x_trace_loc_des      OUT NOCOPY  VARCHAR2,
--               p_atp_workflow       IN    VARCHAR2 := NULL,                 --bug3940999
               p_node_id            IN    NUMBER DEFAULT null  --bug3520746
--               p_use_ship_rec       IN    VARCHAR2 DEFAULT 'N' --bug3593394 --bug3940999
);

PROCEDURE Process_Time_Stamp_Errors (l_atp_table  IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
                                     i NUMBER);--4460369

--optional_fw
/*--GET_SEQ_NUM-------------------------------------------------
|  o  This procedure is called from Schedule to return the seq
|       number for the passed date. (Used in binary search algo)
+---------------------------------------------------------------*/
FUNCTION GET_SEQ_NUM (p_calendar_date           IN DATE,
                      p_calendar_code           IN VARCHAR2,
                      p_instance_id		IN number
                      )  RETURN NUMBER;

/*--GET_DATE_FROM_SEQNUM-----------------------------------------
|  o  This procedure is called from Schedule to return the date
|        for the passed seq number. (Used in binary search algo)
+---------------------------------------------------------------*/

FUNCTION GET_DATE_FROM_SEQNUM (p_seq_num        IN NUMBER,
                      p_calendar_code           IN VARCHAR2,
                      p_instance_id		IN number
                      )  RETURN DATE;
END MSC_ATP_PVT;

/
