--------------------------------------------------------
--  DDL for Package Body RLM_AD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_AD_SV" as
/*$Header: RLMDPARB.pls 120.1 2005/07/17 18:28:56 rlanka noship $  */
/*=======================  RLM_AD_SV  ============================*/
--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
/*===========================================================================

  FUNCTION NAME:        Archive_Headers

===========================================================================*/
FUNCTION Archive_Headers (x_InterfaceHeaderId IN NUMBER,
			  x_RlmScheduleID OUT NOCOPY NUMBER) RETURN BOOLEAN

IS
--
v_RlmScheduleId         number;
x_progress              number;
e_NullOrgIDHdr          EXCEPTION;
v_HdrRec                RLM_INTERFACE_HEADERS_ALL%ROWTYPE;
--
CURSOR c_Hdr IS
SELECT *
FROM  rlm_interface_headers_all
WHERE header_id = x_InterfaceHeaderId
AND   process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                         rlm_core_sv.k_PS_PARTIAL_PROCESSED);
--
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'Archive_Headers');
     rlm_core_sv.dlog(C_SDEBUG, 'x_InterfaceHeaderId ',x_InterfaceHeaderId);
  END IF;
  --
  SELECT rlm_schedule_headers_s.nextval
  INTO  v_RlmScheduleId
  FROM  dual;
  --
  x_progress :='020';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_SDEBUG, 'v_RlmScheduleId ',v_RlmScheduleId);
  END IF;
  --
  x_RlmScheduleId := v_RlmScheduleId;
  --
  UPDATE rlm_interface_headers_all
  SET schedule_header_id = v_RlmScheduleId
  WHERE header_id = x_InterfaceHeaderId
  AND   process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                           rlm_core_sv.k_PS_PARTIAL_PROCESSED);
  --
  x_progress :='030';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated ',SQL%ROWCOUNT);
  END IF;
  --
  OPEN c_Hdr;
  FETCH c_Hdr INTO v_HdrRec;
  CLOSE c_Hdr;
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(C_DEBUG, 'Org ID at header level', v_HdrRec.org_id);
  END IF;
  --
  -- Check if ORG_ID is null.  Ideally, such a condition should not arise.
  -- This is added only as a fail-safe mechanism.
  --
  IF (v_HdrRec.ORG_ID IS NULL) THEN
    RAISE e_NullOrgIdHdr;
  END IF;
  --
  INSERT INTO rlm_schedule_headers_all (
        HEADER_ID,
        INTERFACE_HEADER_ID,
        CUSTOMER_ID,
        SCHEDULE_TYPE,
        SCHED_HORIZON_END_DATE,
        SCHED_HORIZON_START_DATE,
        SCHEDULE_SOURCE,
        SCHEDULE_PURPOSE,
        SCHEDULE_REFERENCE_NUM,
        CUST_ADDRESS_1_EXT,
        CUST_ADDRESS_2_EXT,
        CUST_ADDRESS_3_EXT,
        CUST_ADDRESS_4_EXT,
        CUST_CITY_EXT,
        CUST_COUNTRY_EXT,
        CUST_COUNTY_EXT,
        CUSTOMER_EXT,
        CUST_NAME_EXT,
        CUST_POSTAL_CD_EXT,
        CUST_PROVINCE_EXT,
        CUST_STATE_EXT,
        ECE_TP_LOCATION_CODE_EXT,
        ECE_TP_TRANSLATOR_CODE,
        EDI_CONTROL_NUM_1,
        EDI_CONTROL_NUM_2,
        EDI_CONTROL_NUM_3,
        EDI_TEST_INDICATOR,
        process_status,
        TP_ATTRIBUTE_CATEGORY,
        TP_ATTRIBUTE1,
        TP_ATTRIBUTE2,
        TP_ATTRIBUTE3,
        TP_ATTRIBUTE4,
        TP_ATTRIBUTE5,
        TP_ATTRIBUTE6,
        TP_ATTRIBUTE7,
        TP_ATTRIBUTE8,
        TP_ATTRIBUTE9,
        TP_ATTRIBUTE10,
        TP_ATTRIBUTE11,
        TP_ATTRIBUTE12,
        TP_ATTRIBUTE13,
        TP_ATTRIBUTE14,
        TP_ATTRIBUTE15,
        HEADER_CONTACT_CODE_1,
        HEADER_CONTACT_CODE_2,
        HEADER_CONTACT_VALUE_1,
        HEADER_CONTACT_VALUE_2,
        HEADER_NOTE_TEXT,
        HEADER_REF_CODE_1,
        HEADER_REF_CODE_2,
        HEADER_REF_CODE_3,
        HEADER_REF_VALUE_1,
        HEADER_REF_VALUE_2,
        HEADER_REF_VALUE_3,
        SCHEDULE_TYPE_EXT,
        SCHED_GENERATION_DATE,
        SCHEDULE_PURPOSE_EXT,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        ORG_ID)
  VALUES
      (
        v_hdrRec.SCHEDULE_HEADER_ID,
        v_hdrRec.HEADER_ID,
        v_hdrRec.CUSTOMER_ID,
        v_hdrRec.SCHEDULE_TYPE,
        v_hdrRec.SCHED_HORIZON_END_DATE,
        v_hdrRec.SCHED_HORIZON_START_DATE,
        v_hdrRec.SCHEDULE_SOURCE,
        v_hdrRec.SCHEDULE_PURPOSE,
        v_hdrRec.SCHEDULE_REFERENCE_NUM,
        v_hdrRec.CUST_ADDRESS_1_EXT,
        v_hdrRec.CUST_ADDRESS_2_EXT,
        v_hdrRec.CUST_ADDRESS_3_EXT,
        v_hdrRec.CUST_ADDRESS_4_EXT,
        v_hdrRec.CUST_CITY_EXT,
        v_hdrRec.CUST_COUNTRY_EXT,
        v_hdrRec.CUST_COUNTY_EXT,
        v_hdrRec.CUSTOMER_EXT,
        v_hdrRec.CUST_NAME_EXT,
        v_hdrRec.CUST_POSTAL_CD_EXT,
        v_hdrRec.CUST_PROVINCE_EXT,
        v_hdrRec.CUST_STATE_EXT,
        v_hdrRec.ECE_TP_LOCATION_CODE_EXT,
        v_hdrRec.ECE_TP_TRANSLATOR_CODE,
        v_hdrRec.EDI_CONTROL_NUM_1,
        v_hdrRec.EDI_CONTROL_NUM_2,
        v_hdrRec.EDI_CONTROL_NUM_3,
        v_hdrRec.EDI_TEST_INDICATOR,
        v_hdrRec.PROCESS_STATUS,
        v_hdrRec.TP_ATTRIBUTE_CATEGORY,
        v_hdrRec.TP_ATTRIBUTE1,
        v_hdrRec.TP_ATTRIBUTE2,
        v_hdrRec.TP_ATTRIBUTE3,
        v_hdrRec.TP_ATTRIBUTE4,
        v_hdrRec.TP_ATTRIBUTE5,
        v_hdrRec.TP_ATTRIBUTE6,
        v_hdrRec.TP_ATTRIBUTE7,
        v_hdrRec.TP_ATTRIBUTE8,
        v_hdrRec.TP_ATTRIBUTE9,
        v_hdrRec.TP_ATTRIBUTE10,
        v_hdrRec.TP_ATTRIBUTE11,
        v_hdrRec.TP_ATTRIBUTE12,
        v_hdrRec.TP_ATTRIBUTE13,
        v_hdrRec.TP_ATTRIBUTE14,
        v_hdrRec.TP_ATTRIBUTE15,
        v_hdrRec.HEADER_CONTACT_CODE_1,
        v_hdrRec.HEADER_CONTACT_CODE_2,
        v_hdrRec.HEADER_CONTACT_VALUE_1,
        v_hdrRec.HEADER_CONTACT_VALUE_2,
        v_hdrRec.HEADER_NOTE_TEXT,
        v_hdrRec.HEADER_REF_CODE_1,
        v_hdrRec.HEADER_REF_CODE_2,
        v_hdrRec.HEADER_REF_CODE_3,
        v_hdrRec.HEADER_REF_VALUE_1,
        v_hdrRec.HEADER_REF_VALUE_2,
        v_hdrRec.HEADER_REF_VALUE_3,
        v_hdrRec.SCHEDULE_TYPE_EXT,
        v_hdrRec.SCHED_GENERATION_DATE,
        v_hdrRec.SCHEDULE_PURPOSE_EXT,
        v_hdrRec.LAST_UPDATE_DATE,
        v_hdrRec.LAST_UPDATED_BY,
        v_hdrRec.CREATION_DATE,
        v_hdrRec.CREATED_BY,
        v_hdrRec.ATTRIBUTE_CATEGORY,
        v_hdrRec.ATTRIBUTE1,
        v_hdrRec.ATTRIBUTE2,
        v_hdrRec.ATTRIBUTE3,
        v_hdrRec.ATTRIBUTE4,
        v_hdrRec.ATTRIBUTE5,
        v_hdrRec.ATTRIBUTE6,
        v_hdrRec.ATTRIBUTE7,
        v_hdrRec.ATTRIBUTE8,
        v_hdrRec.ATTRIBUTE9,
        v_hdrRec.ATTRIBUTE10,
        v_hdrRec.ATTRIBUTE11,
        v_hdrRec.ATTRIBUTE12,
        v_hdrRec.ATTRIBUTE13,
        v_hdrRec.ATTRIBUTE14,
        v_hdrRec.ATTRIBUTE15,
        v_hdrRec.LAST_UPDATE_LOGIN,
        v_hdrRec.REQUEST_ID,
        v_hdrRec.PROGRAM_APPLICATION_ID,
        v_hdrRec.PROGRAM_ID,
        v_hdrRec.PROGRAM_UPDATE_DATE,
        v_hdrRec.ORG_ID
    );
  --
  x_progress :='040';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_SDEBUG, 'No of Records Inserted ',SQL%ROWCOUNT);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  return TRUE;
  --
EXCEPTION
    --
    WHEN e_NullOrgIDHdr THEN
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Null Org ID found at header level');
      END IF;
      --
      rlm_message_sv.app_error(
         x_ExceptionLevel => rlm_message_sv.k_error_level,
         x_MessageName => 'RLM_OU_CONTEXT_NOT_SET',
         x_InterfaceHeaderId => x_InterfaceHeaderId,
         x_ScheduleHeaderId  => x_RLMScheduleID);
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RETURN FALSE;
      --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error ('rlm_archive_demand_sv.Archive_Headers',
                               x_progress);
      IF (l_debug <> -1) THEN
       --
       rlm_core_sv.dlog(C_DEBUG,'x_progress',x_progress);
       rlm_core_sv.dlog(C_DEBUG,'Error',sqlerrm);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
       --
      END IF;
      --
      raise;
  return FALSE;
END;

/*===========================================================================

  FUNCTION NAME:        Archive_Lines

===========================================================================*/
FUNCTION Archive_Lines (x_InterfaceHeaderId        IN  NUMBER,
                        x_RlmScheduleId  IN NUMBER)
RETURN BOOLEAN
IS
--
dup_rec         number;
--
CURSOR c_cur IS
SELECT line_id interface_line_id,
       header_id interface_header_id,
       schedule_line_id,
       item_detail_type,
       order_header_id,
       blanket_number,
       org_id
FROM   rlm_interface_lines_all
WHERE  header_id = x_InterfaceHeaderId
AND    process_status = rlm_core_sv.k_PS_AVAILABLE ;
--
v_count NUMBER := 0;
--
x_progress         number;
e_NullOrgID        EXCEPTION;
--
BEGIN
  --
  IF (l_debug <> -1) THEN
   --
   rlm_core_sv.dpush(C_SDEBUG, 'Archive_Lines');
   rlm_core_sv.dlog(C_SDEBUG, 'x_InterfaceHeaderId ',x_InterfaceHeaderId);
   rlm_core_sv.dlog(C_SDEBUG, 'x_RlmScheduleId ',x_RlmScheduleId);
   --
  END IF;
  --
  FOR c_rec IN c_cur LOOP
     --
     -- Raise error if ORG_ID is null.  Ideally, such a condition should not
     -- arise. This is added only as a fail safe mechanism.
     --
     IF c_rec.org_id IS NULL THEN
      RAISE e_NullOrgID;
     END IF;
     --
     UPDATE rlm_interface_lines_all
     SET schedule_line_id = rlm_schedule_lines_s.nextval
     WHERE header_id = c_rec.interface_header_id
     AND  line_id = c_rec.interface_line_id
     AND  schedule_line_id IS NULL
     AND  process_status = rlm_core_sv.k_PS_AVAILABLE ;
     --
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated ',SQL%ROWCOUNT);
     END IF;
     --
     v_count := v_count + 1;
     --
     x_progress :='020';
     --
     IF SQL%ROWCOUNT <> 0 THEN
       --
       INSERT INTO rlm_schedule_lines_all(
         LINE_ID,
         CUSTOMER_ITEM_EXT,
         CUSTOMER_ITEM_ID,
         DATE_TYPE_CODE,
         INVENTORY_ITEM_ID,
         ITEM_DETAIL_SUBTYPE,
         ITEM_DETAIL_TYPE,
         INTERFACE_LINE_ID,
         QTY_TYPE_CODE,
         HEADER_ID,
         START_DATE_TIME,
         UOM_CODE,
         ATO_DATA_TYPE,
         BILL_TO_ADDRESS_1_EXT,
         BILL_TO_ADDRESS_2_EXT,
         BILL_TO_ADDRESS_3_EXT,
         BILL_TO_ADDRESS_4_EXT,
         BILL_TO_ADDRESS_ID,
         BILL_TO_CITY_EXT,
         BILL_TO_COUNTRY_EXT,
         BILL_TO_COUNTY_EXT,
         BILL_TO_NAME_EXT,
         BILL_TO_POSTAL_CD_EXT,
         BILL_TO_PROVINCE_EXT,
         BILL_TO_SITE_USE_ID,
         BILL_TO_STATE_EXT,
         CARRIER_ID_CODE_EXT,
         CARRIER_QUALIFIER_EXT,
         COMMODITY_EXT,
         COUNTRY_OF_ORIGIN_EXT,
         CUST_ASSEMBLY_EXT,
         CUST_ASSIGNED_ID_EXT,
         CUST_BILL_TO_EXT,
         CUST_CONTRACT_NUM_EXT,
         CUSTOMER_DOCK_CODE,
         CUST_INTRMD_SHIP_TO_EXT,
         CUST_ITEM_PRICE_EXT,
         CUST_ITEM_PRICE_UOM_EXT,
         CUSTOMER_ITEM_REVISION,
         CUSTOMER_JOB,
         CUST_MANUFACTURER_EXT,
         CUST_MODEL_NUMBER_EXT,
         CUST_MODEL_SERIAL_NUMBER,
         CUST_ORDER_NUM_EXT,
         CUST_PROCESS_NUM_EXT,
         CUST_PRODUCTION_LINE,
         CUST_SET_NUM_EXT,
         CUST_SHIP_FROM_ORG_EXT,
         CUST_SHIP_TO_EXT,
         CUST_UOM_EXT,
         END_DATE_TIME,
         EQUIPMENT_CODE_EXT,
         EQUIPMENT_NUMBER_EXT,
         HANDLING_CODE_EXT,
         HAZARD_CODE_EXT,
         HAZARD_CODE_QUAL_EXT,
         HAZARD_DESCRIPTION_EXT,
         IMPORT_LICENSE_DATE_EXT,
         IMPORT_LICENSE_EXT,
         INDUSTRY_ATTRIBUTE1,
         INDUSTRY_ATTRIBUTE10,
         INDUSTRY_ATTRIBUTE11,
         INDUSTRY_ATTRIBUTE12,
         INDUSTRY_ATTRIBUTE13,
         INDUSTRY_ATTRIBUTE14,
         INDUSTRY_ATTRIBUTE15,
         INDUSTRY_ATTRIBUTE2,
         INDUSTRY_ATTRIBUTE3,
         INDUSTRY_ATTRIBUTE4,
         INDUSTRY_ATTRIBUTE5,
         INDUSTRY_ATTRIBUTE6,
         INDUSTRY_ATTRIBUTE7,
         INDUSTRY_ATTRIBUTE8,
         INDUSTRY_ATTRIBUTE9,
         INDUSTRY_CONTEXT,
         INTRMD_SHIP_TO_ID,
         INTRMD_ST_ADDRESS_1_EXT,
         INTRMD_ST_ADDRESS_2_EXT,
         INTRMD_ST_ADDRESS_3_EXT,
         INTRMD_ST_ADDRESS_4_EXT,
         INTRMD_ST_CITY_EXT,
         INTRMD_ST_COUNTRY_EXT,
         INTRMD_ST_COUNTY_EXT,
         INTRMD_ST_NAME_EXT,
         INTRMD_ST_POSTAL_CD_EXT,
         INTRMD_ST_PROVINCE_EXT,
         INTRMD_ST_STATE_EXT,
         ITEM_CONTACT_CODE_1,
         ITEM_CONTACT_CODE_2,
         ITEM_CONTACT_VALUE_1,
         ITEM_CONTACT_VALUE_2,
         ITEM_DESCRIPTION_EXT,
         ITEM_DETAIL_QUANTITY,
         ITEM_DETAIL_REF_CODE_1,
         ITEM_DETAIL_REF_CODE_2,
         ITEM_DETAIL_REF_CODE_3,
         ITEM_DETAIL_REF_VALUE_1,
         ITEM_DETAIL_REF_VALUE_2,
         ITEM_DETAIL_REF_VALUE_3,
         ITEM_ENG_CNG_LVL_EXT,
         ITEM_MEASUREMENTS_EXT,
         ITEM_NOTE_TEXT,
         ITEM_REF_CODE_1,
         ITEM_REF_CODE_2,
         ITEM_REF_CODE_3,
         ITEM_REF_VALUE_1,
         ITEM_REF_VALUE_2,
         ITEM_REF_VALUE_3,
         ITEM_RELEASE_STATUS_EXT,
         LADING_QUANTITY_EXT,
         LETTER_CREDIT_EXPDT_EXT,
         LETTER_CREDIT_EXT,
         TP_ATTRIBUTE_CATEGORY,
         TP_ATTRIBUTE1,
         TP_ATTRIBUTE2,
         TP_ATTRIBUTE3,
         TP_ATTRIBUTE4,
         TP_ATTRIBUTE5,
         TP_ATTRIBUTE6,
         TP_ATTRIBUTE7,
         TP_ATTRIBUTE8,
         TP_ATTRIBUTE9,
         TP_ATTRIBUTE10,
         TP_ATTRIBUTE11,
         TP_ATTRIBUTE12,
         TP_ATTRIBUTE13,
         TP_ATTRIBUTE14,
         TP_ATTRIBUTE15,
         LINE_REFERENCE,
         LINK_TO_LINE_REF,
         OTHER_NAME_CODE_1,
         OTHER_NAME_CODE_2,
         OTHER_NAME_VALUE_1,
         OTHER_NAME_VALUE_2,
         PACK_SIZE_EXT,
         PACK_UNITS_PER_PACK_EXT,
         PACK_UOM_CODE_EXT,
         PACKAGING_CODE_EXT,
         PRIMARY_QUANTITY,
         PRIMARY_UOM_CODE,
         PRIME_CONTRCTR_PART_EXT,
         /* line process status */
         PROCESS_STATUS,
         CUST_PO_RELEASE_NUM,
         CUST_PO_DATE,
         CUST_PO_LINE_NUM,
         CUST_PO_NUMBER,
         RETURN_CONTAINER_EXT,
         ROUTING_DESC_EXT,
         ROUTING_SEQ_CODE_EXT,
         SCHEDULE_ITEM_NUM,
         SHIP_DEL_PATTERN_EXT,
         SHIP_DEL_TIME_CODE_EXT,
         SHIP_FROM_ADDRESS_1_EXT,
         SHIP_FROM_ADDRESS_2_EXT,
         SHIP_FROM_ADDRESS_3_EXT,
         SHIP_FROM_ADDRESS_4_EXT,
         SHIP_FROM_CITY_EXT,
         SHIP_FROM_COUNTRY_EXT,
         SHIP_FROM_COUNTY_EXT,
         SHIP_FROM_NAME_EXT,
         SHIP_FROM_ORG_ID,
         SHIP_FROM_POSTAL_CD_EXT,
         SHIP_FROM_PROVINCE_EXT,
         SHIP_FROM_STATE_EXT,
         SHIP_LABEL_INFO_LINE_1,
         SHIP_LABEL_INFO_LINE_10,
         SHIP_LABEL_INFO_LINE_2,
         SHIP_LABEL_INFO_LINE_3,
         SHIP_LABEL_INFO_LINE_4,
         SHIP_LABEL_INFO_LINE_5,
         SHIP_LABEL_INFO_LINE_6,
         SHIP_LABEL_INFO_LINE_7,
         SHIP_LABEL_INFO_LINE_8,
         SHIP_LABEL_INFO_LINE_9,
         SHIP_TO_ADDRESS_1_EXT,
         SHIP_TO_ADDRESS_2_EXT,
         SHIP_TO_ADDRESS_3_EXT,
         SHIP_TO_ADDRESS_4_EXT,
         SHIP_TO_ADDRESS_ID,
         SHIP_TO_CITY_EXT,
         SHIP_TO_COUNTRY_EXT,
         SHIP_TO_COUNTY_EXT,
         SHIP_TO_NAME_EXT,
         SHIP_TO_POSTAL_CD_EXT,
         SHIP_TO_PROVINCE_EXT,
         SHIP_TO_SITE_USE_ID,
         SHIP_TO_STATE_EXT,
         SUBLINE_ASSIGNED_ID_EXT,
         SUBLINE_CONFIG_CODE_EXT,
         SUBLINE_CUST_ITEM_EXT,
         SUBLINE_CUST_ITEM_ID,
         SUBLINE_MODEL_NUM_EXT,
         SUBLINE_QUANTITY,
         SUBLINE_UOM_CODE,
         SUPPLIER_ITEM_EXT,
         TRANSIT_TIME_EXT,
         TRANSIT_TIME_QUAL_EXT,
         CUST_PRODUCTION_SEQ_NUM,
         TRANSPORT_LOC_QUAL_EXT,
         TRANSPORT_LOCATION_EXT,
         TRANSPORT_METHOD_EXT,
         WEIGHT_EXT,
         WEIGHT_QUALIFIER_EXT,
         WEIGHT_UOM_EXT,
         ITEM_DETAIL_SUBTYPE_EXT,
         ITEM_DETAIL_TYPE_EXT,
         QTY_TYPE_CODE_EXT,
         DATE_TYPE_CODE_EXT,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         LINE_NUMBER,
         INTMED_SHIP_TO_ORG_ID,
         SHIP_TO_ORG_ID,
         DELIVER_TO_ORG_ID,
         INVOICE_TO_ORG_ID,
         ORDER_HEADER_ID,
         SHIP_DEL_RULE_NAME,
	 BLANKET_NUMBER,
         ORG_ID,
         SHIP_TO_CUSTOMER_ID)
    SELECT
         SCHEDULE_LINE_ID,
         CUSTOMER_ITEM_EXT,
         CUSTOMER_ITEM_ID,
         DATE_TYPE_CODE,
         INVENTORY_ITEM_ID,
         ITEM_DETAIL_SUBTYPE,
         ITEM_DETAIL_TYPE,
         LINE_ID,
         QTY_TYPE_CODE,
         x_RlmScheduleId,
         START_DATE_TIME,
         UOM_CODE,
         ATO_DATA_TYPE,
         BILL_TO_ADDRESS_1_EXT,
         BILL_TO_ADDRESS_2_EXT,
         BILL_TO_ADDRESS_3_EXT,
         BILL_TO_ADDRESS_4_EXT,
         BILL_TO_ADDRESS_ID,
         BILL_TO_CITY_EXT,
         BILL_TO_COUNTRY_EXT,
         BILL_TO_COUNTY_EXT,
         BILL_TO_NAME_EXT,
         BILL_TO_POSTAL_CD_EXT,
         BILL_TO_PROVINCE_EXT,
         BILL_TO_SITE_USE_ID,
         BILL_TO_STATE_EXT,
         CARRIER_ID_CODE_EXT,
         CARRIER_QUALIFIER_EXT,
         COMMODITY_EXT,
         COUNTRY_OF_ORIGIN_EXT,
         CUST_ASSEMBLY_EXT,
         CUST_ASSIGNED_ID_EXT,
         CUST_BILL_TO_EXT,
         CUST_CONTRACT_NUM_EXT,
         CUSTOMER_DOCK_CODE,
         CUST_INTRMD_SHIP_TO_EXT,
         CUST_ITEM_PRICE_EXT,
         CUST_ITEM_PRICE_UOM_EXT,
         CUSTOMER_ITEM_REVISION,
         CUSTOMER_JOB,
         CUST_MANUFACTURER_EXT,
         CUST_MODEL_NUMBER_EXT,
         CUST_MODEL_SERIAL_NUMBER,
         CUST_ORDER_NUM_EXT,
         CUST_PROCESS_NUM_EXT,
         CUST_PRODUCTION_LINE,
         CUST_SET_NUM_EXT,
         CUST_SHIP_FROM_ORG_EXT,
         CUST_SHIP_TO_EXT,
         CUST_UOM_EXT,
         END_DATE_TIME,
         EQUIPMENT_CODE_EXT,
         EQUIPMENT_NUMBER_EXT,
         HANDLING_CODE_EXT,
         HAZARD_CODE_EXT,
         HAZARD_CODE_QUAL_EXT,
         HAZARD_DESCRIPTION_EXT,
         IMPORT_LICENSE_DATE_EXT,
         IMPORT_LICENSE_EXT,
         INDUSTRY_ATTRIBUTE1,
         INDUSTRY_ATTRIBUTE10,
         INDUSTRY_ATTRIBUTE11,
         INDUSTRY_ATTRIBUTE12,
         INDUSTRY_ATTRIBUTE13,
         INDUSTRY_ATTRIBUTE14,
         INDUSTRY_ATTRIBUTE15,
         INDUSTRY_ATTRIBUTE2,
         INDUSTRY_ATTRIBUTE3,
         INDUSTRY_ATTRIBUTE4,
         INDUSTRY_ATTRIBUTE5,
         INDUSTRY_ATTRIBUTE6,
         INDUSTRY_ATTRIBUTE7,
         INDUSTRY_ATTRIBUTE8,
         INDUSTRY_ATTRIBUTE9,
         INDUSTRY_CONTEXT,
         INTRMD_SHIP_TO_ID,
         INTRMD_ST_ADDRESS_1_EXT,
         INTRMD_ST_ADDRESS_2_EXT,
         INTRMD_ST_ADDRESS_3_EXT,
         INTRMD_ST_ADDRESS_4_EXT,
         INTRMD_ST_CITY_EXT,
         INTRMD_ST_COUNTRY_EXT,
         INTRMD_ST_COUNTY_EXT,
         INTRMD_ST_NAME_EXT,
         INTRMD_ST_POSTAL_CD_EXT,
         INTRMD_ST_PROVINCE_EXT,
         INTRMD_ST_STATE_EXT,
         ITEM_CONTACT_CODE_1,
         ITEM_CONTACT_CODE_2,
         ITEM_CONTACT_VALUE_1,
         ITEM_CONTACT_VALUE_2,
         ITEM_DESCRIPTION_EXT,
         ITEM_DETAIL_QUANTITY,
         ITEM_DETAIL_REF_CODE_1,
         ITEM_DETAIL_REF_CODE_2,
         ITEM_DETAIL_REF_CODE_3,
         ITEM_DETAIL_REF_VALUE_1,
         ITEM_DETAIL_REF_VALUE_2,
         ITEM_DETAIL_REF_VALUE_3,
         ITEM_ENG_CNG_LVL_EXT,
         ITEM_MEASUREMENTS_EXT,
         ITEM_NOTE_TEXT,
         ITEM_REF_CODE_1,
         ITEM_REF_CODE_2,
         ITEM_REF_CODE_3,
         ITEM_REF_VALUE_1,
         ITEM_REF_VALUE_2,
         ITEM_REF_VALUE_3,
         ITEM_RELEASE_STATUS_EXT,
         LADING_QUANTITY_EXT,
         LETTER_CREDIT_EXPDT_EXT,
         LETTER_CREDIT_EXT,
         TP_ATTRIBUTE_CATEGORY,
         TP_ATTRIBUTE1,
         TP_ATTRIBUTE2,
         TP_ATTRIBUTE3,
         TP_ATTRIBUTE4,
         TP_ATTRIBUTE5,
         TP_ATTRIBUTE6,
         TP_ATTRIBUTE7,
         TP_ATTRIBUTE8,
         TP_ATTRIBUTE9,
         TP_ATTRIBUTE10,
         TP_ATTRIBUTE11,
         TP_ATTRIBUTE12,
         TP_ATTRIBUTE13,
         TP_ATTRIBUTE14,
         TP_ATTRIBUTE15,
         LINE_REFERENCE,
         LINK_TO_LINE_REF,
         OTHER_NAME_CODE_1,
         OTHER_NAME_CODE_2,
         OTHER_NAME_VALUE_1,
         OTHER_NAME_VALUE_2,
         PACK_SIZE_EXT,
         PACK_UNITS_PER_PACK_EXT,
         PACK_UOM_CODE_EXT,
         PACKAGING_CODE_EXT,
         PRIMARY_QUANTITY,
         PRIMARY_UOM_CODE,
         PRIME_CONTRCTR_PART_EXT,
         PROCESS_STATUS,
         CUST_PO_RELEASE_NUM,
         CUST_PO_DATE,
         CUST_PO_LINE_NUM,
         CUST_PO_NUMBER,
         RETURN_CONTAINER_EXT,
         ROUTING_DESC_EXT,
         ROUTING_SEQ_CODE_EXT,
         SCHEDULE_ITEM_NUM,
         SHIP_DEL_PATTERN_EXT,
         SHIP_DEL_TIME_CODE_EXT,
         SHIP_FROM_ADDRESS_1_EXT,
         SHIP_FROM_ADDRESS_2_EXT,
         SHIP_FROM_ADDRESS_3_EXT,
         SHIP_FROM_ADDRESS_4_EXT,
         SHIP_FROM_CITY_EXT,
         SHIP_FROM_COUNTRY_EXT,
         SHIP_FROM_COUNTY_EXT,
         SHIP_FROM_NAME_EXT,
         SHIP_FROM_ORG_ID,
         SHIP_FROM_POSTAL_CD_EXT,
         SHIP_FROM_PROVINCE_EXT,
         SHIP_FROM_STATE_EXT,
         SHIP_LABEL_INFO_LINE_1,
         SHIP_LABEL_INFO_LINE_10,
         SHIP_LABEL_INFO_LINE_2,
         SHIP_LABEL_INFO_LINE_3,
         SHIP_LABEL_INFO_LINE_4,
         SHIP_LABEL_INFO_LINE_5,
         SHIP_LABEL_INFO_LINE_6,
         SHIP_LABEL_INFO_LINE_7,
         SHIP_LABEL_INFO_LINE_8,
         SHIP_LABEL_INFO_LINE_9,
         SHIP_TO_ADDRESS_1_EXT,
         SHIP_TO_ADDRESS_2_EXT,
         SHIP_TO_ADDRESS_3_EXT,
         SHIP_TO_ADDRESS_4_EXT,
         SHIP_TO_ADDRESS_ID,
         SHIP_TO_CITY_EXT,
         SHIP_TO_COUNTRY_EXT,
         SHIP_TO_COUNTY_EXT,
         SHIP_TO_NAME_EXT,
         SHIP_TO_POSTAL_CD_EXT,
         SHIP_TO_PROVINCE_EXT,
         SHIP_TO_SITE_USE_ID,
         SHIP_TO_STATE_EXT,
         SUBLINE_ASSIGNED_ID_EXT,
         SUBLINE_CONFIG_CODE_EXT,
         SUBLINE_CUST_ITEM_EXT,
         SUBLINE_CUST_ITEM_ID,
         SUBLINE_MODEL_NUM_EXT,
         SUBLINE_QUANTITY,
         SUBLINE_UOM_CODE,
         SUPPLIER_ITEM_EXT,
         TRANSIT_TIME_EXT,
         TRANSIT_TIME_QUAL_EXT,
         CUST_PRODUCTION_SEQ_NUM,
         TRANSPORT_LOC_QUAL_EXT,
         TRANSPORT_LOCATION_EXT,
         TRANSPORT_METHOD_EXT,
         WEIGHT_EXT,
         WEIGHT_QUALIFIER_EXT,
         WEIGHT_UOM_EXT,
         ITEM_DETAIL_SUBTYPE_EXT,
         ITEM_DETAIL_TYPE_EXT,
         QTY_TYPE_CODE_EXT,
         DATE_TYPE_CODE_EXT,
         sysdate,
         LAST_UPDATED_BY,
         sysdate,
         CREATED_BY,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         LINE_NUMBER,
         INTMED_SHIP_TO_ORG_ID,
         SHIP_TO_ORG_ID,
         DELIVER_TO_ORG_ID,
         INVOICE_TO_ORG_ID,
         ORDER_HEADER_ID,
         SHIP_DEL_RULE_NAME,
         BLANKET_NUMBER,
         ORG_ID,
         SHIP_TO_CUSTOMER_ID
    FROM rlm_interface_lines_all
    WHERE header_id = x_InterfaceHeaderId
    AND  line_id = c_rec.interface_line_id
    AND  process_status = rlm_core_sv.k_PS_AVAILABLE ;
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_SDEBUG, 'No of Records Inserted ',SQL%ROWCOUNT);
    END IF;
    --
  ELSE
    --
    UPDATE rlm_schedule_lines_all
    SET request_id         = rlm_message_sv.g_conc_req_id,
        interface_line_id  = c_rec.interface_line_id,
        order_header_id    = c_rec.order_header_id,
        blanket_number     = c_rec.blanket_number,
        last_update_date   = sysdate,
        last_updated_by    = fnd_global.user_id
    WHERE  header_id = x_RLMScheduleID
    AND    line_id  = c_rec.schedule_line_id;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated to new request id ', SQL%ROWCOUNT);
    END IF;
    --
  END IF;

  /***  Deleting Authorizations and  Test transactions ****/
  /***  Item Detail Type =3 means it is an Authorization ****/
  /***  Item Detail Type =5 means it is Test Transaction ****/
    --
    IF c_rec.item_detail_type IN ('3','5') THEN
      --
      UPDATE rlm_interface_lines_all
      SET process_status = rlm_core_sv.k_PS_PROCESSED
      WHERE  header_id = x_InterfaceHeaderId
      AND    line_id = c_rec.interface_line_id
      AND    process_status = rlm_core_sv.k_PS_AVAILABLE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated in interface for cum auth '
                                 ,SQL%ROWCOUNT);
      END IF;

      --
      UPDATE rlm_schedule_lines
      SET process_status = rlm_core_sv.k_PS_PROCESSED
      WHERE  header_id = x_RLMScheduleID
      AND    interface_line_id = c_rec.interface_line_id
      AND    process_status = rlm_core_sv.k_PS_AVAILABLE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated in schedule for auth
                                cum and test',SQL%ROWCOUNT);
      END IF;
      --
    END IF;
    --
    x_progress :='030';
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_SDEBUG, 'No of Records Scanned ',v_count);
  END IF;
  --
  x_progress :='040';
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  return TRUE;
  --
EXCEPTION
    --
    WHEN e_NullOrgID THEN
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Null Org ID found');
      END IF;
      --
      rlm_message_sv.app_error(
         x_ExceptionLevel => rlm_message_sv.k_error_level,
         x_MessageName => 'RLM_OU_CONTEXT_NOT_SET',
         x_InterfaceHeaderId => x_InterfaceHeaderId,
         x_ScheduleHeaderId  => x_RLMScheduleID);
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RETURN FALSE;
      --
    WHEN OTHERS THEN
      rlm_message_sv.sql_error ('rlm_archive_demand_sv.Archive_Lines', x_progress);
  IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Error',sqlerrm);
         rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
      END IF;
      raise;
      return FALSE;
END;

/*===========================================================================

  FUNCTION NAME:        Archive_demand

===========================================================================*/
FUNCTION Archive_Demand (x_InterfaceHeaderId        IN  NUMBER) RETURN BOOLEAN
IS
v_Count          number;
v_RlmScheduleId         number;
x_progress         number;
CURSOR c_cur IS
 SELECT   schedule_header_id,
          edi_test_indicator,
          process_status
 FROM     rlm_interface_headers_all
 WHERE    header_id = x_InterfaceHeaderId;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'Archive_demand');
     rlm_core_sv.dlog(C_SDEBUG, 'x_InterfaceHeaderId ',x_InterfaceHeaderId);
  END IF;
  --
  FOR c_rec IN c_cur LOOP
    --
    IF c_rec.schedule_header_id IS NOT NULL THEN
      --
      v_RlmScheduleID := c_rec.schedule_header_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'Schedule Header Already Archived',
                                   c_rec.schedule_header_id);
         rlm_core_sv.dlog(C_DEBUG, 'request_id ',rlm_message_sv.g_conc_req_id );
      END IF;
      --
      Update rlm_schedule_headers_all
      SET request_id = rlm_message_sv.g_conc_req_id ,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      WHERE header_id = c_rec.schedule_header_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'Schedule headers updated', SQL%ROWCOUNT);
      END IF;
      --
      -- The lines are updated in Archive Lines no need to do this again
      --
/*
      Update rlm_schedule_lines
      SET request_id = rlm_message_sv.g_conc_req_id ,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      WHERE header_id = c_rec.schedule_header_id;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG, 'Schedule lines updated', SQL%ROWCOUNT);
      END IF;
      --
*/
    ELSE
      --
      IF NOT(Archive_Headers(x_InterfaceHeaderId,v_RlmScheduleID)) then
        --
        IF (l_debug <> -1) THEN
           rlm_core_sv.dpop(C_SDEBUG);
        END IF;
        --
        return FALSE;
        --
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_SDEBUG, 'Archived Header with ', v_RlmScheduleId);
      END IF;
      --
    END IF;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_SDEBUG, 'Archiving Schedule Lines');
    END IF;
    --
    IF NOT(Archive_lines(x_InterfaceHeaderId,v_RlmScheduleId)) then
          --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dpop(C_SDEBUG);
          END IF;
          --
          return FALSE;
          --
    END IF;
    --
    IF c_rec.edi_test_indicator = 'T' THEN
      --
      UPDATE rlm_interface_lines
      SET    process_status = rlm_core_sv.k_PS_PROCESSED
      WHERE  header_id = x_InterfaceHeaderId
      AND    process_status = rlm_core_sv.k_PS_AVAILABLE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated in interface lines for test',SQL%ROWCOUNT);
      END IF;
      --
      UPDATE rlm_schedule_lines
      SET    process_status = rlm_core_sv.k_PS_PROCESSED
      WHERE  header_id = v_RlmScheduleID
      AND    process_status = rlm_core_sv.k_PS_AVAILABLE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated in schedule lines for test',SQL%ROWCOUNT);
      END IF;
      --
      UPDATE rlm_interface_headers_all
      SET    process_status = rlm_core_sv.k_PS_PROCESSED
      WHERE  header_id = x_InterfaceHeaderId
      AND    process_status = rlm_core_sv.k_PS_AVAILABLE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated in interface header for test',SQL%ROWCOUNT);
      END IF;
      --
      -- Update the schedule headers with v_RlmScheduleID instead of
      -- c_rec.header_id for new schedules bug 1085917
      --
      UPDATE rlm_schedule_headers_all
      SET    process_status = rlm_core_sv.k_PS_PROCESSED
      WHERE  header_id = v_RlmScheduleID
      AND    process_status = rlm_core_sv.k_PS_AVAILABLE;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_SDEBUG, 'No of Records Updated in schedule headers for test',SQL%ROWCOUNT);
      END IF;
      --
    END IF;
  END LOOP;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  return TRUE;
  --
EXCEPTION
    WHEN OTHERS THEN
      rlm_message_sv.sql_error ('rlm_archive_demand_sv.Archive_demand',
                                x_progress);
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'x_progress',x_progress);
        rlm_core_sv.dlog(C_DEBUG,'Error',sqlerrm);
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
      END IF;
      --
      raise;
END;

END RLM_AD_SV;

/
