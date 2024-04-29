--------------------------------------------------------
--  DDL for Package Body RLM_FORECAST_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_FORECAST_SV" as
/* $Header: RLMDPFPB.pls 120.4.12010000.2 2009/03/23 09:47:01 sunilku ship $ */
/*=======================  RLM_FORECAST_SV  ============================*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
g_MRP_ListName        VARCHAR2(30) := NULL;  --Bugfix 8326871
/*===========================================================================

  PROCEDURE NAME:       ManageForecast

===========================================================================*/
PROCEDURE ManageForecast(x_InterfaceHeaderId IN NUMBER,
                         x_sched_rec IN  RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN  OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_ReturnStatus OUT NOCOPY NUMBER)
IS
  --
  v_SubGroup_ref      t_Cursor_ref;
  v_SubGroup_rec      rlm_dp_sv.t_Group_rec;
  x_HeaderStatus       NUMBER;
  x_progress           VARCHAR2(3) := '010';
  t_forecast            mrp_forecast_interface_pk.t_forecast_interface;
  empty_designator      mrp_forecast_interface_pk.t_forecast_designator;
  empty_forecast        mrp_forecast_interface_pk.t_forecast_interface;
  t_designator          mrp_forecast_interface_pk.t_forecast_designator;
  e_forecastapifailed  EXCEPTION;
  e_lines_locked       EXCEPTION;
  e_no_forecast        EXCEPTION;
  v_last               NUMBER;
  v_counter            NUMBER;
  v_mrp_count          NUMBER:=0;       /*2816086*/
  v_designator         VARCHAR2(10);
  v_InterfaceLineId    NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ManageForecast');
     rlm_core_sv.dlog(k_DEBUG,'x_InterfaceHeaderId',x_InterfaceHeaderId);
  END IF;
  --
  x_ReturnStatus := rlm_core_sv.k_PROC_SUCCESS;
  --
  IF NOT rlm_dp_sv.CheckForecast(x_InterfaceHeaderId,x_Group_rec) THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'No Forecast processing');
     END IF;
     --
     RAISE e_no_forecast;
     --
  END IF;
  --
  /* Bill_to information is used to get the designator.  Since we
     do not have the bill to information in the  x_Group_rec, we
     initialize the group (by bill_to) and then process the sub groups */
  --
  RLM_TPA_SV.InitializeGroup(x_Sched_rec,
                  v_SubGroup_ref,
                  x_Group_rec);
  --
  WHILE FetchGroup(v_SubGroup_ref, v_SubGroup_rec) LOOP
    --
    IF x_Group_rec.IsSourced THEN
      --
      IF NOT LockLines(v_SubGroup_rec, x_InterfaceHeaderId) THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(k_DEBUG,'RLM_LOCK_NOT_OBTAINED');
          END IF;
          --
          RAISE e_lines_locked;
          --
      END IF;
       --
    END IF;
    --

    IF (l_debug <> -1) THEN
      --
      rlm_core_sv.dlog(k_DEBUG,'customer_id' ,v_subgroup_rec.customer_id);
      rlm_core_sv.dlog(k_DEBUG,'ship_to_customer_id',v_subgroup_rec.ship_to_customer_id);
      rlm_core_sv.dlog(k_DEBUG,'ship_from_org_id' ,v_subgroup_rec.ship_from_org_id);
      rlm_core_sv.dlog(k_DEBUG,'ship_to_org_id' ,v_subgroup_rec.ship_to_address_id);
      rlm_core_sv.dlog(k_DEBUG,'ship_to_site_use_id' ,v_subgroup_rec.ship_to_site_use_id);
      rlm_core_sv.dlog(k_DEBUG,'bill_to_address_id' ,v_subgroup_rec.bill_to_address_id);
      rlm_core_sv.dlog(k_DEBUG,'bill_to_site_use_id' ,v_subgroup_rec.bill_to_site_use_id);
      rlm_core_sv.dlog(k_DEBUG,'customer_item_id' ,v_subgroup_rec.customer_item_id);
      rlm_core_sv.dlog(k_DEBUG,'inventory_item_id' ,v_subgroup_rec.inventory_item_id);
      rlm_core_sv.dlog(k_DEBUG,'industry_attribute15' ,v_subgroup_rec.industry_attribute15);
      --
    END IF;

    RLM_TPA_SV.ManageGroupForecast(x_sched_rec,
                        v_SubGroup_rec,
                        t_forecast,
                        t_designator,
                        x_ReturnStatus);

    IF(x_Sched_rec.schedule_purpose = k_REPLACE_ALL) THEN

      ProcessReplaceAll(x_sched_rec,
                        v_SubGroup_rec,
                        t_designator);

    END IF;  --check for replace_all

  END LOOP;
  --
  CLOSE v_SubGroup_ref;

  IF (l_debug <> -1) THEN
    --
    rlm_core_sv.dlog(k_DEBUG,'before mrp_forecast_interface_pk api');
    --
  END IF;

  IF mrp_forecast_interface_pk.mrp_forecast_interface(t_forecast,
                                                      t_designator) THEN
    IF (l_debug <> -1) THEN
      --
      rlm_core_sv.dlog(k_DEBUG,'after mrp_forecast_interface_pk.
                              mrp_forecast_interface api');
      --
    END IF;

    FOR v_counter IN 1..t_designator.COUNT LOOP

      IF (l_debug <> -1) THEN
        --
        rlm_core_sv.dlog(k_DEBUG,'Inserted new forecast for ', t_designator(v_counter).forecast_designator);
        --
      END IF;
    END LOOP;
    --
    RLM_TPA_SV.ProcessTable(x_Sched_rec, x_Group_rec, t_forecast);

    --
  ELSE
    --
    x_progress :='070';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'MRP Forecast API Failed ');
    END IF;
    --

    FOR v_counter IN 1..t_designator.COUNT LOOP
       --
       v_designator := t_designator(v_counter).forecast_designator;
       --
    END LOOP;
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
           x_MessageName => 'RLM_FORECAST_API_FAILED',
           x_InterfaceHeaderId => x_sched_rec.header_id,
           x_InterfaceLineId => v_InterfaceLineId,
           x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_Token1 => 'GROUP',
           x_value1 => rlm_core_sv.get_ship_from(x_Group_rec.ship_from_org_id)||'-'||
                       rlm_core_sv.get_ship_to(x_Group_rec.ship_to_address_id)||'-'||
                       rlm_core_sv.get_item_number(x_Group_rec.customer_item_id),
           x_Token2 => 'FORECAST_DESIGNATOR',
           x_value2 => v_designator);
    --
    RAISE e_group_error;
    --
  END IF;
  --
  t_forecast.DELETE;
  t_designator.DELETE;
  --
  --x_ReturnStatus := rlm_core_sv.k_PROC_SUCCESS;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_Group_Error THEN
     --
     t_forecast.DELETE;
     t_designator.DELETE;
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
        rlm_core_sv.dpop(k_SDEBUG, 'GROUP ERROR');
     END IF;
     --
  WHEN e_lines_locked THEN
     --
     t_forecast.DELETE;
     t_designator.DELETE;
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
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
           x_MessageName => 'RLM_LOCK_NOT_OBTAINED',
           x_InterfaceHeaderId => x_sched_rec.header_id,
           x_InterfaceLineId => v_InterfaceLineId,
           x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_Token1 => 'SCHED_REF',
           x_value1 => x_sched_rec.schedule_reference_num);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_DEBUG,'lines are locked');
     END IF;
     --
  WHEN NO_DATA_FOUND THEN
      --
     t_forecast.DELETE;
     t_designator.DELETE;
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'No data found in Interface headers for headerId',
                               x_InterfaceHeaderId);
        rlm_core_sv.dpop(k_SDEBUG);
     END IF;
     --
  WHEN e_no_forecast THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'ManageForecast: e_no_forecast');
     END IF;
     --
  WHEN OTHERS THEN
     --
     t_forecast.DELETE;
     t_designator.DELETE;
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     rlm_message_sv.sql_error('rlm_forecast_sv.ManageForecast',x_progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
END ManageForecast;


/*===========================================================================

  PROCEDURE NAME:       ManageGroupForecast

===========================================================================*/
PROCEDURE ManageGroupForecast(x_sched_rec IN  RLM_INTERFACE_HEADERS%ROWTYPE,
                              x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                              x_forecast  IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_interface,
                              x_designator IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_designator,
                              x_ReturnStatus OUT NOCOPY NUMBER)
IS
  --
  v_forecast_designator mrp_forecast_designators.forecast_designator%TYPE;
  x_progress   VARCHAR2(3) := '010';
  v_InterfaceLineId  NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'ManageGroupForecast');
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_id',
                                   x_Group_rec.customer_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id',
                                   x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_site_use_id',
                                   x_Group_rec.ship_to_site_use_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.bill_to_site_use_id',
                                   x_Group_rec.bill_to_site_use_id);
  END IF;
  --
  RLM_TPA_SV.GetDesignator(x_sched_rec,
                x_Group_rec,
                x_Group_rec.customer_id,
                x_Group_rec.ship_from_org_id,
                x_Group_rec.ship_to_site_use_id,
                x_Group_rec.bill_to_site_use_id,
                x_Group_rec.bill_to_address_id,
                v_forecast_designator,
                x_Group_rec.ship_to_customer_id);
  --
  -- Validate the forecast designator as it is not done in
  -- validate demand
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'forecast designator',v_forecast_designator);
     rlm_core_sv.dlog(k_DEBUG,'x_Sched_rec.schedule_purpose',
                            x_Sched_rec.schedule_purpose);
  END IF;
  --
  --
  -- Bug 2766271 - Validate Forecast Designator
  --
  IF v_forecast_designator IS NULL THEN
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG, 'Null Forecast Designator, raising group error');
   END IF;
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
                        x_MessageName => 'RLM_NO_FORECAST_DESIG',
                        x_InterfaceHeaderId => x_Sched_rec.header_id,
                        x_InterfaceLineId => v_InterfaceLineId,
           		x_ScheduleHeaderId => x_Sched_rec.schedule_header_id,
           		x_ScheduleLineId => NULL,
                        x_Token1=>'CUST',
                        x_Value1=> rlm_core_sv.get_customer_name(x_Sched_rec.customer_id));
   --
   RAISE e_Group_Error;
   --
  END IF;
  --
  IF x_Sched_rec.schedule_purpose = k_ADD THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'No Lines in t_designator as schedule purpose = ADD');
     END IF;
     --
  ELSIF x_Sched_rec.schedule_purpose IN (k_CANCEL,
                                            k_DELETE,
                                            k_REPLACE,
                                            k_REPLACE_ALL,
                                            k_ORIGINAL,
                                            k_CHANGE) THEN
    --
    x_designator(x_designator.COUNT + 1).forecast_designator :=
                                                       v_forecast_designator;
    x_designator(x_designator.COUNT).organization_id :=
                                                x_Group_rec.ship_from_org_id;
    x_designator(x_designator.COUNT).inventory_item_id :=
                                               x_Group_rec.inventory_item_id;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'x_designator.forecast_designator',
                          x_designator(x_designator.COUNT).forecast_designator);
       rlm_core_sv.dlog(k_DEBUG,'x_designator.organization_id',
                             x_designator(x_designator.COUNT).organization_id);
       rlm_core_sv.dlog(k_DEBUG,'x_designator.inventory_item_id',
                           x_designator(x_designator.COUNT).inventory_item_id);
    END IF;
    --
  END IF;
  --
  IF x_Sched_rec.schedule_purpose NOT IN (k_CANCEL,k_DELETE) THEN
     --
     RLM_TPA_SV.LoadForecast(x_Sched_rec,
                  x_Group_rec ,
                  x_forecast,
                  v_forecast_designator);
     --
  END IF;
  --
  x_ReturnStatus := rlm_core_sv.k_PROC_SUCCESS;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_DEBUG);
  END IF;
  --
EXCEPTION
  WHEN e_Group_Error THEN
     --
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'ManageGroupForecast : progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG, 'GROUP ERROR');
     END IF;
     --
     RAISE;
     --
  WHEN OTHERS THEN
     --
     x_ReturnStatus := rlm_core_sv.k_PROC_ERROR;
     rlm_message_sv.sql_error('rlm_forecast_sv.ManageForecast',x_progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;
     --
END ManageGroupForecast;

/*===========================================================================

  PROCEDURE InitializeGroup

===========================================================================*/
PROCEDURE InitializeGroup(x_Sched_rec IN rlm_interface_headers%ROWTYPE,
                          x_Group_ref IN OUT NOCOPY rlm_forecast_sv.t_Cursor_ref,
                          x_Group_rec IN rlm_dp_sv.t_Group_rec)
IS
  x_progress          VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'InitializeGroup');
  END IF;
  --
  OPEN x_Group_ref FOR
    SELECT   rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_site_use_id,
             ril.bill_to_address_id,
             ril.bill_to_site_use_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.ship_to_customer_id
    FROM     rlm_interface_headers   rih,
             rlm_interface_lines_all ril
    WHERE    rih.header_id = x_Sched_rec.header_id
    AND      ril.header_id = rih.header_id
    AND      ril.industry_attribute15 = x_Group_rec.ship_from_org_id
    AND      ril.item_detail_type = k_MRP_FORECAST
    AND      ril.inventory_item_id = x_Group_rec.inventory_item_id
    AND      ril.ship_to_address_id = x_Group_rec.ship_to_address_id
    AND      ril.process_status = rlm_core_sv.k_PS_AVAILABLE
    AND      rih.org_id = ril.org_id
    GROUP BY rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_site_use_id,
             ril.bill_to_address_id,
             ril.bill_to_site_use_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.ship_to_customer_id
    ORDER BY
             ril.ship_to_site_use_id,
             ril.bill_to_site_use_id,
             ril.customer_item_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('RLM_FORECAST_SV.InitializeGroup',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise e_group_error;

END InitializeGroup;

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
    x_Group_rec.ship_to_site_use_id,
    x_Group_rec.bill_to_address_id,
    x_Group_rec.bill_to_site_use_id,
    x_Group_rec.customer_item_id,
    x_Group_rec.inventory_item_id,
    x_Group_rec.industry_attribute15,
    x_Group_rec.ship_to_customer_id;
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
      rlm_message_sv.sql_error('rlm_forecast_sv.FetchGroup',x_progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END FetchGroup;

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
     AND   process_status = rlm_core_sv.k_PS_AVAILABLE
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
       rlm_core_sv.dlog(k_DEBUG,'Returning FALSE');
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RETURN FALSE;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_forecast_sv.LockHeaders',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'Returning FALSE from WHEN OTHERS ');
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
  --
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
    rlm_message_sv.sql_error('rlm_forecast_sv.UpdateHeaderStatus',x_progress);
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
FUNCTION LockLines (x_Group_rec         IN    rlm_dp_sv.t_Group_rec,
                    x_header_id         IN     NUMBER)
RETURN BOOLEAN
IS
   x_progress      VARCHAR2(3) := '010';

   CURSOR c IS
     SELECT *
     FROM   rlm_interface_lines_all
     WHERE  header_id  = x_header_id
     AND    ship_from_org_id = x_Group_rec.ship_from_org_id
     AND    ship_to_site_use_id = x_Group_rec.ship_to_site_use_id
     AND    bill_to_site_use_id = x_Group_rec.bill_to_site_use_id
     AND    customer_item_id = x_Group_rec.customer_item_id
     AND    inventory_item_id = x_Group_rec.inventory_item_id
     AND    process_status = rlm_core_sv.k_PS_AVAILABLE
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
       rlm_core_sv.dlog(k_DEBUG,'Returning FALSE');
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RETURN FALSE;

  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_forecast_sv.LockLines',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'Returning FALSE OTHERS ');
       rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RETURN FALSE;

END LockLines;
/*===========================================================================

  FUNCTION  UpdateGroupStatus

===========================================================================*/
PROCEDURE UpdateGroupStatus( x_header_id         IN  NUMBER,
                             x_ScheduleHeaderId  IN  NUMBER,
                             x_Group_rec         IN  rlm_dp_sv.t_Group_rec,
                             x_status            IN  NUMBER,
                             x_UpdateLevel       IN  VARCHAR2)
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
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_site_use_id ',
                                   x_Group_rec.ship_to_site_use_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.bill_to_site_use_id ',
                                   x_Group_rec.bill_to_site_use_id);
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
     AND process_status = rlm_core_sv.k_PS_AVAILABLE
     AND Item_detail_type = k_MRP_FORECAST;
     --
     UPDATE rlm_schedule_lines
     SET    process_status = x_Status
     WHERE  header_id  = x_ScheduleHeaderid
     AND    process_status in (rlm_core_sv.k_PS_AVAILABLE,
                               rlm_core_sv.k_PS_ERROR)
     AND    item_detail_type = k_MRP_FORECAST;
     --
  ELSE
     --
     UPDATE rlm_schedule_lines_all
     SET    process_status = x_Status
     WHERE  header_id  = x_ScheduleheaderId
     AND    ship_from_org_id = x_Group_rec.ship_from_org_id
     AND    nvl(ship_to_site_use_id,k_NNULL)
                    = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
     AND    nvl(bill_to_site_use_id,k_NNULL)
                    = nvl(x_Group_rec.bill_to_site_use_id,k_NNULL)
     AND    inventory_item_id = x_Group_rec.inventory_item_id
     AND    process_status  IN (rlm_core_sv.k_PS_AVAILABLE,
                                rlm_core_sv.k_PS_ERROR)
     AND    line_id IN ( select schedule_line_id
                         from   rlm_interface_lines
                         WHERE  header_id  = x_header_id
                         AND    ship_from_org_id = x_Group_rec.ship_from_org_id
                         AND    nvl(ship_to_site_use_id,k_NNULL)
                               = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
                         AND    nvl(bill_to_site_use_id,k_NNULL)
                                = nvl(x_Group_rec.bill_to_site_use_id,k_NNULL)
                         AND   inventory_item_id = x_Group_rec.inventory_item_id
                         AND    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                                         rlm_core_sv.k_PS_ERROR)
                         AND    item_detail_type = k_MRP_FORECAST);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'No of Schedule Lines Updated ', SQL%ROWCOUNT);
     END IF;
     --
     UPDATE rlm_interface_lines
     SET    process_status = x_Status
     WHERE  header_id  = x_header_id
     AND    ship_from_org_id = x_Group_rec.ship_from_org_id
     AND    nvl(ship_to_site_use_id,k_NNULL)
                    = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
     AND    nvl(bill_to_site_use_id,k_NNULL)
                    = nvl(x_Group_rec.bill_to_site_use_id,k_NNULL)
     AND    inventory_item_id = x_Group_rec.inventory_item_id
     AND    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                               rlm_core_sv.k_PS_ERROR)
     AND    item_detail_type = k_MRP_FORECAST;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'No of interface Lines Updated ', SQL%ROWCOUNT);
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
    rlm_message_sv.sql_error('rlm_forecast_sv.UpdateGroupStatus',x_progress);
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

  PROCEDURE NAME:       initialize_table

===========================================================================*/

PROCEDURE initialize_table(
           t_forecast IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_interface)
IS
  --
  x_progress number  :='010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'initialize_table');
  END IF;
  --
  t_forecast.DELETE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
     rlm_message_sv.sql_error ('RLM_forecast_sv.initialize_table', x_progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHERS - sql error');
     END IF;
     --
     raise;

END initialize_table;

/*===========================================================================

  PROCEDURE NAME:       LoadForecast

===========================================================================*/

PROCEDURE LoadForecast(
             x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
             x_Group_rec IN rlm_dp_sv.t_Group_rec,
             t_forecast IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_interface,
             x_forecast_designator IN
                 mrp_forecast_designators.forecast_designator%TYPE)
IS


   --
    CURSOR C IS
        SELECT  ril.inventory_item_id     inventory_item_id,
                ril.ship_from_org_id      organization_id,
                ril.request_date          forecast_date,
                ril.primary_quantity      quantity,
                ril.uom_code              uom_code,         -- Bug 4176961
                ril.primary_uom_code      primary_uom_code, -- Bug 4176961
                ril.item_detail_subtype   bucket_type,
                ril.line_id               demand_stream_id,
                ril.industry_attribute1   attribute01,
                ril.industry_attribute2   attribute02,
                ril.industry_attribute3   attribute03,
                ril.industry_attribute4   attribute04,
                ril.industry_attribute5   attribute05,
                ril.industry_attribute6   attribute06,
                ril.industry_attribute7   attribute07,
                ril.industry_attribute8   attribute08,
                ril.industry_attribute9   attribute09,
                ril.industry_attribute10  attribute10,
                ril.industry_attribute11  attribute11,
                ril.industry_attribute12  attribute12,
                ril.industry_attribute13  attribute13,
                ril.industry_attribute14  attribute14,
                ril.industry_attribute15  attribute15
        FROM    rlm_interface_lines ril
        WHERE   ril.ship_from_org_id    = x_Group_rec.ship_from_org_id
        AND     ril.header_id           = x_Sched_rec.header_id
        AND     nvl(ril.ship_to_site_use_id ,k_NNULL)
                            = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
        AND     ril.bill_to_site_use_id IS NULL
        AND     ril.inventory_item_id   = x_Group_rec.inventory_item_id
        AND     ril.customer_item_id    = x_Group_rec.customer_item_id
        AND     ril.item_detail_type    = k_MRP_FORECAST
        AND     ril.process_status      = rlm_core_sv.k_PS_AVAILABLE
        AND     ril.request_date is NOT NULL --bug 2882311
        AND     ril.primary_quantity    <> 0
        --bug 1786492

        UNION

        SELECT  ril.inventory_item_id     inventory_item_id,
                ril.ship_from_org_id      organization_id,
                ril.request_date          forecast_date,
                ril.primary_quantity      quantity,
                ril.uom_code              uom_code,         -- Bug 4176961
                ril.primary_uom_code      primary_uom_code, -- Bug 4176961
                ril.item_detail_subtype   bucket_type,
                ril.line_id               demand_stream_id,
                ril.industry_attribute1   attribute01,
                ril.industry_attribute2   attribute02,
                ril.industry_attribute3   attribute03,
                ril.industry_attribute4   attribute04,
                ril.industry_attribute5   attribute05,
                ril.industry_attribute6   attribute06,
                ril.industry_attribute7   attribute07,
                ril.industry_attribute8   attribute08,
                ril.industry_attribute9   attribute09,
                ril.industry_attribute10  attribute10,
                ril.industry_attribute11  attribute11,
                ril.industry_attribute12  attribute12,
                ril.industry_attribute13  attribute13,
                ril.industry_attribute14  attribute14,
                ril.industry_attribute15  attribute15
        FROM    rlm_interface_lines ril
        WHERE   ril.ship_from_org_id    = x_Group_rec.ship_from_org_id
        AND     ril.header_id           = x_Sched_rec.header_id
        AND     nvl(ril.ship_to_site_use_id ,k_NNULL)
                            = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
        AND     ril.bill_to_site_use_id IS NULL
        AND     ril.inventory_item_id   = x_Group_rec.inventory_item_id
        AND     ril.item_detail_type    = k_MRP_FORECAST
        AND     ril.process_status      = rlm_core_sv.k_PS_PROCESSED
        AND     ril.primary_quantity    <> 0;


    CURSOR C_bill IS
        SELECT  ril.inventory_item_id     inventory_item_id,
                ril.ship_from_org_id      organization_id,
                ril.request_date          forecast_date,
                ril.primary_quantity      quantity,
                ril.uom_code              uom_code,         -- Bug 4176961
                ril.primary_uom_code      primary_uom_code, -- Bug 4176961
                ril.item_detail_subtype   bucket_type,
                ril.line_id               demand_stream_id,
                ril.industry_attribute1   attribute01,
                ril.industry_attribute2   attribute02,
                ril.industry_attribute3   attribute03,
                ril.industry_attribute4   attribute04,
                ril.industry_attribute5   attribute05,
                ril.industry_attribute6   attribute06,
                ril.industry_attribute7   attribute07,
                ril.industry_attribute8   attribute08,
                ril.industry_attribute9   attribute09,
                ril.industry_attribute10  attribute10,
                ril.industry_attribute11  attribute11,
                ril.industry_attribute12  attribute12,
                ril.industry_attribute13  attribute13,
                ril.industry_attribute14  attribute14,
                ril.industry_attribute15  attribute15
        FROM    rlm_interface_lines ril
        WHERE   ril.ship_from_org_id    = x_Group_rec.ship_from_org_id
        AND     ril.header_id           = x_Sched_rec.header_id
        AND     nvl(ril.ship_to_site_use_id ,k_NNULL)
                            = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
        AND     bill_to_site_use_id     = x_Group_rec.bill_to_site_use_id
        AND     ril.inventory_item_id   = x_Group_rec.inventory_item_id
        AND     ril.customer_item_id    = x_Group_rec.customer_item_id
        AND     ril.item_detail_type    = k_MRP_FORECAST
        AND     ril.process_status      = rlm_core_sv.k_PS_AVAILABLE
        AND     ril.request_date is NOT NULL --bug 2882311
        AND     ril.primary_quantity    <> 0
        --bug 1786492

        UNION

        SELECT  ril.inventory_item_id     inventory_item_id,
                ril.ship_from_org_id      organization_id,
                ril.request_date          forecast_date,
                ril.primary_quantity      quantity,
                ril.uom_code              uom_code,         -- Bug 4176961
                ril.primary_uom_code      primary_uom_code, -- Bug 4176961
                ril.item_detail_subtype   bucket_type,
                ril.line_id               demand_stream_id,
                ril.industry_attribute1   attribute01,
                ril.industry_attribute2   attribute02,
                ril.industry_attribute3   attribute03,
                ril.industry_attribute4   attribute04,
                ril.industry_attribute5   attribute05,
                ril.industry_attribute6   attribute06,
                ril.industry_attribute7   attribute07,
                ril.industry_attribute8   attribute08,
                ril.industry_attribute9   attribute09,
                ril.industry_attribute10  attribute10,
                ril.industry_attribute11  attribute11,
                ril.industry_attribute12  attribute12,
                ril.industry_attribute13  attribute13,
                ril.industry_attribute14  attribute14,
                ril.industry_attribute15  attribute15
        FROM    rlm_interface_lines ril
        WHERE   ril.ship_from_org_id    = x_Group_rec.ship_from_org_id
        AND     ril.header_id           = x_Sched_rec.header_id
        AND     nvl(ril.ship_to_site_use_id ,k_NNULL)
                            = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
        AND     bill_to_site_use_id     = x_Group_rec.bill_to_site_use_id
        AND     ril.inventory_item_id   = x_Group_rec.inventory_item_id
        AND     ril.item_detail_type    = k_MRP_FORECAST
        AND     ril.process_status      = rlm_core_sv.k_PS_PROCESSED
        AND     ril.primary_quantity    <> 0;

    --
    Recinfo C%ROWTYPE;
    --
    index_cnt   number ;
    --
    x_progress number  :='010';
    --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'LoadForecast');
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_from_org_id',
                            x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.bill_to_site_use_id',
                            x_Group_rec.bill_to_site_use_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.ship_to_site_use_id',
                            x_Group_rec.ship_to_site_use_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.customer_id',
                            x_Group_rec.customer_id);
     rlm_core_sv.dlog(k_DEBUG,'x_Group_rec.inventory_item_id',
                            x_Group_rec.inventory_item_id);
     rlm_core_sv.dlog(k_DEBUG,'x_forecast_designator',
                            x_forecast_designator);
     rlm_core_sv.dlog(k_DEBUG,'k_MRP_FORECAST',
                            k_MRP_FORECAST);
     rlm_core_sv.dlog(k_DEBUG,'rlm_core_sv.k_PS_AVAILABLE',
                            rlm_core_sv.k_PS_AVAILABLE);
  END IF;
  --
/*==============================================================================
=======
                          Loading Records in PL/SQL Table
================================================================================
=====*/

  IF(x_Group_rec.bill_to_site_use_id IS NULL) THEN
    --
    FOR  Recinfo in C
      LOOP
        /* Bug 4176961 : Start */
        IF (RLM_VALIDATEDEMAND_SV.g_convert_uom) THEN
            --
            IF (nvl(Recinfo.uom_code,'-99') <> nvl(Recinfo.primary_uom_code,'99')) THEN
                --
                IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'Recinfo.uom_code',Recinfo.uom_code);
                    rlm_core_sv.dlog(k_DEBUG,'Recinfo.primary_uom_code',Recinfo.primary_uom_code);
                    rlm_core_sv.dlog(k_DEBUG,'Before conversion: Recinfo.quantity',Recinfo.quantity);
                END IF;
                --
                Convert_UOM (Recinfo.uom_code,
                             Recinfo.primary_uom_code,
                             Recinfo.quantity,
                             Recinfo.inventory_item_id,
                             Recinfo.organization_id);
                --
                IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'After conversion: Recinfo.quantity',Recinfo.quantity);
                END IF;
                --
            END IF;
            --
        END IF;
        /* Bug 4176961 : End */
        --
        index_cnt := t_forecast.COUNT + 1;
        t_forecast(index_cnt).inventory_item_id := Recinfo.inventory_item_id;
        t_forecast(index_cnt).forecast_designator :=x_forecast_designator;
        t_forecast(index_cnt).organization_id :=Recinfo.organization_id;
        t_forecast(index_cnt).forecast_date :=Recinfo.forecast_date;
        t_forecast(index_cnt).last_update_date :=sysdate;
        t_forecast(index_cnt).creation_date :=sysdate;
        t_forecast(index_cnt).created_by := fnd_global.user_id;
        t_forecast(index_cnt).last_update_login := fnd_global.login_id;
        t_forecast(index_cnt).quantity :=Recinfo.quantity;
        t_forecast(index_cnt).process_status :=2;
        t_forecast(index_cnt).confidence_percentage :=100;
        t_forecast(index_cnt).comments :=null;
        t_forecast(index_cnt).error_message :=null;
        t_forecast(index_cnt).request_id :=null;
        t_forecast(index_cnt).program_application_id :=null;
        t_forecast(index_cnt).program_id :=null;
        t_forecast(index_cnt).program_update_date :=null;
        t_forecast(index_cnt).workday_control :=3;
        t_forecast(index_cnt).bucket_type :=Recinfo.bucket_type;
        t_forecast(index_cnt).forecast_end_date :=null;
        t_forecast(index_cnt).transaction_id :=null;
        t_forecast(index_cnt).source_code :='RLM';
        t_forecast(index_cnt).source_line_id :=Recinfo.demand_stream_id;
        t_forecast(index_cnt).attribute1  :=Recinfo.attribute01;
        t_forecast(index_cnt).attribute2  :=Recinfo.attribute02;
        t_forecast(index_cnt).attribute3  :=Recinfo.attribute03;
        t_forecast(index_cnt).attribute4  :=Recinfo.attribute04;
        t_forecast(index_cnt).attribute5  :=Recinfo.attribute05;
        t_forecast(index_cnt).attribute6  :=Recinfo.attribute06;
        t_forecast(index_cnt).attribute7  :=Recinfo.attribute07;
        t_forecast(index_cnt).attribute8  :=Recinfo.attribute08;
        t_forecast(index_cnt).attribute9  :=Recinfo.attribute09;
        t_forecast(index_cnt).attribute10 :=Recinfo.attribute10;
        t_forecast(index_cnt).attribute11 :=Recinfo.attribute11;
        t_forecast(index_cnt).attribute12 :=Recinfo.attribute12;
        t_forecast(index_cnt).attribute13 :=Recinfo.attribute13;
        t_forecast(index_cnt).attribute14 :=Recinfo.attribute14;
        t_forecast(index_cnt).attribute15 :=Recinfo.attribute15;
        t_forecast(index_cnt).project_id  :=NULL;
        t_forecast(index_cnt).task_id :=NULL;
        t_forecast(index_cnt).line_id :=NULL;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').source_line_id',
                                  t_forecast(index_cnt).source_line_id);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').inventory_item_id',
                                  t_forecast(index_cnt).inventory_item_id);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').forecast_designator',
                                  t_forecast(index_cnt).forecast_designator);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').organization_id',
                                  t_forecast(index_cnt).organization_id);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').forecast_date',
                                  t_forecast(index_cnt).forecast_date);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').quantity',
                                  t_forecast(index_cnt).quantity);
        END IF;
        --
    END LOOP;

  ELSE
    --
    FOR  Recinfo in C_bill
      LOOP
        /* Bug 4176961 : Start */
        IF (RLM_VALIDATEDEMAND_SV.g_convert_uom) THEN
            --
            IF (nvl(Recinfo.uom_code,'-99') <> nvl(Recinfo.primary_uom_code,'99')) THEN
                --
   	        IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'Recinfo.uom_code',Recinfo.uom_code);
                    rlm_core_sv.dlog(k_DEBUG,'Recinfo.primary_uom_code',Recinfo.primary_uom_code);
                    rlm_core_sv.dlog(k_DEBUG,'Before conversion: Recinfo.quantity',Recinfo.quantity);
                END IF;
                --
                Convert_UOM (Recinfo.uom_code,
                             Recinfo.primary_uom_code,
                             Recinfo.quantity,
                             Recinfo.inventory_item_id,
                             Recinfo.organization_id);
                --
                IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(k_DEBUG,'After conversion: Recinfo.quantity',Recinfo.quantity);
                END IF;
                --
            END IF;
            --
         END IF;
        /* Bug 4176961 : End */
        --
        index_cnt := t_forecast.COUNT + 1;
        t_forecast(index_cnt).inventory_item_id := Recinfo.inventory_item_id;
        t_forecast(index_cnt).forecast_designator :=x_forecast_designator;
        t_forecast(index_cnt).organization_id :=Recinfo.organization_id;
        t_forecast(index_cnt).forecast_date :=Recinfo.forecast_date;
        t_forecast(index_cnt).last_update_date :=sysdate;
        t_forecast(index_cnt).creation_date :=sysdate;
        t_forecast(index_cnt).created_by := fnd_global.user_id;
        t_forecast(index_cnt).last_update_login := fnd_global.login_id;
        t_forecast(index_cnt).quantity :=Recinfo.quantity;
        t_forecast(index_cnt).process_status :=2;
        t_forecast(index_cnt).confidence_percentage :=100;
        t_forecast(index_cnt).comments :=null;
        t_forecast(index_cnt).error_message :=null;
        t_forecast(index_cnt).request_id :=null;
        t_forecast(index_cnt).program_application_id :=null;
        t_forecast(index_cnt).program_id :=null;
        t_forecast(index_cnt).program_update_date :=null;
        t_forecast(index_cnt).workday_control :=3;
        t_forecast(index_cnt).bucket_type :=Recinfo.bucket_type;
        t_forecast(index_cnt).forecast_end_date :=null;
        t_forecast(index_cnt).transaction_id :=null;
        t_forecast(index_cnt).source_code :='RLM';
        t_forecast(index_cnt).source_line_id :=Recinfo.demand_stream_id;
        t_forecast(index_cnt).attribute1  :=Recinfo.attribute01;
        t_forecast(index_cnt).attribute2  :=Recinfo.attribute02;
        t_forecast(index_cnt).attribute3  :=Recinfo.attribute03;
        t_forecast(index_cnt).attribute4  :=Recinfo.attribute04;
        t_forecast(index_cnt).attribute5  :=Recinfo.attribute05;
        t_forecast(index_cnt).attribute6  :=Recinfo.attribute06;
        t_forecast(index_cnt).attribute7  :=Recinfo.attribute07;
        t_forecast(index_cnt).attribute8  :=Recinfo.attribute08;
        t_forecast(index_cnt).attribute9  :=Recinfo.attribute09;
        t_forecast(index_cnt).attribute10 :=Recinfo.attribute10;
        t_forecast(index_cnt).attribute11 :=Recinfo.attribute11;
        t_forecast(index_cnt).attribute12 :=Recinfo.attribute12;
        t_forecast(index_cnt).attribute13 :=Recinfo.attribute13;
        t_forecast(index_cnt).attribute14 :=Recinfo.attribute14;
        t_forecast(index_cnt).attribute15 :=Recinfo.attribute15;
        t_forecast(index_cnt).project_id  :=NULL;
        t_forecast(index_cnt).task_id :=NULL;
        t_forecast(index_cnt).line_id :=NULL;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').source_line_id',
                                  t_forecast(index_cnt).source_line_id);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').inventory_item_id',
                                  t_forecast(index_cnt).inventory_item_id);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').forecast_designator',
                                  t_forecast(index_cnt).forecast_designator);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').organization_id',
                                  t_forecast(index_cnt).organization_id);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').forecast_date',
                                  t_forecast(index_cnt).forecast_date);
           rlm_core_sv.dlog(k_DEBUG,'t_forecast(' || index_cnt || ').quantity',
                                  t_forecast(index_cnt).quantity);
        END IF;
        --
    END LOOP;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'COUNT',index_cnt);
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
/* Bug 4176961 : UOM conversion */
 WHEN e_Group_Error THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
        rlm_core_sv.dpop(k_SDEBUG, 'GROUP ERROR');
    END IF;
    --
    raise;

 WHEN OTHERS THEN
    rlm_message_sv.sql_error ('RLM_forecast_sv.LoadForecast', x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHERS - sql error');
    END IF;
    --
    raise;

END LoadForecast;

/*===========================================================================

  PROCEDURE NAME: process_table

===========================================================================*/

PROCEDURE ProcessTable(
              x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
              x_Group_rec IN rlm_dp_sv.t_Group_rec,
              t_Forecast IN mrp_forecast_interface_pk.t_forecast_interface)
IS

  v_Result                      NUMBER;
  v_ProcessStatus               NUMBER := 5;
  x_Progress            VARCHAR2(3) := '010';
  --
  v_line_error                  BOOLEAN;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(k_SDEBUG,'process_table');
  END IF;
  --
  v_line_error := FALSE;
  --
  FOR v_Count IN 1..t_Forecast.COUNT LOOP
    --
    x_Progress := '020';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'process status of forecast lines',
                              t_Forecast(v_Count).process_status);
    END IF;
    --
    IF t_Forecast(v_Count).process_status = 4 THEN
      --
      x_Progress := '030';
      v_line_error := TRUE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG,'RLM_FORECAST_FAILED',
                              t_Forecast(v_Count).error_message);
      END IF;
      --
      rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_error_level,
           x_MessageName => 'RLM_FORECAST_FAILED',
           x_InterfaceHeaderId => x_sched_rec.header_id,
           x_InterfaceLineId => t_forecast(v_Count).source_line_id,
           x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_Token1 => 'MESSAGE_TEXT',
           x_value1 => t_Forecast(v_Count).error_message,
           x_Token2 => 'QUANTITY',
           x_value2 => t_Forecast(v_Count).quantity,
           x_Token3 => 'GROUP',
           x_value3 => rlm_core_sv.get_ship_from(x_Group_rec.ship_from_org_id)||'-'||
                       rlm_core_sv.get_ship_to(x_Group_rec.ship_to_address_id)||'-'||
                       rlm_core_sv.get_item_number(x_Group_rec.customer_item_id),
           x_Token4 => 'REQ_DATE',
           x_value4 => t_Forecast(v_Count).forecast_date,
           x_Token5 => 'START_DATE_TIME',
           x_value5 => to_date(t_Forecast(v_Count).attribute2,'YYYY/MM/DD HH24:MI:SS'),
           x_Token6 => 'FORECAST_DESIGNATOR',
           x_value6 => t_Forecast(v_Count).forecast_designator);
      --
      x_Progress := '040';
      --
    END IF;
    --
  END LOOP;
  --
  x_Progress := '050';
  --
  -- Bug 4716501 : Even if one MRP line is in error status, DSP should fail the
  -- entire group.
  --
  IF v_line_error THEN
   --{
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG, 'At least one MRP line is in error, so fail entire group');
   END IF;
   --
   RAISE e_Group_error;
   --}
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_Group_error THEN
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(k_DEBUG, 'x_Progress', x_Progress);
    rlm_core_sv.dpop(k_SDEBUG, 'e_Group_error');
   END IF;
   --
   RAISE;
   --
  WHEN OTHERS THEN
    rlm_message_sv.sql_error ('RLM_forecast_sv.process_table', x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: OTHERS - sql error');
    END IF;
    --
    raise;

END ProcessTable;

/*=============================================================================
   PROCEDURE NAME:      get_designator
   PURPOSE:             Fetches the matching forecast designator
==============================================================================*/
PROCEDURE GetDesignator( x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE DEFAULT NULL,
                         x_Group_rec IN rlm_dp_sv.t_Group_rec DEFAULT NULL,
                         x_Customer_id   IN NUMBER,
                         x_ShipFromOrgId IN NUMBER,
                         x_Ship_Site_Id IN NUMBER,
                         x_bill_site_id IN NUMBER,
                         x_bill_address_Id IN NUMBER,
                         x_ForecastDesignator IN OUT NOCOPY VARCHAR2,
                         x_ship_to_customer_id IN NUMBER)
IS

  v_progress  VARCHAR2(3) := '010';
  v_bill_site_id  NUMBER;
  v_bill_address_id  NUMBER;
  v_ListName  VARCHAR2(30);
  v_ListNametmp  VARCHAR2(30);

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(K_SDEBUG, 'GetDesignator');
     rlm_core_sv.dlog(k_DEBUG, 'customer_id',x_customer_id);
     rlm_core_sv.dlog(k_DEBUG, 'x_ship_to_customer_id',x_ship_to_customer_id);
     rlm_core_sv.dlog(k_DEBUG, 'ship_from_org_id',x_ShipFromOrgId);
     rlm_core_sv.dlog(k_DEBUG, 'x_Ship_Site_Id',x_Ship_Site_Id);
     rlm_core_sv.dlog(k_DEBUG, 'x_bill_site_id',x_bill_site_id);
     rlm_core_sv.dlog(k_DEBUG, 'x_bill_address_Id',x_bill_address_Id);
  END IF;

--Bugfix 8326871 Start

  IF g_MRP_ListName IS NULL THEN
     fnd_profile.get('RLM_SELECTION_LIST',v_ListName);
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'v_ListName',v_ListName);
       END IF;
     g_MRP_ListName := v_ListName;
  ELSE
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG,'g_MRP_ListName',g_MRP_ListName);
       END IF;
     v_ListName := g_MRP_ListName;
  END IF;

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'Profile: RLM_SELECTION_LIST',v_ListName);
  END IF;
  --
--Bugfix 8326871 End
  --
  v_listNameTmp := v_ListName;
  --
  BEGIN
    --
    SELECT SUBSTR(v_ListName,1,INSTR(v_ListName,',')-1)
    INTO v_ListName
    FROM DUAL;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(k_DEBUG, 'error getting selection list',
                           SUBSTR(SQLERRM,1,200));
       END IF;
    --
  END;
  --
  IF v_listName IS NULL THEN
     v_ListName := V_ListNameTmp;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'v_ListName',v_ListName);
  END IF;
  --
  IF (x_bill_site_id IS NOT NULL) THEN
      --
      -- Following query is changed as per TCA obsolescence project.
      SELECT    CUST_SITE.CUST_ACCT_SITE_ID
      INTO  	v_bill_address_Id
      FROM  	HZ_CUST_ACCT_SITES    ACCT_SITE ,
		HZ_CUST_SITE_USES_ALL CUST_SITE
      WHERE 	CUST_SITE.site_use_id = x_bill_site_id
      AND   	CUST_SITE.site_use_code =  'BILL_TO'
      AND   	CUST_SITE.status = 'A'
      AND   	CUST_SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
      AND   	ACCT_SITE.status = 'A'
      AND       CUST_SITE.org_id = ACCT_SITE.org_id;
      --
      v_bill_Site_Id := x_bill_site_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'v_bill_address_Id',v_bill_address_Id);
      END IF;
      --
  ELSIF (x_bill_address_id IS NOT NULL) THEN
      --
      -- Following query is changed as per TCA obsolescence project.
      SELECT	CUST_SITE.SITE_USE_ID
      INTO	v_bill_site_id
      FROM	HZ_CUST_ACCT_SITES    ACCT_SITE ,
		HZ_CUST_SITE_USES_ALL CUST_SITE
      WHERE	CUST_SITE.CUST_ACCT_SITE_ID = x_bill_address_id
      AND	CUST_SITE.site_use_code =  'BILL_TO'
      AND	CUST_SITE.status = 'A'
      AND	CUST_SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
      AND	ACCT_SITE.status = 'A'
      AND       CUST_SITE.org_id = ACCT_SITE.org_id;
      --
      v_bill_address_Id := x_bill_address_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'v_bill_Site_Id',v_bill_Site_Id);
      END IF;
      --
  ELSE
      --
      v_bill_address_Id := null;
      v_bill_Site_Id := null;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'v_bill_address_Id',v_bill_address_Id);
         rlm_core_sv.dlog(k_DEBUG, 'v_bill_Site_Id',v_bill_Site_Id);
      END IF;
      --
  END IF;
  --
  SELECT forecast_designator
  INTO x_ForecastDesignator
  FROM mrp_forecast_designators
  WHERE customer_id=NVL(x_ship_to_customer_id, x_customer_id)
  AND (bill_id = v_bill_site_id
  OR (bill_id IS NULL AND v_bill_site_id IS NULL))
  AND (ship_id = x_Ship_Site_Id
  OR (ship_id IS NULL AND x_Ship_Site_Id IS NULL))
  AND (organization_id = x_ShipFromOrgId
  OR (organization_id IS NULL AND x_ShipFromOrgId IS NULL))
  AND forecast_designator IN
                           (SELECT   source_forecast_designator
                            FROM     mrp_load_parameters
                            WHERE    source_organization_id = x_ShipFromOrgId
                            AND      selection_list_type = 2
                            AND      selection_list_name = v_ListName);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG, 'No of rows for forecast designator',SQL%ROWCOUNT);
     rlm_core_sv.dlog(k_DEBUG, 'x_ForecastDesignator',x_ForecastDesignator);
     rlm_core_sv.dpop(K_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    BEGIN
      /* To make match only at ShipTo level,additional check for NULL bill_id */
      --
      SELECT forecast_designator
      INTO   x_ForecastDesignator
      FROM   mrp_forecast_designators
      WHERE  customer_id= nvl(x_ship_to_customer_id, x_customer_id)
      AND    ship_id = x_Ship_Site_Id
      AND    bill_id IS NULL
      AND    organization_id = x_ShipFromOrgId
      AND    forecast_designator IN
                      (SELECT   source_forecast_designator
                       FROM     mrp_load_parameters
                       WHERE    source_organization_id = x_ShipFromOrgId
                       AND      selection_list_type = 2
                       AND      selection_list_name = v_ListName);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'No of rows for forecast designator at CT/ST',SQL%ROWCOUNT);
         rlm_core_sv.dlog(k_DEBUG, 'x_ForecastDesignator',x_ForecastDesignator);
         rlm_core_sv.dpop(K_SDEBUG);
      END IF;
      --
    EXCEPTION
      --
/*2328087*/
      WHEN NO_DATA_FOUND THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(k_DEBUG, 'No data found for forecast designator at ShiptoCT/ST',SQL%ROWCOUNT);
        END IF;
        --
     	BEGIN
          --
   	  SELECT forecast_designator
      	  INTO   x_ForecastDesignator
      	  FROM   mrp_forecast_designators
      	  WHERE  customer_id= nvl(x_ship_to_customer_id, x_customer_id)
      	  AND    ship_id IS NULL
      	  AND    bill_id IS NULL
      	  AND    organization_id = x_ShipFromOrgId
      	  AND    forecast_designator IN
                      (SELECT   source_forecast_designator
                       FROM     mrp_load_parameters
                       WHERE    source_organization_id = x_ShipFromOrgId
                       AND      selection_list_type = 2
                       AND      selection_list_name = v_ListName);
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(k_DEBUG, 'No of rows for forecast designator at CT',SQL%ROWCOUNT);
             rlm_core_sv.dlog(k_DEBUG, 'x_ForecastDesignator',x_ForecastDesignator);
             rlm_core_sv.dpop(K_SDEBUG);
          END IF;
          --
     	 EXCEPTION
             --
       	   WHEN NO_DATA_FOUND THEN
              --
              IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(k_DEBUG, 'No forecast designator for ship to
customer',SQL%ROWCOUNT);
              END IF;
              --
              IF x_ship_to_customer_id is NULL OR
                 x_ship_to_customer_id =  x_customer_id THEN
                 --
                 x_ForecastDesignator := NULL;
                 --
                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dpop(K_SDEBUG);
                 END IF;
                 --
             ELSE
                --
                BEGIN
                --{
                    SELECT forecast_designator
                    INTO   x_ForecastDesignator
                    FROM   mrp_forecast_designators
                    WHERE  customer_id= x_customer_id
                    AND    ship_id IS NULL
                    AND    bill_id IS NULL
                    AND    organization_id = x_ShipFromOrgId
                    AND    forecast_designator IN
                         (SELECT   source_forecast_designator
                          FROM     mrp_load_parameters
                          WHERE    source_organization_id = x_ShipFromOrgId
                          AND      selection_list_type = 2
                          AND      selection_list_name = v_ListName);
                      --
                   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(k_DEBUG, 'No of rows for forecast designator at CT',SQL%ROWCOUNT);
                      rlm_core_sv.dlog(k_DEBUG, 'x_ForecastDesignator',x_ForecastDesignator);
rlm_core_sv.dpop(K_SDEBUG);
                   END IF;
                   --
                EXCEPTION
                    --
                    WHEN NO_DATA_FOUND THEN
                         --
                         x_ForecastDesignator := NULL;
                         --
                         IF (l_debug <> -1) THEN
                            rlm_core_sv.dpop(K_SDEBUG, 'No forecast Designator found for header level customer');
                         END IF;
                         --
                   WHEN TOO_MANY_ROWS THEN
                         --
                         x_ForecastDesignator := NULL;
                         --
                         IF (l_debug <> -1) THEN
rlm_core_sv.dpop(K_SDEBUG, 'Too many rows found for
header level customer');
                         END IF;
                         --
                END;
                --}
             END IF;
             --
      	   WHEN TOO_MANY_ROWS THEN
              --
              x_ForecastDesignator := NULL;
	      --
	      IF (l_debug <> -1) THEN
                 rlm_core_sv.dpop(K_SDEBUG, 'Too many rows');
              END IF;
      	      --
    	 END;
         --
      WHEN TOO_MANY_ROWS THEN
         --
         x_ForecastDesignator := NULL;
	 --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dpop(K_SDEBUG, 'Too many rows');
         END IF;
         --
      END;
      --
  WHEN TOO_MANY_ROWS THEN
    --
    x_ForecastDesignator := NULL;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(K_SDEBUG, 'Too many rows');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_ForecastDesignator := NULL;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(K_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
  --
END GetDesignator;



/*=============================================================================
   PROCEDURE NAME:      emptyforecast
   PURPOSE:             Deletes all the forecast for a designator
==============================================================================*/
PROCEDURE EmptyForecast( x_sched_rec IN  RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_Group_rec IN  OUT NOCOPY rlm_dp_sv.t_Group_rec,
                         x_forecast  IN  OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_interface,
                         x_designator IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_designator,
                         x_t_designator IN OUT NOCOPY
                                mrp_forecast_interface_pk.t_forecast_designator)
IS
  --
  x_progress           VARCHAR2(3) := '010';
  v_InterfaceLineId    NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(K_SDEBUG, 'EmptyForecast');
  END IF;

  --empty all the forecast lines for the designator
  x_designator(1).inventory_item_id := NULL;
  x_designator(1).forecast_designator := x_t_designator(x_t_designator.COUNT).forecast_designator;
  x_designator(1).organization_id:=x_t_designator(x_t_designator.COUNT).organization_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(k_DEBUG,'before mrp_forecast_interface_pk api for REPLACE');
  END IF;
  --
  IF mrp_forecast_interface_pk.mrp_forecast_interface(x_forecast,
                                                      x_designator) THEN
    --
    g_designator_tab(g_designator_tab.count+1).designator :=
			x_t_designator(x_t_designator.COUNT).forecast_designator;
    g_designator_tab(g_designator_tab.count+1).organization_id :=
                        x_t_designator(x_t_designator.COUNT).organization_id;  --Bugfix 6817494
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'after mrp_forecast_interface_pk.mrp_forecast_interface api for REPLACE');
       rlm_core_sv.dlog(k_DEBUG,'Old forecast deleted for ', x_designator(1).forecast_designator);
    END IF;

  ELSE
    --
    x_progress :='060';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'MRP Forecast API Failed ');
    END IF;
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
             x_MessageName => 'RLM_FORECAST_API_FAILED',
             x_InterfaceHeaderId => x_sched_rec.header_id,
             x_InterfaceLineId => v_InterfaceLineId,
             x_ScheduleHeaderId => x_sched_rec.schedule_header_id,
             x_ScheduleLineId => NULL,
             x_Token1 => 'ORGANIZATION_ID',
             x_value1 => x_Group_rec.ship_from_org_id,
             x_Token2 => 'FORECAST_DESIGNATOR',
             x_value2 => x_designator(1).forecast_designator);
    --
    RAISE e_group_error;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(K_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_Group_Error THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(k_DEBUG,'progress',x_Progress);
        rlm_core_sv.dpop(k_SDEBUG, 'GROUP ERROR');
     END IF;
     --
     raise;
     --
  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(K_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END EmptyForecast;


PROCEDURE ProcessReplaceAll (x_sched_rec IN  RLM_INTERFACE_HEADERS%ROWTYPE,
                             x_Group_rec IN OUT NOCOPY rlm_dp_sv.t_Group_rec,
                             x_designator IN OUT NOCOPY mrp_forecast_interface_pk.t_forecast_designator)

IS
  --
  t_forecast            mrp_forecast_interface_pk.t_forecast_interface;
  empty_designator      mrp_forecast_interface_pk.t_forecast_designator;
  empty_forecast        mrp_forecast_interface_pk.t_forecast_interface;
  v_last               NUMBER;
  v_counter            NUMBER;
  v_mrp_count          NUMBER:=0;
  v_designator         VARCHAR2(10);
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(k_SDEBUG,'ProcessReplaceAll');
  END IF;
  --
  -- count the no of mrp lines for the given header and status =5 /*2816086*/
  --
  IF x_Group_rec.bill_to_site_use_id IS NOT NULL THEN
   --
   select count(*) into v_mrp_count
   from rlm_interface_lines
   where header_id = x_Sched_rec.header_id
   and item_detail_type = k_MRP_FORECAST
   and process_status     = 5
   and bill_to_site_use_id =  x_Group_rec.bill_to_site_use_id
   and nvl(ship_to_site_use_id, k_NNULL)
                             = nvl(x_Group_rec.ship_to_site_use_id, k_NNULL)
   and ship_from_org_id = x_Group_rec.ship_from_org_id;
   --
  ELSE
   --
   select count(*) into v_mrp_count
   from rlm_interface_lines
   where header_id = x_Sched_rec.header_id
   and item_detail_type = k_MRP_FORECAST
   and process_status     = 5
   and bill_to_site_use_id IS NULL
   and nvl(ship_to_site_use_id ,k_NNULL)
                             = nvl(x_Group_rec.ship_to_site_use_id,k_NNULL)
   and ship_from_org_id = x_Group_rec.ship_from_org_id;
   --
  END IF;
  --
  v_last := g_designator_tab.last;
  v_counter := g_designator_tab.first;
  --
  IF (v_mrp_count = 0) THEN       /*2816086*/
   --
   IF(g_designator_tab.COUNT <> 0) THEN
    --{
    WHILE v_counter <=  v_last LOOP
     --{
     IF (g_designator_tab(v_counter).designator = x_designator(x_designator.COUNT).forecast_designator)
         AND (g_designator_tab(v_counter).organization_id = x_designator(x_designator.COUNT).organization_id) THEN --Bugfix 6817494
      --
      k_REPLACE_FLAG := FALSE;
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(k_DEBUG,'already deleted old forecast for designator', g_designator_tab(v_counter).designator);
      END IF;
      --
      EXIT;
      --
     ELSE
      --
      k_REPLACE_FLAG := TRUE;
      --
     END IF;
     --
     v_counter := v_counter+1;
     --}
    END LOOP; --loop for designators already deleted
    --
    IF (k_REPLACE_FLAG = TRUE) THEN
     --
     RLM_TPA_SV.emptyforecast( x_sched_rec,
                   x_Group_rec,
                   empty_forecast,
                   empty_designator,
                   x_designator);
     --
    END IF;
    --}
   ELSE
    --
    RLM_TPA_SV.emptyforecast( x_sched_rec,
                   x_Group_rec,
                   empty_forecast,
                   empty_designator,
                   x_designator);
    --
   END IF; --check for g_designator_tab
   --
  END IF;  --check for v_mrp_count
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(k_SDEBUG,'ProcessReplaceAll');
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(K_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    RAISE;
    --
END ProcessReplaceAll;


/*===========================================================================

  PROCEDURE NAME:     GetTPContext

  DESCRIPTION:        This procedure returns the tp group context.
                      This procedure returns a null x_ship_to_ece_locn_code,
                      and null x_inter_ship_to_ece_locn_code

  CHANGE HISTORY:     created jckwok 12/11/03

===========================================================================*/
PROCEDURE GetTPContext( x_sched_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE DEFAULT NULL,
                        x_group_rec  IN rlm_dp_sv.t_Group_rec DEFAULT NULL,
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
      rlm_core_sv.dpush(k_SDEBUG,'GetTPContext');
      rlm_core_sv.dlog(k_DEBUG,'customer_id', x_sched_rec.customer_id);
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.ece_tp_translator_code',
                             x_sched_rec.ece_tp_translator_code);
      rlm_core_sv.dlog(k_DEBUG,'x_sched_rec.ece_tp_location_code_ext',
                             x_sched_rec.ece_tp_location_code_ext);
      rlm_core_sv.dlog(k_DEBUG,'x_group_rec.ship_to_address_id',
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
	and	ACCT_SITE.CUST_ACCOUNT_ID = x_sched_rec.CUSTOMER_ID
	and	ACCT_SITE.ECE_TP_LOCATION_CODE  = x_Sched_rec.ECE_TP_LOCATION_CODE_EXT;

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
   IF x_sched_rec.customer_id is NOT NULL THEN
      --
      -- Following query is changed as per TCA obsolescence project.
      SELECT 	account_number
      INTO   	x_customer_number
      FROM   	HZ_CUST_ACCOUNTS CUST_ACCT
      WHERE 	CUST_ACCT.CUST_ACCOUNT_ID = x_sched_rec.customer_id;
      --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG, 'customer_number', x_customer_number);
      rlm_core_sv.dlog(k_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
      rlm_core_sv.dlog(k_DEBUG, 'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
      rlm_core_sv.dlog(k_DEBUG, 'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
      rlm_core_sv.dlog(k_DEBUG, 'x_tp_group_code',x_tp_group_code);
      rlm_core_sv.dpop(k_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
      --
      x_customer_number := NULL;
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(k_DEBUG, 'No data found for' , x_sched_rec.customer_id);
         rlm_core_sv.dpop(k_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_validatedemand_sv.GetTPContext',v_Progress);
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      raise;

END GetTPContext;

/* Bug 4176961 : UOM conversion */
PROCEDURE Convert_UOM (from_uom             IN            VARCHAR2,
                       to_uom               IN            VARCHAR2,
                       quantity             IN OUT NOCOPY NUMBER,
                       p_item_id            IN            NUMBER,
                       p_org_id             IN            NUMBER)
IS

  result                      NUMBER;
  v_item_number               MTL_ITEM_FLEXFIELDS.ITEM_NUMBER%TYPE;
  v_ShipFromOrgName           VARCHAR2(250) DEFAULT NULL;
  e_PrimaryCodeMissing        EXCEPTION;
  e_UndefinedUOMConversion    EXCEPTION;

  CURSOR c IS
    select item_number
    from   mtl_item_flexfields
    where  inventory_item_id = p_item_id
    and    organization_id = p_org_id;
--
BEGIN
  --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(k_SDEBUG,'Convert_UOM');
      rlm_core_sv.dlog(k_DEBUG,'from_uom',from_uom);
      rlm_core_sv.dlog(k_DEBUG,'to_uom',to_uom);
      rlm_core_sv.dlog(k_DEBUG,'quantity',quantity);
      rlm_core_sv.dlog(k_DEBUG,'p_item_id',p_item_id);
      rlm_core_sv.dlog(k_DEBUG,'p_org_id',p_org_id);
  END IF;
  --
  IF to_uom IS NULL THEN
     raise e_PrimaryCodeMissing;
  END IF;
  --
  IF quantity is NULL THEN
    result := NULL;
  ELSE
    --
    IF from_uom = to_uom THEN
       result := round(quantity,9);
    ELSIF (from_uom IS NULL) THEN
       result := 0;
    ELSE
       --
       result := INV_CONVERT.inv_um_convert(p_item_id,
                                            9,
                                            quantity,
                                            from_uom,
                                            to_uom,
                                            NULL,
                                            NULL);
       IF (result = -99999) THEN
          result := 0;
	  raise e_UndefinedUOMConversion;
       END IF;
       --
    END IF;
    --
  END IF;
  --
  quantity := result;
  --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(k_DEBUG,'result',result);
      rlm_core_sv.dpop(k_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_PrimaryCodeMissing THEN
    --
    BEGIN
      --
      OPEN c;
      FETCH c into v_item_number;
      --
      v_ShipFromOrgName := RLM_CORE_SV.get_ship_from(p_org_id);
      --
      rlm_message_sv.app_error(
                  x_ExceptionLevel => rlm_message_sv.k_error_level,
                  x_MessageName => 'RLM_ERROR_NO_PRIMARY_UOM',
                  x_token1=> 'INVITM',
                  x_value1=> v_item_number,
                  x_token2=> 'SHP_FRM_ORG',
                  x_value2=> v_ShipFromOrgName);
      CLOSE c;
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION:  RLM_ERROR_NO_PRIMARY_UOM');
      END IF;
      --
    EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(K_SDEBUG, 'No data found');
      END IF;
      --
    END;
    --
    raise e_Group_Error;
    --
  WHEN e_UndefinedUOMConversion THEN
    --
    BEGIN
      --
      OPEN c;
      FETCH c into v_item_number;
      --
      rlm_message_sv.app_error(
                  x_ExceptionLevel => rlm_message_sv.k_error_level,
                  x_MessageName => 'RLM_UNDEF_UOM_CONVERSION',
                  x_token1=> 'FROM_UOM',
                  x_value1=> from_uom,
                  x_token2=> 'TO_UOM',
                  x_value2=> to_uom,
                  x_token3=> 'INVITM',
                  x_value3=> v_item_number);
      CLOSE c;
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION:  RLM_UNDEF_UOM_CONVERSION');
      END IF;
      --
    EXCEPTION
    --
    WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(K_SDEBUG, 'No data found');
      END IF;
      --
    END;
    --
    raise e_Group_Error;
    --
  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(k_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END Convert_UOM;

END RLM_FORECAST_SV;

/
