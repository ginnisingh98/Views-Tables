--------------------------------------------------------
--  DDL for Package Body INV_LOT_SERIAL_DATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_SERIAL_DATE_PKG" AS
/* $Header: INVLSDTB.pls 120.1 2005/11/15 01:09:29 nsinghi noship $ */

FUNCTION date_rule (p_subscription_guid IN     RAW,
                   p_event             IN OUT NOCOPY wf_event_t) RETURN VARCHAR2
IS

   l_itemtype              WF_ITEMS.ITEM_TYPE%TYPE :=  'INVDATNT';
   l_itemkey               WF_ITEMS.ITEM_KEY%TYPE  :=  p_event.getEventKey;

   l_errname               VARCHAR2(30);
   l_errmsg                VARCHAR2(2000);
   l_errstack              VARCHAR2(32000);

   l_WorkflowProcess       VARCHAR2(30) := 'INVDATNT_PROCESS';

   default_rule_error      EXCEPTION ;
   l_status                VARCHAR2 (8);
   l_result                VARCHAR2 (30);
   l_return_status         VARCHAR2(240);

BEGIN

   /*Check if the workflow data exists and remove the same for the itemtype and itemkey
     combination */
   BEGIN
      IF (WF_ITEM.ITEM_EXIST (l_itemtype, l_itemkey)) THEN

         /* Check item status */
         WF_ENGINE.ITEMSTATUS ( itemtype => l_itemtype,
         itemkey => l_itemkey,
         status => l_status,
         result => l_result);

--           wf_item_activity_status.root_status (l_itemtype, l_itemkey, l_status, l_result);
         /* If it is not completed then abort the process */
         IF (l_status <> 'COMPLETE')THEN

            WF_ENGINE.ABORTPROCESS (itemtype=> l_itemtype,
            itemkey=> l_itemkey,
            process=> l_workflowprocess);

         END IF;
         /* Purge the workflow data for workflow key */
         WF_PURGE.TOTAL (itemtype=> l_itemtype,
         itemkey=> l_itemkey,
         docommit=> TRUE);

      END IF;
       EXCEPTION
       WHEN OTHERS THEN

       WF_CORE.CONTEXT ('inv_lot_serial_date_pkg', 'date_rule', l_itemtype, l_itemkey) ;
       WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);
   END;
   BEGIN

      /* Start the workflow */

      l_return_status := WF_RULE.DEFAULT_RULE(p_subscription_guid=>p_subscription_guid,p_event=>p_event);

      IF l_return_status = 'ERROR' THEN
         ROLLBACK;
         l_errmsg := p_event.GETERRORMESSAGE;
         RAISE DEFAULT_RULE_ERROR;
      ELSE
         COMMIT;
      END IF;

   END ;

RETURN l_return_status;

EXCEPTION

    WHEN default_rule_error THEN

       WF_CORE.CONTEXT ('inv_lot_serial_date_pkg',
          'date_rule',
          'default_rule_error',
          l_itemtype,
          l_itemkey) ;
       WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);

       RETURN l_return_status;

    WHEN OTHERS THEN

       WF_CORE.CONTEXT ('inv_lot_serial_date_pkg',
          'date_rule',
          l_itemtype,
          l_itemkey) ;
         WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);
       RETURN l_return_status;

END date_rule;

PROCEDURE send_notification (
    p_itemtype      IN VARCHAR2,
    p_itemkey       IN VARCHAR2,
    p_actid         IN NUMBER,
    p_funcmode      IN VARCHAR2,
    p_resultout     OUT NOCOPY VARCHAR2)

IS

   l_approverList ame_util.approversTable;
   l_approverList2 ame_util.approversTable2;
   l_ruleids  ame_util.idList;
   l_rulenames ame_util.stringList;
   approvalProcessCompleteYN ame_util.charType;
   itemClasses ame_util.stringList;
   itemIndexes ame_util.idList;
   itemIds ame_util.stringList;
   itemSources ame_util.longStringList;
   ruleIndexes ame_util.idList;
   sourceTypes ame_util.stringList;

   l_process_complete      VARCHAR2(100);
   l_count                 NUMBER := 0;
   l_notif_id              NUMBER;
   l_actionTypeId          NUMBER;
   l_lot_notifcation       BOOLEAN := FALSE;
   l_serial_notifcation    BOOLEAN := FALSE;
   l_errname               VARCHAR2(30);
   l_errmsg                VARCHAR2(2000);
   l_errstack              VARCHAR2(32000);
   l_application_id        NUMBER;

   l_organization_code     VARCHAR2(3);
   l_organization_id       NUMBER;
   l_item_number           VARCHAR2(240);
   l_item_id               NUMBER;
   l_item_category         VARCHAR2(240);
   l_category_id           NUMBER;
   l_query_for             VARCHAR2(100);
   l_lot_number            VARCHAR2(100);
   l_serial_number         VARCHAR2(100);
   l_date_context          VARCHAR2(240);
   l_date_type             VARCHAR2(240);
   l_user_date_type        VARCHAR2(240);
   l_date_value            VARCHAR2(240);
   l_action_code           VARCHAR2(240);
   l_serial_status         VARCHAR2(240);
   l_onhand_qty_uom        VARCHAR2(240);
   l_context               VARCHAR2(32000);
   l_transaction_id        NUMBER;


BEGIN

   l_organization_id := WF_ENGINE.GETITEMATTRNUMBER
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'ORGANIZATION_ID');

   l_organization_code := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'ORGANIZATION_CODE');

   l_item_id := WF_ENGINE.GETITEMATTRNUMBER
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'ITEM_ID');

   l_item_number := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'ITEM_NUMBER');

   l_category_id := WF_ENGINE.GETITEMATTRNUMBER
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'CATEGORY_ID');

   l_item_category := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'ITEM_CATEGORY');

   l_query_for := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'QUERY_FOR');

   l_lot_number := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'LOT_NUMBER');

   l_serial_number := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'SERIAL_NUMBER');

   l_date_context := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'DATE_CONTEXT');

   l_date_type := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'DATE_TYPE');

   l_user_date_type := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'USER_DATE_TYPE');

   l_date_value := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'DATE_VALUE');

   l_action_code := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'ACTION_CODE');

   l_serial_status := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'SERIAL_STATUS');

   l_onhand_qty_uom := WF_ENGINE.GETITEMATTRTEXT
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'ONHAND_QTY_UOM');

   l_transaction_id := WF_ENGINE.GETITEMATTRNUMBER
                          (itemtype => p_itemtype,
                          itemkey => p_itemkey,
                          aname => 'TRANSACTION_ID');

   IF l_lot_number IS NULL THEN
      l_serial_notifcation := TRUE;
   ELSIF l_serial_number IS NULL THEN
      l_lot_notifcation := TRUE;
   END IF;

   SELECT application_id INTO l_application_id
     FROM fnd_application WHERE application_short_name='INV';

   l_context := l_organization_id||'+-?*'||l_item_id||'+-?*'||l_category_id||'+-?*'||l_query_for||'+-?*'
   ||l_lot_number||'+-?*'||l_serial_number||'+-?*'||l_date_context||'+-?*'||l_date_type
   ||'+-?*'||l_user_date_type||'+-?*'||l_date_value||'+-?*'||l_action_code||'+-?*'
   ||l_serial_status||'+-?*'||l_onhand_qty_uom;

   IF l_serial_notifcation OR l_lot_notifcation THEN
      ame_api2.getAllApprovers6 (applicationIdIn => l_application_id,
                            transactionTypeIn => 'oracle.apps.inv.Date.Notification',
--                            transactionIdIn => p_itemkey,
                            transactionIdIn => l_transaction_id,
                            approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                            approversOut => l_approverList2,
                            itemIndexesOut => itemIndexes,
                            itemClassesOut => itemClasses,
                            itemIdsOut => itemIds,
                            itemSourcesOut => itemSources,
                            ruleIndexesOut => ruleIndexes,
                            sourceTypesOut => sourceTypes,
                            ruleIdsOut => l_ruleIds,
                            ruleDescriptionsOut => l_rulenames);

      IF l_approverList2.COUNT > 0 THEN
         FOR i IN l_approverList2.FIRST..l_approverList2.LAST LOOP

            IF l_lot_notifcation THEN

               l_notif_id := WF_NOTIFICATION.SEND
                  (ROLE => l_approverList2(i).name,
                  MSG_TYPE => 'INVDATNT',
                  MSG_NAME => 'INVDATNT_LOT_MSG',
                  CALLBACK => 'INV_LOT_SERIAL_DATE_PKG.GET_MESSAGE_ATTRS',
                  CONTEXT => l_context);
             ELSE

               l_notif_id := WF_NOTIFICATION.SEND
                  (ROLE => l_approverList2(i).name,
                  MSG_TYPE => 'INVDATNT',
                  MSG_NAME => 'INVDATNT_SERIAL_MSG',
                  CALLBACK => 'INV_LOT_SERIAL_DATE_PKG.GET_MESSAGE_ATTRS',
                  CONTEXT => l_context);
             END IF;
         END LOOP;
      END IF;
   END IF;

   --Bug - 4733445. No longer need reference to the following table.
--   DELETE FROM inv_ame_transactions_temp WHERE transaction_id = l_transaction_id;

END send_notification;

PROCEDURE get_message_attrs
(
   command IN VARCHAR2,
   context IN VARCHAR2,
   attr_name IN VARCHAR2,
   attr_type IN VARCHAR2,
   text_value IN OUT NOCOPY VARCHAR2,
   number_value IN OUT NOCOPY NUMBER,
   date_value IN OUT NOCOPY DATE
)
IS
   invalid_callback      EXCEPTION ;
   l_errname               VARCHAR2(30);
   l_errmsg                VARCHAR2(2000);
   l_errstack              VARCHAR2(32000);

BEGIN

   IF command <> 'GET' THEN
      RAISE invalid_callback;
   ELSE
      IF attr_name = 'ORGANIZATION_CODE' THEN
         SELECT organization_code INTO text_value
         FROM mtl_parameters
         WHERE to_char(organization_id) = SUBSTR(context, 1, (INSTR(context, '+-?*', 1, 1)-1)) ;

      ELSIF attr_name = 'ORGANIZATION_ID' THEN
         number_value := to_number(SUBSTR(context, 1, (INSTR(context, '+-?*', 1, 1)-1)));

      ELSIF attr_name = 'ITEM_NUMBER' THEN
         SELECT concatenated_segments INTO text_value
         FROM mtl_system_items_kfv
         WHERE to_char(organization_id) = SUBSTR(context, 1, (INSTR(context, '+-?*', 1, 1)-1))
         AND to_char(inventory_item_id) = SUBSTR(context, (INSTR(context, '+-?*', 1, 1)+4), INSTR(context, '+-?*', 1, 2) - (INSTR(context, '+-?*', 1, 1)+4));

      ELSIF attr_name = 'ITEM_ID' THEN
         number_value := TO_NUMBER(SUBSTR(context, (INSTR(context, '+-?*', 1, 1)+4), INSTR(context, '+-?*', 1, 2) - (INSTR(context, '+-?*', 1, 1)+4)));

      ELSIF attr_name = 'ITEM_CATEGORY' THEN
         SELECT category_concat_segs INTO text_value
         FROM mtl_categories_v
         WHERE to_char(category_id) = SUBSTR(context, (INSTR(context, '+-?*', 1, 2)+4), INSTR(context, '+-?*', 1, 3) - (INSTR(context, '+-?*', 1, 2)+4));

      ELSIF attr_name = 'CATEGORY_ID' THEN
         number_value := TO_NUMBER(SUBSTR(context, (INSTR(context, '+-?*', 1, 2)+4), INSTR(context, '+-?*', 1, 3) - (INSTR(context, '+-?*', 1, 2)+4)));

      ELSIF attr_name = 'QUERY_FOR' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 3)+4), INSTR(context, '+-?*', 1, 4) - (INSTR(context, '+-?*', 1, 3)+4));

      ELSIF attr_name = 'LOT_NUMBER' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 4)+4), INSTR(context, '+-?*', 1, 5) - (INSTR(context, '+-?*', 1, 4)+4));

      ELSIF attr_name = 'SERIAL_NUMBER' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 5)+4), INSTR(context, '+-?*', 1, 6) - (INSTR(context, '+-?*', 1, 5)+4));

      ELSIF attr_name = 'DATE_CONTEXT' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 6)+4), INSTR(context, '+-?*', 1, 7) - (INSTR(context, '+-?*', 1, 6)+4));

      ELSIF attr_name = 'DATE_TYPE' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 7)+4), INSTR(context, '+-?*', 1, 8) - (INSTR(context, '+-?*', 1, 7)+4));

      ELSIF attr_name = 'USER_DATE_TYPE' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 8)+4), INSTR(context, '+-?*', 1, 9) - (INSTR(context, '+-?*', 1, 8)+4));

      ELSIF attr_name = 'DATE_VALUE' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 9)+4), INSTR(context, '+-?*', 1, 10) - (INSTR(context, '+-?*', 1, 9)+4));

      ELSIF attr_name = 'ACTION_CODE' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 10)+4), INSTR(context, '+-?*', 1, 11) - (INSTR(context, '+-?*', 1, 10)+4));

      ELSIF attr_name = 'SERIAL_STATUS' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 11)+4), INSTR(context, '+-?*', 1, 12) - (INSTR(context, '+-?*', 1, 11)+4));

      ELSIF attr_name = 'ONHAND_QTY_UOM' THEN
         text_value := SUBSTR(context, (INSTR(context, '+-?*', 1, 12)+4));

      ELSIF attr_name = '.MAIL_QUERY' THEN
         text_value := NULL;

      ELSE
         RAISE invalid_callback;
      END IF;
   END IF;

EXCEPTION
   WHEN invalid_callback THEN
     WF_CORE.CONTEXT ('inv_lot_serial_date_pkg',
        'get_message_attrs',
         'invalid_callback') ;
     WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);

    WHEN OTHERS THEN
     WF_CORE.CONTEXT ('inv_lot_serial_date_pkg',
        'get_message_attrs',
         'exception : others') ;
     WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);

END get_message_attrs;

END INV_LOT_SERIAL_DATE_PKG;

/
