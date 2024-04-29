--------------------------------------------------------
--  DDL for Package Body RCV_BUSINESS_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_BUSINESS_EVENTS" AS
/* $Header: RCVBZEVB.pls 120.4.12010000.4 2010/05/29 08:25:34 bashaik ship $ */
   g_pkg_name CONSTANT VARCHAR2(30) := 'RCV_BUSINESS_EVENTS';
   g_debug    CONSTANT VARCHAR2(1)  := NVL(fnd_profile.VALUE('AFLOG_ENABLED'), 'N');
   g_log_head CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name;

   PROCEDURE raise_receive_txn(
      p_group_id   NUMBER,
      p_request_id NUMBER
   ) IS
      l_wf_item_seq     NUMBER;
      l_event_name      VARCHAR2(100);
      l_event_key       VARCHAR2(100);
      l_parameter_list1 wf_parameter_list_t := wf_parameter_list_t();
      l_parameter_list2 wf_parameter_list_t := wf_parameter_list_t();
      l_osa_flag        VARCHAR2(1); --Shikyu project
      l_parameter_list wf_parameter_list_t := wf_parameter_list_t();--opsm change

      CURSOR get_rcv_headers IS
         SELECT DISTINCT rt.shipment_header_id,
                         GROUP_ID
         FROM            rcv_transactions rt
         WHERE           rt.request_id = p_request_id
         AND             rt.transaction_type = 'RECEIVE'
         AND             NVL(p_group_id, 0) = 0
         UNION ALL
         SELECT DISTINCT rt.shipment_header_id,
                         GROUP_ID
         FROM            rcv_transactions rt
         WHERE           rt.GROUP_ID = p_group_id
         AND             rt.request_id in (0, -1, p_request_id) -- for bug 8422764
         AND             rt.transaction_type = 'RECEIVE'
         AND             NVL(p_group_id, 0) <> 0;
--------------------------------
--Modified for OPSM
--------------------------------
		CURSOR get_rcv_headers_rma IS
	   	SELECT DISTINCT rt.shipment_header_id,rt.group_id
	        FROM   rcv_transactions rt
       		WHERE  rt.request_id = p_request_id
       		AND    rt.transaction_type = 'DELIVER'
       		AND    nvl(p_group_id,0) = 0
                UNION ALL
	   	SELECT DISTINCT rt.shipment_header_id,rt.group_id
	        FROM   rcv_transactions rt
       		WHERE  rt.group_id = p_group_id
       		AND    rt.request_id in (0, -1, p_request_id)
       		AND    rt.transaction_type = 'DELIVER'
       		AND    nvl(p_group_id,0) <> 0;
--------------------------------
--Modified for OPSM
--------------------------------
   BEGIN

      l_event_name  := 'oracle.apps.po.rcv.rcvtxn';
      wf_event.setdispatchmode('ASYNC');

      BEGIN
         FOR grh IN get_rcv_headers LOOP
            SELECT po_wf_itemkey_s.NEXTVAL
            INTO   l_wf_item_seq
            FROM   DUAL;

            l_event_key  := TO_CHAR(grh.shipment_header_id) || '-' || TO_CHAR(l_wf_item_seq);
            --Clear the parameter list
            --Bug 3481437 - commented out clear
            --l_parameter_list := wf_parameter_list_t(null);
            wf_event.addparametertolist(p_name             => 'SHIPMENT_HEADER_ID',
                                        p_value            => grh.shipment_header_id,
                                        p_parameterlist    => l_parameter_list1
                                       );
            wf_event.RAISE(p_event_name    => l_event_name,
                           p_event_key     => l_event_key,
                           p_parameters    => l_parameter_list1
                          );
         END LOOP;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

----------------------------
-------Modified For OPSM--
----------------------------
	BEGIN
	For grhr in get_rcv_headers_rma loop
	 select po_wf_itemkey_s.nextval into l_wf_item_seq from dual;
	 wf_event.addparametertolist(p_name             => 'SHIPMENT_HEADER_ID',
							p_value            => grhr.shipment_header_id,
							p_parameterlist    => l_parameter_list);
	wf_event.addparametertolist(p_name             => 'GROUP_ID',
							p_value            => grhr.group_id,
							p_parameterlist    => l_parameter_list);

      WF_EVENT.raise(p_event_name => 'oracle.apps.po.rcv.rcvtxn.outbound'
			  ,p_event_key => l_wf_item_seq
			  ,p_parameters => l_parameter_list
			  ,p_send_date => SYSDATE );
	end loop;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

 -----------------------
---Modified For OPSM--
----------------------

      -- Bugfix 5589175, The original insert statement is now divided into 2 separate insert
      -- statements for performance reason. For online mode request_id might come as 0 or null.
      -- Hence we first check the request_id for Batch and Imeediate request_id is not null.
      IF p_request_id = 0 OR p_request_id IS NULL -- On line mode
      THEN
              INSERT INTO rcv_staging_table
                          (transaction_id,
                           team,
                           status,
                           transaction_request_id,
                           transaction_group_id,
                           creation_date,
                           created_by,
                           last_update_login,
                           request_id,
                           last_updated_by,
                           last_update_date
                          )
                 SELECT rt.transaction_id,
                        'JMF' team,
                        'PENDING' status,
                        rt.request_id transaction_request_id,
                        rt.GROUP_ID transaction_group_id,
                        SYSDATE creation_date,
                        rt.created_by,
                        NULL last_update_login,
                        NULL request_id,
                        0 last_updated_by,
                        SYSDATE last_update_date
                 FROM   rcv_transactions rt,
                        rcv_shipment_lines rsl
                 WHERE  rt.GROUP_ID = p_group_id
                 AND    rt.shipment_line_id = rsl.shipment_line_id
                 AND    rsl.osa_flag = 'Y'
                 AND    (   rt.transaction_type IN('RECEIVE', 'RETURN TO VENDOR', 'RETURN TO CUSTOMER')
                         OR (    rt.transaction_type = 'CORRECT'
                             AND EXISTS(SELECT NULL
                                        FROM   rcv_transactions prt
                                        WHERE  prt.transaction_id = rt.parent_transaction_id
                                        AND    prt.transaction_type IN('RECEIVE', 'RETURN TO VENDOR', 'RETURN TO CUSTOMER')))
                        );
      ELSE -- Batch and Immediate mode.
              INSERT INTO rcv_staging_table
                          (transaction_id,
                           team,
                           status,
                           transaction_request_id,
                           transaction_group_id,
                           creation_date,
                           created_by,
                           last_update_login,
                           request_id,
                           last_updated_by,
                           last_update_date
                          )
                 SELECT rt.transaction_id,
                        'JMF' team,
                        'PENDING' status,
                        rt.request_id transaction_request_id,
                        rt.GROUP_ID transaction_group_id,
                        SYSDATE creation_date,
                        rt.created_by,
                        NULL last_update_login,
                        NULL request_id,
                        0 last_updated_by,
                        SYSDATE last_update_date
                 FROM   rcv_transactions rt,
                        rcv_shipment_lines rsl
                 WHERE  rt.request_id = p_request_id
                 AND    (   rt.GROUP_ID = p_group_id
                         OR p_group_id = 0
                         OR p_group_id IS NULL)
                 AND    rt.shipment_line_id = rsl.shipment_line_id
                 AND    rsl.osa_flag = 'Y'
                 AND    (   rt.transaction_type IN('RECEIVE', 'RETURN TO VENDOR', 'RETURN TO CUSTOMER')
                         OR (    rt.transaction_type = 'CORRECT'
                             AND EXISTS(SELECT NULL
                                        FROM   rcv_transactions prt
                                        WHERE  prt.transaction_id = rt.parent_transaction_id
                                        AND    prt.transaction_type IN('RECEIVE', 'RETURN TO VENDOR', 'RETURN TO CUSTOMER')))
                        );
        END IF;
        -- End of code for bugfix 5589175

   EXCEPTION
      WHEN OTHERS THEN
         NULL; -- We don't want to fail the transaction
   END;
END rcv_business_events;

/
