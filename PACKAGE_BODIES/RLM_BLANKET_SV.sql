--------------------------------------------------------
--  DDL for Package Body RLM_BLANKET_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_BLANKET_SV" as
/*$Header: RLMDPBOB.pls 120.6.12010000.2 2008/08/08 13:28:41 suppal ship $*/
--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
g_line_id       NUMBER := NULL; --Bugfix 6884912
g_req_flag      NUMBER := 0;    --Bugfix 6884912
--

/*============================================================================

PROCEDURE 	DeriveRSO

==============================================================================*/
PROCEDURE DeriveRSO(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
		    x_Group_rec IN RLM_DP_SV.t_Group_rec,
		    x_return_status OUT NOCOPY NUMBER) IS
  --
  CURSOR c_lines IS
   SELECT *
   FROM rlm_interface_lines_all
   WHERE header_id = x_Sched_rec.header_id AND
	 ship_from_org_id = x_Group_rec.ship_from_org_id AND
	 ship_to_address_id = x_Group_rec.ship_to_address_id AND
	 customer_item_id = x_Group_rec.customer_item_id AND
	 blanket_number = x_Group_rec.setup_terms_rec.blanket_number AND
	 item_detail_type IN (k_FIRM, k_PAST_DUE_FIRM, k_FORECAST) AND
         process_status <> rlm_core_sv.k_PS_PROCESSED
   ORDER BY request_date;
  --
  v_rso_hdr_id		NUMBER;
  v_count		NUMBER;
  v_start_date		DATE;
  v_end_date		DATE;
  v_maxend_date 	DATE;
  v_minstart_date	DATE;
  l_index		NUMBER;
  --4302492
  v_req_date            DATE;
  v_fence_days          NUMBER;
  v_RFFlag              VARCHAR2(1) := 'N';
  l_Group_rec           RLM_DP_SV.t_Group_rec;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'DeriveRSO');
     rlm_core_sv.dlog(C_DEBUG, 'Ship From Org', x_Group_Rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG, 'Ship To Address ID', x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG, 'Customer Item Id', x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(C_DEBUG, 'Blanket Number', x_Group_rec.setup_terms_rec.blanket_number);
     rlm_core_sv.dlog(C_DEBUG, 'Release Rule', x_Group_rec.setup_terms_rec.release_rule);
     rlm_core_sv.dlog(C_DEBUG, 'Release Time Frame', x_Group_rec.setup_terms_rec.release_time_frame);
  END IF;
  --
  x_return_status := rlm_core_sv.k_PROC_SUCCESS;
  --
  g_LineIdTab.DELETE;
  g_RSOIdTab.DELETE;
  l_index := 1;
  g_line_id := NULL; --Bugfix 6884912
  --
  v_start_date := k_DNULL;
  v_end_date := k_DNULL;
  --
  FOR c_lines_rec IN c_lines LOOP
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, '====================================');
      rlm_core_sv.dlog(C_DEBUG, 'Processing line', c_lines_rec.line_id);
      rlm_core_sv.dlog(C_DEBUG, 'Request Date', c_lines_rec.request_date);
      rlm_core_sv.dlog(C_DEBUG, 'Item Detail Type', c_lines_rec.item_Detail_type);
   END IF;
   --
   g_line_id  := c_lines_rec.line_id; --Bugfix 6884912
   -- 4302492 :start
   IF x_Sched_rec.schedule_source <> 'MANUAL' THEN
     --{
     IF x_Sched_rec.Schedule_type = k_PLANNING THEN
       v_RFFlag := x_Group_rec.setup_terms_rec.pln_frozen_flag;
     ELSIF x_Sched_rec.Schedule_type = k_SHIPPING THEN
       v_RFFlag := x_Group_rec.setup_terms_rec.shp_frozen_flag;
     ELSIF x_Sched_rec.Schedule_type = k_SEQUENCED THEN
       v_RFFlag := x_Group_rec.setup_terms_rec.seq_frozen_flag;
     END IF;
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'v_RFFlag is:', v_RFFlag);
       rlm_core_sv.dlog(C_DEBUG, 'before calling CalFenceDays');
     END IF;
     --
     CalFenceDays(x_Sched_rec,x_Group_rec,v_fence_days);
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'v_fence_days is:', v_fence_days);
     END IF;
     --
     l_Group_rec:= x_group_rec;
     l_Group_rec.frozen_days := v_fence_days;
     --
     IF v_RFFlag = 'Y' AND RLM_RD_SV.IsFrozen(TRUNC(SYSDATE),l_Group_rec,c_lines_rec.request_date)THEN
       v_req_date := TRUNC(SYSDATE) + nvl(v_fence_days,0) ;  --Bugfix 6485729
     ELSE
       v_req_date := c_lines_rec.request_date;
     END IF;
     --}
   ELSE -- if schedule is MANUAL
      v_req_date := c_lines_rec.request_date;
   END IF;
   -- 4302492 :end

   --4302492 :Use v_req_date instead of c_lines_rec.request_date
   IF NOT (TRUNC(v_req_date) >= TRUNC(v_start_date) AND
           TRUNC(v_req_date) < TRUNC(v_end_date)+1)
   THEN
    --
    QueryRSO(x_Sched_rec.customer_id, v_req_date,
	     c_lines_rec.customer_item_id, x_Group_rec, v_rso_hdr_id,
	     v_start_date, v_end_date, v_maxend_date, v_minstart_date);
    --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_rso_hdr_id', v_rso_hdr_id);
      rlm_core_sv.dlog(C_DEBUG, 'v_start_date', v_start_date);
      rlm_core_sv.dlog(C_DEBUG, 'v_end_date', v_end_date);
      rlm_core_sv.dlog(C_DEBUG, 'v_maxend_date', v_maxend_date);
      rlm_core_sv.dlog(C_DEBUG, 'v_minstart_date', v_minstart_date);
   END IF;
   --
   -- Bug 4901148 : QueryRSO() returns one of the following values
   --  * A valid RSO Header ID, corresponding to a record in oe_order_headers
   --  * -1 if the RSO Header is closed
   --  * -99 if it found an orphan RSO in rlm_blanket_rso table.
   --  * NULL if no RSO encompasses the request date of the line.
   --
   IF (v_rso_hdr_id IS NOT NULL) THEN
    --{
    IF (v_rso_hdr_id = -1) THEN
     --{
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Recreating RSO, since DSP found a closed one');
     END IF;
     --
     RLM_TPA_SV.CreateRSOHeader(x_Sched_rec, x_Group_rec, v_rso_hdr_id);
     RLM_TPA_SV.InsertRSO(x_Sched_rec, x_Group_rec, v_rso_hdr_id, v_start_date,
                          v_end_date);
     --}
    ELSIF (v_rso_hdr_id = -99) THEN
     --{
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Orphan record in RLM table, so recreate RSO and log exception');
     END IF;
     --
     rlm_message_sv.app_error(
        x_ExceptionLevel => rlm_message_sv.k_warn_level,
        x_MessageName => 'RLM_ORPHAN_RSO_FOUND',
        x_InterfaceHeaderId => x_Sched_rec.header_id,
        x_InterfaceLineId => c_lines_rec.line_id,
        x_ScheduleHeaderId => x_Sched_rec.schedule_header_id,
        x_ScheduleLineId => NULL,
        x_Token1 => 'BLANKET',
        x_value1 => x_Group_rec.setup_terms_rec.blanket_number,
        x_Token2 => 'START_DATE',
        x_Value2 => v_start_date,
        x_Token3 => 'END_DATE',
        x_Value3 => v_end_date);
     --
     RLM_TPA_SV.CreateRSOHeader(x_Sched_rec, x_Group_rec, v_rso_hdr_id);
     RLM_TPA_SV.InsertRSO(x_Sched_rec, x_Group_rec, v_rso_hdr_id, v_start_date,
                          v_end_date);
     --}
    END IF;
    --
   ELSIF v_rso_hdr_id IS NULL THEN
    --{
    --4302492 : Use v_req_date instead of c_lines_rec.request_date
    --
    IF TRUNC(v_req_date) <= TRUNC(v_minstart_date) THEN
     --{
     LOOP
      --
      CalcPriorEffectDates(x_Group_rec, v_req_date,
		   v_start_date, v_end_date, v_minstart_date);
      RLM_TPA_SV.CreateRSOHeader(x_Sched_rec, x_Group_rec, v_rso_hdr_id);
      RLM_TPA_SV.InsertRSO(x_Sched_rec, x_Group_rec, v_rso_hdr_id, v_start_date, v_end_date);
      --
      EXIT WHEN (TRUNC(v_req_date) >= TRUNC(v_start_date) AND
                 TRUNC(v_req_date) < TRUNC(v_end_date)+1);
      --
     END LOOP;
     --}
    ELSIF TRUNC(v_req_date) >= TRUNC(v_maxend_date) THEN
     --{
     LOOP
      --
      --4302492 :Use v_req_date instead of c_lines_rec.request_date
      --
      CalcEffectiveDates(x_Group_rec, v_req_date,
		         v_start_date, v_end_date, v_maxend_date);
    --Bugfix 6884912 Start
         g_req_flag := 0;
      IF c_lines_rec.request_date > v_end_date THEN
         g_req_flag := 1;
      END IF;
    --Bugfix 6884912 End

      RLM_TPA_SV.CreateRSOHeader(x_Sched_rec, x_Group_rec, v_rso_hdr_id);
      RLM_TPA_SV.InsertRSO(x_Sched_rec, x_Group_rec, v_rso_hdr_id, v_start_date, v_end_date);
      --
      EXIT WHEN (TRUNC(v_req_date) >= TRUNC(v_start_date) AND
                 TRUNC(v_req_date) < TRUNC(v_end_date)+1);
      --
     END LOOP;
     --}
    END IF;
    --}
   END IF; /* v_rso_hdr_id is null */
   --
   c_lines_rec.order_header_id := v_rso_hdr_id;
   --
   g_LineIdTab(l_index) := c_lines_rec.line_id;
   g_RSOIdTab(l_index)  := v_rso_hdr_id;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Line id', g_LineIdTab(l_index));
      rlm_core_sv.dlog(C_DEBUG, 'RSO Id', g_RSOIdTab(l_index));
   END IF;
   --
   l_index := l_index + 1;
   --
  END LOOP;
  --
  --Bug Fix 4254471 Added parameter to procedure
  UpdateLinesWithRSO(x_Sched_rec.schedule_header_id);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  EXCEPTION
    --
    WHEN e_RSOCreationError THEN
      --
      x_return_Status := rlm_core_sv.k_PROC_ERROR;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG, 'e_RSOCreationError');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_Status := RLM_CORE_SV.k_PROC_ERROR;
      rlm_message_sv.sql_error('RLM_BLANKET_SV.DeriveRSO', '040');
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'When others of DeriveRSO');
         rlm_core_sv.dpop(C_SDEBUG,'DeriveRSO EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
END DeriveRSO;



/*============================================================================

PROCEDURE	QueryRSO

==============================================================================*/
PROCEDURE QueryRSO(p_customer_id     IN NUMBER,
		   p_request_date    IN DATE,
		   p_cust_item_id    IN NUMBER,
		   x_Group_rec	     IN RLM_DP_SV.t_Group_rec,
		   x_rso_hdr_id	     OUT NOCOPY NUMBER,
		   x_start_date	     OUT NOCOPY DATE,
		   x_end_date	     OUT NOCOPY DATE,
		   x_maxend_date     OUT NOCOPY DATE,
		   x_minstart_date   OUT NOCOPY DATE) IS
  --
  CURSOR rlm_rso_pi IS
   SELECT max(decode(oe.open_flag, 'Y', rso_hdr_id, 'N', -1, -99)),
          effective_start_date, effective_end_date
   FROM RLM_BLANKET_RSO rlm, OE_ORDER_HEADERS oe
   WHERE customer_id = p_customer_id AND
         rlm.blanket_number = x_Group_rec.setup_terms_rec.blanket_number AND
         customer_item_id = p_cust_item_id AND
         rlm.rso_hdr_id = oe.header_id(+)
   GROUP BY effective_start_date, effective_end_date
   ORDER BY effective_start_date, effective_end_date; --Bugfix 6759544
  --
  CURSOR rlm_rso_ai IS
   SELECT max(decode(oe.open_flag, 'Y', rso_hdr_id, 'N', -1, -99)),
          effective_start_date, effective_end_date
   FROM RLM_BLANKET_RSO rlm, OE_ORDER_HEADERS oe
   WHERE customer_id = p_customer_id AND
         rlm.blanket_number = x_Group_rec.setup_terms_rec.blanket_number AND
	 rlm.customer_item_id = k_NNULL AND
         rlm.rso_hdr_id = oe.header_id(+)
   GROUP BY effective_start_date, effective_end_date
   ORDER BY effective_start_date, effective_end_date; --Bugfix 6759544
  --
  v_start_date	 DATE;
  v_end_date	 DATE;
  v_maxend_date  DATE;
  v_minstart_date DATE;
  v_rsohdr_id	 NUMBER;
  v_rel_rule	 VARCHAR2(3);
  v_first	 BOOLEAN;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'QueryRSO');
  END IF;
  --
  v_rel_rule := x_Group_rec.setup_terms_rec.release_rule;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'p_customer_id', p_customer_id);
     rlm_core_sv.dlog(C_DEBUG, 'p_blanket_number', x_Group_rec.setup_terms_rec.blanket_number);
     rlm_core_sv.dlog(C_DEBUG, 'p_request_date', p_request_date);
     rlm_core_sv.dlog(C_DEBUG, 'p_cust_item_id', p_cust_item_id);
     rlm_core_sv.dlog(C_DEBUG, 'Release Creation Rule', v_rel_rule);
     rlm_core_sv.dlog(C_DEBUG, 'Release Time Frame', x_Group_rec.setup_terms_rec.release_time_frame);
  END IF;
  --
  v_first := TRUE;
  --
  IF v_rel_rule = 'PI' THEN
   --
   OPEN rlm_rso_pi;
   FETCH rlm_rso_pi INTO v_rsohdr_id, v_start_date, v_end_date;
   --
   WHILE rlm_rso_pi%FOUND LOOP
    --
    IF (TRUNC(p_request_date) >=  TRUNC(v_start_date) AND
        TRUNC(p_request_date) < TRUNC(v_end_date) + 1) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Inside PI if');
     END IF;
     --
     x_rso_hdr_id := v_rsohdr_id;
     x_start_date := v_start_date;
     x_end_date := v_end_date;
     --
     EXIT;
     --
    END IF;
    --
    IF v_first THEN
     v_minstart_date := v_start_date;
     v_first := FALSE;
    END IF;
    --
    v_maxend_date := v_end_date;
    FETCH rlm_rso_pi INTO v_rsohdr_id, v_start_date, v_end_date;
    --
   END LOOP;
   --
   CLOSE rlm_rso_pi;
   --
  ELSE
   --
   OPEN rlm_rso_ai;
   FETCH rlm_rso_ai INTO v_rsohdr_id, v_start_date, v_end_date;
   --
   WHILE rlm_rso_ai%FOUND LOOP
    --
    IF (TRUNC(p_request_date) >= v_start_date AND
        TRUNC(p_request_date) < TRUNC(v_end_date)+1) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Inside AI if');
     END IF;
     --
     x_rso_hdr_id := v_rsohdr_id;
     x_start_date := v_start_date;
     x_end_date := v_end_date;
     --
     EXIT;
     --
    END IF;
    --
    IF v_first THEN
     v_minstart_date := v_start_date;
     v_first := FALSE;
    END IF;
    --
    v_maxend_date := v_end_date;
    FETCH rlm_rso_ai INTO v_rsohdr_id, v_start_date, v_end_date;
    --
   END LOOP;
   --
   CLOSE rlm_rso_ai;
   --
  END IF;
  --
  x_start_date := NVL(v_start_date, k_DNULL);
  x_end_date   := NVL(v_end_date, k_DNULL);
  --
  x_maxend_date := NVL(v_maxend_date, k_DNULL);
  x_minstart_date := NVL(v_minstart_date, k_DNULL);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG, x_rso_hdr_id);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'QueryRSO EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     RAISE;
     --
END QueryRSO;


/*============================================================================

PROCEDURE	CalcEffectiveDates

==============================================================================*/
PROCEDURE CalcEffectiveDates(x_Group_rec	IN RLM_DP_SV.t_Group_rec,
			     p_request_date	IN DATE,
			     x_start_date 	OUT NOCOPY DATE,
			     x_end_date   	OUT NOCOPY DATE,
			     x_maxend_date	IN OUT NOCOPY DATE) IS
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'CalcEffectiveDates');
  END IF;
  --
  IF x_maxend_date = k_DNULL THEN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'This will the first entry of its type in the RLM_RSO table');
   END IF;
   --
   IF to_char(p_request_date, 'D') = g_SundayDOW THEN
    --
    x_end_date   := p_request_date;
    x_start_date := x_end_date - (x_Group_rec.setup_terms_rec.release_time_frame * 7) + 1;
    --
   ELSE
    --
    x_start_date := p_request_date - (to_number(to_char(p_request_date, 'D')) - g_MondayDOW);
    x_end_date   := x_start_date + (x_Group_rec.setup_terms_rec.release_time_frame * 7) - 1;
    --
   END IF;
   --
  ELSE
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Using context of existing RSOs');
      rlm_core_sv.dlog(C_DEBUG, 'End effective date of last RSO', x_maxend_date);
   END IF;
   --
   x_start_date := x_maxend_date + 1;
   x_end_date   := x_start_date + (x_Group_rec.setup_terms_rec.release_time_frame * 7) - 1;
   --
  END IF;
  --
  x_maxend_date := x_end_date;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Effective start date of new RSO', x_start_date);
     rlm_core_sv.dlog(C_DEBUG, 'Effective end date of new RSO', x_end_date);
     rlm_core_sv.dlog(C_DEBUG, 'Max Effec. end date', x_maxend_date);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'CalcEffectiveDates EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     RAISE;
     --
END CalcEffectiveDates;



/*============================================================================

PROCEDURE	CalcPriorEffectDates

==============================================================================*/
PROCEDURE CalcPriorEffectDates(x_Group_rec	  IN RLM_DP_SV.t_Group_rec,
			       p_request_date	  IN DATE,
			       x_start_date 	  OUT NOCOPY DATE,
			       x_end_date   	  OUT NOCOPY DATE,
			       x_minstart_date	  IN OUT NOCOPY DATE) IS
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'CalcPriorEffectDates');
     rlm_core_sv.dlog(C_DEBUG, 'x_minstart_date', x_minstart_date);
  END IF;
  --
  x_end_date := x_minstart_date - 1;
  x_start_date := x_end_date - (7 * x_Group_rec.setup_terms_rec.release_time_frame) + 1;
  x_minstart_date := x_start_date;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'x_start_date', x_start_date);
     rlm_core_sv.dlog(C_DEBUG, 'x_end_date', x_end_date);
     rlm_core_sv.dlog(C_DEBUG, 'New x_minstart_date', x_minstart_date);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'CalcPriorEffectDates EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     RAISE;
     --
END CalcPriorEffectDates;


/*============================================================================

PROCEDURE	InsertRSO

==============================================================================*/
PROCEDURE InsertRSO(x_Sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
		    x_Group_rec  IN RLM_DP_SV.t_Group_rec,
		    p_rso_hdr_id IN NUMBER,
		    p_start_date IN DATE,
		    p_end_date   IN DATE) IS
  --
  v_customer_item_id	NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'InsertRSO');
     rlm_core_sv.dlog(C_DEBUG, 'Customer id', x_Sched_rec.customer_id);
     rlm_core_sv.dlog(C_DEBUG, 'Blanket Number', x_Group_rec.setup_terms_rec.blanket_number);
     rlm_core_sv.dlog(C_DEBUG, 'Release Rule', x_Group_rec.setup_terms_rec.release_rule);
     rlm_core_sv.dlog(C_DEBUG, 'p_rso_hdr_id', p_rso_hdr_id);
     rlm_core_sv.dlog(C_DEBUG, 'Customer Item Id', x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(C_DEBUG, 'p_start_date', p_start_date);
     rlm_core_sv.dlog(C_DEBUG, 'p_end_date', p_end_date);
  END IF;
  --
  IF x_Group_rec.setup_terms_rec.release_rule = 'AI' THEN
   v_customer_item_id := k_NNULL;
  ELSE
   v_customer_item_id := x_Group_rec.customer_item_id;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'v_customer_item_id', v_customer_item_id);
  END IF;
  --
  INSERT INTO RLM_BLANKET_RSO
  (
   customer_id, blanket_number, rso_hdr_id,
   customer_item_id, effective_start_date, effective_end_date
   )
  VALUES
  (
   x_Sched_rec.customer_id, x_Group_rec.setup_terms_rec.blanket_number,
   p_rso_hdr_id, v_customer_item_id, TRUNC(p_start_date), TRUNC(p_end_date)
  );
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
        rlm_core_sv.dpop(C_SDEBUG,'InsertRSO EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     RAISE;
     --
END InsertRSO;


/*============================================================================

PROCEDURE	CreateRSOHeader

==============================================================================*/
PROCEDURE CreateRSOHeader(x_Sched_rec	   IN RLM_INTERFACE_HEADERS%ROWTYPE,
			  x_Group_rec	   IN RLM_DP_SV.t_Group_rec,
			  x_rso_hdr_id	   OUT NOCOPY NUMBER) IS
  --
  l_oe_header_rec                 oe_order_pub.header_rec_type;
  l_oe_header_val_rec             oe_order_pub.header_val_rec_type;
  l_oe_header_adj_tbl             oe_order_pub.header_adj_tbl_type;
  l_oe_header_adj_val_tbl         oe_order_pub.header_adj_val_tbl_type;
  l_oe_header_scredit_tbl         oe_order_pub.header_scredit_tbl_type;
  l_oe_header_scredit_val_tbl     oe_order_pub.header_scredit_val_tbl_type;
  l_oe_line_tbl                   oe_order_pub.line_tbl_type;
  l_oe_line_val_tbl               oe_order_pub.line_val_tbl_type;
  l_oe_header_out_rec             oe_order_pub.header_rec_type;
  l_oe_header_val_out_rec         oe_order_pub.header_val_rec_type;
  l_oe_header_adj_out_tbl         oe_order_pub.header_adj_tbl_type;
  l_oe_header_adj_val_out_tbl     oe_order_pub.header_adj_val_tbl_type;
  l_oe_Header_price_Att_out_tbl   oe_order_pub.Header_Price_Att_Tbl_Type;
  l_oe_Header_Adj_Att_out_tbl     oe_order_pub.Header_Adj_Att_Tbl_Type;
  l_oe_Header_Adj_Assoc_out_tbl   oe_order_pub.Header_Adj_Assoc_Tbl_Type;
  l_oe_header_scredit_out_tbl     oe_order_pub.header_scredit_tbl_type;
  l_oe_hdr_scdt_val_out_tbl       oe_order_pub.header_scredit_val_tbl_type;
  l_oe_line_out_tbl               oe_order_pub.line_tbl_type;
  l_oe_line_val_out_tbl           oe_order_pub.line_val_tbl_type;
  l_oe_line_adj_out_tbl           oe_order_pub.line_adj_tbl_type;
  l_oe_line_adj_val_out_tbl       oe_order_pub.line_adj_val_tbl_type;
  l_oe_Line_price_Att_out_tbl     OE_Order_PUB.Line_Price_Att_Tbl_Type;
  l_oe_Line_Adj_Att_out_tbl       OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_oe_Line_Adj_Assoc_out_tbl     OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  l_oe_line_scredit_out_tbl       oe_order_pub.line_scredit_tbl_type;
  l_oe_line_scredit_val_out_tbl   oe_order_pub.line_scredit_val_tbl_type;
  l_oe_lot_serial_out_tbl         oe_order_pub.Lot_Serial_Tbl_Type;
  l_oe_lot_serial_val_out_tbl     oe_order_pub.Lot_Serial_Val_Tbl_Type;
  l_action_request_tbl            OE_Order_PUB.request_tbl_type;
  l_action_request_tbl_out        OE_Order_PUB.request_tbl_type;
  l_oe_header_rec_out             oe_order_pub.header_rec_type;
  l_return_status                 Varchar2(30);
  x_msg_count                     number;
  x_msg_data                      Varchar2(2000);
  x_msg_index                     number;
  --
  v_progress VARCHAR2(3) := '010';
  v_FileName             VARCHAR2(2000);
  --
  x_token		FND_NEW_MESSAGES.TYPE%TYPE;
  x_msg_name		FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'CreateRSOHeader');
     rlm_core_sv.dlog(C_DEBUG, 'Blanket Number', x_Group_rec.setup_terms_rec.blanket_number);
     rlm_core_sv.dlog(C_DEBUG, 'Customer id', x_Sched_rec.customer_id);
     rlm_core_sv.dlog(C_DEBUG, 'Org ID', x_Sched_rec.org_id);
  END IF;
  --
  l_oe_header_rec   := OE_Order_PUB.G_MISS_HEADER_REC;
  l_oe_header_rec.operation := OE_Globals.G_OPR_CREATE;
  l_oe_header_rec.blanket_number := x_Group_rec.setup_terms_rec.blanket_number;
  l_oe_header_rec.sold_to_org_id := x_Sched_rec.customer_id;
  l_oe_header_rec.org_id := x_Sched_rec.org_id;
  --
  l_action_request_tbl(1).entity_code  := OE_GLOBALS.G_ENTITY_HEADER;
  l_action_request_tbl(1).request_type := OE_GLOBALS.G_BOOK_ORDER;
  --
  OE_Order_Grp.Process_order
  (   p_api_version_number            => 1.0
   ,   p_init_msg_list                 => FND_API.G_TRUE
   ,   p_return_values                 => FND_API.G_FALSE
   ,   p_commit                        => FND_API.G_FALSE
   ,   p_validation_level              => FND_API.G_VALID_LEVEL_NONE
   ,   p_control_rec                   => OE_GLOBALS.G_MISS_CONTROL_REC
   ,   p_api_service_level             => OE_GLOBALS.G_ALL_SERVICE
   ,   x_return_status                 => l_return_status
   ,   x_msg_count                     => x_msg_count
   ,   x_msg_data                      => x_msg_data
   ,   p_header_rec                    => l_oe_header_rec
   ,   p_Action_Request_tbl            => l_action_request_tbl
   ,   x_header_rec                    => l_oe_header_rec_out
   ,   x_header_val_rec                => l_oe_header_val_rec
   ,   x_Header_Adj_tbl                => l_oe_header_adj_tbl
   ,   x_Header_Adj_val_tbl            => l_oe_header_adj_val_tbl
   ,   x_Header_price_Att_tbl          => l_oe_Header_price_Att_out_tbl
   ,   x_Header_Adj_Att_tbl            => l_oe_Header_Adj_Att_out_tbl
   ,   x_Header_Adj_Assoc_tbl          => l_oe_Header_Adj_Assoc_out_tbl
   ,   x_Header_Scredit_tbl            => l_oe_header_scredit_out_tbl
   ,   x_Header_Scredit_val_tbl        => l_oe_hdr_scdt_val_out_tbl
   ,   x_line_tbl                      => l_oe_line_out_tbl
   ,   x_line_val_tbl                  => l_oe_line_val_out_tbl
   ,   x_Line_Adj_tbl                  => l_oe_line_adj_out_tbl
   ,   x_Line_Adj_val_tbl              => l_oe_line_adj_val_out_tbl
   ,   x_Line_price_Att_tbl            => l_oe_Line_price_Att_out_tbl
   ,   x_Line_Adj_Att_tbl              => l_oe_Line_Adj_Att_out_tbl
   ,   x_Line_Adj_Assoc_tbl            => l_oe_Line_Adj_Assoc_out_tbl
   ,   x_Line_Scredit_tbl              => l_oe_line_scredit_out_tbl
   ,   x_Line_Scredit_val_tbl          => l_oe_line_scredit_val_out_tbl
   ,   x_Lot_Serial_tbl                => l_oe_lot_serial_out_tbl
   ,   x_Lot_Serial_val_tbl            => l_oe_lot_serial_val_out_tbl
   ,   x_action_request_tbl            => l_action_request_tbl_out
  );
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Process Order return Status',l_return_Status);
     rlm_core_sv.dlog(C_DEBUG,'Process Order Error Count',x_msg_count);
     rlm_core_sv.dlog(C_DEBUG,'Process Order Error Message',x_msg_data);
  END IF;
  --
  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
      l_return_status = FND_API.G_RET_STS_ERROR) THEN
    --
    RAISE e_RSOCreationError;
    --
  ELSE
   --
   x_token := 'INFO';
   x_msg_name := 'RLM_RSO_CREATION_INFO';
   --
   RLM_TPA_SV.InsertOMMessages(x_Sched_rec, x_Group_rec,
		    x_msg_count, rlm_message_sv.k_INFO_LEVEL,
		    x_token, x_msg_name);
   --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Sales order header id ',
                                l_oe_header_rec_out.header_id);
     rlm_core_sv.dlog(C_DEBUG, 'Sales order number',
                                l_oe_header_rec_out.order_number);
  END IF;
  --
  x_rso_hdr_id := l_oe_header_rec_out.header_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  EXCEPTION
   --
   WHEN e_RSOCreationError THEN
     --
     x_token := 'ERROR';
     x_msg_name := 'RLM_RSO_CREATION_ERROR';
     --
     RLM_TPA_SV.InsertOMMessages(x_Sched_rec, x_Group_rec,
		      x_msg_count, rlm_message_sv.k_ERROR_LEVEL,
		      x_token, x_msg_name);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'RSO Creation Error: ' || x_msg_data);
        rlm_core_sv.dpop(C_SDEBUG, 'e_RSOCreationError');
     END IF;
     --
     RAISE e_RSOCreationError;
     --
   WHEN OTHERS THEN
     rlm_message_sv.sql_error('rlm_blanket_sv.CreateRSOHeader', v_progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG, 'CreateRSOHeader');
     END IF;
     --
     RAISE;
     --
END CreateRSOHeader;

/*============================================================================

PROCEDURE	UpdateLinesWithRSO

==============================================================================*/
--Bug Fix 4254471 Added parameter to procedure
PROCEDURE UpdateLinesWithRSO(x_header_id IN NUMBER) IS
  --
  v_progress	VARCHAR2(3) := '020';
  i		NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'UpdateLinesWithRSO');
     rlm_core_sv.dlog(C_DEBUG, 'x_header_id', x_header_id);
     rlm_core_sv.dlog(C_DEBUG, '# of lines', g_LineIdTab.COUNT);
     rlm_core_sv.dlog(C_DEBUG, '# of RSOs', g_RSOIdTab.COUNT);
  END IF;
  --
  FORALL i IN 1..g_LineIdTab.COUNT
   --
   UPDATE rlm_interface_lines_all
   SET order_header_id = g_RSOIdTab(i)
   WHERE line_id = g_LineIdTab(i);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, '# of interface lines updated', SQL%ROWCOUNT);
   END IF;
   --
  FORALL i IN 1..g_LineIdTab.COUNT
   --
   UPDATE rlm_schedule_lines
   SET order_header_id = g_RSOIdTab(i)
   WHERE interface_line_id = g_LineIdTab(i)
   AND   header_id = x_header_id; /* 4254471 */
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, '# of schedule lines updated', SQL%ROWCOUNT);
     rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
  EXCEPTION
   --
   WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_blanket_sv.UpdateLinesWithRSO', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;

END UpdateLinesWithRSO;


/*============================================================================

PROCEDURE	InsertOMMessages

==============================================================================*/
PROCEDURE InsertOMMessages(x_Sched_rec	IN	RLM_INTERFACE_HEADERS%ROWTYPE,
			   x_Group_rec	IN	RLM_DP_SV.t_Group_rec,
			   x_msg_count  IN	NUMBER,
			   x_msg_level	IN	VARCHAR2,
			   x_token	IN	VARCHAR2,
			   x_msg_name	IN	VARCHAR2) IS
  --
  x_msg                          VARCHAR2(4000);
  v_interface_line_id            NUMBER;
  v_schedule_header_id           NUMBER;
  v_order_header_id              NUMBER;
  v_request_date                 VARCHAR2(150);
  l_entity_code                  VARCHAR2(30);
  l_entity_ref                   VARCHAR2(50);
  l_entity_id                    NUMBER;
  l_header_id                    NUMBER;
  l_line_id                      NUMBER;
  l_order_source_id              NUMBER;
  l_orig_sys_document_ref        VARCHAR2(50);
  l_orig_sys_line_ref            VARCHAR2(50);
  l_orig_sys_shipment_ref        VARCHAR2(50);
  l_change_sequence              VARCHAR2(50);
  l_source_document_type_id      NUMBER;
  l_source_document_id           NUMBER;
  l_source_document_line_id      NUMBER;
  l_attribute_code               VARCHAR2(30);
  l_constraint_id                NUMBER;
  l_process_activity             NUMBER;
  l_transaction_id               NUMBER;
  l_notification_flag            VARCHAR2(1) := 'N' ;
  l_type                         VARCHAR2(30) ;
  l_msg_level                    VARCHAR2(10); --4129069
  --
  v_Progress			 VARCHAR2(3) := '030';
  v_InterfaceLineId		 NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'InsertOMMessages');
  END IF;
  --
  IF x_msg_count >0 THEN
    --
    FOR I in 1..x_msg_count LOOP
     --
     x_msg := oe_msg_pub.get(p_msg_index => I,
                            p_encoded => 'F');
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Message Found', substr(x_msg,1,200));
     END IF;
     --
     oe_msg_pub.Get_msg_context(
                p_msg_index                => I
                ,x_entity_code             => l_entity_code
                ,x_entity_ref              => l_entity_ref
                ,x_entity_id               => l_entity_id
                ,x_header_id               => l_header_id
                ,x_line_id                 => l_line_id
                ,x_order_source_id         => l_order_source_id
                ,x_orig_sys_document_ref   => l_orig_sys_document_ref
                ,x_orig_sys_line_ref       => l_orig_sys_line_ref
                ,x_orig_sys_shipment_ref   => l_orig_sys_shipment_ref
                ,x_change_sequence         => l_change_sequence
                ,x_source_document_type_id => l_source_document_type_id
                ,x_source_document_id      => l_source_document_id
                ,x_source_document_line_id => l_source_document_line_id
                ,x_attribute_code          => l_attribute_code
                ,x_constraint_id           => l_constraint_id
                ,x_process_activity        => l_process_activity
                ,x_notification_flag       => l_notification_flag
                ,x_type                    => l_type
                );
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'l_header_id', l_header_id);
        rlm_core_sv.dlog(C_DEBUG,'x_msg_level', x_msg_level);
        rlm_core_sv.dlog(C_DEBUG,'x_msg_name', x_msg_name);
        rlm_core_sv.dlog(C_DEBUG,'Industry Att15', x_Group_rec.industry_attribute15);
        rlm_core_sv.dlog(C_DEBUG,'x_ShipToAddressId',x_Group_rec.ship_to_address_id);
        rlm_core_sv.dlog(C_DEBUG,'x_CustomerItemId',x_Group_rec.customer_item_id);
        rlm_core_sv.dlog(C_DEBUG,'x_InventoryItemId',x_Group_rec.inventory_item_id);
     END IF;
     --
     SELECT line_id
     INTO v_InterfaceLineId
     FROM rlm_interface_lines
     WHERE header_id = x_Sched_rec.header_id
     AND ship_from_org_id = x_Group_rec.ship_from_org_id
     AND ship_to_address_id = x_Group_rec.ship_to_address_id
     AND customer_item_id = x_Group_rec.customer_item_id
     AND line_id = g_line_id; --Bugfix 6884912
--     AND rownum = 1;        --Bugfix 6884912
     --

     -- Bug 4129069 : Set the message level depending on the seeded error
     -- type only if Process Order API returned Error Status.

     IF x_msg_name = 'RLM_RSO_CREATION_ERROR' THEN
      IF (l_type = 'ERROR') THEN
       l_msg_level := x_msg_level;
      ELSE
       l_msg_level := rlm_message_sv.k_INFO_LEVEL;
      END IF;
     ELSE
      l_msg_level := x_msg_level;
     END IF;
     --
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'l_msg_level', l_msg_level);
     END IF;
     --
     --Bugfix 6884912 Start
     IF  g_req_flag = 1 THEN
       rlm_message_sv.app_error(
                   x_ExceptionLevel => l_msg_level,
                   x_MessageName => x_msg_name,
                   x_InterfaceHeaderId => x_Sched_rec.header_id,
                   x_InterfaceLineId => v_InterfaceLineId,
                   x_ScheduleHeaderId => NULL,
                   x_ScheduleLineId => NULL,
                   x_OrderHeaderId => l_header_id,
                   x_OrderLineId => NULL,
                   x_GroupInfo => TRUE,
                   x_ShipFromOrgId => x_Group_rec.industry_attribute15,
                   x_ShipToAddressId => x_Group_rec.ship_to_address_id,
                   x_CustomerItemId => x_Group_rec.customer_item_id,
                   x_InventoryItemId => x_Group_rec.inventory_item_id,
                   x_Token1 => x_token,
                   x_value1 => substr(x_msg,1,200),
                   x_Token2 => 'BLANKET_NUMBER',
                   x_value2 =>  x_Group_rec.setup_terms_rec.blanket_number,
		           x_Token3 => 'ORDER_NUMBER',
		           x_Value3 => RLM_VALIDATEDEMAND_SV.GetOrderNumber(l_header_id));

     ELSE
     -- bug fix 4198330
     rlm_message_sv.app_error(
                   x_ExceptionLevel => l_msg_level,
                   x_MessageName => x_msg_name,
                   x_InterfaceHeaderId => x_Sched_rec.header_id,
                   x_InterfaceLineId => v_InterfaceLineId,
                   x_ScheduleHeaderId => NULL,
                   x_ScheduleLineId => NULL,
                   x_OrderHeaderId => l_header_id,
                   x_OrderLineId => NULL,
                   x_ShipFromOrgId => x_Group_rec.industry_attribute15,
                   x_ShipToAddressId => x_Group_rec.ship_to_address_id,
                   x_CustomerItemId => x_Group_rec.customer_item_id,
                   x_InventoryItemId => x_Group_rec.inventory_item_id,
                   x_Token1 => x_token,
                   x_value1 => substr(x_msg,1,200),
                   x_Token2 => 'BLANKET_NUMBER',
                   x_value2 =>  x_Group_rec.setup_terms_rec.blanket_number,
		           x_Token3 => 'ORDER_NUMBER',
		           x_Value3 => RLM_VALIDATEDEMAND_SV.GetOrderNumber(l_header_id));
     END IF;
     --
     --Bugfix 6884912 End
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
   WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_blanket_sv.InsertOMMessages', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;
     --
END InsertOMMessages;

/*===========================================================================

        FUNCTION NAME:  GetTPContext

===========================================================================*/
PROCEDURE GetTPContext( x_Sched_rec  			IN  RLM_INTERFACE_HEADERS%ROWTYPE,
                        x_Group_rec  			IN  rlm_dp_sv.t_Group_rec,
                        x_customer_number 		OUT NOCOPY VARCHAR2,
                        x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                        x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                        x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                        x_tp_group_code 		OUT NOCOPY VARCHAR2)
IS
   --
   v_Progress VARCHAR2(3) := '010';
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG,'GetTPContext');
      rlm_core_sv.dlog(C_DEBUG,'customer_id', x_Sched_rec.customer_id);
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
      and	ACCT_SITE.ECE_TP_LOCATION_CODE  = x_Sched_rec.ECE_TP_LOCATION_CODE_EXT;

   ELSE
      x_tp_group_code := x_Sched_rec.ECE_TP_TRANSLATOR_CODE;
   END IF;
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
   -- BUG 2204888 : Since we do not group by bill_to anymore, we would not
   -- have the bill_to in x_group_rec. Code has been removed as a part of
   -- TCA OBSOLESCENCE PROJECT.
   --
   --
   IF x_sched_rec.customer_id is NOT NULL THEN
      --
      -- Following query is changed as per TCA obsolescence project.
      SELECT account_number
      INTO   x_customer_number
      FROM   HZ_CUST_ACCOUNTS CUST_ACCT
      WHERE  CUST_ACCT.CUST_ACCOUNT_ID = x_sched_rec.customer_id;
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
      rlm_message_sv.sql_error('rlm_blanket_sv.GetTPContext',v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetTPContext;

--4302492
/*============================================================================

PROCEDURE	CalFenceDays

==============================================================================*/

PROCEDURE CalFenceDays(x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_Group_rec IN rlm_dp_sv.t_Group_rec,
                       x_fence_days OUT NOCOPY NUMBER)
IS
  --
  v_FrozenFenceDayFrom            NUMBER;
  v_FrozenFenceDayTo              NUMBER;
  v_FrozenFenceDays             NUMBER := NULL;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_DEBUG,'CalFenceDays');
     rlm_core_sv.dlog(C_DEBUG,'x_roll_forward_flag', x_Group_rec.roll_forward_frozen_flag);
  END IF;
  --
  IF x_Sched_rec.Schedule_type = k_PLANNING THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'PLANNING');
    END IF;
    --
    v_FrozenFenceDayFrom := x_Group_rec.setup_terms_rec.pln_frozen_day_from;
    v_FrozenFenceDayTo := x_Group_rec.setup_terms_rec.pln_frozen_day_to;
    --
  ELSIF x_Sched_rec.Schedule_type = k_SHIPPING THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'SHIPPING');
    END IF;
    --
    v_FrozenFenceDayFrom := x_Group_rec.setup_terms_rec.shp_frozen_day_from;
    v_FrozenFenceDayTo := x_Group_rec.setup_terms_rec.shp_frozen_day_to;
    --
  ELSIF x_Sched_rec.Schedule_type = k_SEQUENCED THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'SEQUENCED');
    END IF;
    --
    v_FrozenFenceDayFrom := x_Group_rec.setup_terms_rec.seq_frozen_day_from;
    v_FrozenFenceDayTo := x_Group_rec.setup_terms_rec.seq_frozen_day_to;
    --
  END IF;
  --
  IF v_FrozenFenceDayFrom IS NOT NULL THEN
    v_FrozenFenceDays := v_FrozenFenceDayTo - v_FrozenFenceDayFrom + 1;
  ELSE
    v_FrozenFenceDays := NULL;
  END IF;
  --
  x_fence_days :=v_FrozenFenceDays;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
END CalFenceDays;


END RLM_BLANKET_SV;

/
