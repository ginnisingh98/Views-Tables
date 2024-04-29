--------------------------------------------------------
--  DDL for Package Body RLM_REPLACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_REPLACE_SV" as
/*$Header: RLMDPSWB.pls 120.1.12010000.2 2009/12/01 14:42:49 sunilku ship $*/
--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
/*===========================================================================

  PROCEDURE NAME:    CompareReplaceSched

===========================================================================*/
PROCEDURE CompareReplaceSched (
          x_sched_rec           IN  rlm_interface_headers%ROWTYPE,
          x_warn_dropped_items  IN  VARCHAR2,
          x_return_status       OUT NOCOPY BOOLEAN)
IS
 --
 v_prev_header_id NUMBER;
 v_curr_header_id NUMBER;
 v_curr_sch_header_id NUMBER; --Bugfix 8844817
 v_return_status  BOOLEAN;
 --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CompareReplaceSched');
  END IF;
  --
  v_curr_header_id := x_sched_rec.header_id;
  v_curr_sch_header_id := x_sched_rec.schedule_header_id; --Bugfix 8844817
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'v_curr_header_id', v_curr_header_id);
     rlm_core_sv.dlog(C_DEBUG, 'v_curr_sch_header_id', v_curr_sch_header_id); --Bugfix 8844817
  END IF;
  --
  IF IsWarningNeeded(x_sched_rec, x_warn_dropped_items) THEN
    --
    FindEligibleSched(x_sched_rec,
                      v_prev_header_id,
                      v_return_status);
    --
    IF v_return_status <> FALSE THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'v_prev_header_id',v_prev_header_id);
      END IF;
      --
      -- Populate the global list
      --
      -- 4198327
      PopulateList(v_prev_header_id,
                   v_curr_header_id,
                   v_curr_sch_header_id, --Bugfix 8844817
                   v_return_status);
      --
      x_return_status := TRUE;
      --
    ELSE
      --
      -- Even though no previous schedule is found,
      -- the return status to wrapper program should be TRUE
      --
      x_return_status := TRUE;
      --
    END IF;
    --
  ELSE
    --
    -- Warning is not needed. The return status should still be TRUE
    --
    x_return_status := TRUE;
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
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: OTHER - ' ||  SUBSTR(SQLERRM,1,200));
    END IF;
    --
END CompareReplaceSched;


/*===========================================================================
  FUNCTION NAME:    IsWarningNeeded

===========================================================================*/
FUNCTION IsWarningNeeded (
          x_sched_rec           IN  rlm_interface_headers%ROWTYPE,
          x_warn_dropped_items  IN  VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'IsWarningNeeded');
     rlm_core_sv.dlog(C_DEBUG, 'x_warn_dropped_items', x_warn_dropped_items);
     rlm_core_sv.dlog(C_DEBUG, 'schedule source', x_sched_rec.schedule_source);
     rlm_core_sv.dlog(C_DEBUG, 'schedule purpose', x_sched_rec.schedule_purpose);
  END IF;
  --
  IF x_warn_dropped_items <> 'Y'
     AND x_warn_dropped_items <> 'y' THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RETURN FALSE;
    --
  END IF;
  --
  IF x_sched_rec.schedule_purpose not in ('REPLACE', 'REPLACE_ALL') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RETURN FALSE;
    --
  END IF;
  --
  IF x_sched_rec.schedule_source = 'MANUAL' THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RETURN FALSE;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN TRUE;
  --
END IsWarningNeeded;

/*===========================================================================

  PROCEDURE NAME:    FindEligibleSched

===========================================================================*/
PROCEDURE FindEligibleSched (
          x_sched_rec           IN  rlm_interface_headers%ROWTYPE,
          x_prev_header_id      OUT NOCOPY NUMBER,
	  x_return_status	OUT NOCOPY BOOLEAN)
IS
  --
  CURSOR   c_eligible_schedule IS
  SELECT   header_id
  FROM     rlm_schedule_headers
  WHERE    schedule_type               = x_sched_rec.schedule_type
  AND      schedule_purpose            in (RLM_DP_SV.k_REPLACE, RLM_DP_SV.k_REPLACE_ALL)
  AND      schedule_source             <> RLM_DP_SV.k_MANUAL
  -- AND   customer_id = x_sched_rec.customer_id
  AND      ece_tp_translator_code      = x_sched_rec.ece_tp_translator_code
  AND      ece_tp_location_code_ext    = x_sched_rec.ece_tp_location_code_ext
  AND      NVL(edi_test_indicator,'P') = NVL(x_sched_rec.edi_test_indicator,'P')
  AND	   process_status	       IN (5,7)
  AND      sched_generation_date       < x_sched_rec.sched_generation_date
-- bug 4198327
  ORDER BY sched_generation_date DESC, program_update_date desc;
  --
  e_no_eligible_schedule EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'FindEligibleSched');
     rlm_core_sv.dlog(C_DEBUG,'Curr ece_tp_translator_code', x_sched_rec.ece_tp_translator_code);
     rlm_core_sv.dlog(C_DEBUG,'Curr ece_tp_location_code_ext', x_sched_rec.ece_tp_location_code_ext);
     rlm_core_sv.dlog(C_DEBUG,'Curr edi_test_indicator', x_sched_rec.edi_test_indicator);
     rlm_core_sv.dlog(C_DEBUG,'Curr sched_generation_date', x_sched_rec.sched_generation_date);
  END IF;
  --
  OPEN c_eligible_schedule;
    -- Get the second highest generation date schedule only
    FETCH c_eligible_schedule INTO x_prev_header_id;
    --
    IF c_eligible_schedule%NOTFOUND THEN
      --
      RAISE e_no_eligible_schedule;
      --
    END IF;
    --
  CLOSE c_eligible_schedule;
  --
  x_return_status := TRUE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'x_return_status', x_return_status);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_no_eligible_schedule THEN
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'e_no_eligible_schedule');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: OTHER - ' ||  SUBSTR(SQLERRM,1,200));
    END IF;
    --
END FindEligibleSched;


/*===========================================================================

  PROCEDURE NAME:    PopulateList

===========================================================================*/
PROCEDURE PopulateList (
          x_prev_header_id      IN  NUMBER,
          x_curr_header_id      IN NUMBER,
          x_curr_sch_header_id  IN NUMBER, --Bugfix 8844817
	  x_return_status	OUT NOCOPY BOOLEAN)
IS
  --
  -- bug 4198327 changes include getting all the items which are not in the current schedule
  -- but on the previous schedule. Get the list, then check if there are open order lines
  -- for that item.
  --
  CURSOR   c_drop_list IS
  SELECT   rsl.ship_from_org_id,
           rsl.ship_to_address_id,
           rsl.ship_to_org_id,
           rsl.customer_item_id
  FROM     rlm_schedule_lines_all rsl
  WHERE    rsl.header_id  = x_prev_header_id
  AND      rsl.item_detail_type  IN (0,1,2)
  AND      NOT EXISTS ( SELECT 'X'
                   FROM rlm_interface_lines ril
                   WHERE ril.header_id  = x_curr_header_id
                   AND ril.ship_from_org_id = rsl.ship_from_org_id
                   AND ril.ship_to_address_id = rsl.ship_to_address_id
                   AND ril.ship_to_org_id = rsl.ship_to_org_id
                   AND ril.customer_item_id = rsl.customer_item_id
                   AND ril.item_detail_type IN (0,1,2))
  AND      NOT EXISTS ( SELECT 'X'                 --Bugfix 8844817
                   FROM rlm_schedule_lines rsl2
                   WHERE rsl2.header_id  = x_curr_sch_header_id
                   AND rsl2.ship_from_org_id = rsl.ship_from_org_id
                   AND rsl2.ship_to_address_id = rsl.ship_to_address_id
                   AND rsl2.ship_to_org_id = rsl.ship_to_org_id
                   AND rsl2.customer_item_id = rsl.customer_item_id
                   AND rsl2.item_detail_type IN (0,1,2))
  GROUP BY rsl.ship_from_org_id,
           rsl.ship_to_address_id,
           rsl.ship_to_org_id,
           rsl.customer_item_id;
  --
  CURSOR get_order_info (v_ship_from_org_id NUMBER,
                        v_ship_to_org_id NUMBER,
                        v_customer_item_id  NUMBER) IS
   SELECT oeh.order_number , oeh.header_id
     FROM   oe_order_lines_all oel ,
            oe_order_headers   oeh
     WHERE  oeh.header_id = oel.header_id
     AND    oel.ship_from_org_id   = v_ship_from_org_id
     AND    oel.ship_to_org_id     = v_ship_to_org_id
     AND    oel.ordered_item_id    = v_customer_item_id
     AND    oel.open_flag     = 'Y'
     AND    oel.source_document_type_id = '5';
  --
  v_order_number   NUMBER;
  v_header_id      NUMBER;
  --
  i NUMBER DEFAULT 0;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'PopulateList');
  END IF;
  --
  FOR drop_list IN  c_drop_list LOOP
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Missing items on the schedule');
        rlm_core_sv.dlog(C_DEBUG, 'Ship From:', drop_list.ship_from_org_id);
        rlm_core_sv.dlog(C_DEBUG, 'Ship To Address Id:', drop_list.ship_to_address_id);
        rlm_core_sv.dlog(C_DEBUG, 'ST Org Id:', drop_list.ship_to_org_id);
        rlm_core_sv.dlog(C_DEBUG, 'Customer Item:', drop_list.customer_item_id);
      END IF;
   --
   v_order_number := NULL;
   v_header_id    := NULL;
   --
   BEGIN
    --
    OPEN get_order_info (drop_list.ship_from_org_id,
                         drop_list.ship_to_org_id,
                         drop_list.customer_item_id);
    --
    FETCH get_order_info INTO v_order_number,v_header_id;
    --
    CLOSE get_order_info;
    --
    IF v_header_id is  NOT NULL  THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'RLM_DROPPED_ITEMS');
         rlm_core_sv.dlog(C_DEBUG, 'SF', drop_list.ship_from_org_id);
         rlm_core_sv.dlog(C_DEBUG, 'ST', drop_list.ship_to_address_id);
         rlm_core_sv.dlog(C_DEBUG, 'CI', drop_list.customer_item_id);
         rlm_core_sv.dlog(C_DEBUG, 'Order Number', v_order_number);
         rlm_core_sv.dlog(C_DEBUG, 'Header_id', v_header_id);
      END IF;
      --
      rlm_message_sv.app_error(
             x_ExceptionLevel    => rlm_message_sv.k_warn_level,
             x_MessageName       => 'RLM_WARN_DROPPED_ITEMS',
             x_InterfaceHeaderId => x_curr_header_id,
             x_InterfaceLineId   => NULL,
             x_token1            => 'SF',
             x_value1            => RLM_CORE_SV.get_ship_from(drop_list.ship_from_org_id),
             x_token2            => 'ST',
             x_value2            => RLM_CORE_SV.get_ship_to(drop_list.ship_to_address_id),
             x_token3            => 'CI',
             x_value3            => RLM_CORE_SV.get_item_number(drop_list.customer_item_id),
             x_token4            => 'ORDER_NO',
             x_value4            => v_order_number);
     --
     ELSE
       --
       IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'No Open order line exists for below combination of '|| 'SF' ||','|| 'ST'||' and '|| 'CI.' );
         rlm_core_sv.dlog(C_DEBUG, 'SF', drop_list.ship_from_org_id);
         rlm_core_sv.dlog(C_DEBUG, 'ST', drop_list.ship_to_address_id);
         rlm_core_sv.dlog(C_DEBUG, 'CI', drop_list.customer_item_id);
       END IF ;
      --
     END IF ;
     --
   EXCEPTION
     --
     WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'In the when others of Populate Lists');
        rlm_core_sv.dlog(C_DEBUG, 'EXCEPTION: OTHER - ' ||  SUBSTR(SQLERRM,1,200));
      END IF ;
      --
   END ;
   --
  END LOOP;
  --
  x_return_status := TRUE;
  --
  IF (l_debug <> -1) THEN
--     rlm_core_sv.dlog(C_DEBUG, 'g_list_tbl.COUNT', g_list_tbl.COUNT);
     rlm_core_sv.dlog(C_DEBUG, 'x_return_status', x_return_status);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    x_return_status := FALSE;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: OTHER - ' ||  SUBSTR(SQLERRM,1,200));
    END IF;
    --

END PopulateList;


/*===========================================================================

  PROCEDURE NAME:    CompareList

===========================================================================*/
PROCEDURE CompareList (
          x_curr_header_id      IN  NUMBER)
IS
  --
  v_exist_count VARCHAR2(10);
  --
  i NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'CompareList');
     rlm_core_sv.dlog(C_DEBUG, 'g_list_tbl.COUNT', g_list_tbl.COUNT);
  END IF;
  --
  --
  -- Bug 2778728 : Proceed further only if g_list_tbl has any entries
  --
  IF g_list_tbl.COUNT > 0 THEN
   --
   i := g_list_tbl.FIRST;
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Starting Loop');
   END IF;
   --
   LOOP
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'ship_from_org_id', g_list_tbl(i).ship_from_org_id);
       rlm_core_sv.dlog(C_DEBUG, 'ship_to_address_id', g_list_tbl(i).ship_to_address_id);
       rlm_core_sv.dlog(C_DEBUG, 'customer_item_id', g_list_tbl(i).customer_item_id);
     END IF;
     --
     SELECT count(1)
     INTO   v_exist_count
     FROM   rlm_interface_lines_all
     WHERE  header_id          = x_curr_header_id
     AND    ship_from_org_id   = g_list_tbl(i).ship_from_org_id
     AND    ship_to_address_id = g_list_tbl(i).ship_to_address_id
     AND    customer_item_id   = g_list_tbl(i).customer_item_id;
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'i', i);
       rlm_core_sv.dlog(C_DEBUG, 'v_exist_count', v_exist_count);
     END IF;
     --
     IF v_exist_count > 0 THEN
      --
      EXIT WHEN i = g_list_tbl.LAST;
      --
      i := g_list_tbl.NEXT(i);
      --
     ELSE
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'RLM_DROPPED_ITEMS');
         rlm_core_sv.dlog(C_DEBUG, 'SF', g_list_tbl(i).ship_from_org_id);
         rlm_core_sv.dlog(C_DEBUG, 'ST', g_list_tbl(i).ship_to_address_id);
         rlm_core_sv.dlog(C_DEBUG, 'CI', g_list_tbl(i).customer_item_id);
         rlm_core_sv.dlog(C_DEBUG, 'Order Number', g_list_tbl(i).order_number);
      END IF;
      --
      rlm_message_sv.app_error(
             x_ExceptionLevel    => rlm_message_sv.k_warn_level,
             x_MessageName       => 'RLM_WARN_DROPPED_ITEMS',
             x_InterfaceHeaderId => x_curr_header_id,
             x_InterfaceLineId   => NULL,
             x_token1            => 'SF',
             x_value1            => RLM_CORE_SV.get_ship_from(g_list_tbl(i).ship_from_org_id),
             x_token2            => 'ST',
             x_value2            => RLM_CORE_SV.get_ship_to(g_list_tbl(i).ship_to_address_id),
             x_token3            => 'CI',
             x_value3            => RLM_CORE_SV.get_item_number(g_list_tbl(i).customer_item_id),
             x_token4            => 'ORDER_NO',
             x_value4            => g_list_tbl(i).order_number);
      --
      EXIT WHEN i = g_list_tbl.LAST;
      --
      i := g_list_tbl.NEXT(i);
      --
     END IF;
     --
   END LOOP;
   --
  END IF; /* g_list_tbl.COUNT > 0 */
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: OTHER - ' ||  SUBSTR(SQLERRM,1,200));
    END IF;
    --

END CompareList;

END RLM_REPLACE_SV;

/
