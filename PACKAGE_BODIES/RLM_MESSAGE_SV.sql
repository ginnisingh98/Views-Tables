--------------------------------------------------------
--  DDL for Package Body RLM_MESSAGE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_MESSAGE_SV" as
/* $Header: RLMCOMSB.pls 120.2.12000000.2 2007/09/03 13:52:41 sunilku ship $ */
/*==========================  rlm_message_sv  ============================*/

/*===========================================================================

  PROCEDURE NAME:	app_error
  app_error will just put in the details in the g_message_tab
  all the values will be written to the table at one shot when the dump messages
  is called after a group of records is processed
  --
  The validation type variable which is accepted in this proc will be used to
  update the dependency table with an error for that validationType
  a null could be passed in to the validation type and then no dependency check
  will be done
===========================================================================*/
-- added grouping info for bug 4198330

PROCEDURE app_error (x_ExceptionLevel      IN  VARCHAR2,
		     x_MessageName         IN  VARCHAR2,
                     x_ChildMessageName    IN  VARCHAR2,
		     x_InterfaceHeaderId   IN  NUMBER,
		     x_InterfaceLineId	   IN  NUMBER,
		     x_ScheduleHeaderId	   IN  NUMBER,
		     x_ScheduleLineId	   IN  NUMBER,
		     x_OrderHeaderId	   IN  NUMBER,
		     x_OrderLineId	   IN  NUMBER,
		     x_ErrorText           IN  VARCHAR2,
		     x_ValidationType      IN  VARCHAR2,
		     x_GroupInfo	   IN  BOOLEAN,
                     x_ShipfromOrgId       IN  NUMBER,
                     x_ShipToAddressId     IN  NUMBER,
                     x_CustomerItemId      IN  NUMBER,
                     x_InventoryItemId     IN  NUMBER,
                     x_token1      IN  VARCHAR2,
                     x_value1      IN  VARCHAR2,
                     x_token2      IN  VARCHAR2,
                     x_value2      IN  VARCHAR2,
                     x_token3      IN  VARCHAR2,
                     x_value3      IN  VARCHAR2,
                     x_token4      IN  VARCHAR2,
                     x_value4      IN  VARCHAR2,
                     x_token5      IN  VARCHAR2,
                     x_value5      IN  VARCHAR2,
                     x_token6      IN  VARCHAR2,
                     x_value6      IN  VARCHAR2,
                     x_token7      IN  VARCHAR2, -- Bug 4297984
                     x_value7      IN  VARCHAR2,
                     x_token8      IN  VARCHAR2,
                     x_value8      IN  VARCHAR2,
                     x_token9      IN  VARCHAR2,
                     x_value9      IN  VARCHAR2,
                     x_token10     IN  VARCHAR2,
                     x_value10     IN  VARCHAR2)

IS

x_text		VARCHAR2(2000) := NULL;
v_progress 	VARCHAR2(3) := '010';
v_message_rec t_message_rec;
v_incr NUMBER;
--
BEGIN

    v_message_rec.exception_level := x_ExceptionLevel;
    v_message_rec.message_name := x_MessageName;
    v_message_rec.child_message_name := x_ChildMessageName;
    v_message_rec.error_text := x_ErrorText;
    v_message_rec.interface_header_id := x_InterfaceHeaderId;
    v_message_rec.interface_line_id := x_InterfaceLineId;
    v_message_rec.schedule_header_id := x_ScheduleHeaderId;
    v_message_rec.schedule_line_id := x_ScheduleLineId;
    v_message_rec.order_header_id := x_OrderHeaderId;
    v_message_rec.order_line_id := x_OrderLineId;
    v_message_rec.group_Info    := x_GroupInfo;
    /* Bug 4198330 */
    v_message_rec.ship_from_org_id  := x_ShipFromOrgId;
    v_message_rec.ship_to_address_id := x_ShipToAddressId;
    v_message_rec.customer_item_id   := x_CustomerItemId;
    v_message_rec.inventory_item_id := x_InventoryItemId;
    --
    -- This is for conditions when the user will not have any error codes
    -- defined and the app error is called directly with the text in the
    -- message
    --
    IF x_ErrorText is null THEN
      --
      get_msg_text(x_MessageName,
                   v_message_rec.error_text,
                   x_token1,
                   x_value1,
                   x_token2,
                   x_value2,
                   x_token3,
                   x_value3,
                   x_token4,
                   x_value4,
                   x_token5,
                   x_value5,
                   x_token6,
                   x_value6,
                   x_token7, -- Bug 4297984
                   x_value7,
                   x_token8,
                   x_value8,
                   x_token9,
                   x_value9,
                   x_token10,
                   x_value10);

     --  v_message_rec.error_text := x_MessageName || ': ' ||  v_message_rec.error_text;
      --
    ELSE
       v_message_rec.error_text :=  x_ErrorText;
    END IF;
    --
    v_incr := g_message_tab.COUNT + 1;
    --
    -- set the message in the table
    --
    g_message_tab(v_incr) := v_message_rec;
    --
    IF x_ValidationType IS NOT NULL THEN
      --
      -- set the dependent error for this val type
      set_dependent_error(x_ValidationType);
      --
    END IF;
    --
EXCEPTION
  WHEN OTHERS THEN
    sql_error('rlm_message_sv.app_error', v_progress);
    RAISE;

END app_error;




/*===========================================================================

  PROCEDURE NAME:	app_purge_error

===========================================================================*/


PROCEDURE app_purge_error (x_ExceptionLevel      IN  VARCHAR2,
		     x_MessageName         IN  VARCHAR2,
		     x_ErrorText           IN  VARCHAR2,
                     x_ChildMessageName    IN  VARCHAR2,
		     x_InterfaceHeaderId   IN  NUMBER,
		     x_InterfaceLineId	   IN  NUMBER,
		     x_ScheduleHeaderId	   IN  NUMBER,
		     x_ScheduleLineId	   IN  NUMBER,
		     x_OrderHeaderId	   IN  NUMBER,
		     x_OrderLineId	   IN  NUMBER,
                     x_ScheduleLineNum     IN  NUMBER, --bugfix 6319027
		     x_ValidationType      IN  VARCHAR2,
                     x_token1      IN  VARCHAR2,
                     x_value1      IN  VARCHAR2,
                     x_token2      IN  VARCHAR2,
                     x_value2      IN  VARCHAR2,
                     x_token3      IN  VARCHAR2,
                     x_value3      IN  VARCHAR2,
                     x_token4      IN  VARCHAR2,
                     x_value4      IN  VARCHAR2,
                     x_token5      IN  VARCHAR2,
                     x_value5      IN  VARCHAR2,
                     x_token6      IN  VARCHAR2,
                     x_value6      IN  VARCHAR2,
                     x_token7      IN  VARCHAR2, -- Bug 4297984
                     x_value7      IN  VARCHAR2,
                     x_token8      IN  VARCHAR2,
                     x_value8      IN  VARCHAR2,
                     x_token9      IN  VARCHAR2,
                     x_value9      IN  VARCHAR2,
                     x_token10     IN  VARCHAR2,
                     x_value10     IN  VARCHAR2,
           	     x_user_id             IN  NUMBER,
                     x_conc_req_id         IN  NUMBER,
                     x_prog_appl_id        IN  NUMBER,
                     x_conc_program_id     IN  NUMBER,
                     x_PurgeStatus         IN  VARCHAR2,
                     x_PurgeExp_rec        IN  t_PurExp_rec)

IS

x_text		VARCHAR2(2000) := NULL;
v_message_rec   t_message_rec;
v_conc_req	NUMBER;
v_purge         VARCHAR2(255);
v_purge_rec     t_PurExp_rec;

--
BEGIN

    v_message_rec.exception_level := x_ExceptionLevel;
    v_message_rec.message_name := x_MessageName;
    v_message_rec.child_message_name := x_ChildMessageName;
    v_message_rec.error_text := x_ErrorText;
    v_message_rec.interface_header_id := x_InterfaceHeaderId;
    v_message_rec.interface_line_id := x_InterfaceLineId;
    v_message_rec.schedule_header_id := x_ScheduleHeaderId;
    v_message_rec.schedule_line_id := x_ScheduleLineId;
    v_message_rec.order_header_id := x_OrderHeaderId;
    v_message_rec.order_line_id := x_OrderLineId;
    v_message_rec.Schedule_line_number := x_ScheduleLineNum; --bugfix 6319027
    v_conc_req := x_conc_req_id;
    v_purge := x_PurgeStatus;
    v_purge_rec := x_PurgeExp_rec;

    IF x_MessageName is not null THEN
      --
      get_msg_text(x_MessageName,
                   v_message_rec.error_text,
                   x_token1,
                   x_value1,
                   x_token2,
                   x_value2,
                   x_token3,
                   x_value3,
                   x_token4,
                   x_value4,
                   x_token5,
                   x_value5,
                   x_token6,
                   x_value6,
                   x_token7, -- Bug 4297984
                   x_value7,
                   x_token8,
                   x_value8,
                   x_token9,
                   x_value9,
                   x_token10,
                   x_value10);

      rlm_message_sv.insert_purge_row (x_ExceptionLevel =>v_message_rec.exception_level,
                                       x_MessageName =>v_message_rec.message_name,
                                       x_ErrorText =>v_message_rec.error_text,
                                       x_ScheduleHeaderId =>v_message_rec.schedule_header_id,
                                       x_ScheduleLineId =>v_message_rec.schedule_line_id,
                                       x_OrderHeaderId =>v_message_rec.order_header_id,
                                       x_OrderLineId => v_message_rec.order_line_id,
                                       x_ScheduleLineNum => v_message_rec.Schedule_line_number, --bugfix 6319027
                                       x_conc_req_id =>v_conc_req ,
                                       x_PurgeStatus =>v_purge ,
                                       x_PurgeExp_rec=>v_purge_rec );




    END IF;
    --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END app_purge_error;



/*===========================================================================

  PROCEDURE NAME:	get_msg_text

===========================================================================*/

PROCEDURE get_msg_text (x_message_name  IN      VARCHAR2,
			x_text	      IN OUT NOCOPY  VARCHAR2,
			x_token1      IN      VARCHAR2,
			x_value1      IN      VARCHAR2,
			x_token2      IN      VARCHAR2,
			x_value2      IN      VARCHAR2,
			x_token3      IN      VARCHAR2,
			x_value3      IN      VARCHAR2,
			x_token4      IN      VARCHAR2,
			x_value4      IN      VARCHAR2,
			x_token5      IN      VARCHAR2,
			x_value5      IN      VARCHAR2,
			x_token6      IN      VARCHAR2,
                        x_value6      IN      VARCHAR2,
                        x_token7      IN      VARCHAR2, -- Bug 4297984
                        x_value7      IN      VARCHAR2,
                        x_token8      IN      VARCHAR2,
                        x_value8      IN      VARCHAR2,
                        x_token9      IN      VARCHAR2,
                        x_value9      IN      VARCHAR2,
                        x_token10     IN      VARCHAR2,
                        x_value10     IN      VARCHAR2
)

IS
BEGIN

       /*
       ** Build the message string.
       */

       fnd_message.set_name ('RLM', x_message_name);

       /*
       ** Replace the tokens.
       */

       IF (x_token1 is NULL) THEN
	 null;

       ELSIF (x_token2 is NULL) THEN
         fnd_message.set_token (x_token1, SUBSTR(x_value1,1,2000));
         null;

       ELSIF (x_token3 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 null;
	 fnd_message.set_token (x_token2, x_value2);

       ELSIF (x_token4 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
null;

       ELSIF (x_token5 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
 	 fnd_message.set_token (x_token4, x_value4);
null;

       ELSIF (x_token6 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
 	 fnd_message.set_token (x_token4, x_value4);
	 fnd_message.set_token (x_token5, x_value5);
null;
      -- Bug 4297984
       ELSIF (x_token7 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
 	 fnd_message.set_token (x_token4, x_value4);
	 fnd_message.set_token (x_token5, x_value5);
 	 fnd_message.set_token (x_token6, x_value6);
null;

       ELSIF (x_token8 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
 	 fnd_message.set_token (x_token4, x_value4);
	 fnd_message.set_token (x_token5, x_value5);
 	 fnd_message.set_token (x_token6, x_value6);
 	 fnd_message.set_token (x_token7, x_value7);
null;

       ELSIF (x_token9 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
 	 fnd_message.set_token (x_token4, x_value4);
	 fnd_message.set_token (x_token5, x_value5);
 	 fnd_message.set_token (x_token6, x_value6);
 	 fnd_message.set_token (x_token7, x_value7);
 	 fnd_message.set_token (x_token8, x_value8);
null;

       ELSIF (x_token10 is NULL) THEN
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
 	 fnd_message.set_token (x_token4, x_value4);
	 fnd_message.set_token (x_token5, x_value5);
 	 fnd_message.set_token (x_token6, x_value6);
 	 fnd_message.set_token (x_token7, x_value7);
 	 fnd_message.set_token (x_token8, x_value8);
	 fnd_message.set_token (x_token9, x_value9);
null;

       ELSE
	 fnd_message.set_token (x_token1, x_value1);
	 fnd_message.set_token (x_token2, x_value2);
	 fnd_message.set_token (x_token3, x_value3);
 	 fnd_message.set_token (x_token4, x_value4);
	 fnd_message.set_token (x_token5, x_value5);
	 fnd_message.set_token (x_token6, x_value6);
 	 fnd_message.set_token (x_token7, x_value7);
 	 fnd_message.set_token (x_token8, x_value8);
 	 fnd_message.set_token (x_token9, x_value9);
 	 fnd_message.set_token (x_token10, x_value10);
null;

       END IF;

       /*
       ** Retrieve the error message.
       */

       x_text := fnd_message.get;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_msg_text;

/*===========================================================================

  PROCEDURE NAME:	insert_row

===========================================================================*/

PROCEDURE insert_row (
           x_ExceptionLevel      IN  VARCHAR2,
           x_MessageName         IN  VARCHAR2,
           x_ErrorText           IN  VARCHAR2,
           x_InterfaceHeaderId   IN  NUMBER,
           x_InterfaceLineId     IN  NUMBER,
           x_ScheduleHeaderId    IN  NUMBER,
           x_ScheduleLineId      IN  NUMBER,
           x_OrderHeaderId       IN  NUMBER,
           x_OrderLineId         IN  NUMBER,
           x_GroupInfo           IN  BOOLEAN,
           x_user_id             IN  NUMBER,
           x_conc_req_id         IN  NUMBER,
           x_prog_appl_id        IN  NUMBER,
           x_conc_program_id     IN  NUMBER,
           x_PurgeStatus         IN VARCHAR2
           )

IS
  --
  v_MessageText  	VARCHAR2(5000) := NULL;
  v_ExceptionId		NUMBER 	       := NULL;
  v_progress		VARCHAR2(3)    := '010';
  v_info_txt		VARCHAR2(2000) := NULL;
  v_warn_txt		VARCHAR2(2000) := NULL;
  v_error_txt		VARCHAR2(2000) := NULL;
  v_ProgramDate		DATE	       := NULL;
  v_LoginId 		NUMBER	       := fnd_global.login_id;
  v_inv_item     	VARCHAR2(50);
  v_Exception_rec 	t_exception_rec;
  v_Exception_rec1 	t_exception_rec;
  v_shipTo		hz_cust_acct_sites.ece_tp_location_code%TYPE;
  v_BillTo		hz_cust_acct_sites.ece_tp_location_code%TYPE;
  v_IntrmdShipTo        hz_cust_acct_sites.ece_tp_location_code%TYPE;
  --
  --C_SDEBUG              NUMBER :=rlm_core_sv.C_LEVEL5;
  --C_DEBUG               NUMBER :=rlm_core_sv.C_LEVEL6;
  --
  CURSOR c_GetShipTo IS
  SELECT ece_tp_location_code
  FROM hz_cust_acct_sites_all acct_site,
       rlm_interface_lines_all lines
  WHERE lines.ship_to_address_id = acct_site.cust_acct_site_id
  AND lines.line_id = x_InterfaceLineId;
  --
  CURSOR c_GetBillTo IS
  SELECT ece_tp_location_code
  FROM hz_cust_acct_sites_all acct_site,
       rlm_interface_lines_all lines
  WHERE lines.bill_to_address_id = acct_site.cust_acct_site_id
  AND lines.line_id = x_InterfaceLineId;
  --
  CURSOR c_GetIntrmdShipTo IS
  SELECT ece_tp_location_code
  FROM hz_cust_acct_sites_all acct_site,
       rlm_interface_lines_all lines
  WHERE lines.intrmd_ship_to_id = acct_site.cust_acct_site_id
  AND lines.line_id = x_InterfaceLineId;
  --
  -- Following cursor is changed as per TCA obsolescence project.
  CURSOR c_Excep_Int IS
  SELECT PARTY.PARTY_NAME  customer_name,
         rih.ECE_TP_TRANSLATOR_CODE ,
         rih.ECE_TP_LOCATION_CODE_EXT ,
         rih.EDI_CONTROL_NUM_3 ,
         rih.EDI_TEST_INDICATOR ,
         rih.SCHED_GENERATION_DATE ,
         rih.SCHEDULE_REFERENCE_NUM ,
         rih.SCHEDULE_SOURCE ,
         rih.SCHEDULE_TYPE ,
         rih.SCHEDULE_PURPOSE ,
         rih.SCHED_HORIZON_START_DATE ,
         rih.SCHED_HORIZON_END_DATE ,
         ril.CUST_SHIP_FROM_ORG_EXT ,
         ril.LINE_NUMBER ,
         ril.SCHEDULE_ITEM_NUM ,
         mtl.customer_item_number ,
         ril.ITEM_DESCRIPTION_EXT ,
         ril.CUST_UOM_EXT ,
         ril.SUPPLIER_ITEM_EXT ,
         ril.ITEM_DETAIL_TYPE ,
         ril.ITEM_DETAIL_SUBTYPE ,
         ril.ITEM_DETAIL_QUANTITY ,
         ril.START_DATE_TIME ,
         ril.CUSTOMER_JOB ,
         ril.CUST_MODEL_SERIAL_NUMBER ,
         ril.CUST_PRODUCTION_SEQ_NUM ,
         ril.DATE_TYPE_CODE ,
         ril.QTY_TYPE_CODE ,
	 ril.LINE_NUMBER ,
	 ril.REQUEST_DATE ,
	 ril.SCHEDULE_DATE ,
	 ril.CUST_PO_NUMBER ,
	 ril.INDUSTRY_ATTRIBUTE1 ,
	 ril.CUST_PRODUCTION_LINE ,
	 ril.CUSTOMER_DOCK_CODE ,
	 ril.SCHEDULE_LINE_ID
  FROM   rlm_interface_headers   rih,
         rlm_interface_lines_all  ril,
         HZ_PARTIES PARTY,
         HZ_CUST_ACCOUNTS CUST_ACCT,
         mtl_customer_items  mtl
  WHERE  rih.ORG_ID = ril.ORG_ID
  AND    rih.header_id = x_InterfaceHeaderId
  AND    ril.line_id = x_InterfaceLineId
  AND    rih.header_id = ril.header_id
  And    CUST_ACCT.PARTY_ID = PARTY.PARTY_ID (+)
  AND    rih.customer_id = CUST_ACCT.PARTY_ID (+)
  AND    ril.customer_item_id = mtl.customer_item_id (+);
  --
  -- when no line_id is passed this cursor becomes active
  -- Following cursor is changed as per TCA obsolescence project.
  --
  CURSOR c_Excep_Int1 IS
  SELECT PARTY.PARTY_NAME  customer_name,
         rih.ECE_TP_TRANSLATOR_CODE ,
         rih.ECE_TP_LOCATION_CODE_EXT ,
         rih.EDI_CONTROL_NUM_3 ,
         rih.EDI_TEST_INDICATOR ,
         rih.SCHED_GENERATION_DATE ,
         rih.SCHEDULE_REFERENCE_NUM ,
         rih.SCHEDULE_SOURCE ,
         rih.SCHEDULE_TYPE ,
         rih.SCHEDULE_PURPOSE ,
         rih.SCHED_HORIZON_START_DATE ,
         rih.SCHED_HORIZON_END_DATE ,
         NULL,--ril.CUST_SHIP_FROM_ORG_EXT ,
         NULL,--ril.LINE_NUMBER ,
         NULL,--ril.SCHEDULE_ITEM_NUM ,
         NULL,--mtl.customer_item_number ,
         NULL,--ril.ITEM_DESCRIPTION_EXT ,
         NULL,--ril.CUST_UOM_EXT ,
         NULL,--ril.SUPPLIER_ITEM_EXT ,
         NULL,--ril.ITEM_DETAIL_TYPE ,
         NULL,--ril.ITEM_DETAIL_SUBTYPE ,
         NULL,--ril.ITEM_DETAIL_QUANTITY ,
         NULL,--ril.START_DATE_TIME ,
         NULL,--ril.CUSTOMER_JOB ,
         NULL,--ril.CUST_MODEL_SERIAL_NUMBER ,
         NULL,--ril.CUST_PRODUCTION_SEQ_NUM ,
         NULL,--ril.DATE_TYPE_CODE ,
         NULL,--ril.QTY_TYPE_CODE ,
         NULL,--ril.LINE_NUMBER ,
	 NULL,--ril.REQUEST_DATE ,
	 NULL,--ril.SCHEDULE_DATE ,
	 NULL,--ril.CUST_PO_NUMBER ,
	 NULL,--ril.INDUSTRY_ATTRIBUTE1 ,
	 NULL,--ril.CUST_PRODUCTION_LINE ,
	 NULL,--ril.CUSTOMER_DOCK_CODE ,
	 NULL --ril.SCHEDULE_LINE_ID
  FROM   rlm_interface_headers rih,
         HZ_PARTIES PARTY,
         HZ_CUST_ACCOUNTS CUST_ACCT
  WHERE  rih.header_id = x_InterfaceHeaderId
  AND    CUST_ACCT.PARTY_ID = PARTY.PARTY_ID (+)
  AND    rih.customer_id = cust_acct.cust_account_id (+);
  --
  --
  -- Bug 2778186 : When group Info is required, this cursor will be used.
  --
  -- Following cursor is changed as per TCA obsolescence project.
  CURSOR c_Excep_Int2 IS
  SELECT PARTY.PARTY_NAME customer_name,
         rih.ECE_TP_TRANSLATOR_CODE ,
         rih.ECE_TP_LOCATION_CODE_EXT ,
         rih.EDI_CONTROL_NUM_3 ,
         rih.EDI_TEST_INDICATOR ,
         rih.SCHED_GENERATION_DATE ,
         rih.SCHEDULE_REFERENCE_NUM ,
         rih.SCHEDULE_SOURCE ,
         rih.SCHEDULE_TYPE ,
         rih.SCHEDULE_PURPOSE ,
         rih.SCHED_HORIZON_START_DATE ,
         rih.SCHED_HORIZON_END_DATE ,
         ril.CUST_SHIP_FROM_ORG_EXT ,
         NULL, --ril.LINE_NUMBER ,
         ril.SCHEDULE_ITEM_NUM ,
         mtl.customer_item_number ,
         ril.ITEM_DESCRIPTION_EXT ,
         NULL, --ril.CUST_UOM_EXT ,
         ril.SUPPLIER_ITEM_EXT ,
         NULL, --ril.ITEM_DETAIL_TYPE ,
         NULL, --ril.ITEM_DETAIL_SUBTYPE ,
         NULL, --ril.ITEM_DETAIL_QUANTITY ,
         NULL, --ril.START_DATE_TIME ,
         NULL, --ril.CUSTOMER_JOB ,
         NULL, --ril.CUST_MODEL_SERIAL_NUMBER ,
         NULL, --ril.CUST_PRODUCTION_SEQ_NUM ,
         NULL, --ril.DATE_TYPE_CODE ,
         NULL, --ril.QTY_TYPE_CODE ,
	 NULL, --ril.LINE_NUMBER ,
	 NULL, --ril.REQUEST_DATE ,
	 NULL, --ril.SCHEDULE_DATE ,
	 NULL, --ril.CUST_PO_NUMBER ,
	 NULL, --ril.INDUSTRY_ATTRIBUTE1 ,
	 NULL, --ril.CUST_PRODUCTION_LINE ,
	 NULL, --ril.CUSTOMER_DOCK_CODE ,
	 NULL --ril.SCHEDULE_LINE_ID
  FROM   rlm_interface_headers rih,
         rlm_interface_lines_all  ril,
         HZ_PARTIES PARTY,
         HZ_CUST_ACCOUNTS CUST_ACCT,
         mtl_customer_items  mtl
  WHERE  rih.ORG_ID = ril.ORG_ID
  AND    rih.header_id = x_InterfaceHeaderId
  AND    ril.line_id = x_InterfaceLineId
  AND    rih.header_id = ril.header_id
  AND    CUST_ACCT.PARTY_ID = PARTY.PARTY_ID (+)
  AND    rih.customer_id = CUST_ACCT.PARTY_ID (+)
  AND    ril.customer_item_id = mtl.customer_item_id (+);
  --
BEGIN
  --
  /*
   ** Retrieve translated message for 'Error'
   ** and 'Warning' if required.
   */

  /*
   ** Complete the message string by substituting
   ** tokens.
   */
  --
  IF (x_ExceptionLevel = g_error) THEN
   --
   fnd_message.set_name ('RLM', 'RLM_ERROR');
   v_error_txt := fnd_message.get;
   v_MessageText :=  v_error_txt ||': ' || x_ErrorText;
   g_error_flag := 'Y';
   --
  ELSIF (x_ExceptionLevel = g_warn) THEN
   --
   fnd_message.set_name ('RLM', 'RLM_WARNING');
   v_warn_txt := fnd_message.get;
   v_MessageText :=  v_warn_txt ||': '|| x_ErrorText;
   g_warn_flag := 'Y';
   --
  ELSIF (x_ExceptionLevel = g_info) THEN
   --
   fnd_message.set_name ('RLM', 'RLM_INFORMATION');
   v_info_txt := fnd_message.get;
   v_MessageText := v_info_txt ||': ' || x_ErrorText;
   g_info_flag := 'Y';
   --
  END IF;
  --
  /*
   ** Obtain the exception id from the
   ** sequence rlm_demand_exceptions_s .
   */
  --
  SELECT rlm_demand_exceptions_s.nextval
  INTO   v_ExceptionId
  FROM   sys.dual;
  --
  /*
   ** Program update date should be populated
   ** if called from a concurrent program.
   */
  --
  IF (fnd_global.conc_request_id IS NOT NULL) THEN
    v_ProgramDate := sysdate;
    v_LoginId	:= fnd_global.conc_login_id;
  END IF;
  --
  /*
   ** Select record.
   */
  v_progress := '015';
  --
  IF (x_InterfaceLineId IS NOT NULL) THEN
   --
   OPEN c_GetShipTo;
   FETCH c_GetShipTo INTO v_ShipTo;
   CLOSE c_GetShipTo;
   --
   OPEN c_GetBillTo;
   FETCH c_GetBillTo INTO v_BillTo;
   CLOSE c_GetBillTo;
   --
   OPEN c_GetIntrmdShipTo;
   FETCH c_GetIntrmdShipTo INTO v_IntrmdShipTo;
   CLOSE c_GetIntrmdShipTo;
   --
  END IF;
  --
  IF x_GroupInfo THEN
   --
   OPEN c_Excep_Int2;
   FETCH c_Excep_Int2 INTO v_Exception_rec;
   CLOSE c_Excep_Int2;
   --
  ELSIF (x_InterfaceLineId is NOT NULL) THEN
   --
   OPEN c_Excep_Int;
   FETCH c_Excep_int INTO v_Exception_rec;
   CLOSE c_Excep_Int;
   --
  ELSE
   --
   OPEN c_Excep_Int1;
   FETCH c_Excep_Int1 INTO v_Exception_rec;
   CLOSE c_Excep_Int1;
   --
  END IF;
  --
  /*
   ** Insert record.
   */
  --
  v_progress := '020';
  --
  --  get the inventory item for the exception report
  --
  BEGIN
    --
    SELECT a.item_number
    INTO v_inv_item
    FROM mtl_item_flexfields a,
         mtl_customer_item_xrefs b
    WHERE a.inventory_item_id = b.inventory_item_id
    AND a.organization_id = b.master_organization_id
    AND b.preference_number =1
    AND b.customer_item_id IN (
        SELECT customer_item_id
        FROM rlm_interface_lines
        WHERE line_id = x_InterfaceLineId
        );
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      NULL;
  END;
  --
  --rlm_core_sv.dlog(C_DEBUG, 'ST', v_ShipTo);
  --rlm_core_sv.dlog(C_DEBUG, 'BT', v_BillTo);
  --rlm_core_sv.dlog(C_DEBUG, 'IST', v_IntrmdShipTo);
  --
  INSERT INTO RLM_DEMAND_EXCEPTIONS
        (
         exception_id,
         exception_level,
         message_name,
         message_text,
         interface_header_id,
         interface_line_id,
         schedule_header_id,
         schedule_line_id,
         order_header_id,
         order_line_id,
	 last_update_date,
	 last_updated_by,
	 creation_date,
	 created_by,
	 last_update_login,
	 request_id,
	 program_application_id,
	 program_id,
	 program_update_date,
         CUST_NAME_EXT,
         CUST_SHIP_TO_EXT,
         CUST_BILL_TO_EXT,
         CUST_INTERMD_SHIPTO_EXT,
         ECE_TP_TRANSLATOR_CODE,
         ECE_TP_LOCATION_CODE_EXT,
         EDI_CONTROL_NUM_3,
         EDI_TEST_INDICATOR,
         SCHED_GENERATION_DATE,
         SCHEDULE_REFERENCE_NUM,
         SCHEDULE_SOURCE,
         SCHEDULE_TYPE,
         SCHEDULE_PURPOSE,
         HORIZON_START_DATE,
         HORIZON_END_DATE,
         CUST_SHIP_FROM_ORG_EXT,
         SCHEDULE_LINE_NUMBER,
         SCHEDULE_ITEM_NUM,
         CUSTOMER_ITEM_EXT,
         CUST_ITEM_DESCRIPTION,
         CUST_UOM_EXT,
         INVENTORY_ITEM,
         ITEM_DETAIL_TYPE,
         ITEM_DETAIL_SUBTYPE,
         ITEM_DETAIL_QUANTITY,
         START_DATE_TIME,
         CUST_JOB_NUMBER,
         CUST_MODEL_SERIAL_NUM,
         CUSTOMER_PROD_SEQ_NUM,
         DATE_TYPE_CODE,
         QTY_TYPE_CODE,
	 REQUEST_DATE,
	 SCHEDULE_DATE,
	 CUST_PO_NUMBER,
	 INDUSTRY_ATTRIBUTE1,
	 CUST_PRODUCTION_LINE,
	 CUSTOMER_DOCK_CODE,
         PURGE_STATUS
	)
  VALUES
        (
         v_ExceptionId,
         x_ExceptionLevel,
         x_MessageName,
         SUBSTR(v_MessageText,1,2000),
         x_InterfaceHeaderId,
         x_InterfaceLineId,
         x_ScheduleHeaderId,
         x_ScheduleLineId,
         x_OrderHeaderId,
         x_OrderLineId,
	 sysdate,
	 nvl(x_user_id,fnd_global.user_id),
	 sysdate,
	 fnd_global.user_id,
	 v_LoginId,
	 x_conc_req_id,
	 x_prog_appl_id,
	 x_conc_program_id,
	 v_ProgramDate,
	 v_Exception_rec.CUST_NAME_EXT,
	 v_shipTo,
         v_BillTo,
         v_IntrmdShipTo,
         v_Exception_rec.ECE_TP_TRANSLATOR_CODE,
         v_Exception_rec.ECE_TP_LOCATION_CODE_EXT,
         v_Exception_rec.EDI_CONTROL_NUM_3,
         v_Exception_rec.EDI_TEST_INDICATOR,
         v_Exception_rec.SCHED_GENERATION_DATE,
         v_Exception_rec.SCHEDULE_REFERENCE_NUM,
         v_Exception_rec.SCHEDULE_SOURCE,
         v_Exception_rec.SCHEDULE_TYPE,
         v_Exception_rec.SCHEDULE_PURPOSE,
         v_Exception_rec.HORIZON_START_DATE,
         v_Exception_rec.HORIZON_END_DATE,
         v_Exception_rec.CUST_SHIP_FROM_ORG_EXT,
         v_Exception_rec.SCHEDULE_LINE_NUMBER,
         v_Exception_rec.SCHEDULE_ITEM_NUM,
         v_Exception_rec.CUSTOMER_ITEM_EXT,
         v_Exception_rec.CUST_ITEM_DESCRIPTION,
         v_Exception_rec.CUST_UOM_EXT,
         v_inv_item,
         v_Exception_rec.ITEM_DETAIL_TYPE,
         v_Exception_rec.ITEM_DETAIL_SUBTYPE,
         v_Exception_rec.ITEM_DETAIL_QUANTITY,
         v_Exception_rec.START_DATE_TIME,
         v_Exception_rec.CUST_JOB_NUMBER,
         v_Exception_rec.CUST_MODEL_SERIAL_NUM,
         v_Exception_rec.CUSTOMER_PROD_SEQ_NUM,
         v_Exception_rec.DATE_TYPE_CODE,
         v_Exception_rec.QTY_TYPE_CODE,
	 v_Exception_rec.REQUEST_DATE,
	 v_Exception_rec.SCHEDULE_DATE,
	 v_Exception_rec.CUST_PO_NUMBER,
	 v_Exception_rec.INDUSTRY_ATTRIBUTE1,
	 v_Exception_rec.CUST_PRODUCTION_LINE,
	 v_Exception_rec.CUSTOMER_DOCK_CODE,
         x_PurgeStatus
        );
  --
  --rlm_core_sv.dpop(C_SDEBUG);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
   --
   sql_error ('rlm_message_sv.insert_row', v_progress);
   --
   -- close cursors
   --
   if (c_Excep_Int%ISOPEN) Then
     CLOSE c_Excep_Int;
   end if;
   --
   if (c_Excep_Int1%ISOPEN) Then
     CLOSE c_Excep_Int1;
   end if;
   --
   if (c_Excep_Int2%ISOPEN) Then
     CLOSE c_Excep_Int2;
   end if;
   --
   IF (c_GetShipTo%ISOPEN) THEN
     CLOSE c_GetShipTo;
   END IF;
   --
   IF (c_GetBillTo%ISOPEN) THEN
     CLOSE c_GetBillTo;
   END IF;
   --
   IF (c_GetIntrmdShipTo%ISOPEN) THEN
     CLOSE c_GetIntrmdShipTo;
   END IF;
   --
   --rlm_core_sv.dpop(C_SDEBUG);
   RAISE;
   --
END insert_row;



/*===========================================================================

  PROCEDURE NAME:	insert_purge_row

===========================================================================*/

PROCEDURE insert_purge_row (
           x_ExceptionLevel      IN  VARCHAR2,
           x_MessageName         IN  VARCHAR2,
           x_ErrorText           IN  VARCHAR2,
           x_InterfaceHeaderId   IN  NUMBER,
           x_InterfaceLineId     IN  NUMBER,
           x_ScheduleHeaderId    IN  NUMBER,
           x_ScheduleLineId      IN  NUMBER,
           x_OrderHeaderId       IN  NUMBER,
           x_OrderLineId         IN  NUMBER,
           x_ScheduleLineNum     IN  NUMBER,  --bugfix 6319027
           x_user_id             IN  NUMBER,
           x_conc_req_id         IN  NUMBER,
           x_prog_appl_id        IN  NUMBER,
           x_conc_program_id     IN  NUMBER,
           x_PurgeStatus         IN  VARCHAR2,
           x_PurgeExp_rec        IN  t_PurExp_rec
           )

IS

v_MessageText  	VARCHAR2(5000) := NULL;
v_ExceptionId	NUMBER 	       := NULL;
v_progress	VARCHAR2(3)    := '010';
v_info_txt	VARCHAR2(2000) := NULL;
v_warn_txt	VARCHAR2(2000) := NULL;
v_error_txt	VARCHAR2(2000) := NULL;
v_ProgramDate	DATE	       := NULL;
v_LoginId 	NUMBER	       := fnd_global.login_id;
v_count 	NUMBER	       := 0;

BEGIN

       /*
       ** Retrieve translated message for 'Error'
       ** and 'Warning' if required.
       */

       /*
       ** Complete the message string by substituting
       ** tokens.
       */


       IF (x_ExceptionLevel = g_error) THEN
              fnd_message.set_name ('RLM', 'RLM_ERROR');
	      v_error_txt := fnd_message.get;
	      v_MessageText :=  v_error_txt ||': ' || x_ErrorText;
              g_error_flag := 'Y';


       ELSIF (x_ExceptionLevel = g_warn) THEN
             fnd_message.set_name ('RLM', 'RLM_WARNING');
	      v_warn_txt := fnd_message.get;
	      v_MessageText :=  v_warn_txt ||': '|| x_ErrorText;
              g_warn_flag := 'Y';


       ELSIF (x_ExceptionLevel = g_info) THEN
             fnd_message.set_name ('RLM', 'RLM_INFORMATION');
	      v_info_txt := fnd_message.get;
	      v_MessageText := v_info_txt ||': ' || x_ErrorText;
              g_info_flag := 'Y';

       END IF;



       /*
       ** Obtain the exception id from the
       ** sequence rlm_demand_exceptions_s .
       */

       SELECT rlm_demand_exceptions_s.nextval
       INTO   v_ExceptionId
       FROM   sys.dual;



       /*
       ** Program update date should be populated
       ** if called from a concurrent program.
       */



       IF (fnd_global.conc_request_id IS NOT NULL) THEN
	      v_ProgramDate := sysdate;
	      v_LoginId	:= fnd_global.conc_login_id;
       END IF;



       /*
       ** Select record.
       */



	v_progress := '015';


       /*
       ** Insert record.
       */



	v_progress := '020';

	INSERT INTO RLM_DEMAND_EXCEPTIONS(
		exception_id,
		exception_level,
		message_name,
		message_text,
                interface_header_id,
                interface_line_id,
                schedule_header_id,
                schedule_line_id,
                order_header_id,
                order_line_id,
                schedule_line_number, --bugfix 6319027
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
		ECE_TP_TRANSLATOR_CODE,
		SCHEDULE_REFERENCE_NUM,
		SCHEDULE_TYPE,
		SCHED_GENERATION_DATE,
                ORIGIN_TABLE,   /*2261812*/
                PURGE_STATUS
		)
           VALUES (
		v_ExceptionId,
		x_ExceptionLevel,
		x_MessageName,
		substr(v_MessageText,1,2000),
                x_InterfaceHeaderId,
                x_InterfaceLineId,
                x_ScheduleHeaderId,
                x_ScheduleLineId,
                x_OrderHeaderId,
                x_OrderLineId,
                x_ScheduleLineNum, --bugfix 6319027
		sysdate,
		nvl(x_user_id,fnd_global.user_id),
		sysdate,
		fnd_global.user_id,
		v_LoginId,
		x_conc_req_id,
		x_prog_appl_id,
		x_conc_program_id,
		v_ProgramDate,
                x_PurgeExp_rec.ECE_TP_TRANSLATOR_CODE,
		x_PurgeExp_rec.SCHEDULE_REFERENCE_NUM,
		x_PurgeExp_rec.SCHEDULE_TYPE,
                x_PurgeExp_rec.SCHED_GENERATION_DATE,
                x_PurgeExp_rec.ORIGIN_TABLE,  /* 2261812*/
                x_PurgeStatus);


EXCEPTION
  WHEN OTHERS THEN
    sql_error ('rlm_message_sv.insert_purge_row', v_progress);
    RAISE;

END insert_purge_row;



/*===========================================================================

  PROCEDURE NAME:	sql_error

===========================================================================*/

PROCEDURE sql_error (x_routine  	IN      VARCHAR2,
		     x_location		IN 	VARCHAR2)
IS

  --
  x_text VARCHAR2(255) := NULL;
  --
  v_message_rec t_message_rec;
  v_incr NUMBER;
  --
BEGIN
   --
   IF (g_routine is NULL) THEN
       g_routine  := x_routine;
       g_location := x_location;
   ELSE
       g_routine := x_routine ||'-'|| x_location ||': '|| g_routine;
   END IF;
  /*
  ** Build the message string.
  */
   fnd_message.set_name  ('RLM', 'RLM_ALL_SQL_ERROR');
   fnd_message.set_token ('ROUTINE', g_routine);
   fnd_message.set_token ('ERR_NUMBER', g_location);
   fnd_message.set_token ('SQL_ERR', substr(sqlerrm,1,300));
   --
   v_message_rec.exception_level := rlm_message_sv.k_error_level;
   v_message_rec.message_name := 'RLM_ALL_SQL_ERROR';
   v_message_rec.error_text := fnd_message.get;
   --
   v_incr := g_message_tab.COUNT + 1;
   --
   -- set the message in the table
   --
   g_message_tab(v_incr) := v_message_rec;
   --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END sql_error;

/*===========================================================================

  PROCEDURE NAME:	processing_error

===========================================================================*/

PROCEDURE processing_error (x_routine  	IN      VARCHAR2,
		            x_location	IN 	VARCHAR2)
IS

x_text VARCHAR2(255) := NULL;

BEGIN

   	   IF (g_routine is NULL) THEN
             g_routine  := x_routine;
	     g_location := x_location;

           ELSE
	     g_routine := x_routine ||'-'|| x_location ||': '|| g_routine;

	   END IF;

       /*
       ** Build the message string.
       */

       	fnd_message.set_name  ('RLM', 'RLM_ALL_PROC_ERROR');
	fnd_message.set_token ('ROUTINE', g_routine);
	fnd_message.set_token ('ERR_NUMBER', g_location);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END processing_error;



/*===========================================================================

  FUNCTION NAME:	get

===========================================================================*/

FUNCTION get
RETURN VARCHAR2
IS

BEGIN

  /*
  ** Retrieve the message from the stack.
  */
  --return (fnd_message.get);
  return ('ERROR');

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get;

/*===========================================================================

  FUNCTION NAME:	fatal_error_found

===========================================================================*/

FUNCTION fatal_error_found
RETURN BOOLEAN
IS

BEGIN
  --
  RETURN FALSE;
  --
/*
  IF fatal_error_flag = 'Y' THEN
     return TRUE;
  ELSE
     return FALSE;
  END IF;
*/
  --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END fatal_error_found;

/*===========================================================================

  FUNCTION NAME:	initialize_messages
  This function will initialize the flags
  fatal_error_flag
  error flag and
  warn flag to N
  Also it will reset all records in the dependency table
===========================================================================*/

PROCEDURE initialize_messages
IS

BEGIN
  --
  g_fatal_error_flag := 'N';
  g_error_flag := 'N';
  g_warn_flag  := 'N';
  g_info_flag  := 'N';
  reset_dependency;
  g_message_tab.DELETE;
  --
  --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END initialize_messages;

/*===========================================================================

  PROCEDURE NAME:	reset_dependency
  IF no parameter is passed then the reset dependency will reset all the error
  falg in the dep table to N
  else
   it will only reset the error flag for the valitaion type specified

===========================================================================*/

PROCEDURE reset_dependency( x_val_name IN VARCHAR2)
IS

BEGIN
   --
   FOR i IN 1..g_dependency_tab.COUNT LOOP
     --
     IF x_val_name IS NULL THEN
       --
       g_dependency_tab(i).error_flag := 'N';
       --
     ELSIF (g_dependency_tab(i).val_name = x_val_name OR
            g_dependency_tab(i).dep_name = x_val_name  )
        THEN
       --
       g_dependency_tab(i).error_flag := 'N';
       --
     END IF;
     --
   END LOOP;
   --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END reset_dependency;


/*===========================================================================

  FUNCTION NAME:	dump_messages

===========================================================================*/

PROCEDURE dump_messages
IS
   v_user_id     NUMBER     :=  fnd_global.user_id;
   v_prog_appl_id NUMBER    := fnd_global.prog_appl_id;
   v_conc_program_id NUMBER := fnd_global.conc_program_id;

BEGIN
  --
  IF g_message_tab.COUNT > 0 THEN
    --
    FOR i in 1..g_message_tab.COUNT LOOP
       --
       insert_row (g_message_tab(i).exception_level,
                   NVL(g_message_tab(i).child_message_name,g_message_tab(i).message_name),
                   g_message_tab(i).error_text,
                   g_message_tab(i).interface_header_id,
                   g_message_tab(i).interface_line_id,
                   g_message_tab(i).schedule_header_id,
                   g_message_tab(i).schedule_line_id,
                   g_message_tab(i).order_header_id,
                   g_message_tab(i).order_line_id,
		   g_message_tab(i).group_Info,
                   v_user_id,
                   get_conc_req_id,
                   v_prog_appl_id,
                   v_conc_program_id);
       --
    END LOOP;
    --
    g_message_tab.delete; -- BugFix #4147550
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END dump_messages;



/*===========================================================================

  FUNCTION NAME:	dump_messages

===========================================================================*/

PROCEDURE dump_messages(x_header_id IN NUMBER)
IS
   v_user_id     NUMBER     :=  fnd_global.user_id;
   v_prog_appl_id NUMBER    := fnd_global.prog_appl_id;
   v_conc_program_id NUMBER := fnd_global.conc_program_id;
   -- Bug 2771756
   i             NUMBER;
BEGIN
  --
  IF g_message_tab.COUNT > 0 THEN
    --
    -- Bug 2771756 : Using while loop instead of FOR loop.

    i := g_message_tab.FIRST;
    WHILE i IS NOT NULL LOOP
       --
       insert_row (g_message_tab(i).exception_level,
                   NVL(g_message_tab(i).child_message_name,g_message_tab(i).message_name),
                   g_message_tab(i).error_text,
                   NVL(g_message_tab(i).interface_header_id,x_header_id),
                   g_message_tab(i).interface_line_id,
                   g_message_tab(i).schedule_header_id,
                   g_message_tab(i).schedule_line_id,
                   g_message_tab(i).order_header_id,
                   g_message_tab(i).order_line_id,
	           g_message_tab(i).group_Info,
                   v_user_id,
                   get_conc_req_id,
                   v_prog_appl_id,
                   v_conc_program_id);
       --

       i := g_message_tab.NEXT(i);

    END LOOP;
    --
  END IF;
  --
  g_message_tab.delete; -- BugFix #4147550
  --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END dump_messages;


/*===========================================================================

  FUNCTION NAME:	set_fatal_error

===========================================================================*/

PROCEDURE set_fatal_error
IS

BEGIN

  g_fatal_error_flag := 'Y';

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END set_fatal_error;

/*===========================================================================

  FUNCTION NAME:	are_there_errors

===========================================================================*/

FUNCTION are_there_errors
RETURN BOOLEAN
IS

BEGIN

  IF g_error_flag = 'Y' THEN
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END are_there_errors;


/*===========================================================================

  PROCEDURE NAME:	set_Dependent_error
  This proc will set the error flag for all val types which are
  dependent on the x_type which is passed in
===========================================================================*/

PROCEDURE set_Dependent_error(x_name VARCHAR2)
IS

BEGIN
-- rlm_core_sv.dpush(C_SDEBUG,'set_Dependent_Error');

 FOR i IN 1..g_dependency_tab.COUNT LOOP
   --
   IF (g_dependency_tab(i).dep_name = x_name  OR
       g_dependency_tab(i).val_name = x_name )
   THEN
      --
      g_dependency_tab(i).error_flag := 'Y';
      --
   END IF;
   --
 END LOOP;
-- rlm_core_sv.dpop(C_SDEBUG);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END set_Dependent_Error;

/*===========================================================================

  FUNCTION NAME:	check_dependency
 This function will check in the dependency table for val_name
 if there was a previous error then the flag will be Y so we need to just
 set the error for all other vals where dep_name = name to Y so that
 those values will not be validated in future.
===========================================================================*/

FUNCTION check_dependency(x_name VARCHAR2)
RETURN BOOLEAN
IS
 dependent_error_found EXCEPTION;
BEGIN
 --
 -- rlm_core_sv.dpush(C_SDEBUG, 'check_dependency');
 --
 FOR i IN g_dependency_tab.FIRST..g_dependency_tab.LAST LOOP
   --
   IF g_dependency_tab(i).val_name = x_name AND
      g_dependency_tab(i).error_flag = 'Y'
   THEN
      --
      RAISE dependent_error_found;
      --
   END IF;
   --
 END LOOP;
 --
 -- rlm_core_sv.dpop(C_SDEBUG);
 RETURN TRUE;
 --
EXCEPTION
  WHEN dependent_error_found THEN
      set_dependent_error(x_name);
--      rlm_core_sv.dpop(C_SDEBUG);
      RETURN FALSE;
      --
  WHEN OTHERS THEN
    RAISE;

END check_dependency;

FUNCTION get_dep_rec(x_val_name VARCHAR2,
                        x_dep_name VARCHAR2,
                        x_error_flag  VARCHAR2)
RETURN dep_rec_type
IS
  v_dep_rec dep_rec_type;
BEGIN
   --
   v_dep_rec.val_name := x_val_name;
   v_dep_rec.dep_name := x_dep_name;
   v_dep_rec.error_flag := x_error_flag;
   RETURN v_dep_rec;
   --
END get_dep_rec;

/*
This procedure will add the dependencies to be checked at the time of running
the validations. Any dependencies can be added by the users at any time which
will be accessed by the is_dependent_error which should be called at the start
of each procedure. This will check whether an error has been detected with any
validation type.
*/

PROCEDURE add_dependency (p_val_name VARCHAR2,
                          p_dep_name VARCHAR2)

IS
 depIndex number;
-- v_dep_rec dep_rec_type;
BEGIN

  depIndex := g_dependency_tab.COUNT;
  --
  g_dependency_tab(depIndex +1) := get_dep_rec(p_val_name,p_dep_name,'N');
  --

END add_dependency;

PROCEDURE initialize_dependency(x_module VARCHAR2)
IS

BEGIN
  --
  IF x_module = 'VALIDATE_DEMAND' THEN
    --
    add_dependency('CUSTOMER',null);
    add_dependency('SHIPFROM',null);
    add_dependency('SHIPTO','CUSTOMER');
    add_dependency('BILLTO','CUSTOMER');
    add_dependency('BILLTO','SHIPTO');
    add_dependency('CITEM','CUSTOMER');
    add_dependency('CITEM','SHIPTO');
    add_dependency('INVITEM','CITEM');
    add_dependency('ITEM_DETAIL_SUBTYPE','ITEM_DETAIL_TYPE');
    add_dependency('QUANTITY_TYPE_CODE','ITEM_DETAIL_TYPE');
    add_dependency('UOM_CODE','INVITEM');
    add_dependency('LINE_SCHEDULE_TYPE','SCHEDULE_TYPE');
    add_dependency('FOREASTDESIGNATOR','CUSTOMER');
    add_dependency('FOREASTDESIGNATOR','SHIPFROM');
    add_dependency('CUM_KEY_PO','SHIP_FROM_ORG');
    add_dependency('CUM_KEY_PO','INVENTORY_ITEM');
    add_dependency('CUM_KEY_PO','SHIP_TO');
    add_dependency('CUM_KEY_PO','CUSTOMER_ITEM');
    --
  ELSIF x_module = 'MANAGE_DEMAND' THEN
    --
    add_dependency('INVITEM','CITEM');
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END initialize_dependency;


FUNCTION  get_conc_req_id
RETURN NUMBER
IS
BEGIN
   --
   IF g_conc_req_id IS NOT NULL THEN
      RETURN g_conc_req_id;
   ELSE
      RETURN fnd_global.conc_request_id;
   END IF;
   --
END get_conc_req_id;


PROCEDURE  populate_req_id
IS
BEGIN
   --
   g_conc_req_id := fnd_global.conc_request_id;
   --
END populate_req_id;

-- Bug#: 2771756 - Start
/*===========================================================================

  PROCEDURE NAME:    removeMessages

===========================================================================*/

/* Bug 4198330  added grouping parameters to removeMessages*/

PROCEDURE removeMessages (p_header_id IN NUMBER,
                          p_message   IN VARCHAR2,
                          p_message_type IN VARCHAR2,
                          p_ship_from_org_id IN NUMBER,
                          p_ship_to_address_id IN NUMBER,
                          p_customer_item_id IN NUMBER,
                          p_inventory_item_id IN NUMBER)
IS
  --
  i NUMBER;
  --
BEGIN
  --
  IF g_message_tab.COUNT > 0 THEN
   --
   i := g_message_tab.FIRST;
   --
   WHILE i IS NOT NULL LOOP
    --
    IF  g_message_tab(i).interface_header_id = p_header_id AND
        g_message_tab(i).exception_level = p_message_type AND
        g_message_tab(i).message_name = p_message THEN
        -- Bug 4198330
         IF g_message_tab(i).ship_from_org_id IS NOT NULL AND
            g_message_tab(i).ship_to_address_id IS NOT NULL AND
            g_message_tab(i).inventory_item_id  IS NOT NULL AND
            g_message_tab(i).customer_item_id  IS NOT NULL THEN
            --
            IF g_message_tab(i).ship_from_org_id =
                  nvl(p_ship_from_org_id, g_message_tab(i).ship_from_org_id)  AND
               g_message_tab(i).ship_to_address_id =
                       nvl(p_ship_to_address_id,g_message_tab(i).ship_to_address_id)  AND
               g_message_tab(i).inventory_item_id =
                       nvl(p_inventory_item_id,g_message_tab(i).inventory_item_id) AND
               g_message_tab(i).customer_item_id =
                       nvl(p_customer_item_id,g_message_tab(i).customer_item_id) THEN
                --
                g_message_tab.DELETE(i);
                --
            END IF;
            --
         ELSE
            -- Remove the line from the tab
            g_message_tab.DELETE(i);
            --
         END IF;
         --
    END IF;
    --
    i := g_message_tab.NEXT(i);
    --
   END LOOP;
   --
  END IF;
  --
EXCEPTION
  When others then
    raise;

END removeMessages;
-- Bug#: 2771756 - End

END rlm_message_sv;

/
