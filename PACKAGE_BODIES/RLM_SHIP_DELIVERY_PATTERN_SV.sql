--------------------------------------------------------
--  DDL for Package Body RLM_SHIP_DELIVERY_PATTERN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_SHIP_DELIVERY_PATTERN_SV" as
/* $Header: RLMDPSDB.pls 120.2 2005/07/17 18:31:28 rlanka ship $*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--

/*=============================================================================

PROCEDURE NAME: calc_scheduled_ship_date

==============================================================================*/

PROCEDURE  calc_scheduled_ship_date(x_Input IN rlm_ship_delivery_pattern_sv.t_InputRec,
                                    x_QuantityDate  OUT NOCOPY rlm_ship_delivery_pattern_sv.t_OutputTable,
                                    x_ReturnMessage OUT NOCOPY rlm_ship_delivery_pattern_sv.t_ErrorMsgTable,
                                    x_ReturnStatus  OUT NOCOPY NUMBER)
IS
   --
   v_Progress                     VARCHAR2(3)  := '010';
   v_SdpCode                      VARCHAR2(30);
   v_DailyPercent                 rlm_core_sv.t_NumberTable;
   v_WeeklyBucket                 t_BucketTable;
   v_QuantityDate                 t_OutputTable;
   v_LeadTime                     t_LeadTimeRec;
   v_ReturnMessage                t_ErrorMsgTable;
   v_Input                        t_InputRec;
   v_ShipMethod                   VARCHAR2(30);
   v_SdpCodeReturnStatus          NUMBER;
   v_BreakBucketReturnStatus      NUMBER;
   e_ErrorCondition               EXCEPTION;
   v_tot_percent                  NUMBER;
   x_message                      VARCHAR2(4000);
   v_temp_shipdate                DATE;
   v_supplier_shp_calendar_cd     VARCHAR2(50);
   v_customer_rcv_calendar_cd     VARCHAR2(50);
   v_ShipLocationId               NUMBER;
   v_RcvLocationId                NUMBER;
   v_return_status                VARCHAR2(1);
   v_msg_count                    NUMBER;
   v_msg_data                     VARCHAR2(2000);
   v_entity                       VARCHAR2(100) := 'RCV';
   e_ShpCalAPIFailed              EXCEPTION;
   e_RcvCalAPIFailed              EXCEPTION;
   e_ShpCalAPINULL                EXCEPTION;
   e_RcvCalAPINULL                EXCEPTION;
   e_SDPIntransitSetupDeliver     EXCEPTION; -- Bug 3682051
   e_SDPIntransitSetupShip        EXCEPTION; -- Bug 3682051
   v_summary                      VARCHAR2(3000);
   v_details                      VARCHAR2(3000);
   v_loop                         NUMBER;
   e_SDPFailed                    EXCEPTION;
   v_temp_LeadTime                t_LeadTimeRec;
   v_lead_count                   NUMBER;
   j                              NUMBER;
   trnc                           NUMBER;
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'calc_scheduled_ship_date');
      rlm_core_sv.dlog(g_DEBUG,'ShipDeliveryRuleName',
                             x_Input.ShipDeliveryRuleName);
      rlm_core_sv.dlog(g_DEBUG,'ItemDetailSubtype',
                             x_Input.ItemDetailSubtype);
      rlm_core_sv.dlog(g_DEBUG,'DateTypeCode', x_Input.DateTypeCode);
      rlm_core_sv.dlog(g_DEBUG,'StartDateTime', x_Input.StartDateTime);
      rlm_core_sv.dlog(g_DEBUG,'ShipToAddressId', x_Input.ShipToAddressId);
      rlm_core_sv.dlog(g_DEBUG,'ShipToSiteUseId', x_Input.ShipToSiteUseId);
      rlm_core_sv.dlog(g_DEBUG,'ShipFromOrgId', x_Input.ShipFromOrgId );
      rlm_core_sv.dlog(g_DEBUG,'CustomerItemId', x_Input.CustomerItemId);
      rlm_core_sv.dlog(g_DEBUG,'PrimaryQuantity ',x_Input.PrimaryQuantity);
      rlm_core_sv.dlog(g_DEBUG,'EndDateTime ', x_Input.EndDateTime);
      rlm_core_sv.dlog(g_DEBUG,'DefaultSDP ', x_Input.DefaultSDP);
      rlm_core_sv.dlog(g_DEBUG,'ship_method ', x_Input.ship_method);
      rlm_core_sv.dlog(g_DEBUG,'Intransit_time ', x_Input.Intransit_time);
      rlm_core_sv.dlog(g_DEBUG,'time_uom_code ', x_Input.time_uom_code);
      rlm_core_sv.dlog(g_DEBUG,'exclude non workdays flag', x_input.exclude_non_workdays_flag);
      rlm_core_sv.dlog(g_DEBUG,'ShipToCustomerId', x_Input.ShiptoCustomerId );
   END IF;
   --
   x_ReturnStatus := g_SUCCESS;
   --
   v_ReturnMessage := x_ReturnMessage;
   --
   v_Input := x_Input;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'ShipToAddressId', v_Input.ShipToAddressId);
      rlm_core_sv.dlog(g_DEBUG,'ShipFromOrgId', v_Input.ShipFromOrgId );
   END IF;
   --
  /* Call shipping API to get calendars from Shipping Tables */
   --
   v_RcvLocationId := WSH_UTIL_CORE.Cust_Site_To_Location(
                                      v_Input.ShipToSiteUseId);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_RcvLocationId ', v_RcvLocationId);
      rlm_core_sv.dlog(g_DEBUG,'CustomerId', v_Input.ShipToCustomerId);
      rlm_core_sv.dlog(g_DEBUG,'CustomerId', v_Input.CustomerId);
   END IF;
   --
   WSH_CAL_ASG_VALIDATIONS.Get_Calendar
                           ( p_api_version_number => 1.0,
                             p_init_msg_list => FND_API.G_FALSE,
                             x_return_status => v_return_status,
                             x_msg_count     => v_msg_count,
                             x_msg_data      => v_msg_data,
                             p_entity_type   => 'CUSTOMER',
                             p_entity_id     => nvl(v_Input.ShipToCustomerId,
                                                    v_Input.CustomerId),
                             p_location_id   => v_RcvLocationId,
                             x_calendar_code => v_customer_rcv_calendar_cd
                           );
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_return_status ', v_return_status);
      rlm_core_sv.dlog(g_DEBUG,'customer_rcv_calendar_cd',
                                           v_customer_rcv_calendar_cd);
      rlm_core_sv.dlog(g_DEBUG,'v_msg_count', v_msg_count);
      rlm_core_sv.dlog(g_DEBUG,'v_msg_data', v_msg_data);
   END IF;
   --
   IF v_return_status = FND_API.G_RET_STS_ERROR OR
      v_return_status =  FND_API.G_RET_STS_UNEXP_ERROR  THEN
      --
      raise e_RcvCalAPIFailed;
      --
   END IF;
   --
   /*
   -- Bug 3733396 : Do not raise error if receiving calendar is not specified
   --
   IF v_customer_rcv_calendar_cd is NULL THEN
      --
      raise e_RcvCalAPINULL;
      --
   END IF;
   */
   --
   v_entity := 'SHP';
   v_ShipLocationId := WSH_UTIL_CORE.Org_To_Location( v_Input.ShipFromOrgId);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'ShipFromOrgId ', v_Input.ShipFromOrgId);
      rlm_core_sv.dlog(g_DEBUG,'v_ShipLocationId ', v_ShipLocationId);
   END IF;
   --
   WSH_CAL_ASG_VALIDATIONS.Get_Calendar
                           ( p_api_version_number => 1.0,
                             p_init_msg_list => FND_API.G_FALSE,
                             x_return_status => v_return_status,
                             x_msg_count     => v_msg_count,
                             x_msg_data      => v_msg_data,
                             p_entity_type   => 'ORG',
                             p_entity_id     =>  v_Input.ShipFromOrgId,
                             p_location_id   =>  v_ShiplocationId,
                             x_calendar_code =>  v_supplier_shp_calendar_cd
                            );
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_return_status ', v_return_status);
      rlm_core_sv.dlog(g_DEBUG,'v_msg_count', v_msg_count);
      rlm_core_sv.dlog(g_DEBUG,'v_msg_data', v_msg_data);
      rlm_core_sv.dlog(g_DEBUG,'v_supplier_shp_calendar_cd',
                                        v_supplier_shp_calendar_cd);
   END IF;
   --
   IF v_return_status = FND_API.G_RET_STS_ERROR OR
      v_return_status =  FND_API.G_RET_STS_UNEXP_ERROR  THEN
      --
      raise e_ShpCalAPIFailed;
      --
   END IF;
   --
   IF v_supplier_shp_calendar_cd is NULL THEN
      --
      raise e_ShpCalAPINULL;
      --
   END IF;
   --
   v_Input.supplier_shp_calendar_cd := v_supplier_shp_calendar_cd;
   v_Input.customer_rcv_calendar_cd := v_customer_rcv_calendar_cd;
   --
   --Determine the correct Ship Delivery Pattern Code
   --
   v_SDPCOde := v_Input.ShipDeliveryRuleName;
   --
   determine_sdp_code(v_Input.ShipDeliveryRuleName,
		      v_Input.use_edi_sdp_code_flag,
                      v_Input.DefaultSDP,
                      v_Input.CustomerId,
                      v_Input.ShipFromOrgId,
                      v_Input.ShipToAddressId,
                      v_ReturnMessage,
                      v_SdpCode,
                      v_SdpCodeReturnStatus);
   --
   IF v_SdpCodeReturnStatus = g_RaiseErr THEN
      -- bug 1428466
      raise e_SDPFailed;
   END IF;
   --
   set_return_status(x_ReturnStatus,v_SdpCodeReturnStatus);
   --
   --Find the daily percentages
   --
   IF v_SdpCode IS NOT NULL THEN
      --
      v_DailyPercent := find_daily_percent(v_SdpCode);
      --
      v_tot_percent := v_DailyPercent(1) +
                       v_DailyPercent(2) +
                       v_DailyPercent(3) +
                       v_DailyPercent(4) +
                       v_DailyPercent(5) +
                       v_DailyPercent(6) +
                       v_DailyPercent(7) ;
      --
      -- If the total percent = 0 means that no sdp code needs to be applied
      -- therefore the ship date and the receive date becomes the start date
      --
   ELSE
      --
      v_tot_percent := 0;
      --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' v_tot_percent',v_tot_percent);
   END IF;
   --
   --Find the appropriate lead time
   --
   v_ShipMethod := v_Input.ship_method;
   --
   v_LeadTime.time := v_Input.Intransit_time;
   --
   v_LeadTime.uom := v_Input.time_uom_code;
   --
   IF (v_Input.DateTypeCode = 'DELIVER') THEN
      --
      IF (v_LeadTime.Time IS NULL) THEN
         --
         set_return_status(x_ReturnStatus,g_ERROR);
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,' Lead time is NULL, ERROR condition');
         END IF;
         --
         --v_ReturnMessage.
         rlm_message_sv.get_msg_text('RLM_NULL_LEAD_TIME',
                                 x_message);

         get_err_message(x_message, 'RLM_NULL_LEAD_TIME',-1, v_ReturnMessage);
         --
      END IF;
      --
   ELSIF (v_Input.DateTypeCode = 'SHIP') THEN
      --
      IF (v_LeadTime.Time IS NULL) THEN
         --
         set_return_status(x_ReturnStatus,g_WARNING);
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,' Lead time is NULL, WARNING condition');
         END IF;
         --
         rlm_message_sv.get_msg_text('RLM_NULL_LEAD_TIME',
                                 x_message);
         get_err_message( x_message,'RLM_NULL_LEAD_TIME',0, v_ReturnMessage);
         --
      END IF;
      --
   END IF;
   --
   -- Break buckets
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'ItemDetailSubtype',v_Input.ItemDetailSubtype);
   END IF;
   --
   IF (v_Input.ItemDetailSubtype IN (g_WEEK,
                                     g_FLEXIBLE,
                                     g_MONTH,
                                     g_QUARTER)) THEN
      --
      RLM_TPA_SV.break_bucket(v_Input,
                   v_ReturnMessage,
                   v_WeeklyBucket,
                   v_BreakBucketReturnStatus);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' v_BreakBucketReturnStatus',
                                 v_BreakBucketReturnStatus);
         rlm_core_sv.dlog(g_DEBUG,' v_WeeklyBucket.COUNT ',
                                 v_WeeklyBucket.COUNT);
      END IF;
      --
      set_return_status(x_ReturnStatus,v_BreakBucketReturnStatus);
      --
   END IF;
   --
   --Check for API validation error condition
   --
   IF (x_ReturnStatus = g_ERROR) THEN
      --
      raise e_ErrorCondition;
      --
   END IF;
   --
   --Apply SDPC
   --
   IF (v_Input.ItemDetailSubtype IN (g_WEEK,
                                     g_FLEXIBLE,
                                     g_MONTH,
                                     g_QUARTER)) THEN
     --
     FOR i IN 1..v_WeeklyBucket.COUNT LOOP
        --
        IF v_tot_percent <> 0 THEN
          --
          RLM_TPA_SV.apply_sdp_to_weekly_bucket(
                     v_Input,
                     v_WeeklyBucket(i).ItemDetailSubtype,
                     v_DailyPercent,
                     v_WeeklyBucket(i).StartDateTime,
                     v_WeeklyBucket(i).PrimaryQuantity,
                     v_WeeklyBucket(i).WholeNumber,
                     x_QuantityDate);
          --
        ELSE
          --
          x_QuantityDate(i).PlannedReceiveDate :=
                      v_WeeklyBucket(i).StartDateTime;
          --
          x_QuantityDate(i).PlannedShipmentDate  :=
                      v_WeeklyBucket(i).StartDateTime;
          --
          x_QuantityDate(i).primaryQuantity  :=
                      v_WeeklyBucket(i).PrimaryQuantity;
          --
          x_QuantityDate(i).ItemDetailSubtype  :=
                      v_WeeklyBucket(i).ItemDetailSubtype;
          --
        END IF;
        --
     END LOOP;
     --
   ELSIF (v_Input.ItemDetailSubtype = g_DAY) THEN
     --
     IF v_tot_percent <> 0 THEN
        --
        RLM_TPA_SV.apply_sdp_to_daily_bucket(v_Input,
               v_Input.ItemDetailSubtype,
               v_DailyPercent,
               v_Input.StartDateTime,
               v_Input.PrimaryQuantity,
               x_QuantityDate);
        --
     ELSE
        --
        x_QuantityDate(1).PlannedReceiveDate  :=
                           v_Input.StartDateTime;
        x_QuantityDate(1).PlannedShipmentDate  :=
                           v_Input.StartDateTime;
        x_QuantityDate(1).primaryQuantity  :=
                           v_Input.PrimaryQuantity;
        x_QuantityDate(1).ItemDetailSubtype  :=
                           g_Day;
        --
     END IF;
     --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'x_QuantityDate.COUNT',x_QuantityDate.COUNT);
      rlm_core_sv.dlog(g_DEBUG,'rcv_calendar',v_input.customer_rcv_calendar_cd);
      rlm_core_sv.dlog(g_DEBUG,'DateTypeCode',v_Input.DateTypeCode);
   END IF;
   --
   --   Apply Lead Times
   --
   IF (v_Input.DateTypeCode = 'DELIVER') THEN
      --
      v_temp_LeadTime.Time:= v_LeadTime.Time;
      v_temp_LeadTime.UOM:= v_LeadTime.UOM;
      --
      FOR i IN 1..x_QuantityDate.COUNT LOOP
        --
        IF(nvl(v_input.exclude_non_workdays_flag, 'N') = 'Y') THEN
          --
          /* add exclude non-workdays code here*/
          v_lead_count :=0;
          trnc:=0;

          IF(v_LeadTime.UOM ='HR') THEN
            --
            v_temp_LeadTime.Time:= v_LeadTime.Time/24;
            trnc:=v_temp_LeadTime.Time-TRUNC(v_temp_LeadTime.Time,0);
            --
          ELSE
            --
  	    v_temp_LeadTime.Time:= v_LeadTime.Time;
            --
          END IF;

          v_temp_LeadTime.UOM :='DAY';
          j:=trnc;
          --
          WHILE (v_lead_count < TRUNC(v_temp_LeadTime.Time,0)) LOOP
            --
	    j:=j+1;
            --
	    IF RLM_TPA_SV.check_send_date(v_Input,x_QuantityDate(i).PlannedReceiveDate - j) THEN
              --
              v_lead_count:= v_lead_count+1;
              IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(g_DEBUG,'Found a valid send date');
              END IF;
              --
    	    END IF;
            --
          END LOOP;
          --
          v_temp_LeadTime.Time:= j;

          IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'Effective Lead Time',v_temp_LeadTime.TIME);
          END IF;
          --
        END IF;
        --

         --global_atp
         IF NOT v_Input.ATPItemFlag THEN
           apply_lead_time(v_temp_LeadTime, x_QuantityDate(i), 'SUBTRACT');
         END IF;
         --
         --
         --bug 1970599
         v_loop := 0;
         --
         v_temp_shipdate := x_QuantityDate(i).PlannedShipmentDate;
         --
         WHILE (RLM_TPA_SV.check_send_date(v_Input,
                  x_QuantityDate(i).PlannedShipmentDate) = FALSE)
                AND (v_loop < 40) --bug 2144910
         LOOP
            --
            RLM_TPA_SV.determine_send_date(v_Input,
                                v_DailyPercent,
                                x_QuantityDate(i).PlannedReceiveDate);
            x_QuantityDate(i).PlannedShipmentDate :=
                               x_QuantityDate(i).PlannedReceiveDate ;
            IF NOT v_Input.ATPItemFlag THEN
               --
               apply_lead_time(v_LeadTime, x_QuantityDate(i), 'SUBTRACT');
               --
            END IF;
            --
            v_loop := v_loop + 1;
            --
         END LOOP;
         --
         -- WARNING
         --
         -- Bug 2955782 : Added CUST_ITEM and QTY tokens to the message
         -- RLM_SHIP_DATE_OUTOFSYNC.

         IF v_loop > 0  AND v_loop < 40 THEN --bug 3682051
              rlm_message_sv.get_msg_text(
                       x_message_name => 'RLM_SHIP_DATE_OUTOFSYNC',
                       x_text => x_message,
                       x_token1 => 'SHIP_DATE',
                       x_value1 => v_temp_shipdate,
                       x_token2 => 'CUST_ITEM',
                       x_value2 => rlm_core_sv.get_item_number(x_input.CustomerItemId),
                       x_token3 => 'QTY',
                       x_value3 =>  v_Input.PrimaryQuantity,
                       x_token4 => 'SHIP_NEW_DATE',
                       x_value4 => x_QuantityDate(i).PlannedShipmentDate,
                       x_token5 => 'CALENDAR',
                       x_value5 => v_Input.supplier_shp_calendar_cd);

           get_err_message( x_message,'RLM_SHIP_DATE_OUTOFSYNC',0,
                                                            v_ReturnMessage);
           --
           set_return_status(x_ReturnStatus,g_WARNING);
           --
         ELSIF v_loop = 40  THEN
          --
          raise  e_SDPIntransitSetupDeliver;
          --
         END IF;
         --
         --
         --bug 1970599
         --
         IF (RLM_TPA_SV.check_receive_date(v_Input,
                   x_QuantityDate(i).PlannedReceiveDate) = FALSE)
         THEN
           --
           -- Generate Warning
           --
           -- Bug 2955782 : Added CUST_ITEM and QTY tokens to the message
           -- RLM_RECVD_DATE_CLOSED.

           rlm_message_sv.get_msg_text(
                     x_message_name => 'RLM_RECVD_DATE_CLOSED',
                           x_text => x_message,
                           x_token1 => 'CUST_ITEM',
                           x_value1 => rlm_core_sv.get_item_number(x_input.CustomerItemId),
                           x_token2 => 'QTY',
                           x_value2 =>  v_Input.PrimaryQuantity,
                           x_token3 => 'CALENDAR',
                           x_value3 => v_Input.customer_rcv_calendar_cd,
                           x_token4 => 'RECV_DATE',
                           x_value4 => x_QuantityDate(i).PlannedReceiveDate);

           get_err_message( x_message,'RLM_RECVD_DATE_CLOSED',0,
                                                              v_ReturnMessage);

           --
           set_return_status(x_ReturnStatus,g_WARNING);
           --
         END IF;
         --
      END LOOP;
      --
   ELSIF (v_Input.DateTypeCode = 'SHIP') THEN
      --
      FOR i IN 1..x_QuantityDate.COUNT LOOP
         --
         --bug 1970599
         v_loop := 0;
         WHILE (RLM_TPA_SV.check_send_date(v_Input,
                         x_QuantityDate(i).PlannedShipmentDate) = FALSE)
                AND (v_loop < 40 ) --bug 2144910
         LOOP
          --
            RLM_TPA_SV.determine_send_date(
                                 v_Input,
                                 v_DailyPercent,
                                 x_QuantityDate(i).PlannedShipmentDate);
            --
            v_loop := v_loop + 1;
            --
         END LOOP;
         --
         IF (RLM_TPA_SV.check_send_date(v_Input,
               x_QuantityDate(i).PlannedShipmentDate) = FALSE)
         THEN
            --
            -- Generate Warning
            --
            -- Bug 2955782 : Added CUST_ITEM and QTY tokens to the message
            -- RLM_SHIP_DATE_CLOSED.

           rlm_message_sv.get_msg_text(
                x_message_name => 'RLM_SHIP_DATE_CLOSED',
                x_text => x_message,
                x_token1 => 'CUST_ITEM',
                x_value1 => rlm_core_sv.get_item_number(x_input.CustomerItemId),
                x_token2 => 'QTY',
                x_value2 =>  v_Input.PrimaryQuantity,
                x_token3 => 'SHIP_DATE',
                x_value3 => x_QuantityDate(i).PlannedShipmentDate,
                x_token4 => 'CALENDAR',
                x_value4 => v_Input.supplier_shp_calendar_cd);

            get_err_message( x_message,'RLM_SHIP_DATE_CLOSED',-1, v_ReturnMessage);
            --
            x_ReturnMessage := v_ReturnMessage;
            raise  e_SDPIntransitSetupShip;
            --
         END IF;
         --
         IF (v_LeadTime.Time IS NULL) THEN
             --
             x_QuantityDate(i).PlannedReceiveDate :=
                       x_QuantityDate(i).PlannedShipmentDate;
             --
         ELSE
            --global_atp
            IF NOT v_Input.ATPItemFlag THEN
              apply_lead_time(v_LeadTime, x_QuantityDate(i), 'ADD');
            END IF;
            --
            IF RLM_TPA_SV.check_receive_date(v_Input,
                        x_QuantityDate(i).PlannedReceiveDate) = FALSE THEN
            --
/*
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(g_DEBUG,'RLM_RECVD_DATE_CLOSED',
                                       x_QuantityDate(i).PlannedReceiveDate);
                 END IF;

                 rlm_message_sv.get_msg_text(
                        x_message_name => 'RLM_RECVD_DATE_CLOSED',
                              x_text => x_message,
                              x_token1 => 'CALENDAR',
                              x_value1 => v_Input.customer_rcv_calendar_cd,
                              x_token2 => 'RECV_DATE',
                              x_value2 => x_QuantityDate(i).PlannedReceiveDate);

                 get_err_message( x_message,'RLM_RECVD_DATE_CLOSED',0,
                                                             v_ReturnMessage);
*/

              set_return_status(x_ReturnStatus,g_WARNING);
           END IF;
            --
            --
         END IF;
         --
      END LOOP;
      --
   END IF;
   --
   x_ReturnMessage := v_ReturnMessage;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' x_ReturnMessage.COUNT ',x_ReturnMessage.COUNT);
      rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
      rlm_core_sv.dpop(g_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN e_ShpCalAPINULL THEN
      --
      set_return_status(x_ReturnStatus,g_Error);
      rlm_message_sv.get_msg_text(
               x_message_name => 'RLM_NO_SHP_CALENDAR',
               x_text => x_message,
               x_token1 => 'ORG',
               x_value1 => rlm_core_sv.get_ship_from(v_Input.ShipFromOrgId));
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_message ',x_message);
      END IF;
      --
      get_err_message( x_message,'RLM_NO_SHP_CALENDAR',-1, v_ReturnMessage);
      x_ReturnMessage := v_ReturnMessage;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
         rlm_core_sv.dpop(g_SDEBUG,'e_ShpCalAPINULL');
      END IF;
      --
   WHEN e_RcvCalAPINULL THEN
      --
      set_return_status(x_ReturnStatus,g_Error);
      rlm_message_sv.get_msg_text(
               x_message_name => 'RLM_NO_RCV_CALENDAR',
               x_text => x_message,
               x_token1 => 'CUSTOMER',
               x_value1 => rlm_core_sv.get_customer_name(v_Input.CustomerId));
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_message ',x_message);
      END IF;
      --
      get_err_message( x_message,'RLM_NO_RCV_CALENDAR',-1, v_ReturnMessage);
      x_ReturnMessage := v_ReturnMessage;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
         rlm_core_sv.dpop(g_SDEBUG,'e_RcvCalAPINULL');
      END IF;
      --
   WHEN e_ShpCalAPIFailed THEN
      --
      set_return_status(x_ReturnStatus,g_Error);
      WSH_UTIL_CORE.Get_Messages('N',v_summary, v_details, v_msg_count);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' v_summary ',v_summary);
         rlm_core_sv.dlog(g_DEBUG,' v_details ',v_details);
      END IF;
      --
      get_err_message(v_summary,NULL,-1, v_ReturnMessage);
      x_ReturnMessage := v_ReturnMessage;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnMessage.COUNT ',x_ReturnMessage.COUNT);
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
         rlm_core_sv.dpop(g_SDEBUG,'e_ShpCalAPIFailed');
      END IF;
      --
   WHEN e_RcvCalAPIFailed THEN
      --
      set_return_status(x_ReturnStatus,g_Error);
      WSH_UTIL_CORE.Get_Messages('N',v_summary, v_details, v_msg_count);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' v_summary ',v_summary);
         rlm_core_sv.dlog(g_DEBUG,' v_details ',v_details);
      END IF;
      --
      get_err_message(v_summary,NULL,-1, v_ReturnMessage);
      x_ReturnMessage := v_ReturnMessage;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnMessage.COUNT ',x_ReturnMessage.COUNT);
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
         rlm_core_sv.dpop(g_SDEBUG,'e_RcvCalAPIFailed');
      END IF;
      --
   WHEN  e_SDPIntransitSetupDeliver  THEN
      --
      -- Bug 3671477
      --
      set_return_status(x_ReturnStatus,g_Error);
      rlm_message_sv.get_msg_text(
                 x_message_name => 'RLM_INVALID_SDP_INTRANSIT',
                 x_text => x_message);
      get_err_message( x_message,'RLM_INVALID_SDP_INTRANSIT',-1, v_ReturnMessage);
      x_ReturnMessage := v_ReturnMessage;
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(g_DEBUG,' x_message ',x_message);
          rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
          rlm_core_sv.dpop(g_SDEBUG,'e_SDPIntransitSetupDeliver');
      END IF;
      --
   WHEN  e_SDPIntransitSetupShip  THEN
      --
      -- Bug 3671477
      --
      set_return_status(x_ReturnStatus,g_Error);
      --
      IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(g_DEBUG,' x_message ',x_message);
          rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
          rlm_core_sv.dpop(g_SDEBUG,'e_SDPIntransitSetup');
      END IF;
      --
   WHEN NO_DATA_FOUND THEN
      --
      set_return_status(x_ReturnStatus, g_Error);
      IF v_entity = 'RCV' THEN
         v_entity := rlm_core_sv.get_ship_from(v_Input.ShipFromOrgId);
      ELSE
         v_entity := rlm_core_sv.get_ship_to(v_Input.ShipToAddressId);
      END IF;
      rlm_message_sv.get_msg_text(
                     x_message_name => 'RLM_NO_LOCATION_CODE',
                     x_text => x_message,
                     x_token1 => 'ENTITY',
                     x_value1 => v_entity);
      get_err_message( x_message,'RLM_NO_LOCATION_CODE',-1, v_ReturnMessage);
      x_ReturnMessage := v_ReturnMessage;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnMessage.COUNT ',x_ReturnMessage.COUNT);
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
         rlm_core_sv.dpop(g_SDEBUG,'NO_DATA_FOUND');
      END IF;
      --
   WHEN e_ErrorCondition THEN
      --
      x_ReturnMessage := v_ReturnMessage;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnMessage.COUNT ',x_ReturnMessage.COUNT);
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
         rlm_core_sv.dpop(g_SDEBUG,'e_ErrorCondition');
      END IF;
      --
   WHEN e_SDPFailed THEN
     x_ReturnStatus := g_RaiseErr;
     x_ReturnMessage := v_ReturnMessage;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(g_SDEBUG,'calc_scheduled_ship_date g_RaiseErr');
     END IF;
     --
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_ship_delivery_pattern_sv.calc_scheduled_ship_date', v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END calc_scheduled_ship_date;
--
/*=============================================================================

FUNCTION NAME: determine_sdp_code

==============================================================================*/

PROCEDURE    determine_sdp_code(
   ShipDeliveryRuleName   IN VARCHAR2,
   use_edi_sdp_code_flag  IN rlm_cust_shipto_terms.use_edi_sdp_code_flag%TYPE,
   DefaultSDP             IN rlm_cust_shipto_terms.ship_delivery_rule_name%TYPE,
   x_customer_id          IN      NUMBER,
   x_shipFromOrg          IN      NUMBER,
   x_shipTo               IN      NUMBER,
   x_ReturnMessage        IN OUT NOCOPY   t_ErrorMsgTable,
   x_SdpCode              OUT NOCOPY      VARCHAR2,
   x_ReturnStatus         OUT NOCOPY      NUMBER)
IS
   --
   v_Progress                     varchar2(3)  :='010';
   v_Exists                       NUMBER := 0;
   x_message                      VARCHAR2(4000);
   e_SDPFailed                    EXCEPTION;
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'determine_sdp_code');
      rlm_core_sv.dlog(g_DEBUG,'ShipDeliveryRuleName   ',ShipDeliveryRuleName );
      rlm_core_sv.dlog(g_DEBUG,'use_edi_sdp_code_flag   ',use_edi_sdp_code_flag );
      rlm_core_sv.dlog(g_DEBUG,'DefaultSDP   ',DefaultSDP );
   END IF;
   --
   IF (nvl(use_edi_sdp_code_flag,'N') = 'Y' ) THEN
      --
      x_SdpCode := ShipDeliveryRuleName;
      --
      IF (x_SdpCode IS NOT NULL) THEN
         --
         SELECT count(*)
         INTO  v_Exists
         FROM  rlm_ship_delivery_codes
         WHERE ship_delivery_rule_name = x_SdpCode;
         --
         IF (v_Exists > 0) THEN
            --
            x_ReturnStatus := g_SUCCESS;
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'successful and value returned');
            END IF;
            --
         ELSE
            --
            /*WARNING RLM_INVALID_SDP*/
            x_ReturnStatus := g_WARNING;
            --
            rlm_message_sv.get_msg_text(
                                x_message_name => 'RLM_INVALID_SDP',
                                x_text => x_message,
                                x_token1 => 'SDP_CODE',
                                x_value1 => x_SdpCode);
            get_err_message(x_message,'RLM_INVALID_SDP',0, x_ReturnMessage);
            --
            IF DefaultSDP IS NULL THEN
            --
            -- bug 1428466
            --
  	        IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(g_DEBUG,'Error Default SDP is NULL');
                END IF;
	        --
                rlm_message_sv.get_msg_text(
                   x_message_name => 'RLM_NULL_SDP',
                   x_text => x_message,
                   x_token1 => 'SHIPFROM',
                   x_value1 => rlm_core_sv.get_ship_from(x_shipFromOrg),
                   x_token2 => 'CUSTOMER',
                   x_value2 => rlm_core_sv.get_customer_name(x_customer_id),
                   x_token3 => 'SHIPTO',
                   x_value3 => rlm_core_sv.get_ship_to(x_shipTo));
                get_err_message( x_message,'RLM_NULL_SDP',-1,
                                   x_ReturnMessage);
                raise e_SDPFailed;
            ELSE
              x_SdpCode := DefaultSDP;
              --
  	      IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(g_DEBUG,'invalid input sdp, defaults applied');
              END IF;
	      --
            END IF;
            --
         END IF;
         --
      ELSE
         --
         -- WARNING RLM_NULL_SDP_ON_EDI
         IF DefaultSDP IS NULL THEN
         --
         -- bug 1428466
         --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(g_DEBUG,'Error Default  SDP  is NULL');
             END IF;
	     --
             rlm_message_sv.get_msg_text(
                x_message_name => 'RLM_NULL_SDP',
                   x_text => x_message,
                   x_token1 => 'SHIPFROM',
                   x_value1 => rlm_core_sv.get_ship_from(x_shipFromOrg),
                   x_token2 => 'CUSTOMER',
                   x_value2 => rlm_core_sv.get_customer_name(x_customer_id),
                   x_token3 => 'SHIPTO',
                   x_value3 => rlm_core_sv.get_ship_to(x_shipTo));
             get_err_message( x_message,'RLM_NULL_SDP',-1,
                                x_ReturnMessage);
             raise e_SDPFailed;
         ELSE
            x_SdpCode := DefaultSDP;
            x_ReturnStatus := g_WARNING;
            BEGIN
            rlm_message_sv.get_msg_text(
                   x_message_name => 'RLM_NULL_SDP_ON_EDI',
                   x_text => x_message,
                   x_token1 => 'SHIPFROM',
                   x_value1 => rlm_core_sv.get_ship_from(x_shipFromOrg),
                   x_token2 => 'CUSTOMER',
                   x_value2 => rlm_core_sv.get_customer_name(x_customer_id),
                   x_token3 => 'SHIPTO',
                   x_value3 => rlm_core_sv.get_ship_to(x_shipTo),
                   x_token4 => 'SDP_CODE',
                   x_value4 => DefaultSDP);
            EXCEPTION
              WHEN OTHERS THEN
	       --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(g_DEBUG,'Problem in creating the message: '||
                 'RLM_NULL_SDP_ON_EDI');
               END IF;
	       --
               x_message := 'Could not create RLM_NULL_SDP_ON_EDI';
            END;
            --
            get_err_message( x_message,'RLM_NULL_SDP_ON_EDI',0,
                                    x_ReturnMessage);
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'null input sdp, defaults applied');
            END IF;
            --
         END IF;
      --
      END IF;
      --
   ELSE
      --
      IF (DefaultSDP IS NOT NULL) THEN
         --
         x_SdpCode := DefaultSDP;
         x_ReturnStatus := g_SUCCESS;
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'null input sdp, defaults applied');
         END IF;
         --
      ELSE
         --
         /*ERROR  RLM_NULL_SDP*/
         x_SdpCode := DefaultSDP;
         x_ReturnStatus := g_ERROR;
         rlm_message_sv.get_msg_text(
            x_message_name => 'RLM_NULL_SDP',
                   x_text => x_message,
                   x_token1 => 'SHIPFROM',
                   x_value1 => rlm_core_sv.get_ship_from(x_shipFromOrg),
                   x_token2 => 'CUSTOMER',
                   x_value2 => rlm_core_sv.get_customer_name(x_customer_id),
                   x_token3 => 'SHIPTO',
                   x_value3 => rlm_core_sv.get_ship_to(x_shipTo));
         get_err_message( x_message,'RLM_NULL_SDP',-1, x_ReturnMessage);
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'null default sdp');
         END IF;
         --
         raise e_SDPFailed;
         --
      END IF;
      --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'x_ReturnStatus ',x_ReturnStatus);
      rlm_core_sv.dlog(g_DEBUG,'x_SdpCode', x_SdpCode);
      rlm_core_sv.dpop(g_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN e_SDPFailed THEN
     --
     x_ReturnStatus := g_RaiseErr;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(g_SDEBUG,'determine_sdp_code, g_RaiseErr');
     END IF;
     --
   WHEN OTHERS THEN
      --
      x_ReturnStatus := g_ERROR;
      rlm_message_sv.sql_error('rlm_ship_delivery_pattern_sv.determine_sdp_code'
                                                       ,v_Progress);
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END determine_sdp_code;

/*=============================================================================

FUNCTION NAME: find_default_sdp_code

==============================================================================*/

FUNCTION    find_default_sdp_code( x_ShipFromOrgId      IN            NUMBER,
                                   x_ShipToAddressId    IN            NUMBER,
                                   x_CustomerItemId     IN            NUMBER)
RETURN VARCHAR2
IS
   --
   v_SdpCode         VARCHAR2(30);
   x_message         VARCHAR2(4000);
   --
BEGIN
   --
   SELECT ship_delivery_rule_name
   INTO v_SdpCode
   FROM RLM_CUST_ITEM_TERMS_ALL
   WHERE customer_item_id = x_CustomerItemId
   AND   ship_from_org_id = x_ShipFromOrgId
   AND   address_id = x_ShipToAddressId;
   --
   IF (v_SdpCode IS NULL) THEN
      --
      SELECT ship_delivery_rule_name
      INTO v_SdpCode
      FROM RLM_CUST_SHIPTO_TERMS_ALL
      WHERE ship_from_org_id = x_ShipFromOrgId
      AND address_id = x_ShipToAddressId;
      --
   END IF;
   --
   RETURN(v_SdpCode);
   --
END find_default_sdp_code;

/*=====================================================================

PROCEDURE NAME: set_return_status

==============================================================================*/

PROCEDURE  set_return_status(x_ReturnStatus  IN OUT NOCOPY NUMBER,
                             x_InputStatus   IN NUMBER)
IS
BEGIN
   --
   IF (x_InputStatus > x_ReturnStatus) THEN
      x_ReturnStatus := x_InputStatus;
   END IF;
   --
END set_return_status;

/*=============================================================================

FUNCTION NAME: find_daily_percent

==============================================================================*/

FUNCTION   find_daily_percent(x_RuleName IN VARCHAR2)
RETURN     rlm_core_sv.t_NumberTable
IS
   --
   v_Progress         VARCHAR2(3)  :='010';
   v_DailyPercent     rlm_core_sv.t_NumberTable;
   --
BEGIN
   --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'find_daily_percent');
      rlm_core_sv.dlog(g_DEBUG,'x_RuleName    ',x_RuleName  );
   END IF;
   --
   SELECT   sunday_percent/100,
            monday_percent/100,
            tuesday_percent/100,
            wednesday_percent/100,
            thursday_percent/100,
            friday_percent/100,
            saturday_percent/100
   INTO     v_DailyPercent(g_SundayDOW),
            v_DailyPercent(g_MondayDOW),
            v_DailyPercent(g_TuesdayDOW),
            v_DailyPercent(g_WednesdayDOW),
            v_DailyPercent(g_ThursdayDOW),
            v_DailyPercent(g_FridayDOW),
            v_DailyPercent(g_SaturdayDOW)
   FROM     rlm_ship_delivery_codes
   WHERE    ship_delivery_rule_name = x_RuleName;
   --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_DailyPercent(1)      ', v_DailyPercent(1));
      rlm_core_sv.dlog(g_DEBUG,'v_DailyPercent(2)      ', v_DailyPercent(2));
      rlm_core_sv.dlog(g_DEBUG,'v_DailyPercent(3)      ', v_DailyPercent(3));
      rlm_core_sv.dlog(g_DEBUG,'v_DailyPercent(4)      ', v_DailyPercent(4));
      rlm_core_sv.dlog(g_DEBUG,'v_DailyPercent(5)      ', v_DailyPercent(5));
      rlm_core_sv.dlog(g_DEBUG,'v_DailyPercent(6)      ', v_DailyPercent(6));
      rlm_core_sv.dlog(g_DEBUG,'v_DailyPercent(7)      ', v_DailyPercent(7));
      rlm_core_sv.dpop(g_SDEBUG,'successfullly returned value');
   END IF;
   --
   RETURN(v_DailyPercent);
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
      --
      rlm_message_sv.sql_error('rlm_ship_delivery_pattern_sv.find_daily_percent', v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,'EXCEPTION: When no data found sql error');
         rlm_core_sv.dpop(g_SDEBUG);
      END IF;
      --
      raise;
      --
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_ship_delivery_pattern_sv.find_daily_percent', v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END find_daily_percent;

/*=============================================================================

FUNCTION NAME:  get_ship_method

==============================================================================*/

FUNCTION    get_ship_method(x_ShipFromOrgId            IN    NUMBER,
                            x_ShipToAddressId          IN    NUMBER,
                            x_CustomerItemId           IN    NUMBER)
RETURN VARCHAR2
IS
   v_Progress        VARCHAR2(3) :='010';
   v_ShipMethod      VARCHAR(30);
   x_message         VARCHAR2(4000);

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'get_ship_method');
      rlm_core_sv.dlog(g_DEBUG,'x_ShipFromOrgId ',x_ShipFromOrgId);
      rlm_core_sv.dlog(g_DEBUG,'x_ShipToAddressId ',x_ShipToAddressId);
      rlm_core_sv.dlog(g_DEBUG,'x_CustomerItemId ',x_CustomerItemId);
   END IF;
   --
   SELECT ship_method
   INTO   v_ShipMethod
   FROM   RLM_CUST_ITEM_TERMS_ALL
   WHERE  ship_from_org_id = x_ShipFromOrgId AND
          address_id = x_ShipToAddressId AND
          customer_item_id = x_CustomerItemId;
   --
   IF (v_ShipMethod IS NULL) THEN
      --
      SELECT ship_method
      INTO v_ShipMethod
      FROM RLM_CUST_SHIPTO_TERMS_ALL
      WHERE ship_from_org_id = x_ShipFromOrgId AND
            address_id = x_ShipToAddressId;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,'v_ShipMethod ',v_ShipMethod);
         rlm_core_sv.dpop(g_SDEBUG,'Found at Address level');
      END IF;
      --
      RETURN(v_ShipMethod);
      --
   ELSE
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,'v_ShipMethod ',v_ShipMethod);
         rlm_core_sv.dpop(g_SDEBUG,'Found at Item level');
      END IF;
      --
      RETURN(v_ShipMethod);
      --
   END IF;
   --
END get_ship_method;

/*=============================================================================

FUNCTION NAME:  determine_lead_time

==============================================================================*/

FUNCTION    determine_lead_time(x_ShipFromOrgId        IN    NUMBER,
                                 x_ShipToAddressId     IN    NUMBER,
                                 x_ShipMethod          IN    VARCHAR2)
RETURN t_LeadTimeRec
IS
   v_Progress        VARCHAR2(3)  :='010';
   v_LeadTime         t_LeadTimeRec;
   x_message         VARCHAR2(4000);

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'determine_lead_time');
      rlm_core_sv.dlog(g_DEBUG,'x_ShipFromOrgId ',x_ShipFromOrgId);
      rlm_core_sv.dlog(g_DEBUG,'x_ShipToAddressId ',x_ShipToAddressId);
      rlm_core_sv.dlog(g_DEBUG,'x_ShipMethod ',x_ShipMethod);
   END IF;
   --
   SELECT intransit_time, time_uom_code
   INTO v_LeadTime.Time, v_LeadTime.Uom
   FROM mtl_interorg_ship_methods
   WHERE from_organization_id = x_ShipFromOrgId AND
         to_organization_id =  x_ShipToAddressId AND
         ship_method = x_ShipMethod;
   --
   IF (v_LeadTime.Uom IS NULL) THEN
      v_LeadTime.Uom := 'DAY';
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_LeadTime.Time ',v_LeadTime.Time);
      rlm_core_sv.dlog(g_DEBUG,'v_LeadTime.Uom ',v_LeadTime.Uom);
      rlm_core_sv.dpop(g_SDEBUG,'Lead time found');
   END IF;
   --
   RETURN(v_LeadTime);
   --
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'Lead time not found');
      END IF;
      --
      RETURN(null);
      --
END determine_lead_time;


/*=============================================================================

PROCEDURE NAME: break_bucket

==============================================================================*/

PROCEDURE  break_bucket(
        x_Input   IN RLM_SHIP_DELIVERY_PATTERN_SV.t_InputRec,
        x_ReturnMessage IN OUT NOCOPY RLM_SHIP_DELIVERY_PATTERN_SV.t_ErrorMsgTable,
        x_WeeklyBucket  OUT NOCOPY RLM_SHIP_DELIVERY_PATTERN_SV.t_BucketTable,
        x_ReturnStatus  OUT NOCOPY NUMBER)
IS
   v_Progress            VARCHAR2(3)  :='010';
   v_ReturnMessage       VARCHAR2(30)  ;
   v_Count               NUMBER := 1;
   v_Buckets             NUMBER := 1;
   v_WholeNumber         BOOLEAN := TRUE;
   v_LastDayQuarter      DATE ;
   v_WeeksInQuarter      NUMBER := 12;
   v_WrongDateException  EXCEPTION;
   x_message         VARCHAR2(4000);

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'break_bucket');
   END IF;
   --
   /*Check if input Primary Quantity is a whole number*/
   --
   IF (MOD(x_Input.PrimaryQuantity,1)>0) THEN
      --
      v_WholeNumber := FALSE;
      --
   END IF;
   --
   IF (x_Input.ItemDetailSubtype = g_QUARTER) THEN
      --
      IF (RLM_TPA_SV.check_start_date(x_Input,'QUARTER') = FALSE) THEN
         --
         raise v_WrongDateException;
         --
      ELSE
        --
        v_LastDayQuarter := last_day(ADD_MONTHS(x_Input.StartDateTime,2));
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(g_DEBUG,'v_LastDayQuarter', v_LastDayQuarter);
        END IF;
        --
        v_WeeksInQuarter := TRUNC((v_LastDayQuarter -
                                   x_Input.StartDateTime)/7 );
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(g_DEBUG,'v_WeeksInQuarter', v_WeeksInQuarter);
        END IF;
        --
        FOR week IN 0..v_WeeksInQuarter-1 LOOP
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(g_DEBUG,'week', week);
           END IF;
           --
           x_WeeklyBucket(v_Count).StartDateTime :=
                       x_Input.StartDateTime + 7*week;
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(g_DEBUG,'StartDateTime ',
                    x_WeeklyBucket(v_Count).StartDateTime);
           END IF;
           --
           x_WeeklyBucket(v_Count).PrimaryQuantity :=
                    RLM_TPA_SV.get_weekly_quantity(v_WholeNumber,
                                        v_Count,
                                        x_Input,
                                        v_WeeksInQuarter);
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(g_DEBUG,'PrimaryQuantity',
                            x_WeeklyBucket(v_Count).PrimaryQuantity);
           END IF;
           --
           v_Count := v_Count + 1;
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(g_DEBUG,'v_Count', v_Count);
           END IF;
           --
        END LOOP;
        --
      END IF;
      --
   ELSIF (x_Input.ItemDetailSubtype = g_MONTH) THEN
      --
      IF (RLM_TPA_SV.check_start_date(x_Input,'MONTH') = FALSE) THEN
         raise v_WrongDateException;
         --
      ELSE
         --
         FOR day IN 0..3 LOOP
            x_WeeklyBucket(v_Count).StartDateTime := x_Input.StartDateTime + 7*day;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'StartDateTime ', x_WeeklyBucket(v_Count).StartDateTime);
            END IF;
            x_WeeklyBucket(v_Count).PrimaryQuantity := RLM_TPA_SV.get_weekly_quantity(v_WholeNumber, v_Count,
											x_Input, 4);
	    --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'PrimaryQuantity', x_WeeklyBucket(v_Count).PrimaryQuantity);
            END IF;
            --
            v_Count := v_Count + 1;
            --
         END LOOP;
         --
      END IF;
      --
   ELSIF (x_Input.ItemDetailSubtype = g_FLEXIBLE) THEN
      WHILE ( (x_Input.StartDateTime+(7*v_Buckets)) <= x_Input.EndDateTime ) LOOP
         --
         v_Buckets := v_Buckets + 1;
         --
      END LOOP;
      /*Now v_Buckets gives the number of weekly buckets*/
      --
      FOR v_Count IN 1..v_Buckets LOOP
         --
         x_WeeklyBucket(v_Count).StartDateTime := x_Input.StartDateTime + 7*(v_Count-1);
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'StartDateTime ', x_WeeklyBucket(v_Count).StartDateTime);
         END IF;
         --
         x_WeeklyBucket(v_Count).PrimaryQuantity := RLM_TPA_SV.get_weekly_quantity(v_WholeNumber, v_Count,
										x_Input, v_Buckets);
	 --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'PrimaryQuantity', x_WeeklyBucket(v_Count).PrimaryQuantity);
         END IF;
         --
      END LOOP;
      --
   ELSIF (x_Input.ItemDetailSubtype = g_WEEK) THEN
      --
      IF (RLM_TPA_SV.check_start_date(x_Input,'WEEK') = FALSE) THEN
         --
         raise v_WrongDateException;
         --
      ELSE
         --
         x_WeeklyBucket(v_Count).StartDateTime := x_Input.StartDateTime;
         x_WeeklyBucket(v_Count).PrimaryQuantity := x_Input.PrimaryQuantity;
         --
	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'StartDateTime ', x_WeeklyBucket(v_Count).StartDateTime);
            rlm_core_sv.dlog(g_DEBUG,'PrimaryQuantity', x_WeeklyBucket(v_Count).PrimaryQuantity);
         END IF;
         --
      END IF;
      --
   END IF;
   --
   FOR v_Count IN 1..x_WeeklyBucket.COUNT LOOP
      --
      x_WeeklyBucket(v_Count).ShipDeliveryRuleName := x_Input.ShipDeliveryRuleName;
      x_WeeklyBucket(v_Count).ItemDetailSubtype := g_WEEK;
      x_WeeklyBucket(v_Count).DateTypeCode := x_Input.DateTypeCode;
      x_WeeklyBucket(v_Count).ShipToAddressId := x_Input.ShipToAddressId;
      x_WeeklyBucket(v_Count).ShipFromOrgId := x_Input.ShipFromOrgId;
      x_WeeklyBucket(v_Count).CustomerItemId := x_Input.CustomerItemId;
      x_WeeklyBucket(v_Count).EndDateTime := x_Input.EndDateTime;
      x_WeeklyBucket(v_Count).WholeNumber := v_WholeNumber;
      --
   END LOOP;
   --
   x_ReturnStatus := g_SUCCESS;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' Num of recs in x_WeeklyBucket',x_WeeklyBucket.COUNT);
      rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
      rlm_core_sv.dpop(g_SDEBUG,'successful');
   END IF;
   --
EXCEPTION
   WHEN v_WrongDateException THEN
      x_ReturnStatus := g_ERROR;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,' x_ReturnStatus ',x_ReturnStatus);
      END IF;
      --
      rlm_message_sv.get_msg_text(x_message_name => 'RLM_INVALID_DATE_FOR_BUCKET',
                                x_text => x_message,
                                x_token1 => 'START_DATE',
                                x_value1 => x_Input.StartDateTime,
                                x_token2 => 'BUCKET',
                      x_value2 => rlm_core_sv.get_lookup_meaning('RLM_DEMAND_SUBTYPE',
                                            x_Input.ItemDetailSubType));
      get_err_message( x_message,'RLM_INVALID_DATE_FOR_BUCKET',-1, x_ReturnMessage);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'unsuccessful');
      END IF;
      --
END break_bucket;

/*=============================================================================

FUNCTION NAME: get_weekly_quantity

==============================================================================*/

FUNCTION get_weekly_quantity(x_WholeNumber IN BOOLEAN,
                    x_Count       IN NUMBER,
                    x_Input       IN rlm_ship_delivery_pattern_sv.t_InputRec,
                    x_DivideBy    IN NUMBER)
RETURN NUMBER
IS
   --
   v_WeeklyQuantity        NUMBER;
   v_Temp                  NUMBER;
   x_Quantity              NUMBER;
   v_TruncateTo            NUMBER;
   x_message         VARCHAR2(4000);
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'get_weekly_quantity');
      rlm_core_sv.dlog(g_DEBUG,'x_WholeNumber    ',x_WholeNumber  );
      rlm_core_sv.dlog(g_DEBUG,'x_Count    ',x_Count  );
      rlm_core_sv.dlog(g_DEBUG,'x_Quantity    ',x_Input.PrimaryQuantity);
      rlm_core_sv.dlog(g_DEBUG,'x_DivideBy    ',x_DivideBy  );
   END IF;
   --
   x_Quantity := x_Input.PrimaryQuantity;
   v_TruncateTo := get_precision();
   --
   IF (x_Count = 1) THEN
      IF (x_WholeNumber = TRUE) THEN
         v_WeeklyQuantity := FLOOR(x_Quantity/x_DivideBy) + MOD(x_Quantity,x_DivideBy);
      ELSE
         v_Temp := TRUNC((x_Quantity/x_DivideBy),v_TruncateTo);
         v_WeeklyQuantity := v_Temp + (x_Quantity - v_Temp*x_DivideBy);
      END IF;
   ELSE
      IF (x_WholeNumber = TRUE) THEN
          v_WeeklyQuantity := FLOOR(x_Quantity/x_DivideBy) ;
      ELSE
         v_WeeklyQuantity := TRUNC((x_Quantity/x_DivideBy),v_TruncateTo);
      END IF;
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' v_WeeklyQuantity ',v_WeeklyQuantity);
      rlm_core_sv.dpop(g_SDEBUG,'successful');
   END IF;
   --
   RETURN(v_WeeklyQuantity);
   --
END get_weekly_quantity;

/*=============================================================================

FUNCTION NAME: get_precision

==============================================================================*/

FUNCTION get_precision
RETURN NUMBER
IS
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'get_precision');
      rlm_core_sv.dlog(g_DEBUG,' g_PRECISION    ',g_PRECISION  );
      rlm_core_sv.dpop(g_SDEBUG,'successful');
   END IF;
   --
   RETURN(g_PRECISION);
   --
END get_precision;


/*=============================================================================

PROCEDURE NAME: apply_sdp_to_weekly_bucket

==============================================================================*/

PROCEDURE apply_sdp_to_weekly_bucket(
           x_Input             IN    RLM_SHIP_DELIVERY_PATTERN_SV.t_InputRec,
           x_ItemDetailSubtype IN    VARCHAR2,
           x_DailyPercent      IN    rlm_core_sv.t_NumberTable,
           x_StartDateTime     IN    DATE,
           x_PrimaryQuantity   IN    NUMBER,
           x_WholeNumber       IN    BOOLEAN,
           x_QuantityDate      IN OUT NOCOPY RLM_SHIP_DELIVERY_PATTERN_SV.t_OutputTable)
IS
   v_Progress        VARCHAR2(3)  :='010';
   v_Count           NUMBER;
   v_MondayDate      DATE;
   v_Changed         BOOLEAN := FALSE;
   v_Sum             NUMBER := 0;
   v_InitialCount    NUMBER;
   v_TruncateTo      NUMBER;
   x_message         VARCHAR2(4000);
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'apply_sdp_to_weekly_bucket');
      rlm_core_sv.dlog(g_DEBUG,'x_ItemDetailSubtype    ',x_ItemDetailSubtype  );
      rlm_core_sv.dlog(g_DEBUG,'x_StartDateTime    ',x_StartDateTime  );
      rlm_core_sv.dlog(g_DEBUG,'x_PrimaryQuantity     ',x_PrimaryQuantity   );
      rlm_core_sv.dlog(g_DEBUG,'x_WholeNumber    ',x_WholeNumber  );
   END IF;
   --
   v_TruncateTo := get_precision();
   v_Count := x_QuantityDate.COUNT + 1;
   v_InitialCount := v_Count;
   v_MondayDate := RLM_TPA_SV.find_monday_date(x_Input, x_StartDateTime);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_TruncateTo    ',v_TruncateTo  );
      rlm_core_sv.dlog(g_DEBUG,'v_Count     ',v_Count   );
      rlm_core_sv.dlog(g_DEBUG,'v_MondayDate    ',v_MondayDate  );
   END IF;
   --
   FOR i IN 1..7 LOOP
      --
      IF (x_DailyPercent(i) > 0) THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'x_DailyPercent(i)',x_DailyPercent(i));
         END IF;
         --
         x_QuantityDate(v_Count).PlannedReceiveDate := v_MondayDate +
                                                         (i - g_MondayDOW);
         x_QuantityDate(v_Count).PlannedShipmentDate := v_MondayDate +
                                                         (i - g_MondayDOW);
         x_QuantityDate(v_Count).ItemDetailSubtype := g_Day;
         --
         IF (x_WholeNumber = TRUE) THEN
             --
             x_QuantityDate(v_Count).PrimaryQuantity :=
                            FLOOR(x_PrimaryQuantity * x_DailyPercent(i));
             v_Sum := v_Sum + x_QuantityDate(v_Count).PrimaryQuantity;
             --
         ELSE
             --
             x_QuantityDate(v_Count).PrimaryQuantity :=
                 TRUNC(x_PrimaryQuantity * x_DailyPercent(i), v_TruncateTo);
             v_Sum := v_Sum + x_QuantityDate(v_Count).PrimaryQuantity;
             --
         END IF;
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'PlannedReceiveDate ',
                                 x_QuantityDate(v_Count).PlannedReceiveDate);
            rlm_core_sv.dlog(g_DEBUG,'PlannedShipmentDate ',
                                 x_QuantityDate(v_Count).PlannedShipmentDate);
            rlm_core_sv.dlog(g_DEBUG,'PrimaryQuantity ',
                                 x_QuantityDate(v_Count).PrimaryQuantity);
         END IF;
         --
         v_Changed := TRUE;
         v_Count := v_Count + 1;
         --
      END IF;
      --
   END LOOP;
   --
   IF (v_Changed = TRUE) THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,'v_Changed is TRUE ');
      END IF;
      --
      x_QuantityDate(v_InitialCount).PrimaryQuantity :=
                         x_QuantityDate(v_InitialCount).PrimaryQuantity +
                        (x_PrimaryQuantity - v_Sum);
      x_QuantityDate(v_InitialCount).ItemDetailSubtype := g_Day;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,'PrimaryQuantity ',
                       x_QuantityDate(v_InitialCount).PrimaryQuantity);
         rlm_core_sv.dlog(g_DEBUG,'ItemDetailSubtype ',
                       x_QuantityDate(v_InitialCount).ItemDetailSubtype);
      END IF;
      --
   ELSIF (v_Changed = FALSE) THEN
      --
      x_QuantityDate(v_Count).PlannedReceiveDate := x_StartDateTime;
      --
      x_QuantityDate(v_Count).PlannedShipmentDate := x_StartDateTime;
      --
      x_QuantityDate(v_Count).PrimaryQuantity := x_PrimaryQuantity;
      --
      x_QuantityDate(v_Count).ItemDetailSubtype := g_Day;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG ,'PlannedReceiveDate ',
                       x_QuantityDate(v_Count).PlannedReceiveDate);
         rlm_core_sv.dlog(g_DEBUG, 'PlannedShipmentDate ',
                       x_QuantityDate(v_Count).PlannedShipmentDate);
         rlm_core_sv.dlog(g_DEBUG, 'PrimaryQuantity ',
                       x_QuantityDate(v_Count).PrimaryQuantity);
      END IF;
      --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(g_SDEBUG,'successful');
   END IF;
   --
EXCEPTION
   --
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_ship_delivery_pattern_sv.apply_sdp_to_weekly_bucket', v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END apply_sdp_to_weekly_bucket;


/*=============================================================================

PROCEDURE NAME: apply_sdp_to_daily_bucket

==============================================================================*/

PROCEDURE apply_sdp_to_daily_bucket(
           x_input         IN rlm_ship_delivery_pattern_sv.t_InputRec,
           x_ItemDetailSubtype     IN    VARCHAR2,
           x_DailyPercent  IN rlm_core_sv.t_NumberTable,
           x_StartDateTime         IN    DATE,
           x_PrimaryQuantity       IN    NUMBER,
           x_QuantityDate  IN OUT NOCOPY rlm_ship_delivery_pattern_sv.t_OutputTable)
IS
   v_Progress        VARCHAR2(3)  :='010';
   x_message         VARCHAR2(4000);

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'apply_sdp_to_daily_bucket');
      rlm_core_sv.dlog(g_DEBUG,'CustomerId',x_Input.CustomerId);
      rlm_core_sv.dlog(g_DEBUG,'ShipFromOrgId',x_Input.ShipFromOrgId);
      rlm_core_sv.dlog(g_DEBUG,'x_ItemDetailSubtype', x_Input.ItemDetailSubtype  );
      rlm_core_sv.dlog(g_DEBUG,'x_StartDateTime', x_Input.StartDateTime);
      rlm_core_sv.dlog(g_DEBUG,'x_PrimaryQuantity',x_Input.PrimaryQuantity);
   END IF;
   --
   IF(RLM_TPA_SV.valid_sdp_date(x_Input,x_DailyPercent)) THEN
      --
      x_QuantityDate(1).PlannedReceiveDate := x_Input.StartDateTime;
      x_QuantityDate(1).PlannedShipmentDate := x_Input.StartDateTime;
      --
   ELSE
      --
      x_QuantityDate(1).PlannedReceiveDate :=
                RLM_TPA_SV.previous_valid_sdp_date(x_Input,
                x_Input.StartDateTime, x_DailyPercent);
      x_QuantityDate(1).PlannedShipmentDate :=
               x_QuantityDate(1).PlannedReceiveDate;
      --
   END IF;
   --
   x_QuantityDate(1).PrimaryQuantity := x_Input.PrimaryQuantity;
   x_QuantityDate(1).ItemDetailSubtype := g_Day;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'x_QuantityDate(1).PlannedReceiveDate',
                             x_QuantityDate(1).PlannedReceiveDate);
      rlm_core_sv.dlog(g_DEBUG,'x_QuantityDate(1).PlannedShipmentDate',
                             x_QuantityDate(1).PlannedShipmentDate);
      rlm_core_sv.dlog(g_DEBUG,'x_QuantityDate(1).PrimaryQuantity',
                             x_QuantityDate(1).PrimaryQuantity);
      rlm_core_sv.dlog(g_DEBUG,'x_QuantityDate(1).ItemDetailSubtype',
                             x_QuantityDate(1).ItemDetailSubtype);
      rlm_core_sv.dpop(g_SDEBUG,'successful');
   END IF;
   --
END apply_sdp_to_daily_bucket;


/*=============================================================================

FUNCTION NAME:  check_start_date

==============================================================================*/

FUNCTION check_start_date(
                   x_Input      IN rlm_ship_delivery_pattern_sv.t_InputRec,
                   x_BucketType IN VARCHAR2)
RETURN BOOLEAN
IS
   v_Progress        VARCHAR2(3)  :='010';
   v_ReturnStatus      BOOLEAN := TRUE;
   x_message         VARCHAR2(4000);

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'check_start_date');
      rlm_core_sv.dlog(g_DEBUG, 'x_StartDateTime', x_Input.StartDateTime  );
      rlm_core_sv.dlog(g_DEBUG, 'x_BucketType', x_BucketType   );
      rlm_core_sv.dlog(g_DEBUG, 'v_ReturnStatus', v_ReturnStatus );
   END IF;

   --
   -- Bug 1867988
   -- Do not validate x_Input.StartDateTime for quarterly and monthly buckets
/*
   IF (x_BucketType='QUARTER') THEN
      --
      IF (to_char(x_Input.StartDateTime,'DD-MM')
                            IN ('01-01','01-04','01-07','01-10')) THEN
         v_ReturnStatus := TRUE;
      ELSE
         v_ReturnStatus := FALSE;
      END IF;
      --
   ELSIF (x_BucketType='MONTH') THEN
      IF (to_char(x_Input.StartDateTime,'DD-MM') IN ('01-01',
                                               '01-02',
                                               '01-03',
                                               '01-04',
                                               '01-05',
                                               '01-06',
                                               '01-07',
                                               '01-08',
                                               '01-09',
                                               '01-10',

                                               '01-12')) THEN
         v_ReturnStatus := TRUE;
      ELSE
         v_ReturnStatus := FALSE;
      END IF;
*/

/*
   ELSIF (x_BucketType='WEEK') THEN
      IF (to_char(x_StartDateTime,'D')= g_MondayDOW) THEN
          v_ReturnStatus := TRUE;
      ELSE
          v_ReturnStatus := FALSE;
      END IF;

   END IF;
*/

   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' v_ReturnStatus', v_ReturnStatus  );
      rlm_core_sv.dpop(g_SDEBUG,'check_start_date exited');
   END IF;
   --
   RETURN(v_ReturnStatus);
   --
END check_start_date;


/*=============================================================================

FUNCTION NAME:  find_monday_date

==============================================================================*/

FUNCTION  find_monday_date(x_Input  IN rlm_ship_delivery_pattern_sv.t_InputRec,
                            x_Date  IN DATE)
RETURN DATE
IS
   v_MondayDate      DATE;
   x_message         VARCHAR2(4000);
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'find_monday_date');
      rlm_core_sv.dlog(g_DEBUG,' x_Date', x_Date   );
      rlm_core_sv.dlog(g_DEBUG,' g_SundayDOW ', g_SundayDOW);
   END IF;
   --
   IF (to_char(x_Date,'D') = g_SundayDOW ) THEN
       v_MondayDate := x_Date + 1;
   ELSE
       v_MondayDate := x_Date - (to_number(to_char(x_Date,'D'))- g_MondayDOW);
   END IF;
   --
/*
   IF (to_char(x_Date,'D') = '1') THEN
      v_MondayDate := x_Date + 1;
   ELSE
      v_MondayDate := x_Date - (to_number(to_char(x_Date,to_char(to_date('01/06/1997','DD/MM/YYYY'))'D'))-2);
   END IF;
*/
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' v_MondayDate ', v_MondayDate);
      rlm_core_sv.dpop(g_SDEBUG,'value returned');
   END IF;
   --
   RETURN(v_MondayDate);
   --
END find_monday_date;


/*=============================================================================

FUNCTION NAME:  valid_sdp_date

==============================================================================*/

FUNCTION  valid_sdp_date(
               x_Input        IN rlm_ship_delivery_pattern_sv.t_InputRec,
               x_DailyPercent IN rlm_core_sv.t_NumberTable)
RETURN BOOLEAN
IS
   v_Valid         BOOLEAN := FALSE;
   v_DayCount      NUMBER := 1;
   x_message       VARCHAR2(4000);
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'valid_sdp_date');
      rlm_core_sv.dlog(g_DEBUG,'x_Date', x_Input.StartDateTime);
      --rlm_core_sv.dlog(g_DEBUG,'x_DailyPercent', x_DailyPercent);
   END IF;
   --
   WHILE ((v_Valid = FALSE) AND (v_DayCount<7)) LOOP
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG, 'v_DayCount', v_DayCount);
      END IF;
      --
      IF ((to_number(to_char(x_Input.StartDateTime,'D'))=
           (v_DayCount)) AND (x_DailyPercent(v_DayCount)>0)) THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'v_Valid is', TRUE);
         END IF;
         --
         v_Valid := TRUE ;
         --
      END IF;
      --
      v_DayCount := v_DayCount +1;
      --
   END LOOP;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_Valid', v_Valid);
      rlm_core_sv.dpop(g_SDEBUG,'value returned');
   END IF;
   --
   RETURN(v_Valid);
   --
END valid_sdp_date;

/*=============================================================================

FUNCTION NAME:  previous_valid_sdp_date

==============================================================================*/

FUNCTION previous_valid_sdp_date(
                x_Input        IN rlm_ship_delivery_pattern_sv.t_InputRec,
                x_Date         IN DATE,
                x_DailyPercent IN rlm_core_sv.t_NumberTable)
RETURN DATE
IS
   v_FOUND            BOOLEAN := FALSE;
   v_DayOfTheWeek     NUMBER;
   v_Count            NUMBER;
   v_ReturnDate       DATE;
   v_SubtractDays     NUMBER :=1;
   x_message          VARCHAR2(4000);

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'previous_valid_sdp_date');
      rlm_core_sv.dlog(g_DEBUG,'x_Date ', x_Date   );
   END IF;
   --
   v_DayOfTheWeek := to_number(to_char(x_Date,'D'));
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_DayOfTheWeek', v_DayOfTheWeek);
   END IF;
   --
   IF (v_DayOfTheWeek = 1) THEN
       v_Count := 7;
   ELSE
       v_Count := v_DayOfTheWeek - 1;
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,'v_Count', v_Count);
   END IF;
   --
   WHILE ((v_Count>0) AND (v_FOUND=FALSE)) LOOP
         --
         IF (x_DailyPercent(v_Count) > 0) THEN
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'v_FOUND is  ', TRUE);
            END IF;
            --
            v_FOUND := TRUE;
            v_ReturnDate := x_Date - v_SubtractDays;
	    --
	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'v_ReturnDate      ', v_ReturnDate);
            END IF;
	    --
         END IF;
	 --
         v_Count := v_Count - 1;
         --
	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'v_Count', v_Count);
         END IF;
         --
         v_SubtractDays := v_SubtractDays + 1;
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'v_SubtractDays', v_SubtractDays);
         END IF;
         --
   END LOOP;
   --
   IF ((v_DayOfTheWeek <> 1)AND(v_FOUND=FALSE)) THEN
      v_Count := 7;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,'v_Count', v_Count);
      END IF;
      --
      WHILE ( (v_Count>(v_DayOfTheWeek-1)) AND (v_FOUND=FALSE) ) LOOP
         --
         IF (x_DailyPercent(v_Count) > 0) THEN
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'v_FOUND is', TRUE);
            END IF;
            --
            v_FOUND := TRUE;
            v_ReturnDate := x_Date - v_SubtractDays;
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(g_DEBUG,'v_ReturnDate      ', v_ReturnDate);
            END IF;
            --
         END IF;
         --
         v_Count := v_Count - 1;
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'v_Count', v_Count);
         END IF;
         --
         v_SubtractDays := v_SubtractDays + 1;
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'v_SubtractDays', v_SubtractDays);
         END IF;
         --
      END LOOP;
      --
   END IF;
   --
   IF (v_FOUND = FALSE) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(g_DEBUG,'v_FOUND is  ', FALSE);
          rlm_core_sv.dpop(g_SDEBUG,'unsuccessful');
       END IF;
       --
       RETURN(x_Date - 1);
       --
   ELSE
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG,'v_ReturnDate     ', v_ReturnDate);
         rlm_core_sv.dpop(g_SDEBUG,'value returned successfully');
      END IF;
      --
      RETURN(v_ReturnDate);
      --
   END IF;
   --
EXCEPTION
  --
  WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'previous_valid_sdp_date '||'EXCEPTION:
                                '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END previous_valid_sdp_date;


/*=============================================================================

FUNCTION NAME:  check_receive_date

==============================================================================*/

FUNCTION  check_receive_date(x_Input IN rlm_ship_delivery_pattern_sv.t_InputRec,
                             x_ReceiveDate   IN    DATE)
RETURN BOOLEAN
IS
   --
   v_WorkingDay BOOLEAN := TRUE;
   v_ErrCode NUMBER;
   v_ErrMesg VARCHAR2(100);
   x_message         VARCHAR2(4000);
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'check_receive_date');
      rlm_core_sv.dlog(g_DEBUG,'x_ShipToAddressId ',x_Input.ShipToAddressId);
      rlm_core_sv.dlog(g_DEBUG,'x_ReceiveDate ',x_ReceiveDate);
      rlm_core_sv.dlog(g_DEBUG,'x_CalCode',x_Input.customer_rcv_calendar_cd);
   END IF;
   --
   -- Bug 3733396 : Call BOM API only if we have a valid RECEIVING calendar
   --
   IF x_Input.customer_rcv_calendar_cd IS NOT NULL THEN
     --
     bom_calendar_api_bk.check_working_day(x_Input.customer_rcv_calendar_cd,
  				   	   x_ReceiveDate,
					   v_WorkingDay,
					   v_ErrCode,
					   v_ErrMesg);
     --
   END IF;
   --
   if(v_WorkingDay = TRUE) then
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dpop(g_SDEBUG,'returns TRUE');
        END IF;
        --
        return(TRUE);
        --
     else
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dpop(g_SDEBUG,'returns FALSE');
        END IF;
        --
        return(FALSE);
        --
   end if;

END check_receive_date;

/*=============================================================================

PROCEDURE NAME:  determine_receive_date

==============================================================================*/

PROCEDURE determine_receive_date(x_Input  IN    RLM_SHIP_DELIVERY_PATTERN_SV.t_InputRec,
                         x_DailyPercent   IN     rlm_core_sv.t_NumberTable,
                         x_ReceiveDate    IN OUT NOCOPY DATE)
IS

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'determine_receive_date');
   END IF;
   --
  -- rlm_core_sv.dlog(g_DEBUG,' x_DailyPercent ',x_DailyPercent);
   --
   x_ReceiveDate := RLM_TPA_SV.previous_valid_sdp_date( x_Input,
                              x_ReceiveDate,x_DailyPercent);
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' x_ReceiveDate ',x_ReceiveDate);
      rlm_core_sv.dpop(g_SDEBUG,'value returned');
   END IF;
   --
END determine_receive_date;

/*=============================================================================

PROCEDURE NAME:  apply_lead_time

==============================================================================*/

PROCEDURE apply_lead_time (x_LeadTime            IN       t_LeadTimeRec,
                           x_QuantityDateRec    IN OUT NOCOPY   t_OutputRec,
                           x_LeadType            IN         VARCHAR2)
IS

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'apply_lead_time');
      rlm_core_sv.dlog(g_DEBUG,' x_LeadTime.Time ',x_LeadTime.Time);
      rlm_core_sv.dlog(g_DEBUG,' x_LeadTime.Uom ',x_LeadTime.Uom);
      rlm_core_sv.dlog(g_DEBUG,' x_QuantityDateRec.PlannedShipmentDate ',x_QuantityDateRec.PlannedShipmentDate);
      rlm_core_sv.dlog(g_DEBUG,' x_QuantityDateRec.PlannedReceiveDate ',x_QuantityDateRec.PlannedReceiveDate);
      rlm_core_sv.dlog(g_DEBUG,' x_LeadType ',x_LeadType);
   END IF;
   --
   IF (x_LeadType = 'SUBTRACT') THEN
      IF (x_LeadTime.Uom = 'DAY') THEN
         x_QuantityDateRec.PlannedShipmentDate := x_QuantityDateRec.PlannedReceiveDate - x_LeadTime.Time;
      ELSIF (x_LeadTime.Uom = 'HR') THEN
         x_QuantityDateRec.PlannedShipmentDate := x_QuantityDateRec.PlannedReceiveDate - (x_LeadTime.Time/24);
      END IF;
   ELSIF (x_LeadType = 'ADD') THEN
      IF (x_LeadTime.Uom = 'DAY') THEN
         x_QuantityDateRec.PlannedReceiveDate := x_QuantityDateRec.PlannedShipmentDate + x_LeadTime.Time;
      ELSIF (x_LeadTime.Uom = 'HR') THEN
         x_QuantityDateRec.PlannedReceiveDate := x_QuantityDateRec.PlannedReceiveDate - (x_LeadTime.Time/24);
      END IF;
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' x_QuantityDateRec.PlannedShipmentDate ',x_QuantityDateRec.PlannedShipmentDate);
      rlm_core_sv.dlog(g_DEBUG,' x_QuantityDateRec.PlannedReceiveDate ',x_QuantityDateRec.PlannedReceiveDate);
      rlm_core_sv.dpop(g_SDEBUG,'successful');
   END IF;
   --
END apply_lead_time;

/*=============================================================================

FUNCTION NAME:  check_send_date

==============================================================================*/

FUNCTION check_send_date (x_Input         IN RLM_SHIP_DELIVERY_PATTERN_SV.t_InputRec,
                          x_ShipmentDate  IN DATE)
RETURN BOOLEAN
IS
   --
   v_WorkingDay BOOLEAN := FALSE;
   v_ErrCode NUMBER;
   v_ErrMesg VARCHAR2(100);
   x_message         VARCHAR2(4000);
   --

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'check_send_date');
      rlm_core_sv.dlog(g_DEBUG,' x_ShipFromOrgId ',x_Input.ShipFromOrgId);
      rlm_core_sv.dlog(g_DEBUG,' x_ShipmentDate ',x_ShipmentDate);
      rlm_core_sv.dlog(g_DEBUG,' x_CalCode ',x_Input.supplier_shp_calendar_cd);
   END IF;
   --
   bom_calendar_api_bk.check_working_day(x_Input.supplier_shp_calendar_cd,
                                         x_ShipmentDate,
                                         v_WorkingDay,
                                         v_ErrCode,
                                         v_ErrMesg);
   --
   if(v_WorkingDay = TRUE) then
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'returns TRUE');
      END IF;
      --
      return(TRUE);
      --
   else
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'returns FALSE');
      END IF;
      --
      return(FALSE);
      --
   end if;

END check_send_date;

/*=============================================================================

PROCEDURE NAME:  determine_send_date

==============================================================================*/

PROCEDURE determine_send_date(
                     x_Input         IN rlm_ship_delivery_pattern_sv.t_InputRec,
                     x_DailyPercent  IN  rlm_core_sv.t_NumberTable,
                     x_ShipmentDate  IN OUT NOCOPY DATE)
IS

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'determine_send_date');
      rlm_core_sv.dlog(g_DEBUG,' x_ShipmentDate ',x_ShipmentDate);
   END IF;
   --
   x_ShipmentDate := RLM_TPA_SV.previous_valid_sdp_date(x_Input,x_ShipmentDate,x_DailyPercent);
   /*IF Shipping calendar says it is not possible to ship then backup date to
   the previous valid date according to SDP*/
   null;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(g_SDEBUG,'does nothing');
   END IF;
   --
EXCEPTION
  WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'determine_send_date '||'EXCEPTION:
                                '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
END determine_send_date;

/*=============================================================================

PROCEDURE NAME:  get_err_msg

==============================================================================*/

PROCEDURE get_err_message (
               x_ErrorMessage     IN     VARCHAR2,
               x_ErrorMessageName IN     VARCHAR2,
               x_ErrorType        IN     NUMBER,
               x_ErrMsgTab        IN OUT NOCOPY t_ErrorMsgTable)
IS
   --
   v_index BINARY_INTEGER;
   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'get_err_message');
   END IF;
   --
   v_index := nvl(x_ErrMsgTab.LAST, 0) + 1;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG,' Index ',v_index);
      rlm_core_sv.dlog(g_DEBUG,' x_ErrorMessage ',x_ErrorMessage);
   END IF;
   --
   x_ErrMsgTab(v_index).ErrMessage := x_ErrorMessage;
   x_ErrMsgTab(v_index).ErrMessageName := x_ErrorMessageName;
   x_ErrMsgTab(v_index).ErrType := x_ErrorType;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(g_SDEBUG);
   END IF;
   --
END get_err_message;

/*===========================================================================

        FUNCTION NAME:  GetTPContext

===========================================================================*/
PROCEDURE GetTPContext(
             x_Input              IN rlm_ship_delivery_pattern_sv.t_InputRec,
             x_customer_number             OUT NOCOPY VARCHAR2,
             x_ship_to_ece_locn_code       OUT NOCOPY VARCHAR2,
             x_bill_to_ece_locn_code       OUT NOCOPY VARCHAR2,
             x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
             x_tp_group_code               OUT NOCOPY VARCHAR2)
IS
   --
   v_Progress      VARCHAR2(3) := '010';
   --
   -- Following cursor is changed as per TCA obsolescence project.
   CURSOR C is
	SELECT	ETG.TP_GROUP_CODE
	INTO	x_tp_group_code
	FROM	ECE_TP_GROUP ETG,
		ECE_TP_HEADERS ETH,
		HZ_CUST_ACCT_SITES ACCT_SITE
	WHERE	ETG.TP_GROUP_ID = ETH.TP_GROUP_ID
	and	ETH.TP_HEADER_ID = ACCT_SITE.TP_HEADER_ID
	and	ACCT_SITE.CUST_ACCOUNT_ID = x_Input.ShiptoCustomerId
	and	ACCT_SITE.CUST_ACCT_SITE_ID = x_Input.ShipToAddressId;


   --
BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(g_SDEBUG,'GetTPContext');
      rlm_core_sv.dlog(g_DEBUG,'customer_id', x_Input.CustomerId);
      rlm_core_sv.dlog(g_DEBUG,'ship_to_address_id', x_Input.ShipToAddressId);
      rlm_core_sv.dlog(g_DEBUG,'bill_to_address_id', x_Input.BillToAddressId);
      rlm_core_sv.dlog(g_DEBUG,'INtShipToAddressId',
                             x_Input.IntShipToAddressId);
   END IF;
   --
   BEGIN
     --
     -- Following query is changed as per TCA obsolescence project.
     SELECT 	ece_tp_location_code
     INTO   	x_ship_to_ece_locn_code
     FROM   	HZ_CUST_ACCT_SITES		 ACCT_SITE
     WHERE  	ACCT_SITE.CUST_ACCT_SITE_ID = x_Input.ShipToAddressId;
     --
   EXCEPTION
     --
     WHEN NO_DATA_FOUND THEN
         x_ship_to_ece_locn_code := NULL;
     WHEN OTHERS THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
         END IF;
         --
         raise;
   END;

   BEGIN
     --
     -- Following query is changed as per TCA obsolescence project.
     SELECT 	ece_tp_location_code
     INTO  	x_bill_to_ece_locn_code
     FROM   	HZ_CUST_ACCT_SITES		 ACCT_SITE
     WHERE  	ACCT_SITE.CUST_ACCT_SITE_ID = x_Input.BillToAddressId;
     --
   EXCEPTION
     --
      WHEN NO_DATA_FOUND THEN
         x_bill_to_ece_locn_code := NULL;
      WHEN OTHERS THEN
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
         END IF;
         --
         raise;
     --
   END;

   BEGIN
     --
     -- Following query is changed as per TCA obsolescence project.
     SELECT 	ece_tp_location_code
     INTO  	x_inter_ship_to_ece_locn_code
     FROM   	HZ_CUST_ACCT_SITES		ACCT_SITE
     WHERE  	ACCT_SITE.CUST_ACCT_SITE_ID = x_Input.IntShipToAddressId;
     --
   EXCEPTION
     --
      WHEN NO_DATA_FOUND THEN
         x_inter_ship_to_ece_locn_code := NULL;
      WHEN OTHERS THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(g_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
         END IF;
         --
         raise;
     --
   END;
   --
   IF x_Input.CustomerId is NOT NULL THEN
      --
      BEGIN
        --
        -- Following query is changed as per TCA obsolescence project.
	SELECT	account_number
	INTO	x_customer_number
	FROM	HZ_CUST_ACCOUNTS CUST_ACCT
	WHERE	CUST_ACCT.CUST_ACCOUNT_ID = x_Input.CustomerId;
        --
      EXCEPTION
         --
         WHEN NO_DATA_FOUND THEN
              x_customer_number := NULL;
         WHEN OTHERS THEN
              --
              IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(g_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
              END IF;
              --
              raise;
      END;
      --
      OPEN C;
      FETCH C INTO x_tp_Group_code;
      IF C%NOTFOUND THEN
         raise NO_DATA_FOUND;
      END IF;
      CLOSE C;
      --
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(g_DEBUG, 'customer_number', x_customer_number);
      rlm_core_sv.dlog(g_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
      rlm_core_sv.dlog(g_DEBUG,'x_bill_to_ece_locn_code', x_bill_to_ece_locn_code);
      rlm_core_sv.dlog(g_DEBUG,'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
      rlm_core_sv.dlog(g_DEBUG,'x_tp_Group_code', x_tp_Group_code);
      rlm_core_sv.dpop(g_SDEBUG);
   END IF;
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
      --
      x_tp_Group_code := NULL;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(g_DEBUG, 'No data found for x_tp_Group_code');
         rlm_core_sv.dpop(g_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      --
      rlm_message_sv.sql_error('rlm_ship_delivery_pattern_sv.GetTPContext',v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(g_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetTPContext;

END rlm_ship_delivery_pattern_sv;

/
