--------------------------------------------------------
--  DDL for Package Body RLM_MANAGE_DEMAND_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_MANAGE_DEMAND_SV" as
/* $Header: RLMDPMDB.pls 120.12.12010000.3 2009/06/26 11:15:11 sunilku ship $*/
/*========================== rlm_manage_demand_sv ===========================*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
g_count NUMBER :=0; --Bugfix 7007638
--

/*===========================================================================

PROCEDURE NAME:    ManageDemand

===========================================================================*/

PROCEDURE ManageDemand(x_InterfaceHeaderId IN NUMBER,
                       x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                       x_ReturnStatus OUT NOCOPY NUMBER)
IS
  --
  v_Progress      	 VARCHAR2(30) := '010';
  v_SrcGroup_ref   	 t_Cursor_ref;
  v_SrcGroup_rec    	 rlm_dp_sv.t_Group_rec;
  v_SourcedDemand_Tab    t_MD_Tab;
  v_HeaderLockStatus     NUMBER;
  v_LineLockStatus       NUMBER;
  e_headerLocked         EXCEPTION;
  e_linesLocked          EXCEPTION;
  SrcRulesApplied        BOOLEAN;
  IsGroupProcessed	 BOOLEAN := FALSE;
  IsGroupError         	 BOOLEAN := FALSE;
  x_HeaderStatus   	 NUMBER;
  IsLineProcessed   	 BOOLEAN := FALSE;
  v_ReGroup_ref      	 t_Cursor_ref;
  v_Source_Tab           t_Source_Tab;
  l_ReturnStatus	 NUMBER;
  i		         NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ManageDemand');
     rlm_core_sv.dlog(C_DEBUG,'InterfaceHeaderId',x_InterfaceHeaderId);
  END IF;
  --
  rlm_message_sv.initialize_dependency('MANAGE_DEMAND');
  --
  x_ReturnStatus := rlm_core_sv.k_PROC_SUCCESS;
  x_Group_rec.IsSourced := FALSE;
  RLM_RD_SV.g_SourceTab.DELETE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'x_Sched_rec.sched_horizon_start_date',
                                x_Sched_rec.sched_horizon_start_date);
     rlm_core_sv.dlog(C_DEBUG, 'x_Sched_rec.sched_horizon_end_date',
                                x_Sched_rec.sched_horizon_end_date);
     rlm_core_sv.dlog(C_DEBUG, 'x_Sched_rec.schedule_purpose',
				x_Sched_rec.schedule_purpose);
     rlm_core_sv.dlog(C_DEBUG, 'x_Sched_rec.schedule_type',x_Sched_rec.schedule_type);
     rlm_core_sv.dlog(C_DEBUG, 'x_Sched_rec.header_id',x_Sched_rec.header_id);
  END IF;
  --
  x_HeaderStatus := x_sched_rec.process_status;
  --
  -- Apply Sourcing Rules to x_Group_rec
  --
  PopulateMD(x_Sched_rec, x_Group_rec, 'Y');
  --
  IF g_ManageDemand_tab.COUNT > 0 THEN
     --
     v_SourcedDemand_Tab.Delete;
     --
     CallSetups(x_Sched_rec,x_Group_rec);
     --
     PopulateCUMRec(x_Sched_rec, x_Group_rec);
     --
     RLM_TPA_SV.CUMToDiscrete(x_Sched_rec, x_Group_rec);
     --
     RLM_TPA_SV.ApplySourceRules(x_Sched_rec,x_Group_rec,
                                 v_SourcedDemand_Tab,v_Source_Tab);
     --
     ProcessTable(g_ManageDemand_Tab);
     --
     IF v_SourcedDemand_Tab.COUNT > 0 THEN
        --
        i := v_Source_Tab.FIRST;
        WHILE i IS NOT NULL LOOP
         RLM_RD_SV.g_SourceTab(RLM_RD_SV.g_SourceTab.COUNT+1) := v_Source_Tab(i);
         i := v_Source_Tab.NEXT(i);
        END LOOP;
        --
        ProcessTable(v_SourcedDemand_Tab);
	/*
	--
        IF x_Group_rec.setup_terms_rec.cum_org_level_code IN
             ('SHIP_TO_ALL_SHIP_FROMS', 'BILL_TO_ALL_SHIP_FROMS',
              'DELIVER_TO_ALL_SHIP_FROMS') THEN
         --
         g_AllIntransitQty := RLM_TPA_SV.GetAllIntransitQty(x_Sched_rec,x_Group_rec);
         --
        END IF;
        --
	*/
        x_Group_rec.IsSourced := TRUE;
        --
     ELSE
        --
        x_Group_rec.IsSourced := FALSE;
        --
     END IF;
     --
  END IF;
  --
  -- Note: Regrouping again as the sourcing rules would have added new lines
  -- which belong to a different group
  --
  IF x_Group_rec.IsSourced THEN
   --
   RLM_TPA_SV.InitializeMdGroup(x_Sched_rec, v_SrcGroup_ref, x_Group_rec);
   --
   WHILE FetchGroup(v_SrcGroup_ref, v_SrcGroup_rec) LOOP
    --
    IF NOT LockLines(x_Sched_rec.header_id,v_SrcGroup_rec) AND
 	(v_SrcGroup_rec.ship_from_org_id  <> x_Group_rec.industry_attribute15) THEN
     --
     RAISE e_linesLocked;
     --
    ELSE
     --
     ManageGroupDemand(x_Sched_rec, v_SrcGroup_rec, x_ReturnStatus);
     --
     IF v_SrcGroup_rec.blanket_number IS NOT NULL THEN
      --
      RLM_TPA_SV.DeriveRSO(x_Sched_rec, v_SrcGroup_rec, l_ReturnStatus);
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'DeriveRSO return status', l_ReturnStatus);
      END IF;
      --
      IF l_ReturnStatus <> rlm_core_sv.k_PROC_SUCCESS THEN
       --
       x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
       --
      END IF;
      --
     END IF;
     --
    END IF;
    --
   END LOOP;
   --
   CLOSE v_SrcGroup_ref;
   --
  ELSE /* not sourced */
   --
   ManageGroupDemand(x_Sched_rec, x_Group_rec, x_ReturnStatus);
   --
   IF x_Group_rec.blanket_number IS NOT NULL THEN
    --
    RLM_TPA_SV.DeriveRSO(x_Sched_rec, x_Group_rec, l_ReturnStatus);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'DeriveRSO return status', l_ReturnStatus);
    END IF;
    --
    IF l_ReturnStatus <> rlm_core_sv.k_PROC_SUCCESS THEN
     --
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
     --
    END IF;
    --
   END IF;
   --
  END IF;
  --
  --x_ReturnStatus := rlm_core_sv.k_PROC_SUCCESS;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_GroupError THEN
    --
    x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG, 'GROUP ERROR');
    END IF;
    --
  WHEN e_linesLocked THEN
    --
    x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
    rlm_message_sv.app_error(
         x_ExceptionLevel => rlm_message_sv.k_error_level,
         x_MessageName => 'RLM_LOCK_NOT_OBTAINED',
         x_InterfaceHeaderId => x_sched_rec.header_id,
         x_InterfaceLineId => NULL,
         x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
         x_ScheduleLineId => NULL,
         x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
         x_OrderLineId => NULL,
         --x_ErrorText => 'Lock Not Obtained'
         x_Token1 => 'SCHED_REF',
         x_Value1 => x_sched_rec.schedule_reference_num);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'RLM_LOCK_NOT_OBTAINED');
    END IF;
    --
  WHEN NO_DATA_FOUND THEN
    --
    x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'No header found with the headerID',
                                  x_InterfaceHeaderId);
       rlm_core_sv.dpop(C_SDEBUG, 'NO_DATA_FOUND');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
    rlm_message_sv.sql_error('rlm_manage_demand_sv.ManageDemand', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ManageDemand;

/*===========================================================================

PROCEDURE NAME:    ManageGroupDemand

===========================================================================*/

PROCEDURE ManageGroupDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_ReturnStatus OUT NOCOPY NUMBER)
IS
  --
  v_Progress      	 VARCHAR2(30) := '010';
  IsLineProcessed	 BOOLEAN := FALSE;
  IsGroupError         	 BOOLEAN := FALSE;
  --
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ManageGroupDemand');
       rlm_core_sv.dlog(C_DEBUG,'ship_from_org_id',x_Group_rec.ship_from_org_id);
       rlm_core_sv.dlog('ship_to_address_id', x_Group_rec.ship_to_address_id);
       rlm_core_sv.dlog('inventory_item_id', x_Group_rec.inventory_item_id);
       rlm_core_sv.dlog('customer_item_id', x_Group_rec.customer_item_id);
       rlm_core_sv.dlog(C_DEBUG, 'Order Header Id', x_Group_rec.order_header_id);
       rlm_core_sv.dlog(C_DEBUG, 'Blanket Number', x_Group_rec.blanket_number);
    END IF;
    --
    CallSetups(x_Sched_rec, x_Group_rec);
    --
    --PopulateLastReceiptRec(x_Sched_rec, x_Group_rec);
    --
    --PopulateCUMRec(x_Sched_rec, x_Group_rec);
    --
    PopulateMD(x_Sched_rec, x_Group_rec);
    --
    IF g_ManageDemand_tab.COUNT > 0 THEN
       --
       RLM_TPA_SV.UOMConversion(x_Group_rec);

       IF(UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis)<>'CUSTOMER_CUM') THEN
         --
         RLM_TPA_SV.CUMDiscrepancyCheck(x_Sched_rec, x_Group_rec);
         --
       END IF;

       --RLM_TPA_SV.CUMToDiscrete(x_Sched_rec, x_Group_rec);
       --
       RLM_TPA_SV.CalculateShipDate(x_Sched_rec,x_Group_rec);
       --
       IsLineProcessed := FALSE;
       RLM_TPA_SV.ApplyFFFFences(x_Sched_rec, x_Group_rec, IsLineProcessed);
       --
       IF x_Sched_rec.Schedule_type <> k_SEQUENCED THEN
         --
         --performance changes
         SortDemand;
         AggregateDemand(x_Group_rec);
         RLM_TPA_SV.RoundStandardPack(x_Sched_rec,x_Group_rec);
         --
       END IF;
       --
       ProcessTable(g_ManageDemand_Tab);
       --
       -- If fences are applied and some lines are set to fully processed.
       --
       IF IsLineProcessed THEN
        --
	IF x_Group_rec.blanket_number IS NOT NULL THEN
	 --
         IF (l_debug <> -1) THEN
	   rlm_core_sv.dlog(C_DEBUG, 'Blanket Version of Update', x_Group_rec.blanket_number);
         END IF;
         --
         UPDATE rlm_schedule_lines_all sl
         SET process_status = rlm_core_sv.k_PS_Processed
         WHERE header_id = x_Sched_rec.schedule_header_id
         AND   line_id IN (
                 SELECT schedule_line_id
                 FROM rlm_interface_lines il
                 WHERE il.header_id = x_sched_rec.header_id
                 AND  il.ship_from_org_id = x_Group_rec.ship_from_org_id
                 AND  il.ship_to_address_id = x_Group_rec.ship_to_address_id
                 AND  il.customer_item_id =  x_Group_rec.customer_item_id
                 AND  il.blanket_number = x_Group_rec.blanket_number
                 AND  il.process_status = rlm_core_sv.k_PS_Processed
                 );
         --
	ELSE
	 --
         IF (l_debug <> -1) THEN
	   rlm_core_sv.dlog(C_DEBUG, 'Sales order version of Update', x_Group_rec.order_header_id);
         END IF;
         --
         UPDATE rlm_schedule_lines_all sl
         SET process_status = rlm_core_sv.k_PS_Processed
         WHERE header_id = x_Sched_rec.schedule_header_id
         AND   line_id IN (
                  SELECT schedule_line_id
                  FROM rlm_interface_lines il
                  WHERE il.header_id = x_sched_rec.header_id
                  AND  il.ship_from_org_id = x_Group_rec.ship_from_org_id
                  AND  il.ship_to_address_id = x_Group_rec.ship_to_address_id
                  AND  il.customer_item_id =  x_Group_rec.customer_item_id
                  AND  il.order_header_id = x_Group_rec.order_header_id
                  AND  il.process_status = rlm_core_sv.k_PS_Processed
                  );
         --
         END IF;
         --
         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'# of schedule lines updated', SQL%ROWCOUNT);
         END IF;
         --
       END IF;
       --
    END IF;
    --
    x_ReturnStatus := rlm_core_sv.k_PROC_SUCCESS;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
EXCEPTION
     --
     WHEN e_GroupError THEN
          --
          x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'GroupError for',
                                x_Group_rec.ship_from_org_id);
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
             rlm_core_sv.dpop(C_SDEBUG);
          END IF;
          --
          raise e_GroupError;
          --
     WHEN OTHERS THEN
          --
          x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
          rlm_message_sv.sql_error('rlm_manage_demand_sv.ManageDemand',
                                        v_Progress);
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
             rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
          END IF;
          --
          raise;
         --
END ManageGroupDemand;

/*===========================================================================

PROCEDURE NAME:    PopulateLastReceiptRec

===========================================================================*/

PROCEDURE PopulateLastReceiptRec(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                 x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS
  --
  CURSOR c_LastReceipt IS
    SELECT  x_group_rec.customer_id,
            customer_item_id,
            inventory_item_id,
            ship_from_org_id,
            intrmd_ship_to_id intrmd_ship_to_address_id,
            ship_to_address_id,
            bill_to_address_id,
            cust_po_number purchase_order_number,
            primary_quantity,
            item_detail_quantity,
            start_date_time,
            industry_attribute1 cust_record_year,
            line_id,
            k_TRUE
    FROM    rlm_interface_lines
    WHERE   header_id = x_Sched_rec.header_id
    AND	    item_detail_type = k_SHIP_RECEIPT_INFO
    AND	    item_detail_subtype IN (k_SHIPMENT, k_RECEIPT)
    AND	    ship_to_address_id = x_Group_rec.ship_to_address_id
    AND	    inventory_item_id = x_Group_rec.inventory_item_id
    AND     qty_type_code = k_ACTUAL
    ORDER BY  SCHEDULE_DATE desc;
  --
  v_Progress    VARCHAR2(3) := '010';
  --
BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'PopulateLastReceiptRec');
     rlm_core_sv.dlog(C_DEBUG,'x_Sched_rec.Schedule_header_id',
                                x_Sched_rec.Schedule_header_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_to_address_id',
                                x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.inventory_item_id',
                                x_Group_rec.inventory_item_id);
  END IF;
  --
  OPEN c_LastReceipt;
  --
  FETCH c_LastReceipt INTO g_LastReceipt_rec;
  --
  IF c_LastReceipt%NOTFOUND THEN
    --
    g_LastReceipt_rec.found := k_FALSE;
    --
  END IF;
  --
  CLOSE c_LastReceipt;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'g_LastReceipt_rec.primary_quantity',
                                     g_LastReceipt_rec.primary_quantity);
     rlm_core_sv.dlog(C_DEBUG,'g_LastReceipt_rec.cust_record_year',
                                     g_LastReceipt_rec.cust_record_year);
     rlm_core_sv.dlog(C_DEBUG,'g_LastReceipt_rec.start_date_time',
                                     g_LastReceipt_rec.start_date_time);
     rlm_core_sv.dlog(C_DEBUG,'g_LastReceipt_rec.found', g_LastReceipt_rec.found);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.PopulateLastReceiptRec',
                                v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END PopulateLastReceiptRec;

/*===========================================================================

PROCEDURE NAME:    PopulateCUMRec

===========================================================================*/

PROCEDURE PopulateCUMRec(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS
--Created cursor for Bugfix 7007638
  CURSOR c_CUMRec IS
    SELECT  x_group_rec.customer_id,
            customer_item_id,
            inventory_item_id,
            ship_from_org_id,
            intrmd_ship_to_id intrmd_ship_to_address_id,
            ship_to_address_id,
            bill_to_address_id,
            cust_po_number purchase_order_number,
            primary_quantity,
            item_detail_quantity,
            start_date_time,
            industry_attribute1 cust_record_year,
            line_id,
            k_TRUE
    FROM    rlm_interface_lines
    WHERE	header_id = x_Sched_rec.header_id
      AND	item_detail_type = k_SHIP_RECEIPT_INFO
      AND	item_detail_subtype = k_CUM
      AND   ship_from_org_id   = x_Group_rec.ship_from_org_id
      AND   ship_to_address_id = x_Group_rec.ship_to_address_id
      AND	inventory_item_id = x_Group_rec.inventory_item_id
      AND   customer_item_id  = x_Group_rec.customer_item_id
  ORDER BY  start_date_time desc;
  --

  v_Progress          VARCHAR2(3)  := '010';
  v_Count		      NUMBER := 1;  --Bugfix 7007638

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'PopulateCUMRec');
     rlm_core_sv.dlog(C_DEBUG,'x_Sched_rec.Schedule_header_id',
                                  x_Sched_rec.Schedule_header_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_to_address_id',
                                  x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.inventory_item_id',
                                  x_Group_rec.inventory_item_id);
  END IF;
  --Bugfix 7007638 Start --Modified Select statment into cursor to fetch more than one Shp/Rcv record per group
                         --Record type is converted to PL/SQL table
  g_CUM_tab.DELETE;
  --
  OPEN c_CUMRec;
  --
   LOOP
    FETCH c_CUMRec INTO g_CUM_rec;
    EXIT WHEN c_CUMRec%NOTFOUND;

     g_CUM_tab(v_Count).customer_id               :=   g_CUM_rec.customer_id;
     g_CUM_tab(v_Count).customer_item_id          :=   g_CUM_rec.customer_item_id;
     g_CUM_tab(v_Count).inventory_item_id         :=   g_CUM_rec.inventory_item_id;
     g_CUM_tab(v_Count).ship_from_org_id          :=   g_CUM_rec.ship_from_org_id;
     g_CUM_tab(v_Count).intrmd_ship_to_address_id :=   g_CUM_rec.intrmd_ship_to_address_id;
     g_CUM_tab(v_Count).ship_to_address_id        :=   g_CUM_rec.ship_to_address_id;
     g_CUM_tab(v_Count).bill_to_address_id        :=   g_CUM_rec.bill_to_address_id;
     g_CUM_tab(v_Count).purchase_order_number     :=   g_CUM_rec.purchase_order_number;
     g_CUM_tab(v_Count).primary_quantity          :=   g_CUM_rec.primary_quantity;
     g_CUM_tab(v_Count).item_detail_quantity      :=   g_CUM_rec.item_detail_quantity;
     g_CUM_tab(v_Count).start_date_time           :=   g_CUM_rec.start_date_time;
     g_CUM_tab(v_Count).cust_record_year          :=   g_CUM_rec.cust_record_year;
     g_CUM_tab(v_Count).line_id                   :=   g_CUM_rec.line_id;
     g_CUM_tab(v_Count).found                     :=   g_CUM_rec.found;

    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').purchase_order_number', g_CUM_tab(v_Count).purchase_order_number);
      rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').primary_quantity', g_CUM_tab(v_Count).primary_quantity);
      rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').item_detail_quantity', g_CUM_tab(v_Count).item_detail_quantity);
      rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').start_date_time', g_CUM_tab(v_Count).start_date_time);
      rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').cust_record_year', g_CUM_tab(v_Count).cust_record_year);
      rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').found', g_CUM_tab(v_Count).found);
    END IF;

    v_Count := v_Count + 1;

   END LOOP;
  --
  CLOSE c_CUMRec;
  --Bugfix 7007638 End

  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab.COUNT',g_CUM_tab.COUNT);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION

--Commented exceptions 'NO_DATA_FOUND' and 'TOO_MANY_ROWS' as part of Bugfix 7007638

/*  WHEN NO_DATA_FOUND THEN
     --
     g_CUM_rec.found := k_FALSE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'g_CUM_rec.found', g_CUM_rec.found);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
  WHEN TOO_MANY_ROWS THEN
     --
     rlm_message_sv.app_error(
        x_ExceptionLevel => rlm_message_sv.k_error_level,
        x_MessageName => 'RLM_MULTIPLE_ITM_CUM_DTL_FOUND',
        x_InterfaceHeaderId => x_sched_rec.header_id,
        x_InterfaceLineId => NULL,
        x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
        x_ScheduleLineId => NULL,
        x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
        x_OrderLineId => NULL,
        x_Token1 => 'SHIP_FROM',
        x_Value1 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id),
        x_Token2 => 'SHIP_TO',
        x_Value2 => rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id),
        x_Token3 => 'CITEM',
        x_Value3 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id));
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Too many rows found for item
                 detail type 4 and subtype = cumulative');
        rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: RLM_MULTIPLE_ITM_CUM_DTL_FOUND');
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     RAISE e_GroupError;
     --*/
  WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_manage_demand.PopulateCUMRec',
                              v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;

END PopulateCUMRec;

/*===========================================================================

PROCEDURE NAME:    PopulateMD

===========================================================================*/

PROCEDURE PopulateMD(x_Sched_rec    IN RLM_INTERFACE_HEADERS%ROWTYPE,
		     x_Group_rec    IN rlm_dp_sv.t_Group_rec,
                     x_IncludeCUM   IN VARCHAR2)
IS
  --
  CURSOR c_Demand IS
    SELECT	*
    FROM	rlm_interface_lines_all
    WHERE	header_id = x_Sched_rec.header_id
    AND		ship_from_org_id = x_Group_rec.ship_from_org_id
    AND		ship_to_address_id = x_Group_rec.ship_to_address_id
    AND         customer_item_id = x_Group_rec.customer_item_id
    AND         inventory_item_id = x_Group_rec.inventory_item_id
    AND		item_detail_type IN (k_PAST_DUE_FIRM, k_FIRM_DEMAND,
                  k_FORECAST_DEMAND, k_MRP_FORECAST,k_FIRM_DEMAND)
    AND		process_status = rlm_core_sv.k_PS_AVAILABLE
    ORDER BY	START_DATE_TIME;

  CURSOR c_DemandCum IS
    SELECT	*
    FROM	rlm_interface_lines_all
    WHERE	header_id = x_Sched_rec.header_id
    AND		ship_from_org_id = x_Group_rec.ship_from_org_id
    AND		ship_to_address_id = x_Group_rec.ship_to_address_id
    AND         customer_item_id = x_Group_rec.customer_item_id
    AND         inventory_item_id = x_Group_rec.inventory_item_id
    AND		item_detail_type IN (k_PAST_DUE_FIRM, k_FIRM_DEMAND,
                     k_FORECAST_DEMAND, k_MRP_FORECAST,k_SHIP_RECEIPT_INFO)
    AND		process_status = rlm_core_sv.k_PS_AVAILABLE
    ORDER BY	START_DATE_TIME;

  --
  v_Demand_rec		rlm_interface_lines%ROWTYPE;
  v_Count		NUMBER := 1;
  v_Progress		VARCHAR2(3)  := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'PopulateMD');
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_from_org_id',
                                 x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_to_address_id',
                                 x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.inventory_item_id',
                                 x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.customer_item_id',
                                 x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(C_DEBUG,'x_IncludeCUM', x_IncludeCUM);
  END IF;
  --
  g_ManageDemand_tab.DELETE;

  IF (x_IncludeCUM = 'Y') THEN

    OPEN c_DemandCum;
    --
    LOOP
      FETCH c_DemandCum INTO v_Demand_rec;
      EXIT WHEN c_DemandCum%NOTFOUND;
      g_ManageDemand_tab(v_Count) := v_Demand_rec;
      g_ManageDemand_tab(v_Count).program_id := NULL;
      g_ManageDemand_tab(v_Count).program_application_id := NULL;
      v_Count := v_Count + 1;
    END LOOP;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.COUNT',g_ManageDemand_tab.COUNT);
    END IF;
    --
    CLOSE c_DemandCum;
    --
  ELSE
    --
    OPEN c_Demand;
    --
    LOOP
      FETCH c_Demand INTO v_Demand_rec;
      EXIT WHEN c_Demand%NOTFOUND;
      g_ManageDemand_tab(v_Count) := v_Demand_rec;
      g_ManageDemand_tab(v_Count).program_id := NULL;
      g_ManageDemand_tab(v_Count).program_application_id := NULL;
      v_Count := v_Count + 1;
    END LOOP;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.COUNT',g_ManageDemand_tab.COUNT);
    END IF;
    --
    CLOSE c_Demand;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_manage_demand.PopulateMD',v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END PopulateMD;

/*===========================================================================

PROCEDURE NAME:    UOMConversion

===========================================================================*/

PROCEDURE UOMConversion(x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS

  v_Count		NUMBER := 1;
  v_CustomerUOMCode	VARCHAR2(30) := NULL;
  v_ReturnStatus	VARCHAR2(30) := 'SUCCESS';
  v_Progress		VARCHAR2(3)  :='010';

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'UOMConversion');
     -- note: need to find customer_uom_code?
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.UOMConversion', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END UOMConversion;


/*===========================================================================

PROCEDURE NAME:    CUMDiscrepancyCheck

===========================================================================*/

PROCEDURE CUMDiscrepancyCheck( x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS
  --
  v_ReturnStatus        VARCHAR2(30) := 'SUCCESS';
  v_Progress            VARCHAR2(3) := '010';
  v_cum_key_record      rlm_cum_sv.cum_key_attrib_rec_type;
  v_cum_record          rlm_cum_sv.cum_rec_type;
  cust_cum_start_date   DATE;
  cust_cum_qty          NUMBER;
  e_NoCUMAtItem         EXCEPTION;
  e_Nocumkey            EXCEPTION;
  e_CalCumkeyAPIFailed  EXCEPTION;
  e_CalSupCumAPIFailed  EXCEPTION;
  e_CUMDiscrepancy      EXCEPTION;
  e_CUMDiscrepancyAll   EXCEPTION;
  v_Intransit           NUMBER := 0;
  v_supQty              NUMBER := 0;
  --
  v_InterfaceLineId	NUMBER;
  v_current_rec         NUMBER;        --Bugfix 7007638
  v_control_text        VARCHAR2(100); --Bugfix 7007638
  v_control_value       VARCHAR2(100); --Bugfix 7007638
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CUMDiscrepancyCheck');
     rlm_core_sv.dlog(C_DEBUG,'cum_control_code',
                            x_Group_rec.setup_terms_rec.cum_control_code);
  END IF;
  --
  v_Progress  := '020';
  --
  FOR v_Count IN 1..g_CUM_tab.COUNT LOOP --Bugfix 7007638

  BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').found',g_CUM_tab(v_Count).found);  --Bugfix 7007638
     rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').primary_quantity',g_CUM_tab(v_Count).primary_quantity); --Bugfix 7007638
  END IF;
  -- This assignment is done in order to get the current record during the error processing
  v_current_rec := v_Count; --Bugfix 7007638
  --
  --Bugfix 7007638  --replaced all occurrences of record type g_CUM_rec with PL/SQL table g_CUM_tab(v_Count).
  IF g_CUM_tab(v_Count).found = k_TRUE AND
     x_Group_rec.setup_terms_rec.cum_control_code <> 'NO_CUM' AND
     g_CUM_tab(v_Count).primary_quantity > 0 THEN

     --Bugfix 7007638
     IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
       rlm_message_sv.get_msg_text(
	  		x_message_name	=> 'RLM_CUM_CONTROL_PO',
	  		x_text		    => v_control_text);
        v_control_value := g_CUM_tab(v_Count).purchase_order_number;
     ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
       rlm_message_sv.get_msg_text(
	  		x_message_name	=> 'RLM_CUM_CONTROL_RY',
	  		x_text		    => v_control_text);
        v_control_value := g_CUM_tab(v_Count).cust_record_year;
     ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_ONLY') THEN
       rlm_message_sv.get_msg_text(
	  		x_message_name	=> 'RLM_CUM_CONTROL_DATE',
	  		x_text		    => v_control_text);
        v_control_value := g_CUM_tab(v_Count).start_date_time;
     END IF;
     --Bugfix 7007638
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.calc_cum_flag',
                                  x_Group_rec.setup_terms_rec.calc_cum_flag);
        END IF;
        --
        IF x_Group_rec.setup_terms_rec.calc_cum_flag = 'N' THEN
           --
           raise e_NoCUMAtItem;
           --
        END IF;
        --
        v_cum_key_record.customer_id  :=
                         g_CUM_tab(v_Count).customer_id;
        v_cum_key_record.customer_item_id :=
                         g_CUM_tab(v_Count).customer_item_id;
        v_cum_key_record.inventory_item_id :=
                         g_CUM_tab(v_Count).inventory_item_id;
        v_cum_key_record.ship_from_org_id :=
                         g_CUM_tab(v_Count).ship_from_org_id;
        v_cum_key_record.intrmd_ship_to_address_id :=
                         g_CUM_tab(v_Count).intrmd_ship_to_address_id;
        v_cum_key_record.ship_to_address_id :=
                         g_CUM_tab(v_Count).ship_to_address_id;
        v_cum_key_record.bill_to_address_id :=
                         g_CUM_tab(v_Count).bill_to_address_id;
        v_cum_key_record.purchase_order_number :=
                         g_CUM_tab(v_Count).purchase_order_number;
        v_cum_key_record.cum_start_date :=
                         g_CUM_tab(v_Count).start_date_time;
        v_cum_key_record.cust_record_year :=
                         g_CUM_tab(v_Count).cust_record_year;
        v_cum_key_record.create_cum_key_flag   := 'N';
        --
        -- currently po date is sent in as cust_po_date
        -- Open issue : need to check with Kathleen about warning for po date
        --v_cum_key_record.po_effectivity_start_date :=
        --                            g_ManageDemand_tab(i).cust_po_date;
        --
        v_Progress            := '030';
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.customer_id',
                                      v_cum_key_record.customer_id);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.customer_item_id',
                                      v_cum_key_record.customer_item_id);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.inventory_item_id',
                                      v_cum_key_record.inventory_item_id);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.ship_from_org_id',
                                      v_cum_key_record.ship_from_org_id);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.intrmd_ship_to_address_id'
                              ,v_cum_key_record.intrmd_ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.ship_to_address_id',
                                  v_cum_key_record.ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.bill_to_address_id',
                                v_cum_key_record.bill_to_address_id);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.purchase_order_number',
                                   v_cum_key_record.purchase_order_number);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.cust_record_year',
                                  v_cum_key_record.cust_record_year);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.cum_start_date'
                           ,v_cum_key_record.cum_start_date);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_key_record.create_cum_key_flag',
                            v_cum_key_record.create_cum_key_flag);
           rlm_core_sv.dlog(C_DEBUG,'call cum api for calculate cum key');
        END IF;
        --
        RLM_TPA_SV.CalculateCumKey(v_cum_key_record,v_cum_record);
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_cum_record.record_return_status',
                                     v_cum_record.record_return_status);
        END IF;
        --
        IF v_cum_record.record_return_status THEN
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.msg_data',
                                     v_cum_record.msg_data);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.cum_key_id',
                                     v_cum_record.cum_key_id);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.cum_start_date',
                                     v_cum_record.cum_start_date);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.shipped_quantity',
                                     v_cum_record.shipped_quantity);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.actual_shipment_date',
                                     v_cum_record.actual_shipment_date);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.cum_key_created_flag',
                                     v_cum_record.cum_key_created_flag);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.cum_qty',
                                     v_cum_record.cum_qty);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.as_of_date_cum_qty',
                                     v_cum_record.as_of_date_cum_qty);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.cum_qty_to_be_accumulated',
                                     v_cum_record.cum_qty_to_be_accumulated);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.last_cum_qty_update_date',
                                     v_cum_record.last_cum_qty_update_date);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.cust_uom_code',
                                     v_cum_record.cust_uom_code);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.use_ship_incl_rule_flag',
                                     v_cum_record.use_ship_incl_rule_flag);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.shipment_rule_code',
                                     v_cum_record.shipment_rule_code);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.yesterday_time_cutoff'
                                     ,v_cum_record.yesterday_time_cutoff);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.last_update_date',
                                     v_cum_record.last_update_date);
              rlm_core_sv.dlog(C_DEBUG,'v_cum_record.as_of_date_time',
                                     v_cum_record.as_of_date_time);
           END IF;
           --
           IF v_cum_record.cum_key_id IS NULL THEN
             --
             v_Progress            := '060';
             raise e_NoCumKey;
             --
           END IF;
           --
        ELSE
          --
          raise e_CalCumKeyAPIFAiled;
          --
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_Intransit', v_Intransit);
           rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').primary_quantity',
                                      g_CUM_tab(v_Count).primary_quantity);
           rlm_core_sv.dlog(C_DEBUG,'v_cum_record.cum_qty',
                                      v_cum_record.cum_qty);
        END IF;
        --
        IF x_Group_rec.setup_terms_rec.cum_org_level_code NOT IN (
                                         'SHIP_TO_ALL_SHIP_FROMS',
                                         'BILL_TO_ALL_SHIP_FROMS',
                                         'DELIVER_TO_ALL_SHIP_FROMS') THEN
          --
          g_count := v_Count; --Bugfix 7007638
          --
          v_Intransit := RLM_TPA_SV.CalculateIntransitQty(x_Sched_rec,
                                                          x_Group_rec);
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'v_Intransit', v_Intransit);
          END IF;
          --
          v_SupQty := v_cum_record.cum_qty +
                      v_cum_record.cum_qty_to_be_accumulated +
                      NVL(v_cum_record.cum_qty_after_cutoff,0) - v_Intransit;
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'v_SupQty', v_SupQty);
          END IF;
          --
          IF g_CUM_tab(v_Count).primary_quantity <> v_SupQty THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'NOT ALL');
            END IF;
            --
            v_Progress := '120';
            raise e_CUMDiscrepancy;
            --
          END IF;
          --
        ELSE
         --
         g_count := v_Count; --Bugfix 7007638
         --
	     g_AllIntransitQty := RLM_TPA_SV.GetIntransitAcrossOrgs(x_Sched_rec, x_Group_rec, v_cum_record.cum_key_id);
	     --
	      IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'g_AllIntransitQty', g_AllIntransitQty);
          END IF;
          --
          v_SupQty := v_cum_record.cum_qty +
                      v_cum_record.cum_qty_to_be_accumulated +
                     NVL(v_cum_record.cum_qty_after_cutoff,0)
                     - NVL(g_AllIntransitQty,0);
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'v_SupQty', v_SupQty);
          END IF;
          --
          IF g_CUM_tab(v_Count).item_detail_quantity <> v_SupQty THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count||').item_detail_quantity',
                                         g_CUM_tab(v_Count).item_detail_quantity);
            END IF;
            --
            v_Progress := '120';
            RAISE e_CUMDiscrepancyAll;
            --
          END IF;
          --
        END IF;
        --
  END IF;
  --

EXCEPTION
   --
  WHEN e_CUMDiscrepancy THEN
     --
     -- Bug 2778186: Pick one line as a rep. for this group, so we
     -- can use this to determine SF/ST/CI information
     --
     BEGIN
      --
      SELECT line_id
      INTO v_InterfaceLineId
      FROM rlm_interface_lines
      WHERE header_id = x_Sched_rec.header_id
      AND ship_from_org_id = x_Group_rec.ship_from_org_id
      AND ship_to_address_id = x_Group_rec.ship_to_address_id
      AND customer_item_id = x_Group_rec.customer_item_id
      AND rownum = 1;
      --
      EXCEPTION
       --
       WHEN NO_DATA_FOUND THEN
        v_InterfaceLineId := NULL;
       --
     END;
     --
     rlm_message_sv.app_error(
                  x_ExceptionLevel => rlm_message_sv.k_warn_level,
                  x_MessageName => 'RLM_CUM_QTY_DISCREPANCY',
                  x_InterfaceHeaderId => x_sched_rec.header_id,
                  x_InterfaceLineId => v_InterfaceLineId,
                  x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                  x_ScheduleLineId => NULL,
                  x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                  x_OrderLineId => NULL,
		  x_GroupInfo => TRUE,
                  x_Token1 => 'CUSTCM',
                  x_Value1 => g_CUM_tab(v_current_rec).primary_quantity, --Bugfix 7007638
                  x_Token2 => 'GROUP',                                   --Bugfix 7007638
                  x_value2 => '-'||v_control_text||' '||                 --Bugfix 7007638
                              rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                              rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                              rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                              v_control_value,
                  x_Token3 => 'SUPCUM',
                  x_Value3 => v_SupQty);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'WARNING : CUM Discrepancy found between customer cum and supplier cum');
 	    rlm_core_sv.dlog(C_DEBUG, 'v_InterfaceLineId', v_InterfaceLineId);
     END IF;
     --
  WHEN e_CUMDiscrepancyAll THEN
     --
     -- Bug 2778186: Pick one line as a rep. for this group, so we
     -- can use this to determine SF/ST/CI information
     --
     BEGIN
      --
      SELECT line_id
      INTO v_InterfaceLineId
      FROM rlm_interface_lines
      WHERE header_id = x_Sched_rec.header_id
      AND ship_from_org_id = x_Group_rec.ship_from_org_id
      AND ship_to_address_id = x_Group_rec.ship_to_address_id
      AND customer_item_id = x_Group_rec.customer_item_id
      AND rownum = 1;
      --
      EXCEPTION
       --
       WHEN NO_DATA_FOUND THEN
        v_InterfaceLineId := NULL;
       --
     END;
     --
     rlm_message_sv.app_error(
                  x_ExceptionLevel => rlm_message_sv.k_warn_level,
                  x_MessageName => 'RLM_CUM_QTY_DISCREPANCY',
                  x_InterfaceHeaderId => x_sched_rec.header_id,
                  x_InterfaceLineId => v_InterfaceLineId,
                  x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                  x_ScheduleLineId => NULL,
                  x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                  x_OrderLineId => NULL,
		  x_GroupInfo  => TRUE,
                  x_Token1 => 'CUSTCM',
                  x_Value1 => g_CUM_tab(v_current_rec).item_detail_quantity, --Bugfix 7007638
                  x_Token2 => 'GROUP',                                       --Bugfix 7007638
                  x_value2 => '-'||v_control_text||' '||                     --Bugfix 7007638
                              rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                              rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                              rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                              v_control_value,
                  x_Token3 => 'SUPCUM',
                  x_Value3 => v_SupQty);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'WARNING : CUM Discrepancy found between customer cum and supplier cum');
  	    rlm_core_sv.dlog(C_DEBUG, 'v_InterfaceLineId', v_InterfaceLineId);
     END IF;
     --
  WHEN e_NoCumKey THEN
    --
    -- Bug 2778186: Pick one line as a rep. for this group, so we
    -- can use this to determine SF/ST/CI information
    --
    BEGIN
     --
     SELECT line_id
     INTO v_InterfaceLineId
     FROM rlm_interface_lines
     WHERE header_id = x_Sched_rec.header_id
     AND ship_from_org_id = x_Group_rec.ship_from_org_id
     AND ship_to_address_id = x_Group_rec.ship_to_address_id
     AND customer_item_id = x_Group_rec.customer_item_id
     AND rownum = 1;
     --
     EXCEPTION
       --
       WHEN NO_DATA_FOUND THEN
        v_InterfaceLineId := NULL;
       --
    END;
    --
    rlm_message_sv.app_error(
                      x_ExceptionLevel => rlm_message_sv.k_warn_level,
                      x_MessageName => 'RLM_CUM_KEY_MISSING',
                      x_InterfaceHeaderId => x_sched_rec.header_id,
                      x_InterfaceLineId => v_InterfaceLineId,
                      x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                      x_ScheduleLineId => NULL,
                      x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                      x_OrderLineId => NULL,
		              x_GroupInfo  => TRUE,
                      x_Token1 => 'GROUP',                                   --Bugfix 7007638
                      x_value1 => '-'||v_control_text||' '||                 --Bugfix 7007638
                                  rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                                  rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                                  rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                                  v_control_value);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog('No CUM Key Found need not calculate the supplier cum');
       rlm_core_sv.dlog(C_DEBUG, 'v_InterfaceLineId', v_InterfaceLineId);
    END IF;
    --
  WHEN e_NoCUMAtItem  THEN
    --
    -- Bug 2778186: Pick one line as a rep. for this group, so we
    -- can use this to determine SF/ST/CI information
    --
    BEGIN
     --
     SELECT line_id
     INTO v_InterfaceLineId
     FROM rlm_interface_lines
     WHERE header_id = x_Sched_rec.header_id
     AND ship_from_org_id = x_Group_rec.ship_from_org_id
     AND ship_to_address_id = x_Group_rec.ship_to_address_id
     AND customer_item_id = x_Group_rec.customer_item_id
     AND rownum = 1;
     --
     EXCEPTION
      --
      WHEN NO_DATA_FOUND THEN
       v_InterfaceLineId := NULL;
      --
    END;
    --
    rlm_message_sv.app_error(
        x_ExceptionLevel => rlm_message_sv.k_warn_level,
        x_MessageName => 'RLM_CUM_FOR_ITEM_NOT_ENABLED',
        x_InterfaceHeaderId => x_sched_rec.header_id,
        x_InterfaceLineId => v_InterfaceLineId,
        x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
        x_ScheduleLineId => NULL,
        x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
        x_OrderLineId => NULL,
	    x_GroupInfo   => TRUE,
--        x_Token1 => 'CITEM',
--        x_Value1 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id));
        x_Token1 => 'GROUP',                                   --Bugfix 7007638
        x_value1 => '-'||v_control_text||' '||                 --Bugfix 7007638
                    rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                    rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                    rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                    v_control_value);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dlog(C_DEBUG, 'v_InterfaceLineId', v_InterfaceLineId);
       rlm_core_sv.dlog(C_DEBUG,'CUM overwritten at item level no cum required');
    END IF;
    --
  END;
 END LOOP; --Bugfix 7007638
 --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
   --
EXCEPTION
   --
  WHEN e_CalCumKeyAPIFailed THEN
    --
    -- Bug 2778186: Pick one line as a rep. for this group, so we
    -- can use this to determine SF/ST/CI information
    --
    BEGIN
     --
     SELECT line_id
     INTO v_InterfaceLineId
     FROM rlm_interface_lines
     WHERE header_id = x_Sched_rec.header_id
     AND ship_from_org_id = x_Group_rec.ship_from_org_id
     AND ship_to_address_id = x_Group_rec.ship_to_address_id
     AND customer_item_id = x_Group_rec.customer_item_id
     AND rownum = 1;
     --
     EXCEPTION
      --
      WHEN NO_DATA_FOUND THEN
       v_InterfaceLineId := NULL;
      --
    END;
    --
    rlm_message_sv.sql_error('rlm_manage_demand_sv.CUMDiscrepancyCheck',v_Progress);
    --
    rlm_message_sv.app_error(
                  x_ExceptionLevel => rlm_message_sv.k_error_level,
                  x_MessageName => 'RLM_CALC_CUM_KEY_FAILED',
                  x_ChildMessageName => v_cum_record.msg_name,
                  x_InterfaceHeaderId => x_sched_rec.header_id,
                  x_InterfaceLineId => v_InterfaceLineId,
                  x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                  x_ScheduleLineId => NULL,
                  x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                  x_OrderLineId => NULL,
		          x_GroupInfo   => TRUE,
                  x_Token1 => 'GROUP',                                   --Bugfix 7007638
                  x_value1 => '-'||v_control_text||' '||                 --Bugfix 7007638
                              rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                              rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                              rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                              v_control_value,
                  x_Token2 => 'ERRORMSG',
                  x_Value2 => v_cum_record.msg_data);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'CalculateCUMkey API Failed',v_cum_record.msg_data);
       rlm_core_sv.dlog(C_DEBUG, 'v_InterfaceLineId', v_InterfaceLineId);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    raise e_GroupError;
    --
  WHEN e_CalSupCumAPIFailed THEN /* This is never raised */
    --
    rlm_message_sv.sql_error('rlm_manage_demand_sv.CUMDiscrepancyCheck', v_Progress);
    --
    rlm_message_sv.app_error(
                  x_ExceptionLevel => rlm_message_sv.k_error_level,
                  x_MessageName => 'RLM_CALC_SUPCUM_KEY_FAILED',
                  x_ChildMessageName => v_cum_record.msg_name,
                  x_InterfaceHeaderId => x_sched_rec.header_id,
                  x_InterfaceLineId => NULL,
                  x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                  x_ScheduleLineId => NULL,
                  x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                  x_OrderLineId => NULL,
                  x_Token1 => 'ERROR',
                  x_Value1 => v_cum_record.msg_data);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'CalculateSupplierCUM API Failed',
                                   v_cum_record.msg_data);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    raise e_GroupError;
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_manage_demand_sv.CUMDiscrepancyCheck',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END CUMDiscrepancyCheck;


/*===========================================================================

PROCEDURE NAME:    SetOperation

===========================================================================*/

PROCEDURE SetOperation(x_ManageDemand_rec IN OUT NOCOPY rlm_interface_lines%ROWTYPE,
                       x_Operation IN NUMBER)
IS
  --
  v_Progress		VARCHAR2(3)  :='010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'SetOperation');
     rlm_core_sv.dlog(C_DEBUG,'x_Operation',x_Operation);
     rlm_core_sv.dlog(C_DEBUG,'program_id',x_ManageDemand_rec.program_id);
  END IF;
  --
  IF x_Operation = k_DELETE THEN
    --
    x_ManageDemand_rec.program_id := x_Operation;
    --
    /* Commented out for bug 3320743
    IF nvl(x_ManageDemand_rec.program_id,k_NULL) = k_INSERT THEN
      x_ManageDemand_rec.program_id := NULL;
    ELSE
      x_ManageDemand_rec.program_id := x_Operation;
    END IF; */
    --
  ELSIF x_Operation = k_UPDATE THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_Operation',x_Operation);
    END IF;
    --
    IF nvl(x_ManageDemand_rec.program_id,k_NULL) NOT IN (k_INSERT, k_DELETE)
    THEN
      x_ManageDemand_rec.program_id := x_Operation;
    END IF;
  ELSIF x_Operation = k_INSERT THEN
    SELECT	rlm_interface_lines_s.nextval
    INTO	x_ManageDemand_rec.line_id
    FROM	DUAL;
    x_ManageDemand_rec.program_id := x_Operation;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'program_id',x_ManageDemand_rec.program_id);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_manage_demand_sv.SetOperation', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END SetOperation;

/*===========================================================================

PROCEDURE NAME:    CUMToDiscrete

===========================================================================*/

PROCEDURE CUMToDiscrete(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                        x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS
  --
  v_current_rec		NUMBER;
  v_EarlierDiscreteQty	NUMBER := 0;
  v_Progress		VARCHAR2(3) := '010';
  v_cum_key_record      RLM_CUM_SV.cum_key_attrib_rec_type;
  v_cum_record          RLM_CUM_SV.cum_rec_type;
  v_supplier_total_qty  NUMBER DEFAULT 0;
  e_noSupplierCum       EXCEPTION;
  e_UomMismatch         EXCEPTION; -- Bug 4468377
  v_control_text        VARCHAR2(100); --Bugfix 7007638
  v_control_value       VARCHAR2(100); --Bugfix 7007638
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CUMToDiscrete');
     rlm_core_sv.dlog(C_DEBUG,'v_EarlierDiscreteQty',v_EarlierDiscreteQty);
     rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab.COUNT',g_CUM_tab.COUNT);  --Bugfix 7007638
  END IF;

--Bugfix 7007638 --Replaced all occurrences of record type g_CUM_rec with PL/SQL table g_CUM_tab.

IF g_CUM_tab.COUNT > 0 THEN --Bugfix 7007638

 FOR v_Count1 IN 1..g_CUM_tab.COUNT LOOP --Bugfix 7007638
  --
  v_cum_record.cum_key_id := NULL;
  v_EarlierDiscreteQty := 0; --Bugfix 7007638
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_EarlierDiscreteQty',v_EarlierDiscreteQty);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.cum_control_code',x_Group_rec.setup_terms_rec.cum_control_code);
     rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count1||').purchase_order_number',g_CUM_tab(v_Count1).purchase_order_number);
     rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count1||').cust_record_year',g_CUM_tab(v_Count1).cust_record_year);
  END IF;
  --
  FOR v_Count IN 1..g_ManageDemand_tab.COUNT LOOP
    --Displaying values as part of Bugfix 7007638
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab('||v_Count||').qty_type_code', g_ManageDemand_tab(v_Count).qty_type_code);
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab('||v_Count||').cust_po_number',g_ManageDemand_tab(v_Count).cust_po_number);
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab('||v_Count||').industry_attribute1',g_ManageDemand_tab(v_Count).industry_attribute1);
     END IF;

   --Bugfix 7007638 --Added IF Condition
    IF (x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') AND
        g_ManageDemand_tab(v_Count).cust_po_number = g_CUM_tab(v_Count1).purchase_order_number) OR
       (x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') AND
        g_ManageDemand_tab(v_Count).industry_attribute1 = g_CUM_tab(v_Count1).cust_record_year) OR
       (x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_ONLY')) THEN

    -- This assignment is done in order to get the current record during the error processing
    --
    v_current_rec := v_Count;
    --
    IF g_ManageDemand_tab(v_Count).qty_type_code = k_CUMULATIVE
      AND g_ManageDemand_tab(v_count).item_detail_type IN (k_PAST_DUE_FIRM,k_FIRM_DEMAND,k_FORECAST_DEMAND,k_MRP_FORECAST)
    THEN
      --
            --Bugfix 7007638 --Replaced all occurrences of record type g_CUM_rec with PL/SQL table g_CUM_tab.
      --Calculate supplier CUM only once
      --
      IF v_cum_record.cum_key_id IS NULL THEN
        --
        IF g_CUM_tab(v_Count1).found = k_TRUE THEN
           --
           v_cum_record.record_return_status := TRUE;
           --
           v_cum_key_record.customer_item_id:= g_CUM_tab(v_Count1).customer_item_id;
           --
           v_cum_key_record.inventory_item_id:= g_CUM_tab(v_Count1).inventory_item_id;
           --
           v_cum_key_record.ship_from_org_id:= g_CUM_tab(v_Count1).ship_from_org_id;
           --
           v_cum_key_record.purchase_order_number:= g_CUM_tab(v_Count1).purchase_order_number;
           --
           v_cum_key_record.cust_record_year:= g_CUM_tab(v_Count1).cust_record_year;
           --
           v_cum_key_record.ship_to_address_id:= g_CUM_tab(v_Count1).ship_to_address_id;
           --
           v_cum_key_record.intrmd_ship_to_address_id:= g_CUM_tab(v_Count1).intrmd_ship_to_address_id;
           --
           v_cum_key_record.bill_to_address_id:= g_CUM_tab(v_Count1).bill_to_address_id;
           --
           v_cum_key_record.customer_id:= g_CUM_tab(v_Count1).customer_id;
           --
           v_cum_key_record.cum_start_date:= g_CUM_tab(v_Count1).start_date_time;
           --
           v_cum_key_record.create_cum_key_flag := 'N';
           --
        ELSE -- if g_CUM_tab
           --
           v_cum_record.record_return_status := TRUE;
           --
           v_cum_key_record.cum_start_date:= rlm_manage_demand_sv.K_DNULL;
           --
           v_cum_key_record.customer_item_id:= g_ManageDemand_tab(v_count).customer_item_id;
           --
           v_cum_key_record.inventory_item_id:= g_ManageDemand_tab(v_count).inventory_item_id;
           --
           v_cum_key_record.ship_from_org_id:= g_ManageDemand_tab(v_count).ship_from_org_id;
           --
           v_cum_key_record.purchase_order_number:= g_ManageDemand_tab(v_count).cust_po_number;
           --
           v_cum_key_record.cust_record_year:= g_ManageDemand_tab(v_count).industry_attribute1;
           --
           v_cum_key_record.ship_to_address_id:= g_ManageDemand_tab(v_count).ship_to_address_id;
           --
           v_cum_key_record.intrmd_ship_to_address_id:= g_ManageDemand_tab(v_count).intrmd_ship_to_id;
           --
           v_cum_key_record.bill_to_address_id:= g_ManageDemand_tab(v_count).bill_to_address_id;
           --
           v_cum_key_record.customer_id:= x_Sched_rec.customer_id;
           --
           v_cum_key_record.create_cum_key_flag := 'N';
           --
        END IF; --if g_CUM_tab
        --
        rlm_tpa_sv.CalculateCumKey(v_cum_key_record, v_cum_record);
        --
        --Bugfix 7007638
        IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
           rlm_message_sv.get_msg_text(
	  	   	   x_message_name	=> 'RLM_CUM_CONTROL_PO',
	  		   x_text		    => v_control_text);
           v_control_value := g_CUM_tab(v_Count1).purchase_order_number;
        ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
           rlm_message_sv.get_msg_text(
	  		   x_message_name	=> 'RLM_CUM_CONTROL_RY',
	  		   x_text		    => v_control_text);
           v_control_value := g_CUM_tab(v_Count1).cust_record_year;
        ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_ONLY') THEN
           rlm_message_sv.get_msg_text(
	  		   x_message_name	=> 'RLM_CUM_CONTROL_DATE',
	  		   x_text		    => v_control_text);
           v_control_value := g_CUM_tab(v_Count1).start_date_time;
        END IF;
        --Bugfix 7007638

        IF v_cum_record.cum_key_id IS  NULL THEN
          --
          raise e_noSupplierCum;
          --
        END IF;
        --
        v_supplier_total_qty := NVL(v_cum_record.cum_qty,0) +
                       NVL(v_cum_record.cum_qty_after_cutoff,0) +
                       NVL(v_cum_record.cum_qty_to_be_accumulated,0);
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'cum_qty',v_cum_record.cum_qty);
           rlm_core_sv.dlog(C_DEBUG,'cum_qty_after_cutoff',
                                           v_cum_record.cum_qty_after_cutoff);
           rlm_core_sv.dlog(C_DEBUG,'cum_qty_to_be_accumulated',
                                      v_cum_record.cum_qty_to_be_accumulated);
           rlm_core_sv.dlog(C_DEBUG,'v_supplier_total_qty',v_supplier_total_qty);
        END IF;
        --
      END IF;  --first time in the loop
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'earlier primary_quantity',
                                g_ManageDemand_tab(v_Count).primary_quantity);
         rlm_core_sv.dlog(C_DEBUG,'g_CUM_tab('||v_Count1||').primary_quantity',
                                g_CUM_tab(v_Count1).primary_quantity);

      END IF;
      -- Bug 4468377
      IF (g_ManageDemand_tab(v_Count).uom_code <> v_cum_record.cust_uom_code) THEN
          --
          raise e_UomMismatch;
          --
      END IF;
      --
      g_ManageDemand_tab(v_Count).primary_quantity :=
                    g_ManageDemand_tab(v_Count).primary_quantity
                    -  v_supplier_total_qty
                    - v_EarlierDiscreteQty;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'primary_quantity',
                           g_ManageDemand_tab(v_Count).primary_quantity);
      END IF;
      --
      g_ManageDemand_tab(v_Count).qty_type_code  := 'ACTUAL';
      --
      IF g_ManageDemand_tab(v_Count).primary_quantity < 0 THEN
        --
        --bsadri: just give a warning bug 1966050
        --
        rlm_message_sv.app_error(
             x_ExceptionLevel => rlm_message_sv.k_warn_level,
             x_MessageName => 'RLM_DISCRETE_QTY_NEGATIVE',
             x_InterfaceHeaderId => x_sched_rec.header_id,
             x_InterfaceLineId => g_ManageDemand_tab(v_Count).line_id,
             x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
             x_ScheduleLineId => NULL,
             x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
             x_OrderLineId => NULL,
             --x_ErrorText => 'Discrete Quantity is negative',
             --x_Token1 => 'SCHEDLINE',                              --Bugfix 7007638
             --x_value1 => g_ManageDemand_tab(v_Count).line_number); --Bugfix 7007638
             x_Token1 => 'GROUP',                                    --Bugfix 7007638
             x_value1 => '-'||v_control_text||' '||                  --Bugfix 7007638
                         rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                         rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                         rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                         v_control_value);
        --
        g_ManageDemand_tab(v_Count).primary_quantity := 0;
        --
      END IF;
      --
      SetOperation(g_ManageDemand_tab(v_Count), k_UPDATE);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_Count',v_Count);
         rlm_core_sv.dlog(C_DEBUG,'final g_ManageDemand_tab.primary_quantity',
                        g_ManageDemand_tab(v_Count).primary_quantity);
         rlm_core_sv.dlog(C_DEBUG,'final g_ManageDemand_tab.qty_type_code',
                        g_ManageDemand_tab(v_Count).qty_type_code);
      END IF;
      --
      v_EarlierDiscreteQty := v_EarlierDiscreteQty +
                          g_ManageDemand_tab(v_Count).primary_quantity;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_EarlierDiscreteQty',v_EarlierDiscreteQty);
      END IF;
      --
    END IF;
    --
   END IF; --Cum Control Check
   --
  END LOOP; --g_ManageDemand_tab
  --
 END LOOP; --g_CUM_tab
 --
 ELSE -- IF g_CUM_tab.COUNT --Bugfix 7007638

  v_cum_record.cum_key_id := NULL;

  FOR v_Count IN 1..g_ManageDemand_tab.COUNT LOOP
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || v_Count || ').qty_type_code', g_ManageDemand_tab(v_Count).qty_type_code);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.cum_control_code',x_Group_rec.setup_terms_rec.cum_control_code);
    END IF;
    --
    -- This assignment is done in order to get the current record during
    -- the error processing
    --
    v_current_rec := v_Count;
    --
    IF g_ManageDemand_tab(v_Count).qty_type_code = k_CUMULATIVE
      AND g_ManageDemand_tab(v_count).item_detail_type IN (k_PAST_DUE_FIRM,k_FIRM_DEMAND,k_FORECAST_DEMAND,k_MRP_FORECAST) THEN
      --
      --
      --Calculate supplier CUM only once
      --
      IF v_cum_record.cum_key_id IS NULL THEN
           --Removed IF check for g_CUM_tab.found as no records exists in g_CUM_tab
           v_cum_record.record_return_status := TRUE;
           --
           v_cum_key_record.cum_start_date := rlm_manage_demand_sv.K_DNULL;
           --
           v_cum_key_record.customer_item_id:= g_ManageDemand_tab(v_count).customer_item_id;
           --
           v_cum_key_record.inventory_item_id:= g_ManageDemand_tab(v_count).inventory_item_id;
           --
           v_cum_key_record.ship_from_org_id:= g_ManageDemand_tab(v_count).ship_from_org_id;
           --
           v_cum_key_record.purchase_order_number := g_ManageDemand_tab(v_count).cust_po_number;
           --
           v_cum_key_record.cust_record_year:= g_ManageDemand_tab(v_count).industry_attribute1;
           --
           v_cum_key_record.ship_to_address_id:= g_ManageDemand_tab(v_count).ship_to_address_id;
           --
           v_cum_key_record.intrmd_ship_to_address_id:= g_ManageDemand_tab(v_count).intrmd_ship_to_id;
           --
           v_cum_key_record.bill_to_address_id:= g_ManageDemand_tab(v_count).bill_to_address_id;
           --
           v_cum_key_record.customer_id:= x_Sched_rec.customer_id;
           --
           v_cum_key_record.create_cum_key_flag := 'N';
           --
        rlm_tpa_sv.CalculateCumKey(v_cum_key_record, v_cum_record);
        --
        --Bugfix 7007638
        IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
           rlm_message_sv.get_msg_text(
	  	   	   x_message_name	=> 'RLM_CUM_CONTROL_PO',
	  		   x_text		    => v_control_text);
           v_control_value := v_cum_key_record.purchase_order_number;
        ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
           rlm_message_sv.get_msg_text(
	  		   x_message_name	=> 'RLM_CUM_CONTROL_RY',
	  		   x_text		    => v_control_text);
           v_control_value := v_cum_key_record.cust_record_year;
        ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_ONLY') THEN
           rlm_message_sv.get_msg_text(
	  		   x_message_name	=> 'RLM_CUM_CONTROL_DATE',
	  		   x_text		    => v_control_text);
           v_control_value := v_cum_record.cum_start_date;
        END IF;
        --Bugfix 7007638

        IF v_cum_record.cum_key_id IS  NULL THEN
          --
          raise e_noSupplierCum;
          --
        END IF;
        --
        v_supplier_total_qty := NVL(v_cum_record.cum_qty,0) +
                       NVL(v_cum_record.cum_qty_after_cutoff,0) +
                       NVL(v_cum_record.cum_qty_to_be_accumulated,0);
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'cum_qty',v_cum_record.cum_qty);
           rlm_core_sv.dlog(C_DEBUG,'cum_qty_after_cutoff',
                                           v_cum_record.cum_qty_after_cutoff);
           rlm_core_sv.dlog(C_DEBUG,'cum_qty_to_be_accumulated',
                                      v_cum_record.cum_qty_to_be_accumulated);
           rlm_core_sv.dlog(C_DEBUG,'v_supplier_total_qty',v_supplier_total_qty);
        END IF;
        --
      END IF;  --first time in the loop
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'earlier primary_quantity',g_ManageDemand_tab(v_Count).primary_quantity);
      END IF;
      -- Bug 4436335
      IF (g_ManageDemand_tab(v_Count).uom_code <> v_cum_record.cust_uom_code) THEN
          --
          raise e_UomMismatch;
          --
      END IF;
      --
      g_ManageDemand_tab(v_Count).primary_quantity :=
                    g_ManageDemand_tab(v_Count).primary_quantity
                    -  v_supplier_total_qty
                    - v_EarlierDiscreteQty;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'primary_quantity',
                           g_ManageDemand_tab(v_Count).primary_quantity);
      END IF;
      --
      g_ManageDemand_tab(v_Count).qty_type_code  := 'ACTUAL';
      --
      IF g_ManageDemand_tab(v_Count).primary_quantity < 0 THEN
        --
        --bsadri: just give a warning bug 1966050
        --
        rlm_message_sv.app_error(
             x_ExceptionLevel => rlm_message_sv.k_warn_level,
             x_MessageName => 'RLM_DISCRETE_QTY_NEGATIVE',
             x_InterfaceHeaderId => x_sched_rec.header_id,
             x_InterfaceLineId => g_ManageDemand_tab(v_Count).line_id,
             x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
             x_ScheduleLineId => NULL,
             x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
             x_OrderLineId => NULL,
             --x_ErrorText => 'Discrete Quantity is negative',
             --x_Token1 => 'SCHEDLINE',                              --Bugfix 7007638
             --x_value1 => g_ManageDemand_tab(v_Count).line_number); --Bugfix 7007638
             x_Token1 => 'GROUP',                                    --Bugfix 7007638
             x_value1 => '-'||v_control_text||' '||                  --Bugfix 7007638
                         rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                         rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                         rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                         v_control_value);
        --
        g_ManageDemand_tab(v_Count).primary_quantity := 0;
        --
      END IF;
      --
      SetOperation(g_ManageDemand_tab(v_Count), k_UPDATE);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_Count',v_Count);
         rlm_core_sv.dlog(C_DEBUG,'final g_ManageDemand_tab.primary_quantity',
                        g_ManageDemand_tab(v_Count).primary_quantity);
         rlm_core_sv.dlog(C_DEBUG,'final g_ManageDemand_tab.qty_type_code',
                        g_ManageDemand_tab(v_Count).qty_type_code);
      END IF;
      --
      v_EarlierDiscreteQty := v_EarlierDiscreteQty +
                          g_ManageDemand_tab(v_Count).primary_quantity;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_EarlierDiscreteQty',v_EarlierDiscreteQty);
      END IF;
      --
    END IF;
    --
  END LOOP; --g_ManageDemand_tab
  --
 END IF; --g_CUM_tab.COUNT
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_noSupplierCum THEN
    --
    rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_CUM_KEY_NOTFOUND',
                 x_InterfaceHeaderId => x_sched_rec.header_id,
                 x_InterfaceLineId => g_ManageDemand_tab(v_current_rec).line_id,
                 x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                 x_ScheduleLineId => NULL,
                 x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                 x_OrderLineId => NULL,
                 x_Token1 => 'GROUP',                                   --Bugfix 7007638
                 x_value1 => '-'||v_control_text||' '||                 --Bugfix 7007638
                             rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                             rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                             rlm_core_sv.get_item_number(x_group_rec.customer_item_id)||'-'||
                             v_control_value);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog('No CUM Key Found Cannot calculate the supplier cum');
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    raise e_GroupError;
    --
  --
  -- Bug 4468377
  --
  WHEN e_UomMismatch THEN
    --
    IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN
        --
        rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_CUM_UOM_MISMATCH_SEQ',
                 x_InterfaceHeaderId => x_sched_rec.header_id,
                 x_InterfaceLineId => g_ManageDemand_tab(v_current_rec).line_id,
                 x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                 x_ScheduleLineId => NULL,
                 x_Token1 => 'LINE_UOM',
                 x_value1 => g_ManageDemand_tab(v_current_rec).uom_code,
                 x_Token2 => 'GROUP',
                 x_value2 => rlm_core_sv.get_ship_from(x_Group_rec.ship_from_org_id) || '-' ||
                             rlm_core_sv.get_ship_to(x_Group_rec.ship_to_address_id) || '-' ||
                             rlm_core_sv.get_item_number(x_Group_rec.customer_item_id),
                 x_Token3 => 'REQ_DATE',
                 x_value3 => g_ManageDemand_tab(v_current_rec).start_date_time,
                 x_Token4 => 'CUM_UOM',
                 x_value4 => v_cum_record.cust_uom_code,
                 x_Token5 => 'SEQ_INFO',
                 x_value5 => nvl(g_ManageDemand_tab(v_current_rec).cust_production_seq_num,'NULL')  || '-' ||
                             nvl(g_ManageDemand_tab(v_current_rec).cust_model_serial_number,'NULL') || '-' ||
                             nvl(g_ManageDemand_tab(v_current_rec).customer_job,'NULL'));
        --
        IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'Incoming Uom does not match with CUM key Uom');
            rlm_core_sv.dlog(C_DEBUG,'RLM_CUM_UOM_MISMATCH_SEQ',g_ManageDemand_tab(v_current_rec).line_id);
            rlm_core_sv.dpop(C_SDEBUG);
        END IF;
        --
    ELSE
        --
        rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_CUM_UOM_MISMATCH',
                 x_InterfaceHeaderId => x_sched_rec.header_id,
                 x_InterfaceLineId => g_ManageDemand_tab(v_current_rec).line_id,
                 x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                 x_ScheduleLineId => g_ManageDemand_tab(v_current_rec).schedule_line_id,
                 x_Token1 => 'LINE_UOM',
                 x_value1 => g_ManageDemand_tab(v_current_rec).uom_code,
                 x_Token2 => 'GROUP',
                 x_value2 => rlm_core_sv.get_ship_from(x_Group_rec.ship_from_org_id) || '-' ||
                             rlm_core_sv.get_ship_to(x_Group_rec.ship_to_address_id) || '-' ||
                             rlm_core_sv.get_item_number(x_Group_rec.customer_item_id),
                 x_Token3 => 'REQ_DATE',
                 x_value3 => g_ManageDemand_tab(v_current_rec).start_date_time,
                 x_Token4 => 'CUM_UOM',
                 x_value4 => v_cum_record.cust_uom_code,
                 x_Token5 => 'SCHEDULE_LINE',
                 x_value5 => rlm_core_sv.get_schedule_line_number(g_ManageDemand_tab(v_current_rec).schedule_line_id));
        --
        IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'Incoming Uom does not match with CUM key Uom');
            rlm_core_sv.dlog(C_DEBUG,'RLM_CUM_UOM_MISMATCH',g_ManageDemand_tab(v_current_rec).line_id);
            rlm_core_sv.dpop(C_SDEBUG);
        END IF;
        --
    END IF;
    --
    raise e_GroupError;
    --

  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_manage_demand_sv.CUMToDiscrete', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END CUMToDiscrete;

/*===========================================================================

PROCEDURE NAME:    ApplySourceRules

===========================================================================*/
PROCEDURE  ApplySourceRules(x_Sched_rec IN rlm_interface_headers%ROWTYPE,
                            x_Group_rec IN rlm_dp_sv.t_Group_rec,
                            x_SourcedDemand_tab OUT NOCOPY rlm_manage_demand_sv.t_MD_Tab,
                            x_Source_Tab OUT NOCOPY rlm_manage_demand_sv.t_Source_Tab)
IS
  --
  v_progress         VARCHAR2(3) := '010';
  k_PLANNING_ACTIVE  NUMBER      := 1;
  sr_item_id         NUMBER DEFAULT NULL;
  v_Source_Tab       rlm_manage_demand_sv.t_Source_Tab; --Bugfix 6051397
  --
  -- Source type is used in the decode because the if the source type = 2 =
  -- Make At then the source_organization_id is null as the make at Item
  -- is the same item
  --
  -- Following four new cursors added for Bug 3425360 jckwok
  --

  CURSOR c_MSC_site_profile (x_inv_item_id NUMBER,
                                x_org_id      NUMBER,
                                x_assign_id   NUMBER,
			 	x_srcng_lvl   NUMBER,
			 	x_rank	      NUMBER,
                                x_ship_to_site_id NUMBER) IS
  SELECT DECODE(mislv.source_type,2,mislv.source_organization_id,
		mislv.source_organization_id) org_id, mislv.allocation_percent ,mislv.effective_date, --Bugfix 6051397
         NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy')) --Bugfix 6051397
  FROM   msc_scatp_item_sr_levels_v mislv
  WHERE  mislv.assignment_set_id = x_assign_id
  AND    mislv.sourcing_level = x_srcng_lvl
  AND mislv.inventory_item_id = x_inv_item_id
  AND mislv.source_type IN (1,2)
  AND (SYSDATE BETWEEN mislv.effective_date AND
  NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy')) OR SYSDATE < mislv.effective_date) --Bugfix 6051397
  AND mislv.rank = x_rank
  AND mislv.ship_to_site_id = x_ship_to_site_id
  AND exists (SELECT null
              FROM   msc_sourcing_rules
              WHERE  sourcing_rule_id = mislv.sourcing_rule_id
              AND planning_active = k_PLANNING_ACTIVE)
  ORDER BY mislv.allocation_percent;
  --
  CURSOR c_MRP_site_profile (x_inv_item_id NUMBER,
                                x_org_id      NUMBER,
                                x_assign_id   NUMBER,
			 	x_srcng_lvl   NUMBER,
			 	x_rank	      NUMBER,
                                x_ship_to_site_id NUMBER) IS
  SELECT DECODE(mislv.source_type,2,mislv.source_organization_id,
		mislv.source_organization_id) org_id, mislv.allocation_percent ,mislv.effective_date, --Bugfix 6051397
         NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy')) --Bugfix 6051397
  FROM   mrp_scatp_item_sr_levels_v mislv
  WHERE  mislv.assignment_set_id = x_assign_id
  AND    mislv.sourcing_level = x_srcng_lvl
  AND mislv.inventory_item_id = x_inv_item_id
  AND mislv.source_type IN (1,2)
  AND (SYSDATE BETWEEN mislv.effective_date AND
  NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy')) OR SYSDATE < mislv.effective_date) --Bugfix 6051397
  AND mislv.rank = x_rank
  AND mislv.ship_to_site_id = x_ship_to_site_id
  AND exists (SELECT null
              FROM   mrp_sourcing_rules
              WHERE  sourcing_rule_id = mislv.sourcing_rule_id
              AND planning_active = k_PLANNING_ACTIVE)
  ORDER BY mislv.allocation_percent;
  --
  CURSOR c_MSC_site IS
   select DISTINCT assignment_set_id
   FROM msc_scatp_item_sr_levels_v mislv
   WHERE mislv.inventory_item_id = sr_item_id
   AND mislv.source_type IN (1,2)
   AND (SYSDATE BETWEEN mislv.effective_date
   AND NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy')) OR SYSDATE < mislv.effective_date) --Bugfix 6051397
   AND mislv.ship_to_site_id = x_Group_rec.ship_to_site_use_id
   AND exists (SELECT null
                    FROM   msc_sourcing_rules
                    WHERE  sourcing_rule_id = mislv.sourcing_rule_id
                    AND planning_active = k_PLANNING_ACTIVE);
   --
   CURSOR c_MRP_site IS
    SELECT DISTINCT assignment_set_id
    FROM mrp_scatp_item_sr_levels_v mislv
    WHERE mislv.inventory_item_id = x_Group_rec.inventory_item_id
    AND mislv.source_type IN (1,2)
    AND (SYSDATE BETWEEN mislv.effective_date
    AND NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy')) OR SYSDATE < mislv.effective_date) --Bugfix 6051397
    AND mislv.ship_to_site_id = x_Group_rec.ship_to_site_use_id
    AND exists (SELECT null
                    FROM   mrp_sourcing_rules
                    WHERE  sourcing_rule_id = mislv.sourcing_rule_id
                    AND planning_active = k_PLANNING_ACTIVE);
   --
   -- below are original cursors but names of cursors are changed for clarity
   --
   --perf changes
   --
   CURSOR c_MSC_item_profile (x_inv_item_id NUMBER,
				 x_org_id      NUMBER,
				 x_assign_id   NUMBER,
				 x_srcng_lvl   NUMBER,
				 x_rank	      NUMBER) IS
   SELECT DECODE(mislv.source_type,2,mislv.organization_id,
		 mislv.source_organization_id) org_id, mislv.allocation_percent, mislv.effective_date, --Bugfix 6051397
          NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy')) --Bugfix 6051397
   FROM   msc_item_sourcing_levels_v mislv
   WHERE  mislv.assignment_set_id = x_assign_id
   AND    mislv.sourcing_level = x_srcng_lvl
   AND mislv.inventory_item_id = x_inv_item_id
   AND mislv.organization_id = x_org_id
   AND mislv.source_type IN (1,2)
   AND (SYSDATE BETWEEN mislv.effective_date AND
   NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy'))  OR SYSDATE < mislv.effective_date) --Bugfix 6051397
   AND mislv.rank = x_rank
   AND exists (SELECT null
	       FROM   msc_sourcing_rules
	       WHERE  sourcing_rule_id = mislv.sourcing_rule_id
	       AND planning_active = k_PLANNING_ACTIVE)
   ORDER BY mislv.allocation_percent;
   --
   -- perf changes
   CURSOR c_MRP_item_profile (x_inv_item_id NUMBER,
				 x_org_id      NUMBER,
				 x_assign_id   NUMBER,
				 x_srcng_lvl   NUMBER,
				 x_rank	      NUMBER) IS
   SELECT DECODE(mislv.source_type,2,mislv.organization_id,
		 mislv.source_organization_id) org_id, mislv.allocation_percent, mislv.effective_date, --Bugfix 6051397
          NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy'))  --Bugfix 6051397
   FROM   mrp_item_sourcing_levels_v mislv
   WHERE  mislv.assignment_set_id = x_assign_id
   AND    mislv.sourcing_level = x_srcng_lvl
   AND mislv.inventory_item_id = x_inv_item_id
   AND mislv.organization_id = x_org_id
   AND mislv.source_type IN (1,2)
   AND (SYSDATE BETWEEN mislv.effective_date AND
   NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy'))  OR SYSDATE < mislv.effective_date)  --Bugfix 6051397
   AND mislv.rank = x_rank
   AND exists (SELECT null
	       FROM   mrp_sourcing_rules
	       WHERE  sourcing_rule_id = mislv.sourcing_rule_id
	       AND planning_active = k_PLANNING_ACTIVE)
   ORDER BY mislv.allocation_percent;
   --
   --perf changes
   CURSOR c_MSC_item IS
    select DISTINCT assignment_set_id
    FROM msc_item_sourcing_levels_v mislv
    WHERE mislv.inventory_item_id = sr_item_id
    AND mislv.organization_id = x_Group_rec.ship_from_org_id
    AND mislv.source_type IN (1,2)
    AND (SYSDATE BETWEEN mislv.effective_date
    AND NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy'))  OR SYSDATE < mislv.effective_date) --Bugfix 6051397
    AND exists (SELECT null
		     FROM   msc_sourcing_rules
		     WHERE  sourcing_rule_id = mislv.sourcing_rule_id
		     AND planning_active = k_PLANNING_ACTIVE);
    --
    --perf changes
    CURSOR c_MRP_item IS
     SELECT DISTINCT assignment_set_id
     FROM mrp_item_sourcing_levels_v mislv
     WHERE mislv.inventory_item_id = x_Group_rec.inventory_item_id
     AND mislv.organization_id = x_Group_rec.ship_from_org_id
     AND mislv.source_type IN (1,2)
     AND (SYSDATE BETWEEN mislv.effective_date
     AND NVL(mislv.disable_date, TO_DATE('31/12/4712','dd/mm/yyyy'))  OR SYSDATE < mislv.effective_date) --Bugfix 6051397
     AND exists (SELECT null
		     FROM   mrp_sourcing_rules
		     WHERE  sourcing_rule_id = mislv.sourcing_rule_id
		     AND planning_active = k_PLANNING_ACTIVE);
   --


  v_Index               NUMBER  DEFAULT 0;
  v_OrigQty             NUMBER  DEFAULT 0;
  v_SumQty              NUMBER  DEFAULT 0;
  e_NoSrcRulesSetup     EXCEPTION;
  e_NoSrItemId          EXCEPTION;
  v_org_found           BOOLEAN DEFAULT FALSE;
  v_current_rec         NUMBER;
  v_tmpGroup_rec        rlm_dp_sv.t_Group_Rec;
  v_count_msc 		NUMBER DEFAULT 0;
  v_count_mrp 		NUMBER DEFAULT 0;
  v_normal_source       VARCHAR2(3) DEFAULT 'MSC';
  v_source_level        VARCHAR2(4) DEFAULT 'SITE';  -- possible values 'SITE', 'ITEM', 'PRFL'

  v_assign_set 		VARCHAR2(15);
  v_assign_set_id       NUMBER DEFAULT NULL;
  v_msc_assign_set_id   NUMBER DEFAULT NULL;
  v_mrp_assign_set_id   NUMBER DEFAULT NULL;
  ByPassATP             EXCEPTION;
  --
  v_srcng_lvl		NUMBER;
  v_rank		NUMBER;
  v_Ind_Source          NUMBER  DEFAULT 0; --Bugfix 6051397
  --
BEGIN
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG,'ApplySourceRules');
 END IF;
 --
 --global_atp
 IF IsATPItem(x_group_rec.ship_from_org_id,
              x_group_rec.inventory_item_id) THEN
    --
    RAISE ByPassATP;
    --
 END IF;
 --
 -- Get the profile option value
 --
 fnd_profile.get('RLM_MSC_MRP_ASSIGN_SET', v_assign_set);
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'v_assign_set', v_assign_set);
 END IF;
 --
 IF NVL(v_assign_set, 'N') = 'N' THEN
    --
    RAISE e_NoSrcRulesSetup;
    --
 END IF;
 --
 -- Get the sr_item_id first
 --
 BEGIN
   --
   SELECT inventory_item_id
   INTO   sr_item_id
   FROM   msc_system_items
   WHERE  sr_inventory_item_id = x_Group_rec.inventory_item_id
   AND    plan_id = -1
   AND    organization_id = x_Group_rec.ship_from_org_id
   AND    sr_instance_id IN (SELECT instance_id FROM mrp_ap_apps_instances);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'sr_item_id', sr_item_id);
   END IF;
   --
   OPEN c_MSC_site;
   --
   LOOP
     --
     FETCH c_MSC_site into v_msc_assign_set_id;
     EXIT WHEN ( c_MSC_site%NOTFOUND OR (c_MSC_site%ROWCOUNT > 1));
     --
   END LOOP;
   --
   v_count_msc := c_MSC_site%ROWCOUNT;

   CLOSE c_MSC_site; --bug 4570658
   --
 EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
     --
     v_count_msc := 0;
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'No data found for inventory item',
                             x_Group_rec.inventory_item_id );
     END IF;
     --
   WHEN OTHERS THEN
     --
     v_count_msc := 0;
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'In when others' || SUBSTR(SQLERRM,1,200));
     END IF;
     --
 END;
 --
 v_source_level := 'SITE';
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.inventory_item_id', x_Group_rec.inventory_item_id);
    rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.ship_from_org_id', x_Group_rec.ship_from_org_id);
    rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.ship_to_site_use_id', x_Group_rec.ship_to_site_use_id);
 END IF;
 --
 IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(C_DEBUG, 'c_MSC_site: v_count_msc', v_count_msc);
 END IF;
 --
 IF v_count_msc = 1 THEN  -- first level of hierarchy: MSC SITE  --{
   --
   v_normal_source := 'MSC';
   v_assign_set_id:= v_msc_assign_set_id;
   --
 ELSIF v_count_msc > 1 THEN
   --
   v_normal_source := SUBSTR(v_assign_set,1,3);
   v_assign_set_id := TO_NUMBER(SUBSTR(v_assign_set,4));
   -- Bug 3534969 jckwok
   v_source_level := 'PRFL';
   --
 ELSIF v_count_msc = 0 THEN /* No msc sourcing rules setup at the site level */
   --
   OPEN c_MSC_item;   -- second level of hierarchy: MSC ITEM
   --
   LOOP
     --
     FETCH c_MSC_item into v_msc_assign_set_id;
     EXIT WHEN ( c_MSC_item%NOTFOUND OR (c_MSC_item%ROWCOUNT > 1));
     --
   END LOOP;
   --
   v_count_msc := c_MSC_item%ROWCOUNT;
   CLOSE c_MSC_item; --bug 4570658
   v_source_level := 'ITEM';
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'c_MSC_item: v_count_msc', v_count_msc);
   END IF;
   --
   IF v_count_msc = 1 THEN  -- exactly one sourcing rule in ITEM  --{
      --
      v_normal_source := 'MSC';
      v_assign_set_id:= v_msc_assign_set_id;
      --
   ELSIF(v_count_msc > 1) THEN
      --
      v_normal_source := SUBSTR(v_assign_set,1,3);
      v_assign_set_id := TO_NUMBER(SUBSTR(v_assign_set,4));
      -- Bug 3534969 jckwok
      v_source_level := 'PRFL';
      --
   ELSE  -- third level of hierarchy: MRP SITE
	--
	OPEN c_MRP_site;
	--
	LOOP  --{
	   --
	   FETCH c_MRP_site into v_mrp_assign_set_id;
	   EXIT WHEN ( c_MRP_site%NOTFOUND OR (c_MRP_site%ROWCOUNT > 1));
	   --
	END LOOP;  --}
	--
	v_count_mrp := c_MRP_site%ROWCOUNT;
        v_source_level := 'SITE';
	--
	IF (l_debug <> -1) THEN
	   rlm_core_sv.dlog(C_DEBUG, 'c_MRP_site: v_count_mrp', v_count_mrp);
	END IF;
	--
	IF v_count_mrp = 1 THEN  --{
	   --
	   v_normal_source := 'MRP';
	   v_assign_set_id:= v_mrp_assign_set_id;
	   --
	ELSIF v_count_mrp > 1 THEN
	   --
	   v_normal_source := SUBSTR(v_assign_set,1,3);
	   v_assign_set_id := TO_NUMBER(SUBSTR(v_assign_set,4));
           -- Bug 3534969 jckwok
           v_source_level := 'PRFL';
	   --
	ELSE --  v_count_mrp = 0
           --
	   OPEN c_MRP_item;   -- fourth level of hierarchy: MRP ITEM
           --
	   LOOP
	      --
	      FETCH c_MRP_item into v_mrp_assign_set_id;
	      EXIT WHEN ( c_MRP_item%NOTFOUND OR (c_MRP_item%ROWCOUNT > 1));
	      --
           END LOOP;
	   --
           v_count_mrp := c_MRP_item%ROWCOUNT;
           CLOSE c_MRP_item; --bug 4570658
           v_source_level := 'ITEM';
           --
	   IF (l_debug <> -1) THEN
	       rlm_core_sv.dlog(C_DEBUG, 'c_MRP_item: v_count_mrp', v_count_mrp);
           END IF;
            --
	   IF v_count_mrp = 1 THEN  --{
	       --
	       v_normal_source := 'MRP';
	       v_assign_set_id:= v_mrp_assign_set_id;
               --
	   ELSIF v_count_mrp > 1 THEN
	       --
	       v_normal_source := SUBSTR(v_assign_set,1,3);
	       v_assign_set_id := TO_NUMBER(SUBSTR(v_assign_set,4));
               -- Bug 3534969 jckwok
               v_source_level := 'PRFL';
	       --
	   ELSE
	       --
               -- No rule found after going down all 4 levels of hierarchy.
               --
	       raise e_NOSrcRulesSetup;
	       --
	   END IF;  --}
           --
        END IF; --}
        --
   END IF;  --}
   --
 END IF;  --}
 --
 IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'v_normal_source', v_normal_source);
     rlm_core_sv.dlog(C_DEBUG, 'v_assign_set_id', v_assign_set_id);
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.inventory_item_id', x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.ship_from_org_id', x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.ship_to_site_use_id', x_Group_rec.ship_to_site_use_id);
     rlm_core_sv.dlog(C_DEBUG, 'v_source_level', v_source_level);
 END IF;
 --
 --open cursors based on source (MSC or MRP) and source level (SITE, ITEM, or PRFL).
 --
 IF v_normal_source = 'MSC' THEN  --{
	--
        -- Bug 3534969 jckwok
        -- If v_source_level is PRFL (profile) meaning we must
        -- open site level cursors first and
        -- if there is nothing found there (i.e. v_index = 0),
        -- then we will open the item level cursors.
        --
        IF (v_source_level = 'PRFL') OR (v_source_level = 'SITE') THEN --{
            --
	    SELECT MIN(sourcing_level)
	    INTO v_srcng_lvl
	    FROM msc_scatp_item_sr_levels_v
	    WHERE inventory_item_id = sr_item_id
	    AND assignment_set_id = v_assign_set_id
	    AND ship_to_site_id = x_Group_rec.ship_to_site_use_id;
	    --
	    SELECT MIN(rank)
	    INTO v_rank
	    FROM msc_scatp_item_sr_levels_v
	    WHERE inventory_item_id = sr_item_id
	    AND ship_to_site_id = x_Group_rec.ship_to_site_use_id
	    AND (SYSDATE BETWEEN effective_date AND
	      NVL(disable_date, TO_DATE('31/12/4712', 'DD/MM/YYYY')) OR SYSDATE < effective_date); --Bugfix 6051397
	    --
	    IF (l_debug <> -1) THEN
	     rlm_core_sv.dlog(C_DEBUG, 'MSC Site: Minimum sourcing level', v_srcng_lvl);
	     rlm_core_sv.dlog(C_DEBUG, 'MSC Site: Minimum Rank', v_rank);
	    END IF;
	    --
	    FOR c_rec IN c_MSC_site_profile(sr_item_id,
					       x_Group_rec.ship_from_org_id,
					       v_assign_set_id,
					       v_srcng_lvl,
					       v_rank,
					       x_Group_rec.ship_to_site_use_id) LOOP
		      --
		      v_progress     := '020';
		      v_Index := v_Index + 1;
		      v_Source_Tab(v_Index) := c_rec; --Bugfix 6051397
		      --
	    END LOOP;
        END IF;  --}
        IF (v_source_level = 'ITEM') OR (v_source_level = 'PRFL' AND v_Index = 0)  THEN  --{
            --
	    SELECT MIN(sourcing_level)
	    INTO v_srcng_lvl
	    FROM msc_item_sourcing_levels_v
	    WHERE organization_id = x_Group_rec.ship_from_org_id
	    AND inventory_item_id = sr_item_id
	    AND assignment_set_id = v_assign_set_id;
	    --
	    SELECT MIN(rank)
	    INTO v_rank
	    FROM msc_item_sourcing_levels_v
	    WHERE organization_id = x_Group_rec.ship_from_org_Id
	    AND inventory_item_id = sr_item_id
	    AND (SYSDATE BETWEEN effective_date AND
	      NVL(disable_date, TO_DATE('31/12/4712', 'DD/MM/YYYY'))  OR SYSDATE < effective_date); --Bugfix 6051397
	    --
	    IF (l_debug <> -1) THEN
	     rlm_core_sv.dlog(C_DEBUG, 'MSC Item: Minimum sourcing level', v_srcng_lvl);
	     rlm_core_sv.dlog(C_DEBUG, 'MSC Item: Minimum Rank', v_rank);
	    END IF;
	    --
	    FOR c_rec IN c_MSC_item_profile(sr_item_id,
					       x_Group_rec.ship_from_org_id,
					       v_assign_set_id,
					       v_srcng_lvl, v_rank) LOOP
		 --
		 v_progress     := '020';
		 v_Index := v_Index + 1;
		 v_Source_Tab(v_Index) := c_rec; --Bugfix 6051397
		 --
	    END LOOP;
        END IF;  --}
      ELSE  -- not MSC, so it must be MRP
        IF (v_source_level = 'PRFL') OR (v_source_level = 'SITE') THEN --{
	   -- Determine the minimum sourcing level and rank
	   --
	    SELECT MIN(sourcing_level)
	    INTO v_srcng_lvl
	    FROM mrp_scatp_item_sr_levels_v
	    WHERE inventory_item_id = x_Group_rec.inventory_item_id
	    AND assignment_set_id = v_assign_set_id
	    AND ship_to_site_id = x_Group_rec.ship_to_site_use_id;
	    --
	    SELECT MIN(rank)
	    INTO v_rank
	    FROM mrp_scatp_item_sr_levels_v
	    WHERE inventory_item_id = x_Group_rec.inventory_item_id
	    AND ship_to_site_id = x_Group_rec.ship_to_site_use_id
	    AND (SYSDATE BETWEEN effective_date AND
	      NVL(disable_date, TO_DATE('31/12/4712', 'DD/MM/YYYY')) OR SYSDATE < effective_date); --Bugfix 6051397
	    --
	    IF (l_debug <> -1) THEN
	     rlm_core_sv.dlog(C_DEBUG, 'MRP Site: Minimum sourcing level', v_srcng_lvl);
	     rlm_core_sv.dlog(C_DEBUG, 'MRP Site: Minimum Rank', v_rank);
	    END IF;
	    --
	    FOR c_rec IN c_MRP_site_profile(x_Group_rec.inventory_item_id,
					       x_Group_rec.ship_from_org_id,
					       v_assign_set_id,
					       v_srcng_lvl,
					       v_rank,
					       x_Group_rec.ship_to_site_use_id) LOOP
	     --
	     v_progress     := '020';
	     v_Index := v_Index + 1;
	     v_Source_Tab(v_Index) := c_rec;          --Bugfix 6051397
	     --
	    END LOOP;
        END IF;  --}
        --
        IF (v_source_level = 'ITEM') OR (v_source_level = 'PRFL'  AND v_Index = 0)  THEN  --{
            --
	    SELECT MIN(sourcing_level)
	    INTO v_srcng_lvl
	    FROM mrp_item_sourcing_levels_v
	    WHERE organization_id = x_Group_rec.ship_from_org_id
	    AND inventory_item_id = x_Group_rec.inventory_item_id
	    AND assignment_set_id = v_assign_set_id;
            --
	    SELECT MIN(rank)
	    INTO v_rank
	    FROM mrp_item_sourcing_levels_v
	    WHERE organization_id = x_Group_rec.ship_from_org_Id
	    AND inventory_item_id = x_Group_rec.inventory_item_id
	    AND (SYSDATE BETWEEN effective_date AND
	      NVL(disable_date, TO_DATE('31/12/4712', 'DD/MM/YYYY')) OR SYSDATE < effective_date); --Bugfix 6051397
	    --
	    IF (l_debug <> -1) THEN
	     rlm_core_sv.dlog(C_DEBUG, 'MRP Item: Minimum sourcing level', v_srcng_lvl);
	     rlm_core_sv.dlog(C_DEBUG, 'MRP Item: Minimum Rank', v_rank);
	    END IF;
	    --
	    FOR c_rec IN c_MRP_item_profile(x_Group_rec.inventory_item_id,
					       x_Group_rec.ship_from_org_id,
					       v_assign_set_id,
					       v_srcng_lvl,
					       v_rank) LOOP
	      --
	      v_progress     := '020';
	      v_Index := v_Index + 1;
	      v_Source_Tab(v_Index) := c_rec;         --Bugfix 6051397
	      --
	    END LOOP;
        END IF;  --}
--jckwok: End of Bug 3534969
 END IF; --}
 --
 IF v_Index = 0 THEN  --{
     --
     RAISE e_NOSrcRulesSetup;
     --
 END IF;  --}
 --
 IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab.COUNT',
                                    g_ManageDemand_tab.COUNT);
 END IF;
 --
  FOR i IN 1..g_ManageDemand_tab.COUNT LOOP
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab(' || i || ').qty_type_code',
                                    g_ManageDemand_tab(i).qty_type_code);
         rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.setup_terms_rec.cum_control_code',
                                 x_Group_rec.setup_terms_rec.cum_control_code);
         rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.setup_terms_rec.cum_org_level_code',
                                 x_Group_rec.setup_terms_rec.cum_org_level_code);
      END IF;
      --

      v_Ind_Source := 0;  --Bugfix 6051397

      --Bugfix 6051397 Start
      FOR k IN 1..v_Source_Tab.COUNT LOOP
       IF    g_ManageDemand_tab(i).start_date_time >= v_Source_Tab(k).effective_date
         AND g_ManageDemand_tab(i).start_date_time <= v_Source_Tab(k).disable_date  THEN
             v_Ind_Source := v_Ind_Source +1;
             x_Source_Tab(v_Ind_Source).allocation_percent := v_Source_Tab(k).allocation_percent ;
             x_Source_Tab(v_Ind_Source).organization_id:= v_Source_Tab(k).organization_id ;
       END IF;
      END LOOP;


    IF v_Ind_Source = 0 THEN
             v_Ind_Source := v_Ind_Source + 1;
             x_Source_Tab(v_Ind_Source).allocation_percent := 100;
             x_Source_Tab(v_Ind_Source).organization_id := x_Group_rec.ship_from_org_id;
             rlm_core_sv.dlog(C_DEBUG, 'No Sourcing Rule found for this line ');
    END IF;
    --Bugfix 6051397 End


      IF nvl(g_ManageDemand_tab(i).line_source,'NEW') <> 'SOURCED' THEN --{
         --
         IF (g_ManageDemand_tab(i).qty_type_code = k_CUMULATIVE)  THEN
            IF x_Group_rec.setup_terms_rec.cum_org_level_code NOT IN (
                           'SHIP_TO_ALL_SHIP_FROMS',
                           'BILL_TO_ALL_SHIP_FROMS',
                           'DELIVER_TO_ALL_SHIP_FROMS') THEN
                --
                IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG, 'RLM_CUMORGLEVEL_INVALID');
                   --
                   --bug 1497386 fix:  schedule line id is passed instead of null
                   --
                   rlm_core_sv.dlog(C_DEBUG, 'Schedule_Line_ID',
				g_ManageDemand_tab(i).schedule_line_id );
                END IF;
                --
                rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_warn_level,
                     x_MessageName => 'RLM_CUMORGLEVEL_INVALID',
                     x_InterfaceHeaderId => x_sched_rec.header_id,
                     x_InterfaceLineId => g_ManageDemand_tab(i).line_id,
                     x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                     x_ScheduleLineId => g_ManageDemand_tab(i).schedule_line_id,
                     x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                     x_OrderLineId => NULL,
                     --x_ErrorText => 'Sourcing Rules with CUM Organization Level
                                  --will result in cum discrepancies',
                     x_Token1 => 'CUMORGLEVEL',
                     x_value1 => rlm_core_sv.get_lookup_meaning(
                                   'RLM_CUM_ORG_LEVEL',
                                    x_Group_rec.setup_terms_rec.cum_org_level_code));

              --
            END IF;
            --
         END IF;  --}
         --
         /* We need to add the remaining quantity to the original count
            so we save the index of the first line that we encounter
            in saveIndex */
         --
         v_OrigQty   := g_ManageDemand_tab(i).primary_quantity;
         v_progress  := '050';
         v_SumQty    := 0;
         v_org_found := FALSE;
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'x_Source_tab.COUNT', x_Source_tab.COUNT);
         END IF;
         --
         FOR j IN 1..x_Source_tab.COUNT LOOP
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_Tab(' || i  || ').ship_from_org_id', g_ManageDemand_Tab(i).ship_from_org_id);
	      rlm_core_sv.dlog(C_DEBUG, 'x_Source_tab(' || j || ').organization_id', x_Source_tab(j).organization_id);
           END IF;
           --
           IF g_ManageDemand_Tab(i).ship_from_org_id =
                                   x_Source_tab(j).organization_id THEN
              --
              IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG, 'Org Found in Source Rules');
              END IF;
              --
              v_org_found := TRUE;
              --
              IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG, 'x_Source_tab(' || j || ').allocation_percent',
                                      x_Source_tab(j).allocation_percent);
              END IF;
              --
              IF x_Source_tab(j).allocation_percent = 0 THEN
                --
                v_progress     := '060';
                SetOperation(g_ManageDemand_tab(i), k_DELETE);
                --
              ELSE
                --
                g_ManageDemand_tab(i).primary_quantity :=
                    TRUNC(v_OrigQty * x_Source_tab(j).allocation_percent/100);
                --
                --
                -- Source line_source
                --
                g_ManageDemand_tab(i).line_source := 'SOURCED';
                --
  	        IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab(' || i || ').primary_quantity',
                                      g_ManageDemand_tab(i).primary_quantity);
                   rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab(' || i || ').line_source',
                                      g_ManageDemand_tab(i).line_source);
                END IF;
                --
                v_SumQty := v_SumQty +
                      TRUNC(v_OrigQty * x_Source_tab(j).allocation_percent/100);
                --
                IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG, 'v_SumQty', v_SumQty);
                END IF;
                --
                SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                --
              END IF;
              --
           ELSIF x_Source_tab(j).allocation_percent <> 0 THEN
             -- Add a new line at the end
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG, 'x_Source_tab('|| j || ').organization_id',
                           x_Source_tab(j).organization_id);
             END IF;
             --
             x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT + 1) :=
                                                g_ManageDemand_tab(i);
             --
             x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).primary_quantity :=
                TRUNC(v_OrigQty * x_Source_tab(j).allocation_percent/100);
             x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).ship_from_org_id :=
                x_Source_tab(j).organization_id;
             x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).schedule_item_num :=
                x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).schedule_item_num + (j * 0.1);
             --
             -- Source line_source
             --
             x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).line_source := 'SOURCED';
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab.primary_quantity',
               			x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).primary_quantity);
                rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab.ship_from_org_id',
               			x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).ship_from_org_id);
                rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab.line_source',
               			x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).line_source);
                rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab.schedule_item_num',
               			x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).schedule_item_num);
             END IF;
             --
             v_SumQty := v_SumQty +
                        TRUNC(v_OrigQty * x_Source_tab(j).allocation_percent/100);
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG, 'v_SumQty', v_SumQty);
             END IF;
             --
             SetOperation(x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT),k_INSERT);
             --
           END IF;
           --
        END LOOP;
        --
        -- Now add the remaining quantity the truncated quantity to the
        -- saveIndex record
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'v_OrigQty', v_OrigQty);
           rlm_core_sv.dlog(C_DEBUG, 'v_SumQty', v_SumQty);
        END IF;
        --
        IF NOT v_org_found  THEN
           --
           SetOperation(g_ManageDemand_tab(i),k_DELETE);
           --
           x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).primary_quantity :=
               x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).primary_quantity +
               v_OrigQty - v_SumQty;
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(COUNT).primary_quantity'
             		,x_SourcedDemand_Tab(x_SourcedDemand_Tab.COUNT).primary_quantity);
           END IF;
           --
        ELSE
           --
           g_ManageDemand_tab(i).primary_quantity :=
               g_ManageDemand_tab(i).primary_quantity + v_OrigQty - v_SumQty;
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab(' || i || ').primary_quantity',
                                      g_ManageDemand_tab(i).primary_quantity);
           END IF;
           --
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab(' || i || ').primary_quantity',
                              g_ManageDemand_tab(i).primary_quantity);
        END IF;
        --
      ELSE
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Line already sourced need not apply source rules ');
        END IF;
        --
      END IF;
      --
    END LOOP;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab.Count',
                                              x_SourcedDemand_Tab.Count);
    END IF;
    --
    IF x_SourcedDemand_Tab.COUNT > 0 THEN
      --
      FOR k IN 1..x_SourcedDemand_Tab.COUNT LOOP
        --
        v_tmpGroup_rec.ship_from_org_id :=
                                x_SourcedDemand_Tab(k).ship_from_org_id;
        --
        v_tmpGroup_rec.customer_id  := x_Sched_rec.customer_id;
        --
        v_tmpGroup_rec.customer_item_id :=
                                x_SourcedDemand_Tab(k).customer_item_id;
        --
        v_tmpGroup_rec.ship_to_address_id :=
                                x_SourcedDemand_Tab(k).ship_to_address_id;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').ship_from_org_id',
                                   x_SourcedDemand_Tab(k).ship_from_org_id);
           rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').customer_item_id',
                                   x_SourcedDemand_Tab(k).customer_item_id);
           rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').ship_to_address_id',
                                   x_SourcedDemand_Tab(k).ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').line_id',
                                   x_SourcedDemand_Tab(k).line_id);
           rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').schedule_line_id',
                                   x_SourcedDemand_Tab(k).schedule_line_id);
        END IF;
        --
        -- This is done so that the inventory item id is re calculated in orgDependentIds.
        x_SourcedDemand_tab(k).inventory_item_id := NULL;
        --
        CallSetups(x_Sched_rec, v_tmpGroup_rec);
        --
        rlm_validatedemand_sv.DeriveOrgDependentIDs(
                                        v_tmpGroup_rec.setup_terms_rec,
                                        x_Sched_rec,
                                        x_SourcedDemand_tab(k));

        --deriveinventoryitemid not a part of DeriveOrgDependentIDs
        RLM_TPA_SV.DeriveInventoryItemId(x_Sched_rec,
                                        x_SourcedDemand_tab(k));

        RLM_TPA_SV.ValidateLineDetails(
                                        v_tmpGroup_rec.setup_terms_rec,
                                        x_Sched_rec,
                                        x_SourcedDemand_tab(k),
                                        rlm_validatedemand_sv.k_MRP_SOURCED);
        --
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').process_status',
                                   x_SourcedDemand_Tab(k).process_status);
           rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').ship_from_org_id',
                                   x_SourcedDemand_Tab(k).ship_from_org_id);
	   rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').order_header_id',
				   x_SourcedDemand_Tab(k).order_header_id);
	   rlm_core_sv.dlog(C_DEBUG, 'x_SourcedDemand_Tab(' || k || ').blanket_number',
				   x_SourcedDemand_Tab(k).blanket_number);
        END IF;
        --
        IF x_SourcedDemand_tab(k).process_status = rlm_core_sv.k_PS_ERROR THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dpop(C_SDEBUG);
           END IF;
           --
           RAISE e_GroupError;
           --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
EXCEPTION
  --
  --global_atp
  WHEN ByPassATP THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'No need to apply sourcing rule to ATP item');
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;

  WHEN e_GroupError THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RAISE;


  WHEN e_NoSrcRulesSetup THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'No Source rules setup for Inv Item ',
                                   x_group_rec.inventory_item_id);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_managedemand_sv.ApplySourceRules',
                             v_Progress);
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    RAISE;

END ApplySourceRules;

/*===========================================================================

PROCEDURE NAME:    CalculateShipDate

===========================================================================*/

PROCEDURE CalculateShipDate(x_sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS

  i		NUMBER;
  j		NUMBER;
  v_Input_rec	rlm_ship_delivery_pattern_sv.t_InputRec;
  v_Output_tab	rlm_ship_delivery_pattern_sv.t_OutputTable;
  v_message_tab	rlm_ship_delivery_pattern_sv.t_errormsgtable;
  v_ReturnStatus	NUMBER;
  v_Progress     VARCHAR2(3)  := '010';
  e_SDPFailed    EXCEPTION;
  v_ATP          BOOLEAN;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CalculateShipDate');
  END IF;
  --
  FOR i IN 1..g_ManageDemand_tab.COUNT LOOP
    --
    IF i=1 THEN
      --
      v_ATP := IsATPItem(g_ManageDemand_tab(i).ship_from_org_id,
	                 g_ManageDemand_tab(i).inventory_item_id);
      --
    END IF;
    --
    IF g_ManageDemand_tab(i).request_date IS NOT NULL THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').request_date ',
				g_ManageDemand_tab(i).request_date);
         rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').schedule_date before',
				g_ManageDemand_tab(i).schedule_date);
         rlm_core_sv.dlog(C_DEBUG,'No Need to calculate the ship date as it is already calculated. Just make sure it is not past-due');
      END IF;
      --
      IF v_ATP = TRUE THEN
        --
        g_ManageDemand_tab(i).SCHEDULE_DATE := NULL;
        SetOperation(g_ManageDemand_tab(i), k_UPDATE);
        --
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_ATP', v_ATP);
         rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').schedule_date after',
				g_ManageDemand_tab(i).schedule_date);
      END IF;
      --
    ELSE
      v_Input_rec.ShipDeliveryRuleName:= g_ManageDemand_tab(i).ship_del_rule_name;
      v_Input_rec.ItemDetailSubtype := g_ManageDemand_tab(i).item_detail_subtype;
      v_Input_rec.DateTypeCode := g_ManageDemand_tab(i).date_type_code;
      v_Input_rec.StartDateTime := g_ManageDemand_tab(i).start_date_time;
      v_Input_rec.ShipFromOrgId := x_Group_rec.ship_from_org_id;
      v_Input_rec.CustomerId := x_Group_rec.customer_id;
      v_Input_rec.ShipToCustomerId := x_Group_rec.ship_to_customer_id;
      v_Input_rec.ShipToAddressId := x_Group_rec.ship_to_address_id;
      v_Input_rec.ShipToSiteUseId := g_ManageDemand_tab(i).ship_to_site_use_id;
      v_Input_rec.CustomerItemId := g_ManageDemand_tab(i).customer_item_id;

      --global_atp
      v_Input_rec.ATPItemFlag := v_ATP;

      v_Input_rec.PrimaryQuantity := g_ManageDemand_tab(i).primary_quantity;
      v_Input_rec.EndDateTime := g_ManageDemand_tab(i).end_date_time;
      v_Input_rec.DefaultSDP := x_Group_rec.setup_terms_rec.ship_delivery_rule_name;
      v_Input_rec.ship_method := x_Group_rec.setup_terms_rec.ship_method;
      v_Input_rec.intransit_time := x_Group_rec.setup_terms_rec.intransit_time;
      v_Input_rec.time_uom_code := x_Group_rec.setup_terms_rec.time_uom_code;
      v_Input_rec.use_edi_sdp_code_flag :=
                         x_Group_rec.setup_terms_rec.use_edi_sdp_code_flag;
      v_Input_rec.customer_rcv_calendar_cd :=
                         x_Group_rec.setup_terms_rec.customer_rcv_calendar_cd;
      v_Input_rec.supplier_shp_calendar_cd :=
                         x_Group_rec.setup_terms_rec.supplier_shp_calendar_cd;
      v_Input_rec.sched_horizon_start_date :=
                         x_Sched_rec.sched_horizon_start_date;
      /*add exclude non-workdays code*/
      v_Input_rec.exclude_non_workdays_flag := x_Group_rec.setup_terms_rec.exclude_non_workdays_flag;

      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'ShipDeliveryRuleName ',
                                 v_Input_rec.ShipDeliveryRuleName);
         rlm_core_sv.dlog(C_DEBUG,'CustomerId ', v_Input_rec.CustomerId);
         rlm_core_sv.dlog(C_DEBUG,'DateTypeCode ', v_Input_rec.DateTypeCode);
         rlm_core_sv.dlog(C_DEBUG,'StartDateTime ', v_Input_rec.StartDateTime);
         rlm_core_sv.dlog(C_DEBUG,'ShipToAddressId ', v_Input_rec.ShipToAddressId);
         rlm_core_sv.dlog(C_DEBUG,'ShipFromOrgId ', v_Input_rec.ShipFromOrgId);
         rlm_core_sv.dlog(C_DEBUG,'CustomerItemId ', v_Input_rec.CustomerItemId);
         rlm_core_sv.dlog(C_DEBUG,'ATPITemFlag ', v_Input_rec.ATPItemFlag);
         rlm_core_sv.dlog(C_DEBUG,'PrimaryQuantity ', v_Input_rec.PrimaryQuantity);
         rlm_core_sv.dlog(C_DEBUG,'EndDateTime ', v_Input_rec.EndDateTime);
         rlm_core_sv.dlog(C_DEBUG,'DefaultSDP ', v_Input_rec.DefaultSDP);
         rlm_core_sv.dlog(C_DEBUG,'ship_method ', v_Input_rec.ship_method);
         rlm_core_sv.dlog(C_DEBUG,'intransit_time ', v_Input_rec.intransit_time);
         rlm_core_sv.dlog(C_DEBUG,'time_uom_code ', v_Input_rec.time_uom_code);
         rlm_core_sv.dlog(C_DEBUG,'customer_rcv_calendar_cd ',
                                     v_Input_rec.customer_rcv_calendar_cd);
         rlm_core_sv.dlog(C_DEBUG,'supplier_shp_calendar_cd ',
                                     v_Input_rec.supplier_shp_calendar_cd);
         rlm_core_sv.dlog(C_DEBUG,'sched_horizon_start_date ',
                                      v_Input_rec.sched_horizon_start_date);
         rlm_core_sv.dlog(C_DEBUG,'use_edi_sdp_code_flag ',
                                      v_Input_rec.use_edi_sdp_code_flag);
      END IF;
      --
      rlm_tpa_sv.calc_scheduled_ship_date(v_Input_rec,
                                          v_Output_tab,
                                          v_message_tab,
                                          v_ReturnStatus);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_ReturnStatus ', v_ReturnStatus);
         rlm_core_sv.dlog(C_DEBUG,'v_message_tab.COUNT ', v_message_tab.COUNT);
      END IF;
      --
      FOR j in 1..v_message_tab.COUNT LOOP
          --
        IF v_message_tab(j).ErrType = -1 THEN
            --
            rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_SHIPDELAPI_FAILED',
                 x_ChildMessageName => v_message_tab(j).ErrMessageName,
                 x_InterfaceHeaderId => x_sched_rec.header_id,
                 x_InterfaceLineId => g_ManageDemand_tab(i).line_id,
                 x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                 x_ScheduleLineId => g_ManageDemand_tab(i).schedule_line_id,
                 x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                 x_OrderLineId => NULL,
                 x_Token1 => 'ERROR',
                 x_value1 => v_message_tab(j).ErrMessage);
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,v_message_tab(j).ErrMessage);
           END IF;
           --
        ELSIF v_message_tab(j).ErrType = 0 THEN
           --
           rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_SHIPDELAPI_WARN',
                x_ChildMessageName => v_message_tab(j).ErrMessageName,
                x_InterfaceHeaderId => x_sched_rec.header_id,
                x_InterfaceLineId => g_ManageDemand_tab(i).line_id,
                x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                x_ScheduleLineId => g_ManageDemand_tab(i).schedule_line_id,
                x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                x_OrderLineId => NULL,
                x_Token1 => 'ERROR',
                x_value1 => v_message_tab(j).ErrMessage);
	   --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,v_message_tab(j).ErrMessage);
           END IF;
           --
        END IF;
        --
      END LOOP;
      --
      IF ((v_ReturnStatus = 2) or
          (v_ReturnStatus = RLM_SHIP_DELIVERY_PATTERN_SV.g_RaiseErr)) THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_ReturnStatus',v_ReturnStatus);
           rlm_core_sv.dlog(C_DEBUG,'RLM_CALCULATE_SHIP_DATE_FAILED');
        END IF;
        --
        raise e_SDPFailed;
        --
      ELSE -- the return status not error
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_Output_tab.COUNT',v_Output_tab.COUNT);
        END IF;
        --
        FOR j IN 1..v_Output_tab.COUNT LOOP
          -- The first line should be updated the rest inserted
          --
          IF j = 1 THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'updating the first line');
            END IF;
            --
            g_ManageDemand_tab(i).request_date :=
                                    v_Output_tab(j).PlannedShipmentDate;
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.request_date',
                                     g_ManageDemand_tab(i).request_date);
            END IF;
            --
            IF v_input_rec.ATPItemFlag = TRUE THEN
               --
               g_ManageDemand_tab(i).SCHEDULE_DATE := NULL;
               --
            ELSE
              --
              g_ManageDemand_tab(i).SCHEDULE_DATE :=
                                     v_Output_tab(j).PlannedShipmentDate;
              --
            END IF;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.SCHEDULE_DATE',
                                         g_ManageDemand_tab(i).SCHEDULE_DATE);
            END IF;
            --
            g_ManageDemand_tab(i).primary_quantity :=
                                      v_Output_tab(j).PrimaryQuantity;
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.primary_quantity',
                           g_ManageDemand_tab(i).primary_quantity);
            END IF;
            --
            g_ManageDemand_tab(i).item_detail_subtype :=
                                      v_Output_tab(j).ItemDetailSubtype;
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'item_detail_subtype',
                             g_ManageDemand_tab(i).item_detail_subtype);
            END IF;
            --
            SetOperation(g_ManageDemand_tab(i), k_UPDATE);
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Set operation to update');
            END IF;
            --
          ELSE -- J<> 1 i.e. there are multiple lines in output tab
            --
            g_ManageDemand_tab(g_ManageDemand_tab.COUNT+1):=g_ManageDemand_tab(i);
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand.Count',
                                             g_ManageDemand_tab.COUNT);
            END IF;
            --
            g_ManageDemand_tab(g_ManageDemand_tab.COUNT).REQUEST_DATE :=
                                         v_Output_tab(j).PlannedShipmentDate;
	    --
	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.REQUEST_DATE',
                      g_ManageDemand_tab(g_ManageDemand_tab.COUNT).REQUEST_DATE);
            END IF;
            --
            g_ManageDemand_tab(g_ManageDemand_tab.COUNT).SCHEDULE_DATE :=
                                  v_Output_tab(j).PlannedShipmentDate;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.SCHEDULE_DATE',
                      g_ManageDemand_tab(g_ManageDemand_tab.COUNT).SCHEDULE_DATE);
            END IF;
            --
            g_ManageDemand_tab(g_ManageDemand_tab.COUNT).primary_quantity :=
                               v_Output_tab(j).PrimaryQuantity;
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.primary_quantity',
                   g_ManageDemand_tab(g_ManageDemand_tab.COUNT).primary_quantity);
            END IF;
            --
            g_ManageDemand_tab(g_ManageDemand_tab.COUNT).item_detail_subtype :=
                                      v_Output_tab(j).ItemDetailSubtype;
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'item_detail_subtype',
	              g_ManageDemand_tab(g_ManageDemand_tab.COUNT).item_detail_subtype);
            END IF;
            --
            SetOperation(g_ManageDemand_tab(g_ManageDemand_tab.COUNT), k_INSERT);
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Set operation to insert');
            END IF;
            --
            IF v_Output_tab(j).ReturnMessage IS NOT NULL THEN
               --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'Return message from SDP APIs: ',
                                       v_Output_tab(j).ReturnMessage);
               END IF;
               --
            END IF;
            --
          END IF;
          --
       END LOOP;
       --
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_SDPFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      raise e_GroupError;
      --
  WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO_DATA_FOUND');
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
  WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      raise;
END CalculateShipDate;


/*===========================================================================

PROCEDURE NAME:    ApplyFFFFences

===========================================================================*/

PROCEDURE ApplyFFFFences(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN rlm_dp_sv.t_Group_rec,
                         IsLineProcessed IN OUT NOCOPY BOOLEAN)
IS

  i                             NUMBER;
  v_FirmFenceDayFrom            NUMBER;
  v_FirmFenceDayTo              NUMBER;
  v_ForecastFenceDayFrom        NUMBER;
  v_ForecastFenceDayTo          NUMBER;
  v_FrozenFenceDayFrom          NUMBER;
  v_FrozenFenceDayTo            NUMBER;
  v_MRPFenceDayFrom             NUMBER;
  v_MRPFenceDayTo               NUMBER;
  v_FirmFenceDays               NUMBER := NULL;
  v_ForecastFenceDays           NUMBER := NULL;
  v_FrozenFenceDays             NUMBER := NULL;
  v_MRPFenceDays                NUMBER := NULL;
  v_Progress                    VARCHAR2(3) := '010';
  -- Bug 4297984
  v_MatchAttrTxt                VARCHAR2(2000);
  v_match_rec                   RLM_RD_SV.t_generic_rec;
  v_Group_rec                   rlm_dp_sv.t_Group_rec;

BEGIN
 --
 IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ApplyFFFFences');
     rlm_core_sv.dlog(C_DEBUG,' x_Sched_rec.Schedule_type',
                                       x_Sched_rec.Schedule_type);
     rlm_core_sv.dlog(C_DEBUG,'TRUNC(SYSDATE)',
                                  TRUNC(SYSDATE));
     rlm_core_sv.dlog(C_DEBUG,' x_Sched_rec.sched_horizon_start_date',
                                  x_Sched_rec.sched_horizon_start_date);
     rlm_core_sv.dlog(C_DEBUG,' x_Sched_rec.sched_horizon_end_date',
                             x_Sched_rec.sched_horizon_end_date);
 END IF;
 --
 IF x_Sched_rec.Schedule_type = k_PLANNING THEN

   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'PLANNING');
   END IF;
   --
   v_FrozenFenceDayFrom := x_Group_rec.setup_terms_rec.pln_frozen_day_from;
   v_FrozenFenceDayTo := x_Group_rec.setup_terms_rec.pln_frozen_day_to;
   v_FirmFenceDayFrom := x_Group_rec.setup_terms_rec.pln_firm_day_from;
   v_FirmFenceDayTo := x_Group_rec.setup_terms_rec.pln_firm_day_to;
   v_ForecastFenceDayFrom := x_Group_rec.setup_terms_rec.pln_forecast_day_from;
   v_ForecastFenceDayTo := x_Group_rec.setup_terms_rec.pln_forecast_day_to;
   v_ForecastFenceDayFrom := x_Group_rec.setup_terms_rec.pln_forecast_day_from;
   v_ForecastFenceDayTo := x_Group_rec.setup_terms_rec.pln_forecast_day_to;
   v_MRPFenceDayFrom := x_Group_rec.setup_terms_rec.pln_mrp_forecast_day_from;
   v_MRPFenceDayTo := x_Group_rec.setup_terms_rec.pln_mrp_forecast_day_to;

 ELSIF x_Sched_rec.Schedule_type = k_SHIPPING THEN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'SHIPPING');
   END IF;
   --
   v_FrozenFenceDayFrom := x_Group_rec.setup_terms_rec.shp_frozen_day_from;
   v_FrozenFenceDayTo := x_Group_rec.setup_terms_rec.shp_frozen_day_to;
   v_FirmFenceDayFrom := x_Group_rec.setup_terms_rec.shp_firm_day_from;
   v_FirmFenceDayTo := x_Group_rec.setup_terms_rec.shp_firm_day_to;
   v_ForecastFenceDayFrom := x_Group_rec.setup_terms_rec.shp_forecast_day_from;
   v_ForecastFenceDayTo := x_Group_rec.setup_terms_rec.shp_forecast_day_to;
   v_MRPFenceDayFrom := x_Group_rec.setup_terms_rec.shp_mrp_forecast_day_from;
   v_MRPFenceDayTo := x_Group_rec.setup_terms_rec.shp_mrp_forecast_day_to;

 ELSIF x_Sched_rec.Schedule_type = k_SEQUENCED THEN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'SEQUENCED');
   END IF;
   --
   v_FrozenFenceDayFrom := x_Group_rec.setup_terms_rec.seq_frozen_day_from;
   v_FrozenFenceDayTo := x_Group_rec.setup_terms_rec.seq_frozen_day_to;
   v_FirmFenceDayFrom := x_Group_rec.setup_terms_rec.seq_firm_day_from;
   v_FirmFenceDayTo := x_Group_rec.setup_terms_rec.seq_firm_day_to;
   v_ForecastFenceDayFrom := x_Group_rec.setup_terms_rec.seq_forecast_day_from;
   v_ForecastFenceDayTo := x_Group_rec.setup_terms_rec.seq_forecast_day_to;
   v_MRPFenceDayFrom := x_Group_rec.setup_terms_rec.seq_mrp_forecast_day_from;
   v_MRPFenceDayTo := x_Group_rec.setup_terms_rec.seq_mrp_forecast_day_to;

 END IF;

  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_FrozenFenceDayFrom',v_FrozenFenceDayFrom);
     rlm_core_sv.dlog(C_DEBUG,'v_FrozenFenceDayTo',v_FrozenFenceDayTo);
     rlm_core_sv.dlog(C_DEBUG,'v_FirmFenceDayFrom',v_FirmFenceDayFrom);
     rlm_core_sv.dlog(C_DEBUG,'v_FirmFenceDayTo',v_FirmFenceDayTo);
     rlm_core_sv.dlog(C_DEBUG,'v_ForecastFenceDayFrom',v_ForecastFenceDayFrom);
     rlm_core_sv.dlog(C_DEBUG,'v_ForecastFenceDayTo',v_ForecastFenceDayTo);
     rlm_core_sv.dlog(C_DEBUG,'v_MRPFenceDayFrom',v_MRPFenceDayFrom);
     rlm_core_sv.dlog(C_DEBUG,'v_MRPFenceDayTo',v_MRPFenceDayTo);
  END IF;

 IF v_FrozenFenceDayFrom IS NOT NULL THEN
    v_FrozenFenceDays := v_FrozenFenceDayTo - v_FrozenFenceDayFrom + 1;
 ELSE
    v_FrozenFenceDays := NULL;
 END IF;

 IF v_FirmFenceDayFrom IS NOT NULL THEN
   IF v_FirmFenceDayFrom <> 0 THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_FirmFenceDayFrom',v_FirmFenceDayFrom);
      END IF;
      --
      v_FirmFenceDays := v_FirmFenceDayTo - v_FirmFenceDayFrom + 1;
   ELSE
      v_FirmFenceDays := 0;
   END IF;
 ELSE
    v_FirmFenceDays := NULL;
 END IF;

 IF v_ForecastFenceDayFrom IS NOT NULL THEN
   IF v_ForecastFenceDayFrom <> 0 THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_ForecastFenceDayFrom',v_ForecastFenceDayFrom);
      END IF;
      --
      v_ForecastFenceDays := v_ForecastFenceDayTo - v_ForecastFenceDayFrom + 1;
   ELSE
      v_ForecastFenceDays := 0;
   END IF;
 ELSE
      v_ForecastFenceDays := NULL;
 END IF;

 IF v_MRPFenceDayFrom IS NOT NULL THEN
   IF v_MRPFenceDayFrom <> 0 THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'v_MRPFenceDayFrom',v_MRPFenceDayFrom);
      END IF;
      --
      v_MRPFenceDays := v_MRPFenceDayTo - v_MRPFenceDayFrom + 1;
   ELSE
      v_MRPFenceDays := 0;
   END IF;
 ELSE
      v_MRPFenceDays := NULL;
 END IF;
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG,'v_FrozenFenceDays',v_FrozenFenceDays);
    rlm_core_sv.dlog(C_DEBUG,'v_FirmFenceDays',v_FirmFenceDays);
    rlm_core_sv.dlog(C_DEBUG,'v_ForecastFenceDays',v_ForecastFenceDays);
    rlm_core_sv.dlog(C_DEBUG,'v_MRPFenceDays',v_MRPFenceDays);
 END IF;
 --
/* checking for past due demand and giving a warning message */
 --
 FOR i IN 1..g_ManageDemand_tab.COUNT LOOP --{
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').request_date',
                                    g_ManageDemand_tab(i).request_date);
        rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').schedule_date',
                                    g_ManageDemand_tab(i).schedule_date);
        rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                    g_ManageDemand_tab(i).item_detail_type);
        rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').process_status',
                                    g_ManageDemand_tab(i).process_status);
     END IF;
     --
     IF (g_ManageDemand_tab(i).request_date <
              TRUNC(SYSDATE) ) THEN --{
        --
        --pdue
        IF x_sched_rec.schedule_source <> 'MANUAL' THEN --{
          --
          --g_ManageDemand_tab(i).item_detail_type := k_PAST_DUE_FIRM;
          IF v_FirmFenceDays IS NOT NULL THEN --{
             --
             g_ManageDemand_tab(i).item_detail_type := k_FIRM_DEMAND;
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                       g_ManageDemand_tab(i).item_detail_type);
                rlm_core_sv.dlog(C_DEBUG,'k_FIRM_DEMAND', k_FIRM_DEMAND);
             END IF;
             --
          ELSE --}{
             --
             IF v_ForecastFenceDays IS NOT NULL THEN --{
                --
                IF v_ForecastFenceDayFrom = 1 THEN --{
                   --
                   g_ManageDemand_tab(i).item_detail_type := k_FORECAST_DEMAND;
                   --
                END IF; --}
                --
  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                          g_ManageDemand_tab(i).item_detail_type);
                   rlm_core_sv.dlog(C_DEBUG,'k_FORECAST_DEMAND', k_FORECAST_DEMAND);
                END IF;
                --
             ELSE --}{
                --
                IF v_MRPFenceDays IS NOT NULL THEN --{
                   --
                   IF v_MRPFenceDayFrom = 1 THEN --{
                     --
                     g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
                     --
                   END IF; --}
                   --
  	           IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                             g_ManageDemand_tab(i).item_detail_type);
                      rlm_core_sv.dlog(C_DEBUG,'k_MRP_FORECAST', k_MRP_FORECAST);
                   END IF;
                   --
                END IF; --}
                --
             END IF; --}
             --
          END IF; --}
          --
        END IF; --}
        --
        -- Bug 4297984
        RLM_RD_SV.AssignMatchAttribValues(g_ManageDemand_tab(i),v_match_rec);
        -- RLM_RD_SV.GetMatchAttributes defines the second argument:Group_rec as IN OUT
        -- where as in this function (ApplyFFFFences) x_Group_rec is an IN arguement.
        -- Hence x_Group_rec cannot be passed as such and the following assignment is done.
        v_Group_rec := x_Group_rec;
        RLM_RD_SV.GetMatchAttributes(x_Sched_rec, v_Group_rec, v_match_rec, v_MatchAttrTxt);
        --
        IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN --{
            --
            rlm_message_sv.app_error(
               x_ExceptionLevel => rlm_message_sv.k_warn_level,
               x_MessageName => 'RLM_PAST_DUE_DEMAND_SEQ',
               x_InterfaceHeaderId => x_sched_rec.header_id,
               x_InterfaceLineId => g_ManageDemand_tab(i).line_id,
               x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
               x_ScheduleLineId => g_ManageDemand_tab(i).schedule_line_id,
               x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
               x_OrderLineId => NULL,
               x_token1 => 'QUANTITY',
               x_value1 => g_ManageDemand_tab(i).primary_quantity,
               x_Token2 => 'GROUP',
               x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                           rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                           rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
               x_token3 => 'REQ_DATE',
               x_value3 => g_ManageDemand_tab(i).request_date,
               x_token4 => 'START_DATE_TIME',
               x_value4 => to_date(g_ManageDemand_tab(i).industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
               x_token5 => 'PROCDATE',
               x_value5 => sysdate,
               x_Token6 => 'SEQ_INFO',
               x_value6 => nvl(g_ManageDemand_tab(i).cust_production_seq_num,'NULL') || '-' ||
	                   nvl(g_ManageDemand_tab(i).cust_model_serial_number,'NULL')|| '-' ||
			   nvl(g_ManageDemand_tab(i).customer_job,'NULL'),
               x_Token7 => 'MATCH_ATTR',
               x_value7 => v_MatchAttrTxt);
            --
            IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'RLM_PAST_DUE_DEMAND_SEQ');
                rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                 g_ManageDemand_tab(i).item_detail_type);
            END IF;
            --
        ELSE --}{
            --
            rlm_message_sv.app_error(
               x_ExceptionLevel => rlm_message_sv.k_warn_level,
               x_MessageName => 'RLM_PAST_DUE_DEMAND',
               x_InterfaceHeaderId => x_sched_rec.header_id,
               x_InterfaceLineId => g_ManageDemand_tab(i).line_id,
               x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
               x_ScheduleLineId => g_ManageDemand_tab(i).schedule_line_id,
               x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
               x_OrderLineId => NULL,
               x_token1 => 'QUANTITY',
               x_value1 => g_ManageDemand_tab(i).primary_quantity,
               x_Token2 => 'GROUP',
               x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                           rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                           rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
               x_token3 => 'REQ_DATE',
               x_value3 => g_ManageDemand_tab(i).request_date,
               x_token4 => 'START_DATE_TIME',
               x_value4 => to_date(g_ManageDemand_tab(i).industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
               x_token5 => 'PROCDATE',
               x_value5 => sysdate,
               x_Token6 => 'SCHEDULE_LINE',
               x_value6 => rlm_core_sv.get_schedule_line_number(g_ManageDemand_tab(i).schedule_line_id),
               x_Token7 => 'MATCH_ATTR',
               x_value7 => v_MatchAttrTxt);
            --
            IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'RLM_PAST_DUE_DEMAND');
                rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                 g_ManageDemand_tab(i).item_detail_type);
            END IF;
            --
        END IF; --}
	--
     END IF; --}
     --
 END LOOP; --}
 --
 IF x_sched_rec.schedule_source <> 'MANUAL' THEN --{
    --
    IF v_FirmFenceDays IS NOT NULL OR v_ForecastFenceDays IS NOT NULL
      OR v_FrozenFenceDays IS NOT NULL OR v_MRPFenceDays IS NOT NULL THEN --{
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.COUNT',
                                       g_ManageDemand_tab.COUNT);
      END IF;
      --
      FOR i IN 1..g_ManageDemand_tab.COUNT LOOP --{
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').request_date',
                                     g_ManageDemand_tab(i).request_date);
           rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                    g_ManageDemand_tab(i).item_detail_type);
           rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').process_status',
                                    g_ManageDemand_tab(i).process_status);
        END IF;
        --

        /* Bug 3339621
         * Bug fix for Dana                                                  *
         * If firm AND forecast fences are null AND MRP fences not null then *
         *  If request date falls between MRP fences                     *
         *     lines should be interfaced to MRP                             *
         *  else                                                             *
         *     drop demand and set line process status to 5                  *
         *  end if                                                           *
         * else                                                              *
         *  continue regular DSP flow                                        *
         * end if                                                            *
        */
        IF (v_FirmFenceDays = 0 AND
            v_ForecastFenceDays = 0 AND v_MRPFenceDays > 0) THEN --{

         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Firm and forecast fences are set to zero');
           rlm_core_sv.dlog(C_DEBUG, 'MRP forecast fences are set to not-null values');
         END IF;
         --
         IF (g_ManageDemand_tab(i).request_date BETWEEN
             (TRUNC(SYSDATE) + v_MRPFenceDayFrom - 1) AND
             (TRUNC(SYSDATE) + v_MRPFenceDayTo - 1)) THEN --{
          --
          IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'request date is within MRP fences');
          END IF;
          --
          g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
          SetOperation(g_ManageDemand_tab(i), k_UPDATE);
          --
         ELSE --}{
          --
          IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'request date outside MRP fences');
            rlm_core_sv.dlog(C_DEBUG, 'Demand line will be dropped');
          END IF;
          --
          IsLineProcessed := TRUE;
          g_ManageDemand_tab(i).process_status := rlm_core_sv.k_PS_PROCESSED;
          --Bug 5208135
          IF (g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST) THEN
              g_ManageDemand_tab(i).item_detail_type := k_MRP_DROP_DEMAND;
          END IF;

          SetOperation(g_ManageDemand_tab(i), k_UPDATE);
          --
         END IF; --}
        ELSIF v_FirmFenceDays = 0 THEN --}{
           --
           g_ManageDemand_tab(i).process_status := rlm_core_sv.k_PS_PROCESSED;
           IsLineProcessed := TRUE;
           SetOperation(g_ManageDemand_tab(i), k_UPDATE);
           --
        ELSIF v_FirmFenceDays IS NOT NULL THEN --}{
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'v_FirmFenceDayFROM',v_FirmFenceDayFrom);
               rlm_core_sv.dlog(C_DEBUG,'v_FirmFenceDayTo',v_FirmFenceDayTo);
            END IF;
            --
            -- Bug 4207235
            --
            IF  ( v_FrozenFenceDays is NOT NULL AND
                  g_ManageDemand_tab(i).request_date < (TRUNC(SYSDATE) + v_FirmFenceDayTo) )
                OR
                ( v_FrozenFenceDays is NULL AND
                  g_ManageDemand_tab(i).request_date < (TRUNC(SYSDATE) + v_FirmFenceDayTo) AND
                  g_ManageDemand_tab(i).request_date >=(TRUNC(SYSDATE) + v_FirmFenceDayFrom - 1) ) THEN --{
                --
                IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'request_date within firm fence');
                END IF;
                --
                g_ManageDemand_tab(i).item_detail_type := k_FIRM_DEMAND;
                SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                --
            ELSIF (g_ManageDemand_tab(i).request_date >=
                (TRUNC(SYSDATE) + v_FirmFenceDayTo)) THEN --}{
                --
  	        IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'request_date outside firm fence');
                END IF;
                --
                IF v_ForecastFenceDays = 0 THEN --{
                   --
                   g_ManageDemand_tab(i).item_detail_type := k_FORECAST_DEMAND;
                   g_ManageDemand_tab(i).process_status
                                        := rlm_core_sv.k_PS_PROCESSED;
                   IsLineProcessed := TRUE;
                   SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                   --
                ELSIF v_ForecastFenceDays is NOT NULL THEN --}{
                   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'v_ForecastFenceDays',
                                            v_ForecastFenceDays);
                   END IF;
                   --
                   IF(g_ManageDemand_tab(i).request_date <
                     (TRUNC(SYSDATE) +
                                             v_ForecastFenceDayTo))THEN --{
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_DEBUG,'request_date inside oe forecast fence');
                      END IF;
	              --
                      g_ManageDemand_tab(i).item_detail_type := k_FORECAST_DEMAND;
                      SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                      --
                   ELSIF(g_ManageDemand_tab(i).request_date >=
                      (TRUNC(SYSDATE) + v_ForecastFenceDayTo))THEN --}{
                      --
		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_DEBUG,'request_date outside oe forecast fence');
                      END IF;
	              --
                      IF v_MRPFenceDays  = 0  THEN --{
                         --
                         g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
                         g_ManageDemand_tab(i).process_status
                                        := rlm_core_sv.k_PS_PROCESSED;
                         IsLineProcessed := TRUE;
                         SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                         --
                      ELSIF v_MRPFenceDays is NOT NULL THEN --}{
                         --
                         IF (g_ManageDemand_tab(i).request_date <
                            (TRUNC(SYSDATE) + v_MRPFenceDayTo)) THEN --{
                             --
  			     IF (l_debug <> -1) THEN
                                rlm_core_sv.dlog(C_DEBUG,
                                     'request_date inside MRP forecast fence');
                             END IF;
	                     --
                             g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
                             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                             --
                         ELSIF (g_ManageDemand_tab(i).request_date >=
                             (TRUNC(SYSDATE) + v_MRPFenceDayTo)) THEN --}{
                             --
  			     IF (l_debug <> -1) THEN
                                rlm_core_sv.dlog(C_DEBUG,
                                        'request_date outside MRP forecast fence');
                             END IF;
			     --
                             g_ManageDemand_tab(i).process_status
                                        := rlm_core_sv.k_PS_PROCESSED;
                             --Bug 5208135
                             IF (g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST) THEN
                                 g_ManageDemand_tab(i).item_detail_type := k_MRP_DROP_DEMAND;
                             END IF;
                             --
                             IsLineProcessed := TRUE;
                             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                             --
                         END IF; --}
                         --
                      END IF; /* MRP fence NULL */ --}
                      --
                   END IF; /* schedule date check */ --}
                   --
                ELSE --}{
                    --
                    /* IF OE forecast fence is NULL */
  		    IF (l_debug <> -1) THEN
                       rlm_core_sv.dlog(C_DEBUG,'OE Forecast fence NULL' );
                    END IF;
                    --
                    IF v_MRPFenceDays  = 0  THEN  --{
                       --
  		       IF (l_debug <> -1) THEN
                          rlm_core_sv.dlog(C_DEBUG, ' item_detail_type',
                                      g_ManageDemand_tab(i).item_detail_type );
                       END IF;
		       --
                       IF g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST THEN --{
                          --
                          g_ManageDemand_tab(i).process_status
                                             := rlm_core_sv.k_PS_PROCESSED;
                          IsLineProcessed := TRUE;
                          SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                          --
                       END IF; --}
                       --
                    ELSIF v_MRPFenceDays is NOT NULL THEN --}{
                        --
  			IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG,'MRP Forecast fence NOT NULL' );
                        END IF;
	                --
                        IF (g_ManageDemand_tab(i).request_date BETWEEN
                           (TRUNC(SYSDATE) + v_MRPFenceDayFrom - 1) AND
                           (TRUNC(SYSDATE) + v_MRPFenceDayTo - 1)) THEN --{
                             --
  			     IF (l_debug <> -1) THEN
                                rlm_core_sv.dlog(C_DEBUG,
                                          'request_date inside MRP forecast fence');
                             END IF;
			     --
                             g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
                             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                             --
                        ELSIF (g_ManageDemand_tab(i).request_date >=
                           (TRUNC(SYSDATE) + v_MRPFenceDayTo)) THEN --}{
                             --
  			     IF (l_debug <> -1) THEN
                                rlm_core_sv.dlog(C_DEBUG,
                                             'request_date outside MRP forecast fence');
                             END IF;
			     --
                             g_ManageDemand_tab(i).process_status
                                             := rlm_core_sv.k_PS_PROCESSED;
                             --Bug 5208135
                             IF (g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST) THEN
                                 g_ManageDemand_tab(i).item_detail_type := k_MRP_DROP_DEMAND;
                             END IF;
                             --
                             IsLineProcessed := TRUE;
                             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                             --
                        END IF; --}
                        --
                    END IF; /* v_MRPFence is zero */ --}
                    --
                END IF; /* OE fence NULL */ --}
                --
            END IF; /* schedule date check */ --}
            --
        ELSE --}{
            --
            /* if firmfence is null */
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG, 'firm fence is null');
            END IF;
	    --
            IF v_ForecastFenceDays = 0 THEN --{
               --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG, ' item_detail_type',
                                 g_ManageDemand_tab(i).item_detail_type );
               END IF;
	       --
               IF g_ManageDemand_tab(i).item_detail_type = k_FORECAST_DEMAND OR
                  g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST  THEN --{
                  --
                  g_ManageDemand_tab(i).process_status:= rlm_core_sv.k_PS_PROCESSED;
                  IsLineProcessed := TRUE;
                  SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                  --
               END IF; --}
               --
            ELSIF v_ForecastFenceDays IS NOT NULL THEN --}{
                  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(C_DEBUG, 'OE forecast fence not null');
                  END IF;
                  --
                  IF (g_ManageDemand_tab(i).request_date <
                     (TRUNC(SYSDATE) + v_ForecastFenceDayTo))
                      AND
                     (g_ManageDemand_tab(i).request_date >=
                     (TRUNC(SYSDATE) +
                      v_ForecastFenceDayFrom - 1)) THEN --{
                      --
		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_DEBUG,'request_date inside oe forecast fence');
                      END IF;
	              --
                      g_ManageDemand_tab(i).item_detail_type := k_FORECAST_DEMAND;
                      SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                      --
                  ELSIF(g_ManageDemand_tab(i).request_date >=
                       (TRUNC(SYSDATE) +
                                   v_ForecastFenceDayTo))THEN --}{
                      --
  		      IF (l_debug <> -1) THEN
                         rlm_core_sv.dlog(C_DEBUG,'request_date outside oe forecast fence');
                      END IF;
		      --
                      IF v_MRPFenceDays  = 0  THEN  --{
                         --
                         g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
                         g_ManageDemand_tab(i).process_status
                                        := rlm_core_sv.k_PS_PROCESSED;
                         IsLineProcessed := TRUE;
                         SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                         --
                      ELSIF v_MRPFenceDays is NOT NULL THEN --}{
                         --
                         IF (g_ManageDemand_tab(i).request_date <
                            (TRUNC(SYSDATE) + v_MRPFenceDayTo)) THEN --{
                             --
  		             IF (l_debug <> -1) THEN
                                rlm_core_sv.dlog(C_DEBUG,
                                     'request_date inside MRP forecast fence');
                             END IF;
			     --
                             g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
                             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                             --
                         ELSIF (g_ManageDemand_tab(i).request_date >=
                             (TRUNC(SYSDATE) + v_MRPFenceDayTo)) THEN --}{
                             --
  			     IF (l_debug <> -1) THEN
                                rlm_core_sv.dlog(C_DEBUG,
                                        'request_date outside MRP forecast fence');
                             END IF;
			     --
                             g_ManageDemand_tab(i).process_status
                                        := rlm_core_sv.k_PS_PROCESSED;
                             --Bug 5208135
                             IF (g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST) THEN
                                 g_ManageDemand_tab(i).item_detail_type := k_MRP_DROP_DEMAND;
                             END IF;
                             --
                             IsLineProcessed := TRUE;
                             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                             --
                         END IF; --}
                         --
                      END IF; /* v_MRPFence is 0 */ --}
                  END IF; /* request date check */  --}
            ELSE --}{
               --
               /* IF OE forecast fence is NULL */
  	       IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'OE Forecast fence NULL' );
               END IF;
               --
               IF v_MRPFenceDays  = 0  THEN  --{
                  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(C_DEBUG, ' item_detail_type',
                                 g_ManageDemand_tab(i).item_detail_type );
                  END IF;
		  --
                  IF g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST THEN --{
                     --
                     g_ManageDemand_tab(i).process_status
                                        := rlm_core_sv.k_PS_PROCESSED;
                     IsLineProcessed := TRUE;
                     SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                     --
                  END IF; --}
                  --
               ELSIF v_MRPFenceDays is NOT NULL THEN --}{
                   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'MRP Forecast fence NOT NULL' );
                   END IF;
	           --
                   IF (g_ManageDemand_tab(i).request_date BETWEEN
                      (TRUNC(SYSDATE) + v_MRPFenceDayFrom - 1) AND
                      (TRUNC(SYSDATE) + v_MRPFenceDayTo - 1)) THEN --{
                        --
  		        IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG,
                                     'request_date inside MRP forecast fence');
                        END IF;
	                --
                        g_ManageDemand_tab(i).item_detail_type := k_MRP_FORECAST;
                        SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                        --
                   ELSIF (g_ManageDemand_tab(i).request_date >=
                      (TRUNC(SYSDATE) + v_MRPFenceDayTo)) THEN --}{
                        --
  			IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG,
                                        'request_date outside MRP forecast fence');
                        END IF;
			--
                        g_ManageDemand_tab(i).process_status
                                        := rlm_core_sv.k_PS_PROCESSED;
                        --Bug 5208135
                        IF (g_ManageDemand_tab(i).item_detail_type = k_MRP_FORECAST) THEN
                            g_ManageDemand_tab(i).item_detail_type := k_MRP_DROP_DEMAND;
                        END IF;
                        --
                        IsLineProcessed := TRUE;
                        SetOperation(g_ManageDemand_tab(i), k_UPDATE);
                        --
                   END IF; --}
                   --
               END IF; /* v_MRPFence is zero */ --}
               --
            END IF; /*  OE ForecastFence NULL */ --}
            --
        END IF; /* Firm Fence is NULL */ --}
        --
        IF v_FrozenFenceDays IS NOT NULL
           AND g_ManageDemand_tab(i).request_date < (TRUNC(SYSDATE) + v_FrozenFenceDays)
           AND g_ManageDemand_tab(i).item_detail_type <> k_FORECAST_DEMAND
           AND g_ManageDemand_tab(i).item_detail_type <> k_MRP_FORECAST
           AND nvl(v_FirmFenceDays,-99) <> 0  --bug 3562125
        THEN --{
             --
             g_ManageDemand_tab(i).process_status := rlm_core_sv.k_PS_FROZEN_FIRM;
             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
             --
        END IF; --}
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').item_detail_type',
                                        g_ManageDemand_tab(i).item_detail_type);
           rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab(' || i || ').process_status',
                                        g_ManageDemand_tab(i).process_status);
        END IF;
        --
      END LOOP; --}
    --
   END IF; --}
   --
 END IF; --}
 --
 IF IsLineProcessed THEN
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog('Some of the lines are in fully processed state');
    END IF;
 END IF;
 --
 IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(C_SDEBUG);
 END IF;
 --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: NO_DATA_FOUND');
       rlm_core_sv.dlog('rlm_manage_demand_sv.ApplyFFFFences', v_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_manage_demand_sv.ApplyFFFFences', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ApplyFFFFences;

/*===========================================================================

PROCEDURE NAME:    ProcessTable

===========================================================================*/

PROCEDURE ProcessTable(x_Demand_tab IN t_MD_Tab)
IS

  i		NUMBER;
  v_Progress	VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ProcessTable');
     rlm_core_sv.dlog(C_DEBUG,'x_Demand_tab.COUNT',x_Demand_tab.COUNT);
  END IF;
  --
  FOR i IN 1..x_Demand_tab.COUNT LOOP
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').line_id', x_Demand_tab(i).line_id);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').primary_quantity', x_Demand_tab(i).primary_quantity);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').customer_item_id', x_Demand_tab(i).customer_item_id);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').item_detail_type', x_Demand_tab(i).item_detail_type);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').industry_attribute15', x_Demand_tab(i).industry_attribute15);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').header_id', x_Demand_tab(i).header_id);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').request_date', x_Demand_tab(i).request_date);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').program_id', x_Demand_tab(i).program_id);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').process_status', x_Demand_tab(i).process_status);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').ship_from_org_id',
                                  x_Demand_tab(i).ship_from_org_id);
       rlm_core_sv.dlog(C_DEBUG, 'x_Demand_tab('||i||').ship_to_customer_id', x_Demand_tab(i).ship_to_customer_id);
    END IF;
    --
    IF x_Demand_tab(i).program_id = k_DELETE THEN
      DeleteReq(x_Demand_tab(i));
    ELSIF x_Demand_tab(i).program_id = k_UPDATE THEN
      UpdateReq(x_Demand_tab(i));
    ELSIF x_Demand_tab(i).program_id = k_INSERT THEN
      InsertReq(x_Demand_tab(i));
    END IF;
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.ProcessTable',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ProcessTable;


/*===========================================================================

PROCEDURE NAME:    DeleteReq

===========================================================================*/

PROCEDURE DeleteReq(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE)
IS

  i		NUMBER;
  v_Progress	VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DeleteReq');
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.line_id',x_ManageDemand_rec.line_id);
  END IF;
  --
  DELETE	rlm_interface_lines
  WHERE		line_id = x_ManageDemand_rec.line_id;
  --
  -- JAUTOMO: The interface_line_id should be updated with the
  --          the line id of new lines created by SDP, Sourcing Rules,
  --          or Aggregate Demand.
  --
  --UPDATE	rlm_schedule_lines
  --SET           interface_line_id = NULL
  --WHERE		line_id = x_ManageDemand_rec.schedule_line_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.DeleteReq',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END DeleteReq;


/*===========================================================================

PROCEDURE NAME:    InsertReq

===========================================================================*/

PROCEDURE InsertReq(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE)
IS
  --
  v_Progress	VARCHAR2(3) := '010';
  e_NullOrgId   EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'InsertReq');
     rlm_core_sv.dlog(C_DEBUG,'Changed lines to be inserted into table');
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.primary_quantity',
                            x_ManageDemand_rec.primary_quantity);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.ship_from_org_id',
                            x_ManageDemand_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.item_detail_type',
                            x_ManageDemand_rec.item_detail_type);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.item_detail_subtype',
                            x_ManageDemand_rec.item_detail_subtype);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.line_source',
                            x_ManageDemand_rec.line_source);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.qty_type_code',
                            x_ManageDemand_rec.qty_type_code);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.org_id',
                            x_ManageDemand_rec.org_id);
  END IF;
  --
  IF x_ManageDemand_rec.org_id IS NULL THEN
   RAISE e_NullOrgId;
  END IF;
  --
  INSERT INTO rlm_interface_lines_all(
  line_id,
  header_id,
  schedule_item_num,
  agreement_id,
  ato_data_type,
  bill_to_address_1_ext,
  bill_to_address_2_ext,
  bill_to_address_3_ext,
  bill_to_address_4_ext,
  bill_to_address_id,
  bill_to_city_ext,
  bill_to_country_ext,
  bill_to_county_ext,
  bill_to_name_ext,
  bill_to_postal_cd_ext,
  bill_to_province_ext,
  bill_to_site_use_id,
  invoice_to_org_id,
  bill_to_state_ext,
  carrier_id_code_ext,
  carrier_qualifier_ext,
  commodity_ext,
  country_of_origin_ext,
  cust_assembly_ext,
  cust_assigned_id_ext,
  cust_bill_to_ext,
  cust_contract_num_ext,
  customer_dock_code,
  cust_intrmd_ship_to_ext,
  cust_item_price_ext,
  cust_item_price_uom_ext,
  customer_item_revision,
  customer_job,
  cust_manufacturer_ext,
  cust_model_number_ext,
  cust_model_serial_number,
  cust_order_num_ext,
  cust_process_num_ext,
  cust_production_line,
   -- cust_record_year, -- Removed from table
  cust_set_num_ext,
  cust_ship_from_org_ext,
  cust_ship_to_ext,
  cust_uom_ext,
  customer_item_ext,
  customer_item_id,
  REQUEST_DATE,
  SCHEDULE_DATE,
  date_type_code,
  date_type_code_ext,
  delivery_lead_time,
  end_date_time,
  equipment_code_ext,
  equipment_number_ext,
  handling_code_ext,
  hazard_code_ext,
  hazard_code_qual_ext,
  hazard_description_ext,
  import_license_date_ext,
  import_license_ext,
  industry_attribute1,
  industry_attribute10,
  industry_attribute11,
  industry_attribute12,
  industry_attribute13,
  industry_attribute14,
  industry_attribute15,
  industry_attribute2,
  industry_attribute3,
  industry_attribute4,
  industry_attribute5,
  industry_attribute6,
  industry_attribute7,
  industry_attribute8,
  industry_attribute9,
  industry_context,
  intrmd_ship_to_id,
  intrmd_st_address_1_ext,
  intrmd_st_address_2_ext,
  intrmd_st_address_3_ext,
  intrmd_st_address_4_ext,
  intrmd_st_city_ext,
  intrmd_st_country_ext,
  intrmd_st_county_ext,
  intrmd_st_name_ext,
  intrmd_st_postal_cd_ext,
  intrmd_st_province_ext,
  intrmd_st_state_ext,
  intmed_ship_to_org_id,
  inventory_item_id,
  inventory_item_segment1,
  inventory_item_segment10,
  inventory_item_segment11,
  inventory_item_segment12,
  inventory_item_segment13,
  inventory_item_segment14,
  inventory_item_segment15,
  inventory_item_segment16,
  inventory_item_segment17,
  inventory_item_segment18,
  inventory_item_segment19,
  inventory_item_segment2,
  inventory_item_segment20,
  inventory_item_segment3,
  inventory_item_segment4,
  inventory_item_segment5,
  inventory_item_segment6,
  inventory_item_segment7,
  inventory_item_segment8,
  inventory_item_segment9,
  item_contact_code_1,
  item_contact_code_2,
  item_contact_value_1,
  item_contact_value_2,
  item_description_ext,
  item_detail_quantity,
  item_detail_ref_code_1,
  item_detail_ref_code_2,
  item_detail_ref_code_3,
  item_detail_ref_value_1,
  item_detail_ref_value_2,
  item_detail_ref_value_3,
  item_detail_subtype,
  item_detail_subtype_ext,
  item_detail_type,
  item_detail_type_ext,
  item_eng_cng_lvl_ext,
  item_measurements_ext,
  item_note_text,
  item_ref_code_1,
  item_ref_code_2,
  item_ref_code_3,
  item_ref_value_1,
  item_ref_value_2,
  item_ref_value_3,
  item_release_status_ext,
  lading_quantity_ext,
  letter_credit_expdt_ext,
  letter_credit_ext,
  line_reference,
  link_to_line_ref,
  order_header_id,
  other_name_code_1,
  other_name_code_2,
  other_name_value_1,
  other_name_value_2,
  pack_size_ext,
  pack_units_per_pack_ext,
  pack_uom_code_ext,
  packaging_code_ext,
  parent_link_line_ref,
  cust_production_seq_num,
  price_list_id,
  primary_quantity,
  primary_uom_code,
  prime_contrctr_part_ext,
  process_status,
  cust_po_release_num,
  cust_po_date,
  cust_po_line_num,
  cust_po_number,
  qty_type_code,
  qty_type_code_ext,
  return_container_ext,
  schedule_line_id,
  routing_desc_ext,
  routing_seq_code_ext,
  ship_del_pattern_ext,
  ship_del_time_code_ext,
  ship_del_rule_name,
  ship_from_address_1_ext,
  ship_from_address_2_ext,
  ship_from_address_3_ext,
  ship_from_address_4_ext,
  ship_from_city_ext,
  ship_from_country_ext,
  ship_from_county_ext,
  ship_from_name_ext,
  ship_from_org_id,
  ship_from_postal_cd_ext,
  ship_from_province_ext,
  ship_from_state_ext,
  ship_label_info_line_1,
  ship_label_info_line_10,
  ship_label_info_line_2,
  ship_label_info_line_3,
  ship_label_info_line_4,
  ship_label_info_line_5,
  ship_label_info_line_6,
  ship_label_info_line_7,
  ship_label_info_line_8,
  ship_label_info_line_9,
  ship_to_address_1_ext,
  ship_to_address_2_ext,
  ship_to_address_3_ext,
  ship_to_address_4_ext,
  ship_to_address_id,
  ship_to_city_ext,
  ship_to_country_ext,
  ship_to_county_ext,
  ship_to_name_ext,
  ship_to_postal_cd_ext,
  ship_to_province_ext,
  ship_to_site_use_id,
  deliver_to_org_id,
  ship_to_org_id,
  ship_to_state_ext,
  start_date_time,
  subline_assigned_id_ext,
  subline_config_code_ext,
  subline_cust_item_ext,
  subline_cust_item_id,
  subline_model_num_ext,
  subline_quantity,
  subline_uom_code,
  supplier_item_ext,
  transit_time_ext,
  transit_time_qual_ext,
  transport_loc_qual_ext,
  transport_location_ext,
  transport_method_ext,
  uom_code,
  weight_ext,
  weight_qualifier_ext,
  weight_uom_ext,
  last_update_date,
  last_updated_by,
  creation_date,
  created_by,
  attribute_category,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  attribute8,
  attribute9,
  attribute10,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  last_update_login,
  request_id,
  program_application_id,
  program_id,
  line_source,
  program_update_date,
  tp_attribute1, --bug 2056845
  tp_attribute2,
  tp_attribute3,
  tp_attribute4,
  tp_attribute5,
  tp_attribute6,
  tp_attribute7,
  tp_attribute8,
  tp_attribute9,
  tp_attribute10,
  tp_attribute11,
  tp_attribute12,
  tp_attribute13,
  tp_attribute14,
  tp_attribute15,
  tp_attribute_category,
  blanket_number,
  dsp_child_process_index,
  org_id,
  ship_to_customer_id
  )
  VALUES(
  x_ManageDemand_rec.line_id,
  x_ManageDemand_rec.header_id,
  x_ManageDemand_rec.schedule_item_num,
  x_ManageDemand_rec.agreement_id,
  x_ManageDemand_rec.ato_data_type,
  x_ManageDemand_rec.bill_to_address_1_ext,
  x_ManageDemand_rec.bill_to_address_2_ext,
  x_ManageDemand_rec.bill_to_address_3_ext,
  x_ManageDemand_rec.bill_to_address_4_ext,
  x_ManageDemand_rec.bill_to_address_id,
  x_ManageDemand_rec.bill_to_city_ext,
  x_ManageDemand_rec.bill_to_country_ext,
  x_ManageDemand_rec.bill_to_county_ext,
  x_ManageDemand_rec.bill_to_name_ext,
  x_ManageDemand_rec.bill_to_postal_cd_ext,
  x_ManageDemand_rec.bill_to_province_ext,
  x_ManageDemand_rec.bill_to_site_use_id,
  x_ManageDemand_rec.invoice_to_org_id,
  x_ManageDemand_rec.bill_to_state_ext,
  x_ManageDemand_rec.carrier_id_code_ext,
  x_ManageDemand_rec.carrier_qualifier_ext,
  x_ManageDemand_rec.commodity_ext,
  x_ManageDemand_rec.country_of_origin_ext,
  x_ManageDemand_rec.cust_assembly_ext,
  x_ManageDemand_rec.cust_assigned_id_ext,
  x_ManageDemand_rec.cust_bill_to_ext,
  x_ManageDemand_rec.cust_contract_num_ext,
  x_ManageDemand_rec.customer_dock_code,
  x_ManageDemand_rec.cust_intrmd_ship_to_ext,
  x_ManageDemand_rec.cust_item_price_ext,
  x_ManageDemand_rec.cust_item_price_uom_ext,
  x_ManageDemand_rec.customer_item_revision,
  x_ManageDemand_rec.customer_job,
  x_ManageDemand_rec.cust_manufacturer_ext,
  x_ManageDemand_rec.cust_model_number_ext,
  x_ManageDemand_rec.cust_model_serial_number,
  x_ManageDemand_rec.cust_order_num_ext,
  x_ManageDemand_rec.cust_process_num_ext,
  x_ManageDemand_rec.cust_production_line,
  x_ManageDemand_rec.cust_set_num_ext,
  x_ManageDemand_rec.cust_ship_from_org_ext,
  x_ManageDemand_rec.cust_ship_to_ext,
  x_ManageDemand_rec.cust_uom_ext,
  x_ManageDemand_rec.customer_item_ext,
  x_ManageDemand_rec.customer_item_id,
  x_ManageDemand_rec.REQUEST_DATE,
  x_ManageDemand_rec.SCHEDULE_DATE,
  x_ManageDemand_rec.date_type_code,
  x_ManageDemand_rec.date_type_code_ext,
  x_ManageDemand_rec.delivery_lead_time,
  x_ManageDemand_rec.end_date_time,
  x_ManageDemand_rec.equipment_code_ext,
  x_ManageDemand_rec.equipment_number_ext,
  x_ManageDemand_rec.handling_code_ext,
  x_ManageDemand_rec.hazard_code_ext,
  x_ManageDemand_rec.hazard_code_qual_ext,
  x_ManageDemand_rec.hazard_description_ext,
  x_ManageDemand_rec.import_license_date_ext,
  x_ManageDemand_rec.import_license_ext,
  x_ManageDemand_rec.industry_attribute1,
  x_ManageDemand_rec.industry_attribute10,
  x_ManageDemand_rec.industry_attribute11,
  x_ManageDemand_rec.industry_attribute12,
  x_ManageDemand_rec.industry_attribute13,
  x_ManageDemand_rec.industry_attribute14,
  x_ManageDemand_rec.industry_attribute15,
  x_ManageDemand_rec.industry_attribute2,
  x_ManageDemand_rec.industry_attribute3,
  x_ManageDemand_rec.industry_attribute4,
  x_ManageDemand_rec.industry_attribute5,
  x_ManageDemand_rec.industry_attribute6,
  x_ManageDemand_rec.industry_attribute7,
  x_ManageDemand_rec.industry_attribute8,
  x_ManageDemand_rec.industry_attribute9,
  x_ManageDemand_rec.industry_context,
  x_ManageDemand_rec.intrmd_ship_to_id,
  x_ManageDemand_rec.intrmd_st_address_1_ext,
  x_ManageDemand_rec.intrmd_st_address_2_ext,
  x_ManageDemand_rec.intrmd_st_address_3_ext,
  x_ManageDemand_rec.intrmd_st_address_4_ext,
  x_ManageDemand_rec.intrmd_st_city_ext,
  x_ManageDemand_rec.intrmd_st_country_ext,
  x_ManageDemand_rec.intrmd_st_county_ext,
  x_ManageDemand_rec.intrmd_st_name_ext,
  x_ManageDemand_rec.intrmd_st_postal_cd_ext,
  x_ManageDemand_rec.intrmd_st_province_ext,
  x_ManageDemand_rec.intrmd_st_state_ext,
  x_ManageDemand_rec.intmed_ship_to_org_id,
  x_ManageDemand_rec.inventory_item_id,
  x_ManageDemand_rec.inventory_item_segment1,
  x_ManageDemand_rec.inventory_item_segment10,
  x_ManageDemand_rec.inventory_item_segment11,
  x_ManageDemand_rec.inventory_item_segment12,
  x_ManageDemand_rec.inventory_item_segment13,
  x_ManageDemand_rec.inventory_item_segment14,
  x_ManageDemand_rec.inventory_item_segment15,
  x_ManageDemand_rec.inventory_item_segment16,
  x_ManageDemand_rec.inventory_item_segment17,
  x_ManageDemand_rec.inventory_item_segment18,
  x_ManageDemand_rec.inventory_item_segment19,
  x_ManageDemand_rec.inventory_item_segment2,
  x_ManageDemand_rec.inventory_item_segment20,
  x_ManageDemand_rec.inventory_item_segment3,
  x_ManageDemand_rec.inventory_item_segment4,
  x_ManageDemand_rec.inventory_item_segment5,
  x_ManageDemand_rec.inventory_item_segment6,
  x_ManageDemand_rec.inventory_item_segment7,
  x_ManageDemand_rec.inventory_item_segment8,
  x_ManageDemand_rec.inventory_item_segment9,
  x_ManageDemand_rec.item_contact_code_1,
  x_ManageDemand_rec.item_contact_code_2,
  x_ManageDemand_rec.item_contact_value_1,
  x_ManageDemand_rec.item_contact_value_2,
  x_ManageDemand_rec.item_description_ext,
  x_ManageDemand_rec.item_detail_quantity,
  x_ManageDemand_rec.item_detail_ref_code_1,
  x_ManageDemand_rec.item_detail_ref_code_2,
  x_ManageDemand_rec.item_detail_ref_code_3,
  x_ManageDemand_rec.item_detail_ref_value_1,
  x_ManageDemand_rec.item_detail_ref_value_2,
  x_ManageDemand_rec.item_detail_ref_value_3,
  x_ManageDemand_rec.item_detail_subtype,
  x_ManageDemand_rec.item_detail_subtype_ext,
  x_ManageDemand_rec.item_detail_type,
  x_ManageDemand_rec.item_detail_type_ext,
  x_ManageDemand_rec.item_eng_cng_lvl_ext,
  x_ManageDemand_rec.item_measurements_ext,
  x_ManageDemand_rec.item_note_text,
  x_ManageDemand_rec.item_ref_code_1,
  x_ManageDemand_rec.item_ref_code_2,
  x_ManageDemand_rec.item_ref_code_3,
  x_ManageDemand_rec.item_ref_value_1,
  x_ManageDemand_rec.item_ref_value_2,
  x_ManageDemand_rec.item_ref_value_3,
  x_ManageDemand_rec.item_release_status_ext,
  x_ManageDemand_rec.lading_quantity_ext,
  x_ManageDemand_rec.letter_credit_expdt_ext,
  x_ManageDemand_rec.letter_credit_ext,
  x_ManageDemand_rec.line_reference,
  x_ManageDemand_rec.link_to_line_ref,
  x_ManageDemand_rec.order_header_id,
  x_ManageDemand_rec.other_name_code_1,
  x_ManageDemand_rec.other_name_code_2,
  x_ManageDemand_rec.other_name_value_1,
  x_ManageDemand_rec.other_name_value_2,
  x_ManageDemand_rec.pack_size_ext,
  x_ManageDemand_rec.pack_units_per_pack_ext,
  x_ManageDemand_rec.pack_uom_code_ext,
  x_ManageDemand_rec.packaging_code_ext,
  x_ManageDemand_rec.parent_link_line_ref,
  x_ManageDemand_rec.cust_production_seq_num,
  x_ManageDemand_rec.price_list_id,
  x_ManageDemand_rec.primary_quantity,
  x_ManageDemand_rec.primary_uom_code,
  x_ManageDemand_rec.prime_contrctr_part_ext,
  x_ManageDemand_rec.process_status,
  x_ManageDemand_rec.cust_po_release_num,
  x_ManageDemand_rec.cust_po_date,
  x_ManageDemand_rec.cust_po_line_num,
  x_ManageDemand_rec.cust_po_number,
  x_ManageDemand_rec.qty_type_code,
  x_ManageDemand_rec.qty_type_code_ext,
  x_ManageDemand_rec.return_container_ext,
  x_ManageDemand_rec.schedule_line_id,
  x_ManageDemand_rec.routing_desc_ext,
  x_ManageDemand_rec.routing_seq_code_ext,
  x_ManageDemand_rec.ship_del_pattern_ext,
  x_ManageDemand_rec.ship_del_time_code_ext,
  x_ManageDemand_rec.ship_del_rule_name,
  x_ManageDemand_rec.ship_from_address_1_ext,
  x_ManageDemand_rec.ship_from_address_2_ext,
  x_ManageDemand_rec.ship_from_address_3_ext,
  x_ManageDemand_rec.ship_from_address_4_ext,
  x_ManageDemand_rec.ship_from_city_ext,
  x_ManageDemand_rec.ship_from_country_ext,
  x_ManageDemand_rec.ship_from_county_ext,
  x_ManageDemand_rec.ship_from_name_ext,
  x_ManageDemand_rec.ship_from_org_id,
  x_ManageDemand_rec.ship_from_postal_cd_ext,
  x_ManageDemand_rec.ship_from_province_ext,
  x_ManageDemand_rec.ship_from_state_ext,
  x_ManageDemand_rec.ship_label_info_line_1,
  x_ManageDemand_rec.ship_label_info_line_10,
  x_ManageDemand_rec.ship_label_info_line_2,
  x_ManageDemand_rec.ship_label_info_line_3,
  x_ManageDemand_rec.ship_label_info_line_4,
  x_ManageDemand_rec.ship_label_info_line_5,
  x_ManageDemand_rec.ship_label_info_line_6,
  x_ManageDemand_rec.ship_label_info_line_7,
  x_ManageDemand_rec.ship_label_info_line_8,
  x_ManageDemand_rec.ship_label_info_line_9,
  x_ManageDemand_rec.ship_to_address_1_ext,
  x_ManageDemand_rec.ship_to_address_2_ext,
  x_ManageDemand_rec.ship_to_address_3_ext,
  x_ManageDemand_rec.ship_to_address_4_ext,
  x_ManageDemand_rec.ship_to_address_id,
  x_ManageDemand_rec.ship_to_city_ext,
  x_ManageDemand_rec.ship_to_country_ext,
  x_ManageDemand_rec.ship_to_county_ext,
  x_ManageDemand_rec.ship_to_name_ext,
  x_ManageDemand_rec.ship_to_postal_cd_ext,
  x_ManageDemand_rec.ship_to_province_ext,
  x_ManageDemand_rec.ship_to_site_use_id,
  x_ManageDemand_rec.deliver_to_org_id,
  x_ManageDemand_rec.ship_to_org_id,
  x_ManageDemand_rec.ship_to_state_ext,
  x_ManageDemand_rec.start_date_time,
  x_ManageDemand_rec.subline_assigned_id_ext,
  x_ManageDemand_rec.subline_config_code_ext,
  x_ManageDemand_rec.subline_cust_item_ext,
  x_ManageDemand_rec.subline_cust_item_id,
  x_ManageDemand_rec.subline_model_num_ext,
  x_ManageDemand_rec.subline_quantity,
  x_ManageDemand_rec.subline_uom_code,
  x_ManageDemand_rec.supplier_item_ext,
  x_ManageDemand_rec.transit_time_ext,
  x_ManageDemand_rec.transit_time_qual_ext,
  x_ManageDemand_rec.transport_loc_qual_ext,
  x_ManageDemand_rec.transport_location_ext,
  x_ManageDemand_rec.transport_method_ext,
  x_ManageDemand_rec.uom_code,
  x_ManageDemand_rec.weight_ext,
  x_ManageDemand_rec.weight_qualifier_ext,
  x_ManageDemand_rec.weight_uom_ext,
  x_ManageDemand_rec.last_update_date,
  x_ManageDemand_rec.last_updated_by,
  sysdate, /* creation_date */
  x_ManageDemand_rec.created_by, /* created_by */
  x_ManageDemand_rec.attribute_category,
  x_ManageDemand_rec.attribute1,
  x_ManageDemand_rec.attribute2,
  x_ManageDemand_rec.attribute3,
  x_ManageDemand_rec.attribute4,
  x_ManageDemand_rec.attribute5,
  x_ManageDemand_rec.attribute6,
  x_ManageDemand_rec.attribute7,
  x_ManageDemand_rec.attribute8,
  x_ManageDemand_rec.attribute9,
  x_ManageDemand_rec.attribute10,
  x_ManageDemand_rec.attribute11,
  x_ManageDemand_rec.attribute12,
  x_ManageDemand_rec.attribute13,
  x_ManageDemand_rec.attribute14,
  x_ManageDemand_rec.attribute15,
  x_ManageDemand_rec.last_update_login,
  x_ManageDemand_rec.request_id,
  x_ManageDemand_rec.program_application_id,
  x_ManageDemand_rec.program_id,
  x_ManageDemand_rec.line_source,
  sysdate, /* program_update_date */
  x_ManageDemand_rec. tp_attribute1, --bug 2056845
  x_ManageDemand_rec.tp_attribute2,
  x_ManageDemand_rec.tp_attribute3,
  x_ManageDemand_rec.tp_attribute4,
  x_ManageDemand_rec.tp_attribute5,
  x_ManageDemand_rec.tp_attribute6,
  x_ManageDemand_rec.tp_attribute7,
  x_ManageDemand_rec.tp_attribute8,
  x_ManageDemand_rec.tp_attribute9,
  x_ManageDemand_rec.tp_attribute10,
  x_ManageDemand_rec.tp_attribute11,
  x_ManageDemand_rec.tp_attribute12,
  x_ManageDemand_rec.tp_attribute13,
  x_ManageDemand_rec.tp_attribute14,
  x_ManageDemand_rec.tp_attribute15,
  x_ManageDemand_rec.tp_attribute_category,
  x_ManageDemand_rec.blanket_number,
  x_ManageDemand_rec.dsp_child_process_index,
  x_ManageDemand_rec.org_id,
  x_ManageDemand_rec.ship_to_customer_id
  );
  --
  -- JAUTOMO: update schedule lines with the interface line id
  --          created when sourcing rule is applied
  --
  UPDATE rlm_schedule_lines_all
  SET    interface_line_id = x_ManageDemand_rec.line_id
  WHERE  line_id = x_ManageDemand_rec.schedule_line_id
  AND    x_ManageDemand_rec.line_source = 'SOURCED';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'interface_line_id', x_ManageDemand_rec.line_id);
     rlm_core_sv.dlog(C_DEBUG,'schedule_line_id', x_ManageDemand_rec.schedule_line_id);
     rlm_core_sv.dlog(C_DEBUG,'# of schedule lines updated', SQL%ROWCOUNT);
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_NullOrgId THEN
   --
   rlm_message_sv.app_error(
         x_ExceptionLevel => rlm_message_sv.k_error_level,
         x_MessageName => 'RLM_OU_CONTEXT_NOT_SET',
         x_InterfaceHeaderId => x_ManageDemand_rec.header_id,
         x_InterfaceLineId => x_ManageDemand_rec.line_id);
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Null Org ID detected during Insert');
    rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
   RAISE;
   --
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.InsertReq',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END InsertReq;


/*===========================================================================

PROCEDURE NAME:    UpdateReq

===========================================================================*/

PROCEDURE UpdateReq(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE)
IS

  v_Progress	VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'UpdateReq');
     rlm_core_sv.dlog(C_DEBUG,'Changed lines to be updated to table');
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.primary_quantity',
                            x_ManageDemand_rec.primary_quantity);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.ship_from_org_id',
                            x_ManageDemand_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.item_detail_type',
                            x_ManageDemand_rec.item_detail_type);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.item_detail_subtype',
                            x_ManageDemand_rec.item_detail_subtype);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.line_source',
                            x_ManageDemand_rec.line_source);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.qty_type_code',
                            x_ManageDemand_rec.qty_type_code);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.order_header_id',
                            x_ManageDemand_rec.order_header_id);
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.blanket_number',
                            x_ManageDemand_rec.blanket_number);
  END IF;
  --
  UPDATE	rlm_interface_lines_all
  SET		primary_quantity    = x_ManageDemand_rec.primary_quantity,
		ship_from_org_id    = x_ManageDemand_rec.ship_from_org_id,
		item_detail_type    = x_ManageDemand_rec.item_detail_type,
		item_detail_subtype = x_ManageDemand_rec.item_detail_subtype,
		line_source         = x_ManageDemand_rec.line_source,
		qty_type_code       = x_ManageDemand_rec.qty_type_code,
		request_date        = x_ManageDemand_rec.request_date    ,
		schedule_date       = x_ManageDemand_rec.schedule_date   ,
		process_status      = x_ManageDemand_rec.process_status
  WHERE		line_id = x_ManageDemand_rec.line_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.UpdateReq',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END UpdateReq;


/*===========================================================================

PROCEDURE NAME:    UpdateSchedule

===========================================================================*/

PROCEDURE UpdateSchedule(x_ManageDemand_rec IN rlm_interface_lines%ROWTYPE,
                         x_AggregateDemand_rec IN rlm_interface_lines%ROWTYPE)
IS

  v_Progress          	VARCHAR2(3)  := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'UpdateSchedule');
     rlm_core_sv.dlog(C_DEBUG,'x_ManageDemand_rec.schedule_line_id',
			x_ManageDemand_rec.schedule_line_id);
  END IF;
  --
  IF x_ManageDemand_rec.program_id <> k_INSERT THEN
    --
    UPDATE	rlm_schedule_lines_all
    SET		interface_line_id = x_AggregateDemand_rec.line_id
    WHERE	line_id = x_ManageDemand_rec.schedule_line_id;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'# of schedule lines updated',SQL%ROWCOUNT);
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.UpdateSchedule', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END UpdateSchedule;


/*===========================================================================

PROCEDURE NAME:    MatchDemand

===========================================================================*/

PROCEDURE MatchDemand(x_Group_rec IN rlm_dp_sv.t_Group_rec,
                      x_Index IN NUMBER,
                      x_AggregateDemand_tab IN OUT NOCOPY t_MD_tab,
                      x_Delete_tab IN OUT NOCOPY t_Number_tab,
                      x_ExcpTab    IN OUT NOCOPY t_Match_Tab)
IS
  --
  i		NUMBER;
  j		NUMBER;
  q             NUMBER :=1;
  k             NUMBER;
  x             NUMBER;
  b_Match  	BOOLEAN := FALSE;
  v_Progress	VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'MatchDemand');
     rlm_core_sv.dlog(C_DEBUG, 'x_Index', x_Index);
     rlm_core_sv.dlog(C_DEBUG, 'Line_id to be matched',
                             g_ManageDemand_tab(x_Index).line_id);
  END IF;
  --
  /* note: 866 attributes still need to be determined */
  --
  FOR j IN x_index+1..g_ManageDemand_tab.COUNT LOOP
    --
    -- Initialize the record
    --
    x_ExcpTab(x_ExcpTab.COUNT + 1).industry_attribute15 := 'N';
    x := x_ExcpTab.COUNT;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'x_AggregateDemand_tab.COUNT',
                                      x_AggregateDemand_tab.COUNT);
    END IF;
    --
    b_match := TRUE;
    --
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).request_date, k_DNULL) <>
         NVL(g_ManageDemand_tab(j).request_date, k_DNULL) THEN
        IF  x_Group_rec.match_within_rec.request_date = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).request_date := 'Y';
        END IF;
      END IF;
    END IF;

/*
    IF NVL(g_ManageDemand_tab(x_Index).bill_to_site_use_id,k_NULL) <>
       NVL(g_ManageDemand_tab(j).bill_to_site_use_id,k_NULL) THEN
      b_Match := FALSE;
    END IF;

*/
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).intrmd_ship_to_id,k_NULL) <>
         NVL(g_ManageDemand_tab(j).intrmd_ship_to_id,k_NULL) THEN
        b_Match := FALSE;
      END IF;
    END IF;

/*
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).inventory_item_id,k_NULL) <>
         NVL(x_Demand_tab(j).inventory_item_id,k_NULL) THEN
        b_Match := FALSE;
      END IF;
    END IF;

*/
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).item_detail_type,'k_NULL') <>
         NVL(g_ManageDemand_tab(j).item_detail_type,'k_NULL') THEN
        b_Match := FALSE;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).item_detail_subtype,'k_NULL') <>
         NVL(g_ManageDemand_tab(j).item_detail_subtype,'k_NULL') THEN
        b_Match := FALSE;
      END IF;
    END IF;

--Bugfix 6640105 Start  --Enforcing Request Date for MRP Lines
    IF b_Match THEN
      IF x_Group_rec.setup_terms_rec.ship_delivery_rule_name IS NOT NULL AND g_ManageDemand_tab(x_Index).item_detail_type = k_MRP_FORECAST --Bugfix 8597878
      AND g_ManageDemand_tab(j).item_detail_type = k_MRP_FORECAST THEN --Bugfix 8597878
          IF NVL(g_ManageDemand_tab(x_Index).request_date, k_DNULL) <>
             NVL(g_ManageDemand_tab(j).request_date, k_DNULL) THEN
               b_Match := FALSE;
              IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG, 'Request Date as match attribute is enforced so the MRP lines splitted by SDP rule are not aggregated');
              END IF;
          ELSE
             x_ExcpTab(x).request_date := 'Y';
          END IF;
      END IF;
    END IF;
--Bugfix 6640105 End

/*
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).order_header_id,k_NULL) <>
         NVL(g_ManageDemand_tab(j).order_header_id,k_NULL) THEN
        b_Match := FALSE;
      END IF;
    END IF;
*/

/*
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).customer_item_id,k_NULL) <>
         NVL(g_ManageDemand_tab(j).customer_item_id,k_NULL) THEN
        b_Match := FALSE;
      END IF;
    END IF;

*/

/*

    Took out the match_across comparison as per code review

*/


    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).cust_po_number, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).cust_po_number, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.cust_po_number = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).cust_po_number := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).customer_item_revision, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).customer_item_revision, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.customer_item_revision = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).customer_item_revision := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).customer_dock_code, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).customer_dock_code, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.customer_dock_code = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).customer_dock_code := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).customer_job, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).customer_job, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.customer_job = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).customer_job := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).cust_production_line, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).cust_production_line, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.cust_production_line = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).cust_production_line := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).cust_model_serial_number, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).cust_model_serial_number, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.cust_model_serial_number = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).cust_model_serial_number := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).cust_production_seq_num, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).cust_production_seq_num, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.cust_production_seq_num = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).cust_production_seq_num := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute1, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute1, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute1 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute1 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute2, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute2, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute2 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute2 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute4, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute4, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute4 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute4 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute5, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute5, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute5 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute5 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute6, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute6, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute6 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute6 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute10, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute10, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute10 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute10 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute11, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute11, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute11 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute11 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute12, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute12, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute12 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute12 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute13, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute13, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute13 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute13 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute14, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute14, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.industry_attribute14 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).industry_attribute14 := 'Y';
        END IF;
      END IF;
    END IF;

/*
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).industry_attribute15, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).industry_attribute15, k_VNULL) THEN
          --match_within_rec.industry_attribute15 is always 'Y'
          b_Match := FALSE;
      END IF;
    END IF;

*/
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute1, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute1, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute1 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute1 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute2, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute2, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute2 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute2 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute3, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute3, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute3 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute3 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute4, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute4, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute4 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute4 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute5, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute5, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute5 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute5 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute6, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute6, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute6 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute6 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute7, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute7, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute7 = 'Y' THEN
          b_Match := FALSE;
        ELSE
           x_ExcpTab(x).attribute7 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute8, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute8, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute8 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute8 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute9, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute9, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute9 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute9 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute10, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute10, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute10 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute10 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute11, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute11, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute11 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute11 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute12, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute12, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute12 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute12 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute13, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute13, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute13 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute13 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute14, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute14, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute14 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute14 := 'Y';
        END IF;
      END IF;
    END IF;
    IF b_Match THEN
      IF NVL(g_ManageDemand_tab(x_Index).attribute15, k_VNULL) <>
         NVL(g_ManageDemand_tab(j).attribute15, k_VNULL) THEN
        IF x_Group_rec.match_within_rec.attribute15 = 'Y' THEN
          b_Match := FALSE;
        ELSE
          x_ExcpTab(x).attribute15 := 'Y';
        END IF;
      END IF;
    END IF;
    --

    IF q = 1 THEN
      k := x_AggregateDemand_tab.COUNT+1;
      x_AggregateDemand_tab(k) := g_ManageDemand_tab(x_Index);
      x_AggregateDemand_tab(k).program_application_id := x_Index;
      x_AggregateDemand_tab(k).program_id := NULL;
    END IF;

    IF b_Match THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'match found');
      END IF;
      --
      IF x_AggregateDemand_tab(k).program_id IS NULL THEN
        --
        SetOperation(x_AggregateDemand_tab(k), k_INSERT);
--        bug1230450
--        x_AggregateDemand_tab(j).schedule_line_id := NULL;
        x_Delete_tab(x_Delete_tab.COUNT) :=
                           x_AggregateDemand_tab(k).program_application_id;
        UpdateSchedule(
            g_ManageDemand_tab(x_AggregateDemand_tab(k).program_application_id),
            x_AggregateDemand_tab(k));
        --
      END IF;
      --
      x_AggregateDemand_tab(k).primary_quantity :=
                     x_AggregateDemand_tab(k).primary_quantity +
                     g_ManageDemand_tab(j).primary_quantity;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Line to be deleted',
                       g_ManageDemand_tab(j).line_id);
      END IF;
      --
      SetOperation(g_ManageDemand_tab(j), k_DELETE);
      UpdateSchedule(g_ManageDemand_tab(j), x_AggregateDemand_tab(k));
      --
      --EXIT;
      --
    ELSE
      x_ExcpTab.DELETE(x);
    END IF;
    --
    q := q + 1;

  END LOOP;

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_manage_demand_sv.MatchDemand', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END MatchDemand;


/*===========================================================================

PROCEDURE NAME:    AggregateDemand

===========================================================================*/

PROCEDURE AggregateDemand(x_Group_rec IN  rlm_dp_sv.t_Group_rec)
IS

  i			NUMBER;
  v_Delete_tab 		t_Number_tab;
  v_AggregateDemand_tab t_MD_tab;
  v_Progress          	VARCHAR2(3)  := '010';
  v_ExcpTab             t_Match_tab;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'AggregateDemand');
  END IF;
  --
  FOR i IN 1..g_ManageDemand_tab.COUNT LOOP
    --
    IF g_ManageDemand_tab(i).program_id <> k_DELETE OR
       g_ManageDemand_tab(i).program_id IS NULL
    THEN
      MatchDemand(x_Group_rec,i, v_AggregateDemand_tab, v_Delete_tab,v_ExcpTab);
    END IF;
    --
  END LOOP;
  --
  IF v_ExcpTab.COUNT > 0 THEN
    --
    ReportExc(v_ExcpTab);
    --
    v_ExcpTab.DELETE;
    --
  END IF;
  --
  FOR i IN 0..v_Delete_tab.COUNT-1 LOOP
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Line to be deleted',
                     g_ManageDemand_tab(v_Delete_tab(i)).line_id);
    END IF;
    --
    SetOperation(g_ManageDemand_tab(v_Delete_tab(i)), k_DELETE);
    --
  END LOOP;
  --
  FOR i IN 1..v_AggregateDemand_tab.COUNT LOOP
    --
    IF v_AggregateDemand_tab(i).program_id IS NOT NULL THEN
      --
      g_ManageDemand_tab(g_ManageDemand_tab.COUNT + 1) :=
                                     v_AggregateDemand_tab(i);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'aggregated line qty ',
              g_ManageDemand_tab(g_ManageDemand_tab.COUNT).primary_quantity);
         rlm_core_sv.dlog(C_DEBUG,'Ship to org',
              g_ManageDemand_tab(g_ManageDemand_tab.COUNT).ship_to_org_id);
         rlm_core_sv.dlog(C_DEBUG,'Intermediate ship to org ',
             g_ManageDemand_tab(g_ManageDemand_tab.COUNT).intmed_ship_to_org_id);
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.AggregateDemand', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END AggregateDemand;


/*===========================================================================

PROCEDURE NAME:    SortDemand

===========================================================================*/

PROCEDURE SortDemand
IS

  i		NUMBER;
  v_Progress	VARCHAR2(3) := '010';

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'SortDemand');
  END IF;

  i := g_ManageDemand_tab.FIRST;
  LOOP
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab('||i||').line_id',
      			g_ManageDemand_tab(i).line_id);
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab('||i||').request_date',
      			g_ManageDemand_tab(i).request_date);
       rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab('||i||').operation',
			g_ManageDemand_tab(i).program_id);
    END IF;
    --
    EXIT WHEN i = g_ManageDemand_tab.LAST ;
    --
     i := g_ManageDemand_tab.NEXT(i);
     --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Call QuickSort');
     rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab.COUNT', g_ManageDemand_tab.COUNT);
  END IF;
  --
  QuickSort(1, g_ManageDemand_tab.COUNT);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Return QuickSort');
  END IF;
  --
  --InsertionSort(1,g_ManageDemand_tab.COUNT);
  i := g_ManageDemand_tab.FIRST;
  --
  LOOP
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab('||i||').line_id',
      			g_ManageDemand_tab(i).line_id);
       rlm_core_sv.dlog(C_DEBUG,'g_ManageDemand_tab('||i||').request_date',
      			g_ManageDemand_tab(i).request_date);
       rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab('||i||').primary_quantity',
			g_ManageDemand_tab(i).primary_quantity);
    END IF;
    --
    EXIT WHEN i = g_ManageDemand_tab.LAST ;
    --
     i := g_ManageDemand_tab.NEXT(i);
     --
  END LOOP;

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.SortDemand', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END SortDemand;


/*===========================================================================

PROCEDURE NAME:    QuickSort

===========================================================================*/

PROCEDURE QuickSort(first IN NUMBER,
                    last IN NUMBER)
IS

  Low           NUMBER;
  High          NUMBER;
  Pivot         DATE;
  v_Progress    VARCHAR2(3) := '010';

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'QuickSort');
  END IF;

  low := First;
  high := Last;

  /* Select an element from the middle. */
  pivot :=  g_ManageDemand_tab(TRUNC((First + Last) / 2)).request_date;
  LOOP
    /* Find lowest element that is >= Pivot */
    WHILE g_ManageDemand_tab(Low).request_date < Pivot LOOP
      Low := Low + 1;
    END LOOP;
    /* Find highest element that is <= Pivot */
    WHILE g_ManageDemand_tab(High).request_date > Pivot LOOP
      High := High - 1;
    END LOOP;
    /*  swap the elements */
    IF Low <= High THEN
      Swap(High, Low);
      Low := Low + 1;
      High := High - 1;
    End IF;
    EXIT WHEN Low > High;
  END LOOP ;
  IF (First < High) THEN
      Quicksort(First, High);
  END IF;
  IF (Low < Last) THEN
     Quicksort(Low, Last);
  END IF;

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.QuickSort', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
END QuickSort;

/*===========================================================================

PROCEDURE NAME:    Swap

===========================================================================*/

PROCEDURE Swap( i IN NUMBER,
               j IN NUMBER)
IS

  T		rlm_interface_lines%ROWTYPE;
  v_Progress	VARCHAR2(3) := '010';

BEGIN

--  rlm_core_sv.dpush(C_SDEBUG,'Swap');

  T := g_ManageDemand_tab(i);
  g_ManageDemand_tab(i) := g_ManageDemand_tab(j);
  g_ManageDemand_tab(j) := T;

--  rlm_core_sv.dpop(C_SDEBUG);

EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.Swap', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END Swap;


/*===========================================================================

PROCEDURE NAME:    InsertionSort

===========================================================================*/

PROCEDURE InsertionSort(lo IN NUMBER,
                        hi IN NUMBER)
IS

  i		NUMBER;
  j		NUMBER;
  v		rlm_interface_lines%ROWTYPE;
  v_Progress	VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'InsertionSort');
  END IF;
  --
  FOR i IN lo+1..hi LOOP
    v := g_ManageDemand_tab(i);
    j := i;
    WHILE ((j>lo) AND (g_ManageDemand_tab(j-1).request_date > v.request_date)) LOOP
      g_ManageDemand_tab(j) := g_ManageDemand_tab(j-1);
      j := j - 1;
    END LOOP;
    g_ManageDemand_tab(j) := v;
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.InsertionSort', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END InsertionSort;


/*===========================================================================

PROCEDURE NAME:    RoundStandardPack

===========================================================================*/

PROCEDURE RoundStandardPack(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS

  v_RoundPack		VARCHAR(1);
  v_StdPackQty		NUMBER;
  v_QtyToAdd		NUMBER;
  v_ModQty		NUMBER;
  i			NUMBER := 1;
  j			NUMBER := 1;
  v_Sum			NUMBER := 0;
  v_qty_before_round      NUMBER := 0 ;
  v_qty_after_round      NUMBER := 0 ;
  v_Progress		VARCHAR2(3)  := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'RoundStandardPack');
     rlm_core_sv.dlog(C_DEBUG, 'round_to_std_pack_flag',
                         x_Group_rec.setup_terms_rec.round_to_std_pack_flag);
     rlm_core_sv.dlog(C_DEBUG, 'standard pack qty ',
                              x_Group_rec.setup_terms_rec.STD_PACK_QTY);
  END IF;
  --
  IF x_Group_rec.setup_terms_rec.round_to_std_pack_flag = 'Y' THEN
    --
    -- Perf fix
    SortDemand;

    /* TO give the message for over shipment we need the total primary qty
     before we do the rounding and then we need to get the total after
     rounding give an warn if it is greater than the first */
    --
    FOR i IN 1..g_ManageDemand_Tab.COUNT LOOP
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'program_id ',g_ManageDemand_tab(i).program_id);
         rlm_core_sv.dlog(C_DEBUG, 'index ',i);
      END IF;
      --
      IF g_ManageDemand_tab(i).program_id <> k_DELETE THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'index ',i);
            rlm_core_sv.dlog(C_DEBUG,'primary_quantity',
                                   g_ManageDemand_Tab(i).primary_quantity);
         END IF;
         --
         v_qty_before_round := v_qty_before_round +
                            g_ManageDemand_Tab(i).primary_quantity;
         --
      END IF;
      --
    END LOOP;
    --
    v_StdPackQty := x_Group_rec.setup_terms_rec.std_pack_qty;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Total primary qty before rounding',
                                v_qty_before_round);
       rlm_core_sv.dlog(C_DEBUG, 'Table COUNT ',g_ManageDemand_tab.COUNT);
    END IF;
    --
    WHILE (i <= g_ManageDemand_tab.COUNT) LOOP
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'i ',i);
          rlm_core_sv.dlog(C_DEBUG, 'program_id',g_ManageDemand_tab(i).program_id);
       END IF;
       --
       -- Do not consider the lines which have been marked for deletion
       -- either by aggregration or other ways for Round to std pack calculation
       --
       IF(g_ManageDemand_tab(i).program_id <> k_DELETE) THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab(i).primary_quantity',
                     g_ManageDemand_tab(i).primary_quantity);
          END IF;
          --
          v_ModQty := MOD(g_ManageDemand_tab(i).primary_quantity, v_StdPackQty);
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'ModQty',v_ModQty);
          END IF;
          --
          IF v_ModQty <> 0 THEN
             --
             v_QtyToAdd := v_StdPackQty - v_ModQty;
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG, 'v_QtyToAdd',v_QtyToAdd);
             END IF;
             --
             g_ManageDemand_tab(i).primary_quantity :=
                                  g_ManageDemand_tab(i).primary_quantity
                                  + v_QtyToAdd;
             --
             SetOperation(g_ManageDemand_tab(i), k_UPDATE);
             --
             v_Sum := 0;
             j := i + 1;
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG, 'v_Sum ',v_Sum);
                rlm_core_sv.dlog(C_DEBUG, 'g_ManageDemand_tab(i).primary_quantity',
                        g_ManageDemand_tab(i).primary_quantity);
             END IF;
             --
             WHILE (v_Sum < v_QtyToAdd) AND (j <= g_ManageDemand_tab.COUNT) LOOP
                 --
                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG, 'j ',j);
                    rlm_core_sv.dlog(C_DEBUG, 'program_id',
                                 g_ManageDemand_tab(j).program_id );
                 END IF;
                 --
                 IF (g_ManageDemand_tab(j).program_id <> k_DELETE) THEN
                    --
                    -- Do not consider the lines which have been marked
                    -- for deletion
                    --
  		    IF (l_debug <> -1) THEN
                       rlm_core_sv.dlog(C_DEBUG, 'j.primary_quantity',
                           g_ManageDemand_tab(j).primary_quantity);
                       rlm_core_sv.dlog(C_DEBUG, 'v_Sum ',v_Sum);
                       rlm_core_sv.dlog(C_DEBUG, 'v_QtyToAdd ',v_QtyToAdd);
                    END IF;
                    --
                    IF g_ManageDemand_tab(j).primary_quantity >
                          (v_QtyToAdd - v_Sum) THEN
                       --
                       g_ManageDemand_tab(j).primary_quantity :=
                                   g_ManageDemand_tab(j).primary_quantity
                                   - (v_QtyToAdd - v_Sum);
                       v_Sum := v_QtyToAdd;
		       --
  		       IF (l_debug <> -1) THEN
                          rlm_core_sv.dlog(C_DEBUG, 'j.primary_quantity',
                                g_ManageDemand_tab(j).primary_quantity);
                          rlm_core_sv.dlog(C_DEBUG, 'v_Sum ',v_Sum);
                       END IF;
		       --
                       SetOperation(g_ManageDemand_tab(j), k_UPDATE);
                       --
                    ELSE
                       --
                       v_Sum := v_Sum + g_ManageDemand_tab(j).primary_quantity;
		       --
  		       IF (l_debug <> -1) THEN
                          rlm_core_sv.dlog(C_DEBUG, 'v_Sum ',v_Sum);
                          rlm_core_sv.dlog(C_DEBUG,'j.primary_quantity',
                                g_ManageDemand_tab(j).primary_quantity);
                          rlm_core_sv.dlog(C_DEBUG,'Setting the primary qty to O');
                       END IF;
		       --
                       g_ManageDemand_tab(j).primary_quantity := 0;
                       SetOperation(g_ManageDemand_tab(j), k_UPDATE);
                       j := j + 1;
                       --
                    END IF;
                    --
                 ELSE
                    --
                    j := j + 1;
                    --
                 END IF;
                 --
             END LOOP;
             --
             i := j;
             --
          ELSE
             --
             i := i + 1;
             --
          END IF;
          --
      ELSE
         --
         i := i + 1;
         --
      END IF;
      --
    END LOOP;
    --
    -- after rounding
    --
    FOR i IN 1..g_ManageDemand_Tab.COUNT LOOP
      --
      IF g_ManageDemand_tab(i).program_id <> k_DELETE THEN
         --
         v_qty_after_round := v_qty_after_round +
                           g_ManageDemand_Tab(i).primary_quantity;
         --
      END IF;
      --
    END LOOP;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Total primary qty after rounding',
                                v_qty_after_round);
    END IF;
    --
    IF v_qty_after_round > v_qty_before_round THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'WARNING overshipment has occured by qty = '
                              ,v_qty_after_round - v_qty_before_round);
      END IF;
      --
         rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_OVERSHIP_ITEM',
              x_InterfaceHeaderId => x_sched_rec.header_id,
              x_InterfaceLineId => g_ManageDemand_tab(g_ManageDemand_tab.COUNT).line_id,
              x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
              x_ScheduleLineId => g_ManageDemand_tab(g_ManageDemand_tab.COUNT).schedule_line_id,
              x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
              x_OrderLineId => NULL,
              --x_ErrorText => 'Overshipment for Item',
              x_token1 => 'CUSTITEM',
              x_value1 => rlm_core_sv.get_item_number(g_ManageDemand_tab(g_ManageDemand_tab.COUNT).customer_item_id),
              x_token2 => 'OVRQTY',
              x_value2 => v_qty_after_round - v_qty_before_round);
         --
      --
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_manage_demand_sv.RoundStandardPack',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END RoundStandardPack;

/*===========================================================================

  PROCEDURE InitializeMdGroup

===========================================================================*/
PROCEDURE InitializeMdGroup(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_ref IN OUT NOCOPY rlm_manage_demand_sv.t_Cursor_ref,
                          x_Group_rec IN  rlm_dp_sv.t_Group_rec)
IS

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'InitializeMdGroup');
  END IF;

  OPEN x_Group_ref FOR
    SELECT   rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.order_header_id,
             ril.blanket_number,
             -- CR changes
             ril.ship_to_customer_id
	     -- Perf change
             -- ril.cust_production_seq_num
    FROM     rlm_interface_headers   rih,
             rlm_interface_lines_all ril
    WHERE    rih.header_id = x_Sched_rec.header_id
    AND      rih.org_id = ril.org_id
    AND      ril.header_id = rih.header_id
    AND      ril.industry_attribute15 = x_Group_rec.ship_from_org_id
    AND      ril.process_status = rlm_core_sv.k_PS_AVAILABLE
    AND      ril.customer_item_id = x_Group_rec.customer_item_id
    --AND      ril.inventory_item_id = x_Group_rec.inventory_item_id
    AND      ril.ship_to_address_id = x_Group_rec.ship_to_address_id
    GROUP BY rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.order_header_id,
	     ril.blanket_number,
             ril.ship_to_customer_id
	     -- Perf change
             -- ril.cust_production_seq_num
    ORDER BY ril.ship_to_address_id, ril.customer_item_id;
             /* we do not need to have the schedule item number as it prevents
                aggregation when there is a change in 2000 level in
                edi a new schedule item num is generated in this case there
                will be 2 lines which will be inserted but having the same
                match attributes */

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END InitializeMdGroup;

/*===========================================================================

  FUNCTION FetchGroup

===========================================================================*/
FUNCTION FetchGroup(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                    x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN
IS
BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'FetchGroup');
  END IF;

  FETCH x_Group_ref INTO
    x_Group_rec.customer_id,
    x_Group_rec.ship_from_org_id,
    x_Group_rec.ship_to_address_id,
    x_Group_rec.ship_to_org_id,
    x_Group_rec.customer_item_id,
    x_Group_rec.inventory_item_id,
    x_Group_rec.industry_attribute15,
    x_Group_rec.order_header_id,
    x_Group_rec.blanket_number,
    x_Group_rec.ship_to_customer_id;
    -- Perf change
    -- x_Group_rec.cust_production_seq_num;
  IF x_Group_ref%NOTFOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'false');
    END IF;
    --
    RETURN(FALSE);
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'true');
    END IF;
    --
    RETURN(TRUE);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END FetchGroup;

/*===========================================================================

  PROCEDURE CallSetups

===========================================================================*/
PROCEDURE CallSetups(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
IS

  v_SetupTerms_rec    rlm_setup_terms_sv.setup_terms_rec_typ;
  v_TermsLevel        VARCHAR2(30) := NULL;
  v_ReturnStatus      BOOLEAN;
  v_ReturnMsg         VARCHAR2(2000);
  e_SetupAPIFailed    EXCEPTION;
  v_InterfaceLineID   NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CallSetups');
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_from_org_id',
                              x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.customer_id',
                              x_Group_rec.customer_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_to_address_id',
                              x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.customer_item_id',
                              x_Group_rec.customer_item_id);
  END IF;
  --
-- NOTE: call rla setups to populate setup info in the group rec:
-- schedule precedence,match within/across strings
-- firm disposition code and offset days, order header id

  RLM_TPA_SV.get_setup_terms(x_Group_rec.ship_from_org_id,
                                     x_Group_rec.customer_id,
                                     x_Group_rec.ship_to_address_id,
                                     x_Group_rec.customer_item_id,
                                     v_TermsLevel,
                                     v_SetupTerms_rec,
                                     v_ReturnMsg,
                                     v_ReturnStatus);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'v_TermsLevel', v_TermsLevel);
     rlm_core_sv.dlog(C_DEBUG, 'v_ReturnStatus', v_ReturnStatus);
     rlm_core_sv.dlog(C_DEBUG, 'v_ReturnMsg', v_ReturnMsg);
     rlm_core_sv.dlog(C_DEBUG,'v_SetupTerms_rec.schedule_hierarchy_code',
                   v_SetupTerms_rec.schedule_hierarchy_code);
     rlm_core_sv.dlog(C_DEBUG,'v_SetupTerms_rec.header_id',
                   v_SetupTerms_rec.header_id);
     rlm_core_sv.dlog(C_DEBUG,'v_SetupTerms_rec.blanket_number',
                   v_SetupTerms_rec.blanket_number);
  END IF;
  --
  IF v_ReturnStatus THEN
    --
    IF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,1,3) = 'PLN' THEN
       x_Group_rec.schedule_type_one := k_PLANNING;
    ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,1,3) = 'SHP' THEN
       x_Group_rec.schedule_type_one := k_SHIPPING;
    ELSE
       x_Group_rec.schedule_type_one := k_SEQUENCED;
    END IF;
    --
    IF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,5,3) = 'PLN' THEN
       x_Group_rec.schedule_type_two := k_PLANNING;
    ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,5,3) = 'SHP' THEN
       x_Group_rec.schedule_type_two := k_SHIPPING;
    ELSE
       x_Group_rec.schedule_type_two := k_SEQUENCED;
    END IF;
    --
    IF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,9,3) = 'PLN' THEN
        x_Group_rec.schedule_type_three := k_PLANNING;
    ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,9,3) = 'SHP' THEN
        x_Group_rec.schedule_type_three := k_SHIPPING;
    ELSE
        x_Group_rec.schedule_type_three := k_SEQUENCED;
    END IF;

    x_Group_rec.setup_terms_rec := v_SetupTerms_rec;
    --
    x_Group_rec.match_within := v_SetupTerms_rec.match_within_key;
    --
    x_Group_rec.match_across := v_SetupTerms_rec.match_across_key;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.match_within',
                     x_Group_rec.match_within);
    END IF;
    --
    rlm_core_sv.populate_match_keys(x_Group_rec.match_within_rec,
                                    x_Group_rec.match_within);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.match_across',
                      x_Group_rec.match_across);
    END IF;
    --
    rlm_core_sv.populate_match_keys(x_Group_rec.match_across_rec,
                                    x_Group_rec.match_across);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.pln_frozen_day_from',
                     x_Group_rec.setup_terms_rec.pln_frozen_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.pln_frozen_day_to',
                     x_Group_rec.setup_terms_rec.pln_frozen_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.pln_firm_day_from',
                     x_Group_rec.setup_terms_rec.pln_firm_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.pln_firm_day_to',
                     x_Group_rec.setup_terms_rec.pln_firm_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.pln_forecast_day_from',
                     x_Group_rec.setup_terms_rec.pln_forecast_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.pln_forecast_day_to',
                     x_Group_rec.setup_terms_rec.pln_forecast_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.shp_frozen_day_from',
                     x_Group_rec.setup_terms_rec.shp_frozen_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.shp_frozen_day_to',
                     x_Group_rec.setup_terms_rec.shp_frozen_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.shp_firm_day_from',
                     x_Group_rec.setup_terms_rec.shp_firm_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.shp_firm_day_to',
                     x_Group_rec.setup_terms_rec.shp_firm_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.shp_forecast_day_from',
                     x_Group_rec.setup_terms_rec.shp_forecast_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.shp_forecast_day_to',
                     x_Group_rec.setup_terms_rec.shp_forecast_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.seq_frozen_day_from',
                     x_Group_rec.setup_terms_rec.seq_frozen_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.seq_frozen_day_to',
                     x_Group_rec.setup_terms_rec.seq_frozen_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.seq_firm_day_from',
                     x_Group_rec.setup_terms_rec.seq_firm_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.seq_firm_day_to',
                     x_Group_rec.setup_terms_rec.seq_firm_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.seq_forecast_day_from',
                     x_Group_rec.setup_terms_rec.seq_forecast_day_from);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.seq_forecast_day_to',
                     x_Group_rec.setup_terms_rec.seq_forecast_day_to);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.schedule_type_one',
                     x_Group_rec.schedule_type_one);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.schedule_type_two',
                     x_Group_rec.schedule_type_two);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.schedule_type_three',
                     x_Group_rec.schedule_type_three);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.use_edi_sdp_code_flag',
                     x_Group_rec.setup_terms_rec.use_edi_sdp_code_flag);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.ship_delivery_rule_name',
                     x_Group_rec.Setup_terms_rec.ship_delivery_rule_name);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.ship_method',
                     x_Group_rec.setup_terms_rec.ship_method);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.intransit_time',
                     x_Group_rec.setup_terms_rec.intransit_time);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.customer_rcv_calendar_cd',
                     x_Group_rec.setup_terms_rec.customer_rcv_calendar_cd);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.supplier_shp_calendar_cd',
                     x_Group_rec.setup_terms_rec.supplier_shp_calendar_cd);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.time_uom_code',
                     x_Group_rec.setup_terms_rec.time_uom_code);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.cum_control_code',
                     x_Group_rec.setup_terms_rec.cum_control_code);
       rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.setup_terms_rec.exclude_non_workdays_flag',
                     x_Group_rec.setup_terms_rec.exclude_non_workdays_flag);
    END IF;
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'setups failed');
    END IF;
    --
    raise e_SetupAPIFailed;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN e_SetupAPIFailed THEN
     --
     BEGIN
       --
       SELECT line_id
       INTO v_InterfaceLineId
       FROM rlm_interface_lines
       WHERE header_id = x_Sched_rec.header_id
       AND ship_from_org_id = x_Group_rec.ship_from_org_id
       AND ship_to_address_id = x_Group_rec.ship_to_address_id
       AND customer_item_id = x_Group_rec.customer_item_id
       AND rownum = 1;
       --
       EXCEPTION
        --
        WHEN NO_DATA_FOUND THEN
         v_InterfaceLineId := NULL;
        --
     END;
     --
     rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_error_level,
           x_MessageName => 'RLM_SETUPAPI_FAILED',
           x_ChildMessageName => v_SetupTerms_rec.msg_name,
           x_InterfaceHeaderId => x_sched_rec.header_id,
           x_InterfaceLineId => v_InterfaceLineId,
           x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
           x_OrderLineId => NULL,
           x_GroupInfo   => TRUE,
           x_Token1 => 'ERROR',
           x_value1 => v_ReturnMsg);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     raise e_GroupError;
     --
  WHEN OTHERS THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;

END CallSetups;

/*=========================================================================

PROCEDURE NAME:       LockLines

===========================================================================*/

FUNCTION LockLines (x_headerId  IN NUMBER,
                    x_GroupRec  IN rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN
IS
   --
   x_progress      VARCHAR2(3) := '010';
   --
   CURSOR c IS
     SELECT *
     FROM   rlm_interface_lines_all
     WHERE  header_id  = x_HeaderId
     --and    inventory_item_id = x_GroupRec.inventory_item_id
     and customer_item_id = x_GroupRec.customer_item_id
     and    ship_from_org_id = x_GroupRec.ship_from_org_id
     and    ship_to_org_id = x_GroupRec.ship_to_org_id
     --and    schedule_item_num = x_GroupRec.schedule_item_num
     and    order_header_id = x_GroupRec.Order_header_id
     -- Perf change
     --and    cust_production_seq_num = x_GroupRec.cust_production_seq_num
     and    process_status = rlm_core_sv.k_PS_AVAILABLE
     FOR UPDATE NOWAIT;
   --
   CURSOR c_blanket IS
     SELECT *
     FROM   rlm_interface_lines_all
     WHERE  header_id  = x_HeaderId
     and customer_item_id = x_GroupRec.customer_item_id
     and    ship_from_org_id = x_GroupRec.ship_from_org_id
     and    ship_to_org_id = x_GroupRec.ship_to_org_id
     and    blanket_number = x_GroupRec.blanket_number
     and    process_status = rlm_core_sv.k_PS_AVAILABLE
     FOR UPDATE NOWAIT;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'LockLines');
     rlm_core_sv.dlog(C_DEBUG,'Locking RLM_INTERFACE_LINES');
  END IF;
  --
  IF x_GroupRec.blanket_number is NULL THEN
   --
   OPEN  c;
   CLOSE c;
   --
  ELSE
   --
   OPEN c_blanket;
   CLOSE c_blanket;
   --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN(TRUE);

EXCEPTION
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RETURN(FALSE);

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_managedemand_sv.LockLines', x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RAISE;

END LockLines;

/*=========================================================================

PROCEDURE NAME:       UpdateHeaderStatus

===========================================================================*/

PROCEDURE UpdateHeaderStatus (x_HeaderId    IN   NUMBER,
                              x_ScheduleHeaderId    IN   NUMBER,
                              x_ProcessStatus IN NUMBER )
IS

  x_progress      VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'UpdateHeaderStatus');
     rlm_core_sv.dlog(C_DEBUG,'x_HeaderId',x_HeaderId);
     rlm_core_sv.dlog(C_DEBUG,'x_ScheduleHeaderId',x_ScheduleHeaderId);
     rlm_core_sv.dlog(C_DEBUG,'x_ProcessStatus',x_ProcessStatus);
  END IF;
  --
  UPDATE rlm_interface_headers_all
  SET    process_status = x_ProcessStatus
  WHERE  header_id  = x_HeaderId;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Number of Interface header updated',SQL%ROWCOUNT);
  END IF;
  --
  UPDATE rlm_schedule_headers_all
  SET    process_status = x_ProcessStatus
  WHERE  header_id  = x_ScheduleHeaderId;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Number of schedule header updated',SQL%ROWCOUNT);
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'NO DATA FOUND ERROR',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_managedemand_sv.UpdateHeaderStatus',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;

END UpdateHeaderStatus;

/*=========================================================================

PROCEDURE NAME:       UpdateGroupStatus

===========================================================================*/

PROCEDURE UpdateGroupStatus (x_HeaderId         IN NUMBER,
                             x_ScheduleHeaderId IN NUMBER,
                             x_GroupRec         IN rlm_dp_sv.t_Group_rec,
                             x_ProcessStatus    IN NUMBER,
                             x_UpdateLevel      IN VARCHAR2)
IS
  --
  x_progress      VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'UpdateGroupStatus');
     rlm_core_sv.dlog(C_DEBUG,'x_UpdateLevel',x_UpdateLevel);
     rlm_core_sv.dlog(C_DEBUG,'x_ProcessStatus',x_ProcessStatus);
     rlm_core_sv.dlog(C_DEBUG,'x_HeaderId',x_HeaderId);
     rlm_core_sv.dlog(C_DEBUG,'x_ScheduleHeaderId',x_ScheduleHeaderId);
  END IF;
  --
  IF x_UpdateLevel = 'GROUP' THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_GroupRec.inventory_item_id',x_GroupRec.inventory_item_id);
       rlm_core_sv.dlog(C_DEBUG,'x_GroupRec.ship_from_org_id',x_GroupRec.ship_from_org_id);
       rlm_core_sv.dlog(C_DEBUG,'x_GroupRec.ship_to_address_id',x_GroupRec.ship_to_address_id);
       rlm_core_sv.dlog(C_DEBUG,'x_GroupRec.Order_header_id',x_GroupRec.Order_header_id);
      /*rlm_core_sv.dlog(C_DEBUG,'x_GroupRec.cust_production_seq_num',
                                       x_GroupRec.cust_production_seq_num);*/
    END IF;

    --
    UPDATE rlm_interface_lines
    SET    process_status = x_ProcessStatus
    WHERE  header_id  = x_HeaderId
    and    inventory_item_id = x_GroupRec.inventory_item_id
    and    ship_from_org_id = x_GroupRec.ship_from_org_id
    and    ship_to_address_id = x_GroupRec.ship_to_address_id
    and    order_header_id = x_GroupRec.Order_header_id
    -- Perf change
    /*and    nvl(cust_production_seq_num,k_VNULL) =
                      nvl(x_GroupRec.cust_production_seq_num, k_VNULL)*/
    and    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                                  rlm_core_sv.k_PS_FROZEN_FIRM);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Number of Interface lines updated',SQL%ROWCOUNT);
    END IF;
    --
    UPDATE rlm_schedule_lines
    SET    process_status = x_ProcessStatus
    WHERE  header_id  = x_ScheduleHeaderId
    and    inventory_item_id = x_GroupRec.inventory_item_id
    and    ship_from_org_id = x_GroupRec.ship_from_org_id
    and    ship_to_address_id = x_GroupRec.ship_to_address_id
  --  and    order_header_id = x_GroupRec.Order_header_id
    -- Perf change
    /*and    nvl(cust_production_seq_num, k_VNULL) =
                     nvl(x_GroupRec.cust_production_seq_num, k_VNULL)*/
    and    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                                  rlm_core_sv.k_PS_FROZEN_FIRM);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Number of schedule lines updated',SQL%ROWCOUNT);
    END IF;
    --
  ELSIF x_UpdateLevel = 'ALL' THEN
    --
    UPDATE rlm_interface_lines
    SET    process_status = x_ProcessStatus
    WHERE  header_id  = x_HeaderId
    and    process_status = rlm_core_sv.k_PS_AVAILABLE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Number of Interface lines updated',SQL%ROWCOUNT);
    END IF;
    --
    UPDATE rlm_schedule_lines
    SET    process_status = x_ProcessStatus
    WHERE  header_id  = x_ScheduleHeaderId
    and    process_status = rlm_core_sv.k_PS_AVAILABLE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Number of schedule lines updated',SQL%ROWCOUNT);
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'NO DATA FOUND ERROR',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_managedemand_sv.UpdateGroupStatus',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
END UpdateGroupStatus;

/*=============================================================================

PROCEDURE NAME:  GetConvertedLeadTime

==============================================================================*/
FUNCTION GetConvertedLeadTime (x_LeadTime     IN       NUMBER,
                               x_LeadUOM     IN        VARCHAR2)
RETURN NUMBER
IS
  --
  x_progress VARCHAR2(3) := '010';
  --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG,'apply_lead_time');
      rlm_core_sv.dlog(C_DEBUG,' x_LeadTime',x_LeadTime);
      rlm_core_sv.dlog(C_DEBUG,' x_LeadUOM ',x_LeadUom);
   END IF;
   --
   IF (x_LeadUom = 'DAY') THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RETURN x_LeadTime;
      --
   ELSIF (x_LeadUom = 'HR') THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RETURN  (x_LeadTime/24);
      --
   ELSE
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RETURN  x_LeadTime;
      --
   END IF;
   --
EXCEPTION
  --
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_managedemand_sv.GetConvertedLeadTime',
                                         x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    raise;

END GetConvertedLeadTime;

/*===========================================================================

        FUNCTION NAME:  GetTPContext

===========================================================================*/
PROCEDURE GetTPContext( x_sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
                        x_group_rec  IN rlm_dp_sv.t_Group_rec,
                        x_customer_number OUT NOCOPY VARCHAR2,
                        x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_tp_group_code OUT NOCOPY VARCHAR2)
IS
   --
   v_Progress VARCHAR2(3) := '010';
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG,'GetTPContext');
      rlm_core_sv.dlog(C_DEBUG,'customer_id', x_sched_rec.customer_id);
      rlm_core_sv.dlog(C_DEBUG,'x_sched_rec.ece_tp_translator_code',
                             x_sched_rec.ece_tp_translator_code);
      rlm_core_sv.dlog(C_DEBUG,'x_sched_rec.ece_tp_location_code_ext',
                             x_sched_rec.ece_tp_location_code_ext);
      rlm_core_sv.dlog(C_DEBUG,'x_group_rec.ship_to_address_id',
                             x_group_rec.ship_to_address_id);
   END IF;
   --
   IF x_sched_rec.ECE_TP_LOCATION_CODE_EXT is NOT NULL THEN
        -- Following query is changed as per TCA obsolescence project.
	SELECT	ETG.TP_GROUP_CODE
	INTO	x_tp_group_code
	FROM	ECE_TP_GROUP ETG,
		ECE_TP_HEADERS ETH,
		HZ_CUST_ACCT_SITES ACCT_SITE
	WHERE	ETG.TP_GROUP_ID = ETH.TP_GROUP_ID
	and	ETH.TP_HEADER_ID = ACCT_SITE.TP_HEADER_ID
	and	ACCT_SITE.CUST_ACCOUNT_ID  = x_sched_rec.CUSTOMER_ID
	and	ACCT_SITE.ECE_TP_LOCATION_CODE = x_Sched_rec.ECE_TP_LOCATION_CODE_EXT ;

   ELSE
      x_tp_group_code := x_sched_rec.ECE_TP_TRANSLATOR_CODE;
   END IF;
   --

   BEGIN
     --
     -- Following query is changed as per TCA obsolescence project.
     SELECT 	ece_tp_location_code
     INTO   	x_ship_to_ece_locn_code
     FROM   	HZ_CUST_ACCT_SITES ACCT_SITE
     WHERE  	ACCT_SITE.CUST_ACCT_SITE_ID = x_group_rec.ship_to_address_id;
     --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_ship_to_ece_locn_code := NULL;
   END;

   --   BUG 2204888 : Since we do not group by bill_to anymore, we would not
   --   have the bill_to in x_group_rec. Code has been removed as a part of
   --   TCA OBSOLESCENCE PROJECT.

   --
   IF x_sched_rec.customer_id is NOT NULL THEN
      --
      -- Following query is changed as per TCA obsolescence project.
      SELECT	account_number
      INTO	x_customer_number
      FROM	HZ_CUST_ACCOUNTS CUST_ACCT
      WHERE	CUST_ACCT.CUST_ACCOUNT_ID = x_sched_rec.customer_id;
      --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'customer_number', x_customer_number);
      rlm_core_sv.dlog(C_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG, 'x_tp_group_code',x_tp_group_code);
      rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
      --
      x_customer_number := NULL;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'No data found for' , x_sched_rec.customer_id);
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_ManageDemand_sv.GetTPContext',v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetTPContext;

/*===========================================================================

  FUNCTION CalculateIntransitQty

===========================================================================*/

/*any changes to this package may be incorporated in the function rlm_managedemand_sv.GetAllIntransitQty and rlm_rd_sv.SynchronizeShipments and vice versa */


FUNCTION CalculateIntransitQty(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN rlm_dp_sv.t_Group_rec)
RETURN NUMBER
IS
  --
  v_InTransitQty  NUMBER := 0;
  --
  v_count 			NUMBER DEFAULT 0 ;
  v_shipment_date		DATE;
  v_receipt_date		DATE;
  v_date			DATE;
  v_item_detail_subtype		VARCHAR2(80);
  v_intransit_time              NUMBER := 0;
  --
  x_progress          VARCHAR2(3) DEFAULT '010';
  v_return_status     VARCHAR2(240);
  --
  v_intransit_calc_basis 	VARCHAR2(15);
  v_shipper_rec   		WSH_RLM_INTERFACE.t_shipper_rec;
  v_match_rec	  		WSH_RLM_INTERFACE.t_optional_match_rec;
  v_match_within_rule		RLM_CORE_SV.t_Match_rec;
  v_match_across_rule		RLM_CORE_SV.t_Match_rec;
  v_min_horizon_date    VARCHAR2(30);  --Bugfix 6265953
  v_match_rec_shipline  RLM_RD_SV.t_generic_rec;--Bugfix 6265953
  v_Group_rec           rlm_dp_sv.t_Group_rec; --Bugfix 6265953
  --

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CalculateIntransitQty');
  END IF;
  --
  v_intransit_calc_basis := UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Intransit Calc. basis', v_intransit_calc_basis);
  END IF;
  --
  IF (v_intransit_calc_basis = k_NONE OR v_intransit_calc_basis is NULL) THEN
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Processing rule set to NONE or NULL');
     rlm_core_sv.dlog(C_DEBUG, 'All shipments assumed to be received');
     rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
   RETURN v_IntransitQty;
   --
  ELSIF v_intransit_calc_basis IN (k_RECEIPT, k_SHIPMENT) THEN     --Bugfix 6265953
  --
    RLM_RD_SV.InitializeIntransitParam(x_Sched_rec, x_Group_rec, v_intransit_calc_basis,
				     v_Shipper_rec, v_Shipment_date);
  --
    InitializeMatchCriteria(v_match_within_rule, v_match_across_rule);
  --
    RLM_EXTINTERFACE_SV.getIntransitQty (
        x_Group_rec.customer_id,
        x_Group_rec.ship_to_org_id,
        x_Group_rec.intmed_ship_to_org_id, --Bugfix 5911991
        x_Group_rec.ship_from_org_id,
        x_Group_rec.inventory_item_id,
	    x_Group_rec.customer_item_id,
        x_Group_rec.order_header_id,
        NVL(x_Group_rec.blanket_number, k_NULL),
        x_Sched_rec.org_id,
        x_Sched_rec.schedule_type,
        v_Shipper_Rec,
        v_Shipment_date,
	    v_match_within_rule,
	    v_match_across_rule,
	    v_match_rec,
        x_Sched_rec.header_id,
        v_InTransitQty,
        v_return_status);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'v_return_status', v_return_status);
       rlm_core_sv.dlog(C_DEBUG, 'v_InTransitQty', v_InTransitQty);
    END IF;
    --
    IF v_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG, 'GetIntransitQtyAPI Failed');
      END IF;
      --
      RAISE e_group_error;
    --
    ELSIF v_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG, 'GetIntransitQtyAPI Failed');
      END IF;
      --
      RAISE e_group_error;
    --
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'v_InTransitQty', v_InTransitQty);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RETURN (v_InTransitQty);
  --
--Bugfix 6265953 START
  ELSIF (v_intransit_calc_basis IN ('SHIPPED_LINES','PART_SHIP_LINES')) THEN

      v_Group_rec := x_Group_rec;

      v_Group_rec.match_within_rec := v_match_within_rule;
      v_Group_rec.match_across_rec := v_match_across_rule;
      v_match_rec_shipline.industry_attribute15 := x_Group_rec.industry_attribute15;

--Purchase Order
   IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
     --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG, 'Manage Demand - CUM BY PURCHASE ORDER');
      END IF;

      IF x_group_rec.match_across_rec.cust_po_number = 'Y' THEN
         v_Group_rec.match_across_rec.cust_po_number := 'Y';
      ELSE
         v_Group_rec.match_within_rec.cust_po_number :='Y';
      END IF;
     --
     v_match_rec_shipline.cust_po_number := g_CUM_tab(g_count).purchase_order_number; --Bugfix 7007638
   END IF;  /*Purchase Order*/

--Record Keeping Year
   IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
     --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG, 'Manage Demand - CUM BY RECORD YEAR');
      END IF;

      IF x_group_rec.match_across_rec.industry_attribute1 = 'Y' THEN
         v_Group_rec.match_across_rec.industry_attribute1 := 'Y';
      ELSE
         v_Group_rec.match_within_rec.industry_attribute1 :='Y';
      END IF;
     --
     v_match_rec_shipline.industry_attribute1 := g_CUM_tab(g_count).cust_record_year; --Bugfix 7007638
   END IF;  /*Record Keeping Year*/

      SELECT TO_CHAR(TRUNC(min(il.start_date_time)), 'RRRR/MM/DD HH24:MI:SS')
      INTO v_min_horizon_date
      FROM rlm_interface_lines il,
	       rlm_schedule_lines  sl
      WHERE  il.header_id = x_Sched_rec.header_id
      AND    il.ship_from_org_id = x_Group_rec.ship_from_org_id
      AND    il.ship_to_org_id = x_Group_rec.ship_to_org_id
      AND    il.inventory_item_id = x_Group_rec.inventory_item_id
      AND    il.customer_item_id = x_Group_rec.customer_item_id
      AND    il.schedule_line_id = sl.line_id
      AND    NVL(il.item_detail_type, ' ')
			 <> rlm_manage_demand_sv.k_SHIP_RECEIPT_INFO
      AND    sl.qty_type_code    = rlm_manage_demand_sv.k_ACTUAL;


      --
     IF (v_min_horizon_date IS NOT NULL ) THEN
 	  --

	  IF (l_debug <> -1) THEN
	      rlm_core_sv.dlog(C_DEBUG, 'v_min_request_date', v_min_horizon_date);
	  END IF;
	  --
	  IF TO_DATE(v_min_horizon_date,'RRRR/MM/DD HH24:MI:SS') > x_Sched_rec.sched_horizon_start_date THEN
	    --
	    v_min_horizon_date:=  TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_start_date), 'RRRR/MM/DD HH24:MI:SS');
	    --
	  END IF;
	  --
	  IF (l_debug <> -1) THEN
	      rlm_core_sv.dlog(C_DEBUG, 'v_min_horizon_date', v_min_horizon_date);
	  END IF;

          RLM_EXTINTERFACE_SV.GetIntransitShippedLines(x_Sched_rec,
                                                       v_Group_rec,
                    						           v_match_rec_shipline,
                                                       v_min_horizon_date,
                                                       v_InTransitQty);
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG, v_IntransitQty);
      END IF;

      RETURN v_IntransitQty;

     END IF;

  END IF;
--Bugfix 6265953 END

  --
  EXCEPTION
    --
    WHEN e_group_error THEN
       --
       RAISE;
       --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.CalculateIntransitQty',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END CalculateIntransitQty;


FUNCTION GetAllIntransitQty(x_Sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec  IN rlm_dp_sv.t_Group_rec,
                            x_Source_Tab IN RLM_MANAGE_DEMAND_SV.t_Source_Tab)
RETURN NUMBER
IS

  -- The shipper ID is stored in the item_detail_ref_value_1 field
  -- when the item detail type = 4 and the sub type = 'RECEIPT', 'SHIPMENT'
  --

  CURSOR c_RctShipperIds IS
    SELECT start_date_time,
           primary_quantity,
           substr(item_detail_ref_value_1,1,29) shipper_Id,
           line_id
    FROM   rlm_schedule_lines
    WHERE  ship_from_org_id = x_Group_rec.ship_from_org_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id =  x_Group_rec.inventory_item_id
    AND    customer_item_id  =  x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_RECEIPT
    ORDER BY start_date_time DESC;

  CURSOR c_ShpShipperIds IS
    SELECT start_date_time,
           primary_quantity,
           substr(item_detail_ref_value_1,1,29) shipper_Id,
           line_id
    FROM   rlm_schedule_lines
    WHERE  ship_from_org_id = x_Group_rec.ship_from_org_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id =  x_Group_rec.inventory_item_id
    AND    customer_item_id  =  x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_SHIPMENT
    ORDER BY start_date_time DESC;

  --
  -- This cursor is to select the most recent receipt
  -- line on the current schedule for each group
  --
  CURSOR c_LastReceipt(i IN NUMBER) IS
    SELECT start_date_time,
	   item_detail_subtype,
	   item_detail_ref_value_1
    FROM   rlm_interface_lines
    WHERE  header_id = x_Sched_rec.header_id
    AND    ship_from_org_id = x_Source_Tab(i).organization_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id = x_Group_rec.inventory_item_id
    AND    customer_item_id = x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_RECEIPT
    ORDER BY start_date_time DESC;


  --
  -- This cursor is to select the most recent shipment
  -- line on the current schedule for each group
  --
  CURSOR c_LastShipment(i IN NUMBER) IS
    SELECT start_date_time,
	   item_detail_subtype,
	   item_detail_ref_value_1
    FROM   rlm_interface_lines
    WHERE  header_id = x_Sched_rec.header_id
    AND    ship_from_org_id = x_Source_Tab(i).organization_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id = x_Group_rec.inventory_item_id
    AND    customer_item_id = x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_SHIPMENT
    ORDER BY start_date_time DESC;


  --
  v_InTransitQty                NUMBER DEFAULT 0;
  v_Temp_InTransitQty           NUMBER DEFAULT 0;
  --
  v_count 			NUMBER DEFAULT 0 ;
  v_shipment_date		DATE;
  v_receipt_date		DATE;
  v_date			DATE;
  v_item_detail_subtype		VARCHAR2(80);
  v_cust_production_seq_num 	VARCHAR2(35);
  v_intransit_time              NUMBER := 0;
  --
  x_progress                    VARCHAR2(3) DEFAULT '010';
  v_return_status               VARCHAR2(240);

  v_Total_Qty                   NUMBER DEFAULT 0;

  i NUMBER;

  v_SetupTerms_rec    rlm_setup_terms_sv.setup_terms_rec_typ;
  v_TermsLevel        VARCHAR2(30) := NULL;
  v_ReturnStatus      BOOLEAN;
  v_ReturnMsg         VARCHAR2(2000);
  e_SetupAPIFailed    EXCEPTION;
  v_order_header_id   NUMBER;
  --
  v_match_within_rule		RLM_CORE_SV.t_Match_rec;
  v_match_across_rule		RLM_CORE_SV.t_Match_rec;
  v_match_rec			WSH_RLM_INTERFACE.t_optional_match_rec;
  v_shipper_rec                 WSH_RLM_INTERFACE.t_shipper_rec;
  v_intransit_calc_basis	VARCHAR2(15);
  v_deliveryID			VARCHAR2(35);
  e_IntransitNone		EXCEPTION;
  --

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'GetAllIntransitQty');
  END IF;
  --
  InitializeMatchCriteria(v_match_within_rule, v_match_across_rule);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'count', x_Source_Tab.COUNT);
  END IF;
  --
  FOR i IN 1 .. x_Source_Tab.COUNT LOOP

    BEGIN /* outer begin */
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Loop Counter', i);
       rlm_core_sv.dlog(C_DEBUG, 'Src Orgzn ID', x_Source_Tab(i).organization_id);
    END IF;
    --
    BEGIN

      RLM_TPA_SV.get_setup_terms(x_Source_Tab(i).organization_id,
                                x_Group_rec.customer_id,
                                x_Group_rec.ship_to_address_id,
                                x_Group_rec.customer_item_id,
                                v_TermsLevel,
                                v_SetupTerms_rec,
                                v_ReturnMsg,
                                v_ReturnStatus);
      IF v_ReturnStatus THEN
        v_order_header_id := v_SetupTerms_rec.header_id;
      ELSE
        RAISE e_SetupAPIFailed;
      END IF;

    EXCEPTION
       WHEN e_SetupAPIFailed THEN
         --
         rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_error_level,
           x_MessageName => 'RLM_SETUPAPI_FAILED',
           x_ChildMessageName => v_SetupTerms_rec.msg_name,
           x_InterfaceHeaderId => x_sched_rec.header_id,
           x_InterfaceLineId => NULL,
           x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
           x_OrderLineId => NULL,
           x_Token1 => 'ERROR',
           x_value1 => v_ReturnMsg);
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(C_SDEBUG);
         END IF;
         --
         raise e_group_error;
         --

       WHEN OTHERS THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(C_SDEBUG);
         END IF;
         --
         raise e_group_error;

    END; /* get_setup_terms */
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'order_header_id', v_order_header_id);
       rlm_core_sv.dlog(C_DEBUG, 'Intransit calc. basis', v_SetupTerms_rec.intransit_calc_basis);
    END IF;
    --
    IF (v_SetupTerms_rec.time_uom_code = 'HR') THEN
      v_intransit_time := nvl(v_SetupTerms_rec.intransit_time,0)/24;
    ELSE
      v_intransit_time := nvl(v_SetupTerms_rec.intransit_time,0);
    END IF;
    --
    IF (v_SetupTerms_rec.intransit_calc_basis = k_NONE OR v_SetupTerms_rec.intransit_calc_basis is NULL) THEN
      --
      RAISE e_IntransitNone;
      --
    ELSIF (v_SetupTerms_rec.intransit_calc_basis = k_RECEIPT) THEN
      --
      OPEN c_LastReceipt(i);
      FETCH c_LastReceipt INTO v_shipment_Date, v_item_detail_subtype, v_deliveryID;
      --
      IF (c_LastReceipt%NOTFOUND) THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(c_DEBUG, 'No receipt line present on schedule');
        END IF;
        --
        v_shipment_date := x_Sched_rec.sched_generation_date - v_intransit_time;
        v_shipper_rec.shipper_Id1 := NULL;
        v_Shipper_rec.shipper_Id2 := NULL;
        v_Shipper_rec.shipper_Id3 := NULL;
        v_Shipper_rec.shipper_Id3 := NULL;
        v_Shipper_rec.shipper_Id3 := NULL;
        --
      ELSIF (v_deliveryID is NOT NULL) THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Delivery ID present on schedule');
        END IF;
        --
        FOR v_RctSID in c_RctShipperIds LOOP
         --
         IF (c_RctShipperIds%NOTFOUND OR v_count > 5 ) THEN
           EXIT;
         END IF;
         --
         v_count := v_count + 1;
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'line_id', v_RctSID.line_id);
            rlm_core_sv.dlog(C_DEBUG,'start_date_time', v_RctSID.start_date_time);
            rlm_core_sv.dlog(C_DEBUG,'i', i);
            rlm_core_sv.dlog(C_DEBUG,'v_count', v_count);
            rlm_core_sv.dlog(C_DEBUG,'Shipper_id', v_RctSID.shipper_Id);
         END IF;
         --
         IF v_count = 1 THEN
          --
          v_shipper_rec.shipper_Id1 := v_RctSID.shipper_Id;
          --
         ELSIF v_count = 2  THEN
          --
          v_shipper_rec.shipper_Id2 := v_RctSID.shipper_Id;
          --
         ELSIF v_count = 3  THEN
          --
          v_shipper_rec.shipper_Id3 := v_RctSID.shipper_Id;
          --
         ELSIF v_count = 4  THEN
          --
          v_shipper_rec.shipper_Id4 := v_RctSID.shipper_Id;
          --
         ELSIF v_count = 5  THEN
          --
          v_shipper_rec.shipper_Id5 := v_RctSID.shipper_Id;
          --
         END IF;
         --
        END LOOP;
        --
        ELSIF (v_shipment_date is NOT NULL) THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, 'No delivery ID present on schedule');
         END IF;
	 --
         v_shipment_date := v_shipment_Date - v_intransit_time;
         v_shipper_rec.shipper_Id1 := NULL;
         v_Shipper_rec.shipper_Id2 := NULL;
         v_Shipper_rec.shipper_Id3 := NULL;
         v_Shipper_rec.shipper_Id3 := NULL;
         v_Shipper_rec.shipper_Id3 := NULL;
         --
        END IF;
        --
        CLOSE c_LastReceipt;
        --
      ELSE /* intransit calc. basis = 'shipment' */
       --
       OPEN c_LastShipment(i);
       FETCH c_LastShipment INTO v_shipment_date, v_item_detail_subtype, v_deliveryID;
       --
       IF (c_LastShipment%NOTFOUND) THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'No shipment line, so shipment date = sched_gen_Date');
        END IF;
	--
        v_shipment_date := x_Sched_rec.sched_generation_date;
        v_shipper_rec.shipper_Id1 := NULL;
        v_Shipper_rec.shipper_Id2 := NULL;
        v_Shipper_rec.shipper_Id3 := NULL;
        v_Shipper_rec.shipper_Id4 := NULL;
        v_Shipper_rec.shipper_Id5 := NULL;
        --
       ELSIF (v_deliveryID is NOT NULL) THEN
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Delivery ID present on schedule');
        END IF;
        --
        FOR v_ShpSID  IN c_ShpShipperIds LOOP
         --
         IF (c_ShpShipperIds%NOTFOUND  OR v_count > 5) THEN
          EXIT;
         END IF;
         --
         v_count := v_count + 1;
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'line_id', v_ShpSID.line_id);
            rlm_core_sv.dlog(C_DEBUG,'start_date_time', v_ShpSID.start_date_time);
            rlm_core_sv.dlog(C_DEBUG,'v_count', v_count);
            rlm_core_sv.dlog(C_DEBUG,'Shipper_id', v_ShpSID.shipper_Id);
         END IF;
         --
         IF v_count = 1 THEN
          --
          v_shipper_rec.shipper_Id1 := v_ShpSID.shipper_Id;
          --
         ELSIF v_count = 2  THEN
          --
          v_shipper_rec.shipper_Id2 := v_ShpSID.shipper_Id;
          --
         ELSIF v_count = 3  THEN
          --
          v_shipper_rec.shipper_Id3 := v_ShpSID.shipper_Id;
          --
         ELSIF v_count = 4  THEN
          --
          v_shipper_rec.shipper_Id4 := v_ShpSID.shipper_Id;
          --
         ELSIF v_count = 5  THEN
          --
          v_shipper_rec.shipper_Id5 := v_ShpSID.shipper_Id;
          --
         END IF;
         --
        END LOOP;
        --
       ELSIF (v_shipment_date is NOT NULL) THEN
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'No delivery ID present on schedule');
        END IF;
	--
        v_shipper_rec.shipper_Id1 := NULL;
        v_Shipper_rec.shipper_Id2 := NULL;
        v_Shipper_rec.shipper_Id3 := NULL;
        v_Shipper_rec.shipper_Id3 := NULL;
        v_Shipper_rec.shipper_Id3 := NULL;
        --
       END IF;
       --
       CLOSE c_LastShipment;
       --
      END IF; /* if intransit calculation basis */
      --
      RLM_EXTINTERFACE_SV.getIntransitQty (
          x_Group_rec.customer_id,
          x_Group_rec.ship_to_org_id,
          x_Group_rec.intmed_ship_to_org_id, --Bugfix 5911991
          x_Source_Tab(i).organization_id,
          x_Group_rec.inventory_item_id,
	  x_Group_rec.customer_item_id,
          v_order_header_id,
	  NVL(x_Group_rec.blanket_number, k_NULL),
          x_Sched_rec.org_id,
	  x_Sched_rec.schedule_type,
          v_Shipper_rec,
          v_Shipment_date,
          v_match_within_rule,
	  v_match_across_rule,
	  v_match_rec,
          x_Sched_rec.header_id,
          v_InTransitQty,
          v_return_status);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'v_return_status', v_return_status);
          rlm_core_sv.dlog(C_DEBUG, 'v_InTransitQty', v_InTransitQty);
       END IF;
       --
       IF v_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR THEN
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dpop(C_SDEBUG, 'GetIntransitQtyAPI Failed');
          END IF;
	  --
          RAISE e_group_error;
          --
       ELSIF v_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dpop(C_SDEBUG, 'GetIntransitQtyAPI Failed');
          END IF;
	  --
          RAISE e_group_error;
          --
       END IF;

       --
       -- to do JH : The line id os from schedule lines and not interface lines
       -- what implications of keeping this line id and also or line id as null?
       --
       v_Total_Qty := v_Total_Qty + v_InTransitQty;

       EXCEPTION
	  WHEN e_IntransitNone THEN
	      --
  	      IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG, 'e_IntransitNone');
                 rlm_core_sv.dlog(C_DEBUG, 'Skipping intransit calns for orgId', x_Source_Tab(i).organization_id);
              END IF;

       END; /* outer begin */

  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  return v_Total_Qty;
  --
  EXCEPTION
    --
    WHEN e_group_error THEN
       --
       RAISE;
       --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('GetAllIntransitQty',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      RAISE;

END GetAllIntransitQty;


PROCEDURE InitializeMatchCriteria(x_match_within_rule IN OUT NOCOPY RLM_CORE_SV.t_Match_Rec,
				  x_match_across_rule IN OUT NOCOPY RLM_CORE_SV.t_Match_rec)
IS

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'InitializeMatchCriteria');
  END IF;
  --
  x_match_within_rule.cust_production_line := 'N';
  x_match_within_rule.customer_dock_code := 'N';
  x_match_within_rule.request_date := 'N';
  x_match_within_rule.schedule_date := 'N';
  x_match_within_rule.cust_po_number := 'N';
  x_match_within_rule.customer_item_revision := 'N';
  x_match_within_rule.customer_job := 'N';
  x_match_within_rule.cust_model_serial_number := 'N';
  x_match_within_rule.cust_production_seq_num := 'N';
  x_match_within_rule.industry_attribute1 := 'N';
  x_match_within_rule.industry_attribute2 := 'N';
  x_match_within_rule.industry_attribute3 := 'N';
  x_match_within_rule.industry_attribute4 := 'N';
  x_match_within_rule.industry_attribute5 := 'N';
  x_match_within_rule.industry_attribute6 := 'N';
  x_match_within_rule.industry_attribute7 := 'N';
  x_match_within_rule.industry_attribute8 := 'N';
  x_match_within_rule.industry_attribute9 := 'N';
  x_match_within_rule.industry_attribute10 := 'N';
  x_match_within_rule.industry_attribute11 := 'N';
  x_match_within_rule.industry_attribute12 := 'N';
  x_match_within_rule.industry_attribute13 := 'N';
  x_match_within_rule.industry_attribute14 := 'N';
  x_match_within_rule.industry_attribute15 := 'N';
  x_match_within_rule.attribute1 := 'N';
  x_match_within_rule.attribute2 := 'N';
  x_match_within_rule.attribute3 := 'N';
  x_match_within_rule.attribute4 := 'N';
  x_match_within_rule.attribute5 := 'N';
  x_match_within_rule.attribute6 := 'N';
  x_match_within_rule.attribute7 := 'N';
  x_match_within_rule.attribute8 := 'N';
  x_match_within_rule.attribute9 := 'N';
  x_match_within_rule.attribute10 := 'N';
  x_match_within_rule.attribute11 := 'N';
  x_match_within_rule.attribute12 := 'N';
  x_match_within_rule.attribute13 := 'N';
  x_match_within_rule.attribute14 := 'N';
  x_match_within_rule.attribute15 := 'N';
  --
  x_match_across_rule.cust_production_line := 'N';
  x_match_across_rule.customer_dock_code := 'N';
  x_match_across_rule.request_date := 'N';
  x_match_across_rule.schedule_date := 'N';
  x_match_across_rule.cust_po_number := 'N';
  x_match_across_rule.customer_item_revision := 'N';
  x_match_across_rule.customer_job := 'N';
  x_match_across_rule.cust_model_serial_number := 'N';
  x_match_across_rule.cust_production_seq_num := 'N';
  x_match_across_rule.industry_attribute1 := 'N';
  x_match_across_rule.industry_attribute2 := 'N';
  x_match_across_rule.industry_attribute3 := 'N';
  x_match_across_rule.industry_attribute4 := 'N';
  x_match_across_rule.industry_attribute5 := 'N';
  x_match_across_rule.industry_attribute6 := 'N';
  x_match_across_rule.industry_attribute7 := 'N';
  x_match_across_rule.industry_attribute8 := 'N';
  x_match_across_rule.industry_attribute9 := 'N';
  x_match_across_rule.industry_attribute10 := 'N';
  x_match_across_rule.industry_attribute11 := 'N';
  x_match_across_rule.industry_attribute12 := 'N';
  x_match_across_rule.industry_attribute13 := 'N';
  x_match_across_rule.industry_attribute14 := 'N';
  x_match_across_rule.industry_attribute15 := 'N';
  x_match_across_rule.attribute1 := 'N';
  x_match_across_rule.attribute2 := 'N';
  x_match_across_rule.attribute3 := 'N';
  x_match_across_rule.attribute4 := 'N';
  x_match_across_rule.attribute5 := 'N';
  x_match_across_rule.attribute6 := 'N';
  x_match_across_rule.attribute7 := 'N';
  x_match_across_rule.attribute8 := 'N';
  x_match_across_rule.attribute9 := 'N';
  x_match_across_rule.attribute10 := 'N';
  x_match_across_rule.attribute11 := 'N';
  x_match_across_rule.attribute12 := 'N';
  x_match_across_rule.attribute13 := 'N';
  x_match_across_rule.attribute14 := 'N';
  x_match_across_rule.attribute15 := 'N';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG, 'InitializeMatchCriteria');
  END IF;
  --
END InitializeMatchCriteria;

/*=========================================================================
--global_atp
FUNCTION NAME:       IsATPItem

===========================================================================*/

FUNCTION IsATPItem (x_ship_from_org_id  IN NUMBER,
                    x_inventory_item_id IN NUMBER)
RETURN BOOLEAN
IS
  v_atp_flag            VARCHAR2(1);
  v_atp_components_flag VARCHAR2(1);
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'IsATPItem');
     rlm_core_sv.dlog(C_DEBUG,'x_ship_from_org_id',x_ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_inventory_item_id', x_inventory_item_id);
  END IF;
  --
  SELECT atp_flag, atp_components_flag
  INTO   v_atp_flag, v_atp_components_flag
  FROM   mtl_system_items
  WHERE  inventory_item_id = x_inventory_item_id
  AND    organization_id = x_ship_from_org_id;

  IF v_atp_flag = 'Y' OR v_atp_components_flag = 'Y' THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'TRUE');
    END IF;
    --
    RETURN TRUE;
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'FALSE');
    END IF;
    --
    RETURN FALSE;
  END IF;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'FALSE');
    END IF;
    --
    RETURN FALSE;

  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RAISE;

END IsATPItem;

/*===========================================================================

        PROCEDURE NAME:  ReportExc

===========================================================================*/
PROCEDURE ReportExc(x_ExcpTab      IN   t_Match_tab)
IS
  v_shipFrom             org_organization_definitions.organization_code%TYPE;
  v_shipTo               HZ_CUST_ACCT_SITES_ALL.ece_tp_location_code%TYPE; -- Parameter definition is changed as per TCA obsolescence project.
  v_Item                 mtl_customer_items.customer_item_number%TYPE;
  v_excpRec              rlm_core_sv.t_Match_rec;


BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ReportExc');
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'shipFrom', g_ManageDemand_tab(1).ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'shipTo', g_ManageDemand_tab(1).ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG,'customerItem',g_ManageDemand_tab(1).customer_item_id);
     rlm_core_sv.dlog(C_DEBUG,'headerId', g_ManageDemand_tab(1).header_id);
     rlm_core_sv.dlog(C_DEBUG,'line_id', g_ManageDemand_tab(1).line_id);
  END IF;
  --
  FOR i IN 1..x_ExcpTab.COUNT LOOP
     IF x_ExcpTab(i).cust_production_line = 'Y' THEN
        v_excpRec.cust_production_line := 'Y' ;
     END IF;
     --
     IF x_ExcpTab(i).customer_dock_code = 'Y'THEN
        v_excpRec.customer_dock_code := 'Y' ;
     END IF;
     --
     IF x_ExcpTab(i).request_date = 'Y'THEN
        v_excpRec.request_date := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).cust_po_number = 'Y'THEN
        v_excpRec.cust_po_number := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).customer_item_revision = 'Y'THEN
        v_excpRec.customer_item_revision := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).customer_job = 'Y'THEN
        v_excpRec.customer_job := 'Y' ;
     END IF;
     --
     IF x_ExcpTab(i).cust_model_serial_number = 'Y'THEN
        v_excpRec.cust_model_serial_number := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).cust_production_seq_num = 'Y'THEN
        v_excpRec.cust_production_seq_num := 'Y' ;
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute1 = 'Y'THEN
        v_excpRec.industry_attribute1 := 'Y' ;
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute2 = 'Y'THEN
        v_excpRec.industry_attribute2 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute4 = 'Y'THEN
        v_excpRec.industry_attribute4 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute5 = 'Y'THEN
        v_excpRec.industry_attribute5 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute6 = 'Y'THEN
        v_excpRec.industry_attribute6 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute10 = 'Y'THEN
        v_excpRec.industry_attribute10 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute11 = 'Y'THEN
        v_excpRec.industry_attribute11 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute12 = 'Y'THEN
        v_excpRec.industry_attribute12 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute13 = 'Y'THEN
        v_excpRec.industry_attribute13 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).industry_attribute14 = 'Y'THEN
        v_excpRec.industry_attribute14 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute1 = 'Y'THEN
        v_excpRec.attribute1 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute2 = 'Y'THEN
        v_excpRec.attribute2 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute3 = 'Y'THEN
        v_excpRec.attribute3 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute4 = 'Y'THEN
        v_excpRec.attribute4 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute5 = 'Y'THEN
        v_excpRec.attribute5 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute6 = 'Y'THEN
        v_excpRec.attribute6 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute7 = 'Y'THEN
        v_excpRec.attribute7 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute8 = 'Y'THEN
        v_excpRec.attribute8 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute9 = 'Y'THEN
        v_excpRec.attribute9 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute10 = 'Y'THEN
        v_excpRec.attribute10 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute11 = 'Y'THEN
        v_excpRec.attribute11 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute12 = 'Y'THEN
        v_excpRec.attribute12 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute13 = 'Y'THEN
        v_excpRec.attribute13 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute14 = 'Y'THEN
        v_excpRec.attribute14 := 'Y';
     END IF;
     --
     IF x_ExcpTab(i).attribute15 = 'Y'THEN
        v_excpRec.attribute15 := 'Y';
     END IF;
     --
  END LOOP;

  --Prepare to print warnings
  v_shipFrom := rlm_core_sv.get_ship_from(g_ManageDemand_tab(1).ship_from_org_id);
  --
  v_shipTo := rlm_core_sv.get_ship_to(g_ManageDemand_tab(1).ship_to_address_id);
  --
  v_item := rlm_core_sv.get_item_number(g_ManageDemand_tab(1).customer_item_id);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_item', v_item);
     rlm_core_sv.dlog(C_DEBUG,'v_shipTo', v_shipTo);
     rlm_core_sv.dlog(C_DEBUG,'v_shipFrom', v_shipFrom);
  END IF;
  --
  IF v_excpRec.cust_production_line = 'Y' THEN
    printMessage(k_CUST_PRODUCTION_LINE,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.customer_dock_code = 'Y'THEN
    printMessage(k_CUSTOMER_DOCK_CODE,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.request_date = 'Y'THEN
    printMessage(k_REQUEST_DATE,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.cust_po_number = 'Y'THEN
    printMessage(k_CUST_PO_NUMBER,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.customer_item_revision = 'Y'THEN
    printMessage(k_CUSTOMER_ITEM_REVISION,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.customer_job = 'Y'THEN
    printMessage(k_CUSTOMER_JOB,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.cust_model_serial_number = 'Y'THEN
    printMessage(k_CUST_MODEL_SERIAL_NUMBER,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.cust_production_seq_num = 'Y'THEN
    printMessage(k_CUST_PRODUCTION_SEQ_NUM,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute1 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE1,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute2 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE2,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute4 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE4,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute5 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE5,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute6 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE6,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute10 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE10,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute11 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE11,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute12 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE12,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute13 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE13,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.industry_attribute14 = 'Y'THEN
    printMessage(k_INDUSTRY_ATTRIBUTE14,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute1 = 'Y'THEN
    printMessage(k_ATTRIBUTE1,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute2 = 'Y'THEN
    printMessage(k_ATTRIBUTE2,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute3 = 'Y'THEN
    printMessage(k_ATTRIBUTE3,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute4 = 'Y'THEN
    printMessage(k_ATTRIBUTE4,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute5 = 'Y'THEN
    printMessage(k_ATTRIBUTE5,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute6 = 'Y'THEN
    printMessage(k_ATTRIBUTE6,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute7 = 'Y'THEN
    printMessage(k_ATTRIBUTE7,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute8 = 'Y'THEN
    printMessage(k_ATTRIBUTE8,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute9 = 'Y'THEN
    printMessage(k_ATTRIBUTE9,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute10 = 'Y'THEN
    printMessage(k_ATTRIBUTE10,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute11 = 'Y'THEN
    printMessage(k_ATTRIBUTE11,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute12 = 'Y'THEN
    printMessage(k_ATTRIBUTE12,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute13 = 'Y'THEN
    printMessage(k_ATTRIBUTE13,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute14 = 'Y'THEN
    printMessage(k_ATTRIBUTE14,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF v_excpRec.attribute15 = 'Y'THEN
    printMessage(k_ATTRIBUTE15,v_shipFrom,v_shipTo,v_item);
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG,'ReportExc');
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'Error '|| SUBSTR(SQLERRM,1,200));
      END IF;
      --
END ReportExc;

/*===========================================================================

        PROCEDURE NAME:  printMessage

===========================================================================*/
PROCEDURE printMessage(   x_lookupCode   IN   VARCHAR2,
                          x_shipFrom     IN   VARCHAR2,
                          x_shipTo       IN   VARCHAR2,
                          x_customerItem IN   VARCHAR2)
IS
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'printMessage');
     rlm_core_sv.dlog(C_DEBUG,'warning for:', x_lookupCode);
  END IF;
  --
  rlm_message_sv.app_error(
             x_ExceptionLevel => rlm_message_sv.k_warn_level,
             x_MessageName => 'RLM_DUPLICATE_LINES',
             x_InterfaceHeaderId => g_ManageDemand_tab(1).header_id,
             x_InterfaceLineId => g_ManageDemand_tab(1).line_id,
             x_token1=> 'MATCH_ATTRIBUTE',
             x_value1=> rlm_core_sv.get_lookup_meaning(
                          'RLM_OPTIONAL_MATCH_ATTRIBUTES',
                          x_lookupCode),
             x_token2=> 'SF',
             x_value2=> x_shipFrom,
             x_token3=> 'ST',
             x_value3=> x_shipTo,
             x_token4=> 'CI',
             x_value4=> x_customerItem);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG,'printMessage ');
  END IF;
  --
EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'Exception '|| SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END printMessage;

--
-- Bug 2788014: Calculate intransit quantities across orgs and orders
-- if CUM org level is xxx/All Ship Froms
--
FUNCTION GetIntransitAcrossOrgs(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
			        x_Group_rec IN rlm_dp_sv.t_Group_rec,
				x_cum_key_id IN NUMBER)
RETURN NUMBER IS
  -- The shipper ID is stored in the item_detail_ref_value_1 field
  -- when the item detail type = 4 and the sub type = 'RECEIPT', 'SHIPMENT'
  --

  CURSOR c_RctShipperIds IS
    SELECT start_date_time,
           primary_quantity,
           substr(item_detail_ref_value_1,1,29) shipper_Id,
           line_id
    FROM   rlm_schedule_lines
    WHERE  ship_from_org_id = x_Group_rec.ship_from_org_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id =  x_Group_rec.inventory_item_id
    AND    customer_item_id  =  x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_RECEIPT
    ORDER BY start_date_time DESC;

  CURSOR c_ShpShipperIds IS
    SELECT start_date_time,
           primary_quantity,
           substr(item_detail_ref_value_1,1,29) shipper_Id,
           line_id
    FROM   rlm_schedule_lines
    WHERE  ship_from_org_id = x_Group_rec.ship_from_org_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id =  x_Group_rec.inventory_item_id
    AND    customer_item_id  =  x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_SHIPMENT
    ORDER BY start_date_time DESC;
  --
  -- This cursor is to select the most recent receipt
  -- line on the current schedule for each group
  --
  CURSOR c_LastReceipt IS
    SELECT start_date_time,
	   item_detail_subtype,
	   item_detail_ref_value_1
    FROM   rlm_interface_lines
    WHERE  header_id = x_Sched_rec.header_id
    AND    ship_from_org_id = x_Group_rec.ship_from_org_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id = x_Group_rec.inventory_item_id
    AND    customer_item_id = x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_RECEIPT
    ORDER BY start_date_time DESC;
  --
  -- This cursor is to select the most recent shipment
  -- line on the current schedule for each group
  --
  CURSOR c_LastShipment IS
    SELECT start_date_time,
	   item_detail_subtype,
	   item_detail_ref_value_1
    FROM   rlm_interface_lines
    WHERE  header_id = x_Sched_rec.header_id
    AND    ship_from_org_id = x_Group_rec.ship_from_org_id
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    inventory_item_id = x_Group_rec.inventory_item_id
    AND    customer_item_id = x_Group_rec.customer_item_id
    AND    item_detail_type = k_RECT
    AND    qty_type_code = k_ACTUAL
    AND    item_detail_subtype = k_SHIPMENT
    ORDER BY start_date_time DESC;
  --
  v_InTransitQty                NUMBER DEFAULT 0;
  v_count 			NUMBER DEFAULT 0 ;
  v_shipment_date		DATE;
  v_receipt_date		DATE;
  v_date			DATE;
  v_item_detail_subtype		VARCHAR2(80);
  v_cust_production_seq_num 	VARCHAR2(35);
  v_intransit_time              NUMBER := 0;
  --
  x_progress                    VARCHAR2(3) DEFAULT '010';
  v_return_status               VARCHAR2(240);
  i NUMBER;
  v_ReturnStatus      BOOLEAN;
  v_ReturnMsg         VARCHAR2(2000);
  --
  v_match_within_rule		RLM_CORE_SV.t_Match_rec;
  v_match_across_rule		RLM_CORE_SV.t_Match_rec;
  v_match_rec			WSH_RLM_INTERFACE.t_optional_match_rec;
  v_shipper_rec                 WSH_RLM_INTERFACE.t_shipper_rec;
  v_intransit_calc_basis	VARCHAR2(15);
  v_deliveryID			VARCHAR2(35);
  v_min_horizon_date    VARCHAR2(30);  --Bugfix 6265953
  v_match_rec_shipline  RLM_RD_SV.t_generic_rec;--Bugfix 6265953
  v_Group_rec           rlm_dp_sv.t_Group_rec; --Bugfix 6265953
  --
  CURSOR c_Orders IS
  SELECT header_id
  FROM oe_order_lines
  WHERE ship_to_org_id = x_Group_rec.ship_to_org_id
  AND ordered_item_id = x_Group_rec.customer_item_id
  AND inventory_item_id = x_Group_rec.inventory_item_id
  AND veh_cus_item_cum_key_id = x_cum_key_id
  GROUP BY header_id;
  --
  v_order_header_id	NUMBER;
  v_IntransitQty_tmp	NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(C_SDEBUG, 'GetIntransitAcrossOrgs');
   rlm_core_sv.dlog(C_DEBUG, 'CUM Key ID', x_cum_key_id);
  END IF;
  --
  InitializeMatchCriteria(v_match_within_rule, v_match_across_rule);
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Intran. calc.basis', x_Group_rec.setup_terms_rec.intransit_calc_basis);
  END IF;
  --
  IF (x_Group_rec.setup_terms_rec.time_uom_code = 'HR') THEN
      v_intransit_time := nvl(x_Group_rec.setup_terms_rec.intransit_time,0)/24;
  ELSE
      v_intransit_time := nvl(x_Group_rec.setup_terms_rec.intransit_time,0);
  END IF;
  --
  IF (x_Group_rec.setup_terms_rec.intransit_calc_basis = k_NONE OR
      x_Group_rec.setup_terms_rec.intransit_calc_basis is NULL) THEN
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'No intransit qty calculations');
    rlm_core_sv.dpop(C_SDEBUG, v_IntransitQty);
   END IF;
   --
   RETURN v_IntransitQty;
   --
  ELSIF x_Group_rec.setup_terms_rec.intransit_calc_basis IN (k_RECEIPT, k_SHIPMENT) THEN     --Bugfix 6265953
   --
   IF x_Group_rec.setup_terms_rec.intransit_calc_basis = k_RECEIPT THEN --Bugfix 6265953

   OPEN c_LastReceipt;
   FETCH c_LastReceipt INTO v_shipment_Date, v_item_detail_subtype, v_deliveryID;
   --
   IF (c_LastReceipt%NOTFOUND) THEN
    --
    v_shipment_date := x_Sched_rec.sched_generation_date - v_intransit_time;
    v_shipper_rec.shipper_Id1 := NULL;
    v_Shipper_rec.shipper_Id2 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(c_DEBUG, 'No receipt line present on schedule, using Sched Gen date');
      rlm_core_sv.dlog(C_DEBUG, 'v_shipment_date', v_shipment_date);
    END IF;
    --
   ELSIF (v_deliveryID is NOT NULL) THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Delivery ID present on schedule');
    END IF;
    --
    FOR v_RctSID in c_RctShipperIds LOOP
     --
     IF (c_RctShipperIds%NOTFOUND OR v_count > 5 ) THEN
       EXIT;
     END IF;
     --
     v_count := v_count + 1;
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'line_id', v_RctSID.line_id);
       rlm_core_sv.dlog(C_DEBUG,'start_date_time', v_RctSID.start_date_time);
       rlm_core_sv.dlog(C_DEBUG,'i', i);
       rlm_core_sv.dlog(C_DEBUG,'v_count', v_count);
       rlm_core_sv.dlog(C_DEBUG,'Shipper_id', v_RctSID.shipper_Id);
     END IF;
     --
     IF v_count = 1 THEN
       v_shipper_rec.shipper_Id1 := v_RctSID.shipper_Id;
     ELSIF v_count = 2  THEN
       v_shipper_rec.shipper_Id2 := v_RctSID.shipper_Id;
     ELSIF v_count = 3  THEN
       v_shipper_rec.shipper_Id3 := v_RctSID.shipper_Id;
     ELSIF v_count = 4  THEN
       v_shipper_rec.shipper_Id4 := v_RctSID.shipper_Id;
     ELSIF v_count = 5  THEN
       v_shipper_rec.shipper_Id5 := v_RctSID.shipper_Id;
     END IF;
     --
    END LOOP;
    --
   ELSIF (v_shipment_date is NOT NULL) THEN
    --
    v_shipment_date := v_shipment_Date - v_intransit_time;
    v_shipper_rec.shipper_Id1 := NULL;
    v_Shipper_rec.shipper_Id2 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'No delivery ID present on schedule');
      rlm_core_sv.dlog(C_DEBUG, 'v_shipment_date', v_shipment_date);
    END IF;
    --
   END IF;
   --
   CLOSE c_LastReceipt;
   --
  ELSE /* intransit calc. basis = 'shipment' */
   --
   OPEN c_LastShipment;
   FETCH c_LastShipment INTO v_shipment_date, v_item_detail_subtype, v_deliveryID;
   --
   IF (c_LastShipment%NOTFOUND) THEN
    --
    v_shipment_date := x_Sched_rec.sched_generation_date;
    v_shipper_rec.shipper_Id1 := NULL;
    v_Shipper_rec.shipper_Id2 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    v_Shipper_rec.shipper_Id4 := NULL;
    v_Shipper_rec.shipper_Id5 := NULL;
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'No shipment line, so shipment date = sched_gen_Date', v_shipment_date);
    END IF;
    --
   ELSIF (v_deliveryID is NOT NULL) THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Delivery ID present on schedule');
    END IF;
    --
    FOR v_ShpSID  IN c_ShpShipperIds LOOP
     --
     IF (c_ShpShipperIds%NOTFOUND  OR v_count > 5) THEN
       EXIT;
     END IF;
     --
     v_count := v_count + 1;
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'line_id', v_ShpSID.line_id);
       rlm_core_sv.dlog(C_DEBUG,'start_date_time', v_ShpSID.start_date_time);
       rlm_core_sv.dlog(C_DEBUG,'v_count', v_count);
       rlm_core_sv.dlog(C_DEBUG,'Shipper_id', v_ShpSID.shipper_Id);
     END IF;
     --
     IF v_count = 1 THEN
        v_shipper_rec.shipper_Id1 := v_ShpSID.shipper_Id;
     ELSIF v_count = 2  THEN
        v_shipper_rec.shipper_Id2 := v_ShpSID.shipper_Id;
     ELSIF v_count = 3  THEN
        v_shipper_rec.shipper_Id3 := v_ShpSID.shipper_Id;
     ELSIF v_count = 4  THEN
        v_shipper_rec.shipper_Id4 := v_ShpSID.shipper_Id;
     ELSIF v_count = 5  THEN
        v_shipper_rec.shipper_Id5 := v_ShpSID.shipper_Id;
     END IF;
     --
    END LOOP;
    --
   ELSIF (v_shipment_date is NOT NULL) THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'No delivery ID present on schedule');
    END IF;
    --
    v_shipper_rec.shipper_Id1 := NULL;
    v_Shipper_rec.shipper_Id2 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    v_Shipper_rec.shipper_Id3 := NULL;
    --
   END IF;
   --
   CLOSE c_LastShipment;
   --
  END IF;
  --
  FOR c_Orders_rec IN c_Orders LOOP
   --
   v_order_header_id := c_Orders_rec.header_id;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Order Header ID', v_order_header_id);
   END IF;
   --
   RLM_EXTINTERFACE_SV.getIntransitQty (
          x_Group_rec.customer_id,
          x_Group_rec.ship_to_org_id,
          x_Group_rec.intmed_ship_to_org_id, --Bugfix 5911991
          NULL,
          x_Group_rec.inventory_item_id,
	  x_Group_rec.customer_item_id,
          v_order_header_id,
 --	  NVL(x_Group_rec.blanket_number, k_NULL), --Bugfix 6594840
        k_NULL, --Bugfix 6594840
          x_Sched_rec.org_id,
	  x_Sched_rec.schedule_type,
          v_Shipper_rec,
          v_Shipment_date,
          v_match_within_rule,
	  v_match_across_rule,
	  v_match_rec,
          x_Sched_rec.header_id,
          v_InTransitQty_tmp,
          v_return_status);
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_return_status', v_return_status);
      rlm_core_sv.dlog(C_DEBUG, 'v_InTransitQty', v_InTransitQty_tmp);
    END IF;
    --
    IF v_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR THEN
     --
     rlm_core_sv.dpop(C_SDEBUG, 'GetIntransitQtyAPI Failed');
     RAISE e_group_error;
     --
    ELSIF v_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
     --
     rlm_core_sv.dpop(C_SDEBUG, 'GetIntransitQtyAPI Failed');
     RAISE e_group_error;
     --
   END IF;
   --
   v_IntransitQty := v_IntransitQty + v_IntransitQty_tmp;
   --
  END LOOP;
  --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG, v_IntransitQty);
    END IF;
   return v_IntransitQty; -- Bug 4535823
  --
--Bugfix 6265953 START
  ELSIF (UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis) IN ('SHIPPED_LINES','PART_SHIP_LINES')) THEN

      v_Group_rec := x_Group_rec;

      v_Group_rec.match_within_rec := v_match_within_rule;
      v_Group_rec.match_across_rec := v_match_across_rule;

--Purchase Order
   IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
     --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG, 'Manage Demand - CUM BY PURCHASE ORDER');
      END IF;

      IF x_group_rec.match_across_rec.cust_po_number = 'Y' THEN
         v_Group_rec.match_across_rec.cust_po_number := 'Y';
      ELSE
         v_Group_rec.match_within_rec.cust_po_number :='Y';
      END IF;
     --
     v_match_rec_shipline.cust_po_number := g_CUM_tab(g_count).purchase_order_number;  --Bugfix 7007638
   END IF;  /*Purchase Order*/

--Record Keeping Year
   IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
     --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_SDEBUG, 'Manage Demand - CUM BY RECORD YEAR');
      END IF;

      IF x_group_rec.match_across_rec.industry_attribute1 = 'Y' THEN
         v_Group_rec.match_across_rec.industry_attribute1 := 'Y';
      ELSE
         v_Group_rec.match_within_rec.industry_attribute1 :='Y';
      END IF;
     --
     v_match_rec_shipline.industry_attribute1 := g_CUM_tab(g_count).cust_record_year;  --Bugfix 7007638
   END IF;  /*Record Keeping Year*/

      SELECT TO_CHAR(TRUNC(min(il.start_date_time)), 'RRRR/MM/DD HH24:MI:SS')
      INTO v_min_horizon_date
      FROM rlm_interface_lines il,
	       rlm_schedule_lines  sl
      WHERE  il.header_id = x_Sched_rec.header_id
      AND    il.ship_from_org_id = x_Group_rec.ship_from_org_id
      AND    il.ship_to_org_id = x_Group_rec.ship_to_org_id
      AND    il.inventory_item_id = x_Group_rec.inventory_item_id
      AND    il.customer_item_id = x_Group_rec.customer_item_id
      AND    il.schedule_line_id = sl.line_id
      AND    NVL(il.item_detail_type, ' ')
			 <> rlm_manage_demand_sv.k_SHIP_RECEIPT_INFO
      AND    sl.qty_type_code    = rlm_manage_demand_sv.k_ACTUAL;


      --
      IF (v_min_horizon_date IS NOT NULL ) THEN
 	  --

	  IF (l_debug <> -1) THEN
	      rlm_core_sv.dlog(C_DEBUG, 'v_min_request_date', v_min_horizon_date);
	  END IF;
	  --
	  IF TO_DATE(v_min_horizon_date,'RRRR/MM/DD HH24:MI:SS') > x_Sched_rec.sched_horizon_start_date THEN
	    --
	    v_min_horizon_date:=  TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_start_date), 'RRRR/MM/DD HH24:MI:SS');
	    --
	  END IF;
	  --
	  IF (l_debug <> -1) THEN
	      rlm_core_sv.dlog(C_DEBUG, 'v_min_horizon_date', v_min_horizon_date);
	  END IF;

      FOR c_Orders_rec IN c_Orders LOOP

        v_Group_rec.order_header_id := c_Orders_rec.header_id;
        v_Group_rec.ship_from_org_id := NULL;

        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Order Header ID', v_Group_rec.order_header_id);
        END IF;

        RLM_EXTINTERFACE_SV.GetIntransitShippedLines(x_Sched_rec,
                                                     v_Group_rec,
                   						             v_match_rec_shipline,
                                                     v_min_horizon_date,
                                                     v_InTransitQty_tmp);
        IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'v_InTransitQty', v_InTransitQty_tmp);
        END IF;

        v_IntransitQty := v_IntransitQty + v_IntransitQty_tmp;
   --
      END LOOP;

     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG, v_IntransitQty);
     END IF;

     RETURN v_IntransitQty;

     END IF;
   END IF;
--Bugfix 6265953 END
  --
  EXCEPTION
   WHEN e_Group_error THEN
     --
     RAISE;
     --
   WHEN OTHERS THEN
      rlm_message_sv.sql_error('GetIntransitAcrossOrgs',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      RAISE;
END GetIntransitAcrossOrgs;


/*===========================================================================

        PROCEDURE NAME: GetVarK_dNull

===========================================================================*/

FUNCTION GetvarK_DNULL

RETURN DATE  IS

BEGIN

 return(RLM_MANAGE_DEMAND_SV.K_DNULL);

END GetvarK_DNULL;


END RLM_MANAGE_DEMAND_SV;

/
