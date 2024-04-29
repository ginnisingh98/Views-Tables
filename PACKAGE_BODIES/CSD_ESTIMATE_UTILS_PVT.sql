--------------------------------------------------------
--  DDL for Package Body CSD_ESTIMATE_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_ESTIMATE_UTILS_PVT" AS
  /* $Header: csdueutb.pls 120.3.12010000.2 2010/03/17 21:01:18 swai ship $ */

  -- ---------------------------------------------------------
  -- Define global variables
  -- ---------------------------------------------------------

  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIR_ESTIMATE_PVT';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'csduestb.pls';
  g_debug NUMBER := Csd_Gen_Utility_Pvt.g_debug_level;
  ----Begin change for 3931317, wrpper aPI forward port

  C_EST_STATUS_ACCEPTED CONSTANT VARCHAR2(30) := 'ACCEPTED';
  C_EST_STATUS_REJECTED CONSTANT VARCHAR2(30) := 'REJECTED';
  C_EST_STATUS_NEW      CONSTANT VARCHAR2(30) := 'NEW';
  C_REP_STATUS_APPROVED CONSTANT VARCHAR2(30) := 'A';
  C_REP_STATUS_REJECTED CONSTANT VARCHAR2(30) := 'R';
  G_DEBUG_LEVEL         CONSTANT NUMBER := TO_NUMBER(NVL(Fnd_Profile.value('CSD_DEBUG_LEVEL'),
                                                         '0'));

  ------------------------------------------------------------------
  -----------------------------------------------------------------

  PROCEDURE debug(msg VARCHAR2) IS
  BEGIN
    IF (G_DEBUG_LEVEL >= 0) THEN
      Csd_Gen_Utility_Pvt.ADD(msg);
      --DBMS_OUTPUT.PUT_LINE(msg);
    END IF;
  END DEBUG;

  /*-------------------------------------------------------*/
  /* function name: validate_estimate_id                   */
  /* DEscription: Validates the estimate in the context    */
  /*              of repair_line_Id                        */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_ESTIMATE_ID(p_estimate_id    NUMBER,
                                p_repair_line_id NUMBER) RETURN BOOLEAN IS
    --Cursor to validate estimate id
    CURSOR CUR_EST IS
      SELECT 'x' col1
        FROM CSD_REPAIR_ESTIMATE_V
       WHERE repair_estimate_id = p_estimate_id
         AND repair_line_id = p_repair_line_id
         AND NVL(ESTIMATE_FREEZE_FLAG, 'N') = 'N';

    l_dummy VARCHAR2(1);

  BEGIN

    l_dummy := ' ';
    FOR c1_rec IN CUR_EST LOOP
      l_dummy := c1_rec.col1;
    END LOOP;

    IF l_dummy = 'x' THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_ESTIMATE');
      Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_ID', p_estimate_id);
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;

  END VALIDATE_ESTIMATE_ID;

  /*-------------------------------------------------------*/
  /* procedure name: validate_estiamte_status              */
  /* DEscription: Validates the estimate status            */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_EST_STATUS(p_estimate_status VARCHAR2) RETURN BOOLEAN IS
    --Cursor to validate estimate status
    CURSOR CUR_EST_STATUS(p_estimate_status VARCHAR2) IS
      SELECT 1 col1
        FROM fnd_lookup_values_vl
       WHERE lookup_type = 'CSD_ESTIMATE_STATUS'
         AND enabled_flag = 'Y'
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE)) AND
             TRUNC(NVL(end_date_active, SYSDATE))
         AND lookup_code = p_estimate_status;

    l_tmp_count NUMBER;

  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN CUR_EST_STATUS(p_estimate_status) LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;

    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_EST_STATUS');
      Fnd_Message.SET_TOKEN('STATUS', p_estimate_status);
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;

  END VALIDATE_EST_STATUS;
  /*-------------------------------------------------------*/
  /* function name: validate_Reason                 */
  /* DEscription: Validates the estimate reject reason     */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*                    11/3/04 added status as param      */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_REASON(p_reason_code VARCHAR2,
                           p_status      VARCHAR2) RETURN BOOLEAN IS
    --Cursor to validate estimate status
    CURSOR CUR_REJECT_REASON IS
      SELECT 1 col1
        FROM fnd_lookup_values_vl
       WHERE lookup_type = DECODE(p_status,
                                  C_EST_STATUS_REJECTED,
                                  'CSD_REJECT_REASON',
                                  C_EST_STATUS_ACCEPTED,
                                  'CSD_REASON')
         AND enabled_flag = 'Y'
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE)) AND
             TRUNC(NVL(end_date_active, SYSDATE))
         AND lookup_code = p_reason_code;

    l_tmp_count NUMBER;

  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN CUR_REJECT_REASON LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;

    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REJECT_REASON');
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;
  END VALIDATE_REASON;

  /*-------------------------------------------------------*/
  /* function name: validate_lead_time_uom                 */
  /* DEscription: Validates the uom code of the lead time  */
  /*  Change History  : Created 24th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_LEAD_TIME_UOM(p_lead_time_uom VARCHAR2) RETURN BOOLEAN IS
    --Cursor to validate estimate status
    CURSOR CUR_LEAD_TIME_UOM IS
      SELECT 1 col1
        FROM fnd_lookup_values_vl
       WHERE lookup_type = 'CSD_UNIT_OF_MEASURE'
         AND enabled_flag = 'Y'
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE)) AND
             TRUNC(NVL(end_date_active, SYSDATE))
         AND lookup_code = p_lead_time_uom;

    l_tmp_count NUMBER;

  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN CUR_LEAD_TIME_UOM LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;

    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_LEAD_TIME_UOM');
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;
  END VALIDATE_LEAD_TIME_UOM;

  /*-------------------------------------------------------*/
  /* function name: validate_uom_Code                      */
  /* Description: Validates the uom code                   */
  /* Change History  : Created 16th Sep 2004 by Vijay      */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_UOM_CODE(p_uom_code VARCHAR2,
                             p_item_id  NUMBER) RETURN BOOLEAN IS
    CURSOR c1 IS
      SELECT 1 col1
        FROM mtl_item_uoms_view
       WHERE inventory_item_id = p_item_id
         AND organization_id = Cs_Std.get_item_valdn_orgzn_id
         AND uom_type =
             (SELECT allowed_units_lookup_code
                FROM mtl_system_items_b
               WHERE organization_id = Cs_Std.get_item_valdn_orgzn_id
                 AND inventory_item_id = p_item_id)
         AND uom_code = p_uom_code;
    l_tmp_count NUMBER;
  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN c1 LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;
    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_UOM');
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;

    END IF;

  END VALIDATE_UOM_CODE;

  /*-------------------------------------------------------*/
  /* function name: validate_price_list                    */
  /* DEscription: Validates price_list                     */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_PRICE_LIST(p_price_list_id NUMBER) RETURN BOOLEAN IS
    CURSOR c1 IS
      SELECT 1 col1
        FROM oe_price_lists
       WHERE price_list_id = p_price_list_id;
    l_tmp_count NUMBER;
  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN c1 LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;
    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_PRICE_LIST_ID');
      Fnd_Message.SET_TOKEN('PRICE_LIST_ID', TO_CHAR(p_price_list_id));
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;

    END IF;

  END VALIDATE_PRICE_LIST;
  /*-------------------------------------------------------*/
  /* function name: validate_Item_pl_uom                   */
  /* DEscription: Validates the item/pl/uom code           */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  -- FUNCTION VALIDATE_ITEM_PL_UOM
  --          ( p_item_id       NUMBER,
  --            p_price_list_id NUMBER,
  --            p_uom           VARCHAR2) RETURN BOOLEAN;
  -- BEGIN
  --      null;
  --
  -- END VALIDATE_ITEM_PL_UOM;

  /*-------------------------------------------------------*/
  /* function name: validate_order                         */
  /* DEscription: Validates the order header and line      */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_ORDER(p_order_header_id NUMBER) RETURN VARCHAR2 IS

    CURSOR c1 IS
      SELECT A.ORDER_NUMBER
        FROM oe_order_headers_all A
       WHERE A.HEADER_ID = p_order_header_id;

    l_order_number VARCHAR2(30);
  BEGIN

    l_order_number := NULL;
    FOR c1_rec IN c1 LOOP
      l_order_number := c1_rec.order_number;
    END LOOP;
    IF l_order_number IS NOT NULL THEN
      RETURN l_order_number;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_ORDER_HEADER_ID');
      Fnd_Message.SET_TOKEN('ORDER_HEADER_ID', TO_CHAR(p_order_header_id));
      Fnd_Msg_Pub.ADD;
      RETURN NULL;

    END IF;
  END VALIDATE_ORDER;

  /*-------------------------------------------------------*/
  /* function name: validate_item_instance                 */
  /* DEscription: Validates the item instance and returns  */
  /*              the itme instance number                 */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_ITEM_INSTANCE(p_instance_id NUMBER) RETURN VARCHAR2 IS

    CURSOR c1 IS
      SELECT INSTANCE_NUMBER
        FROM CSI_ITEM_INSTANCES
       WHERE INSTANCE_ID = p_instance_id;

    l_instance_number VARCHAR2(30);
  BEGIN

    l_instance_number := NULL;
    FOR c1_rec IN c1 LOOP
      l_instance_number := c1_rec.instance_number;
    END LOOP;
    IF l_instance_number IS NOT NULL THEN
      RETURN l_instance_number;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_INSTANCE');
      Fnd_Msg_Pub.ADD;
      RETURN NULL;

    END IF;
  END VALIDATE_ITEM_INSTANCE;

  /*-------------------------------------------------------*/
  /* function name: validate_revision                      */
  /* DEscription: Validates the revision                   */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_REVISION(p_revision VARCHAR2,
                             p_item_id  NUMBER,
                             p_org_id   NUMBER) RETURN BOOLEAN IS
    CURSOR c1 IS
      SELECT 1 col1
        FROM mtl_item_revisions
       WHERE revision = p_revision
         AND inventory_item_id = p_item_id
         AND organization_id = p_org_id;

    l_tmp_count NUMBER;

  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN c1 LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;
    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REVISION');
      Fnd_Message.SET_TOKEN('REVISION', p_revision);
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;

  END VALIDATE_REVISION;

  /*-------------------------------------------------------*/
  /* function name: validate_serial_number                 */
  /* DEscription: Validates the serial number              */
  /*  Change History  : Created 16th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_SERIAL_NUMBER(p_serial_number VARCHAR2,
                                  p_item_id       NUMBER) RETURN BOOLEAN IS
    CURSOR c1 IS
      SELECT 1 col1
        FROM mtl_serial_numbers
       WHERE serial_number = p_serial_number
         AND inventory_item_id = p_item_id;

    l_tmp_count NUMBER;

  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN c1 LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;
    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_SERIAL_NUMBER');
      Fnd_Message.SET_TOKEN('SERIAL_NUMBER', p_serial_number);
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;

  END VALIDATE_SERIAL_NUMBER;

  /*-------------------------------------------------------*/
  /* function name: validate_billing_type                  */
  /* DEscription: Validates the billing type from looks    */
  /* table                                                 */
  /*  Change History  : Created 21st Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION VALIDATE_BILLING_TYPE(p_billing_type VARCHAR2) RETURN BOOLEAN IS

    CURSOR c1 IS
      SELECT 1 col1
        FROM fnd_lookup_values
       WHERE lookup_code = P_BILLING_TYPE
         AND lookup_type = 'CSD_EST_BILLING_TYPE'
         AND enabled_flag = 'Y'
         AND LANGUAGE = 'US'
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE)) AND
             TRUNC(NVL(end_date_active, SYSDATE));

    l_tmp_count NUMBER;

  BEGIN

    l_tmp_count := 0;
    FOR c1_rec IN c1 LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;
    IF l_tmp_count > 0 THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_BILLING_TYPE');
      Fnd_Message.SET_TOKEN('BILLING_TYPE', p_billing_type);
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;

  END VALIDATE_BILLING_TYPE;

  /*-------------------------------------------------------*/
  /* function name: validate_rep_line_id                  */
  /* DEscription: Validates the repair line id             */
  /*                                                       */
  /*  Change History  : Created 30th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION validate_rep_line_id(p_repair_line_id IN NUMBER) RETURN BOOLEAN

   IS
    l_C_STATUS_CLOSED VARCHAR2(1) := 'C';

    CURSOR c1 IS
      SELECT 'x' col1
        FROM csd_repairs
       WHERE repair_line_id = p_repair_line_id
         AND status <> l_C_STATUS_CLOSED;

    l_dummy VARCHAR2(1);

  BEGIN
    l_dummy := ' ';
    FOR c1_rec IN c1 LOOP
      l_dummy := c1_rec.col1;
    END LOOP;
    IF l_dummy = 'x' THEN
      RETURN TRUE;
    ELSE
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REP_LINE_ID');
      Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', p_repair_line_id);
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    END IF;

  END Validate_rep_line_id;

  /*-------------------------------------------------------*/
  /* function name: validate_incident_id                  */
  /* DEscription: Validates the incident    id             */
  /*                                                       */
  /*  Change History  : Created 30th Sep 2004 by Vijay     */
  /*-------------------------------------------------------*/
  FUNCTION validate_incident_id(p_incident_id IN NUMBER) RETURN BOOLEAN IS

    CURSOR c1 IS
      SELECT 'x' col1
        FROM cs_incidents_all_b A, cs_incident_statuses_b B
       WHERE A.incident_id = p_incident_id
         AND B.INCIDENT_STATUS_ID = A.INCIDENT_STATUS_ID
         AND B.incident_subtype = 'INC'
         AND TRUNC(SYSDATE) BETWEEN
             TRUNC(NVL(B.start_date_active, SYSDATE)) AND
             TRUNC(NVL(B.end_date_active, SYSDATE))
         AND B.CLOSE_FLAG = 'Y';

    l_dummy VARCHAR2(1);

  BEGIN
    l_dummy := ' ';
    FOR c1_rec IN c1 LOOP
      l_dummy := c1_rec.col1;
    END LOOP;
    IF l_dummy = 'x' THEN
      Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_INC_STATUS');
      Fnd_Message.SET_TOKEN('INCIDENT_ID', p_incident_id);
      Fnd_Msg_Pub.ADD;
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;

  END validate_incident_id;

  /*-------------------------------------------------------*/
  /* procedure name: validate_est_hdr_rec                  */
  /* DEscription: Validates estimates header record        */
  /*                                                       */
  /*  Change History  : Created 25th June2005 by Vijay     */
  /*-------------------------------------------------------*/

  PROCEDURE validate_est_hdr_rec(p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec ,
                                 p_validation_level                       IN NUMBER) IS
    --Cursor definition to check the existing repair estimate header record for the
    -- given repair order line.
    CURSOR CUR_ESTIMATE_HDR(p_repair_line_id NUMBER) IS
      SELECT 1 col1
        FROM CSD_REPAIR_ESTIMATE
       WHERE REPAIR_LINE_ID = p_repair_line_id
         AND ROWNUM = 1;

    l_tmp_count NUMBER;
    l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_EST_HDR_REC';

  BEGIN

    -- Check the required parameters
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_hdr_rec.repair_line_id,
                                      p_param_name  => 'REPAIR_LINE_ID',
                                      p_api_name    => l_api_name);
    /*
    -- swai: bug 9462862 - lead time and uom are not required fields
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_hdr_rec.lead_time,
                                      p_param_name  => 'LEAD_TIME',
                                      p_api_name    => l_api_name);
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_hdr_rec.lead_time_uom,
                                      p_param_name  => 'LEAD_TIME_UOM',
                                      p_api_name    => l_api_name);
    */
    -- Validate repair line id
    IF (NOT VALIDATE_REP_LINE_ID(p_estimate_hdr_rec.repair_line_id)) THEN
      debug('Invalid repair order line[' ||
            p_estimate_hdr_rec.repair_line_id || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    -- Check if the repair line has already an estimate record.
    -- if so then return failure with warning message.
    l_tmp_count := 0;
    FOR c1_rec IN CUR_ESTIMATE_HDR(p_estimate_hdr_rec.repair_line_id) LOOP
      l_tmp_count := c1_rec.col1;
    END LOOP;

    IF l_tmp_count > 0 THEN
      Fnd_Message.SET_NAME('CSD', 'CSD_API_ESTIMATE_EXISTS');
      Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                            p_estimate_hdr_rec.repair_line_id);
      Fnd_Msg_Pub.ADD;
      Fnd_Msg_Pub.ADD_DETAIL(p_message_type => Fnd_Msg_Pub.G_WARNING_MSG);
      debug('Estimate header already exists');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

  END VALIDATE_EST_HDR_REC;

  /*------------------------------------------------------------------------*/
  /* procedure name: DEFAULT_EST_HDR_REC                                    */
  /* DEscription: DEfault values are set in  estimates header record        */
  /*                                                                        */
  /*  Change History  : Created 25th June2005 by Vijay                      */
  /*------------------------------------------------------------------------*/

  PROCEDURE DEFAULT_EST_HDR_REC(p_estimate_hdr_rec IN OUT NOCOPY Csd_Repair_Estimate_Pub.estimate_hdr_Rec) IS
    -- Cursor to get the object version number and repair quantity
    -- and SR summary
    CURSOR CUR_REPAIR_LINE(p_Repair_line_id NUMBER) IS
      SELECT A.QUANTITY, A.OBJECT_VERSION_NUMBER, B.SUMMARY, B.INCIDENT_ID
        FROM CSD_REPAIRS A, CS_INCIDENTS_ALL_VL B
       WHERE A.REPAIR_LINE_ID = p_repair_line_id
         AND A.INCIDENT_ID = B.INCIDENT_ID;

    l_incident_id NUMBER;

  BEGIN

    --------------------------------------------------------------------
    -- Get the repair line attributes and default into the estimate hdr
    --------------------------------------------------------------------
    p_estimate_hdr_rec.ro_object_version_number := -1;
    p_estimate_hdr_rec.repair_line_quantity     := 0;
    FOR c1_rec IN CUR_REPAIR_LINE(p_estimate_hdr_rec.repair_line_id) LOOP
      p_estimate_hdr_rec.ro_object_version_number := c1_rec.Object_Version_number;
      p_estimate_hdr_rec.repair_line_quantity     := c1_rec.quantity;
      l_incident_id                               := c1_rec.incident_id;
      IF (p_estimate_hdr_rec.work_summary IS NULL) THEN
        p_estimate_hdr_rec.work_summary := c1_rec.summary;
      END IF;
    END LOOP;
    debug('summary=[' || p_estimate_hdr_rec.work_summary || ']');

    --------------------------------------------------------------------
    -- Validate incident id status. Ensure that the SR status is not closed.
    --------------------------------------------------------------------
    IF (NOT VALIDATE_INCIDENT_ID(l_incident_id)) THEN
      debug('Invalid incident id[' || l_incident_id || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    -- Defualt the estiamte date to sysdate if it is null
    IF (p_estimate_hdr_rec.estimate_date IS NULL) THEN
      p_estimate_hdr_rec.estimate_date := SYSDATE;
    END IF;

    -- Defualt the status to 'NEW' if null
    IF (p_estimate_hdr_rec.estimate_status IS NULL) THEN
      p_estimate_hdr_rec.estimate_status := C_EST_STATUS_NEW;
    END IF;

  END DEFAULT_EST_HDR_REC;

  /*------------------------------------------------------------------------*/
  /* procedure name: VALIDATE_DEFAULTED_EST_HDR                             */
  /* DEscription: Validate the defaulted  estimates header record           */
  /*                                                                        */
  /*  Change History  : Created 25th June2005 by Vijay                      */
  /*------------------------------------------------------------------------*/
  PROCEDURE VALIDATE_DEFAULTED_EST_HDR(p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec,
                                       p_validation_level IN NUMBER) IS

  l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_DEFAULTED_EST_HDR';

  BEGIN
    -- If the summary is null even after SR summary is defaulted, then
    -- it is an error.
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_hdr_rec.work_summary,
                                      p_param_name  => 'SUMMARY',
                                      p_api_name    => l_api_name);

    --Validate input status
    IF (NOT VALIDATE_EST_STATUS(p_estimate_hdr_rec.estimate_status)) THEN
      debug('Invalid estimate status[' ||
            p_estimate_hdr_rec.estimate_status || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;


    -- Validate lead time UOM
    -- swai: bug 9462862  only validate lead time UOM if it has been entered.
    -- Lead time is optional and UOM should not be validated if not enetered.
    IF (p_estimate_hdr_rec.lead_time is not null or
        p_estimate_hdr_rec.lead_time_uom is not null) THEN
        IF (NOT VALIDATE_LEAD_TIME_UOM(p_estimate_hdr_rec.lead_time_uom)) THEN
          debug('Invalid lead time uom[' || p_estimate_hdr_rec.lead_time_uom || ']');
          RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
    END IF;

  END VALIDATE_DEFAULTED_EST_HDR;

  /*------------------------------------------------------------------------*/
  /* procedure name: COPY_TO_EST_HDR_REC                                    */
  /* DEscription: Creates the record required for private api              */
  /*                                                                        */
  /*  Change History  : Created 25th June2005 by Vijay                      */
  /*------------------------------------------------------------------------*/
  PROCEDURE COPY_TO_EST_HDR_REC(p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec,
                                x_est_pvt_hdr_rec  OUT NOCOPY Csd_Repair_Estimate_Pvt.REPAIR_ESTIMATE_REC) IS
  BEGIN

    IF (p_estimate_hdr_rec.repair_estimate_id IS NOT NULL) then
      x_est_pvt_hdr_rec.repair_estimate_id := p_estimate_hdr_rec.repair_estimate_id;
    END IF;

    IF (p_estimate_hdr_rec.repair_line_id IS NOT NULL) then
      x_est_pvt_hdr_rec.repair_line_id := p_estimate_hdr_rec.repair_line_id;
    END IF;
    IF (p_estimate_hdr_rec.note_id IS NOT NULL) then
      x_est_pvt_hdr_rec.note_id := p_estimate_hdr_rec.note_id;
    END IF;
    IF (p_estimate_hdr_rec.estimate_date IS NOT NULL) then
      x_est_pvt_hdr_rec.estimate_date := p_estimate_hdr_rec.estimate_date;
    END IF;
    IF (p_estimate_hdr_rec.estimate_status IS NOT NULL) then
      x_est_pvt_hdr_rec.estimate_status := p_estimate_hdr_rec.estimate_status;
    END IF;
    IF (p_estimate_hdr_rec.lead_time IS NOT NULL) then
      x_est_pvt_hdr_rec.lead_time := p_estimate_hdr_rec.lead_time;
    END IF;
    IF (p_estimate_hdr_rec.lead_time_uom IS NOT NULL) then
      x_est_pvt_hdr_rec.lead_time_uom := p_estimate_hdr_rec.lead_time_uom;
    END IF;
    IF (p_estimate_hdr_rec.work_summary IS NOT NULL) then
      x_est_pvt_hdr_rec.work_summary := p_estimate_hdr_rec.work_summary;
    END IF;
    IF (p_estimate_hdr_rec.po_number IS NOT NULL) then
      x_est_pvt_hdr_rec.po_number := p_estimate_hdr_rec.po_number;
    END IF;
    IF (p_estimate_hdr_rec.estimate_reason_code IS NOT NULL) then
      x_est_pvt_hdr_rec.estimate_reason_code := p_estimate_hdr_rec.estimate_reason_code;
    END IF;
    IF (p_estimate_hdr_rec.last_update_date IS NOT NULL) then
      x_est_pvt_hdr_rec.last_update_date := p_estimate_hdr_rec.last_update_date;
    END IF;
    IF (p_estimate_hdr_rec.creation_date IS NOT NULL) then
      x_est_pvt_hdr_rec.creation_date := p_estimate_hdr_rec.creation_date;
    END IF;
    IF (p_estimate_hdr_rec.last_updated_by IS NOT NULL) then
      x_est_pvt_hdr_rec.last_updated_by := p_estimate_hdr_rec.last_updated_by;
    END IF;
    IF (p_estimate_hdr_rec.created_by IS NOT NULL) then
      x_est_pvt_hdr_rec.created_by := p_estimate_hdr_rec.created_by;
    END IF;
    IF (p_estimate_hdr_rec.last_update_login IS NOT NULL) then
      x_est_pvt_hdr_rec.last_update_login := p_estimate_hdr_rec.last_update_login;
    END IF;
    IF (p_estimate_hdr_rec.attribute1 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute1 := p_estimate_hdr_rec.attribute1;
    END IF;
    IF (p_estimate_hdr_rec.attribute2 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute2 := p_estimate_hdr_rec.attribute2;
    END IF;
    IF (p_estimate_hdr_rec.attribute3 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute3 := p_estimate_hdr_rec.attribute3;
    END IF;
    IF (p_estimate_hdr_rec.attribute4 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute4 := p_estimate_hdr_rec.attribute4;
    END IF;
    IF (p_estimate_hdr_rec.attribute5 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute5 := p_estimate_hdr_rec.attribute5;
    END IF;
    IF (p_estimate_hdr_rec.attribute6 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute6 := p_estimate_hdr_rec.attribute6;
    END IF;
    IF (p_estimate_hdr_rec.attribute7 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute7 := p_estimate_hdr_rec.attribute7;
    END IF;
    IF (p_estimate_hdr_rec.attribute8 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute8 := p_estimate_hdr_rec.attribute8;
    END IF;
    IF (p_estimate_hdr_rec.attribute9 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute9 := p_estimate_hdr_rec.attribute9;
    END IF;
    IF (p_estimate_hdr_rec.attribute10 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute10 := p_estimate_hdr_rec.attribute10;
    END IF;
    IF (p_estimate_hdr_rec.attribute11 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute11 := p_estimate_hdr_rec.attribute11;
    END IF;
    IF (p_estimate_hdr_rec.attribute12 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute12 := p_estimate_hdr_rec.attribute12;
    END IF;
    IF (p_estimate_hdr_rec.attribute13 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute13 := p_estimate_hdr_rec.attribute13;
    END IF;
    IF (p_estimate_hdr_rec.attribute14 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute14 := p_estimate_hdr_rec.attribute14;
    END IF;
    IF (p_estimate_hdr_rec.attribute15 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute15 := p_estimate_hdr_rec.attribute15;
    END IF;
    IF (p_estimate_hdr_rec.context IS NOT NULL) then
      x_est_pvt_hdr_rec.context := p_estimate_hdr_rec.context;
    END IF;
    IF (p_estimate_hdr_rec.object_version_number IS NOT NULL) then
      x_est_pvt_hdr_rec.object_version_number := p_estimate_hdr_rec.object_version_number;
    END IF;
    -- swai: bug 9462789
    IF (p_estimate_hdr_rec.not_to_exceed IS NOT NULL) then
      x_est_pvt_hdr_rec.not_to_exceed := p_estimate_hdr_rec.not_to_exceed;
    END IF;
    -- swai: end bug 9462789

  END COPY_TO_EST_HDR_REC;

  /*------------------------------------------------------------------------*/
  /* procedure name: COPY_TO_EST_HDR_REC_UPD                                */
  /* DEscription: Creates the record required for private update api        */
  /*                                                                        */
  /*  Change History  : Created 25th June2005 by Vijay                      */
  /*------------------------------------------------------------------------*/
  PROCEDURE COPY_TO_EST_HDR_REC_UPD(p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec,
                                    x_est_pvt_hdr_rec  OUT NOCOPY Csd_Repair_Estimate_Pvt.REPAIR_ESTIMATE_REC) IS
  BEGIN
    -- swai: bug 9462789
    x_est_pvt_hdr_rec.repair_estimate_id := p_estimate_hdr_rec.repair_estimate_id;

    IF (p_estimate_hdr_rec.not_to_exceed IS NOT NULL) then
      x_est_pvt_hdr_rec.not_to_exceed := p_estimate_hdr_rec.not_to_exceed;
    END IF;
    -- swai: end bug 9462789

    IF (p_estimate_hdr_rec.note_id IS NOT NULL) then
      x_est_pvt_hdr_rec.note_id := p_estimate_hdr_rec.note_id;
    END IF;
    IF (p_estimate_hdr_rec.estimate_date IS NOT NULL) then
      x_est_pvt_hdr_rec.estimate_date := p_estimate_hdr_rec.estimate_date;
    END IF;
    IF (p_estimate_hdr_rec.estimate_status IS NOT NULL) then
      x_est_pvt_hdr_rec.estimate_status := p_estimate_hdr_rec.estimate_status;
    END IF;
    IF (p_estimate_hdr_rec.lead_time IS NOT NULL) then
      x_est_pvt_hdr_rec.lead_time := p_estimate_hdr_rec.lead_time;
    END IF;
    IF (p_estimate_hdr_rec.lead_time_uom IS NOT NULL) then
      x_est_pvt_hdr_rec.lead_time_uom := p_estimate_hdr_rec.lead_time_uom;
    END IF;
    IF (p_estimate_hdr_rec.work_summary IS NOT NULL) then
      x_est_pvt_hdr_rec.work_summary := p_estimate_hdr_rec.work_summary;
    END IF;
    IF (p_estimate_hdr_rec.po_number IS NOT NULL) then
      x_est_pvt_hdr_rec.po_number := p_estimate_hdr_rec.po_number;
    END IF;
    IF (p_estimate_hdr_rec.estimate_reason_code IS NOT NULL) then
      x_est_pvt_hdr_rec.estimate_reason_code := p_estimate_hdr_rec.estimate_reason_code;
    END IF;
    IF (p_estimate_hdr_rec.attribute1 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute1 := p_estimate_hdr_rec.attribute1;
    END IF;
    IF (p_estimate_hdr_rec.attribute2 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute2 := p_estimate_hdr_rec.attribute2;
    END IF;
    IF (p_estimate_hdr_rec.attribute3 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute3 := p_estimate_hdr_rec.attribute3;
    END IF;
    IF (p_estimate_hdr_rec.attribute4 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute4 := p_estimate_hdr_rec.attribute4;
    END IF;
    IF (p_estimate_hdr_rec.attribute5 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute5 := p_estimate_hdr_rec.attribute5;
    END IF;
    IF (p_estimate_hdr_rec.attribute6 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute6 := p_estimate_hdr_rec.attribute6;
    END IF;
    IF (p_estimate_hdr_rec.attribute7 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute7 := p_estimate_hdr_rec.attribute7;
    END IF;
    IF (p_estimate_hdr_rec.attribute8 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute8 := p_estimate_hdr_rec.attribute8;
    END IF;
    IF (p_estimate_hdr_rec.attribute9 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute9 := p_estimate_hdr_rec.attribute9;
    END IF;
    IF (p_estimate_hdr_rec.attribute10 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute10 := p_estimate_hdr_rec.attribute10;
    END IF;
    IF (p_estimate_hdr_rec.attribute11 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute11 := p_estimate_hdr_rec.attribute11;
    END IF;
    IF (p_estimate_hdr_rec.attribute12 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute12 := p_estimate_hdr_rec.attribute12;
    END IF;
    IF (p_estimate_hdr_rec.attribute13 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute13 := p_estimate_hdr_rec.attribute13;
    END IF;
    IF (p_estimate_hdr_rec.attribute14 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute14 := p_estimate_hdr_rec.attribute14;
    END IF;
    IF (p_estimate_hdr_rec.attribute15 IS NOT NULL) then
      x_est_pvt_hdr_rec.attribute15 := p_estimate_hdr_rec.attribute15;
    END IF;
    IF (p_estimate_hdr_rec.context IS NOT NULL) then
      x_est_pvt_hdr_rec.context := p_estimate_hdr_rec.context;
    END IF;

    x_est_pvt_hdr_rec.object_version_number := p_estimate_hdr_rec.object_version_number;

  END COPY_TO_EST_HDR_REC_UPD;

  /*-------------------------------------------------------*/
  /* procedure name: validate_est_line_rec                  */
  /* DEscription: Validates estimates line record          */
  /*                                                       */
  /*  Change History  : Created 25th June2005 by Vijay     */
  /*-------------------------------------------------------*/

  PROCEDURE VALIDATE_EST_LINE_REC(p_estimate_line_rec IN Csd_Repair_Estimate_Pub.estimate_line_Rec,
                                  p_validation_level                        IN NUMBER) IS

    l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_EST_LINE_REC';
	l_order_number varchar2(30);

  BEGIN
    -- Check the required parameters
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_line_rec.repair_line_id,
                                      p_param_name  => 'REPAIR_LINE_ID',
                                      p_api_name    => l_api_name);
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_line_rec.repair_estimate_id,
                                      p_param_name  => 'REPAIR_ESTIMATE_ID',
                                      p_api_name    => l_api_name);
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_line_rec.inventory_item_id,
                                      p_param_name  => 'INVENTORY_ITEM_ID',
                                      p_api_name    => l_api_name);
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_line_rec.price_list_id,
                                      p_param_name  => 'PRICE_LIST_ID',
                                      p_api_name    => l_api_name);
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_line_rec.unit_of_measure_code,
                                      p_param_name  => 'UNIT_OF_MEASURE_CODE',
                                      p_api_name    => l_api_name);
    Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_line_rec.estimate_quantity,
                                      p_param_name  => 'ESTIMATE_QUANTITY',
                                      p_api_name    => l_api_name);

    --------------------------------------------------------------------
    -- Validate repair line id
    --------------------------------------------------------------------
    IF (NOT VALIDATE_REP_LINE_ID(p_estimate_line_rec.repair_line_id)) THEN
      debug('Invalid repair order line[' ||
            p_estimate_line_rec.repair_line_id || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    --------------------------------------------------------------------
    -- Validate estiamate hdr id repair line id combination
    --------------------------------------------------------------------
    IF (NOT VALIDATE_ESTIMATE_ID(p_estimate_line_rec.repair_estimate_id,
                                 p_estimate_line_rec.repair_line_id)) THEN
      debug('Invalid estiamte header, rep line[' ||
            p_estimate_line_rec.repair_line_id || ']estimate[' ||
            p_estimate_line_rec.repair_estimate_id || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    --------------------------------------------------------------------
    -- Validate inventory item id
    --------------------------------------------------------------------
    IF (NOT
        Csd_Process_Util.VALIDATE_INVENTORY_ITEM_ID(p_estimate_line_rec.inventory_item_id)) THEN
      debug('Invalid Inventory item[' ||
            p_estimate_line_rec.inventory_item_id || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    --------------------------------------------------------------------
    -- Validate  UOM
    --------------------------------------------------------------------

    IF (NOT VALIDATE_UOM_CODE(p_estimate_line_rec.unit_of_measure_code,
                              p_estimate_line_rec.inventory_item_id)) THEN
      debug('Invalid  uom[' || p_estimate_line_rec.unit_of_measure_code || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    --------------------------------------------------------------------
    -- Validate  Price list
    --------------------------------------------------------------------

    IF (NOT VALIDATE_PRICE_LIST(p_estimate_line_rec.price_list_id)) THEN
      debug('Invalid  uom[' || p_estimate_line_rec.price_list_id || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    --------------------------------------------------------------------
    -- Validate add to order (order _header id and order_line_Id)
    --------------------------------------------------------------------
    IF (p_estimate_line_rec.add_to_order_flag = 'Y') THEN
      l_order_number := VALIDATE_ORDER(p_estimate_line_rec.order_header_id);
      IF (l_order_number IS NULL OR
         l_order_number = Fnd_Api.G_MISS_CHAR) THEN
        debug('Invalid order header id[' ||
              p_estimate_line_rec.order_header_id || '] ');
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
    END IF;

    -- Validate override charge flag.
    IF (p_estimate_line_rec.override_charge_flag = 'Y') THEN
      IF (NVL(Fnd_Profile.value('CSD_ALLOW_CHARGE_OVERRIDE'), 'N') <> 'Y') THEN
        Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_OVERRIDE_FLAG');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
    END IF;

  END VALIDATE_EST_LINE_REC;

/*------------------------------------------------------------------------*/
/* procedure name: DEFAULT_EST_LINE_REC                                    */
/* DEscription: DEfault values are set in  estimates line record         */
/*                                                                        */
/*  Change History  : Created 25th June2005 by Vijay                      */
/*------------------------------------------------------------------------*/

PROCEDURE DEFAULT_EST_LINE_REC(px_estimate_line_rec IN OUT NOCOPY Csd_Repair_Estimate_Pub.estimate_line_Rec) IS
  -- cursor to get nocharge flag, txn_type and validate txn_billing_type
  CURSOR CUR_NO_CHARGE_FLAG(p_txn_billing_Type_id NUMBER) IS
    SELECT NVL(ctt.no_charge_flag, 'N') no_charge_flag,
           ctt.transaction_Type_id
      FROM cs_txn_billing_types ctbt, cs_transaction_types ctt
     WHERE ctbt.txn_billing_type_id = p_txn_billing_type_id
       AND ctbt.transaction_type_id = ctt.transaction_type_id;
  -- Cursor to get the incident id , repair type, business process
  CURSOR CUR_REPAIR_LINE(p_Repair_line_id NUMBER) IS
    SELECT A.INCIDENT_ID,
           A.CONTRACT_LINE_ID,
           B.BUSINESS_PROCESS_ID,
           B.REPAIR_TYPE_ID
      FROM CSD_REPAIRS A, CSD_REPAIR_TYPES_B B
     WHERE A.REPAIR_LINE_ID = p_repair_line_id
       AND A.REPAIR_TYPE_ID = B.REPAIR_TYPE_ID;

  -- Cursor to get the contract_id and contract_number
  CURSOR CUR_CONTRACT_DETAILS(p_contract_line_id NUMBER) IS
    SELECT HD.ID CONTRACT_ID, HD.CONTRACT_NUMBER
      FROM OKC_K_HEADERS_B HD, OKC_K_LINES_B KL
     WHERE HD.ID = KL.DNZ_CHR_ID
       AND KL.CLE_ID = p_contract_line_id
       AND ROWNUM = 1;

  -- Cursor to get the billable_flag
  CURSOR CUR_BILLING_TYPE(p_item_id NUMBER) IS
    SELECT material_billable_flag
      FROM mtl_system_items_b
     WHERE inventory_item_id = p_item_id
       AND organization_id = Cs_Std.GET_ITEM_VALDN_ORGZN_ID;

  -- Cursor to get the item cost for a material item
  -- Service validation org is considered here.
  CURSOR CUR_MATERIAL_COST(p_item_id NUMBER) IS
    SELECT item_cost item_cost
      FROM cst_item_costs a, cst_cost_types b
     WHERE a.cost_type_id = b.cost_type_id
       AND UPPER(b.cost_type) = 'FROZEN'
       AND a.inventory_item_id = p_item_id
       AND a.organization_id = Cs_Std.GET_ITEM_VALDN_ORGZN_ID;

  -- Cursor to get the txn_billing_Types from the repair type.
  CURSOR CUR_TXN_BILLING_TYPE(p_repair_type_id NUMBER, p_billing_category VARCHAR2, p_billing_type VARCHAR2) IS
    SELECT txn_billing_type_id
      FROM csd_repair_types_sar_vl
     WHERE repair_type_id = p_repair_type_id
       AND BILLING_CATEGORY = p_billing_Category
       AND BILLING_TYPE = p_billing_Type;

 CURSOR CUR_ITEM_INSTANCE(p_item_id NUMBER, p_serial_number NUMBER) IS
    SELECT instance_number, instance_id
      FROM csi_item_instances
     WHERE inventory_item_id = p_item_id
       AND serial_number = p_serial_number;

  l_billing_Type     VARCHAR2(1);
  l_no_charge_flag   VARCHAR2(1);
  l_repair_Type_id   NUMBER;
  l_contract_line_id NUMBER;
  l_pricing_rec      Csd_Process_Util.PRICING_ATTR_REC;
  l_return_status    varchar2(1);
  l_msg_Count        NUMBER;
  l_msg_data         VARCHAR2(4000);

  --bug#3875036
  l_account_id						NUMBER        := NULL;


BEGIN
  px_estimate_line_rec.source_id            := px_estimate_line_rec.repair_line_id;
  px_estimate_line_rec.original_source_id   := px_estimate_line_rec.repair_line_id;
  px_estimate_line_rec.source_code          := 'DR';
  px_estimate_line_rec.original_source_code := 'DR';

  /* bug#3875036 */
  l_account_id := CSD_CHARGE_LINE_UTIL.Get_SR_AccountId(px_estimate_line_rec.repair_line_id);

  debug('Input No charge flag [' || px_estimate_line_rec.no_charge_flag || ']');
  l_no_charge_flag                         := 'N';
  px_estimate_line_rec.transaction_Type_id := -1;
  FOR c1_rec IN CUR_NO_CHARGE_FLAG(px_estimate_line_rec.txn_billing_Type_id) LOOP
    l_no_charge_flag                         := c1_rec.no_charge_flag;
    px_estimate_line_rec.transaction_Type_id := c1_rec.transaction_Type_id;
  END LOOP;
  debug('txn_type_id is derived from txn_billing type[' ||
        px_estimate_line_rec.transaction_Type_id || ']');
  IF (px_estimate_line_rec.transaction_Type_id = -1) THEN
    Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_TRANSACTION_TYPE');
    Fnd_Message.SET_TOKEN('TXN_BILLING_TYPE_ID',
                          px_estimate_line_rec.txn_billing_Type_id);
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  IF (px_estimate_line_rec.no_charge_flag = 'Y' AND
     (px_estimate_line_rec.override_charge_flag IS NULL OR
     px_estimate_line_rec.override_charge_flag <> 'Y')) THEN
    Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_NOCHARGE_FLAG');
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  ELSIF (px_estimate_line_rec.no_charge_flag IS NULL OR
        px_estimate_line_rec.no_charge_flag <> 'Y') THEN
    debug('No charge flag is not Y, deriving from txn_billing_type[' ||
          px_estimate_line_rec.txn_billing_Type_id || ']');
    px_estimate_line_rec.no_charge_flag := l_no_charge_flag;
    debug('No charge flag is derived from txn_billing type[' ||
          px_estimate_line_rec.no_charge_flag || ']');

  END IF;

  --------------------------------------------------------------------
  --Get the business process and incident id values from the
  -- CSD_REPAIRS table. Since the repair line id is validated
  -- there is no need to check for rec not found condition.
  --------------------------------------------------------------------
  px_estimate_line_rec.business_process_id := -1;
  px_estimate_line_rec.incident_id         := -1;
  FOR c1_rec IN CUR_REPAIR_LINE(px_estimate_line_rec.repair_line_id) LOOP
    px_estimate_line_rec.business_process_id := c1_rec.business_process_id;
    px_estimate_line_rec.incident_id         := c1_rec.incident_id;
    l_repair_type_id                         := c1_rec.repair_type_id;
    ---------------------------------------------------------------------
    --  Default the repair order contract
    ---------------------------------------------------------------------
    l_contract_line_id := c1_rec.contract_line_id;
    OPEN CUR_CONTRACT_DETAILS(c1_rec.contract_line_id);
    FETCH CUR_CONTRACT_DETAILS
      INTO px_estimate_line_rec.contract_id, px_estimate_line_rec.contract_number;
    CLOSE CUR_CONTRACT_DETAILS;

    debug('business_process_id[' || c1_rec.business_process_id || ']' ||
          'incident_id[' || c1_rec.incident_id || ']' || 'contract_id[' ||
          px_estimate_line_rec.contract_id || ']' || 'contract_number[' ||
          px_estimate_line_rec.contract_number || ']');

  END LOOP;

  --------------------------------------------------------------------
  -- Get the operating unit from the incident id.
  --------------------------------------------------------------------
  px_estimate_line_rec.organization_id := Csd_Process_Util.get_org_id(px_estimate_line_rec.incident_id);
  IF (px_estimate_line_rec.organization_id = -1) THEN
    debug('incident_id[' || px_estimate_line_rec.incident_id ||
          '] is invlaid');
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  -- Get the billing type from the item.
  FOR c1_rec IN CUR_BILLING_TYPE(px_estimate_line_rec.inventory_item_id) LOOP
    l_billing_type := c1_rec.material_billable_flag;
  END LOOP;

  -------------------------------------------------------------------
  -- Validate resource id if the billing_type = 'L' which is
  -- labor. Get the cost for the input reosurce id. If the resource
  -- id results in no record then it is an error condition.
  -------------------------------------------------------------------
  IF (l_billing_type = 'L') THEN

    Csd_Cost_Analysis_Pvt.Get_ResItemCost(x_return_status     => l_return_status,
                                          x_msg_count         => l_msg_count,
                                          x_msg_data          => l_msg_data,
                                          p_inventory_item_id => px_estimate_line_rec.inventory_item_id,
                                          p_organization_id   => Cs_Std.GET_ITEM_VALDN_ORGZN_ID,
										  p_bom_resource_id   => null,
    	  								  p_charge_date       => SYSDATE,
                                          p_currency_code      => px_estimate_line_rec.currency_code,
                                          p_chg_line_uom_code => px_estimate_line_rec.unit_of_measure_code,
                                          x_item_cost         => px_estimate_line_rec.item_cost);

    --  changed the default to null instead of 0.
    --  also if the cost is 0 changed it to null
    IF (px_estimate_line_rec.item_cost = 0) THEN
      px_estimate_line_rec.item_cost := NULL;
    END IF;

  ELSE
    ---------------------------------------------------------------------
    -- Billing type M is material. In the case of material, get the
    -- item cost from item costs table.
    ---------------------------------------------------------------------
    --px_estimate_line_rec.item_cost := 0;
    debug('item cost,before =[' || px_estimate_line_rec.item_cost || ']');
    FOR c1_rec IN CUR_MATERIAL_COST(px_estimate_line_rec.inventory_item_id) LOOP
      px_estimate_line_rec.item_cost := c1_rec.item_cost;
    END LOOP;
    IF (px_estimate_line_rec.item_cost = 0) THEN
      px_estimate_line_rec.item_cost := NULL;
    END IF;
    debug('item cost, after api call =[' || px_estimate_line_rec.item_cost || ']');

  END IF;

  ---------------------------------------------------------------------
  -- Get selling price if it is null
  ---------------------------------------------------------------------
  IF (px_estimate_line_rec.selling_price IS NULL) THEN
    l_pricing_rec := get_pricing_rec(px_estimate_line_rec);
    Csd_Process_Util.GET_CHARGE_SELLING_PRICE(p_inventory_item_id    => px_estimate_line_rec.inventory_item_id,

									p_price_list_header_id => px_estimate_line_rec.price_list_id,
                                             p_unit_of_measure_code => px_estimate_line_rec.unit_of_measure_code,
                                             p_currency_code        => px_estimate_line_rec.currency_code,
                                             p_quantity_required    => px_estimate_line_rec.estimate_quantity,
											 p_account_id			  => l_account_id,  /* bug#3875036 */
								     p_org_id   =>  px_estimate_line_rec.organization_id , -- Added for R12
                                             p_pricing_rec          => l_pricing_rec,
                                             x_selling_price        => px_estimate_line_rec.selling_price,
                                             x_return_status        => l_return_status,
											  x_msg_data             => l_msg_data,
											  x_msg_count            => l_msg_count);

    IF(l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
		RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF;

  IF   (px_estimate_line_rec.override_charge_flag <> 'Y') THEN
	  IF (l_contract_line_id IS NULL) THEN
	   px_estimate_line_rec.after_warranty_cost := px_estimate_line_rec.selling_price * px_estimate_line_rec.estimate_quantity;
	  ELSE
	-----------------------------------------------------------------------
	-- Get the discounted price by applying the contract defaulted from the
	--- repair order
	-----------------------------------------------------------------------
		Csd_Charge_Line_Util.GET_DISCOUNTEDPRICE(p_api_version         => 1.0,
                                         p_init_msg_list       => Fnd_Api.G_TRUE,
                                         p_contract_line_id    => l_contract_line_id,
                                         p_repair_type_id      => l_repair_type_id,
                                         p_txn_billing_type_id => px_estimate_line_rec.txn_billing_Type_id,
                                         p_coverage_txn_grp_id => px_estimate_line_rec.coverage_txn_group_id,
                                         p_extended_price      => px_estimate_line_rec.selling_price *
                                                                  px_estimate_line_rec.estimate_quantity,
                                         p_no_charge_flag      => px_estimate_line_rec.no_Charge_flag,
                                         x_discounted_price    => px_estimate_line_rec.after_warranty_cost,
                                         x_return_status       => l_return_status,
                                         x_msg_count           => l_msg_count,
                                         x_msg_data            => l_msg_data);

	IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
		Fnd_Message.set_name('CSD',                                                                                            'CSD_EST_ESTIMATED_CHARGE_ERR');
		Fnd_Message.set_token('CONTRACT_NUMBER',       px_estimate_line_rec.CONTRACT_NUMBER);
		Fnd_Msg_Pub.ADD      ;
		RAISE                 Fnd_Api.G_EXC_ERROR;
	END IF;
	END IF; END IF;

    IF (px_estimate_line_rec.no_Charge_flag = 'Y') THEN
       px_estimate_line_rec.after_warranty_cost := 0;
    END IF;

----------------------------------------------------------------------------------
-- Default the other fields in the estimate_line_rec
----------------------------------------------------------------------------------
	px_estimate_line_rec.est_line_source_type_code := 'MANUAL';
	px_estimate_line_rec.charge_line_type := 'ESTIMATE';
	px_estimate_line_rec.apply_contract_discount := 'N';

--------------------------------------------------------------------
-- Validate billing type and derive txn_billing_Type from
-- billing tpye and repair type_id
--------------------------------------------------------------------
    IF (NOT VALIDATE_BILLING_TYPE(l_billing_Type)) THEN
        debug('Invalid billing_type[' || l_billing_Type || ']');
        RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    px_estimate_line_rec.txn_billing_type_id := -1;
    FOR c1_rec IN CUR_TXN_BILLING_TYPE(l_repair_type_id, px_estimate_line_rec.billing_category, l_billing_type) LOOP
        px_estimate_line_rec.txn_billing_type_id := c1_rec.txn_billing_type_id;
    END LOOP;
    IF (px_estimate_line_rec.txn_billing_type_id = -1) THEN
        debug('txn billing_type_id[' || px_estimate_line_rec.txn_billing_type_id || '] is invlaid'); Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_TXN_BILLING_TYPE');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    -- Get the reference number from
    -- csi table and populate the instance_id/customer_product_id
	if(px_estimate_line_rec.serial_number is not null and
	    px_estimate_line_rec.inventory_item_id is not null) then
      FOR c2_rec IN CUR_ITEM_INSTANCE(px_estimate_line_rec.serial_number,
                                      px_estimate_line_rec.inventory_item_id) LOOP
        debug('instance id from serial number is[' || c2_rec.instance_id || ']');
        px_estimate_line_rec.instance_id    := c2_rec.instance_id;
        px_estimate_line_rec.customer_product_id := c2_rec.instance_id;
      END LOOP;
	End If;


END DEFAULT_EST_LINE_REC;

/*------------------------------------------------------------------------*/
/* procedure name: VALIDATE_DEFAULTED_EST_LINE                            */
/* DEscription: Validate the defaulted  estimates header record           */
/*                                                                        */
/*  Change History  : Created 25th June2005 by Vijay                      */
/*------------------------------------------------------------------------*/
PROCEDURE VALIDATE_DEFAULTED_EST_LINE(p_estimate_line_rec IN Csd_Repair_Estimate_Pub.estimate_line_Rec,
                                      p_validation_level  IN NUMBER) IS

  -- cursor to get the item attributes.
  -- revision control = 'N' when revision control_Code <>2
  -- serial_control = 'Y' when the serial_control_Code <>1 and <>6
  -- 1==> not serrialized 6 ==> serialized at sales order issue.
  CURSOR CUR_ITEM_ATTRIB(p_item_id NUMBER) IS
    SELECT DECODE(revision_qty_Control_code, 2, 'Y', 'N') revision_control,
           DECODE(serial_number_control_Code, 1, 'N', '6', 'N', 'Y') serial_control,
           comms_nl_trackable_Flag ib_control,
           primary_uom_code,
           material_billable_flag
      FROM mtl_system_items_b
     WHERE inventory_item_id = p_item_id
       AND organization_id = Cs_Std.GET_ITEM_VALDN_ORGZN_ID;


  l_revision_control VARCHAR2(1);
  l_serial_control   VARCHAR2(1);
  l_ib_control       VARCHAR2(1);
  l_billing_Type     VARCHAR2(1);
  l_uom_code         varchar2(10);

BEGIN

  --------------------------------------------------------------------
  -- Validate incident id status. Ensure that the SR status is not closed.
  --------------------------------------------------------------------
  IF (NOT VALIDATE_INCIDENT_ID(p_estimate_line_rec.incident_id)) THEN
    debug('Invalid incident id[' || p_estimate_line_rec.incident_id || ']');
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  --------------------------------------------------------------------
  -- Get the item  attributes and validate revision, serial number,
  -- and instance number and also get the primary uom if the uom
  -- in the input is null.
  -- this query gets the billing_type from item attributes.
  --------------------------------------------------------------------
  l_revision_Control := 'N';
  l_serial_control   := 'N';
  l_ib_control       := 'N';
  l_uom_code         := NULL;
  FOR c1_rec IN CUR_ITEM_ATTRIB(p_estimate_line_rec.inventory_item_id) LOOP
    l_revision_Control := c1_rec.revision_Control;
    l_serial_control   := c1_rec.serial_control;
    l_ib_control       := c1_rec.ib_control;
    l_uom_code         := c1_rec.primary_uom_code;
    l_billing_type     := c1_rec.material_billable_flag;
  END LOOP;

  debug('item[' || p_estimate_line_rec.inventory_item_id ||
        ']revision control[' || l_revision_control || ']' ||
        ']serial control[' || l_serial_control || ']');

		/****
  IF (p_estimate_line_rec.unit_of_measure_code IS NULL OR
     p_estimate_line_rec.unit_of_measure_code = Fnd_Api.G_MISS_CHAR) THEN
    p_estimate_line_rec.unit_of_measure_code := l_uom_Code;
  END IF;
  ***********/

  debug('serial number[' || p_estimate_line_rec.serial_number || ']');
  IF (l_revision_control = 'Y') THEN
    IF (p_estimate_line_rec.item_revision IS NOT NULL AND
       p_estimate_line_rec.item_revision <> Fnd_Api.G_MISS_CHAR AND
       NOT VALIDATE_REVISION(p_estimate_line_rec.item_revision,
                              p_estimate_line_rec.inventory_item_id,
                              Cs_Std.GET_ITEM_VALDN_ORGZN_ID)) THEN
      debug('Invalid revision[' || p_estimate_line_rec.item_revision || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF;

  IF (l_serial_control = 'Y') THEN
    IF (p_estimate_line_rec.serial_number IS NOT NULL AND
       p_estimate_line_rec.serial_number <> Fnd_Api.G_MISS_CHAR AND NOT
        VALIDATE_SERIAL_NUMBER(p_estimate_line_rec.serial_number,
                                                                                             p_estimate_line_rec.inventory_item_id)) THEN
      debug('Invalid serial number[' || p_estimate_line_rec.serial_number || ']');
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF;

END VALIDATE_DEFAULTED_EST_LINE;

/*------------------------------------------------------------------------*/
/* procedure name: COPY_EST_HDR_REC                            */
/* DEscription: Copy the input estimate record          */
/*                                                                        */
/*  Change History  : Created 25th June2005 by Vijay                      */
/*------------------------------------------------------------------------*/
--PROCEDURE COPY_EST_HDR_REC(

/*------------------------------------------------------------------------*/
/* procedure name: get_pricing_rec                            */
/* DEscription: Copy the pricing attributes into a separate rec           */
/*                                                                        */
/*  Change History  : Created 25th June2005 by Vijay                      */
/*------------------------------------------------------------------------*/
FUNCTION get_pricing_rec(p_estimate_line_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC)
  RETURN Csd_Process_Util.PRICING_ATTR_REC IS
  l_pricing_rec Csd_Process_Util.PRICING_ATTR_REC;
BEGIN
  l_pricing_rec.pricing_context      := p_estimate_line_rec.pricing_context;
  l_pricing_rec.pricing_attribute1   := p_estimate_line_rec.pricing_attribute1;
  l_pricing_rec.pricing_attribute2   := p_estimate_line_rec.pricing_attribute2;
  l_pricing_rec.pricing_attribute3   := p_estimate_line_rec.pricing_attribute3;
  l_pricing_rec.pricing_attribute4   := p_estimate_line_rec.pricing_attribute4;
  l_pricing_rec.pricing_attribute5   := p_estimate_line_rec.pricing_attribute5;
  l_pricing_rec.pricing_attribute6   := p_estimate_line_rec.pricing_attribute6;
  l_pricing_rec.pricing_attribute7   := p_estimate_line_rec.pricing_attribute7;
  l_pricing_rec.pricing_attribute8   := p_estimate_line_rec.pricing_attribute8;
  l_pricing_rec.pricing_attribute9   := p_estimate_line_rec.pricing_attribute9;
  l_pricing_rec.pricing_attribute10  := p_estimate_line_rec.pricing_attribute10;
  l_pricing_rec.pricing_attribute11  := p_estimate_line_rec.pricing_attribute11;
  l_pricing_rec.pricing_attribute12  := p_estimate_line_rec.pricing_attribute12;
  l_pricing_rec.pricing_attribute13  := p_estimate_line_rec.pricing_attribute13;
  l_pricing_rec.pricing_attribute14  := p_estimate_line_rec.pricing_attribute14;
  l_pricing_rec.pricing_attribute15  := p_estimate_line_rec.pricing_attribute15;
  l_pricing_rec.pricing_attribute16  := p_estimate_line_rec.pricing_attribute16;
  l_pricing_rec.pricing_attribute17  := p_estimate_line_rec.pricing_attribute17;
  l_pricing_rec.pricing_attribute18  := p_estimate_line_rec.pricing_attribute18;
  l_pricing_rec.pricing_attribute19  := p_estimate_line_rec.pricing_attribute19;
  l_pricing_rec.pricing_attribute20  := p_estimate_line_rec.pricing_attribute20;
  l_pricing_rec.pricing_attribute21  := p_estimate_line_rec.pricing_attribute21;
  l_pricing_rec.pricing_attribute22  := p_estimate_line_rec.pricing_attribute22;
  l_pricing_rec.pricing_attribute23  := p_estimate_line_rec.pricing_attribute23;
  l_pricing_rec.pricing_attribute24  := p_estimate_line_rec.pricing_attribute24;
  l_pricing_rec.pricing_attribute25  := p_estimate_line_rec.pricing_attribute25;
  l_pricing_rec.pricing_attribute26  := p_estimate_line_rec.pricing_attribute26;
  l_pricing_rec.pricing_attribute27  := p_estimate_line_rec.pricing_attribute27;
  l_pricing_rec.pricing_attribute28  := p_estimate_line_rec.pricing_attribute28;
  l_pricing_rec.pricing_attribute29  := p_estimate_line_rec.pricing_attribute29;
  l_pricing_rec.pricing_attribute30  := p_estimate_line_rec.pricing_attribute30;
  l_pricing_rec.pricing_attribute31  := p_estimate_line_rec.pricing_attribute31;
  l_pricing_rec.pricing_attribute32  := p_estimate_line_rec.pricing_attribute32;
  l_pricing_rec.pricing_attribute33  := p_estimate_line_rec.pricing_attribute33;
  l_pricing_rec.pricing_attribute34  := p_estimate_line_rec.pricing_attribute34;
  l_pricing_rec.pricing_attribute35  := p_estimate_line_rec.pricing_attribute35;
  l_pricing_rec.pricing_attribute36  := p_estimate_line_rec.pricing_attribute36;
  l_pricing_rec.pricing_attribute37  := p_estimate_line_rec.pricing_attribute37;
  l_pricing_rec.pricing_attribute38  := p_estimate_line_rec.pricing_attribute38;
  l_pricing_rec.pricing_attribute39  := p_estimate_line_rec.pricing_attribute39;
  l_pricing_rec.pricing_attribute40  := p_estimate_line_rec.pricing_attribute40;
  l_pricing_rec.pricing_attribute41  := p_estimate_line_rec.pricing_attribute41;
  l_pricing_rec.pricing_attribute42  := p_estimate_line_rec.pricing_attribute42;
  l_pricing_rec.pricing_attribute43  := p_estimate_line_rec.pricing_attribute43;
  l_pricing_rec.pricing_attribute44  := p_estimate_line_rec.pricing_attribute44;
  l_pricing_rec.pricing_attribute45  := p_estimate_line_rec.pricing_attribute45;
  l_pricing_rec.pricing_attribute46  := p_estimate_line_rec.pricing_attribute46;
  l_pricing_rec.pricing_attribute47  := p_estimate_line_rec.pricing_attribute47;
  l_pricing_rec.pricing_attribute48  := p_estimate_line_rec.pricing_attribute48;
  l_pricing_rec.pricing_attribute49  := p_estimate_line_rec.pricing_attribute49;
  l_pricing_rec.pricing_attribute50  := p_estimate_line_rec.pricing_attribute50;
  l_pricing_rec.pricing_attribute51  := p_estimate_line_rec.pricing_attribute51;
  l_pricing_rec.pricing_attribute52  := p_estimate_line_rec.pricing_attribute52;
  l_pricing_rec.pricing_attribute53  := p_estimate_line_rec.pricing_attribute53;
  l_pricing_rec.pricing_attribute54  := p_estimate_line_rec.pricing_attribute54;
  l_pricing_rec.pricing_attribute55  := p_estimate_line_rec.pricing_attribute55;
  l_pricing_rec.pricing_attribute56  := p_estimate_line_rec.pricing_attribute56;
  l_pricing_rec.pricing_attribute57  := p_estimate_line_rec.pricing_attribute57;
  l_pricing_rec.pricing_attribute58  := p_estimate_line_rec.pricing_attribute58;
  l_pricing_rec.pricing_attribute59  := p_estimate_line_rec.pricing_attribute59;
  l_pricing_rec.pricing_attribute60  := p_estimate_line_rec.pricing_attribute60;
  l_pricing_rec.pricing_attribute61  := p_estimate_line_rec.pricing_attribute61;
  l_pricing_rec.pricing_attribute62  := p_estimate_line_rec.pricing_attribute62;
  l_pricing_rec.pricing_attribute63  := p_estimate_line_rec.pricing_attribute63;
  l_pricing_rec.pricing_attribute64  := p_estimate_line_rec.pricing_attribute64;
  l_pricing_rec.pricing_attribute65  := p_estimate_line_rec.pricing_attribute65;
  l_pricing_rec.pricing_attribute66  := p_estimate_line_rec.pricing_attribute66;
  l_pricing_rec.pricing_attribute67  := p_estimate_line_rec.pricing_attribute67;
  l_pricing_rec.pricing_attribute68  := p_estimate_line_rec.pricing_attribute68;
  l_pricing_rec.pricing_attribute69  := p_estimate_line_rec.pricing_attribute69;
  l_pricing_rec.pricing_attribute70  := p_estimate_line_rec.pricing_attribute70;
  l_pricing_rec.pricing_attribute71  := p_estimate_line_rec.pricing_attribute71;
  l_pricing_rec.pricing_attribute72  := p_estimate_line_rec.pricing_attribute72;
  l_pricing_rec.pricing_attribute73  := p_estimate_line_rec.pricing_attribute73;
  l_pricing_rec.pricing_attribute74  := p_estimate_line_rec.pricing_attribute74;
  l_pricing_rec.pricing_attribute75  := p_estimate_line_rec.pricing_attribute75;
  l_pricing_rec.pricing_attribute76  := p_estimate_line_rec.pricing_attribute76;
  l_pricing_rec.pricing_attribute77  := p_estimate_line_rec.pricing_attribute77;
  l_pricing_rec.pricing_attribute78  := p_estimate_line_rec.pricing_attribute78;
  l_pricing_rec.pricing_attribute79  := p_estimate_line_rec.pricing_attribute79;
  l_pricing_rec.pricing_attribute80  := p_estimate_line_rec.pricing_attribute80;
  l_pricing_rec.pricing_attribute81  := p_estimate_line_rec.pricing_attribute81;
  l_pricing_rec.pricing_attribute82  := p_estimate_line_rec.pricing_attribute82;
  l_pricing_rec.pricing_attribute83  := p_estimate_line_rec.pricing_attribute83;
  l_pricing_rec.pricing_attribute84  := p_estimate_line_rec.pricing_attribute84;
  l_pricing_rec.pricing_attribute85  := p_estimate_line_rec.pricing_attribute85;
  l_pricing_rec.pricing_attribute86  := p_estimate_line_rec.pricing_attribute86;
  l_pricing_rec.pricing_attribute87  := p_estimate_line_rec.pricing_attribute87;
  l_pricing_rec.pricing_attribute88  := p_estimate_line_rec.pricing_attribute88;
  l_pricing_rec.pricing_attribute89  := p_estimate_line_rec.pricing_attribute89;
  l_pricing_rec.pricing_attribute90  := p_estimate_line_rec.pricing_attribute90;
  l_pricing_rec.pricing_attribute91  := p_estimate_line_rec.pricing_attribute91;
  l_pricing_rec.pricing_attribute92  := p_estimate_line_rec.pricing_attribute92;
  l_pricing_rec.pricing_attribute93  := p_estimate_line_rec.pricing_attribute93;
  l_pricing_rec.pricing_attribute94  := p_estimate_line_rec.pricing_attribute94;
  l_pricing_rec.pricing_attribute95  := p_estimate_line_rec.pricing_attribute95;
  l_pricing_rec.pricing_attribute96  := p_estimate_line_rec.pricing_attribute96;
  l_pricing_rec.pricing_attribute97  := p_estimate_line_rec.pricing_attribute97;
  l_pricing_rec.pricing_attribute98  := p_estimate_line_rec.pricing_attribute98;
  l_pricing_rec.pricing_attribute99  := p_estimate_line_rec.pricing_attribute99;
  l_pricing_rec.pricing_attribute100 := p_estimate_line_rec.pricing_attribute100;

END;

END Csd_Estimate_Utils_Pvt;

/
