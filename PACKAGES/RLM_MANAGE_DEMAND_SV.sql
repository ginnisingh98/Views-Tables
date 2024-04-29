--------------------------------------------------------
--  DDL for Package RLM_MANAGE_DEMAND_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_MANAGE_DEMAND_SV" AUTHID CURRENT_USER as
/* $Header: RLMDPMDS.pls 120.4.12010000.2 2008/07/30 12:12:16 sunilku ship $*/
--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>

/*===========================================================================
  PACKAGE NAME:		rlm_manage_demand_sv

  DESCRIPTION:		Contains all server side code for the RLM Manage Demand.

  CLIENT/SERVER:        Server

  LIBRARY NAME:         None

  OWNER:                mnandell

  PROCEDURE/FUNCTIONS:

  GLOBALS:

============================================================================*/

  TYPE t_match_Tab  IS TABLE OF rlm_core_sv.t_match_rec INDEX BY BINARY_INTEGER;
  TYPE t_Cursor_ref IS REF CURSOR;

  TYPE t_MD_rec IS RECORD (
    operation_code                NUMBER,
    source_index                NUMBER
    );

  TYPE t_MD_tab IS TABLE OF rlm_interface_lines%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE t_Number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE t_Ship_rec IS RECORD (
    customer_id               NUMBER,
    customer_item_id          NUMBER,
    inventory_item_id         NUMBER,
    ship_from_org_id          NUMBER,
    intrmd_ship_to_address_id NUMBER,
    ship_to_address_id        NUMBER,
    bill_to_address_id        NUMBER,
    purchase_order_number     rlm_interface_lines.cust_po_number%TYPE,
    primary_quantity          NUMBER,
    item_detail_quantity      NUMBER, -- Added by JAUTOMO
    start_date_time           DATE,
    cust_record_year          rlm_interface_lines.industry_attribute1%TYPE,
    line_id                   NUMBER,
    found                     NUMBER
    );

  -- JAUTOMO: Bug 1689974
  TYPE t_source_rec IS RECORD( organization_id  NUMBER,
                               allocation_percent   NUMBER,
                               effective_date DATE, --Bugfix 6051397
                               disable_date DATE);  --Bugfix 6051397

  TYPE t_Source_tab IS TABLE OF t_source_rec INDEX BY BINARY_INTEGER;
  TYPE t_Ship_tab IS TABLE OF t_Ship_rec INDEX BY BINARY_INTEGER;  --Bugfix 7007638

  g_AllIntransitQty NUMBER := 0;
  --

  e_GroupError            EXCEPTION;
  k_INSERT                CONSTANT NUMBER := 0;
  k_UPDATE                CONSTANT NUMBER := 1;
  k_DELETE                CONSTANT NUMBER := 2;
  k_PAST_DUE_FIRM         CONSTANT VARCHAR2(1) := '0';
  k_FIRM_DEMAND           CONSTANT VARCHAR2(1) := '1';
  k_FORECAST_DEMAND       CONSTANT VARCHAR2(1) := '2';
  k_MRP_FORECAST          CONSTANT VARCHAR2(1) := '6';
  k_MRP_DROP_DEMAND       CONSTANT VARCHAR2(1) := 'D'; --bug 5208135
  k_AUTHORIZATION         CONSTANT VARCHAR2(1) := '3';
  k_SHIP_RECEIPT_INFO     CONSTANT VARCHAR2(1) := '4';
  k_OTHER_DETAIL_TYPE     CONSTANT VARCHAR2(1) := '5';
  k_CONFIRMATION          CONSTANT VARCHAR2(30) := 'CONFIRMATION';
  k_ACTUAL                CONSTANT VARCHAR2(30) := 'ACTUAL';
  k_CUMULATIVE            CONSTANT VARCHAR2(30) := 'CUMULATIVE';
  k_CUM                   CONSTANT VARCHAR2(30) := 'CUM';
  k_SHIPMENT              CONSTANT VARCHAR2(30) := 'SHIPMENT';
  k_RECEIPT               CONSTANT VARCHAR2(30) := 'RECEIPT';
  k_PLANNING            CONSTANT VARCHAR2(30) := 'PLANNING_RELEASE';
  k_SHIPPING            CONSTANT VARCHAR2(30) := 'SHIPPING';
  k_SEQUENCED           CONSTANT VARCHAR2(30) := 'SEQUENCED';
  k_TRUE                CONSTANT   NUMBER := 1;
  k_FALSE               CONSTANT   NUMBER := 0;
  k_VNULL               CONSTANT   VARCHAR2(30) := 'THIS_IS_NULL_VALUE';
  k_NULL                CONSTANT   NUMBER := -19999999999;
  k_DNULL               CONSTANT   DATE := to_date('01/01/1930','dd/mm/yyyy');
  C_SDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL7;
  C_DEBUG               CONSTANT   NUMBER := rlm_core_sv.C_LEVEL8;
  C_TDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL9;
  --
  k_FIRM                CONSTANT VARCHAR2(1) := '1';
  k_FORECAST            CONSTANT VARCHAR2(1) := '2';
  k_RECT                CONSTANT VARCHAR2(1) := '4';
  -- Bug# 2124495
  k_NONE		CONSTANT VARCHAR2(30):= 'NONE';
  --
  k_REQUEST_DATE             CONSTANT VARCHAR2(30) := 'REQUEST_DATE,C';
  k_CUST_PO_NUMBER           CONSTANT VARCHAR2(30) := 'CUST_PO_NUMBER,E';
  k_CUSTOMER_ITEM_REVISION   CONSTANT VARCHAR2(30) := 'CUSTOMER_ITEM_REVISION,F';
  k_CUSTOMER_DOCK_CODE       CONSTANT VARCHAR2(30) := 'CUSTOMER_DOCK_CODE,B';
  k_CUSTOMER_JOB             CONSTANT VARCHAR2(30) := 'CUSTOMER_JOB,G';
  k_CUST_PRODUCTION_LINE     CONSTANT VARCHAR2(30) := 'CUSTOMER_PRODUCTION_LINE,A';
  k_CUST_MODEL_SERIAL_NUMBER CONSTANT VARCHAR2(30) := 'CUST_MODEL_SERIAL_NUMBER,H';
  k_CUST_PRODUCTION_SEQ_NUM  CONSTANT VARCHAR2(30) := 'CUST_PRODUCTION_SEQ_NUM,$';
  k_INDUSTRY_ATTRIBUTE1      CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE1,I' ;
  k_INDUSTRY_ATTRIBUTE2      CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE2,J' ;
  k_INDUSTRY_ATTRIBUTE4      CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE4,K';
  k_INDUSTRY_ATTRIBUTE5      CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE5,L' ;
  k_INDUSTRY_ATTRIBUTE6      CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE6,M' ;
  k_INDUSTRY_ATTRIBUTE10     CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE10,O';
  k_INDUSTRY_ATTRIBUTE11     CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE11,P';
  k_INDUSTRY_ATTRIBUTE12     CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE12,Q';
  k_INDUSTRY_ATTRIBUTE13     CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE13,R';
  k_INDUSTRY_ATTRIBUTE14     CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE14,S';
  k_INDUSTRY_ATTRIBUTE15     CONSTANT VARCHAR2(30) := 'INDUSTRY_ATTRIBUTE15,T';
  k_ATTRIBUTE1               CONSTANT VARCHAR2(30) := 'ATTRIBUTE1,U';
  k_ATTRIBUTE2               CONSTANT VARCHAR2(30) := 'ATTRIBUTE2,V';
  k_ATTRIBUTE3               CONSTANT VARCHAR2(30) := 'ATTRIBUTE3,W';
  k_ATTRIBUTE4               CONSTANT VARCHAR2(30) := 'ATTRIBUTE4,X';
  k_ATTRIBUTE5               CONSTANT VARCHAR2(30) := 'ATTRIBUTE5,Y';
  k_ATTRIBUTE6               CONSTANT VARCHAR2(30) := 'ATTRIBUTE6,Z';
  k_ATTRIBUTE7               CONSTANT VARCHAR2(30) := 'ATTRIBUTE7,1';
  k_ATTRIBUTE8               CONSTANT VARCHAR2(30) := 'ATTRIBUTE8,2';
  k_ATTRIBUTE9               CONSTANT VARCHAR2(30) := 'ATTRIBUTE9,3';
  k_ATTRIBUTE10              CONSTANT VARCHAR2(30) := 'ATTRIBUTE10,4';
  k_ATTRIBUTE11              CONSTANT VARCHAR2(30) := 'ATTRIBUTE11,5';
  k_ATTRIBUTE12              CONSTANT VARCHAR2(30) := 'ATTRIBUTE12,6';
  k_ATTRIBUTE13              CONSTANT VARCHAR2(30) := 'ATTRIBUTE13,7';
  k_ATTRIBUTE14              CONSTANT VARCHAR2(30) := 'ATTRIBUTE14,8';
  k_ATTRIBUTE15              CONSTANT VARCHAR2(30) := 'ATTRIBUTE15,9';

  g_ManageDemand_tab t_MD_tab;
  g_Group_rec        rlm_dp_sv.t_Group_rec;
  g_LastReceipt_rec  t_Ship_rec;
  g_CUM_rec  t_Ship_rec;
  g_CUM_tab          t_Ship_tab;  --Bugfix 7007638

  e_group_error          EXCEPTION;

  -- Bug 3686095 : Record structure to hold the percentage allocation
  -- of intransit quantities
  TYPE t_SrcIntransit IS RECORD(organization_id NUMBER,
                                intransit_qty   NUMBER);
  TYPE t_SrcIntransitQtyTab IS TABLE OF t_SrcIntransit INDEX BY BINARY_INTEGER;

/*===========================================================================
  PROCEDURE NAME:        ManageDemand

  DESCRIPTION:           This procedure will be called to manage demand
                         for a particular schedule, and serve as the top level
                         routine from which all other routines will be called.

  PARAMETERS:            x_InterfaceHeaderId IN NUMBER
                         x_ReturnStatus OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/98        created
===========================================================================*/
PROCEDURE ManageDemand(x_InterfaceHeaderId IN NUMBER,
                       x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                       x_ReturnStatus OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:        ManageGroupDemand

  DESCRIPTION:           This procedure will be called to manage demand
                         for a particular schedule, and serve as the top level
                         routine from which all other routines will be called.

  PARAMETERS:            x_InterfaceHeaderId IN NUMBER
                         x_ReturnStatus OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/98        created
===========================================================================*/
PROCEDURE ManageGroupDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_ReturnStatus OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:        PopulateLastReceiptRec

  DESCRIPTION:                This procedure retrieves the last ship receipt rec
ord.

  PARAMETERS:                x_ScheduleId IN NUMBER
                        x_Group_rec IN t_Group_rec
                        x_LastReceipt_rec OUT NOCOPY t_Ship_rec

  DESIGN REFERENCES:        rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  PopulateLastReceiptRec(x_Sched_rec IN rlm_interface_headers%ROWTYPE,
                                  x_Group_rec IN rlm_dp_sv.t_Group_rec);

/*===========================================================================
  PROCEDURE NAME:        PopulateMD

  DESCRIPTION:           This procedure retrieves all requirements for a
                         particular ship-from, ship-to, and item.

  PARAMETERS:            x_ManageDemand_tab IN OUT NOCOPY t_MD_tab
                         x_Group_rec IN t_Group_rec

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  PopulateMD(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                      x_Group_rec IN rlm_dp_sv.t_Group_rec,
                      x_IncludeCUM IN VARCHAR2 DEFAULT 'N');


/*===========================================================================
  PROCEDURE NAME:        CUMToDiscrete

  DESCRIPTION:           This procedure converts CUM quantities to discrete
                         quantities.

  PARAMETERS:            x_ManageDemand_tab IN OUT NOCOPY t_MD_tab
                         x_ReceiveShip_rec IN t_Ship_rec

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  CUMToDiscrete(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:        PopulateCUMRec

  DESCRIPTION:           This procedure retrieves the cumulative
                         received/shipped quantity for a particular ship-to
                         and item.

  PARAMETERS:            x_ScheduleId IN NUMBER
                         x_Group_rec IN t_Group_rec
                         x_ReceiveShip_rec OUT NOCOPY t_Ship_rec


  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  PopulateCUMRec(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_rec IN rlm_dp_sv.t_Group_rec );

/*===========================================================================
  PROCEDURE NAME:        UOMConversion

  DESCRIPTION:           This procedure converts the transaction uom to the
                         customer uom code where required

  PARAMETERS:            x_ManageDemand_tab IN OUT NOCOPY t_MD_tab
                         x_Group_rec IN t_Group_rec

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  UOMConversion(x_Group_rec IN rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:        CUMDiscrepancyCheck

  DESCRIPTION:           This procedure compares oracle's CUMs to what the
                         customer has sent, and reports any discrepancies.

  PARAMETERS:            x_ManageDemand_tab IN OUT NOCOPY t_MD_tab
                         x_LastReceipt_rec IN t_Ship_rec
                         x_ReceiveShip_rec IN t_Ship_rec

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  CUMDiscrepancyCheck( x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                x_Group_rec IN rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:        SetOperation

  DESCRIPTION:           This procedure sets the operation code for the passed demand record.

  PARAMETERS:            x_ManageDemand_rec IN OUT NOCOPY t_MD_rec
                         x_Operation IN NUMBER

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  SetOperation(x_ManageDemand_rec IN OUT NOCOPY rlm_interface_lines%ROWTYPE,
                        x_Operation IN NUMBER);

/*===========================================================================
  PROCEDURE NAME        ApplySourceRules:

  DESCRIPTION:          If multiple ship-from locations are defined in
                        RLM_SHIPFR_CUST_ITEMS for a
                        customer item, this procedure will find the
                        appropriate sourcing rules
                        and assign the requirements between multiple
                        warehouses accordingly.

  PARAMETERS:           x_ManageDemand_tab IN OUT NOCOPY t_MD_tab
                        x_Group_rec IN t_Group_rec


  DESIGN REFERENCES:    rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE ApplySourceRules(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                           x_Group_rec IN rlm_dp_sv.t_Group_rec,
                           x_SourcedDemand_tab OUT NOCOPY rlm_manage_demand_sv.t_MD_Tab,
                           x_Source_Tab OUT NOCOPY rlm_manage_demand_sv.t_Source_Tab
);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:        CalculateShipDate

  DESCRIPTION:           Calls the Calculate Scheduled Ship Date API
                        and updates the x_ManageDemand_tab
                        with the returned results.

  PARAMETERS:            x_Group_rec IN t_Group_rec

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  CalculateShipDate( x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                              x_Group_rec IN rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:       ApplyFFFFences

  DESCRIPTION:          Applys the applicable fence days to incoming demand.

  PARAMETERS:           x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                        x_Group_rec IN t_Group_rec
                        IsLineProcessed IN OUT NOCOPY BOOLEAN

  DESIGN REFERENCES:    rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/98        created
===========================================================================*/
PROCEDURE  ApplyFFFFences(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_rec IN rlm_dp_sv.t_Group_rec,
                          IsLineProcessed IN OUT NOCOPY BOOLEAN );
--<TPA_PUBLIC_NAME>

/*===========================================================================
  PROCEDURE NAME:        ProcessTable

  DESCRIPTION:           Perform operations stored in x_ManageDemand_tab.
                         These operations consist of updates, deletes,
                         and inserts into the rlm_interface_lines.

  PARAMETERS:            x_ManageDemand_tab IN t_MD_tab

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  ProcessTable(x_Demand_tab IN t_MD_Tab);

/*===========================================================================
  PROCEDURE NAME:        DeleteReq

  DESCRIPTION:           Deletes passed requirement.

  PARAMETERS:            x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  DeleteReq(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE);

/*===========================================================================
  PROCEDURE NAME:        InsertReq

  DESCRIPTION:           Inserts passed requirement.

  PARAMETERS:            x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  InsertReq(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE);

/*===========================================================================
  PROCEDURE NAME:        UpdateReq

  DESCRIPTION:           Updates passed requirement.

  PARAMETERS:            x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE  UpdateReq(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE);

/*===========================================================================
  PROCEDURE NAME:        UpdateSchedule

  DESCRIPTION:           Update the schedule lines when they are
                         aggregated to a new line.

  PARAMETERS:            x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE
                         x_AggregateDemand_rec IN rlm_interface_lines%ROWTYPE

  DESIGN REFERENCES:     rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98/28        created
===========================================================================*/
PROCEDURE  UpdateSchedule(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE,
                          x_AggregateDemand_rec IN rlm_interface_lines%ROWTYPE);

/*===========================================================================
  PROCEDURE NAME:      MatchDemand

  DESCRIPTION:         Matches and aggregates like demand
                       in the x_AggregateDemand_tab.
                       When requirements are aggregated,
                       the originals will be marked
                       for deletetion.  This is where x_Delete_tab is used.

  PARAMETERS:           x_Group_Rec IN t_Group_Rec
                        x_Index IN NUMBER
                        x_AggregateDemand_tab IN OUT NOCOPY t_MD_tab
                        x_Delete_tab OUT NOCOPY t_Number_tab

  DESIGN REFERENCES:    rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/98/28        created
===========================================================================*/
PROCEDURE  MatchDemand(x_Group_rec IN rlm_dp_sv.t_Group_rec,
                       x_Index IN NUMBER,
                       x_AggregateDemand_tab IN OUT NOCOPY t_MD_tab,
                       x_Delete_tab IN OUT NOCOPY t_Number_tab,
                       x_ExcpTab    IN OUT NOCOPY t_Match_Tab);

/*===========================================================================
  PROCEDURE NAME:        AggregateDemand

  DESCRIPTION:          Aggregates like demand based on the predefined
                        sidentifiers.  Refer to aggregate demand section
                        under major features for a complete listing
                        of sidentifiers.

  PARAMETERS:           x_ManageDemand_tab IN t_MD_tab

  DESIGN REFERENCES:    rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/98        created
===========================================================================*/
PROCEDURE  AggregateDemand(x_Group_rec IN rlm_dp_sv.t_Group_rec);

/*===========================================================================
  PROCEDURE NAME:       SortDemand

  DESCRIPTION:          Sorts demand by ascending planned schedule date.
                        This routine will use the fast quicksort algorithm to
                        sort on planned shipment date.

  PARAMETERS:

  DESIGN REFERENCES:   rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      mnandell        8/6/98        created
===========================================================================*/
PROCEDURE  SortDemand;

/*===========================================================================
  PROCEDURE NAME:      QuickSort

  DESCRIPTION:         Sorts demand by ascending planned schedule date.
                       This routine will use the fast quicksort algorithm
                       to sort on planned shipment date.

  PARAMETERS:          l IN NUMBER
                       r IN NUMBER

  DESIGN REFERENCES:   rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/98        created
===========================================================================*/
PROCEDURE QuickSort(first IN NUMBER, last IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       Swap

  DESCRIPTION:          Swaps records in table based on the passed indexes.

  PARAMETERS:           i IN NUMBER
                        j IN NUMBER

  DESIGN REFERENCES:    rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        jhaulund        8/6/98        created
===========================================================================*/
PROCEDURE Swap(i IN NUMBER, j IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       InsertionSort

  DESCRIPTION:          Performs insertion sort on table with few records.

  PARAMETERS:
                        lo IN NUMBER
                        hi IN NUMBER

  DESIGN REFERENCES:    rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/99        created
===========================================================================*/
PROCEDURE InsertionSort(lo IN NUMBER,
                        hi IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:      RoundStandardPack

  DESCRIPTION:         If the customer item has standard pack rounding enabled,
                       this procedure will round all requirement quantities for
                       standard packaging based on the value of STD_PACK_QTY and
                       customer item UOM.

  PARAMETERS:           x_Group_rec IN t_Group_rec

  DESIGN REFERENCES:    rlmdpmdd.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        mnandell        8/6/99        created
===========================================================================*/
PROCEDURE RoundStandardPack(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  PROCEDURE NAME:        InitializeMdGroup

  DESCRIPTION:           This procedure sets up the group cursor.

  PARAMETERS:            x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                         x_Group_ref IN OUT NOCOPY t_Cursor_ref

  DESIGN REFERENCES:     RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:        created jhaulund 03/08/99
===========================================================================*/
--Bugfix 6084578 changed procedure name
Procedure InitializeMdGroup(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_ref IN OUT NOCOPY rlm_manage_demand_sv.t_Cursor_ref,
                          x_Group_rec IN  rlm_dp_sv.t_Group_rec);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION NAME:      FetchGroup

  DESCRIPTION:        This function fetches next group

  PARAMETERS:         x_Group_ref IN OUT NOCOPY t_Cursor_ref
                      x_Group_rec IN OUT NOCOPY t_Group_rec

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      created jhaulund 03/08/99
===========================================================================*/
FUNCTION FetchGroup(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                    x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:     CallSetups

  DESCRIPTION:        This procedure calls rla setups to populate group record
                      with setup informations.

  PARAMETERS:         x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                      x_Group_rec IN t_Group_rec

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
Procedure CallSetups(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec);

/*===========================================================================
  PROCEDURE NAME:     LockHeader

  DESCRIPTION:        This procedure locks the header in RLM_INTERFACE_HEADERS

  PARAMETERS:         x_HeaderId  IN NUMBER

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================
FUNCTION LockHeader(x_headerId  IN NUMBER)
RETURN BOOLEAN; */

/*===========================================================================
  PROCEDURE NAME:     LockLines

  DESCRIPTION:        This procedure locks the lines for a group

  PARAMETERS:         x_HeaderId  IN NUMBER
                      x_GroupRec  IN t_Group_rec

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
FUNCTION LockLines (x_headerId  IN NUMBER,
                    x_GroupRec  IN rlm_dp_sv.t_Group_rec)
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
                             x_ProcessStatus      IN NUMBER );

/*===========================================================================
  PROCEDURE NAME:     UpdateGroupStatus

  DESCRIPTION:        This procedure update the process status for the group

  PARAMETERS:         x_HeaderId           IN  NUMBER
                      x_ScheduleHeaderId   IN  NUMBER
                      x_GroupRec           IN  t_Group_rec
                      x_ProcessStatus      IN  NUMBER

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
PROCEDURE UpdateGroupStatus(x_HeaderId           IN   NUMBER,
                            x_ScheduleHeaderId   IN   NUMBER,
                            x_GroupRec           IN   rlm_dp_sv.t_Group_rec,
                            x_ProcessStatus      IN   NUMBER ,
                            x_UpdateLevel        IN   VARCHAR2 DEFAULT 'GROUP');

/*===========================================================================
  PROCEDURE NAME:     GetConvertedLeadTime

  DESCRIPTION:        This procedure update the process status for the group

  PARAMETERS:         x_LeadTime     IN  NUMBER
                      x_LeadUOM      IN  NUMBER

  DESIGN REFERENCES:  RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
FUNCTION GetConvertedLeadTime (x_LeadTime  IN NUMBER,
                              x_LeadUOM   IN VARCHAR2)
RETURN NUMBER;
/*===========================================================================
  PROCEDURE NAME:     GetTPContext
  DESCRIPTION:        This procedure returns the tp group context.
                      This procedure returns a null x_ship_to_ece_locn_code,
                      and null x_inter_ship_to_ece_locn_code
  PARAMETERS:         x_sched_rec     IN  RLM_INTERFACE_HEADERS%ROWTYPE
                      x_group_rec     IN  t_Group_rec
                      x_customer_number OUT NOCOPY VARCHAR2
                      x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2
                      x_tp_group_code OUT NOCOPY VARCHAR2
  DESIGN REFERENCES:  RLMDPRDD.rtf
  CHANGE HISTORY:     created mnandell 03/08/99
===========================================================================*/
PROCEDURE GetTPContext( x_sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_group_rec  IN rlm_dp_sv.t_Group_rec,
                       x_customer_number OUT NOCOPY VARCHAR2,
                       x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_tp_group_code OUT NOCOPY VARCHAR2);
--<TPA_TPS>

/*===========================================================================
  PROCEDURE NAME:	CalculateIntransitQty

  DESCRIPTION:	This procedure fetches information  about supplier shipments
		which took place after the last customer recognized shipment
		to ship for the current schedule item

  PARAMETERS:	x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE
                x_Group_rec IN rlm_dp_sv.t_Group_rec

  DESIGN REFERENCES:	RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	created kvenkate 01/16/01
===========================================================================*/
FUNCTION  CalculateIntransitQty(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN rlm_dp_sv.t_Group_rec)
RETURN NUMBER;
--<TPA_PUBLIC_NAME>


FUNCTION GetAllIntransitQty(x_Sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec  IN rlm_dp_sv.t_Group_rec,
                            x_Source_Tab IN rlm_manage_demand_sv.t_Source_Tab)
RETURN NUMBER;
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:	InitializeMatchCritieria

  DESCRIPTION:		This procedure initializes the components of match_within_rec and
			match_across_rec to 'N', so we do not use any matching
	 		criteria when calculating in-transit quantities.  This procedure is
			called from GetAllIntransitQty and CalculateIntransitQty

  PARAMETERS:		x_match_within_rule IN OUT NOCOPY RLM_CORE_SV.t_Match_Rec
			x_match_across_rule IN OUT NOCOPY RLM_CORE_SV.t_Match_Rec

  CHANGE HISTORY:	created rlanka 01/14/02
===========================================================================*/
PROCEDURE InitializeMatchCriteria(x_match_within_rule IN OUT NOCOPY RLM_CORE_SV.t_Match_Rec,
				  x_match_across_rule IN OUT NOCOPY RLM_CORE_SV.t_Match_Rec);

/*=========================================================================
--global_atp
FUNCTION NAME:       IsATPItem

===========================================================================*/

FUNCTION IsATPItem (x_ship_from_org_id  IN NUMBER,
                    x_inventory_item_id IN NUMBER)
RETURN BOOLEAN;


/*===========================================================================

        PROCEDURE NAME:  ReportExc

===========================================================================*/
PROCEDURE ReportExc(      x_ExcpTab      IN   t_Match_tab);


/*===========================================================================

        PROCEDURE NAME:  printMessage

===========================================================================*/
PROCEDURE printMessage(   x_lookupCode   IN   VARCHAR2,
                          x_shipFrom     IN   VARCHAR2,
                          x_shipTo       IN   VARCHAR2,
                          x_customerItem IN   VARCHAR2);



FUNCTION GetIntransitAcrossOrgs(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
			        x_Group_rec IN rlm_dp_sv.t_Group_rec,
				x_cum_key_id IN NUMBER)
RETURN NUMBER;
--<TPA_PUBLIC_NAME>


/*===========================================================================
  PROCEDURE NAME:     Getvark_DNULL

  DESCRIPTION:       This procedure is called from RLMNETCH.rdf
                     to get the value of constant K_DNULL.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES: This function will be used by Netchange report.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     created  brana  02/20/03
===========================================================================*/

FUNCTION  GetvarK_DNULL
RETURN  DATE ;

END RLM_MANAGE_DEMAND_SV;

/
