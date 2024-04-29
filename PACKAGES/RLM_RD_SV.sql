--------------------------------------------------------
--  DDL for Package RLM_RD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_RD_SV" AUTHID CURRENT_USER as
/*$Header: RLMDPRDS.pls 120.2.12010000.2 2008/07/30 12:51:01 sunilku ship $*/
--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>

/*===========================================================================
  PACKAGE NAME: 	RLM_RD_SV

  DESCRIPTION:		Contains the server side code for reconcile demand API
                        of RLA Demand Processor.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		abkulkar

  PROCEDURE/FUNCTIONS:

  GLOBALS:

=========================================================================== */


  TYPE t_Cursor_ref IS REF CURSOR;

  TYPE t_Generic_rec IS RECORD(
    customer_id               NUMBER,
    customer_item_id          NUMBER,
    inventory_item_id         NUMBER,
    header_id                 NUMBER,
    line_id                   NUMBER,
    -- we need these 2 columns to pass to OE the scheduleheader and line details
    schedule_header_id        NUMBER,
    schedule_line_id          NUMBER,
    bill_to_address_id        NUMBER,
    intmed_ship_to_org_id     NUMBER,
    intrmd_ship_to_id         NUMBER,
    invoice_to_org_id         NUMBER,
    operation                 VARCHAR2(30),
    order_header_id           NUMBER,
    ordered_quantity          NUMBER,
    shipped_quantity          NUMBER,
    primary_quantity          rlm_interface_lines.primary_quantity%TYPE,
    schedule_item_number      NUMBER,
    ship_from_org_id          rlm_interface_lines.ship_from_org_id%TYPE,
    ship_to_address_id        NUMBER,
    ship_to_org_id            NUMBER,
    schedule_type             rlm_interface_headers.schedule_type%TYPE,
    price_list_id             rlm_interface_lines.price_list_id%TYPE,
    agreement_id              rlm_interface_lines.agreement_id%TYPE,
    item_detail_type          rlm_interface_lines.item_detail_type%TYPE,
    item_detail_subtype       rlm_interface_lines.item_detail_subtype%TYPE,
    supplier_item_ext         rlm_interface_lines.supplier_item_ext%TYPE,
    customer_item_ext         rlm_interface_lines.customer_item_ext%TYPE,
    delivery_lead_time        rlm_interface_lines.delivery_lead_time%TYPE,
    cust_po_number            rlm_interface_lines.cust_po_number%TYPE,
    customer_item_revision    rlm_interface_lines.customer_item_revision%TYPE,
    customer_dock_code        rlm_interface_lines.customer_dock_code%TYPE,
    customer_job              rlm_interface_lines.customer_job%TYPE,
    cust_production_line      rlm_interface_lines.cust_production_line%TYPE,
    cust_model_serial_number  rlm_interface_lines.cust_model_serial_number%TYPE,
    cust_production_seq_num   rlm_interface_lines.cust_production_seq_num%TYPE,
    industry_attribute1       rlm_interface_lines.industry_attribute1%TYPE,
    industry_attribute2       rlm_interface_lines.industry_attribute2%TYPE,
    industry_attribute3       rlm_interface_lines.industry_attribute3%TYPE,
    industry_attribute4       rlm_interface_lines.industry_attribute4%TYPE,
    industry_attribute5       rlm_interface_lines.industry_attribute5%TYPE,
    industry_attribute6       rlm_interface_lines.industry_attribute6%TYPE,
    industry_attribute7       rlm_interface_lines.industry_attribute7%TYPE,
    industry_attribute8       rlm_interface_lines.industry_attribute8%TYPE,
    industry_attribute9       rlm_interface_lines.industry_attribute9%TYPE,
    industry_attribute10      rlm_interface_lines.industry_attribute10%TYPE,
    industry_attribute11      rlm_interface_lines.industry_attribute11%TYPE,
    industry_attribute12      rlm_interface_lines.industry_attribute12%TYPE,
    industry_attribute13      rlm_interface_lines.industry_attribute13%TYPE,
    industry_attribute14      rlm_interface_lines.industry_attribute14%TYPE,
    industry_attribute15      rlm_interface_lines.industry_attribute15%TYPE,
    industry_context            rlm_interface_lines.industry_context%TYPE,
    attribute1                rlm_interface_lines.attribute1%TYPE,
    attribute2                rlm_interface_lines.attribute2%TYPE,
    attribute3                rlm_interface_lines.attribute3%TYPE,
    attribute4                rlm_interface_lines.attribute4%TYPE,
    attribute5                rlm_interface_lines.attribute5%TYPE,
    attribute6                rlm_interface_lines.attribute6%TYPE,
    attribute7                rlm_interface_lines.attribute7%TYPE,
    attribute8                rlm_interface_lines.attribute8%TYPE,
    attribute9                rlm_interface_lines.attribute9%TYPE,
    attribute10               rlm_interface_lines.attribute10%TYPE,
    attribute11               rlm_interface_lines.attribute11%TYPE,
    attribute12               rlm_interface_lines.attribute12%TYPE,
    attribute13               rlm_interface_lines.attribute13%TYPE,
    attribute14               rlm_interface_lines.attribute14%TYPE,
    attribute15               rlm_interface_lines.attribute15%TYPE,
    attribute_category        rlm_interface_lines.attribute_category%TYPE,
    tp_attribute1             rlm_interface_lines.tp_attribute1%TYPE,
    tp_attribute2             rlm_interface_lines.tp_attribute2%TYPE,
    tp_attribute3             rlm_interface_lines.tp_attribute3%TYPE,
    tp_attribute4             rlm_interface_lines.tp_attribute4%TYPE,
    tp_attribute5             rlm_interface_lines.tp_attribute5%TYPE,
    tp_attribute6             rlm_interface_lines.tp_attribute6%TYPE,
    tp_attribute7             rlm_interface_lines.tp_attribute7%TYPE,
    tp_attribute8             rlm_interface_lines.tp_attribute8%TYPE,
    tp_attribute9             rlm_interface_lines.tp_attribute9%TYPE,
    tp_attribute10            rlm_interface_lines.tp_attribute10%TYPE,
    tp_attribute11            rlm_interface_lines.tp_attribute11%TYPE,
    tp_attribute12            rlm_interface_lines.tp_attribute12%TYPE,
    tp_attribute13            rlm_interface_lines.tp_attribute13%TYPE,
    tp_attribute14            rlm_interface_lines.tp_attribute14%TYPE,
    tp_attribute15            rlm_interface_lines.tp_attribute15%TYPE,
    tp_attribute_category     rlm_interface_lines.tp_attribute_category%TYPE,
    request_date              rlm_interface_lines.request_date%TYPE,
    schedule_date             rlm_interface_lines.schedule_date%TYPE,
    uom_code                  rlm_interface_lines.uom_code%TYPE,
    authorized_to_ship_flag   oe_order_lines.authorized_to_ship_flag%TYPE,
    shipment_flag             VARCHAR2(30),
    item_identifier_type      VARCHAR2(25),
    process_status            rlm_interface_lines.process_status%TYPE,
    cust_po_line_num          rlm_interface_lines.cust_po_line_num%TYPE,
    blanket_number	      rlm_interface_lines.blanket_number%TYPE
  );

  TYPE t_consume_rec IS RECORD( line_id     NUMBER,
                                quantity    NUMBER);

  TYPE t_consume_tab IS TABLE OF t_consume_rec
    INDEX BY BINARY_INTEGER;

  TYPE t_matching_line IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  TYPE t_Generic_tab IS TABLE OF t_Generic_rec
    INDEX BY BINARY_INTEGER;

  TYPE t_Qty_rec IS RECORD(
    available_to_cancel   NUMBER,
    unshipped             NUMBER,
    reconcile             NUMBER,
    shipped               NUMBER,
    picked                NUMBER,
    backordered           NUMBER,
    ordered               NUMBER
  );

  TYPE t_Key_rec IS RECORD(
    oe_line_id            NUMBER,
    rlm_line_id           NUMBER,
    req_rec               t_Generic_rec,
    dem_rec               t_Generic_rec
  );

  TYPE t_Ship_rec IS RECORD (         --Bugfix 7007638
    customer_id               NUMBER,
    customer_item_id          NUMBER,
    inventory_item_id         NUMBER,
    ship_from_org_id          NUMBER,
    intrmd_ship_to_address_id NUMBER,
    ship_to_address_id        NUMBER,
    bill_to_address_id        NUMBER,
    purchase_order_number     rlm_interface_lines.cust_po_number%TYPE,
    primary_quantity          NUMBER,
    item_detail_quantity      NUMBER,
    start_date_time           DATE,
    cust_record_year          rlm_interface_lines.industry_attribute1%TYPE,
    line_id                   NUMBER
  );

  TYPE t_Ship_tab IS TABLE OF t_Ship_rec INDEX BY BINARY_INTEGER;  --Bugfix 7007638

  k_ORIGINAL            CONSTANT VARCHAR2(30) := 'ORIGINAL';
  k_REPLACE             CONSTANT VARCHAR2(30) := 'REPLACE';
  k_REPLACE_ALL         CONSTANT VARCHAR2(30) := 'REPLACE_ALL';
  k_CHANGE              CONSTANT VARCHAR2(30) := 'CHANGE';
  k_CANCEL              CONSTANT VARCHAR2(30) := 'CANCELLATION';
  k_DELETE              CONSTANT VARCHAR2(30) := 'DELETE';
  k_INSERT              CONSTANT VARCHAR2(30) := 'INSERT';
  k_UPDATE              CONSTANT VARCHAR2(30) := 'UPDATE';
  k_UPDATE_ATTR         CONSTANT VARCHAR2(30) := 'UPDATE_ATTR';
  k_CONFIRMATION        CONSTANT VARCHAR2(30) := 'CONFIRMATION';
  k_ADD                 CONSTANT VARCHAR2(30) := 'ADD';
  k_REMAIN_ON_FILE      CONSTANT VARCHAR2(80) := 'REMAIN_ON_FILE';
 -- Bug# 4223359
  k_REMAIN_ON_FILE_RECONCILE  CONSTANT VARCHAR2(80) := 'REMAIN_ON_FILE_RECONCILE';
  --
  k_CANCEL_ALL          CONSTANT VARCHAR2(80) := 'CANCEL_ALL';
  k_CANCEL_AFTER_N_DAYS CONSTANT VARCHAR2(80) := 'CANCEL_AFTER_N_DAYS';
  k_RECEIPT             CONSTANT VARCHAR2(80) := 'RECEIPT';
  k_SHIPMENT            CONSTANT VARCHAR2(80) := 'SHIPMENT';
  k_ACTUAL              CONSTANT VARCHAR2(80) := 'ACTUAL';
  k_PLANNING            CONSTANT VARCHAR2(30) := 'PLANNING_RELEASE';
  k_SHIPPING            CONSTANT VARCHAR2(30) := 'SHIPPING';
  k_SEQUENCED           CONSTANT VARCHAR2(30) := 'SEQUENCED';
  k_RECONCILE           CONSTANT BOOLEAN := TRUE;
  k_NORECONCILE         CONSTANT BOOLEAN := FALSE;
  k_TDEBUG              CONSTANT NUMBER := rlm_CORE_SV.C_LEVEL10;
  k_SDEBUG              CONSTANT NUMBER := rlm_CORE_SV.C_LEVEL11;
  k_DEBUG               CONSTANT NUMBER := rlm_CORE_SV.C_LEVEL12;
  k_VNULL               CONSTANT VARCHAR2(25) := 'THIS_IS_A_NULL_VALUE';
  k_NNULL               CONSTANT NUMBER := -19999999999;
  k_DNULL               CONSTANT DATE := to_date('01/01/1930','dd/mm/yyyy');
  k_ATS                 CONSTANT VARCHAR2(1) := 'Y';
  k_NATS                CONSTANT VARCHAR2(1) := 'N';
  k_PAST_DUE_FIRM       CONSTANT VARCHAR2(1) := '0';
  k_FIRM                CONSTANT VARCHAR2(1) := '1';
  k_FORECAST            CONSTANT VARCHAR2(1) := '2';
  -- Bug# 1291145
  k_MRP_FORECAST	CONSTANT VARCHAR2(1) := '6';
  --
  k_RECT                CONSTANT VARCHAR2(1) := '4';
  k_AUTH                CONSTANT VARCHAR2(1) := '3';
  k_Weekly              CONSTANT VARCHAR2(1) := '2';
  k_Quarterly           CONSTANT VARCHAR2(1) :='5';
  k_Monthly             CONSTANT VARCHAR2(1) :='3';
  k_Daily               CONSTANT VARCHAR2(1) := '1';
  k_Flexible            CONSTANT VARCHAR2(1) := '4';
  -- Bug# 2124495
  k_NONE		CONSTANT VARCHAR2(80):= 'NONE';
  --
  g_Reconcile_tab        t_Generic_tab;
  g_Op_tab               t_Generic_tab;
  --global_atp
  g_Op_tab_Unschedule    t_Generic_tab;
  g_Accounted_tab        t_Generic_tab;
  --
  e_group_error          EXCEPTION;

  --global_atp
  g_ATP                  NUMBER;
  k_ATP                  CONSTANT NUMBER := 1;
  k_NON_ATP              CONSTANT NUMBER := 0;

  -- Bug 2729086
  k_LARGE                CONSTANT NUMBER := 9999;
  --
  -- For bug 2124495
  TYPE t_intransit_rec IS RECORD(
    cust_production_line            VARCHAR2(50),
    customer_dock_code              VARCHAR2(50),
    request_date                    DATE,
    schedule_date                   DATE,
    cust_po_number                  VARCHAR2(50),
    customer_item_revision          VARCHAR2(3),
    customer_job                    VARCHAR2(50),
    cust_model_serial_number        VARCHAR2(35),
    cust_production_seq_num         VARCHAR2(35),
    industry_attribute1             VARCHAR2(150),
    industry_attribute2             VARCHAR2(150),
    industry_attribute3             VARCHAR2(150),
    industry_attribute4             VARCHAR2(150),
    industry_attribute5             VARCHAR2(150),
    industry_attribute6             VARCHAR2(150),
    industry_attribute7             VARCHAR2(150),
    industry_attribute8             VARCHAR2(150),
    industry_attribute9             VARCHAR2(150),
    industry_attribute10            VARCHAR2(150),
    industry_attribute11            VARCHAR2(150),
    industry_attribute12            VARCHAR2(150),
    industry_attribute13            VARCHAR2(150),
    industry_attribute14            VARCHAR2(150),
    industry_attribute15            VARCHAR2(150),
    attribute1                      VARCHAR2(150),
    attribute2                      VARCHAR2(150),
    attribute3                      VARCHAR2(150),
    attribute4                      VARCHAR2(150),
    attribute5                      VARCHAR2(150),
    attribute6                      VARCHAR2(150),
    attribute7                      VARCHAR2(150),
    attribute8                      VARCHAR2(150),
    attribute9                      VARCHAR2(150),
    attribute10                     VARCHAR2(150),
    attribute11                     VARCHAR2(150),
    attribute12                     VARCHAR2(150),
    attribute13                     VARCHAR2(150),
    attribute14                     VARCHAR2(150),
    attribute15                     VARCHAR2(150),
    intransit_qty		    NUMBER
  );

  TYPE t_Intransit_Tab IS TABLE OF t_Intransit_Rec
    INDEX BY BINARY_INTEGER;

  g_IntransitTab	t_Intransit_Tab;
  -- 2124495

  TYPE t_Line_Match_Typ IS RECORD(
    sum_qty             NUMBER,
    match_count         NUMBER,
    lowest_oelineid     NUMBER
  );

  TYPE t_Line_Match_Tab IS TABLE OF t_Line_Match_Typ
    INDEX BY BINARY_INTEGER;

  --
  -- Tables to hold bind variable values
  --
  g_GetDemandTab	RLM_CORE_SV.t_dynamic_tab;
  g_InitDemandTab	RLM_CORE_SV.t_dynamic_tab;
  g_NewDemandTab  	RLM_CORE_SV.t_dynamic_tab;
  g_WhereTab1		RLM_CORE_SV.t_dynamic_tab;
  g_WhereTab2		RLM_CORE_SV.t_dynamic_tab;
  g_BindVarTab		RLM_CORE_SV.t_dynamic_tab;
  --
  -- Bug 3666834 : To indicate that intransit calc. are done for a blanket
  g_BlktIntransits  BOOLEAN := FALSE;
  --
  -- Bug4206823
  g_IsFirm         BOOLEAN := FALSE;
  g_max_rso_hdr_id NUMBER;
  --
  g_SourceTab       RLM_MANAGE_DEMAND_SV.t_Source_Tab;
  g_IntransitQty    NUMBER := FND_API.G_MISS_NUM;
  --
  g_RecCUM_rec      RLM_RD_SV.t_Ship_rec;  --Bugfix 7007638
  g_RecCUM_tab      RLM_RD_SV.t_Ship_tab;  --Bugfix 7007638
  --
  -- Bug 3733520 : Record structure used in ProcessOld() to capture sales
  -- order line attributes
  --
  TYPE t_OEDemand_rec IS RECORD (
  header_id		    NUMBER,
  line_id	            NUMBER,
  ship_from_org_id          oe_order_lines.ship_from_org_id%TYPE,
  ship_to_org_id            oe_order_lines.ship_to_org_id%TYPE,
  ordered_item_id           oe_order_lines.ordered_item_id%TYPE,
  inventory_item_id         oe_order_lines.inventory_item_id%TYPE,
  invoice_to_org_id         oe_order_lines.invoice_to_org_id%TYPE,
  intmed_ship_to_org_id     oe_order_lines.intmed_ship_to_org_id%TYPE,
  demand_bucket_type_code   oe_order_lines.demand_bucket_type_code%TYPE,
  rla_schedule_type_code    oe_order_lines.rla_schedule_type_code%TYPE,
  authorized_to_ship_flag   oe_order_lines.authorized_to_ship_flag%TYPE,
  orig_ordered_quantity     oe_order_lines.ordered_quantity%TYPE,
  ordered_quantity          oe_order_lines.ordered_quantity%TYPE,
  ordered_item              oe_order_lines.ordered_item%TYPE,
  item_identifier_type      oe_order_lines.item_identifier_type%TYPE,
  item_type_code            oe_order_lines.item_type_code%TYPE,
  blanket_number            oe_order_lines.blanket_number%TYPE,
  customer_line_number      oe_order_lines.customer_line_number%TYPE,
  cust_production_line      oe_order_lines.customer_production_line%TYPE,
  customer_dock_code        oe_order_lines.customer_dock_code%TYPE,
  request_date              oe_order_lines.request_date%TYPE,
  schedule_ship_date        oe_order_lines.schedule_ship_date%TYPE,
  cust_po_number            oe_order_lines.cust_po_number%TYPE,
  customer_item_revision    oe_order_lines.item_revision%TYPE,
  customer_job              oe_order_lines.customer_job%TYPE,
  cust_model_serial_number  oe_order_lines.cust_model_serial_number%TYPE,
  cust_production_seq_num   oe_order_lines.cust_production_seq_num%TYPE,
  industry_attribute1       oe_order_lines.industry_attribute1%TYPE,
  industry_attribute2       oe_order_lines.industry_attribute2%TYPE,
  industry_attribute3       oe_order_lines.industry_attribute3%TYPE,
  industry_attribute4       oe_order_lines.industry_attribute4%TYPE,
  industry_attribute5       oe_order_lines.industry_attribute5%TYPE,
  industry_attribute6       oe_order_lines.industry_attribute6%TYPE,
  industry_attribute7       oe_order_lines.industry_attribute7%TYPE,
  industry_attribute8       oe_order_lines.industry_attribute8%TYPE,
  industry_attribute9       oe_order_lines.industry_attribute9%TYPE,
  industry_attribute10      oe_order_lines.industry_attribute10%TYPE,
  industry_attribute11      oe_order_lines.industry_attribute11%TYPE,
  industry_attribute12      oe_order_lines.industry_attribute12%TYPE,
  industry_attribute13      oe_order_lines.industry_attribute13%TYPE,
  industry_attribute14      oe_order_lines.industry_attribute14%TYPE,
  industry_attribute15      oe_order_lines.industry_attribute15%TYPE,
  attribute1                oe_order_lines.attribute1%TYPE,
  attribute2                oe_order_lines.attribute2%TYPE,
  attribute3                oe_order_lines.attribute3%TYPE,
  attribute4                oe_order_lines.attribute4%TYPE,
  attribute5                oe_order_lines.attribute5%TYPE,
  attribute6                oe_order_lines.attribute6%TYPE,
  attribute7                oe_order_lines.attribute7%TYPE,
  attribute8                oe_order_lines.attribute8%TYPE,
  attribute9                oe_order_lines.attribute9%TYPE,
  attribute10               oe_order_lines.attribute10%TYPE,
  attribute11               oe_order_lines.attribute11%TYPE,
  attribute12               oe_order_lines.attribute12%TYPE,
  attribute13               oe_order_lines.attribute13%TYPE,
  attribute14               oe_order_lines.attribute14%TYPE,
  attribute15               oe_order_lines.attribute15%TYPE,
  end_date_time             oe_order_lines.request_date%TYPE,
  schedule_hierarchy        VARCHAR2(30)
  );

  -- Bug 4351397
  g_order_rec      t_OEDemand_rec;

/*===========================================================================

  PROCEDURE NAME:	RecDemand

  DESCRIPTION:	        Cover function for Reconcile Demand API

  PARAMETERS:	        x_InterfaceHeaderId IN NUMBER

  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/05/99
===========================================================================*/
PROCEDURE RecDemand(x_InterfaceHeaderId IN NUMBER,
                    x_Sched_rec         IN RLM_INTERFACE_HEADERS%ROWTYPE,
                    x_Group_rec         IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                    x_ReturnStatus      OUT NOCOPY NUMBER);

/*============================================================================

  PROCEDURE NAME:       RecGroupDemand

 ============================================================================*/

PROCEDURE RecGroupDemand(x_Sched_rec     IN     RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec     IN OUT NOCOPY rlm_dp_sv.t_Group_rec);


/*===========================================================================
  PROCEDURE NAME:	CallSetups

  DESCRIPTION:	        This procedure calls rla setups to populate group
                        record with setup informations.

  PARAMETERS:	        x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		        x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/11/99
===========================================================================*/
Procedure CallSetups(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);


/*===========================================================================
  PROCEDURE NAME:	ExecOperations

  DESCRIPTION:	This procedure calls process order api using the global
		operations table loaded in reconcile demand.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure ExecOperations(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);


/*===========================================================================
  PROCEDURE NAME:	CancelPreHorizonNATS

  DESCRIPTION:	This procedure cancels prehorizon demand which are not authorized
		to ship for the current schedule item

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure CancelPreHorizonNATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);


/*===========================================================================
  PROCEDURE NAME:	SynchronizeShipments

  DESCRIPTION:	This procedure fetches information  about supplier shipments
		which took place after the last customer recognized shipment
		to ship for the current schedule item

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure SynchronizeShipments(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	ProcessPreHorizonATS

  DESCRIPTION:	This procedure processes pre-horizon firm demand.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure ProcessPreHorizonATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	ProcessNATS

  DESCRIPTION:	This procedure will process incoming requirements which are
		not authorized to ship.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure ProcessNATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                      x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	ProcessATS

  DESCRIPTION:	This procedure will process incoming firm requirements

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure ProcessATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  FUNCTION NAME:	ProcessConstraint

  DESCRIPTION:	This function will check for processing constraints within
		OE.

  PARAMETERS:	x_Key_rec IN t_Key_rec
                x_Qty_rec OUT NOCOPY t_Qty_rec
		x_Operation IN VARCHAR2
		x_OperationQty IN NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
FUNCTION ProcessConstraint(x_Key_rec IN RLM_RD_SV.t_Key_rec,
                           x_Qty_rec OUT NOCOPY t_Qty_rec,
                           x_Operation IN VARCHAR2,
                           x_OperationQty IN NUMBER :=0)
                           RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	GetQtyRec

  DESCRIPTION:	This procedure will retrieve quantity states for a line in OE.

  PARAMETERS:	x_Key_rec IN t_Key_rec
		x_QtyRec OUT NOCOPY t_Qty_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure GetQtyRec(x_Key_rec IN RLM_RD_SV.t_Key_rec,
		    x_Qty_rec OUT NOCOPY t_Qty_rec);


/*===========================================================================
  PROCEDURE NAME:	GetReq

  DESCRIPTION:	This procedure will retrieve Requirement attributes from
		rlm_interface_lines.

  PARAMETERS:	x_Key_rec IN OUT NOCOPY t_Key_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure GetReq(x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec);


/*===========================================================================
  PROCEDURE NAME:	DeleteRequirement

  DESCRIPTION:	This procedure will delete the passed requirement

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN OUT NOCOPY t_Key_rec
		x_Reconcile IN BOOLEAN
		x_DeleteQty OUT NOCOPY NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure DeleteRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                            x_Reconcile IN BOOLEAN,
                            x_DeleteQty OUT NOCOPY NUMBER);



/*===========================================================================
  PROCEDURE NAME:	UpdateRequirement

  DESCRIPTION:	This procedure will update the passed demand

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN t_Key_rec
		x_Quantity IN NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure UpdateRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                            x_Quantity IN NUMBER);



/*===========================================================================
  PROCEDURE NAME:	InsertRequirement

  DESCRIPTION:	This procedure will insert the passed requirement

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN t_Key_rec
		x_Quantity IN NUMBER
		x_Reconcile IN BOOLEAN

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure InsertRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                            x_Reconcile IN BOOLEAN,
                            x_Quantity IN OUT NOCOPY NUMBER);
--<TPA_PUBLIC_NAME>



/*===========================================================================
  PROCEDURE NAME:	UpdateDemand

  DESCRIPTION:	This procedure will update demand for the passed requirement

  PARAMETERS:	x_Sched_rec IN t_Sched_type
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN t_Key_rec
		x_SumOrderedQty IN NUMBER
                x_Demand_type IN VARCHAR2

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure UpdateDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
		       x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                       x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
		       x_SumOrderedQty IN NUMBER,
                       x_DemandType IN VARCHAR2);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	IncreaseDemand

  DESCRIPTION:	This procedure will increase demand for the passed requirement

  PARAMETERS:	x_Sched_rec IN t_Sched_type
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN t_Key_rec
		x_Demand_ref IN OUT NOCOPY t_Cursor_ref
		x_SumOrderedQty IN NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure IncreaseDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
			 x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                         x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref,
                         x_SumOrderedQty IN NUMBER);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	DeleteDemand

  DESCRIPTION:	This procedure will delete demand for the passed requirement

  PARAMETERS:	x_Sched_rec IN t_Sched_type
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN t_Key_rec
		x_Demand_ref IN OUT NOCOPY t_Cursor_ref

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure DeleteDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
		       x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                       x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                       x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	DecreaseDemand

  DESCRIPTION:	This procedure will decrease demand for the passed requirement

  PARAMETERS:	x_Sched_rec IN t_Sched_type
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN t_Key_rec
                x_Demand_ref IN OUT NOCOPY t_Cursor_ref
		x_SumOrderedQty IN NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure DecreaseDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                         x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref,
                         x_SumOrderedQty IN NUMBER);
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	OtherDemand

  DESCRIPTION:	This procedure will update demand for the passed requirement
		where the attributes have changed.

  PARAMETERS:	x_Sched_rec IN t_Sched_type
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		x_Key_rec IN OUT NOCOPY t_Key_rec
		x_Demand_ref IN OUT NOCOPY t_Cursor_ref

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure OtherDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
		      x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                      x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                      x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:	CancelRequirement

  DESCRIPTION:	This procedure will cancel the passed requirement

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                x_Group_rec IN rlm_dp_sv.t_Group_rec
                x_Key_rec IN t_Key_rec
		x_CancelQty IN NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure CancelRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_Key_rec IN RLM_RD_SV.t_Key_rec,
                            x_CancelQty IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:	SetOperation

  DESCRIPTION:	This procedure will store the operation to be passed to the
		process order api.

  PARAMETERS:	x_Key_rec IN t_Key_rec
		x_Operation IN VARCHAR2
                x_Quantity IN NUMBER := NULL

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure SetOperation(x_Key_rec IN RLM_RD_SV.t_Key_rec,
                       x_Operation IN VARCHAR2,
                       x_Quantity IN NUMBER := NULL);


/*===========================================================================
  FUNCTION NAME:	MatchReconcile

  DESCRIPTION:	This procedure will match against the reconcile table

  PARAMETERS:	x_Group_rec IN rlm_dp_sv.t_Group_rec
		x_Current_rec IN t_Generic_rec
		x_Index OUT NOCOPY NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Function MatchReconcile(x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                        x_Current_rec IN t_Generic_rec,
                        x_Index OUT NOCOPY NUMBER)
                        RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	MatchWithin

  DESCRIPTION:	This function will check for match within schedule type

  PARAMETERS:	x_WithinString IN VARCHAR2
		x_ColumnName IN VARCHAR2

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Function MatchWithin(x_WithinString IN VARCHAR2,
                     x_ColumnName IN VARCHAR2)
                     RETURN VARCHAR2;


/*===========================================================================
  FUNCTION NAME:	MatchAcross

  DESCRIPTION:	This function will check for match across schedule type

  PARAMETERS:	x_AcrossString IN VARCHAR2
		x_ColumnName IN VARCHAR2

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Function MatchAcross(x_AcrossString IN VARCHAR2,
                     x_ColumnName IN VARCHAR2)
                     RETURN VARCHAR2;


/*===========================================================================
  FUNCTION NAME:	AttributeChange

  DESCRIPTION:       	This function checks for an attribute change
                        between oe demand and incoming requirements

  PARAMETERS:	        x_Key_rec IN t_Key_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 30/11/99
===========================================================================*/
Function AttributeChange(x_Key_rec IN RLM_RD_SV.t_Key_rec)
                         RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	StoreReconcile

  DESCRIPTION:	This procedure will store unreconcilable quantities to be
		reconciled against incoming requirements.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN rlm_dp_sv.t_Group_rec
		x_Key_rec IN t_Key_rec
		x_RecQty IN NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure StoreReconcile(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_Key_rec IN RLM_RD_SV.t_Key_rec,
                         x_Quantity IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:	Reconcile

  DESCRIPTION:	This procedure will reconcile quantities
		of incoming requirements against unreconcilable
		demand.

  PARAMETERS:	x_Group_rec IN rlm_dp_sv.t_Group_rec
		x_Key_rec IN OUT NOCOPY t_Key_rec
		x_RecQty IN NUMBER

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure Reconcile(x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                    x_Key_rec IN RLM_RD_SV.t_Key_rec,
                    x_Quantity IN OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:	ProcessOld

  DESCRIPTION:	This procedure delete demand which is not included on the
		incoming schedule.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure ProcessOld(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);

--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	InitializeSoGroup

  DESCRIPTION:	This procedure sets up the group cursor, when blankets
		are not used

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_ref IN OUT NOCOPY t_Cursor_ref

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure InitializeSoGroup(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_ref IN OUT NOCOPY rlm_rd_sv.t_Cursor_ref,
                          x_Group_rec IN OUT NOCOPY  rlm_dp_sv.t_Group_rec);
 --<TPA_PUBLIC_NAME>
-- NOTE: need to add for checking irreconcileable differences
/*===========================================================================
  PROCEDURE NAME:	CheckRec

  DESCRIPTION:	This procedure checks for irreconcileable differences and
		attempts to reconcile or generates exceptions.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_ref IN OUT NOCOPY t_Cursor_ref

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================
Procedure CheckRec(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                   x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);
*/


/*===========================================================================
  PROCEDURE NAME:	InitializeReq

  DESCRIPTION:	This procedure sets up the requirements cursor.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN  rlm_dp_sv.t_Group_rec
                x_Req_ref IN OUT NOCOPY t_Cursor_ref
                x_ReqType IN VARCHAR2

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure InitializeReq(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                        x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                        x_Req_ref IN OUT NOCOPY t_Cursor_ref,
                        x_ReqType IN VARCHAR2);


/*===========================================================================
  FUNCTION NAME:	FetchGroup

  DESCRIPTION:	This function fetches next group, when blankets are not used.

  PARAMETERS:	x_Group_ref IN OUT NOCOPY t_Cursor_ref
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Function FetchGroup(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                    x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
                    RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	FetchReq

  DESCRIPTION:	This function fetches next requirement

  PARAMETERS:	x_Req_ref     IN OUT NOCOPY t_Cursor_ref
		x_Key_rec     IN OUT NOCOPY t_Key_rec
                x_oe_line_id     OUT NOCOPY NUMBER
                x_SumOrderedQty  OUT NOCOPY NUMBER
                x_ScheduleType   OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Function FetchReq(x_Req_ref IN OUT NOCOPY t_Cursor_ref,
                  x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                  x_oe_line_id     OUT NOCOPY NUMBER,
                  x_SumOrderedQty  OUT NOCOPY NUMBER,
                  x_ScheduleType   OUT NOCOPY VARCHAR2)
                  RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	FetchDemand

  DESCRIPTION:	This function fetches next demand

  PARAMETERS:	x_Demand_ref IN OUT NOCOPY t_Cursor_ref
		x_Key_rec IN OUT NOCOPY t_Key_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Function FetchDemand(x_Demand_ref IN OUT NOCOPY t_Cursor_ref,
		     x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec)
                     RETURN BOOLEAN;


/*===========================================================================

  FUNCTION NAME:	SchedulePrecedence

  DESCRIPTION:	        Check for schedule precedence.

  PARAMETERS:	        x_Group_rec IN rlm_dp_sv.t_Group_rec
	         	x_ScheduleType IN VARCHAR2


  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/09/99
===========================================================================*/
FUNCTION SchedulePrecedence(x_Group_rec    IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_Sched_rec    IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_ScheduleType IN VARCHAR2)
                            RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:	StoreShipments

  DESCRIPTION:	This procedure will store the shipments information in the
                reconcile_tab. This shipment information will be useful for
                shipment reconciliation

  PARAMETERS:	x_Group_rec IN rlm_dp_sv.t_Group_rec
		x_ScheduleType IN VARCHAR2


  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/05/99
===========================================================================*/
PROCEDURE StoreShipments(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_Key_rec IN RLM_RD_SV.t_Key_rec,
                         x_Quantity IN NUMBER);

/*===========================================================================

  PROCEDURE NAME:	ReconcileShipments

  DESCRIPTION:	This procedure will reconcile the shipments withe the new demand
                which comes in

  PARAMETERS:	x_Group_rec IN rlm_dp_sv.t_Group_rec
		x_ScheduleType IN VARCHAR2


  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/05/99
===========================================================================*/
PROCEDURE ReconcileShipments(x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                    x_Key_rec IN RLM_RD_SV.t_Key_rec,
                    x_Quantity IN OUT NOCOPY NUMBER);
--<TPA_PUBLIC_NAME>


/*===========================================================================

  FUNCTION NAME:	MatchShipments

  DESCRIPTION:	Check to see if the current_rec line matches the shipment info in
                reconcile tab

  PARAMETERS:	x_Group_rec IN rlm_dp_sv.t_Group_rec
		x_ScheduleType IN VARCHAR2


  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/05/99
===========================================================================*/
FUNCTION MatchShipments(x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                        x_Current_rec IN RLM_RD_SV.t_Generic_rec,
                        x_Index OUT NOCOPY NUMBER)
RETURN BOOLEAN;
--<TPA_PUBLIC_NAME>


/*===========================================================================

  FUNCTION NAME:	IsLineConsumable

  DESCRIPTION:	 returns true if the line is consumable i.e teh line is not
                 part of the x_consume_tab
                 If it is part of the consume tab then the line should not
                 be used for consumption

  PARAMETERS:	x_Group_rec IN rlm_dp_sv.t_Group_rec
		x_ScheduleType IN VARCHAR2


  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/05/99
===========================================================================*/

FUNCTION IsLineConsumable(x_consume_tab IN t_consume_tab,
                          x_line_id IN RLM_INTERFACE_LINES.LINE_ID%TYPE,
                          x_index   OUT NOCOPY NUMBER)
RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:  UpdateGroupStatus

  DESCRIPTION:	   Updates the process status to x_status for the entire
                   group passed in with the x_group_rec

  PARAMETERS:      x_Group_rec         IN     rlm_dp_sv.t_Group_rec
                   x_header_id         IN     NUMBER,
                   x_ScheduleHeaderId  IN     NUMBER,
                   x_status            IN     NUMBER



  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/
PROCEDURE  UpdateGroupStatus( x_header_id         IN     NUMBER,
                              x_ScheduleHeaderId  IN     NUMBER,
                              x_Group_rec         IN     rlm_dp_sv.t_Group_rec,
                              x_status            IN     NUMBER,
                              x_UpdateLevel       IN  VARCHAR2 DEFAULT 'GROUP');



/*===========================================================================

  PROCEDURE NAME:  IsFrozen

  DESCRIPTION:	   Checks whether a lines fall within the frozen fence

  PARAMETERS:   x_horizon_start_date IN DATE
                x_Group_rec   IN rlm_dp_sv.t_Group_rec
                x_ShipDate    IN     DATE

  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/
FUNCTION IsFrozen(x_horizon_start_date IN DATE,
                  x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                  x_ShipDate IN DATE)
RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:  LockLines

  DESCRIPTION:	   Locks lines

  DESIGN REFERENCES:	RLADPHLD.rtf
			RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/
FUNCTION LockLines (x_Group_rec         IN     rlm_dp_sv.t_Group_rec,
                    x_header_id         IN     NUMBER)
RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:       LockHeaders

  DESCRIPTION:	        Locks headers

  DESIGN REFERENCES:	RLMDPHLD.rtf
			RLMDPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 03/05/99
===========================================================================*/
FUNCTION LockHeaders (x_header_id         IN     NUMBER)
RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:     UpdateHeaderStatus

  DESCRIPTION:        This procedure update the process status for the header

  PARAMETERS:         x_HeaderId           IN NUMBER
                      x_ScheduleHeaderId   IN   NUMBER
                      x_ProcessStatus      IN NUMBER

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
PROCEDURE UpdateHeaderStatus(x_HeaderId           IN   NUMBER,
                             x_ScheduleHeaderId   IN   NUMBER,
                             x_Status             IN   NUMBER );

/*===========================================================================
  PROCEDURE NAME:       CheckTolerance

  DESCRIPTION:	        This procedure checks if difference between old
		        quantity and new quantity is greater than the specified
                        tolerance.

  PARAMETERS:	        x_CustomerItemId IN NUMBER
                        x_OldQty IN NUMBER
                        x_NewQty IN NUMBER
                        x_DemandTolerancePos IN NUMBER
                        x_DemandToleranceNeg IN NUMBER
                        x_DemandLineId  IN  NUMBER

  DESIGN REFERENCES:	RLMDPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created mnandell 12/15/99
===========================================================================*/
PROCEDURE CheckTolerance(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_Key_rec   IN RLM_RD_SV.t_Key_rec,
                         x_OldQty IN NUMBER,
                         x_NewQty IN NUMBER);

/*===========================================================================
  FUNCTION NAME:        AlreadyUpdated

  DESCRIPTION:	        This function checks if current OE lines that match
			incoming schedule lines have previously been updated

  PARAMETERS:	        x_line_id_tab IN t_matching_line

  DESIGN REFERENCES:	RLMDPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created JAUTOMO 05/03/00
===========================================================================*/
FUNCTION AlreadyUpdated(x_line_id_tab IN t_matching_line)
		       RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:         GetTPContext

  DESCRIPTION:            This procedure returns the tpcontext.
                          When this procedure is called from
                          ProcessPreHorizonATS, ProcessNATS, and
                          ProcessATS it returns null for x_bill_to_ece_locn_code
                          and x_inter_ship_to_ece_locn_code

  PARAMETERS:             x_sched_rec  IN  RLM_INTERFACE_HEADERS%ROWTYPE
                          x_group_rec  IN  rlm_dp_sv.t_Group_rec
                          x_req_rec    IN  t_generic_rec
                          x_customer_number OUT NOCOPY VARCHAR2
                          x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
                          x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2
                          x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
 			  x_tp_group_code OUT NOCOPY VARCHAR2,
                          x_key_rec    IN  rlm_rd_sv.t_key_rec DEFAULT NULL
  DESIGN REFERENCES:

  NOTES:

  OPEN ISSUES:
  CLOSED ISSUES:

  CHANGE HISTORY:         bsadri      01/12/00    created
===========================================================================*/
PROCEDURE GetTPContext(x_sched_rec  IN  RLM_INTERFACE_HEADERS%ROWTYPE DEFAULT NULL,
                       x_group_rec  IN  rlm_dp_sv.t_Group_rec DEFAULT NULL,
                       x_req_rec    IN  rlm_rd_sv.t_generic_rec DEFAULT NULL,
                       x_customer_number OUT NOCOPY VARCHAR2,
                       x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_tp_group_code OUT NOCOPY VARCHAR2,
                       x_key_rec    IN  rlm_rd_sv.t_key_rec DEFAULT NULL);
--<TPA_TPS>


/*===========================================================================
  PROCEDURE NAME:         InitializeMatchRec

  DESCRIPTION:            This procedure uses the processing rules to determine
			  which optional matching attributes to use when
			  calculating in-transit quantities.


  PARAMETERS:             x_Sched_rec  IN  RLM_INTERFACE_HEADERS%ROWTYPE
                          x_Group_rec  IN  rlm_dp_sv.t_Group_rec
                          x_match_ref  IN OUT NOCOPY t_Cursor_ref

  CHANGE HISTORY:         rlanka      01/14/02    created
===========================================================================*/
Procedure InitializeMatchRec(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                             x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                             x_match_ref IN OUT NOCOPY t_Cursor_ref);


/*===========================================================================
  FUNCTION NAME:          FetchMatchRec

  DESCRIPTION:            This function is used to retrieve the matching
			  attributes one sub-group at a time.  Returns true
			  if a match_rec was found, else returns false


  PARAMETERS:             x_match_ref     IN OUT NOCOPY t_Cursor_ref
			  x_opt_match_rec IN OUT NOCOPY WSH_RLM_INTERFACE.t_optional_match_rec

  CHANGE HISTORY:         rlanka      01/14/02    created
===========================================================================*/
Function FetchMatchRec(x_match_ref     IN OUT NOCOPY t_Cursor_ref,
		       x_opt_match_rec IN OUT NOCOPY WSH_RLM_INTERFACE.t_optional_match_rec)
RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:          AlreadyMatched

  DESCRIPTION:            This function is used to determine if a set of
			  matching criteria have already been used for
			  calculation of intransit shipments


  PARAMETERS:             x_Group_rec	  IN  RLM_DP_SV.t_Group_rec
			  x_match_rec     IN  WSH_RLM_INTERFACE.t_optional_match_rec
			  x_Index	  OUT NOCOPY NUMBER

  CHANGE HISTORY:         rlanka      01/14/02    created
===========================================================================*/
Function  AlreadyMatched(x_Group_rec IN  OUT NOCOPY RLM_DP_SV.t_Group_rec,
			 x_match_rec IN  WSH_RLM_INTERFACE.t_optional_match_rec,
			 x_Index     OUT NOCOPY NUMBER)
RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:          MRPOnly

  DESCRIPTION:            This function is used to determine if the schedule
                          in process contains only MRP Forecast Requirement.

  PARAMETERS:             x_Sched_rec 		 IN RLM_INTERFACE_HEADERS%ROWTYPE
			  x_Group_rec IN rlm_dp_sv.t_Group_rec

  CHANGE HISTORY:         jautomo      01/17/02    created
===========================================================================*/
FUNCTION MRPOnly(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                 x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:         InsertIntransitMatchRec

  DESCRIPTION:            This procedure inserts the match_record and the
		          corresponding in-transit quantity into g_IntransitTab

  PARAMETERS:         	  x_match_rec     IN WSH_RLM_INTERFACE.t_optional_match_rec
			  x_Quantity	  IN NUMBER

  CHANGE HISTORY:         rlanka      01/14/02    created
===========================================================================*/
Procedure InsertIntransitMatchRec(x_match_rec IN WSH_RLM_INTERFACE.t_optional_match_rec,
				  x_Quantity  IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:         InitializeIntransitParam

  DESCRIPTION:            This procedure sets up the parameters to be passed to
			  Shipping API to determine in-transit quantities.

  DESIGN REFERENCE:	  intransit.rtf

  PARAMETERS:         	  x_Sched_rec 		 IN RLM_INTERFACE_HEADERS%ROWTYPE
			  x_Group_rec 		 IN rlm_dp_sv.t_Group_rec
			  x_intransit_calc_basis IN VARCHAR2
			  x_Shipper_rec 	 IN OUT NOCOPY WSH_RLM_INTERFACE.t_shipper_rec
			  x_Shipment_date 	 IN OUT NOCOPY DATE

  CHANGE HISTORY:         rlanka      01/14/02    created
===========================================================================*/
Procedure InitializeIntransitParam(x_Sched_rec 		  IN RLM_INTERFACE_HEADERS%ROWTYPE,
				   x_Group_rec 		  IN rlm_dp_sv.t_Group_rec,
				   x_intransit_calc_basis IN VARCHAR2,
				   x_Shipper_rec 	  IN OUT NOCOPY WSH_RLM_INTERFACE.t_shipper_rec,
				   x_Shipment_date 	  IN OUT NOCOPY DATE);

/*===========================================================================
  PROCEDURE NAME:         PrintMatchRec

  DESCRIPTION:            This procedure prints the match rec.  Used solely
		          for debugging purposes

  PARAMETERS:         	  x_opt_match_rec IN WSH_RLM_INTERFACE.t_optional_match_rec

  CHANGE HISTORY:         rlanka      01/14/02    created
===========================================================================*/
Procedure PrintMatchRec(x_opt_match_rec IN  WSH_RLM_INTERFACE.t_optional_match_rec);

--
-- Blanket Order Procedures
--
/*===========================================================================
  PROCEDURE NAME:	InitializeBlktGrp

  DESCRIPTION:	This procedure sets up the group cursor, when blankets
		are used.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_ref IN OUT NOCOPY t_Cursor_ref

  DESIGN REFERENCES:	rlmbldld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created rlanka 10/10/02
===========================================================================*/
Procedure InitializeBlktGrp(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_ref IN OUT NOCOPY  rlm_rd_sv.t_Cursor_ref,
                            x_Group_rec IN OUT NOCOPY  rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  FUNCTION NAME:	FetchBlktGroup

  DESCRIPTION:	This function fetches next group, when blankets are used

  PARAMETERS:	x_Group_ref IN OUT NOCOPY t_Cursor_ref
		x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	rlmbldld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created rlanka 10/11/02
===========================================================================*/
Function FetchBlktGrp(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                      x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
                      RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	GetDemand

  DESCRIPTION:	This procedure will retrieve demand attributes from
		oe_order_lines.

  PARAMETERS:	x_Key_rec IN OUT NOCOPY t_Key_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure GetDemand(x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                    x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);


/*===========================================================================
  PROCEDURE NAME:	InitializeDemand

  DESCRIPTION:	This procedure sets up the demand cursor.

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
		x_Group_rec IN  rlm_dp_sv.t_Group_rec
                x_Key_rec, IN t_Key_rec
                x_Demand_ref IN OUT NOCOPY t_Cursor_ref
		x_DemandType IN VARCHAR2

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created jhaulund 03/08/99
===========================================================================*/
Procedure InitializeDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                           x_Group_rec In OUT NOCOPY rlm_dp_sv.t_Group_rec,
                           x_Key_rec IN RLM_RD_SV.t_Key_rec,
                           x_Demand_ref IN OUT NOCOPY t_Cursor_ref,
                           x_DemandType IN VARCHAR2);


/*=================================================================================
  PROCEDURE NAME:	BuildMatchQuery

  DESCRIPTION:		This procedure is called from ProcessATS and ProcessNATS.
			Earlier it was a private procedure, now made it public.

  PARAMETERS:

  DESIGN REFERENCES:	RLADPRDD.rtf

  CHANGE HISTORY:	created jautomo	01/14/02
==================================================================================*/
PROCEDURE BuildMatchQuery(x_Sched_rec     IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_Rec     IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                          x_Demand_Type   IN VARCHAR2,
                          x_Sql           OUT NOCOPY VARCHAR2,
                          x_Sql1          OUT NOCOPY VARCHAR2,
                          x_Sql2          OUT NOCOPY VARCHAR2,
                          x_Sum_Sql       OUT NOCOPY VARCHAR2);
--<TPA_PUBLIC_NAME>


/*==================================================================================
  PROCEDURE NAME:	ReconcileAction

  DESCRIPTION:		This procedure is called from ProcessATS and ProcessNATS.
			Earlier, it was a private procedure now made it public.

  PARAMETERS:

  DESIGN REFERENCES:	RLADPRDD.rtf

  CHANGE HISTORY:	created jautomo
===================================================================================*/
PROCEDURE ReconcileAction(x_sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                          x_key_rec   IN OUT NOCOPY RLM_RD_SV.t_key_rec,
                          x_line_id_tab IN RLM_RD_SV.t_matching_line,
                          x_DemandCount IN NUMBER,
                          x_SumOrderedQty IN NUMBER,
                          x_DemandType IN VARCHAR2);
--<TPA_PUBLIC_NAME>

/*==================================================================================
  FUNCTION NAME:	BuildBindVarTab3

  DESCRIPTION:		This function is called from ProcessATS and ProcessNATS.
			It takes in three bind variable value tables and concatenates
			all of them into one single table to be passed to
			RLM_CORE_SV.OpenDynamicCursor

  PARAMETERS:

  DESIGN REFERENCES:	RLADPRDD.rtf

  CHANGE HISTORY:	created rlanka
===================================================================================*/
FUNCTION BuildBindVarTab3(p_Tab1 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab2 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab3 IN RLM_CORE_SV.t_dynamic_tab)
RETURN RLM_CORE_SV.t_dynamic_tab;


/*==================================================================================
  FUNCTION NAME:	BuildBindVarTab5

  DESCRIPTION:		This function is called from ProcessATS and ProcessNATS.
			It takes in five bind variable value tables and concatenates
			all of them into one single table to be passed to
			RLM_CORE_SV.OpenDynamicCursor

  PARAMETERS:

  DESIGN REFERENCES:	RLADPRDD.rtf

  CHANGE HISTORY:	created rlanka
===================================================================================*/
FUNCTION BuildBindVarTab5(p_Tab1 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab2 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab3 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab4 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab5 IN RLM_CORE_SV.t_dynamic_tab)
RETURN RLM_CORE_SV.t_dynamic_tab;


/*==================================================================================
  FUNCTION NAME:	BuildBindVarTab2

  DESCRIPTION:		This function is called from ProcessATS and ProcessNATS.
			It takes in two bind variable value tables and concatenates
			all of them into one single table to be passed to
			RLM_CORE_SV.OpenDynamicCursor

  PARAMETERS:

  DESIGN REFERENCES:	RLADPRDD.rtf

  CHANGE HISTORY:	created rlanka
===================================================================================*/
FUNCTION BuildBindVarTab2(p_Tab1 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab2 IN RLM_CORE_SV.t_dynamic_tab)
RETURN RLM_CORE_SV.t_dynamic_tab;




/*===========================================================================
  PROCEDURE NAME:     SourceCUMIntransitQty

  DESCRIPTION:      This procedure is used to apply sourcing rules to the
                    intransit quantity (Supplier CUM - Customer CUM) and is
                    used only when the intransit calculation basis is
                    Customer CUM and the CUM org level is XXX/All Ship Froms.

  PARAMETERS:       x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                    x_Group_rec IN OUT  rlm_dp_sv.t_Group_rec
                    x_Cum_rec   IN RLM_RD_SV.t_Ship_rec --Bugfix 7007638

  DESIGN REFERENCES:

  ALGORITHM:
             (a) Using data in g_SourceTab, split g_IntransitQty into
                 respective allocations.
             (b) Call StoreShipments() to store the sourced intransit quantity
                 for the current SF org being processed.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created  rlanka  06/21/04
===========================================================================*/
PROCEDURE SourceCUMIntransitQty(x_Sched_rec    IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                x_Group_rec    IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                                x_Cum_rec      IN RLM_RD_SV.t_Ship_rec); --Bugfix 7007638



/*===========================================================================
  PROCEDURE NAME:     CalculateCUMIntransit

  DESCRIPTION:      This procedure uses the CUM information on the schedule
                    in order to calculate the supplier CUM and hence the
                    intransit quantity (Supplier - Customer CUM).  This
                    is called from within SynchronizeShipments.

  PARAMETERS:       x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                    x_Group_rec IN OUT  rlm_dp_sv.t_Group_rec
                    x_Line_id IN NUMBER --Bugfix 7007638
                    x_IntransitQty IN NUMBER

  DESIGN REFERENCES:

  ALGORITHM:
             (a) Using CUM information on the schedule, derive the
                 attributes needed to calculate the CUM key.
             (b) Call CUM API to derive the CUM key information.
             (c) Calculate Supplier CUM.
             (d) Intransit Quantity := Supplier CUM - Customer CUM
             (e) Return quantity in (d) as an OUT parameter.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created  rlanka  06/21/04
===========================================================================*/
PROCEDURE CalculateCUMIntransit(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                                x_Line_id   IN NUMBER, --Bugfix 7007638
                                x_Intransit OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:     AssignOEAttribValues

  DESCRIPTION:      This procedure uses the information in p_OEDemand_rec
                    structure to populate values for the dem_rec component
                    of x_Key_rec.  This is called from procedure ProcessOld.
                    and can eventually be used to eliminate calls to GetDemand().

  PARAMETERS:       x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec
                    p_OEDemand_rec IN RLM_RD_SV.t_OEDemand_rec


  CHANGE HISTORY:     created  rlanka  06/28/04
===========================================================================*/
PROCEDURE AssignOEAttribValues(x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                               p_OEDemand_rec IN RLM_RD_SV.t_OEDemand_rec);

--bug4223359

/*===========================================================================
  FUNCTION NAME:        MatchFrozen

  DESCRIPTION:  This procedure will match against the reconcile table

  PARAMETERS:   x_Group_rec IN rlm_dp_sv.t_Group_rec
                x_Index2 IN NUMBER
                x_Current_rec IN t_Generic_rec
                x_Index OUT NOCOPY NUMBER

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 03/28/05
===========================================================================*/
Function MatchFrozen(x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                     x_index2 NUMBER,
                     x_Current_rec IN t_Generic_rec,
                     x_Index OUT NOCOPY NUMBER)
                     RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:       FrozenFenceWarning

  DESCRIPTION: Logs the Aggregate frozen fence message with the net qty
               within the frozen fence period.

  PARAMETERS:   x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                x_Group_rec IN rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:
  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 03/28/05
===========================================================================*/
Procedure  FrozenFenceWarning(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);

/*===========================================================================
  PROCEDURE NAME:       GetMatchAttributes

  DESCRIPTION: Get the code Values pair of the matching attributes excluding the request date
               Original Customer request Date.

  PARAMETERS:   x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                x_Group_rec IN rlm_dp_sv.t_Group_rec
                x_frozenTabRec IN t_generic_rec,
                x_MatAttrCodeValue OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 03/28/05
==============================================================================*/

PROCEDURE GetMatchAttributes(x_sched_rec IN rlm_interface_headers%ROWTYPE,
                             x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                             x_frozenTabRec IN t_Generic_rec,
                             x_MatAttrCodeValue OUT NOCOPY VARCHAR2);



/*=====================================================================

PROCEDURE NAME:  ProcessReleases


PARAMETERS:     x_Sched_rec IN rlm_interface_headers%ROWTYPE
                x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec
                x_Processed IN OUT NOCOPY VARCHAR2

DESCRIPTION:     This procedure is called from within RecDemand() for
                 each SF/ST/CI group.  For each such group, this procedure
                 calls RecGroupDemand() if the group has a blanket
                 number associated with it.

HISTORY:         Created   rlanka     04/25/2005 (for Bug 4255553)

=======================================================================*/
PROCEDURE ProcessReleases(x_Sched_rec IN rlm_interface_headers%ROWTYPE,
                          x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                          x_Processed IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:     AssignMatchAttribValues

  DESCRIPTION:        This procedure is called from ApplyFFFFences
                      when RLM_PAST_DUE_DEMAND exception is raised.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:              Bug 4297984

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created  stananth  06/20/05
===========================================================================*/

PROCEDURE  AssignMatchAttribValues ( x_req_rec     IN  rlm_interface_lines_all%ROWTYPE,
                                     x_match_rec   IN OUT NOCOPY RLM_RD_SV.t_generic_rec);

/*============================================================================

PROCEDURE NAME:  PopulateReconcileCumRec

PARAMETERS:      x_Sched_rec IN rlm_interface_headers%ROWTYPE
                 x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec

DESCRIPTION:     This procedure is called from within SynchronizeShipments() for
                 each SF/ST/CI group.  This procedure retrieves the cumulative
                 received/shipped quantity for a particular ship-to and item.

HISTORY:         Created   sunilku     03/19/2008 (for Bug 7007638)

============================================================================*/
PROCEDURE PopulateReconcileCumRec(x_Sched_rec IN            rlm_interface_headers%ROWTYPE,
                                  x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);


/*===========================================================================
  FUNCTION NAME:	Match_PO_RY_Reconcile

  DESCRIPTION:	This procedure will match against the reconcile table

  PARAMETERS:	x_Group_rec   IN OUT NOCOPY rlm_dp_sv.t_Group_rec
		        x_Current_rec IN            t_Generic_rec
 		        x_Index          OUT NOCOPY NUMBER

  HISTORY:	    created sunilku 04/03/2008 (for Bug 7007638)
===========================================================================*/
Function Match_PO_RY_Reconcile(x_Group_rec   IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                               x_Current_rec IN            t_Generic_rec,
                               x_Index          OUT NOCOPY NUMBER)
                               RETURN BOOLEAN;

END RLM_RD_SV;

/
