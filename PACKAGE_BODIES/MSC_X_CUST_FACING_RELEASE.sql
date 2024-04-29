--------------------------------------------------------
--  DDL for Package Body MSC_X_CUST_FACING_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_CUST_FACING_RELEASE" AS
/* $Header: */

g_msc_cp_debug VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');
G_VMI_OM_ORDER_TYPE VARCHAR2(30) := FND_PROFILE.VALUE('MSC_X_VMI_OM_ORDER_TYPE');

-- This procesure prints out message to user
PROCEDURE log_message( p_user_info IN VARCHAR2)
    IS
BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
     -- dbms_output.put_line(p_user_info);
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_message;

-- This procesure prints out debug information
PROCEDURE LOG_DEBUG( p_debug_info IN VARCHAR2)
IS
  BEGIN
    IF ( g_msc_cp_debug= '1' OR g_msc_cp_debug = '2') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, p_debug_info);
    END IF;
    -- dbms_output.put_line(p_debug_info);
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END LOG_DEBUG;

FUNCTION LAUNCH_RELEASE_ON_SOURCE( pItem_name          IN VARCHAR2,
				   pCustomer_name      IN VARCHAR2,
				   pCustomer_site_name IN VARCHAR2,
                                   pItemtype           IN VARCHAR2,
				   pItemkey            IN VARCHAR2,
				   pRelease_Id         IN NUMBER,
			           p_dblink            IN VARCHAR2
					, p_instance_id IN NUMBER -- bug 3436758
					, p_instance_code IN VARCHAR2
					, p_a2m_dblink IN VARCHAR2
					, o_req_id     OUT NOCOPY NUMBER
					)
RETURN BOOLEAN
   IS
       v_sql_stmt  varchar2(1000);
       l_user_name              VARCHAR2(100):= NULL;
       l_resp_name              VARCHAR2(100):= NULL;
       l_application_name       VARCHAR2(240):= NULL;
       l_user_id                NUMBER;

       lv_errbuf            VARCHAR2(2048);
       lv_retcode           NUMBER;

       lv_request_id        NUMBER;
       lv_timeout           NUMBER:= 120.0;  /* minutes */
BEGIN
    LOG_MESSAGE( 'Started the Release program on Source instance');

      l_user_name := FND_GLOBAL.USER_NAME;
      l_resp_name := FND_GLOBAL.RESP_NAME;
      l_application_name := FND_GLOBAL.APPLICATION_NAME;

   v_sql_stmt:=
     'BEGIN MSC_X_VMI_POREQ.START_RELEASE_PROGRAM'||p_dblink||'('
   ||'             :lv_errbuf,'
   ||'             :lv_retcode,'
   ||'             :l_user_name,'
   ||'             :l_resp_name,'
   ||'             :l_application_name,'
   ||'             :pItem_name,'
   ||'             :pCustomer_name,'
   ||'             :pCustomer_site_name,'
   ||'             :pItemtype,'
   ||'             :pItemkey,'
   ||'             :pRelease_Id,'
   ||'             :p_instance_id,' -- bug 3436758
   ||'             :p_instance_code,'
   ||'             :p_a2m_dblink,'
   ||'             :lv_request_id);'
   ||'END;';

   EXECUTE IMMEDIATE v_sql_stmt
           USING OUT lv_errbuf,
                 OUT lv_retcode,
                 IN  l_user_name,
                 IN  l_resp_name,
                 IN  l_application_name,
		 IN  pItem_name,
		 IN  pCustomer_name,
		 IN  pCustomer_site_name,
		 IN  pItemtype,
		 IN  pItemkey,
		 IN  pRelease_Id,
		 IN  p_instance_id,
		 IN  p_instance_code,
		 IN  p_a2m_dblink,

                 OUT lv_request_id;

    IF lv_retcode= G_ERROR THEN
       LOG_MESSAGE( lv_errbuf);
       LOG_MESSAGE( 'Error in the Release program on Source.');
       RETURN FALSE;
    END IF;

    IF lv_request_id= 0 THEN
       LOG_MESSAGE( lv_errbuf);
       LOG_MESSAGE( 'Error in Launching the Release program on Source.');
       RETURN FALSE;
    END IF;

    COMMIT;

    o_req_id := lv_request_id;

    LOG_MESSAGE( 'Launched the Request : '|| lv_request_id|| ' on the source instance');

    v_sql_stmt:=
        'BEGIN MSC_X_VMI_POREQ.WAIT_FOR_REQUEST'||p_dblink||'('
      ||'           :lv_request_id,'
      ||'           :lv_timeout,'
      ||'           :lv_retcode);'
      ||'END;';

    EXECUTE IMMEDIATE v_sql_stmt
            USING IN  lv_request_id,
		  IN  lv_timeout,
                  OUT lv_retcode;

    IF lv_retcode= SYS_YES THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

EXCEPTION
  when others then
       LOG_MESSAGE( SQLERRM);
       LOG_MESSAGE( 'Error in Launching the Release program on Source.');
       RETURN FALSE;

END LAUNCH_RELEASE_ON_SOURCE;

/* This procedure will be called from the Workflow node when
   Planner chooses to override ATP schedule date.
   This case can happen in Unconsigned VMI when ATP has modified the schedule_ship_date
   */
PROCEDURE UPDATE_SO_ATP_OVERRIDE
  (   itemtype       in varchar2,
      itemkey        in varchar2,
      actid          in number,
      funcmode       in varchar2,
      resultout      out nocopy varchar2)
IS
BEGIN

        /* Change the VMI release type to ATP override.
	   Next node in workflow will call the release replenishment
	   */

	  wf_engine.SetItemAttrNumber
		    ( itemtype => itemtype,
		      itemkey  => itemkey,
		      aname    => 'VMI_RELEASE_TYPE',
		      avalue   => G_PLANNER_OVERRIDE_ATP
		      );

EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END UPDATE_SO_ATP_OVERRIDE;

/* This procedure will be called from the Workflow node for Unconsigned VMI.
   This will return YES if the Schedule Date has been changed by ATP .
   */
PROCEDURE SCHEDULE_DATE_CHANGED( itemtype  in varchar2,
				 itemkey   in varchar2,
				 actid     in number,
				 funcmode  in varchar2,
				 resultout out nocopy varchar2
				)
IS

       l_schedule_date_changed NUMBER :=
	 wf_engine.GetItemAttrNumber
		 (itemtype => itemtype,
		  itemkey  => itemkey,
		  aname    => 'SCHEDULE_DATE_CHANGE'
		   );

BEGIN
   IF funcmode = 'RUN' THEN

        IF (l_schedule_date_changed = SYS_YES) THEN     --- schedule date is changed
            resultout := 'COMPLETE:Y';
	ELSE                  ---- Schedule date is not changed
            resultout := 'COMPLETE:N';
	END IF;

   END IF;

   IF funcmode = 'CANCEL' THEN
      resultout := 'COMPLETE:vmi_release_run_cancel';
   END IF;

   IF funcmode = 'TIMEOUT' THEN
      resultout := 'COMPLETE:vmi_release_run_timeout';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('MSC_X_CUST_FACING_RELEASE', 'vmi_release', itemtype, itemkey, actid, funcmode);
      RAISE;
END SCHEDULE_DATE_CHANGED;

/* This procedure will be called from the Workflow node to check Consigned/Unconsigned VMI
   This will return YES if the Consigned is Yes .
   */
PROCEDURE IS_CONSIGNED_VMI( itemtype  in varchar2,
				 itemkey   in varchar2,
				 actid     in number,
				 funcmode  in varchar2,
				 resultout out nocopy varchar2
				)
IS

       lv_consigned NUMBER :=
	 wf_engine.GetItemAttrNumber
		 (itemtype => itemtype,
		  itemkey  => itemkey,
		  aname    => 'CONSIGNED_FLAG'
		   );

BEGIN
   IF funcmode = 'RUN' THEN

        IF (lv_consigned = SYS_YES) THEN     --- Consigned is Yes
            resultout := 'COMPLETE:Y';
	ELSE                  ---- Consigned is No
            resultout := 'COMPLETE:N';
	END IF;

   END IF;

   IF funcmode = 'CANCEL' THEN
      resultout := 'COMPLETE:vmi_release_run_cancel';
   END IF;

   IF funcmode = 'TIMEOUT' THEN
      resultout := 'COMPLETE:vmi_release_run_timeout';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('MSC_X_CUST_FACING_RELEASE', 'vmi_release', itemtype, itemkey, actid, funcmode);
      RAISE;
END IS_CONSIGNED_VMI;

-- This procedure will be called by the VMI Workflow for customer facing VMI
-- and will create a replenishment  for Replenishment/Consumption Advice
-- and update the Sales orders if for ATP override
PROCEDURE vmi_release( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out nocopy varchar2
) IS

lvs_request_id  number;
	      l_call_status boolean;

	      l_phase            varchar2(80);
	      l_status           varchar2(80);
	      l_dev_phase        varchar2(80);
	      l_dev_status       varchar2(80);
	      l_message          varchar2(2048);

       l_item_name  varchar2(250) :=
         wf_engine.GetItemAttrText
	    ( itemtype => itemtype
	      , itemkey  => itemkey
	      , aname    => 'SUPPLIER_ITEM_NAME'
	      );

       l_customer_name varchar2(250) :=
	  wf_engine.GetItemAttrText
	    ( itemtype => itemtype
	      , itemkey  => itemkey
	      , aname    => 'CUSTOMER_NAME'
	      );

       l_customer_site_name  varchar2(250) :=
	  wf_engine.GetItemAttrText
	    ( itemtype => itemtype
	      , itemkey  => itemkey
	      , aname    => 'CUSTOMER_SITE_NAME'
	      );
BEGIN

   IF funcmode = 'RUN' THEN

		lvs_request_id := FND_REQUEST.SUBMIT_REQUEST(
				     'MSC',
				     'MSCXCVR',
				     NULL,  -- description
				     NULL,  -- start date
				     FALSE, -- not a sub request,
				     l_item_name,
				     l_customer_name,
				     l_customer_site_name,
				     itemtype,
				     itemkey,
				     0,    ----dummy Release id
				     SYS_YES,        ---running on Destination
				     NULL, -- bug 3436758
				     NULL,
				     NULL
				     );

		COMMIT;

		   --LOG_MESSAGE(itemtype);
		   --LOG_MESSAGE(itemkey);
		   --LOG_MESSAGE('Inside VMI Release');
		   --LOG_MESSAGE('Request id : ' ||lvs_request_id);
		IF lvs_request_id=0 THEN
		   LOG_MESSAGE(SQLERRM);
                   resultout := 'COMPLETE:N';
		ELSE

	     LOOP
	     /* come out of function only when the MSCXCVR is complete */

		  l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
				      ( lvs_request_id,
					NULL,
					NULL,
					l_phase,
					l_status,
					l_dev_phase,
					l_dev_status,
					l_message);

		   IF (l_call_status=FALSE) THEN
			   resultout := 'COMPLETE:N';
			   LOG_MESSAGE(l_message);

		   END IF;

		   EXIT WHEN l_dev_phase = 'COMPLETE';

	     END LOOP;

 --log_message('Dev_status : ' || l_dev_status);
	     IF (l_dev_status = 'ERROR') then
			   resultout := 'COMPLETE:N';
	     ELSE
			   resultout := 'COMPLETE:Y';
	     END IF;

     end if;

   END IF; -- if "RUN"

   IF funcmode = 'CANCEL' THEN
      resultout := 'COMPLETE:vmi_release_run_cancel';
   END IF;

   IF funcmode = 'TIMEOUT' THEN
      resultout := 'COMPLETE:vmi_release_run_timeout';
   END IF;

   commit;
EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('MSC_X_CUST_FACING_RELEASE', 'vmi_release', itemtype, itemkey, actid, funcmode);
      RAISE;
END vmi_release;

PROCEDURE DELETE_INTERFACE_RECORD
			  ( itemtype  in varchar2,
			    itemkey   in varchar2,
			    actid     in number,
			    funcmode  in varchar2,
			    resultout out nocopy varchar2
			  )
IS
       lv_delete_release_id NUMBER :=
			 wf_engine.GetItemAttrNumber
				 (itemtype => itemtype,
				  itemkey  => itemkey,
				  aname    => 'RELEASE_ID'
				   );
BEGIN

        /* delete from the interface table */

   delete msc_so_release_interface
    where release_id = lv_delete_release_id;

   commit;

EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END DELETE_INTERFACE_RECORD;


PROCEDURE CREATE_VMI_RELEASE( ERRBUF    OUT NOCOPY VARCHAR2,
			      RETCODE   OUT NOCOPY NUMBER,
			      pItem_name          in varchar2,
			      pCustomer_name      in varchar2,
			      pCustomer_site_name in varchar2,
			      itemtype            in varchar2,
			      itemkey             in varchar2,
			      pRelease_ID         in number,
			      pDestination        in number,
          p_instance_id IN  NUMBER,
          p_instance_code  IN  VARCHAR2,
          p_a2m_dblink IN  VARCHAR2
			       )
IS

       l_user_name              VARCHAR2(100):= NULL;
       l_resp_name              VARCHAR2(100):= NULL;
       l_application_name       VARCHAR2(240):= NULL;
       l_user_id                NUMBER;

lv_sql_stmt        varchar2(2000);
lv_error_message   varchar2(1000);
lv_atp_override    varchar2(1);
l_dblink           VARCHAR2(128);

null_dblink  VARCHAR2(128);
dest_dblink           VARCHAR2(128);

lv_instance_id     number;

lv_sr_cust_id      number;
lv_sr_cust_site_id number;
lv_rel_id          number;
lv_return_status   number;
lv_action          number;
lv_sr_req_id       number;

lv_header_id       number;
lv_line_id         number;
lv_success         number;
lv_transaction_type varchar2(30);

lv_schedule_date_change number;

lv_ship_from_org_id  number;
lv_schedule_ship_date  date;
lv_schedule_arrival_date date;
lv_supplier_site_name  varchar2(10);
lv_sales_order_number number;

       l_sr_instance_id NUMBER;
       l_cust_organization_id NUMBER;
       l_source_org_id NUMBER;
       l_inventory_item_id NUMBER;
       l_sr_inventory_item_id NUMBER;
       l_order_quantity NUMBER;
       l_request_date DATE;
       l_cons_request_date DATE;
       l_vmi_type NUMBER;
       l_transaction_type NUMBER;
       l_release_id NUMBER;
       l_rep_transaction_id NUMBER;
       l_item_name  varchar2(250);
       l_uom_code   varchar2(3);

       l_employee_id number;

	   -- l_instance_id	   NUMBER; -- bug 3436758
	   l_instance_code VARCHAR2(100);
	   l_a2m_dblink VARCHAR2(100);
       l_ORDER_NUMBER VARCHAR2(240);  -- Consigned CVMI Enh
       l_RELEASE_NUMBER VARCHAR2(20);
       l_LINE_NUMBER  VARCHAR2(20);
       l_END_ORDER_NUMBER  VARCHAR2(240);
       l_END_ORDER_REL_NUMBER  VARCHAR2(20);
       l_END_ORDER_LINE_NUMBER  VARCHAR2(20);

BEGIN

	SELECT FND_GLOBAL.USER_ID,
		FND_GLOBAL.USER_NAME,
		FND_GLOBAL.RESP_NAME,
		FND_GLOBAL.APPLICATION_NAME
	   INTO l_user_id,
	        l_user_name,
	        l_resp_name,
	        l_application_name
	   FROM dual;

 IF (pDestination = SYS_YES) then

	 /*SELECT FND_GLOBAL.USER_ID,
		FND_GLOBAL.USER_NAME,
		FND_GLOBAL.RESP_NAME,
		FND_GLOBAL.APPLICATION_NAME
	   INTO l_user_id,
	        l_user_name,
	        l_resp_name,
	        l_application_name
	   FROM dual;
*/
 -- Debug snippet start
     log_message('Inside PROCEDURE CREATE_VMI_RELEASE at Destination Side');
     log_message('===================== 1 ==============================');
     log_message('l_user_id / l_user_name / l_resp_name / l_appliaction_name = '
                   || l_user_id || '/'
                   || l_user_name || '/'
                   || l_resp_name || '/'
                   || l_application_name);
     -- Debug snippet end


	       l_sr_instance_id :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'SR_INSTANCE_ID'
		   );

	       l_cust_organization_id :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'CUSTOMER_ORG_ID'
		   );

	       l_source_org_id :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'SOURCE_ORG_ID'
		   );

	       l_inventory_item_id :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'INVENTORY_ITEM_ID'
		   );

	       l_sr_inventory_item_id :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'SR_INVENTORY_ITEM_ID'
		   );

	       l_order_quantity :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		 --  , aname    => 'ORDER_QUANTITY'
		   , aname    => 'RELEASE_QUANTITY'
		   );

	       l_request_date :=
		 wf_engine.GetItemAttrDate
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'TIME_FENCE_END_DATE'
		   );

	       l_cons_request_date :=
		 wf_engine.GetItemAttrDate
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'REQUEST_DATE'
		   );

	       l_vmi_type :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'CONSIGNED_FLAG'
		   );

	       l_transaction_type :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'VMI_RELEASE_TYPE'
		   );

	       l_release_id :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'RELEASE_ID'
		   );

	       l_rep_transaction_id :=
		 wf_engine.GetItemAttrNumber
		 ( itemtype => itemtype
		   , itemkey  => itemkey
		   , aname    => 'REP_TRANSACTION_ID'
		   );

	       l_item_name  :=
		 wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'SUPPLIER_ITEM_NAME'
		      );

	       l_uom_code :=
		  wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'UOM_CODE'
		      );

	     --Consigned CVMI Enh : Bug # 4562914

	       l_ORDER_NUMBER  :=
		 wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'ORDER_NUMBER'
		      );

		l_RELEASE_NUMBER  :=
		 wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'RELEASE_NUMBER'
		      );

		l_LINE_NUMBER  :=
		 wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'LINE_NUMBER'
		      );

		l_END_ORDER_NUMBER  :=
		 wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'END_ORDER_NUMBER'
		      );

		l_END_ORDER_REL_NUMBER  :=
		 wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'END_ORDER_REL_NUMBER'
		      );

		 l_END_ORDER_LINE_NUMBER  :=
		 wf_engine.GetItemAttrText
		    ( itemtype => itemtype
		      , itemkey  => itemkey
		      , aname    => 'END_ORDER_LINE_NUMBER'
		      );

    log_message('Item  : '|| l_item_name );
    log_message('Customer : '||pCustomer_name );
    log_message('Customer site : ' ||pCustomer_site_name);

	select mtil.sr_tp_id
	  into lv_sr_cust_id
	  from msc_tp_id_lid  mtil,
	       msc_trading_partners mtp,
	       msc_trading_partners mtp1
	where  mtp.partner_type = 3
	  and  mtp.sr_tp_id = l_cust_organization_id
	  and  mtp.sr_instance_id = l_sr_instance_id
	  and  mtp.modeled_customer_id = mtil.tp_id
	  and  mtil.sr_instance_id = mtp.sr_instance_id
	  and  mtil.partner_type = 2
	  and mtil.sr_tp_id = mtp1.sr_tp_id   -- bug #4929350
	  and mtp1.partner_type = 2
	  and mtil.sr_instance_id = mtp1.sr_instance_id
	  and mtp1.partner_id = mtp.modeled_customer_id
	  and mtp1.sr_instance_id = mtp.sr_instance_id;

    log_debug('Source Customer Id: '|| lv_sr_cust_id );

	select mtsil.sr_tp_site_id
	  into lv_sr_cust_site_id
	  from msc_tp_site_id_lid  mtsil,
	       msc_trading_partner_sites mtps,
	       msc_trading_partners mtp
	 where mtp.partner_type = 3
	   and mtp.sr_tp_id = l_cust_organization_id
	   and mtp.sr_instance_id = l_sr_instance_id
	   and mtps.PARTNER_SITE_ID = mtp.modeled_customer_site_id
	   and mtps.partner_id = mtp.modeled_customer_id
	   and mtsil.sr_instance_id = mtp.sr_instance_id
	   and mtsil.PARTNER_TYPE = mtps.partner_type
	   and mtsil.tp_site_id = mtps.PARTNER_SITE_ID
	   and mtsil.sr_tp_site_id = mtps.sr_tp_site_id;  -- bug #4929350

    log_debug('Source Customer Site Id: '|| lv_sr_cust_site_id );
    log_debug('Replenishment transaction_id   : '|| l_rep_transaction_id );
    log_debug('Source Organization  : '|| l_source_org_id );
    log_debug('Customer Modeled Org : '|| l_cust_organization_id );
    log_debug('UOM Code : '|| l_uom_code );

l_request_date  := to_date(l_request_date,NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY'));
                                       -- bug 5248018
    log_debug('Request Date: '||l_request_date);
    log_debug('Date format: '||NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY'));

    IF (l_vmi_type = G_CONSIGNED_VMI) then

    log_message('Consigned VMI ');
		if (l_transaction_type = G_CONSUMPTION_ADVICE)  then
				/* Create a Sales Order for Invoicing and
				   decreasing onhand without Physical shipment */
                        log_message('Creating Sales Order for the Consumption Advice.');
			lv_action := G_CREATE;
			lv_transaction_type := G_VMI_OM_ORDER_TYPE;
                        l_request_date := nvl(l_cons_request_date,sysdate);
                        l_request_date  := to_date(l_request_date,NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY'));

		elsif (l_transaction_type = G_REPLENISHMENT) then
			        /* Create internal req which inturn will create Int. Sales Order   */
                        log_message('Creating Internal Requisition for the Replenishment .');
			  MSC_X_REPLENISH.create_requisition
			  ( l_inventory_item_id,
			    l_order_quantity,
			    to_char(l_request_date,NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY')),
			    G_OEM_ID,                --- customer id
			    l_cust_organization_id,  --- customer site id
			    l_source_org_id,     --- supplier id , in this case Source_org_id
			    -1,                 -- supplier_site_id
			    l_uom_code,                   --- uom code
			    lv_error_message,
			    l_sr_instance_id
			  );

                     if (lv_error_message is null) then
			      -- change the release status of the replenishment record from
			      -- from UNRELEASED to RELEASED
			   UPDATE msc_sup_dem_entries sd
			      SET sd.release_status = G_RELEASED,
				  sd.quantity_in_process = l_order_quantity
			    WHERE sd.publisher_id = 1
			      AND sd.inventory_item_id = l_inventory_item_id
			      AND sd.publisher_order_type = G_REPLENISHMENT_ORDER
			      AND sd.plan_id = -1
			      AND sd.transaction_id = l_rep_transaction_id
			      AND sd.release_status = G_UNRELEASED;

			   log_debug('    updated status of replenishment record to RELEASED');

			        RETCODE := G_SUCCESS;

		     else
				log_message('Error in loading Requsition : ' || lv_error_message);
			        RETCODE := G_ERROR;
			        ERRBUF := lv_error_message;
		     end if;
		     return;
		end if;

    ELSIF (l_vmi_type = G_UNCONSIGNED_VMI) then

    log_message('Unconsigned VMI ');
		if (l_transaction_type = G_REPLENISHMENT) then
			       /* create a Sales Order       */
                        log_message('Creating Sales Order for the Replenishment .');
			lv_action := G_CREATE;
		elsif (l_transaction_type = G_PLANNER_OVERRIDE_ATP) then
			       /* update the Sales Order created as replenishment
				  to override the ATP schedule_ship_date
				*/
                        log_message('Updating Sales Order with ATP Override.');
			lv_atp_override := 'Y';
			lv_action := G_UPDATE;
			lv_rel_id := l_release_id;

			UPDATE MSC_SO_RELEASE_INTERFACE
		           SET action = lv_action,
			       atp_override = 'Y'
		         WHERE release_id = lv_rel_id;

		end if;

    END IF;

  IF (lv_action = G_CREATE) THEN
	  /* If the action is to create, then insert the record in interface table */

	 select msc_so_release_s.nextval
	   into lv_rel_id
	   from dual;

              /* set the Release_id attribute to system-generated sequence  */
	  wf_engine.SetItemAttrNumber(
		      itemtype => itemtype,
		      itemkey  => itemkey,
		      aname    => 'RELEASE_ID',
		      avalue   => lv_rel_id
		      );

	  log_debug('Selected the Released Id : ' || lv_rel_id );

/* Consigned CVMI Enh : Bug # 4247230 : Insert [ Order Number or Line Number or Release Number or
	End Order Number or End Order Line Number or End Order Release Number] also */

	 insert into MSC_SO_RELEASE_INTERFACE(
		RELEASE_ID         ,
		SR_INSTANCE_ID     ,
		SR_CUSTOMER_ID        ,
		SR_CUSTOMER_SITE_ID   ,
		SR_ITEM_ID            ,
		QUANTITY           ,
		UOM_CODE           ,
		ACTION             ,
		REQUEST_DATE       ,
		ATP_OVERRIDE  ,
		OE_TRANSACTION_TYPE,
		SHIP_FROM_ORG_ID,
		LAST_UPDATE_DATE   ,
		LAST_UPDATED_BY    ,
		CREATION_DATE      ,
		CREATED_BY         ,
		LAST_UPDATE_LOGIN  ,
		ORDER_NUMBER       ,
		RELEASE_NUMBER     ,
		LINE_NUMBER        ,
		END_ORDER_NUMBER   ,
		END_ORDER_REL_NUMBER ,
		END_ORDER_LINE_NUMBER )
	 values
	      ( lv_rel_id,
		l_sr_instance_id,
		lv_sr_cust_id,
		lv_sr_cust_site_id,
		l_sr_inventory_item_id,
		l_order_quantity,
		l_uom_code,
		lv_action,  ---- create
		l_request_date,         --- request_date
		lv_atp_override,        --- atp override
		lv_transaction_type,
		l_cust_organization_id,  --- For cons. advice , pass the cust model org
		sysdate,
		FND_GLOBAL.USER_ID,
		sysdate,
		FND_GLOBAL.USER_ID,
		-1,
		l_ORDER_NUMBER  ,
		l_RELEASE_NUMBER ,
		l_LINE_NUMBER    ,
		l_END_ORDER_NUMBER ,
		l_END_ORDER_REL_NUMBER ,
		l_END_ORDER_LINE_NUMBER
		);
  END IF;

    log_debug('VMI transaction Type (3-Cons. Advice,2-ATP override,1-Replenish) : ' || l_transaction_type );
    log_debug('ATP override flag =  : ' || lv_atp_override );
    log_debug('Action(1-create, 2-update)   : ' || lv_action );
    log_debug('Inserted into msc_so_release_interface: ' || lv_rel_id );

	SELECT DECODE(apps.m2a_dblink
			,NULL,' '
			,'@' || m2a_dblink),
		m2a_dblink
		, a2m_dblink -- bug 3436758
		, instance_code
	 INTO   l_dblink,
		null_dblink
		, l_a2m_dblink
		, l_instance_code
	 FROM   msc_apps_instances apps
	WHERE   apps.instance_id = l_sr_instance_id;

	  log_debug('Selected the l_sr_instance_id Id : ' || l_sr_instance_id );
	  log_debug('Selected the l_dblink : ' || l_dblink );

		     /* Call the source procedure to load the data from interface table
			and make a call to the OM Process Order API
			--l_user_name := 'OPERATIONS';
			--l_resp_name := 'Advanced Planning Administrator';
	       --l_application_name := 'Oracle Advanced Supply Chain Planning';
			*/

	      IF (null_dblink IS NULL) THEN --- same instances
		    lv_sql_stmt:=   'BEGIN'
				  ||' MSC_X_VMI_POREQ.LD_SO_RELEASE_INTERFACE'
				  ||'( :l_user_name,:l_resp_name,:l_application_name,:rel_id , '
				  ||'  :l_sr_instance_id,:l_instance_code,:l_a2m_dblink, ' -- bug 3436758
				  ||'  :lv_return_status,:lv_header_id,:lv_line_id,:lv_sales_order_number,:lv_ship_from_org_id '
				  ||'  ,:lv_schedule_ship_date,:lv_schedule_arrival_date '
				  ||' ,:lv_schedule_date_change,:lv_error_message);' ||' END;';

			EXECUTE IMMEDIATE lv_sql_stmt
				USING
				      IN  l_user_name,
				      IN  l_resp_name,
				      IN  l_application_name,
				      IN  lv_rel_id,
                      IN  l_sr_instance_id , -- bug 3436758
                      IN  l_instance_code ,
                      IN  l_a2m_dblink,
				      OUT lv_return_status,
				      OUT lv_header_id,
				      OUT lv_line_id,
				      OUT lv_sales_order_number,
				      OUT lv_ship_from_org_id,
				      OUT lv_schedule_ship_date,
				      OUT lv_schedule_arrival_date,
				      OUT lv_schedule_date_change,
				      OUT lv_error_message;

	      ELSE -- launch the program on the source instance

		 IF LAUNCH_RELEASE_ON_SOURCE(pItem_name,
					     pCustomer_name,
					     pCustomer_site_name,
					     itemtype,
					     itemkey,
					     lv_rel_id,
					     l_dblink
						 , l_sr_instance_id -- bug 3436758
						 , l_instance_code
						 , l_a2m_dblink
						 , lv_sr_req_id
						 )=FALSE THEN
		     lv_return_status := G_ERROR;

		     select substr('Request Id '||lv_sr_req_id||' failed on the Source instance. Error Message:'
		                ||ERROR_MESSAGE,1,1000)
		       INTO lv_error_message
		       from msc_so_release_interface
		      where RELEASE_ID = lv_rel_id;

		 ELSE
		     lv_return_status := G_SUCCESSFUL;

		     select return_status,
			    OE_HEADER_ID,
			    OE_LINE_ID,
			    sales_order_number,
			    SHIP_FROM_ORG_ID,
			    schedule_ship_date,
			    schedule_arrival_date,
			    schedule_date_change,
			    ERROR_MESSAGE
		       INTO lv_return_status,
			    lv_header_id,
			    lv_line_id,
			    lv_sales_order_number,
			    lv_ship_from_org_id,
			    lv_schedule_ship_date,
			    lv_schedule_arrival_date,
			    lv_schedule_date_change,
			    lv_error_message
		       from msc_so_release_interface
		      where RELEASE_ID = lv_rel_id;

		 END IF;

	      END IF;

			   log_message('    Ship from Org  :' || lv_ship_from_org_id );
			   log_message('    Schedule ship date :' || lv_schedule_ship_date );
			   log_message('    Schedule Arrival Date :' || lv_schedule_arrival_date );

	   IF ((l_vmi_type = G_CONSIGNED_VMI) and (l_transaction_type = G_CONSUMPTION_ADVICE))  THEN

		    log_message('ORDER_NUMBER : '||l_ORDER_NUMBER);
		    log_message('RELEASE_NUMBER : '||l_RELEASE_NUMBER);
		    log_message('LINE_NUMBER : '||l_LINE_NUMBER);
		    log_message('END_ORDER_NUMBER : '||l_END_ORDER_NUMBER);
		    log_message('END_ORDER_REL_NUMBER : '||l_END_ORDER_REL_NUMBER);
		    log_message('END_ORDER_LINE_NUMBER : '||l_END_ORDER_LINE_NUMBER);

	    END IF;

		IF (lv_return_status = G_SUCCESSFUL) THEN     --- Success  in Releasing

		   if (l_transaction_type =  G_REPLENISHMENT) then
		      -- change the release status of the replenishment record from
		      -- from UNRELEASED to RELEASED
			   UPDATE msc_sup_dem_entries sd
			      SET sd.release_status = G_RELEASED,
				  sd.quantity_in_process = l_order_quantity
			    WHERE sd.publisher_id = 1
			      AND sd.inventory_item_id = l_inventory_item_id
			      AND sd.publisher_order_type = G_REPLENISHMENT_ORDER
			      AND sd.plan_id = -1
			      AND sd.transaction_id = l_rep_transaction_id
			      AND sd.release_status = G_UNRELEASED;

			   log_debug('    updated status of replenishment record to RELEASED');
		   end if;

			   log_message('Success in loading Sales order ........ ');
		  if (l_vmi_type = G_UNCONSIGNED_VMI) and (lv_schedule_date_change = SYS_YES) then
				    /* ATP has change the date for Unconsigned VMI */

			   log_message('ATP changed date in unconsigned(1-yes,2-no) : ' || lv_schedule_date_change);

				   /* update the interface table with Line Id
				      and Header Id of the Sales order created.
				      This information is required for updating the Sales Order
				      if planner overrides ATP schedule date  */
			   update msc_so_release_interface
			      set oe_header_id = lv_header_id,
				  oe_line_id = lv_line_id
			    where release_id = lv_rel_id;

			if (lv_ship_from_org_id is not null) then
			      select organization_code
				into lv_supplier_site_name
				from msc_trading_partners
			       where partner_type = 3
				 and sr_instance_id = l_sr_instance_id
				 and sr_tp_id = lv_ship_from_org_id;
			end if;

				     /* Set the item attribute SCHEDULE_DATE_CHANGE as YES   */
			  wf_engine.SetItemAttrNumber(
				      itemtype => itemtype,
				      itemkey  => itemkey,
				      aname    => 'SCHEDULE_DATE_CHANGE',
				      avalue   => SYS_YES
				      );

			  wf_engine.SetItemAttrText(
				      itemtype => itemtype,
				      itemkey  => itemkey,
				      aname    => 'SUPPLIER_SITE_NAME',
				      avalue   => lv_supplier_site_name
				      );
			  wf_engine.SetItemAttrDate(
				      itemtype => itemtype,
				      itemkey  => itemkey,
				      aname    => 'SCHEDULED_DATE',
				      avalue   => lv_schedule_ship_date
				      );
			  wf_engine.SetItemAttrDate(
				      itemtype => itemtype,
				      itemkey  => itemkey,
				      aname    => 'SCHEDULED_ARRIVAL_DATE',
				      avalue   => lv_schedule_arrival_date
				      );
			  wf_engine.SetItemAttrNumber(
				      itemtype => itemtype,
				      itemkey  => itemkey,
				      aname    => 'SALES_ORDER_NUMBER',
				      avalue   => lv_sales_order_number
				      );
		  else

			  wf_engine.SetItemAttrNumber(
				      itemtype => itemtype,
				      itemkey  => itemkey,
				      aname    => 'SCHEDULE_DATE_CHANGE',
				      avalue   => SYS_NO
				      );
		  end if;

			RETCODE := G_SUCCESS;

		ELSE                  ---- failure

		   ---- send notification to planner with the error message

		   /* update the interface table with error message */
		   update msc_so_release_interface
		      set error_message = lv_error_message
		    where release_id = lv_rel_id;

		      /* set the Release_id attribute to system-generated sequence  */
		  wf_engine.SetItemAttrText(
			      itemtype => itemtype,
			      itemkey  => itemkey,
			      aname    => 'SO_ERROR_MESSAGE',
			      avalue   => lv_error_message
			      );

	     log_message('Error : ' || lv_error_message);
		  RETCODE := G_ERROR;

		END IF;

 ELSE   --- program is running on the source instance

/* bug 3436758
	    select DECODE( A2M_DBLINK, NULL, ' ',
			   '@'||A2M_DBLINK),
		   INSTANCE_ID
	      into dest_dblink,
		   lv_instance_id
	      from MRP_AP_APPS_INSTANCES;
*/


     -- Debug snippet start
     log_message('Inside PROCEDURE CREATE_VMI_RELEASE at Source Side');
     log_message('===================== 2 ==============================');
     log_message('l_user_id / l_user_name / l_resp_name / l_appliaction_name = '
                   || l_user_id || '/'
                   || l_user_name || '/'
                   || l_resp_name || '/'
                   || l_application_name);
     -- Debug snippet end

		log_message('  destination database instance id/code/link = '
				|| p_instance_id
				|| '/' || p_instance_code
				|| '/' || NVL(p_a2m_dblink,'NULL_DBLINK')
				);

    BEGIN
      select DECODE( A2M_DBLINK, NULL, ' ','@'||A2M_DBLINK),
            INSTANCE_ID
      into dest_dblink,
            lv_instance_id
      from MRP_AP_APPS_INSTANCES_ALL
      where instance_id                  = p_instance_id
      and  instance_code                = p_instance_code
      and  nvl(a2m_dblink,'NULL_DBLINK')    = nvl(p_a2m_dblink,'NULL_DBLINK')
      and ALLOW_RELEASE_FLAG=1;
  	EXCEPTION
  	WHEN OTHERS THEN
		log_message('  DB link set up is not correct: ' || sqlerrm);
    	--RAISE;
  	END;

		log_message('  destination database link/instance id = '
				|| dest_dblink
				|| '/' || lv_instance_id
				);

		    lv_sql_stmt:=   'BEGIN'
				  ||' MSC_X_VMI_POREQ.LD_SO_RELEASE_INTERFACE'
				  ||'( :l_user_name,:l_resp_name,:l_application_name,:rel_id , '
				  ||' :p_instance_id,:p_instance_code,:p_a2m_dblink , ' -- bug 3436758
				  ||'  :lv_return_status,:lv_header_id,:lv_line_id,:lv_sales_order_number,:lv_ship_from_org_id '
				  ||'  ,:lv_schedule_ship_date,:lv_schedule_arrival_date '
				  ||' ,:lv_schedule_date_change,:lv_error_message);' ||' END;';

			EXECUTE IMMEDIATE lv_sql_stmt
				USING
				      IN  l_user_name,
				      IN  l_resp_name,
				      IN  l_application_name,
				      IN  pRelease_ID,
				      IN  p_instance_id, -- bug 3436758
				      IN  p_instance_code,
				      IN  p_a2m_dblink,
					  OUT lv_return_status,
				      OUT lv_header_id,
				      OUT lv_line_id,
				      OUT lv_sales_order_number,
				      OUT lv_ship_from_org_id,
				      OUT lv_schedule_ship_date,
				      OUT lv_schedule_arrival_date,
				      OUT lv_schedule_date_change,
				      OUT lv_error_message;

		log_message('  after call MSC_X_VMI_POREQ.LD_SO_RELEASE_INTERFACE in the source') ;

	    lv_sql_stmt := 'update msc_so_release_interface'||dest_dblink
			  ||' set return_status = :lv_return_status, '
			  ||'     OE_HEADER_ID = :lv_header_id, '
			  ||'     OE_LINE_ID = :lv_line_id, '
			  ||'     sales_order_number = :lv_sales_order_number, '
			  ||'     SHIP_FROM_ORG_ID = :lv_ship_from_org_id, '
			  ||'     schedule_ship_date = :lv_schedule_ship_date, '
			  ||'     schedule_arrival_date = :lv_schedule_arrival_date, '
			  ||'     schedule_date_change = :lv_schedule_date_change, '
			  ||'     ERROR_MESSAGE = :lv_error_message '
			  ||' where sr_instance_id = :lv_instance_id '
			  ||'   and RELEASE_ID = :pRelease_ID ';

	    EXECUTE IMMEDIATE lv_sql_stmt
		        USING lv_return_status,
			      lv_header_id,
			      lv_line_id,
			      lv_sales_order_number,
			      lv_ship_from_org_id,
			      lv_schedule_ship_date,
			      lv_schedule_arrival_date,
			      lv_schedule_date_change,
			      lv_error_message,
			      lv_instance_id,
			      pRelease_ID;

		log_message('  after update msc_so_release_interface in destination ') ;

     IF (lv_return_status = G_ERROR) then
	RETCODE := G_ERROR;
     ELSE
	RETCODE := G_SUCCESS;
     END IF;

 END IF;

EXCEPTION
    WHEN OTHERS THEN
     log_message(SQLERRM);
          RETCODE := G_ERROR;

END CREATE_VMI_RELEASE;


END MSC_X_CUST_FACING_RELEASE;

/
