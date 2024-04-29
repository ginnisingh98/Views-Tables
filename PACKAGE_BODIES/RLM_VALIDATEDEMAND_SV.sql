--------------------------------------------------------
--  DDL for Package Body RLM_VALIDATEDEMAND_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_VALIDATEDEMAND_SV" as
/* $Header: RLMDPVDB.pls 120.15.12010000.3 2009/08/07 09:27:30 sunilku ship $*/
/*=========================RLM_VALIDATEDEMAND_SV ===========================*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
/*===========================================================================

  PROCEDURE InitializeGroup

===========================================================================*/

PROCEDURE InitializeGroup(x_header_id IN NUMBER,
                          x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                          p_caller IN VARCHAR2 DEFAULT NULL)
IS

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'InitializeGroup');
     rlm_core_sv.dlog(C_DEBUG,'x_header_id',x_header_id);
     rlm_core_sv.dlog(C_DEBUG,'g_header_rec.schedule_type',
                            g_header_rec.schedule_type);
     rlm_core_sv.dlog(C_DEBUG,'p_caller',p_caller);
  END IF;
  --

  IF g_header_rec.schedule_type <> 'SEQUENCED' AND nvl(p_caller,'NULL') <> 'Header' THEN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'p_caller',p_caller);
   END IF;
   --
    OPEN x_Group_ref FOR
      SELECT   'N',
               ril.schedule_item_num,
               null,
               null,
               null,
               null,
               null,
               null
      FROM     rlm_interface_headers   rih,
               rlm_interface_lines_all ril
      WHERE    ril.header_id = rih.header_id
      AND      rih.header_id = x_header_id
      AND      rih.org_id = ril.org_id
      GROUP BY schedule_item_num;
   --
  ELSE
   --
  /*2313139*/

    IF g_header_rec.schedule_source <> 'MANUAL' THEN
     --
      OPEN x_Group_ref FOR
        SELECT   'S',
                 null,
                 ril.cust_ship_from_org_ext,
                 ril.cust_ship_to_ext,
                 ril.customer_item_ext,
                 null,
                 null,
                 null
        FROM     rlm_interface_headers rih,
                 rlm_interface_lines_all ril
        WHERE    ril.header_id = rih.header_id
        AND      rih.header_id = x_header_id
        AND      rih.org_id = ril.org_id
        GROUP BY cust_ship_from_org_ext, cust_ship_to_ext,
                 customer_item_ext;
     --
    ELSE
     --
      OPEN x_Group_ref FOR
      SELECT   'S',
               null,
               null,
               null,
               null,
               ril.customer_item_id,
               ril.ship_from_org_id,
               ril.ship_to_address_id
      FROM     rlm_interface_headers rih,
               rlm_interface_lines_all ril
      WHERE    ril.header_id = rih.header_id
      AND      rih.header_id = x_header_id
      AND      rih.org_id = ril.org_id
      GROUP BY customer_item_id,
               ship_from_org_id,
               ship_to_address_id;

    END IF;
     --
  /*2313139*/
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
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
  --
END InitializeGroup;

/*===========================================================================

  FUNCTION FetchGroup

===========================================================================*/
FUNCTION FetchGroup(x_Group_ref IN OUT NOCOPY t_Cursor_ref,
                    x_Group_rec IN OUT NOCOPY t_Group_rec)
RETURN BOOLEAN
IS

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'FetchGroup');
  END IF;
  --
    FETCH x_Group_ref INTO
     x_Group_rec.group_type,
     x_Group_rec.schedule_item_num,
     x_Group_rec.cust_ship_from_org_ext,
     x_Group_rec.cust_ship_to_ext,
     x_Group_rec.customer_item_ext,
     x_Group_rec.customer_item_id,
     x_group_rec.ship_from_org_id,
     x_group_rec.ship_to_address_id;
  --
  IF x_Group_ref%NOTFOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'false');
    END IF;
    --
    RETURN(FALSE);
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'group_type',x_Group_rec.group_type);
       rlm_core_sv.dlog(C_DEBUG,'schedule_item_num',x_Group_rec.schedule_item_num);
       rlm_core_sv.dpop(C_SDEBUG, 'true');
    END IF;
    --
    RETURN(TRUE);
    --
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;
      --
END FetchGroup;

/*===========================================================================

	PROCEDURE NAME: CheckHeaderECETpLocCode

===========================================================================*/

PROCEDURE CheckHeaderECETpLocCode(x_header_rec  IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE,
                                  x_ReturnStatus  OUT NOCOPY NUMBER)
IS
  --
  v_progress            VARCHAR2(10) := '010';
  v_Group_ref           t_Cursor_ref;
  v_Group_rec           t_Group_rec;
  v_shiptocustomerid    NUMBER;
  v_prevshiptocustomerid    NUMBER;
  e_NullHeaderLocCode   EXCEPTION;
  e_InvalidTPLocCode    EXCEPTION;
  v_ReturnStatus        VARCHAR2(10);
  v_MsgCount            NUMBER;
  v_MsgData             VARCHAR2(2000);
  v_Customer            VARCHAR2(35);
  v_ShipToLoc           VARCHAR2(35);
  v_shipToAddressId     NUMBER;
  e_InvalidCustomerExt  EXCEPTION;
  e_NullCustomerExt     EXCEPTION;
  e_NullShipToExt       EXCEPTION;
  v_first               BOOLEAN;
  p_caller             VARCHAR2(3);
  --
  BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'CheckHeaderECETpLocCode');
       rlm_core_sv.dlog(C_DEBUG,'x_header_rec', x_header_rec.header_id);
    END IF;
    --
    IF x_header_rec.customer_id is NULL THEN
      --
      v_first := TRUE;
      --
      IF x_header_rec.ece_tp_location_code_ext IS NULL THEN
         --
         InitializeGroup(x_header_rec.header_id, v_Group_ref, 'Header');
         --
         v_progress := '020';
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'start of loop to check related ship to');
         END IF;
         --
         WHILE FetchGroup(v_Group_ref, v_Group_rec) LOOP
           --
            IF x_header_rec.customer_ext IS NOT NULL THEN
               --
               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'customer_ext ',x_header_rec.customer_ext);
               END IF;
               --
               v_Customer := x_header_rec.customer_ext;
               --
             ELSIF  x_header_rec.ece_tp_translator_code IS NOT NULL THEN
               --
               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'ece_tp_translator_code',
                                       x_header_rec.ece_tp_translator_code);
               END IF;
               --
               v_Customer := x_header_rec.ece_tp_translator_code;
               --
             ELSE
               --
               raise e_NullCustomerExt;
               --
             END IF;
             --
             IF v_group_rec.cust_ship_to_ext is NULL THEN
                --
                raise e_NullShipToExt;
                --
             END IF;
             --
             IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'cust_ship_to_ext',
                                       v_group_rec.cust_ship_to_ext);
             END IF;
             --
             ece_trading_partners_pub.get_tp_address(1, NULL, NULL, NULL,
                                          NULL, v_ReturnStatus, v_MsgCount,
                                          v_MsgData,
                                          v_customer,
                                          v_Group_rec.cust_ship_to_ext,
                                          'CUSTOMER',
                                          v_shipToCustomerId,
                                          v_shipToAddressId);
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'customer_id ', v_shipToCustomerId);
               rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id ', v_shipToAddressId);
             END IF;
             --
             IF v_shipToCustomerId is NULL THEN
                 --
                 SELECT DISTINCT ACCT_SITE.CUST_ACCOUNT_ID
                 INTO   v_shipToCustomerId
                 FROM   HZ_CUST_ACCT_SITES ACCT_SITE ,
                        ECE_TP_HEADERS eth
                 WHERE  ACCT_SITE.tp_header_id = eth.tp_header_id
                 AND    ACCT_SITE.ece_tp_location_code = v_Group_rec.cust_ship_to_ext
                 AND    eth.TP_REFERENCE_EXT1 = v_Customer;
                 --
             END IF;

             IF v_shipToCustomerId IS NULL THEN
                --
                raise e_invalidTPLocCode;
                --
             END IF;
             --
             IF v_shipToCustomerId <> v_prevShiptoCustomerId and NOT v_first THEN
                --
                raise e_NullHeaderLocCode;
                --
             END IF;
             --
             v_prevShiptoCustomerId := v_shipToCustomerId;
             --
             v_first := FALSE;
             --
         END LOOP; /* while loop */
         --
         CLOSE v_Group_ref;
         --
      END IF;
      --
      x_header_rec.customer_id := v_shipToCustomerId;
      --
     END IF;
     --
     x_returnStatus := rlm_core_sv.k_PROC_SUCCESS;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;

EXCEPTION
    WHEN e_NullCustomerExt THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    g_Schedule_PS := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_CUSTOMER_NULL',
                x_InterfaceHeaderId => x_header_rec.header_id,
                x_ValidationType => 'CUSTOMER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUSTOMER_NULL');
    END IF;
    --
  WHEN e_NullHeaderLocCode  THEN
     --
     x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
     x_returnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SCH_NULL_LOC_CODE_CR',
                x_InterfaceHeaderId => x_Header_Rec.header_id,
                x_Token1 => 'TRANSLATOR_CODE',
                x_value1 => x_header_rec.ece_tp_translator_code,
                x_ValidationType => 'CUSTOMER');
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: RLM_SCH_NULL_LOC_CODE_CR ',v_Progress);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
  WHEN NO_DATA_FOUND OR e_InvalidTPLocCode  THEN
     --
     x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
     g_Schedule_PS := rlm_core_sv.k_PS_ERROR;
     x_returnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     IF x_header_rec.ece_tp_translator_code IS NOT NULL THEN
        --
        rlm_message_sv.app_error(
                      x_ExceptionLevel => rlm_message_sv.k_error_level,
                      x_MessageName => 'RLM_TP_TRANSL_SHIPTO_INVALID',
                      x_InterfaceHeaderId => x_header_rec.header_id,
                      x_token1=>'TP_TRANSLATOR',
                      x_value1=>x_header_rec.ece_tp_translator_code,
                      x_token2=>'SHIP_TO',
                      x_value2=>v_group_rec.cust_ship_to_ext,
                      x_ValidationType => 'CUSTOMER');
        --
        IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
             rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_TP_TRANSL_SHIPTO_INVALID');
        END IF;
        --
     ELSE
        --
        rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_error_level,
                       x_MessageName => 'RLM_CUST_SHIP_TO_INVALID',
                       x_InterfaceHeaderId => x_header_rec.header_id,
                       x_token1=>'CUSTOMER_EXT',
                       x_value1=>x_header_rec.customer_ext,
                       x_token2=>'SHIP_TO',
                       x_value2=>v_group_rec.cust_ship_to_ext,
                       x_ValidationType => 'CUSTOMER');
        --
        IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
              rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUST_SHIP_TO_INVALID');
        END IF;
        --
     END IF;
     --
  WHEN e_NullShipToExt THEN
     --
     g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
     x_returnStatus := rlm_core_sv.k_PROC_ERROR;
     --
     g_Schedule_PS := rlm_core_sv.k_PS_ERROR;
     --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SHIPTO_NULL',
                x_InterfaceHeaderId => x_header_rec.header_id,
                x_token1=>'CUSTOMER_EXT',
                x_value1=>v_Customer,
                x_ValidationType => 'CUSTOMER');
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: RLM_SHIPTO_NULL ',v_Progress);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
  WHEN OTHERS THEN
     --
     g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
     x_returnStatus := rlm_core_sv.k_PROC_ERROR;
     rlm_message_sv.sql_error('rlm_validatedemand_sv.CheckHeaderECETpLocCode', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
END CheckHeaderECETpLocCode;

/*===========================================================================

	PROCEDURE NAME:  GroupValidateDemand

===========================================================================*/

PROCEDURE GroupValidateDemand(x_Header_Id IN RLM_INTERFACE_HEADERS.HEADER_ID%TYPE,
                              x_Procedure_Status OUT NOCOPY NUMBER)
IS
  --
  v_progress            VARCHAR2(10) := '010';
  x_ReturnStatus        NUMBER;
  v_Group_ref           t_Cursor_ref;
  v_Group_rec           t_Group_rec;
  curr_rec              NUMBER;
  v_bill_to_customer_id NUMBER Default NULL;
  v_first_time          BOOLEAN DEFAULT TRUE;
  e_no_record_found     EXCEPTION;
  e_error_found         EXCEPTION;
  setupterms_APIFailed  EXCEPTION;
  --
  e_InactiveBlanket	EXCEPTION;
  --
  BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'GroupValidateDemand');
       rlm_core_sv.dlog(C_DEBUG,'x_header_id',x_header_id);
    END IF;
    --
    -- we start with a schedule process status of an error
    -- if we find any one of the lines to be a success then we will
    -- update the status to success in UpdateInterfaceLines.
    -- This value of g_schedule_PS will be used to update the header PS
    -- IF no success record found then g_schedule_PS will remain as an ERROR
    --
    g_schedule_PS := rlm_core_sv.k_PS_ERROR;
    g_line_PS := rlm_core_sv.k_PS_AVAILABLE;
    --
    rlm_message_sv.initialize_dependency('VALIDATE_DEMAND');
    --
    IF NOT BuildHeaderRec(x_header_id) THEN
      --
      RAISE e_no_record_found;
      --
    END IF;
    --
    ApplyHeaderDefaults(g_header_rec);
    --
    v_progress := '020';
    --
    RLM_TPA_SV.ValidScheduleHeader(g_header_rec);
    --
    v_progress := '025';
    --
    CheckHeaderECETpLocCode(g_header_rec, x_ReturnStatus);
    --
    IF x_ReturnStatus =  rlm_core_sv.k_PROC_ERROR THEN
       raise e_error_found;
    END IF;
    --
    InitializeGroup(x_header_id, v_Group_ref);
    --
    v_progress := '030';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'start of loop');
    END IF;
    --
    WHILE FetchGroup(v_Group_ref, v_Group_rec) LOOP
      --
      BEGIN
       --
       v_progress := '040';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'v_Group_rec.group_type',
                                 v_Group_rec.group_type);
          rlm_core_sv.dlog(C_DEBUG,'v_Group_rec.schedule_item_num',
                                 v_Group_rec.schedule_item_num);
       END IF;
       --
       PopulateLinesTab(v_Group_rec);
       --
       v_progress := '060';
       --
       -- THis record is used to store the first record which is derived and
       -- validated for the entire line and then the values are assigned to
       -- the entire grouping of lines in assign_line_values
       v_progress := '070';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog (C_DEBUG,'before Group Validate loop/ COUNT',
                                          g_lines_tab.COUNT );
       END IF;
       --
       v_first_time := TRUE;
       --
       --Bug 5098241
       v_Group_rec.setup_terms_rec := NULL;

       FOR i IN 1..g_lines_tab.COUNT LOOP
         -- performance related changes have to go in here.
         -- instead of all the lines validations we need to
         -- change the loop to be inside each of the following.
         -- sub types e.g in DeriveCustomerID loop through all
         -- the values and derive only when the values change or else default
            --
            curr_rec := i;
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog (C_DEBUG,'Processing line' , g_lines_tab(i).line_id);
	       rlm_core_sv.dlog(C_DEBUG, 'Index i', i);
            END IF;

            --perf code some ids are derived per group only once

            IF(i=1) THEN
              --
              DeriveCustomerID(g_header_rec,g_lines_tab(i)) ;
              DeriveShipToID(g_header_rec, g_lines_tab(i));
              DeriveShipFromOrg(g_header_rec, g_lines_tab(i));
              RLM_TPA_SV.ValidateCustomerItem(g_header_rec, g_lines_tab(i));

            --
            ELSE
              --
              IF(NVL(g_lines_tab(i).cust_ship_to_ext,1) = NVL(g_lines_tab(1).cust_ship_to_ext,1)) THEN
                --
	        IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG, 'Line in same group, so copy IDs from first line');
                END IF;
	        --
                g_lines_tab(i).ship_to_address_id := NVL(g_lines_tab(1).ship_to_address_id, g_lines_tab(i).ship_to_address_id);
                --
                -- CR change
                g_lines_tab(i).ship_to_customer_id := NVL(g_lines_tab(1).ship_to_customer_id, g_lines_tab(i).ship_to_customer_id);
                --
                g_lines_tab(i).ship_to_org_id := NVL(g_lines_tab(1).ship_to_org_id,g_lines_tab(i).ship_to_org_id);

                g_lines_tab(i).ship_to_site_use_id := NVL(g_lines_tab(1).ship_to_site_use_id,g_lines_tab(i).ship_to_site_use_id);

                g_lines_tab(i).customer_item_id:= NVL(g_lines_tab(1).customer_item_id,g_lines_tab(i).customer_item_id);
                --
              ELSE
                --
	        IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG, 'Line in different group, so derive IDs again');
                END IF;
	        --
                DeriveCustomerID(g_header_rec,g_lines_tab(i)) ;
                DeriveShipToID(g_header_rec, g_lines_tab(i));
                RLM_TPA_SV.ValidateCustomerItem(g_header_rec, g_lines_tab(i));
                --
              END IF;

              g_lines_tab(i).ship_from_org_id := NVL(g_lines_tab(1).ship_from_org_id,
					g_lines_tab(i).ship_from_org_id);
              --
            END IF;

            --
            DeriveIntrmdShipToID(g_header_rec, g_lines_tab(i));
            --
	    RLM_TPA_SV.SetLineTPAttCategory(	g_header_rec,
				g_lines_tab(i),
				v_Group_rec);
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog (C_DEBUG,'after DeriveIDs/before CallSetups');
            END IF;
            --
            v_progress := '080';
            --
             IF (i=1) THEN /* Call setup terms once for each group */
               --
               IF NOT CallSetups(v_Group_rec, g_header_rec, g_lines_tab(i)) THEN
                 --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog (C_DEBUG,'Setup API failed for line ', g_lines_tab(i).line_id);
                 END IF;
	         --
                 g_lines_tab(i).process_status := rlm_core_sv.k_PS_ERROR;
                 --RAISE setupterms_APIFailed; --continue processing other lines
                --
               END IF;
               --
             ELSE

               IF(NVL(g_lines_tab(i).ship_to_address_id,1) <> NVL(g_lines_tab(1).ship_to_address_id,1)) THEN

                 IF NOT CallSetups(v_Group_rec, g_header_rec, g_lines_tab(i)) THEN
                   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog (C_DEBUG,'Setup API failed for line ', g_lines_tab(i).line_id);
                   END IF;
	           --
                   g_lines_tab(i).process_status := rlm_core_sv.k_PS_ERROR;
                   --RAISE setupterms_APIFailed; --continue processing other lines
                   --
                 END IF;
                 --
               END IF;
               --
             END IF;

             --global_atp
             IF g_lines_tab(i).ship_from_org_id IS NULL THEN
               --
               g_lines_tab(i).ship_from_org_id := v_Group_rec.setup_terms_rec.ship_from_org_id;
               --
             END IF;
             --
             DeriveBillToId(g_header_rec,
                            g_lines_tab(i),
                            v_Group_rec.setup_terms_rec.cum_org_level_code);
             --
             DeriveOrgDependentIDs (v_Group_rec.setup_terms_rec,
                                      g_header_rec, g_lines_tab(i));

            /** Bugfix  6185706  commented the performance changes
             --perf changes
             IF(i=1) THEN
               --
               RLM_TPA_SV.DeriveInventoryItemId(g_header_rec, g_lines_tab(i));
               --
             ELSE
               --
               IF(NVL(g_lines_tab(i).ship_to_address_id,1) <> NVL(g_lines_tab(1).ship_to_address_id,1)) THEN
                 --
                 RLM_TPA_SV.DeriveInventoryItemId(g_header_rec, g_lines_tab(i));
                 --
               ELSE
                 --
                 g_lines_tab(i).inventory_item_id := NVL(g_lines_tab(1).inventory_item_id,g_lines_tab(i).inventory_item_id);
                 --
               END IF;
               --
             END IF;

             --perf changes
             --
             **/
             v_progress := '80';
             --
             IF v_first_time
                AND g_lines_tab(i).Item_Detail_Type in ('0','1','2')
             THEN
              --
              -- All the lines within a group have the same PO and Cust_rec_year
              -- This procedure needs to be called once per group.
              --
              RLM_TPA_SV.CheckCUMKeyPO(v_group_rec,
                             g_header_rec,
                             g_lines_tab(i));
               --
               v_first_time := FALSE;
               --
             END IF;
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog (C_DEBUG,'process_status',g_lines_tab(i).process_status);
             END IF;
             --
             RLM_TPA_SV.ValidateLineDetails(v_Group_rec.setup_terms_rec,
                                   g_header_rec,
                                   g_lines_tab(i),
                                   k_ORIGINAL);
             --
             v_progress := '100';
             --
	     -- For blanket orders
	     --
	     IF (i=1) THEN
	      --
              IF v_Group_rec.setup_terms_rec.blanket_number IS NOT NULL THEN
               --
               DeriveBlanketPO(g_lines_tab(i).cust_po_number, v_Group_rec, x_header_id);
               --
	      END IF;
	      --
	     ELSE
	      --
	      IF g_lines_tab(i).blanket_number IS NOT NULL AND
		 g_lines_tab(i).blanket_number <> g_lines_tab(1).blanket_number THEN
	       --
               DeriveBlanketPO(g_lines_tab(i).cust_po_number, v_Group_rec, x_header_id);
               --
	      END IF;
	      --
	     END IF;
	     --
       END LOOP; /* for loop */
       --
       --
       -- Blanket Order should be validated after all IDs have been derived
       --
       IF v_Group_rec.setup_terms_rec.blanket_number IS NOT NULL THEN
	--
        IF NOT ValidateBlanket(v_Group_rec, g_Header_rec) THEN
	 --
         IF (l_debug <> -1) THEN
	   rlm_core_sv.dlog(C_DEBUG, 'ValidateBlanket failed');
	 END IF;
	 --
	 g_lines_tab(1).process_status := rlm_core_sv.k_PS_ERROR;
	 RAISE e_InactiveBlanket;
         --
        END IF;
        --
       END IF;
       --
       RLM_TPA_SV.UpdateInterfaceLines(g_header_rec);
       --
       --commit;
       --
       -- We need to reset_dependency so that the next group does not face the
       -- same dependency problem
       --
       rlm_message_sv.reset_dependency;
       --
       -- bug 4570658
       --
       g_lines_tab.DELETE;

      EXCEPTION
       --
        WHEN setupterms_APIFailed  THEN
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
          END IF;
          /* update error status for the entire group */
          RLM_TPA_SV.UpdateInterfaceLines(g_header_rec);
          --
        WHEN e_InactiveBlanket  THEN
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
          END IF;
	  --
          RLM_TPA_SV.UpdateInterfaceLines(g_header_rec);
          --
        WHEN OTHERS THEN
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
             rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: LOOP '||SUBSTR(SQLERRM,1,200));
             rlm_core_sv.dlog (C_DEBUG,'g_lines_tab(curr_rec).process_status',
                                     g_lines_tab(curr_rec).process_status);
          END IF;
          --
          g_lines_tab(curr_rec).process_status := rlm_core_sv.k_PS_ERROR;
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog (C_DEBUG,'g_lines_tab(curr_rec).process_status',
                                     g_lines_tab(curr_rec).process_status);
          END IF;
          --
          /* update error status for the entire group */
          RLM_TPA_SV.UpdateInterfaceLines(g_header_rec);
          --
      END;
      --
    END LOOP; /* while loop */
    --
    CLOSE v_Group_ref;
    --
    --bug 1560271
    --
    IF g_header_rec.process_status = rlm_core_sv.k_PS_ERROR THEN
      g_schedule_PS := rlm_core_sv.k_PS_ERROR;
    END IF;
    --
    UpdateInterfaceHeaders;
    --
    --commit;
    --
    x_procedure_status := rlm_core_sv.k_PROC_SUCCESS;
    --
    FOR i IN 1..rlm_message_sv.g_message_tab.COUNT LOOP
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Message: ',
                               rlm_message_sv.g_message_tab(i).message_name);
      END IF;
      --
    END LOOP;
    --
    --commit;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  EXCEPTION
   --
   WHEN e_error_found  THEN
     --
     x_procedure_status := rlm_core_sv.k_PROC_ERROR;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     --added by asutar
     UpdateInterfaceHeaders;
     --commit;
     --
   WHEN NO_DATA_FOUND  THEN
     --
     x_procedure_status := rlm_core_sv.k_PROC_ERROR;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     --added by asutar
     UpdateInterfaceHeaders;
     --commit;
     --
   WHEN e_no_record_found  THEN
     --
     x_procedure_status := rlm_core_sv.k_PROC_ERROR;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     --added by asutar
     UpdateInterfaceHeaders;
     --commit;
     --
  WHEN OTHERS THEN
     --
     x_procedure_status := rlm_core_sv.k_PROC_ERROR;
     rlm_message_sv.sql_error('rlm_validatedemand_sv.GroupValidateDemand', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     --added by asutar
     UpdateInterfaceHeaders;
     --commit;
     raise;
     --
END GroupValidateDemand;

/*===========================================================================

	PROCEDURE NAME:  ValidateLineDetails

===========================================================================*/
PROCEDURE ValidateLineDetails(
                  x_setup_terms_rec  IN rlm_setup_terms_sv.setup_terms_rec_typ,
                  x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                  x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE,
                  x_line_source IN VARCHAR2)
IS
  --
  v_progress            VARCHAR2(3) := '010';
  x_ForecastDesignator  VARCHAR2(30);
  --
BEGIN
  --
  IF rlm_message_sv.check_dependency('VALIDATE_LINES') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidateLineDetails');
    END IF;
    --
    IF x_line_source = k_ORIGINAL THEN
      --
      RLM_TPA_SV.ValidItemDetailType(x_header_rec, x_lines_rec);
      --
      RLM_TPA_SV.ValidItemDetailSubtype(x_header_rec, x_lines_rec);
      --
      RLM_TPA_SV.ValidQtyTypeCode(x_setup_terms_rec, x_header_rec, x_lines_rec);
      --
      RLM_TPA_SV.ValidItemDetailQty(x_header_rec, x_lines_rec);
      --
      RLM_TPA_SV.ValidDateTypeCode(x_header_rec, x_lines_rec);
      --
      RLM_TPA_SV.ValidDateRange(x_header_rec, x_lines_rec);
      --
      RLM_TPA_SV.ValidateUOM(x_header_rec, x_lines_rec);
      --
      --bug 1811536
      --RLM_TPA_SV.ValidPlanningProdSeqNum(x_setup_terms_rec,x_header_rec, x_lines_rec);
      --
      RLM_TPA_SV.ValidLineScheduleType(x_header_rec, x_lines_rec);
      --
      --performance changes
      --ValidForecastDesig(x_setup_terms_rec,x_header_rec, x_lines_rec,x_ForecastDesignator);
      --
    END IF;
    --
    -- Call to ValidOrderHeaderId should be made only if blankets are not setup.
    --
    IF x_setup_terms_rec.blanket_number IS NULL THEN
     --
     RLM_TPA_SV.ValidOrderHeaderId(x_setup_terms_rec, x_header_rec, x_lines_rec);
     x_lines_rec.blanket_number := x_setup_terms_rec.blanket_number;
     --
    ELSE
     --
     x_lines_rec.blanket_number := x_setup_terms_rec.blanket_number;
     x_lines_rec.order_header_id := x_setup_terms_rec.header_id;
     --
    END IF;
    --
    ValidateDateTypeATP(x_lines_rec);
    ValidateCriticalKeys(x_setup_terms_rec, x_header_rec, x_lines_rec);
    --
    --CheckCUMKeyPO(x_setup_terms_rec, x_header_rec, x_lines_rec);
    --
    v_progress := '060';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidateLineDetails',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'process_status',x_lines_rec.process_status);
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidateLineDetails;

/*===========================================================================

        PROCEDURE NAME:  GetOrderNumber

===========================================================================*/

FUNCTION  GetOrderNumber(x_order_header_id  IN NUMBER)
RETURN NUMBER
IS
  v_ord_num NUMBER;
BEGIN
   --
   SELECT order_number
   INTO v_ord_num
   FROM oe_order_headers_all
   WHERE header_id = x_order_header_id;
   --
   RETURN v_ord_num;
   --
EXCEPTION
   --
   WHEN NO_DATA_FOUND THEN
        RETURN null;
   --
   WHEN OTHERS  THEN
        raise;
   --
END GetOrderNumber;
/*===========================================================================

        PROCEDURE NAME:  ValidOrderHeaderId

===========================================================================*/

PROCEDURE ValidOrderHeaderId(
          x_setup_terms_rec   IN rlm_setup_terms_sv.setup_terms_rec_typ,
          x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  e_NoOrderDefined   EXCEPTION;
  e_OrderClosed      EXCEPTION;
  e_OrderIDMismatch  EXCEPTION;
  e_SalesOrderMissing EXCEPTION;
  e_SetupOrderMissing EXCEPTION;
  w_CustOrderInvalid EXCEPTION;
  x_Exists           NUMBER := 0;
  v_Progress         VARCHAR2(3) := '010';
  v_OpenFlag         VARCHAR2(1) ;
  v_OrderNumber      NUMBER ;

BEGIN

  IF rlm_message_sv.check_dependency('ORDER_HEADER') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidOrderHeaderId');
       rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.Order_header_Id',
                                  x_lines_rec.Order_header_Id);
    END IF;
    --
    IF x_lines_rec.cust_order_num_ext IS NULL THEN
       --{
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog('Order Number on Schedule is Null ');
          rlm_core_sv.dlog('Order Header Id Null. Using default Setup.');
       END IF;
       --
       IF x_setup_terms_rec.header_id IS NOT NULL THEN
           --{
           x_lines_rec.Order_header_id := x_setup_terms_rec.header_id;
	   --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'Order_header_Id',x_lines_rec.Order_header_Id);
           END IF;
           --
           SELECT open_flag, order_number
           INTO   v_OpenFlag, v_OrderNumber
           FROM   oe_order_headers_all
           WHERE  header_id = x_lines_rec.Order_header_id;
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'v_OpenFlag',v_OpenFlag);
              rlm_core_sv.dlog(C_DEBUG, 'v_OrderNumber', v_OrderNumber);
           END IF;
           --
           IF v_OpenFlag = 'N' then
             --
             raise e_OrderClosed;
             --
           END IF;
           --}
       ELSE
          --
          raise e_SalesOrderMissing;
          --
       END IF;
       --}
    ELSE
       --{
       BEGIN
         --{
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog('Order Number on schedule not Null ');
            rlm_core_sv.dlog(C_DEBUG,'cust_order_num_ext',
                                   x_lines_rec.cust_order_num_ext);
         END IF;
         --
         IF x_setup_terms_rec.header_id IS NOT NULL THEN
             --{
             SELECT order_number, open_flag
             INTO   v_Ordernumber, v_OpenFlag
             FROM   oe_order_headers_all
             WHERE  header_id =  x_setup_terms_rec.header_id;
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog('From setup terms');
                rlm_core_sv.dlog(C_DEBUG,'v_Ordernumber', v_Ordernumber);
                rlm_core_sv.dlog(C_DEBUG,'v_OpenFlag', v_OpenFlag);
             END IF;
             --
          BEGIN
             --{
             IF to_number(x_lines_rec.cust_order_num_ext) <> v_Ordernumber THEN
                --
  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog('Order Mismatch found, between setup terms and order number on schedule');
                END IF;
		--
                raise e_OrderIDMismatch;
                --
             END IF;
             --
             IF v_OpenFlag = 'N' THEN
              --
              IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG, 'Order is closed');
              END IF;
              --
              RAISE e_OrderClosed;
              --
             END IF;
             --
          EXCEPTION
              --
              WHEN e_OrderIDMismatch THEN
                 --
                 raise e_OrderIDMismatch;
                 --
              WHEN e_OrderClosed THEN
                 --
                 RAISE e_OrderClosed;
                 --
              WHEN OTHERS  THEN
                 --
                 raise invalid_number;
                 --
             --}
          END;
             --
             x_lines_rec.Order_header_id := x_setup_terms_rec.header_id;
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'Order_header_Id',
                                   x_lines_rec.Order_header_Id);
             END IF;
	     --}
         ELSE
             --
             raise e_SetupOrderMissing;
             --
         END IF;
         --
      EXCEPTION
         --
         WHEN NO_DATA_FOUND THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: e_SetupOrderMissing');
           END IF;
           --
           raise e_SetupOrderMissing;
           --
         WHEN INVALID_NUMBER THEN
           --
           rlm_message_sv.app_error(
                    x_ExceptionLevel => rlm_message_sv.k_warn_level,
                    x_MessageName => 'RLM_WARN_ORDER_INVALID_NUMBER',
                    x_InterfaceHeaderId => x_lines_rec.header_id,
                    x_InterfaceLineId => x_lines_rec.line_id,
                    x_token1=>'CUST_ORDER_NUM_EXT',
                    x_value1=>x_lines_rec.cust_order_num_ext,
                    x_ValidationType => 'ORDER_HEADER');
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: INVALID_NUMBER');
              rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: RLM_WARN_ORDER_INVALID_NUMBER');
           END IF;
           --
         WHEN  e_SetupOrderMissing THEN
           --
           raise;
           --
         WHEN OTHERS THEN
           --
           x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
	   --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: ValidOrderHeader'||SUBSTR(SQLERRM,1,200));
           END IF;
	   --
           raise ;
        --}
       END;
       --}
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Order_header_Id',x_lines_rec.Order_header_Id);
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;

EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SALES_ORDER_MISSING',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'ORDER_HEADER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_SALES_ORDER_MISSING');
    END IF;
    --
  WHEN  e_SalesOrderMissing THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SALES_ORDER_MISSING',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'ORDER_HEADER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_SALES_ORDER_MISSING');
    END IF;
    --
  WHEN  e_SetupOrderMissing THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SETUP_ORDER_MISSING',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'ORDER_HEADER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_SETUP_ORDER_MISSING');
    END IF;
    --
  WHEN e_NoOrderDefined THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    --
    -- Fetch relevant Cust_Order_num_ext for given header Id for error message
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SALES_ORDER_UNDEFINED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'CUST_ORDER_NUM_EXT',
                x_value1=>x_lines_rec.cust_order_num_ext,
                x_ValidationType => 'ORDER_HEADER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Order_header_Id',x_lines_rec.Order_header_Id);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SALES_ORDER_UNDEFINED');
    END IF;
    --
  WHEN e_OrderClosed THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SALES_ORDER_CLOSED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'CUST_ORDER_NUM_EXT',
                x_value1=>v_OrderNumber,
                x_ValidationType => 'ORDER_HEADER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SALES_ORDER_CLOSED');
    END IF;
    --
  WHEN e_OrderIDMismatch THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_ORDER_ID_MISMATCH',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'SCH_ORDER_NUM',
                x_value1=>GetOrderNumber(x_lines_rec.order_header_id),
                x_token2=>'SETUP_ORDER_NUM',
                x_value2=>GetOrderNumber(x_setup_terms_rec.header_id),
                x_ValidationType => 'ORDER_HEADER');

  IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Order_header_Id',x_lines_rec.Order_header_Id);
       rlm_core_sv.dlog(C_DEBUG,'x_setup_terms_rec.header_id',x_setup_terms_rec.header_id);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_ORDER_ID_MISMATCH');
    END IF;

  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.sql_error('rlm_validateDemand_sv.ValidOrderHeaderId',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'process_status',x_lines_rec.process_status);
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidOrderHeaderId;

/*===========================================================================

        PROCEDURE NAME:  ValidateUOM

===========================================================================*/
PROCEDURE ValidateUOM(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  v_Progress           VARCHAR(3) := '010';
  v_Primary_UOM_Code   VARCHAR(3);
  v_Primary_UOM_Class  VARCHAR(10);
  v_UOM_Class          VARCHAR(10);
  v_Cust_UOM_Class     VARCHAR(10);
  v_Cust_UOM_Code      VARCHAR(10);
  v_Count              NUMBER;
  e_UOMInactive        EXCEPTION;
  e_PrimaryCodeMissing EXCEPTION;
  e_NoConvPrimary      EXCEPTION;
  e_NoConvCustItemUOM  EXCEPTION;
  e_CustUOMDiff        EXCEPTION;
  x_Success            NUMBER := 1;

  CURSOR c_uom IS
    SELECT 1
    FROM MTL_UNITS_OF_MEASURE_vl
    WHERE UOM_CODE = x_lines_rec.uom_code;

  -- Bug 4176961
  CURSOR c_primary_uom IS
    SELECT PRIMARY_UOM_CODE
    FROM MTL_SYSTEM_ITEMS
    WHERE INVENTORY_ITEM_ID = x_lines_rec.INVENTORY_ITEM_ID
    AND ORGANIZATION_ID  =  x_lines_rec.ship_from_org_id;

BEGIN
  IF rlm_message_sv.check_dependency('UOM_CODE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidateUOM');
       rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.uom_code',x_lines_rec.UOM_CODE);
       rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.INVENTORY_ITEM_ID',x_lines_rec.INVENTORY_ITEM_ID);
       --global_atp
       rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.ship_from_org_id',x_lines_rec.ship_from_org_id);
    END IF;
  --
  OPEN c_uom ;
  --
  FETCH c_uom INTO x_success;
  --
  IF c_uom%NOTFOUND THEN
    --
    CLOSE c_uom;
    RAISE e_UOMInactive;
    --
  END IF;
  CLOSE c_uom; --4570658
  --
  -- Bug 4176961
  --
    OPEN c_primary_uom;
    --
    FETCH c_primary_uom iNTO v_Primary_UOM_Code;
    --
    x_lines_rec.primary_uom_code := v_Primary_UOM_Code;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'v_Primary_UOM_Code',v_Primary_UOM_Code);
    END IF;
    --
    v_Progress := '020';
    IF v_Primary_UOM_Code IS NULL THEN
        raise e_PrimaryCodeMissing;
    END IF;
  --
  -- Bug 4176961
  --
    IF v_Primary_UOM_Code <>  x_lines_rec.UOM_Code THEN
        g_convert_uom := TRUE;
    END IF;
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'g_convert_uom',g_convert_uom);
    END IF;
    --

/* THIS CHECK IS NOT NEEDED AS OE ACCEPTS ANY UOM SENT IN
SO WE DO NOT NEED TO verify that a conversion is available or not
    -- check if the primary UOM_Code is different

    IF v_Primary_UOM_Code <>  x_lines_rec.UOM_Code THEN
        SELECT Count(*)
        INTO   v_Count
        FROM MTL_UOM_CONVERSIONS a, MTL_UOM_CONVERSIONS b
        WHERE a.UOM_CODE = v_Primary_UOM_Code
        AND b.UOM_CODE = x_lines_rec.UOM_Code
        AND a.UOM_CLASS = b.UOM_CLASS ;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_Count',v_Count);
        END IF;
        --
        IF v_Count < 1 THEN
           raise e_NoConvPrimary;
        END IF;
    END IF;
*/
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;

EXCEPTION
  WHEN e_UOMInactive THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_UOM_INACTIVE',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'UOM_CODE',
                x_value1=>x_lines_rec.uom_code,
                x_ValidationType => 'UOM_CODE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_UOM_INACTIVE ');
    END IF;
    --
  WHEN NO_DATA_FOUND THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_UOM_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'UOM_CODE',
                x_value1=>x_lines_rec.uom_code,
                x_ValidationType => 'UOM_CODE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_UOM_INVALID ');
    END IF;
    --
  WHEN e_PrimaryCodeMissing THEN
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_WARN_NO_PRIMARY_UOM',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'UOM_CODE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_WARN_NO_PRIMARY_UOM');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.sql_error('rlm_validateDemand_sv.ValidateUOM', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidateUOM;
/*===========================================================================

	PROCEDURE NAME:  ValidDateRange

===========================================================================*/
PROCEDURE ValidDateRange(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress         VARCHAR2(3) := '010';
  e_DateRangeInv     EXCEPTION;
  e_StartHorizonInv  EXCEPTION;
  e_EndHorizonInv    EXCEPTION;
  e_StartDateInv     EXCEPTION;
  --
BEGIN
  --
  IF rlm_message_sv.check_dependency('DATE_RANGE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidDateRange');
       rlm_core_sv.dlog(C_DEBUG,'Horizon Start Date',
                             x_header_rec.sched_horizon_start_date);
       rlm_core_sv.dlog(C_DEBUG,'Horizon End Date',
                             x_header_rec.sched_horizon_end_date);
       rlm_core_sv.dlog(C_DEBUG,'Start_Date_Time',
                             x_lines_rec.start_date_time);
       rlm_core_sv.dlog(C_DEBUG,'End_Date_Time',
                             x_lines_rec.end_date_time);
    END IF;
    --
    IF (x_lines_rec.end_date_time is NOT NULL) AND
       (x_lines_rec.end_date_time < x_lines_rec.start_date_time)
    THEN
       raise e_DateRangeInv;
    END IF;
    --
    v_progress := '020';
    --
    IF (x_lines_rec.start_date_time is NOT NULL) THEN
       --
       IF (x_lines_rec.start_date_time >=
             (TRUNC(x_header_rec.sched_horizon_end_date) + 1)) THEN
           --
           v_progress := '030';
           raise e_EndHorizonInv;
           --
       END IF;
       --
    ELSE
       --
       v_progress := '040';
       raise e_StartDateInv;
       --
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;
  --
EXCEPTION
  WHEN e_EndHorizonInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_END_HORIZON_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'START_DATE_TIME',
                x_value1=>x_lines_rec.start_date_time,
                x_token2=>'END_HORIZON_DATE',
                x_value2=>x_header_rec.sched_horizon_end_date,
                x_ValidationType => 'DATE_RANGE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_END_HORIZON_INVALID');
    END IF;
    --
  WHEN e_StartDateInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_START_DATE_NULL',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'DATE_RANGE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_START_DATE_NULL');
    END IF;
    --
  WHEN e_DateRangeInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(x_MessageName => 'RLM_DATE_RANGE_INVALID',
                             x_InterfaceHeaderId => x_lines_rec.header_id,
                             x_InterfaceLineId => x_lines_rec.line_id,
                             x_token1=>'START_DATE_TIME',
                             x_value1=>x_lines_rec.start_date_time,
                             x_token2=>'END_DATE_TIME',
                             x_value2=>x_lines_rec.end_date_time,
                             x_ValidationType => 'DATE_RANGE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_DATE_RANGE_INVALID');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidDateRange',v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidDateRange;
/*===========================================================================

	PROCEDURE NAME:  ValidDateTypeCode

===========================================================================*/
PROCEDURE ValidDateTypeCode(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_DateTypeInv  EXCEPTION;
  --
BEGIN
  --
  IF rlm_message_sv.check_dependency('DATE_TYPE_CODE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidDateTypeCode');
    END IF;
    --
    -- Allow custom date type values
    IF NOT x_lines_rec.item_detail_type in ('3','4','5') Then
      IF NOT RLM_TPA_SV.ValidLookup('RLM_DATE_TYPE_CODE', x_lines_rec.date_type_code,
                        Sysdate) THEN
         --
         v_progress := '020';
         raise e_DateTypeInv;
         --
       END IF;
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;
  --
EXCEPTION
  WHEN e_DateTypeInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_ITEM_DTL_DATE_TYPE_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'DATE_TYPE_CODE',
                x_value1=>x_lines_rec.date_type_code,
                x_ValidationType => 'DATE_TYPE_CODE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_ITEM_DTL_DATE_TYPE_INVALID');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidDateTypeCode: ',
                                               v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidDateTypeCode;

/*===========================================================================

	PROCEDURE NAME:  ValidItemDetailQty

===========================================================================*/
PROCEDURE ValidItemDetailQty(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_QtyInvalid  EXCEPTION;
  --
BEGIN
  --
  IF rlm_message_sv.check_dependency('ITEM_DETAIL_QUANTITY') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidItemDetailQty');
       rlm_core_sv.dlog(C_DEBUG,'item_detail_quantity',
                              x_lines_rec.item_detail_quantity);
       rlm_core_sv.dlog(C_DEBUG,'Item_detail_Type',x_lines_rec.item_detail_type);
    END IF;
    --
    -- allow null quantities on ATH segments (bug 1892891)
    --
/*
    IF (x_lines_rec.item_detail_type IN ('0','1','2','3','4','6')) AND
       ((x_lines_rec.item_detail_quantity is NULL)
        OR (x_lines_rec.item_detail_quantity < 0)) THEN
*/
    IF ((x_lines_rec.item_detail_type IN ('0','1','2','3','4','6') AND
	(x_lines_rec.item_detail_quantity < 0)) OR
       (x_lines_rec.item_detail_type IN ('0','1','2','4','6') AND
	(x_lines_rec.item_detail_quantity is NULL))) THEN
       --
       v_progress := '020';
       raise e_QtyInvalid;
       --
    END IF;
    --
    v_progress := '030';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;
  --
EXCEPTION
  WHEN e_QtyInvalid THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_ITEM_DETAIL_QTY_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'ITEM_DETAIL_QUANTITY',
                x_value1=>x_lines_rec.item_detail_quantity,
                x_ValidationType => 'ITEM_DETAIL_QUANTITY');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_ITEM_DETAIL_QTY_INVALID');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidItemDetailQty: ',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidItemDetailQty;

/*===========================================================================

	PROCEDURE NAME:  ValidQtyTypeCode

===========================================================================*/
PROCEDURE ValidQtyTypeCode(
          x_setup_terms_rec  IN rlm_setup_terms_sv.setup_terms_rec_typ,
          x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_NoCum        EXCEPTION;
  e_QtyTypeInv  EXCEPTION;
  e_SeqCumQty  EXCEPTION;
  v_Count      NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidQtyTypeCode');
  END IF;
  --
  IF rlm_message_sv.check_dependency('QUANTITY_TYPE_CODE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Qty_Type_Code',x_lines_rec.qty_type_code);
       rlm_core_sv.dlog(C_DEBUG,'Item_Detail_Type',x_lines_rec.item_detail_type);
       rlm_core_sv.dlog(C_DEBUG,'schedule_type',x_header_rec.schedule_type);
    END IF;
    --

    -- Allow custom qty type codes
    IF NOT x_lines_rec.item_detail_type in ('3','4','5') Then
     IF NOT RLM_TPA_SV.ValidLookup( 'RLM_QTY_TYPE_CODE',
                         x_lines_rec.qty_type_code,
                         Sysdate) THEN
       raise e_QtyTypeInv;
     END IF;
    END IF;
    --
    IF x_lines_rec.item_detail_type IN (0,1,2) AND
       x_lines_rec.qty_type_code = 'CUMULATIVE' THEN
       --
       IF x_header_rec.schedule_type = 'SEQUENCED' THEN
          raise e_SeqCumQty;
       ELSIF x_setup_terms_rec.cum_control_code = 'NO_CUM' THEN
          raise  e_NOCum;
       END IF;
       --
    END IF;
    --
    v_progress := '060';
    --
  END IF;
  --
  -- Need to assign the primary quantity with the item detail qty
  -- if the primary quantity is populated i.e comes in from the edi
  -- schedule then we do use that quantity or else use the quantity from
  -- the item detail qty
  --
  --IF x_lines_rec.primary_quantity is NULL THEN
    --
    x_lines_rec.primary_quantity := nvl(x_lines_rec.item_detail_quantity,0);
    --
  --END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_NoCum THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_CUM_QTY_TYPE_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'QUANTITY_TYPE_CODE',
                x_value1=>x_lines_rec.qty_type_code,
                x_ValidationType => 'QUANTITY_TYPE_CODE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: RLM_CUM_CONTROL_CODE_INVALID');
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN e_QtyTypeInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_ITEM_QTY_TYPE_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'QUANTITY_TYPE_CODE',
                x_value1=>x_lines_rec.qty_type_code,
                x_ValidationType => 'QUANTITY_TYPE_CODE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_ITEM_DTL_TYPE_INVALID');
    END IF;
    --
  WHEN e_SeqCumQty THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SEQUENCED_CUMULATIVE_QTY',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'QUANTITY_TYPE_CODE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SEQUENCED_CUMULATIVE_QTY');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidQtyTypeCode',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidQtyTypeCode;

/*===========================================================================

	PROCEDURE NAME:  ValidItemDetailSubtype

===========================================================================*/
PROCEDURE ValidItemDetailSubtype(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_DetailSubTypeInv  EXCEPTION;
  v_status  BOOLEAN;
  --
BEGIN
  --
  IF rlm_message_sv.check_dependency('ITEM_DETAIL_SUBTYPE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidItemDetailSubtype');
    END IF;
    --
    IF x_lines_rec.item_detail_type IN ('0','1','2','6') THEN
       v_Status := RLM_TPA_SV.ValidLookup( 'RLM_DEMAND_SUBTYPE',
                                x_lines_rec.ITEM_DETAIL_SUBTYPE,
                                Sysdate);

/*
    -- allow custom item detail subtypes
    ELSIF x_lines_rec.item_detail_type = '3' THEN
       v_Status := RLM_TPA_SV.ValidLookup( 'RLM_AUTH_SUBTYPE',
                                x_lines_rec.ITEM_DETAIL_SUBTYPE,
                                     Sysdate);
    ELSIF x_lines_rec.item_detail_type = '4' THEN
       v_Status := RLM_TPA_SV.ValidLookup( 'RLM_SHP_RCV_SUBTYPE',
                                 x_lines_rec.ITEM_DETAIL_SUBTYPE,
                                     Sysdate);
    ELSE
       v_Status := RLM_TPA_SV.ValidLookup( 'RLM_INFO_SUBTYPE',
                                x_lines_rec.ITEM_DETAIL_SUBTYPE,
                                     Sysdate);
*/

    END IF;
    --
    IF NOT v_Status THEN
       raise e_DetailSubTypeInv;
    END IF;
    --
    v_progress := '060';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN e_DetailSubTypeInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_DETAIL_SUBTYPE_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'ITEM_DETAIL_SUBTYPE',
                x_value1=>x_lines_rec.item_detail_subtype,
                x_token2=>'ITEM_DETAIL_TYPE',
                x_value2=>x_lines_rec.item_detail_type,
                x_ValidationType => 'ITEM_DETAIL_SUBTYPE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'RLM_DETAIL_SUBTYPE_INVALID',
                                   x_lines_rec.item_detail_subtype);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidItemDetailSubtype: ',
                                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidItemDetailSubtype;

/*===========================================================================

	PROCEDURE NAME:  ValidItemDetailType

===========================================================================*/
PROCEDURE ValidItemDetailType(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_ItemDetailTypeInvalid  EXCEPTION;
  --
BEGIN
  --
  IF rlm_message_sv.check_dependency('ITEM_DETAIL_TYPE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidItemDetailType');
    END IF;
    --
    IF NOT RLM_TPA_SV.ValidLookup( 'RLM_DETAIL_TYPE_CODE',
                          x_lines_rec.item_detail_type,
                              Sysdate)
    THEN
       raise e_ItemDetailTypeInvalid;
    END IF;

    v_progress := '060';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN e_ItemDetailTypeInvalid THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_ITEM_DETAIL_TYPE_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'ITEM_DETAIL_TYPE',
                x_value1=>x_lines_rec.item_detail_type,
                x_ValidationType => 'ITEM_DETAIL_TYPE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'RLM_ITEM_DETAIL_TYPE_INVALID',
                                 x_lines_rec.item_detail_type);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidItemDetailType: ',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'OTHERS',x_lines_rec.item_detail_type);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidItemDetailType;

/*===========================================================================

	PROCEDURE NAME:  ValidateCriticalKeys

===========================================================================*/
PROCEDURE ValidateCriticalKeys(
               x_setup_terms_rec IN RLM_SETUP_TERMS_SV.setup_terms_rec_typ,
               x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
               x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress           VARCHAR2(3) := '010';
  x_critical_key_rec   rlm_core_sv.t_match_rec;
  x_key_description    VARCHAR2(100);
  e_CriticalKeyMissing EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidateCriticalKeys');
  END IF;
  --
  IF rlm_message_sv.check_dependency('CRITICAL_KEYS') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'critical_attribute_key',
                x_setup_terms_rec.critical_attribute_key);
    END IF;
    --
    rlm_core_sv.Populate_Match_Keys(x_critical_key_rec,
                  nvl(x_setup_terms_rec.critical_attribute_key,'0'));

    -- Check whether Critical key attribute key missing
    -- May have to change code due to NLS requirements
    -- The current description of lookup type RLM_OPTIONAL_MATCH_ATTRIBUTES
    -- needs to be corrected before we can use lookup codes for description

    IF ((x_critical_key_rec.cust_production_line = 'Y') AND
        (x_lines_rec.cust_production_line IS NULL ) )
    THEN
       x_key_description := 'Production Line';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.customer_dock_code = 'Y') AND
        (x_lines_rec.customer_dock_code IS NULL ) )
    THEN
       x_key_description := 'Dock Code';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.request_date = 'Y') AND
        (x_lines_rec.request_date IS NULL ) )
    THEN
       x_key_description := 'Request Date';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.schedule_date = 'Y') AND
        (x_lines_rec.schedule_date IS NULL ) )
    THEN
       x_key_description := 'Schedule Date';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.cust_po_number = 'Y') AND
        (x_lines_rec.cust_po_number IS NULL ) )
    THEN
       x_key_description := 'PO Number';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.customer_item_revision = 'Y') AND
        (x_lines_rec.customer_item_revision IS NULL ) )
    THEN
       x_key_description := 'Item Revision';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.customer_job = 'Y') AND
        (x_lines_rec.customer_job IS NULL ) )
    THEN
       x_key_description := 'Customer Job';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.cust_model_serial_number = 'Y') AND
        (x_lines_rec.cust_model_serial_number IS NULL ) )
    THEN
       x_key_description := 'Model Serial Number';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute1 = 'Y') AND
        (x_lines_rec.industry_attribute1 IS NULL ) )
    THEN
       x_key_description := 'Record Year';
       raise e_CriticalKeyMissing;
    END IF;
    --
   --  Begin of changes for Bug 2183405

     IF ((x_critical_key_rec.industry_attribute2 = 'Y') AND
        (nvl(x_lines_rec.industry_attribute2,to_char(x_lines_rec.start_date_time,'RRRR/MM/DD HH24:MI:SS')) IS NULL ))
    THEN
       x_key_description := 'Customer Request date';
       raise e_CriticalKeyMissing;
    END IF;
    --
     IF ((x_critical_key_rec.cust_production_seq_num = 'Y') AND
        (x_lines_rec.cust_production_seq_num  IS  NULL))
     THEN
        x_key_description := 'Customer Production Sequence Number' ;
        raise e_CriticalKeyMissing;
     END IF ;
      -- end of changes for Bug 2183405

     IF ((x_critical_key_rec.industry_attribute4 = 'Y') AND
        (x_lines_rec.industry_attribute4 IS NULL ) )
    THEN
       x_key_description := 'Pull Signal Reference Number';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute5 = 'Y') AND
        (x_lines_rec.industry_attribute5 IS NULL ) )
    THEN
       x_key_description := 'Pull Signal Starting Serial Number';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute6 = 'Y') AND
        (x_lines_rec.industry_attribute6 IS NULL ) )
    THEN
       x_key_description := 'Pull Signal Ending Serial Number';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute8 = 'Y') AND
        (x_lines_rec.industry_attribute8 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute8';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute9 = 'Y') AND
        (x_lines_rec.industry_attribute9 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute9';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute10 = 'Y') AND
        (x_lines_rec.industry_attribute10 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute10';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute11 = 'Y') AND
        (x_lines_rec.industry_attribute11 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute11';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute12 = 'Y') AND
        (x_lines_rec.industry_attribute12 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute12';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute13 = 'Y') AND
        (x_lines_rec.industry_attribute13 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute13';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.industry_attribute14 = 'Y') AND
        (x_lines_rec.industry_attribute14 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute14';
       raise e_CriticalKeyMissing;
    END IF;
    --
/* Commented as the industry attribute is copied later
    IF ((x_critical_key_rec.industry_attribute15 = 'Y') AND
        (x_lines_rec.industry_attribute15 IS NULL ) )
    THEN
       x_key_description := 'Industry Attribute15';
       raise e_CriticalKeyMissing;
    END IF;
    --
*/
    --
    IF ((x_critical_key_rec.attribute1 = 'Y') AND
        (x_lines_rec.attribute1 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute1';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute2 = 'Y') AND
        (x_lines_rec.attribute2 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute2';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute4 = 'Y') AND
        (x_lines_rec.attribute4 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute4';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute5 = 'Y') AND
        (x_lines_rec.attribute5 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute5';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute6 = 'Y') AND
        (x_lines_rec.attribute6 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute6';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute8 = 'Y') AND
        (x_lines_rec.attribute8 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute8';
    END IF;
    --
    IF ((x_critical_key_rec.attribute9 = 'Y') AND
        (x_lines_rec.attribute9 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute9';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute10 = 'Y') AND
        (x_lines_rec.attribute10 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute10';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute11 = 'Y') AND
        (x_lines_rec.attribute11 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute11';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute12 = 'Y') AND
        (x_lines_rec.attribute12 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute12';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute13 = 'Y') AND
        (x_lines_rec.attribute13 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute13';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute14 = 'Y') AND
        (x_lines_rec.attribute14 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute14';
       raise e_CriticalKeyMissing;
    END IF;
    --
    IF ((x_critical_key_rec.attribute15 = 'Y') AND
        (x_lines_rec.attribute15 IS NULL ) )
    THEN
       x_key_description := 'Descriptive Flexfield Attribute15';
       raise e_CriticalKeyMissing;
    END IF;
    --
    v_progress := '060';
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN e_CriticalKeyMissing THEN
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_CRITICAL_KEY_NULL',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'DESCRIPTION',
                x_value1=>x_key_description,
                x_ValidationType => 'CRITICAL_KEYS');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Missing key description',x_key_description);
       rlm_core_sv.dpop(C_SDEBUG,'WARNING: RLM_CRITICAL_KEY_NULL');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidateCriticalKeys:',
                              v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidateCriticalKeys;

/*===========================================================================

  PROCEDURE POPULATE_MATCH_KEY
        ( To be moved later to common package to be accessed both by
          Validate and Reconcile )

===========================================================================
PROCEDURE PopulateMatchKeys(x_match_rec IN OUT NOCOPY t_match_rec,
                             x_match_key  IN VARCHAR2)
IS

  x_progress          VARCHAR2(3) := '010';
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'POPULATE_MATCH_KEY');
     rlm_core_sv.dlog(C_DEBUG,'x_match_key',x_match_key);
  END IF;
  --
  --
  SELECT DECODE(INSTR(x_match_key,'A'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'B'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'C'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'D'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'E'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'F'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'G'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'H'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'I'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'J'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'K'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'L'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'M'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'N'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'O'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'P'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'Q'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'R'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'S'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'T'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'U'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'V'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'W'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'X'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'Y'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'Z'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'1'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'2'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'3'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'4'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'5'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'6'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'7'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'8'),0,'N','Y'),
         DECODE(INSTR(x_match_key,'9'),0,'N','Y')
  INTO
         x_match_rec.cust_production_line,
         x_match_rec.customer_dock_code,
         x_match_rec.request_date,
         x_match_rec.schedule_date,
         x_match_rec.cust_po_number,
         x_match_rec.customer_item_revision,
         x_match_rec.customer_job,
         x_match_rec.cust_model_serial_number,
         x_match_rec.industry_attribute1,
         x_match_rec.industry_attribute2,
         x_match_rec.industry_attribute4,
         x_match_rec.industry_attribute5,
         x_match_rec.industry_attribute6,
         x_match_rec.industry_attribute9,
         x_match_rec.industry_attribute10,
         x_match_rec.industry_attribute11,
         x_match_rec.industry_attribute12,
         x_match_rec.industry_attribute13,
         x_match_rec.industry_attribute14,
         x_match_rec.industry_attribute15,
         x_match_rec.attribute1,
         x_match_rec.attribute2,
         x_match_rec.attribute3,
         x_match_rec.attribute4,
         x_match_rec.attribute5,
         x_match_rec.attribute6,
         x_match_rec.attribute7,
         x_match_rec.attribute8,
         x_match_rec.attribute9,
         x_match_rec.attribute10,
         x_match_rec.attribute11,
         x_match_rec.attribute12,
         x_match_rec.attribute13,
         x_match_rec.attribute14,
         x_match_rec.attribute15
  FROM dual;

    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.cust_production_line',
                                x_match_rec.cust_production_line);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.customer_dock_code',
                                x_match_rec.customer_dock_code);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.request_date',
                                x_match_rec.request_date);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.schedule_date',
                                x_match_rec.schedule_date);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.cust_po_number',
                                x_match_rec.cust_po_number);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.customer_item_revision',
                                x_match_rec.customer_item_revision);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.customer_job',
                                x_match_rec.customer_job);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.cust_model_serial_number',
                                x_match_rec.cust_model_serial_number);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute1',
                                x_match_rec.industry_attribute1);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute2',
                                x_match_rec.industry_attribute2);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute4',
                                x_match_rec.industry_attribute4);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute5',
                                x_match_rec.industry_attribute5);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute6',
                                x_match_rec.industry_attribute6);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute9',
                                x_match_rec.industry_attribute9);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute10',
                                x_match_rec.industry_attribute10);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute11',
                                x_match_rec.industry_attribute11);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute12',
                                x_match_rec.industry_attribute12);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute13',
                                x_match_rec.industry_attribute13);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute14',
                              x_match_rec.industry_attribute14);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.industry_attribute15',
                               x_match_rec.industry_attribute15);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute1',x_match_rec.attribute1);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute2',x_match_rec.attribute2);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute3',x_match_rec.attribute3);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute4',x_match_rec.attribute4);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute5',x_match_rec.attribute5);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute6',x_match_rec.attribute6);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute7',x_match_rec.attribute7);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute8',x_match_rec.attribute8);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute9',x_match_rec.attribute9);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute10',x_match_rec.attribute10);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute11',x_match_rec.attribute11);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute12',x_match_rec.attribute12);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute13',x_match_rec.attribute13);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute14',x_match_rec.attribute14);
       rlm_core_sv.dlog(C_DEBUG,'x_match_rec.attribute15',x_match_rec.attribute15);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_validate_sv.PopulateMatchKeys',x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END PopulateMatchKeys;
*/

/*===========================================================================

	PROCEDURE NAME:  PopulateLinesTab

===========================================================================*/
PROCEDURE PopulateLinesTab(v_Group_rec IN t_Group_rec)
IS
  --
  v_lines_rec   RLM_INTERFACE_LINES%ROWTYPE;
  v_Progress    VARCHAR2(30) := '010';
  v_temp        VARCHAR2(30);
  v_Count       NUMBER := 1;
  TYPE  c_lines_typ  IS REF CURSOR;
  c_lines c_lines_typ;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'PopulateLinesTab');
     rlm_core_sv.dlog(C_DEBUG,'schedule_item_num',v_Group_rec.schedule_item_num);
     rlm_core_sv.dlog(C_DEBUG,'header_id',g_header_rec.header_id);
     rlm_core_sv.dlog(C_DEBUG,'cust_ship_from_org_ext',
                            v_Group_rec.cust_ship_from_org_ext);
     rlm_core_sv.dlog(C_DEBUG,'cust_ship_to_ext',v_Group_rec.cust_ship_to_ext);
     rlm_core_sv.dlog(C_DEBUG,'cust_production_seq_num',
                            v_Group_rec.cust_production_seq_num);
  END IF;
  --
  g_lines_tab.DELETE;
  --
  v_Progress := '020';
  --
  IF v_Group_rec.group_type = 'N' THEN
    --
    OPEN c_lines FOR
      SELECT *
      FROM RLM_INTERFACE_LINES_ALL --bug 4907839
      WHERE schedule_item_num = v_Group_rec.schedule_item_num
      AND header_id = g_header_rec.header_id
      AND   process_status = rlm_core_sv.k_PS_AVAILABLE
      --ORDER BY item_detail_type desc
      FOR UPDATE NOWAIT;
    --
  ELSE
    --
    IF (g_header_rec.schedule_source <> 'MANUAL') THEN
      --
      IF (v_Group_rec.cust_ship_from_org_ext IS NOT NULL AND v_Group_rec.cust_ship_to_ext IS NOT NULL) THEN
          --
          OPEN c_lines FOR
          SELECT *
          FROM RLM_INTERFACE_LINES_ALL --Bug 4907839
          WHERE header_id       = g_header_rec.header_id
          AND  cust_ship_from_org_ext =
               v_Group_rec.cust_ship_from_org_ext
          AND  cust_ship_to_ext =
                v_Group_rec.cust_ship_to_ext
          AND  customer_item_ext = v_Group_rec.customer_item_ext
          AND   process_status   = rlm_core_sv.k_PS_AVAILABLE
          --ORDER BY item_detail_type desc
          FOR UPDATE NOWAIT;
          --
      ELSE
        --
        OPEN c_lines FOR
        SELECT *
        FROM RLM_INTERFACE_LINES_ALL --bug 4907839
        WHERE header_id       = g_header_rec.header_id
        AND  nvl(cust_ship_from_org_ext,k_VNULL) =
                 nvl(v_Group_rec.cust_ship_from_org_ext,k_VNULL)
        AND  nvl(cust_ship_to_ext,k_VNULL) =
                nvl(v_Group_rec.cust_ship_to_ext,k_VNULL)
        AND  customer_item_ext = v_Group_rec.customer_item_ext
        AND   process_status   = rlm_core_sv.k_PS_AVAILABLE
        --ORDER BY item_detail_type desc
        FOR UPDATE NOWAIT;
        --
      END IF;

    ELSE
      --
      OPEN c_lines FOR
        SELECT *
        FROM RLM_INTERFACE_LINES
        WHERE header_id       = g_header_rec.header_id
        AND  customer_item_id = v_Group_rec.customer_item_id
        AND  ship_from_org_id = v_Group_rec.ship_from_org_id
        AND  ship_to_address_id = v_Group_rec.ship_to_address_id
        AND   process_status   = rlm_core_sv.k_PS_AVAILABLE
        --ORDER BY item_detail_type desc
        FOR UPDATE NOWAIT;
      --
    END IF;
    --
  END IF;
  --
  v_Count := 1;
  --
 LOOP
    FETCH c_lines INTO v_lines_rec ;
    --
    EXIT WHEN c_lines%NOTFOUND  ;
    --
    v_Progress := '030';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'inserted line_id',v_lines_rec.line_id);
    END IF;
    --
    g_lines_tab(v_Count) := v_lines_rec;
    g_lines_tab(v_Count).process_status  := rlm_core_sv.k_PS_AVAILABLE;
    v_Count := v_Count + 1;
    v_Progress := '040';
    --
  END LOOP;
  --
  CLOSE  c_lines;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.PopulateLinesTab',
                              v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END PopulateLinesTab;

/*===========================================================================

	PROCEDURE NAME:  BuildHeaderRec

===========================================================================*/
FUNCTION BuildHeaderRec(x_header_id IN rlm_interface_headers.header_id%TYPE)
RETURN BOOLEAN
IS
  --
  v_Progress    VARCHAR2(30) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'BuildHeaderRec');
     rlm_core_sv.dlog(C_DEBUG,'x_header_id',x_header_id);
  END IF;
  --
  SELECT *
  INTO g_header_rec
  FROM rlm_interface_headers
  WHERE header_id = x_header_id
  FOR UPDATE NOWAIT;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'No of headers selected',SQL%ROWCOUNT);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN TRUE;
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_header_id',x_header_id);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: NO_DATA_FOUND');
    END IF;
    --
    RETURN FALSE;
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_validatedemand_sv.BuildHeaderRec',v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    RETURN FALSE; /* should we raise here */
    --
END BuildHeaderRec;

/*===========================================================================

	PROCEDURE NAME:  ApplyHeaderDefaults

===========================================================================*/
PROCEDURE ApplyHeaderDefaults(x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
 --
  v_progress     VARCHAR2(3) := '010';
 --
BEGIN
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG,'ApplyHeaderDefaults');
 END IF;
 --
 IF x_header_rec.sched_horizon_start_date IS NULL THEN
     --
     x_header_rec.sched_horizon_start_date := GetDateFromTable('START');
     v_progress := '020';
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Horizon start date',
              x_header_rec.sched_horizon_start_date);
     END IF;
     --
 END IF;
 --
 IF  x_header_rec.sched_horizon_end_date IS NULL THEN
     --
     x_header_rec.sched_horizon_end_date := GetDateFromTable('END');
     v_progress := '030';
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Horizon end date',
              x_header_rec.sched_horizon_end_date);
     END IF;
     --
 ELSE
     --
     v_progress := '040';
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'no defaulting needed');
     END IF;
     --
 END IF;
 --
 v_progress := '050';
 --
 RLM_TPA_SV.SetHdrTPAttCategory(x_header_rec);
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG);
 END IF;
 --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ApplyHeaderDefaults',
                              v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ApplyHeaderDefaults;

/*===========================================================================

	FUNCTION  NAME:  GetDateFromTable
This function will return the date based on  the criteria specified
If criteria = 'START' THEN
  return the date which is least for the schedule item num
If criteria = 'END' THEN
  return the date which is greatest for the schedule item num

===========================================================================*/
FUNCTION GetDateFromTable(p_date_criteria VARCHAR2)
RETURN DATE
IS
  --
  v_progress     VARCHAR2(3) := '010';
  v_Start_Date   DATE;
  v_End_Date_d   DATE ;
  v_End_Date_w   DATE ;
  v_End_Date_m   DATE ;
  v_End_Date_f   DATE ;
  v_End_Date     DATE ;
  v_SundayDate   VARCHAR2(30) := '05/01/1997';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'GetDateFromTable');
     rlm_core_sv.dlog(C_DEBUG,'p_date_criteria',p_date_criteria);
  END IF;
  --
  IF p_date_criteria = 'START' THEN
     --
     SELECT MIN(start_date_time)
     INTO v_start_date
     FROM rlm_interface_lines
     WHERE header_id = g_header_rec.header_id;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'v_Start_Date',v_Start_Date);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     RETURN(v_Start_Date);
     --
  ELSIF p_date_criteria = 'END' THEN
     --{
     SELECT MAX(end_date_time)
     INTO   v_end_date_f
     FROM   rlm_interface_lines
     WHERE  header_id = g_header_rec.header_id
     AND    item_detail_type IN (0,1,2,6) --Bug 5478817
     AND    item_detail_subtype = rlm_ship_delivery_pattern_sv.g_FLEXIBLE;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'v_End_Date_f',v_End_Date_f);
     END IF;
     --
     SELECT MAX(start_date_time)
     INTO   v_End_Date_d
     FROM   rlm_interface_lines
     WHERE  header_id = g_header_rec.header_id
     AND    item_detail_type IN (0,1,2,6) --Bug 5478817
     AND    item_detail_subtype = rlm_ship_delivery_pattern_sv.g_DAY;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'v_End_Date_d',v_End_Date_d);
     END IF;
     --
     SELECT MAX(start_date_time)
     INTO   v_End_Date_w
     FROM   rlm_interface_lines
     WHERE  header_id = g_header_rec.header_id
     AND    item_detail_type IN (0,1,2,6) --Bug 5478817
     AND    item_detail_subtype = rlm_ship_delivery_pattern_sv.g_WEEK;
     --
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_End_Date_w', v_End_Date_w);
     END IF;
     --
     SELECT MAX(start_date_time)
     INTO   v_End_Date_m
     FROM   rlm_interface_lines
     WHERE  header_id = g_header_rec.header_id
     AND    item_detail_type IN (0,1,2,6) --Bug 5478817
     AND    item_detail_subtype = rlm_ship_delivery_pattern_sv.g_MONTH;
     --
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'v_End_Date_m', v_End_Date_m);
     END IF;
     --
     SELECT NEXT_DAY(v_End_Date_w,
            to_char(to_date(v_SundayDate, 'DD/MM/RRRR'), 'DY'))
     INTO v_End_Date_w
     FROM DUAL;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Sunday after v_End_Date_w',v_End_Date_w);
     END IF;
     --
     SELECT LAST_DAY(v_End_Date_m)
     INTO v_End_Date_m
     FROM DUAL;
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Last day of the month of v_End_Date_m',
                        v_End_Date_m);
     END IF;
     --
     -- Compare each of the end dates to figure out the horiz. end date
     --
     IF v_End_Date_f IS NOT NULL AND v_End_date_m IS NOT NULL THEN
      v_End_Date := GREATEST(v_End_Date_f, v_End_date_m);
     ELSE
      v_End_Date := NVL(v_End_Date_f, v_End_date_m);
     END IF;
     --
     IF v_End_Date IS NOT NULL THEN
      --
      IF v_End_Date_w IS NOT NULL THEN
       v_End_Date := GREATEST(v_End_Date, v_End_Date_w);
      ELSIF v_End_date_d IS NOT NULL THEN
       v_End_Date := GREATEST(v_End_Date, v_End_Date_d);
      END IF;
      --
     ELSE
      --
      IF v_End_Date_w IS NOT NULL AND v_End_date_d IS NOT NULL THEN
       v_End_Date := GREATEST(v_End_Date_w, v_End_date_d);
      ELSE
       v_End_Date := NVL(v_End_Date_w, v_End_Date_d);
      END IF;
      --
     END IF;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'v_End_Date',v_End_Date);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     RETURN(v_End_Date);
     --}
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
    g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.GetDateFromTable', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END GetDateFromTable;

/*===========================================================================

	PROCEDURE NAME:  ValidScheduleHeader

===========================================================================*/
PROCEDURE ValidScheduleHeader(x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidScheduleHeader');
  END IF;
  --
  RLM_TPA_SV.ValidScheduleType(x_header_rec);
  v_progress := '020';
  RLM_TPA_SV.ValidSchedulePurpose(x_header_rec);
  v_progress := '030';
  RLM_TPA_SV.ValidHorizonDates(x_header_rec);
  v_progress := '040';
  RLM_TPA_SV.ValidScheduleReferenceNum(x_header_rec);
  v_progress := '060';
  RLM_TPA_SV.ValidScheduleSource(x_header_rec);
  v_progress := '070';
  RLM_TPA_SV.ValidNumberLines(x_header_rec);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidScheduleHeader', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidScheduleHeader;

/*===========================================================================

	PROCEDURE NAME:  ValidNumberLines

===========================================================================*/
PROCEDURE ValidNumberLines(x_header_rec  IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_no_lines EXCEPTION;
  v_Count NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidNumberLines');
     rlm_core_sv.dlog(C_DEBUG,'x_header_rec.header_id',x_header_rec.header_id);
  END IF;
  --
  SELECT count(*)
  INTO v_Count
  FROM rlm_interface_lines
  where header_id = x_header_rec.header_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'ValidNumberLines ', v_Count);
  END IF;
  --
  IF v_count = 0 THEN
     raise e_no_lines;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_no_lines THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_NO_LINES_ON_SCHEDULE',
                x_InterfaceHeaderId => x_header_rec.header_id);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_NO_LINES_ON_SCHEDULE');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidNumberLines',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidNumberLines;

/*===========================================================================

	PROCEDURE NAME:  ValidScheduleSource

===========================================================================*/


PROCEDURE ValidScheduleSource(x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  v_Chk_Date     DATE;
  e_SchSrcInv    EXCEPTION;
  e_OldManualSch EXCEPTION;
  --   Bug 4995267:
  TYPE c_typ IS REF CURSOR;
  c c_typ;
  v_edi_num2               VARCHAR2(15);
  v_edi_num3               VARCHAR2(15);
  v_ref_num                VARCHAR2(35);
  v_purpose                NUMBER;
  v_status                 NUMBER;
  v_new_purpose            NUMBER;
  v_purpose_code           VARCHAR2(30);
  v_gen_date               DATE;
  v_creation_date          DATE;
  e_HighGenDateProcessed   EXCEPTION;
  e_HighEdiProcessed       EXCEPTION;
  e_HighRefProcessed       EXCEPTION;
  e_HighPurProcessed       EXCEPTION;
  e_HighCrDateProcessed    EXCEPTION;
  --
  CURSOR c_processed_stype IS
    SELECT   sched_generation_date,
             edi_control_num_2,
             edi_control_num_3,
             schedule_reference_num,
	     process_status,
             schedule_purpose,
             DECODE(schedule_purpose, 'ADD', 1, 'CONFIRMATION', 2, 'ORIGINAL', 3, 'REPLACE', 4,
                                      'REPLACE_ALL', 5, 'CANCELLATION', 6, 'CHANGE', 7, 'DELETE', 8),
             creation_date
    FROM     rlm_schedule_headers
    WHERE    ece_tp_translator_code   = x_header_rec.ece_tp_translator_code
    AND      ece_tp_location_code_ext = x_header_rec.ece_tp_location_code_ext
    AND      schedule_type            = x_header_rec.schedule_type
    AND      interface_header_id      <> x_header_rec.header_id
    AND      schedule_source          <> 'MANUAL'
    AND      process_status            IN (5,7)
    ORDER BY sched_generation_date    DESC,
             edi_control_num_2        DESC,
             edi_control_num_3        DESC,
             schedule_reference_num   DESC,
             DECODE(schedule_purpose, 'ADD', 1, 'CONFIRMATION', 2, 'ORIGINAL', 3,
                    'REPLACE', 4, 'REPLACE_ALL', 5, 'CANCELLATION', 6, 'CHANGE', 7, 'DELETE', 8) DESC,
             creation_date DESC;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidScheduleSource');
  END IF;
  --
  IF RLM_MESSAGE_SV.CHECK_DEPENDENCY('SCHEDULE_SOURCE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'schedule_source',
                              x_header_rec.schedule_source);
    END IF;
    --
    IF (x_header_rec.schedule_source IS NULL )  THEN
       --
       raise e_SchSrcInv;
       --
    ELSIF (x_header_rec.schedule_source <> 'MANUAL' ) THEN
    --{
       --
       --
       -- Bug 4995267: Query rlm_schedule_headers table for schedules.  Then, compare each attribute
       -- (one-by-one) according to the ORDER BY clause (RLMDPWPB). If at any point of
       -- attribute comparison, we find a schedule whose attributes are greater than the one
       -- currently being processed, DSP should stop indicating that the processing is out of order.
       --
       IF (l_debug <> -1) THEN
           --
           rlm_core_sv.dlog(C_DEBUG,'----- Checking the schedules in the archive tables -----');
           rlm_core_sv.dlog(C_DEBUG,'RLM_DP_SV.g_order_by_schedule_type', RLM_DP_SV.g_order_by_schedule_type);
           --
       END IF;
       --
       OPEN  c_processed_stype;
       FETCH c_processed_stype INTO v_gen_date, v_edi_num2, v_edi_num3, v_ref_num, v_status, v_purpose_code, v_purpose, v_creation_date;
       CLOSE c_processed_stype;
           --
       --
       IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'--- Archive schedule info ---');
               rlm_core_sv.dlog(C_DEBUG,'v_gen_date',
                                         to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'));
               rlm_core_sv.dlog(C_DEBUG,'v_edi_num2',v_edi_num2);
               rlm_core_sv.dlog(C_DEBUG,'v_edi_num3',v_edi_num3);
               rlm_core_sv.dlog(C_DEBUG,'v_ref_num',v_ref_num);
               rlm_core_sv.dlog(C_DEBUG,'v_status',v_status);
               rlm_core_sv.dlog(C_DEBUG,'v_purpose_code',v_purpose_code);
               rlm_core_sv.dlog(C_DEBUG,'v_creation_date',
                                         to_char(v_creation_date,'DD-MON-YYYY HH24:MI:SS'));
               rlm_core_sv.dlog(C_DEBUG,'--- Incoming schedule info ---');
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.sched_generation_date',
                                         to_char(x_header_rec.sched_generation_date,'DD-MON-YYYY HH24:MI:SS'));
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.edi_control_num_2', x_header_rec.edi_control_num_2);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.edi_control_num_3', x_header_rec.edi_control_num_3);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.schedule_reference_num', x_header_rec.schedule_reference_num);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.schedule_purpose', x_header_rec.schedule_purpose);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.x_header_rec.creation_date',
                                         to_char(x_header_rec.creation_date,'DD-MON-YYYY HH24:MI:SS'));
       END IF;
       --
       IF ( v_gen_date IS NOT NULL) THEN
       --{
           --
           IF (v_gen_date > x_header_rec.sched_generation_date) THEN
               --
               raise e_HighGenDateProcessed;
               --
           ELSIF ( v_gen_date = x_header_rec.sched_generation_date ) THEN
               --
               IF ( v_edi_num2 > x_header_rec.edi_control_num_2 ) THEN
                   --
                   IF (l_debug <> -1) THEN
                       rlm_core_sv.dlog(C_DEBUG,'Higher EDI Control Number2');
                   END IF;
                   --
                   raise e_HighEdiProcessed;
                   --
               ELSIF ( (v_edi_num2 = x_header_rec.edi_control_num_2) OR
                       (v_edi_num2 IS NULL AND x_header_rec.edi_control_num_2 IS NULL) ) THEN
                   --
                   IF ( v_edi_num3 > x_header_rec.edi_control_num_3 ) THEN
                       --
                       IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG,'Higher EDI Control Number3');
                       END IF;
                       --
                       raise e_HighEdiProcessed;
                       --
                   ELSIF ( (v_edi_num3 = x_header_rec.edi_control_num_3) OR
                           (v_edi_num3 IS NULL AND x_header_rec.edi_control_num_3 IS NULL)  ) THEN
                       --
                       IF ( v_ref_num > x_header_rec.schedule_reference_num ) THEN
                           --
                           raise e_HighRefProcessed;
                           --
                       ELSIF ( v_ref_num = x_header_rec.schedule_reference_num ) THEN
                           --
                           OPEN c FOR
                                SELECT DECODE(schedule_purpose, 'ADD', 1,
                                              'CONFIRMATION', 2, 'ORIGINAL', 3,'REPLACE', 4,
                                              'REPLACE_ALL', 5, 'CANCELLATION', 6,'CHANGE', 7, 'DELETE', 8)
                                FROM   rlm_interface_headers
                                WHERE  header_id = x_header_rec.header_id;
                           FETCH c into v_new_purpose;
                           CLOSE c;
                           --
                           IF (l_debug <> -1) THEN
                               rlm_core_sv.dlog(C_DEBUG,'v_purpose',v_purpose);
                               rlm_core_sv.dlog(C_DEBUG,'v_new_purpose',v_new_purpose);
                           END IF;
                           --
                           IF ( v_purpose > v_new_purpose ) THEN
                               --
                               raise e_HighPurProcessed;
                               --
                           ELSIF ( v_purpose = v_new_purpose ) THEN
                               --
                               IF ( v_creation_date > x_header_rec.creation_date ) THEN
                                   --
                                   raise e_HighCrDateProcessed;
                                   --
                               END IF;
                               --
                           END IF; /* Sch Purpose Check */
                           --
                       END IF; /* Sch Ref Num Check */
                       --
                   END IF; /* Edi Num3 Check */
                   --
               END IF; /*  Edi Num2 Check*/
               --
           END IF; /* Sch Gen Date Check */
           --
       --}
       END IF; /* v_Gen_Date Null Check */
       --  Bug 4995267: End
       --
    --}
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'ValidScheduleSource valid');
    END IF;
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'ValidScheduleSource not required because of dep');
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
  WHEN e_SchSrcInv THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SCHEDULE_SOURCE_INVALID',
                x_InterfaceHeaderId => x_header_rec.header_id,
                x_ValidationType => 'SCHEDULE_SOURCE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_SCHEDULE_SOURCE_INVALID');
    END IF;
    --
  -- Bug 4995267: Start
  WHEN e_HighGenDateProcessed THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with Higher Schedule Generation Date already processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_HIGH_GEN_DATE_PROCESSED',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
		     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_HIGH_GEN_DATE_PROCESSED');
    END IF;
    --
  WHEN e_HighEdiProcessed THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with Higher EDI control num already processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_HIGH_EDI_PROCESSED',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_HIGH_EDI_PROCESSED');
    END IF;
    --
  WHEN e_HighRefProcessed THEN
    --
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with Higher Schedule Reference num already processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_HIGH_REF_PROCESSED',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_HIGH_REF_PROCESSED');
    END IF;
    --
    --
  WHEN e_HighPurProcessed THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with Higher Schedule Purpose Code already processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_HIGH_PUR_PROCESSED',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_token7=> 'PURPOSE',
                     x_value7=> v_purpose_code,
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_HIGH_PUR_PROCESSED');
    END IF;
    --
  WHEN e_HighCrDateProcessed THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with HIGHER Creation Date already processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_HIGH_CR_DATE_PROCESSED',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_token7=> 'PURPOSE',
                     x_value7=> v_purpose_code,
                     x_token8=> 'CR_DATE',
                     x_value8=> to_char(v_creation_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_HIGH_CR_DATE_PROCESSED');
    END IF;
    --
  -- Bug 4995267: End
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidScheduleSource',
                                  v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidScheduleSource;

/*===========================================================================

	PROCEDURE NAME:  ValidHorizonDates

===========================================================================*/
PROCEDURE ValidHorizonDates(x_header_rec  IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_horizon_dates_invalid EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidHorizonDates');
  END IF;
  --
  IF RLM_MESSAGE_SV.CHECK_DEPENDENCY('HORIZON_DATES') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'SCHED_HORIZON_START_DATE',
                              x_header_rec.SCHED_HORIZON_START_DATE);
       rlm_core_sv.dlog(C_DEBUG,'SCHED_HORIZON_END_DATE',
                              x_header_rec.SCHED_HORIZON_END_DATE);
    END IF;
    --
    IF (x_header_rec.SCHED_HORIZON_START_DATE >
                x_header_rec.SCHED_HORIZON_END_DATE) THEN
       --
       raise e_horizon_dates_invalid;
       --
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'ValidHorizonDates valid');
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
  WHEN e_horizon_dates_invalid THEN
    --
     x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
     rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_HORIZON_DATES_INVALID',
                x_InterfaceHeaderId => x_header_rec.header_id,
                x_token1=>'SCHED_HORIZON_START_DATE',
                x_value1=>x_header_rec.sched_horizon_start_date,
                x_token2=>'SCHED_HORIZON_END_DATE',
                x_value2=>x_header_rec.sched_horizon_end_date,
                x_ValidationType => 'HORIZON_DATES');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_HORIZON_DATES_INVALID');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidHorizonDates',
                               v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidHorizonDates;

/*===========================================================================

	PROCEDURE NAME:  ValidScheduleReferenceNum

===========================================================================*/
PROCEDURE ValidScheduleReferenceNum(x_header_rec  IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_SchRefInv EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidScheduleReferenceNum');
  END IF;
  --
  IF RLM_MESSAGE_SV.CHECK_DEPENDENCY('SCHEDULE_REF_NUM') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'schedule_reference_num',
                           x_header_rec.schedule_reference_num);
    END IF;
    --
    IF x_header_rec.schedule_reference_num IS NULL THEN
       --
       RAISE e_SchRefInv;
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
  --
  WHEN e_SchRefInv THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SCHEDULE_REFERENCE_MISS',
                x_InterfaceHeaderId => x_header_rec.header_id,
                x_ValidationType => 'SCHEDULE_REF_NUM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_SCHEDULE_REFERENCE_MISS');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidScheduleReferenceNum',
                               v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidScheduleReferenceNum;

/*===========================================================================

	PROCEDURE NAME:  ValidScheduleType

===========================================================================*/
PROCEDURE ValidScheduleType(x_header_rec  IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  e_SchTypeInv   EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidScheduleType');
  END IF;
  --
  IF RLM_MESSAGE_SV.CHECK_DEPENDENCY('SCHEDULE_TYPE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'ScheduleType',x_header_rec.schedule_type);
    END IF;
    --
    IF NOT (RLM_TPA_SV.ValidLookup('RLM_SCHEDULE_TYPE',
                        x_header_rec.schedule_type,
                        x_header_rec.sched_generation_date)) THEN
       --
       RAISE e_SchTypeInv;
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
  --
  WHEN e_SchTypeInv THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SCHEDULE_TYPE_INVALID',
                x_InterfaceHeaderId => x_header_rec.header_id,
                x_token1=>'SCHEDULE_TYPE',
                x_value1=>x_header_rec.schedule_type,
                x_token2=>'SCHED_GENERATION_DATE',
                x_value2=>x_header_rec.sched_generation_date,
                x_ValidationType => 'SCHEDULE_TYPE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_SCHEDULE_TYPE_INVALID');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidScheduleType: ',
                                v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidScheduleType;

/*===========================================================================

	PROCEDURE NAME:  ValidLookup

===========================================================================*/
FUNCTION ValidLookup(p_lookup_type IN VARCHAR2,
                       p_lookup_code IN VARCHAR2,
                       p_date IN DATE)
RETURN BOOLEAN
IS
  --
  v_progress     VARCHAR2(3) := '010';
  --
  CURSOR c
  IS SELECT 1
  FROM fnd_lookups
  WHERE lookup_type = p_lookup_type
  AND   lookup_code = p_lookup_code
  AND   p_date between nvl(start_date_active,to_date('01/01/1900','dd/mm/yyyy'))
        AND   nvl(end_date_active, to_date('31/12/4712','dd/mm/yyyy'));
  --
  v_dummy VARCHAR2(1);
  --
BEGIN
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG,'ValidLookup');
    rlm_core_sv.dlog(C_DEBUG,'Lookup type ' || p_lookup_type );
    rlm_core_sv.dlog(C_DEBUG,'Lookup code ' || p_lookup_code );
    rlm_core_sv.dlog(C_DEBUG,'date  ' || p_date );
 END IF;
 --
 OPEN c;
 --
 FETCH c INTO v_dummy ;
 --
 v_progress  := '020';
 --
 IF c%NOTFOUND THEN
    --
    v_progress  := '030';
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Lookup ' || p_lookup_code || ' not valid');
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RETURN FALSE;
    --
 END IF;
 --
 CLOSE c;
 --
 v_progress  := '040';
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG);
 END IF;
 --
 RETURN TRUE;
 --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidLookup: ',v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidLookup;

/*===========================================================================

	PROCEDURE NAME:  ValidSchedulePurpose

===========================================================================*/
PROCEDURE ValidSchedulePurpose(x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_progress      VARCHAR2(3) := '010';
  e_SchPurposeInv EXCEPTION;
  v_sch_pur       NUMBER;
  v_edi_count     NUMBER;
  v_sched_ref     VARCHAR2(35);
  TYPE c_typ IS REF CURSOR;
  c c_typ;
  --
  --   Bug 4995267:
  v_edi_num2             VARCHAR2(15);
  v_edi_num3             VARCHAR2(15);
  v_ref_num              VARCHAR2(35);
  v_status               NUMBER;
  v_purpose              NUMBER;
  v_new_purpose          NUMBER;
  v_purpose_code         VARCHAR2(30);
  v_gen_date             DATE;
  v_creation_date        DATE;
  e_LowGenDatePending    EXCEPTION;
  e_LowEdiPending        EXCEPTION;
  e_LowRefPending        EXCEPTION;
  e_LowPurPending        EXCEPTION;
  e_LowCrDatePending     EXCEPTION;
  --
  CURSOR c_pending_stype IS
    SELECT   sched_generation_date,
             edi_control_num_2,
             edi_control_num_3,
             schedule_reference_num,
             process_status,
             schedule_purpose,
             DECODE(schedule_purpose, 'ADD', 1, 'CONFIRMATION', 2, 'ORIGINAL', 3, 'REPLACE', 4,
                                      'REPLACE_ALL', 5, 'CANCELLATION', 6, 'CHANGE', 7, 'DELETE', 8),
             creation_date
    FROM     rlm_interface_headers
    WHERE    ece_tp_translator_code   = x_header_rec.ece_tp_translator_code
    AND      ece_tp_location_code_ext = x_header_rec.ece_tp_location_code_ext
    AND      schedule_type            = x_header_rec.schedule_type
    AND      header_id                <> x_header_rec.header_id
    AND      schedule_source          <> 'MANUAL'
    ORDER BY sched_generation_date,
             edi_control_num_2,
             edi_control_num_3,
             schedule_reference_num ,
             DECODE(schedule_purpose, 'ADD', 1, 'CONFIRMATION', 2, 'ORIGINAL', 3,
                    'REPLACE', 4, 'REPLACE_ALL', 5, 'CANCELLATION', 6, 'CHANGE', 7, 'DELETE', 8),
             creation_date;
  --   Bug 4995267:
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidSchedulePurpose');
  END IF;
  --
  IF RLM_MESSAGE_SV.CHECK_DEPENDENCY('SCHEDULE_PURPOSE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'x_header_rec.schedule_purpose',
                                x_header_rec.schedule_purpose);
       rlm_core_sv.dlog(C_DEBUG,'x_header_rec.ece_tp_translator_code',
                                x_header_rec.ece_tp_translator_code );
       rlm_core_sv.dlog(C_DEBUG,'x_header_rec.ece_tp_location_code_ext',
                                x_header_rec.ece_tp_location_code_ext );
       rlm_core_sv.dlog(C_DEBUG,'x_header_rec.schedule_purpose',
                                x_header_rec.schedule_purpose );
    END IF;
    --
    IF NOT (RLM_TPA_SV.ValidLookup('RLM_SCHEDULE_PURPOSE',
                         x_header_rec.schedule_purpose,
                         x_header_rec.sched_generation_date)) THEN
       --
       RAISE e_SchPurposeInv;
       --
    ELSIF (x_header_rec.edi_control_num_2 IS NULL AND
           x_header_rec.edi_control_num_3 IS NULL ) THEN
          --
       IF x_header_rec.schedule_purpose IN (k_CANCEL, k_CHANGE, k_DELETE)THEN
           --
           SELECT count(*)
           INTO v_sch_pur
           FROM rlm_interface_headers
           WHERE ece_tp_translator_code = x_header_rec.ece_tp_translator_code
           AND ece_tp_location_code_ext=x_header_rec.ece_tp_location_code_ext
           AND schedule_type=x_header_rec.schedule_type
           AND sched_generation_date = x_header_rec.sched_generation_date
           AND schedule_reference_num = x_header_rec.schedule_reference_num
           AND schedule_purpose IN (
               DECODE (x_header_rec.schedule_purpose, k_CANCEL, k_DELETE,
                       k_DELETE, k_CANCEL, k_CHANGE, k_DELETE),
               DECODE (x_header_rec.schedule_purpose, k_CANCEL,
                       k_CHANGE, k_DELETE, k_CHANGE, k_CHANGE, k_CANCEL),
               k_ORIGINAL, k_REPLACE, k_REPLACE_ALL, k_ADD);
   	   --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'v_sch_pur', v_sch_pur);
           END IF;
           --
           IF (v_sch_pur > 0  ) THEN
               --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'Null EDI control values and purpose in
                                         CANCEL, CHANGE, DELETE');
               END IF;
	       --
               x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
               rlm_message_sv.app_error(
                           x_ExceptionLevel => rlm_message_sv.k_error_level,
                           x_MessageName => 'RLM_PUR_PROCESSING_ORDER_V',
                           x_InterfaceHeaderId => x_header_rec.header_id,
                           x_token1=>'SCHEDULE_REF_NUM',
                           x_value1=>x_header_rec.schedule_reference_num,
                           x_token2=>'ECE_TP_TRANS_CD',
                           x_value2=>x_header_rec.ece_tp_translator_code,
                           x_token3=>'ECE_TP_LOC_CD_EXT',
                           x_value3=>x_header_rec.ece_tp_location_code_ext,
                           x_token4=>'SCHED_GENERATION_DATE',
                           x_value4=>x_header_rec.sched_generation_date,
                           x_ValidationType => 'SCHEDULE_PURPOSE');
		--
  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: PURPOSE ORDER VIOLATION');
                END IF;
                --
           END IF;
          --
       END IF;
       --
    ELSE -- When x_header_rec.edi_control_num_2 IS NOT NULL OR x_header_rec.edi_control_num_3 IS NOT NULL
    --{
         /* Bug 4995267: First query rlm_interface_headers table for schedules, irrespective of their
                         process_status and start comparing each attribute (one-by-one) as indicated
                         in the ORDER BY clause (RLMDPWPB).  If at any point of attribute comparison,
                         we find a schedule whose attributes are less than the one currently being
                         processed, DSP should stop indicating that the processing is out of order. */
       --
       IF (x_header_rec.schedule_source <> 'MANUAL' ) THEN
           --
           IF (l_debug <> -1) THEN
               --
               rlm_core_sv.dlog(C_DEBUG,'----- Checking the schedules in the interface tables -----');
               rlm_core_sv.dlog(C_DEBUG,'RLM_DP_SV.g_order_by_schedule_type', RLM_DP_SV.g_order_by_schedule_type);
               --
           END IF;
           --
           --
           OPEN  c_pending_stype;
           FETCH c_pending_stype INTO v_Gen_Date, v_edi_num2, v_edi_num3, v_ref_num, v_status, v_purpose_code, v_purpose, v_creation_date;
           CLOSE c_pending_stype;
           --
           --
           IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'--- Interface schedule info ---');
               rlm_core_sv.dlog(C_DEBUG,'v_gen_date',
                                         to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'));
               rlm_core_sv.dlog(C_DEBUG,'v_edi_num2',v_edi_num2);
               rlm_core_sv.dlog(C_DEBUG,'v_edi_num3',v_edi_num3);
               rlm_core_sv.dlog(C_DEBUG,'v_ref_num',v_ref_num);
               rlm_core_sv.dlog(C_DEBUG,'v_purpose_code',v_purpose_code);
               rlm_core_sv.dlog(C_DEBUG,'v_creation_date',
                                         to_char(v_creation_date,'DD-MON-YYYY HH24:MI:SS'));
               rlm_core_sv.dlog(C_DEBUG,'--- Incoming schedule info ---');
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.sched_generation_date',
                                         to_char(x_header_rec.sched_generation_date,'DD-MON-YYYY HH24:MI:SS'));
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.edi_control_num_2', x_header_rec.edi_control_num_2);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.edi_control_num_3', x_header_rec.edi_control_num_3);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.schedule_reference_num', x_header_rec.schedule_reference_num);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.schedule_purpose', x_header_rec.schedule_purpose);
               rlm_core_sv.dlog(C_DEBUG,'x_header_rec.x_header_rec.creation_date',
                                         to_char(x_header_rec.creation_date,'DD-MON-YYYY HH24:MI:SS'));
           END IF;
           --
           IF ( v_gen_date IS NOT NULL) THEN
               --
               IF (v_gen_date < x_header_rec.sched_generation_date) THEN
                   --
                   raise e_LowGenDatePending;
                   --
               ELSIF ( v_gen_date = x_header_rec.sched_generation_date ) THEN
                   --
                   IF ( v_edi_num2 < x_header_rec.edi_control_num_2 ) THEN
                       --
                       IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG,'Lower EDI Control Number2');
                       END IF;
                       --
                       raise e_LowEdiPending;
                       --
                   ELSIF ( (v_edi_num2 = x_header_rec.edi_control_num_2) OR
                           (v_edi_num2 IS NULL AND x_header_rec.edi_control_num_2 IS NULL) ) THEN
                       --
                       IF ( v_edi_num3 < x_header_rec.edi_control_num_3 ) THEN
                           --
                           IF (l_debug <> -1) THEN
                               rlm_core_sv.dlog(C_DEBUG,'Lower EDI Control Number3');
                           END IF;
                           --
                           raise e_LowEdiPending;
                           --
                       ELSIF ( (v_edi_num3 = x_header_rec.edi_control_num_3) OR
                               (v_edi_num3 IS NULL AND x_header_rec.edi_control_num_3 IS NULL) ) THEN
                           --
                           IF ( v_ref_num < x_header_rec.schedule_reference_num ) THEN
                               --
                               raise e_LowRefPending;
                               --
                           ELSIF ( v_ref_num = x_header_rec.schedule_reference_num ) THEN
                               --
                               OPEN c FOR
                                    SELECT DECODE(schedule_purpose, 'ADD',1,
                                                  'CONFIRMATION', 2, 'ORIGINAL', 3,'REPLACE', 4,
                                                   'REPLACE_ALL', 5, 'CANCELLATION', 6,'CHANGE', 7, 'DELETE', 8)
                                    FROM   rlm_interface_headers
                                    WHERE  header_id = x_header_rec.header_id;
                               FETCH c into v_new_purpose;
                               CLOSE c;
                               --
                               IF (l_debug <> -1) THEN
                                   rlm_core_sv.dlog(C_DEBUG,'v_purpose',v_purpose);
                                   rlm_core_sv.dlog(C_DEBUG,'v_new_purpose',v_new_purpose);
                               END IF;
                               --
                               IF ( v_purpose < v_new_purpose ) THEN
                                   --
                                   raise e_LowPurPending;
                                   --
                               ELSIF ( v_purpose = v_new_purpose ) THEN
                                   --
                                   IF ( v_creation_date < x_header_rec.creation_date ) THEN
                                       --
                                       raise e_LowCrDatePending;
                                       --
                                   END IF;
                                   --
                               END IF; /* Sch Purpose Check */
                               --
                           END IF; /* Sch Ref Num Check */
                           --
                       END IF; /* Edi Num3 Check */
                       --
                   END IF; /* Edi Num2 Check */
                   --
               END IF; /* Sch Gen Date Check */
               --
           END IF; /* v_Gen_Date Null Check */
           --
       END IF; /* Manual check */
       --
    --}
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
  WHEN e_SchPurposeInv THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SCHEDULE_PURPOSE_INVALID',
                x_InterfaceHeaderId => x_header_rec.header_id,
                x_token1=>'SCHEDULE_PURPOSE',
                x_value1=>x_header_rec.schedule_purpose,
                x_token2=>'SCHED_GENERATION_DATE',
                x_value2=>x_header_rec.sched_generation_date,
                x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_SCHEDULE_PURPOSE_INVALID');
     END IF;
    --
  -- Bug 4995267: Start
  WHEN e_LowGenDatePending THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with lower Schedule Generation Date is not yet processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_LOW_GEN_DATE_PENDING',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_LOW_GEN_DATE_PENDING');
    END IF;
    --
  WHEN e_LowEdiPending THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with lower EDI control num is not yet processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_LOW_EDI_PENDING',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_LOW_EDI_PENDING');
    END IF;
    --
  WHEN e_LowRefPending THEN
    --
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with lower Schedule Reference num is not yet processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_LOW_REF_PENDING',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_LOW_REF_PENDING');
    END IF;
    --
  WHEN e_LowPurPending THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with lower Schedule Purpose Code is not yet processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_LOW_PUR_PENDING',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_token7=> 'PURPOSE',
                     x_value7=> v_purpose_code,
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_LOW_PUR_PENDING');
    END IF;
    --
  WHEN e_LowCrDatePending THEN
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Schedule with lower Creation Date is not yet processed');
    END IF;
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                     x_ExceptionLevel => rlm_message_sv.k_error_level,
                     x_MessageName => 'RLM_LOW_CR_DATE_PENDING',
                     x_InterfaceHeaderId => x_header_rec.header_id,
                     x_token1=> 'REF_NUM',
                     x_value1=> v_ref_num,
                     x_token2=> 'STATUS',
                     x_value2=> rlm_core_sv.get_proc_status_meaning(v_status),
                     x_token3=> 'ECE_TP_LOC_CD_EXT',
                     x_value3=> x_header_rec.ece_tp_location_code_ext,
                     x_token4=> 'ECE_TP_TRANS_CD',
                     x_value4=> x_header_rec.ece_tp_translator_code,
                     x_token5=> 'GEN_DATE',
                     x_value5=> to_char(v_gen_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_token6=> 'EDI_NUM',
                     x_value6=> v_edi_num2 || '-' || v_edi_num3,
                     x_token7=> 'PURPOSE',
                     x_value7=> v_purpose_code,
                     x_token8=> 'CR_DATE',
                     x_value8=> to_char(v_creation_date,'DD-MON-YYYY HH24:MI:SS'),
                     x_ValidationType => 'SCHEDULE_PURPOSE');
    --
    IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_DEBUG,'EXCEPTION: RLM_LOW_CR_DATE_PENDING');
    END IF;
    --
    -- Bug 4995267: End
  WHEN OTHERS THEN
    --
    x_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidSchedulePurpose: ',
                                v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidSchedulePurpose;

/*===========================================================================

	PROCEDURE NAME:  DeriveOrgDependentIDs

===========================================================================*/
PROCEDURE DeriveOrgDependentIDs(
                   x_setup_terms_rec  IN RLM_SETUP_TERMS_SV.setup_terms_rec_typ,
                   x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                   x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DeriveOrgDependentIDs');
  END IF;
  --
  --undo performance changes for bug 6185706
  RLM_TPA_SV.DeriveInventoryItemId(x_header_rec, x_lines_rec);
  DerivePurchaseOrder(x_setup_terms_rec, x_header_rec, x_lines_rec);
  --derive_price_list; -- TODO
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveOrgDependentIDs: ',
                                   v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DeriveOrgDependentIDs;

/*===========================================================================

	PROCEDURE NAME:  DeriveIDs

===========================================================================*/
PROCEDURE DeriveIDs( x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE,
                     x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS

  v_progress     VARCHAR2(3) := '010';
  v_bill_to_customer_id NUMBER default NULL;

  -- Need to change all the DeriveIDs to accept records
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DeriveIDs');
  END IF;
  --
  DeriveCustomerID(x_header_rec,x_lines_rec) ;
  DeriveShipToID(x_header_rec, x_lines_rec);
  --DeriveBillToID(x_header_rec, x_lines_rec);
  --
  --rlm_core_sv.dlog(C_DEBUG,'BILLTOID', x_lines_rec.bill_to_address_id);

  --     validate the relationship of customer id of bill_to and ship_to
  --
  DeriveIntrmdShipToID(x_header_rec, x_lines_rec);
  RLM_TPA_SV.ValidateCustomerItem(x_header_rec, x_lines_rec);
  DeriveShipFromOrg(x_header_rec, x_lines_rec);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveIDs', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DeriveIDs;

/*===========================================================================

	PROCEDURE NAME:  DeriveInventoryItemId

===========================================================================*/
PROCEDURE DeriveInventoryItemId(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';
  v_CustomerId                  NUMBER;
  v_CustomerCategoryCode        VARCHAR2(30);
  v_AddressId                   NUMBER;
  v_CustomerItemNumber          VARCHAR2(50);
  v_BillCustomerItemId          NUMBER;
  v_BillInventoryItemId         NUMBER;
  v_ItemDefinitionLevel         VARCHAR2(1);
  v_CustomerItemDesc            VARCHAR2(240);
  v_ModelCustomerItemId         NUMBER;
  v_CommodityCodeId             NUMBER;
  v_MasterContainerItemId       NUMBER;
  v_ContainerItemOrgId          NUMBER;
  v_DetailContainerItemId       NUMBER;
  v_MinFillPercentage           NUMBER;
  v_DepPlanRequiredFlag         VARCHAR2(1);
  v_DepPlanPriorBldFlag         VARCHAR2(1);
  v_DemandTolerancePositive     NUMBER;
  v_DemandToleranceNegative     NUMBER;
  v_InventoryItemIdFromSup      NUMBER;
  v_InventoryItemIdFromSeg      NUMBER;
  v_AttributeCategory           VARCHAR2(30);
  v_Attribute1                  VARCHAR2(150);
  v_Attribute2                  VARCHAR2(150);
  v_Attribute3                  VARCHAR2(150);
  v_Attribute4                  VARCHAR2(150);
  v_Attribute5                  VARCHAR2(150);
  v_Attribute6                  VARCHAR2(150);
  v_Attribute7                  VARCHAR2(150);
  v_Attribute8                  VARCHAR2(150);
  v_Attribute9                  VARCHAR2(150);
  v_Attribute10                 VARCHAR2(150);
  v_Attribute11                 VARCHAR2(150);
  v_Attribute12                 VARCHAR2(150);
  v_Attribute13                 VARCHAR2(150);
  v_Attribute14                 VARCHAR2(150);
  v_Attribute15                 VARCHAR2(150);
  v_MasterOrganizationId        NUMBER;
  v_BillMasterOrganizationId    NUMBER;
  v_PreferenceNumber            NUMBER;
  v_ErrorCode                   VARCHAR2(9);
  v_ErrorFlag                   VARCHAR2(1);
  v_ErrorMessage                VARCHAR2(2000);
  e_NullCustItemId              EXCEPTION;
  e_SuppItemInvalid             EXCEPTION;
  e_InvalidItem                 EXCEPTION;
  -- global_atp
  e_ATPSequenced                EXCEPTION;
  v_Active                      NUMBER := 0;
  v_customer_item_id            NUMBER;
  v_CustOrderEnabledFlag        VARCHAR2(1);
  v_dummy_id                    NUMBER;
  e_NotCustOrderEnabled		EXCEPTION;
  v_ship_to_address_id          NUMBER;
  --
  CURSOR c_CustOrderEnabled(p_InvItemId NUMBER, p_ShipFromOrgId NUMBER) IS
  SELECT customer_order_enabled_flag
  FROM mtl_system_items
  WHERE inventory_item_id = p_InvItemId AND
  organization_id = p_ShipFromOrgId;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DeriveInventoryItemId');
     rlm_core_sv.dlog(C_DEBUG,'inventory_item_id ',x_lines_rec.inventory_item_id);
  END IF;
  --

  IF rlm_message_sv.check_dependency('INVENTORY_ITEM') THEN
    --
    -- The original customer item id needs to be stored. This value
    -- can be lost if inv api returns false
    v_customer_item_id := x_lines_rec.customer_item_id;

    IF x_lines_rec.inventory_item_id IS NULL THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'inventory item derived from inv API');
         rlm_core_sv.dlog(C_DEBUG,'customer_item_id id ' ,
                                 x_lines_rec.customer_item_id);
         rlm_core_sv.dlog(C_DEBUG,'ship_from_org ' ,
                                 x_lines_rec.ship_from_org_id);
      END IF;
      --
      -- get_inv_item_id from inventory API
      -- where customer_item_id = x_lines_rec.customer_item_id
      -- and master_organization_id = x_lines_rec.ship_from_org_id
      IF (x_header_rec.customer_id is  not NULL) THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Calling inv_customer_item_grp.fetch_attributes ');
           rlm_core_sv.dlog(C_DEBUG, 'x_lines_rec.ship_to_address_id',
                                     x_lines_rec.ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG, 'x_lines_rec.ship_to_customer_id',
                                     x_lines_rec.ship_to_customer_id);
           rlm_core_sv.dlog(C_DEBUG, 'x_lines_rec.Ship_From_Org_Id',
                                     x_lines_rec.Ship_From_Org_Id);
           rlm_core_sv.dlog(C_DEBUG, 'x_lines_rec.customer_item_id',
                                           x_lines_rec.customer_item_id);
        END IF;
        --
        IF (x_header_rec.customer_id <> nvl(x_lines_rec.ship_to_customer_id, x_header_rec.customer_id)) THEN
         --
         v_ship_to_address_id := NULL;
         --
        ELSE
         --
         v_ship_to_address_id := x_lines_rec.SHIP_TO_ADDRESS_ID;
         --
        END IF;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'v_ship_to_address_id ',
                                           v_ship_to_address_id);
        END IF;
        --
        inv_customer_item_grp.fetch_attributes(
               --x_lines_rec.SHIP_TO_ADDRESS_ID,
               v_ship_to_address_id,
               NULL, x_header_rec.customer_id,
               x_lines_rec.Customer_Item_Ext,
               x_lines_rec.Ship_From_Org_Id,
               x_lines_rec.Customer_Item_Id,NULL,
               --x_lines_rec.Customer_Item_Id,
               v_dummy_id,
               v_CustomerId, v_CustomerCategoryCode,
               v_AddressId, v_CustomerItemNumber,
               v_ItemDefinitionLevel,
               v_CustomerItemDesc,
               v_ModelCustomerItemId,
               v_CommodityCodeId,
               v_MasterContainerItemId,
               v_ContainerItemOrgId,
               v_DetailContainerItemId,
               v_MinFillPercentage,
               v_DepPlanRequiredFlag,
               v_DepPlanPriorBldFlag,
               v_DemandTolerancePositive,
               v_DemandToleranceNegative,
               v_AttributeCategory,
               v_Attribute1, v_Attribute2,
               v_Attribute3, v_Attribute4,
               v_Attribute5, v_Attribute6,
               v_Attribute7, v_Attribute8,
               v_Attribute9, v_Attribute10,
               v_Attribute11, v_Attribute12,
               v_Attribute13, v_Attribute14,
               v_Attribute15,
               x_lines_rec.INVENTORY_ITEM_ID,
               v_MasterOrganizationId,
               v_PreferenceNumber, v_ErrorCode,
               v_ErrorFlag, v_ErrorMessage);
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_ErrorMessage', v_ErrorMessage);
           rlm_core_sv.dlog(C_DEBUG,'v_ErrorCode', v_ErrorCode);
           rlm_core_sv.dlog(C_DEBUG, 'Inventory Item ID from Inventory API',
                            x_lines_rec.inventory_item_id);
        END IF;
        --
        IF v_ErrorFlag = 'Y' THEN
          --
          raise e_InvalidItem;
          --
        ELSIF x_lines_rec.Customer_Item_Id is NULL THEN
          --
          raise e_NullCustItemId;
          --
        END IF;
        --
        OPEN c_CustOrderEnabled(x_lines_rec.inventory_item_id,
                          x_lines_rec.ship_from_org_id);
        FETCH c_CustOrderEnabled INTO v_CustOrderEnabledFlag;
        CLOSE c_CustOrderEnabled;
        --
        IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'customer_order_enabled_flag',
                          v_CustOrderEnabledFlag);
        END IF;
        --
        IF NVL(v_CustOrderEnabledFlag, 'N') <> 'Y' THEN
          RAISE e_NotCustOrderEnabled;
        END IF;
        --
      END IF;
      --
      IF x_lines_rec.supplier_item_ext IS NOT NULL THEN
        --
        v_progress := '020';
        --
        BEGIN
          --
          SELECT inventory_item_id
          INTO   v_InventoryItemidFromSup
          FROM   mtl_item_flexfields
          WHERE  item_number =  x_lines_rec.supplier_item_ext
          AND    organization_id  =  x_lines_rec.ship_from_org_id
          AND    customer_order_enabled_flag = 'Y';
          --
          -- Check if this is the same as derived from customer item
          --
          IF(v_InventoryItemIdFromSup <> x_lines_rec.inventory_item_id) THEN

            rlm_message_sv.app_error(
                         x_ExceptionLevel => rlm_message_sv.k_warn_level,
                         x_MessageName => 'RLM_SUPPLIER_ITEM_MISMATCH',
                         x_InterfaceHeaderId => x_lines_rec.header_id,
                         x_InterfaceLineId => x_lines_rec.line_id,
                         x_token1=>'SUPPLIER_ITEM',
                         x_value1=>x_lines_rec.supplier_item_ext);
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog('WARNING: RLM_SUPPLIER_ITEM_MISMATCH');
            END IF;
	    --
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            --
            rlm_message_sv.app_error(
                         x_ExceptionLevel => rlm_message_sv.k_warn_level,
                         x_MessageName => 'RLM_INVALID_SUPPLIER_ITEM',
                         x_InterfaceHeaderId => x_lines_rec.header_id,
                         x_InterfaceLineId => x_lines_rec.line_id,
                         x_token1=>'SUPPLIER_ITEM',
                         x_value1=>x_lines_rec.supplier_item_ext);
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog('WARNING: RLM_INVALID_SUPPLIER_ITEM');
            END IF;
            --
        END;
      --
      ELSIF (x_lines_rec.inventory_item_segment1 IS NOT NULL AND
             x_lines_rec.inventory_item_segment2 IS NOT NULL AND
             x_lines_rec.inventory_item_segment3 IS NOT NULL AND
             x_lines_rec.inventory_item_segment4 IS NOT NULL AND
             x_lines_rec.inventory_item_segment5 IS NOT NULL AND
             x_lines_rec.inventory_item_segment6 IS NOT NULL AND
             x_lines_rec.inventory_item_segment7 IS NOT NULL AND
             x_lines_rec.inventory_item_segment8 IS NOT NULL AND
             x_lines_rec.inventory_item_segment9 IS NOT NULL AND
             x_lines_rec.inventory_item_segment10 IS NOT NULL AND
             x_lines_rec.inventory_item_segment11 IS NOT NULL AND
             x_lines_rec.inventory_item_segment12 IS NOT NULL AND
             x_lines_rec.inventory_item_segment13 IS NOT NULL AND
             x_lines_rec.inventory_item_segment14 IS NOT NULL AND
             x_lines_rec.inventory_item_segment15 IS NOT NULL AND
             x_lines_rec.inventory_item_segment16 IS NOT NULL AND
             x_lines_rec.inventory_item_segment17 IS NOT NULL AND
             x_lines_rec.inventory_item_segment18 IS NOT NULL AND
             x_lines_rec.inventory_item_segment19 IS NOT NULL AND
             x_lines_rec.inventory_item_segment20 IS NOT NULL)
      THEN
        -- derive inv item based on the segments
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment1 ',
                                       x_lines_rec.inventory_item_segment1);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment2 ',
                                       x_lines_rec.inventory_item_segment2);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment3 ',
                                       x_lines_rec.inventory_item_segment3);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment4 ',
                                       x_lines_rec.inventory_item_segment4);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment5 ',
                                      x_lines_rec.inventory_item_segment5);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment6 ',
                                      x_lines_rec.inventory_item_segment6);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment7 ',
                                      x_lines_rec.inventory_item_segment7);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment8 ',
                                      x_lines_rec.inventory_item_segment8);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment9 ',
                                      x_lines_rec.inventory_item_segment9);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment10 ',
                                      x_lines_rec.inventory_item_segment10);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment11',
                                      x_lines_rec.inventory_item_segment11);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment12 ',
                                      x_lines_rec.inventory_item_segment12);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment13 ',
                                      x_lines_rec.inventory_item_segment13);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment14 ',
                                       x_lines_rec.inventory_item_segment14);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment15 ',
                                      x_lines_rec.inventory_item_segment15);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment16 ',
                                      x_lines_rec.inventory_item_segment16);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment17 ',
                                      x_lines_rec.inventory_item_segment17);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment18 ',
                                      x_lines_rec.inventory_item_segment18);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment19 ',
                                      x_lines_rec.inventory_item_segment19);
           rlm_core_sv.dlog(C_DEBUG,'inventory_item_segment20 ',
                                      x_lines_rec.inventory_item_segment20);
        END IF;
        --
        BEGIN
        --
          SELECT inventory_item_id
          INTO   v_InventoryItemIdFromSeg
          FROM   mtl_system_items
          WHERE  segment1 = x_lines_rec.inventory_item_segment1
          AND    segment2 = x_lines_rec.inventory_item_segment2
          AND    segment3 = x_lines_rec.inventory_item_segment3
          AND    segment4 = x_lines_rec.inventory_item_segment4
          AND    segment5 = x_lines_rec.inventory_item_segment5
          AND    segment6 = x_lines_rec.inventory_item_segment6
          AND    segment7 = x_lines_rec.inventory_item_segment7
          AND    segment8 = x_lines_rec.inventory_item_segment8
          AND    segment9 = x_lines_rec.inventory_item_segment9
          AND    segment10 = x_lines_rec.inventory_item_segment10
          AND    segment11 = x_lines_rec.inventory_item_segment11
          AND    segment12 = x_lines_rec.inventory_item_segment12
          AND    segment13 = x_lines_rec.inventory_item_segment13
          AND    segment14 = x_lines_rec.inventory_item_segment14
          AND    segment15 = x_lines_rec.inventory_item_segment15
          AND    segment16 = x_lines_rec.inventory_item_segment16
          AND    segment17 = x_lines_rec.inventory_item_segment17
          AND    segment18 = x_lines_rec.inventory_item_segment18
          AND    segment19 = x_lines_rec.inventory_item_segment19
          AND    segment20 = x_lines_rec.inventory_item_segment20
          AND    customer_order_enabled_flag = 'Y';
          --
          v_progress := '040';

          --check if this is the same as derived from customer item

          IF(v_InventoryItemIdFromSeg <> x_lines_rec.inventory_item_id) THEN

            rlm_message_sv.app_error(
                         x_ExceptionLevel => rlm_message_sv.k_warn_level,
                         x_MessageName => 'RLM_INV_ITEM_SEG_MISMATCH',
                         x_InterfaceHeaderId => x_lines_rec.header_id,
                         x_InterfaceLineId => x_lines_rec.line_id);
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog('WARNING: RLM_INVENTORY_ITEM_SEG_MISMATCH');
            END IF;
	    --
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            --
            rlm_message_sv.app_error(
                         x_ExceptionLevel => rlm_message_sv.k_warn_level,
                         x_MessageName => 'RLM_INVALID_INVENTORY_ITEM_SEG',
                         x_InterfaceHeaderId => x_lines_rec.header_id,
                         x_InterfaceLineId => x_lines_rec.line_id);
	    --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog('WARNING: RLM_INVALID_INVENTORY_ITEM_SEGMENTS');
            END IF;
            --

        END;
        --
      END IF; --checks for supplier and inv item segments
      --
    END IF; --inventory_item_id
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'inventory_item_id is ' ||
                                 x_lines_rec.inventory_item_id);
    END IF;
    --
  END IF;
  --
  -- global_atp
  -- Validate: ATP items in sequenced schedule should be rejected
  IF RLM_MANAGE_DEMAND_SV.IsATPItem(x_lines_rec.ship_from_org_id,
                                    x_lines_rec.inventory_item_id) THEN
     --
     IF x_header_rec.schedule_type = 'SEQUENCED' THEN
        --
        RAISE e_ATPSequenced;
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
  --
  WHEN e_ATPSequenced THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_ATP_SEQUENCED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'INVENTORY_ITEM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_ATP_SEQUENCED');
    END IF;
    --
  WHEN e_NullCustItemId THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_NULL_CUSTOMER_ITEM_ID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=> 'CUSTEXT',
                x_value1=> x_lines_rec.customer_item_ext,
                x_ValidationType => 'INVENTORY_ITEM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: RLM_NULL_CUSTOMER_ITEM_ID');
    END IF;
    --
  WHEN e_SuppItemInvalid THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SUPPLIER_ITEM_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'SUPPLIER_ITEM_EXT',
                x_value1=>x_lines_rec.supplier_item_ext,
                x_ValidationType => 'INVENTORY_ITEM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SUPPLIER_ITEM_INVALID');
    END IF;
    --
  WHEN e_InvalidItem THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_INVENTORY_ITEM_INACTIVE',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=> 'CUSTOMER_ITEM',
                x_value1=> RLM_CORE_SV.get_item_number(v_customer_item_id),
                x_ValidationType => 'INVENTORY_ITEM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_INVENTORY_ITEM_INACTIVE');
    END IF;
    --
  WHEN e_NotCustOrderEnabled THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
             x_ExceptionLevel => rlm_message_sv.k_error_level,
             x_MessageName => 'RLM_ITEM_NOT_CUST_ORDERABLE',
             x_InterfaceHeaderId => x_lines_rec.header_id,
             x_InterfaceLineId => x_lines_rec.line_id,
             x_GroupInfo => TRUE,
             x_token1=>'CUSTOMER_ITEM',
             x_value1=>v_CustomerItemNumber,
             x_token2=>'SHIP_FROM_ORG',
             x_value2=>RLM_CORE_SV.get_ship_from(x_lines_rec.ship_from_org_id),
             x_ValidationType => 'INVENTORY_ITEM');
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION:RLM_ITEM_NOT_CUST_ORDERABLE');
    END IF;
    --
  WHEN NO_DATA_FOUND THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_INVITEM_NOT_DERIVED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'INVENTORY_ITEM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_INVITEM_NOT_DERIVED');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveInventoryItemId',
                                                       v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DeriveInventoryItemId;

/*===========================================================================

	PROCEDURE NAME:  ValidateCustomerItem

===========================================================================*/
PROCEDURE ValidateCustomerItem(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_progress     VARCHAR2(3) := '010';

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidateCustomerItem');
     rlm_core_sv.dlog(C_DEBUG,'customer item ext', x_lines_rec.customer_item_ext);
     rlm_core_sv.dlog(C_DEBUG,'customer_item_id', x_lines_rec.customer_item_id);
     rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id',x_lines_rec.ship_to_address_id);
  END IF;
  --
  IF rlm_message_sv.check_dependency('CUSTOMER_ITEM') THEN
    --
    IF x_lines_rec.customer_item_id IS NULL THEN
     --
     BEGIN
       --
       IF (l_debug <> -1) THEN
	  rlm_core_sv.dlog(C_DEBUG, 'Check if item is defined at address level in Inventory');
          rlm_core_sv.dlog(C_DEBUG,'x_header_rec.customer_id', x_header_rec.customer_id);
          rlm_core_sv.dlog(C_DEBUG, 'x_lines_rec.ship_to_address_id', x_lines_rec.ship_to_address_id);
       END IF;
       --
       SELECT customer_item_id
       INTO x_lines_rec.customer_item_id
       FROM mtl_customer_items
       WHERE customer_item_number = x_lines_rec.customer_item_ext
       AND   customer_id   = x_header_rec.customer_id
       AND   address_id    = x_lines_rec.ship_to_address_id
       AND   item_definition_level = '3'
       AND   inactive_flag = 'N';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'Address level, customer item ID', x_lines_rec.customer_item_id);
       END IF;
       --
     EXCEPTION
       --
       WHEN NO_DATA_FOUND THEN
       --
       IF (l_debug <> -1) THEN
	  rlm_core_sv.dlog(C_DEBUG, 'Check if item is defined at address-category level in Inventory');
          rlm_core_sv.dlog(C_DEBUG,'x_header_rec.customer_id', x_header_rec.customer_id);
       END IF;
       --
       BEGIN
         --
         -- Following query is changed as per TCA obsolescence project.
         SELECT mci.customer_item_id
         INTO x_lines_rec.customer_item_id
         FROM mtl_customer_items mci
         WHERE mci.customer_item_number = x_lines_rec.customer_item_ext
         AND   mci.customer_id   = x_header_rec.customer_id
         AND   x_lines_rec.ship_to_address_id IN
			       (select cust_acct_site_id from hz_cust_acct_sites
			        where customer_category_code = mci.customer_category_code
			        and cust_account_id = mci.customer_id)
         AND   mci.item_definition_level = '2'
         AND   mci.inactive_flag = 'N';
         --
         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'Address-Cat level, customer item ID', x_lines_rec.customer_item_id);
         END IF;
         --
         EXCEPTION
           --
           WHEN NO_DATA_FOUND THEN
            --
            IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'Check if item is defined at customer level in Inventory');
            END IF;
            --
            SELECT customer_item_id
            INTO x_lines_rec.customer_item_id
            FROM mtl_customer_items
            WHERE customer_item_number = x_lines_rec.customer_item_ext
            AND   address_id IS NULL
            AND   customer_id   = x_header_rec.customer_id
            AND   item_definition_level = '1'
            AND   inactive_flag = 'N';
            --
            IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'Customer Level, customer item ID', x_lines_rec.customer_item_id);
            END IF;
            --
       END;
       --
     END;
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
  --
  WHEN NO_DATA_FOUND THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    -- bug 5197388
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_CUSTOMER_ITEM_NOT_DERIVED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'CUSTOMER_ITEM',
                x_value1=>x_lines_rec.customer_item_ext,
                x_token2=>'CUSTOMER',
                x_value2=>nvl(rlm_core_sv.get_customer_name(x_header_rec.customer_id), x_header_rec.cust_name_ext ),
                x_ValidationType => 'CUSTOMER_ITEM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUSTOMER_ITEM_NOT_DERIVED');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.ValidateCustomerItem',
                                                v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidateCustomerItem;

/*===========================================================================

	PROCEDURE NAME:  DerivePurchaseOrder

===========================================================================*/

PROCEDURE DerivePurchaseOrder(
                 x_setup_terms_rec  IN rlm_setup_terms_sv.setup_terms_rec_typ,
                 x_header_rec IN rlm_interface_headers%ROWTYPE,
                 x_lines_rec IN OUT NOCOPY rlm_interface_lines%ROWTYPE)
IS
  --
  l_org_code              VARCHAR2(30);
  v_progress              VARCHAR2(3) := '010';
  v_OE_Purchase_Order     VARCHAR2(50);
  v_Agreement_id          NUMBER;
  v_Agreement_Name        VARCHAR2(240);
  v_fut_Agreement_id      NUMBER;
  v_fut_Agreement_Name    VARCHAR2(240);
  v_start_date            DATE;
  v_end_date              DATE;
  x_Price_list_id         NUMBER;
  v_Price_list_name       VARCHAR2(240);
  --DeriveARPriceList     BOOLEAN := FALSE;
  e_SetupAgreementInv     EXCEPTION;
  e_POAgreementDiff       EXCEPTION;
  e_POWithoutAgreement    EXCEPTION;
  e_POAgreementInv        EXCEPTION;
  e_CustMissingPriceList  EXCEPTION;
  e_POAgreementInactive   EXCEPTION;
  e_PriceListInactive     EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DerivePurchaseOrder');
     rlm_core_sv.dlog(C_DEBUG,'item_detail_type', x_lines_rec.item_detail_type);
  END IF;
  --
  IF rlm_message_sv.check_dependency('PURCHASE_ORDER') THEN
    --
    IF x_lines_rec.item_detail_type in ('0','1','2') THEN
       --
       v_Agreement_id := x_setup_terms_rec.agreement_id;
       v_Agreement_Name := x_setup_terms_rec.agreement_name;
       v_fut_Agreement_id := x_setup_terms_rec.future_agreement_id;
       v_fut_Agreement_Name := x_setup_terms_rec.future_agreement_name;
       x_Price_list_id := x_setup_terms_rec.price_list_id;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'x_setup_terms_rec.agreement_name',v_Agreement_Name);
          rlm_core_sv.dlog(C_DEBUG,'x_setup_terms_rec.agreement_id',v_Agreement_Id);
          rlm_core_sv.dlog(C_DEBUG,'x_setup_terms_rec.fut_agreement_id',v_fut_Agreement_Id);
          rlm_core_sv.dlog(C_DEBUG,'x_setup_terms_rec.Price_list_id',x_Price_list_id);
          rlm_core_sv.dlog(C_DEBUG,'PO on schedule - cust_po_number',
                                               x_lines_rec.cust_po_number);
       END IF;
       --
       IF (x_Price_list_id IS NULL) THEN
        --
        x_lines_rec.price_list_id := x_Price_list_id;
        --
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dlog(C_DEBUG, ' Null price list x_lines_rec.price_list_id', x_lines_rec.price_list_id);
	END IF;
        --
       END IF;
       --
       IF (v_Agreement_id is NULL) THEN  --Changed from Agreement_name to agreement_id
	--
        x_lines_rec.agreement_id := NULL;
	--
	IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'Null agreement on setup terms x_lines_rec.agreement_id', x_lines_rec.agreement_id);
        END IF;
        --
       END IF;
       --
       ---Replaced Agreement_id with Agreement_name
       IF  v_agreement_id is NOT NULL THEN
         --
         v_progress := '020';
         --
         BEGIN
           --
           v_start_date := x_lines_rec.start_date_time;

           SELECT oea.price_list_id, oea.purchase_order_num
           INTO   x_lines_rec.price_list_id,
                  v_OE_Purchase_Order
           FROM   oe_agreements oea
           WHERE  oea.agreement_id  = v_agreement_id
           AND  v_start_date between nvl(oea.start_date_active, to_date('01/01/1900','dd/mm/yyyy'))
                and nvl(oea.end_date_active, to_date('31/12/4712','dd/mm/yyyy'));
           --
           x_lines_rec.agreement_id := v_agreement_id;
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'current agreement Purchase Order',
                                                 v_OE_Purchase_Order);
              rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.Price_List_Id',
                                         x_lines_rec.Price_List_Id);
              rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.agreement_id',
                                         x_lines_rec.agreement_id);
              rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.cust_po_number',
                                         x_lines_rec.cust_po_number);
           END IF;
	   --
         EXCEPTION
            --
            WHEN NO_DATA_FOUND THEN
              --
  	      IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'Start date time does not fall
                     within the current agreement effective dates');
              END IF;
              --
              v_progress := '030';
              BEGIN
                --
                SELECT  oea.price_list_id, oea.purchase_order_num
                INTO  x_lines_rec.price_list_id,
                       v_OE_Purchase_Order
                FROM   oe_agreements oea
                WHERE  agreement_id = v_fut_agreement_id
                AND  v_start_date between nvl(oea.start_date_active, to_date('01/01/1900','dd/mm/yyyy') )
                      and nvl(oea.end_date_active, to_date('31/12/4712','dd/mm/yyyy'));
                 --
                 x_lines_rec.agreement_id := v_fut_agreement_id;
                 --

  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,' future agreement Purchase_Order',
                                                          v_OE_Purchase_Order);
                   rlm_core_sv.dlog(C_DEBUG,' future agreement Price List',
                                         x_lines_rec.Price_List_Id);
                   rlm_core_sv.dlog(C_DEBUG,'PO number on schedule ',
                                         x_lines_rec.cust_po_number);
                END IF;
                --
              EXCEPTION
                --
                WHEN NO_DATA_FOUND THEN
                     --
  		     IF (l_debug <> -1) THEN

                        rlm_core_sv.dlog(C_DEBUG,'WARNING: No Agreement_id found for future and current agreements ');
                        rlm_core_sv.dlog(C_DEBUG,' agreement Purchase_Order',
                                                          v_OE_Purchase_Order);
                        rlm_core_sv.dlog(C_DEBUG,' Price List',
                                         x_lines_rec.Price_List_Id);
                        rlm_core_sv.dlog(C_DEBUG,'PO number on schedule ',
                                         x_lines_rec.cust_po_number);
                     END IF;
		     --
                     rlm_message_sv.app_error(
                             x_ExceptionLevel => rlm_message_sv.k_warn_level,
                             x_MessageName => 'RLM_SETUP_AGREEMENT_INVALID',
                             x_InterfaceHeaderId => x_lines_rec.header_id,
                             x_InterfaceLineId => x_lines_rec.line_id,
                             x_token1=>'CURRENT_AGR',
                             x_value1=>v_Agreement_Name,
                             x_token2=>'FUTURE_AGR',
                             x_value2=>v_fut_Agreement_Name,
                             x_ValidationType => 'PURCHASE_ORDER');
		     --
  		     IF (l_debug <> -1) THEN
                        rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
                        rlm_core_sv.dlog(C_SDEBUG,'RLM_SETUP_AGREEMENT_INVALID');
                     END IF;
                     --
                WHEN OTHERS THEN
                     --
  		     IF (l_debug <> -1) THEN
                        rlm_core_sv.dlog(C_DEBUG,'EXCEPTION:'
                                                   ||SUBSTR(SQLERRM,1,200));
                     END IF;
		     --
                     raise ;
                     --
              END;
              --
            WHEN OTHERS THEN
                --
  		IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
                END IF;
		--
                raise ;
                --
         END;
         --
         v_start_date := null;
         v_progress := '030';
         IF x_lines_rec.cust_po_number IS NOT NULL AND
            x_lines_rec.cust_po_number <> v_OE_Purchase_Order THEN
            --
            raise e_POAgreementDiff;
            --
         END IF;
         --
       ELSE
          IF x_Price_list_id is NOT NULL THEN
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'x_Price_List_Id',
                                        x_Price_List_Id);
             END IF;
	     --
             x_lines_rec.PRICE_LIST_ID := x_Price_List_Id;
	     --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.cust_po_number',
                                       x_lines_rec.cust_po_number);
             END IF;
             --
             IF x_lines_rec.cust_po_number is NOT NULL THEN
                v_Progress := '015';
                --perf raise e_POWithoutAgreement;
             END IF;
             --
          /* ELSE took out this portion for bug 1490685
            IF x_lines_rec.cust_po_number is NOT NULL THEN
             v_Progress := '020';
	     --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.cust_po_number',
                                         x_lines_rec.cust_po_number);
             END IF;
	     --
             BEGIN
                 SELECT oea.agreement_id, oea.name,
                        oea.price_list_id,oea.start_date_active,
                        oea.end_date_active
                 INTO   x_lines_rec.agreement_id, v_agreement_name,
                        x_lines_rec.price_list_id, v_start_date, v_end_date
                 FROM   oe_agreements oea
                 WHERE  purchase_order_num = x_lines_rec.cust_po_number
                 AND    x_lines_rec.start_date_time
                        BETWEEN oea.start_date_active AND
                        nvl(oea.end_date_active,
                        to_date('31/12/4712','dd/mm/yyyy'))
                 AND    revision = (Select MAX(oem.revision)
                        FROM oe_agreements oem
                        WHERE oem.purchase_order_num =
                                x_lines_rec.cust_po_number);
	         --
  		 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.price_list_id',
                                         x_lines_rec.price_list_id);
                 END IF;
                 --
                 IF x_lines_rec.start_date_time > v_end_date OR
                    x_lines_rec.start_date_time < v_start_date THEN
                    --
                    rlm_message_sv.app_error(
                         x_ExceptionLevel => rlm_message_sv.k_warn_level,
                         x_MessageName => 'RLM_AGREEMENT_INACTIVE',
                         x_InterfaceHeaderId => x_lines_rec.header_id,
                         x_InterfaceLineId => x_lines_rec.line_id,
                         x_token1=>'PURCHASE_ORDER',
                         x_value1=>x_lines_rec.cust_po_number,
                         x_token2=>'AGREEMENT_NAME',
                         x_value2=>v_agreement_name,
                         x_ValidationType => 'PURCHASE_ORDER');
		     --
  		     IF (l_debug <> -1) THEN
                        rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
                     END IF;
                     --
                 END IF;
                 --
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
			--
  			IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG,'WARNING:
                         Cannot Derive agreement from Purchase Order on line');
                        END IF;
			--
                        --DeriveARPriceList := TRUE;
                        rlm_message_sv.app_error(
                                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                                x_MessageName => 'RLM_WARN_PO_AGREEMENT_ID',
                                x_InterfaceHeaderId => x_lines_rec.header_id,
                                x_InterfaceLineId => x_lines_rec.line_id,
                                x_token1=>'PURCHASE_ORDER',
                                x_value1=>x_lines_rec.cust_po_number,
                                x_ValidationType => 'PURCHASE_ORDER');
			--
			IF (l_debug <> -1) THEN
                           rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
                           rlm_core_sv.dlog(C_SDEBUG,'RLM_WARN_PO_AGREEMENT_ID');
                        END IF;
                        --
                    WHEN OTHERS THEN
                       rlm_message_sv.sql_error(
                        'rlm_validateDemand_sv.DerivePurchaseOrder',v_Progress);
		       --
  		       IF (l_debug <> -1) THEN
                          rlm_core_sv.dlog(C_DEBUG,'EXCEPTION:'||SUBSTR(SQLERRM,1,200));
                       END IF;
		       --
                       raise ;
             END;
            END IF; */

          END IF;/* Price List Id is  not NULL */
       END IF; /* Agreement name not null */
       --
       v_progress := '051';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'CustomerId',x_header_rec.customer_id);
          rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.cust_po_number',
                                         x_lines_rec.cust_po_number);
          rlm_core_sv.dlog(C_DEBUG,'x_Price_List_Id',x_Price_List_Id);
          rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.agreement_id',
                                              x_lines_rec.agreement_id);
       END IF;
       --
/*
        IF DeriveARPriceList THEN
          v_progress := '055';
          BEGIN
	      --
  	      IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'x_header_rec.customer_id',
                                             x_header_rec.customer_id);
              END IF;
	      --
              -- Following query is changed as per TCA obsolescence project.
              SELECT	CUST_ACCT.PRICE_LIST_ID
              INTO	x_lines_rec.PRICE_LIST_ID
              FROM	HZ_CUST_ACCOUNTS CUST_ACCT
              WHERE	CUST_ACCT.CUST_ACCOUNT_ID = x_header_rec.customer_id;
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
		  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: NO_DATA_FOUND');
                  END IF;
		  --
                  raise e_CustMissingPriceList;
		  --
               WHEN OTHERS THEN
		  --
  		  IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(C_DEBUG,'EXCEPTION:'||SUBSTR(SQLERRM,1,200));
                  END IF;
		  --
                  raise ;
          END;
       END IF;
 */
       --
       IF x_lines_rec.price_list_id is NOT NULL THEN
          --
          v_progress := '060';
	  --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'Price list id',x_lines_rec.price_list_id);
          END IF;
	  --
          BEGIN
             --
             SELECT oep.name
             INTO   v_Price_list_name
             FROM   qp_list_headers oep
             WHERE  oep.LIST_HEADER_ID = x_lines_rec.price_list_id
             AND    x_lines_rec.start_date_time BETWEEN
                    nvl(oep.start_date_active,
                     to_date('01/01/1900','dd/mm/yyyy'))  AND
                    nvl(oep.end_date_active,to_date('31/12/4712','dd/mm/yyyy'));
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG, 'Price list name', v_Price_list_name);
             END IF;
             --
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  raise e_PriceListInactive;
          END;
          --
       END IF; /* checking effective dates for price lists */
       --
    END IF; /* Item detail type in (0,1,2)*/
    --
    v_progress := '070';
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN e_PriceListInactive THEN
    -- Waning message
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_PRICE_LIST_INACTIVE',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'PRICE_LIST',
            x_value1=>v_Price_list_name,
            x_token2=>'START_DATE',
            x_value2=>x_lines_rec.start_date_time,
            x_ValidationType => 'PURCHASE_ORDER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'RLM_PRICE_LIST_INACTIVE');
    END IF;
    --
  WHEN e_POAgreementDiff THEN
    -- Waning message
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_WARN_SETUP_PO_MISMATCH',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'PRICING_CONTRACT',
            x_value1=>v_Agreement_Name,
            x_token2=>'PURCHASE_ORDER',
            x_value2=>x_lines_rec.cust_po_number,
            x_token3=>'SETUP_PURCHASE_ORDER',
            x_value3=>v_OE_Purchase_Order,
            x_ValidationType => 'PURCHASE_ORDER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'RLM_SETUP_PO_MISMATCH');
    END IF;
    --
  WHEN e_POAgreementInv THEN
    -- Waning message
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_WARN_PO_AGREEMENT_ID',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'PURCHASE_ORDER',
            x_value1=>x_lines_rec.cust_po_number,
            x_ValidationType => 'PURCHASE_ORDER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'RLM_WARN_PO_AGREEMENT_ID');
    END IF;
    --
  WHEN e_POWithoutAgreement THEN
    -- Warning message
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_WARN_PO_WITHOUT_AGREEMENT',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'PURCHASE_ORDER',
            x_value1=>x_lines_rec.cust_po_number,
            x_ValidationType => 'PURCHASE_ORDER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'RLM_WARN_PO_WITHOUT_AGREEMENT');
    END IF;
    --
  WHEN e_CustMissingPriceList THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_CUST_WITHOUT_PRICELIST',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=> 'CUSTEXT',
            x_value1=> nvl(x_header_rec.customer_ext,
                           x_header_rec.ece_tp_translator_code),
            x_ValidationType => 'PURCHASE_ORDER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'RLM_CUST_WITHOUT_PRICELIST');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DerivePurchaseOrder',
                                                 v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DerivePurchaseOrder;

/*===========================================================================

	PROCEDURE NAME:  DeriveCustomerID

===========================================================================*/
PROCEDURE DeriveCustomerID(x_header_rec  IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS

  v_progress     VARCHAR2(3) := '010';
  --
  v_ReturnStatus        VARCHAR2(10);
  v_MsgCount            NUMBER;
  v_MsgData             VARCHAR2(2000);
  v_Customer            VARCHAR2(35);
  v_ShipToLoc           VARCHAR2(35);
  v_shipToAddressId	NUMBER;
  v_tmp_ship            NUMBER;
  e_InvalidCustomerExt  EXCEPTION;
  e_NullCustomerExt     EXCEPTION;
  e_NullShipToExt       EXCEPTION;
  --
BEGIN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpush(C_SDEBUG,'DeriveCustomerID');
     END IF;
     --
     --
     v_progress := '020';
     --
     -- if customer_id is not null then we do not need to derive the cust id
     -- again as it has already been allocated before
     -- Choose the Customer based on customer_ext or ece_tp_translator_code

     IF x_header_rec.customer_id IS NULL  THEN
        --
        IF x_header_rec.customer_ext IS NOT NULL THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'customer_ext ',x_header_rec.customer_ext);
          END IF;
	  --
          v_Customer := x_header_rec.customer_ext;
          --
        ELSIF  x_header_rec.ece_tp_translator_code IS NOT NULL THEN
          --
	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'ece_tp_translator_code',
                                     x_header_rec.ece_tp_translator_code);
          END IF;
	  --
          v_Customer := x_header_rec.ece_tp_translator_code;
          --
        END IF;
        -- CR Changes
        -- Choose the Ship To Location based on
        -- ece_tp_location_code_ext first.  If this is null, look for
        -- line level cust_ship_to_ext

        IF x_header_rec.ece_tp_location_code_ext IS NOT NULL THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'ece_tp_location_code_ext',
                                         x_header_rec.ece_tp_location_code_ext);                   END IF;
          --
          v_ShipToLoc := x_header_rec.ece_tp_location_code_ext;
          --
        ELSIF x_lines_rec.cust_ship_to_ext IS NOT NULL THEN
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'cust_ship_to_ext ',
                                             x_lines_rec.cust_ship_to_ext);
          END IF;
	  --
          v_ShipToLoc := x_lines_rec.cust_ship_to_ext;
--          g_LineLevelShipTo := TRUE;
          --
        END IF;

        IF v_Customer IS NOT NULL THEN
          --
          v_progress := '030';
	  --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'v_Customer ', v_Customer);
             rlm_core_sv.dlog(C_DEBUG,'v_ShipToLoc ', v_ShipToLoc);
          END IF;
          --
          ece_trading_partners_pub.get_tp_address(1, NULL, NULL, NULL,
                                        NULL, v_ReturnStatus, v_MsgCount,
                                        v_MsgData,
                                        v_Customer,
                                        v_ShipToLoc,
                                        'CUSTOMER',
                                        x_header_rec.customer_id,
                                        v_shipToAddressId);
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'customer_id ',x_header_rec.customer_id);
             rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id ',
                                            v_shipToAddressId);
          END IF;
          --
           IF x_header_rec.customer_id IS NULL THEN
             IF v_ShipToLoc IS NOT NULL THEN
               BEGIN
                  v_progress := '060';
                   --
  		   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'v_Customer ', v_Customer);
                      rlm_core_sv.dlog(C_DEBUG,'v_ShipToLoc ', v_ShipToLoc);
                   END IF;
                   --
                   -- Following query is changed as per TCA obsolescence project.
                   SELECT DISTINCT ACCT_SITE.CUST_ACCOUNT_ID
                   INTO   x_header_rec.customer_id
                   FROM   HZ_CUST_ACCT_SITES ACCT_SITE ,
                          ece_tp_headers eth
                   WHERE  ACCT_SITE.tp_header_id = eth.tp_header_id
                   AND    ACCT_SITE.ece_tp_location_code = v_ShipToLoc
                   AND    eth.TP_REFERENCE_EXT1 = v_Customer;
                  --
  	          IF (l_debug <> -1) THEN
                     rlm_core_sv.dlog(C_DEBUG,'customer_id ',
                                                 x_header_rec.customer_id);
                  END IF;
                  --
                  IF x_header_rec.ece_tp_location_code_ext IS NULL THEN
                   g_LineLevelShipTo := TRUE;
                  END IF;
                  --
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    raise e_InvalidCustomerExt;
                  WHEN OTHERS THEN
                    raise;
               END;
             ELSE
                 raise e_NullShipToExt;
             END IF; /*If v_ShipToLoc Not Null */
           END IF; /*If customer_id NULL */
          --
        ELSE
           raise e_NullCustomerExt;
        END IF; /*If v_Customer Not Null */
     ELSE
      --{
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'customer_id ', x_header_rec.customer_id);
      END IF;
      --}
     END IF;
     --
     IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
             ec_debug.disable_debug;
     END IF;
     --
     v_progress := '080';
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    -- Warning
/*
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_PRIMARYADDRESS_NOT_DERIVED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'CUSTOMER');

    rlm_core_sv.dpop(C_SDEBUG,'WARNING: RLM_PRIMARYADDRESS_NOT_DERIVED');
*/
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN e_NullCustomerExt THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    g_Schedule_PS := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_CUSTOMER_NULL',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'CUSTOMER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUSTOMER_NULL');
    END IF;
    --
  WHEN e_NullShipToExt THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    g_Schedule_PS := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_SHIPTO_NULL',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'CUSTOMER_EXT',
                x_value1=>v_Customer,
                x_ValidationType => 'CUSTOMER');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIPTO_NULL');
    END IF;
    --
  WHEN e_InvalidCustomerExt THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    g_Schedule_PS := rlm_core_sv.k_PS_ERROR;
    --
    IF x_header_rec.customer_ext IS NOT NULL THEN
       --
       IF x_lines_rec.cust_ship_to_ext IS NOT NULL THEN
           --
           rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_error_level,
                       x_MessageName => 'RLM_CUST_SHIP_TO_INVALID',
                       x_InterfaceHeaderId => x_lines_rec.header_id,
                       x_InterfaceLineId => x_lines_rec.line_id,
                       x_token1=>'CUSTOMER_EXT',
                       x_value1=>x_header_rec.customer_ext,
                       x_token2=>'SHIP_TO',
                       x_value2=>x_lines_rec.cust_ship_to_ext,
                       x_ValidationType => 'CUSTOMER');
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
              rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUST_SHIP_TO_INVALID');
           END IF;
           --
       ELSIF x_header_rec.ece_tp_location_code_ext IS NOT NULL THEN
           --
           rlm_message_sv.app_error(
                       x_ExceptionLevel => rlm_message_sv.k_error_level,
                       x_MessageName => 'RLM_CUST_TPLOC_INVALID',
                       x_InterfaceHeaderId => x_lines_rec.header_id,
                       x_InterfaceLineId => x_lines_rec.line_id,
                       x_token1=>'CUSTOMER_EXT',
                       x_value1=>x_header_rec.customer_ext,
                       x_token2=>'TP_LOCATION',
                       x_value2=>x_header_rec.ece_tp_location_code_ext,
                       x_ValidationType => 'CUSTOMER');
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
              rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUST_TPLOC_INVALID');
           END IF;
           --
       END IF;
       --
    ELSIF x_header_rec.ece_tp_translator_code IS NOT NULL THEN
       --
       IF x_lines_rec.cust_ship_to_ext IS NOT NULL THEN
          --
          rlm_message_sv.app_error(
                      x_ExceptionLevel => rlm_message_sv.k_error_level,
                      x_MessageName => 'RLM_TP_TRANSL_SHIPTO_INVALID',
                      x_InterfaceHeaderId => x_lines_rec.header_id,
                      x_InterfaceLineId => x_lines_rec.line_id,
                      x_token1=>'TP_TRANSLATOR',
                      x_value1=>x_header_rec.ece_tp_translator_code,
                      x_token2=>'SHIP_TO',
                      x_value2=>x_lines_rec.cust_ship_to_ext,
                      x_ValidationType => 'CUSTOMER');
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
             rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_TP_TRANSL_SHIPTO_INVALID');
          END IF;
          --
       ELSIF x_header_rec.ece_tp_location_code_ext IS NOT NULL THEN
          --
          rlm_message_sv.app_error(
                      x_ExceptionLevel => rlm_message_sv.k_error_level,
                      x_MessageName => 'RLM_TP_TRANSL_LOC_CODE_INVALID',
                      x_InterfaceHeaderId => x_lines_rec.header_id,
                      x_InterfaceLineId => x_lines_rec.line_id,
                      x_token1=>'TP_TRANSLATOR',
                      x_value1=>x_header_rec.ece_tp_translator_code,
                      x_token2=>'TP_LOCATION',
                      x_value2=>x_header_rec.ece_tp_location_code_ext,
                      x_ValidationType => 'CUSTOMER');
          --
  	  IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
             rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_TP_TRANSL_LOC_CODE_INVALID');
          END IF;
          --
       END IF;
       --
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    g_Schedule_PS := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveCustomerID',
                                                                 v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DeriveCustomerID;

/*===========================================================================

	PROCEDURE NAME:  DeriveShipFromOrg

===========================================================================*/
PROCEDURE DeriveShipFromOrg(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
                            x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  l_org_code  VARCHAR2(30);
  v_progress  VARCHAR2(3) := '010';
  e_NoDataFound  EXCEPTION;
  e_ManyRows     EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DeriveShipFromOrg');
     rlm_core_sv.dlog(C_DEBUG,'cust_ship_from_org_ext',
                                 x_lines_rec.cust_ship_from_org_ext);
     rlm_core_sv.dlog(C_DEBUG,'ship_from_org_id ', x_lines_rec.ship_from_org_id);
  END IF;
  --
  IF rlm_message_sv.check_dependency('SHIP_FROM_ORG') THEN
    --
    IF x_lines_rec.ship_from_org_id IS NULL THEN
    --
     IF x_lines_rec.cust_ship_from_org_ext IS NOT NULL THEN
       --
       v_progress := '020';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'cust_ship_from_org_ext ',
              x_lines_rec.cust_ship_from_org_ext);
          rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id ',
              x_lines_rec.ship_to_address_id);
       END IF;
       --
       BEGIN
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'Customer Address Level');
         END IF;
	 --
         SELECT ship_from_org_id
         INTO   x_lines_rec.ship_from_org_id
         FROM   rlm_cust_shipto_terms t
          WHERE  customer_id = x_header_rec.customer_id
         AND    address_id  = nvl(x_lines_rec.ship_to_address_id,address_id)
         AND    cust_assign_supplier_cd =
                              x_lines_rec.cust_ship_from_org_ext;
         --
         v_progress := '030';
	 --
	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'organization id ' ||
                                 x_lines_rec.ship_from_org_id);
         END IF;
         --
       EXCEPTION
          --
          WHEN NO_DATA_FOUND THEN
             --
             BEGIN
               --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'Customer Level');
               END IF;
               --
               SELECT ship_from_org_id
               INTO   x_lines_rec.ship_from_org_id
               FROM   rlm_cust_shipto_terms t
               WHERE  customer_id = x_header_rec.customer_id AND
                      address_id IS NULL  AND
                      cust_assign_supplier_cd =
                                    x_lines_rec.cust_ship_from_org_ext;
               --
               v_progress := '040';
	       --
  	       IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'organization id ' ||
                                   x_lines_rec.ship_from_org_id);
               END IF;
             --
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     raise e_NoDataFound;
                WHEN TOO_MANY_ROWS THEN
		     --
  		     IF (l_debug <> -1) THEN
                        rlm_core_sv.dlog(C_DEBUG,'organization id ' ||
                                             x_lines_rec.ship_from_org_id);
                     END IF;
	 	     --
                     raise e_ManyRows;
             END;
	     --
          WHEN TOO_MANY_ROWS THEN
	     --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'organization id ' ||
                                      x_lines_rec.ship_from_org_id);
             END IF;
	     --
             raise e_ManyRows;
	     --
          WHEN OTHERS THEN
             --
             rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveShipFromOrg',
                                                     v_Progress);
	     --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
             END IF;
	     --
             raise;
       END;
       --
    END IF;

    --
   ELSE
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'ship_from_org_id ',x_lines_rec.ship_from_org_id);
     END IF;
     --
   END IF;
   --
   v_progress := '060';
   --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND or e_NoDataFound THEN
    --
    --2859506. ATP items should send null values for ship from org ext
    IF x_lines_rec.cust_ship_from_org_ext IS NOT NULL THEN
           --
       x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
       --Bug Fix 2892076 added call to procedure app_error

       rlm_message_sv.app_error(
                    x_ExceptionLevel => rlm_message_sv.k_error_level,
                    x_MessageName => 'RLM_SHIPFROM_NOT_DERIVED',
                    x_InterfaceHeaderId => x_lines_rec.header_id,
                    x_InterfaceLineId => x_lines_rec.line_id,
                    x_token1=>'SHIP_FROM_ORG_EXT',
                    x_value1=>x_lines_rec.cust_ship_from_org_ext,
                    x_ValidationType => 'SHIP_FROM_ORG');
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
           rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIPFROM_NOT_DERIVED');
        END IF;
        --
        --raise; /* Bug 4395540 */
        --BUG 5098241 commented the raise
        --
    ELSE
      -- global_atp to be derived by Setup API later
      x_lines_rec.ship_from_org_id := NULL;
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'Null ship from org id ');
      END IF;
    END IF;
    --
  WHEN e_ManyRows THEN
    --
    -- global_atp to be derived by Setup API later
    x_lines_rec.ship_from_org_id := NULL;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'In too many rows use default SF');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveShipFromOrg', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DeriveShipFromOrg;

/*===========================================================================

	PROCEDURE NAME:  derive_intmd_shipto_id

===========================================================================*/
PROCEDURE DeriveIntrmdShipToID(x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                               x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
       CURSOR c_IntrmdShipToID_ext IS  --Added cursor as part of Bugfix 8672453
         SELECT ACCT_SITE.CUST_ACCT_SITE_ID,
                ACCT_SITE.STATUS, SITE_USES.STATUS,
                SITE_USES.site_use_id
         FROM   HZ_CUST_ACCT_SITES	ACCT_SITE,
                HZ_CUST_SITE_USES_ALL    SITE_USES
         WHERE  acct_site.ece_tp_location_code =
                x_lines_rec.cust_intrmd_ship_to_ext
         AND    acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
         AND    site_uses.site_use_code = 'SHIP_TO'
         AND    acct_site.org_id = site_uses.org_id
         AND    cust_account_id IN
                 (SELECT to_number(x_header_rec.customer_id) from dual
                 UNION
                 SELECT cust_account_id
                 FROM hz_cust_acct_relate_all
                 WHERE related_cust_account_id = x_header_rec.customer_id
                 AND ship_to_flag = 'Y'
                 AND status = 'A'
                 AND org_id = x_header_rec.org_id
                 AND oe_sys_parameters.value('CUSTOMER_RELATIONSHIPS_FLAG') IN ('Y', 'A'))
        ORDER BY site_uses.status; --To query first Active and then Inactive records

       CURSOR c_IntrmdShipToID IS  --Added cursor as part of Bugfix 8672453
         SELECT hcas.status, cust_account_id, hcsu.status,
                 hcsu.site_use_id
          FROM   hz_cust_acct_sites_all hcas, hz_cust_site_uses_all hcsu
          WHERE  hcas.cust_acct_site_id = x_lines_rec.intrmd_ship_to_id
          AND    hcas.cust_acct_site_id = hcsu.cust_acct_site_id
          AND    hcsu.site_use_code = 'SHIP_TO'
          AND    hcas.org_id = hcsu.org_id
        ORDER BY hcsu.status; --To query first Active and then Inactive records

  v_progress            VARCHAR2(3) := '010';
  v_int_shp_to_cust_id     NUMBER;
  e_InvalidIntmdShipTo     EXCEPTION;
  e_invalidIntmdShiptoId   EXCEPTION;
  e_InactiveIntmdShipTo    EXCEPTION;
  e_IntrmdSiteUseInv       EXCEPTION;
  e_InactiveIntShipSiteUse EXCEPTION;
  e_InactiveIntShipTo      EXCEPTION;
  v_addStatus              VARCHAR2(1) := 'I';
  v_siteUseStatus          VARCHAR2(1) := 'I';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DeriveIntrmdShipToID');
     rlm_core_sv.dlog(C_DEBUG,'Cust_Intrmd_Ship_To_Ext',
                                        x_lines_rec.cust_intrmd_ship_to_ext);
     rlm_core_sv.dlog(C_DEBUG,'IntrmdShipToID',x_lines_rec.intrmd_ship_to_id);
  END IF;
  --
--  IF rlm_message_sv.check_dependency('SHIPTO') THEN
    --
    IF x_lines_rec.intrmd_ship_to_id IS NULL AND
       x_lines_rec.cust_intrmd_ship_to_ext IS NOT NULL THEN
       --{
       v_progress := '020';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'cust_intrmd_ship_to_ext ',
                 x_lines_rec.cust_intrmd_ship_to_ext);
       END IF;
       --
       BEGIN
       --
       -- Following query is changed as per TCA obsolescence project.
       -- R12 Perf Bug 4129291 : Use HCSU also in query below
       --Bugfix 8672453 Start
        OPEN c_IntrmdShipToID_ext;
        --
        FETCH c_IntrmdShipToID_ext INTO x_lines_rec.intrmd_ship_to_id,
                                        v_addStatus,v_siteUseStatus,
                                        x_lines_rec.intrmd_st_site_use_id;
        --
        IF c_IntrmdShipToID_ext%NOTFOUND THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'No Intermediate ShipTo Locations found');
          END IF;
          raise NO_DATA_FOUND;
          --
        END IF;
        --
        CLOSE c_IntrmdShipToID_ext;
        --Bugfix 8672453 End
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'intrmd_ship_to_id ', x_lines_rec.intrmd_ship_to_id);
           rlm_core_sv.dlog(C_DEBUG, 'Intrmd ST Site Use ID', x_lines_rec.intrmd_st_site_use_id);
           rlm_core_sv.dlog(C_DEBUG, 'Address Status', v_addStatus);
           rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
        END IF;
        --
       END;
       --
       IF v_addStatus = 'I' THEN
         raise e_InactiveIntShipTo;
       END IF;
       --
       IF v_siteUseStatus = 'I' THEN
         RAISE e_InactiveIntShipSiteUse;
       END IF;
       --}
    ELSIF x_lines_rec.intrmd_ship_to_id IS NOT NULL THEN
       --intrmd_ship_to_address_id is not null
       --{
       BEGIN
          --
          -- Following query is changed as per TCA obsolescence project.
          -- R12 Perf. Bug 4129291 : Use HCSU in query below
          --
        --Bugfix 8672453 Start
        OPEN c_IntrmdShipToID;
        --
        FETCH c_IntrmdShipToID INTO v_addStatus,
                                    v_int_shp_to_cust_id, v_siteUseStatus,
                                    x_lines_rec.intrmd_st_site_use_id;
        --
        IF c_IntrmdShipToID%NOTFOUND THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'Invalid Intermediate ShipTo Location');
          END IF;
          raise e_InvalidIntmdShipto;
          --
        END IF;
        --
        CLOSE c_IntrmdShipToID;
        --Bugfix 8672453 End

        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'intermdiate ship-to customer id', v_int_shp_to_cust_id);
           rlm_core_sv.dlog(C_DEBUG,'customer_id', x_header_rec.customer_id);
           rlm_core_sv.dlog(C_DEBUG, 'Intrmd ST Site Use ID', x_lines_rec.intrmd_st_site_use_id);
           rlm_core_sv.dlog(C_DEBUG, 'Address Status', v_addStatus);
           rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
        END IF;
        --
        IF v_addStatus = 'I' THEN
           raise e_InactiveIntmdShipTo;
        END IF;
        --
        IF v_siteUseStatus = 'I' THEN
           RAISE e_InactiveIntShipSiteUse;
        END IF;
        --
        IF NOT CustomerRelationship(x_header_rec.customer_id,
                                    v_int_shp_to_cust_id,
                                    x_header_rec.header_id,
                                    'SHIP_TO') THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Invalid customer relationship');
            END IF;
            --
            raise e_invalidIntmdShiptoId;
            --
        END IF;
        --
       END;
       --}
    END IF;
    --
    x_lines_rec.INTMED_SHIP_TO_ORG_ID := x_lines_rec.intrmd_st_site_use_id;
    --
    /*
     * R12 Perf Bug 4129291
     * We do not need this segment of code below since the status
     * of site use record is included in queries above
     *
    IF x_lines_rec.intrmd_ship_to_id IS NOT NULL THEN
      --{
      BEGIN
         --
         -- Following query is changed as per TCA obsolescence project.
         SELECT site_use_id ,
                status
         INTO   x_lines_rec.intrmd_st_site_use_id,
                v_status
         FROM   HZ_CUST_SITE_USES
         WHERE  CUST_ACCT_SITE_ID = x_lines_rec.INTRMD_SHIP_TO_ID
         AND    site_use_code = 'SHIP_TO';
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'intrmd_st_site_use_id ',
                                x_lines_rec.intrmd_st_site_use_id);
            rlm_core_sv.dlog(C_DEBUG,'intrmd_site_use_id status', v_status);
         END IF;
         --
         x_lines_rec.INTMED_SHIP_TO_ORG_ID := x_lines_rec.intrmd_st_site_use_id;
         v_progress := '030';
         --
         IF v_status = 'I' THEN
            raise e_InactiveIntShipSiteUse;
         END IF;
         --
      EXCEPTION
         --
         WHEN NO_DATA_FOUND THEN
            raise e_IntrmdSiteUseInv;
      END;
      --}
    END IF;
    */
    --
--  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_INTRMD_SHIPTO_ID_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'INTRMD_SHIP_TO_EXT',
                x_value1=>x_lines_rec.cust_intrmd_ship_to_ext,
                x_ValidationType => 'INTRMD_SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_INTRMD_SHIPTO_ID_INVALID');
    END IF;
    --
  WHEN e_invalidIntmdShiptoId THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_INTRMD_SHIP_TO_ID_RELATED');
    END IF;
    --
  WHEN e_IntrmdSiteUseInv THEN
    -- Warning
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_INTRMD_SHIPTO_SITEUSE',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'INTRMD_SHIP_TO_EXT',
                x_value1=>x_lines_rec.cust_intrmd_ship_to_ext,
                x_ValidationType => 'INTRMD_SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'WARNING: RLM_INTRMD_SHIPTO_SITEUSE');
    END IF;
    --
  WHEN e_InactiveIntShipTo THEN
    -- Warning
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_INTSHIP_INACTIVE',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'INTRMD_SHIP_TO_EXT',
            x_value1=>x_lines_rec.cust_intrmd_ship_to_ext,
            x_ValidationType => 'INTRMD_SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'WARNING: RLM_INTSHIP_INACTIVE');
    END IF;
    --
  WHEN e_InactiveIntShipSiteUse THEN
    -- Warning
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_warn_level,
            x_MessageName => 'RLM_INTSHIP_SITE_USE_INACTIVE',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'INTRMD_SHIP_TO_EXT',
            x_value1=>x_lines_rec.cust_intrmd_ship_to_ext,
            x_ValidationType => 'INTRMD_SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'WARNING: RLM_INTSHIP_SITE_USE_INACTIVE');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveIntrmdShipToID',
                                                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DeriveIntrmdShipToID;

/*===========================================================================

	PROCEDURE NAME:  DeriveBillToID

===========================================================================*/
PROCEDURE DeriveBillToID(x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE,
                         x_cum_org_level_code IN rlm_cust_shipto_terms.cum_org_level_code%TYPE)
IS
  --
       CURSOR c_BillToID_ext IS  --Added cursor as part of Bugfix 8672453
           SELECT    ACCT_SITE.CUST_ACCT_SITE_ID,
                     ACCT_SITE.STATUS, SITE_USE.STATUS,
                     SITE_USE.site_use_id
           FROM      HZ_CUST_ACCT_SITES ACCT_SITE, HZ_CUST_SITE_USES_ALL SITE_USE
           WHERE     acct_site.ece_tp_location_code = x_lines_rec.cust_bill_to_ext
           AND       ACCT_SITE.CUST_ACCOUNT_ID = x_header_rec.customer_id
           AND       site_use_code = 'BILL_TO'
           AND       ACCT_SITE.cust_acct_site_id = SITE_USE.cust_acct_site_id
           AND       ACCT_SITE.org_id = SITE_USE.org_id
           ORDER BY  SITE_USE.status; --To query first Active and then Inactive records

       CURSOR c_BillToID_cust_rel IS  --Added cursor as part of Bugfix 8672453
           SELECT ACCT_SITE.CUST_ACCT_SITE_ID,
                  ACCT_SITE.status,
                  ACCT_SITE.CUST_ACCOUNT_ID, SITE_USE.STATUS,
                  SITE_USE.site_use_id
           FROM   HZ_CUST_ACCT_SITES  ACCT_SITE, HZ_CUST_SITE_USES_ALL SITE_USE
           WHERE  ACCT_SITE.ece_tp_location_code 	= x_lines_rec.cust_bill_to_ext
           AND    ACCT_SITE.cust_acct_site_id = SITE_USE.cust_acct_site_id
           AND    SITE_USE.site_use_code = 'BILL_TO'
           AND    ACCT_SITE.org_id = SITE_USE.org_id
           AND    ACCT_SITE.CUST_ACCOUNT_ID in
                  (SELECT DISTINCT cust_account_id
                   FROM HZ_CUST_ACCT_RELATE_ALL
                  WHERE related_cust_account_id = x_header_rec.customer_id
                    AND status='A'
                    AND bill_to_flag = 'Y'
                    AND oe_sys_parameters.value('CUSTOMER_RELATIONSHIPS_FLAG', x_header_rec.org_id) IN ('Y', 'A')
                    AND org_id = x_header_rec.org_id)
         ORDER BY SITE_USE.status; --To query first Active and then Inactive records

       CURSOR c_BillToID_org_level IS  --Added cursor as part of Bugfix 8672453
           SELECT site_use_id, status
           FROM   HZ_CUST_SITE_USES
           WHERE  CUST_ACCT_SITE_ID = x_lines_rec.ship_to_address_id
           AND    site_use_code = 'SHIP_TO'
         ORDER BY status; --To query first Active and then Inactive records

       CURSOR c_BillToID IS  --Added cursor as part of Bugfix 8672453
           SELECT    ACCT_SITE.STATUS, ACCT_SITE.CUST_ACCOUNT_ID,
                     SITE_USE.STATUS, SITE_USE.site_use_id
           FROM      HZ_CUST_ACCT_SITES  ACCT_SITE, HZ_CUST_SITE_USES_ALL SITE_USE
           WHERE     ACCT_SITE.CUST_ACCT_SITE_ID = x_lines_rec.bill_to_address_id
           AND       ACCT_SITE.cust_acct_site_id = SITE_USE.cust_acct_site_id
           AND       SITE_USE.site_use_code = 'BILL_TO'
           AND       ACCT_SITE.org_id = SITE_USE.org_id
           ORDER BY  SITE_USE.status; --To query first Active and then Inactive records

  v_progress             VARCHAR2(3) := '010';
  v_count                NUMBER;
  v_status               VARCHAR2(1) := 'I';
  v_bill_to_customer_id  NUMBER DEFAULT NULL;
  v_ship_to_customer_id  NUMBER;
  v_tp_loc               VARCHAR2(30);
  e_InvalidBillTo        EXCEPTION;
  e_InvalidBillToID      EXCEPTION;
  e_InactiveBillTo       EXCEPTION;
  e_NoBillTo             EXCEPTION;
  e_BillToSiteUseInv     EXCEPTION;
  e_InactiveBillSiteUse  EXCEPTION;
  e_bad_location         EXCEPTION;
  e_related_cust         EXCEPTION;
  v_addStatus            VARCHAR2(1) := 'I';
  v_siteUseStatus        VARCHAR2(1) := 'I';
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'DeriveBillToID');
     rlm_core_sv.dlog(C_DEBUG, 'x_lines_rec.bill_to_address_id',
                      x_lines_rec.bill_to_address_id);
     rlm_core_sv.dlog(C_DEBUG,'x_cum_org_level_code',
                            x_cum_org_level_code);
  END IF;
  --
  -- R12 Perf Bug 4129291 : Modified queries to use both hz_cust_acct_sites and
  -- hz_cust_site_uses, so DSP determines the status of address record and site use
  -- record in one DB query.
  --
  IF rlm_message_sv.check_dependency('BILL_TO') THEN
    --
    IF x_lines_rec.bill_to_address_id IS NULL THEN
       --{
       IF x_lines_rec.cust_bill_to_ext IS NOT NULL THEN
         --{
         BEGIN
           --{
           v_progress := '030';
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'cust_bill_to_ext ', x_lines_rec.cust_bill_to_ext);
           END IF;
           --
           --if the bill_to does not exist for the customer, try customer
           -- relationship
           --
           BEGIN
             --{
             -- Following query is changed as per TCA obsolescence project.
             --Bugfix 8672453 Start
             OPEN c_BillToID_ext;
             --
             FETCH c_BillToID_ext INTO x_lines_rec.intrmd_ship_to_id,
                                       v_addStatus,v_siteUseStatus,
                                       x_lines_rec.intrmd_st_site_use_id;
             --
             IF c_BillToID_ext%NOTFOUND THEN
               --
               IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'No BillTo Locations found');
                 rlm_core_sv.dlog(C_DEBUG,'e_related_cust');
               END IF;
               --
               OPEN c_BillToID_cust_rel;
               --
               FETCH c_BillToID_cust_rel INTO x_lines_rec.bill_to_address_id,
                                              v_addStatus,
                                              v_bill_to_customer_id, v_siteUseStatus,
                                              x_lines_rec.bill_to_site_use_id;
               --
               IF c_BillToID_cust_rel%NOTFOUND THEN
                 --
                 IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'No Customer Relation record found');
                 END IF;
                 raise NO_DATA_FOUND;
                 --
               END IF;
               --
               IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'bill_to_address_id ', x_lines_rec.bill_to_address_id);
                   rlm_core_sv.dlog(C_DEBUG,'bill to Address status ', v_addStatus);
                   rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
                   rlm_core_sv.dlog(C_DEBUG,'v_bill_to_customer_id', v_bill_to_customer_id);
               END IF;
               --
               IF v_addStatus = 'I' THEN
                  raise e_InactiveBillTo;
               END IF;
               --
               IF v_siteUseStatus = 'I' THEN
                  RAISE e_InactiveBillSiteUse;
               END IF;
               --
               CLOSE c_BillToID_cust_rel;
               --
             END IF;
             --
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'bill_to_address_id ', x_lines_rec.bill_to_address_id);
                rlm_core_sv.dlog(C_DEBUG, 'bill_to_site_use_id', x_lines_rec.bill_to_site_use_id);
                rlm_core_sv.dlog(C_DEBUG,'bill to Address status ', v_addStatus);
                rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
             END IF;
             --
             IF v_addStatus = 'I' THEN
                raise e_InactiveBillTo;
             END IF;
             --
             IF v_siteUseStatus = 'I' THEN
                RAISE e_InactiveBillSiteUse;
             END IF;
             --
             CLOSE c_BillToID_ext;
             --Bugfix 8672453 End

           END;
             --}
         END;
           --
           x_lines_rec.invoice_to_org_id := x_lines_rec.bill_to_site_use_id;
           --
         --}
      ELSE -- CUST_BILL_TO_EXT is null
         --{
         IF x_cum_org_level_code = 'BILL_TO_SHIP_FROM' THEN
           --{
           v_progress := '040';
	   --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id ',
                                  x_lines_rec.ship_to_address_id);
           END IF;
           --
           -- If the bill_to_ext is null then we use the bill_to
           -- defined in HZ_CUST_ACCT_SITES for the SHIP_TO
           -- the bill_To_site_use as from the HZ_CUST_ACCT_SITES where
           -- address_useage is ship to
           --
           -- Following query is changed as per TCA obsolescence project.
           BEGIN
           --Bugfix 8672453 Start
           OPEN c_BillToID_org_level;
           --
           FETCH c_BillToID_org_level INTO x_lines_rec.bill_to_site_use_id, v_status;
           --
           IF c_BillToID_org_level%NOTFOUND THEN
             --
             IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Invalid BillTo Location(Org level)');
             END IF;
             raise e_InvalidBillTo;
             --
           END IF;
           --
           CLOSE c_BillToID_org_level;
           --Bugfix 8672453 End

           IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'bill site use status ', v_siteUseStatus );
                 rlm_core_sv.dlog(C_DEBUG,'bill site use id ', x_lines_rec.bill_to_site_use_id );
           END IF;
	       --
               x_lines_rec.invoice_to_org_id := x_lines_rec.bill_to_site_use_id;
	       --
           IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'invoice_to_org_id ', x_lines_rec.invoice_to_org_id );
           END IF;
           --
           IF x_lines_rec.bill_to_site_use_id is NOT NULL AND v_status = 'A'THEN
                 --
                 -- Following query is changed as per TCA obsolescence project.
                 SELECT CUST_ACCT_SITE_ID, status
                 INTO   x_lines_rec.bill_to_address_id, v_status
                 FROM   HZ_CUST_SITE_USES_ALL
                 WHERE  SITE_USE_ID =  x_lines_rec.bill_to_site_use_id;
                 --
           ELSE
                 --
                 IF x_lines_rec.bill_to_site_use_id is NULL THEN
                    raise e_NoBillTo;
                 ELSIF v_status = 'I' THEN
                    raise e_InactiveBillSiteUse;
                 END IF;
                 --
           END IF;
           --
           EXCEPTION
             --
             WHEN e_NoBillTo THEN
               raise e_InvalidBillTo;
            --}
           END;
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'bill_to_address_id ', x_lines_rec.bill_to_address_id);
           END IF;
           --}
        END IF;
        --}
      END IF;
      --}
    ELSE
       --{
       -- x_lines_rec.bill_to_address_id is NOT NULL
       --
       BEGIN
          --{
          -- Following query is changed as per TCA obsolescence project.
          --Bugfix 8672453 Start
          OPEN c_BillToID;
          --
          FETCH c_BillToID INTO v_addStatus, v_bill_to_customer_id,
                                v_siteUseStatus, x_lines_rec.bill_to_site_use_id;
          --
          IF c_BillToID%NOTFOUND THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Invalid BillTo Location');
            END IF;
            raise NO_DATA_FOUND;
            --
          END IF;
          --
          CLOSE c_BillToID;
          --Bugfix 8672453 End
          --
          IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'bill_to_address_id', x_lines_rec.bill_to_address_id);
              rlm_core_sv.dlog(C_DEBUG,'v_bill_to_customer_id',v_bill_to_customer_id);
              rlm_core_sv.dlog(C_DEBUG, 'Address Status', v_addStatus);
              rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
              rlm_core_sv.dlog(C_DEBUG, 'Site Use ID', x_lines_rec.bill_to_site_use_id);
          END IF;
          --
          IF v_addStatus = 'I' THEN
             raise e_InactiveBillTo;
          END IF;
          --
          IF v_siteUseStatus = 'I' THEN
             RAISE e_InactiveBillSiteUse;
          END IF;
          --
          IF NOT CustomerRelationship(x_header_rec.customer_id,
                                      v_bill_to_customer_id,
                                      x_header_rec.header_id,
                                      'BILL_TO') THEN
             --
             raise e_InvalidBillToId;
             --
          END IF;
          --
          x_lines_rec.invoice_to_org_id := x_lines_rec.bill_to_site_use_id;
          --
          IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Invoice To Org ID', x_lines_rec.invoice_to_org_id);
          END IF;
          --}
       END;
       --}
    END IF;
    --}
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
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_BILLTO_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'BILL_TO_EXT',
                x_value1=> nvl(x_lines_rec.cust_bill_to_ext,
                               x_header_rec.ece_tp_location_code_ext),
                x_ValidationType => 'BILL_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_BILLTO_INVALID');
    END IF;
    --
  WHEN e_BillToSiteUseInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_BILLTO_SITEUSE',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'BILL_TO_EXT',
                x_value1=> nvl(x_lines_rec.cust_bill_to_ext,
                               x_header_rec.ece_tp_location_code_ext),
                x_ValidationType => 'BILL_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_BILLTO_SITEUSE');
    END IF;
    --
  WHEN e_InvalidBillTo THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_MessageName => 'RLM_BILLTO_ID_NOT_DERIVED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'TP_LOCATION',
                x_value1=> nvl(x_lines_rec.cust_bill_to_ext,
                               x_header_rec.ece_tp_location_code_ext),
                x_ValidationType => 'BILL_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_BILLTO_ID_NOT_DERIVED');
    END IF;
    --
  WHEN e_bad_location THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_MessageName => 'RLM_BILLTO_ID_NOT_DERIVED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'TP_LOCATION',
                x_value1=> nvl(x_lines_rec.cust_bill_to_ext,
                               x_header_rec.ece_tp_location_code_ext),
                x_ValidationType => 'BILL_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_BILLTO_ID_NOT_DERIVED');
    END IF;
    --
  WHEN e_InactiveBillTo THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_BILLTO_INACTIVE',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'TP_LOCATION',
                x_value1=> nvl(x_lines_rec.cust_bill_to_ext,
                               x_header_rec.ece_tp_location_code_ext),
                x_ValidationType => 'BILL_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_BILLTO_ID_NOT_ACTIVE');
    END IF;
    --
  WHEN e_InvalidBilltoId THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_BILL_TO_ID_NO_RELATED',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'CUSTOMER',
                x_value1=> nvl(x_lines_rec.cust_bill_to_ext,
                               x_header_rec.ece_tp_location_code_ext),
                x_ValidationType => 'BILL_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dlog(C_DEBUG,'Customer Relationships: Bill to address id passed does not belong to the Customer nor its related customers');
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_BILLTO_ID_NOT_RELATED');
    END IF;
    --
  WHEN e_InactiveBillSiteUse THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_BILLTO_SITE_USE_INACTIVE',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'TP_LOCATION',
            x_value1=> nvl(x_lines_rec.cust_bill_to_ext,
                           x_header_rec.ece_tp_location_code_ext),
            x_ValidationType => 'BILL_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_BILLTO_SITE_USE_INACTIVE');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveBillToID',v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END DeriveBillToID;

/*===========================================================================

        PROCEDURE NAME:  DeriveShipToID

===========================================================================*/
PROCEDURE DeriveShipToID(x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE,
                         x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
     CURSOR c_ShipToID_line_ext IS --Added cursor as part of Bugfix 8672453
         SELECT hz.cust_acct_site_id, hz.status, cust_account_id,
                hcsu.status, site_use_id
         FROM   hz_cust_acct_sites hz, hz_cust_site_uses_all hcsu
         WHERE  hz.ece_tp_location_code = x_lines_rec.cust_ship_to_ext
         AND    hz.cust_acct_site_id    = hcsu.cust_acct_site_id
         AND    site_use_code           = 'SHIP_TO'
         AND    hz.org_id               = hcsu.org_id
         AND    hz.cust_account_id IN
                (SELECT to_number(x_header_rec.customer_id) from dual
                 UNION
                 SELECT cust_account_id
                 FROM hz_cust_acct_relate_all
                 WHERE related_cust_account_id = x_header_rec.customer_id
                 AND ship_to_flag = 'Y'
                 AND status = 'A'
                 AND org_id = x_header_rec.org_id
                 AND oe_sys_parameters.value('CUSTOMER_RELATIONSHIPS_FLAG')
                     IN ('Y', 'A'))
       ORDER BY hcsu.status; --To query first Active and then Inactive records

     CURSOR c_ShipToID_header_ext IS --Added cursor as part of Bugfix 8672453
         SELECT hcas.cust_acct_site_id,  hcas.status, hcsu.status,
                hcsu.site_use_id
         FROM   hz_cust_acct_sites hcas, hz_cust_site_uses_all hcsu
         WHERE  ece_tp_location_code = x_header_rec.ece_tp_location_code_ext
         AND    hcas.cust_account_id = x_header_rec.customer_id
         AND    hcas.cust_acct_site_id = hcsu.cust_acct_site_id
         AND    site_use_code          = 'SHIP_TO'
         AND    hcas.org_id            = hcsu.org_id
       ORDER BY hcsu.status; --To query first Active and then Inactive records

     CURSOR c_ShipToID IS --Added cursor as part of Bugfix 8672453
         SELECT hcas.status, cust_account_id, hcsu.status, hcsu.site_use_id
         FROM   hz_cust_acct_sites_all hcas, hz_cust_site_uses_all hcsu
         WHERE  hcas.cust_acct_site_id = x_lines_rec.ship_to_address_id
         AND    hcas.cust_acct_site_id = hcsu.cust_acct_site_id
         AND    hcsu.site_use_code     = 'SHIP_TO'
         AND    hcas.org_id = hcsu.org_id
       ORDER BY hcsu.status; --To query first Active and then Inactive records

  v_progress            VARCHAR2(3) := '010';
  v_addStatus           VARCHAR2(1);
  v_siteUseStatus       VARCHAR2(1);
  v_ship_to_customer_id NUMBER;
  e_InvalidShipTo       EXCEPTION;
  e_InvalidShipToId       EXCEPTION;
  e_InactiveShipTo      EXCEPTION;
  e_ShipToSiteUseInv    EXCEPTION;
  e_InactiveShipSiteUse EXCEPTION;
  e_InvalidCustomerId   EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'DeriveShipToID');
     rlm_core_sv.dlog(C_DEBUG, 'ship_to_address_id ',
                          x_lines_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG, 'ece_tp_location_code_ext',
                          x_header_rec.ece_tp_location_code_ext);
     rlm_core_sv.dlog(C_DEBUG, 'cust_ship_to_ext',
                          x_lines_rec.cust_ship_to_ext);
     rlm_core_sv.dlog(C_DEBUG, 'ece_primary_address_id',
                          x_header_rec.ece_primary_address_id);

  END IF;
  --
  IF rlm_message_sv.check_dependency('SHIPTO') THEN
    --
    IF x_lines_rec.ship_to_address_id IS NULL THEN
       --{
       IF x_lines_rec.cust_ship_to_ext IS NOT NULL THEN
         --{
         v_progress := '030';
	 --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'Using Ship-To-Ext to derive Id ',
                   x_lines_rec.cust_ship_to_ext);
         END IF;
         --
         -- Following query is changed as per TCA obsolescence project.
         -- CR Changes
         -- R12 Perf. Bug 4129291 : Use HCSU also in query below
         --
       --Bugfix 8672453 Start
        OPEN c_ShipToID_line_ext;
        --
        FETCH c_ShipToID_line_ext INTO x_lines_rec.ship_to_address_id, v_addStatus,
                                       x_lines_rec.ship_to_customer_id, v_siteUseStatus,
                                       x_lines_rec.ship_to_site_use_id;
        --
        IF c_ShipToID_line_ext%NOTFOUND THEN
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'No ShipTo Locations found');
          END IF;
          raise NO_DATA_FOUND;
          --
        END IF;
        --
        CLOSE c_ShipToID_line_ext;
        --Bugfix 8672453 End
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id ', x_lines_rec.ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.ship_to_customer_id ', x_lines_rec.ship_to_customer_id);
           rlm_core_sv.dlog(C_DEBUG,'customer_id ', x_header_rec.customer_id);
           rlm_core_sv.dlog(C_DEBUG, 'x_lines_rec.ship_to_site_use_id', x_lines_rec.ship_to_site_use_id);
           rlm_core_sv.dlog(C_DEBUG, 'Address Status', v_addStatus);
           rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
        END IF;
        --
        IF v_addStatus = 'I' THEN
         raise e_InactiveShipTo;
        END IF;
        --
        IF v_siteUseStatus = 'I' THEN
         RAISE e_InactiveShipSiteUse;
        END IF;
        --
         /* IF x_header_rec.customer_id <> x_lines_rec.ship_to_customer_id
            AND g_LineLevelShipTo THEN
            --
            IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'ship to customer id <> header customer id');
            END IF;
            --
            raise e_InvalidCustomerId;
            --
         END IF;  */
         --}
       --performance

       ELSIF x_header_rec.ece_tp_location_code_ext IS NOT NULL THEN
         --{
         v_progress := '035';
	 --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'Using TP Location Code to derive ID ',
                   x_header_rec.ece_tp_location_code_ext);
         END IF;
         --
         BEGIN
          --
          -- Following query is changed as per TCA obsolescence project.
          -- R12 Perf Bug 4129291 : Use HCSU in query below
          --
          --Bugfix 8672453 Start
          OPEN c_ShipToID_header_ext;
          --
          FETCH c_ShipToID_header_ext INTO x_lines_rec.ship_to_address_id, v_addStatus, v_siteUseStatus,
                                           x_lines_rec.ship_to_site_use_id;
          --
          IF c_ShipToID_header_ext%NOTFOUND THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Invalid ShipTo Location(Header)');
            END IF;
            raise e_InvalidShipTo;
            --
          END IF;
          --
          CLOSE c_ShipToID_header_ext;
          --Bugfix 8672453 End
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id ', x_lines_rec.ship_to_address_id);
             rlm_core_sv.dlog(C_DEBUG,'ship_to_site_use_id', x_lines_rec.ship_to_site_use_id);
             rlm_core_sv.dlog(C_DEBUG, 'Address Status', v_addStatus);
             rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
          END IF;
          --
          IF v_addStatus = 'I' THEN
           raise e_InactiveShipTo;
          END IF;
          --
          IF v_siteUseStatus = 'I' THEN
           RAISE e_InactiveShipSiteUse;
          END IF;
          --
         END;
         --}
       ELSE
        --{
        v_progress := '040';
        --
        IF (x_header_rec.customer_id IS NOT NULL AND
            x_header_rec.ece_primary_address_id IS NULL) THEN
         --{
         -- Following query is changed as per TCA obsolescence project.
         SELECT rasu.cust_acct_site_id, rad.status, rasu.status,
                rasu.site_use_id
         INTO   x_header_rec.ece_primary_address_id, v_addStatus, v_siteUseStatus,
                x_lines_rec.ship_to_site_use_id
         FROM   hz_cust_acct_sites     rad,
                hz_cust_site_uses_all  rasu
         WHERE  rad.cust_acct_site_id = rasu.cust_acct_site_id
         AND    rasu.site_use_code = 'SHIP_TO'
         AND    rasu.primary_flag = 'Y'
         AND    rad.cust_account_id = x_header_rec.customer_id
         AND    rad.status = 'A'
         AND    rad.org_id = rasu.org_id;
         --
         IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'customer_id ',x_header_rec.customer_id);
          rlm_core_sv.dlog(C_DEBUG,'ece_primary_address_id ',
                                 x_header_rec.ece_primary_address_id);
         END IF;
         --}
        END IF;
        --
        x_lines_rec.ship_to_address_id := x_header_rec.ece_primary_address_id;
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Using ECE primary address as ship-to');
           rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id ',
                   x_lines_rec.ship_to_address_id);
           rlm_core_sv.dlog(C_DEBUG, 'Address Status', v_addStatus);
           rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
        END IF;
        --}
       END IF;
       --
       IF v_addStatus = 'I' THEN
        raise e_InactiveShipTo;
       END IF;
       --
       IF v_siteUseStatus = 'I' THEN
        RAISE e_InactiveShipSiteUse;
       END IF;
       --
       --}
    ELSE    --ship_to_address_id is not null
       --{
       /* check if the address_id is inactive */
       BEGIN
          --
          --Bugfix 8672453 Start
          OPEN c_ShipToID;
          --
          FETCH c_ShipToID INTO v_addStatus, x_lines_rec.ship_to_customer_id, v_siteUseStatus,
                                x_lines_rec.ship_to_site_use_id;
          --
          IF c_ShipToID%NOTFOUND THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Invalid ShipTo Location');
            END IF;
            raise e_InvalidShipto;
            --
          END IF;
          --
          CLOSE c_ShipToID;
          --Bugfix 8672453 End

          -- Following query is changed as per TCA obsolescence project.
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'ship-to customer id',
                              x_lines_rec.ship_to_customer_id);
             rlm_core_sv.dlog(C_DEBUG, 'Ship To Site Use ID',
                              x_lines_rec.ship_to_site_use_id);
             rlm_core_sv.dlog(C_DEBUG, 'Address Status', v_addStatus);
             rlm_core_sv.dlog(C_DEBUG, 'Site Use Status', v_siteUseStatus);
          END IF;
          --
          IF v_addStatus = 'I' THEN
             raise e_InactiveShipTo;
          END IF;
          --
          IF v_siteUseStatus = 'I' THEN
            RAISE e_InactiveShipSiteUse;
          END IF;
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.ship_to_customer_id', x_lines_rec.ship_to_customer_id);
          END IF;
          --
          IF NOT CustomerRelationship(x_header_rec.customer_id,
                                x_lines_rec.ship_to_customer_id,
                                x_header_rec.header_id,
                                'SHIP_TO') THEN
            --
            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Invalid customer relationship');
            END IF;
            --
            raise e_InvalidShipToID;
            --
          END IF;
          --
       END;
       --}
    END IF;
    --
    x_lines_rec.ship_to_org_id := x_lines_rec.ship_to_site_use_id;
    --
    /*
     * R12 Perf Bug 4129291
     * This segment of code is not required any longer, since the check on status
     * of site use record has been included in queries above
     *
    BEGIN
      --{
      v_progress := '050';
      --
      -- Following query is changed as per TCA obsolescence project.
         SELECT site_use_id , status
         INTO   x_lines_rec.ship_to_site_use_id, v_status
         FROM   HZ_CUST_SITE_USES
         WHERE  CUST_ACCT_SITE_ID = x_lines_rec.ship_to_address_id
         AND    site_use_code = 'SHIP_TO';
      --
      x_lines_rec.ship_to_org_id := x_lines_rec.ship_to_site_use_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'site use id status ', v_status );
         rlm_core_sv.dlog(C_DEBUG,'ship_to_site_use_id ',
                                 x_lines_rec.ship_to_site_use_id);
      END IF;
      --
      IF v_status = 'I' THEN
         --
         raise e_InactiveShipSiteUse;
         --
      END IF;
      --
      EXCEPTION
        --
        WHEN NO_DATA_FOUND THEN
            raise e_ShipToSiteUseInv;
     --}
    END; */
    --}
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
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_SHIPTO_ID_NOT_DERIVED',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'TP_LOCATION',
            x_value1=> nvl(x_lines_rec.cust_ship_to_ext,
                           x_header_rec.ece_tp_location_code_ext),
            x_ValidationType => 'SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIPTO_NOT_DERIVED');
    END IF;
    --
  WHEN e_ShipToSiteUseInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_SHIPTO_SITEUSE',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'SHIP_TO_EXT',
            x_value1=> nvl(x_lines_rec.cust_ship_to_ext,
                           x_header_rec.ece_tp_location_code_ext),
            x_ValidationType => 'SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIPTO_SITEUSE');
    END IF;
    --
  WHEN e_InvalidShipTo THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_SHIPTO_ID_NOT_DERIVED',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'TP_LOCATION',
            x_value1=> nvl(x_lines_rec.cust_ship_to_ext,
                           x_header_rec.ece_tp_location_code_ext),
            x_ValidationType => 'SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIPTO_ID_NOT_DERIVED');
    END IF;
    --
  WHEN e_InvalidShipToID THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIP_TO_ID_NOT_RELATED');
    END IF;
    --
  WHEN e_InactiveShipTo THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_SHIPTO_INACTIVE',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'TP_LOCATION',
            x_value1=> nvl(x_lines_rec.cust_ship_to_ext,
                           x_header_rec.ece_tp_location_code_ext),
            x_ValidationType => 'SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIPTO_INACTIVE');
    END IF;
    --
  WHEN e_InactiveShipSiteUse THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_SHIPTO_SITE_USE_INACTIVE',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'TP_LOCATION',
            x_value1=>x_header_rec.ece_tp_location_code_ext,
            x_ValidationType => 'SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SHIPTO_SITE_USE_INACTIVE');
    END IF;
    --
  WHEN e_InvalidCustomerId THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
            x_ExceptionLevel => rlm_message_sv.k_error_level,
            x_MessageName => 'RLM_INVALID_CUSTOMER',
            x_InterfaceHeaderId => x_lines_rec.header_id,
            x_InterfaceLineId => x_lines_rec.line_id,
            x_token1=>'TP_LOCATION',
            x_value1=>x_header_rec.ece_tp_location_code_ext,
            x_ValidationType => 'SHIP_TO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_INVALID_CUSTOMER');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validatedemand_sv.DeriveShipToID',
                                                            v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    raise;
    --
END DeriveShipToID;

/*====================================================================

        PROCEDURE validateWithCumRec

====================================================================*/
PROCEDURE validateWithCumRec(
          x_cum_key_record   IN rlm_cum_sv.cum_key_attrib_rec_type,
          x_group_rec        IN t_group_rec,
          x_lines_rec        IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS

  e_CumRecYearMissing  EXCEPTION;
  e_CumKeyPOMissing    EXCEPTION;
  e_NoCumRec           EXCEPTION;                         -- 4307505
  v_cum_key_record     rlm_cum_sv.cum_key_attrib_rec_type;
  v_cum_record         RLM_CUM_SV.cum_rec_type;           -- 4307505

BEGIN
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG,'validateWithCumRec');
 END IF;
 --
 IF (x_lines_rec.cust_po_number IS NULL) AND
     x_Group_rec.setup_terms_rec.CUM_CONTROL_CODE IN
                ('CUM_BY_PO_ONLY','CUM_BY_DATE_PO') THEN
   --
   raise e_CumKeyPOMissing;
   --
 END IF;
 --
 IF (x_lines_rec.industry_attribute1 IS NULL) AND
     x_Group_rec.setup_terms_rec.CUM_CONTROL_CODE = 'CUM_BY_DATE_RECORD_YEAR'
 THEN
   --
   raise e_CumRecYearMissing;
   --
 END IF;
 --
 -- 4307505 [  done only if the Intrasit calc basis is customer cum
 IF (x_Group_rec.setup_terms_rec.intransit_calc_basis = 'CUSTOMER_CUM' ) THEN
 --{ it.basis cust.cum
 --
  v_cum_record.cum_key_id := NULL;
  v_cum_key_record := x_cum_key_record;
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG,'customer_item_id',
                           v_cum_key_record.customer_item_id);
    rlm_core_sv.dlog(C_DEBUG,'ship_from_org_id',
                           v_cum_key_record.ship_from_org_id);
    rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id',
                         v_cum_key_record.ship_to_address_id);
 END IF;
  --
  v_cum_key_record.create_cum_key_flag := 'N';
  RLM_TPA_SV.CalculateCUMKey(v_cum_key_record, v_cum_record);
  --
  IF v_cum_record.cum_key_id IS NULL THEN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'error: rlm_nocum_rec');
   END IF;
   --
   raise e_NoCumRec;
   --
  END IF;
  --
 END IF;
 -- }  end.if. it.basis cust.cum
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG,'validateWithCumRec');
 END IF;
 --
EXCEPTION
  WHEN e_CumRecYearMissing THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_CUM_RECORD_YEAR_MISSING',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'CUM_KEY_PO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUM_RECORD_YEAR_MISSING');
    END IF;
    --
  WHEN e_CumKeyPOMissing THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_CUM_KEY_PO_MISSING',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'CUM_KEY_PO');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUM_KEY_PO_MISSING');
    END IF;
    --
  -- 4307505
  WHEN e_NoCumRec THEN
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_NOACT_CUMKEY_CSTCUM_INTRST',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_Token1 => 'SHIP_TO',
                x_Value1 =>
                       rlm_core_sv.get_ship_to(x_lines_rec.ship_to_address_id),
                x_Token2 => 'CITEM',
                x_Value2 =>
                    rlm_core_sv.get_item_number(x_lines_rec.customer_item_id));
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_NOACT_CUMKEY_CSTCUM_INTRST');
    END IF;
    --
END validateWithCumRec;

/*===============================================================

       PROCEDURE validateWithoutCumRec

===============================================================*/

PROCEDURE validateWithoutCumRec(
          x_customer_id   IN NUMBER,
          x_group_rec     IN t_group_rec,
          x_lines_rec     IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)

IS

  v_cum_record         RLM_CUM_SV.cum_rec_type;
  v_cum_key_record      rlm_cum_sv.cum_key_attrib_rec_type;
  e_NoCumRec           EXCEPTION;
  e_NoPoCumRec         EXCEPTION;

BEGIN
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG,'validateWithoutCumRec');
 END IF;
 --
 IF x_Group_rec.setup_terms_rec.cum_control_code = 'CUM_BY_PO_ONLY' THEN
    --bug 4307505
     rlm_message_sv.app_error(
        x_ExceptionLevel => rlm_message_sv.k_warn_level,
        x_MessageName => 'RLM_CUMPO_STUP_NO_RECORD',
        x_InterfaceHeaderId => x_lines_rec.header_id,
        x_InterfaceLineId => x_lines_rec.line_id);
    --
 END IF;
 --
 --give a warning
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG,'warning: RLM_CUM_STUP_NO_RECORD');
 END IF;
 --
 rlm_message_sv.app_error(
        x_ExceptionLevel => rlm_message_sv.k_warn_level,
        x_MessageName => 'RLM_CUM_STUP_NO_RECORD',
        x_InterfaceHeaderId => x_lines_rec.header_id,
        x_InterfaceLineId => x_lines_rec.line_id);
 --
 v_cum_key_record.customer_id := x_customer_id;
 --
 v_cum_key_record.customer_item_id := x_lines_rec.customer_item_id;
 --
 v_cum_key_record.ship_from_org_id := x_lines_rec.ship_from_org_id;
 --
 v_cum_key_record.intrmd_ship_to_address_id :=
                                    x_lines_rec.intrmd_ship_to_id;
 --
 v_cum_key_record.ship_to_address_id := x_lines_rec.ship_to_address_id ;
 --
 v_cum_key_record.bill_to_address_id := x_lines_rec.bill_to_address_id ;
 --
 v_cum_key_record.purchase_order_number :=
                                   x_lines_rec.cust_po_number;
 --
 v_cum_key_record.cust_record_year := x_lines_rec.industry_attribute1;
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG,'customer_item_id',
                           v_cum_key_record.customer_item_id);
    rlm_core_sv.dlog(C_DEBUG,'ship_from_org_id',
                           v_cum_key_record.ship_from_org_id);
    rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id',
                         v_cum_key_record.ship_to_address_id);
 END IF;
 --
 v_cum_record.cum_key_id := NULL;
 v_cum_record.msg_name := NULL;
 --
 rlm_cum_sv.GetLatestCum(v_cum_key_record,
                           x_Group_rec.setup_terms_rec,
                           v_cum_record,
                           rlm_cum_sv.k_CalledByVD);
 --
 IF v_cum_record.cum_key_id IS NULL THEN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'error: rlm_nocum_rec');
   END IF;
   --
   raise e_NoCumRec;
   --
 ELSE
   --
   IF v_cum_record.msg_name = 'RLM_CUM_START_FUTURE' THEN
     --
     rlm_message_sv.app_error(
        x_ExceptionLevel => rlm_message_sv.k_warn_level,
        x_MessageName => 'RLM_CUM_START_FUTURE',
        x_InterfaceHeaderId => x_lines_rec.header_id,
        x_InterfaceLineId => x_lines_rec.line_id,
        x_token1=>'ITEM',
        x_value1=>
          rlm_core_sv.get_item_number(x_lines_rec.customer_item_id),
        x_token2=>'SDATE',
        x_value2=>v_cum_record.cum_start_date);
      --
   END IF;
   --
 END IF;
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG,'validateWithoutCumRec');
 END IF;
 --
EXCEPTION

  WHEN e_NoCumRec THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_NO_ACTIVE_CUM',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_NO_ACTIVE_CUM');
    END IF;
    --
 END validateWithoutCumRec;


/*===========================================================================

   PROCEDURE NAME:  CheckCUMKeyPO

===========================================================================*/

PROCEDURE CheckCUMKeyPO(
          x_group_rec      IN RLM_VALIDATEDEMAND_SV.t_group_rec,
          x_header_rec     IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  --
  v_Progress           VARCHAR2(3) := '010';
  x_Success            NUMBER := 0;
  v_cum_record         RLM_CUM_SV.cum_rec_type;
  v_exist              VARCHAR2(30);
  v_cum_key_record     rlm_cum_sv.cum_key_attrib_rec_type;

  CURSOR c_cum
  IS
    SELECT  nvl(customer_item_id,   x_lines_rec.customer_item_id),
            nvl(inventory_item_id,  x_lines_rec.inventory_item_id),
            nvl(ship_from_org_id,   x_lines_rec.ship_from_org_id),
            nvl(intrmd_ship_to_id,  x_lines_rec.intrmd_ship_to_id),
            nvl(ship_to_address_id, x_lines_rec.ship_to_address_id),
            nvl(bill_to_address_id, x_lines_rec.bill_to_address_id),
            cust_po_number ,
            start_date_time,
            industry_attribute1                   -- cust_record_year
    FROM    rlm_interface_lines
    WHERE   header_id = x_header_rec.header_id
    AND     schedule_item_num = x_group_rec.schedule_item_num
    AND     item_detail_type = '4'
    AND     item_detail_subtype = 'CUM';


BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CheckCUMKeyPO');
     rlm_core_sv.dlog(C_DEBUG,'calc_cum_flag',
                                x_Group_rec.setup_terms_rec.calc_cum_flag);
     rlm_core_sv.dlog(C_DEBUG,'intransit calc basis',x_Group_rec.setup_terms_rec.intransit_calc_basis);
  END IF;
  --
  IF rlm_message_sv.check_dependency('CUM_KEY_PO') THEN
    --
    IF x_Group_rec.setup_terms_rec.calc_cum_flag = 'Y' THEN

       --calc_cum_flag = Y does not mean cum processing
       --find out if there are any cum info provided
       --
       IF NVL(x_Group_rec.setup_terms_rec.cum_control_code,'NO_CUM') IN
          ('CUM_BY_DATE_PO','CUM_BY_DATE_RECORD_YEAR'
            ,'CUM_BY_DATE_ONLY','CUM_BY_PO_ONLY')
       THEN --{
         --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'schedule_item_num',
                                             x_group_rec.schedule_item_num );
         END IF;
         --
         v_Progress := 20;
         --
         --for each group find out if there is a cum info line (item detail
         -- type 4).  If there are no cum line sent, verify that there is
         -- a cum_key defined
         --
         BEGIN

           OPEN c_cum;

           FETCH c_cum into
            v_cum_key_record.customer_item_id,
            v_cum_key_record.inventory_item_id,
            v_cum_key_record.ship_from_org_id,
            v_cum_key_record.intrmd_ship_to_address_id,
            v_cum_key_record.ship_to_address_id,
            v_cum_key_record.bill_to_address_id,
            v_cum_key_record.purchase_order_number,
            v_cum_key_record.cum_start_date,
            v_cum_key_record.cust_record_year;

           IF c_cum%NOTFOUND THEN
             --
             raise no_data_found;
             --
           END IF;

           -- 4307505 : passing customer id in addition
           v_cum_key_record.customer_id := x_header_rec.customer_id;
           validateWithCumRec( v_cum_key_record, x_group_rec  , x_lines_rec );
           --
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             --
             validateWithoutCumRec(x_header_rec.customer_id,
                                  x_group_rec ,
                                  x_lines_rec);
           WHEN TOO_MANY_ROWS THEN
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'error:RLM_MULTIPLE_ITM_CUM_DTL_FOUND') ;
             END IF;
	     --
             x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
             rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_error_level,
                 x_MessageName => 'RLM_MULTIPLE_ITM_CUM_DTL_FOUND',
                 x_InterfaceHeaderId => x_lines_rec.header_id,
                 x_InterfaceLineId => x_lines_rec.line_id,
                 x_Token1 => 'SHIP_FROM',
                 x_Value1 =>
                       rlm_core_sv.get_ship_from(x_lines_rec.ship_from_org_id),
                 x_Token2 => 'SHIP_TO',
                 x_Value2 =>
                       rlm_core_sv.get_ship_to(x_lines_rec.ship_to_address_id),
                 x_Token3 => 'CITEM',
                 x_Value3 =>
                    rlm_core_sv.get_item_number(x_lines_rec.customer_item_id));
             --
  	     IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
                rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: e_TooManyRows');
             END IF;
             --
         END;
         --
       END IF;--}
       --
    END IF;

    IF x_Group_rec.setup_terms_rec.intransit_calc_basis= 'CUSTOMER_CUM' THEN         --
      BEGIN
        --
        IF c_cum%ISOPEN THEN
          --
          IF c_cum%NOTFOUND THEN
            --
            raise no_data_found;
            --
          END IF;
          --
        ELSE
          --
          OPEN c_cum;
          FETCH c_cum into
            v_cum_key_record.customer_item_id,
            v_cum_key_record.inventory_item_id,
            v_cum_key_record.ship_from_org_id,
            v_cum_key_record.intrmd_ship_to_address_id,
            v_cum_key_record.ship_to_address_id,
            v_cum_key_record.bill_to_address_id,
            v_cum_key_record.purchase_order_number,
            v_cum_key_record.cum_start_date,
            v_cum_key_record.cust_record_year;

          IF c_cum%NOTFOUND THEN
            --
            raise no_data_found;
            --
          END IF;
          --
        END IF;
        --
      EXCEPTION
       --
       When NO_DATA_FOUND then
         --
         -- 4307505 : changed this from Error to Warning
         rlm_message_sv.app_error(
                 x_ExceptionLevel => rlm_message_sv.k_warn_level,     -- 4307505
                 x_MessageName => 'RLM_NO_CUM_INTRST_CUST_CUM',
                 x_InterfaceHeaderId => x_lines_rec.header_id,
                 x_InterfaceLineId => x_lines_rec.line_id,
                 x_Token1 => 'SHIP_TO',
                 x_Value1 =>
                       rlm_core_sv.get_ship_to(x_lines_rec.ship_to_address_id),
                 x_Token2 => 'CITEM',
                 x_Value2 =>
                    rlm_core_sv.get_item_number(x_lines_rec.customer_item_id));
         --
  	 IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
           rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: No CUM Line for Intransit Basis Customer CUM');
         END IF;
       --
      END;
      --
    END IF;
    --
  END IF;
  --
  IF c_cum%ISOPEN THEN
     CLOSE c_cum; --bug 4570658
  END IF;

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF c_cum%ISOPEN THEN
       CLOSE c_cum; --bug 4570658
    END IF;

    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validateDemand_sv.CheckCUMKeyPO', v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END CheckCUMKeyPO;


/*===========================================================================

        PROCEDURE NAME:  ValidPlanningProdSeqNum

===========================================================================*/
PROCEDURE ValidPlanningProdSeqNum(
                 x_setup_terms_rec  IN rlm_setup_terms_sv.setup_terms_rec_typ,
                 x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                 x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  v_Progress         VARCHAR(3) := '010';
  e_ProdSeqMissing   EXCEPTION;
  e_MatchProdSeq     EXCEPTION;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidPlanningProdSeqNum');
  END IF;
  --
  IF rlm_message_sv.check_dependency('PROD_SEQ_NUM') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'ScheduleType',x_header_rec.schedule_type);
       rlm_core_sv.dlog(C_DEBUG,'Planning_Prod_Seq',
                                  x_lines_rec.CUST_PRODUCTION_SEQ_NUM);
    END IF;
    --
    IF (x_header_rec.schedule_type = 'SEQUENCED') THEN
       --
       IF (x_lines_rec.CUST_PRODUCTION_SEQ_NUM IS NULL AND
           x_lines_rec.item_detail_type IN ('0', '1', '2', '6')) THEN
          --
          raise e_ProdSeqMissing;
          --
       ELSE
          --
          IF INSTR(x_setup_terms_rec.match_within_key,'$') = 0 THEN
             /* Mandatory to set match within in case of a sequenced schedule*/
             raise e_MatchProdSeq;
          END IF ;
          --
       END IF;
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
  --
  WHEN e_ProdSeqMissing THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_PLANNING_PROD_SEQ_MISSING',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'PROD_SEQ_NUM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_PLANNING_PROD_SEQ_MISSING');
    END IF;
    --
  WHEN e_MatchProdSeq THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    --
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_MATCH_WITHIN_PLN_PROD_SEQ',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_ValidationType => 'PROD_SEQ_NUM');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_MATCH_WITHIN_PLN_PROD_SEQ');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validateDemand_sv.ValidPlanningProdSeqNum',
                                       v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
    --
END ValidPlanningProdSeqNum;

/*===========================================================================

        PROCEDURE NAME:  ValidLineScheduleType

===========================================================================*/
PROCEDURE ValidLineScheduleType(x_header_rec  IN RLM_INTERFACE_HEADERS%ROWTYPE,
          x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE)
IS
  v_Progress         VARCHAR(3) := '010';
  e_SchedTypeInv     EXCEPTION;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'ValidLineScheduleType');
  END IF;
  --
  IF rlm_message_sv.check_dependency('LINE_SCHEDULE_TYPE') THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Schedule_Type',x_header_rec.Schedule_type );
    END IF;
    --
    IF x_lines_rec.Subline_Assigned_Id_Ext IS NOT NULL AND
       x_lines_rec.Subline_Config_Code_Ext IS NOT NULL AND
       x_lines_rec.Subline_Cust_Item_Ext IS NOT NULL AND
       x_lines_rec.Subline_Cust_Item_Id IS NOT NULL AND
       x_lines_rec.Subline_Model_Num_Ext IS NOT NULL AND
       x_lines_rec.Subline_Quantity IS NOT NULL AND
       x_lines_rec.Subline_UOM_CODE IS NOT NULL AND
       x_header_rec.Schedule_type <> 'SEQUENCED' THEN
          --
          raise e_SchedTypeInv;
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
  --
  WHEN e_SchedTypeInv THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_LINE_SCHEDULE_TYPE_INVALID',
                x_InterfaceHeaderId => x_lines_rec.header_id,
                x_InterfaceLineId => x_lines_rec.line_id,
                x_token1=>'SCHEDULE_TYPE',
                x_value1=>x_header_rec.Schedule_type,
                x_ValidationType => 'LINE_SCHEDULE_TYPE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION:  RLM_LINE_SCHEDULE_TYPE_INVALID');
    END IF;
    --
  WHEN OTHERS THEN
    --
    x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validateDemand_sv.ValidLineScheduleType: ',
                                       v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
END ValidLineScheduleType;

/*===========================================================================

        PROCEDURE NAME:  UpdateInterfaceLines

===========================================================================*/
PROCEDURE UpdateInterfaceLines(x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE)
IS
  --
  v_Progress         VARCHAR(3) := '010';
  IsGroupError       BOOLEAN := FALSE;
  --
  header_id_tab			g_number_tbl_type;
  line_id_tab			g_number_tbl_type;
  AGREEMENT_ID_TAB              AGREEMENT_ID_T;
  ATO_DATA_TYPE_TAB             ATO_DATA_TYPE_T;
  BILL_TO_ADDRESS_1_EXT_TAB    BILL_TO_ADDRESS_1_EXT_T;
  BILL_TO_ADDRESS_2_EXT_TAB    BILL_TO_ADDRESS_2_EXT_T;
  BILL_TO_ADDRESS_3_EXT_TAB    BILL_TO_ADDRESS_3_EXT_T;
  BILL_TO_ADDRESS_4_EXT_TAB	    BILL_TO_ADDRESS_4_EXT_T;
  BILL_TO_ADDRESS_ID_TAB      BILL_TO_ADDRESS_ID_T;
  INVOICE_TO_ORG_ID_TAB       INVOICE_TO_ORG_ID_T;
  BILL_TO_CITY_EXT_TAB       BILL_TO_CITY_EXT_T;
  BILL_TO_COUNTRY_EXT_TAB    BILL_TO_COUNTRY_EXT_T;
  BILL_TO_COUNTY_EXT_TAB     BILL_TO_COUNTY_EXT_T;
  BILL_TO_NAME_EXT_TAB       BILL_TO_NAME_EXT_T;
  BILL_TO_POSTAL_CD_EXT_TAB    BILL_TO_POSTAL_CD_EXT_T;
  BILL_TO_PROVINCE_EXT_TAB    BILL_TO_PROVINCE_EXT_T;
  BILL_TO_SITE_USE_ID_TAB     BILL_TO_SITE_USE_ID_T;
  BILL_TO_STATE_EXT_TAB       BILL_TO_STATE_EXT_T;
  CARRIER_ID_CODE_EXT_TAB     CARRIER_ID_CODE_EXT_T;
  CARRIER_QUALIFIER_EXT_TAB    CARRIER_QUALIFIER_EXT_T;
  COMMODITY_EXT_TAB           COMMODITY_EXT_T;
  COUNTRY_OF_ORIGIN_EXT_TAB    COUNTRY_OF_ORIGIN_EXT_T;
  CUST_ASSEMBLY_EXT_TAB        CUST_ASSEMBLY_EXT_T;
  CUST_ASSIGNED_ID_EXT_TAB     CUST_ASSIGNED_ID_EXT_T;
  CUST_BILL_TO_EXT_TAB         CUST_BILL_TO_EXT_T;
  CUST_CONTRACT_NUM_EXT_TAB       CUST_CONTRACT_NUM_EXT_T;
  CUSTOMER_DOCK_CODE_TAB          CUSTOMER_DOCK_CODE_T;
  CUST_INTRMD_SHIP_TO_EXT_TAB     CUST_INTRMD_SHIP_TO_EXT_T;
  CUST_ITEM_PRICE_EXT_TAB         CUST_ITEM_PRICE_EXT_T;
  CUST_ITEM_PRICE_UOM_EXT_TAB     CUST_ITEM_PRICE_UOM_EXT_T;
  CUSTOMER_ITEM_REVISION_TAB      CUSTOMER_ITEM_REVISION_T;
  CUSTOMER_JOB_TAB                CUSTOMER_JOB_T;
  CUST_MANUFACTURER_EXT_TAB       CUST_MANUFACTURER_EXT_T;
  CUST_MODEL_NUMBER_EXT_TAB       CUST_MODEL_NUMBER_EXT_T;
  CUST_MODEL_SERIAL_NUMBER_TAB    CUST_MODEL_SERIAL_NUMBER_T;
  CUST_ORDER_NUM_EXT_TAB         CUST_ORDER_NUM_EXT_T;
  CUST_PROCESS_NUM_EXT_TAB      CUST_PROCESS_NUM_EXT_T;
  CUST_SET_NUM_EXT_TAB             CUST_SET_NUM_EXT_T;
  CUST_SHIP_FROM_ORG_EXT_TAB      CUST_SHIP_FROM_ORG_EXT_T;
  CUST_SHIP_TO_EXT_TAB            CUST_SHIP_TO_EXT_T;
  CUST_UOM_EXT_TAB                CUST_UOM_EXT_T;
  CUSTOMER_ITEM_EXT_TAB           CUSTOMER_ITEM_EXT_T;
  CUSTOMER_ITEM_ID_TAB            CUSTOMER_ITEM_ID_T;
  REQUEST_DATE_TAB                REQUEST_DATE_T;
  SCHEDULE_DATE_TAB              SCHEDULE_DATE_T;
  DATE_TYPE_CODE_TAB             DATE_TYPE_CODE_T;
  DATE_TYPE_CODE_EXT_TAB         DATE_TYPE_CODE_EXT_T;
  DELIVERY_LEAD_TIME_TAB         DELIVERY_LEAD_TIME_T;
  END_DATE_TIME_TAB	              END_DATE_TIME_T;
  EQUIPMENT_CODE_EXT_TAB         EQUIPMENT_CODE_EXT_T;
  EQUIPMENT_NUMBER_EXT_TAB       EQUIPMENT_NUMBER_EXT_T;
  HANDLING_CODE_EXT_TAB          HANDLING_CODE_EXT_T;
  HAZARD_CODE_EXT_TAB            HAZARD_CODE_EXT_T;
  HAZARD_CODE_QUAL_EXT_TAB       HAZARD_CODE_QUAL_EXT_T;
  HAZARD_DESCRIPTION_EXT_TAB     HAZARD_DESCRIPTION_EXT_T;
  IMPORT_LICENSE_DATE_EXT_TAB     IMPORT_LICENSE_DATE_EXT_T;
  IMPORT_LICENSE_EXT_TAB          IMPORT_LICENSE_EXT_T;
  INDUSTRY_ATTRIBUTE1_TAB         INDUSTRY_ATTRIBUTE1_T;
  INDUSTRY_ATTRIBUTE10_TAB        INDUSTRY_ATTRIBUTE10_T;
  INDUSTRY_ATTRIBUTE11_TAB        INDUSTRY_ATTRIBUTE11_T;
  INDUSTRY_ATTRIBUTE12_TAB        INDUSTRY_ATTRIBUTE12_T;
  INDUSTRY_ATTRIBUTE13_TAB        INDUSTRY_ATTRIBUTE13_T;
  INDUSTRY_ATTRIBUTE14_TAB        INDUSTRY_ATTRIBUTE14_T;
  INDUSTRY_ATTRIBUTE15_TAB        INDUSTRY_ATTRIBUTE15_T;
  INDUSTRY_ATTRIBUTE2_TAB         INDUSTRY_ATTRIBUTE2_T;
  INDUSTRY_ATTRIBUTE3_TAB         INDUSTRY_ATTRIBUTE3_T;
  INDUSTRY_ATTRIBUTE4_TAB         INDUSTRY_ATTRIBUTE4_T;
  INDUSTRY_ATTRIBUTE5_TAB         INDUSTRY_ATTRIBUTE5_T;
  INDUSTRY_ATTRIBUTE6_TAB         INDUSTRY_ATTRIBUTE6_T;
  INDUSTRY_ATTRIBUTE7_TAB         INDUSTRY_ATTRIBUTE7_T;
  INDUSTRY_ATTRIBUTE8_TAB         INDUSTRY_ATTRIBUTE8_T;
  INDUSTRY_ATTRIBUTE9_TAB         INDUSTRY_ATTRIBUTE9_T;
  INDUSTRY_CONTEXT_TAB            INDUSTRY_CONTEXT_T;
  INTRMD_SHIP_TO_ID_TAB           INTRMD_SHIP_TO_ID_T;
  SHIP_TO_ORG_ID_TAB              SHIP_TO_ORG_ID_T;
  INTRMD_ST_ADDRESS_1_EXT_TAB     INTRMD_ST_ADDRESS_1_EXT_T;
  INTRMD_ST_ADDRESS_2_EXT_TAB     INTRMD_ST_ADDRESS_2_EXT_T;
  INTRMD_ST_ADDRESS_3_EXT_TAB     INTRMD_ST_ADDRESS_3_EXT_T;
  INTRMD_ST_ADDRESS_4_EXT_TAB     INTRMD_ST_ADDRESS_4_EXT_T;
  INTRMD_ST_CITY_EXT_TAB          INTRMD_ST_CITY_EXT_T;
  INTRMD_ST_COUNTRY_EXT_TAB       INTRMD_ST_COUNTRY_EXT_T;
  INTRMD_ST_COUNTY_EXT_TAB        INTRMD_ST_COUNTY_EXT_T;
  INTRMD_ST_NAME_EXT_TAB          INTRMD_ST_NAME_EXT_T;
  INTRMD_ST_POSTAL_CD_EXT_TAB     INTRMD_ST_POSTAL_CD_EXT_T;
  INTRMD_ST_PROVINCE_EXT_TAB     INTRMD_ST_PROVINCE_EXT_T;
  INTRMD_ST_STATE_EXT_TAB        INTRMD_ST_STATE_EXT_T;
  INTRMD_ST_SITE_USE_ID_TAB      INTRMD_ST_SITE_USE_ID_T;
  INVENTORY_ITEM_ID_TAB          INVENTORY_ITEM_ID_T;
  INVENTORY_ITEM_SEGMENT1_TAB    INVENTORY_ITEM_SEGMENT1_T;
  INVENTORY_ITEM_SEGMENT10_TAB      INVENTORY_ITEM_SEGMENT10_T;
  INVENTORY_ITEM_SEGMENT11_TAB      INVENTORY_ITEM_SEGMENT11_T;
  INVENTORY_ITEM_SEGMENT12_TAB      INVENTORY_ITEM_SEGMENT12_T;
  INVENTORY_ITEM_SEGMENT13_TAB      INVENTORY_ITEM_SEGMENT13_T;
  INVENTORY_ITEM_SEGMENT14_TAB      INVENTORY_ITEM_SEGMENT14_T;
  INVENTORY_ITEM_SEGMENT15_TAB      INVENTORY_ITEM_SEGMENT15_T;
  INVENTORY_ITEM_SEGMENT16_TAB      INVENTORY_ITEM_SEGMENT16_T;
  INVENTORY_ITEM_SEGMENT17_TAB      INVENTORY_ITEM_SEGMENT17_T;
  INVENTORY_ITEM_SEGMENT18_TAB      INVENTORY_ITEM_SEGMENT18_T;
  INVENTORY_ITEM_SEGMENT19_TAB      INVENTORY_ITEM_SEGMENT19_T;
  INVENTORY_ITEM_SEGMENT2_TAB       INVENTORY_ITEM_SEGMENT2_T;
  INVENTORY_ITEM_SEGMENT20_TAB      INVENTORY_ITEM_SEGMENT20_T;
  INVENTORY_ITEM_SEGMENT3_TAB      INVENTORY_ITEM_SEGMENT3_T;
  INVENTORY_ITEM_SEGMENT4_TAB      INVENTORY_ITEM_SEGMENT4_T;
  INVENTORY_ITEM_SEGMENT5_TAB      INVENTORY_ITEM_SEGMENT5_T;
  INVENTORY_ITEM_SEGMENT6_TAB      INVENTORY_ITEM_SEGMENT6_T;
  INVENTORY_ITEM_SEGMENT7_TAB      INVENTORY_ITEM_SEGMENT7_T;
  INVENTORY_ITEM_SEGMENT8_TAB      INVENTORY_ITEM_SEGMENT8_T;
  INVENTORY_ITEM_SEGMENT9_TAB      INVENTORY_ITEM_SEGMENT9_T;
  ITEM_CONTACT_CODE_1_TAB         ITEM_CONTACT_CODE_1_T;
  ITEM_CONTACT_CODE_2_TAB         ITEM_CONTACT_CODE_2_T;
  ITEM_CONTACT_VALUE_1_TAB        ITEM_CONTACT_VALUE_1_T;
  ITEM_CONTACT_VALUE_2_TAB        ITEM_CONTACT_VALUE_2_T;
  ITEM_DESCRIPTION_EXT_TAB        ITEM_DESCRIPTION_EXT_T;
  ITEM_DETAIL_QUANTITY_TAB        ITEM_DETAIL_QUANTITY_T;
  ITEM_DETAIL_REF_CODE_1_TAB      ITEM_DETAIL_REF_CODE_1_T;
  ITEM_DETAIL_REF_CODE_2_TAB      ITEM_DETAIL_REF_CODE_2_T;
  ITEM_DETAIL_REF_CODE_3_TAB      ITEM_DETAIL_REF_CODE_3_T;
  ITEM_DETAIL_REF_VALUE_1_TAB     ITEM_DETAIL_REF_VALUE_1_T;
  ITEM_DETAIL_REF_VALUE_2_TAB     ITEM_DETAIL_REF_VALUE_2_T;
  ITEM_DETAIL_REF_VALUE_3_TAB     ITEM_DETAIL_REF_VALUE_3_T;
  ITEM_DETAIL_SUBTYPE_TAB         ITEM_DETAIL_SUBTYPE_T;
  ITEM_DETAIL_SUBTYPE_EXT_TAB     ITEM_DETAIL_SUBTYPE_EXT_T;
  ITEM_DETAIL_TYPE_TAB            ITEM_DETAIL_TYPE_T;
  ITEM_DETAIL_TYPE_EXT_TAB        ITEM_DETAIL_TYPE_EXT_T;
  ITEM_ENG_CNG_LVL_EXT_TAB        ITEM_ENG_CNG_LVL_EXT_T;
  ITEM_MEASUREMENTS_EXT_TAB       ITEM_MEASUREMENTS_EXT_T;
  ITEM_NOTE_TEXT_TAB              ITEM_NOTE_TEXT_T;
  ITEM_REF_CODE_1_TAB             ITEM_REF_CODE_1_T;
  ITEM_REF_CODE_2_TAB            ITEM_REF_CODE_2_T;
  ITEM_REF_CODE_3_TAB            ITEM_REF_CODE_3_T;
  ITEM_REF_VALUE_1_TAB           ITEM_REF_VALUE_1_T;
  ITEM_REF_VALUE_2_TAB           ITEM_REF_VALUE_2_T;
  ITEM_REF_VALUE_3_TAB           ITEM_REF_VALUE_3_T;
  ITEM_RELEASE_STATUS_EXT_TAB    ITEM_RELEASE_STATUS_EXT_T;
  LADING_QUANTITY_EXT_TAB        LADING_QUANTITY_EXT_T;
  LETTER_CREDIT_EXPDT_EXT_TAB    LETTER_CREDIT_EXPDT_EXT_T;
  LETTER_CREDIT_EXT_TAB          LETTER_CREDIT_EXT_T;
  LINE_REFERENCE_TAB             LINE_REFERENCE_T;
  LINK_TO_LINE_REF_TAB           LINK_TO_LINE_REF_T;
  ORDER_HEADER_ID_TAB            ORDER_HEADER_ID_T;
  OTHER_NAME_CODE_1_TAB          OTHER_NAME_CODE_1_T;
  OTHER_NAME_CODE_2_TAB          OTHER_NAME_CODE_2_T;
  OTHER_NAME_VALUE_1_TAB         OTHER_NAME_VALUE_1_T;
  OTHER_NAME_VALUE_2_TAB         OTHER_NAME_VALUE_2_T;
  PACK_SIZE_EXT_TAB              PACK_SIZE_EXT_T;
  PACK_UNITS_PER_PACK_EXT_TAB    PACK_UNITS_PER_PACK_EXT_T;
  PACK_UOM_CODE_EXT_TAB          PACK_UOM_CODE_EXT_T;
  PACKAGING_CODE_EXT_TAB         PACKAGING_CODE_EXT_T;
  PARENT_LINK_LINE_REF_TAB       PARENT_LINK_LINE_REF_T;
  CUST_PRODUCTION_SEQ_NUM_TAB      CUST_PRODUCTION_SEQ_NUM_T;
  PRICE_LIST_ID_TAB              PRICE_LIST_ID_T;
  PRIMARY_QUANTITY_TAB           PRIMARY_QUANTITY_T;
  PRIMARY_UOM_CODE_TAB           PRIMARY_UOM_CODE_T;
  PRIME_CONTRCTR_PART_EXT_TAB    PRIME_CONTRCTR_PART_EXT_T;
  PROCESS_STATUS_TAB             PROCESS_STATUS_T;
  CUST_PO_RELEASE_NUM_TAB        CUST_PO_RELEASE_NUM_T;
  CUST_PO_DATE_TAB               CUST_PO_DATE_T;
  CUST_PO_LINE_NUM_TAB           CUST_PO_LINE_NUM_T;
  CUST_PO_NUMBER_TAB             CUST_PO_NUMBER_T;
  QTY_TYPE_CODE_TAB              QTY_TYPE_CODE_T;
  QTY_TYPE_CODE_EXT_TAB          QTY_TYPE_CODE_EXT_T;
  RETURN_CONTAINER_EXT_TAB       RETURN_CONTAINER_EXT_T;
  SCHEDULE_LINE_ID_TAB           SCHEDULE_LINE_ID_T;
  ROUTING_DESC_EXT_TAB           ROUTING_DESC_EXT_T;
  ROUTING_SEQ_CODE_EXT_TAB       ROUTING_SEQ_CODE_EXT_T;
  SCHEDULE_ITEM_NUM_TAB          SCHEDULE_ITEM_NUM_T;
  SHIP_DEL_PATTERN_EXT_TAB       SHIP_DEL_PATTERN_EXT_T;
  SHIP_DEL_TIME_CODE_EXT_TAB     SHIP_DEL_TIME_CODE_EXT_T;
  SHIP_DEL_RULE_NAME_TAB         SHIP_DEL_RULE_NAME_T;
  SHIP_FROM_ADDRESS_1_EXT_TAB    SHIP_FROM_ADDRESS_1_EXT_T;
  SHIP_FROM_ADDRESS_2_EXT_TAB    SHIP_FROM_ADDRESS_2_EXT_T;
  SHIP_FROM_ADDRESS_3_EXT_TAB    SHIP_FROM_ADDRESS_3_EXT_T;
  SHIP_FROM_ADDRESS_4_EXT_TAB    SHIP_FROM_ADDRESS_4_EXT_T;
  SHIP_FROM_CITY_EXT_TAB         SHIP_FROM_CITY_EXT_T;
  SHIP_FROM_COUNTRY_EXT_TAB      SHIP_FROM_COUNTRY_EXT_T;
  SHIP_FROM_COUNTY_EXT_TAB       SHIP_FROM_COUNTY_EXT_T;
  SHIP_FROM_NAME_EXT_TAB         SHIP_FROM_NAME_EXT_T;
  SHIP_FROM_ORG_ID_TAB           SHIP_FROM_ORG_ID_T;
  SHIP_FROM_POSTAL_CD_EXT_TAB    SHIP_FROM_POSTAL_CD_EXT_T;
  SHIP_FROM_PROVINCE_EXT_TAB     SHIP_FROM_PROVINCE_EXT_T;
  SHIP_FROM_STATE_EXT_TAB        SHIP_FROM_STATE_EXT_T;
  SHIP_LABEL_INFO_LINE_1_TAB     SHIP_LABEL_INFO_LINE_1_T;
  SHIP_LABEL_INFO_LINE_10_TAB    SHIP_LABEL_INFO_LINE_10_T;
  SHIP_LABEL_INFO_LINE_2_TAB     SHIP_LABEL_INFO_LINE_2_T;
  SHIP_LABEL_INFO_LINE_3_TAB     SHIP_LABEL_INFO_LINE_3_T;
  SHIP_LABEL_INFO_LINE_4_TAB     SHIP_LABEL_INFO_LINE_4_T;
  SHIP_LABEL_INFO_LINE_5_TAB     SHIP_LABEL_INFO_LINE_5_T;
  SHIP_LABEL_INFO_LINE_6_TAB     SHIP_LABEL_INFO_LINE_6_T;
  SHIP_LABEL_INFO_LINE_7_TAB     SHIP_LABEL_INFO_LINE_7_T;
  SHIP_LABEL_INFO_LINE_8_TAB     SHIP_LABEL_INFO_LINE_8_T;
  SHIP_LABEL_INFO_LINE_9_TAB     SHIP_LABEL_INFO_LINE_9_T;
  SHIP_TO_ADDRESS_1_EXT_TAB      SHIP_TO_ADDRESS_1_EXT_T;
  SHIP_TO_ADDRESS_2_EXT_TAB       SHIP_TO_ADDRESS_2_EXT_T;
  SHIP_TO_ADDRESS_3_EXT_TAB       SHIP_TO_ADDRESS_3_EXT_T;
  SHIP_TO_ADDRESS_4_EXT_TAB       SHIP_TO_ADDRESS_4_EXT_T;
  SHIP_TO_ADDRESS_ID_TAB          SHIP_TO_ADDRESS_ID_T;
  DELIVER_TO_ORG_ID_TAB           DELIVER_TO_ORG_ID_T;
  SHIP_TO_CITY_EXT_TAB            SHIP_TO_CITY_EXT_T;
  SHIP_TO_COUNTRY_EXT_TAB         SHIP_TO_COUNTRY_EXT_T;
  SHIP_TO_COUNTY_EXT_TAB          SHIP_TO_COUNTY_EXT_T;
  SHIP_TO_NAME_EXT_TAB            SHIP_TO_NAME_EXT_T;
  SHIP_TO_POSTAL_CD_EXT_TAB       SHIP_TO_POSTAL_CD_EXT_T;
  SHIP_TO_PROVINCE_EXT_TAB        SHIP_TO_PROVINCE_EXT_T;
  SHIP_TO_SITE_USE_ID_TAB         SHIP_TO_SITE_USE_ID_T;
  SHIP_TO_STATE_EXT_TAB           SHIP_TO_STATE_EXT_T;
  START_DATE_TIME_TAB             START_DATE_TIME_T;
  SUBLINE_ASSIGNED_ID_EXT_TAB     SUBLINE_ASSIGNED_ID_EXT_T;
  SUBLINE_CONFIG_CODE_EXT_TAB     SUBLINE_CONFIG_CODE_EXT_T;
  SUBLINE_CUST_ITEM_EXT_TAB       SUBLINE_CUST_ITEM_EXT_T;
  SUBLINE_CUST_ITEM_ID_TAB        SUBLINE_CUST_ITEM_ID_T;
  SUBLINE_MODEL_NUM_EXT_TAB       SUBLINE_MODEL_NUM_EXT_T;
  SUBLINE_QUANTITY_TAB           SUBLINE_QUANTITY_T;
  SUBLINE_UOM_CODE_TAB           SUBLINE_UOM_CODE_T;
  SUPPLIER_ITEM_EXT_TAB          SUPPLIER_ITEM_EXT_T;
  TRANSIT_TIME_EXT_TAB           TRANSIT_TIME_EXT_T;
  TRANSIT_TIME_QUAL_EXT_TAB      TRANSIT_TIME_QUAL_EXT_T;
  TRANSPORT_LOC_QUAL_EXT_TAB     TRANSPORT_LOC_QUAL_EXT_T;
  TRANSPORT_LOCATION_EXT_TAB     TRANSPORT_LOCATION_EXT_T;
  TRANSPORT_METHOD_EXT_TAB      TRANSPORT_METHOD_EXT_T;
  UOM_CODE_TAB                 UOM_CODE_T;
  WEIGHT_EXT_TAB              WEIGHT_EXT_T;
  WEIGHT_QUALIFIER_EXT_TAB     WEIGHT_QUALIFIER_EXT_T;
  WEIGHT_UOM_EXT_TAB           WEIGHT_UOM_EXT_T;
  FBO_CONFIGURATION_KEY_1_TAB     FBO_CONFIGURATION_KEY_1_T;
  FBO_CONFIGURATION_KEY_2_TAB    FBO_CONFIGURATION_KEY_2_T;
  FBO_CONFIGURATION_KEY_3_TAB    FBO_CONFIGURATION_KEY_3_T;
  FBO_CONFIGURATION_KEY_4_TAB    FBO_CONFIGURATION_KEY_4_T;
  FBO_CONFIGURATION_KEY_5_TAB    FBO_CONFIGURATION_KEY_5_T;
  MATCH_KEY_ACROSS_TAB           MATCH_KEY_ACROSS_T;
  MATCH_KEY_WITHIN_TAB           MATCH_KEY_WITHIN_T;
  CRITICAL_KEY_ATTRIBUTES_TAB    CRITICAL_KEY_ATTRIBUTES_T;
  ATTRIBUTE_CATEGORY_TAB         ATTRIBUTE_CATEGORY_T;
  ATTRIBUTE1_TAB                 ATTRIBUTE1_T;
  ATTRIBUTE2_TAB                 ATTRIBUTE2_T;
  ATTRIBUTE3_TAB                 ATTRIBUTE3_T;
  ATTRIBUTE4_TAB                 ATTRIBUTE4_T;
  ATTRIBUTE5_TAB                 ATTRIBUTE5_T;
  ATTRIBUTE6_TAB                ATTRIBUTE6_T;
  ATTRIBUTE7_TAB                ATTRIBUTE7_T;
  ATTRIBUTE8_TAB                ATTRIBUTE8_T;
  ATTRIBUTE9_TAB                ATTRIBUTE9_T;
  ATTRIBUTE10_TAB               ATTRIBUTE10_T;
  ATTRIBUTE11_TAB               ATTRIBUTE11_T;
  ATTRIBUTE12_TAB               ATTRIBUTE12_T;
  ATTRIBUTE13_TAB               ATTRIBUTE13_T;
  ATTRIBUTE14_TAB               ATTRIBUTE14_T;
  ATTRIBUTE15_TAB               ATTRIBUTE15_T;
  BLANKET_NUMBER_TAB	        BLANKET_NUMBER_T;
  INTMED_SHIP_TO_ORG_ID_TAB	INTMED_SHIP_TO_ORG_ID_T;
  SHIP_TO_CUSTOMER_ID_TAB       SHIP_TO_CUSTOMER_ID_T;
  --
  v_last_update_date       DATE   := sysdate;
  v_last_updated_by        NUMBER := fnd_global.user_id;
  v_last_update_login      NUMBER := fnd_global.login_id;
  v_request_id             NUMBER := fnd_global.conc_REQUEST_ID;
  v_program_application_id NUMBER := fnd_global.PROG_APPL_ID;
  v_program_id             NUMBER := fnd_global.conc_program_id;
  v_program_update_date    DATE   := sysdate;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'UpdateInterfaceLines');
     rlm_core_sv.dlog(C_DEBUG,'Number of Interface lines in g_lines_tab ',g_lines_tab.COUNT);
  END IF;
  --
  g_line_PS := rlm_core_sv.k_PS_AVAILABLE;

  FOR i IN 1..g_lines_tab.COUNT LOOP
    --
    IF g_lines_tab(i).process_status = rlm_core_sv.k_PS_AVAILABLE THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'line_id',g_lines_tab(i).line_id);
          rlm_core_sv.dlog(C_DEBUG,'Process Status AVAILABLE ');
       END IF;
       --
    ELSIF g_lines_tab(i).process_status = rlm_core_sv.k_PS_ERROR THEN
       --
       g_line_PS := rlm_core_sv.k_PS_ERROR;
       IsGroupError := TRUE;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'line_id',g_lines_tab(i).line_id);
          rlm_core_sv.dlog(C_DEBUG,'Process Status ERROR ');
       END IF;
       --
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'customer_item_id ',
                                    g_lines_tab(i).customer_item_id);
    END IF;
    --
    -- assign values for industry attribute fields
    --
    g_lines_tab(i).industry_attribute2 := to_char(g_lines_tab(i).start_date_time,'RRRR/MM/DD HH24:MI:SS');
    g_lines_tab(i).industry_attribute3 := g_header_rec.schedule_reference_num;
    g_lines_tab(i).industry_attribute15 := g_lines_tab(i).ship_from_org_id;
    --
    --assign tables to values
      header_id_tab(i)		:=      g_lines_tab(i).header_id;
      line_id_tab(i)		:=      g_lines_tab(i).line_id;
      AGREEMENT_ID_TAB(i)            := g_lines_tab(i).AGREEMENT_ID;
      ATO_DATA_TYPE_TAB(i)           := g_lines_tab(i).ATO_DATA_TYPE;
      BILL_TO_ADDRESS_1_EXT_TAB(i)   := g_lines_tab(i).BILL_TO_ADDRESS_1_EXT;
      BILL_TO_ADDRESS_2_EXT_TAB(i)   := g_lines_tab(i).BILL_TO_ADDRESS_2_EXT;
      BILL_TO_ADDRESS_3_EXT_TAB(i)   := g_lines_tab(i).BILL_TO_ADDRESS_3_EXT;
      BILL_TO_ADDRESS_4_EXT_TAB(i)	   := g_lines_tab(i).BILL_TO_ADDRESS_4_EXT;
      BILL_TO_ADDRESS_ID_TAB(i)     := g_lines_tab(i).BILL_TO_ADDRESS_ID;
      INVOICE_TO_ORG_ID_TAB(i)      := g_lines_tab(i).INVOICE_TO_ORG_ID ;
      BILL_TO_CITY_EXT_TAB(i)      := g_lines_tab(i).BILL_TO_CITY_EXT;
      BILL_TO_COUNTRY_EXT_TAB(i)   := g_lines_tab(i).BILL_TO_COUNTRY_EXT;
      BILL_TO_COUNTY_EXT_TAB(i)    := g_lines_tab(i).BILL_TO_COUNTY_EXT;
      BILL_TO_NAME_EXT_TAB(i)      := g_lines_tab(i).BILL_TO_NAME_EXT;
      BILL_TO_POSTAL_CD_EXT_TAB(i)   := g_lines_tab(i).BILL_TO_POSTAL_CD_EXT;
      BILL_TO_PROVINCE_EXT_TAB(i)   := g_lines_tab(i).BILL_TO_PROVINCE_EXT;
      BILL_TO_SITE_USE_ID_TAB(i)    := g_lines_tab(i).BILL_TO_SITE_USE_ID;
      BILL_TO_STATE_EXT_TAB(i)      := g_lines_tab(i).BILL_TO_STATE_EXT;
      CARRIER_ID_CODE_EXT_TAB(i)    := g_lines_tab(i).CARRIER_ID_CODE_EXT;
      CARRIER_QUALIFIER_EXT_TAB(i)   := g_lines_tab(i).CARRIER_QUALIFIER_EXT;
      COMMODITY_EXT_TAB(i)          := g_lines_tab(i).COMMODITY_EXT;
      COUNTRY_OF_ORIGIN_EXT_TAB(i)   := g_lines_tab(i).COUNTRY_OF_ORIGIN_EXT;
      CUST_ASSEMBLY_EXT_TAB(i)       := g_lines_tab(i).CUST_ASSEMBLY_EXT;
      CUST_ASSIGNED_ID_EXT_TAB(i)    := g_lines_tab(i).CUST_ASSIGNED_ID_EXT;
      CUST_BILL_TO_EXT_TAB(i)        := g_lines_tab(i).CUST_BILL_TO_EXT;
      CUST_CONTRACT_NUM_EXT_TAB(i)      := g_lines_tab(i).CUST_CONTRACT_NUM_EXT;
      CUSTOMER_DOCK_CODE_TAB(i)         := g_lines_tab(i).CUSTOMER_DOCK_CODE;
      CUST_INTRMD_SHIP_TO_EXT_TAB(i)    := g_lines_tab(i).CUST_INTRMD_SHIP_TO_EXT;
      CUST_ITEM_PRICE_EXT_TAB(i)        := g_lines_tab(i).CUST_ITEM_PRICE_EXT;
      CUST_ITEM_PRICE_UOM_EXT_TAB(i)    := g_lines_tab(i).CUST_ITEM_PRICE_UOM_EXT;
      CUSTOMER_ITEM_REVISION_TAB(i)     := g_lines_tab(i).CUSTOMER_ITEM_REVISION;
      CUSTOMER_JOB_TAB(i)               := g_lines_tab(i).CUSTOMER_JOB;
      CUST_MANUFACTURER_EXT_TAB(i)      := g_lines_tab(i).CUST_MANUFACTURER_EXT;
      CUST_MODEL_NUMBER_EXT_TAB(i)      := g_lines_tab(i).CUST_MODEL_NUMBER_EXT;
      CUST_MODEL_SERIAL_NUMBER_TAB(i)   := g_lines_tab(i).CUST_MODEL_SERIAL_NUMBER;
      CUST_ORDER_NUM_EXT_TAB(i)        := g_lines_tab(i).CUST_ORDER_NUM_EXT;
      CUST_PROCESS_NUM_EXT_TAB(i)     := g_lines_tab(i).CUST_PROCESS_NUM_EXT;
      CUST_SET_NUM_EXT_TAB(i)            := g_lines_tab(i).CUST_SET_NUM_EXT;
      CUST_SHIP_FROM_ORG_EXT_TAB(i)     := g_lines_tab(i).CUST_SHIP_FROM_ORG_EXT;
      CUST_SHIP_TO_EXT_TAB(i)           := g_lines_tab(i).CUST_SHIP_TO_EXT;
      CUST_UOM_EXT_TAB(i)               := g_lines_tab(i).CUST_UOM_EXT;
      CUSTOMER_ITEM_EXT_TAB(i)          := g_lines_tab(i).CUSTOMER_ITEM_EXT;
      CUSTOMER_ITEM_ID_TAB(i)           := g_lines_tab(i).CUSTOMER_ITEM_ID;
      REQUEST_DATE_TAB(i)               := g_lines_tab(i).REQUEST_DATE;
      SCHEDULE_DATE_TAB(i)             := g_lines_tab(i).SCHEDULE_DATE;
      DATE_TYPE_CODE_TAB(i)            := g_lines_tab(i).DATE_TYPE_CODE;
      DATE_TYPE_CODE_EXT_TAB(i)        := g_lines_tab(i).DATE_TYPE_CODE_EXT;
      DELIVERY_LEAD_TIME_TAB(i)        := g_lines_tab(i).DELIVERY_LEAD_TIME;
      END_DATE_TIME_TAB(i)	             := g_lines_tab(i).END_DATE_TIME;
      EQUIPMENT_CODE_EXT_TAB(i)        := g_lines_tab(i).EQUIPMENT_CODE_EXT;
      EQUIPMENT_NUMBER_EXT_TAB(i)      := g_lines_tab(i).EQUIPMENT_NUMBER_EXT;
      HANDLING_CODE_EXT_TAB(i)         := g_lines_tab(i).HANDLING_CODE_EXT;
      HAZARD_CODE_EXT_TAB(i)           := g_lines_tab(i).HAZARD_CODE_EXT;
      HAZARD_CODE_QUAL_EXT_TAB(i)      := g_lines_tab(i).HAZARD_CODE_QUAL_EXT;
      HAZARD_DESCRIPTION_EXT_TAB(i)    := g_lines_tab(i).HAZARD_DESCRIPTION_EXT;
      IMPORT_LICENSE_DATE_EXT_TAB(i)    := g_lines_tab(i).IMPORT_LICENSE_DATE_EXT;
      IMPORT_LICENSE_EXT_TAB(i)         := g_lines_tab(i).IMPORT_LICENSE_EXT;
      INDUSTRY_ATTRIBUTE1_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE1;
      INDUSTRY_ATTRIBUTE10_TAB(i)       := g_lines_tab(i).INDUSTRY_ATTRIBUTE10;
      INDUSTRY_ATTRIBUTE11_TAB(i)       := g_lines_tab(i).INDUSTRY_ATTRIBUTE11;
      INDUSTRY_ATTRIBUTE12_TAB(i)       := g_lines_tab(i).INDUSTRY_ATTRIBUTE12;
      INDUSTRY_ATTRIBUTE13_TAB(i)       := g_lines_tab(i).INDUSTRY_ATTRIBUTE13;
      INDUSTRY_ATTRIBUTE14_TAB(i)       := g_lines_tab(i).INDUSTRY_ATTRIBUTE14;
      INDUSTRY_ATTRIBUTE15_TAB(i)       := g_lines_tab(i).INDUSTRY_ATTRIBUTE15;
      INDUSTRY_ATTRIBUTE2_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE2;
      INDUSTRY_ATTRIBUTE3_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE3;
      INDUSTRY_ATTRIBUTE4_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE4;
      INDUSTRY_ATTRIBUTE5_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE5;
      INDUSTRY_ATTRIBUTE6_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE6;
      INDUSTRY_ATTRIBUTE7_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE7;
      INDUSTRY_ATTRIBUTE8_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE8;
      INDUSTRY_ATTRIBUTE9_TAB(i)        := g_lines_tab(i).INDUSTRY_ATTRIBUTE9;
      INDUSTRY_CONTEXT_TAB(i)           := g_lines_tab(i).INDUSTRY_CONTEXT;
      INTRMD_SHIP_TO_ID_TAB(i)          := g_lines_tab(i).INTRMD_SHIP_TO_ID;
      SHIP_TO_ORG_ID_TAB(i)             := g_lines_tab(i).SHIP_TO_ORG_ID   ;
      INTRMD_ST_ADDRESS_1_EXT_TAB(i)    := g_lines_tab(i).INTRMD_ST_ADDRESS_1_EXT;
      INTRMD_ST_ADDRESS_2_EXT_TAB(i)    := g_lines_tab(i).INTRMD_ST_ADDRESS_2_EXT;
      INTRMD_ST_ADDRESS_3_EXT_TAB(i)    := g_lines_tab(i).INTRMD_ST_ADDRESS_3_EXT;
      INTRMD_ST_ADDRESS_4_EXT_TAB(i)    := g_lines_tab(i).INTRMD_ST_ADDRESS_4_EXT;
      INTRMD_ST_CITY_EXT_TAB(i)         := g_lines_tab(i).INTRMD_ST_CITY_EXT;
      INTRMD_ST_COUNTRY_EXT_TAB(i)      := g_lines_tab(i).INTRMD_ST_COUNTRY_EXT;
      INTRMD_ST_COUNTY_EXT_TAB(i)       := g_lines_tab(i).INTRMD_ST_COUNTY_EXT;
      INTRMD_ST_NAME_EXT_TAB(i)         := g_lines_tab(i).INTRMD_ST_NAME_EXT;
      INTRMD_ST_POSTAL_CD_EXT_TAB(i)    := g_lines_tab(i).INTRMD_ST_POSTAL_CD_EXT;
      INTRMD_ST_PROVINCE_EXT_TAB(i)    := g_lines_tab(i).INTRMD_ST_PROVINCE_EXT;
      INTRMD_ST_STATE_EXT_TAB(i)       := g_lines_tab(i).INTRMD_ST_STATE_EXT;
      INTRMD_ST_SITE_USE_ID_TAB(i)     := g_lines_tab(i).INTRMD_ST_SITE_USE_ID;
      INVENTORY_ITEM_ID_TAB(i)         := g_lines_tab(i).INVENTORY_ITEM_ID;
      INVENTORY_ITEM_SEGMENT1_TAB(i)   := g_lines_tab(i).INVENTORY_ITEM_SEGMENT1;
      INVENTORY_ITEM_SEGMENT10_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT10;
      INVENTORY_ITEM_SEGMENT11_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT11;
      INVENTORY_ITEM_SEGMENT12_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT12;
      INVENTORY_ITEM_SEGMENT13_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT13;
      INVENTORY_ITEM_SEGMENT14_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT14;
      INVENTORY_ITEM_SEGMENT15_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT15;
      INVENTORY_ITEM_SEGMENT16_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT16;
      INVENTORY_ITEM_SEGMENT17_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT17;
      INVENTORY_ITEM_SEGMENT18_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT18;
      INVENTORY_ITEM_SEGMENT19_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT19;
      INVENTORY_ITEM_SEGMENT2_TAB(i)      := g_lines_tab(i).INVENTORY_ITEM_SEGMENT2;
      INVENTORY_ITEM_SEGMENT20_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT20;
      INVENTORY_ITEM_SEGMENT3_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT3;
      INVENTORY_ITEM_SEGMENT4_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT4;
      INVENTORY_ITEM_SEGMENT5_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT5;
      INVENTORY_ITEM_SEGMENT6_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT6;
      INVENTORY_ITEM_SEGMENT7_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT7;
      INVENTORY_ITEM_SEGMENT8_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT8;
      INVENTORY_ITEM_SEGMENT9_TAB(i)     := g_lines_tab(i).INVENTORY_ITEM_SEGMENT9;
      ITEM_CONTACT_CODE_1_TAB(i)        := g_lines_tab(i).ITEM_CONTACT_CODE_1;
      ITEM_CONTACT_CODE_2_TAB(i)        := g_lines_tab(i).ITEM_CONTACT_CODE_2;
      ITEM_CONTACT_VALUE_1_TAB(i)       := g_lines_tab(i).ITEM_CONTACT_VALUE_1;
      ITEM_CONTACT_VALUE_2_TAB(i)       := g_lines_tab(i).ITEM_CONTACT_VALUE_2;
      ITEM_DESCRIPTION_EXT_TAB(i)       := g_lines_tab(i).ITEM_DESCRIPTION_EXT;
      ITEM_DETAIL_QUANTITY_TAB(i)       := g_lines_tab(i).ITEM_DETAIL_QUANTITY;
      ITEM_DETAIL_REF_CODE_1_TAB(i)     := g_lines_tab(i).ITEM_DETAIL_REF_CODE_1;
      ITEM_DETAIL_REF_CODE_2_TAB(i)     := g_lines_tab(i).ITEM_DETAIL_REF_CODE_2;
      ITEM_DETAIL_REF_CODE_3_TAB(i)     := g_lines_tab(i).ITEM_DETAIL_REF_CODE_3;
      ITEM_DETAIL_REF_VALUE_1_TAB(i)    := g_lines_tab(i).ITEM_DETAIL_REF_VALUE_1;
      ITEM_DETAIL_REF_VALUE_2_TAB(i)    := g_lines_tab(i).ITEM_DETAIL_REF_VALUE_2;
      ITEM_DETAIL_REF_VALUE_3_TAB(i)    := g_lines_tab(i).ITEM_DETAIL_REF_VALUE_3;
      ITEM_DETAIL_SUBTYPE_TAB(i)        := g_lines_tab(i).ITEM_DETAIL_SUBTYPE;
      ITEM_DETAIL_SUBTYPE_EXT_TAB(i)    := g_lines_tab(i).ITEM_DETAIL_SUBTYPE_EXT;
      ITEM_DETAIL_TYPE_TAB(i)           := g_lines_tab(i).ITEM_DETAIL_TYPE;
      ITEM_DETAIL_TYPE_EXT_TAB(i)       := g_lines_tab(i).ITEM_DETAIL_TYPE_EXT;
      ITEM_ENG_CNG_LVL_EXT_TAB(i)       := g_lines_tab(i).ITEM_ENG_CNG_LVL_EXT;
      ITEM_MEASUREMENTS_EXT_TAB(i)      := g_lines_tab(i).ITEM_MEASUREMENTS_EXT;
      ITEM_NOTE_TEXT_TAB(i)             := g_lines_tab(i).ITEM_NOTE_TEXT;
      ITEM_REF_CODE_1_TAB(i)            := g_lines_tab(i).ITEM_REF_CODE_1;
      ITEM_REF_CODE_2_TAB(i)           := g_lines_tab(i).ITEM_REF_CODE_2;
      ITEM_REF_CODE_3_TAB(i)           := g_lines_tab(i).ITEM_REF_CODE_3;
      ITEM_REF_VALUE_1_TAB(i)          := g_lines_tab(i).ITEM_REF_VALUE_1;
      ITEM_REF_VALUE_2_TAB(i)          := g_lines_tab(i).ITEM_REF_VALUE_2;
      ITEM_REF_VALUE_3_TAB(i)          := g_lines_tab(i).ITEM_REF_VALUE_3;
      ITEM_RELEASE_STATUS_EXT_TAB(i)   := g_lines_tab(i).ITEM_RELEASE_STATUS_EXT;
      LADING_QUANTITY_EXT_TAB(i)       := g_lines_tab(i).LADING_QUANTITY_EXT;
      LETTER_CREDIT_EXPDT_EXT_TAB(i)   := g_lines_tab(i).LETTER_CREDIT_EXPDT_EXT;
      LETTER_CREDIT_EXT_TAB(i)         := g_lines_tab(i).LETTER_CREDIT_EXT;
      LINE_REFERENCE_TAB(i)            := g_lines_tab(i).LINE_REFERENCE;
      LINK_TO_LINE_REF_TAB(i)          := g_lines_tab(i).LINK_TO_LINE_REF;
      ORDER_HEADER_ID_TAB(i)           := g_lines_tab(i).ORDER_HEADER_ID;
      OTHER_NAME_CODE_1_TAB(i)         := g_lines_tab(i).OTHER_NAME_CODE_1;
      OTHER_NAME_CODE_2_TAB(i)         := g_lines_tab(i).OTHER_NAME_CODE_2;
      OTHER_NAME_VALUE_1_TAB(i)        := g_lines_tab(i).OTHER_NAME_VALUE_1;
      OTHER_NAME_VALUE_2_TAB(i)        := g_lines_tab(i).OTHER_NAME_VALUE_2;
      PACK_SIZE_EXT_TAB(i)             := g_lines_tab(i).PACK_SIZE_EXT;
      PACK_UNITS_PER_PACK_EXT_TAB(i)   := g_lines_tab(i).PACK_UNITS_PER_PACK_EXT;
      PACK_UOM_CODE_EXT_TAB(i)         := g_lines_tab(i).PACK_UOM_CODE_EXT;
      PACKAGING_CODE_EXT_TAB(i)        := g_lines_tab(i).PACKAGING_CODE_EXT;
      PARENT_LINK_LINE_REF_TAB(i)      := g_lines_tab(i).PARENT_LINK_LINE_REF;
      CUST_PRODUCTION_SEQ_NUM_TAB(i)     := g_lines_tab(i).CUST_PRODUCTION_SEQ_NUM;
      PRICE_LIST_ID_TAB(i)             := g_lines_tab(i).PRICE_LIST_ID;
      PRIMARY_QUANTITY_TAB(i)          := g_lines_tab(i).PRIMARY_QUANTITY;
      PRIMARY_UOM_CODE_TAB(i)          := g_lines_tab(i).PRIMARY_UOM_CODE;
      PRIME_CONTRCTR_PART_EXT_TAB(i)   := g_lines_tab(i).PRIME_CONTRCTR_PART_EXT;
      PROCESS_STATUS_TAB(i)            := g_lines_tab(i).PROCESS_STATUS;
      CUST_PO_RELEASE_NUM_TAB(i)       := g_lines_tab(i).CUST_PO_RELEASE_NUM;
      CUST_PO_DATE_TAB(i)              := g_lines_tab(i).CUST_PO_DATE;
      CUST_PO_LINE_NUM_TAB(i)          := g_lines_tab(i).CUST_PO_LINE_NUM;
      CUST_PO_NUMBER_TAB(i)            := g_lines_tab(i).CUST_PO_NUMBER;
      QTY_TYPE_CODE_TAB(i)             := g_lines_tab(i).QTY_TYPE_CODE;
      QTY_TYPE_CODE_EXT_TAB(i)         := g_lines_tab(i).QTY_TYPE_CODE_EXT;
      RETURN_CONTAINER_EXT_TAB(i)      := g_lines_tab(i).RETURN_CONTAINER_EXT;
      SCHEDULE_LINE_ID_TAB(i)          := g_lines_tab(i).SCHEDULE_LINE_ID;
      ROUTING_DESC_EXT_TAB(i)          := g_lines_tab(i).ROUTING_DESC_EXT;
      ROUTING_SEQ_CODE_EXT_TAB(i)      := g_lines_tab(i).ROUTING_SEQ_CODE_EXT;
      SCHEDULE_ITEM_NUM_TAB(i)         := g_lines_tab(i).SCHEDULE_ITEM_NUM;
      SHIP_DEL_PATTERN_EXT_TAB(i)      := g_lines_tab(i).SHIP_DEL_PATTERN_EXT;
      SHIP_DEL_TIME_CODE_EXT_TAB(i)    := g_lines_tab(i).SHIP_DEL_TIME_CODE_EXT;
      SHIP_DEL_RULE_NAME_TAB(i)        := g_lines_tab(i).SHIP_DEL_RULE_NAME;
      SHIP_FROM_ADDRESS_1_EXT_TAB(i)   := g_lines_tab(i).SHIP_FROM_ADDRESS_1_EXT;
      SHIP_FROM_ADDRESS_2_EXT_TAB(i)   := g_lines_tab(i).SHIP_FROM_ADDRESS_2_EXT;
      SHIP_FROM_ADDRESS_3_EXT_TAB(i)   := g_lines_tab(i).SHIP_FROM_ADDRESS_3_EXT;
      SHIP_FROM_ADDRESS_4_EXT_TAB(i)   := g_lines_tab(i).SHIP_FROM_ADDRESS_4_EXT;
      SHIP_FROM_CITY_EXT_TAB(i)        := g_lines_tab(i).SHIP_FROM_CITY_EXT;
      SHIP_FROM_COUNTRY_EXT_TAB(i)     := g_lines_tab(i).SHIP_FROM_COUNTRY_EXT;
      SHIP_FROM_COUNTY_EXT_TAB(i)      := g_lines_tab(i).SHIP_FROM_COUNTY_EXT;
      SHIP_FROM_NAME_EXT_TAB(i)        := g_lines_tab(i).SHIP_FROM_NAME_EXT;
      SHIP_FROM_ORG_ID_TAB(i)          := g_lines_tab(i).SHIP_FROM_ORG_ID;
      SHIP_FROM_POSTAL_CD_EXT_TAB(i)   := g_lines_tab(i).SHIP_FROM_POSTAL_CD_EXT;
      SHIP_FROM_PROVINCE_EXT_TAB(i)    := g_lines_tab(i).SHIP_FROM_PROVINCE_EXT;
      SHIP_FROM_STATE_EXT_TAB(i)       := g_lines_tab(i).SHIP_FROM_STATE_EXT;
      SHIP_LABEL_INFO_LINE_1_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_1;
      SHIP_LABEL_INFO_LINE_10_TAB(i)   := g_lines_tab(i).SHIP_LABEL_INFO_LINE_10;
      SHIP_LABEL_INFO_LINE_2_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_2;
      SHIP_LABEL_INFO_LINE_3_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_3;
      SHIP_LABEL_INFO_LINE_4_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_4;
      SHIP_LABEL_INFO_LINE_5_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_5;
      SHIP_LABEL_INFO_LINE_6_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_6;
      SHIP_LABEL_INFO_LINE_7_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_7;
      SHIP_LABEL_INFO_LINE_8_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_8;
      SHIP_LABEL_INFO_LINE_9_TAB(i)    := g_lines_tab(i).SHIP_LABEL_INFO_LINE_9;
      SHIP_TO_ADDRESS_1_EXT_TAB(i)     := g_lines_tab(i).SHIP_TO_ADDRESS_1_EXT;
      SHIP_TO_ADDRESS_2_EXT_TAB(i)      := g_lines_tab(i).SHIP_TO_ADDRESS_2_EXT;
      SHIP_TO_ADDRESS_3_EXT_TAB(i)      := g_lines_tab(i).SHIP_TO_ADDRESS_3_EXT;
      SHIP_TO_ADDRESS_4_EXT_TAB(i)      := g_lines_tab(i).SHIP_TO_ADDRESS_4_EXT;
      SHIP_TO_ADDRESS_ID_TAB(i)         := g_lines_tab(i).SHIP_TO_ADDRESS_ID;
      DELIVER_TO_ORG_ID_TAB(i)          := g_lines_tab(i).DELIVER_TO_ORG_ID ;
      SHIP_TO_CITY_EXT_TAB(i)           := g_lines_tab(i).SHIP_TO_CITY_EXT;
      SHIP_TO_COUNTRY_EXT_TAB(i)        := g_lines_tab(i).SHIP_TO_COUNTRY_EXT;
      SHIP_TO_COUNTY_EXT_TAB(i)         := g_lines_tab(i).SHIP_TO_COUNTY_EXT;
      SHIP_TO_NAME_EXT_TAB(i)           := g_lines_tab(i).SHIP_TO_NAME_EXT;
      SHIP_TO_POSTAL_CD_EXT_TAB(i)      := g_lines_tab(i).SHIP_TO_POSTAL_CD_EXT;
      SHIP_TO_PROVINCE_EXT_TAB(i)       := g_lines_tab(i).SHIP_TO_PROVINCE_EXT;
      SHIP_TO_SITE_USE_ID_TAB(i)        := g_lines_tab(i).SHIP_TO_SITE_USE_ID;
      SHIP_TO_STATE_EXT_TAB(i)          := g_lines_tab(i).SHIP_TO_STATE_EXT;
      START_DATE_TIME_TAB(i)            := g_lines_tab(i).START_DATE_TIME;
      SUBLINE_ASSIGNED_ID_EXT_TAB(i)    := g_lines_tab(i).SUBLINE_ASSIGNED_ID_EXT;
      SUBLINE_CONFIG_CODE_EXT_TAB(i)    := g_lines_tab(i).SUBLINE_CONFIG_CODE_EXT;
      SUBLINE_CUST_ITEM_EXT_TAB(i)      := g_lines_tab(i).SUBLINE_CUST_ITEM_EXT;
      SUBLINE_CUST_ITEM_ID_TAB(i)       := g_lines_tab(i).SUBLINE_CUST_ITEM_ID;
      SUBLINE_MODEL_NUM_EXT_TAB(i)      := g_lines_tab(i).SUBLINE_MODEL_NUM_EXT;
      SUBLINE_QUANTITY_TAB(i)          := g_lines_tab(i).SUBLINE_QUANTITY;
      SUBLINE_UOM_CODE_TAB(i)          := g_lines_tab(i).SUBLINE_UOM_CODE;
      SUPPLIER_ITEM_EXT_TAB(i)         := g_lines_tab(i).SUPPLIER_ITEM_EXT;
      TRANSIT_TIME_EXT_TAB(i)          := g_lines_tab(i).TRANSIT_TIME_EXT;
      TRANSIT_TIME_QUAL_EXT_TAB(i)     := g_lines_tab(i).TRANSIT_TIME_QUAL_EXT;
      TRANSPORT_LOC_QUAL_EXT_TAB(i)    := g_lines_tab(i).TRANSPORT_LOC_QUAL_EXT;
      TRANSPORT_LOCATION_EXT_TAB(i)    := g_lines_tab(i).TRANSPORT_LOCATION_EXT;
      TRANSPORT_METHOD_EXT_TAB(i)     := g_lines_tab(i).TRANSPORT_METHOD_EXT;
      UOM_CODE_TAB(i)                := g_lines_tab(i).UOM_CODE;
      WEIGHT_EXT_TAB(i)             := g_lines_tab(i).WEIGHT_EXT;
      WEIGHT_QUALIFIER_EXT_TAB(i)    := g_lines_tab(i).WEIGHT_QUALIFIER_EXT;
      WEIGHT_UOM_EXT_TAB(i)          := g_lines_tab(i).WEIGHT_UOM_EXT;
      FBO_CONFIGURATION_KEY_1_TAB(i)    := g_lines_tab(i).FBO_CONFIGURATION_KEY_1;
      FBO_CONFIGURATION_KEY_2_TAB(i)   := g_lines_tab(i).FBO_CONFIGURATION_KEY_2;
      FBO_CONFIGURATION_KEY_3_TAB(i)   := g_lines_tab(i).FBO_CONFIGURATION_KEY_3;
      FBO_CONFIGURATION_KEY_4_TAB(i)   := g_lines_tab(i).FBO_CONFIGURATION_KEY_4;
      FBO_CONFIGURATION_KEY_5_TAB(i)   := g_lines_tab(i).FBO_CONFIGURATION_KEY_5;
      MATCH_KEY_ACROSS_TAB(i)          := g_lines_tab(i).MATCH_KEY_ACROSS;
      MATCH_KEY_WITHIN_TAB(i)          := g_lines_tab(i).MATCH_KEY_WITHIN;
      CRITICAL_KEY_ATTRIBUTES_TAB(i)   := g_lines_tab(i).CRITICAL_KEY_ATTRIBUTES;
      ATTRIBUTE_CATEGORY_TAB(i)        := g_lines_tab(i).ATTRIBUTE_CATEGORY;
      ATTRIBUTE1_TAB(i)                := g_lines_tab(i).ATTRIBUTE1;
      ATTRIBUTE2_TAB(i)                := g_lines_tab(i).ATTRIBUTE2;
      ATTRIBUTE3_TAB(i)                := g_lines_tab(i).ATTRIBUTE3;
      ATTRIBUTE4_TAB(i)                := g_lines_tab(i).ATTRIBUTE4;
      ATTRIBUTE5_TAB(i)                := g_lines_tab(i).ATTRIBUTE5;
      ATTRIBUTE6_TAB(i)               := g_lines_tab(i).ATTRIBUTE6;
      ATTRIBUTE7_TAB(i)               := g_lines_tab(i).ATTRIBUTE7;
      ATTRIBUTE8_TAB(i)               := g_lines_tab(i).ATTRIBUTE8;
      ATTRIBUTE9_TAB(i)               := g_lines_tab(i).ATTRIBUTE9;
      ATTRIBUTE10_TAB(i)              := g_lines_tab(i).ATTRIBUTE10;
      ATTRIBUTE11_TAB(i)              := g_lines_tab(i).ATTRIBUTE11;
      ATTRIBUTE12_TAB(i)              := g_lines_tab(i).ATTRIBUTE12;
      ATTRIBUTE13_TAB(i)              := g_lines_tab(i).ATTRIBUTE13;
      ATTRIBUTE14_TAB(i)              := g_lines_tab(i).ATTRIBUTE14;
      ATTRIBUTE15_TAB(i)              := g_lines_tab(i).ATTRIBUTE15;
      BLANKET_NUMBER_TAB(i)	      := g_lines_tab(i).BLANKET_NUMBER;
      INTMED_SHIP_TO_ORG_ID_TAB(i)    := g_lines_tab(i).INTMED_SHIP_TO_ORG_ID;
      SHIP_TO_CUSTOMER_ID_TAB(i)      := g_lines_tab(i).SHIP_TO_CUSTOMER_ID;
    --
  END LOOP;

  FOR i IN 1..g_lines_tab.COUNT LOOP
     --
     process_status_tab(i) := 		g_line_PS;
     --
  END LOOP;

/* oracle 9i compatible bulk update
FORALL i in 1..g_lines_tab.COUNT

    UPDATE rlm_interface_lines
      SET ROW = g_lines_tab(i)
    WHERE header_id = header_id_tab(i)
    AND   line_id = line_id_tab(i);

*/

  --bulk update
  FORALL i in 1..g_lines_tab.COUNT
    UPDATE rlm_interface_lines
      SET
      AGREEMENT_ID           = AGREEMENT_ID_TAB(i),
      ATO_DATA_TYPE          = ATO_DATA_TYPE_TAB(i),
      BILL_TO_ADDRESS_1_EXT  = BILL_TO_ADDRESS_1_EXT_TAB(i),
      BILL_TO_ADDRESS_2_EXT  = BILL_TO_ADDRESS_2_EXT_TAB(i),
      BILL_TO_ADDRESS_3_EXT  = BILL_TO_ADDRESS_3_EXT_TAB(i),
      BILL_TO_ADDRESS_4_EXT  = BILL_TO_ADDRESS_4_EXT_TAB(i),
      BILL_TO_ADDRESS_ID    = BILL_TO_ADDRESS_ID_TAB(i),
      INVOICE_TO_ORG_ID     = INVOICE_TO_ORG_ID_TAB(i),
      BILL_TO_CITY_EXT     = BILL_TO_CITY_EXT_TAB(i),
      BILL_TO_COUNTRY_EXT  = BILL_TO_COUNTRY_EXT_TAB(i),
      BILL_TO_COUNTY_EXT   = BILL_TO_COUNTY_EXT_TAB(i),
      BILL_TO_NAME_EXT     = BILL_TO_NAME_EXT_TAB(i),
      BILL_TO_POSTAL_CD_EXT  = BILL_TO_POSTAL_CD_EXT_TAB(i),
      BILL_TO_PROVINCE_EXT  = BILL_TO_PROVINCE_EXT_TAB(i),
      BILL_TO_SITE_USE_ID   = BILL_TO_SITE_USE_ID_TAB(i),
      BILL_TO_STATE_EXT     = BILL_TO_STATE_EXT_TAB(i),
      CARRIER_ID_CODE_EXT   = CARRIER_ID_CODE_EXT_TAB(i),
      CARRIER_QUALIFIER_EXT  = CARRIER_QUALIFIER_EXT_TAB(i),
      COMMODITY_EXT         = COMMODITY_EXT_TAB(i),
      COUNTRY_OF_ORIGIN_EXT  = COUNTRY_OF_ORIGIN_EXT_TAB(i),
      CUST_ASSEMBLY_EXT      = CUST_ASSEMBLY_EXT_TAB(i),
      CUST_ASSIGNED_ID_EXT   = CUST_ASSIGNED_ID_EXT_TAB(i),
      CUST_BILL_TO_EXT       = CUST_BILL_TO_EXT_TAB(i),
      CUST_CONTRACT_NUM_EXT     = CUST_CONTRACT_NUM_EXT_TAB(i),
      CUSTOMER_DOCK_CODE        = CUSTOMER_DOCK_CODE_TAB(i),
      CUST_INTRMD_SHIP_TO_EXT   = CUST_INTRMD_SHIP_TO_EXT_TAB(i),
      CUST_ITEM_PRICE_EXT       = CUST_ITEM_PRICE_EXT_TAB(i),
      CUST_ITEM_PRICE_UOM_EXT   = CUST_ITEM_PRICE_UOM_EXT_TAB(i),
      CUSTOMER_ITEM_REVISION    = CUSTOMER_ITEM_REVISION_TAB(i),
      CUSTOMER_JOB              = CUSTOMER_JOB_TAB(i),
      CUST_MANUFACTURER_EXT     = CUST_MANUFACTURER_EXT_TAB(i),
      CUST_MODEL_NUMBER_EXT     = CUST_MODEL_NUMBER_EXT_TAB(i),
      CUST_MODEL_SERIAL_NUMBER  = CUST_MODEL_SERIAL_NUMBER_TAB(i),
      CUST_ORDER_NUM_EXT       = CUST_ORDER_NUM_EXT_TAB(i),
      CUST_PROCESS_NUM_EXT    = CUST_PROCESS_NUM_EXT_TAB(i),
      CUST_SET_NUM_EXT           = CUST_SET_NUM_EXT_TAB(i),
      CUST_SHIP_FROM_ORG_EXT    = CUST_SHIP_FROM_ORG_EXT_TAB(i),
      CUST_SHIP_TO_EXT          = CUST_SHIP_TO_EXT_TAB(i),
      CUST_UOM_EXT              = CUST_UOM_EXT_TAB(i),
      CUSTOMER_ITEM_EXT         = CUSTOMER_ITEM_EXT_TAB(i),
      CUSTOMER_ITEM_ID          = CUSTOMER_ITEM_ID_TAB(i),
      REQUEST_DATE              = REQUEST_DATE_TAB(i),
      SCHEDULE_DATE            = SCHEDULE_DATE_TAB(i),
      DATE_TYPE_CODE           = DATE_TYPE_CODE_TAB(i),
      DATE_TYPE_CODE_EXT       = DATE_TYPE_CODE_EXT_TAB(i),
      DELIVERY_LEAD_TIME       = DELIVERY_LEAD_TIME_TAB(i),
      END_DATE_TIME	        = END_DATE_TIME_TAB(i),
      EQUIPMENT_CODE_EXT       = EQUIPMENT_CODE_EXT_TAB(i),
      EQUIPMENT_NUMBER_EXT     = EQUIPMENT_NUMBER_EXT_TAB(i),
      HANDLING_CODE_EXT        = HANDLING_CODE_EXT_TAB(i),
      HAZARD_CODE_EXT          = HAZARD_CODE_EXT_TAB(i),
      HAZARD_CODE_QUAL_EXT     = HAZARD_CODE_QUAL_EXT_TAB(i),
      HAZARD_DESCRIPTION_EXT   = HAZARD_DESCRIPTION_EXT_TAB(i),
      IMPORT_LICENSE_DATE_EXT   = IMPORT_LICENSE_DATE_EXT_TAB(i),
      IMPORT_LICENSE_EXT        = IMPORT_LICENSE_EXT_TAB(i),
      INDUSTRY_ATTRIBUTE1       = INDUSTRY_ATTRIBUTE1_TAB(i),
      INDUSTRY_ATTRIBUTE10      = INDUSTRY_ATTRIBUTE10_TAB(i),
      INDUSTRY_ATTRIBUTE11      = INDUSTRY_ATTRIBUTE11_TAB(i),
      INDUSTRY_ATTRIBUTE12      = INDUSTRY_ATTRIBUTE12_TAB(i),
      INDUSTRY_ATTRIBUTE13      = INDUSTRY_ATTRIBUTE13_TAB(i),
      INDUSTRY_ATTRIBUTE14      = INDUSTRY_ATTRIBUTE14_TAB(i),
      INDUSTRY_ATTRIBUTE15      = INDUSTRY_ATTRIBUTE15_TAB(i),
      INDUSTRY_ATTRIBUTE2       = INDUSTRY_ATTRIBUTE2_TAB(i),
      INDUSTRY_ATTRIBUTE3       = INDUSTRY_ATTRIBUTE3_TAB(i),
      INDUSTRY_ATTRIBUTE4       = INDUSTRY_ATTRIBUTE4_TAB(i),
      INDUSTRY_ATTRIBUTE5       = INDUSTRY_ATTRIBUTE5_TAB(i),
      INDUSTRY_ATTRIBUTE6       = INDUSTRY_ATTRIBUTE6_TAB(i),
      INDUSTRY_ATTRIBUTE7       = INDUSTRY_ATTRIBUTE7_TAB(i),
      INDUSTRY_ATTRIBUTE8       = INDUSTRY_ATTRIBUTE8_TAB(i),
      INDUSTRY_ATTRIBUTE9       = INDUSTRY_ATTRIBUTE9_TAB(i),
      INDUSTRY_CONTEXT          = INDUSTRY_CONTEXT_TAB(i),
      INTRMD_SHIP_TO_ID         = INTRMD_SHIP_TO_ID_TAB(i),
      SHIP_TO_ORG_ID            = SHIP_TO_ORG_ID_TAB(i),
      INTRMD_ST_ADDRESS_1_EXT   = INTRMD_ST_ADDRESS_1_EXT_TAB(i),
      INTRMD_ST_ADDRESS_2_EXT   = INTRMD_ST_ADDRESS_2_EXT_TAB(i),
      INTRMD_ST_ADDRESS_3_EXT   = INTRMD_ST_ADDRESS_3_EXT_TAB(i),
      INTRMD_ST_ADDRESS_4_EXT   = INTRMD_ST_ADDRESS_4_EXT_TAB(i),
      INTRMD_ST_CITY_EXT        = INTRMD_ST_CITY_EXT_TAB(i),
      INTRMD_ST_COUNTRY_EXT     = INTRMD_ST_COUNTRY_EXT_TAB(i),
      INTRMD_ST_COUNTY_EXT      = INTRMD_ST_COUNTY_EXT_TAB(i),
      INTRMD_ST_NAME_EXT        = INTRMD_ST_NAME_EXT_TAB(i),
      INTRMD_ST_POSTAL_CD_EXT   = INTRMD_ST_POSTAL_CD_EXT_TAB(i),
      INTRMD_ST_PROVINCE_EXT   = INTRMD_ST_PROVINCE_EXT_TAB(i),
      INTRMD_ST_STATE_EXT      = INTRMD_ST_STATE_EXT_TAB(i),
      INTRMD_ST_SITE_USE_ID    = INTRMD_ST_SITE_USE_ID_TAB(i),
      INVENTORY_ITEM_ID        = INVENTORY_ITEM_ID_TAB(i),
      INVENTORY_ITEM_SEGMENT1  = INVENTORY_ITEM_SEGMENT1_TAB(i),
      INVENTORY_ITEM_SEGMENT10    = INVENTORY_ITEM_SEGMENT10_TAB(i),
      INVENTORY_ITEM_SEGMENT11    = INVENTORY_ITEM_SEGMENT11_TAB(i),
      INVENTORY_ITEM_SEGMENT12    = INVENTORY_ITEM_SEGMENT12_TAB(i),
      INVENTORY_ITEM_SEGMENT13    = INVENTORY_ITEM_SEGMENT13_TAB(i),
      INVENTORY_ITEM_SEGMENT14    = INVENTORY_ITEM_SEGMENT14_TAB(i),
      INVENTORY_ITEM_SEGMENT15    = INVENTORY_ITEM_SEGMENT15_TAB(i),
      INVENTORY_ITEM_SEGMENT16    = INVENTORY_ITEM_SEGMENT16_TAB(i),
      INVENTORY_ITEM_SEGMENT17    = INVENTORY_ITEM_SEGMENT17_TAB(i),
      INVENTORY_ITEM_SEGMENT18    = INVENTORY_ITEM_SEGMENT18_TAB(i),
      INVENTORY_ITEM_SEGMENT19    = INVENTORY_ITEM_SEGMENT19_TAB(i),
      INVENTORY_ITEM_SEGMENT2     = INVENTORY_ITEM_SEGMENT2_TAB(i),
      INVENTORY_ITEM_SEGMENT20    = INVENTORY_ITEM_SEGMENT20_TAB(i),
      INVENTORY_ITEM_SEGMENT3    = INVENTORY_ITEM_SEGMENT3_TAB(i),
      INVENTORY_ITEM_SEGMENT4    = INVENTORY_ITEM_SEGMENT4_TAB(i),
      INVENTORY_ITEM_SEGMENT5    = INVENTORY_ITEM_SEGMENT5_TAB(i),
      INVENTORY_ITEM_SEGMENT6    = INVENTORY_ITEM_SEGMENT6_TAB(i),
      INVENTORY_ITEM_SEGMENT7    = INVENTORY_ITEM_SEGMENT7_TAB(i),
      INVENTORY_ITEM_SEGMENT8    = INVENTORY_ITEM_SEGMENT8_TAB(i),
      INVENTORY_ITEM_SEGMENT9    = INVENTORY_ITEM_SEGMENT9_TAB(i),
      ITEM_CONTACT_CODE_1       = ITEM_CONTACT_CODE_1_TAB(i),
      ITEM_CONTACT_CODE_2       = ITEM_CONTACT_CODE_2_TAB(i),
      ITEM_CONTACT_VALUE_1      = ITEM_CONTACT_VALUE_1_TAB(i),
      ITEM_CONTACT_VALUE_2      = ITEM_CONTACT_VALUE_2_TAB(i),
      ITEM_DESCRIPTION_EXT      = ITEM_DESCRIPTION_EXT_TAB(i),
      ITEM_DETAIL_QUANTITY      = ITEM_DETAIL_QUANTITY_TAB(i),
      ITEM_DETAIL_REF_CODE_1    = ITEM_DETAIL_REF_CODE_1_TAB(i),
      ITEM_DETAIL_REF_CODE_2    = ITEM_DETAIL_REF_CODE_2_TAB(i),
      ITEM_DETAIL_REF_CODE_3    = ITEM_DETAIL_REF_CODE_3_TAB(i),
      ITEM_DETAIL_REF_VALUE_1   = ITEM_DETAIL_REF_VALUE_1_TAB(i),
      ITEM_DETAIL_REF_VALUE_2   = ITEM_DETAIL_REF_VALUE_2_TAB(i),
      ITEM_DETAIL_REF_VALUE_3   = ITEM_DETAIL_REF_VALUE_3_TAB(i),
      ITEM_DETAIL_SUBTYPE       = ITEM_DETAIL_SUBTYPE_TAB(i),
      ITEM_DETAIL_SUBTYPE_EXT   = ITEM_DETAIL_SUBTYPE_EXT_TAB(i),
      ITEM_DETAIL_TYPE          = ITEM_DETAIL_TYPE_TAB(i),
      ITEM_DETAIL_TYPE_EXT      = ITEM_DETAIL_TYPE_EXT_TAB(i),
      ITEM_ENG_CNG_LVL_EXT      = ITEM_ENG_CNG_LVL_EXT_TAB(i),
      ITEM_MEASUREMENTS_EXT     = ITEM_MEASUREMENTS_EXT_TAB(i),
      ITEM_NOTE_TEXT            = ITEM_NOTE_TEXT_TAB(i),
      ITEM_REF_CODE_1           = ITEM_REF_CODE_1_TAB(i),
      ITEM_REF_CODE_2          = ITEM_REF_CODE_2_TAB(i),
      ITEM_REF_CODE_3          = ITEM_REF_CODE_3_TAB(i),
      ITEM_REF_VALUE_1         = ITEM_REF_VALUE_1_TAB(i),
      ITEM_REF_VALUE_2         = ITEM_REF_VALUE_2_TAB(i),
      ITEM_REF_VALUE_3         = ITEM_REF_VALUE_3_TAB(i),
      ITEM_RELEASE_STATUS_EXT  = ITEM_RELEASE_STATUS_EXT_TAB(i),
      LADING_QUANTITY_EXT      = LADING_QUANTITY_EXT_TAB(i),
      LETTER_CREDIT_EXPDT_EXT  = LETTER_CREDIT_EXPDT_EXT_TAB(i),
      LETTER_CREDIT_EXT        = LETTER_CREDIT_EXT_TAB(i),
      LINE_REFERENCE           = LINE_REFERENCE_TAB(i),
      LINK_TO_LINE_REF         = LINK_TO_LINE_REF_TAB(i),
      ORDER_HEADER_ID          = ORDER_HEADER_ID_TAB(i),
      OTHER_NAME_CODE_1        = OTHER_NAME_CODE_1_TAB(i),
      OTHER_NAME_CODE_2        = OTHER_NAME_CODE_2_TAB(i),
      OTHER_NAME_VALUE_1       = OTHER_NAME_VALUE_1_TAB(i),
      OTHER_NAME_VALUE_2       = OTHER_NAME_VALUE_2_TAB(i),
      PACK_SIZE_EXT            = PACK_SIZE_EXT_TAB(i),
      PACK_UNITS_PER_PACK_EXT  = PACK_UNITS_PER_PACK_EXT_TAB(i),
      PACK_UOM_CODE_EXT        = PACK_UOM_CODE_EXT_TAB(i),
      PACKAGING_CODE_EXT       = PACKAGING_CODE_EXT_TAB(i),
      PARENT_LINK_LINE_REF     = PARENT_LINK_LINE_REF_TAB(i),
      CUST_PRODUCTION_SEQ_NUM    = CUST_PRODUCTION_SEQ_NUM_TAB(i),
      PRICE_LIST_ID            = PRICE_LIST_ID_TAB(i),
      PRIMARY_QUANTITY         = PRIMARY_QUANTITY_TAB(i),
      PRIMARY_UOM_CODE         = PRIMARY_UOM_CODE_TAB(i),
      PRIME_CONTRCTR_PART_EXT  = PRIME_CONTRCTR_PART_EXT_TAB(i),
      PROCESS_STATUS           = PROCESS_STATUS_TAB(i),
      CUST_PO_RELEASE_NUM      = CUST_PO_RELEASE_NUM_TAB(i),
      CUST_PO_DATE             = CUST_PO_DATE_TAB(i),
      CUST_PO_LINE_NUM         = CUST_PO_LINE_NUM_TAB(i),
      CUST_PO_NUMBER           = CUST_PO_NUMBER_TAB(i),
      QTY_TYPE_CODE            = QTY_TYPE_CODE_TAB(i),
      QTY_TYPE_CODE_EXT        = QTY_TYPE_CODE_EXT_TAB(i),
      RETURN_CONTAINER_EXT     = RETURN_CONTAINER_EXT_TAB(i),
      SCHEDULE_LINE_ID         = SCHEDULE_LINE_ID_TAB(i),
      ROUTING_DESC_EXT         = ROUTING_DESC_EXT_TAB(i),
      ROUTING_SEQ_CODE_EXT     = ROUTING_SEQ_CODE_EXT_TAB(i),
      SCHEDULE_ITEM_NUM        = SCHEDULE_ITEM_NUM_TAB(i),
      SHIP_DEL_PATTERN_EXT     = SHIP_DEL_PATTERN_EXT_TAB(i),
      SHIP_DEL_TIME_CODE_EXT   = SHIP_DEL_TIME_CODE_EXT_TAB(i),
      SHIP_DEL_RULE_NAME       = SHIP_DEL_RULE_NAME_TAB(i),
      SHIP_FROM_ADDRESS_1_EXT  = SHIP_FROM_ADDRESS_1_EXT_TAB(i),
      SHIP_FROM_ADDRESS_2_EXT  = SHIP_FROM_ADDRESS_2_EXT_TAB(i),
      SHIP_FROM_ADDRESS_3_EXT  = SHIP_FROM_ADDRESS_3_EXT_TAB(i),
      SHIP_FROM_ADDRESS_4_EXT  = SHIP_FROM_ADDRESS_4_EXT_TAB(i),
      SHIP_FROM_CITY_EXT       = SHIP_FROM_CITY_EXT_TAB(i),
      SHIP_FROM_COUNTRY_EXT    = SHIP_FROM_COUNTRY_EXT_TAB(i),
      SHIP_FROM_COUNTY_EXT     = SHIP_FROM_COUNTY_EXT_TAB(i),
      SHIP_FROM_NAME_EXT       = SHIP_FROM_NAME_EXT_TAB(i),
      SHIP_FROM_ORG_ID         = SHIP_FROM_ORG_ID_TAB(i),
      SHIP_FROM_POSTAL_CD_EXT  = SHIP_FROM_POSTAL_CD_EXT_TAB(i),
      SHIP_FROM_PROVINCE_EXT   = SHIP_FROM_PROVINCE_EXT_TAB(i),
      SHIP_FROM_STATE_EXT      = SHIP_FROM_STATE_EXT_TAB(i),
      SHIP_LABEL_INFO_LINE_1   = SHIP_LABEL_INFO_LINE_1_TAB(i),
      SHIP_LABEL_INFO_LINE_10  = SHIP_LABEL_INFO_LINE_10_TAB(i),
      SHIP_LABEL_INFO_LINE_2   = SHIP_LABEL_INFO_LINE_2_TAB(i),
      SHIP_LABEL_INFO_LINE_3   = SHIP_LABEL_INFO_LINE_3_TAB(i),
      SHIP_LABEL_INFO_LINE_4   = SHIP_LABEL_INFO_LINE_4_TAB(i),
      SHIP_LABEL_INFO_LINE_5   = SHIP_LABEL_INFO_LINE_5_TAB(i),
      SHIP_LABEL_INFO_LINE_6   = SHIP_LABEL_INFO_LINE_6_TAB(i),
      SHIP_LABEL_INFO_LINE_7   = SHIP_LABEL_INFO_LINE_7_TAB(i),
      SHIP_LABEL_INFO_LINE_8   = SHIP_LABEL_INFO_LINE_8_TAB(i),
      SHIP_LABEL_INFO_LINE_9   = SHIP_LABEL_INFO_LINE_9_TAB(i),
      SHIP_TO_ADDRESS_1_EXT    = SHIP_TO_ADDRESS_1_EXT_TAB(i),
      SHIP_TO_ADDRESS_2_EXT     = SHIP_TO_ADDRESS_2_EXT_TAB(i),
      SHIP_TO_ADDRESS_3_EXT     = SHIP_TO_ADDRESS_3_EXT_TAB(i),
      SHIP_TO_ADDRESS_4_EXT     = SHIP_TO_ADDRESS_4_EXT_TAB(i),
      SHIP_TO_ADDRESS_ID        = SHIP_TO_ADDRESS_ID_TAB(i),
      DELIVER_TO_ORG_ID         = DELIVER_TO_ORG_ID_TAB(i),
      SHIP_TO_CITY_EXT          = SHIP_TO_CITY_EXT_TAB(i),
      SHIP_TO_COUNTRY_EXT       = SHIP_TO_COUNTRY_EXT_TAB(i),
      SHIP_TO_COUNTY_EXT        = SHIP_TO_COUNTY_EXT_TAB(i),
      SHIP_TO_NAME_EXT          = SHIP_TO_NAME_EXT_TAB(i),
      SHIP_TO_POSTAL_CD_EXT     = SHIP_TO_POSTAL_CD_EXT_TAB(i),
      SHIP_TO_PROVINCE_EXT      = SHIP_TO_PROVINCE_EXT_TAB(i),
      SHIP_TO_SITE_USE_ID       = SHIP_TO_SITE_USE_ID_TAB(i),
      SHIP_TO_STATE_EXT         = SHIP_TO_STATE_EXT_TAB(i),
      START_DATE_TIME           = START_DATE_TIME_TAB(i),
      SUBLINE_ASSIGNED_ID_EXT   = SUBLINE_ASSIGNED_ID_EXT_TAB(i),
      SUBLINE_CONFIG_CODE_EXT   = SUBLINE_CONFIG_CODE_EXT_TAB(i),
      SUBLINE_CUST_ITEM_EXT     = SUBLINE_CUST_ITEM_EXT_TAB(i),
      SUBLINE_CUST_ITEM_ID      = SUBLINE_CUST_ITEM_ID_TAB(i),
      SUBLINE_MODEL_NUM_EXT     = SUBLINE_MODEL_NUM_EXT_TAB(i),
      SUBLINE_QUANTITY         = SUBLINE_QUANTITY_TAB(i),
      SUBLINE_UOM_CODE         = SUBLINE_UOM_CODE_TAB(i),
      SUPPLIER_ITEM_EXT        = SUPPLIER_ITEM_EXT_TAB(i),
      TRANSIT_TIME_EXT         = TRANSIT_TIME_EXT_TAB(i),
      TRANSIT_TIME_QUAL_EXT    = TRANSIT_TIME_QUAL_EXT_TAB(i),
      TRANSPORT_LOC_QUAL_EXT   = TRANSPORT_LOC_QUAL_EXT_TAB(i),
      TRANSPORT_LOCATION_EXT   = TRANSPORT_LOCATION_EXT_TAB(i),
      TRANSPORT_METHOD_EXT    = TRANSPORT_METHOD_EXT_TAB(i),
      UOM_CODE               = UOM_CODE_TAB(i),
      WEIGHT_EXT            = WEIGHT_EXT_TAB(i),
      WEIGHT_QUALIFIER_EXT   = WEIGHT_QUALIFIER_EXT_TAB(i),
      WEIGHT_UOM_EXT         = WEIGHT_UOM_EXT_TAB(i),
      FBO_CONFIGURATION_KEY_1   = FBO_CONFIGURATION_KEY_1_TAB(i),
      FBO_CONFIGURATION_KEY_2  = FBO_CONFIGURATION_KEY_2_TAB(i),
      FBO_CONFIGURATION_KEY_3  = FBO_CONFIGURATION_KEY_3_TAB(i),
      FBO_CONFIGURATION_KEY_4  = FBO_CONFIGURATION_KEY_4_TAB(i),
      FBO_CONFIGURATION_KEY_5  = FBO_CONFIGURATION_KEY_5_TAB(i),
      MATCH_KEY_ACROSS         = MATCH_KEY_ACROSS_TAB(i),
      MATCH_KEY_WITHIN         = MATCH_KEY_WITHIN_TAB(i),
      CRITICAL_KEY_ATTRIBUTES  = CRITICAL_KEY_ATTRIBUTES_TAB(i),
      ATTRIBUTE_CATEGORY       = ATTRIBUTE_CATEGORY_TAB(i),
      ATTRIBUTE1               = ATTRIBUTE1_TAB(i),
      ATTRIBUTE2               = ATTRIBUTE2_TAB(i),
      ATTRIBUTE3               = ATTRIBUTE3_TAB(i),
      ATTRIBUTE4               = ATTRIBUTE4_TAB(i),
      ATTRIBUTE5               = ATTRIBUTE5_TAB(i),
      ATTRIBUTE6              = ATTRIBUTE6_TAB(i),
      ATTRIBUTE7              = ATTRIBUTE7_TAB(i),
      ATTRIBUTE8              = ATTRIBUTE8_TAB(i),
      ATTRIBUTE9              = ATTRIBUTE9_TAB(i),
      ATTRIBUTE10             = ATTRIBUTE10_TAB(i),
      ATTRIBUTE11             = ATTRIBUTE11_TAB(i),
      ATTRIBUTE12             = ATTRIBUTE12_TAB(i),
      ATTRIBUTE13             = ATTRIBUTE13_TAB(i),
      ATTRIBUTE14             = ATTRIBUTE14_TAB(i),
      ATTRIBUTE15             = ATTRIBUTE15_TAB(i),
      BLANKET_NUMBER	      = BLANKET_NUMBER_TAB(i),
      INTMED_SHIP_TO_ORG_ID   = INTMED_SHIP_TO_ORG_ID_TAB(i),
      LAST_UPDATE_DATE          = v_last_update_date,
      LAST_UPDATED_BY           = v_last_updated_by,
      LAST_UPDATE_LOGIN         = v_last_update_login,
      REQUEST_ID                = v_request_id,
      PROGRAM_APPLICATION_ID    = v_program_application_id,
      PROGRAM_ID                = v_program_id,
      PROGRAM_UPDATE_DATE       = v_program_update_date,
      SHIP_TO_CUSTOMER_ID       = SHIP_TO_CUSTOMER_ID_TAB(i)
    WHERE header_id = header_id_tab(i)
    AND   line_id = line_id_tab(i);
  -- bulk update
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG,'Number of Interface lines updated',SQL%ROWCOUNT);
    rlm_core_sv.dlog(C_DEBUG,'Number of Interface lines in g_lines_tab ',g_lines_tab.COUNT);
  END IF;
  --
  --
  IF g_lines_tab.COUNT >= 1 AND IsGroupError THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Current group failed validation');
     END IF;
     --
  END IF;
  --
  --
  IF NOT IsGroupError THEN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog('Current group passed validation, so set g_schedule_PS to PS_available');
   END IF;
   --
   g_schedule_PS := rlm_core_sv.k_PS_AVAILABLE;
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
    rlm_message_sv.sql_error('rlm_validateDemand_sv.UpdateInterfaceLines',
                                      v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    raise;
    --
END UpdateInterfaceLines;

/*===========================================================================

        PROCEDURE NAME:  UpdateInterfaceHeaders

===========================================================================*/
PROCEDURE UpdateInterfaceHeaders
IS
  v_Progress         VARCHAR(3) := '010';

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'UpdateInterfaceHeaders');
       rlm_core_sv.dlog(C_DEBUG, 'g_schedule_PS', g_schedule_PS);
       rlm_core_sv.dlog(C_DEBUG, 'g_line_PS', g_line_PS);
    END IF;
    --
    IF (g_schedule_PS = rlm_core_sv.k_PS_AVAILABLE
       AND g_line_PS = rlm_core_sv.k_PS_ERROR ) THEN
       --
       g_schedule_PS := rlm_core_sv.k_PS_PARTIAL_PROCESSED;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'Process Status PARTIAL_PROCESSED');
       END IF;
       --
    ELSIF (g_schedule_PS = rlm_core_sv.k_PS_ERROR
       AND g_line_PS = rlm_core_sv.k_PS_ERROR ) THEN
       --
       g_schedule_PS := rlm_core_sv.k_PS_ERROR;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'Process Status ERROR');
       END IF;
       --
    ELSIF (g_schedule_PS = rlm_core_sv.k_PS_AVAILABLE
       AND g_line_PS = rlm_core_sv.k_PS_AVAILABLE ) THEN
       --
       g_schedule_PS := rlm_core_sv.k_PS_AVAILABLE;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'Process Status AVAILABLE');
       END IF;
       --
    END IF;

    UPDATE rlm_interface_headers SET
      CUST_ADDRESS_1_EXT    =   g_header_rec.CUST_ADDRESS_1_EXT ,
      CUST_ADDRESS_2_EXT    =  g_header_rec. CUST_ADDRESS_2_EXT ,
      CUST_ADDRESS_3_EXT    =    g_header_rec.CUST_ADDRESS_3_EXT ,
      CUST_ADDRESS_4_EXT    =    g_header_rec.CUST_ADDRESS_4_EXT ,
      CUST_CITY_EXT         =  g_header_rec.CUST_CITY_EXT ,
      CUST_COUNTRY_EXT      =  g_header_rec.CUST_COUNTRY_EXT ,
      CUST_COUNTY_EXT       =  g_header_rec.CUST_COUNTY_EXT ,
      CUSTOMER_EXT          =  g_header_rec.CUSTOMER_EXT ,
      CUST_NAME_EXT         =  g_header_rec.CUST_NAME_EXT ,
      CUST_POSTAL_CD_EXT    =  g_header_rec.CUST_POSTAL_CD_EXT ,
      CUST_PROVINCE_EXT     =  g_header_rec.CUST_PROVINCE_EXT ,
      CUST_STATE_EXT        =  g_header_rec.CUST_STATE_EXT ,
      CUSTOMER_ID           =  g_header_rec.CUSTOMER_ID ,
      ECE_PRIMARY_ADDRESS_ID =  g_header_rec.ECE_PRIMARY_ADDRESS_ID ,
      ECE_TP_LOCATION_CODE_EXT =  g_header_rec.ECE_TP_LOCATION_CODE_EXT ,
      ECE_TP_TRANSLATOR_CODE   =  g_header_rec.ECE_TP_TRANSLATOR_CODE ,
      EDI_CONTROL_NUM_1        =  g_header_rec.EDI_CONTROL_NUM_1 ,
      EDI_CONTROL_NUM_2        =  g_header_rec.EDI_CONTROL_NUM_2 ,
      EDI_CONTROL_NUM_3        =  g_header_rec.EDI_CONTROL_NUM_3 ,
      EDI_TEST_INDICATOR       =  g_header_rec.EDI_TEST_INDICATOR ,
      HEADER_CONTACT_CODE_1    =  g_header_rec.HEADER_CONTACT_CODE_1 ,
      HEADER_CONTACT_CODE_2    =  g_header_rec.HEADER_CONTACT_CODE_2 ,
      HEADER_CONTACT_VALUE_1   =  g_header_rec.HEADER_CONTACT_VALUE_1 ,
      HEADER_CONTACT_VALUE_2   =  g_header_rec.HEADER_CONTACT_VALUE_2 ,
      HEADER_NOTE_TEXT         =  g_header_rec.HEADER_NOTE_TEXT ,
      HEADER_REF_CODE_1        =  g_header_rec.HEADER_REF_CODE_1 ,
      HEADER_REF_CODE_2        =  g_header_rec.HEADER_REF_CODE_2 ,
      HEADER_REF_CODE_3        =  g_header_rec.HEADER_REF_CODE_3 ,
      HEADER_REF_VALUE_1       =  g_header_rec.HEADER_REF_VALUE_1 ,
      HEADER_REF_VALUE_2       =  g_header_rec.HEADER_REF_VALUE_2 ,
      HEADER_REF_VALUE_3       =  g_header_rec.HEADER_REF_VALUE_3 ,
      PROCESS_STATUS           =  g_schedule_PS,
      SCHEDULE_HEADER_ID       =  g_header_rec.SCHEDULE_HEADER_ID ,
      SCHEDULE_TYPE            =  g_header_rec.SCHEDULE_TYPE ,
      SCHEDULE_TYPE_EXT        =  g_header_rec.SCHEDULE_TYPE_EXT ,
      SCHED_GENERATION_DATE    =  g_header_rec.SCHED_GENERATION_DATE ,
      SCHED_HORIZON_END_DATE   =  g_header_rec.SCHED_HORIZON_END_DATE ,
      SCHED_HORIZON_START_DATE =  g_header_rec.SCHED_HORIZON_START_DATE ,
      SCHEDULE_PURPOSE         =  g_header_rec.SCHEDULE_PURPOSE ,
      SCHEDULE_PURPOSE_EXT     =  g_header_rec.SCHEDULE_PURPOSE_EXT ,
      SCHEDULE_REFERENCE_NUM   =  g_header_rec.SCHEDULE_REFERENCE_NUM ,
      SCHEDULE_SOURCE          =  g_header_rec.SCHEDULE_SOURCE ,
      LAST_UPDATE_DATE         =  sysdate,
      LAST_UPDATED_BY          =  fnd_global.user_id ,
      CREATION_DATE            =  g_header_rec.CREATION_DATE ,
      CREATED_BY               =  g_header_rec.CREATED_BY ,
      ATTRIBUTE_CATEGORY       =  g_header_rec.ATTRIBUTE_CATEGORY ,
      ATTRIBUTE1               =  g_header_rec.ATTRIBUTE1 ,
      ATTRIBUTE2               =  g_header_rec.ATTRIBUTE2 ,
      ATTRIBUTE3               =  g_header_rec.ATTRIBUTE3 ,
      ATTRIBUTE4               =  g_header_rec.ATTRIBUTE4 ,
      ATTRIBUTE5               =  g_header_rec.ATTRIBUTE5 ,
      ATTRIBUTE6               =  g_header_rec.ATTRIBUTE6 ,
      ATTRIBUTE7               =  g_header_rec.ATTRIBUTE7 ,
      ATTRIBUTE8               =  g_header_rec.ATTRIBUTE8 ,
      ATTRIBUTE9               =  g_header_rec.ATTRIBUTE9 ,
      ATTRIBUTE10              =  g_header_rec.ATTRIBUTE10 ,
      ATTRIBUTE11              =  g_header_rec.ATTRIBUTE11 ,
      ATTRIBUTE12              =  g_header_rec.ATTRIBUTE12 ,
      ATTRIBUTE13              =  g_header_rec.ATTRIBUTE13 ,
      ATTRIBUTE14              =  g_header_rec.ATTRIBUTE14 ,
      ATTRIBUTE15              =  g_header_rec.ATTRIBUTE15 ,
      LAST_UPDATE_LOGIN        =  fnd_global.login_id ,
      REQUEST_ID               =  fnd_global.conc_REQUEST_ID ,
      PROGRAM_APPLICATION_ID   =  fnd_global.PROG_APPL_ID ,
      PROGRAM_ID               =  fnd_global.conc_PROGRAM_ID ,
      PROGRAM_UPDATE_DATE      =  sysdate
    WHERE header_id = g_header_rec.header_id;

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Number of Interface header updated',SQL%ROWCOUNT);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    --
    rollback;
    rlm_message_sv.sql_error('rlm_validateDemand_sv.UpdateInterfaceHeaders: ',
                               v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    raise;
    --
END UpdateInterfaceHeaders;

/*===========================================================================

        FUNCTION NAME:  PostValidation

===========================================================================*/
PROCEDURE PostValidation
IS
  v_Status             BOOLEAN := TRUE;
  v_Progress           VARCHAR(3) := '010';
  e_ArchiveAPIFailed   EXCEPTION;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'PostValidation');
     rlm_core_sv.dlog(C_DEBUG,'Header_id',g_Header_Rec.header_id);
  END IF;
  --
  v_Status := rlm_ad_sv.Archive_Demand(g_Header_Rec.header_id);
  --
  v_Progress := '020';
  --
  IF NOT v_Status THEN
     raise e_ArchiveAPIFailed;
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  WHEN e_ArchiveAPIFailed THEN
    --
    g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_error_level,
                x_MessageName => 'RLM_ARCHIVE_API_ERROR',
                x_InterfaceHeaderId => g_Header_Rec.header_id,
                x_Token1 => 'ERROR',
                x_value1 => sqlerrm,
                x_ValidationType => 'ARCHIVE');
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'EXCEPTION: RLM_ARCHIVE_API_ERROR ',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
    rlm_message_sv.sql_error('rlm_validateDemand_sv.PostValidation: ',
                                 v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    raise;
    --
END PostValidation;

/*===========================================================================

  PROCEDURE CallSetups

===========================================================================*/
FUNCTION CallSetups( x_Group_rec IN OUT NOCOPY t_Group_rec,
                     x_header_rec IN rlm_interface_headers%ROWTYPE,
                     x_lines_rec IN rlm_interface_lines%ROWTYPE)
RETURN BOOLEAN
IS

  v_SetupTerms_rec    rlm_setup_terms_sv.setup_terms_rec_typ;
  v_TermsLevel        VARCHAR2(30) := NULL;
  v_ReturnStatus      BOOLEAN;
  v_ReturnMsg         VARCHAR2(3000);
  e_NoSetupTerms      EXCEPTION;
  --e_skip_callsetup    EXCEPTION; --Commented as part of Bugfix 8693697

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CallSetups');
     rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.ship_from_org_id',
                              x_lines_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.cust_ship_from_org_ext',
                              x_lines_rec.cust_ship_from_org_ext);
     rlm_core_sv.dlog(C_DEBUG,'x_header_rec.customer_id',
                              x_header_rec.customer_id);
     rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.ship_to_address_id',
                              x_lines_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG,'x_lines_rec.customer_item_id',
                              x_lines_rec.customer_item_id);
  END IF;
  --
-- NOTE: call setupAPI to poulate setup info in the group rec:
-- schedule precedence,match within/across strings
-- firm disposition code and offset days, order header id
  --
  -- Bug 5098241
  -- For ATP item we expect the ship_from_org_id and
  -- cust_ship_from_org_ext to be null. If ship_from_org_id is null
  -- and cust_ship_from_org_ext is not null, then this means that for
  -- a non-ATP item, we have failed to derive the ship_from_org_id
  -- and for this reason we won't be able to get the setup terms.
  --
--Commented as part of Bugfix 8693697
/*  IF (x_lines_rec.cust_ship_from_org_ext IS NOT NULL)
    AND (x_lines_rec.ship_from_org_id IS NULL)
  THEN
    RAISE e_skip_callsetup;
  END IF;*/ --Bugfix 8693697 End

  RLM_TPA_SV.get_setup_terms(x_lines_rec.ship_from_org_id,
                                     x_header_rec.customer_id,
                                     x_lines_rec.ship_to_address_id,
                                     x_lines_rec.customer_item_id,
                                     v_TermsLevel,
                                     v_SetupTerms_rec,
                                     v_ReturnMsg, -- For Patch for Nov17 freeze
                                     v_ReturnStatus);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'v_TermsLevel', v_TermsLevel);
     rlm_core_sv.dlog(C_DEBUG, 'v_ReturnStatus', v_ReturnStatus);
     rlm_core_sv.dlog(C_DEBUG,'v_SetupTerms_rec.schedule_hierarchy_code',
                   v_SetupTerms_rec.schedule_hierarchy_code);
     rlm_core_sv.dlog(C_DEBUG,'v_SetupTerms_rec.header_id',
                   v_SetupTerms_rec.header_id);
     rlm_core_sv.dlog(C_DEBUG, 'v_SetupTerms_rec.blanket_number',
		   v_SetupTerms_rec.blanket_number);
  END IF;
  --
  IF v_ReturnStatus THEN
    --
    x_Group_rec.setup_terms_rec := v_SetupTerms_rec;
    --
  ELSE
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'setups failed');
    END IF;
    --
    RAISE e_NoSetupTerms;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN TRUE;
  --
EXCEPTION
  --
  -- bug 5098241
  --Commented as part of Bugfix 8693697
/*  WHEN e_skip_callsetup THEN
   --

  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG,'SetupAPI failed');
     rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: e_skip_callsetup');
  END IF;
  --
  RETURN FALSE;*/ --Bugfix 8693697 End
  --
  WHEN e_NoSetupTerms THEN
   --
   --g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
   IF(v_SetupTerms_rec.msg_name = 'RLM_SETUP_CUST_INACTIVE_RECORD') THEN
     --
     rlm_message_sv.get_msg_text(
                  x_message_name => v_SetupTerms_rec.msg_name,
                  x_text => v_ReturnMsg,
                  x_token1 => 'CUSTOMER',
                  x_value1 => rlm_core_sv.get_customer_name(x_header_rec.customer_id),
                  x_token2 => 'SHIPFROM',
                  x_value2 => rlm_core_sv.get_ship_from(x_lines_rec.ship_from_org_id),
                  x_token3 => 'SHIPTO',
                  x_value3 => RLM_CORE_SV.get_ship_to(x_lines_rec.ship_to_address_id),
                  x_token4 => 'ITEM',
                  x_value4 => RLM_CORE_SV.get_item_number(x_lines_rec.customer_item_id)
                  );
     --
   END IF;

   rlm_message_sv.app_error(
           x_ExceptionLevel    => rlm_message_sv.k_error_level,
           x_MessageName       => 'RLM_SETUPAPI_FAILED',
           x_ChildMessageName  => v_SetupTerms_rec.msg_name,
           x_InterfaceHeaderId => x_lines_rec.header_id,
           x_InterfaceLineId   => x_lines_rec.line_id,
           x_Token1            => 'ERROR',
           x_value1            => v_ReturnMsg,
           x_ValidationType => 'SETUPS');
  --
  IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG,'SetupAPI failed');
     rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_SETUPAPI_FAILED');
  END IF;
  --
  RETURN FALSE;
  --
 WHEN OTHERS THEN
  --
  --g_header_rec.process_status := rlm_core_sv.k_PS_ERROR;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
  END IF;
  --
  raise; /* should we do a raise here */
  --
END CallSetups;

/*=============================================================================
   PROCEDURE NAME:      ValidForecastDesig

==============================================================================*/
PROCEDURE ValidForecastDesig(
               x_setup_terms_rec  IN RLM_SETUP_TERMS_SV.setup_terms_rec_typ,
               x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
               x_lines_rec IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE,
               x_ForecastDesignator IN OUT NOCOPY VARCHAR2)
IS
  --
  v_progress            VARCHAR2(3) := '010';
  IsMRPForecastFence    BOOLEAN := FALSE;
  v_mrp_cnt             NUMBER  := 0;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'ValidForecastDesig');
     rlm_core_sv.dlog(C_DEBUG, 'schedule type',x_header_rec.schedule_type);
     rlm_core_sv.dlog(C_DEBUG, 'pln_mrp_forecast_day_from',
                            x_setup_terms_rec.pln_mrp_forecast_day_from);
     rlm_core_sv.dlog(C_DEBUG, 'shp_mrp_forecast_day_from',
                            x_setup_terms_rec.shp_mrp_forecast_day_from);
     rlm_core_sv.dlog(C_DEBUG, 'seq_mrp_forecast_day_from',
                            x_setup_terms_rec.seq_mrp_forecast_day_from);
  END IF;
  --
  IF rlm_message_sv.check_dependency('FORECASTDESIGNATOR') THEN
     --
     IF x_header_rec.schedule_type = k_PLANNING AND
       (x_setup_terms_rec.pln_mrp_forecast_day_from IS NOT NULL AND
        x_setup_terms_rec.pln_mrp_forecast_day_from <> 0)  THEN
        --
        IsMRPForecastFence := TRUE;
        --
     ELSIF x_header_rec.schedule_type = k_SHIPPING AND
       (x_setup_terms_rec.shp_mrp_forecast_day_from IS NOT NULL AND
        x_setup_terms_rec.shp_mrp_forecast_day_from <> 0)  THEN
        --
        IsMRPForecastFence := TRUE;
        --
     ELSIF x_header_rec.schedule_type = k_SEQUENCED AND
       (x_setup_terms_rec.seq_mrp_forecast_day_from IS NOT NULL AND
        x_setup_terms_rec.seq_mrp_forecast_day_from <> 0)  THEN
        --
        IsMRPForecastFence := TRUE;
        --
     END IF;

     IF NOT IsMRPForecastFence THEN
        --
        -- We need to check whether any lines have been interfaced with the item detail
        -- type 6 since the forecast designator needs to be validated even in that instance
        --
        SELECT COUNT(*)
        INTO  v_mrp_cnt
        FROM  rlm_interface_lines
        WHERE item_detail_type = '6'
        AND   header_id = x_header_rec.header_id
        AND   line_id  = x_lines_rec.line_id;
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'number of lines interfaced as MRP forecast ',v_mrp_cnt);
        END IF;
        --
        IF v_mrp_cnt > 0 THEN
          --
          IsMRPForecastFence := TRUE;
          --
        END IF;
        --
     END IF;
     --
     IF IsMRPForecastFence THEN
        --
        rlm_tpa_sv.GetDesignator(
                   NULL,
                   NULL,
                   x_header_rec.Customer_id,
                   x_lines_rec.Ship_From_Org_Id,
                   x_lines_rec.ship_to_site_use_id ,
                   x_lines_rec.bill_to_site_use_id,
                   x_lines_rec.bill_to_address_Id,
                   x_ForecastDesignator);
	--
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'x_ForecastDesignator',x_ForecastDesignator);
        END IF;
        --
        IF x_ForecastDesignator is NULL THEN
           --
            x_lines_rec.process_status := rlm_core_sv.k_PS_ERROR;
            rlm_message_sv.app_error(
                        x_ExceptionLevel => rlm_message_sv.k_error_level,
                        x_MessageName => 'RLM_NO_FORECAST_DESIG',
                        x_InterfaceHeaderId => x_lines_rec.header_id,
                        x_InterfaceLineId => x_lines_rec.line_id,
                        x_token1=>'CUST',
                        x_value1=>
                        rlm_core_sv.get_customer_name(x_header_rec.customer_id),
                        x_ValidationType => 'FORECASTDESIGNATOR');
            --
         END IF;
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
  --
  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
END ValidForecastDesig;

/*===========================================================================

        FUNCTION NAME:  PrintTable

===========================================================================*/
PROCEDURE PrintTable(v_LinesTab IN t_Lines_Tab,
                     i IN NUMBER)
IS
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'PrintTable');
     rlm_core_sv.dlog(C_DEBUG,'v_LinesTab.COUNT',v_LinesTab.COUNT);
  END IF;
  --
  IF i is not NULL THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'process_status',v_LinesTab(i).process_status);
        rlm_core_sv.dlog(C_DEBUG,'cust_ship_from_org_ext',v_LinesTab(i).cust_ship_from_org_ext);
        rlm_core_sv.dlog(C_DEBUG,'ship_from_org_id',v_LinesTab(i).ship_from_org_id);
        rlm_core_sv.dlog(C_DEBUG,'cust_ship_to_ext',v_LinesTab(i).cust_ship_to_ext);
        rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id',v_LinesTab(i).ship_to_address_id);
        rlm_core_sv.dlog(C_DEBUG,'supplier_item_ext',v_LinesTab(i).supplier_item_ext);
        rlm_core_sv.dlog(C_DEBUG,'Customer_Item_Ext',v_LinesTab(i).Customer_Item_Ext);
        rlm_core_sv.dlog(C_DEBUG,'Customer_Item_Id',v_LinesTab(i).Customer_Item_Id);
        rlm_core_sv.dlog(C_DEBUG,'INVENTORY_ITEM_ID',v_LinesTab(i).INVENTORY_ITEM_ID);
        rlm_core_sv.dlog(C_DEBUG,'CUST_BILL_TO_EXT',v_LinesTab(i).CUST_BILL_TO_EXT);
        rlm_core_sv.dlog(C_DEBUG,'BILL_TO_ADDRESS_ID',v_LinesTab(i).BILL_TO_ADDRESS_ID);
        rlm_core_sv.dlog(C_DEBUG,'CUST_INTRMD_SHIP_TO_EXT',v_LinesTab(i).CUST_INTRMD_SHIP_TO_EXT);
        rlm_core_sv.dlog(C_DEBUG,'INTRMD_SHIP_TO_ID',v_LinesTab(i).INTRMD_SHIP_TO_ID);
        rlm_core_sv.dlog(C_DEBUG,'ITEM_DETAIL_TYPE',v_LinesTab(i).ITEM_DETAIL_TYPE);
        rlm_core_sv.dlog(C_DEBUG,'ITEM_DETAIL_SUBTYPE',v_LinesTab(i).ITEM_DETAIL_SUBTYPE);
        rlm_core_sv.dlog(C_DEBUG,'order_header_id',v_LinesTab(i).order_header_id);
        rlm_core_sv.dlog(C_DEBUG,'ship_del_rule_name',v_LinesTab(i).ship_del_rule_name);
     END IF;
     --
  ELSE
    --
    For i IN 1..v_LinesTab.COUNT LOOP
       --
       IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'process_status',v_LinesTab(i).process_status);
         rlm_core_sv.dlog(C_DEBUG,'cust_ship_from_org_ext',v_LinesTab(i).cust_ship_from_org_ext);
         rlm_core_sv.dlog(C_DEBUG,'ship_from_org_id',v_LinesTab(i).ship_from_org_id);
         rlm_core_sv.dlog(C_DEBUG,'cust_ship_to_ext',v_LinesTab(i).cust_ship_to_ext);
         rlm_core_sv.dlog(C_DEBUG,'ship_to_address_id',v_LinesTab(i).ship_to_address_id);
         rlm_core_sv.dlog(C_DEBUG,'supplier_item_ext',v_LinesTab(i).supplier_item_ext);
         rlm_core_sv.dlog(C_DEBUG,'Customer_Item_Ext',v_LinesTab(i).Customer_Item_Ext);
         rlm_core_sv.dlog(C_DEBUG,'Customer_Item_Id',v_LinesTab(i).Customer_Item_Id);
         rlm_core_sv.dlog(C_DEBUG,'INVENTORY_ITEM_ID',v_LinesTab(i).INVENTORY_ITEM_ID);
         rlm_core_sv.dlog(C_DEBUG,'CUST_BILL_TO_EXT',v_LinesTab(i).CUST_BILL_TO_EXT);
         rlm_core_sv.dlog(C_DEBUG,'BILL_TO_ADDRESS_ID',v_LinesTab(i).BILL_TO_ADDRESS_ID);
         rlm_core_sv.dlog(C_DEBUG,'CUST_INTRMD_SHIP_TO_EXT',v_LinesTab(i).CUST_INTRMD_SHIP_TO_EXT);
         rlm_core_sv.dlog(C_DEBUG,'INTRMD_SHIP_TO_ID',v_LinesTab(i).INTRMD_SHIP_TO_ID);
         rlm_core_sv.dlog(C_DEBUG,'ITEM_DETAIL_TYPE',v_LinesTab(i).ITEM_DETAIL_TYPE);
         rlm_core_sv.dlog(C_DEBUG,'ITEM_DETAIL_SUBTYPE',v_LinesTab(i).ITEM_DETAIL_SUBTYPE);
         rlm_core_sv.dlog(C_DEBUG,'order_header_id',v_LinesTab(i).order_header_id);
         rlm_core_sv.dlog(C_DEBUG,'ship_del_rule_name',v_LinesTab(i).ship_del_rule_name);
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
  WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;
END PrintTable;


/*===========================================================================

        FUNCTION NAME:  GetTPContext

===========================================================================*/
PROCEDURE GetTPContext(x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                       x_lines_rec IN RLM_INTERFACE_LINES%ROWTYPE,
                       x_customer_number OUT NOCOPY VARCHAR2,
                       x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_tp_group_code OUT NOCOPY VARCHAR2)
IS
   v_Progress VARCHAR2(3) := '010';

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG,'GetTPContext');
   END IF;
   --
   IF x_header_rec.ECE_TP_LOCATION_CODE_EXT is NOT NULL THEN
        -- Following query is changed as per TCA obsolescence project.
	SELECT	ETG.TP_GROUP_CODE
	INTO	x_tp_group_code
	FROM	ECE_TP_GROUP ETG,
		ECE_TP_HEADERS ETH,
		HZ_CUST_ACCT_SITES ACCT_SITE
	WHERE	ETG.TP_GROUP_ID = ETH.TP_GROUP_ID
	and	ETH.TP_HEADER_ID = ACCT_SITE.TP_HEADER_ID
	and	ACCT_SITE.CUST_ACCOUNT_ID = x_header_rec.CUSTOMER_ID
	and	ACCT_SITE.ECE_TP_LOCATION_CODE = x_header_rec.ECE_TP_LOCATION_CODE_EXT;
   ELSE
      x_tp_group_code := x_header_rec.ECE_TP_TRANSLATOR_CODE;
   END IF;
   --
   x_ship_to_ece_locn_code := x_header_rec.ECE_TP_LOCATION_CODE_EXT;

   IF x_ship_to_ece_locn_code is NULL THEN
       x_ship_to_ece_locn_code := x_lines_rec.cust_ship_to_ext;
   END IF;

   x_bill_to_ece_locn_code := x_lines_rec.cust_bill_to_ext;
   x_inter_ship_to_ece_locn_code := x_lines_rec.cust_intrmd_ship_to_ext;

   IF x_header_rec.customer_id is NOT NULL THEN
      -- Following query is changed as per TCA obsolescence project.
      SELECT 	ACCOUNT_NUMBER
      INTO   	x_customer_number
      FROM   	HZ_CUST_ACCOUNTS CUST_ACCT
      WHERE 	CUST_ACCT.CUST_ACCOUNT_ID = x_header_rec.Customer_Id;
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'customer_id', x_customer_number);
      rlm_core_sv.dlog(C_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG,'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG,'x_bill_to_ece_loc_code', x_bill_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG,'x_tp_group_code', x_tp_group_code);
      rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      x_customer_number := NULL;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'No data found for' , x_header_rec.customer_id);
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

   WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_validatedemand_sv.GetTPContext', v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetTPContext;

/*===========================================================================

        FUNCTION NAME:  GetHdrTPContext

===========================================================================*/
PROCEDURE GetHdrTPContext(x_header_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                          x_customer_number OUT NOCOPY VARCHAR2,
                          x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                          x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                          x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                          x_tp_group_code OUT NOCOPY VARCHAR2)
IS
   v_Progress VARCHAR2(3) := '010';

BEGIN
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dpush(C_SDEBUG,'GetHdrTPContext');
   END IF;
   --
   IF x_header_rec.ECE_TP_LOCATION_CODE_EXT is NOT NULL THEN
        -- Following query is changed as per TCA obsolescence project.
	SELECT	ETG.TP_GROUP_CODE
	INTO	x_tp_group_code
	FROM	ECE_TP_GROUP ETG,
		ECE_TP_HEADERS ETH,
		HZ_CUST_ACCT_SITES ACCT_SITE
	WHERE  	ETG.TP_GROUP_ID = ETH.TP_GROUP_ID
	and	ETH.TP_HEADER_ID = ACCT_SITE.TP_HEADER_ID
	and	ACCT_SITE.ECE_TP_LOCATION_CODE = x_header_rec.ECE_TP_LOCATION_CODE_EXT;
   ELSE
      x_tp_group_code := x_header_rec.ECE_TP_TRANSLATOR_CODE;
   END IF;
   --

   x_ship_to_ece_locn_code := x_header_rec.ECE_TP_LOCATION_CODE_EXT;
   x_bill_to_ece_locn_code := NULL;
   x_inter_ship_to_ece_locn_code := NULL;

   IF x_header_rec.customer_id is NOT NULL THEN
      -- Following query is changed as per TCA obsolescence project.
      SELECT 	ACCOUNT_NUMBER
      INTO   	x_customer_number
      FROM   	HZ_CUST_ACCOUNTS CUST_ACCT
      WHERE 	CUST_ACCT.CUST_ACCOUNT_ID = x_header_rec.Customer_Id;
   END IF;
   --
   IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'customer_id', x_customer_number);
      rlm_core_sv.dlog(C_DEBUG,'x_ship_to_ece_locn_code', x_ship_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG,'x_inter_ship_to_ece_locn_code', x_inter_ship_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG,'x_bill_to_ece_loc_code', x_bill_to_ece_locn_code);
      rlm_core_sv.dlog(C_DEBUG,'x_tp_group_code', x_tp_group_code);
      rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      x_customer_number := NULL;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'No data found for' , x_header_rec.customer_id);
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

   WHEN OTHERS THEN
      rlm_message_sv.sql_error('rlm_validatedemand_sv.GetHdrTPContext', v_Progress);
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
      END IF;
      --
      raise;

END GetHdrTPContext;

/*=============================================================================
  PROCEDURE NAME: SetTPAttCategory
==============================================================================*/
PROCEDURE SetTPAttCategory (
  		x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE,
                x_lines_rec  IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE,
                x_group_rec  IN OUT NOCOPY RLM_VALIDATEDEMAND_SV.t_Group_rec) IS
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(C_SDEBUG,'SetTPAttCategory');
  END IF;
  --
  x_header_rec.tp_attribute_category := x_header_rec.ece_tp_translator_code;
  x_lines_rec.tp_attribute_category := x_header_rec.ece_tp_translator_code;
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
     WHEN OTHERS THEN
        --
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
	END IF;
        --
END SetTPAttCategory;

/*=============================================================================
  PROCEDURE NAME: SetHdrTPAttCategory
==============================================================================*/
PROCEDURE SetHdrTPAttCategory (
  		x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE) IS
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(C_SDEBUG,'SetHdrTPAttCategory');
  END IF;
  --
  --x_header_rec.tp_attribute_category := NVL(x_header_rec.ece_tp_translator_code, x_header_rec.customer_ext);
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
     WHEN OTHERS THEN
        --
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
	END IF;

END SetHdrTPAttCategory;

/*=============================================================================
  PROCEDURE NAME: SetLineTPAttCategory
==============================================================================*/
PROCEDURE SetLineTPAttCategory (
  		x_header_rec IN OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE,
                x_lines_rec  IN OUT NOCOPY RLM_INTERFACE_LINES%ROWTYPE,
                x_group_rec  IN OUT NOCOPY RLM_VALIDATEDEMAND_SV.t_Group_rec) IS
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(C_SDEBUG,'SetLineTPAttCategory');
  END IF;
  --
  --x_header_rec.tp_attribute_category := NVL(x_header_rec.ece_tp_translator_code, x_header_rec.customer_ext);
  --x_lines_rec.tp_attribute_category := NVL(x_header_rec.ece_tp_translator_code, x_header_rec.customer_ext);
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
     WHEN OTHERS THEN
        --
        IF (l_debug <> -1) THEN
   	  rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
	END IF;

END SetLineTPAttCategory;

/*===========================================================================
        FUNCTION NAME:  CustomerRelationship
===========================================================================*/

FUNCTION CustomerRelationship(x_RelatedCustomerId IN NUMBER,
                              x_customer_id IN NUMBER,
                              x_header_id     IN NUMBER,
                              x_site_use_code IN VARCHAR2 DEFAULT 'BILL_TO')
RETURN BOOLEAN
IS

  v_Progress                    VARCHAR2(3) := '010';
  v_Temp                        VARCHAR2(10);
  v_parameter                   VARCHAR2(1);
  e_no_om_cr                    EXCEPTION;

BEGIN
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CustomerRelationship');
     rlm_core_sv.dlog(C_DEBUG,'x_RelatedCustomerId',x_RelatedCustomerId);
     rlm_core_sv.dlog(C_DEBUG,'x_customer_id',x_customer_id);
     rlm_core_sv.dlog(C_DEBUG,'x_site_use_code',x_site_use_code);
  END IF;
  --

  IF x_RelatedCustomerId <> x_customer_id THEN
     --
     IF x_site_use_code = 'BILL_TO' THEN
       --
       rlm_core_sv.dlog(C_DEBUG,'x_site_use_code',x_site_use_code);
       --
       SELECT      'exists'
       INTO        v_Temp
       FROM        HZ_CUST_ACCT_RELATE
       WHERE       cust_account_id = x_customer_id
       AND         related_cust_account_id = x_RelatedCustomerId
       AND         bill_to_flag = 'Y'
       AND         status='A';
       --
     ELSE
       --
       SELECT      'exists'
       INTO        v_Temp
       FROM        HZ_CUST_ACCT_RELATE
       WHERE       cust_account_id = x_customer_id
       AND         related_cust_account_id = x_RelatedCustomerId
       AND         ship_to_flag = 'Y'
       AND         status='A';
       --
     END IF;
     --
     -- Use Customer relationship only if the OM profile option is set.
     --
     v_parameter := OE_Sys_Parameters.value('CUSTOMER_RELATIONSHIPS_FLAG',
                                              MO_GLOBAL.get_current_org_id);
     --
     IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'v_parameter',v_parameter);
     END IF;
     --
     IF NVL(v_parameter,'N') NOT IN ('Y','A')  THEN
        --
        raise e_no_om_cr;
        --
     END IF;
     --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN(TRUE);

EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'NO_DATA_FOUND');
    END IF;
    --
    rlm_message_sv.app_error(
                              x_ExceptionLevel => rlm_message_sv.k_error_level,
                              x_MessageName => 'RLM_CUSTOMER_RELATIONSHIP',
                              x_InterfaceHeaderId => x_header_id,
                              x_token1=>'CUSTOMER1',
                              x_value1 => rlm_core_sv.get_customer_name(x_RelatedCustomerId),
                              x_token2=>'CUSTOMER2',
                              x_value2 => rlm_core_sv.get_customer_name(x_customer_id)
                             );
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_CUSTOMER_RELATIONSHIP');
    END IF;
    --
    RETURN(FALSE);
    --
  WHEN e_no_om_cr THEN
    --
    rlm_message_sv.app_error(x_ExceptionLevel => rlm_message_sv.k_error_level,
                             x_MessageName => 'RLM_OM_CUSTOMER_RELATIONSHIP',
                             x_InterfaceHeaderId => x_header_id);
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'e_no_om_cr');
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: RLM_OM_CUSTOMER_RELATIONSHIP');
    END IF;
    --
    RETURN(FALSE);
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('RLM_VALIDATEDEMAND_SV.CustomerRelationship',
                             v_Progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog (C_DEBUG,'SQL Error: ',substr(sqlerrm,1,300));
       rlm_core_sv.dlog(C_DEBUG,'progress',v_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    raise;
    --
END CustomerRelationship;


/*===========================================================================

        PROCEDURE NAME:  ValidateDateTypeATP

===========================================================================*/
PROCEDURE ValidateDateTypeATP(
          x_line      IN RLM_INTERFACE_LINES%ROWTYPE)
IS
 --global_atp
 v_order_date_type_code    VARCHAR2(30);
 v_order_number            NUMBER;
BEGIN
 --
 IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG, 'ValidateDateTypeATP');
 END IF;
 --
 IF RLM_MANAGE_DEMAND_SV.IsATPItem(x_line.ship_from_org_id,
                                   x_line.inventory_item_id) THEN

   IF x_line.item_detail_type IN ('0','1','2') THEN
      --
      BEGIN
        SELECT DECODE(order_date_type_code, 'ARRIVAL', 'DELIVER', 'SHIP'),
               order_number
        INTO   v_order_date_type_code, v_order_number
        FROM   oe_order_headers_all
        WHERE  header_id = x_line.order_header_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE;
        WHEN OTHERS THEN
          RAISE;
      END;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'OM Date Type', v_order_date_type_code);
         rlm_core_sv.dlog(C_DEBUG, 'RLM Date Type', x_line.date_type_code);
      END IF;
      --
      IF v_order_date_type_code <> x_line.date_type_code THEN
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'RLM line date type does not match OM date type');
        END IF;
        --
        rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_MISMATCH_DATE_TYPE',
                x_InterfaceHeaderId => x_line.header_id,
                x_InterfaceLineId => x_line.line_id,
                x_token1=> 'RLM_DATE_TYPE',
                x_value1=> rlm_core_sv.get_lookup_meaning(
                             'RLM_DATE_TYPE_CODE',
                             x_line.date_type_code),
                x_token2=> 'OM_DATE_TYPE',
                x_value2=> OE_Id_To_Value.Order_Date_Type(v_order_date_type_code),
                x_token3=> 'ORDER',
                x_value3=> TO_CHAR(v_order_number),
                x_token4=> 'SF',
                x_value4=> rlm_core_sv.get_ship_from(x_line.ship_from_org_id),
                x_token5=> 'ST',
                x_value5=> rlm_core_sv.get_ship_to(x_line.ship_to_address_id),
                x_token6=> 'CI',
                x_value6=> rlm_core_sv.get_item_number(x_line.customer_item_id));

                g_warned := TRUE;
          --
      END IF;
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
        rlm_core_sv.dpop(C_SDEBUG, 'No sales order found');
     END IF;

  WHEN OTHERS THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     END IF;

END ValidateDateTypeATP;


--
-- Blanket Order Procedures
--
/*=======================================================================================

  PROCEDURE DeriveBlanketPO

========================================================================================*/
PROCEDURE DeriveBlanketPO(x_cust_po_num	    IN RLM_INTERFACE_LINES.cust_po_number%TYPE,
			  x_Group_rec       IN t_Group_rec,
			  x_header_id	    IN RLM_INTERFACE_HEADERS.HEADER_ID%TYPE)
IS
 --
 v_blanket_po	VARCHAR2(240);
 v_blanket_num   NUMBER;
 e_POMisMatch	EXCEPTION;
 --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG, 'DeriveBlanketPO');
  END IF;
  --
  SELECT cust_po_number
  INTO v_blanket_po
  FROM oe_blanket_headers
  WHERE order_number = x_Group_rec.setup_terms_rec.blanket_number;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Blanket Number', x_Group_rec.setup_terms_rec.blanket_number);
    rlm_core_sv.dlog(C_DEBUG, 'Blanket PO number', v_blanket_po);
    rlm_core_sv.dlog(C_DEBUG, 'Schedule PO', x_cust_po_num);
  END IF;
  --
  IF (x_cust_po_num IS NOT NULL AND v_blanket_po IS NOT NULL) THEN
   --
    IF (v_blanket_po <> x_cust_po_num) THEN
     --
     RAISE e_POMisMatch;
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
   --
   WHEN e_POMisMatch THEN
    --
    rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_warn_level,
           x_MessageName => 'RLM_BLKT_PO_MISMATCH',
           x_InterfaceHeaderId => x_header_id,
           x_token1=>'SCHED_PO',
           x_value1=>x_cust_po_num,
           x_token2=>'BLKT_PO',
           x_value2=>v_blanket_po,
           x_ValidationType => 'PURCHASE_ORDER');
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'WARNING: Mismatch between PO on schedule and blanket order');
      rlm_core_sv.dpop(C_SDEBUG, 'RLM_BLKT_PO_MISMATCH');
    END IF;
    --
   WHEN NO_DATA_FOUND THEN
    --
    rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_warn_level,
           x_MessageName => 'RLM_BLANKET_UNDEFINED',
           x_InterfaceHeaderId => x_header_id,
           x_token1=>'BLANKET_NUM',
           x_value1=>x_Group_rec.setup_terms_rec.blanket_number,
           x_ValidationType => 'PURCHASE_ORDER');
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Blanket Order not defined');
      rlm_core_sv.dpop(C_SDEBUG, 'RLM_BLANKET_UNDEFINED');
    END IF;
    --
   WHEN OTHERS THEN
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'when others of DeriveBlanketPO');
      rlm_core_sv.dpop(C_SDEBUG, 'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
    END IF;
    --
    RAISE;
    --
END DeriveBlanketPO;


/*===========================================================================

  FUNCTION ValidateBlanket

===========================================================================*/
FUNCTION ValidateBlanket(x_Group_rec IN t_Group_rec,
			 x_Sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE)
RETURN BOOLEAN
IS
  --
  l_reqdate		DATE;
  h_reqdate		DATE;
  v_startdate		DATE;
  v_enddate		DATE;
  v_onholdflag    	VARCHAR2(1);
  e_BlktStartDate	EXCEPTION;
  e_BlktEndDate		EXCEPTION;
  e_BlktOnHold		EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG, 'ValidateBlanket');
    rlm_core_sv.dlog(C_DEBUG, 'Header_id', x_Sched_rec.header_id);
    rlm_core_sv.dlog(C_DEBUG, 'Schedule source', x_Sched_rec.schedule_source);
    rlm_core_sv.dlog(C_DEBUG, 'Schedule Type', x_Sched_rec.schedule_type);
  END IF;
  --
  IF x_Sched_rec.schedule_type <> 'SEQUENCED' THEN
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Non-sequenced schedule');
    rlm_core_sv.dlog(C_DEBUG, 'Schedule Item Number', x_Group_rec.schedule_item_num);
   END IF;
   --
   SELECT MIN(start_date_time), MAX(start_date_time)
   INTO l_reqdate, h_reqdate
   FROM rlm_interface_lines
   WHERE header_id = x_Sched_rec.header_id AND
   schedule_item_num = x_Group_rec.schedule_item_num AND
   item_detail_type IN (k_FIRM, k_FORECAST, k_PAST_DUE_FIRM);
   --
  ELSE
   --
   IF x_Sched_rec.schedule_source <> 'MANUAL' THEN
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'EDI Sequenced Schedule');
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.cust_ship_from_org_ext', x_Group_rec.cust_ship_from_org_ext);
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.cust_ship_to_ext', x_Group_rec.cust_ship_to_ext);
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.customer_item_ext', x_Group_rec.customer_item_ext);
    END IF;
    --
    SELECT MIN(start_date_time), MAX(start_date_time)
    INTO l_reqdate, h_reqdate
    FROM rlm_interface_lines
    WHERE header_id = x_Sched_rec.header_id AND
    cust_ship_from_org_ext = x_Group_rec.cust_ship_from_org_ext AND
    cust_ship_to_ext = x_Group_rec.cust_ship_to_ext AND
    customer_item_ext = x_Group_rec.customer_item_ext AND
    item_detail_type IN (k_FIRM, k_FORECAST, k_PAST_DUE_FIRM);
    --
   ELSE
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Manual Sequenced Schedule');
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.ship_from_org_id', x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.ship_to_address_id', x_Group_rec.ship_to_address_id);
     rlm_core_sv.dlog(C_DEBUG, 'x_Group_rec.customer_item_id', x_Group_rec.customer_item_id);
    END IF;
    --
    SELECT MIN(start_date_time), MAX(start_date_time)
    INTO l_reqdate, h_reqdate
    FROM rlm_interface_lines
    WHERE header_id = x_Sched_rec.header_id AND
    ship_from_org_id = x_Group_rec.ship_from_org_id AND
    ship_to_address_id = x_Group_rec.ship_to_address_id AND
    customer_item_id = x_Group_rec.customer_item_id AND
    item_detail_type IN (k_FIRM, k_FORECAST, k_PAST_DUE_FIRM);
    --
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Lowest request date in current group',  l_reqdate);
    rlm_core_sv.dlog(C_DEBUG, 'Highest request date in current group', h_reqdate);
  END IF;
  --
  SELECT start_date_active, end_date_active, on_hold_flag
  INTO v_startdate, v_enddate, v_onholdflag
  FROM oe_blanket_headers_ext
  WHERE order_number = x_Group_rec.setup_terms_rec.blanket_number;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Blanket Number',x_Group_rec.setup_terms_rec.blanket_number);
    rlm_core_sv.dlog(C_DEBUG, 'Blanket Effectivity Start Date', v_startdate);
    rlm_core_sv.dlog(C_DEBUG, 'Blanket Effectivity End Date', v_enddate);
    rlm_core_sv.dlog(C_DEBUG, 'On Hold Flag', v_onholdflag);
  END IF;
  --
  IF v_onholdflag = 'Y' THEN
   --
   RAISE e_BlktOnHold;
   --
  END IF;
  --
  IF (l_reqdate < v_startdate) THEN
   --
   RAISE e_BlktStartDate;
   --
  END IF;
  --
  IF (v_enddate is NOT NULL)  THEN
   --
   IF (h_reqdate > v_enddate) THEN
    --
    RAISE e_BlktEndDate;
    --
   END IF;
   --
  END IF;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG, 'TRUE');
  END IF;
  --
  RETURN TRUE;
  --
  EXCEPTION
   --
   WHEN e_BlktOnHold THEN
    --
    rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_error_level,
           x_MessageName => 'RLM_BLANKET_ON_HOLD',
           x_InterfaceHeaderId => x_Sched_rec.header_id,
           x_InterfaceLineId => NULL,
	   x_token1=>'BLANKET_NUMBER',
	   x_value1=>x_Group_rec.setup_terms_rec.blanket_number);
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Blanket Order on hold');
       rlm_core_sv.dpop(C_SDEBUG, 'FALSE');
     END IF;
     --
     RETURN FALSE;
     --
   WHEN e_BlktStartDate THEN
    --
    rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_error_level,
           x_MessageName => 'RLM_STARTDATE_BEFORE_BLANKET',
           x_InterfaceHeaderId => x_Sched_rec.header_id,
           x_InterfaceLineId => NULL,
           x_token1=>'REQDATE',
           x_value1=>to_char(l_reqdate, 'MM/DD/YYYY HH24:MI:SS'),
           x_token2=>'BLKT_START_DATE',
           x_value2=>to_char(v_startdate, 'MM/DD/YYYY HH24:MI:SS'),
	   x_token3=>'BLANKET_NUM',
	   x_value3=>x_Group_rec.setup_terms_rec.blanket_number);
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Lowest request date before effectivity start');
       rlm_core_sv.dpop(C_SDEBUG, 'FALSE');
     END IF;
     --
     RETURN FALSE;
     --
   WHEN e_BlktEndDate   THEN
    --
    rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_error_level,
           x_MessageName => 'RLM_ENDDATE_AFTER_BLANKET',
           x_InterfaceHeaderId => x_Sched_rec.header_id,
           x_InterfaceLineId => NULL,
           x_token1=>'REQDATE',
           x_value1=>to_char(h_reqdate, 'MM/DD/YYYY HH24:MI:SS'),
           x_token2=>'BLKT_END_DATE',
           x_value2=>to_char(v_enddate, 'MM/DD/YYYY HH24:MI:SS'),
	   x_token3=>'BLANKET_NUM',
	   x_value3=>x_Group_rec.setup_terms_rec.blanket_number);
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Highest request date after effectivity start');
       rlm_core_sv.dpop(C_SDEBUG, 'FALSE');
     END IF;
     --
     RETURN FALSE;
     --
   WHEN NO_DATA_FOUND THEN
    --
    rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_warn_level,
           x_MessageName => 'RLM_BLANKET_UNDEFINED',
           x_InterfaceHeaderId => x_Sched_rec.header_id,
           x_token1=>'BLANKET_NUM',
           x_value1=>x_Group_rec.setup_terms_rec.blanket_number);
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'Blanket Order not defined');
      rlm_core_sv.dpop(C_SDEBUG, 'FALSE');
    END IF;
    --
    RETURN FALSE;
    --
 WHEN OTHERS THEN
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'When others of ValidateBlanket');
     rlm_core_sv.dlog(C_DEBUG, 'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
     rlm_core_sv.dpop(C_SDEBUG, 'FALSE');
   END IF;
   --
   RETURN FALSE;

END ValidateBlanket;

-- End of package
END RLM_VALIDATEDEMAND_SV;

/
