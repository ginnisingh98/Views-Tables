--------------------------------------------------------
--  DDL for Package Body RLM_RD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_RD_SV" as
/*$Header: RLMDPRDB.pls 120.15.12010000.5 2009/06/26 11:06:13 sunilku ship $*/
/*===========================================================================*/
--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);

g_sch_line_qty         NUMBER := 0; --Bugfix 6131516
g_del_reconcile        VARCHAR2(1) := 'N'; --Bugfix 6131516
g_inc_exception        VARCHAR2(1) := 'N'; --Bugfix 6159269
--
/*============================================================================

PROCEDURE NAME:	RecDemand

==============================================================================*/
PROCEDURE RecDemand(x_InterfaceHeaderId IN NUMBER,
                    x_Sched_rec         IN RLM_INTERFACE_HEADERS%ROWTYPE,
                    x_Group_rec         IN  OUT NOCOPY rlm_dp_sv.t_Group_rec,
                    x_ReturnStatus      OUT NOCOPY NUMBER)
IS
  --
  v_ReGroup_ref    t_Cursor_ref;
  v_ReGroup_rec    rlm_dp_sv.t_Group_rec;
  x_progress       VARCHAR2(3) := '010';
  e_lines_locked   EXCEPTION;
  v_sf_org_id	   NUMBER;
  v_rso_start_date DATE;
  v_Processed      VARCHAR2(1) := 'N';
  --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(k_SDEBUG,'RecDemand');
      rlm_core_sv.dlog(k_DEBUG,'InterfaceHeaderId',x_Sched_rec.header_id);
   END IF;
   --
   -- We set the return status = sucess at the start
   -- if there are errors the status will become error or else will complete
   -- as success
   --
   x_ReturnStatus := rlm_core_sv.k_PROC_SUCCESS;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.headerId',x_Sched_rec.header_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_type',
                                      x_Sched_rec.schedule_type);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_purpose',
                                      x_Sched_rec.schedule_purpose);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_source',
                                      x_Sched_rec.schedule_source);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_generation_date',
                                      x_Sched_rec.sched_generation_date);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_start_date',
                                      x_Sched_rec.sched_horizon_start_date);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_end_date',
                                      x_Sched_rec.sched_horizon_end_date);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_reference_num',
                                  x_Sched_rec.schedule_reference_num);
      rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.isSourced',
                               x_Group_rec.isSourced);
      rlm_core_sv.dlog(k_DEBUG, 'g_SourceTab.COUNT', g_SourceTab.COUNT);
   END IF;
   --
   g_Reconcile_Tab.DELETE;
   -- Bug 4223359
   g_IsFirm := FALSE;
   g_IntransitTab.DELETE;
   g_Accounted_Tab.DELETE;
   g_BlktIntransits := FALSE;
   g_IntransitQty := FND_API.G_MISS_NUM;
   --
   RLM_TPA_SV.InitializeSoGroup(x_Sched_rec, v_ReGroup_ref, x_Group_rec);
   --
   WHILE FetchGroup(v_ReGroup_ref, v_ReGroup_rec) LOOP
    --{
    CallSetups(x_Sched_rec, v_ReGroup_rec);
    v_ReGroup_rec.isSourced := x_Group_rec.isSourced;
    --
    ProcessReleases(x_Sched_rec, v_ReGroup_rec, v_Processed);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'Releases Processed (Y/N)', v_Processed);
    END IF;
    --
    v_ReGroup_rec.order_header_id := NULL;
    v_ReGroup_rec.blanket_number  := NULL;
    --
    IF NVL(v_Processed, 'N') = 'N' THEN
     RecGroupDemand(x_Sched_rec, v_ReGroup_rec);
    END IF;
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'Cleaning up global tables');
    END IF;
    --
    g_Reconcile_Tab.DELETE;
    g_IntransitTab.DELETE;
    g_BlktIntransits := FALSE;
    -- Bug 4223359
    g_IsFirm := FALSE;
    --}
   END LOOP;
   --
   --x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN e_lines_locked THEN
     --
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     rlm_message_sv.app_error(
        x_ExceptionLevel => rlm_message_sv.k_error_level,
        x_MessageName => 'RLM_LOCK_NOT_OBTAINED',
        x_InterfaceHeaderId => x_Sched_rec.header_id,
        x_InterfaceLineId => NULL,
        x_ScheduleHeaderId => x_Sched_rec.schedule_header_id,
        x_ScheduleLineId => NULL,
        x_OrderHeaderId => x_Group_rec.setup_terms_rec.header_id,
        x_OrderLineId => NULL,
        --x_ErrorText => 'Lock Not Obtained',
        x_Token1 => 'SCHED_REF',
        x_value1 => x_Sched_rec.schedule_reference_num);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'lines locked already');
     END IF;
     --
  WHEN e_Group_error THEN
    --
    x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'Group error');
    END IF;
    --
  WHEN NO_DATA_FOUND THEN
   --
   x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'No data found in Interface headers for headerId',
                              x_Sched_rec.header_id);
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
  WHEN OTHERS THEN
    --
    x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
    rlm_message_sv.sql_error('rlm_rd_sv.RecDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
END RecDemand;


/*============================================================================

  PROCEDURE NAME:	RecGroupDemand

 ============================================================================*/

PROCEDURE RecGroupDemand(x_Sched_rec         IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec         IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
IS
   --
   x_progress   VARCHAR2(3) := '010';
   --
   -- JAUTOMO: pdue hierarchy
   e_MRPOnly    EXCEPTION;

   -- Bug 4351397
   CURSOR c_order_dem IS
    SELECT  header_id,
            line_id,
            ship_from_org_id,
            ship_to_org_id,
            ordered_item_id,
            inventory_item_id,
            invoice_to_org_id,
            intmed_ship_to_org_id,
            demand_bucket_type_code,
            rla_schedule_type_code,
            authorized_to_ship_flag ATS,
            ordered_quantity orig_ordered_quantity,
            NVL(ordered_quantity,0) -
            NVL(shipped_quantity,0) ordered_quantity,
            ordered_item,
            item_identifier_type,
            item_type_code,
            DECODE(x_Group_rec.setup_terms_rec.blanket_number, NULL,
                   NULL, blanket_number) blanket_number,
            customer_line_number,
            customer_production_line cust_production_line,
            customer_dock_code,
            request_date,
            schedule_ship_date,
            cust_po_number,
            item_revision customer_item_revision,
            customer_job,
            cust_model_serial_number,
            cust_production_seq_num,
            industry_attribute1,
            industry_attribute2,
            industry_attribute3,
            industry_attribute4,
            industry_attribute5,
            industry_attribute6,
            industry_attribute7,
            industry_attribute8,
            industry_attribute9,
            industry_attribute10,
            industry_attribute11,
            industry_attribute12,
            industry_attribute13,
            industry_attribute14,
            industry_attribute15,
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
            request_date +
                  DECODE(demand_bucket_type_code,
                         k_WEEKLY,6.99999,
                         k_MONTHLY,29.99999,
                         k_QUARTERLY,89.99999,0.99999) end_date_time,
            DECODE(rla_schedule_type_code,
                   x_Group_rec.schedule_type_one, 1,
                   x_Group_rec.schedule_type_two, 2,
                   x_Group_rec.schedule_type_three, 3) schedule_hierarchy
    FROM    oe_order_lines_all
    WHERE   header_id = x_Group_rec.order_header_id
    AND     open_flag = 'Y'
    AND     ship_from_org_id = DECODE(g_ATP, k_ATP, ship_from_org_id, x_Group_rec.ship_from_org_id)
    AND     ship_to_org_id = x_Group_rec.ship_to_org_id
    AND     ordered_item_id = x_Group_rec.customer_item_id
    AND     inventory_item_id = x_Group_rec.inventory_item_id
    AND     NVL(intmed_ship_to_org_id,k_NNULL) = NVL(x_Group_rec.intmed_ship_to_org_id,k_NNULL) --Bugfix 5911991
    AND     NVL(industry_attribute15, k_VNULL) =
            DECODE(g_ATP, k_ATP, NVL(industry_attribute15, k_VNULL),
            NVL(x_Group_rec.industry_attribute15, k_VNULL))
    AND     to_date(industry_attribute2,'RRRR/MM/DD HH24:MI:SS')  BETWEEN
            DECODE(authorized_to_ship_flag,k_ATS,
            DECODE(x_group_rec.disposition_code,
                   k_REMAIN_ON_FILE,x_Sched_rec.sched_horizon_start_date,
                   k_REMAIN_ON_FILE_RECONCILE, to_date(industry_attribute2,'RRRR/MM/DD HH24:MI:SS'),
                   TRUNC(SYSDATE) - nvl(x_Group_rec.Cutoff_days,0)),
                   TRUNC(SYSDATE))
            AND TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999
    AND     DECODE(rla_schedule_type_code,
                   x_Group_rec.schedule_type_one, 1,
                   x_Group_rec.schedule_type_two, 2,
                   x_Group_rec.schedule_type_three, 3,0)  >
            DECODE(x_Sched_rec.schedule_type, x_Group_rec.schedule_type_one, 1,
                   x_Group_rec.schedule_type_two, 2,
                   x_Group_rec.schedule_type_three, 3)
    AND     (NVL(ordered_quantity,0) - NVL(shipped_quantity,0) > 0)
    ORDER BY request_date DESC;
    --
BEGIN
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG, 'RecGroupDemand');
    rlm_core_sv.dlog(k_DEBUG, 'x_Group_rec.isSourced', x_Group_rec.isSourced);
    rlm_core_sv.dlog(k_DEBUG, 'x_Sched_rec.schedule_purpose',
                               x_Sched_rec.schedule_purpose);
   END IF;
   --
   g_Op_tab.DELETE;
   --global_atp
   g_Op_tab_Unschedule.DELETE;
   --Bugfix 5620035 Initialize to null
   g_order_rec :=NULL;
   --
   /* These are now part of RecDemand */
   --g_Reconcile_tab.DELETE;
   --g_IntransitTab.DELETE;
   --CallSetups(x_Sched_rec, x_Group_rec);
   --
   -- JAUTOMO: pdue hierarchy
   IF MRPOnly(x_Sched_rec, x_Group_rec) THEN
      RAISE e_MRPOnly;
   END IF;
   --
   IF x_Group_rec.order_header_id IS NULL THEN
     x_group_rec.order_header_id := x_Group_rec.setup_terms_rec.header_id;
   END IF;
   --
   IF x_Group_rec.blanket_number IS NULL THEN
    x_Group_rec.blanket_number := x_Group_rec.setup_terms_rec.blanket_number;
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'Intransit calc basis', x_Group_Rec.setup_terms_Rec.intransit_calc_basis);
      rlm_core_sv.dlog(k_DEBUG, 'Order Header Id', x_Group_rec.order_header_id);      rlm_core_sv.dlog(k_DEBUG, 'Blanket Number', x_Group_rec.blanket_number);
   END IF;
   --
   --global_atp
   IF RLM_MANAGE_DEMAND_SV.IsATPItem(x_group_rec.ship_from_org_id,x_group_rec.inventory_item_id) THEN
      g_ATP := k_ATP;
   ELSE
      g_ATP := k_NON_ATP;
   END IF;
   --
   IF x_Sched_rec.schedule_purpose IN (k_REPLACE, k_REPLACE_ALL, k_ORIGINAL,K_CHANGE) THEN
     --
     CancelPreHorizonNATS(x_Sched_rec, x_Group_rec);
     RLM_TPA_SV.SynchronizeShipments(x_Sched_rec, x_Group_rec);
     RLM_TPA_SV.ProcessPreHorizonATS(x_Sched_rec, x_Group_rec);
     RLM_TPA_SV.ProcessOld(x_Sched_rec, x_Group_rec);
     --
   END IF;
   --
   IF x_Sched_rec.schedule_purpose = k_ADD THEN
     --
     RLM_TPA_SV.ProcessOld(x_Sched_rec, x_Group_rec);
     --
   END IF;
   --
   -- Bug 4351397 : Start
   -- Here, we consider the existing demands populated by higher precedence schedules
   -- and get the most recent request date. When the incoming schedule has a lower
   -- precedence, the new requirements falling on/prior to this most recent request
   -- date will not be inserted. See InsertRequirement().
   --
   OPEN c_order_dem;
   --
   FETCH c_order_dem INTO g_order_rec ;
   --
   IF c_order_dem%FOUND THEN
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'--- Most recent existing demand populated by higher precedence schedule ---' );
          rlm_core_sv.dlog(k_DEBUG,'g_order_rec.request_date', g_order_rec.request_date);
          rlm_core_sv.dlog(k_DEBUG,'g_order_rec.line_id', g_order_rec.line_id);
          rlm_core_sv.dlog(k_DEBUG,'g_order_rec.rla_schedule_type_code', g_order_rec.rla_schedule_type_code);
          rlm_core_sv.dlog(k_DEBUG,'g_order_rec.industry_attribute3', g_order_rec.industry_attribute3);
          rlm_core_sv.dlog(k_DEBUG,'g_order_rec.schedule_hierarchy', g_order_rec.schedule_hierarchy);
          rlm_core_sv.dlog(k_DEBUG,'g_order_rec.ordered_item_id', g_order_rec.ordered_item_id);
          rlm_core_sv.dlog(k_DEBUG,'g_order_rec.inventory_item_id', g_order_rec.inventory_item_id);
      END IF;
      --
   END IF;
   --
   CLOSE c_order_dem ;
   --
   -- Bug 4351397 : End
   --
   -- the following order of ATS and then NATS is used reg.bug1548628
   --
   RLM_TPA_SV.ProcessATS(x_Sched_rec, x_Group_rec);
   --
   --Start of bug fix 4223359
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'g_max_rso_hdr_id',g_max_rso_hdr_id);
     rlm_core_sv.dlog(k_DEBUG, 'x_group_rec.blanket_number',x_group_rec.blanket_number);
     rlm_core_sv.dlog(k_DEBUG, 'g_isFirm',g_isFirm);
   END IF;
   --
   IF NOT g_isFirm AND x_group_rec.blanket_number is NOT NULL
       AND x_group_rec.order_header_id = g_max_rso_hdr_id THEN
     --
     FrozenFenceWarning(x_Sched_rec, x_Group_rec);
     --
   END IF;
     --
   IF NOT g_isFirm AND x_group_rec.blanket_number is NULL THEN
     --
     FrozenFenceWarning(x_Sched_rec, x_Group_rec);
     --
   END IF;
   --
   --End of bug fix 4223359
   --
   RLM_TPA_SV.ProcessNATS(x_Sched_rec, x_Group_rec);
   --
   ExecOperations(x_Sched_rec, x_Group_rec);
   --
   -- Bug 2261743
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.COUNT', g_Reconcile_tab.COUNT);
      rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.FIRST', g_Reconcile_tab.FIRST);
      rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.LAST', g_Reconcile_tab.LAST);
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
 EXCEPTION
   --
   WHEN e_MRPOnly THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'MRP Requirements only. There is no need to reconcile against Sales Order');
        rlm_core_sv.dpop(k_SDEBUG);
     END IF;

   WHEN e_group_error THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'group error');
        rlm_core_sv.dpop(k_SDEBUG);
     END IF;
     --
     raise e_group_error;
     --
   WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_rd_sv.RecGroupDemand',x_progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG);
     END IF;
     --
     RAISE;
     --
END RecGroupDemand;

/*===========================================================================

  PROCEDURE CallSetups

===========================================================================*/
PROCEDURE CallSetups(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
IS
  --
  v_SetupTerms_rec    rlm_setup_terms_sv.setup_terms_rec_typ;
  v_TermsLevel        VARCHAR2(30) := NULL;
  v_ReturnStatus      BOOLEAN;
  v_ReturnMsg         VARCHAR2(3000);
  e_SetupAPIFailed   EXCEPTION;
  x_progress          VARCHAR2(3) := '010';
  v_InterfaceLineId	NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'CallSetups');
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id',x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_id',x_Group_rec.customer_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_address_id',x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id',x_Group_rec.customer_item_id);
  END IF;
  --
  -- NOTE: call rla setups to populate setup info in the group rec:
  -- schedule precedence, match within/across strings, firm disposition code
  --   offset days, order header id
  --
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
     rlm_core_sv.dlog(k_DEBUG, 'v_TermsLevel', v_TermsLevel);
     rlm_core_sv.dlog(k_DEBUG, 'v_ReturnStatus', v_ReturnStatus);
     rlm_core_sv.dlog(k_DEBUG,'v_SetupTerms_rec.schedule_hierarchy_code',
                   v_SetupTerms_rec.schedule_hierarchy_code);
     rlm_core_sv.dlog(k_DEBUG,'v_SetupTerms_rec.header_id',
                   v_SetupTerms_rec.header_id);
     rlm_core_sv.dlog(k_DEBUG,'v_SetupTerms_rec.demand_tolerance_above',
                   v_SetupTerms_rec.demand_tolerance_above);
     rlm_core_sv.dlog(k_DEBUG,'v_SetupTerms_rec.demand_tolerance_below',
                   v_SetupTerms_rec.demand_tolerance_below);
  END IF;
  --
  IF NOT v_ReturnStatus THEN
     --
     RAISE e_SetupAPIFailed;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'setups failed');
     END IF;
     --
  ELSE
     --
     x_Group_rec.match_within := v_SetupTerms_rec.match_within_key;
     --
     x_Group_rec.match_across := v_SetupTerms_rec.match_across_key;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.match_within',
                      x_Group_rec.match_within);
     END IF;
     --
     rlm_core_sv.populate_match_keys(x_Group_rec.match_within_rec,
                                     x_Group_rec.match_within);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.match_across',
                      x_Group_rec.match_across);
     END IF;
     --
     rlm_core_sv.populate_match_keys(x_Group_rec.match_across_rec,
                                     x_Group_rec.match_across);
     --
     IF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,1,3) = 'PLN' THEN
       --
       x_Group_rec.schedule_type_one := k_PLANNING;
       --
     ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,1,3) = 'SHP' THEN
       --
       x_Group_rec.schedule_type_one := k_SHIPPING;
       --
     ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,1,3) = 'SEQ' THEN
       --
       x_Group_rec.schedule_type_one := k_SEQUENCED;
       --
     ELSE
       --
       x_Group_rec.schedule_type_one := NULL;
       --
     END IF;
     --
     IF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,5,3) = 'PLN' THEN
       --
       x_Group_rec.schedule_type_two := k_PLANNING;
       --
     ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,5,3) = 'SHP' THEN
       --
       x_Group_rec.schedule_type_two := k_SHIPPING;
       --
     ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,5,3) = 'SEQ' THEN
       --
       x_Group_rec.schedule_type_two := k_SEQUENCED;
       --
     ELSE
       --
       x_Group_rec.schedule_type_two := NULL;
       --
     END IF;
     --
     IF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,9,3) = 'PLN' THEN
       --
       x_Group_rec.schedule_type_three := k_PLANNING;
       --
     ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,9,3) = 'SHP' THEN
       --
       x_Group_rec.schedule_type_three := k_SHIPPING;
       --
     ELSIF SUBSTR(v_SetupTerms_rec.schedule_hierarchy_code,9,3) = 'SEQ' THEN
       --
       x_Group_rec.schedule_type_three := k_SEQUENCED;
       --
     ELSE
       --
       x_Group_rec.schedule_type_three := NULL;
       --
     END IF;
     --
     x_Group_rec.disposition_code := v_SetupTerms_rec.unshipped_firm_disp_cd;
     --
     x_Group_rec.cutoff_days := v_SetupTerms_rec.unship_firm_cutoff_days;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.disposition_code',
                      x_Group_rec.disposition_code);
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.cutoff_days',
                      	x_Group_rec.cutoff_days);
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.schedule_type_one',
		  	   x_Group_rec.schedule_type_one);
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.schedule_type_two',
                      x_Group_rec.schedule_type_two);
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.schedule_type_three',
                      x_Group_rec.schedule_type_three);
     END IF;
     --
     IF x_Sched_rec.Schedule_type = k_PLANNING THEN
        --
        IF v_SetupTerms_rec.pln_frozen_day_from IS NOT NULL THEN
           --
           x_Group_rec.frozen_days := nvl(v_SetupTerms_rec.pln_frozen_day_to,0)
				     - nvl(v_SetupTerms_rec.pln_frozen_day_from,0) + 1;
           --
           x_Group_rec.roll_forward_frozen_flag:=v_SetupTerms_rec.pln_frozen_flag;
           --
        ELSE
           --
           x_Group_rec.frozen_days := 0;
           --
           x_Group_rec.roll_forward_frozen_flag:='N';
           --
        END IF;
        --
     ELSIF x_Sched_rec.Schedule_type = k_SHIPPING THEN
        --
        IF v_SetupTerms_rec.shp_frozen_day_from IS NOT NULL THEN
           --
           x_Group_rec.frozen_days := nvl(v_SetupTerms_rec.shp_frozen_day_to,0)
                          - nvl(v_SetupTerms_rec.shp_frozen_day_from,0) + 1;

           x_Group_rec.roll_forward_frozen_flag:=v_SetupTerms_rec.shp_frozen_flag;
           --
        ELSE
           --
           x_Group_rec.frozen_days := 0;
           --
           x_Group_rec.roll_forward_frozen_flag:='N';
           --
        END IF;
        --
     ELSIF x_Sched_rec.Schedule_type = k_SEQUENCED THEN
        --
        IF v_SetupTerms_rec.seq_frozen_day_from IS NOT NULL THEN
           --
           x_Group_rec.frozen_days := nvl(v_SetupTerms_rec.seq_frozen_day_to,0)
                                      - nvl(v_SetupTerms_rec.seq_frozen_day_from,0) + 1;
           --
           x_Group_rec.roll_forward_frozen_flag:=v_SetupTerms_rec.seq_frozen_flag;
           --
        ELSE
           --
           x_Group_rec.frozen_days := 0;
           x_Group_rec.roll_forward_frozen_flag:='N';
           --
        END IF;
        --
     END IF;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.frozen_days',
                                         x_Group_rec.frozen_days );
        rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.roll_forward_frozen_flag',
                                         x_Group_rec.roll_forward_frozen_flag);
     END IF;
     --
     -- Need to change the group rec to remove the cutoff days and the
     -- match_within and accross keys.
     --
     x_Group_rec.setup_terms_rec := v_SetupTerms_rec;
     --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
 --
 WHEN e_SetupAPIFailed THEN
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
           --x_ErrorText => 'Setup API failed',
           x_Token1 => 'ERROR',
           x_value1 => v_ReturnMsg);
   --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_SDEBUG,'SetupAPI failed');
      rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
   END IF;
   --
   raise e_group_error;
   --
 WHEN OTHERS THEN
  --
  rlm_message_sv.sql_error('rlm_rd_sv.CallSetups',x_progress);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
  END IF;
  --
  raise;
  --
END CallSetups;


/*===========================================================================

  PROCEDURE ExecOperations

===========================================================================*/
PROCEDURE ExecOperations(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS

  --
  x_progress          VARCHAR2(3) := '010';
  v_ReturnStatus  VARCHAR2(30);
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ExecOperations');
  END IF;
  --
  --global_atp
  -- Need to call ProcessConstraint for g_Op_Tab_Unschedule before doing for
  -- g_Op_Tab
  rlm_extinterface_sv.ProcessOperation(g_Op_Tab_Unschedule,x_Sched_rec.header_id,v_ReturnStatus);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'After calling Process Order API (Unscheduling)');
     rlm_core_sv.dlog(k_DEBUG, 'v_ReturnStatus', v_ReturnStatus);
  END IF;
  --
  IF v_ReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG, 'Process Order API (Unscheduling) Failed');
      END IF;
      --
      RAISE e_group_error;
      --
  ELSIF v_ReturnStatus = FND_API.G_RET_STS_ERROR THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG, 'Process Order API (Unscheduling) Failed');
      END IF;
      --
      RAISE e_group_error;
      --
  END IF;
  --
  -- Proceed with Process Order API (Scheduling)

  rlm_extinterface_sv.ProcessOperation(g_Op_Tab,x_Sched_rec.header_id,v_ReturnStatus);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'After calling Process Order API (Scheduling)');
     rlm_core_sv.dlog(k_DEBUG, 'v_ReturnStatus', v_ReturnStatus);
  END IF;
  --
  IF v_ReturnStatus = FND_API.G_RET_STS_UNEXP_ERROR THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG, 'Process Order API Failed');
      END IF;
      --
      RAISE e_group_error;
      --
  ELSIF v_ReturnStatus = FND_API.G_RET_STS_ERROR THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG, 'Process Order API Failed');
      END IF;
      --
      RAISE e_group_error;
      --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'Process Order API Suceess');
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
 WHEN e_group_error THEN
    --
    raise;
    --
 WHEN OTHERS THEN
   rlm_message_sv.sql_error('rlm_rd_sv.ExecOperations', x_progress);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
   END IF;
   --
   raise;

END ExecOperations;


/*===========================================================================

  PROCEDURE CancelPreHorizonNATS

===========================================================================*/
PROCEDURE CancelPreHorizonNATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS

  CURSOR c_PreHorizonNATS IS
    SELECT line_id
    FROM   oe_order_lines
    WHERE  header_id = x_Group_rec.order_header_id
    --global_atp
    AND    ship_from_org_id =
           DECODE(g_ATP, k_ATP, ship_from_org_id,
           x_Group_rec.ship_from_org_id)
    AND    ship_to_org_id = x_Group_rec.ship_to_org_id
    AND    ordered_item_id = x_Group_rec.customer_item_id
    AND    inventory_item_id= x_Group_rec.inventory_item_id
    --global_atp
    AND     NVL(industry_attribute15, k_VNULL) =
            DECODE(g_ATP, k_ATP, NVL(industry_attribute15, k_VNULL),
            NVL(x_Group_rec.industry_attribute15, k_VNULL))
--bug 2181228
    /*AND    NVL(cust_production_seq_num, k_NNULL) =
           NVL(x_Group_rec.cust_production_seq_num, k_NNULL)*/
    --
    --AND    request_date         < x_Sched_rec.sched_horizon_start_date --chg
    AND     to_date(industry_attribute2,'RRRR/MM/DD HH24:MI:SS')
            < TRUNC(SYSDATE)
    --pdue
    --      < x_Sched_rec.sched_horizon_start_date
    AND    authorized_to_ship_flag = k_NATS
    AND    nvl(ordered_quantity,0 ) - nvl(shipped_quantity,0) > 0;

  v_Key_rec     t_Key_rec;
  v_DeleteQty   NUMBER;

  x_progress          VARCHAR2(3) := '010';

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(k_SDEBUG,'CancelPreHorizonNATS');
      rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id',
                             x_Group_rec.order_header_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id',
                             x_Group_rec.ship_from_org_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_org_id',
                             x_Group_rec.ship_to_org_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id',
                             x_Group_rec.customer_item_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id',
                             x_Group_rec.inventory_item_id);
      rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_start_date',
		             x_Sched_rec.sched_horizon_start_date);
   END IF;
   --
   FOR c_PreHorizonNATS_rec IN c_PreHorizonNATS LOOP
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'c_PreHorizonNATS_rec.line_id',
                             c_PreHorizonNATS_rec.line_id);
     END IF;
     --
     v_Key_rec.oe_line_id := c_PreHorizonNATS_rec.line_id;
     --
     GetDemand(v_Key_rec, x_Group_rec);
     --
     v_Key_rec.req_rec := v_Key_rec.dem_rec;
     --
     DeleteRequirement(x_Sched_rec, x_Group_rec,
                       v_Key_rec, k_NORECONCILE, v_DeleteQty);
     --
   END LOOP;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN e_group_error THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'group error');
        rlm_core_sv.dpop(k_SDEBUG);
     END IF;
     --
     raise e_group_error;

   WHEN OTHERS THEN
     rlm_message_sv.sql_error('rlm_rd_sv.CancelPreHorizonNATS',x_progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;

END CancelPreHorizonNATS;


/*===========================================================================

  FUNCTION ProcessConstraint

===========================================================================*/
FUNCTION ProcessConstraint(x_Key_rec IN RLM_RD_SV.t_Key_rec,
                           x_Qty_rec OUT NOCOPY t_Qty_rec,
                           x_Operation IN VARCHAR2,
                           x_OperationQty IN NUMBER := 0)
RETURN BOOLEAN
IS
  b_Result  BOOLEAN := FALSE;
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ProcessConstraint');
     rlm_core_sv.dlog(k_DEBUG,'x_Operation',x_Operation);
     rlm_core_sv.dlog(k_DEBUG,'x_OperationQty',x_OperationQty);
  END IF;
  --
  IF x_Operation = k_UPDATE_ATTR THEN
     --
     b_Result := rlm_extinterface_sv.CallProcessConstraintAPI(x_key_rec,
                                  x_Qty_rec,
                                  'UPDATE',
                                  x_OperationQty);
     --
  ELSE
     --
     b_Result := rlm_extinterface_sv.CallProcessConstraintAPI(x_key_rec,
                                  x_Qty_rec,
                                  x_Operation,
                                  x_OperationQty);
     --
  END IF;
  --
  IF x_Operation = k_DELETE THEN
    IF b_Result THEN
      x_Qty_rec.reconcile := x_Key_rec.dem_rec.ordered_quantity;
      -- ASH : Temp fix till process constraint returns the quantity
      x_Qty_rec.available_to_cancel := 0;
    ELSE
      -- ASH : Temp fix till process constraint returns the quantity
      x_Qty_rec.reconcile := 0;
      x_Qty_rec.ordered := x_Key_rec.dem_rec.ordered_quantity;
      x_Qty_rec.available_to_cancel := 0;
    END IF;
  ELSIF x_Operation = k_INSERT THEN
    NULL;
  ELSIF x_Operation = k_UPDATE THEN
    IF b_Result THEN
      x_Qty_rec.reconcile := x_Key_rec.req_rec.ordered_quantity
                                -  x_Key_rec.dem_rec.ordered_quantity;
      -- ASH :Temp fix till process constraint returns the quantity
      x_Qty_rec.available_to_cancel := 0;
    ELSE
      -- ASH : Temp fix till process constraint returns the quantity
      x_Qty_rec.reconcile := 0;
      x_Qty_rec.ordered := x_Key_rec.dem_rec.ordered_quantity;
      x_Qty_rec.available_to_cancel := 0;
    END IF;
  ELSIF x_Operation = k_UPDATE_ATTR THEN
    NULL;
  END IF;

  IF b_Result THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'true');
    END IF;
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
  END IF;
  --
  RETURN(b_Result);
  --
EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.ProcessConstraint',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END ProcessConstraint;

/*===========================================================================

  FUNCTION FetchGroup

===========================================================================*/
FUNCTION FetchGroup(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                    x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN
IS

  x_progress          VARCHAR2(3) := '010';
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'FetchGroup');
  END IF;
  --
  FETCH x_Group_ref INTO
    x_Group_rec.customer_id,
    x_Group_rec.ship_from_org_id,
    x_Group_rec.ship_to_address_id,
    x_Group_rec.ship_to_org_id,
    x_Group_rec.customer_item_id,
    x_Group_rec.inventory_item_id,
    x_Group_rec.industry_attribute15,
    x_Group_rec.intrmd_ship_to_id,       --Bugfix 5911991
    x_Group_rec.intmed_ship_to_org_id ;  --Bugfix 5911991
    --x_Group_rec.order_header_id,
    --x_Group_rec.blanket_number;
    --x_Group_rec.cust_production_seq_num;
  --
  IF x_Group_ref%NOTFOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
    RETURN(FALSE);
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'true');
    END IF;
    --
    RETURN(TRUE);
    --
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.FetchGroup',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END FetchGroup;

/*===========================================================================

  FUNCTION NAME:    RemainOnFile

===========================================================================*/

FUNCTION RemainOnFile(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                      x_Key_rec   IN RLM_RD_SV.t_Key_rec)
RETURN BOOLEAN
IS
  v_Progress VARCHAR2(3) := '010';
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG,'RemainOnFile');
  END IF;
  --
  IF (TO_DATE(x_key_rec.dem_rec.industry_attribute2,'RRRR/MM/DD HH24:MI:SS') < TRUNC(SYSDATE)) AND x_key_rec.dem_rec.authorized_to_ship_flag = 'Y' THEN
    --
    IF x_group_rec.disposition_code = k_REMAIN_ON_FILE THEN
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'Remain on File');
        rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
      END IF;
      RETURN TRUE;
      --
    ELSIF x_group_rec.disposition_code = k_CANCEL_AFTER_N_DAYS THEN
      --
      IF TO_DATE(x_key_rec.dem_rec.industry_attribute2,'RRRR/MM/DD HH24:MI:SS') >= (TRUNC(SYSDATE) - NVL(x_group_rec.cutoff_days,0)) THEN
        --
        IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'Between cutoff and sysdate');
          rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
        END IF;
        RETURN TRUE;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
  END IF;
  --
  RETURN FALSE;
  --
EXCEPTION

  WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('RLM_RD_SV.RemainOnFile', v_Progress);
     IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     RAISE;

END RemainOnFile;

/*===========================================================================

  PROCEDURE DeleteRequirement

===========================================================================*/
PROCEDURE DeleteRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                            x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                            x_Reconcile IN BOOLEAN,
                            x_DeleteQty OUT NOCOPY NUMBER)
IS

  v_Qty_rec        t_Qty_rec;
  x_progress       VARCHAR2(3) := '010';
  -- For Shipping API
  v_changed_attributes WSH_SHIPPING_CONSTRAINTS_PKG.ChangedAttributeRecType;
  v_return_status VARCHAR2(4);
  v_action_allowed VARCHAR2(2);
  v_action_message VARCHAR2(30);
  v_ord_qty_allowed NUMBER := 0;
  v_source_code VARCHAR2(3) := 'OE';
  --v_log_level NUMBER := 0;
  v_MatchAttrTxt        VARCHAR2(2000); -- Bug 4297984
  v_del_line_qty NUMBER :=0;  --Bugfix 6159269

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'DeleteRequirement');
     rlm_core_sv.dlog(k_DEBUG,'x_Reconcile',x_Reconcile);
     rlm_core_sv.dlog(k_DEBUG,'g_del_reconcile',g_del_reconcile);  --Bugfix 6131516
  END IF;
  --
  /*passing the header_id so it can create proper error message if
    process order api fails*/

  x_key_rec.dem_rec.header_id := x_Sched_rec.header_id;
  x_key_rec.dem_rec.schedule_header_id := x_Sched_rec.schedule_header_id;
  x_key_rec.req_rec.header_id :=  x_Sched_rec.header_id;
  x_key_rec.req_rec.schedule_header_id :=  x_Sched_rec.schedule_header_id;

  --pdue
  IF x_Sched_rec.schedule_source <> 'MANUAL' AND
        IsFrozen(TRUNC(SYSDATE),
              x_Group_rec, x_key_rec.dem_rec.request_date) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'Line cannot be deleted-- within frozen fence',
                              x_key_rec.dem_rec.line_id);
       rlm_core_sv.dlog(k_DEBUG,'dem_rec.request_date',
                              x_key_rec.dem_rec.request_date);
    END IF;
    --
    IF x_Reconcile THEN
       --
       StoreReconcile(x_Sched_rec, x_Group_rec, x_Key_rec,
                      x_key_rec.dem_rec.ordered_quantity);/*2263253*/
       --
    END IF;
    --
    -- Bug 4297984 Start
    GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.dem_rec,v_MatchAttrTxt);
    --
 IF x_Key_rec.dem_rec.ordered_quantity <> g_sch_line_qty THEN        --Bugfix 6159269

    IF (x_Key_rec.dem_rec.schedule_type = 'SEQUENCED') THEN
       --
       rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_warn_level,
           x_MessageName => 'RLM_FROZEN_DELETE_SEQ',
           x_InterfaceHeaderId => x_sched_rec.header_id,
           x_InterfaceLineId => NULL,
           x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
           x_OrderLineId => x_key_rec.dem_rec.line_id,
           x_Token1 => 'LINE',
           x_value1 => rlm_core_sv.get_order_line_number(x_Key_rec.dem_rec.line_id),
           x_Token2 => 'ORDER',
           x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
           x_Token3 => 'QUANTITY',
           x_value3 => x_Key_rec.dem_rec.ordered_quantity,
           x_Token4 => 'CUSTITEM',
           x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
           x_Token5 => 'REQ_DATE',
           x_value5 => x_key_rec.dem_rec.request_date,
           x_Token6 => 'SCH_LINE_QTY',          --Bugfix 6159269
           x_value6 => v_del_line_qty,          --Bugfix 6159269
           x_Token7 => 'SEQ_INFO',
           x_value7 => nvl(x_Key_rec.dem_rec.cust_production_seq_num,'NULL')||'-'||
                       nvl(x_Key_rec.dem_rec.cust_model_serial_number,'NULL')||'-'||
                       nvl(x_Key_rec.dem_rec.customer_job,'NULL'),
           x_Token8 => 'MATCH_ATTR',
           x_value8 => v_MatchAttrTxt );
       --
       IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_DELETE_SEQ',x_key_rec.dem_rec.line_id);
       END IF;
       --
    ELSE
       --
       rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_warn_level,
           x_MessageName => 'RLM_FROZEN_DELETE',
           x_InterfaceHeaderId => x_sched_rec.header_id,
           x_InterfaceLineId => NULL,
           x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
           x_OrderLineId => x_key_rec.dem_rec.line_id,
           x_Token1 => 'LINE',
           x_value1 => rlm_core_sv.get_order_line_number(x_Key_rec.dem_rec.line_id),
           x_Token2 => 'ORDER',
           x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
           x_Token3 => 'QUANTITY',
           x_value3 => x_Key_rec.dem_rec.ordered_quantity,
           x_Token4 => 'CUSTITEM',
           x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
           x_Token5 => 'REQ_DATE',
           x_value5 => x_key_rec.dem_rec.request_date,
           x_Token6 => 'SCH_LINE_QTY',               --Bugfix 6159269
           x_value6 => v_del_line_qty,               --Bugfix 6159269
           x_Token7 => 'MATCH_ATTR',
           x_value7 => v_MatchAttrTxt);
       --
       IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_DELETE',x_key_rec.dem_rec.line_id);
       END IF;
       --
    END IF;

  END IF; --Bugfix 6159269
    -- Bug 4297984 End
  ELSIF ProcessConstraint(x_Key_rec, v_Qty_rec, k_DELETE) THEN
    --
    --CancelRequirement(x_Sched_rec, x_Group_rec,
                      --x_Key_rec, v_Qty_rec.available_to_cancel);
    IF x_Reconcile THEN
      StoreReconcile(x_Sched_rec, x_Group_rec, x_Key_rec,
                     v_Qty_rec.reconcile);
    END IF;
    --x_DeleteQty := v_Qty_rec.available_to_cancel;
    --rlm_core_sv.dlog(k_DEBUG,'x_DeleteQty',x_DeleteQty);
    --
  ELSE
     --
     -- Call to check if Shipping allows delete
     -- Use 'D' for delete, 'U' for update, and 'C' for cancel
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_key_rec.dem_rec.line_id',x_key_rec.dem_rec.line_id);
        rlm_core_sv.dlog(k_DEBUG,'x_key_rec.oe_line_id',x_key_rec.oe_line_id);
     END IF;
     --
     v_changed_attributes.action_flag    := 'D';
     v_changed_attributes.source_line_id := nvl(x_Key_rec.oe_line_id, x_key_rec.dem_rec.line_id);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'source_line_id',v_changed_attributes.source_line_id);
     END IF;
     --
     RLM_EXTINTERFACE_SV.CheckShippingConstraints(
        x_source_code        => v_source_code,
        x_changed_attributes => v_changed_attributes,
        x_return_status      => v_return_status,
        x_action_allowed     => v_action_allowed,
        x_action_message     => v_action_message,
        x_ord_qty_allowed    => v_ord_qty_allowed,
        x_header_id          => x_Sched_rec.header_id,
        x_order_header_id    => x_group_rec.setup_terms_rec.header_id);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'v_action_allowed',v_action_allowed);
        rlm_core_sv.dlog(k_DEBUG,'v_return_status',v_return_status);
     END IF;
     --
     IF v_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG, 'CheckShippingConstraintsAPI Failed. Unexpected Error');
       END IF;
       --
       RAISE e_group_error;
       --
     ELSIF v_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG, 'CheckShippingConstraintsAPI Failed.');
       END IF;
       --
       RAISE e_group_error;
       --
     END IF;
     --
     IF (v_action_allowed = 'N') THEN

       -- bug 5199318
       IF ProcessConstraint(x_Key_rec, v_Qty_rec, k_UPDATE, 0) THEN
       --{
           --

           IF x_Reconcile THEN
             StoreReconcile(x_Sched_rec, x_Group_rec, x_Key_rec, x_key_rec.dem_rec.ordered_quantity);
           END IF;

           --
       --}
       ELSE
       --{
           --
           -- Call again to see if Shipping allows Cancel
           -- Use 'D' for delete, 'U' for update, and 'C' for cancel
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'oe_line_id',x_Key_rec.oe_line_id);
              rlm_core_sv.dlog(k_DEBUG,'oe_line_id',x_Key_rec.dem_rec.line_id);
           END IF;
           --
           v_changed_attributes.action_flag    := 'C';
           v_changed_attributes.source_line_id := nvl(x_Key_rec.oe_line_id,
                                                x_key_rec.dem_rec.line_id);
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'source_line_id',v_changed_attributes.source_line_id);
           END IF;
           --
           RLM_EXTINTERFACE_SV.CheckShippingConstraints(
              x_source_code        => v_source_code,
              x_changed_attributes => v_changed_attributes,
              x_return_status      => v_return_status,
              x_action_allowed     => v_action_allowed,
              x_action_message     => v_action_message,
              x_ord_qty_allowed    => v_ord_qty_allowed,
              x_header_id          => x_Sched_rec.header_id,
              x_order_header_id    => x_group_rec.setup_terms_rec.header_id);
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'v_action_allowed',v_action_allowed);
              rlm_core_sv.dlog(k_DEBUG,'v_return_status',v_return_status);
           END IF;
           --
           IF v_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dpop(k_SDEBUG, 'CheckShippingConstraintsAPI Failed');
             END IF;
             --
             RAISE e_group_error;
             --
           ELSIF v_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dpop(k_SDEBUG, 'CheckShippingConstraintsAPI Failed.');
             END IF;
             --
             RAISE e_group_error;
             --
           END IF;
           --
           IF (v_action_allowed = 'N') THEN
             --
             IF x_Reconcile THEN
               StoreReconcile(x_Sched_rec, x_Group_rec, x_Key_rec,
                              v_Qty_rec.reconcile);
             END IF;
             --
           ELSE
             --
             IF NOT RemainOnFile(x_group_rec, x_key_rec) THEN
               --
               x_DeleteQty := 0;
               SetOperation(x_Key_rec, k_UPDATE, x_DeleteQty);
               --
               IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(k_DEBUG,'x_DeleteQty',x_DeleteQty);
               END IF;
               --
             END IF;
             --
           END IF;
       --}
       END IF; -- bug 5199318
       --
     ELSE
       --
       IF NOT RemainOnFile(x_group_rec, x_key_rec) THEN
         --
         SetOperation(x_Key_rec, k_DELETE);
         x_DeleteQty := v_Qty_rec.ordered;
         --
         --Bugfix 6131516 Start
         IF g_sch_line_qty >0  AND g_del_reconcile = 'Y' THEN
            GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.req_rec,v_MatchAttrTxt);
           IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN
            --
            rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_RECONCILE_DELETE_SEQ',
                x_InterfaceHeaderId => x_sched_rec.header_id,
                x_InterfaceLineId => x_key_rec.req_rec.line_id,
                x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                x_OrderLineId => NULL,
   	        x_Token1 => 'QUANTITY',
                x_value1 => g_sch_line_qty,
   	        x_Token2 => 'GROUP',
                x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                            rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                            rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
	        x_Token3 => 'REQ_DATE',
                x_value3 => x_key_rec.req_rec.request_date,
  	        x_Token4 => 'START_DATE_TIME',
                x_value4 => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
                x_Token5 => 'SEQ_INFO',
                x_value5 => nvl(x_Key_rec.req_rec.cust_production_seq_num,'NULL') ||'-'||
	                    nvl(x_Key_rec.req_rec.cust_model_serial_number,'NULL')||'-'||
            	            nvl(x_Key_rec.req_rec.customer_job,'NULL'),
                x_Token6 => 'ORDER',
                x_value6 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                x_Token7 => 'LINE',
                x_value7 =>rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
 		        x_Token8 => 'MATCH_ATTR',
                x_value8 => v_MatchAttrTxt);
	    --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_DELETE_SEQ',
                                 x_key_rec.req_rec.line_id);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_DELETE_SEQ',
                                 x_Key_rec.req_rec.cust_model_serial_number);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_DELETE_SEQ',
                                 x_Key_rec.req_rec.request_date);
             END IF;
            --
           ELSE
            --
            rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_RECONCILE_DELETE',
                x_InterfaceHeaderId => x_sched_rec.header_id,
                x_InterfaceLineId => x_key_rec.req_rec.line_id,
                x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                x_OrderLineId => NULL,
   	        x_Token1 => 'QUANTITY',
                x_value1 => g_sch_line_qty,
   	        x_Token2 => 'GROUP',
                x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                            rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                            rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
	        x_Token3 => 'REQ_DATE',
                x_value3 => x_key_rec.req_rec.request_date,
  	        x_Token4 => 'START_DATE_TIME',
                x_value4 => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
                x_Token5 => 'SCHEDULE_LINE',
                x_value5 => rlm_core_sv.get_schedule_line_number(x_key_rec.req_rec.schedule_line_id),
                x_Token6 => 'ORDER',
                x_value6 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                x_Token7 => 'LINE',
                x_value7 =>rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
  	            x_Token8 => 'MATCH_ATTR',
                x_value8 => v_MatchAttrTxt);
	    --
            IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_DELETE',
                                 x_key_rec.req_rec.line_id);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_DELETE',
                                 x_Key_rec.req_rec.cust_model_serial_number);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_DELETE',
                                 x_Key_rec.req_rec.request_date);
            END IF;
            --
	       END IF; /* Exception */

         END IF;/* Check g_sch_line_qty*/
         --Bugfix 6131516 End

         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'x_DeleteQty',x_DeleteQty);
         END IF;
         --
       END IF;
       --
     END IF;
     --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    --
    WHEN e_group_error THEN
      --
      RAISE;
      --
    WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_rd_sv.DeleteRequirement',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END DeleteRequirement;

/*===========================================================================

  PROCEDURE InsertRequirement

===========================================================================*/
PROCEDURE InsertRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                            x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
			    x_Reconcile IN BOOLEAN,
                            x_Quantity IN OUT NOCOPY NUMBER)
IS

  x_progress          VARCHAR2(3) := '010';
  v_RF_Enabled        VARCHAR2(1) := 'N';
  e_FrozenFences      EXCEPTION;
  v_MatchAttrTxt      VARCHAR2(2000); -- Bug 4297984
  v_Quantity          NUMBER;         -- Bug 4297984

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'InsertRequirement');
     rlm_core_sv.dlog(k_DEBUG,'x_Reconcile',x_Reconcile);
     rlm_core_sv.dlog(k_DEBUG,'x_Quantity',x_Quantity);
     rlm_core_sv.dlog(k_DEBUG,'request_date',x_key_rec.req_rec.request_date);
  END IF;

--logic to roll forward frozen fence goes here

  v_RF_Enabled:=x_Group_rec.roll_forward_frozen_flag;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,' Rollforward set to: ', v_RF_Enabled);
  END IF;
  --
  -- bug 4223359 first reconcile the quantity in the reconcile table before trying to
  -- insert the new requirement. If there is additional qty after reconciling then
  -- check for frozenfences and if not within frozen fence then insert that qty.
  --
  IF x_Quantity > 0 THEN
      --
      v_Quantity := x_Quantity; -- Bug 4297984
      --
     IF x_Reconcile THEN
        --
        RLM_TPA_SV.ReconcileShipments(x_Group_rec, x_Key_rec, x_Quantity);
        --
        IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(k_DEBUG,'x_Quantity',x_Quantity);
        END IF;
        --
        Reconcile(x_Group_rec, x_Key_rec, x_Quantity);
        --
     END IF;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'x_Quantity',x_Quantity);
     END IF;
     --
     IF x_Quantity = 0 THEN
        -- Bug 4297984 Start
	GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.req_rec,v_MatchAttrTxt);
	--
	IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN
            --
            rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_RECONCILE_ZERO_INSERT_SEQ',
                x_InterfaceHeaderId => x_sched_rec.header_id,
                x_InterfaceLineId => x_key_rec.req_rec.line_id,
                x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                x_OrderLineId => NULL,
                x_Token1 => 'QUANTITY',
                x_value1 => v_Quantity,
                x_Token2 => 'GROUP',
                x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                            rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                            rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                x_Token3 => 'REQ_DATE',
                x_value3 => x_key_rec.req_rec.request_date,
                x_Token4 => 'START_DATE_TIME',
                x_value4 => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
                x_Token5 => 'SEQ_INFO',
                x_value5 => nvl(x_Key_rec.req_rec.cust_production_seq_num,'NULL') ||'-'||
                            nvl(x_Key_rec.req_rec.cust_model_serial_number,'NULL')||'-'||
                            nvl(x_Key_rec.req_rec.customer_job,'NULL'),
                x_Token6 => 'MATCH_ATTR',
                x_value6 => v_MatchAttrTxt);
            --
            IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_ZERO_INSERT_SEQ',
                                 x_key_rec.req_rec.line_id);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_ZERO_INSERT_SEQ',
                                 x_Key_rec.req_rec.cust_model_serial_number);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_ZERO_INSERT_SEQ',
                                 x_Key_rec.req_rec.request_date);
            END IF;
            --
        ELSE
            --
            rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_RECONCILE_ZERO_INSERT',
                x_InterfaceHeaderId => x_sched_rec.header_id,
                x_InterfaceLineId => x_key_rec.req_rec.line_id,
                x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                x_OrderLineId => NULL,
                x_Token1 => 'QUANTITY',
                x_value1 => v_Quantity,
                x_Token2 => 'GROUP',
                x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                            rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                            rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                x_Token3 => 'REQ_DATE',
                x_value3 => x_key_rec.req_rec.request_date,
                x_Token4 => 'START_DATE_TIME',
                x_value4 => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
                x_Token5 => 'SCHEDULE_LINE',
                x_value5 => rlm_core_sv.get_schedule_line_number(x_key_rec.req_rec.schedule_line_id),
                x_Token6 => 'MATCH_ATTR',
                x_value6 => v_MatchAttrTxt);
            --
            IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_ZERO_INSERT',
                                 x_key_rec.req_rec.line_id);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_ZERO_INSERT',
                                 x_Key_rec.req_rec.cust_model_serial_number);
                rlm_core_sv.dlog(k_DEBUG,'RLM_RECONCILE_ZERO_INSERT',
                                 x_Key_rec.req_rec.request_date);
            END IF;
            --
	END IF;
	-- Bug 4297984 End
     ELSE
        --
        IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(k_DEBUG,'schedule_source',x_Sched_rec.schedule_source);
        END IF;
        --
        -- start of bug fix 4223359
        --
        IF x_Sched_rec.schedule_source <> 'MANUAL' AND nvl(v_RF_Enabled,'N') = 'N' THEN
           --
           IF  IsFrozen(TRUNC(SYSDATE),x_Group_rec,x_key_rec.req_rec.request_date) OR
               IsFrozen(TRUNC(SYSDATE),x_Group_rec,x_key_rec.req_rec.schedule_date) THEN
               --
               IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                               x_key_rec.req_rec.line_id);
                    rlm_core_sv.dlog(k_DEBUG, 'Not inserting line', x_key_rec.req_rec.line_id);
                    rlm_core_sv.dlog(k_DEBUG, 'Qty not  inserting ', x_quantity);
               END IF;
               --
               -- If not able to insert the new quantity due to frozen fence
               -- store that quantity with a negative quantity in the g_reconcile_tab
               -- for that calling store shipments as store shipment stores req_rec
               --
               x_Key_rec.req_rec.shipment_flag := NULL;
               --
               x_Key_rec.req_rec.schedule_type := x_Sched_rec.schedule_type;
               --
               StoreShipments(x_Sched_rec, x_Group_rec, x_Key_rec, -x_quantity);
               --
               IF (l_debug <> -1) THEN
                  --
                  rlm_core_sv.dlog(k_DEBUG, 'x_Key_rec.req_rec.schedule_type',
                           x_Key_rec.req_rec.schedule_type);
                  rlm_core_sv.dlog(k_DEBUG, 'x_Key_rec.req_rec.shipment_flag',
                           x_Key_rec.req_rec.shipment_flag);
                  --
               END IF;
               --
               RAISE e_FrozenFences;
               --
           END IF;
           --
        END IF;
        --
        -- end of bug fix 4223359
        --
        IF v_RF_Enabled = 'Y' AND
           IsFrozen(TRUNC(SYSDATE),x_Group_rec,x_key_rec.req_rec.request_date) AND
              x_Sched_rec.schedule_source <> 'MANUAL' THEN
           --
	   IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.frozen_days',x_Group_rec.frozen_days);
           END IF;

-- Bugfix 8279132 Start
     GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.req_rec,v_MatchAttrTxt);

     IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN
        rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_ROLL_FORWARD_SEQ',
              x_InterfaceHeaderId => x_sched_rec.header_id,
              x_InterfaceLineId => x_key_rec.req_rec.line_id,
              x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
              x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
              x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
              x_OrderLineId => x_key_rec.dem_rec.line_id,
              x_Token1 => 'GROUP',
              x_value1 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                          rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                          rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
              x_Token2 => 'REQ_DATE',
              x_value2 => x_key_rec.req_rec.request_date,
              x_Token3 => 'REC_LINE_QTY',
              x_value3 => x_Quantity,
              x_Token4 => 'NEW_REQ_DATE',
              x_value4 => TRUNC(SYSDATE)+nvl(x_Group_rec.frozen_days,0),
              x_Token5 => 'SEQ_INFO',
              x_value5 => nvl(x_Key_rec.req_rec.cust_production_seq_num,'NULL')||'-'||
                          nvl(x_Key_rec.req_rec.cust_model_serial_number,'NULL')||'-'||
                          nvl(x_Key_rec.req_rec.customer_job,'NULL'),
              x_Token6 => 'MATCH_ATTR',
              x_value6 => v_MatchAttrTxt);
          --
          IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'The line is roll forwarded due to frozen fence',
                               x_key_rec.req_rec.line_id);
              rlm_core_sv.dlog(k_DEBUG,'RLM_ROLL_FORWARD_SEQ',
                               x_key_rec.req_rec.line_id);
          END IF;

     ELSE
        rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_ROLL_FORWARD',
              x_InterfaceHeaderId => x_sched_rec.header_id,
              x_InterfaceLineId => x_key_rec.req_rec.line_id,
              x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
              x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
              x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
              x_OrderLineId => x_key_rec.dem_rec.line_id,
              x_Token1 => 'GROUP',
              x_value1 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                          rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                          rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
              x_Token2 => 'REQ_DATE',
              x_value2 => x_key_rec.req_rec.request_date,
              x_Token3 => 'REC_LINE_QTY',
              x_value3 => x_Quantity,
              x_Token4 => 'NEW_REQ_DATE',
              x_value4 => TRUNC(SYSDATE)+nvl(x_Group_rec.frozen_days,0),
              x_Token5 => 'SCHEDULE_LINE',
              x_value5 => rlm_core_sv.get_schedule_line_number(x_key_rec.req_rec.schedule_line_id),
              x_Token6 => 'MATCH_ATTR',
              x_value6 => v_MatchAttrTxt);
          --
          IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'The line is roll forwarded due to frozen fence',
                               x_key_rec.req_rec.line_id);
              rlm_core_sv.dlog(k_DEBUG,'RLM_ROLL_FORWARD',
                               x_key_rec.req_rec.line_id);
          END IF;
     END IF;
     --  Bugfix 8279132 End
	   --
           x_key_rec.req_rec.request_date := TRUNC(SYSDATE)
                                       + nvl(x_Group_rec.frozen_days,0);
	   --
  	   IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'request_date',x_key_rec.req_rec.request_date);
           END IF;
           --
        END IF;
        --
 	IF v_RF_Enabled = 'Y' AND
           IsFrozen(TRUNC(SYSDATE),x_Group_rec,x_key_rec.req_rec.schedule_date) AND
              x_Sched_rec.schedule_source <> 'MANUAL' THEN
           --
  	   IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.frozen_days',x_Group_rec.frozen_days);
           END IF;
           --pdue
           x_key_rec.req_rec.schedule_date := TRUNC(SYSDATE)
                                       + nvl(x_Group_rec.frozen_days,0);
	   --
  	   IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'schedule_date',x_key_rec.req_rec.schedule_date);
           END IF;
           --
        END IF;
	--
        -- Bug 4351397 : Start
        --
        IF g_order_rec.request_date IS NOT NULL THEN
           --
           IF trunc(g_order_rec.request_date) < trunc(x_Key_rec.req_rec.request_date) THEN
              --
	      SetOperation(x_Key_rec, k_INSERT, x_Quantity);
              --
           ELSE
              --
              IF (l_debug <> -1) THEN
	          --
                  rlm_core_sv.dlog(k_DEBUG,'Insertion will not happen as a demand populated by higher precedence ' ||
                                   g_order_rec.rla_schedule_type_code || ' schedule exists on ' ||
				   g_order_rec.request_date);
                  --
              END IF;
	      --
              GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.req_rec, v_MatchAttrTxt);
              --
              IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN
                  --
                  rlm_message_sv.app_error(
                      x_ExceptionLevel => rlm_message_sv.k_warn_level,
                      x_MessageName => 'RLM_LOW_PRECEDENCE_INSERT_SEQ',
                      x_InterfaceHeaderId => x_sched_rec.header_id,
                      x_InterfaceLineId => x_key_rec.req_rec.line_id,
                      x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                      x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                      x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                      x_OrderLineId => NULL,
   	              x_Token1  => 'QUANTITY',
                      x_value1  => x_Key_rec.req_rec.primary_quantity,
                      x_Token2  => 'GROUP',
                      x_value2  => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                                   rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                                   rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
	              x_Token3  => 'REQ_DATE',
                      x_value3  => x_key_rec.req_rec.request_date,
                      x_Token4  => 'START_DATE_TIME',
                      x_value4  => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
                      x_Token5  => 'SCHEDULE_TYPE',
                      x_value5  => g_order_rec.rla_schedule_type_code,
                      x_Token6  => 'SCHEDULE_NUM',
                      x_value6  => g_order_rec.industry_attribute3,
                      x_Token7  => 'RECENT_REQ_DATE',
                      x_value7  => g_order_rec.request_date,
                      x_Token8  => 'ORDER',
                      x_value8  => rlm_core_sv.get_order_number(g_order_rec.header_id),
                      x_Token9  => 'SEQ_INFO',
                      x_value9  => nvl(x_Key_rec.req_rec.cust_production_seq_num,'NULL') ||'-'||
	                           nvl(x_Key_rec.req_rec.cust_model_serial_number,'NULL')||'-'||
                                   nvl(x_Key_rec.req_rec.customer_job,'NULL'),
                      x_Token10 => 'MATCH_ATTR',
                      x_value10 => v_MatchAttrTxt);
                  --
                  IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'RLM_LOW_PRECEDENCE_INSERT_SEQ',
                                       x_key_rec.req_rec.line_id);
                      rlm_core_sv.dlog(k_DEBUG,'RLM_LOW_PRECEDENCE_INSERT_SEQ',
                                       x_Key_rec.req_rec.cust_model_serial_number);
                      rlm_core_sv.dlog(k_DEBUG,'RLM_LOW_PRECEDENCE_INSERT_SEQ',
                                       x_Key_rec.req_rec.request_date);
                  END IF;
                  --
              ELSE
                  --
                  rlm_message_sv.app_error(
                      x_ExceptionLevel => rlm_message_sv.k_warn_level,
                      x_MessageName => 'RLM_LOW_PRECEDENCE_INSERT',
                      x_InterfaceHeaderId => x_sched_rec.header_id,
                      x_InterfaceLineId => x_key_rec.req_rec.line_id,
                      x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                      x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                      x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                      x_OrderLineId => NULL,
   	              x_Token1  => 'QUANTITY',
                      x_value1  => x_Key_rec.req_rec.primary_quantity,
                      x_Token2  => 'GROUP',
                      x_value2  => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                                   rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                                   rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
	              x_Token3  => 'REQ_DATE',
                      x_value3  => x_key_rec.req_rec.request_date,
                      x_Token4  => 'START_DATE_TIME',
                      x_value4  => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
                      x_Token5  => 'SCHEDULE_TYPE',
                      x_value5  => g_order_rec.rla_schedule_type_code,
                      x_Token6  => 'SCHEDULE_NUM',
                      x_value6  => g_order_rec.industry_attribute3,
                      x_Token7  => 'RECENT_REQ_DATE',
                      x_value7  => g_order_rec.request_date,
                      x_Token8  => 'ORDER',
                      x_value8  => rlm_core_sv.get_order_number(g_order_rec.header_id),
                      x_Token9  => 'SCHEDULE_LINE',
                      x_value9  => rlm_core_sv.get_schedule_line_number(x_key_rec.req_rec.schedule_line_id),
                      x_Token10 => 'MATCH_ATTR',
                      x_value10 => v_MatchAttrTxt);
                  --
                  IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'RLM_LOW_PRECEDENCE_INSERT',
                                       x_key_rec.req_rec.line_id);
                      rlm_core_sv.dlog(k_DEBUG,'RLM_LOW_PRECEDENCE_INSERT',
                                       x_Key_rec.req_rec.cust_model_serial_number);
                      rlm_core_sv.dlog(k_DEBUG,'RLM_LOW_PRECEDENCE_INSERT',
                                       x_Key_rec.req_rec.request_date);
                  END IF;
                  --
	      END IF;
	      --
           END IF ;
           --
        ELSE
           --
           SetOperation(x_Key_rec, k_INSERT, x_Quantity);
           --
        END IF;
        --
        -- Bug 4351397 : End
	--
     END IF;
     --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;

  EXCEPTION
    WHEN e_FrozenFences THEN
        -- Bug 4297984 Start
        GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.req_rec,v_MatchAttrTxt);
	--
     IF g_inc_exception <> 'Y' THEN  --Bugfix 6159269
        IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN
            --
            rlm_message_sv.app_error(
               x_ExceptionLevel => rlm_message_sv.k_warn_level,
               x_MessageName => 'RLM_FROZEN_INSERT_SEQ',
               x_InterfaceHeaderId => x_sched_rec.header_id,
               x_InterfaceLineId => x_key_rec.req_rec.line_id,
               x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
               x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
               x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
               x_OrderLineId => NULL,
               x_Token1 => 'QUANTITY',
               x_value1 => x_Key_rec.req_rec.primary_quantity,
               x_Token2 => 'GROUP',
               x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                           rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                           rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
               x_Token3 => 'REQ_DATE',
               x_value3 => x_key_rec.req_rec.request_date,
               x_Token4 => 'START_DATE_TIME',
               x_value4 => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
               x_Token5 => 'SEQ_INFO',
               x_value5 => nvl(x_Key_rec.req_rec.cust_production_seq_num,'NULL')||'-'||
                           nvl(x_Key_rec.req_rec.cust_model_serial_number,'NULL')||'-'||
                           nvl(x_Key_rec.req_rec.customer_job,'NULL'),
               x_Token6 => 'MATCH_ATTR',
               x_value6 => v_MatchAttrTxt);
            --
            IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_INSERT_SEQ',
                                  x_key_rec.req_rec.line_id);
                rlm_core_sv.dpop(k_SDEBUG);
	    END IF;
            --
        ELSE
            --
            rlm_message_sv.app_error(
               x_ExceptionLevel => rlm_message_sv.k_warn_level,
               x_MessageName => 'RLM_FROZEN_INSERT',
               x_InterfaceHeaderId => x_sched_rec.header_id,
               x_InterfaceLineId => x_key_rec.req_rec.line_id,
               x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
               x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
               x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
               x_OrderLineId => NULL,
               x_Token1 => 'QUANTITY',
               x_value1 => x_Key_rec.req_rec.primary_quantity,
               x_Token2 => 'GROUP',
               x_value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                           rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                           rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
               x_Token3 => 'REQ_DATE',
               x_value3 => x_key_rec.req_rec.request_date,
               x_Token4 => 'START_DATE_TIME',
               x_value4 => to_date(x_key_rec.req_rec.industry_attribute2,'YYYY/MM/DD HH24:MI:SS'),
               x_Token5 => 'SCHEDULE_LINE',
               x_value5 => rlm_core_sv.get_schedule_line_number(x_key_rec.req_rec.schedule_line_id),
               x_Token6 => 'MATCH_ATTR',
               x_value6 => v_MatchAttrTxt);
            --
            IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_INSERT',
                                 x_key_rec.req_rec.line_id);
                rlm_core_sv.dpop(k_SDEBUG);
            END IF;
            --
        END IF;
      END IF;  /*IF g_inc_exception */ --Bugfix 6159269

        -- Bug 4297984 End
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.InsertRequirement',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END InsertRequirement;

/*===========================================================================

  PROCEDURE UpdateRequirement

===========================================================================*/
PROCEDURE UpdateRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                            x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                            x_Quantity IN NUMBER)
IS

  v_Qty_rec     t_Qty_rec;
  x_progress    VARCHAR2(3) := '010';
  v_RF_Enabled  VARCHAR2(1) := 'N';
  v_MatchAttrTxt      VARCHAR2(2000); -- Bug 4297984
  v_line_id_tab   t_matching_line;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'UpdateRequirement');
     rlm_core_sv.dlog(k_DEBUG,'x_Quantity',x_Quantity);
  END IF;
  --
  -- logic to get roll forward values
  v_RF_Enabled:=x_Group_rec.roll_forward_frozen_flag;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'Rollforward set to: ', v_RF_Enabled);
  END IF;
  --
  --pdue
  --
  IF x_Sched_rec.schedule_source <> 'MANUAL' AND
      (IsFrozen(TRUNC(SYSDATE),x_Group_rec,x_Key_rec.req_rec.schedule_date) OR
       IsFrozen(TRUNC(SYSDATE),x_Group_rec,x_key_rec.req_rec.request_date)) THEN
     --{
     IF nvl(v_RF_Enabled, 'N') = 'N' THEN
        --{
        -- Bug 4297984 Start
        GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.dem_rec,v_MatchAttrTxt);
        --
  IF x_Key_rec.dem_rec.ordered_quantity <> g_sch_line_qty THEN        --Bugfix 6159269
        --
        IF (x_key_rec.dem_rec.schedule_type = 'SEQUENCED') THEN
          --
          rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_FROZEN_UPDATE_SEQ',
              x_InterfaceHeaderId => x_sched_rec.header_id,
              x_InterfaceLineId => x_key_rec.req_rec.line_id,
              x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
              x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
              x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
              x_OrderLineId => x_key_rec.dem_rec.line_id,
              x_Token1 => 'LINE',
              x_value1 => rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
              x_Token2 => 'ORDER',
              x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
              x_Token3 => 'QUANTITY',
              x_value3 => x_key_rec.dem_rec.ordered_quantity,
              x_Token4 => 'CUSTITEM',
              x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
              x_Token5 => 'REQ_DATE',
              x_value5 => x_key_rec.dem_rec.request_date,
    	      x_Token6 => 'SCH_LINE_QTY',               --Bugfix 6159269
              x_value6 => g_sch_line_qty,               --Bugfix 6159269
              x_Token7 => 'SEQ_INFO',
              x_value7 => nvl(x_Key_rec.dem_rec.cust_production_seq_num,'NULL')||'-'||
                          nvl(x_Key_rec.dem_rec.cust_model_serial_number,'NULL')||'-'||
                          nvl(x_Key_rec.dem_rec.customer_job,'NULL'),
              x_Token8 => 'MATCH_ATTR',
              x_value8 => v_MatchAttrTxt);
          --
          IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                               x_key_rec.req_rec.line_id);
              rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE_SEQ',
                               x_key_rec.req_rec.line_id);
          END IF;
          --
	  ELSE
          --
          rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_FROZEN_UPDATE',
              x_InterfaceHeaderId => x_sched_rec.header_id,
              x_InterfaceLineId => x_key_rec.req_rec.line_id,
              x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
              x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
              x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
              x_OrderLineId => x_key_rec.dem_rec.line_id,
              x_Token1 => 'LINE',
              x_value1 =>rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
              x_Token2 => 'ORDER',
              x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
              x_Token3 => 'QUANTITY',
              x_value3 => x_key_rec.dem_rec.ordered_quantity,
              x_Token4 => 'CUSTITEM',
              x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
              x_Token5 => 'REQ_DATE',
              x_value5 => x_key_rec.dem_rec.request_date,
              x_Token6 => 'SCH_LINE_QTY',               --Bugfix 6159269
              x_value6 => g_sch_line_qty,               --Bugfix 6159269
              x_Token7 => 'MATCH_ATTR',
              x_value7 => v_MatchAttrTxt);
          --
          IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                               x_key_rec.req_rec.line_id);
              rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE',
                               x_key_rec.req_rec.line_id);
          END IF;
          --
	    END IF;
        --
   END IF; --Bugfix 6159269
	-- Bug 4297984 End
        --}
     ELSE
        --{
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'dem_rec.ordered_quantity:',
                                  x_key_rec.dem_rec.ordered_quantity);
           rlm_core_sv.dlog(k_DEBUG,'frozen_days:',
                                  x_Group_rec.frozen_days);
        END IF;
        --
     -- Bugfix 8279132 Start
     GetMatchAttributes(x_sched_rec, x_group_rec, x_key_rec.req_rec,v_MatchAttrTxt);

     IF (x_sched_rec.schedule_type = 'SEQUENCED') THEN
        rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_ROLL_FORWARD_SEQ',
              x_InterfaceHeaderId => x_sched_rec.header_id,
              x_InterfaceLineId => x_key_rec.req_rec.line_id,
              x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
              x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
              x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
              x_OrderLineId => x_key_rec.dem_rec.line_id,
              x_Token1 => 'GROUP',
              x_value1 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                          rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                          rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
              x_Token2 => 'REQ_DATE',
              x_value2 => x_key_rec.req_rec.request_date,
              x_Token3 => 'REC_LINE_QTY',
              x_value3 => x_Quantity,
              x_Token4 => 'NEW_REQ_DATE',
              x_value4 => TRUNC(SYSDATE)+nvl(x_Group_rec.frozen_days,0),
              x_Token5 => 'SEQ_INFO',
              x_value5 => nvl(x_Key_rec.req_rec.cust_production_seq_num,'NULL')||'-'||
                          nvl(x_Key_rec.req_rec.cust_model_serial_number,'NULL')||'-'||
                          nvl(x_Key_rec.req_rec.customer_job,'NULL'),
              x_Token6 => 'MATCH_ATTR',
              x_value6 => v_MatchAttrTxt);
          --
          IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'The line is roll forwarded due to frozen fence',
                               x_key_rec.req_rec.line_id);
              rlm_core_sv.dlog(k_DEBUG,'RLM_ROLL_FORWARD_SEQ',
                               x_key_rec.req_rec.line_id);
          END IF;

     ELSE
        rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_ROLL_FORWARD',
              x_InterfaceHeaderId => x_sched_rec.header_id,
              x_InterfaceLineId => x_key_rec.req_rec.line_id,
              x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
              x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
              x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
              x_OrderLineId => x_key_rec.dem_rec.line_id,
              x_Token1 => 'GROUP',
              x_value1 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id)||'-'||
                          rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id)||'-'||
                          rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
              x_Token2 => 'REQ_DATE',
              x_value2 => x_key_rec.req_rec.request_date,
              x_Token3 => 'REC_LINE_QTY',
              x_value3 => x_Quantity,
              x_Token4 => 'NEW_REQ_DATE',
              x_value4 => TRUNC(SYSDATE)+nvl(x_Group_rec.frozen_days,0),
              x_Token5 => 'SCHEDULE_LINE',
              x_value5 => rlm_core_sv.get_schedule_line_number(x_key_rec.req_rec.schedule_line_id),
              x_Token6 => 'MATCH_ATTR',
              x_value6 => v_MatchAttrTxt);
          --
          IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'The line is roll forwarded due to frozen fence',
                               x_key_rec.req_rec.line_id);
              rlm_core_sv.dlog(k_DEBUG,'RLM_ROLL_FORWARD',
                               x_key_rec.req_rec.line_id);
          END IF;
     END IF;
     -- Bugfix 8279132 End
        x_key_rec.req_rec.request_date := TRUNC(SYSDATE) +
                                          nvl(x_Group_rec.frozen_days,0);
	x_key_rec.req_rec.schedule_Date := TRUNC(SYSDATE) +
					  nvl(x_Group_rec.frozen_days,0);
        --
        IF (x_key_rec.dem_rec.ordered_quantity < x_Quantity ) THEN
         --
         SetOperation(x_Key_rec, k_INSERT,
                      x_Quantity - x_key_rec.dem_rec.ordered_quantity);
         --
        ELSE
          --
          -- Bug 3999833 : Update the quantity on the OE line
          --
          SetOperation(x_Key_rec, k_UPDATE, x_Quantity);
          --
        END IF;
        --}
     END IF;
     --}
  ELSE
     --
     -- Bug 5122974
     --
     v_line_id_tab(0) := x_Key_rec.dem_rec.line_id;
     --
     IF not alreadyupdated(v_line_id_tab) THEN
       SetOperation(x_Key_rec, k_UPDATE, x_Quantity);
     else
      --
      if (x_Quantity < x_Key_rec.dem_rec.ordered_quantity) then
       RLM_TPA_SV.InsertRequirement(x_Sched_rec, x_Group_rec,
                        x_Key_rec, k_RECONCILE,
                        x_Key_rec.req_rec.primary_quantity);
      end if;
      --
     end if;
     --
     -- End bug 5122974

  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.UpdateRequirement',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END UpdateRequirement;

/*===========================================================================

  PROCEDURE GetQtyRec

===========================================================================*/
PROCEDURE GetQtyRec(x_Key_rec IN RLM_RD_SV.t_Key_rec,
                    x_Qty_rec OUT NOCOPY t_Qty_rec)
IS

  x_progress          VARCHAR2(3) := '010';
BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'GetQtyRec');
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.GetQtyRec',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetQtyRec;


/*===========================================================================

  PROCEDURE GetReq

===========================================================================*/
PROCEDURE GetReq(x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec)
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'GetReq');
  END IF;
  --
  IF x_Key_rec.rlm_line_id IS NOT NULL THEN
    IF x_Key_rec.rlm_line_id <> NVL(x_Key_rec.req_rec.line_id,k_NNULL) THEN
      NULL;
    END IF;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.GetReq',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetReq;


/*===========================================================================

  PROCEDURE GetDemand

===========================================================================*/
PROCEDURE GetDemand(x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                    x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS
  x_progress          VARCHAR2(3) := '010';
  v_sql               VARCHAR2(32000);
  c_Demand            t_Cursor_ref;

  CURSOR c_blanket IS
    SELECT line_id,customer_production_line,customer_dock_code,request_date,
           schedule_ship_date,cust_po_number,item_revision customer_item_revision,
           customer_job,cust_model_serial_number,cust_production_seq_num,
           industry_attribute1,industry_attribute2,industry_attribute3,
           industry_attribute4,industry_attribute5,industry_attribute6,
           industry_attribute7,industry_attribute8,industry_attribute9,
           industry_attribute10,industry_attribute11,industry_attribute12,
           industry_attribute13,industry_attribute14,industry_attribute15,
           attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,
           attribute7,attribute8,attribute9,attribute10,attribute11,attribute12,
           attribute13,attribute14,attribute15,demand_bucket_type_code,
           ship_to_org_id,invoice_to_org_id,intmed_ship_to_org_id,
           ordered_item_id customer_item_id,inventory_item_id,header_id,
           ship_from_org_id,rla_schedule_type_code,authorized_to_ship_flag,
           ordered_quantity,ordered_item,item_identifier_type,item_type_code,
           customer_line_number,blanket_number
           FROM oe_order_lines_all WHERE line_id = x_Key_rec.oe_line_id;

  CURSOR c_order IS
    SELECT line_id,customer_production_line,customer_dock_code,request_date,
           schedule_ship_date,cust_po_number,item_revision customer_item_revision,
           customer_job,cust_model_serial_number,cust_production_seq_num,
           industry_attribute1,industry_attribute2,industry_attribute3,
           industry_attribute4,industry_attribute5,industry_attribute6,
           industry_attribute7,industry_attribute8,industry_attribute9,
           industry_attribute10,industry_attribute11,industry_attribute12,
           industry_attribute13,industry_attribute14,industry_attribute15,
           attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,
           attribute7,attribute8,attribute9,attribute10,attribute11,attribute12,
           attribute13,attribute14,attribute15,demand_bucket_type_code,
           ship_to_org_id,invoice_to_org_id,intmed_ship_to_org_id,
           ordered_item_id customer_item_id,inventory_item_id,header_id,
           ship_from_org_id,rla_schedule_type_code,authorized_to_ship_flag,
           ordered_quantity,ordered_item,item_identifier_type,item_type_code,
           customer_line_number,NULL
           FROM oe_order_lines_all WHERE line_id = x_Key_rec.oe_line_id;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'GetDemand');
  END IF;
  --
  IF x_Group_rec.setup_terms_rec.blanket_number IS NOT NULL THEN
    --
    OPEN c_blanket;
    --
    FETCH c_blanket INTO
          x_Key_rec.dem_rec.line_id,
          x_Key_rec.dem_rec.cust_production_line,
          x_Key_rec.dem_rec.customer_dock_code,
          x_Key_rec.dem_rec.request_date,
          x_Key_rec.dem_rec.schedule_date,
          x_Key_rec.dem_rec.cust_po_number,
          x_Key_rec.dem_rec.customer_item_revision,
          x_Key_rec.dem_rec.customer_job,
          x_Key_rec.dem_rec.cust_model_serial_number,
          x_Key_rec.dem_rec.cust_production_seq_num,
          x_Key_rec.dem_rec.industry_attribute1,
          x_Key_rec.dem_rec.industry_attribute2,
          x_Key_rec.dem_rec.industry_attribute3,
          x_Key_rec.dem_rec.industry_attribute4,
          x_Key_rec.dem_rec.industry_attribute5,
          x_Key_rec.dem_rec.industry_attribute6,
          x_Key_rec.dem_rec.industry_attribute7,
          x_Key_rec.dem_rec.industry_attribute8,
          x_Key_rec.dem_rec.industry_attribute9,
          x_Key_rec.dem_rec.industry_attribute10,
          x_Key_rec.dem_rec.industry_attribute11,
          x_Key_rec.dem_rec.industry_attribute12,
          x_Key_rec.dem_rec.industry_attribute13,
          x_Key_rec.dem_rec.industry_attribute14,
          x_Key_rec.dem_rec.industry_attribute15,
          x_Key_rec.dem_rec.attribute1,
          x_Key_rec.dem_rec.attribute2,
          x_Key_rec.dem_rec.attribute3,
          x_Key_rec.dem_rec.attribute4,
          x_Key_rec.dem_rec.attribute5,
          x_Key_rec.dem_rec.attribute6,
          x_Key_rec.dem_rec.attribute7,
          x_Key_rec.dem_rec.attribute8,
          x_Key_rec.dem_rec.attribute9,
          x_Key_rec.dem_rec.attribute10,
          x_Key_rec.dem_rec.attribute11,
          x_Key_rec.dem_rec.attribute12,
          x_Key_rec.dem_rec.attribute13,
          x_Key_rec.dem_rec.attribute14,
          x_Key_rec.dem_rec.attribute15,
          x_Key_rec.dem_rec.item_detail_subtype,
          x_Key_rec.dem_rec.ship_to_org_id,
          x_Key_rec.dem_rec.invoice_to_org_id,
          x_Key_rec.dem_rec.intmed_ship_to_org_id,
          x_Key_rec.dem_rec.customer_item_id,
          x_Key_rec.dem_rec.inventory_item_id,
          x_Key_rec.dem_rec.order_header_id,
          x_Key_rec.dem_rec.ship_from_org_id,
          x_Key_rec.dem_rec.schedule_type,
          x_Key_rec.dem_rec.authorized_to_ship_flag,
          x_Key_rec.dem_rec.ordered_quantity,
          x_Key_rec.dem_rec.customer_item_ext,
          x_Key_rec.dem_rec.item_identifier_type,
          x_Key_rec.dem_rec.item_detail_type,
	  x_Key_rec.dem_rec.cust_po_line_num,
	  x_Key_rec.dem_rec.blanket_number;
    --
    CLOSE c_blanket;
    --
  ELSE
    --
    OPEN c_order;
    --
    FETCH c_order INTO
          x_Key_rec.dem_rec.line_id,
          x_Key_rec.dem_rec.cust_production_line,
          x_Key_rec.dem_rec.customer_dock_code,
          x_Key_rec.dem_rec.request_date,
          x_Key_rec.dem_rec.schedule_date,
          x_Key_rec.dem_rec.cust_po_number,
          x_Key_rec.dem_rec.customer_item_revision,
          x_Key_rec.dem_rec.customer_job,
          x_Key_rec.dem_rec.cust_model_serial_number,
          x_Key_rec.dem_rec.cust_production_seq_num,
          x_Key_rec.dem_rec.industry_attribute1,
          x_Key_rec.dem_rec.industry_attribute2,
          x_Key_rec.dem_rec.industry_attribute3,
          x_Key_rec.dem_rec.industry_attribute4,
          x_Key_rec.dem_rec.industry_attribute5,
          x_Key_rec.dem_rec.industry_attribute6,
          x_Key_rec.dem_rec.industry_attribute7,
          x_Key_rec.dem_rec.industry_attribute8,
          x_Key_rec.dem_rec.industry_attribute9,
          x_Key_rec.dem_rec.industry_attribute10,
          x_Key_rec.dem_rec.industry_attribute11,
          x_Key_rec.dem_rec.industry_attribute12,
          x_Key_rec.dem_rec.industry_attribute13,
          x_Key_rec.dem_rec.industry_attribute14,
          x_Key_rec.dem_rec.industry_attribute15,
          x_Key_rec.dem_rec.attribute1,
          x_Key_rec.dem_rec.attribute2,
          x_Key_rec.dem_rec.attribute3,
          x_Key_rec.dem_rec.attribute4,
          x_Key_rec.dem_rec.attribute5,
          x_Key_rec.dem_rec.attribute6,
          x_Key_rec.dem_rec.attribute7,
          x_Key_rec.dem_rec.attribute8,
          x_Key_rec.dem_rec.attribute9,
          x_Key_rec.dem_rec.attribute10,
          x_Key_rec.dem_rec.attribute11,
          x_Key_rec.dem_rec.attribute12,
          x_Key_rec.dem_rec.attribute13,
          x_Key_rec.dem_rec.attribute14,
          x_Key_rec.dem_rec.attribute15,
          x_Key_rec.dem_rec.item_detail_subtype,
          x_Key_rec.dem_rec.ship_to_org_id,
          x_Key_rec.dem_rec.invoice_to_org_id,
          x_Key_rec.dem_rec.intmed_ship_to_org_id,
          x_Key_rec.dem_rec.customer_item_id,
          x_Key_rec.dem_rec.inventory_item_id,
          x_Key_rec.dem_rec.order_header_id,
          x_Key_rec.dem_rec.ship_from_org_id,
          x_Key_rec.dem_rec.schedule_type,
          x_Key_rec.dem_rec.authorized_to_ship_flag,
          x_Key_rec.dem_rec.ordered_quantity,
          x_Key_rec.dem_rec.customer_item_ext,
          x_Key_rec.dem_rec.item_identifier_type,
          x_Key_rec.dem_rec.item_detail_type,
	  x_Key_rec.dem_rec.cust_po_line_num,
	  x_Key_rec.dem_rec.blanket_number;
    --
    CLOSE c_order;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.dem_rec.order_header_id',
                                  x_Key_rec.dem_rec.order_header_id);
           rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.dem_rec.blanket_number',
                                  x_Key_rec.dem_rec.blanket_number);
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.GetDemand',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetDemand;


/*===========================================================================

  PROCEDURE InitializeDemand

===========================================================================*/
PROCEDURE InitializeDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                           x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                           x_Key_rec IN RLM_RD_SV.t_Key_rec,
                           x_Demand_ref IN OUT NOCOPY t_Cursor_ref,
                           x_DemandType IN VARCHAR2)
IS
  x_progress          VARCHAR2(3) := '010';
  v_select_clause     VARCHAR2(32000);
  v_where_clause      VARCHAR2(32000);
  v_sql               VARCHAR2(32000);
  e_no_init           EXCEPTION;
  v_request_date_str  VARCHAR2(30);
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'InitializeDemand');
  END IF;
  --
  g_InitDemandTab.DELETE;
  --
  IF x_DemandType NOT IN (k_ATS, k_NATS) THEN
    --
    RAISE e_no_init;
    --
  END IF;
  --
  v_select_clause :=
  'SELECT line_id,NVL(ordered_quantity,0),NVL(shipped_quantity,0),'||
  'sold_to_org_id,customer_production_line,customer_dock_code,'||
  'request_date,schedule_ship_date,cust_po_number,'||
  'item_revision customer_item_revision,customer_job,'||
  'cust_model_serial_number,cust_production_seq_num,industry_attribute1,'||
  'industry_attribute2,industry_attribute3,industry_attribute4,'||
  'industry_attribute5,industry_attribute6,industry_attribute7,'||
  'industry_attribute8,industry_attribute9,industry_attribute10,'||
  'industry_attribute11,industry_attribute12,industry_attribute13,'||
  'industry_attribute14,industry_attribute15,industry_context,'||
  'attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,'||
  'attribute7,attribute8,attribute9,attribute10,attribute11,attribute12,'||
  'attribute13,attribute14,attribute15,context,tp_attribute1,'||
  'tp_attribute2,tp_attribute3,tp_attribute4,tp_attribute5,tp_attribute6,'||
  'tp_attribute7,tp_attribute8,tp_attribute9,tp_attribute10,'||
  'tp_attribute11,tp_attribute12,tp_attribute13,tp_attribute14,'||
  'tp_attribute15,tp_context,demand_bucket_type_code,item_type_code,'||
  'ship_to_org_id,invoice_to_org_id,intmed_ship_to_org_id,'||
  'ordered_item_id customer_item_id,inventory_item_id,header_id,'||
  'ship_from_org_id,rla_schedule_type_code,authorized_to_ship_flag,'||
  'item_identifier_type,agreement_id,price_list_id,ordered_item,'||
  'order_quantity_uom,';

  IF x_Group_rec.setup_terms_rec.blanket_number IS NOT NULL THEN
    --
    v_select_clause := v_select_clause || 'blanket_number FROM oe_order_lines';
    --
  ELSE
    --
    v_select_clause := v_select_clause || 'NULL FROM oe_order_lines';
    --
  END IF;

  -- Mandatory Match Attributes
  v_where_clause :=
  ' WHERE header_id = :order_header_id' ||
  ' AND ship_to_org_id = :ship_to_org_id' ||
  ' AND ordered_item_id = :customer_item_id'||
  ' AND inventory_item_id= :inventory_item_id' ||
  ' AND  NVL(intmed_ship_to_org_id,' ||  k_NNULL||  ') =   NVL(:intmed_ship_to_org_id , '||k_NNULL || ')'||  --Bugfix 5911991
  ' AND (NVL(ordered_quantity,0) - NVL(shipped_quantity,0)) > 0' ||
  ' AND NVL(demand_bucket_type_code,'|| k_NNULL || ') = NVL(:item_detail_subtype,'||k_NNULL||')';
  --
  g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Group_rec.order_header_id;
  g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Group_rec.ship_to_org_id;
  g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Group_rec.customer_item_id;
  g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Group_rec.inventory_item_id;
  g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Group_rec.intmed_ship_to_org_id;  --Bugfix 5911991
  g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.item_detail_subtype;
  --
  -- Start of bug 4223359
  --If the disposition code is remain on File reconcile get all the open sales order lines
  --If the disposition code is remain on File then use horizon_start_date and horizon end date
  --If the disposition code is Cancel All then use SYSDATE
  --
  IF x_Group_rec.disposition_code = k_CANCEL_ALL THEN
     --
      v_where_clause := v_where_clause || ' AND TO_DATE(industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') BETWEEN TO_DATE(:sched_start_date,''RRRR/MM/DD HH24:MI:SS'') AND TO_DATE(:sched_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
     g_InitDemandTab(g_InitDemandTab.COUNT+1) := TO_CHAR(TRUNC(SYSDATE), 'RRRR/MM/DD HH24:MI:SS');
     g_InitDemandTab(g_InitDemandTab.COUNT+1) := TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999, 'RRRR/MM/DD HH24:MI:SS');
    --
  ELSIF x_Group_rec.disposition_code = k_CANCEL_AFTER_N_DAYS THEN
     --
      v_where_clause := v_where_clause || ' AND TO_DATE(industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') BETWEEN TO_DATE(:sched_start_date,''RRRR/MM/DD HH24:MI:SS'') AND TO_DATE(:sched_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
     g_InitDemandTab(g_InitDemandTab.COUNT+1) := TO_CHAR(TRUNC(SYSDATE) - NVL(x_group_rec.cutoff_days,0), 'RRRR/MM/DD HH24:MI:SS');
     g_InitDemandTab(g_InitDemandTab.COUNT+1) := TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999, 'RRRR/MM/DD HH24:MI:SS');
     --
  ELSIF x_Group_rec.disposition_code = k_REMAIN_ON_FILE_RECONCILE THEN
     --
      v_where_clause := v_where_clause || ' AND TO_DATE(industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') < TO_DATE(:sched_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
     g_InitDemandTab(g_InitDemandTab.COUNT+1) := TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999, 'RRRR/MM/DD HH24:MI:SS');
     --
  ELSE
     --
      v_where_clause := v_where_clause || ' AND TO_DATE(industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') BETWEEN TO_DATE(:sched_start_date,''RRRR/MM/DD HH24:MI:SS'') AND TO_DATE(:sched_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
     g_InitDemandTab(g_InitDemandTab.COUNT+1) := TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_start_date), 'RRRR/MM/DD HH24:MI:SS');
     g_InitDemandTab(g_InitDemandTab.COUNT+1) := TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999, 'RRRR/MM/DD HH24:MI:SS');
     --
  END IF;
  --
  -- END of bug 4223359
  --
  -- Optional match
  v_request_date_str := TO_CHAR(x_Key_rec.req_rec.request_date,'RRRR/MM/DD HH24:MI:SS');

  IF x_group_rec.match_across_rec.request_date = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND request_date = TO_DATE(:v_req_date,''RRRR/MM/DD HH24:MI:SS'')';
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := v_request_date_str;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.request_date = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND request_date = DECODE(rla_schedule_type_code, :schedule_type, TO_DATE(:v_req_date,''RRRR/MM/DD HH24:MI:SS'')'||',request_date)';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := v_request_date_str;
    END IF;
    --
  END IF;
  --

  IF x_group_rec.match_across_rec.cust_production_line = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(customer_production_line,'''||k_VNULL||
      ''') =  NVL(:customer_production_line, ''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_production_line;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_production_line = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(customer_production_line,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:customer_production_line,''' || k_VNULL ||
        '''), NVL(customer_production_line,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_production_line;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.customer_dock_code = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(customer_dock_code,'''||k_VNULL||
      ''') = NVL(:customer_dock_code,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.customer_dock_code;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.customer_dock_code = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(customer_dock_code,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:customer_dock_code,''' || k_VNULL ||
        '''), NVL(customer_dock_code,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.customer_dock_code;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.cust_po_number = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(cust_po_number,'''||k_VNULL||
     ''') = NVL(:cust_po_number,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_po_number;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_po_number = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(cust_po_number,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:cust_po_number,''' || k_VNULL ||
        '''), NVL(cust_po_number,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_po_number;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.customer_item_revision = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(item_revision,'''||k_VNULL||
      ''') = NVL(:customer_item_revision,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.customer_item_revision;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.customer_item_revision = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(item_revision,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:customer_item_revision,''' || k_VNULL ||
        '''), NVL(item_revision,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.customer_item_revision;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.customer_job = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(customer_job,'''||k_VNULL||
      ''') = NVL(:customer_job,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.customer_job;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.customer_job = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(customer_job,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:customer_job, ''' || k_VNULL ||
        '''), NVL(customer_job,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.customer_job;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.cust_model_serial_number = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(cust_model_serial_number,'''||k_VNULL||
      ''') = NVL(:cust_model_serial_number,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_model_serial_number;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_model_serial_number = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(cust_model_serial_number,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:cust_model_serial_num,''' || k_VNULL ||
        '''), NVL(cust_model_serial_number,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_model_serial_number;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.cust_production_seq_num = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(cust_production_seq_num,'''||k_VNULL||
      ''') = NVL(:cust_production_seq_num,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_production_seq_num;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_production_seq_num = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(cust_production_seq_num,'''||k_VNULL||
       ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:cust_production_seq_num,''' || k_VNULL ||
       '''), NVL(cust_production_seq_num,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.cust_production_seq_num;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute1 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute1,'''||k_VNULL||
      ''') = NVL(:industry_attribute1,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute1;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute1 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute1,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute1,''' || k_VNULL ||
        '''), NVL(industry_attribute1,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute1;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute2 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute2,'''||k_VNULL||
      ''') = NVL(:industry_attribute2,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute2;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute2 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute2,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute2,''' || k_VNULL ||
        '''),NVL(industry_attribute2,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute2;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute4 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute4,'''||k_VNULL||
      ''') = NVL(:industry_attribute4, ''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute4;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute4 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute4,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute4,''' || k_VNULL ||
        '''),NVL(industry_attribute4,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute4;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute5 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute5,'''||k_VNULL||
      ''') = NVL(:industry_attribute5,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute5;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute5 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute5,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute5,''' || k_VNULL ||
        '''),NVL(industry_attribute5,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute5;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute6 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute6,'''||k_VNULL||
      ''') = NVL(:industry_attribute6,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute6;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute6 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute6,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute6,''' || k_VNULL ||
        '''), NVL(industry_attribute6,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute6;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute10 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute10,'''||k_VNULL||
      ''') = NVL(:industry_attribute10,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute10;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute10 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute10,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute10,''' || k_VNULL ||
        '''),NVL(industry_attribute10,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute10;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute11 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute11,'''||k_VNULL||
      ''') = NVL(:industry_attribute11,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute11;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute11 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute11,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute11,''' || k_VNULL ||
        '''), NVL(industry_attribute11,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute11;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute12 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute12,'''||k_VNULL||
      ''') = NVL(:industry_attribute12,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute12;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute12 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute12,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute12,''' || k_VNULL ||
        '''), NVL(industry_attribute12,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute12;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute13 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute13,'''||k_VNULL||
      ''') = NVL(:industry_attribute13,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute13;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute13 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute13,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type,' ||
        ' NVL(:industry_attribute13,''' || k_VNULL || '''), NVL(industry_attribute13,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute13;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute14 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(industry_attribute14,'''||k_VNULL||
      ''') = NVL(:industry_attribute14,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute14;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute14 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(industry_attribute14,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:industry_attribute14,''' || k_VNULL ||
        '''), NVL(industry_attribute14,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute14;
      --
    END IF;
    --
  END IF;
  --
  IF g_ATP <> k_ATP THEN
   --
   v_where_clause := v_where_clause ||
      ' AND ship_from_org_id = :ship_from_org_id '||
      ' AND NVL(industry_attribute15,'''||k_VNULL||
      ''') = NVL(:industry_attribute15,''' || k_VNULL || ''')';
   --
   g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Group_rec.ship_from_org_id;
   g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.industry_attribute15;
   --
  END IF;

  --
  IF x_group_rec.match_across_rec.attribute1 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute1,'''||k_VNULL||
      ''') = NVL(:attribute1, ''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute1;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute1 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute1,'''||k_VNULL||
        ''')  = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute2,''' || k_VNULL || '''), NVL(attribute2,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute2;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute3 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute3,'''||k_VNULL||
      ''') = NVL(:attribute3,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute3;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute3 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute3,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute3,''' || k_VNULL ||
        '''), NVL(attribute3,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute3;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute4 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute4,'''||k_VNULL||
      ''') = NVL(:attribute4,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute4;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute4 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute4,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute4,''' || k_VNULL ||
        '''), NVL(attribute4,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute4;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute5 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute5,'''||k_VNULL||
      ''') = NVL(:attribute5,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute5;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute5 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute5,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute5,''' || k_VNULL ||
        '''), NVL(attribute5,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute5;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute6 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute6,'''||k_VNULL||
      ''') = NVL(:attribute6,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute6;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute6 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute6,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute6,''' || k_VNULL ||
        '''), NVL(attribute6,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute6;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute7 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute7,'''||k_VNULL||
      ''') = NVL(:attribute7,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute7;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute7 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute7,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute7,''' || k_VNULL ||
        '''), NVL(attribute7,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute7;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute8 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute8,'''||k_VNULL||
      ''') = NVL(:attribute8,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute8;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute8 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute8,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute8,''' || k_VNULL ||
        '''), NVL(attribute8,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute8;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute9 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute9,'''||k_VNULL||
      ''') = NVL(:attribute9,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute9;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute9 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute9,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute9,''' || k_VNULL ||
        '''), NVL(attribute9,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute9;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute10 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute10,'''||k_VNULL||
      ''') = NVL(:attribute10,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute10;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute10 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute10,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute10,''' || k_VNULL ||
        '''), NVL(attribute10,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute10;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute11 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute11,'''||k_VNULL||
      ''') = NVL(:attribute11,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute11;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute11 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute11,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute11, ''' || k_VNULL ||
        '''), NVL(attribute11,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute11;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute12 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute12,'''||k_VNULL||
      ''') = NVL(:attribute12,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute12;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute12 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute12,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute12,''' || k_VNULL ||
        '''), NVL(attribute12,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute12;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute13 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute13,'''||k_VNULL||
      ''') = NVL(:attribute13,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute13;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute13 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute13,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute13,''' || k_VNULL ||
        '''), NVL(attribute13,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute13;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute14 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute14,'''||k_VNULL||
      ''') = NVL(:attribute14,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute14;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute14 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute14,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute14,''' || k_VNULL ||
        '''), NVL(attribute14,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute14;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute15 = 'Y' THEN
    --
    v_where_clause := v_where_clause ||
      ' AND NVL(attribute15,'''||k_VNULL||
      ''') = NVL(:attribute15,''' || k_VNULL || ''')';
    --
    g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute15;
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute15 = 'Y' THEN
      --
      v_where_clause := v_where_clause ||
        ' AND NVL(attribute15,'''||k_VNULL||
        ''') = DECODE(rla_schedule_type_code, :schedule_type, NVL(:attribute15,''' || k_VNULL ||
        '''), NVL(attribute15,'''||k_VNULL||'''))';
      --
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Sched_rec.schedule_type;
      g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_Key_rec.req_rec.attribute15;
      --
    END IF;
    --
  END IF;
  --
  -- R12 Perf Bug 5013956 : Use bind variable for ATS flag
  --
  v_where_clause := v_where_clause || ' AND authorized_to_ship_flag = :x_DemandType ORDER BY request_date DESC';
  g_InitDemandTab(g_InitDemandTab.COUNT+1) := x_DemandType;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG,'v_select_clause',v_select_clause);
    rlm_core_sv.dlog(k_DEBUG,'v_where_clause',v_where_clause);
    rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for x_Demand_ref cursor', g_InitDemandTab.COUNT);
  END IF;
  --
  v_sql := v_select_clause || v_where_clause;
  --
  RLM_CORE_SV.OpenDynamicCursor(x_Demand_ref, v_sql, g_InitDemandTab);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN e_no_init THEN
    rlm_core_sv.dpop(k_SDEBUG,'Demand Type is not ATS or NATS');

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.InitializeDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END InitializeDemand;

/*===========================================================================

  PROCEDURE InitializeSoGroup

===========================================================================*/
PROCEDURE InitializeSoGroup(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_ref IN OUT NOCOPY rlm_rd_sv.t_Cursor_ref,
                          x_Group_rec IN OUT NOCOPY  rlm_dp_sv.t_Group_rec)
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'InitializeSoGroup');
  END IF;
  --
  OPEN x_Group_ref FOR
    SELECT   rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.intrmd_ship_to_id,      --Bugfix 5911991
	     ril.intmed_ship_to_org_id   --Bugfix 5911991
             --ril.order_header_id,
	     --ril.blanket_number
             --ril.cust_production_seq_num
    FROM     rlm_interface_headers   rih,
             rlm_interface_lines_all ril
    WHERE    rih.header_id = x_Sched_rec.header_id
    AND      rih.org_id = ril.org_id
    AND      ril.header_id = rih.header_id
    AND      ril.industry_attribute15 = x_Group_rec.ship_from_org_id
    AND      ril.process_status IN (rlm_core_sv.k_PS_AVAILABLE, rlm_core_sv.k_PS_FROZEN_FIRM)
    --AND      ril.inventory_item_id = x_Group_rec.inventory_item_id
    AND      ril.customer_item_id = x_Group_rec.customer_item_id
    AND      ril.ship_to_address_id = x_Group_rec.ship_to_address_id
    -- blankets
    --AND      ril.blanket_number IS NULL
    GROUP BY rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.intrmd_ship_to_id,     --Bugfix 5911991
	     ril.intmed_ship_to_org_id  --Bugfix 5911991
             --ril.order_header_id,
	     --ril.blanket_number
             --ril.cust_production_seq_num
    ORDER BY ril.ship_to_org_id,
             ril.customer_item_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.InitializeSoGroup',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise e_group_error;

END InitializeSoGroup;


/*===========================================================================

  PROCEDURE InitializeReq

===========================================================================*/
PROCEDURE InitializeReq(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                        x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                        x_Req_ref IN OUT NOCOPY t_Cursor_ref,
                        x_ReqType IN VARCHAR2)
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'InitializeReq');
     rlm_core_sv.dlog(k_DEBUG,'x_ReqType', x_ReqType);
  END IF;
  --
  IF x_ReqType IN (k_NATS, k_ATS) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_org_id', x_Group_rec.ship_to_org_id);
       rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id', x_Group_rec.customer_item_id);
       rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id', x_Group_rec.inventory_item_id);
       rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id', x_Group_rec.order_header_id);
       rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_start_date', x_Sched_rec.sched_horizon_start_date);
       rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_end_date', x_Sched_rec.sched_horizon_end_date);
    END IF;
    --
    IF (x_ReqType = k_ATS) THEN

      OPEN x_Req_ref FOR
        SELECT  x_group_rec.customer_id,
              header_id,
              line_id,
              cust_production_line,
              customer_dock_code,
              request_date,
              schedule_date,
              cust_po_number,
              customer_item_revision,
              customer_job,
              cust_model_serial_number,
              cust_production_seq_num,
              industry_attribute1,
              industry_attribute2,
              industry_attribute3,
              industry_attribute4,
              industry_attribute5,
              industry_attribute6,
              industry_attribute7,
              industry_attribute8,
              industry_attribute9,
              industry_attribute10,
              industry_attribute11,
              industry_attribute12,
              industry_attribute13,
              industry_attribute14,
              industry_attribute15,
              industry_context,
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
              attribute_category,
              tp_attribute1,
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
              item_detail_type,
              item_detail_subtype,
              intrmd_ship_to_id,
              ship_to_org_id,
              invoice_to_org_id,
              primary_quantity,
              intmed_ship_to_org_id,
              customer_item_id,
              inventory_item_id,
              order_header_id,
              x_ReqType,
              ship_from_org_id,
              x_Sched_rec.schedule_type,
              'CUST' item_identifier_type,
              customer_item_ext,
              agreement_id,
              price_list_id,
              x_Sched_rec.schedule_header_id,
              schedule_line_id,
              process_status,
              uom_code,
              cust_po_line_num
      FROM    rlm_interface_lines
      WHERE   header_id = x_Sched_rec.header_id
      AND     ship_from_org_id = x_Group_rec.ship_from_org_id
      AND     industry_attribute15 = x_Group_rec.industry_attribute15
      AND     ship_to_org_id = x_Group_rec.ship_to_org_id
      AND     customer_item_id = x_Group_rec.customer_item_id
      AND     inventory_item_id = x_Group_rec.inventory_item_id
      AND     order_header_id = x_Group_rec.order_header_id
      AND     NVL(intmed_ship_to_org_id ,K_NNULL) =  NVL(x_Group_rec.intmed_ship_to_org_id, K_NNULL)  --Bugfix 5911991
      AND     process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                                 rlm_core_sv.k_PS_FROZEN_FIRM)
      AND     (item_detail_type = k_FIRM OR item_detail_type = k_PAST_DUE_FIRM)
      ORDER BY request_date;

    ELSE

       OPEN x_Req_ref FOR
         SELECT  x_group_rec.customer_id,
              header_id,
              line_id,
              cust_production_line,
              customer_dock_code,
              request_date,
              schedule_date,
              cust_po_number,
              customer_item_revision,
              customer_job,
              cust_model_serial_number,
              cust_production_seq_num,
              industry_attribute1,
              industry_attribute2,
              industry_attribute3,
              industry_attribute4,
              industry_attribute5,
              industry_attribute6,
              industry_attribute7,
              industry_attribute8,
              industry_attribute9,
              industry_attribute10,
              industry_attribute11,
              industry_attribute12,
              industry_attribute13,
              industry_attribute14,
              industry_attribute15,
              industry_context,
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
              attribute_category,
              tp_attribute1,
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
              item_detail_type,
              item_detail_subtype,
              intrmd_ship_to_id,
              ship_to_org_id,
              invoice_to_org_id,
              primary_quantity,
              intmed_ship_to_org_id,
              customer_item_id,
              inventory_item_id,
              order_header_id,
              x_ReqType,
              ship_from_org_id,
              x_Sched_rec.schedule_type,
              'CUST' item_identifier_type,
              customer_item_ext,
              agreement_id,
              price_list_id,
              x_Sched_rec.schedule_header_id,
              schedule_line_id,
              process_status,
              uom_code,
              cust_po_line_num
      FROM    rlm_interface_lines
      WHERE   header_id = x_Sched_rec.header_id
      AND     ship_from_org_id = x_Group_rec.ship_from_org_id
      AND     industry_attribute15 = x_Group_rec.industry_attribute15
      AND     ship_to_org_id = x_Group_rec.ship_to_org_id
      AND     customer_item_id = x_Group_rec.customer_item_id
      AND     inventory_item_id = x_Group_rec.inventory_item_id
      AND     NVL(intmed_ship_to_org_id ,K_NNULL) =  NVL(x_Group_rec.intmed_ship_to_org_id, K_NNULL)  --Bugfix 5911991
      AND     order_header_id = x_Group_rec.order_header_id
      AND     process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                                 rlm_core_sv.k_PS_FROZEN_FIRM)
      AND     item_detail_type = k_FORECAST
      ORDER BY request_date;

    END IF;

  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.InitializeReq',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise e_group_error;

END InitializeReq;


-- NOTE: cancel requirement may be obsolete
/*===========================================================================

  PROCEDURE CancelRequirement

===========================================================================*/
PROCEDURE CancelRequirement(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                            x_Key_rec IN RLM_RD_SV.t_Key_rec,
                            x_CancelQty IN NUMBER)
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'CancelRequirement');
     rlm_core_sv.dlog(k_DEBUG,'x_CancelQty',x_CancelQty);
  END IF;
  --
  SetOperation(x_Key_rec, k_UPDATE, x_Key_rec.dem_rec.ordered_quantity - x_CancelQty);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.CancelRequirement',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END CancelRequirement;


/*===========================================================================

  PROCEDURE SynchronizeShipments

===========================================================================*/
PROCEDURE SynchronizeShipments(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS
  --
  v_InTransitQty  NUMBER;
  --
  v_shipper_rec   WSH_RLM_INTERFACE.t_shipper_rec;
  v_match_rec	  WSH_RLM_INTERFACE.t_optional_match_rec;
  --
  v_Key_rec  t_Key_rec;
  --
  v_count 			NUMBER DEFAULT 0 ;
  v_shipment_date		DATE;
  v_intransit_time              NUMBER := 0;
  v_item_detail_subtype		VARCHAR2(80);
  --
  x_progress          VARCHAR2(3) DEFAULT '010';
  v_return_status     VARCHAR2(240);
  --
  v_cumDiscrete       NUMBER;
  e_cumDiscrete       EXCEPTION;
  --
  v_match_ref			t_Cursor_ref;
  v_Index			NUMBER;
  v_intransit_calc_basis        VARCHAR2(15);
  v_match_across_rule		RLM_CORE_SV.t_Match_rec;
  v_match_within_rule		RLM_CORE_SV.t_Match_rec;
  v_header_id			NUMBER;
  v_Intransit		NUMBER := 0;
  v_LineID		NUMBER;
  v_min_horizon_date    VARCHAR2(30);
  --

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'SynchronizeShipments');
  END IF;
  --
  v_intransit_calc_basis := UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis);
  --
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'ship_from_org_id', x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG, 'inventory_item_id', x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(k_DEBUG, 'ship_to_org_id', x_Group_rec.ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'customer_item_id', x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(k_DEBUG, 'Intransit calc basis', v_intransit_calc_basis);
     rlm_core_sv.dlog(k_DEBUG, 'Order Header Id', x_Group_rec.order_header_id);
     rlm_core_sv.dlog(k_DEBUG, 'Blanket Number', x_Group_rec.blanket_number);
     rlm_core_sv.dlog(k_DEBUG, 'g_BlktIntransits', g_BlktIntransits);
     rlm_core_sv.dlog(k_DEBUG, 'CUM Org Level',
                              x_Group_rec.setup_terms_rec.cum_org_level_code);
     rlm_core_sv.dlog(k_DEBUG, 'x_Group_rec.isSourced', x_Group_rec.isSourced);
  END IF;
  --
  v_match_across_rule := x_Group_rec.match_across_rec;
  v_match_within_rule := x_Group_rec.match_within_rec;
  --
  IF (v_intransit_calc_basis = k_NONE OR v_intransit_calc_basis is NULL) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG, 'All shipments assumed to have been received');
       rlm_core_sv.dpop(k_SDEBUG, 'Processing rule set to NONE or NULL');
    END IF;
    --
    RETURN;
    --
  END IF;
  --
  --
  SELECT COUNT(*)
  INTO v_cumDiscrete
  FROM rlm_interface_lines     il,
       rlm_schedule_lines_all  sl
  WHERE  il.header_id = x_Sched_rec.header_id
  AND    il.ship_from_org_id = x_Group_rec.ship_from_org_id
  AND    il.ship_to_org_id = x_Group_rec.ship_to_org_id
  AND    il.inventory_item_id = x_Group_rec.inventory_item_id
  AND    il.customer_item_id = x_Group_rec.customer_item_id
  AND    NVL(il.item_detail_type, ' ') NOT IN
                       (rlm_manage_demand_sv.k_SHIP_RECEIPT_INFO,
                        rlm_manage_demand_sv.k_AUTHORIZATION,
                        rlm_manage_demand_sv.k_OTHER_DETAIL_TYPE)
  AND    il.schedule_line_id = sl.line_id
  AND    sl.qty_type_code    = rlm_manage_demand_sv.k_CUMULATIVE
  AND    il.org_id = sl.org_id;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG,'v_cumDiscrete', v_cumDiscrete);
  END IF;
  --
  IF v_cumDiscrete > 0 THEN
    --
    /*
       If the interface line has a CUMULATIVE qty_code then this means
       that its primary qty has been calculated based on the supplier cum.
       There is no need to re-calculate the in transit qty.
       See manage demand CumtoDiscrete procedure.
    */
    RAISE e_cumDiscrete;
    --
  END IF;
  --
  -- Customer CUM logic is as follows :
  --
  -- (a) If blankets are used and g_BlktIntransits = TRUE, it means
  --     that intransit quantity has already been calc. across all releases
  --     tied to the blanket. If not, proceed further.
  -- (b) If the group is sourced and the CUM org level is XXX/All SFs
  --     (which is what it should be), calculate intransit quantity
  --     ONLY ONCE across the sourced orgs and store it in the variable
  --     g_IntransitQty.  Then for each sourced group, call
  --     SourceCUMIntransitQty to store a percent of g_IntransitQty
  --     in g_ReconcileTab.  This percentage would come from the sourcing
  --     rules applied in Manage Demand.
  -- (c) If the group is not sourced, then calculate intransit quantity
  --     every time and store the intransit quantity in g_ReconcileTab.
  --
  IF (v_intransit_calc_basis = 'CUSTOMER_CUM') THEN
   --{
   IF ((x_Group_rec.blanket_number IS NOT NULL AND NOT g_BlktIntransits) OR
       (x_Group_rec.blanket_number IS NULL)) THEN
    --
    PopulateReconcileCumRec(x_Sched_rec, x_Group_rec); --Bugfix 7007638
    --{
    IF (x_Group_rec.isSourced AND
        x_Group_rec.setup_terms_rec.cum_org_level_code IN
        ('SHIP_TO_ALL_SHIP_FROMS', 'BILL_TO_ALL_SHIP_FROMS',
          'DELIVER_TO_ALL_SHIP_FROMS')) THEN
     --{
     IF g_RecCUM_tab.COUNT > 0 THEN

      FOR v_Count IN 1..g_RecCUM_tab.COUNT LOOP --Bugfix 7007638
       --
       IF (g_IntransitQty = FND_API.G_MISS_NUM) THEN
        CalculateCUMIntransit(x_Sched_rec, x_Group_rec, g_RecCUM_tab(v_Count).line_id, g_IntransitQty);
       END IF;
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'Intransit Qty', g_IntransitQty);
       END IF;
       --
       IF g_IntransitQty > 0 THEN
         SourceCUMIntransitQty(x_Sched_rec, x_Group_rec, g_RecCUM_tab(v_Count));
       END IF;
       --
       g_IntransitQty := FND_API.G_MISS_NUM; --Bugfix 7007638
       --
      END LOOP; --Bugfix 7007638

     END IF; --if count
     --}
    ELSE --if cum_org_level_code SHIP_TO_SHIP_FROM
     --{
     IF g_RecCUM_tab.COUNT > 0 THEN
      --
      FOR v_Count IN 1..g_RecCUM_tab.COUNT LOOP --Bugfix 7007638
       --
       CalculateCUMIntransit(x_Sched_rec, x_Group_rec, g_RecCUM_tab(v_Count).line_id, v_Intransit);
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'Intransit Qty', v_Intransit);
       END IF;
       --
       IF v_Intransit > 0 THEN
        --
        v_Key_rec.rlm_line_id         := null;
        v_Key_rec.req_rec.customer_id := x_Group_rec.customer_id;
        v_Key_rec.req_rec.customer_item_id := x_Group_rec.customer_item_id;
        v_Key_rec.req_rec.inventory_item_id := x_Group_rec.inventory_item_id;
        v_Key_rec.req_rec.ship_to_org_id := x_Group_rec.ship_to_org_id;
        v_Key_rec.req_rec.order_header_id := x_Group_rec.order_header_id;
        v_Key_rec.req_rec.ship_from_org_id := x_Group_rec.ship_from_org_id;
        v_Key_rec.req_rec.shipment_flag := 'SHIPMENT';
        v_Key_rec.req_rec.schedule_type := x_Sched_rec.schedule_type;
        --
        -- Bugfix 7007638 Start
        IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
           v_Key_rec.req_rec.cust_po_number := g_RecCUM_tab(v_Count).purchase_order_number;
        ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
           v_Key_rec.req_rec.industry_attribute1 := g_RecCUM_tab(v_Count).cust_record_year;
        END IF;
        -- Bugfix 7007638 End

        RLM_RD_SV.StoreShipments(x_Sched_rec, x_Group_rec,
                                v_Key_rec, v_Intransit);
        --
       END IF;
       --
       g_IntransitQty := FND_API.G_MISS_NUM; --Bugfix 7007638
       --
      END LOOP; --Bugfix 7007638

     END IF;  --if count
     --}
    END IF; -- cum_org_level_code
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    IF (x_Group_rec.blanket_number IS NOT NULL AND NOT g_BlktIntransits) THEN
     g_BlktIntransits := TRUE;
    END IF;
    --
    RETURN;
    --}
   END IF; -- blanket_number
   --}
  ELSIF v_intransit_calc_basis IN (k_RECEIPT, k_SHIPMENT) THEN
    --{
    InitializeIntransitParam(x_Sched_rec, x_Group_rec,
                               v_intransit_calc_basis, v_Shipper_rec,
                               v_Shipment_date);
    --
    InitializeMatchRec(x_Sched_rec, x_Group_rec, v_match_ref);
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'x_Sched_rec.schedule_type', x_Sched_rec.schedule_type);
      rlm_core_sv.dlog(k_DEBUG, 'x_Sched_rec.sched_generation_date', x_Sched_rec.sched_generation_date);
    END IF;
    --
    WHILE FetchMatchRec(v_match_ref, v_match_rec) LOOP
      --
      PrintMatchRec(v_match_rec);
      --
      IF NOT AlreadyMatched(x_Group_rec, v_match_rec, v_Index) Then
        --
        RLM_EXTINTERFACE_SV.getIntransitQty (
                          x_Group_rec.customer_id,
                          x_Group_rec.ship_to_org_id,
                          x_Group_rec.intmed_ship_to_org_id, --Bugfix 5911991
                          x_Group_rec.ship_from_org_id,
                          x_Group_rec.inventory_item_id,
	                  x_Group_rec.customer_item_id,
                          x_Group_rec.order_header_id,
	    		  NVL(x_Group_rec.blanket_number, k_NNULL),
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
            rlm_core_sv.dlog(k_DEBUG, 'v_return_status', v_return_status);
            rlm_core_sv.dlog(k_DEBUG, 'v_InTransitQty', v_InTransitQty);
      	  END IF;
      	  --
      	  IF v_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       	    --
            IF (l_debug <> -1) THEN
              rlm_core_sv.dpop(k_SDEBUG, 'GetIntransitQtyAPI Failed');
       	    END IF;
       	    --
       	    RAISE e_group_error;
       	    --
      	  ELSIF v_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            --
            IF (l_debug <> -1) THEN
              rlm_core_sv.dpop(k_SDEBUG, 'GetIntransitQtyAPI Failed');
            END IF;
            --
            RAISE e_group_error;
            --
          END IF;

      	--
        -- to do JH : The line id os from schedule lines and not interface lines
      	-- what implications of keeping this line id and also or line id as null?
      	--

      	IF v_InTransitQty > 0 THEN
          --
          v_Key_rec.rlm_line_id         := null;
          --
          v_Key_rec.req_rec.customer_id := x_Group_rec.customer_id;
          v_Key_rec.req_rec.customer_item_id := x_Group_rec.customer_item_id;
          v_Key_rec.req_rec.inventory_item_id := x_Group_rec.inventory_item_id;
          --v_Key_rec.req_rec.bill_to_address_id := x_Group_rec.bill_to_address_id;
          v_Key_rec.req_rec.ship_to_org_id := x_Group_rec.ship_to_org_id;
          --v_Key_rec.req_rec.intrmd_ship_to_id := x_Group_rec.intrmd_ship_to_id;
          v_Key_rec.req_rec.order_header_id := x_Group_rec.order_header_id;
          v_Key_rec.req_rec.ship_from_org_id := x_Group_rec.ship_from_org_id;
          v_Key_rec.req_rec.shipment_flag := 'SHIPMENT';
          v_Key_rec.req_rec.cust_production_line := v_match_rec.cust_production_line;
          v_Key_rec.req_rec.customer_dock_code := v_match_rec.customer_dock_code;
          v_Key_rec.req_rec.cust_po_number := v_match_rec.cust_po_number;
          v_Key_rec.req_rec.customer_item_revision := v_match_rec.customer_item_revision;
          v_Key_rec.req_rec.customer_job := v_match_rec.customer_job;
          v_Key_rec.req_rec.cust_model_serial_number := v_match_rec.cust_model_serial_number;
          v_Key_rec.req_rec.cust_production_seq_num := v_match_rec.cust_production_seq_num;
          v_Key_rec.req_rec.industry_attribute1 := v_match_rec.industry_attribute1;
          v_Key_rec.req_rec.industry_attribute2 := v_match_rec.industry_attribute2;
          v_Key_rec.req_rec.industry_attribute3 := v_match_rec.industry_attribute3;
          v_Key_rec.req_rec.industry_attribute4 := v_match_rec.industry_attribute4;
          v_Key_rec.req_rec.industry_attribute5 := v_match_rec.industry_attribute5;
          v_Key_rec.req_rec.industry_attribute6 := v_match_rec.industry_attribute6;
          v_Key_rec.req_rec.industry_attribute7 := v_match_rec.industry_attribute7;
          v_Key_rec.req_rec.industry_attribute8 := v_match_rec.industry_attribute8;
          v_Key_rec.req_rec.industry_attribute9 := v_match_rec.industry_attribute9;
          v_Key_rec.req_rec.industry_attribute10 := v_match_rec.industry_attribute10;
          v_Key_rec.req_rec.industry_attribute11 := v_match_rec.industry_attribute11;
          v_Key_rec.req_rec.industry_attribute12 := v_match_rec.industry_attribute12;
          v_Key_rec.req_rec.industry_attribute13 := v_match_rec.industry_attribute13;
          v_Key_rec.req_rec.industry_attribute14 := v_match_rec.industry_attribute14;
          v_Key_rec.req_rec.industry_attribute15 := v_match_rec.industry_attribute15;
          v_Key_rec.req_rec.attribute1 := v_match_rec.attribute1;
          v_Key_rec.req_rec.attribute2 := v_match_rec.attribute2;
          v_Key_rec.req_rec.attribute3 := v_match_rec.attribute3;
          v_Key_rec.req_rec.attribute4 := v_match_rec.attribute4;
          v_Key_rec.req_rec.attribute5 := v_match_rec.attribute5;
          v_Key_rec.req_rec.attribute6 := v_match_rec.attribute6;
          v_Key_rec.req_rec.attribute7 := v_match_rec.attribute7;
          v_Key_rec.req_rec.attribute8 := v_match_rec.attribute8;
          v_Key_rec.req_rec.attribute9 := v_match_rec.attribute9;
          v_Key_rec.req_rec.attribute10 := v_match_rec.attribute10;
          v_Key_rec.req_rec.attribute11 := v_match_rec.attribute11;
          v_Key_rec.req_rec.attribute12 := v_match_rec.attribute12;
          v_Key_rec.req_rec.attribute13 := v_match_rec.attribute13;
          v_Key_rec.req_rec.attribute14 := v_match_rec.attribute14;
          v_Key_rec.req_rec.attribute15 := v_match_rec.attribute15;
          v_Key_rec.req_rec.schedule_type := x_Sched_rec.schedule_type;
          v_Key_rec.req_rec.blanket_number := x_Group_rec.blanket_number;
          --
          StoreShipments(x_Sched_rec, x_Group_rec, v_Key_rec, v_IntransitQty);
          --
        END IF; /* if intransit_qty > 0 */
        --
        InsertIntransitMatchRec(v_match_rec, v_IntransitQty);
        --
      END IF; /* if not alreadymatched */
      --
    END LOOP; /* while fetchmatchrec */
    --}
  END IF; /*Intransit Basis*/
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    --
    WHEN e_cumDiscrete THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'Intransit Calculations not needed as more than one CUM lines exist');
         rlm_core_sv.dpop(k_SDEBUG,'e_cumDiscrete');
      END IF;
      --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.SynchronizeShipments',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END SynchronizeShipments;


/*===========================================================================

  FUNCTION MatchWithin

===========================================================================*/
FUNCTION MatchWithin(x_WithinString IN VARCHAR2,
                     x_ColumnName IN VARCHAR2)
RETURN VARCHAR2
IS

  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'MatchWithin');
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN('Y');

EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.MatchWithin',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END MatchWithin;


/*===========================================================================

  FUNCTION MatchAcross

===========================================================================*/
FUNCTION MatchAcross(x_AcrossString IN VARCHAR2,
                     x_ColumnName IN VARCHAR2)
RETURN VARCHAR2
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'MatchAcross');
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN('Y');

EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.MatchAcross',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END MatchAcross;


/*===========================================================================

  PROCEDURE StoreShipments

===========================================================================*/
PROCEDURE StoreShipments(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                         x_Key_rec IN RLM_RD_SV.t_Key_rec,
                         x_Quantity IN NUMBER)
IS

  v_Index  NUMBER;
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'StoreShipments');
  END IF;
  --
  -- start of bug fix 4223359
  --
  IF x_Quantity > 0 THEN
     --
     IF RLM_TPA_SV.MatchShipments(x_Group_rec, x_Key_rec.req_rec, v_Index) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'v_index',v_Index);
       END IF;
       --
       g_Reconcile_tab(v_Index).ordered_quantity :=
         NVL(g_Reconcile_tab(v_Index).ordered_quantity,0) + NVL(x_Quantity,0);
       --
     ELSE
       --
       IF g_Reconcile_tab.First is NULL THEN
            --
            g_Reconcile_tab(1) := x_Key_rec.req_rec;
            g_Reconcile_tab(1).ordered_quantity := NVL(x_Quantity, 0);
            --
       ELSE
            --
            g_Reconcile_tab(g_Reconcile_tab.LAST+1) := x_Key_rec.req_rec;
            g_Reconcile_tab(g_Reconcile_tab.LAST).ordered_quantity := NVL(x_Quantity,0);
            --
       END IF;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'x_quantity',x_quantity);
          rlm_core_sv.dlog(k_DEBUG,'Added to reconcile table x_index',g_Reconcile_tab.LAST);
       END IF;
       --
     END IF;
     --
  ELSE
     --
     IF MatchReconcile(x_Group_rec, x_Key_rec.req_rec, v_Index) THEN
        --
        g_Reconcile_tab(v_Index).ordered_quantity :=
          NVL(g_Reconcile_tab(v_Index).ordered_quantity,0) + NVL(x_Quantity,0);
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'v_index',v_Index);
           rlm_core_sv.dlog(k_DEBUG,'g_reconcile_tab.ordered_quantity',g_Reconcile_tab(v_Index).ordered_quantity);
        END IF;
        --
     ELSE
        --
        IF g_Reconcile_tab.First is NULL THEN
            --
            g_Reconcile_tab(1) := x_Key_rec.req_rec;
            g_Reconcile_tab(1).ordered_quantity := NVL(x_Quantity, 0);
            --
        ELSE
            --
            g_Reconcile_tab(g_Reconcile_tab.LAST+1) := x_Key_rec.req_rec;
            g_Reconcile_tab(g_Reconcile_tab.LAST).ordered_quantity := NVL(x_Quantity,0);
            --
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'New Line x_quantity',x_quantity);
           rlm_core_sv.dlog(k_DEBUG,'Added to reconcile table x_index',g_Reconcile_tab.LAST);
        END IF;
        --
     END IF;
     --
  END IF;
  --
  -- end of bug fix 4223359
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.StoreShipments',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END StoreShipments;


/*===========================================================================

  PROCEDURE ReconcileShipments

===========================================================================*/
PROCEDURE ReconcileShipments(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                    x_Key_rec IN RLM_RD_SV.t_Key_rec,
                    x_Quantity IN OUT NOCOPY NUMBER)
IS

  v_Index  NUMBER;
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ReconcileShipments');
  END IF;
  --
  IF RLM_TPA_SV.MatchShipments(x_Group_rec, x_Key_rec.req_rec, v_Index) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'x_quantity',x_quantity);
       rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab(v_Index).ordered_quantity',
                              g_Reconcile_tab(v_Index).ordered_quantity);
    END IF;
    --
    -- start of bug fix 4223359
    --
    IF nvl(g_Reconcile_tab(v_Index).ordered_quantity,0) > NVL(x_Quantity,0)
    THEN
      --
      g_Reconcile_tab(v_Index).ordered_quantity :=
                               NVL(g_Reconcile_tab(v_Index).ordered_quantity,0)
                                - NVL(x_Quantity,0);
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'new g_Reconcile_tab(v_Index).ordered_quantity',
                                g_Reconcile_tab(v_Index).ordered_quantity);
      END IF;
      --
      x_Quantity := 0;
      --
    ELSE
      --
      x_Quantity := NVL(x_Quantity,0)
                         - nvl(g_Reconcile_tab(v_Index).ordered_quantity,0);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_quantity',x_quantity);
         rlm_core_sv.dlog(k_DEBUG,'Entry getting deleted from Reconcile Table', v_Index);
         rlm_core_sv.dlog(k_DEBUG,'deleted g_Reconcile_tab(v_Index).ordered_quantity',
                                g_Reconcile_tab(v_Index).ordered_quantity);

      END IF;
      --
      g_Reconcile_tab.DELETE(v_Index);
      --
    END IF;
    --
  END IF;
  --
  -- end of bug fix 4223359
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.ReconcileShipments',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ReconcileShipments;

/*===========================================================================

  FUNCTION MatchShipments

===========================================================================*/
FUNCTION MatchShipments(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                        x_Current_rec IN RLM_RD_SV.t_Generic_rec,
                        x_Index OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  x_progress          VARCHAR2(3) := '010';

  v_Index        NUMBER;
  v_Count        NUMBER;
  b_Match        BOOLEAN := FALSE;
  v_intransit_calc_basis        VARCHAR2(15);

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'MatchShipments');
  END IF;
  --
  v_intransit_calc_basis := UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.COUNT', g_Reconcile_tab.COUNT);
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.FIRST', g_Reconcile_tab.FIRST);
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.LAST', g_Reconcile_tab.LAST);
  END IF;
  --
  -- Bug 2261743
  --
  IF g_Reconcile_tab.COUNT <> 0 THEN
    --
    -- 4223359 Changed the for loop to while as the entries in the PL/SQL table could be non-contiguous
    --
    v_Count :=  g_Reconcile_tab.FIRST;
    --
    WHILE v_Count is NOT NULL LOOP
      --
      IF nvl(g_Reconcile_tab(v_Count).shipment_flag,k_VNULL) = 'SHIPMENT' THEN
        --
        IF( v_intransit_calc_basis = 'CUSTOMER_CUM') THEN
          --
          IF Match_PO_RY_Reconcile(x_Group_rec, x_Current_rec, v_Index) THEN --Bugfix 7007638
            b_Match := TRUE;
            x_Index := v_Index;  --Bugfix 7007638
            EXIT;
          END IF;
          --
        ELSE
          --
          IF MatchReconcile(x_Group_rec, x_Current_rec, v_Index) THEN
            b_Match := TRUE;
            x_Index := v_Index;
            EXIT;
          END IF;
          --
        END IF;
        --
      END IF;
      --
      v_Count := g_Reconcile_tab.next(v_Count);
      --
    END LOOP;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'b_match', b_Match);
     rlm_core_sv.dlog(k_DEBUG, 'Returning index', x_Index);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN(b_Match);

EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.MatchShipments',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END MatchShipments;

/*===========================================================================

  FUNCTION Matchfrozen

  Description: Added this function for bug 4223359
  this is required to find duplicate records in the g_reconcile_tab to
  print the aggregate frozenQty message

===========================================================================*/
FUNCTION MatchFrozen(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                     x_Index2 IN  NUMBER,
                     x_Current_rec IN t_Generic_rec,
                     x_Index OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  x_progress          VARCHAR2(3) := '010';
  v_Index        NUMBER;
  v_Count        NUMBER;
  b_Match        BOOLEAN := FALSE;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'MatchFrozen');
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.COUNT', g_Reconcile_tab.COUNT);
     rlm_core_sv.dlog(k_DEBUG,'x_index2', x_Index2);
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.LAST', g_Reconcile_tab.LAST);
     rlm_core_sv.dlog(k_DEBUG,'x_current_rec.schedule_type',  x_Current_rec.schedule_type);
  END IF;
  --
  IF g_Reconcile_tab.COUNT <> 0 THEN
    --
    v_Count := x_Index2;
    --
    WHILE v_Count IS NOT NULL LOOP
      --{
      b_Match := TRUE;
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'schedule_type',  g_Reconcile_tab(v_Count).schedule_type);
      END IF;
      --
      IF x_Current_rec.schedule_type = g_Reconcile_tab(v_Count).schedule_type THEN
        --{
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'Match Within Schedules only ');
        END IF;
        --
        IF  x_Group_rec.match_within_rec.cust_po_number = 'Y' THEN
         IF NVL(x_Current_rec.cust_po_number, k_VNULL) <>
            NVL(g_Reconcile_tab(v_Count).cust_po_number, k_VNULL) THEN
           b_Match := FALSE;
         END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_po_number', x_Current_rec.cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_po_number', g_Reconcile_tab(v_Count).cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.customer_item_revision = 'Y' THEN
            IF NVL(x_Current_rec.customer_item_revision, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_item_revision, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_item_revision', x_Current_rec.customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_item_revision',
                                   g_Reconcile_tab(v_Count).customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.customer_dock_code = 'Y' THEN
            IF NVL(x_Current_rec.customer_dock_code, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_dock_code, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_dock_code', x_Current_rec.customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_dock_code', g_Reconcile_tab(v_Count).customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.customer_job = 'Y' THEN
            IF NVL(x_Current_rec.customer_job, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_job, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_job', x_Current_rec.customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_job', g_Reconcile_tab(v_Count).customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.cust_production_line = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_line, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_line, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_line', x_Current_rec.cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_line', g_Reconcile_tab(v_Count).cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.cust_model_serial_number = 'Y' THEN
            IF NVL(x_Current_rec.cust_model_serial_number, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_model_serial_number, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_model_serial_number', x_Current_rec.cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_model_serial_number',
					g_Reconcile_tab(v_Count).cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.cust_production_seq_num = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_seq_num, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_seq_num, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_seq_num', x_Current_rec.cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_seq_num',
			    g_Reconcile_tab(v_Count).cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute1', x_Current_rec.industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute1', g_Reconcile_tab(v_Count).industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute2', x_Current_rec.industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute2', g_Reconcile_tab(v_Count).industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute4', x_Current_rec.industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute4', g_Reconcile_tab(v_Count).industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute5', x_Current_rec.industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute5', g_Reconcile_tab(v_Count).industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute6', x_Current_rec.industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute6', g_Reconcile_tab(v_Count).industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute10', x_Current_rec.industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute10', g_Reconcile_tab(v_Count).industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute11', x_Current_rec.industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute11', g_Reconcile_tab(v_Count).industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute12', x_Current_rec.industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute12', g_Reconcile_tab(v_Count).industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute13', x_Current_rec.industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute13', g_Reconcile_tab(v_Count).industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute14', x_Current_rec.industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute14', g_Reconcile_tab(v_Count).industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute15', x_Current_rec.industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute15', g_Reconcile_tab(v_Count).industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute1', x_Current_rec.attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute1', g_Reconcile_tab(v_Count).attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute2 = 'Y' THEN
            IF NVL(x_Current_rec.attribute2, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute2, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'uattribute2', x_Current_rec.attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute2', g_Reconcile_tab(v_Count).attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute3 = 'Y' THEN
            IF NVL(x_Current_rec.attribute3, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute3, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute3', x_Current_rec.attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute3', g_Reconcile_tab(v_Count).attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute4', x_Current_rec.attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute4', g_Reconcile_tab(v_Count).attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute5', x_Current_rec.attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute5', g_Reconcile_tab(v_Count).attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute6', x_Current_rec.attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute6', g_Reconcile_tab(v_Count).attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute7 = 'Y' THEN
            IF NVL(x_Current_rec.attribute7, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute7, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute7', x_Current_rec.attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute7', g_Reconcile_tab(v_Count).attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute8 = 'Y' THEN
            IF NVL(x_Current_rec.attribute8, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute8, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute8', x_Current_rec.attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute8', g_Reconcile_tab(v_Count).attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute9 = 'Y' THEN
            IF NVL(x_Current_rec.attribute9, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute9, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute9', x_Current_rec.attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute9', g_Reconcile_tab(v_Count).attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute10', x_Current_rec.attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute10', g_Reconcile_tab(v_Count).attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute11', x_Current_rec.attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute11', g_Reconcile_tab(v_Count).attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute12', x_Current_rec.attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute12', g_Reconcile_tab(v_Count).attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute13', x_Current_rec.attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute13', g_Reconcile_tab(v_Count).attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute14', x_Current_rec.attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute14', g_Reconcile_tab(v_Count).attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute15', x_Current_rec.attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute15', g_Reconcile_tab(v_Count).attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        --
        --}
     ELSIF x_Current_rec.schedule_type <> g_Reconcile_tab(v_Count).schedule_type THEN
        --
        --
        --{
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'Match across Schedules only ');
        END IF;
        --
        IF  x_Group_rec.match_across_rec.cust_po_number = 'Y' THEN
         IF NVL(x_Current_rec.cust_po_number, k_VNULL) <>
            NVL(g_Reconcile_tab(v_Count).cust_po_number, k_VNULL) THEN
           b_Match := FALSE;
         END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_po_number', x_Current_rec.cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_po_number', g_Reconcile_tab(v_Count).cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.customer_item_revision = 'Y' THEN
            IF NVL(x_Current_rec.customer_item_revision, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_item_revision, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_item_revision', x_Current_rec.customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_item_revision',
                                   g_Reconcile_tab(v_Count).customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.customer_dock_code = 'Y' THEN
            IF NVL(x_Current_rec.customer_dock_code, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_dock_code, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_dock_code', x_Current_rec.customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_dock_code', g_Reconcile_tab(v_Count).customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.customer_job = 'Y' THEN
            IF NVL(x_Current_rec.customer_job, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_job, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_job', x_Current_rec.customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_job', g_Reconcile_tab(v_Count).customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.cust_production_line = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_line, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_line, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_line', x_Current_rec.cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_line', g_Reconcile_tab(v_Count).cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.cust_model_serial_number = 'Y' THEN
            IF NVL(x_Current_rec.cust_model_serial_number, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_model_serial_number, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_model_serial_number', x_Current_rec.cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_model_serial_number',
					g_Reconcile_tab(v_Count).cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.cust_production_seq_num = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_seq_num, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_seq_num, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_seq_num', x_Current_rec.cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_seq_num',
				g_Reconcile_tab(v_Count).cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute1', x_Current_rec.industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute1', g_Reconcile_tab(v_Count).industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute2 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute2, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute2, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute2', x_Current_rec.industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute2', g_Reconcile_tab(v_Count).industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute4', x_Current_rec.industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute4', g_Reconcile_tab(v_Count).industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute5', x_Current_rec.industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute5', g_Reconcile_tab(v_Count).industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute6', x_Current_rec.industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute6', g_Reconcile_tab(v_Count).industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute10', x_Current_rec.industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute10', g_Reconcile_tab(v_Count).industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute11', x_Current_rec.industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute11', g_Reconcile_tab(v_Count).industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute12', x_Current_rec.industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute12', g_Reconcile_tab(v_Count).industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute13', x_Current_rec.industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute13', g_Reconcile_tab(v_Count).industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute14', x_Current_rec.industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute14', g_Reconcile_tab(v_Count).industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute15', x_Current_rec.industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute15', g_Reconcile_tab(v_Count).industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute1', x_Current_rec.attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute1', g_Reconcile_tab(v_Count).attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute2 = 'Y' THEN
            IF NVL(x_Current_rec.attribute2, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute2, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'uattribute2', x_Current_rec.attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute2', g_Reconcile_tab(v_Count).attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute3 = 'Y' THEN
            IF NVL(x_Current_rec.attribute3, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute3, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute3', x_Current_rec.attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute3', g_Reconcile_tab(v_Count).attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute4', x_Current_rec.attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute4', g_Reconcile_tab(v_Count).attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute5', x_Current_rec.attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute5', g_Reconcile_tab(v_Count).attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute6', x_Current_rec.attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute6', g_Reconcile_tab(v_Count).attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute7 = 'Y' THEN
            IF NVL(x_Current_rec.attribute7, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute7, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute7', x_Current_rec.attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute7', g_Reconcile_tab(v_Count).attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute8 = 'Y' THEN
            IF NVL(x_Current_rec.attribute8, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute8, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute8', x_Current_rec.attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute8', g_Reconcile_tab(v_Count).attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute9 = 'Y' THEN
            IF NVL(x_Current_rec.attribute9, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute9, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute9', x_Current_rec.attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute9', g_Reconcile_tab(v_Count).attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute10', x_Current_rec.attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute10', g_Reconcile_tab(v_Count).attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute11', x_Current_rec.attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute11', g_Reconcile_tab(v_Count).attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute12', x_Current_rec.attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute12', g_Reconcile_tab(v_Count).attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute13', x_Current_rec.attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute13', g_Reconcile_tab(v_Count).attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute14', x_Current_rec.attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute14', g_Reconcile_tab(v_Count).attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute15', x_Current_rec.attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute15', g_Reconcile_tab(v_Count).attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --}
      ELSE
        --{
         b_Match := FALSE;
         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
         END IF;
        --}
      END IF;
      --
      IF b_Match THEN
        x_Index := v_Count;
        EXIT;
      END IF;
      --
      v_Count := g_Reconcile_Tab.next(v_Count);
      --
      --}
    END LOOP;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'b_match', b_Match);
     rlm_core_sv.dlog(k_DEBUG,'x_index', x_index);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN(b_Match);
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.MatchFrozen',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END MatchFrozen;


/*===========================================================================

  FUNCTION MatchReconcile

===========================================================================*/
FUNCTION MatchReconcile(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                        x_Current_rec IN t_Generic_rec,
                        x_Index OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  x_progress     VARCHAR2(3) := '010';
  v_Count        NUMBER;
  v_Index        NUMBER;
  b_Match        BOOLEAN := FALSE;
  v_intransit_calc_basis  VARCHAR2(30) ;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'MatchReconcile');
     rlm_core_sv.dlog(k_DEBUG, 'x_Current_rec.schedule_type',
                                x_Current_rec.schedule_type);
  END IF;
  --
  -- Bug 2261743
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.COUNT', g_Reconcile_tab.COUNT);
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.FIRST', g_Reconcile_tab.FIRST);
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.LAST', g_Reconcile_tab.LAST);
  END IF;

  IF g_Reconcile_tab.COUNT <> 0 THEN
    --
    -- bug 4223359  changed the for loop to while as the PL/SQL table to null entries in between
    --
    v_Count := g_Reconcile_tab.FIRST;
    --
    WHILE v_Count IS NOT NULL LOOP
      --{
      b_Match := TRUE;
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG, 'g_Reconcile_Tab('||v_Count||').schedule_type',
                                  g_Reconcile_Tab(v_Count).schedule_type);
      END IF;
       -- Bug 5608510
       v_intransit_calc_basis := UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis);
       --
       IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG, 'Intransit calc basis ',x_Group_rec.setup_terms_rec.intransit_calc_basis);
       END IF;
      --
      IF x_Current_rec.schedule_type = g_Reconcile_tab(v_Count).schedule_type THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'Match Within Schedules only ');
        END IF;
        --
        IF  x_Group_rec.match_within_rec.cust_po_number = 'Y' THEN
         IF NVL(x_Current_rec.cust_po_number, k_VNULL) <>
            NVL(g_Reconcile_tab(v_Count).cust_po_number, k_VNULL) THEN
           b_Match := FALSE;
         END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_po_number', x_Current_rec.cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_po_number', g_Reconcile_tab(v_Count).cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.customer_item_revision = 'Y' THEN
            IF NVL(x_Current_rec.customer_item_revision, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_item_revision, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_item_revision', x_Current_rec.customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_item_revision',
                                   g_Reconcile_tab(v_Count).customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.customer_dock_code = 'Y' THEN
            IF NVL(x_Current_rec.customer_dock_code, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_dock_code, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_dock_code', x_Current_rec.customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_dock_code', g_Reconcile_tab(v_Count).customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.customer_job = 'Y' THEN
            IF NVL(x_Current_rec.customer_job, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_job, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_job', x_Current_rec.customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_job', g_Reconcile_tab(v_Count).customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.cust_production_line = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_line, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_line, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_line', x_Current_rec.cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_line', g_Reconcile_tab(v_Count).cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.cust_model_serial_number = 'Y' THEN
            IF NVL(x_Current_rec.cust_model_serial_number, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_model_serial_number, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_model_serial_number', x_Current_rec.cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_model_serial_number',
					g_Reconcile_tab(v_Count).cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.cust_production_seq_num = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_seq_num, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_seq_num, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_seq_num', x_Current_rec.cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_seq_num',
			    g_Reconcile_tab(v_Count).cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute1', x_Current_rec.industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute1', g_Reconcile_tab(v_Count).industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
	END IF;
       --
    --Bug 5608510
      --
      IF v_intransit_calc_basis = 'PART_SHIP_LINES' THEN
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute2 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute2, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute2, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
	--
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute2', x_Current_rec.industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute2', g_Reconcile_tab(v_Count).industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
	      IF x_Group_rec.match_within_rec.request_date  = 'Y' THEN
               IF NVL(x_Current_rec.request_date, k_DNULL) <>
               NVL(g_Reconcile_tab(v_Count).request_date, k_DNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
	--
	--
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'request_date', x_Current_rec.request_date);
           rlm_core_sv.dlog(k_DEBUG, 'rec request_date', g_Reconcile_tab(v_Count).request_date);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
      END IF; --bugfix 5608510 ends
      --
	 IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute4', x_Current_rec.industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute4', g_Reconcile_tab(v_Count).industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute5', x_Current_rec.industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute5', g_Reconcile_tab(v_Count).industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute6', x_Current_rec.industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute6', g_Reconcile_tab(v_Count).industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute10', x_Current_rec.industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute10', g_Reconcile_tab(v_Count).industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute11', x_Current_rec.industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute11', g_Reconcile_tab(v_Count).industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute12', x_Current_rec.industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute12', g_Reconcile_tab(v_Count).industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute13', x_Current_rec.industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute13', g_Reconcile_tab(v_Count).industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute14', x_Current_rec.industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute14', g_Reconcile_tab(v_Count).industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.industry_attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute15', x_Current_rec.industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute15', g_Reconcile_tab(v_Count).industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute1', x_Current_rec.attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute1', g_Reconcile_tab(v_Count).attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute2 = 'Y' THEN
            IF NVL(x_Current_rec.attribute2, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute2, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'uattribute2', x_Current_rec.attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute2', g_Reconcile_tab(v_Count).attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute3 = 'Y' THEN
            IF NVL(x_Current_rec.attribute3, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute3, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute3', x_Current_rec.attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute3', g_Reconcile_tab(v_Count).attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute4', x_Current_rec.attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute4', g_Reconcile_tab(v_Count).attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute5', x_Current_rec.attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute5', g_Reconcile_tab(v_Count).attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute6', x_Current_rec.attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute6', g_Reconcile_tab(v_Count).attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute7 = 'Y' THEN
            IF NVL(x_Current_rec.attribute7, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute7, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute7', x_Current_rec.attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute7', g_Reconcile_tab(v_Count).attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute8 = 'Y' THEN
            IF NVL(x_Current_rec.attribute8, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute8, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute8', x_Current_rec.attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute8', g_Reconcile_tab(v_Count).attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute9 = 'Y' THEN
            IF NVL(x_Current_rec.attribute9, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute9, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute9', x_Current_rec.attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute9', g_Reconcile_tab(v_Count).attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute10', x_Current_rec.attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute10', g_Reconcile_tab(v_Count).attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute11', x_Current_rec.attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute11', g_Reconcile_tab(v_Count).attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute12', x_Current_rec.attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute12', g_Reconcile_tab(v_Count).attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute13', x_Current_rec.attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute13', g_Reconcile_tab(v_Count).attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute14', x_Current_rec.attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute14', g_Reconcile_tab(v_Count).attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_within_rec.attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute15', x_Current_rec.attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute15', g_Reconcile_tab(v_Count).attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        --
        --
     ELSIF x_Current_rec.schedule_type <> g_Reconcile_tab(v_Count).schedule_type THEN
        --
        --
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'Match across Schedules only ');
        END IF;
        --
        IF  x_Group_rec.match_across_rec.cust_po_number = 'Y' THEN
         IF NVL(x_Current_rec.cust_po_number, k_VNULL) <>
            NVL(g_Reconcile_tab(v_Count).cust_po_number, k_VNULL) THEN
           b_Match := FALSE;
         END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_po_number', x_Current_rec.cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_po_number', g_Reconcile_tab(v_Count).cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.customer_item_revision = 'Y' THEN
            IF NVL(x_Current_rec.customer_item_revision, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_item_revision, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_item_revision', x_Current_rec.customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_item_revision',
                                   g_Reconcile_tab(v_Count).customer_item_revision);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.customer_dock_code = 'Y' THEN
            IF NVL(x_Current_rec.customer_dock_code, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_dock_code, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_dock_code', x_Current_rec.customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_dock_code', g_Reconcile_tab(v_Count).customer_dock_code);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.customer_job = 'Y' THEN
            IF NVL(x_Current_rec.customer_job, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).customer_job, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'customer_job', x_Current_rec.customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'rec customer_job', g_Reconcile_tab(v_Count).customer_job);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.cust_production_line = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_line, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_line, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_line', x_Current_rec.cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_line', g_Reconcile_tab(v_Count).cust_production_line);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.cust_model_serial_number = 'Y' THEN
            IF NVL(x_Current_rec.cust_model_serial_number, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_model_serial_number, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_model_serial_number', x_Current_rec.cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_model_serial_number',
					g_Reconcile_tab(v_Count).cust_model_serial_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.cust_production_seq_num = 'Y' THEN
            IF NVL(x_Current_rec.cust_production_seq_num, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).cust_production_seq_num, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_production_seq_num', x_Current_rec.cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_production_seq_num',
				g_Reconcile_tab(v_Count).cust_production_seq_num);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute1', x_Current_rec.industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute1', g_Reconcile_tab(v_Count).industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
	-- Bugfix 5608510
        IF v_intransit_calc_basis = 'PART_SHIP_LINES' THEN

        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute2 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute2, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute2, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --

        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute2', x_Current_rec.industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute2', g_Reconcile_tab(v_Count).industry_attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
	IF b_Match THEN
          IF x_Group_rec.match_across_rec.request_date  = 'Y' THEN
            IF NVL(x_Current_rec.request_date, k_DNULL) <>
               NVL(g_Reconcile_tab(v_Count).request_date, k_DNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
	--
	--
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'request_date', x_Current_rec.request_date);
           rlm_core_sv.dlog(k_DEBUG, 'rec request_date', g_Reconcile_tab(v_Count).request_date);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
      END IF ; -- bugfix 5608510
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute4', x_Current_rec.industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute4', g_Reconcile_tab(v_Count).industry_attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute5', x_Current_rec.industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute5', g_Reconcile_tab(v_Count).industry_attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute6', x_Current_rec.industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute6', g_Reconcile_tab(v_Count).industry_attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute10', x_Current_rec.industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute10', g_Reconcile_tab(v_Count).industry_attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute11', x_Current_rec.industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute11', g_Reconcile_tab(v_Count).industry_attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute12', x_Current_rec.industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute12', g_Reconcile_tab(v_Count).industry_attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute13', x_Current_rec.industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute13', g_Reconcile_tab(v_Count).industry_attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute14', x_Current_rec.industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute14', g_Reconcile_tab(v_Count).industry_attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.industry_attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.industry_attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute15', x_Current_rec.industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute15', g_Reconcile_tab(v_Count).industry_attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute1 = 'Y' THEN
            IF NVL(x_Current_rec.attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute1', x_Current_rec.attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute1', g_Reconcile_tab(v_Count).attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute2 = 'Y' THEN
            IF NVL(x_Current_rec.attribute2, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute2, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'uattribute2', x_Current_rec.attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute2', g_Reconcile_tab(v_Count).attribute2);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute3 = 'Y' THEN
            IF NVL(x_Current_rec.attribute3, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute3, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute3', x_Current_rec.attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute3', g_Reconcile_tab(v_Count).attribute3);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute4 = 'Y' THEN
            IF NVL(x_Current_rec.attribute4, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute4, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute4', x_Current_rec.attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute4', g_Reconcile_tab(v_Count).attribute4);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute5 = 'Y' THEN
            IF NVL(x_Current_rec.attribute5, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute5, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute5', x_Current_rec.attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute5', g_Reconcile_tab(v_Count).attribute5);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute6 = 'Y' THEN
            IF NVL(x_Current_rec.attribute6, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute6, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute6', x_Current_rec.attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute6', g_Reconcile_tab(v_Count).attribute6);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute7 = 'Y' THEN
            IF NVL(x_Current_rec.attribute7, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute7, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute7', x_Current_rec.attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute7', g_Reconcile_tab(v_Count).attribute7);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute8 = 'Y' THEN
            IF NVL(x_Current_rec.attribute8, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute8, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute8', x_Current_rec.attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute8', g_Reconcile_tab(v_Count).attribute8);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute9 = 'Y' THEN
            IF NVL(x_Current_rec.attribute9, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute9, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute9', x_Current_rec.attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute9', g_Reconcile_tab(v_Count).attribute9);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute10 = 'Y' THEN
            IF NVL(x_Current_rec.attribute10, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute10, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute10', x_Current_rec.attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute10', g_Reconcile_tab(v_Count).attribute10);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute11 = 'Y' THEN
            IF NVL(x_Current_rec.attribute11, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute11, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute11', x_Current_rec.attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute11', g_Reconcile_tab(v_Count).attribute11);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute12 = 'Y' THEN
            IF NVL(x_Current_rec.attribute12, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute12, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute12', x_Current_rec.attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute12', g_Reconcile_tab(v_Count).attribute12);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute13 = 'Y' THEN
            IF NVL(x_Current_rec.attribute13, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute13, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute13', x_Current_rec.attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute13', g_Reconcile_tab(v_Count).attribute13);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute14 = 'Y' THEN
            IF NVL(x_Current_rec.attribute14, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute14, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute14', x_Current_rec.attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute14', g_Reconcile_tab(v_Count).attribute14);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.match_across_rec.attribute15 = 'Y' THEN
            IF NVL(x_Current_rec.attribute15, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).attribute15, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'attribute15', x_Current_rec.attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'rec attribute15', g_Reconcile_tab(v_Count).attribute15);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
      END IF;
      --
      IF b_Match THEN
        --
        x_Index := v_Count;
        EXIT;
        --
      END IF;
      --
      v_Count := g_Reconcile_tab.NEXT(v_Count);
      --}
    END LOOP;
    --}
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'b_match', b_Match);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN(b_Match);
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.MatchReconcile',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END MatchReconcile;


/*===========================================================================

  PROCEDURE StoreReconcile

===========================================================================*/
PROCEDURE StoreReconcile(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                         x_Key_rec IN RLM_RD_SV.t_Key_rec,
                         x_Quantity IN NUMBER)
IS
  --
  v_Index  NUMBER;
  x_progress          VARCHAR2(3) := '010';
  --
BEGIN
/*Bug 2263253 : Reverted the modifications done under bug 2194938 */
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'StoreReconcile');
     rlm_core_sv.dlog(k_DEBUG,'Quantity to be reconciled', x_Quantity);
   END IF;
   --
   IF MatchReconcile(x_Group_rec, x_Key_rec.dem_rec, v_Index) THEN
    --
     g_Reconcile_tab(v_Index).ordered_quantity:=
     NVL(g_Reconcile_tab(v_Index).ordered_quantity,0) + x_Quantity;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,' Match Quantity ', g_Reconcile_tab(v_Index).ordered_quantity);
     END IF;
    --
   ELSE
    --
    -- bug 4223359 added this check as the PL/SQL table to null entries in between
    -- and the count is not necessarily the last element of the table
    --
    IF g_Reconcile_tab.First is NULL THEN
        --
        g_Reconcile_tab(1) := x_Key_rec.dem_rec;
        g_Reconcile_tab(1).ordered_quantity := x_Quantity;
        --
     ELSE
        --
        g_Reconcile_tab(g_Reconcile_tab.LAST+1) := x_Key_rec.dem_rec;
        g_Reconcile_tab(g_Reconcile_tab.LAST).ordered_quantity := x_Quantity;
        --
     END IF;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,' New Line Quantity ', g_Reconcile_tab(g_Reconcile_tab.COUNT).ordered_quantity);
     END IF;
    --
   END IF;
    --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.StoreReconcile',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END StoreReconcile;


/*===========================================================================

  PROCEDURE Reconcile

===========================================================================*/
PROCEDURE Reconcile(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                    x_Key_rec IN RLM_RD_SV.t_Key_rec,
                    x_Quantity IN OUT NOCOPY NUMBER)
IS

  v_Index  NUMBER;
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'Reconcile');
  END IF;
  --
  IF MatchReconcile(x_Group_rec, x_Key_rec.req_rec, v_Index) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'v_Index',v_Index);
    END IF;
    --
    --start of  bug 4223359
    --
    IF NVL(g_Reconcile_tab(v_Index).ordered_quantity,0) < 0 THEN
      --
      IF (l_debug <> -1) THEN
         --
         rlm_core_sv.dlog(k_DEBUG,'ordered_quantity',g_Reconcile_tab(v_Index).ordered_quantity);
         rlm_core_sv.dpop(k_SDEBUG);
         --
      END IF;
      --
      return;
      --
    ELSIF NVL(g_Reconcile_tab(v_Index).ordered_quantity,0) > NVL(x_Quantity,0) THEN
      --
      g_Reconcile_tab(v_Index).ordered_quantity :=
                               NVL(g_Reconcile_tab(v_Index).ordered_quantity,0)
                                - NVL(x_Quantity,0);
      --
      x_Quantity := 0;
      --
    ELSE
      --
      IF (l_debug <> -1) THEN
         --
         rlm_core_sv.dlog(k_DEBUG,'x_quantity',x_quantity);
         rlm_core_sv.dlog(k_DEBUG,'Entry getting deleted from Reconcile Table', v_Index);
         rlm_core_sv.dlog(k_DEBUG,'deleted g_Reconcile_tab(v_Index).ordered_quantity',
                                g_Reconcile_tab(v_Index).ordered_quantity);
         --
      END IF;
      --
      x_Quantity := NVL(x_Quantity ,0)-
                    NVL(g_Reconcile_tab(v_Index).ordered_quantity,0);
      g_Reconcile_tab.DELETE(v_Index);
      --
    END IF;
    --
    --end of bug 4223359
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'x_Quantity',x_Quantity);
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.Reconcile',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END Reconcile;


/*===========================================================================

  FUNCTION AttributeChange

===========================================================================*/
FUNCTION AttributeChange(x_Key_rec IN RLM_RD_SV.t_Key_rec)
RETURN BOOLEAN
IS

  b_Result  BOOLEAN := TRUE;
  b_change  BOOLEAN := FALSE;
  c_attr_cur   t_Cursor_ref;
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'AttributeChange');
  END IF;
  --
 /*checks for an attribute change between dem rec
   and req rec. */

  IF NVL(x_key_rec.req_rec.cust_po_number, k_VNULL) <>
      NVL(x_key_rec.dem_rec.cust_po_number, k_VNULL) THEN
      b_Change := TRUE;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.customer_item_revision, k_VNULL) <>
         NVL(x_key_rec.dem_rec.customer_item_revision, k_VNULL) THEN
          b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.customer_dock_code, k_VNULL) <>
           NVL(x_key_rec.dem_rec.customer_dock_code, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.customer_job, k_VNULL) <>
           NVL(x_key_rec.dem_rec.customer_job, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.cust_production_line, k_VNULL) <>
           NVL(x_key_rec.dem_rec.cust_production_line, k_VNULL) THEN
          b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.cust_model_serial_number, k_VNULL) <>
           NVL(x_key_rec.dem_rec.cust_model_serial_number, k_VNULL) THEN
          b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.cust_production_seq_num, k_VNULL) <>
           NVL(x_key_rec.dem_rec.cust_production_seq_num, k_VNULL) THEN
          b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute1, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute1, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute2, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute2, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute4, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute4, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute5, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute5, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute6, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute6, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute10, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute10, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute11, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute11, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute12, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute12, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute13, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute13, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute14, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute14, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.industry_attribute15, k_VNULL) <>
           NVL(x_key_rec.dem_rec.industry_attribute15, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute1, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute1, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute2, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute2, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute3, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute3, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute4, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute4, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute5, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute5, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute6, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute6, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute7, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute7, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute8, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute8, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute9, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute9, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute10, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute10, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute12, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute12, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute13, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute13, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute14, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute14, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;
  IF NOT b_Change THEN
     IF NVL(x_key_rec.req_rec.attribute15, k_VNULL) <>
           NVL(x_key_rec.dem_rec.attribute15, k_VNULL) THEN
        b_Change := TRUE;
     END IF;
  END IF;

  IF b_Change THEN
  IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'true');
    END IF;
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
  END IF;

  RETURN(b_Change);

EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.AttributeChange',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END AttributeChange;


/*===========================================================================

  PROCEDURE ProcessPreHorizonATS

===========================================================================*/
PROCEDURE ProcessPreHorizonATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS

  CURSOR c_PreHorizonDisp (x_OffsetDays NUMBER) IS
    SELECT  line_id, rla_schedule_type_code
    FROM    oe_order_lines
    WHERE   header_id = x_Group_rec.order_header_id
    --global_atp
    AND     ship_from_org_id =
            DECODE(g_ATP, k_ATP, ship_from_org_id,
            x_Group_rec.ship_from_org_id)
    AND     ship_to_org_id = x_Group_rec.ship_to_org_id
    AND     ordered_item_id = x_Group_rec.customer_item_id
    AND     inventory_item_id= x_Group_rec.inventory_item_id
    --pdue, global_atp
    AND     NVL(industry_attribute15, k_VNULL) =
            DECODE(g_ATP, k_ATP, NVL(industry_attribute15, k_VNULL),
            NVL(x_Group_rec.industry_attribute15, k_VNULL))
--bug 2181228
    AND     to_date(industry_attribute2,'RRRR/MM/DD HH24:MI:SS')
            < (TRUNC(SYSDATE) - x_OffsetDays)
    AND     (NVL(ordered_quantity,0) -
            NVL(shipped_quantity,0) > 0)
    AND     authorized_to_ship_flag = k_ATS
    ORDER BY request_date  DESC;

  v_Key_rec                t_Key_rec;
  v_DeleteQty              NUMBER;
  x_progress          VARCHAR2(3) := '010';
  v_line_num          oe_order_lines.line_number%TYPE;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ProcessPreHorizonATS');
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id',x_Group_rec.order_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id',x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_org_id',x_Group_rec.ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id',x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id',x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.disposition_code',x_Group_rec.disposition_code);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.cutoff_days',x_Group_rec.cutoff_days);
  END IF;
  --
  IF x_Group_rec.disposition_code IN (k_CANCEL_ALL, k_CANCEL_AFTER_N_DAYS) THEN
    --
    FOR c_PreHorizonDisp_rec IN c_PreHorizonDisp(nvl(x_Group_rec.cutoff_days,0)) LOOP
      --
      v_Key_rec.oe_line_id := c_PreHorizonDisp_rec.line_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'c_PreHorizonDisp_rec.line_id',
                                     c_PreHorizonDisp_rec.line_id);
      END IF;
      --
      GetDemand(v_Key_rec, x_Group_rec);
      --
      v_Key_rec.req_rec := v_Key_rec.dem_rec;
      --
      IF NVL(c_PreHorizonDisp_rec.rla_schedule_type_code, ' ')
        NOT IN (x_Group_rec.schedule_type_one,
             x_Group_rec.schedule_type_two,
             x_Group_rec.schedule_type_three)
      THEN
        --
        SELECT line_number INTO v_line_num
        FROM oe_order_lines_all
        WHERE line_id = c_PreHorizonDisp_rec.line_id;
        --
        rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_WRONG_SCHEDTYPE',
            x_InterfaceHeaderId => x_sched_rec.header_id,
            x_InterfaceLineId => NULL,
            x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
            x_ScheduleLineId => NULL,
            x_OrderHeaderId => x_Group_rec.order_header_id,
            x_Token1 => 'LINENUM',
            x_value1 => v_line_num,
            x_Token2 => 'SCHEDTYPE',
            x_value2 => c_PreHorizonDisp_rec.rla_schedule_type_code );
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'line_number', v_line_num);
           rlm_core_sv.dlog(k_DEBUG,'RLM_WRONG_SCHEDTYPE');
        END IF;
        --
      END IF;
      --
      IF SchedulePrecedence(x_Group_rec, x_sched_rec,c_PreHorizonDisp_rec.rla_schedule_type_code) THEN
        --
        DeleteRequirement(x_Sched_rec, x_Group_rec,
                          v_Key_rec, k_NORECONCILE, v_DeleteQty);
      END IF;
      --
    END LOOP;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN e_group_error THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'group error');
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.ProcessPreHorizonATS',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ProcessPreHorizonATS;


/*===========================================================================

  PROCEDURE ProcessOld
-- NOTE JH: open issue with bucket requirements overlapping end horizon date

===========================================================================*/
PROCEDURE ProcessOld(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS
  --
  -- Bug 3733520 : Modified cursor to select attributes that are
  -- selected in procedure GetDemand().  All calls to GetDemand()
  -- have been replaced with a call to AssignOEAttribValues().
  --
  CURSOR c_OldDemand (x_ATS_start_date DATE,
                      x_NATS_start_date DATE) IS
    SELECT  header_id,
            line_id,
            ship_from_org_id,
            ship_to_org_id,
            ordered_item_id,
            inventory_item_id,
            invoice_to_org_id,
            intmed_ship_to_org_id,
            demand_bucket_type_code,
            rla_schedule_type_code,
            authorized_to_ship_flag ATS,
            ordered_quantity orig_ordered_quantity,
            NVL(ordered_quantity,0) -
            NVL(shipped_quantity,0) ordered_quantity,
            ordered_item,
            item_identifier_type,
            item_type_code,
            DECODE(x_Group_rec.setup_terms_rec.blanket_number, NULL,
                   NULL, blanket_number) blanket_number,
            customer_line_number,
            customer_production_line cust_production_line,
            customer_dock_code,
            request_date,
            schedule_ship_date,
            cust_po_number,
            item_revision customer_item_revision,
            customer_job,
            cust_model_serial_number,
            cust_production_seq_num,
            industry_attribute1,
            industry_attribute2,
            industry_attribute3,
            industry_attribute4,
            industry_attribute5,
            industry_attribute6,
            industry_attribute7,
            industry_attribute8,
            industry_attribute9,
            industry_attribute10,
            industry_attribute11,
            industry_attribute12,
            industry_attribute13,
            industry_attribute14,
            industry_attribute15,
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
            request_date +
                  DECODE(demand_bucket_type_code,
                         k_WEEKLY,6.99999,
                         k_MONTHLY,29.99999,
                         k_QUARTERLY,89.99999,0.99999) end_date_time, --bug 3596869
            DECODE(x_Sched_rec.schedule_purpose,
                   k_ADD,DECODE(rla_schedule_type_code,
                   x_Group_rec.schedule_type_one, 3,
                   x_Group_rec.schedule_type_two, 2,
                   x_Group_rec.schedule_type_three, 1),
            DECODE(rla_schedule_type_code,
                   x_Group_rec.schedule_type_one, 1,
                   x_Group_rec.schedule_type_two, 2,
                   x_Group_rec.schedule_type_three, 3)) schedule_hierarchy
    FROM    oe_order_lines
    WHERE   header_id = x_Group_rec.order_header_id
    AND     open_flag = 'Y' /*2263270*/
    --global_atp
    AND     ship_from_org_id =
            DECODE(g_ATP, k_ATP, ship_from_org_id,
            x_Group_rec.ship_from_org_id)
    AND     ship_to_org_id = x_Group_rec.ship_to_org_id
    AND     ordered_item_id = x_Group_rec.customer_item_id
    AND     inventory_item_id = x_Group_rec.inventory_item_id
    AND     NVL(intmed_ship_to_org_id,k_NNULL)= NVL(x_Group_rec.intmed_ship_to_org_id,k_NNULL) --Bugfix 5911991
    --global_atp
    AND     NVL(industry_attribute15, k_VNULL) =
            DECODE(g_ATP, k_ATP, NVL(industry_attribute15, k_VNULL),
            NVL(x_Group_rec.industry_attribute15, k_VNULL))
    --bug 4223359
    AND     to_date(industry_attribute2,'RRRR/MM/DD HH24:MI:SS')  BETWEEN /*bug3879857*/
            DECODE(authorized_to_ship_flag,k_ATS,
            DECODE(x_group_rec.disposition_code,
                   k_REMAIN_ON_FILE, x_Sched_rec.sched_horizon_start_date,
                   k_REMAIN_ON_FILE_RECONCILE, to_date(industry_attribute2,'RRRR/MM/DD HH24:MI:SS'),
                   TRUNC(SYSDATE) - nvl(x_Group_rec.Cutoff_days,0)), TRUNC(SYSDATE))
             AND TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999
    --bug 2022158 (issue with sched_horizon_end_date timestamp)
    AND     DECODE(x_Sched_rec.schedule_purpose,
                   k_ADD, DECODE(rla_schedule_type_code,
                   x_Group_rec.schedule_type_one, 2,
                   x_Group_rec.schedule_type_two, 3,
                   x_Group_rec.schedule_type_three, 4,0),
                   DECODE(rla_schedule_type_code,
                   x_Group_rec.schedule_type_one, 1,
                   x_Group_rec.schedule_type_two, 2,
                   x_Group_rec.schedule_type_three, 3,0)) <=
            DECODE(x_Sched_rec.schedule_type, x_Group_rec.schedule_type_one, 1,
                   x_Group_rec.schedule_type_two, 2,
                   x_Group_rec.schedule_type_three, 3)
    AND     DECODE(x_Sched_rec.schedule_purpose,
            k_ADD,authorized_to_ship_flag,
            'N') = 'N'
    AND     (NVL(ordered_quantity,0) - NVL(shipped_quantity,0) > 0)
    ORDER BY demand_bucket_type_code, schedule_hierarchy, end_date_time;
  --
  v_Quantity               NUMBER;
  j                        NUMBER;
  v_Index                  NUMBER;
  v_Count                  NUMBER;
  v_Key_rec                t_Key_rec;
  v_DeleteQty              NUMBER;
  c_NewReq_ref             t_Cursor_ref;
  v_Qty_rec                t_Qty_rec;
  v_qty                    NUMBER;
  v_consume_quantity       NUMBER;
  v_newref_qty             NUMBER;
  v_newref_line_id         RLM_INTERFACE_LINES.LINE_ID%TYPE;
  v_line_id                RLM_INTERFACE_LINES.LINE_ID%TYPE;
  c_consume_ref            t_Cursor_ref;
  v_consume_line_tab        t_consume_tab;
  x_progress          VARCHAR2(3) := '010';
  v_line_num               oe_order_lines.line_number%type;
  e_WrongSchedType         EXCEPTION;
  c_OldDemand_rec          t_OEDemand_rec;
  v_ATS_start_date         DATE;
  v_NATS_start_date        DATE;
  v_MatchAttrTxt           VARCHAR2(2000); -- Bug 4297984
  v_del_line_qty           NUMBER :=0;  --Bugfix 6159269
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ProcessOld');
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id', x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id', x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id', x_Group_rec.order_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id',
                                             x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_org_id',
                                             x_Group_rec.ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.schedule_type_one', x_Group_rec.schedule_type_one);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.schedule_type_two',
                                             x_Group_rec.schedule_type_two);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.schedule_type_three',
                                            x_Group_rec.schedule_type_three);
  END IF;
  --
  /* We need to initialize the consume tab before the oldrec because the
     line should be matched against all old lines and consumed accordingly */
  --
  v_consume_line_tab.DELETE;
  --
  --
  -- FP Bug 3933822 jckwok
  IF (TRUNC(SYSDATE) > x_Sched_rec.sched_horizon_start_date)
  THEN
     IF (x_group_rec.disposition_code = k_REMAIN_ON_FILE)
     THEN
        v_ATS_start_date := x_Sched_rec.sched_horizon_start_date;
     ELSIF (x_group_rec.disposition_code = k_CANCEL_AFTER_N_DAYS)
     THEN
        v_ATS_start_date := TRUNC(SYSDATE) - nvl(x_Group_rec.Cutoff_days,0);
     ELSE
        v_ATS_start_date := TRUNC(SYSDATE);
     END IF;

     v_NATS_start_date := TRUNC(SYSDATE);
  ELSE
     v_ATS_start_date := x_Sched_rec.sched_horizon_start_date;
     v_NATS_start_date := x_Sched_rec.sched_horizon_start_date;
  END IF;

  IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_ATS_start_date', v_ATS_start_date);
         rlm_core_sv.dlog(k_DEBUG,'x_NATS_start_date', v_NATS_start_date);
  END IF;

  OPEN c_OldDemand(v_ATS_start_date , v_NATS_start_date);
  --End of FP Bug 3933822 changes --jckwok
  FETCH c_OldDemand INTO c_OldDemand_rec;
  WHILE c_OldDemand%FOUND LOOP
    --
    BEGIN
      --
      IF NVL(c_OldDemand_rec.rla_schedule_type_code, ' ')
         NOT IN (x_Group_rec.schedule_type_one,
             x_Group_rec.schedule_type_two,
             x_Group_rec.schedule_type_three)
      THEN
         RAISE e_WrongSchedType;
      END IF;

      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, '-------------------------------------------');
         rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.line_id', c_OldDemand_rec.line_id);
         rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.schedule_hierarchy',
                                           c_OldDemand_rec.schedule_hierarchy);
         rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.end_date_time',
                                              c_OldDemand_rec.end_date_time);
         rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.schedule_ship_date',
                                              c_OldDemand_rec.schedule_ship_date);
         rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.request_date', c_OldDemand_rec.request_date);
         rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.rla_schedule_type_code',
					c_OldDemand_rec.rla_schedule_type_code);
      END IF;

      --
      /* We do need to select based on the item detail subtype as the weekly
         demand needs to be consumed by the daily demand as the weekly demand needs
         to be replaced by daily. Also we need to take into account the
         schedule date between old demands schedule date and end date.
         We have taken item_detail_type <= demand.item_method_type so that
         firm demand is never replaced by forecast data */
      --
      OPEN c_NewReq_ref FOR
        SELECT  line_id, primary_quantity
        FROM    rlm_interface_lines_all -- Bug 5223933
        WHERE   header_id = x_Sched_rec.header_id
        --global_atp
        AND     ship_from_org_id = x_Group_rec.ship_from_org_id
        AND     ship_to_org_id = x_Group_rec.ship_to_org_id
        AND     customer_item_id = x_Group_rec.customer_item_id
        AND     inventory_item_id= x_Group_rec.inventory_item_id
        AND     order_header_id= x_Group_rec.order_header_id
        AND     item_detail_subtype = c_OldDemand_rec.demand_bucket_type_code
        AND     process_status  IN (rlm_core_sv.k_PS_AVAILABLE,
                                      rlm_core_sv.k_PS_FROZEN_FIRM)
        --bug 2031077
        --AND     NVL(invoice_to_org_id, k_NNULL) =
        --        NVL(c_OldDemand_rec.invoice_to_org_id, k_NNULL)
        -- bug 4502559
        AND     NVL(intmed_ship_to_org_id, k_NNULL) =
                     NVL(c_OldDemand_rec.intmed_ship_to_org_id, k_NNULL)
        AND     NVL(ship_to_org_id, k_NNULL) =
                NVL(c_OldDemand_rec.ship_to_org_id, k_NNULL)
        AND     NVL(cust_production_line, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.cust_production_line, 'Y',
                NVL(c_OldDemand_rec.cust_production_line, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.cust_production_line, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.cust_production_line, k_VNULL),
                NVL(cust_production_line, k_VNULL)),
                NVL(cust_production_line, k_VNULL)))
        AND     NVL(customer_dock_code, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.customer_dock_code, 'Y',
                NVL(c_OldDemand_rec.customer_dock_code, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.customer_dock_code, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.customer_dock_code, k_VNULL),
                NVL(customer_dock_code, k_VNULL)),
                NVL(customer_dock_code, k_VNULL)))
        AND     NVL(request_date, k_DNULL) =
                DECODE(x_Group_rec.match_across_rec.request_date, 'Y',
                NVL(c_OldDemand_rec.request_date, k_DNULL),
                DECODE(x_Group_rec.match_within_rec.request_date, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.request_date, k_DNULL),
                NVL(request_date, k_DNULL)),
                NVL(request_date, k_DNULL)))
        AND     NVL(cust_po_number, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.cust_po_number, 'Y',
                NVL(c_OldDemand_rec.cust_po_number, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.cust_po_number, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.cust_po_number, k_VNULL),
                NVL(cust_po_number, k_VNULL)),
                NVL(cust_po_number, k_VNULL)))
        AND     NVL(customer_item_revision, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.customer_item_revision, 'Y',
                NVL(c_OldDemand_rec.customer_item_revision, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.customer_item_revision, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.customer_item_revision, k_VNULL),
                NVL(customer_item_revision, k_VNULL)),
                NVL(customer_item_revision, k_VNULL)))
        AND     NVL(customer_job, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.customer_job, 'Y',
                NVL(c_OldDemand_rec.customer_job, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.customer_job, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.customer_job, k_VNULL),
                NVL(customer_job, k_VNULL)),
                NVL(customer_job, k_VNULL)))
        AND     NVL(cust_model_serial_number, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.cust_model_serial_number, 'Y',
                NVL(c_OldDemand_rec.cust_model_serial_number, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.cust_model_serial_number, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.cust_model_serial_number, k_VNULL),
                NVL(cust_model_serial_number, k_VNULL)),
                NVL(cust_model_serial_number, k_VNULL)))
        AND     NVL(cust_production_seq_num, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.cust_production_seq_num, 'Y',
                NVL(c_OldDemand_rec.cust_production_seq_num, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.cust_production_seq_num, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.cust_production_seq_num, k_VNULL),
                NVL(cust_production_seq_num, k_VNULL)),
                NVL(cust_production_seq_num, k_VNULL)))
        AND     NVL(industry_attribute1, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute1, 'Y',
                NVL(c_OldDemand_rec.industry_attribute1, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute1, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute1, k_VNULL),
                NVL(industry_attribute1, k_VNULL)),
                NVL(industry_attribute1, k_VNULL)))
        AND     NVL(industry_attribute2, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute2, 'Y',
                NVL(c_OldDemand_rec.industry_attribute2, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute2, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute2, k_VNULL),
                NVL(industry_attribute2, k_VNULL)),
                NVL(industry_attribute2, k_VNULL)))
        AND     NVL(industry_attribute4, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute4, 'Y',
                NVL(c_OldDemand_rec.industry_attribute4, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute4, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute4, k_VNULL),
                NVL(industry_attribute4, k_VNULL)),
                NVL(industry_attribute4, k_VNULL)))
        AND     NVL(industry_attribute5, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute5, 'Y',
                NVL(c_OldDemand_rec.industry_attribute5, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute5, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute5, k_VNULL),
                NVL(industry_attribute5, k_VNULL)),
                NVL(industry_attribute5, k_VNULL)))
        AND     NVL(industry_attribute6, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute6, 'Y',
                NVL(c_OldDemand_rec.industry_attribute6, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute6, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute6, k_VNULL),
                NVL(industry_attribute6, k_VNULL)),
                NVL(industry_attribute6, k_VNULL)))
        AND     NVL(industry_attribute10, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute10, 'Y',
                NVL(c_OldDemand_rec.industry_attribute10, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute10, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute10, k_VNULL),
                NVL(industry_attribute10, k_VNULL)),
                NVL(industry_attribute10, k_VNULL)))
        AND     NVL(industry_attribute11, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute11, 'Y',
                NVL(c_OldDemand_rec.industry_attribute11, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute11, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute11, k_VNULL),
                NVL(industry_attribute11, k_VNULL)),
                NVL(industry_attribute11, k_VNULL)))
        AND     NVL(industry_attribute12, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute12, 'Y',
                NVL(c_OldDemand_rec.industry_attribute12, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute12, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute12, k_VNULL),
                NVL(industry_attribute12, k_VNULL)),
                NVL(industry_attribute12, k_VNULL)))
        AND     NVL(industry_attribute13, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute13, 'Y',
                NVL(c_OldDemand_rec.industry_attribute13, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute13, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute13, k_VNULL),
                NVL(industry_attribute13, k_VNULL)),
                NVL(industry_attribute13, k_VNULL)))
        AND     NVL(industry_attribute14, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.industry_attribute14, 'Y',
                NVL(c_OldDemand_rec.industry_attribute14, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.industry_attribute14, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.industry_attribute14, k_VNULL),
                NVL(industry_attribute14, k_VNULL)),
                NVL(industry_attribute14, k_VNULL)))
        --global_atp?
        AND     NVL(industry_attribute15, k_VNULL) =
                DECODE(g_ATP, k_ATP, NVL(industry_attribute15, k_VNULL),
                NVL(c_OldDemand_rec.industry_attribute15, k_VNULL))
        AND     NVL(attribute1, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute1, 'Y',
                NVL(c_OldDemand_rec.attribute1, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute1, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute1, k_VNULL),
                NVL(attribute1, k_VNULL)),
                NVL(attribute1, k_VNULL)))
        AND     NVL(attribute2, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute2, 'Y',
                NVL(c_OldDemand_rec.attribute2, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute2, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute2, k_VNULL),
                NVL(attribute2, k_VNULL)),
                NVL(attribute2, k_VNULL)))
        AND     NVL(attribute3, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute3, 'Y',
                NVL(c_OldDemand_rec.attribute3, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute3, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute3, k_VNULL),
                NVL(attribute3, k_VNULL)),
                NVL(attribute3, k_VNULL)))
        AND     NVL(attribute4, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute4, 'Y',
                NVL(c_OldDemand_rec.attribute4, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute4, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute4, k_VNULL),
                NVL(attribute4, k_VNULL)),
                NVL(attribute4, k_VNULL)))
        AND     NVL(attribute5, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute5, 'Y',
                NVL(c_OldDemand_rec.attribute5, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute5, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute5, k_VNULL),
                NVL(attribute5, k_VNULL)),
                NVL(attribute5, k_VNULL)))
        AND     NVL(attribute6, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute6, 'Y',
                NVL(c_OldDemand_rec.attribute6, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute6, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute6, k_VNULL),
                NVL(attribute6, k_VNULL)),
                NVL(attribute6, k_VNULL)))
        AND     NVL(attribute7, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute7, 'Y',
                NVL(c_OldDemand_rec.attribute7, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute7, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute7, k_VNULL),
                NVL(attribute7, k_VNULL)),
                NVL(attribute7, k_VNULL)))
        AND     NVL(attribute8, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute8, 'Y',
                NVL(c_OldDemand_rec.attribute8, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute8, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute8, k_VNULL),
                NVL(attribute8, k_VNULL)),
                NVL(attribute8, k_VNULL)))
        AND     NVL(attribute9, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute9, 'Y',
                NVL(c_OldDemand_rec.attribute9, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute9, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute9, k_VNULL),
                NVL(attribute9, k_VNULL)),
                NVL(attribute9, k_VNULL)))
        AND     NVL(attribute10, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute10, 'Y',
                NVL(c_OldDemand_rec.attribute10, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute10, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute10, k_VNULL),
                NVL(attribute10, k_VNULL)),
                NVL(attribute10, k_VNULL)))
        AND     NVL(attribute11, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute11, 'Y',
                NVL(c_OldDemand_rec.attribute11, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute11, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute11, k_VNULL),
                NVL(attribute11, k_VNULL)),
                NVL(attribute11, k_VNULL)))
        AND     NVL(attribute12, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute12, 'Y',
                NVL(c_OldDemand_rec.attribute12, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute12, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute12, k_VNULL),
                NVL(attribute12, k_VNULL)),
                NVL(attribute12, k_VNULL)))
        AND     NVL(attribute13, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute13, 'Y',
                NVL(c_OldDemand_rec.attribute13, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute13, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute13, k_VNULL),
                NVL(attribute13, k_VNULL)),
                NVL(attribute13, k_VNULL)))
        AND     NVL(attribute14, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute14, 'Y',
                NVL(c_OldDemand_rec.attribute14, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute14, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute14, k_VNULL),
                NVL(attribute14, k_VNULL)),
                NVL(attribute14, k_VNULL)))
        AND     NVL(attribute15, k_VNULL) =
                DECODE(x_Group_rec.match_across_rec.attribute15, 'Y',
                NVL(c_OldDemand_rec.attribute15, k_VNULL),
                DECODE(x_Group_rec.match_within_rec.attribute15, 'Y',
                DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                NVL(c_OldDemand_rec.attribute15, k_VNULL),
                NVL(attribute15, k_VNULL)),
                NVL(attribute15, k_VNULL)));
      --
      FETCH c_NewReq_ref INTO v_newref_line_id, v_newref_qty;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'v_consume_quantity',v_consume_quantity);
         rlm_core_sv.dlog(k_DEBUG,'v_Count',v_Count);
         rlm_core_sv.dlog(k_DEBUG,'c_NewReq_ref%ROWCOUNT',c_NewReq_ref%ROWCOUNT);
         rlm_core_sv.dlog(k_DEBUG,'c_NewReq_ref%NOTFOUND',c_NewReq_ref%NOTFOUND);
      END IF;
      --
      IF  c_NewReq_ref%NOTFOUND OR x_Sched_rec.schedule_purpose = k_ADD THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_end_date',
                                      x_Sched_rec.sched_horizon_end_date);
           rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.end_date_time',
                                     c_OldDemand_rec.end_date_time);
        END IF;
        --
        --pdue
        IF x_Sched_rec.schedule_source <> 'MANUAL' AND
           IsFrozen(TRUNC(SYSDATE), x_Group_rec, c_OldDemand_rec.request_date)
           AND x_Sched_rec.schedule_purpose <> k_ADD THEN
            --
  	    IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.line_id',
                                  c_OldDemand_rec.line_id);
                rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.request_date',
                                       c_OldDemand_rec.request_date);
                rlm_core_sv.dlog(k_DEBUG,'c_OldDemand_rec.schedule_ship_date',
                                       c_OldDemand_rec.schedule_ship_date);
            END IF;
            --
            AssignOEAttribValues(v_Key_rec, c_OldDemand_rec);
            StoreReconcile(x_Sched_rec, x_Group_rec, v_Key_rec,
                            c_OldDemand_rec.ordered_quantity);
            --
	    -- Bug 4297984 Start
	    GetMatchAttributes(x_sched_rec,x_group_rec, v_Key_rec.dem_rec,v_MatchAttrTxt);
	    --
	    IF (c_OldDemand_rec.rla_schedule_type_code = 'SEQUENCED') THEN
              --
              rlm_message_sv.app_error(
                   x_ExceptionLevel => rlm_message_sv.k_warn_level,
                   x_MessageName => 'RLM_FROZEN_DELETE_SEQ',
                   x_InterfaceHeaderId => x_sched_rec.header_id,
                   x_InterfaceLineId => NULL,
                   x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                   x_ScheduleLineId => NULL,
                   x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                   x_OrderLineId => c_OldDemand_rec.line_id,
                   x_Token1 => 'LINE',
                   x_value1 => rlm_core_sv.get_order_line_number(c_OldDemand_rec.line_id),
                   x_Token2 => 'ORDER',
                   x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                   x_Token3 => 'QUANTITY',
                   x_value3 => c_OldDemand_rec.ordered_quantity,
                   x_Token4 => 'CUSTITEM',
                   x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                   x_Token5 => 'REQ_DATE',
                   x_value5 => c_OldDemand_rec.request_date,
      	           x_Token6 => 'SCH_LINE_QTY',          --Bugfix 6159269
                   x_value6 => v_del_line_qty,          --Bugfix 6159269
                   x_Token7 => 'SEQ_INFO',
                   x_value7 => nvl(c_OldDemand_rec.cust_production_seq_num,'NULL') ||'-'||
                               nvl(c_OldDemand_rec.cust_model_serial_number,'NULL')||'-'||
                               nvl(c_OldDemand_rec.customer_job,'NULL'),
                   x_Token8 => 'MATCH_ATTR',
                   x_value8 => v_MatchAttrTxt);
              --
              IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_DELETE_SEQ',
                                   c_OldDemand_rec.line_id);
              END IF;
              --
	    ELSE
              --
              rlm_message_sv.app_error(
                   x_ExceptionLevel => rlm_message_sv.k_warn_level,
                   x_MessageName => 'RLM_FROZEN_DELETE',
                   x_InterfaceHeaderId => x_sched_rec.header_id,
                   x_InterfaceLineId => NULL,
                   x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                   x_ScheduleLineId => NULL,
                   x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                   x_OrderLineId => c_OldDemand_rec.line_id,
                   x_Token1 => 'LINE',
                   x_value1 => rlm_core_sv.get_order_line_number(c_OldDemand_rec.line_id),
                   x_Token2 => 'ORDER',
                   x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                   x_Token3 => 'QUANTITY',
                   x_value3 => c_OldDemand_rec.ordered_quantity,
                   x_Token4 => 'CUSTITEM',
                   x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                   x_Token5 => 'REQ_DATE',
                   x_value5 => c_OldDemand_rec.request_date,
                   x_Token6 => 'SCH_LINE_QTY',           --Bugfix 6159269
                   x_value6 => v_del_line_qty,           --Bugfix 6159269
                   x_Token7 => 'MATCH_ATTR',
                   x_value7 => v_MatchAttrTxt);
              --
              IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_DELETE',
                                   c_OldDemand_rec.line_id);
              END IF;
              --
            END IF;
            -- Bug 4297984 End
            --
        ELSIF TRUNC(x_Sched_rec.sched_horizon_end_date) + 0.99999
              >= TRUNC(c_OldDemand_rec.end_date_time) AND
              x_Sched_rec.schedule_purpose <> k_ADD THEN
           --bug 1680657
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'in no consume delete ');
           END IF;
           --
           AssignOEAttribValues(v_Key_rec, c_OldDemand_rec);
           --
           v_Key_rec.req_rec := v_Key_rec.dem_rec;
           --
           DeleteRequirement(x_Sched_rec, x_Group_rec,
                             v_Key_rec, k_RECONCILE, v_DeleteQty);
           --
        ELSE
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'In consume -- c_OldDemand_rec.end_date_time',
                                          c_OldDemand_rec.end_date_time);
           END IF;
           --
           /* Consume demand -- We may need to loop through the new demand
              recs because there could be a case where
              we have multiple new lines which need to be consumed as 2
              or more old demands fall outside the new horizon and
              so we need to keep a track of which lines are consumed
              already and then consume the demand as it comes in. */
           --
           OPEN c_consume_ref FOR
             SELECT  line_id, primary_quantity
             FROM    rlm_interface_lines
             WHERE   header_id = x_Sched_rec.header_id
             --global_atp
             AND     ship_from_org_id = x_Group_rec.ship_from_org_id
             AND     ship_to_org_id = x_Group_rec.ship_to_org_id
             AND     customer_item_id = x_Group_rec.customer_item_id
             AND     inventory_item_id= x_Group_rec.inventory_item_id
             AND     order_header_id= x_Group_rec.order_header_id
             /*AND     nvl(cust_production_seq_num, k_VNULL)=
                     nvl(x_Group_rec.cust_production_seq_num,k_VNULL)*/
             AND     item_detail_type in (
                            DECODE(x_Sched_rec.schedule_purpose,
                            k_ADD,
                            1,0),
                            DECODE(x_Sched_rec.schedule_purpose,
                            k_ADD,
                            0,1),DECODE(x_Sched_rec.schedule_purpose,
                            k_ADD,
                            0,2))
             AND     DECODE(x_Sched_rec.schedule_purpose,
                            k_ADD,
                            item_detail_subtype,
                            DECODE(item_detail_subtype,'AHEAD_BEHIND', k_LARGE,
                                   'CUM', k_LARGE, 'FINISHED', k_LARGE,
                                   'HOLDOUT_QTY', k_LARGE, 'INVENTORY_BAL', k_LARGE,
                                    'LABOR', k_LARGE, 'LABOR_MATERIAL', k_LARGE,
                                    'MATERIAL', k_LARGE, 'PRIOR_CUM_REQ', k_LARGE,
                                    'RECEIPT', k_LARGE, 'SHIPMENT', k_LARGE,
                                   item_detail_subtype)
                            +1)
                     <= c_OldDemand_rec.demand_bucket_type_code
             AND     request_date  BETWEEN c_OldDemand_rec.request_date
                                    AND c_OldDemand_rec.end_date_time
             AND     process_status =  rlm_core_sv.k_PS_AVAILABLE
             --bug 2031077
             --AND     NVL(invoice_to_org_id, k_NNULL) =
             --        NVL(c_OldDemand_rec.invoice_to_org_id, k_NNULL)
             AND     NVL(intmed_ship_to_org_id, k_NNULL) =
                     NVL(c_OldDemand_rec.intmed_ship_to_org_id, k_NNULL)
             /*  including matching critera */
             AND     NVL(cust_production_line, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.cust_production_line, 'Y',
                     NVL(c_OldDemand_rec.cust_production_line, k_VNULL),
                     DECODE(x_Group_rec.match_within_rec.cust_production_line, 'Y',
                     DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                     NVL(c_OldDemand_rec.cust_production_line, k_VNULL),
                     NVL(cust_production_line, k_VNULL)),
                     NVL(cust_production_line, k_VNULL)))
             AND     NVL(customer_dock_code, k_VNULL) =
                     DECODE(x_Group_rec.match_across_rec.customer_dock_code, 'Y',
                     NVL(c_OldDemand_rec.customer_dock_code, k_VNULL),
                     DECODE(x_Group_rec.match_within_rec.customer_dock_code, 'Y',
                     DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                     NVL(c_OldDemand_rec.customer_dock_code, k_VNULL),
                     NVL(customer_dock_code, k_VNULL)),
                     NVL(customer_dock_code, k_VNULL)))

          /* Fix for Bug #: 1588331
	       For consumption, do not use request_date as a
             matching attribute across schedules */

             AND     NVL(cust_po_number, k_VNULL) =
                     DECODE(x_Group_rec.match_across_rec.cust_po_number, 'Y',
                     NVL(c_OldDemand_rec.cust_po_number, k_VNULL),
                     DECODE(x_Group_rec.match_within_rec.cust_po_number, 'Y',
                     DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                     NVL(c_OldDemand_rec.cust_po_number, k_VNULL),
                     NVL(cust_po_number, k_VNULL)),
                     NVL(cust_po_number, k_VNULL)))
             AND     NVL(customer_item_revision, k_VNULL) =
                     DECODE(x_Group_rec.match_across_rec.customer_item_revision, 'Y',
                     NVL(c_OldDemand_rec.customer_item_revision, k_VNULL),
                     DECODE(x_Group_rec.match_within_rec.customer_item_revision, 'Y',
                     DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                     NVL(c_OldDemand_rec.customer_item_revision, k_VNULL),
                     NVL(customer_item_revision, k_VNULL)),
                     NVL(customer_item_revision, k_VNULL)))
             AND     NVL(customer_job, k_VNULL) =
                     DECODE(x_Group_rec.match_across_rec.customer_job, 'Y',
                     NVL(c_OldDemand_rec.customer_job, k_VNULL),
                     DECODE(x_Group_rec.match_within_rec.customer_job, 'Y',
                     DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                     NVL(c_OldDemand_rec.customer_job, k_VNULL),
                     NVL(customer_job, k_VNULL)),
                     NVL(customer_job, k_VNULL)))
             AND     NVL(cust_model_serial_number, k_VNULL) =
                     DECODE(x_Group_rec.match_across_rec.cust_model_serial_number, 'Y',
                     NVL(c_OldDemand_rec.cust_model_serial_number, k_VNULL),
                     DECODE(x_Group_rec.match_within_rec.cust_model_serial_number, 'Y',
                     DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                     NVL(c_OldDemand_rec.cust_model_serial_number, k_VNULL),
                     NVL(cust_model_serial_number, k_VNULL)),
                     NVL(cust_model_serial_number, k_VNULL)))
             AND     NVL(industry_attribute1, k_VNULL) =
                     DECODE(x_Group_rec.match_across_rec.industry_attribute1, 'Y',
                     NVL(c_OldDemand_rec.industry_attribute1, k_VNULL),
                     DECODE(x_Group_rec.match_within_rec.industry_attribute1, 'Y',
                     DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                     NVL(c_OldDemand_rec.industry_attribute1, k_VNULL),
                     NVL(industry_attribute1, k_VNULL)),
                     NVL(industry_attribute1, k_VNULL)))

	  /* Fix for Bug #: 1588331
	     For consumption, do not use industry_attribute2 as a
             matching attribute across schedules. */

             AND     NVL(industry_attribute4, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute4, 'Y',
                   NVL(c_OldDemand_rec.industry_attribute4, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute4, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute4, k_VNULL),
                   NVL(industry_attribute4, k_VNULL)),
                   NVL(industry_attribute4, k_VNULL)))
             AND     NVL(industry_attribute5, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute5, 'Y',
                   NVL(c_OldDemand_rec.industry_attribute5, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute5, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute5, k_VNULL),
                   NVL(industry_attribute5, k_VNULL)),
                   NVL(industry_attribute5, k_VNULL)))
             AND     NVL(industry_attribute6, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute6, 'Y',
                   NVL(c_OldDemand_rec.industry_attribute6, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute6, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute6, k_VNULL),
                   NVL(industry_attribute6, k_VNULL)),
                   NVL(industry_attribute6, k_VNULL)))
             AND     NVL(industry_attribute10, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute10, 'Y',
                   NVL(c_OldDemand_rec.industry_attribute10, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute10, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute10, k_VNULL),
                   NVL(industry_attribute10, k_VNULL)),
                   NVL(industry_attribute10, k_VNULL)))
             AND     NVL(industry_attribute11, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute11, 'Y',
                   NVL(c_OldDemand_rec.industry_attribute11, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute11, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute11, k_VNULL),
                   NVL(industry_attribute11, k_VNULL)),
                   NVL(industry_attribute11, k_VNULL)))
             AND     NVL(industry_attribute12, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute12, 'Y',
                   NVL(c_OldDemand_rec.industry_attribute12, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute12, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute12, k_VNULL),
                   NVL(industry_attribute12, k_VNULL)),
                   NVL(industry_attribute12, k_VNULL)))
             AND     NVL(industry_attribute13, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute13, 'Y',
                   NVL(c_OldDemand_rec.industry_attribute13, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute13, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute13, k_VNULL),
                   NVL(industry_attribute13, k_VNULL)),
                   NVL(industry_attribute13, k_VNULL)))
             AND     NVL(industry_attribute14, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.industry_attribute14, 'Y',
              NVL(c_OldDemand_rec.industry_attribute14, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.industry_attribute14, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.industry_attribute14, k_VNULL),
                   NVL(industry_attribute14, k_VNULL)),
                   NVL(industry_attribute14, k_VNULL)))
           --global_atp
             AND   NVL(industry_attribute15, k_VNULL) =
                   DECODE(g_ATP, k_ATP, NVL(industry_attribute15, k_VNULL),
                   NVL(c_OldDemand_rec.industry_attribute15, k_VNULL))
             AND   NVL(attribute1, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute1, 'Y',
                   NVL(c_OldDemand_rec.attribute1, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute1, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute1, k_VNULL),
                   NVL(attribute1, k_VNULL)),
                   NVL(attribute1, k_VNULL)))
             AND   NVL(attribute2, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute2, 'Y',
                   NVL(c_OldDemand_rec.attribute2, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute2, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute2, k_VNULL),
                   NVL(attribute2, k_VNULL)),
                   NVL(attribute2, k_VNULL)))
             AND     NVL(attribute3, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute3, 'Y',
                   NVL(c_OldDemand_rec.attribute3, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute3, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute3, k_VNULL),
                   NVL(attribute3, k_VNULL)),
                   NVL(attribute3, k_VNULL)))
             AND     NVL(attribute4, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute4, 'Y',
                   NVL(c_OldDemand_rec.attribute4, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute4, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute4, k_VNULL),
                   NVL(attribute4, k_VNULL)),
                   NVL(attribute4, k_VNULL)))
             AND     NVL(attribute5, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute5, 'Y',
                   NVL(c_OldDemand_rec.attribute5, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute5, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute5, k_VNULL),
                   NVL(attribute5, k_VNULL)),
                   NVL(attribute5, k_VNULL)))
             AND     NVL(attribute6, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute6, 'Y',
                   NVL(c_OldDemand_rec.attribute6, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute6, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute6, k_VNULL),
                   NVL(attribute6, k_VNULL)),
                   NVL(attribute6, k_VNULL)))
             AND     NVL(attribute7, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute7, 'Y',
                   NVL(c_OldDemand_rec.attribute7, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute7, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute7, k_VNULL),
                   NVL(attribute7, k_VNULL)),
                   NVL(attribute7, k_VNULL)))
             AND     NVL(attribute8, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute8, 'Y',
                   NVL(c_OldDemand_rec.attribute8, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute8, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute8, k_VNULL),
                   NVL(attribute8, k_VNULL)),
                   NVL(attribute8, k_VNULL)))
             AND     NVL(attribute9, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute9, 'Y',
                   NVL(c_OldDemand_rec.attribute9, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute9, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute9, k_VNULL),
                   NVL(attribute9, k_VNULL)),
                   NVL(attribute9, k_VNULL)))
             AND     NVL(attribute10, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute10, 'Y',
                   NVL(c_OldDemand_rec.attribute10, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute10, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute10, k_VNULL),
                   NVL(attribute10, k_VNULL)),
                   NVL(attribute10, k_VNULL)))
             AND     NVL(attribute11, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute11, 'Y',
                   NVL(c_OldDemand_rec.attribute11, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute11, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute11, k_VNULL),
                   NVL(attribute11, k_VNULL)),
                   NVL(attribute11, k_VNULL)))
             AND     NVL(attribute12, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute12, 'Y',
                   NVL(c_OldDemand_rec.attribute12, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute12, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute12, k_VNULL),
                   NVL(attribute12, k_VNULL)),
                   NVL(attribute12, k_VNULL)))
             AND     NVL(attribute13, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute13, 'Y',
                   NVL(c_OldDemand_rec.attribute13, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute13, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute13, k_VNULL),
                   NVL(attribute13, k_VNULL)),
                   NVL(attribute13, k_VNULL)))
             AND     NVL(attribute14, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute14, 'Y',
                   NVL(c_OldDemand_rec.attribute14, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute14, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute14, k_VNULL),
                   NVL(attribute14, k_VNULL)),
                   NVL(attribute14, k_VNULL)))
             AND     NVL(attribute15, k_VNULL) =
                   DECODE(x_Group_rec.match_across_rec.attribute15, 'Y',
                   NVL(c_OldDemand_rec.attribute15, k_VNULL),
                   DECODE(x_Group_rec.match_within_rec.attribute15, 'Y',
                   DECODE(c_OldDemand_rec.rla_schedule_type_code, x_Sched_rec.schedule_type,
                   NVL(c_OldDemand_rec.attribute15, k_VNULL),
                   NVL(attribute15, k_VNULL)),
                   NVL(attribute15, k_VNULL)));

           /* We need the above query because we could have a case where the
              schedule date for both the lines are same but the item detail
              subtype is of less granularity in which case we will have
              to consume  the old quantity, else replace.
              Also we do not need to check for non mandatory attributes
              in this case as they will be different */
           --
           v_consume_quantity := 0;
           --
           j := v_consume_line_tab.COUNT;
           --
           LOOP
             --
             FETCH c_consume_ref INTO v_line_id, v_qty;
             --
             EXIT WHEN c_consume_ref%NOTFOUND;
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'consume_ref.v_line_id' , v_line_id);
                rlm_core_sv.dlog(k_DEBUG,'consume_ref.v_qty', v_qty);
             END IF;
             --
             IF isLineConsumable(v_consume_line_tab,v_line_id, v_index) THEN
                --
                j := j + 1;
                --
                IF c_OldDemand_rec.ordered_quantity >
                                           (v_consume_quantity + v_qty) THEN
                  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(k_DEBUG,'complete consumtion of qty' , v_qty);
                  END IF;
                  --
                  v_consume_line_tab(j).quantity := v_qty;
                  v_consume_line_tab(j).line_id := v_line_id;
                  v_consume_quantity := v_consume_quantity + v_qty;
                  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(k_DEBUG,'v_consume_quantity',
                                                           v_consume_quantity);
                  END IF;
                  --
                ELSE
                  --
                  v_qty := c_OldDemand_rec.ordered_quantity - v_consume_quantity;
                  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(k_DEBUG,'partial consumtion of qty', v_qty);
                     rlm_core_sv.dlog(k_DEBUG,'partial consumtion of line',v_line_id);
                  END IF;
                  --
                  v_consume_line_tab(j).quantity := v_qty;
                  v_consume_line_tab(j).line_id := v_line_id;
                  v_consume_quantity := v_consume_quantity + v_qty;
                  --
                END IF;
                --
  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(k_DEBUG,'v_consume_line_tab(j).line_id',
                                          v_consume_line_tab(j).line_id);
                   rlm_core_sv.dlog(k_DEBUG,'v_consume_line_tab(j).quantity',
                                          v_consume_line_tab(j).quantity);
                END IF;
                --
             ELSE
                --
                /* If the line is not consumable then we need to check if the line
                   has been partially consumed in which case we need to consume
                   the remaining qty */
               --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(k_DEBUG,'v_consume_line_tab(v_Index).line_id',
                                          v_consume_line_tab(v_Index).line_id);
                  rlm_core_sv.dlog(k_DEBUG,'v_consume_line_tab(v_Index).quantity',
                                          v_consume_line_tab(v_Index).quantity);
                  rlm_core_sv.dlog(k_DEBUG,'quantity for current line v_qty',v_qty);
               END IF;
               --
               IF v_consume_line_tab(v_Index).quantity <> v_qty THEN
                 --
                 /* This will ocur when there is partial consumption so
                    we need to take into account only the difference between the
                    two quantities */
                 --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'Consuming partially consumed line', v_line_id);
                 END IF;
                 --
                 v_qty := v_qty - v_consume_line_tab(v_Index).quantity;
                 --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'v_qty',v_qty);
                 END IF;
                 --
                 IF c_OldDemand_rec.ordered_quantity >
                                              (v_consume_quantity + v_qty) THEN
                   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'Consuming partially consumed line
                                              completely', v_line_id);
                      rlm_core_sv.dlog(k_DEBUG,'Consuming partially consumed line
                                        completely qty ', v_qty);
                   END IF;
                   --
                   v_consume_line_tab(v_index).quantity :=
                                v_consume_line_tab(v_index).quantity + v_qty;
                   v_consume_quantity := v_consume_quantity + v_qty;
                   --
                 ELSE
                   --
                   v_qty := c_OldDemand_rec.ordered_quantity - v_consume_quantity;
                   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'Consuming partially consumed line
                                    again partially',v_line_id);
                      rlm_core_sv.dlog(k_DEBUG,'Consuming partially consumed line
                                    again partially qty ', v_qty);
                   END IF;
                   --
                   v_consume_line_tab(v_index).quantity :=
                              v_consume_line_tab(v_index).quantity + v_qty;
                   v_consume_quantity := v_consume_quantity + v_qty;
                   --
                 END IF;
                 --
               END IF;
               --
             END IF;
             --
           END LOOP;
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG,'Total quantity to be consumed ',
                                                        v_consume_quantity);
           END IF;
           --
           IF c_consume_ref%ROWCOUNT = 0 THEN
            -- If the rowcount is = 0 means that there are no lines to be consumed
            -- If the rowcount is = 0 means that there are no lines to be consumed
            -- so the old line needs to be deleted
              --
  	      IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(k_DEBUG,'in rowcount = 0');
                 rlm_core_sv.dlog(k_DEBUG,'No lines came into the
                           schedule to be consumed so keep line as it is');
              END IF;
              --
           ELSIF v_consume_quantity > 0 THEN
             --
             v_Key_rec.oe_line_id := c_OldDemand_rec.line_id;
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'oe_line_id',v_Key_rec.oe_line_id);
             END IF;
             --
             AssignOEAttribValues(v_Key_rec, c_OldDemand_rec);
             --
             v_Key_rec.req_rec := v_Key_rec.dem_rec;
             --
             v_quantity := c_OldDemand_rec.ordered_quantity - v_consume_quantity;
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,'v_quantity',v_quantity);
             END IF;
             --
             IF v_quantity = 0 THEN
                --
                DeleteRequirement(x_Sched_rec, x_Group_rec, v_Key_rec,
                                       k_RECONCILE, v_DeleteQty);
                --
             ELSE
                --
                -- 4292516 added the check if req_rec.request_date falls within frozen fence also
                --
                IF (NOT (IsFrozen(TRUNC(SYSDATE), x_Group_rec,
                             v_Key_rec.dem_rec.request_date) OR
                     IsFrozen(TRUNC(SYSDATE), x_Group_rec, v_Key_rec.req_rec.request_date)) OR x_Sched_rec.schedule_source = 'MANUAL') --Bugfix 8221799
                   AND NOT ProcessConstraint(v_Key_rec,v_Qty_rec,k_UPDATE,v_Quantity) THEN
                   --
  	           IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'v_quantity',v_quantity);
                   END IF;
                   --
                   --global_atp
                   UpdateRequirement(x_Sched_rec, x_Group_rec, v_Key_rec,
                                     v_quantity);
                   --
                ELSE
                   --  irreconcileable differences
                   --
                   StoreReconcile(x_Sched_rec, x_Group_rec, v_Key_rec,
                                 v_consume_quantity);
                   --
                END IF;
                --
             END IF;
             --
           END IF;
           --
        END IF;
        --
      ELSE
      --
        /* We add this new line to the consume tab so that these lines should not
           be considered for consumption later on.
             WE have added the difference between the New ref qty and what was
           there earlier. Hence we find that if this consume_line_tab.quantity
           > 0 then we should consume */
        --
        v_Count := v_consume_line_tab.COUNT + 1;
        --
        v_consume_line_tab(v_Count).line_id := v_Newref_line_id;
        v_consume_line_tab(v_Count).quantity := c_OldDemand_rec.ordered_quantity;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'new line addede to the consume tab');
           rlm_core_sv.dlog(k_DEBUG,'v_consume_line_tab(v_Count).line_id',
                                  v_consume_line_tab(v_Count).line_id);
           rlm_core_sv.dlog(k_DEBUG,'v_consume_line_tab(v_Count).quantity',
                                  v_consume_line_tab(v_Count).quantity);
        END IF;
        --
      END IF;
      --
      CLOSE c_NewReq_ref;

    EXCEPTION
       --
      WHEN e_WrongSchedType THEN
        --
        SELECT line_number INTO v_line_num
        FROM oe_order_lines
        WHERE line_id = c_OldDemand_rec.line_id;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'line_id', c_OldDemand_rec.line_id);
           rlm_core_sv.dlog(k_DEBUG,'rla_schedule_type_code',
                                        c_OldDemand_rec.rla_schedule_type_code);
           rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_type',
                                                x_Sched_rec.schedule_type);
           rlm_core_sv.dlog(k_DEBUG,'line_number', v_line_num);
           rlm_core_sv.dlog(k_DEBUG,'RLM_WRONG_SCHEDTYPE');
        END IF;
        --
        rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_WRONG_SCHEDTYPE',
            x_InterfaceHeaderId => x_sched_rec.header_id,
            x_InterfaceLineId => NULL,
            x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
            x_ScheduleLineId => NULL,
            x_OrderHeaderId => x_Group_rec.order_header_id,
            x_OrderLineId => c_OldDemand_rec.line_id,
            x_Token1 => 'LINENUM',
            x_value1 => v_line_num,
            x_Token2 => 'SCHEDTYPE',
            x_value2 => c_OldDemand_rec.rla_schedule_type_code );
        --
    END;
    --
    FETCH c_OldDemand INTO c_OldDemand_rec;
    --
  END LOOP;
  CLOSE c_OldDemand; --bug 4570658
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

   WHEN e_group_error THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'group error');
        rlm_core_sv.dpop(k_SDEBUG);
     END IF;
     --
     raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.ProcessOld',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ProcessOld;


/*===========================================================================

  FUNCTION FetchReq

===========================================================================*/
FUNCTION FetchReq(x_Req_ref       IN OUT NOCOPY t_Cursor_ref,
                  x_Key_rec       IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                  x_oe_line_id    OUT    NOCOPY NUMBER,
                  x_SumOrderedQty OUT    NOCOPY NUMBER,
                  x_ScheduleType  OUT    NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'FetchReq');
  END IF;
  --
    FETCH x_Req_Ref INTO
          x_oe_line_id,
          x_SumOrderedQty,
          x_ScheduleType, -- existing schedule_type
          x_Key_rec.req_rec.customer_id,
          x_Key_rec.req_rec.header_id,
          x_Key_rec.req_rec.line_id,
          x_Key_rec.req_rec.cust_production_line,
          x_Key_rec.req_rec.customer_dock_code,
          x_Key_rec.req_rec.request_date,
          x_Key_rec.req_rec.schedule_date,
          x_Key_rec.req_rec.cust_po_number,
          x_Key_rec.req_rec.customer_item_revision,
          x_Key_rec.req_rec.customer_job,
          x_Key_rec.req_rec.cust_model_serial_number,
          x_Key_rec.req_rec.cust_production_seq_num,
          x_Key_rec.req_rec.industry_attribute1,
          x_Key_rec.req_rec.industry_attribute2,
          x_Key_rec.req_rec.industry_attribute3,
          x_Key_rec.req_rec.industry_attribute4,
          x_Key_rec.req_rec.industry_attribute5,
          x_Key_rec.req_rec.industry_attribute6,
          x_Key_rec.req_rec.industry_attribute7,
          x_Key_rec.req_rec.industry_attribute8,
          x_Key_rec.req_rec.industry_attribute9,
          x_Key_rec.req_rec.industry_attribute10,
          x_Key_rec.req_rec.industry_attribute11,
          x_Key_rec.req_rec.industry_attribute12,
          x_Key_rec.req_rec.industry_attribute13,
          x_Key_rec.req_rec.industry_attribute14,
          x_Key_rec.req_rec.industry_attribute15,
          x_Key_rec.req_rec.industry_context,
          x_Key_rec.req_rec.attribute1,
          x_Key_rec.req_rec.attribute2,
          x_Key_rec.req_rec.attribute3,
          x_Key_rec.req_rec.attribute4,
          x_Key_rec.req_rec.attribute5,
          x_Key_rec.req_rec.attribute6,
          x_Key_rec.req_rec.attribute7,
          x_Key_rec.req_rec.attribute8,
          x_Key_rec.req_rec.attribute9,
          x_Key_rec.req_rec.attribute10,
          x_Key_rec.req_rec.attribute11,
          x_Key_rec.req_rec.attribute12,
          x_Key_rec.req_rec.attribute13,
          x_Key_rec.req_rec.attribute14,
          x_Key_rec.req_rec.attribute15,
          x_Key_rec.req_rec.attribute_category,
          x_Key_rec.req_rec.tp_attribute1,
          x_Key_rec.req_rec.tp_attribute2,
          x_Key_rec.req_rec.tp_attribute3,
          x_Key_rec.req_rec.tp_attribute4,
          x_Key_rec.req_rec.tp_attribute5,
          x_Key_rec.req_rec.tp_attribute6,
          x_Key_rec.req_rec.tp_attribute7,
          x_Key_rec.req_rec.tp_attribute8,
          x_Key_rec.req_rec.tp_attribute9,
          x_Key_rec.req_rec.tp_attribute10,
          x_Key_rec.req_rec.tp_attribute11,
          x_Key_rec.req_rec.tp_attribute12,
          x_Key_rec.req_rec.tp_attribute13,
          x_Key_rec.req_rec.tp_attribute14,
          x_Key_rec.req_rec.tp_attribute15,
          x_Key_rec.req_rec.tp_attribute_category,
          x_Key_rec.req_rec.item_detail_type,
          x_Key_rec.req_rec.item_detail_subtype,
          x_Key_rec.req_rec.intrmd_ship_to_id,
          x_Key_rec.req_rec.ship_to_org_id,
          x_Key_rec.req_rec.invoice_to_org_id,
          x_Key_rec.req_rec.primary_quantity,
          x_Key_rec.req_rec.intmed_ship_to_org_id,
          x_Key_rec.req_rec.customer_item_id,
          x_Key_rec.req_rec.inventory_item_id,
          x_Key_rec.req_rec.order_header_id,
          x_Key_rec.req_rec.authorized_to_ship_flag,
          x_Key_rec.req_rec.ship_from_org_id,
          x_Key_rec.req_rec.schedule_type, --incoming
          x_Key_rec.req_rec.item_identifier_type,
          x_Key_rec.req_rec.customer_item_ext,
          x_Key_rec.req_rec.agreement_id,
          x_Key_rec.req_rec.price_list_id,
          x_Key_rec.req_rec.schedule_header_id,
          x_Key_rec.req_rec.schedule_line_id,
          x_Key_rec.req_rec.process_status,
          x_Key_rec.req_rec.uom_code,
          x_Key_rec.req_rec.cust_po_line_num,
	  x_Key_rec.req_rec.blanket_number;

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'after fetch');
  END IF;
  --
  IF x_Req_ref%NOTFOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
    RETURN(FALSE);
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'true');
    END IF;
    --
    RETURN(TRUE);
    --
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.FetchReq',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END FetchReq;


/*===========================================================================

  FUNCTION FetchDemand

===========================================================================*/
FUNCTION FetchDemand(x_Demand_ref IN OUT NOCOPY t_Cursor_ref,
                     x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec)
RETURN BOOLEAN
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'FetchDemand');
  END IF;
  --
  FETCH x_Demand_ref INTO
    x_Key_rec.dem_rec.line_id,
    x_Key_rec.dem_rec.ordered_quantity,
    x_Key_rec.dem_rec.shipped_quantity,
    x_Key_rec.dem_rec.customer_id,
    x_Key_rec.dem_rec.cust_production_line,
    x_Key_rec.dem_rec.customer_dock_code,
    x_Key_rec.dem_rec.request_date,
    x_Key_rec.dem_rec.schedule_date,
    x_Key_rec.dem_rec.cust_po_number,
    x_Key_rec.dem_rec.customer_item_revision,
    x_Key_rec.dem_rec.customer_job,
    x_Key_rec.dem_rec.cust_model_serial_number,
    x_Key_rec.dem_rec.cust_production_seq_num,
    x_Key_rec.dem_rec.industry_attribute1,
    x_Key_rec.dem_rec.industry_attribute2,
    x_Key_rec.dem_rec.industry_attribute3,
    x_Key_rec.dem_rec.industry_attribute4,
    x_Key_rec.dem_rec.industry_attribute5,
    x_Key_rec.dem_rec.industry_attribute6,
    x_Key_rec.dem_rec.industry_attribute7,
    x_Key_rec.dem_rec.industry_attribute8,
    x_Key_rec.dem_rec.industry_attribute9,
    x_Key_rec.dem_rec.industry_attribute10,
    x_Key_rec.dem_rec.industry_attribute11,
    x_Key_rec.dem_rec.industry_attribute12,
    x_Key_rec.dem_rec.industry_attribute13,
    x_Key_rec.dem_rec.industry_attribute14,
    x_Key_rec.dem_rec.industry_attribute15,
    x_Key_rec.dem_rec.industry_context,
    x_Key_rec.dem_rec.attribute1,
    x_Key_rec.dem_rec.attribute2,
    x_Key_rec.dem_rec.attribute3,
    x_Key_rec.dem_rec.attribute4,
    x_Key_rec.dem_rec.attribute5,
    x_Key_rec.dem_rec.attribute6,
    x_Key_rec.dem_rec.attribute7,
    x_Key_rec.dem_rec.attribute8,
    x_Key_rec.dem_rec.attribute9,
    x_Key_rec.dem_rec.attribute10,
    x_Key_rec.dem_rec.attribute11,
    x_Key_rec.dem_rec.attribute12,
    x_Key_rec.dem_rec.attribute13,
    x_Key_rec.dem_rec.attribute14,
    x_Key_rec.dem_rec.attribute15,
    x_Key_rec.dem_rec.attribute_category,
    x_Key_rec.dem_rec.tp_attribute1,
    x_Key_rec.dem_rec.tp_attribute2,
    x_Key_rec.dem_rec.tp_attribute3,
    x_Key_rec.dem_rec.tp_attribute4,
    x_Key_rec.dem_rec.tp_attribute5,
    x_Key_rec.dem_rec.tp_attribute6,
    x_Key_rec.dem_rec.tp_attribute7,
    x_Key_rec.dem_rec.tp_attribute8,
    x_Key_rec.dem_rec.tp_attribute9,
    x_Key_rec.dem_rec.tp_attribute10,
    x_Key_rec.dem_rec.tp_attribute11,
    x_Key_rec.dem_rec.tp_attribute12,
    x_Key_rec.dem_rec.tp_attribute13,
    x_Key_rec.dem_rec.tp_attribute14,
    x_Key_rec.dem_rec.tp_attribute15,
    x_Key_rec.dem_rec.tp_attribute_category,
    x_Key_rec.dem_rec.item_detail_subtype,
    x_Key_rec.dem_rec.item_detail_type,
    x_Key_rec.dem_rec.ship_to_org_id,
    x_Key_rec.dem_rec.invoice_to_org_id,
    x_Key_rec.dem_rec.intmed_ship_to_org_id,
    x_Key_rec.dem_rec.customer_item_id,
    x_Key_rec.dem_rec.inventory_item_id,
    x_Key_rec.dem_rec.order_header_id,
    x_Key_rec.dem_rec.ship_from_org_id,
    x_Key_rec.dem_rec.schedule_type,
    x_Key_rec.dem_rec.authorized_to_ship_flag,
    x_Key_rec.dem_rec.item_identifier_type,
    x_Key_rec.dem_rec.agreement_id,
    x_Key_rec.dem_rec.price_list_id,
    x_Key_rec.dem_rec.customer_item_ext,
    x_key_rec.dem_rec.uom_code,
    x_Key_rec.dem_rec.blanket_number;
  --
  IF x_Demand_ref%NOTFOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
    RETURN(FALSE);
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'true');
    END IF;
    --
    RETURN(TRUE);
    --
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.FetchDemand',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END FetchDemand;


/*===========================================================================

  FUNCTION SchedulePrecedence

===========================================================================*/
FUNCTION SchedulePrecedence(x_Group_rec    IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                            x_sched_rec    IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_ScheduleType IN VARCHAR2)
RETURN BOOLEAN
IS
 v_cannot_replace NUMBER;
 x_progress          VARCHAR2(3) := '010';
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'SchedulePrecedence');
     rlm_core_sv.dlog(k_DEBUG,'x_ScheduleType', x_ScheduleType);
     rlm_core_sv.dlog(k_DEBUG,'x_group_rec.schedule_type_one', x_group_rec.schedule_type_one);
     rlm_core_sv.dlog(k_DEBUG,'x_group_rec.schedule_type_two', x_group_rec.schedule_type_two);
     rlm_core_sv.dlog(k_DEBUG,'x_group_rec.schedule_type_three', x_group_rec.schedule_type_three);
     rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.schedule_type', x_sched_rec.schedule_type);
  END IF;
  --
  -- If the given schedule line is less in hierarchy than the oe line
  -- schedule line then return false  else return true
  --
  SELECT DECODE(x_ScheduleType,x_group_rec.schedule_type_one,1,
                x_group_rec.schedule_type_two,2,
                x_group_rec.schedule_type_three,3) -
         DECODE(x_Sched_rec.schedule_type,x_group_rec.schedule_type_one,1,
                x_group_rec.schedule_type_two,2,
                x_group_rec.schedule_type_three,3)
  INTO  v_cannot_replace
  FROM dual;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'v_cannot_replace', v_cannot_replace);
  END IF;
  --
  IF v_cannot_replace <= 0 THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
     END IF;
     --
     RETURN TRUE;
     --
  ELSE
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG, 'false');
     END IF;
     --
     RETURN FALSE;
     --
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.SchedulePrecedence',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END SchedulePrecedence;


PROCEDURE CountMatchedDemand(x_sched_rec        IN RLM_INTERFACE_HEADERS%ROWTYPE,
                             x_key_rec          IN RLM_RD_SV.t_Key_rec,
                             x_rlm_line_id      IN NUMBER,
                             x_oe_line_id       IN NUMBER,
                             x_DemandCount      IN OUT NOCOPY NUMBER,
                             x_SumOrderedQty    IN OUT NOCOPY NUMBER,
                             x_SumOrderedQtyTmp IN OUT NOCOPY NUMBER)
IS
  x_progress               VARCHAR2(3) := '010';
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'CountMatchedDemand');
     rlm_core_sv.dlog(k_DEBUG, 'Matched Demand Counter', x_DemandCount);
     rlm_core_sv.dlog(k_DEBUG, 'RLM Line Id', x_rlm_line_id);
     rlm_core_sv.dlog(k_DEBUG, 'OM Line Id', x_oe_line_id);
     rlm_core_sv.dlog(k_DEBUG, 'x_SumOrderedQtyTmp', x_SumOrderedQtyTmp);
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_type',
                            x_Sched_rec.schedule_type);
     rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.req_rec.item_detail_subtype',
                            x_Key_rec.req_rec.item_detail_subtype);
     rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.req_rec.invoice_to_org_id',
                            x_Key_rec.req_rec.invoice_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.req_rec.ship_to_org_id',
                            x_Key_rec.req_rec.ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.intmed_ship_to_org_id',
                            x_key_rec.req_rec.intmed_ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.cust_production_line',
                            x_key_rec.req_rec.cust_production_line);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.cust_production_seq_num',
                            x_key_rec.req_rec.cust_production_seq_num);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.primary_quantity',
                            x_key_rec.req_rec.primary_quantity);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.cust_production_line',
                            x_key_rec.req_rec.cust_production_line);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.primary_quantity',
                            x_key_rec.req_rec.primary_quantity);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.customer_item_revision',
                            x_key_rec.req_rec.customer_item_revision);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.customer_job',
                            x_key_rec.req_rec.customer_job);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.cust_po_number',
                            x_key_rec.req_rec.cust_po_number);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.customer_dock_code',
                            x_key_rec.req_rec.customer_dock_code);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.cust_model_serial_number',
                            x_key_rec.req_rec.cust_model_serial_number);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.request_date',
                            x_key_rec.req_rec.request_date);
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.schedule_date',
                            x_key_rec.req_rec.schedule_date);
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_purpose',
                            x_Sched_rec.schedule_purpose);
  END IF;
  --
  x_SumOrderedQty := x_SumOrderedQty + x_SumOrderedQtyTmp;
  --
  x_DemandCount := x_DemandCount + 1;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'x_SumOrderedQty',x_SumOrderedQty);
     rlm_core_sv.dlog(k_DEBUG,'x_DemandCount',x_DemandCount);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN e_group_error THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'group error');
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.CountMatchedDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END CountMatchedDemand;


PROCEDURE ReconcileAction(x_sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                          x_key_rec   IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                          x_line_id_tab IN RLM_RD_SV.t_matching_line,
                          x_DemandCount IN NUMBER,
                          x_SumOrderedQty IN NUMBER,
                          x_DemandType IN VARCHAR2)
IS
  x_progress               VARCHAR2(3) := '010';
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'ReconcileAction');
  END IF;
  --
  IF (x_DemandCount > 0) AND (NOT AlreadyUpdated(x_line_id_tab)) THEN
    --
    IF x_Sched_rec.schedule_purpose IN (k_DELETE, k_CANCEL)  THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'Deleting requirement due to purpose code of '
                       ,x_Sched_rec.schedule_purpose);
         rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.primary_quantity',
                                x_key_rec.req_rec.primary_quantity);
      END IF;
      --
      x_key_rec.req_rec.primary_quantity := x_SumOrderedQty -
                              x_key_rec.req_rec.primary_quantity;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'new x_key_rec.req_rec.primary_quantity',
                                x_key_rec.req_rec.primary_quantity);
      END IF;
      --
    ELSIF x_Sched_rec.schedule_purpose = k_ADD  THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'Adding requirement due to purpose code of ',
                                              x_Sched_rec.schedule_purpose);
           rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.primary_quantity',
                                  x_key_rec.req_rec.primary_quantity);
        END IF;
        --
        x_key_rec.req_rec.primary_quantity := x_SumOrderedQty +
                                x_key_rec.req_rec.primary_quantity;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'new x_key_rec.req_rec.primary_quantity',
                                 x_key_rec.req_rec.primary_quantity);
        END IF;
        --
    END IF;
    --
    RLM_TPA_SV.UpdateDemand(x_Sched_rec, x_Group_rec, x_Key_rec,
                     x_SumOrderedQty, x_DemandType);
      --
    -- this means that the req was not matched in OE so we should
    -- only insert the new requirement
  ELSIF x_Sched_rec.schedule_purpose NOT IN (k_DELETE,k_CANCEL) THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'insert x_key_rec.req_rec.primary_quantity',
                                x_key_rec.req_rec.primary_quantity);
      END IF;
      --
      RLM_TPA_SV.InsertRequirement(x_Sched_rec, x_Group_rec,
                        x_Key_rec, k_RECONCILE,
                        x_Key_rec.req_rec.primary_quantity);
      --
  END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
EXCEPTION

  WHEN e_group_error THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'group error');
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.ReconcileAction',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ReconcileAction;


/* ============================================================================================

  Procedure BuildMatchQuery

  The following is the order of WHERE clause for each SQL
   x_Sql  => uses v_where_clause1, v_where_clause2, w_where_clause1, v_where_clause1, v_where_clause2
   x_Sql1 => uses v_where_clause1, v_where_clause2
   x_Sql2 => uses w_where_clause1, v_where_clause1, v_where_clause2

  ProcessATS calls BuildMatchQuery with the following parameter mapping
   v_ATSDemand  => x_Sql
   v_NATSDemand => x_Sql1
   v_SumDemand  => x_Sum_Sql
   v_NewDemand  => x_Sql2

  ProcessNATS calls BuildMatchQuery with the following parameter mapping
   v_ATSDemand  => x_Sql1
   v_NATSDemand => x_Sql
   v_SumDemand  => x_Sum_Sql
   v_NewDemand  => x_Sql2

=============================================================================================== */

PROCEDURE BuildMatchQuery(x_Sched_rec     IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_Rec     IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                          x_Demand_Type   IN VARCHAR2,
                          x_Sql           OUT NOCOPY VARCHAR2,
                          x_Sql1          OUT NOCOPY VARCHAR2,
                          x_Sql2          OUT NOCOPY VARCHAR2,
                          x_Sum_Sql       OUT NOCOPY VARCHAR2)
IS
  --
  x_progress               VARCHAR2(3) := '010';
  v_Select_Clause          VARCHAR2(32000);
  w_Select_Clause1         VARCHAR2(32000);
  w_Select_Clause2         VARCHAR2(32000);
  v_Where_Clause1          VARCHAR2(32000);
  w_Where_Clause1          VARCHAR2(32000);
  v_Where_Clause2          VARCHAR2(32000);
  v_Order_Clause           VARCHAR2(5000);
  v_sum_clause             VARCHAR2(32000);
  v_ATSWhere		   VARCHAR2(5000);
  v_NATSWhere		   VARCHAR2(5000);
  v_Date		   DATE;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG, 'BuildMatchQuery');
    rlm_core_sv.dlog(k_DEBUG, 'Disposition Code', x_Group_rec.disposition_code);
  END IF;

  v_select_clause :=

  'SELECT o.line_id,(NVL(o.ordered_quantity,0)-NVL(o.shipped_quantity,0)),'||
  'o.rla_schedule_type_code,'|| x_group_rec.customer_id ||
  ',r.header_id interface_header_id, r.line_id interface_line_id,'||
  'r.cust_production_line,r.customer_dock_code,r.request_date,'||
  'r.schedule_date,r.cust_po_number,r.customer_item_revision,'||
  'r.customer_job,r.cust_model_serial_number,r.cust_production_seq_num,'||
  'r.industry_attribute1,r.industry_attribute2,r.industry_attribute3,'||
  'r.industry_attribute4,r.industry_attribute5,r.industry_attribute6,'||
  'r.industry_attribute7,r.industry_attribute8,r.industry_attribute9,'||
  'r.industry_attribute10,r.industry_attribute11,r.industry_attribute12,'||
  'r.industry_attribute13,r.industry_attribute14,r.industry_attribute15,'||
  'r.industry_context,r.attribute1,r.attribute2,r.attribute3,'||
  'r.attribute4,r.attribute5,r.attribute6,r.attribute7,r.attribute8,'||
  'r.attribute9,r.attribute10,r.attribute11,r.attribute12,r.attribute13,'||
  'r.attribute14,r.attribute15,r.attribute_category,r.tp_attribute1,'||
  'r.tp_attribute2,r.tp_attribute3,r.tp_attribute4,r.tp_attribute5,'||
  'r.tp_attribute6,r.tp_attribute7,r.tp_attribute8,r.tp_attribute9,'||
  'r.tp_attribute10,r.tp_attribute11,r.tp_attribute12,r.tp_attribute13,'||
  'r.tp_attribute14,r.tp_attribute15,r.tp_attribute_category,'||
  'r.item_detail_type,r.item_detail_subtype,r.intrmd_ship_to_id,'||
  'r.ship_to_org_id,r.invoice_to_org_id,r.primary_quantity,'||
  'r.intmed_ship_to_org_id,r.customer_item_id,r.inventory_item_id,'||
  'r.order_header_id,o.authorized_to_ship_flag,r.ship_from_org_id,''' ||
  x_sched_rec.schedule_type ||''',''CUST'' item_identifier_type,'||
  'r.customer_item_ext,r.agreement_id,r.price_list_id,'||
  x_Sched_rec.schedule_header_id ||
  ',r.schedule_line_id,r.process_status,r.uom_code,r.cust_po_line_num,r.blanket_number ' ||
  'FROM oe_order_lines_all o,rlm_interface_lines r ';

  w_Select_Clause1 :=

  'SELECT TO_NUMBER(NULL),TO_NUMBER(NULL),TO_CHAR(NULL),'||
  x_group_rec.customer_id ||
  ',r1.header_id interface_header_id, r1.line_id interface_line_id,'||
  'r1.cust_production_line,r1.customer_dock_code,r1.request_date,'||
  'r1.schedule_date,r1.cust_po_number,r1.customer_item_revision,'||
  'r1.customer_job,r1.cust_model_serial_number,r1.cust_production_seq_num,'||
  'r1.industry_attribute1,r1.industry_attribute2,r1.industry_attribute3,'||
  'r1.industry_attribute4,r1.industry_attribute5,r1.industry_attribute6,'||
  'r1.industry_attribute7,r1.industry_attribute8,r1.industry_attribute9,'||
  'r1.industry_attribute10,r1.industry_attribute11,r1.industry_attribute12,'||
  'r1.industry_attribute13,r1.industry_attribute14,r1.industry_attribute15,'||
  'r1.industry_context,r1.attribute1,r1.attribute2,r1.attribute3,'||
  'r1.attribute4,r1.attribute5,r1.attribute6,r1.attribute7,r1.attribute8,'||
  'r1.attribute9,r1.attribute10,r1.attribute11,r1.attribute12,r1.attribute13,'||
  'r1.attribute14,r1.attribute15,r1.attribute_category,r1.tp_attribute1,'||
  'r1.tp_attribute2,r1.tp_attribute3,r1.tp_attribute4,r1.tp_attribute5,'||
  'r1.tp_attribute6,r1.tp_attribute7,r1.tp_attribute8,r1.tp_attribute9,'||
  'r1.tp_attribute10,r1.tp_attribute11,r1.tp_attribute12,r1.tp_attribute13,'||
  'r1.tp_attribute14,r1.tp_attribute15,r1.tp_attribute_category,'||
  'r1.item_detail_type,r1.item_detail_subtype,r1.intrmd_ship_to_id,'||
  'r1.ship_to_org_id,r1.invoice_to_org_id,r1.primary_quantity,'||
  'r1.intmed_ship_to_org_id,r1.customer_item_id,r1.inventory_item_id,'||
  'r1.order_header_id,''' || x_Demand_Type ||
  ''' authorized_to_ship_flag,r1.ship_from_org_id,''' ||
  x_sched_rec.schedule_type ||''',''CUST'' item_identifier_type,'||
  'r1.customer_item_ext,r1.agreement_id,r1.price_list_id,'||
  x_Sched_rec.schedule_header_id ||
  ',r1.schedule_line_id,r1.process_status,r1.uom_code,r1.cust_po_line_num,r1.blanket_number ' ||
  'FROM rlm_interface_lines r1 ';

  --
  v_where_clause1 :=

  'WHERE o.header_id = r.order_header_id ' ||
   ' AND o.org_id = r.org_id ' ||
   ' AND o.header_id = :order_header_id' ||
   ' AND r.order_header_id = :order_header_id' ||
   ' AND o.open_flag = ''Y''' ||
   ' AND r.header_id = :header_id' ||
   ' AND o.ship_to_org_id = r.ship_to_org_id ' ||
   ' AND o.ship_to_org_id = :ship_to_org_id' ||
   ' AND r.ship_to_org_id = :ship_to_org_id' ||
   ' AND NVL(o.intmed_ship_to_org_id,-19999) = NVL(r.intmed_ship_to_org_id,-19999) ' ||
   ' AND o.ordered_item_id = r.customer_item_id ' ||
   ' AND o.ordered_item_id = :customer_item_id' ||
   ' AND r.customer_item_id = :customer_item_id' ||
   ' AND o.inventory_item_id = r.inventory_item_id ' ||
   ' AND o.inventory_item_id = :inventory_item_id '||
   ' AND r.inventory_item_id = :inventory_item_id ' ||
   ' AND o.demand_bucket_type_code = r.item_detail_subtype ' ||
   ' AND r.process_status IN ('||rlm_core_sv.k_PS_AVAILABLE||','||rlm_core_sv.k_PS_FROZEN_FIRM||')';
  --
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.order_header_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.order_header_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Sched_rec.header_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.ship_to_org_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.ship_to_org_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.customer_item_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.customer_item_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.inventory_item_id;
  g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.inventory_item_id;
  --
  --
  -- Optional Match
  IF x_group_rec.match_across_rec.request_date = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND o.request_date = r.request_date';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.request_date = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND o.request_date = DECODE(o.rla_schedule_type_code,:schedule_type, r.request_date, o.request_date)';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.cust_production_line = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.customer_production_line,'''||k_VNULL||
      ''') = NVL(r.cust_production_line,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_production_line = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.customer_production_line,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.cust_production_line,'''||
        k_VNULL||'''), NVL(o.customer_production_line,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.customer_dock_code = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.customer_dock_code,'''||k_VNULL||
      ''') = NVL(r.customer_dock_code,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.customer_dock_code = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.customer_dock_code,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.customer_dock_code,'''||
        k_VNULL||'''), NVL(o.customer_dock_code,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.cust_po_number = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.cust_po_number,'''||k_VNULL||
     ''') = NVL(r.cust_po_number,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_po_number = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.cust_po_number,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.cust_po_number,'''||
        k_VNULL||'''), NVL(o.cust_po_number,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.customer_item_revision = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.item_revision,'''||k_VNULL||
      ''') = NVL(r.customer_item_revision,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.customer_item_revision = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.item_revision,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.customer_item_revision,'''||
        k_VNULL||'''), NVL(o.item_revision,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.customer_job = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.customer_job,'''||k_VNULL||
      ''') = NVL(r.customer_job,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.customer_job = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.customer_job,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.customer_job,'''||
        k_VNULL||'''), NVL(o.customer_job,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.cust_model_serial_number = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.cust_model_serial_number,'''||k_VNULL||
      ''') = NVL(r.cust_model_serial_number,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_model_serial_number = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.cust_model_serial_number,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.cust_model_serial_number,'''||
        k_VNULL||'''), NVL(o.cust_model_serial_number,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.cust_production_seq_num = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.cust_production_seq_num,'''||k_VNULL||
      ''') = NVL(r.cust_production_seq_num,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.cust_production_seq_num = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.cust_production_seq_num,'''||k_VNULL||
       ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.cust_production_seq_num,'''||
        k_VNULL||'''), NVL(o.cust_production_seq_num,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute1 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute1,'''||k_VNULL||
      ''') = NVL(r.industry_attribute1,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute1 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute1,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute1,'''||
        k_VNULL||'''), NVL(o.industry_attribute1,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute2 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute2,'''||k_VNULL||
      ''') = NVL(r.industry_attribute2,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute2 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute2,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute2,'''||
        k_VNULL||'''), NVL(o.industry_attribute2,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute4 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute4,'''||k_VNULL||
      ''') = NVL(r.industry_attribute4,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute4 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute4,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute4,'''||
        k_VNULL||'''), NVL(o.industry_attribute4,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute5 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute5,'''||k_VNULL||
      ''') = NVL(r.industry_attribute5,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute5 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute5,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute5,'''||
        k_VNULL||'''), NVL(o.industry_attribute5,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute6 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute6,'''||k_VNULL||
      ''') = NVL(r.industry_attribute6,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute6 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute6,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute6,'''||
        k_VNULL||'''), NVL(o.industry_attribute6,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute10 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute10,'''||k_VNULL||
      ''') = NVL(r.industry_attribute10,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute10 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute10,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute10,'''||
        k_VNULL||'''), NVL(o.industry_attribute10,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute11 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute11,'''||k_VNULL||
      ''') = NVL(r.industry_attribute11,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute11 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute11,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code,:schedule_type, NVL(r.industry_attribute11,'''||
        k_VNULL||'''), NVL(o.industry_attribute11,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute12 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute12,'''||k_VNULL||
      ''') = NVL(r.industry_attribute12,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute12 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute12,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute12,'''||
        k_VNULL||'''), NVL(o.industry_attribute12,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute13 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute13,'''||k_VNULL||
      ''') = NVL(r.industry_attribute13,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute13 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute13,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute13,'''||
        k_VNULL||'''), NVL(o.industry_attribute13,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.industry_attribute14 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.industry_attribute14,'''||k_VNULL||
      ''') = NVL(r.industry_attribute14,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.industry_attribute14 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.industry_attribute14,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.industry_attribute14,'''||
        k_VNULL||'''), NVL(o.industry_attribute14,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute1 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute1,'''||k_VNULL||
      ''') = NVL(r.attribute1,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute1 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute1,'''||k_VNULL||
        ''')  = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute1,'''||
        k_VNULL||'''), NVL(o.attribute1,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute2 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute2,'''||k_VNULL||
      ''') = NVL(r.attribute2,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute2 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute2,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute2,'''||
        k_VNULL||'''), NVL(o.attribute2,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute3 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute3,'''||k_VNULL||
      ''') = NVL(r.attribute3,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute3 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute3,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute3,'''||
        k_VNULL||'''), NVL(o.attribute3,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute4 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute4,'''||k_VNULL||
      ''') = NVL(r.attribute4,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute4 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute4,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute4,'''||
        k_VNULL||'''), NVL(o.attribute4,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute5 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute5,'''||k_VNULL||
      ''') = NVL(r.attribute5,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute5 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute5,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute5,'''||
        k_VNULL||'''), NVL(o.attribute5,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute6 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute6,'''||k_VNULL||
      ''') = NVL(r.attribute6,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute6 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute6,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute6,'''||
        k_VNULL||'''), NVL(o.attribute6,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute7 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute7,'''||k_VNULL||
      ''') = NVL(r.attribute7,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute7 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute7,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute7,'''||
        k_VNULL||'''), NVL(o.attribute7,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute8 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute8,'''||k_VNULL||
      ''') = NVL(r.attribute8,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute8 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute8,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute8,'''||
        k_VNULL||'''), NVL(o.attribute8,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute9 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute9,'''||k_VNULL||
      ''') = NVL(r.attribute9,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute9 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute9,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute9,'''||
        k_VNULL||'''), NVL(o.attribute9,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute10 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute10,'''||k_VNULL||
      ''') = NVL(r.attribute10,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute10 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute10,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute10,'''||
        k_VNULL||'''), NVL(o.attribute10,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute11 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute11,'''||k_VNULL||
      ''') = NVL(r.attribute11,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute11 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute11,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute11,'''||
        k_VNULL||'''), NVL(o.attribute11,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute12 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute12,'''||k_VNULL||
      ''') = NVL(r.attribute12,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute12 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute12,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute12,'''||
        k_VNULL||'''), NVL(o.attribute12,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute13 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute13,'''||k_VNULL||
      ''') = NVL(r.attribute13,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute13 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute13,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute13,'''||
        k_VNULL||'''), NVL(o.attribute13,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute14 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute14,'''||k_VNULL||
      ''') = NVL(r.attribute14,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute14 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute14,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute14,'''||
        k_VNULL||'''), NVL(o.attribute14,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --
  IF x_group_rec.match_across_rec.attribute15 = 'Y' THEN
    --
    v_where_clause2 := v_where_clause2 ||
      ' AND NVL(o.attribute15,'''||k_VNULL||
      ''') = NVL(r.attribute15,'''||k_VNULL|| ''')';
    --
  ELSE
    --
    IF x_group_rec.match_within_rec.attribute15 = 'Y' THEN
      --
      v_where_clause2 := v_where_clause2 ||
        ' AND NVL(o.attribute15,'''||k_VNULL||
        ''') = DECODE(o.rla_schedule_type_code, :schedule_type, NVL(r.attribute15,'''||
        k_VNULL||'''), NVL(o.attribute15,'''||k_VNULL||'''))';
      --
      g_WhereTab2(g_WhereTab2.COUNT+1) := x_Sched_rec.schedule_type;
      --
    END IF;
    --
  END IF;
  --

  w_where_clause1 :=
  'WHERE r1.order_header_id = :order_header_id' ||
   ' AND r1.header_id = :header_id' ||
   ' AND r1.ship_from_org_id = :ship_from_org_id' ||
   ' AND r1.industry_attribute15 = :industry_attribute15' ||
   ' AND r1.ship_to_org_id = :ship_to_org_id' ||
   ' AND r1.customer_item_id = :customer_item_id' ||
   ' AND r1.inventory_item_id = :inventory_item_id' ||
   ' AND r1.process_status IN ('||rlm_core_sv.k_PS_AVAILABLE||','||rlm_core_sv.k_PS_FROZEN_FIRM||')';
  --
  g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Group_rec.order_header_id;
  g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Sched_rec.header_id;
  g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Group_rec.ship_from_org_id;
  g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Group_rec.industry_attribute15;
  g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Group_rec.ship_to_org_id;
  g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Group_rec.customer_item_id;
  g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Group_rec.inventory_item_id;
  --
  IF g_ATP <> k_ATP THEN
   --
   v_where_clause1 := v_where_clause1 ||
      ' AND o.ship_from_org_id = r.ship_from_org_id '||
      ' AND o.ship_from_org_id = :ship_from_org_id'||
      ' AND r.ship_from_org_id = :ship_from_org_id';
   --
   g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.ship_from_org_id;
   g_WhereTab1(g_WhereTab1.COUNT+1) := x_Group_rec.ship_from_org_id;
   --
   v_where_clause1 := v_where_clause1 ||
      ' AND NVL(o.industry_attribute15,'''||k_VNULL||
      ''') = NVL(r.industry_attribute15,'''||k_VNULL|| ''')';
   --
  END IF;
  --

  -- match on blanket number only if blankets are used
  --
  IF x_Group_rec.blanket_number IS NOT NULL THEN
   v_where_clause1 := v_where_clause1 || ' AND o.blanket_number = r.blanket_number ';
   w_where_clause1 := w_where_clause1 || ' AND r1.blanket_number = :blanket_number ';
   --
   g_NewDemandTab(g_NewDemandTab.COUNT+1) := x_Group_rec.blanket_number;
   --
  END IF;
  --

  IF x_Demand_Type = k_ATS THEN
  --
    -- Begin ArvinMeritor Change
    --
    IF x_Group_rec.disposition_code = k_CANCEL_ALL THEN
     --
     v_ATSWhere :=   ' TO_DATE(o.industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') BETWEEN TO_DATE(:sched_horizon_start_date,''RRRR/MM/DD HH24:MI:SS'') AND TO_DATE(:sched_horizon_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
      --
      g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR(TRUNC(SYSDATE),'RRRR/MM/DD HH24:MI:SS');
      g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR((TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999),'RRRR/MM/DD HH24:MI:SS');
      --
    ELSIF x_Group_rec.disposition_code = k_CANCEL_AFTER_N_DAYS THEN
      --
      v_Date := SYSDATE - nvl(x_Group_rec.cutoff_days, 0);
      rlm_core_sv.dlog(k_DEBUG, 'x_Group_rec.cutoff_days', x_Group_rec.cutoff_days);
      rlm_core_sv.dlog(k_DEBUG, 'v_Date', v_Date);
      --
      v_ATSWhere :=  ' TO_DATE(o.industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') BETWEEN TO_DATE(:sched_horizon_start_date,''RRRR/MM/DD HH24:MI:SS'') AND TO_DATE(:sched_horizon_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
      --
      g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR(TRUNC(v_Date),'RRRR/MM/DD HH24:MI:SS');
      g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR((TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999),'RRRR/MM/DD HH24:MI:SS');
      --
    ELSIF x_Group_rec.disposition_code = k_REMAIN_ON_FILE_RECONCILE THEN
      --
      -- bug4223359 For 'RemainOnFileReconcile' consider all the open order lines to be matched.
      --
      v_ATSWhere :=  ' TO_DATE(o.industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') < TO_DATE(:sched_horizon_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
      --
      g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR((TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999),'RRRR/MM/DD HH24:MI:SS');
      --
    ELSE
      --
      v_ATSWhere := ' TO_DATE(o.industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') BETWEEN TO_DATE(:sched_horizon_start_date,''RRRR/MM/DD HH24:MI:SS'') AND TO_DATE(:sched_horizon_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
      --
      g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_start_date),'RRRR/MM/DD HH24:MI:SS');
      g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR((TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999),'RRRR/MM/DD HH24:MI:SS');
      --
    END IF;
    --
    v_where_clause1 := v_where_clause1 || ' AND ' || v_ATSWhere;
    --
    -- End ArvinMeritor Change
    --
    --
    v_where_clause1 := v_where_clause1 ||
    ' AND (r.item_detail_type = '''||k_FIRM||''' OR r.item_detail_type = '''||k_PAST_DUE_FIRM||''')'; --Bugfix 8597878 Added single quotes
    --
    w_where_clause1 := w_where_clause1 ||
    ' AND (r1.item_detail_type = '''||k_FIRM||''' OR r1.item_detail_type = '''||k_PAST_DUE_FIRM||''')'; --Bugfix 8597878 Added single quotes

    -- this is to let ATS replace existing NATS
    x_Sql1 := v_select_clause ||
              v_where_clause1  ||
              v_where_clause2  ||
              ' AND o.authorized_to_ship_flag = ''N'' ';

    -- this has to come after x_Sql1
    v_where_clause2 := v_where_clause2 ||
                       ' AND o.authorized_to_ship_flag = ''Y'' ';
    --
  ELSE /* k_NATS */
    --
    -- Begin ArvinMeritor Change
    --
    v_NATSWhere := ' TO_DATE(o.industry_attribute2,''RRRR/MM/DD HH24:MI:SS'') BETWEEN TO_DATE(:sched_horizon_start_date,''RRRR/MM/DD HH24:MI:SS'') AND TO_DATE(:sched_horizon_end_date,''RRRR/MM/DD HH24:MI:SS'') ';
    --
    g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR(TRUNC(SYSDATE),'RRRR/MM/DD HH24:MI:SS');
    g_WhereTab1(g_WhereTab1.COUNT+1):= TO_CHAR((TRUNC(x_Sched_rec.sched_horizon_end_date)+0.99999),'RRRR/MM/DD HH24:MI:SS');
    --
    v_where_clause1 := v_where_clause1 || ' AND ' || v_NATSWhere;
    --
    -- End ArvinMeritor Change
    v_where_clause1 := v_where_clause1 ||
    ' AND r.item_detail_type = '''|| k_FORECAST||'''';    --Bugfix 8597878  Added single quotes
    --
    w_where_clause1 := w_where_clause1 ||
    ' AND r1.item_detail_type = '''|| k_FORECAST||'''';   --Bugfix 8597878  Added single quotes

    -- this is to let NATS replace existing ATS
    x_Sql1 := v_select_clause ||
              v_where_clause1  ||
              v_where_clause2  ||
              ' AND o.authorized_to_ship_flag = ''Y'' ';

    -- this has to come after x_Sql1
    v_where_clause2 := v_where_clause2 ||
                       ' AND o.authorized_to_ship_flag = ''N'' ';
    --
  END IF;
  --

  -- subquery
  w_select_clause2 :=
  '(SELECT ''X'' ' ||
   'FROM oe_order_lines_all o,rlm_interface_lines r ' ||
   v_where_clause1 ||
   v_where_clause2 ||
   ' AND r1.line_id = r.line_id) ';

  v_order_clause :=
  ' ORDER BY request_date, line_id ';
  --

  x_Sql2 := w_select_clause1   ||
            w_where_clause1    ||
            ' AND NOT EXISTS ' ||
            w_select_clause2   ||
            v_order_clause;


  x_Sql := v_select_clause ||
           v_where_clause1 ||
           v_where_clause2 ||
                         ' UNION ALL ' || x_Sql2;

  x_Sum_Sql := 'SELECT r.line_id, SUM(NVL(o.ordered_quantity,0)-NVL(o.shipped_quantity,0)), COUNT(1),  MIN(o.line_id) ' ||
               'FROM rlm_interface_lines r, oe_order_lines_all o ' ||
               v_where_clause1 ||
               v_where_clause2 ||
               ' GROUP BY r.line_id ORDER BY line_id';

  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG, 'v_select_clause', v_select_clause);
    rlm_core_sv.dlog(k_DEBUG, 'v_ATSWhere', v_ATSWhere);
    rlm_core_sv.dlog(k_DEBUG, 'v_NATSWhere', v_NATSWhere);
    rlm_core_sv.dlog(k_DEBUG, 'v_where_clause1', substr(v_where_clause1, 1, 800));
    rlm_core_sv.dlog(k_DEBUG, 'v_where_clause1 Contd.', substr(v_where_clause1, 800, 1600));
    rlm_core_sv.dlog(k_DEBUG, 'v_where_clause1 Contd.', substr(v_where_clause1, 1600, 2400));
    rlm_core_sv.dlog(k_DEBUG, 'v_where_clause2', substr(v_where_clause2, 1, 800));
    rlm_core_sv.dlog(k_DEBUG, 'v_where_clause2 Contd.', substr(v_where_clause2, 800, 1600));
    rlm_core_sv.dlog(k_DEBUG, 'v_where_clause2 Contd.', substr(v_where_clause2, 1600, 2400));
    rlm_core_sv.dlog(k_DEBUG, 'w_select_clause1', w_select_clause1);
    rlm_core_sv.dlog(k_DEBUG, 'w_select_clause2', substr(w_select_clause2, 1, 800));
    rlm_core_sv.dlog(k_DEBUG, 'w_select_clause2 Contd.', substr(w_select_clause2, 800, 1600));
    rlm_core_sv.dlog(k_DEBUG, 'w_select_clause2 Contd.', substr(w_select_clause2, 1600, 2400));
    rlm_core_sv.dlog(k_DEBUG, 'w_where_clause1', w_where_clause1);
    rlm_core_sv.dlog(k_DEBUG, 'x_Sum_Sql', x_Sum_Sql);
    rlm_core_sv.dlog(k_DEBUG, 'v_order_clause', v_order_clause);
    rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --

EXCEPTION

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.BuildMatchQuery',x_progress);
    IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    RAISE;

END;


/*===========================================================================

  PROCEDURE ProcessATS -
  (1) New code with performance changes (dynamic sql)

===========================================================================*/

PROCEDURE ProcessATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS

  v_Key_rec                t_Key_rec;
  v_ScheduleType           VARCHAR2(30);
  v_SumOrderedQty          NUMBER DEFAULT 0;
  v_SumOrderedQtyTmp	   NUMBER DEFAULT 0;
  v_DemandCount            NUMBER DEFAULT 0;
  v_LowestOeLineId         NUMBER DEFAULT 0;
  v_line_id_tab		   t_matching_line;
  v_line_id_tmp            NUMBER DEFAULT 0;
  --
  v_DeleteQty              NUMBER;
  c_NATS                   t_Cursor_ref;
  c_Matched                t_Cursor_ref;
  c_Sum                    t_Cursor_ref;
  x_progress               VARCHAR2(3) := '010';
  v_NewCount               NUMBER DEFAULT 0;
  v_AtsDemand              VARCHAR2(32000);
  v_NatsDemand             VARCHAR2(32000);
  v_SumDemand              VARCHAR2(32000);
  v_NewDemand              VARCHAR2(32000);
  v_LineId                 NUMBER;
  v_LineMatch              t_Line_Match_Tab;
  v_LowestLineId           NUMBER;
  v_min_horizon_date       VARCHAR2(40);
  v_InTransitQty           NUMBER   :=0;
  v_ActualCount            NUMBER;
  -- Bug 5608510
 v_total_ordered_qty  NUMBER :=0;
 v_total_partial_shipped_qty  NUMBER :=0;
 v_check_partial_flag   VARCHAR2(1) :='N';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ProcessATS');
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.header_id', x_Sched_rec.header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id', x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id', x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id', x_Group_rec.order_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id', x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.industry_attribute15', x_Group_rec.industry_attribute15);
  END IF;

  IF(UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis)  IN  ('SHIPPED_LINES',  'PART_SHIP_LINES' )) THEN
      --
      --Bug 3549475 jckwok
      --
      SELECT COUNT(*)
      INTO v_ActualCount
      FROM rlm_interface_lines     il,
	   rlm_schedule_lines_all  sl
      WHERE  il.header_id = x_Sched_rec.header_id
      AND    il.ship_from_org_id = x_Group_rec.ship_from_org_id
      AND    il.ship_to_org_id = x_Group_rec.ship_to_org_id
      AND    il.inventory_item_id = x_Group_rec.inventory_item_id
      AND    il.customer_item_id = x_Group_rec.customer_item_id
      AND    il.schedule_line_id = sl.line_id
      AND    NVL(il.item_detail_type, ' ')
			 <> rlm_manage_demand_sv.k_SHIP_RECEIPT_INFO
      AND    sl.qty_type_code    = rlm_manage_demand_sv.k_ACTUAL
      AND    il.org_id = sl.org_id;
      --
      IF (l_debug <> -1) THEN
	rlm_core_sv.dlog(k_DEBUG,'number of lines with qty_type_code ACTUAL: ',v_ActualCount);
      END IF;
      --
      IF (v_ActualCount > 0 ) THEN
	 --
	  SELECT   TO_CHAR(TRUNC(min(request_date)), 'RRRR/MM/DD HH24:MI:SS')
	  INTO     v_min_horizon_date
	  FROM     rlm_interface_lines
	  WHERE    header_id=x_sched_rec.header_id
	  AND      inventory_item_id = x_group_rec.inventory_item_id
	  AND      customer_item_id = x_group_rec.customer_item_id
	  AND      Ship_from_org_id=x_group_rec.ship_from_org_id
	  AND      Ship_to_address_id=x_group_rec.ship_to_address_id;

	  IF (l_debug <> -1) THEN
	    rlm_core_sv.dlog(k_DEBUG, 'v_min_request_date', v_min_horizon_date);
	  END IF;
	  --
	  IF TO_DATE(v_min_horizon_date,'RRRR/MM/DD HH24:MI:SS') > x_Sched_rec.sched_horizon_start_date THEN
	    --
	    v_min_horizon_date:=  TO_CHAR(TRUNC(x_Sched_rec.sched_horizon_start_date), 'RRRR/MM/DD HH24:MI:SS');
	    --
	  END IF;
	  --
	  IF (l_debug <> -1) THEN
	    rlm_core_sv.dlog(k_DEBUG, 'v_min_horizon_date', v_min_horizon_date);
	  END IF;
       END IF;
  END IF;
  --
  -- Delete all the bind variable tables
  --
  g_NewDemandTab.DELETE;
  g_WhereTab1.DELETE;
  g_WhereTab2.DELETE;
  g_BindVarTab.DELETE;
  --
  RLM_TPA_SV.BuildMatchQuery(x_sched_rec,
                  x_Group_rec,
                  k_ATS,
                  v_AtsDemand,
                  v_NatsDemand,
                  v_NewDemand,
                  v_SumDemand);
  --
  -- (1) Handle the case when incoming ATS match existing NATS
  --
  g_BindVarTab := BuildBindVarTab2(g_WhereTab1, g_WhereTab2);
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_NATS cursor', g_BindVarTab.COUNT);
  END IF;
  --
  RLM_CORE_SV.OpenDynamicCursor(c_NATS, v_NatsDemand, g_BindVarTab);
  --
  WHILE FetchReq(c_NATS,
                 v_Key_rec,
                 v_line_id_tmp,
                 v_SumOrderedQtyTmp,
                 v_ScheduleType)

  LOOP

    EXIT WHEN c_NATS%NOTFOUND;
    --
    IF (l_debug <> -1) THEN
      --
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_start_date', x_sched_rec.sched_horizon_start_date);
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_end_date', x_sched_rec.sched_horizon_end_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.request_date', v_Key_rec.req_rec.request_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.primary_quantity', v_Key_rec.req_rec.primary_quantity);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_subtype', v_Key_rec.req_rec.item_detail_subtype);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.intmed_ship_to_org_id', v_Key_rec.req_rec.intmed_ship_to_org_id);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_production_line', v_Key_rec.req_rec.cust_production_line);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_dock_code', v_Key_rec.req_rec.customer_dock_code);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_po_number', v_Key_rec.req_rec.cust_po_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_item_revision', v_Key_rec.req_rec.customer_item_revision);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_job', v_Key_rec.req_rec.customer_job);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_model_serial_number', v_Key_rec.req_rec.cust_model_serial_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_subtype', v_Key_rec.req_rec.item_detail_subtype);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.blanket_number', v_Key_rec.req_rec.blanket_number);
      rlm_core_sv.dlog(k_DEBUG,'v_line_id_tmp', v_line_id_tmp);
    --
    END IF;

    IF x_Sched_rec.schedule_purpose NOT IN (k_DELETE, k_CANCEL, k_ADD)  THEN
      --
      v_Key_rec.oe_line_id := v_line_id_tmp;
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'OM NATS Line Id', v_line_id_tmp);
      END IF;
      --
      GetDemand(v_Key_rec, x_Group_rec);
      --
      IF SchedulePrecedence(x_Group_rec, x_Sched_rec, v_ScheduleType) THEN
        --
        DeleteRequirement(x_Sched_rec, x_Group_rec,
                          v_Key_rec, k_RECONCILE,
                          v_DeleteQty);
        --
      END IF;
      --
    END IF;
    --
  END LOOP;
  CLOSE c_NATS;
  --
  -- (2) Find all the ATS and NATS demand that matches in OM
  --
  g_BindVarTab := BuildBindVarTab2(g_WhereTab1, g_WhereTab2);
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_SumDemand cursor', g_BindVarTab.COUNT);
  END IF;
  --
  RLM_CORE_SV.OpenDynamicCursor(c_Sum, v_SumDemand, g_BindVarTab);
  --
  FETCH c_Sum INTO v_LowestLineId,
                   v_SumOrderedQtyTmp,
                   v_DemandCount,
                   v_LowestOeLineId;
  IF c_Sum%FOUND THEN
    --
    v_LineMatch(0).sum_qty     := v_SumOrderedQtyTmp;
    v_LineMatch(0).match_count := v_DemandCount;
    v_LineMatch(0).lowest_oelineid := v_LowestOeLineId;
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'v_LowestLineId', v_LowestLineId);
      rlm_core_sv.dlog(k_DEBUG,'Total matching order qty', v_SumOrderedQtyTmp);
      rlm_core_sv.dlog(k_DEBUG,'Number of matching lines', v_DemandCount);
      rlm_core_sv.dlog(k_DEBUG,'Min matching oe line id', v_LowestOeLineId);
    END IF;
    --
    LOOP
      FETCH c_Sum INTO v_LineId,
                       v_SumOrderedQtyTmp,
                       v_DemandCount,
                       v_LowestOeLineId;
      EXIT WHEN c_Sum%NOTFOUND;
      v_LineMatch(v_LineId-v_LowestLineId).sum_qty := v_SumOrderedQtyTmp;
      v_LineMatch(v_LineId-v_LowestLineId).match_count := v_DemandCount;
      v_LineMatch(v_LineId-v_LowestLineId).lowest_oelineid := v_LowestOeLineId;
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'For RLM Line Id', v_LineId);
        rlm_core_sv.dlog(k_DEBUG,'Total matching order qty', v_SumOrderedQtyTmp);
        rlm_core_sv.dlog(k_DEBUG,'Number of matching lines', v_DemandCount);
        rlm_core_sv.dlog(k_DEBUG,'Min matching oe line id', v_LowestOeLineId);
      END IF;
    END LOOP;
    --
  END IF;
  CLOSE c_Sum;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG,'v_LowestLineId', v_LowestLineId);
  END IF;
  --
  IF v_LineMatch.COUNT > 0 THEN
    --
    -- (3) Find all ATS demand that matched in OM
    --
    g_BindVarTab := BuildBindVarTab5(g_WhereTab1, g_WhereTab2, g_NewDemandTab, g_WhereTab1, g_WhereTab2);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_ATSDemand cursor', g_BindVarTab.COUNT);
     rlm_core_sv.dlog(k_DEBUG,'Opening for v_AtsDemand');
    END IF;
    --
    RLM_CORE_SV.OpenDynamicCursor(c_Matched, v_ATSDemand, g_BindVarTab);
    --
  ELSE
    --
    -- (4) Find all ATS demand that did not match with lines in OM
    --
    g_BindVarTab := BuildBindVarTab3(g_NewDemandTab, g_WhereTab1, g_WhereTab2);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_NewDemand cursor', g_BindVarTab.COUNT);
     rlm_core_sv.dlog(k_DEBUG,'Opening for v_NewDemand');
    END IF;
    --
    RLM_CORE_SV.OpenDynamicCursor(c_Matched, v_NewDemand, g_BindVarTab);
    --
  END IF;
  --
  WHILE FetchReq(c_Matched,
                 v_Key_rec,
                 v_line_id_tmp,
                 v_SumOrderedQtyTmp,
                 v_ScheduleType)
  LOOP

    EXIT WHEN c_Matched%NOTFOUND;
    --
    IF (l_debug <> -1) THEN
      --
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_start_date', x_sched_rec.sched_horizon_start_date);
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_end_date', x_sched_rec.sched_horizon_end_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.request_date', v_Key_rec.req_rec.request_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.primary_quantity', v_Key_rec.req_rec.primary_quantity);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_type', v_Key_rec.req_rec.item_detail_type);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.intmed_ship_to_org_id', v_Key_rec.req_rec.intmed_ship_to_org_id);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_production_line', v_Key_rec.req_rec.cust_production_line);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_dock_code', v_Key_rec.req_rec.customer_dock_code);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_po_number', v_Key_rec.req_rec.cust_po_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_item_revision', v_Key_rec.req_rec.customer_item_revision);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_job', v_Key_rec.req_rec.customer_job);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_model_serial_number', v_Key_rec.req_rec.cust_model_serial_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_subtype', v_Key_rec.req_rec.item_detail_subtype);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.blanket_number', v_Key_rec.req_rec.blanket_number);
      rlm_core_sv.dlog(k_DEBUG,'v_line_id_tmp', v_line_id_tmp);
    --
    END IF;
    --
      g_sch_line_qty := v_Key_rec.req_rec.primary_quantity; --Bugfix 6131516
    -- start of bug fix 4223359
    --
    IF (v_key_rec.req_rec.process_status <> rlm_core_sv.k_PS_FROZEN_FIRM) THEN
      --
      FrozenFenceWarning(x_sched_rec, x_group_rec);
      --
    END IF;
    --
    -- end of bug fix 4223359
    --
    -- When there is NO MATCH

    IF v_line_id_tmp IS NULL THEN
      --
      --Intransit Based on Shipped Lines
      --
      -- Bug 3549475 Added condition to check if there is at least one ACTUAL lines jckwok
      IF(UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis) IN ('SHIPPED_LINES','PART_SHIP_LINES')
            AND v_ActualCount > 0) THEN
        --
        RLM_EXTINTERFACE_SV.GetIntransitShippedLines(x_Sched_rec,
                                                     x_Group_rec,
						     v_Key_rec.req_rec,
                                                     v_min_horizon_date,
                                                     v_InTransitQty);
        IF(v_InTransitQty >0 ) THEN
          --
          v_key_rec.req_rec.shipment_flag := 'SHIPMENT';
          StoreShipments(x_Sched_rec,
                         x_Group_rec,
                         v_Key_rec,
                         v_InTransitQty);
          --
        END IF;
        --
      END IF;

      IF x_Sched_rec.schedule_purpose NOT IN (k_DELETE,k_CANCEL) THEN
        --
        v_NewCount := v_NewCount +1;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'v_NewCount', v_NewCount);
        END IF;
        --
        RLM_TPA_SV.InsertRequirement(x_Sched_rec, x_Group_rec,
                          v_Key_rec, k_RECONCILE,
                          v_Key_rec.req_rec.primary_quantity);
      END IF;
      --
    -- When there is a MATCH
    ELSE

      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'RLM Line Id', v_Key_rec.req_rec.line_id);
      END IF;
      --
      IF v_line_id_tmp = v_LineMatch(v_Key_rec.req_rec.line_id-v_LowestLineId).lowest_oelineid THEN
        --
        v_DemandCount   := v_LineMatch(v_Key_rec.req_rec.line_id-v_LowestLineId).match_count;
        v_SumOrderedQty := v_LineMatch(v_Key_rec.req_rec.line_id-v_LowestLineId).sum_qty;
        v_line_id_tab(0) := v_line_id_tmp;

        --Intransit Based on Shipped Lines
	-- Bug 5608510
        v_check_partial_flag  :=  'N' ;
        IF (UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis) IN ('SHIPPED_LINES','PART_SHIP_LINES')
              AND v_ActualCount > 0) THEN
          --
          RLM_EXTINTERFACE_SV.GetIntransitShippedLines(x_Sched_rec,
                                                     x_Group_rec,
						     v_Key_rec.req_rec,
                                                     v_min_horizon_date,
                                                     v_InTransitQty);
          --Bug 5608510
          IF(v_InTransitQty >0 ) THEN
            --
	    IF (UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis)  =  'PART_SHIP_LINES' ) THEN

            v_total_ordered_qty := 0 ;
            v_total_partial_shipped_qty := 0;

	    BEGIN
              SELECT SUM(nvl(ordered_quantity,0)) ,SUM(nvl(shipped_quantity,0))
               INTO  v_total_ordered_qty, v_total_partial_shipped_qty
               FROM  oe_order_lines oel
               WHERE oel.line_set_id IN
                                 (SELECT ol.line_set_id
                                   FROM  oe_order_lines ol
                                   WHERE ol.line_id = v_line_id_tmp);
                --
                IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(k_DEBUG,' Total  Order  Quantity', v_total_ordered_qty);
                rlm_core_sv.dlog(k_DEBUG,' Partial Shipped Quantity' , v_total_partial_shipped_qty);
                END IF;
                --
           EXCEPTION
       	  WHEN OTHERS THEN
          --
          IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'When Other Exception PART_SHIP_LINES',substr(sqlerrm,1,200));
          END IF;
          --
          END;

         END IF ;
         --
          --
          IF ((v_InTransitQty < v_total_ordered_qty AND v_total_partial_shipped_qty > 0 )
                  AND (v_total_ordered_qty > v_Key_rec.req_rec.primary_quantity )) THEN
            --
            IF v_Key_rec.req_rec.primary_quantity <> 0 THEN
	      v_check_partial_flag  :=  'Y';
            END IF;
            --
           IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(k_DEBUG,'Intransit Qty ',v_InTransitQty);
             rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.primary_quantity ',v_Key_rec.req_rec.primary_quantity );
     	     rlm_core_sv.dlog(k_DEBUG,'v_check_partial_flag ',v_check_partial_flag );
           END  IF;
           --
           ELSE
	   --
            v_key_rec.req_rec.shipment_flag := 'SHIPMENT';
            StoreShipments(x_Sched_rec,
                         x_Group_rec,
                         v_Key_rec,
                         v_InTransitQty);
            --
          END IF;
          --
        END IF;
        --
	END IF ;
        --
        --bug 5608510
      --
      IF  v_check_partial_flag = 'N'  THEN
        RLM_TPA_SV.ReconcileAction(x_sched_rec,
                        x_group_rec,
                        v_Key_rec,
                        v_line_id_tab,
                        v_DemandCount,
                        v_SumOrderedQty,
                        k_ATS);
        v_line_id_tab.DELETE;
        --
      END IF;
      --
    END IF;
    --
    END IF;
  END LOOP;
  --
  CLOSE c_Matched;
  --
  g_sch_line_qty :=0; --Bugfix 6159269
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN e_group_error THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'group error');
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.ProcessATS',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ProcessATS;


/*===========================================================================

  PROCEDURE ProcessNATS
  (1) New version with dynamic sql for performance changes

===========================================================================*/

PROCEDURE ProcessNATS(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                      x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
IS

  v_Key_rec                t_Key_rec;
  v_ScheduleType           VARCHAR2(30);
  v_SumOrderedQty          NUMBER DEFAULT 0;
  v_SumOrderedQtyTmp	   NUMBER DEFAULT 0;
  v_DemandCount            NUMBER DEFAULT 0;
  v_LowestOeLineId         NUMBER DEFAULT 0;
  v_line_id_tab		   t_matching_line;
  v_line_id_tmp            NUMBER DEFAULT 0;
  --
  v_DeleteQty              NUMBER;
  c_ATS                    t_Cursor_ref;
  c_Matched                t_Cursor_ref;
  c_Sum                    t_Cursor_ref;
  x_progress               VARCHAR2(3) := '010';
  v_NewCount               NUMBER DEFAULT 0;
  v_NatsDemand             VARCHAR2(32000);
  v_AtsDemand             VARCHAR2(32000);
  v_SumDemand              VARCHAR2(32000);
  v_NewDemand              VARCHAR2(32000);
  v_LineId                 NUMBER;
  v_LineMatch              t_Line_Match_Tab;
  v_LowestLineId           NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ProcessNATS');
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.header_id', x_Sched_rec.header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id', x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id', x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id', x_Group_rec.order_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id', x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.industry_attribute15', x_Group_rec.industry_attribute15);
  END IF;
  --
  -- Delete all the bind variable tables
  --
  g_NewDemandTab.DELETE;
  g_WhereTab1.DELETE;
  g_WhereTab2.DELETE;
  g_BindVarTab.DELETE;
  --
  RLM_TPA_SV.BuildMatchQuery(x_sched_rec,
                  x_Group_rec,
                  k_NATS,
                  v_NatsDemand,
                  v_AtsDemand,
                  v_NewDemand,
                  v_SumDemand);
  --
  -- (1) Handle the case when incoming NATS match existing ATS
  --
  g_BindVarTab := BuildBindVarTab2(g_WhereTab1, g_WhereTab2);
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_ATSDemand cursor', g_BindVarTab.COUNT);
  END IF;
  --
  RLM_CORE_SV.OpenDynamicCursor(c_ATS, v_ATSDemand, g_BindVarTab);
  --
  WHILE FetchReq(c_ATS,
                 v_Key_rec,
                 v_line_id_tmp,
                 v_SumOrderedQtyTmp,
                 v_ScheduleType)
  LOOP

    EXIT WHEN c_ATS%NOTFOUND;
    --
    IF (l_debug <> -1) THEN
      --
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_start_date', x_sched_rec.sched_horizon_start_date);
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_end_date', x_sched_rec.sched_horizon_end_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.request_date', v_Key_rec.req_rec.request_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.primary_quantity', v_Key_rec.req_rec.primary_quantity);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_type', v_Key_rec.req_rec.item_detail_type);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.intmed_ship_to_org_id', v_Key_rec.req_rec.intmed_ship_to_org_id);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_production_line', v_Key_rec.req_rec.cust_production_line);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_dock_code', v_Key_rec.req_rec.customer_dock_code);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_po_number', v_Key_rec.req_rec.cust_po_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_item_revision', v_Key_rec.req_rec.customer_item_revision);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_job', v_Key_rec.req_rec.customer_job);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_model_serial_number', v_Key_rec.req_rec.cust_model_serial_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_subtype', v_Key_rec.req_rec.item_detail_subtype);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.blanket_number', v_Key_rec.req_rec.blanket_number);
      rlm_core_sv.dlog(k_DEBUG,'v_line_id_tmp', v_line_id_tmp);
    --
    END IF;

    IF x_Sched_rec.schedule_purpose NOT IN (k_DELETE, k_CANCEL, k_ADD)  THEN
      --
      v_Key_rec.oe_line_id := v_line_id_tmp;
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'OM NATS Line Id', v_line_id_tmp);
      END IF;
      --
      GetDemand(v_Key_rec, x_Group_rec);
      --
      IF SchedulePrecedence(x_Group_rec, x_Sched_rec, v_ScheduleType) THEN
        --
        DeleteRequirement(x_Sched_rec, x_Group_rec,
                          v_Key_rec, k_RECONCILE,
                          v_DeleteQty);
        --
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  CLOSE c_ATS;
  --
  -- (2) Find all the ATS and NATS demand that matches in OM
  --
  g_BindVarTab := BuildBindVarTab2(g_WhereTab1, g_WhereTab2);
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_SumDemand cursor', g_BindVarTab.COUNT);
  END IF;
  --
  RLM_CORE_SV.OpenDynamicCursor(c_Sum, v_SumDemand, g_BindVarTab);
  --
  FETCH c_Sum INTO v_LowestLineId,
                   v_SumOrderedQtyTmp,
                   v_DemandCount,
                   v_LowestOeLineId;
  --
  IF c_Sum%FOUND THEN
    --
    v_LineMatch(0).sum_qty     := v_SumOrderedQtyTmp;
    v_LineMatch(0).match_count := v_DemandCount;
    v_LineMatch(0).lowest_oelineid := v_LowestOeLineId;
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'v_LowestLineId', v_LowestLineId);
      rlm_core_sv.dlog(k_DEBUG,'Total matching order qty', v_SumOrderedQtyTmp);
      rlm_core_sv.dlog(k_DEBUG,'Number of matching lines', v_DemandCount);
      rlm_core_sv.dlog(k_DEBUG,'Min matching oe line id', v_LowestOeLineId);
    END IF;
    --
    LOOP
      FETCH c_Sum INTO v_LineId,
                       v_SumOrderedQtyTmp,
                       v_DemandCount,
                       v_LowestOeLineId;
      EXIT WHEN c_Sum%NOTFOUND;
      v_LineMatch(v_LineId-v_LowestLineId).sum_qty := v_SumOrderedQtyTmp;
      v_LineMatch(v_LineId-v_LowestLineId).match_count := v_DemandCount;
      v_LineMatch(v_LineId-v_LowestLineId).lowest_oelineid := v_LowestOeLineId;
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'RLM Line Id', v_LineId);
        rlm_core_sv.dlog(k_DEBUG,'Total matching order qty', v_SumOrderedQtyTmp);
        rlm_core_sv.dlog(k_DEBUG,'Number of matching lines', v_DemandCount);
        rlm_core_sv.dlog(k_DEBUG,'Min matching oe line id', v_LowestOeLineId);
      END IF;
      --
    END LOOP;
    --
  END IF;
  --
  --
  IF v_LineMatch.COUNT > 0 THEN
    --
    -- (3) Find all NATS demand that matched
    --
    g_BindVarTab := BuildBindVarTab5(g_WhereTab1, g_WhereTab2, g_NewDemandTab, g_WhereTab1, g_WhereTab2);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_NATS cursor', g_BindVarTab.COUNT);
     rlm_core_sv.dlog(k_DEBUG, 'Opening for v_NATSDemand');
    END IF;
    --
    RLM_CORE_SV.OpenDynamicCursor(c_Matched, v_NatsDemand, g_BindVarTab);
    --
  ELSE
    --
    -- (4) Find all NATS demand that did not match in OM
    --
    g_BindVarTab := BuildBindVarTab3(g_NewDemandTab, g_WhereTab1, g_WhereTab2);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'No. of bind variables for v_NewDemand cursor', g_BindVarTab.COUNT);
     rlm_core_sv.dlog(k_DEBUG,'Opening for v_NewDemand');
    END IF;
    --
    RLM_CORE_SV.OpenDynamicCursor(c_Matched, v_NewDemand, g_BindVarTab);
    --
  END IF;
  --
  WHILE FetchReq(c_Matched,
                 v_Key_rec,
                 v_line_id_tmp,
                 v_SumOrderedQtyTmp,
                 v_ScheduleType)
  LOOP

    EXIT WHEN c_Matched%NOTFOUND;
    --
    IF (l_debug <> -1) THEN
      --
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_start_date', x_sched_rec.sched_horizon_start_date);
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.sched_horizon_end_date', x_sched_rec.sched_horizon_end_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.request_date', v_Key_rec.req_rec.request_date);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.primary_quantity', v_Key_rec.req_rec.primary_quantity);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_type', v_Key_rec.req_rec.item_detail_type);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.intmed_ship_to_org_id', v_Key_rec.req_rec.intmed_ship_to_org_id);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_production_line', v_Key_rec.req_rec.cust_production_line);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_dock_code', v_Key_rec.req_rec.customer_dock_code);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_po_number', v_Key_rec.req_rec.cust_po_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_item_revision', v_Key_rec.req_rec.customer_item_revision);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.customer_job', v_Key_rec.req_rec.customer_job);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.cust_model_serial_number', v_Key_rec.req_rec.cust_model_serial_number);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.item_detail_subtype', v_Key_rec.req_rec.item_detail_subtype);
      rlm_core_sv.dlog(k_DEBUG,'v_Key_rec.req_rec.blanket_number', v_Key_rec.req_rec.blanket_number);
      rlm_core_sv.dlog(k_DEBUG,'v_line_id_tmp', v_line_id_tmp);
    --
    END IF;
    --
    g_sch_line_qty := v_Key_rec.req_rec.primary_quantity; --Bugfix 6159269
    -- When there is NO MATCH
    IF v_line_id_tmp IS NULL THEN

      IF x_Sched_rec.schedule_purpose NOT IN (k_DELETE,k_CANCEL) THEN
        --
        v_NewCount := v_NewCount +1;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'v_NewCount', v_NewCount);
        END IF;
        --
        RLM_TPA_SV.InsertRequirement(x_Sched_rec, x_Group_rec,
                          v_Key_rec, k_RECONCILE,
                          v_Key_rec.req_rec.primary_quantity);
      END IF;

    -- When there is a MATCH
    ELSE
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'RLM Line Id', v_Key_rec.req_rec.line_id);
      END IF;
      --
      IF v_line_id_tmp = v_LineMatch(v_Key_rec.req_rec.line_id-v_LowestLineId).lowest_oelineid THEN
        v_DemandCount   := v_LineMatch(v_Key_rec.req_rec.line_id-v_LowestLineId).match_count;
        v_SumOrderedQty := v_LineMatch(v_Key_rec.req_rec.line_id-v_LowestLineId).sum_qty;
        v_line_id_tab(0) := v_line_id_tmp;
        --
        RLM_TPA_SV.ReconcileAction(x_sched_rec,
                        x_group_rec,
                        v_Key_rec,
                        v_line_id_tab,
                        v_DemandCount,
                        v_SumOrderedQty,
                        k_NATS);
        v_line_id_tab.DELETE;
        --
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  CLOSE c_Matched;
  --
  g_sch_line_qty :=0; --Bugfix 6159269
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN e_group_error THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'group error');
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.ProcessNATS',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END ProcessNATS;


/*===========================================================================

  PROCEDURE UpdateDemand

===========================================================================*/
PROCEDURE UpdateDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                       x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                       x_SumOrderedQty IN NUMBER,
                       x_DemandType IN VARCHAR2)
IS

  v_QtyDelta               NUMBER;
  v_Qty_rec                t_Qty_rec;
  v_Demand_ref             t_Cursor_ref;
  v_DeleteQty              NUMBER;
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'UpdateDemand');
     rlm_core_sv.dlog(k_DEBUG,'x_SumOrderedQty', x_SumOrderedQty);
     rlm_core_sv.dlog(k_DEBUG,'x_DemandType', x_DemandType);
  END IF;
  --
  RLM_TPA_SV.ReconcileShipments(x_Group_rec,
                     x_Key_rec,
                     x_Key_rec.req_rec.primary_quantity);
  --
  Reconcile(x_Group_rec,
            x_Key_rec,
            x_Key_rec.req_rec.primary_quantity);
  --
  InitializeDemand(x_Sched_rec,
                   x_Group_rec,
                   x_Key_rec,
                   v_Demand_ref,
                   x_DemandType);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'x_key_rec.req_rec.primary_quantity',
                            x_key_rec.req_rec.primary_quantity);
  END IF;
  --
  CheckTolerance(x_Sched_rec,
                 x_Group_rec,
                 x_Key_rec,
                 x_SumOrderedQty,
                 x_key_rec.req_rec.primary_quantity);
  --
  IF x_Key_rec.req_rec.primary_quantity <= 0 THEN
    --
    g_del_reconcile := 'Y'; --Bugfix 6131516
    RLM_TPA_SV.DeleteDemand(x_Sched_rec,
                 x_Group_rec,
                 x_Key_rec,
                 v_Demand_ref);
    --
  ELSIF x_Key_rec.req_rec.primary_quantity > x_SumOrderedQty THEN
    --
    RLM_TPA_SV.IncreaseDemand(x_Sched_rec,
                   x_Group_rec,
                   x_Key_rec,
                   v_Demand_ref,
                   x_SumOrderedQty);
    --
  ELSIF x_Key_rec.req_rec.primary_quantity < x_SumOrderedQty THEN
    --
    RLM_TPA_SV.DecreaseDemand(x_Sched_rec,
                   x_Group_rec,
                   x_Key_rec,
                   v_Demand_ref,
                   x_SumOrderedQty);
    --
  ELSIF x_Key_rec.req_rec.primary_quantity = x_SumOrderedQty THEN
    --
    RLM_TPA_SV.OtherDemand(x_Sched_rec,
                x_Group_rec,
                x_Key_rec,
                v_Demand_ref);
    --
  END IF;
  CLOSE v_Demand_ref;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.UpdateDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END UpdateDemand;


/*===========================================================================

  PROCEDURE DeleteDemand

===========================================================================*/
PROCEDURE DeleteDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                       x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                       x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref)
IS

  v_DeleteQty              NUMBER;
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'DeleteDemand');
  END IF;
  --
  WHILE FetchDemand(x_Demand_ref, x_Key_rec) LOOP
    --
    IF SchedulePrecedence(x_Group_rec, x_sched_rec,x_Key_rec.dem_rec.schedule_type) THEN
      --
      DeleteRequirement(x_Sched_rec, x_Group_rec,
                        x_Key_rec, k_RECONCILE,
                        v_DeleteQty);
      --
    END IF;
    --
  END LOOP;
  --
  g_del_reconcile := 'N'; --Bugfix 6131516
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN e_group_error THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'group error');
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.DeleteDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END DeleteDemand;


/*===========================================================================

  PROCEDURE IncreaseDemand

===========================================================================*/
PROCEDURE IncreaseDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                         x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                         x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref,
                         x_SumOrderedQty IN NUMBER)
IS
  --
  v_QtyDelta               NUMBER;
  v_Qty_rec                t_Qty_rec;
  x_progress               VARCHAR2(3) := '010';
  IsSchedulePrecedence     BOOLEAN := TRUE;
  v_Index                  NUMBER := 0;
  v_MatchAttrTxt           VARCHAR2(2000); --Bugfix 6159269
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'IncreaseDemand');
  END IF;
  --
  v_QtyDelta := x_Key_rec.req_rec.primary_quantity - x_SumOrderedQty;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'v_QtyDelta',v_QtyDelta);
  END IF;
  --
  WHILE FetchDemand(x_Demand_ref, x_Key_rec) LOOP
    --
    IF SchedulePrecedence(x_Group_rec, x_sched_rec,x_Key_rec.dem_rec.schedule_type) THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.dem_rec.ordered_quantity',
                                  x_Key_rec.dem_rec.ordered_quantity);
         rlm_core_sv.dlog(k_DEBUG, 'x_Key_rec.dem_rec.line_id',
                                    x_Key_rec.dem_rec.line_id);
         rlm_core_sv.dlog(k_DEBUG,'New Schedule of higher Precedence -- TRUE');
      END IF;
      --
      IsSchedulePrecedence := TRUE;
      --
      -- 4292516 added the check if req_rec.request_date falls within frozen fence also
      --
      IF v_QtyDelta > 0 AND NOT ProcessConstraint(x_Key_rec, v_Qty_rec, k_UPDATE,
                           x_Key_rec.dem_rec.ordered_quantity + v_QtyDelta) THEN

       IF NOT (IsFrozen(TRUNC(SYSDATE), x_Group_rec, x_Key_rec.dem_rec.request_date) OR
        IsFrozen(TRUNC(SYSDATE), x_Group_rec, x_Key_rec.req_rec.request_date)) OR x_Sched_rec.schedule_source = 'MANUAL' THEN --Bugfix 8221799
          --
         UpdateRequirement(x_Sched_rec, x_Group_rec,
                           x_Key_rec, x_Key_rec.dem_rec.ordered_quantity + v_QtyDelta);
         v_QtyDelta := 0;
        --
       --Bugfix 6159269 START
       ELSE

          IF x_Key_rec.dem_rec.ordered_quantity <> g_sch_line_qty THEN
             g_inc_exception := 'Y';
             GetMatchAttributes(x_sched_rec, x_group_rec, x_Key_rec.dem_rec,v_MatchAttrTxt);
           --
           IF (x_key_rec.dem_rec.schedule_type = 'SEQUENCED') THEN
               --
               rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_UPDATE_SEQ',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_InterfaceLineId => x_key_rec.req_rec.line_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => x_key_rec.dem_rec.line_id,
           	           x_Token1 => 'LINE',
                       x_value1 => rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
                       x_Token2 => 'ORDER',
                       x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                       x_Token3 => 'QUANTITY',
                       x_value3 => x_key_rec.dem_rec.ordered_quantity,
   	                   x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
	                   x_Token5 => 'REQ_DATE',
                       x_value5 => x_key_rec.dem_rec.request_date,
                       x_Token6 => 'SCH_LINE_QTY',
                       x_value6 => g_sch_line_qty,
  	                   x_Token7 => 'SEQ_INFO',
    	               x_value7 => nvl(x_Key_rec.dem_rec.cust_production_seq_num,'NULL') ||'-'||
	                               nvl(x_Key_rec.dem_rec.cust_model_serial_number,'NULL')||'-'||
             	                   nvl(x_Key_rec.dem_rec.customer_job,'NULL'),
                       x_Token8 => 'MATCH_ATTR',
                       x_value8 => v_MatchAttrTxt);
               --
               IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                                    x_key_rec.req_rec.line_id);
                   rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE_SEQ',
                                    x_key_rec.req_rec.line_id);
               END IF;
               --
           ELSE
	       --
               rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_UPDATE',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_InterfaceLineId => x_key_rec.req_rec.line_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => x_key_rec.dem_rec.line_id,
               	       x_Token1 => 'LINE',
                       x_value1 => rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
                       x_Token2 => 'ORDER',
                       x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
    	               x_Token3 => 'QUANTITY',
                       x_value3 => x_key_rec.dem_rec.ordered_quantity,
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'REQ_DATE',
                       x_value5 => x_key_rec.dem_rec.request_date,
                       x_Token6 => 'SCH_LINE_QTY',
                       x_value6 => g_sch_line_qty,
                       x_Token7 => 'MATCH_ATTR',
                       x_value7 => v_MatchAttrTxt);
	       --
               IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                                    x_key_rec.req_rec.line_id);
                   rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE',
                                    x_key_rec.req_rec.line_id);
               END IF;
  	       --
	       END IF; /* Exception */

          END IF; /* Check g_sch_line_qty */
        --
       END IF;  /* IsFrozen */

  END IF; /* v_QtyDelta AND ProcessConstraint */
            --
      --Bugfix 6159269 END
      --
      --  Bug 3919971 : Add OE line to g_Accounted_tab, so DSP will not
      -- try to reconcile against the quantity again.
      -- Need to be accounted only after update requirement call

      v_Index := g_Accounted_tab.COUNT+1;
      g_Accounted_tab(v_Index) := x_Key_rec.dem_rec;
      g_Accounted_Tab(v_Index).line_id := x_Key_rec.dem_rec.line_id;
    ELSE
      --
      IsSchedulePrecedence := FALSE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'New Schedule of Lower Precedence -- FALSE');
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  IF v_QtyDelta <> 0 AND IsSchedulePrecedence THEN
    --
    RLM_TPA_SV.InsertRequirement(x_Sched_rec, x_Group_rec,
                      x_Key_rec, k_NORECONCILE, v_QtyDelta);
    --
  END IF;
  g_inc_exception := 'N';     --Bugfix 6159269
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.IncreaseDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END IncreaseDemand;


/*===========================================================================

  PROCEDURE DecreaseDemand

===========================================================================*/
PROCEDURE DecreaseDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                         x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                         x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref,
                         x_SumOrderedQty IN NUMBER)
IS

  v_QtyDelta               NUMBER;
  v_Qty_rec                t_Qty_rec;
  v_DeleteQty              NUMBER;
  x_progress               VARCHAR2(3) := '010';
  v_Index                  NUMBER := 0;
  v_MatchAttrTxt           VARCHAR2(2000); --Bugfix 6159269
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'DecreaseDemand');
     rlm_core_sv.dlog(k_DEBUG,'x_SumOrderedQty',x_SumOrderedQty);
     rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.req_rec.primary_quantity',
                            x_Key_rec.req_rec.primary_quantity);
  END IF;
  --
  v_QtyDelta := x_SumOrderedQty - x_Key_rec.req_rec.primary_quantity;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'v_QtyDelta',v_QtyDelta);
  END IF;
  --
  WHILE FetchDemand(x_Demand_ref, x_Key_rec) AND v_QtyDelta >0 LOOP
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'x_Key_rec.dem_rec.ordered_quantity',x_Key_rec.dem_rec.ordered_quantity);
    END IF;
    --
    IF SchedulePrecedence(x_Group_rec, x_sched_rec,x_Key_rec.dem_rec.schedule_type) THEN
      --
      IF v_QtyDelta >= x_Key_rec.dem_rec.ordered_quantity THEN
         --
         IF NOT ProcessConstraint(x_Key_rec, v_Qty_rec, k_DELETE,
                                  x_Key_rec.dem_rec.ordered_quantity-v_QtyDelta)
            AND (NOT
            (IsFrozen(TRUNC(SYSDATE), x_Group_rec,
                      x_Key_rec.dem_rec.request_date) OR
             IsFrozen(TRUNC(SYSDATE), x_Group_rec,
                     x_Key_rec.dem_rec.schedule_date)) OR x_Sched_rec.schedule_source = 'MANUAL') THEN --Bugfix 8221799
            --
            DeleteRequirement(x_Sched_rec, x_Group_rec,
                        x_Key_rec, k_RECONCILE,
                        v_DeleteQty);
            v_QtyDelta := v_QtyDelta - x_Key_rec.dem_rec.ordered_quantity;
            --
         END IF;
         --
      ELSIF  v_QtyDelta > 0 THEN
        --
        -- 4292516 added the check if req_rec.request_date falls within frozen fence also
        --
        IF NOT ProcessConstraint(x_Key_rec, v_Qty_rec, k_UPDATE, x_Key_rec.dem_rec.ordered_quantity - v_QtyDelta) THEN

          IF NOT (IsFrozen(TRUNC(SYSDATE), x_Group_rec, x_Key_rec.dem_rec.request_date) OR
                  IsFrozen(TRUNC(SYSDATE), x_Group_rec, x_Key_rec.req_rec.request_date)) OR x_Sched_rec.schedule_source = 'MANUAL' THEN --Bugfix 8221799

             UpdateRequirement(x_Sched_rec, x_Group_rec, x_Key_rec, x_Key_rec.dem_rec.ordered_quantity - v_QtyDelta);
             --
             v_QtyDelta := 0;
             --
           --Bugfix 6159269 START
          ELSE

           IF x_Key_rec.dem_rec.ordered_quantity <> g_sch_line_qty THEN
              GetMatchAttributes(x_sched_rec, x_group_rec, x_Key_rec.dem_rec,v_MatchAttrTxt);
           --
              IF (x_key_rec.dem_rec.schedule_type = 'SEQUENCED') THEN
               --
               rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_UPDATE_SEQ',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_InterfaceLineId => x_key_rec.req_rec.line_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => x_key_rec.dem_rec.line_id,
           	           x_Token1 => 'LINE',
                       x_value1 => rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
                       x_Token2 => 'ORDER',
                       x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                       x_Token3 => 'QUANTITY',
                       x_value3 => x_key_rec.dem_rec.ordered_quantity,
   	                   x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
	                   x_Token5 => 'REQ_DATE',
                       x_value5 => x_key_rec.dem_rec.request_date,
                       x_Token6 => 'SCH_LINE_QTY',
                       x_value6 => g_sch_line_qty,
  	                   x_Token7 => 'SEQ_INFO',
    	               x_value7 => nvl(x_Key_rec.dem_rec.cust_production_seq_num,'NULL') ||'-'||
	                               nvl(x_Key_rec.dem_rec.cust_model_serial_number,'NULL')||'-'||
             	                   nvl(x_Key_rec.dem_rec.customer_job,'NULL'),
                       x_Token8 => 'MATCH_ATTR',
                       x_value8 => v_MatchAttrTxt);
               --
                   IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                                      x_key_rec.req_rec.line_id);
                      rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE_SEQ',
                                       x_key_rec.req_rec.line_id);
                   END IF;
               --
                ELSE
	       --
                    rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_UPDATE',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_InterfaceLineId => x_key_rec.req_rec.line_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => x_key_rec.dem_rec.line_id,
               	       x_Token1 => 'LINE',
                       x_value1 => rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
                       x_Token2 => 'ORDER',
                       x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
    	               x_Token3 => 'QUANTITY',
                       x_value3 => x_key_rec.dem_rec.ordered_quantity,
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'REQ_DATE',
                       x_value5 => x_key_rec.dem_rec.request_date,
                       x_Token6 => 'SCH_LINE_QTY',
                       x_value6 => g_sch_line_qty,
                       x_Token7 => 'MATCH_ATTR',
                       x_value7 => v_MatchAttrTxt);
	       --
                 IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                                      x_key_rec.req_rec.line_id);
                     rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE',
                                      x_key_rec.req_rec.line_id);
                END IF;
  	       --
  	       END IF; /* Exception */

          END IF; /* g_sch_line_qty */

         END IF;  /* IsFrozen */
            --
       END IF; /* ProcessConstraint */
     --Bugfix 6159269 END
        --
      END IF;
      --
      -- Bug 3919971, 3999833 : Add OE line to g_Accounted_tab so DSP will
      -- not attempt reconciling this quantity again
      --
      v_Index := g_Accounted_Tab.COUNT+1;
      g_Accounted_tab(v_Index):= x_Key_rec.dem_rec;
      g_Accounted_Tab(v_Index).line_id := x_Key_rec.dem_rec.line_id;
      --
    END IF;
    --
  END LOOP;
  --
  IF v_QtyDelta <> 0 THEN
    -- irreconcileable differences
    StoreReconcile(x_Sched_rec, x_Group_rec, x_Key_rec,
                   v_QtyDelta);
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN e_group_error THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'group error');
       rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    raise e_group_error;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.DecreaseDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END DecreaseDemand;


/*===========================================================================

  PROCEDURE OtherDemand

===========================================================================*/
PROCEDURE OtherDemand(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                      x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                      x_Key_rec IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                      x_Demand_ref IN OUT NOCOPY RLM_RD_SV.t_Cursor_ref)
IS

  v_Qty_rec                t_Qty_rec;
  x_progress               VARCHAR2(3) := '010';
  v_Index                  NUMBER;
  v_MatchAttrTxt      VARCHAR2(2000); -- Bug 4297984
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'OtherDemand');
  END IF;
  --
  WHILE FetchDemand(x_Demand_ref, x_Key_rec) LOOP
    --
    IF SchedulePrecedence(x_Group_rec, x_sched_rec,x_Key_rec.dem_rec.schedule_type) THEN
      --
      -- Bug 3919971 : Add OE line to g_Accounted_Tab so DSP will
      -- not attempt to reconcile the quantity again
      --
      v_Index := g_Accounted_tab.COUNT+1;
      g_Accounted_Tab(v_Index) := x_Key_rec.dem_rec;
      g_Accounted_Tab(v_Index).line_id := x_Key_rec.dem_rec.line_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'x_Key_rec.dem_rec.ordered_quantity',
                       x_Key_rec.dem_rec.ordered_quantity);
         rlm_core_sv.dlog(k_DEBUG, 'x_Key_rec.req_rec.primary_quantity',
                       x_Key_rec.req_rec.primary_quantity);
      END IF;

    --bug2308608

    --IF AttributeChange(x_Key_rec) THEN

        -- Bug 2802487
        -- Changes:
        -- (1) Pass x_Key_rec.dem_rec.ordered_quantity to
        --     ProcessConstraint instead of passing 0 quantity.
        -- (2) Pass x_Key_rec.dem_rec.ordered_quantity to
        --     UpdateRequirement.
        -- Result: if primary quantity equals SumOrderedQty,
        -- update SO line with the same existing quantity,
        -- or in other words, no ordered qty update would occur at all.
        -- Also update SO line with any attribute changes.

        -- Bug 4297984 Start
        IF NOT (IsFrozen(TRUNC(SYSDATE), x_Group_rec, x_Key_rec.dem_rec.request_date) OR
                IsFrozen(TRUNC(SYSDATE), x_Group_rec, x_Key_rec.req_rec.request_date)) OR x_Sched_rec.schedule_source = 'MANUAL' THEN --Bugfix 8221799
            --
            IF NOT ProcessConstraint(x_Key_rec, v_Qty_rec, k_UPDATE_ATTR,
                                     x_Key_rec.dem_rec.ordered_quantity) THEN
              --
              UpdateRequirement(x_Sched_rec, x_Group_rec, x_Key_rec,
                                x_Key_rec.dem_rec.ordered_quantity);
              --
            ELSE
              --
              GetMatchAttributes(x_sched_rec, x_group_rec, x_Key_rec.dem_rec,v_MatchAttrTxt);
              --
              IF (x_Key_rec.dem_rec.schedule_type = 'SEQUENCED') THEN
                  --
                  rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_warn_level,
                     x_MessageName => 'RLM_UNABLE_ATTR_UPDATE_SEQ',
                     x_InterfaceHeaderId => x_sched_rec.header_id,
                     x_InterfaceLineId => x_Key_rec.req_rec.line_id,
                     x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                     x_ScheduleLineId => x_Key_rec.req_rec.schedule_line_id,
                     x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                     x_OrderLineId => x_Key_rec.dem_rec.line_id,
                     x_Token1 => 'LINE',
                     x_value1 =>rlm_core_sv.get_order_line_number(x_Key_rec.dem_rec.line_id),
                     x_Token2 => 'ORDER',
                     x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                     x_Token3 => 'QUANTITY',
                     x_value3 => x_Key_rec.dem_rec.ordered_quantity,
                     x_Token4 => 'CUSTITEM',
                     x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                     x_Token5 => 'REQ_DATE',
                     x_value5 => x_key_rec.dem_rec.request_date,
                     x_Token6 => 'SEQ_INFO',
                     x_value6 => nvl(x_key_rec.dem_rec.cust_production_seq_num,'NULL') ||'-'||
                                 nvl(x_key_rec.dem_rec.cust_model_serial_number,'NULL')||'-'||
                                 nvl(x_key_rec.dem_rec.customer_job,'NULL'),
                     x_Token7 => 'MATCH_ATTR',
                     x_value7 => v_MatchAttrTxt);
                  --
                  IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'Process Constraints on line',
                                       x_key_rec.req_rec.line_id);
                      rlm_core_sv.dlog(k_DEBUG,'RLM_UNABLE_ATTR_UPDATE_SEQ',
                                       x_key_rec.req_rec.line_id);
                  END IF;
                  --
              ELSE
                  --
                  rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_warn_level,
                     x_MessageName => 'RLM_UNABLE_ATTR_UPDATE',
                     x_InterfaceHeaderId => x_sched_rec.header_id,
                     x_InterfaceLineId => x_Key_rec.req_rec.line_id,
                     x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                     x_ScheduleLineId => x_Key_rec.req_rec.schedule_line_id,
                     x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                     x_OrderLineId => x_Key_rec.dem_rec.line_id,
                     x_Token1 => 'LINE',
                     x_value1 => rlm_core_sv.get_order_line_number(x_Key_rec.dem_rec.line_id),
                     x_Token2 => 'ORDER',
                     x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                     x_Token3 => 'QUANTITY',
                     x_value3 => x_Key_rec.dem_rec.ordered_quantity,
                     x_Token4 => 'CUSTITEM',
                     x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                     x_Token5 => 'REQ_DATE',
                     x_value5 => x_key_rec.dem_rec.request_date,
                     x_Token6 => 'MATCH_ATTR',
                     x_value6 => v_MatchAttrTxt);
                  --
                  IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'Process Constraints on line',
                                       x_key_rec.req_rec.line_id);
                      rlm_core_sv.dlog(k_DEBUG,'RLM_UNABLE_ATTR_UPDATE',
                                       x_key_rec.req_rec.line_id);
                  END IF;
                  --
	      END IF;
	      --
          END IF;
          --
	ELSE
          IF x_Key_rec.dem_rec.ordered_quantity <> g_sch_line_qty THEN        --Bugfix 6159269
           GetMatchAttributes(x_sched_rec, x_group_rec, x_Key_rec.dem_rec,v_MatchAttrTxt);
           --
           IF (x_key_rec.dem_rec.schedule_type = 'SEQUENCED') THEN
               --
               rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_UPDATE_SEQ',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_InterfaceLineId => x_key_rec.req_rec.line_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => x_key_rec.dem_rec.line_id,
                       x_Token1 => 'LINE',
                       x_value1 => rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
                       x_Token2 => 'ORDER',
                       x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                       x_Token3 => 'QUANTITY',
                       x_value3 => x_key_rec.dem_rec.ordered_quantity,
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'REQ_DATE',
                       x_value5 => x_key_rec.dem_rec.request_date,
    	               x_Token6 => 'SCH_LINE_QTY',            --Bugfix 6159269
                       x_value6 => g_sch_line_qty,            --Bugfix 6159269
                       x_Token7 => 'SEQ_INFO',
                       x_value7 => nvl(x_Key_rec.dem_rec.cust_production_seq_num,'NULL') ||'-'||
                                   nvl(x_Key_rec.dem_rec.cust_model_serial_number,'NULL')||'-'||
                                   nvl(x_Key_rec.dem_rec.customer_job,'NULL'),
                       x_Token8 => 'MATCH_ATTR',
                       x_value8 => v_MatchAttrTxt);
               --
               IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                                    x_key_rec.req_rec.line_id);
                   rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE_SEQ',
                                    x_key_rec.req_rec.line_id);
               END IF;
               --
           ELSE
               --
               rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_UPDATE',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_InterfaceLineId => x_key_rec.req_rec.line_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_ScheduleLineId => x_key_rec.req_rec.schedule_line_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => x_key_rec.dem_rec.line_id,
                       x_Token1 => 'LINE',
                       x_value1 => rlm_core_sv.get_order_line_number(x_key_rec.dem_rec.line_id),
                       x_Token2 => 'ORDER',
                       x_value2 => rlm_core_sv.get_order_number(x_group_rec.setup_terms_rec.header_id),
                       x_Token3 => 'QUANTITY',
                       x_value3 => x_key_rec.dem_rec.ordered_quantity,
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'REQ_DATE',
                       x_value5 => x_key_rec.dem_rec.request_date,
                       x_Token6 => 'SCH_LINE_QTY',               --Bugfix 6159269
                       x_value6 => g_sch_line_qty,               --Bugfix 6159269
                       x_Token7 => 'MATCH_ATTR',
                       x_value7 => v_MatchAttrTxt);
               --
               IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(k_DEBUG,'The line is within frozen fence',
                                    x_key_rec.req_rec.line_id);
                   rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_UPDATE',
                                    x_key_rec.req_rec.line_id);
               END IF;
               --
	   END IF;
  END IF; --Bugfix 6159269
           --
        END IF;  /* IsFrozen */
        -- Bug 4297984 End
    END IF;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.OtherDemand',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END OtherDemand;


/*===========================================================================

  PROCEDURE SetOperation

===========================================================================*/
PROCEDURE SetOperation(x_Key_rec IN RLM_RD_SV.t_Key_rec,
                       x_Operation IN VARCHAR2,
                       x_Quantity IN NUMBER := NULL)
IS

  v_Index  NUMBER;
  x_progress          VARCHAR2(3) := '010';
  --pdue
  v_line_id_tab   t_matching_line;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'SetOperation');
     rlm_core_sv.dlog(k_DEBUG, 'x_Quantity',
                   x_Quantity);
  END IF;
  --
  IF x_Operation = k_DELETE THEN
    --pdue, global_atp
    v_line_id_tab(0) := x_Key_rec.dem_rec.line_id;
    IF NOT AlreadyUpdated(v_line_id_tab) THEN
      --
      v_Index := g_Op_tab_Unschedule.COUNT + 1;
      g_Op_tab_Unschedule(v_Index) := x_Key_rec.dem_rec;
      g_Op_tab_Unschedule(v_Index).operation := OE_GLOBALS.G_OPR_DELETE;
      g_Op_tab_Unschedule(v_Index).ordered_quantity := x_Quantity;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).line_id',
                       g_Op_tab_Unschedule(v_Index).line_id);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).operation',
                       g_Op_tab_Unschedule(v_Index).operation);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).ship_to_org_id',
                       g_Op_tab_Unschedule(v_Index).ship_to_org_id);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).invoice_to_org_id',
                       g_Op_tab_Unschedule(v_Index).invoice_to_org_id);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).inventory_item_id',
                       g_Op_tab_Unschedule(v_Index).inventory_item_id);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).schedule_date',
                       g_Op_tab_Unschedule(v_Index).schedule_date);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).request_date',
                       g_Op_tab_Unschedule(v_Index).request_date);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).ordered_quantity',
                       g_Op_tab_Unschedule(v_Index).ordered_quantity);
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).UOM_code',
                       g_Op_tab_Unschedule(v_Index).UOM_code);
      END IF;
      --
    END IF;
    --
  ELSE

    IF x_Operation = k_INSERT THEN
      --pdue
      v_Index := g_Op_tab.COUNT + 1;
      g_Op_tab(v_Index) := x_Key_rec.req_rec;
      g_Op_tab(v_Index).line_id := NULL;
      g_Op_tab(v_Index).operation := OE_GLOBALS.G_OPR_CREATE;
      g_Op_tab(v_Index).ordered_quantity := x_Quantity;
      --
    ELSIF x_Operation = k_UPDATE THEN
      --pdue, global_atp
      IF x_Quantity < x_Key_rec.dem_rec.ordered_quantity THEN
        --
        v_Index := g_Op_tab_Unschedule.COUNT + 1;
        g_Op_tab_Unschedule(v_Index) := x_Key_rec.req_rec;
        g_Op_tab_Unschedule(v_Index).operation := OE_GLOBALS.G_OPR_UPDATE;
        g_Op_tab_Unschedule(v_Index).line_id := x_Key_rec.dem_rec.line_id;
        g_Op_tab_Unschedule(v_Index).ordered_quantity := x_Quantity;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).line_id',
                         g_Op_tab_Unschedule(v_Index).line_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).operation',
                         g_Op_tab_Unschedule(v_Index).operation);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).ship_to_org_id',
                         g_Op_tab_Unschedule(v_Index).ship_to_org_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).invoice_to_org_id',
                         g_Op_tab_Unschedule(v_Index).invoice_to_org_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).inventory_item_id',
                         g_Op_tab_Unschedule(v_Index).inventory_item_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).schedule_date',
                         g_Op_tab_Unschedule(v_Index).schedule_date);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).request_date',
                         g_Op_tab_Unschedule(v_Index).request_date);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).ordered_quantity',
                         g_Op_tab_Unschedule(v_Index).ordered_quantity);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule(v_Index).UOM_code',
                         g_Op_tab_Unschedule(v_Index).UOM_code);
        END IF;
        --
      ELSE
        --
        v_Index := g_Op_tab.COUNT + 1;
        g_Op_tab(v_Index) := x_Key_rec.req_rec;
        g_Op_tab(v_Index).operation := OE_GLOBALS.G_OPR_UPDATE;
        g_Op_tab(v_Index).line_id := x_Key_rec.dem_rec.line_id;
        g_Op_tab(v_Index).ordered_quantity := x_Quantity;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).line_id',
                         g_Op_tab(v_Index).line_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).operation',
                         g_Op_tab(v_Index).operation);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).ship_to_org_id',
                         g_Op_tab(v_Index).ship_to_org_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).invoice_to_org_id',
                         g_Op_tab(v_Index).invoice_to_org_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).inventory_item_id',
                         g_Op_tab(v_Index).inventory_item_id);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).schedule_date',
                         g_Op_tab(v_Index).schedule_date);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).request_date',
                         g_Op_tab(v_Index).request_date);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).ordered_quantity',
                         g_Op_tab(v_Index).ordered_quantity);
           rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab(v_Index).UOM_code',
                         g_Op_tab(v_Index).UOM_code);
        END IF;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.SetOperation',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END SetOperation;

/*===========================================================================

  FUNCTION  IsLineConsumable

===========================================================================*/
FUNCTION IsLineConsumable(x_consume_tab IN t_consume_tab,
                          x_line_id IN RLM_INTERFACE_LINES.LINE_ID%TYPE,
                          x_index   OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS

  x_progress          VARCHAR2(3) := '010';
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'IsLineConsumable');
  END IF;
  --
  FOR i IN 1..x_consume_tab.COUNT LOOP
    --
    IF x_consume_tab(i).line_id = x_line_id THEN
      --
      x_Index := i;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'index', i);
         rlm_core_sv.dlog(k_DEBUG, 'returning False');
         rlm_core_sv.dpop(k_SDEBUG);
      END IF;
      --
      RETURN FALSE;
      --
    END IF;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'returning true');
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN TRUE;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.IsLineConsumable',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END IsLineConsumable;


/*===========================================================================

  FUNCTION  UpdateGroupStatus

===========================================================================*/
PROCEDURE UpdateGroupStatus( x_header_id    IN     NUMBER,
                             x_ScheduleHeaderId  IN     NUMBER,
                             x_Group_rec    IN     rlm_dp_sv.t_Group_rec,
                             x_status       IN     NUMBER,
                             x_UpdateLevel  IN  VARCHAR2)
IS
x_progress      VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'UpdateGroupStatus');
     rlm_core_sv.dlog(k_DEBUG,'UpdateGroupStatus to ', x_status);
     rlm_core_sv.dlog(k_DEBUG,'x_header_id ', x_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id ',
                                   x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id ',
                                   x_Group_rec.order_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_org_id ',
                                   x_Group_rec.ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id ',
                                   x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_ScheduleHeaderId ', x_ScheduleHeaderId);
     rlm_core_sv.dlog(k_DEBUG,'x_UpdateLevel to ', x_UpdateLevel);
  END IF;
  --
  IF x_UpdateLevel  <> 'GROUP' THEN
     --
     UPDATE rlm_interface_lines
     SET    process_status = x_Status
     WHERE  header_id  = x_header_id
     AND    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                               rlm_core_sv.k_PS_FROZEN_FIRM)
     AND    item_detail_type IN (k_PAST_DUE_FIRM, k_FIRM, k_FORECAST, k_RECT);
     --
     UPDATE rlm_schedule_lines
     SET    process_status = x_Status
     WHERE  header_id  = x_ScheduleHeaderid
     AND    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                             rlm_core_sv.k_PS_FROZEN_FIRM)
     AND    item_detail_type IN (k_PAST_DUE_FIRM, k_FIRM, k_FORECAST, k_RECT);
     --
  ELSE
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'Update Group');
     END IF;
     --
     UPDATE rlm_interface_lines
     SET    process_status = x_Status
     WHERE  header_id  = x_header_id
     AND    ship_from_org_id = x_Group_rec.ship_from_org_id
     AND    ship_to_org_id = x_Group_rec.ship_to_org_id
     AND    customer_item_id = x_Group_rec.customer_item_id
     AND    inventory_item_id = x_Group_rec.inventory_item_id
     AND    order_header_id = x_Group_rec.order_header_id
     /*AND    nvl(cust_production_seq_num,k_VNULL) =
                              nvl(x_Group_rec.cust_production_seq_num, k_VNULL)
     AND    process_status  IN (rlm_core_sv.k_PS_AVAILABLE,
                                    rlm_core_sv.k_PS_FROZEN_FIRM) */
     AND    item_detail_type IN (k_PAST_DUE_FIRM, k_FIRM, k_FORECAST, k_RECT);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'No of interface Lines Updated ', SQL%ROWCOUNT);
     END IF;
     --
     UPDATE rlm_schedule_lines
     SET    process_status = x_Status
     WHERE  header_id  = x_ScheduleheaderId
     AND    ship_from_org_id = x_Group_rec.ship_from_org_id
     AND    ship_to_org_id = x_Group_rec.ship_to_org_id
     AND    customer_item_id = x_Group_rec.customer_item_id
     AND    inventory_item_id = x_Group_rec.inventory_item_id
     --AND    order_header_id = x_Group_rec.order_header_id
     /*AND    nvl(cust_production_seq_num, k_VNULL) =
                     nvl(x_Group_rec.cust_production_seq_num, k_VNULL)*/
     AND    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                     rlm_core_sv.k_PS_FROZEN_FIRM, rlm_core_sv.k_PS_ERROR)
     AND    item_detail_type IN (k_PAST_DUE_FIRM, k_FIRM, k_FORECAST, k_RECT);
     --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'No of Schedule Lines Updated ', SQL%ROWCOUNT);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_rd_sv.UpdateGroupStatus',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RAISE ;
    --
END UpdateGroupStatus;

/*===========================================================================

  FUNCTION IsFrozen

===========================================================================*/
FUNCTION IsFrozen(x_horizon_start_date IN DATE,
                  x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                  x_ShipDate IN DATE)
RETURN BOOLEAN
IS

  x_progress                    VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'IsFrozen');
     rlm_core_sv.dlog(k_DEBUG,'x_ShipToId',x_group_rec.ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_ShipfromOrgId',x_group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_horizon_start_date',x_horizon_start_date);
     rlm_core_sv.dlog(k_DEBUG,'x_ShipDate',x_ShipDate);
     rlm_core_sv.dlog(k_DEBUG,'frozen_days',x_Group_rec.frozen_days);
  END IF;
  --
  /*
  --global_atp
  IF g_ATP = k_ATP THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'FALSE');
    END IF;
    --
    RETURN FALSE;
    --
  END IF;
  */

  /* check if the order line falls within the frozen fence */
  --
  IF ((to_date(to_char(x_ShipDate,'DD-MM-YYYY'),'DD-MM-YYYY')) <
       (to_date(to_char(x_horizon_start_date,'DD-MM-YYYY'),'DD-MM-YYYY') +
         x_Group_rec.frozen_days )) AND x_Group_rec.frozen_days <> 0 THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'TRUE');
    END IF;
    --
    RETURN(TRUE);
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'FALSE');
    END IF;
    --
    RETURN(FALSE);
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_rd_sv.IsFrozen', x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    RAISE;
    --
END IsFrozen;
--
/*===========================================================================

  FUNCTION  LockHeaders

===========================================================================*/
FUNCTION LockHeaders (x_header_id         IN     NUMBER)
RETURN BOOLEAN
IS
   x_progress      VARCHAR2(3) := '010';

   CURSOR c IS
     SELECT *
     FROM   rlm_interface_headers
     WHERE  header_id  = x_header_id
     AND   process_status IN (rlm_core_sv.k_PS_AVAILABLE,rlm_core_sv.k_PS_PARTIAL_PROCESSED)
     FOR UPDATE NOWAIT;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'LockHeaders');
     rlm_core_sv.dlog(k_DEBUG,'Locking RLM_INTERFACE_HEADERS');
  END IF;
  --
  OPEN  c;
  --
  CLOSE c;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'Returning True ');
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN TRUE;
  --
EXCEPTION
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'REturning FALSE');
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RETURN FALSE;
    --
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.LockHeaders',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'REturning FALSE OTHERS ');
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RETURN FALSE;

END LockHeaders;

/*===========================================================================

  PROCEDURE  UpdateHeaderStatus

===========================================================================*/
PROCEDURE UpdateHeaderStatus( x_HeaderId    IN     NUMBER,
                              x_ScheduleHeaderId  IN     NUMBER,
                              x_status       IN     NUMBER)
IS
  x_progress      VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'UpdateHeaderStatus');
     rlm_core_sv.dlog(k_DEBUG,'UpdateHeaderStatus to ', x_status);
  END IF;
  --
  UPDATE rlm_interface_headers
  SET    process_status = x_Status
  WHERE  header_id  = x_HeaderId;

  UPDATE rlm_schedule_headers
  SET    process_status = x_Status
  WHERE  header_id  = x_ScheduleHeaderId;

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_rd_sv.UpdateHeaderStatus',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RAISE ;
    --
END UpdateHeaderStatus;

/*===========================================================================

  FUNCTION  LockLines

===========================================================================*/
FUNCTION LockLines (x_Group_rec         IN     rlm_dp_sv.t_Group_rec,
                    x_header_id         IN     NUMBER)
RETURN BOOLEAN
IS
   x_progress      VARCHAR2(3) := '010';

   CURSOR c IS
     SELECT *
     FROM   rlm_interface_lines_all
     WHERE  header_id  = x_header_id
     AND    ship_from_org_id = x_Group_rec.ship_from_org_id
     AND    ship_to_org_id = x_Group_rec.ship_to_org_id
     AND    customer_item_id = x_Group_rec.customer_item_id
     AND    inventory_item_id = x_Group_rec.inventory_item_id
     --AND    nvl(schedule_item_num,k_NNULL) = nvl(x_Group_rec.schedule_item_num, k_NNULL)
     AND    order_header_id = x_Group_rec.order_header_id
     /*AND    nvl(cust_production_seq_num,k_VNULL) = nvl(x_Group_rec.cust_production_seq_num, k_VNULL)*/
     AND    process_status  IN (rlm_core_sv.k_PS_AVAILABLE, rlm_core_sv.k_PS_FROZEN_FIRM)
     FOR UPDATE NOWAIT;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'LockLines');
     rlm_core_sv.dlog(k_DEBUG,'Locking RLM_INTERFACE_LINES');
  END IF;
  --
  OPEN  c;
  --
  CLOSE c;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'Returning True ');
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN TRUE;
  --
EXCEPTION
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'REturning FALSE');
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RETURN FALSE;
    --
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.LockLines',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'REturning FALSE OTHERS ');
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RETURN FALSE;
    --
END LockLines;

/*===========================================================================

PROCEDURE NAME:    CheckTolerance

===========================================================================*/

PROCEDURE CheckTolerance(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                         x_Key_rec IN RLM_RD_SV.t_Key_rec,
                         x_OldQty IN NUMBER,
                         x_NewQty IN NUMBER)
IS

  v_PctDelta        NUMBER;
  v_item_no         VARCHAR2(80);
  v_Progress        VARCHAR2(3) := '010';
  v_text            VARCHAR2(2000) := NULL;
  x_DemandTolerancePos NUMBER;
  x_DemandToleranceNeg NUMBER;
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'checktolerance');
     rlm_core_sv.dlog(k_DEBUG,'CustomerItemId',x_Group_rec.Customer_Item_Id);
     rlm_core_sv.dlog(k_DEBUG,'x_OldQty',x_OldQty);
     rlm_core_sv.dlog(k_DEBUG,'x_NewQty',x_NewQty);
     rlm_core_sv.dlog(k_DEBUG,'x_DemandTolerancePos',
                     x_Group_rec.setup_terms_rec.demand_tolerance_above);
     rlm_core_sv.dlog(k_DEBUG,'x_DemandToleranceNeg',
                     x_group_rec.setup_terms_rec.demand_tolerance_below);
  END IF;
  --
  -- Verify that the quantity change falls within the defined tolerance limits
  -- for the passed customer_item_id
  --
  x_DemandTolerancePos := x_Group_rec.setup_terms_rec.demand_tolerance_above;
  x_DemandToleranceNeg := x_Group_rec.setup_terms_rec.demand_tolerance_below;
  --
  IF nvl(x_OldQty,0) <> 0 THEN
     --
     v_PctDelta := ((x_NewQty - x_OldQty)/x_OldQty)*100;
     v_PctDelta := round(v_PctDelta,2);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'v_PctDelta',v_PctDelta);
     END IF;
     --
     IF (x_DemandTolerancePos < v_PctDelta) OR
        (x_DemandToleranceNeg < ABS(v_PctDelta)) THEN
      --
      rlm_message_sv.app_error(
          x_ExceptionLevel => rlm_message_sv.k_warn_level,
          x_MessageName => 'RLM_TOLERANCE_CHECK_FAILED',
          x_InterfaceHeaderId => x_sched_rec.header_id,
          x_InterfaceLineId => x_Key_rec.req_rec.line_id,
          x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
          x_ScheduleLineId => x_Key_rec.req_rec.schedule_line_id,
          x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
          x_OrderLineId => x_Key_rec.dem_rec.line_id,
          x_token1=>'CUSITEM',
          x_value1=>rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
          x_token2=>'PCT_DELTA1',
          x_value2=>v_PctDelta,
          x_token3=>'PCT_DELTA_POSITIVE',
          x_value3=>x_DemandTolerancePos,
          x_token4=>'PCT_DELTA_NEGATIVE',
          x_value4=>x_DemandToleranceNeg);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'WARNING:RLM_TOLERANCE_CHECK_FAILED');
         rlm_core_sv.dlog(k_DEBUG,'tolerance check failed');
      END IF;
      --
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_rd_sv.CheckTolerance', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHERS - sql error');
    END IF;
    --
    raise;
    --
END CheckTolerance;
--

/*===========================================================================

        FUNCTION NAME:  AlreadyUpdated

===========================================================================*/
FUNCTION AlreadyUpdated(x_line_id_tab IN t_matching_line)
RETURN BOOLEAN
IS
  v_already_updated BOOLEAN DEFAULT FALSE;
BEGIN
  --
  IF (l_debug <> -1) THEN
     --{
     rlm_core_sv.dpush(k_SDEBUG, 'AlreadyUpdated');
     rlm_core_sv.dlog(k_DEBUG, 'x_line_id_tab.COUNT', x_line_id_tab.COUNT);
     rlm_core_sv.dlog(k_DEBUG, 'x_line_id_tab(0)', x_line_id_tab(0));
     rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab.COUNT', g_Op_tab.COUNT);
     rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab_Unschedule.COUNT', g_Op_tab_Unschedule.COUNT);
     rlm_core_sv.dlog(k_DEBUG, 'g_Accounted_Tab.COUNT', g_Accounted_Tab.COUNT);
     --
     IF g_Op_tab.COUNT <> 0 THEN
       FOR i IN g_Op_Tab.FIRST..g_Op_Tab.LAST LOOP
         rlm_core_sv.dlog(k_DEBUG, 'g_Op_Tab('||i||').line_id',
                                 g_Op_Tab(i).line_id);
       END LOOP;
     END IF;
     --
     IF g_Op_Tab_Unschedule.COUNT <> 0 THEN
       FOR i IN g_Op_Tab_Unschedule.FIRST..g_Op_Tab_unschedule.LAST LOOP
        rlm_core_sv.dlog(k_DEBUG, 'g_Op_Tab_Unschedule('||i||').line_id',
                                 g_Op_Tab_Unschedule(i).line_id);
       END LOOP;
     END IF;
     --
     IF g_Accounted_Tab.COUNT <> 0 THEN
       FOR i IN g_Accounted_Tab.FIRST..g_Accounted_Tab.LAST LOOP
        rlm_core_sv.dlog(k_DEBUG, 'g_Accounted_Tab('||i||').line_id',
                                 g_Accounted_Tab(i).line_id);
       END LOOP;
     END IF;
     --}
  END IF;
  --
  IF (x_line_id_tab.COUNT = 0) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
     END IF;
     --
     RETURN FALSE;
     --
  END IF;

  IF g_Op_tab.COUNT <> 0 THEN
     --
     FOR i IN x_line_id_tab.FIRST..x_line_id_tab.LAST LOOP
       --
       FOR j IN g_Op_tab.FIRST..g_Op_tab.LAST LOOP
	 --
	 IF x_line_id_tab(i) = g_Op_tab(j).line_id THEN
	   --
           IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(k_DEBUG, 'This line id has already been updated', x_line_id_tab(i));
             rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
           END IF;
           --
          RETURN TRUE;
          --
	 END IF;
	 --
       END LOOP;
       --
     END LOOP;
     --
  END IF;
  --
  --
  IF g_Accounted_tab.COUNT <> 0 THEN
     --
     FOR i IN x_line_id_tab.FIRST..x_line_id_tab.LAST LOOP
       --
       FOR j IN g_Accounted_tab.FIRST..g_Accounted_tab.LAST LOOP
	 --
	 IF x_line_id_tab(i) = g_Accounted_tab(j).line_id THEN
	   --
	   IF (l_debug <> -1) THEN
   	     rlm_core_sv.dlog(k_DEBUG, 'This line id has already been updated', x_line_id_tab(i));
	     rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
           END IF;
           --
           RETURN TRUE;
           --
	 END IF;
	 --
       END LOOP;
       --
     END LOOP;
     --
  END IF;
  --
  --
  --global_atp
  --
  IF g_Op_tab_Unschedule.COUNT <> 0 THEN
     --
     FOR k IN x_line_id_tab.FIRST..x_line_id_tab.LAST LOOP
       --
       FOR l IN g_Op_tab_Unschedule.FIRST..g_Op_tab_Unschedule.LAST LOOP
         --
         IF x_line_id_tab(k) = g_Op_tab_Unschedule(l).line_id THEN
            --
            IF (l_debug <> -1) THEN
   	       rlm_core_sv.dlog(k_DEBUG, 'This line id has already been updated', x_line_id_tab(k));
               rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
            END IF;
            --
            RETURN TRUE;
            --
	 END IF;
	 --
       END LOOP;
       --
     END LOOP;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
     END IF;
     --
     RETURN FALSE;
     --
  ELSE
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
     END IF;
     --
     RETURN FALSE;
     --
  END IF;
  --
EXCEPTION
   --
   WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
       rlm_core_sv.dpop(k_SDEBUG, 'When Others - FALSE');
      END IF;
      --
      RETURN FALSE;
      --

END;
--
/*===========================================================================

        FUNCTION NAME:  GetTPContext

===========================================================================*/
PROCEDURE GetTPContext( x_sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
                        x_group_rec  IN rlm_dp_sv.t_Group_rec,
                        x_req_rec    IN rlm_rd_sv.t_generic_rec,
                        x_customer_number OUT NOCOPY VARCHAR2,
                        x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                        x_tp_group_code OUT NOCOPY VARCHAR2,
                        x_key_rec    IN  rlm_rd_sv.t_key_rec)
IS

   --
   v_Progress VARCHAR2(3) := '010';
   v_ece_tp_location_code_ext VARCHAR2(35);
   v_ece_tp_translator_code   VARCHAR2(35);
   --
BEGIN
   --
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(k_SDEBUG,'GetTPContext');
   END IF;
   --
   IF(x_sched_rec.header_id is not null) then
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'customer_id', x_sched_rec.customer_id);
        rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.ece_tp_translator_code',
                               x_sched_rec.ece_tp_translator_code);
        rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.ece_tp_location_code_ext',
                               x_sched_rec.ece_tp_location_code_ext);
        rlm_core_sv.dlog(k_DEBUG,'x_group_rec.ship_to_address_id',
                               x_group_rec.ship_to_address_id);
        rlm_core_sv.dlog(k_DEBUG,'x_group_rec.bill_to_address_id',
                             x_group_rec.bill_to_address_id);
     END IF;
     --
     IF x_sched_rec.ECE_TP_LOCATION_CODE_EXT is NOT NULL THEN
       --
       -- Following query is changed as per TCA obsolescence project.
      SELECT	ETG.TP_GROUP_CODE
      INTO	x_tp_group_code
      FROM	ECE_TP_GROUP ETG,
		ECE_TP_HEADERS ETH,
		HZ_CUST_ACCT_SITES ACCT_SITE
      WHERE  	ETG.TP_GROUP_ID = ETH.TP_GROUP_ID
      and	ETH.TP_HEADER_ID = ACCT_SITE.TP_HEADER_ID
      and	ACCT_SITE.CUST_ACCOUNT_ID  = x_sched_rec.CUSTOMER_ID
      and	ACCT_SITE.ECE_TP_LOCATION_CODE = x_Sched_rec.ECE_TP_LOCATION_CODE_EXT;

     ELSE
       x_tp_group_code := x_sched_rec.ECE_TP_TRANSLATOR_CODE;
     END IF;
     --
     BEGIN
       --
       -- Following query is changed as per TCA obsolescence project.
	SELECT	ece_tp_location_code
	INTO	x_ship_to_ece_locn_code
	FROM	HZ_CUST_ACCT_SITES ACCT_SITE
	WHERE	ACCT_SITE.CUST_ACCT_SITE_ID = x_group_rec.ship_to_address_id;
       --
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_ship_to_ece_locn_code := NULL;
     END;
     --

     --

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
        rlm_core_sv.dlog(k_DEBUG, 'customer_number', x_customer_number);
        rlm_core_sv.dlog(k_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_tp_group_code',x_tp_group_code);
     END IF;
     --
   ELSIF(x_key_rec.req_rec.header_id is not NULL) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'customer_id', x_key_rec.req_rec.customer_id);
        rlm_core_sv.dlog(k_DEBUG,'ship_to_address_id',
                             x_key_rec.req_rec.ship_to_address_id);
        rlm_core_sv.dlog(k_DEBUG,'bill_to_address_id',
                             x_key_rec.req_rec.bill_to_address_id);
     END IF;
     --
     SELECT ECE_TP_LOCATION_CODE_EXT, ECE_TP_TRANSLATOR_CODE
     INTO   v_ece_tp_location_code_ext,v_ece_tp_translator_code
     FROM   rlm_interface_headers
     WHERE  header_id = x_key_rec.req_rec.header_id;
     --
     IF v_ECE_TP_LOCATION_CODE_EXT is NOT NULL THEN
       --
       -- Following query is changed as per TCA obsolescence project.
	SELECT	ETG.TP_GROUP_CODE
	INTO	x_tp_group_code
	FROM	ECE_TP_GROUP ETG,
		ECE_TP_HEADERS ETH,
		HZ_CUST_ACCT_SITES   ACCT_SITE
	WHERE	ETG.TP_GROUP_ID = ETH.TP_GROUP_ID
	and	ETH.TP_HEADER_ID = ACCT_SITE.TP_HEADER_ID
	and	ACCT_SITE.ECE_TP_LOCATION_CODE = v_ECE_TP_LOCATION_CODE_EXT ;
     ELSE
       x_tp_group_code := v_ECE_TP_TRANSLATOR_CODE;
     END IF;
     --
     BEGIN
       --
       -- Following query is changed as per TCA obsolescence project.
	SELECT	ece_tp_location_code
	INTO	x_ship_to_ece_locn_code
	FROM	HZ_CUST_ACCT_SITES
	WHERE	CUST_ACCT_SITE_ID = x_key_rec.req_rec.ship_to_address_id;
       --
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_ship_to_ece_locn_code := NULL;
     END;
     --

     --  BUG 2204888 : Since we do not group by bill_to anymore, we would not
     --  have the bill_to in x_group_rec. Code has been removed as a part of
     --  TCA OBSOLESCENCE PROJECT.

     --
     IF x_key_rec.req_rec.customer_id is NOT NULL THEN
        --
        -- Following query is changed as per TCA obsolescence project.
	SELECT	account_number
	INTO	x_customer_number
	FROM	HZ_CUST_ACCOUNTS
	WHERE	ACCOUNT_NUMBER  = x_key_rec.req_rec.customer_id;
        --
     END IF;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'customer_number', x_customer_number);
        rlm_core_sv.dlog(k_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_tp_group_code',x_tp_group_code);
     END IF;
     --
   ELSE
     --
     BEGIN
       --
       -- Following query is changed as per TCA obsolescence project.
	SELECT	ece_tp_location_code
	INTO	x_ship_to_ece_locn_code
	FROM	HZ_CUST_ACCT_SITES
	WHERE	CUST_ACCT_SITE_ID = x_group_rec.ship_to_address_id;
       --
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_ship_to_ece_locn_code := NULL;
     END;
     --

     --   BUG 2204888 : Since we do not group by bill_to anymore, we would not
     --   have the bill_to in x_group_rec. Code has been removed as a part of
     --   TCA OBSOLESCENCE PROJECT.

     --
     IF x_group_rec.customer_id is NOT NULL THEN
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
        rlm_core_sv.dlog(k_DEBUG, 'customer_number', x_customer_number);
        rlm_core_sv.dlog(k_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
        rlm_core_sv.dlog(k_DEBUG, 'x_tp_group_code',x_tp_group_code);
     END IF;
     --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
      --
      x_customer_number := NULL;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'No data found for' , x_sched_rec.customer_id);
         rlm_core_sv.dpop(k_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.GetTPContext',v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END GetTPContext;


PROCEDURE InitializeMatchRec(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                             x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                             x_match_ref IN OUT NOCOPY t_Cursor_ref) IS
  --
  x_progress  VARCHAR2(3) := '010';
  x_Query     VARCHAR2(32767);
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'InitializeMatchRec');
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_org_id', x_Group_rec.ship_to_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_item_id', x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id', x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.order_header_id', x_Group_rec.order_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_start_date', x_Sched_rec.sched_horizon_start_date);
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.sched_horizon_end_date', x_Sched_rec.sched_horizon_end_date);
  END IF;
  --
  OPEN x_match_ref FOR
	SELECT
	   DECODE(x_Group_rec.match_within_rec.cust_production_line,'Y',cust_production_line, NULL),
	   DECODE(x_Group_rec.match_within_rec.customer_dock_code,'Y',customer_dock_code,NULL),
           NULL,--request_date
	   NULL,--schedule_date
	   DECODE(x_Group_rec.match_within_rec.cust_po_number,'Y',cust_po_number,NULL),
	   DECODE(x_Group_rec.match_within_rec.customer_item_revision,'Y', customer_item_revision, NULL),
    	   DECODE(x_Group_rec.match_within_rec.customer_job,'Y',customer_job, NULL),
	   DECODE(x_Group_rec.match_within_rec.cust_model_serial_number,'Y',cust_model_serial_number, NULL),
  	   DECODE(x_Group_rec.match_within_rec.cust_production_seq_num,'Y',cust_production_seq_num,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute1,'Y', industry_attribute1,NULL),
	   NULL,
           NULL,
           DECODE(x_Group_rec.match_within_rec.industry_attribute4,'Y', industry_attribute4,NULL),
           DECODE(x_Group_rec.match_within_rec.industry_attribute5,'Y', industry_attribute5,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute6,'Y', industry_attribute6,NULL),
	   NULL,
	   NULL,
	   DECODE(x_Group_rec.match_within_rec.industry_attribute9,  'Y', industry_attribute9,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute10, 'Y', industry_attribute10,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute11, 'Y', industry_attribute11,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute12, 'Y', industry_attribute12,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute13, 'Y', industry_attribute13,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute14, 'Y', industry_attribute14,NULL),
	   DECODE(x_Group_rec.match_within_rec.industry_attribute15, 'Y', industry_attribute15,NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute1, 'Y', attribute1, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute2, 'Y', attribute2, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute3, 'Y', attribute3, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute4, 'Y', attribute4, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute5, 'Y', attribute5, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute6, 'Y', attribute6, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute7, 'Y', attribute7, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute8, 'Y', attribute8, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute9, 'Y', attribute9, NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute10, 'Y', attribute10,NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute11, 'Y', attribute11,NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute12, 'Y', attribute12,NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute13, 'Y', attribute13,NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute14, 'Y', attribute14,NULL),
	   DECODE(x_Group_rec.match_within_rec.attribute15, 'Y', attribute15,NULL)
    FROM   rlm_interface_lines
    WHERE  header_id = x_Sched_rec.header_id
      	AND  ship_from_org_id = x_Group_rec.ship_from_org_id
      	AND  ship_to_org_id = x_Group_rec.ship_to_org_id
	AND  customer_item_id = x_Group_rec.customer_item_id
      	AND  inventory_item_id = x_Group_rec.inventory_item_id
     	AND  order_header_id = x_Group_rec.order_header_id
     	AND  item_detail_type IN (k_FIRM, k_FORECAST, k_PAST_DUE_FIRM);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG, 'InitializeMatchRec');
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
       rlm_message_sv.sql_error('RLM_RD_SV.InitializeMatchRec', x_progress);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG, 'EXCEPTION: ' || SUBSTR(SQLERRM,1,200));
       END IF;
       --
       RAISE e_group_error;

END InitializeMatchRec;


FUNCTION FetchMatchRec(x_match_ref     IN OUT NOCOPY t_Cursor_ref,
		       x_opt_match_rec IN OUT NOCOPY WSH_RLM_INTERFACE.t_optional_match_rec)
RETURN BOOLEAN IS

  x_progress VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush('FetchMatchRec');
  END IF;
  --
  FETCH x_match_ref INTO
    x_opt_match_rec.cust_production_line,
    x_opt_match_rec.customer_dock_code,
    x_opt_match_rec.request_date,
    x_opt_match_rec.schedule_date,
    x_opt_match_rec.cust_po_number,
    x_opt_match_rec.customer_item_revision,
    x_opt_match_rec.customer_job,
    x_opt_match_rec.cust_model_serial_number,
    x_opt_match_rec.cust_production_seq_num,
    x_opt_match_rec.industry_attribute1,
    x_opt_match_rec.industry_attribute2,
    x_opt_match_rec.industry_attribute3,
    x_opt_match_rec.industry_attribute4,
    x_opt_match_rec.industry_attribute5,
    x_opt_match_rec.industry_attribute6,
    x_opt_match_rec.industry_attribute7,
    x_opt_match_rec.industry_attribute8,
    x_opt_match_rec.industry_attribute9,
    x_opt_match_rec.industry_attribute10,
    x_opt_match_rec.industry_attribute11,
    x_opt_match_rec.industry_attribute12,
    x_opt_match_rec.industry_attribute13,
    x_opt_match_rec.industry_attribute14,
    x_opt_match_rec.industry_attribute15,
    x_opt_match_rec.attribute1,
    x_opt_match_rec.attribute2,
    x_opt_match_rec.attribute3,
    x_opt_match_rec.attribute4,
    x_opt_match_rec.attribute5,
    x_opt_match_rec.attribute6,
    x_opt_match_rec.attribute7,
    x_opt_match_rec.attribute8,
    x_opt_match_rec.attribute9,
    x_opt_match_rec.attribute10,
    x_opt_match_rec.attribute11,
    x_opt_match_rec.attribute12,
    x_opt_match_rec.attribute13,
    x_opt_match_rec.attribute14,
    x_opt_match_rec.attribute15;
  --
  IF x_match_ref%NOTFOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
    RETURN (FALSE);
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'true');
    END IF;
    --
    RETURN (TRUE);
    --
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
       rlm_message_sv.sql_error('RLM_RD_SV.FetchMatchRec', x_progress);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG, 'EXCEPTION: ' || SUBSTR(SQLERRM,1,200));
       END IF;
       --
       RAISE e_group_error;
  --
END FetchMatchRec;


PROCEDURE PrintMatchRec(x_opt_match_rec IN WSH_RLM_INTERFACE.t_optional_match_rec) IS

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'PrintMatchRec');
     rlm_core_sv.dlog(k_DEBUG, 'Production Line', x_opt_match_rec.cust_production_line);
     rlm_core_sv.dlog(k_DEBUG, 'Customer dock code', x_opt_match_rec.customer_dock_code);
     rlm_core_sv.dlog(k_DEBUG, 'Cust PO Number', x_opt_match_rec.cust_po_number);
     rlm_core_sv.dlog(k_DEBUG, 'Customer item revision', x_opt_match_rec.customer_item_revision);
     rlm_core_sv.dlog(k_DEBUG, 'Customer job', x_opt_match_rec.customer_job);
     rlm_core_sv.dlog(k_DEBUG, 'Model serial number', x_opt_match_rec.cust_model_serial_number);
     rlm_core_sv.dlog(k_DEBUG, 'Prod seq num', x_opt_match_rec.cust_production_seq_num);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute1', x_opt_match_rec.industry_attribute1);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute2', x_opt_match_rec.industry_attribute1);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute4', x_opt_match_rec.industry_attribute4);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute5', x_opt_match_rec.industry_attribute5);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute6', x_opt_match_rec.industry_attribute6);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute9', x_opt_match_rec.industry_attribute9);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute10', x_opt_match_rec.industry_attribute10);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute11', x_opt_match_rec.industry_attribute11);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute12', x_opt_match_rec.industry_attribute12);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute13', x_opt_match_rec.industry_attribute13);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute14', x_opt_match_rec.industry_attribute14);
     rlm_core_sv.dlog(k_DEBUG, 'Industry attribute15', x_opt_match_rec.industry_attribute15);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute1', x_opt_match_rec.attribute1);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute2', x_opt_match_rec.attribute2);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute3', x_opt_match_rec.attribute3);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute4', x_opt_match_rec.attribute4);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute5', x_opt_match_rec.attribute5);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute6', x_opt_match_rec.attribute6);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute7', x_opt_match_rec.attribute7);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute8', x_opt_match_rec.attribute8);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute9', x_opt_match_rec.attribute9);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute10', x_opt_match_rec.attribute10);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute11', x_opt_match_rec.attribute11);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute12', x_opt_match_rec.attribute12);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute13', x_opt_match_rec.attribute13);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute14', x_opt_match_rec.attribute14);
     rlm_core_sv.dlog(k_DEBUG, 'Attribute15', x_opt_match_rec.attribute15);
     rlm_core_sv.dpop(k_SDEBUG, 'PrintMatchRec');
  END IF;
  --
END PrintMatchRec;


FUNCTION AlreadyMatched(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
			x_match_rec IN WSH_RLM_INTERFACE.t_optional_match_rec, x_Index OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  --
  b_Match 	BOOLEAN;
  e_NoMatch	EXCEPTION;
  x_progress    VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'AlreadyMatched');
     rlm_core_sv.dlog(k_DEBUG, '# of rows in intransit tab', g_IntransitTab.COUNT);
  END IF;
  --
  b_Match := FALSE;
  --
  IF g_IntransitTab.COUNT = 0 THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
    RETURN (FALSE);
    --
  END IF;
  --
  FOR i IN 1..g_IntransitTab.COUNT LOOP
   --
   BEGIN
    --
    IF (x_Group_rec.match_within_rec.cust_production_line = 'Y') THEN
     IF NVL(g_IntransitTab(i).cust_production_line, k_VNULL) <> NVL(x_match_rec.cust_production_line, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'prod line didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.customer_dock_code = 'Y') THEN
     IF NVL(g_IntransitTab(i).customer_dock_code, k_VNULL) <> NVL(x_match_rec.customer_dock_code, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'dock code didnt match');
       END IF;
       --
       RAISE e_NoMatch;
       --
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.cust_po_number = 'Y') THEN
     IF NVL(g_IntransitTab(i).cust_po_number, k_VNULL) <> NVL(x_match_rec.cust_po_number, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'po num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.customer_item_revision = 'Y') THEN
     IF NVL(g_IntransitTab(i).customer_item_revision, k_VNULL) <> NVL(x_match_rec.customer_item_revision, k_VNULL)   THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'cust item rev didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.customer_job = 'Y') THEN
     IF NVL(g_IntransitTab(i).customer_job, k_VNULL) <> NVL(x_match_rec.customer_job, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'customer job didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.cust_model_serial_number = 'Y') THEN
     IF NVL(g_IntransitTab(i).cust_model_serial_number, k_VNULL) <> NVL(x_match_rec.cust_model_serial_number, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'model serial no. didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.cust_production_seq_num = 'Y') THEN
     IF NVL(g_IntransitTab(i).cust_production_seq_num, k_VNULL) <> NVL(x_match_rec.cust_production_seq_num, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'PSQ num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute1 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute1, k_VNULL) <> NVL(x_match_rec.industry_attribute1, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA1 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute4 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute4, k_VNULL) <> NVL(x_match_rec.industry_attribute4, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA4 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute5 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute5, k_VNULL) <> NVL(x_match_rec.industry_attribute5, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA5 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute6 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute6, k_VNULL) <> NVL(x_match_rec.industry_attribute6, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA6 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute9 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute9, k_VNULL) <> NVL(x_match_rec.industry_attribute9, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA9 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute10 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute10, k_VNULL) <> NVL(x_match_rec.industry_attribute10, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA10 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute11 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute11, k_VNULL) <> NVL(x_match_rec.industry_attribute11, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA11 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute12 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute12, k_VNULL) <> NVL(x_match_rec.industry_attribute12, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA12 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute13 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute13, k_VNULL) <> NVL(x_match_rec.industry_attribute13, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA13 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.industry_attribute14 = 'Y') THEN
     IF NVL(g_IntransitTab(i).industry_attribute14, k_VNULL) <> NVL(x_match_rec.industry_attribute14, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'IA14 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute1 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute1, k_VNULL) <> NVL(x_match_rec.attribute1, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A1 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute2 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute2, k_VNULL) <> NVL(x_match_rec.attribute2, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A2 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute3 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute3, k_VNULL) <> NVL(x_match_rec.attribute3, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A3 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute4 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute4, k_VNULL) <> NVL(x_match_rec.attribute4, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A4 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute5 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute5, k_VNULL) <> NVL(x_match_rec.attribute5, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A5 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute6 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute6, k_VNULL) <> NVL(x_match_rec.attribute6, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A6 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute7 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute7, k_VNULL) <> NVL(x_match_rec.attribute7, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A7 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute8 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute8, k_VNULL) <> NVL(x_match_rec.attribute8, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A8 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute9 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute9, k_VNULL) <> NVL(x_match_rec.attribute9, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A9 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute10 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute10, k_VNULL) <> NVL(x_match_rec.attribute10, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A10 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute11 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute11, k_VNULL) <> NVL(x_match_rec.attribute11, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A11 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute12 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute12, k_VNULL) <> NVL(x_match_rec.attribute12, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A12 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute13 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute13, k_VNULL) <> NVL(x_match_rec.attribute13, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A13 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute14 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute14, k_VNULL) <> NVL(x_match_rec.attribute14, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A14 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;

    IF (x_Group_rec.match_within_rec.attribute15 = 'Y') THEN
     IF NVL(g_IntransitTab(i).attribute15, k_VNULL) <> NVL(x_match_rec.attribute15, k_VNULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'A15 num didnt match');
       END IF;
       --
       RAISE e_NoMatch;
     END IF;
    END IF;
    --
    b_Match := TRUE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG, 'Matched with index', i);
    END IF;
    --
    x_Index := i;
    EXIT;
    --
    EXCEPTION
      WHEN e_NoMatch THEN
        null;
   END;
   --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG, 'AlreadyMatched');
  END IF;
  --
  RETURN (b_Match);
  --
END AlreadyMatched;

/*===========================================================================

  FUNCTION NAME:    MRPOnly

===========================================================================*/

FUNCTION MRPOnly(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                 x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec)
RETURN BOOLEAN

IS
  --
  v_Progress VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'MRPOnly');
     rlm_core_sv.dlog(k_DEBUG, 'g_Op_tab.COUNT', g_Op_tab.COUNT);
  END IF;
  --
  IF x_Sched_rec.Schedule_Source <> 'MANUAL' THEN

    IF x_Sched_rec.Schedule_type = RLM_MANAGE_DEMAND_SV.k_PLANNING THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'pln_mrp_forecast_day_from',
			x_group_rec.setup_terms_rec.pln_mrp_forecast_day_from);
      END IF;
      --
      IF x_Group_rec.setup_terms_rec.pln_mrp_forecast_day_from = 1 THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
         END IF;
         --
         RETURN TRUE;
         --
      ELSE
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
         END IF;
         --
         RETURN FALSE;
         --
      END IF;
      --
    ELSIF x_Sched_rec.Schedule_type = RLM_MANAGE_DEMAND_SV.k_SHIPPING THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'shp_mrp_forecast_day_from',
			x_group_rec.setup_terms_rec.shp_mrp_forecast_day_from);
      END IF;
      --
      IF x_Group_rec.setup_terms_rec.shp_mrp_forecast_day_from = 1 THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
         END IF;
         --
         RETURN TRUE;
         --
      ELSE
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
         END IF;
         --
         RETURN FALSE;
         --
      END IF;
      --
    ELSIF x_Sched_rec.Schedule_type = RLM_MANAGE_DEMAND_SV.k_SEQUENCED THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'seq_mrp_forecast_day_from',
			x_group_rec.setup_terms_rec.seq_mrp_forecast_day_from);
      END IF;
      --
      IF x_Group_rec.setup_terms_rec.seq_mrp_forecast_day_from = 1 THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(k_SDEBUG, 'TRUE');
         END IF;
         --
         RETURN TRUE;
         --
      ELSE
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
         END IF;
         --
         RETURN FALSE;
         --
      END IF;
      --
    ELSE
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
      END IF;
      --
      RETURN FALSE;
      --
    END IF;
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG, 'FALSE');
    END IF;
    --
    RETURN FALSE;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('RLM_RD_SV.MRPOnly', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;
     --
END MRPOnly;


PROCEDURE InsertIntransitMatchRec(x_match_rec IN WSH_RLM_INTERFACE.t_optional_match_rec,
			          x_Quantity  IN NUMBER) IS
  v_Index	NUMBER;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'InsertIntransitMatchRec');
  END IF;
  --
  v_Index := g_IntransitTab.COUNT;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, '# of rows in intransit table', v_Index);
  END IF;
  --
  g_IntransitTab(v_Index+1).cust_production_line := x_match_rec.cust_production_line;
  g_IntransitTab(v_Index+1).customer_dock_code := x_match_rec.customer_dock_code;
  g_IntransitTab(v_Index+1).request_date := NULL; --x_match_rec.request_date;
  g_IntransitTab(v_Index+1).schedule_date := NULL; --x_match_rec.schedule_date;
  g_IntransitTab(v_Index+1).cust_po_number := x_match_rec.cust_po_number;
  g_IntransitTab(v_Index+1).customer_item_revision := x_match_rec.customer_item_revision;
  g_IntransitTab(v_Index+1).customer_job := x_match_rec.customer_job;
  g_IntransitTab(v_Index+1).cust_model_serial_number := x_match_rec.cust_model_serial_number;
  g_IntransitTab(v_Index+1).cust_production_seq_num := x_match_rec.cust_production_seq_num;
  g_IntransitTab(v_Index+1).industry_attribute1 := x_match_rec.industry_attribute1;
  g_IntransitTab(v_Index+1).industry_attribute2 := NULL; --x_match_rec.industry_attribute2;
  g_IntransitTab(v_Index+1).industry_attribute3 := NULL; --x_match_rec.industry_attribute3;
  g_IntransitTab(v_Index+1).industry_attribute4 := x_match_rec.industry_attribute4;
  g_IntransitTab(v_Index+1).industry_attribute5 := x_match_rec.industry_attribute5;
  g_IntransitTab(v_Index+1).industry_attribute6 := x_match_rec.industry_attribute6;
  g_IntransitTab(v_Index+1).industry_attribute7 := NULL; --x_match_rec.industry_attribute7;
  g_IntransitTab(v_Index+1).industry_attribute8 := NULL; --x_match_rec.industry_attribute8;
  g_IntransitTab(v_Index+1).industry_attribute9 := x_match_rec.industry_attribute9;
  g_IntransitTab(v_Index+1).industry_attribute10 := x_match_rec.industry_attribute10;
  g_IntransitTab(v_Index+1).industry_attribute11 := x_match_rec.industry_attribute11;
  g_IntransitTab(v_Index+1).industry_attribute12 := x_match_rec.industry_attribute12;
  g_IntransitTab(v_Index+1).industry_attribute13 := x_match_rec.industry_attribute13;
  g_IntransitTab(v_Index+1).industry_attribute14 := x_match_rec.industry_attribute14;
  g_IntransitTab(v_Index+1).industry_attribute15 := x_match_rec.industry_attribute15;
  g_IntransitTab(v_Index+1).attribute1 := x_match_rec.attribute1;
  g_IntransitTab(v_Index+1).attribute2 := x_match_rec.attribute2;
  g_IntransitTab(v_Index+1).attribute3 := x_match_rec.attribute3;
  g_IntransitTab(v_Index+1).attribute4 := x_match_rec.attribute4;
  g_IntransitTab(v_Index+1).attribute5 := x_match_rec.attribute5;
  g_IntransitTab(v_Index+1).attribute6 := x_match_rec.attribute6;
  g_IntransitTab(v_Index+1).attribute7 := x_match_rec.attribute7;
  g_IntransitTab(v_Index+1).attribute8 := x_match_rec.attribute8;
  g_IntransitTab(v_Index+1).attribute9 := x_match_rec.attribute9;
  g_IntransitTab(v_Index+1).attribute10 := x_match_rec.attribute10;
  g_IntransitTab(v_Index+1).attribute11 := x_match_rec.attribute11;
  g_IntransitTab(v_Index+1).attribute12 := x_match_rec.attribute12;
  g_IntransitTab(v_Index+1).attribute13 := x_match_rec.attribute13;
  g_IntransitTab(v_Index+1).attribute14 := x_match_rec.attribute14;
  g_IntransitTab(v_Index+1).attribute15 := x_match_rec.attribute15;
  g_IntransitTab(v_Index+1).intransit_qty := x_Quantity;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG, 'InsertIntransitMatchRec');
  END IF;
  --
END InsertIntransitMatchRec;


--
-- Common to reconcile and manage demand
-- Set up parameters to pass to shipping API
--
PROCEDURE InitializeIntransitParam(x_Sched_rec      	  IN  RLM_INTERFACE_HEADERS%ROWTYPE,
			           x_Group_rec      	  IN  rlm_dp_sv.t_Group_rec,
				   x_intransit_calc_basis IN  VARCHAR2,
				   x_Shipper_rec    	  IN OUT NOCOPY WSH_RLM_INTERFACE.t_shipper_rec,
				   x_Shipment_date  	  IN OUT NOCOPY DATE)
IS

  -- The shipper ID is stored in the item_detail_ref_value_1 field
  -- when the item detail type = 4 and the sub type = 'RECEIPT', 'SHIPMENT'
  --
  CURSOR c_RctShipperIds IS
    SELECT start_date_time,
           primary_quantity,
           -- do not use item_ref_value_1
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
           -- do not use item_ref_value_1
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
    AND    item_detail_subtype  = k_RECEIPT
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
    AND    item_detail_subtype  = k_SHIPMENT
    ORDER BY start_date_time DESC;
  --
  v_intransit_time    		NUMBER := 0;
  v_intransit_calc_basis	VARCHAR2(15);
  v_shipment_date		DATE;
  v_item_detail_subtype		VARCHAR2(80);
  v_count			NUMBER DEFAULT 0;
  v_deliveryID			VARCHAR2(35);
  --

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'InitializeIntransitParam');
     rlm_core_sv.dlog(k_DEBUG, 'Intransit calc basis', x_intransit_calc_basis);
  END IF;
  --
  IF (x_Group_rec.setup_terms_rec.time_uom_code = 'HR') THEN
     v_intransit_time := nvl(x_Group_rec.setup_terms_rec.intransit_time,0)/24;
  ELSE
     v_intransit_time := nvl(x_Group_rec.setup_terms_rec.intransit_time,0);
  END IF;
  --
  IF (x_intransit_calc_basis = k_RECEIPT) THEN
   --
   OPEN  c_LastReceipt;
   FETCH c_LastReceipt INTO v_shipment_date, v_item_detail_subtype, v_deliveryID;
   --
   IF (c_LastReceipt%NOTFOUND) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'No receipt line, so shipment date = sched_gen_Date - intransit');
     END IF;
     --
     v_shipment_date := x_Sched_rec.sched_generation_date - v_intransit_time;
     x_shipper_rec.shipper_Id1 := NULL;
     x_Shipper_rec.shipper_Id2 := NULL;
     x_Shipper_rec.shipper_Id3 := NULL;
     x_Shipper_rec.shipper_Id4 := NULL;
     x_Shipper_rec.shipper_Id5 := NULL;
     --
   ELSIF (v_deliveryID is NOT NULL) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog('Delivery ID present on schedule');
     END IF;
     --
     FOR v_RctSID IN c_RctShipperIds LOOP
     --
      IF (c_RctShipperIds%NOTFOUND  OR v_count > 5) THEN
       EXIT;
      END IF;
     --
     v_count := v_count + 1;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'line_id', v_RctSID.line_id);
        rlm_core_sv.dlog(k_DEBUG,'start_date_time', v_RctSID.start_date_time);
        rlm_core_sv.dlog(k_DEBUG,'v_count', v_count);
        rlm_core_sv.dlog(k_DEBUG,'Shipper_id', v_RctSID.shipper_Id);
     END IF;
     --
     IF v_count = 1 THEN
       --
       x_shipper_rec.shipper_Id1 := v_RctSID.shipper_Id;
       --
     ELSIF v_count = 2  THEN
       --
       x_shipper_rec.shipper_Id2 := v_RctSID.shipper_Id;
       --
     ELSIF v_count = 3  THEN
       --
       x_shipper_rec.shipper_Id3 := v_RctSID.shipper_Id;
       --
     ELSIF v_count = 4  THEN
       --
       x_shipper_rec.shipper_Id4 := v_RctSID.shipper_Id;
       --
     ELSIF v_count = 5  THEN
       --
       x_shipper_rec.shipper_Id5 := v_RctSID.shipper_Id;
       --
     END IF;
     --
    END LOOP;
     --
   ELSIF (v_shipment_date IS NOT NULL) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'No delivery ID present on schedule');
     END IF;
     --
     v_shipment_date := v_shipment_date - v_intransit_time;
     x_shipper_rec.shipper_Id1 := NULL;
     x_Shipper_rec.shipper_Id2 := NULL;
     x_Shipper_rec.shipper_Id3 := NULL;
     x_Shipper_rec.shipper_Id4 := NULL;
     x_Shipper_rec.shipper_Id5 := NULL;
     --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'v_item_detail_subtype', v_item_detail_subtype);
      rlm_core_sv.dlog(k_DEBUG, 'calculated shipment_date', v_shipment_date);
   END IF;
   --
   x_Shipment_date := v_shipment_date;
   CLOSE c_LastReceipt;
   --
  ELSIF (x_intransit_calc_basis = k_SHIPMENT) THEN
   --
   OPEN  c_LastShipment;
   FETCH c_LastShipment INTO v_shipment_date, v_item_detail_subtype, v_deliveryID;
   --
   IF (c_LastShipment%NOTFOUND) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'No shipment line, so shipment date = sched_gen_Date');
     END IF;
     --
     v_shipment_date := x_Sched_rec.sched_generation_date;
     x_shipper_rec.shipper_Id1 := NULL;
     x_Shipper_rec.shipper_Id2 := NULL;
     x_Shipper_rec.shipper_Id3 := NULL;
     x_Shipper_rec.shipper_Id4 := NULL;
     x_Shipper_rec.shipper_Id5 := NULL;
     --
   ELSIF (v_deliveryID is NOT NULL) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog('Delivery ID present on schedule');
     END IF;
     --
     FOR v_ShpSID IN c_ShpShipperIds LOOP
     --
      IF (c_ShpShipperIds%NOTFOUND  OR v_count > 5) THEN
       EXIT;
      END IF;
     --
     v_count := v_count + 1;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'line_id', v_ShpSID.line_id);
        rlm_core_sv.dlog(k_DEBUG,'start_date_time', v_ShpSID.start_date_time);
        rlm_core_sv.dlog(k_DEBUG,'v_count', v_count);
        rlm_core_sv.dlog(k_DEBUG,'Shipper_id', v_ShpSID.shipper_Id);
     END IF;
     --
     IF v_count = 1 THEN
       --
       x_shipper_rec.shipper_Id1 := v_ShpSID.shipper_Id;
       --
     ELSIF v_count = 2  THEN
       --
       x_shipper_rec.shipper_Id2 := v_ShpSID.shipper_Id;
       --
     ELSIF v_count = 3  THEN
       --
       x_shipper_rec.shipper_Id3 := v_ShpSID.shipper_Id;
       --
     ELSIF v_count = 4  THEN
       --
       x_shipper_rec.shipper_Id4 := v_ShpSID.shipper_Id;
       --
     ELSIF v_count = 5  THEN
       --
       x_shipper_rec.shipper_Id5 := v_ShpSID.shipper_Id;
       --
     END IF;
     --
    END LOOP;
    --
   ELSIF (v_shipment_date IS NOT NULL) THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG, 'No delivery ID present on schedule');
    END IF;
    --
    x_shipper_rec.shipper_Id1 := NULL;
    x_Shipper_rec.shipper_Id2 := NULL;
    x_Shipper_rec.shipper_Id3 := NULL;
    x_Shipper_rec.shipper_Id4 := NULL;
    x_Shipper_rec.shipper_Id5 := NULL;
    --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'v_item_detail_subtype', v_item_detail_subtype);
      rlm_core_sv.dlog(k_DEBUG, 'calculated shipment_date', v_shipment_date);
   END IF;
   --
   x_Shipment_date := v_shipment_date;
   CLOSE c_LastShipment;
   --
  END IF; /* if intransit_calc_basis */
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG, 'InitializeIntransitParam');
  END IF;
  --
END InitializeIntransitParam;


--
-- Blanket Order Procedures
--
/*===========================================================================

  PROCEDURE InitializeBlktGroup

===========================================================================*/
PROCEDURE InitializeBlktGrp(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_ref IN OUT NOCOPY   rlm_rd_sv.t_Cursor_ref,
                          x_Group_rec IN OUT NOCOPY  rlm_dp_sv.t_Group_rec)
IS
  --
  x_progress          VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG,'InitializeBlktGroup');
  END IF;
  --
  OPEN x_Group_ref FOR
    SELECT   rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             rso.rso_hdr_id,
	     ril.blanket_number,
             rso.effective_start_date,
             ril.intrmd_ship_to_id,      --Bugfix 5911991
	     ril.intmed_ship_to_org_id   --Bugfix 5911991
    FROM     rlm_interface_headers   rih,
             rlm_interface_lines_all ril,
	     rlm_blanket_rso rso
    WHERE    rih.header_id = x_Sched_rec.header_id
    AND      rih.org_id = ril.org_id
    AND      ril.header_id = rih.header_id
    AND      ril.ship_from_org_id = x_Group_rec.ship_from_org_id
    AND      ril.process_status IN (rlm_core_sv.k_PS_AVAILABLE, rlm_core_sv.k_PS_FROZEN_FIRM)
    AND      ril.customer_item_id = x_Group_rec.customer_item_id
    AND      ril.ship_to_address_id = x_Group_rec.ship_to_address_id
    AND      ril.blanket_number = rso.blanket_number
    AND      rih.customer_id    = rso.customer_id
    AND      item_detail_type IN (k_FIRM, k_FORECAST, k_PAST_DUE_FIRM)
    AND      rso.customer_item_id = DECODE(x_Group_rec.setup_terms_rec.release_rule, 'PI',
				    x_Group_rec.customer_item_id, K_NNULL)
    GROUP BY rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             rso.rso_hdr_id,
             ril.blanket_number,
             rso.effective_start_date,
             ril.intrmd_ship_to_id,      --Bugfix 5911991
     	     ril.intmed_ship_to_org_id   --Bugfix 5911991
    ORDER BY ril.ship_from_org_id,
	     ril.ship_to_org_id,
             ril.customer_item_id,
             rso.effective_start_date;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.InitializeBlktGrp',x_progress);
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'When others of InitializeBlktGrp');
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise e_group_error;
  --
END InitializeBlktGrp;


/*===========================================================================

  FUNCTION FetchBlktGroup

===========================================================================*/
FUNCTION FetchBlktGrp(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                      x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN
IS
  --
  x_progress          VARCHAR2(3) := '010';
  v_effective_start_date DATE;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG,'FetchBlktGroup');
  END IF;
  --
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
    v_effective_start_date,
    x_Group_rec.intrmd_ship_to_id,       --Bugfix 5911991
    x_Group_rec.intmed_ship_to_org_id ;  --Bugfix 5911991
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG,'Blanket Number', x_Group_rec.blanket_number);
    rlm_core_sv.dlog(k_DEBUG,'Order header ID', x_Group_rec.order_header_id);
    rlm_core_sv.dlog(k_DEBUG,'v_effective_start_date',v_effective_start_date);
  END IF;
  --
  IF x_Group_ref%NOTFOUND THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG, 'false');
    END IF;
    --
    RETURN(FALSE);
  ELSE
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG, 'true');
    END IF;
    --
    RETURN(TRUE);
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.FetchBlktGrp',x_progress);
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'When others of FetchBlktGrp');
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
  --
END FetchBlktGrp;


/*                                                                       *
 * SQL Bind Project: These functions just build a combined table         *
 * of bind variable values to be passed to RLM_CORE_SV.OpenDynamicCursor *
*/
FUNCTION BuildBindVarTab3(p_Tab1 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab2 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab3 IN RLM_CORE_SV.t_dynamic_tab)
RETURN RLM_CORE_SV.t_dynamic_tab IS
  --
  x_BindVarTab	RLM_CORE_SV.t_dynamic_tab;
  x_Progress	VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG, 'BuildBindVarTab3');
  END IF;
  --
  FOR i IN 1..p_Tab1.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab1(i);
  END LOOP;
  --
  FOR i IN 1..p_Tab2.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab2(i);
  END LOOP;
  --
  FOR i IN 1..p_Tab3.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab3(i);
  END LOOP;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN x_BindVarTab;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_rd_sv.BuildBindVarTab3',x_progress);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG, 'Exception ' ||  substr(SQLERRM, 1, 200));
    END IF;
    --
    raise;
    --
END BuildBindVarTab3;


FUNCTION BuildBindVarTab5(p_Tab1 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab2 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab3 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab4 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab5 IN RLM_CORE_SV.t_dynamic_tab)
RETURN RLM_CORE_SV.t_dynamic_tab IS
  --
  x_BindVarTab	RLM_CORE_SV.t_dynamic_tab;
  x_Progress	VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG, 'BuildBindVarTab5');
  END IF;
  --
  FOR i IN 1..p_Tab1.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab1(i);
  END LOOP;
  --
  FOR i IN 1..p_Tab2.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab2(i);
  END LOOP;
  --
  FOR i IN 1..p_Tab3.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab3(i);
  END LOOP;
  --
  FOR i IN 1..p_Tab4.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab4(i);
  END LOOP;
  --
  FOR i IN 1..p_Tab5.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab5(i);
  END LOOP;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN x_BindVarTab;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_rd_sv.BuildBindVarTab5',x_progress);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG, 'Exception ' || substr(SQLERRM, 1, 200));
    END IF;
    --
    raise;
    --
END BuildBindVarTab5;


FUNCTION BuildBindVarTab2(p_Tab1 IN RLM_CORE_SV.t_dynamic_tab,
			  p_Tab2 IN RLM_CORE_SV.t_dynamic_tab)
RETURN RLM_CORE_SV.t_dynamic_tab IS
  --
  x_BindVarTab	RLM_CORE_SV.t_dynamic_tab;
  x_Progress	VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG, 'BuildBindVarTab2');
  END IF;
  --
  FOR i IN 1..p_Tab1.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab1(i);
  END LOOP;
  --
  FOR i IN 1..p_Tab2.COUNT LOOP
   x_BindVarTab(x_BindVarTab.COUNT+1) := p_Tab2(i);
  END LOOP;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN x_BindVarTab;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_rd_sv.BuildBindVarTab2',x_progress);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG, 'Exception ' || substr(SQLERRM, 1, 200));
    END IF;
    --
    raise;
    --
END BuildBindVarTab2;


/*============================================================================

PROCEDURE NAME: SourceCUMIntransitQty

==============================================================================*/
PROCEDURE SourceCUMIntransitQty(x_Sched_rec    IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                x_Group_rec    IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                                x_Cum_rec      IN RLM_RD_SV.t_Ship_rec) --Bugfix 7007638
IS
  --
  i                     NUMBER;
  j                     NUMBER;
  v_SrcIntransitTab     RLM_MANAGE_DEMAND_SV.t_SrcIntransitQtyTab;
  v_Progress		VARCHAR2(3);
  v_Key_rec		t_Key_rec;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(k_SDEBUG, 'SourceCUMIntransitQty');
   rlm_core_sv.dlog(k_DEBUG, 'IntransitQty to be sourced', g_IntransitQty);
   rlm_core_sv.dlog(k_DEBUG, 'g_SourceTab.COUNT', g_SourceTab.COUNT);
   --
   FOR i IN g_SourceTab.FIRST..g_SourceTab.LAST LOOP
    rlm_core_sv.dlog(k_DEBUG, 'g_SourceTab('||i||').organization_id',
                               g_SourceTab(i).organization_id);
    rlm_core_sv.dlog(k_DEBUG, 'g_SourceTab('||i||').allocation_percent',
                               g_SourceTab(i).allocation_percent);
   END LOOP;
   --
  END IF;
  --
  v_Progress := '010';
  --
  i := g_SourceTab.FIRST;
  j := 0;
  --
  WHILE i IS NOT NULL LOOP
   --{
   j := j+1;
   --
   v_SrcIntransitTab(j).intransit_qty :=
     ROUND(g_IntransitQty * g_SourceTab(i).allocation_percent/100);
   v_SrcIntransitTab(j).organization_id := g_SourceTab(i).organization_id;
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG, 'v_SrcIntransitTab('||j||').intransit_qty',
                               v_SrcIntransitTab(j).intransit_qty);
    rlm_core_sv.dlog(k_DEBUG, 'v_SrcIntransitTab('||j||').organization_id',
                               v_SrcIntransitTab(j).organization_id);
   END IF;
   --
   i := g_SourceTab.NEXT(i);
   --}
  END LOOP;
  --
  v_Progress := '020';
  i := v_SrcIntransitTab.FIRST;
  --
  WHILE i IS NOT NULL LOOP
   --{
   IF v_SrcIntransitTab(i).organization_id = x_Group_rec.ship_from_org_id THEN
    --
    v_Key_rec.rlm_line_id         := null;
    v_Key_rec.req_rec.customer_id := x_Group_rec.customer_id;
    v_Key_rec.req_rec.customer_item_id := x_Group_rec.customer_item_id;
    v_Key_rec.req_rec.inventory_item_id := x_Group_rec.inventory_item_id;
    v_Key_rec.req_rec.ship_to_org_id := x_Group_rec.ship_to_org_id;
    v_Key_rec.req_rec.order_header_id := x_Group_rec.order_header_id;
    v_Key_rec.req_rec.ship_from_org_id := v_SrcIntransitTab(i).organization_id;
    v_Key_rec.req_rec.shipment_flag := 'SHIPMENT';
    v_Key_rec.req_rec.schedule_type := x_Sched_rec.schedule_type;
    --
    -- Bugfix 7007638 Start
    IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
       v_Key_rec.req_rec.cust_po_number := x_Cum_rec.purchase_order_number;
    ELSIF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
          v_Key_rec.req_rec.industry_attribute1 := x_Cum_rec.cust_record_year;
    END IF;
   -- Bugfix 7007638 End
    RLM_RD_SV.StoreShipments(x_Sched_rec, x_Group_rec, v_Key_rec,
                             v_SrcIntransitTab(i).intransit_qty);
    --
   END IF;
   --
   i := v_SrcIntransitTab.NEXT(i);
   --}
  END LOOP;
  --
  v_Progress := '030';
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('RLM_RD_SV.SourceCUMIntransitQty',v_Progress);
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'progress',v_Progress);
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    RAISE;
    --
END SourceCUMIntransitQty;



PROCEDURE CalculateCUMIntransit(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                                x_Line_id IN NUMBER, --Bugfix 7007638
                                x_Intransit OUT NOCOPY NUMBER)
IS
  --
  v_cum_key_record      RLM_CUM_SV.cum_key_attrib_rec_type;
  v_cum_record          RLM_CUM_SV.cum_rec_type;
  v_PrimaryQty          NUMBER;
  v_CUMQty              NUMBER;
  v_SupQty              NUMBER;
  v_Intransit           NUMBER;
  v_LineID              NUMBER;
  v_Progress            VARCHAR2(3);
  e_no_cum_key          EXCEPTION;
  v_control_text        VARCHAR2(100); --Bugfix 7007638
  v_control_value       VARCHAR2(100); --Bugfix 7007638
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(k_SDEBUG, 'CalculateCUMIntransit');
   rlm_core_sv.dlog(k_DEBUG, 'x_Line_id', x_Line_id); --Bugfix 7007638
  END IF;
  --
  v_CUMQty := 0;
  v_SupQty := 0;
  v_Intransit := 0;
  v_Progress := '010';
  --
  SELECT    x_group_rec.customer_id,
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
            line_id
  INTO      v_cum_key_record.customer_id,
            v_cum_key_record.customer_item_id,
            v_cum_key_record.inventory_item_id,
            v_cum_key_record.ship_from_org_id,
            v_cum_key_record.intrmd_ship_to_address_id,
            v_cum_key_record.ship_to_address_id,
            v_cum_key_record.bill_to_address_id,
            v_cum_key_record.purchase_order_number,
            v_PrimaryQty,
            v_CUMQty,
            v_cum_key_record.cum_start_date,
            v_cum_key_record.cust_record_year,
            v_LineID
  FROM      rlm_interface_lines
  WHERE     header_id = x_Sched_rec.header_id
  AND       item_detail_type = RLM_MANAGE_DEMAND_SV.k_SHIP_RECEIPT_INFO
  AND       item_detail_subtype = RLM_MANAGE_DEMAND_SV.k_CUM
  AND       ship_from_org_id   = x_Group_rec.ship_from_org_id
  AND       ship_to_address_id = x_Group_rec.ship_to_address_id
  AND       inventory_item_id = x_Group_rec.inventory_item_id
  AND       customer_item_id  = x_Group_rec.customer_item_id
  AND       line_id = x_Line_id --Bugfix 7007638
  ORDER BY  start_date_time desc;
  --
  v_cum_key_record.create_cum_key_flag := 'N';
  RLM_TPA_SV.CalculateCUMKey(v_cum_key_record, v_cum_record);
  --
  v_Progress := '020';
  --
  IF v_cum_record.cum_key_id IS NULL THEN
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
        v_control_value := v_cum_key_record.cum_start_date;
     END IF;
     --Bugfix 7007638
   --
   RAISE e_No_Cum_Key;
   --
  ELSE
   --
   v_SupQty := NVL(v_cum_record.cum_qty,0) +
               NVL(v_cum_record.cum_qty_after_cutoff,0) +
               NVL(v_cum_record.cum_qty_to_be_accumulated,0);
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(k_DEBUG, 'Supplier CUM Qty', v_SupQty);
   rlm_core_sv.dlog(k_DEBUG, 'Customer CUM Qty', v_CUMQty);
  END IF;
  --
  IF NVL(v_SupQty, 0) <> NVL(v_CUMQty, 0) THEN
    v_Intransit := v_SupQty - v_CUMQty;
  END IF;
  --
  x_Intransit := v_Intransit;
  v_Progress := '030';
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
     -- 4307505  [
     WHEN NO_DATA_FOUND THEN
     v_Intransit := 0;
     x_Intransit := 0;
     rlm_message_sv.app_error(
         x_ExceptionLevel => rlm_message_sv.k_warn_level,
         x_MessageName => 'RLM_NO_CUM_INTRST_CUST_CUM',
         x_InterfaceHeaderId => x_sched_rec.header_id,
         x_InterfaceLineId => NULL,
         x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
         x_ScheduleLineId => NULL ,
         x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
         x_OrderLineId => NULL,
         x_Token1 => 'SHIP_TO',
         x_Value1 =>
            rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id),
         x_Token2 => 'CITEM',
         x_Value2 =>
            rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
         x_GroupInfo  => TRUE);
     --
     IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'- warning: RLM_CUM_STUP_NO_RECORD');
         rlm_core_sv.dlog(k_DEBUG,'- Intransit Qty = 0 considered to be 0 in this case');
         rlm_core_sv.dpop(k_SDEBUG);
     END IF;
    -- 4307505  ]
    WHEN e_no_cum_key THEN
      --
      rlm_message_sv.app_error(
                      x_ExceptionLevel => rlm_message_sv.k_warn_level,
                      x_MessageName => 'RLM_CUM_KEY_MISSING',
                      x_InterfaceHeaderId => x_sched_rec.header_id,
                      x_InterfaceLineId => NULL,
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
        rlm_core_sv.dlog(k_DEBUG, 'No CUM Key Found - intransit qty no calc');
        rlm_core_sv.dpop(k_SDEBUG);
      END IF;
      --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_rd_sv.CalculateCUMIntransit',v_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END CalculateCUMIntransit;


/*============================================================================

PROCEDURE NAME: AssignOEAttribValues

This procedure uses the information in p_OEDemand_rec structure to populate values
for the dem_rec component of x_Key_rec.  This is currently only called from
procedure ProcessOld() and can eventually be used to eliminate calls to GetDemand().

==============================================================================*/
PROCEDURE AssignOEAttribValues(x_Key_rec      IN OUT NOCOPY RLM_RD_SV.t_Key_rec,
                               p_OEDemand_rec IN RLM_RD_SV.t_OEDemand_rec) IS
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(k_SDEBUG, 'AssignOEAttribValues');
  END IF;
  --
  x_Key_rec.oe_line_id            := p_OEDemand_rec.line_id;
  x_Key_rec.dem_rec.line_id       := p_OEDemand_rec.line_id;
  x_Key_rec.dem_rec.request_date  := p_OEDemand_rec.request_date;
  x_Key_rec.dem_rec.schedule_date := p_OEDemand_rec.schedule_ship_date;
  --
  x_Key_rec.dem_rec.ship_from_org_id  := p_OEDemand_rec.ship_from_org_id;
  x_Key_rec.dem_rec.ship_to_org_id    := p_OEDemand_rec.ship_to_org_id;
  x_Key_rec.dem_rec.invoice_to_org_id := p_OEDemand_rec.invoice_to_org_id;
  x_Key_rec.dem_rec.customer_item_id  := p_OEDemand_rec.ordered_item_id;
  x_Key_rec.dem_rec.inventory_item_id := p_OEDemand_rec.inventory_item_id;
  x_Key_rec.dem_rec.order_header_id   := p_OEDemand_rec.header_id;
  x_Key_rec.dem_rec.blanket_number    := p_OEDemand_rec.blanket_number;
  x_Key_rec.dem_rec.customer_item_ext := p_OEDemand_rec.ordered_item;
  x_Key_rec.dem_rec.intmed_ship_to_org_id := p_OEDemand_rec.intmed_ship_to_org_id;
  --
  x_Key_rec.dem_rec.item_detail_type := p_OEDemand_rec.item_type_code;
  x_Key_rec.dem_rec.schedule_type    := p_OEDemand_rec.rla_schedule_type_code;
  x_Key_rec.dem_rec.ordered_quantity := p_OEDemand_rec.orig_ordered_quantity;
  x_Key_rec.dem_rec.item_identifier_type := p_OEDemand_rec.item_identifier_type;
  x_Key_rec.dem_rec.item_detail_subtype  := p_OEDemand_rec.demand_bucket_type_code;
  x_Key_rec.dem_rec.authorized_to_ship_flag := p_OEDemand_rec.authorized_to_ship_flag;
  --
  x_Key_rec.dem_rec.cust_po_line_num   := p_OEDemand_rec.customer_line_number;
  x_Key_rec.dem_rec.customer_dock_code := p_OEDemand_rec.customer_dock_code;
  x_Key_rec.dem_rec.cust_po_number     := p_OEDemand_rec.cust_po_number;
  x_Key_rec.dem_rec.customer_job       := p_OEDemand_rec.customer_job;
  x_Key_rec.dem_rec.customer_item_revision := p_OEDemand_rec.customer_item_revision;
  x_Key_rec.dem_rec.cust_production_line   := p_OEDemand_rec.cust_production_line;
  x_Key_rec.dem_rec.cust_production_seq_num  := p_OEDemand_rec.cust_production_seq_num;
  x_Key_rec.dem_rec.cust_model_serial_number := p_OEDemand_rec.cust_model_serial_number;
  --
  x_Key_rec.dem_rec.industry_attribute1  := p_OEDemand_rec.industry_attribute1;
  x_Key_rec.dem_rec.industry_attribute2  := p_OEDemand_rec.industry_attribute2;
  x_Key_rec.dem_rec.industry_attribute3  := p_OEDemand_rec.industry_attribute3;
  x_Key_rec.dem_rec.industry_attribute4  := p_OEDemand_rec.industry_attribute4;
  x_Key_rec.dem_rec.industry_attribute5  := p_OEDemand_rec.industry_attribute5;
  x_Key_rec.dem_rec.industry_attribute6  := p_OEDemand_rec.industry_attribute6;
  x_Key_rec.dem_rec.industry_attribute7  := p_OEDemand_rec.industry_attribute7;
  x_Key_rec.dem_rec.industry_attribute8  := p_OEDemand_rec.industry_attribute8;
  x_Key_rec.dem_rec.industry_attribute9  := p_OEDemand_rec.industry_attribute9;
  x_Key_rec.dem_rec.industry_attribute10 := p_OEDemand_rec.industry_attribute10;
  x_Key_rec.dem_rec.industry_attribute11 := p_OEDemand_rec.industry_attribute11;
  x_Key_rec.dem_rec.industry_attribute12 := p_OEDemand_rec.industry_attribute12;
  x_Key_rec.dem_rec.industry_attribute13 := p_OEDemand_rec.industry_attribute13;
  x_Key_rec.dem_rec.industry_attribute14 := p_OEDemand_rec.industry_attribute14;
  x_Key_rec.dem_rec.industry_attribute15 := p_OEDemand_rec.industry_attribute15;
  --
  x_Key_rec.dem_rec.attribute1  := p_OEDemand_rec.attribute1;
  x_Key_rec.dem_rec.attribute2  := p_OEDemand_rec.attribute2;
  x_Key_rec.dem_rec.attribute3  := p_OEDemand_rec.attribute3;
  x_Key_rec.dem_rec.attribute4  := p_OEDemand_rec.attribute4;
  x_Key_rec.dem_rec.attribute5  := p_OEDemand_rec.attribute5;
  x_Key_rec.dem_rec.attribute6  := p_OEDemand_rec.attribute6;
  x_Key_rec.dem_rec.attribute7  := p_OEDemand_rec.attribute7;
  x_Key_rec.dem_rec.attribute8  := p_OEDemand_rec.attribute8;
  x_Key_rec.dem_rec.attribute9  := p_OEDemand_rec.attribute9;
  x_Key_rec.dem_rec.attribute10 := p_OEDemand_rec.attribute10;
  x_Key_rec.dem_rec.attribute11 := p_OEDemand_rec.attribute11;
  x_Key_rec.dem_rec.attribute12 := p_OEDemand_rec.attribute12;
  x_Key_rec.dem_rec.attribute13 := p_OEDemand_rec.attribute13;
  x_Key_rec.dem_rec.attribute14 := p_OEDemand_rec.attribute14;
  x_Key_rec.dem_rec.attribute15 := p_OEDemand_rec.attribute15;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('RLM_RD_SV.AssignOEAttribValues', '010');
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG, 'Unexpected error', SUBSTRB(SQLERRM, 1, 200));
       rlm_core_sv.dpop(k_SDEBUG);
     END IF;
     --
     RAISE;
     --
END AssignOEAttribValues;


/*==============================================================================
 PROCEDURE NAME: FrozenFenceWarning
Added this new procedure to give the overall frozen period warning for bug4223359
==============================================================================*/

 PROCEDURE FrozenFenceWarning(x_sched_rec IN rlm_interface_headers%ROWTYPE,
                              x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec) IS
  --
  i                        NUMBER DEFAULT 0;
  v_index                  NUMBER DEFAULT 0;
  v_Count                  NUMBER DEFAULT 0;
  v_FrozenTab              t_generic_Tab;
  x_frozenWarnQty          NUMBER;
  v_frozenDays             NUMBER;
  v_frozenFrom             NUMBER;
  v_MatchAttrTxt           VARCHAR2(2000);
  --
 BEGIN
   --{
   IF (l_debug  > -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, ' FrozenFenceWarning ');
   END IF;
    --
    IF x_Sched_rec.Schedule_type = 'PLANNING_RELEASE' THEN
       --
       v_frozenDays :=  nvl(x_Group_rec.setup_terms_rec.pln_frozen_day_to,0) -
                         nvl(x_Group_rec.setup_terms_rec.pln_frozen_day_from, 0) + 1;
       v_frozenFrom := x_group_rec.setup_terms_rec.pln_frozen_day_from;
       --
    ELSIF x_Sched_rec.Schedule_type = 'SHIPPING' THEN
       --
       v_frozenDays :=  nvl(x_Group_rec.setup_terms_rec.shp_frozen_day_to,0) -
                       nvl(x_Group_rec.setup_terms_rec.shp_frozen_day_from, 0) + 1;
       v_frozenFrom := x_group_rec.setup_terms_rec.shp_frozen_day_from;
       --
    ELSE
       --
       v_frozenDays :=  nvl(x_Group_rec.setup_terms_rec.seq_frozen_day_to,0) -
                         nvl(x_Group_rec.setup_terms_rec.seq_frozen_day_from, 0) + 1;
       v_frozenFrom := x_group_rec.setup_terms_rec.seq_frozen_day_from;
       --
    END IF;
    --
    IF (l_debug  > -1) THEN
    rlm_core_sv.dlog(k_DEBUG, 'g_isFirm', g_isFirm);
     rlm_core_sv.dlog(k_DEBUG, 'v_frozenDays', v_frozenDays);
     rlm_core_sv.dlog(k_DEBUG, 'x_Sched_rec.Schedule_Source', x_Sched_rec.Schedule_Source);
    END IF;
    --
    IF NOT g_isFirm AND x_Sched_rec.Schedule_Source <> 'MANUAL' AND v_frozenFrom is NOT NULL THEN
       --{
       g_isFirm := TRUE;
       --
       IF g_Reconcile_tab.COUNT <> 0 THEN
          --{
          v_Count := g_Reconcile_tab.FIRST;
          --
          WHILE v_Count is NOT NULL LOOP
             --{
             x_frozenWarnQty :=  g_Reconcile_tab(v_Count).ordered_quantity;
             --
             i := v_FrozenTab.count;
             --
             IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG, 'Begining of the loop Index i', i);
              rlm_core_sv.dlog(k_DEBUG, 'v_Count', v_Count);
              rlm_core_sv.dlog(k_DEBUG, 'x_FrozenWarnQty', x_FrozenWarnQty);
              rlm_core_sv.dlog(k_DEBUG, 'request_date', g_Reconcile_tab(v_Count).request_date);
              rlm_core_sv.dlog(k_DEBUG, 'Customer request Date', g_Reconcile_tab(v_Count).industry_attribute2);
             END IF;
             --
             IF MatchFrozen(x_Group_rec, g_Reconcile_tab.NEXT(v_Count), g_Reconcile_tab(v_Count), v_Index) THEN
                --
                x_frozenWarnQty := x_frozenWarnQty + g_Reconcile_tab(v_Index).ordered_quantity;
                --
                IF (l_debug <> -1) THEN
                --
                rlm_core_sv.dlog(k_DEBUG, 'v_Index', v_Index);
                rlm_core_sv.dlog(k_DEBUG, 'ordered_quantity', g_Reconcile_tab(v_Index).ordered_quantity);
                rlm_core_sv.dlog(k_DEBUG, 'x_FrozenWarnQty', x_FrozenWarnQty);
                --
                END IF;
                --
             END IF;
             --
             i := i + 1;
             v_FrozenTab(i) := g_Reconcile_tab(v_Count);
             v_FrozenTab(i).ordered_quantity := x_frozenWarnQty;
             --
             IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(k_DEBUG, 'Ending of the loop Index i', i);
             END IF;
             --
             v_Count := g_Reconcile_tab.next(v_Count);
             --
          END LOOP;
          --}
       END IF;
       --}
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'v_FrozenTab.COUNT', v_FrozenTab.COUNT);
       END IF;
       --
       IF v_FrozenTab.COUNT <> 0 THEN
          --{
          FOR v_Count IN v_frozenTab.FIRST..v_frozenTab.LAST LOOP
             --{
             GetMatchAttributes(x_sched_rec,x_group_rec, v_frozenTab(v_count), v_MatchAttrTxt);
             --
             IF v_MatchAttrTxt is NULL THEN
                --
                IF v_frozenTab(v_Count).ordered_quantity  < 0  THEN
                   --
                   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_OVERALL_WARN_UNDER:',
                              v_frozenTab(v_Count).ordered_quantity);
                      rlm_core_sv.dlog(k_DEBUG,'Ship from', x_group_rec.ship_from_org_id);
                      rlm_core_sv.dlog(k_DEBUG,'Ship to', x_group_rec.ship_to_address_id );
                      rlm_core_sv.dlog(k_DEBUG,'Customer Item Id', x_group_rec.customer_item_id);
                      rlm_core_sv.dlog(k_DEBUG,'Matching Attributes', v_MatchAttrTxt);
                   END IF;
                   --
                   rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_OVERALL_WARN_UNDER',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => NULL,
                       x_Token1 => 'ENDDATE',
                       x_Value1 => TRUNC(SYSDATE) + v_frozenDays - 1,
                       x_Token2 => 'SHIP_FROM',
                       x_Value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id),
                       x_Token3 => 'SHIP_TO',
                       x_Value3 => rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id),
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'QUANTITY',
                       x_value5 => abs(v_frozenTab(v_Count).ordered_quantity));
                   --
                ELSE
                   --
                   IF (l_debug <> -1) THEN
                      --
                      rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_OVERALL_WARN_OVER:',
                              v_frozenTab(v_Count).ordered_quantity);
                      rlm_core_sv.dlog(k_DEBUG,'Ship from', x_group_rec.ship_from_org_id);
                      rlm_core_sv.dlog(k_DEBUG,'Ship to', x_group_rec.ship_to_address_id );
                      rlm_core_sv.dlog(k_DEBUG,'Customer Item Id', x_group_rec.customer_item_id);
                      rlm_core_sv.dlog(k_DEBUG,'Matching Attributes', v_MatchAttrTxt);
                      --
                   END IF;
                   --
                   rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_OVERALL_WARN_OVER',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => NULL,
                       x_Token1 => 'ENDDATE',
                       x_Value1 => TRUNC(SYSDATE) + v_frozenDays - 1,
                       x_Token2 => 'SHIP_FROM',
                       x_Value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id),
                       x_Token3 => 'SHIP_TO',
                       x_Value3 => rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id),
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'QUANTITY',
                       x_value5 => abs(v_frozenTab(v_Count).ordered_quantity));
                   --
                END IF;
                --
             ELSE
                --
                IF v_frozenTab(v_Count).ordered_quantity  < 0  THEN
                   --
                   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_OVERALL_QTY_UNDER:',
                              v_frozenTab(v_Count).ordered_quantity);
                      rlm_core_sv.dlog(k_DEBUG,'Ship from', x_group_rec.ship_from_org_id);
                      rlm_core_sv.dlog(k_DEBUG,'Ship to', x_group_rec.ship_to_address_id );
                      rlm_core_sv.dlog(k_DEBUG,'Customer Item Id', x_group_rec.customer_item_id);
                      rlm_core_sv.dlog(k_DEBUG,'Matching Attributes', v_MatchAttrTxt);
                   END IF;
                   --
                   rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_OVERALL_QTY_UNDER',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => NULL,
                       x_Token1 => 'ENDDATE',
                       x_Value1 => TRUNC(SYSDATE) + v_frozenDays - 1,
                       x_Token2 => 'SHIP_FROM',
                       x_Value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id),
                       x_Token3 => 'SHIP_TO',
                       x_Value3 => rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id),
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'QUANTITY',
                       x_value5 => abs(v_frozenTab(v_Count).ordered_quantity),
                       x_Token6 => 'MATCH_ATTR',
                       x_value6 => v_MatchAttrTxt);
                   --
                ELSE
                   --
                   IF (l_debug <> -1) THEN
                      --
                      rlm_core_sv.dlog(k_DEBUG,'RLM_FROZEN_OVERALL_QTY_OVER:',
                              v_frozenTab(v_Count).ordered_quantity);
                      rlm_core_sv.dlog(k_DEBUG,'Ship from', x_group_rec.ship_from_org_id);
                      rlm_core_sv.dlog(k_DEBUG,'Ship to', x_group_rec.ship_to_address_id );
                      rlm_core_sv.dlog(k_DEBUG,'Customer Item Id', x_group_rec.customer_item_id);
                      rlm_core_sv.dlog(k_DEBUG,'Matching Attributes', v_MatchAttrTxt);
                      --
                   END IF;
                  --
                   rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_warn_level,
                       x_MessageName => 'RLM_FROZEN_OVERALL_QTY_OVER',
                       x_InterfaceHeaderId => x_sched_rec.header_id,
                       x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
                       x_OrderHeaderId => x_group_rec.setup_terms_rec.header_id,
                       x_OrderLineId => NULL,
                       x_Token1 => 'ENDDATE',
                       x_Value1 => TRUNC(SYSDATE) + v_frozenDays - 1,
                       x_Token2 => 'SHIP_FROM',
                       x_Value2 => rlm_core_sv.get_ship_from(x_group_rec.ship_from_org_id),
                       x_Token3 => 'SHIP_TO',
                       x_Value3 => rlm_core_sv.get_ship_to(x_group_rec.ship_to_address_id),
                       x_Token4 => 'CUSTITEM',
                       x_value4 => rlm_core_sv.get_item_number(x_group_rec.customer_item_id),
                       x_Token5 => 'QUANTITY',
                       x_value5 => abs(v_frozenTab(v_Count).ordered_quantity),
                       x_Token6 => 'MATCH_ATTR',
                       x_value6 => v_MatchAttrTxt);
                   --
                END IF;
                --
             END IF ;
             --
          END LOOP;
          --}
       END IF;
       --}
    END IF;
    --}
    IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --}
 EXCEPTION
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('RLM_RD_SV.FrozenFenceWarning', '010');
      --
       IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'Unexpected error', SUBSTRB(SQLERRM, 1, 200));
         rlm_core_sv.dpop(k_SDEBUG);
       END IF;
       --
       --
       RAISE;
       --
 END FrozenFenceWarning;

/*==============================================================================
 PROCEDURE NAME: GetMatchAttributes
Added this new procedure to get the matching attributes code value pair to display
in the overall frozen fence message for bug 4223359.
==============================================================================*/

PROCEDURE GetMatchAttributes(x_sched_rec IN rlm_interface_headers%ROWTYPE,
                             x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                             x_frozenTabRec IN t_generic_rec,
                             x_MatAttrCodeValue OUT NOCOPY VARCHAR2)
IS
  --
  i                        NUMBER DEFAULT 0;
  v_lookupCode             VARCHAR2(30);
  v_lookupMeaning          VARCHAR2(80);
  v_ColumnName             VARCHAR2(30);
  v_MatchCode              VARCHAR2(2);
  v_MatchWithinRec         rlm_core_sv.t_match_rec;
--  v_MatchKey               rlm_cust_shipto_terms.match_within_key%TYPE;
  v_first                  BOOLEAN := TRUE;
  --
  Cursor   C(p_MatchCode   in VARCHAR2,
             p_enabledFlag in VARCHAR2,
             p_lookupType  in VARCHAR2)
  IS
  SELECT   LOOKUP_CODE, MEANING
  FROM     FND_LOOKUPS
  WHERE    LOOKUP_TYPE = p_lookupType
  AND      ENABLED_FLAG = p_enabledFlag
  AND     SUBSTR(LOOKUP_CODE,INSTR(LOOKUP_CODE, ',') +1) = p_MatchCode;
  --
  Cursor c_flex_ind_attr(p_ColumnName  IN VARCHAR2,
                         p_descFlex    IN VARCHAR2,
                         p_enabledFlag IN VARCHAR2,
                         p_appId       IN NUMBER)
  IS
  SELECT FORM_ABOVE_PROMPT
  FROM   FND_DESCR_FLEX_COL_USAGE_VL
  WHERE  APPLICATION_ID = p_appId
  AND    DESCRIPTIVE_FLEXFIELD_NAME = p_descFlex
  AND    ENABLED_FLAG = p_enabledFlag
  AND    APPLICATION_COLUMN_NAME = p_ColumnName;
  --
  Cursor c_flex_line_attr(p_ColumnName IN VARCHAR2,
                          p_descFlex    IN VARCHAR2,
                          p_enabledFlag IN VARCHAR2,
                          p_appId       IN NUMBER)
  IS
  SELECT FORM_LEFT_PROMPT
  FROM   FND_DESCR_FLEX_COL_USAGE_VL
  WHERE  APPLICATION_ID = p_appId
  AND    DESCRIPTIVE_FLEXFIELD_NAME = p_descFlex
  AND    ENABLED_FLAG = p_enabledFlag
  AND    APPLICATION_COLUMN_NAME = p_ColumnName;
  --
 BEGIN
   --
   IF (l_debug  > -1) THEN
     rlm_core_sv.dpush(k_SDEBUG, 'GetMatchAttributes ');
     rlm_core_sv.dlog(k_DEBUG, 'match_within ', x_group_rec.match_within);
   END IF;
   --
   v_MatchCode := SUBSTR(x_Group_rec.match_within,1,1);
   i := 1;
   --
   WHILE v_MatchCode is NOT NULL LOOP
     --{
     IF (l_debug  > -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'v_MatchCode ', v_MatchCode);
     END IF;
     --
     IF v_MatchCode <> 'C' AND v_MatchCode <> 'J' THEN
     --{
       OPEN  c(v_matchCode, 'Y', 'RLM_OPTIONAL_MATCH_ATTRIBUTES');
          --{
          FETCH c INTO v_lookupCode, v_lookupMeaning;
          --
          v_ColumnName := SUBSTR(v_lookupCode, 1, INSTR(v_lookupCode, ',')-1);
          --
          IF (INSTR(v_ColumnName, 'INDUSTRY_ATTRIBUTE') = 1) THEN
              --
              OPEN c_flex_ind_attr(v_ColumnName, 'RLM_SCHEDULE_LINES', 'Y', 662);
              FETCH c_flex_ind_attr INTO v_lookupMeaning;
              CLOSE c_flex_ind_attr;
              --
          ELSIF(INSTR(v_ColumnName, 'ATTRIBUTE') = 1) THEN
              --
              OPEN c_flex_line_attr(v_ColumnName, 'OE_LINE_ATTRIBUTES', 'Y', 660);
              FETCH c_flex_line_attr INTO v_lookupMeaning;
              CLOSE c_flex_line_attr;
              --
          END IF;
          --
          IF v_first THEN
              --
            x_MatAttrCodeValue :=  v_lookupMeaning || '= ';
              --
          ELSE
              --
              x_MatAttrCodeValue :=  x_MatAttrCodeValue || ', ' || v_lookupMeaning || '= ';
              --
          END IF;
          --
          rlm_core_sv.populate_match_keys(v_MatchWithinRec, v_MatchCode);
          --
          IF  v_MatchWithinRec.cust_po_number = 'Y' THEN
              --
              x_MatAttrCodeValue :=  x_MatAttrCodeValue ||  x_FrozenTabRec.cust_po_number;
              --
          ELSIF v_MatchWithinRec.customer_item_revision = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue || x_FrozenTabRec.customer_item_revision;

              --
          ELSIF v_MatchWithinRec.customer_dock_code = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.customer_dock_code;
              --
          ELSIF v_MatchWithinRec.customer_job = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.customer_job;
              --
          ELSIF v_MatchWithinRec.cust_production_line = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.cust_production_line;
              --
          ELSIF v_MatchWithinRec.cust_model_serial_number = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.cust_model_serial_number;

              --
          ELSIF v_MatchWithinRec.cust_production_seq_num = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.cust_production_seq_num;

              --
          ELSIF v_MatchwithinRec.industry_attribute1 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute1;
              --
          ELSIF v_MatchwithinRec.industry_attribute4 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute4;
              --
          ELSIF v_MatchwithinRec.industry_attribute5 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute5;
              --
              IF (l_debug  > -1) THEN
                  rlm_core_sv.dlog(k_DEBUG, 'x_FrozenTabRec.industry_attribute5 ', x_FrozenTabRec.industry_attribute5);
              END IF;
              --
          ELSIF v_MatchwithinRec.industry_attribute6 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute6;
              --
          ELSIF v_MatchwithinRec.industry_attribute10 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute10;
              --
          ELSIF v_MatchwithinRec.industry_attribute11 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute11;
              --
          ELSIF v_MatchwithinRec.industry_attribute12 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute12;
              --
          ELSIF v_MatchwithinRec.industry_attribute13 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute13;
              --
          ELSIF v_MatchwithinRec.industry_attribute14 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute14;
              --
   --       ELSIF v_MatchwithinRec.industry_attribute15 = 'Y' THEN
              --
  --           x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.industry_attribute15;

              --
          ELSIF v_MatchwithinRec.attribute1 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute1;
              --
          ELSIF v_MatchwithinRec.attribute2 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute2;
              --
          ELSIF v_MatchwithinRec.attribute3 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute3;
              --
          ELSIF v_MatchwithinRec.attribute4 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute4;
              --
          ELSIF v_MatchwithinRec.attribute5 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute5;
              --
          ELSIF v_MatchwithinRec.attribute6 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute6;
              --
          ELSIF v_MatchwithinRec.attribute7 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute7;
              --
          ELSIF v_MatchwithinRec.attribute8 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute8;
              --
          ELSIF v_MatchwithinRec.attribute9 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute9;
              --
          ELSIF v_MatchwithinRec.attribute10 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute10;
              --
          ELSIF v_MatchwithinRec.attribute11 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute11;
              --
          ELSIF v_MatchwithinRec.attribute12 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute12;
              --
          ELSIF v_MatchwithinRec.attribute13 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute13;
              --
          ELSIF v_MatchwithinRec.attribute14 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute14;
              --
          ELSIF v_MatchwithinRec.attribute15 = 'Y' THEN
              --
              x_MatAttrCodeValue := x_MatAttrCodeValue ||  x_FrozenTabRec.attribute15;
              --
          END IF;
          --
          IF (l_debug  > -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'x_MatAttrCodeValue ', x_MatAttrCodeValue);
          END IF;
          --}
        CLOSE C;
        --
        v_first := FALSE;
        --}
      END IF;
      --
      i := i + 1;
      v_MatchCode := SUBSTR(x_Group_rec.match_within,i,1);
      --}
   END LOOP;
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
 EXCEPTION
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('RLM_RD_SV.GetMatchAttributes', '010');
      --
       IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'Unexpected error', SUBSTRB(SQLERRM, 1, 200));
         rlm_core_sv.dpop(k_SDEBUG);
       END IF;
       --
       RAISE;
       --
 END GetMatchAttributes;
 --}


/*======================================================================

PROCEDURE NAME:    ProcessReleases

DESCRIPTION:       The following logic is used within this procedure
                   (a) For a given SF/ST/CI, obtain the number of
                       distinct releases tied to the demand lines.
                   (b) For each such distinct release, call
                       RecGroupDemand()
                   (c) If any release was processed by DSP, set the output
                       variable x_Processed to Y, so we do not call
                       RecGroupDemand() again in procedure RecDemand().

=======================================================================*/
PROCEDURE ProcessReleases(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                          x_Processed IN OUT NOCOPY VARCHAR2) IS
  --
  v_BlkGroup_ref   t_Cursor_ref;
  v_BlkGroup_rec   rlm_dp_sv.t_Group_rec;
  e_lines_locked   EXCEPTION;
  v_sf_org_id      NUMBER;
  v_rso_start_date DATE;
  --
  CURSOR c_getMaxRSO IS
  SELECT rso_hdr_id, effective_start_date
  FROM RLM_BLANKET_RSO
  WHERE blanket_number = v_BlkGroup_rec.setup_terms_rec.blanket_number
  AND customer_item_id =
        DECODE(v_BlkGroup_rec.setup_terms_rec.release_rule, 'PI',
               v_BlkGroup_rec.customer_item_id, k_NNULL)
  AND effective_start_date  =
   (SELECT max(rlm.effective_start_date)
    FROM RLM_BLANKET_RSO rlm, OE_ORDER_HEADERS oe
    WHERE rlm.blanket_number = v_BlkGroup_rec.setup_terms_rec.blanket_number
    AND rlm.rso_hdr_id = oe.header_id
    AND rlm.customer_item_id =
        DECODE(v_BlkGroup_rec.setup_terms_rec.release_rule, 'PI',
               v_BlkGroup_rec.customer_item_id, K_NNULL)
    AND oe.open_flag = 'Y')
  ORDER BY rso_hdr_id DESC;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(k_SDEBUG, 'ProcessReleases');
  END IF;
  x_Processed := 'N';
  --
  RLM_TPA_SV.InitializeBlktGrp(x_Sched_rec, v_BlkGroup_ref, x_Group_rec);
  --
  WHILE FetchBlktGrp(v_BlkGroup_ref, v_BlkGroup_rec) LOOP
   --{
   v_BlkGroup_rec.isSourced := x_Group_rec.isSourced;
   CallSetups(x_Sched_rec, v_BlkGroup_rec);
   --
   IF NOT LockLines(v_BlkGroup_rec, x_Sched_rec.header_id) THEN
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'RLM_LOCK_NOT_OBTAINED');
    END IF;
    --
    RAISE e_lines_locked;
    --
   END IF;
   --
   OPEN c_getMaxRSO;
   FETCH c_getMaxRSO INTO g_max_rso_hdr_id, v_rso_start_date;
   CLOSE c_getMaxRSO;
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'g_max_rso_hdr_id',g_max_rso_hdr_id);
     rlm_core_sv.dlog(k_DEBUG, 'v_rso_start_date',v_rso_start_date);
   END IF;
   --
   RecGroupDemand(x_Sched_rec, v_BlkGroup_rec);
   x_Processed := 'Y';
   --}
  END LOOP;
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  EXCEPTION
   --
   WHEN e_lines_locked THEN
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'e_lines_locked exception');
     rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    RAISE;
    --
   WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'SQLERRM', SUBSTRB(SQLERRM,1,200));
     rlm_core_sv.dpop(k_SDEBUG);
    END IF;
    --
    RAISE;
    --
END ProcessReleases;

/*=========================================================================

        PROCEDURE NAME: AssignMatchAttribValues

===========================================================================*/
-- Bug 4297984
PROCEDURE  AssignMatchAttribValues ( x_req_rec     IN            rlm_interface_lines_all%ROWTYPE,
                                   x_match_rec     IN OUT NOCOPY RLM_RD_SV.t_generic_rec)
IS

BEGIN
    --
    -- The x_match_rec populated here will be passed to RLM_RD_SV.GetMatchAttributes
    -- where we retrieve only the additional matching attribute columns. Hence only the
    -- additional matching attribute columns are populated here and the remaining fields
    -- defined in RLM_RD_SV.t_Generic_rec will be NULL. The function is needed
    -- as the RLM_RD_SV.GetMatchAttributes requires a RLM_RD_SV.t_Generic_rec argument type.
    --
    x_match_rec.cust_po_number            :=   x_req_rec.cust_po_number           ;
    x_match_rec.customer_item_revision    :=   x_req_rec.customer_item_revision   ;
    x_match_rec.customer_dock_code        :=   x_req_rec.customer_dock_code       ;
    x_match_rec.customer_job              :=   x_req_rec.customer_job             ;
    x_match_rec.cust_production_line      :=   x_req_rec.cust_production_line     ;
    x_match_rec.cust_model_serial_number  :=   x_req_rec.cust_model_serial_number ;
    x_match_rec.cust_production_seq_num   :=   x_req_rec.cust_production_seq_num  ;
    x_match_rec.industry_attribute1       :=   x_req_rec.industry_attribute1      ;
    x_match_rec.industry_attribute2       :=   x_req_rec.industry_attribute2      ;
    x_match_rec.industry_attribute3       :=   x_req_rec.industry_attribute3      ;
    x_match_rec.industry_attribute4       :=   x_req_rec.industry_attribute4      ;
    x_match_rec.industry_attribute5       :=   x_req_rec.industry_attribute5      ;
    x_match_rec.industry_attribute6       :=   x_req_rec.industry_attribute6      ;
    x_match_rec.industry_attribute7       :=   x_req_rec.industry_attribute7      ;
    x_match_rec.industry_attribute8       :=   x_req_rec.industry_attribute8      ;
    x_match_rec.industry_attribute9       :=   x_req_rec.industry_attribute9      ;
    x_match_rec.industry_attribute10      :=   x_req_rec.industry_attribute10     ;
    x_match_rec.industry_attribute11      :=   x_req_rec.industry_attribute11     ;
    x_match_rec.industry_attribute12      :=   x_req_rec.industry_attribute12     ;
    x_match_rec.industry_attribute13      :=   x_req_rec.industry_attribute13     ;
    x_match_rec.industry_attribute14      :=   x_req_rec.industry_attribute14     ;
    x_match_rec.industry_attribute15      :=   x_req_rec.industry_attribute15     ;
    x_match_rec.attribute1                :=   x_req_rec.attribute1               ;
    x_match_rec.attribute2                :=   x_req_rec.attribute2               ;
    x_match_rec.attribute3                :=   x_req_rec.attribute3               ;
    x_match_rec.attribute4                :=   x_req_rec.attribute4               ;
    x_match_rec.attribute5                :=   x_req_rec.attribute5               ;
    x_match_rec.attribute6                :=   x_req_rec.attribute6               ;
    x_match_rec.attribute7                :=   x_req_rec.attribute7               ;
    x_match_rec.attribute8                :=   x_req_rec.attribute8               ;
    x_match_rec.attribute9                :=   x_req_rec.attribute9               ;
    x_match_rec.attribute10               :=   x_req_rec.attribute10              ;
    x_match_rec.attribute11               :=   x_req_rec.attribute11              ;
    x_match_rec.attribute12               :=   x_req_rec.attribute12              ;
    x_match_rec.attribute13               :=   x_req_rec.attribute13              ;
    x_match_rec.attribute14               :=   x_req_rec.attribute14              ;
    x_match_rec.attribute15               :=   x_req_rec.attribute15              ;

END AssignMatchAttribValues;

/*===========================================================================

PROCEDURE NAME:    PopulateReconcileCumRec

===========================================================================*/
--Bugfix 7007638 Start
PROCEDURE PopulateReconcileCumRec(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                                  x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec)
IS

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
            line_id
  FROM      rlm_interface_lines
  WHERE     header_id = x_Sched_rec.header_id
  AND       item_detail_type = RLM_MANAGE_DEMAND_SV.k_SHIP_RECEIPT_INFO
  AND       item_detail_subtype = RLM_MANAGE_DEMAND_SV.k_CUM
  AND       ship_from_org_id   = x_Group_rec.ship_from_org_id
  AND       ship_to_address_id = x_Group_rec.ship_to_address_id
  AND       inventory_item_id = x_Group_rec.inventory_item_id
  AND       customer_item_id  = x_Group_rec.customer_item_id
  ORDER BY  start_date_time desc;
 --

  v_Progress          VARCHAR2(3)  := '010';
  v_Count		      NUMBER       := 1;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'PopulateReconcileCumRec');
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.Schedule_header_id',
                                  x_Sched_rec.Schedule_header_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_address_id',
                                  x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id',
                                  x_Group_rec.inventory_item_id);
  END IF;
  --
  g_RecCUM_tab.DELETE;
  --
  OPEN c_CUMRec;
  --
   LOOP
    FETCH c_CUMRec INTO g_RecCUM_rec;
    EXIT WHEN c_CUMRec%NOTFOUND;

     g_RecCUM_tab(v_Count).customer_id               :=   g_RecCUM_rec.customer_id;
     g_RecCUM_tab(v_Count).customer_item_id          :=   g_RecCUM_rec.customer_item_id;
     g_RecCUM_tab(v_Count).inventory_item_id         :=   g_RecCUM_rec.inventory_item_id;
     g_RecCUM_tab(v_Count).ship_from_org_id          :=   g_RecCUM_rec.ship_from_org_id;
     g_RecCUM_tab(v_Count).intrmd_ship_to_address_id :=   g_RecCUM_rec.intrmd_ship_to_address_id;
     g_RecCUM_tab(v_Count).ship_to_address_id        :=   g_RecCUM_rec.ship_to_address_id;
     g_RecCUM_tab(v_Count).bill_to_address_id        :=   g_RecCUM_rec.bill_to_address_id;
     g_RecCUM_tab(v_Count).purchase_order_number     :=   g_RecCUM_rec.purchase_order_number;
     g_RecCUM_tab(v_Count).primary_quantity          :=   g_RecCUM_rec.primary_quantity;
     g_RecCUM_tab(v_Count).item_detail_quantity      :=   g_RecCUM_rec.item_detail_quantity;
     g_RecCUM_tab(v_Count).start_date_time           :=   g_RecCUM_rec.start_date_time;
     g_RecCUM_tab(v_Count).cust_record_year          :=   g_RecCUM_rec.cust_record_year;
     g_RecCUM_tab(v_Count).line_id                   :=   g_RecCUM_rec.line_id;

    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'g_RecCUM_tab('||v_Count||').purchase_order_number', g_RecCUM_tab(v_Count).purchase_order_number);
      rlm_core_sv.dlog(k_DEBUG,'g_RecCUM_tab('||v_Count||').primary_quantity', g_RecCUM_tab(v_Count).primary_quantity);
      rlm_core_sv.dlog(k_DEBUG,'g_RecCUM_tab('||v_Count||').item_detail_quantity', g_RecCUM_tab(v_Count).item_detail_quantity);
      rlm_core_sv.dlog(k_DEBUG,'g_RecCUM_tab('||v_Count||').start_date_time', g_RecCUM_tab(v_Count).start_date_time);
      rlm_core_sv.dlog(k_DEBUG,'g_RecCUM_tab('||v_Count||').cust_record_year', g_RecCUM_tab(v_Count).cust_record_year);
      rlm_core_sv.dlog(k_DEBUG,'g_RecCUM_tab('||v_Count||').line_id', g_RecCUM_tab(v_Count).line_id);
    END IF;

    v_Count := v_Count + 1;

   END LOOP;
  --
  CLOSE c_CUMRec;

  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'g_RecCUM_tab.COUNT',g_RecCUM_tab.COUNT);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION

  WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_rd_sv.PopulateReconcileCumRec',
                              v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;

END PopulateReconcileCumRec;

/*===========================================================================

  FUNCTION Match_PO_RY_Reconcile

===========================================================================*/
FUNCTION Match_PO_RY_Reconcile(x_Group_rec IN OUT NOCOPY RLM_DP_SV.t_Group_rec,
                               x_Current_rec IN t_Generic_rec,
                               x_Index OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  x_progress              VARCHAR2(3) := '010';
  v_Count                 NUMBER;
  v_Index                 NUMBER;
  b_Match                 BOOLEAN := FALSE;
  v_intransit_calc_basis  VARCHAR2(30) ;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'Match_PO_RY_Reconcile');
     rlm_core_sv.dlog(k_DEBUG, 'x_Current_rec.schedule_type',
                                x_Current_rec.schedule_type);
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.COUNT', g_Reconcile_tab.COUNT);
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.FIRST', g_Reconcile_tab.FIRST);
     rlm_core_sv.dlog(k_DEBUG,'g_Reconcile_tab.LAST', g_Reconcile_tab.LAST);
  END IF;

  IF g_Reconcile_tab.COUNT <> 0 THEN
   --{
    v_Count := g_Reconcile_tab.FIRST;
    --
    WHILE v_Count IS NOT NULL LOOP
      --{
      b_Match := TRUE;
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG, 'g_Reconcile_Tab('||v_Count||').schedule_type',
                                  g_Reconcile_Tab(v_Count).schedule_type);
      END IF;

       v_intransit_calc_basis := UPPER(x_Group_rec.setup_terms_rec.intransit_calc_basis);
       --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG, 'Intransit calc basis ',x_Group_rec.setup_terms_rec.intransit_calc_basis);
      END IF;
       --
        IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_PO','CUM_BY_PO_ONLY') THEN
         IF NVL(x_Current_rec.cust_po_number, k_VNULL) <>
            NVL(g_Reconcile_tab(v_Count).cust_po_number, k_VNULL) THEN
           b_Match := FALSE;
         END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'cust_po_number', x_Current_rec.cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'rec cust_po_number', g_Reconcile_tab(v_Count).cust_po_number);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
        --
        IF b_Match THEN
          IF x_Group_rec.setup_terms_rec.cum_control_code IN ('CUM_BY_DATE_RECORD_YEAR') THEN
            IF NVL(x_Current_rec.industry_attribute1, k_VNULL) <>
               NVL(g_Reconcile_tab(v_Count).industry_attribute1, k_VNULL) THEN
              b_Match := FALSE;
            END IF;
          END IF;
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'industry_attribute1', x_Current_rec.industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'rec industry_attribute1', g_Reconcile_tab(v_Count).industry_attribute1);
           rlm_core_sv.dlog(k_DEBUG, 'b_Match', b_Match);
        END IF;
       --
     IF b_Match THEN
        --
        x_Index := v_Count;
        EXIT;
        --
     END IF;
     --
     v_Count := g_Reconcile_tab.NEXT(v_Count);
     --}
    END LOOP;
    --}
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'b_match', b_Match);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
  RETURN(b_Match);
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_rd_sv.Match_PO_RY_Reconcile',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END Match_PO_RY_Reconcile;
--Bugfix 7007638 End

END RLM_RD_SV;

/
