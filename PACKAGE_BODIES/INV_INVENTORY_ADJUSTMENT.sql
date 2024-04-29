--------------------------------------------------------
--  DDL for Package Body INV_INVENTORY_ADJUSTMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVENTORY_ADJUSTMENT" AS
/* $Header: INVADJTB.pls 120.0.12010000.6 2010/02/26 20:09:52 musinha noship $ */

g_debug      NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


PROCEDURE send_adjustment   (x_errbuf          OUT  NOCOPY VARCHAR2,
                             x_retcode         OUT  NOCOPY NUMBER,
                             p_deploy_mode IN NUMBER DEFAULT null,
                             p_client_code IN VARCHAR2,
                             p_client      IN VARCHAR2,
                             p_org_id IN NUMBER,
                             p_trx_date_from IN VARCHAR2 DEFAULT null,
                             p_trx_date_to IN VARCHAR2 DEFAULT null,
                             p_trx_type IN VARCHAR2 DEFAULT null,
			     p_xml_doc_id IN NUMBER DEFAULT null) IS

l_wf_item_seq      NUMBER;
l_event_name       VARCHAR2(100);
l_event_key        VARCHAR2(100);
l_parameter_list1 wf_parameter_list_t := wf_parameter_list_t();
l_return_status   VARCHAR2(1);
temp_txn_num      NUMBER := NULL;
xml_doc_id        NUMBER := NULL;
temp_trx_date_from  DATE;
trx_date_from       DATE;
trx_date_to         DATE;
l_txn_type_id       NUMBER;
l_entity_id         NUMBER;
l_dummy             NUMBER := 0;


BEGIN

if (g_debug = 1) then
    inv_trx_util_pub.TRACE('Entering send_adjustment', 'INV_INVENTORY_ADJUSTMENT', 9);
    inv_trx_util_pub.TRACE('p_org_id is '||p_org_id, 'INV_INVENTORY_ADJUSTMENT', 9);
    inv_trx_util_pub.TRACE('p_client_code is '||p_client_code, 'INV_INVENTORY_ADJUSTMENT', 9);
    inv_trx_util_pub.TRACE('p_xml_doc_id is ' ||p_xml_doc_id, 'INV_INVENTORY_ADJUSTMENT', 9);
    inv_trx_util_pub.TRACE('p_trx_type is ' ||p_trx_type, 'INV_INVENTORY_ADJUSTMENT', 9);
end if;


x_errbuf := 'Success';
x_retcode := 0;


IF p_xml_doc_id IS NOT NULL THEN
   xml_doc_id := p_xml_doc_id;
end if;

-- Convert the transaction_type to transaction_type_id
IF p_trx_type IS NOT NULL THEN

  begin
    select transaction_type_id
      into l_txn_type_id
      from mtl_transaction_types
     where transaction_type_name = p_trx_type;
  exception
     when others then
        l_txn_type_id := null;
  end;

END IF;

if (g_debug = 1) then
   inv_trx_util_pub.TRACE('l_txn_type_id is ' || l_txn_type_id, 'INV_INVENTORY_ADJUSTMENT', 9);
end if;

-- trx_date_from := FND_DATE.Canonical_To_Date(p_trx_date_from);
-- trx_date_to := FND_DATE.Canonical_To_Date(p_trx_date_to);


IF (p_trx_date_from IS NULL) or (p_trx_date_to IS NULL) THEN
   if (g_debug = 1) then
      inv_trx_util_pub.TRACE('transaction date range is not provided.', 'INV_INVENTORY_ADJUSTMENT', 9);
   end if;

   x_errbuf := 'Transaction date range is not provided.';
   x_retcode := 2;

   return;
END IF;


trx_date_from := FND_DATE.Canonical_To_Date(p_trx_date_from);
trx_date_to   := FND_DATE.Canonical_To_Date(p_trx_date_to);

trx_date_from := trunc(trx_date_from);
trx_date_to   := trunc(trx_date_to);

if (g_debug = 1) then
    inv_trx_util_pub.TRACE('From Trxn Date is ' ||trx_date_from, 'INV_INVENTORY_ADJUSTMENT', 9);
    inv_trx_util_pub.TRACE('To Trxn Date ' || trx_date_to, 'INV_INVENTORY_ADJUSTMENT', 9);
    inv_trx_util_pub.TRACE('xml_doc_id is '||xml_doc_id, 'INV_INVENTORY_ADJUSTMENT', 9);
end if;


l_event_name  := 'oracle.apps.inv.standalone.adjo';

  select mtl_txns_history_s.nextval
  into l_entity_id
  from dual;


if (g_debug = 1) then
   inv_trx_util_pub.TRACE('l_entity_id is ' || l_entity_id, 'INV_INVENTORY_ADJUSTMENT', 9);
end if;

IF ( p_client_code is not null ) THEN

  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Client code is not null', 'INV_INVENTORY_ADJUSTMENT', 9);
  end if;

  IF (p_xml_doc_id is null) THEN

    if (g_debug = 1) then
       inv_trx_util_pub.TRACE('xml_doc_id is null', 'INV_INVENTORY_ADJUSTMENT', 9);
       inv_trx_util_pub.TRACE('Inserting into mtl_adjustment_sync_temp', 'INV_INVENTORY_ADJUSTMENT', 9);
    end if;

    insert into mtl_adjustment_sync_temp
     (TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     ENTITY_ID)
     select
     TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     WMS_DEPLOY.GET_CLIENT_ITEM(ORGANIZATION_ID,INVENTORY_ITEM_ID) ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     l_entity_id
     from mtl_adj_sync_wrapper_v
     where organization_id =	p_org_id
     AND wms_deploy.get_client_code(inventory_item_id) =  p_client_code
     AND NVL(transaction_extracted, 'N') NOT IN ('Y','P')
     AND transaction_type_id = nvl(l_txn_type_id, transaction_type_id)
     AND transaction_date >= trx_date_from
     AND transaction_date < trx_date_to + 1; -- Added 1 as the input dates are truncated.

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('no of rows inserted: '||SQL%ROWCOUNT, 'INV_INVENTORY_ADJUSTMENT', 9);
     end if;

   ELSE

    if (g_debug = 1) then
       inv_trx_util_pub.TRACE('xml_doc_id is not null', 'INV_INVENTORY_ADJUSTMENT', 9);
       inv_trx_util_pub.TRACE('Inserting into mtl_adjustment_sync_temp', 'INV_INVENTORY_ADJUSTMENT', 9);
    end if;

    insert into mtl_adjustment_sync_temp
     (TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     ENTITY_ID)
     select
     TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     WMS_DEPLOY.GET_CLIENT_ITEM(ORGANIZATION_ID,INVENTORY_ITEM_ID) ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     l_entity_id
     from mtl_adj_sync_wrapper_v
     where organization_id = p_org_id
     AND wms_deploy.get_client_code(inventory_item_id) =  p_client_code
     AND xml_document_id = p_xml_doc_id
     AND NVL(transaction_extracted, 'N') IN ('Y');
     --If xml_document_id is not null then other parameters are irrelevant
     --AND transaction_type_id = nvl(l_txn_type_id, transaction_type_id);
     --AND transaction_date >= trx_date_from
     --AND transaction_date < trx_date_to + 1;

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('no of rows inserted: '||SQL%ROWCOUNT, 'INV_INVENTORY_ADJUSTMENT', 9);
     end if;

   END IF;

ELSE

  if (g_debug = 1) then
     inv_trx_util_pub.TRACE('Client code is null', 'INV_INVENTORY_ADJUSTMENT', 9);
  end if;

  IF (p_xml_doc_id is null) THEN

    if (g_debug = 1) then
       inv_trx_util_pub.TRACE('xml_doc_id is null', 'INV_INVENTORY_ADJUSTMENT', 9);
       inv_trx_util_pub.TRACE('Inserting into mtl_adjustment_sync_temp', 'INV_INVENTORY_ADJUSTMENT', 9);
    end if;

    insert into mtl_adjustment_sync_temp
     (TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     ENTITY_ID)
     select
     TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     WMS_DEPLOY.GET_CLIENT_ITEM(ORGANIZATION_ID,INVENTORY_ITEM_ID) ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     l_entity_id
     from mtl_adj_sync_wrapper_v
     where organization_id =	p_org_id
     AND NVL(transaction_extracted, 'N') NOT	IN ('Y','P')
     AND transaction_type_id = nvl(l_txn_type_id, transaction_type_id)
     AND transaction_date >= trx_date_from
     AND transaction_date < trx_date_to + 1;

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('no of rows inserted: '||SQL%ROWCOUNT, 'INV_INVENTORY_ADJUSTMENT', 9);
     end if;

   ELSE

    if (g_debug = 1) then
       inv_trx_util_pub.TRACE('xml_doc_id is not null', 'INV_INVENTORY_ADJUSTMENT', 9);
       inv_trx_util_pub.TRACE('Inserting into mtl_adjustment_sync_temp', 'INV_INVENTORY_ADJUSTMENT', 9);
    end if;

    insert into mtl_adjustment_sync_temp
     (TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     ENTITY_ID)
     select
     TRANSACTION_NUMBER,
     TRANSACTION_DATE,
     CATEGORY,
     CATEGORY_ID,
     WAREHOUSE,
     ORGANIZATION_ID,
     WMS_DEPLOY.GET_CLIENT_ITEM(ORGANIZATION_ID,INVENTORY_ITEM_ID) ITEM,
     ITEM_DESCRIPTION,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY,
     LOCATOR,
     TRANSFER_WAREHOUSE,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR,
     LPN,
     TRANSFER_LPN,
     CONTENT_LPN,
     TRANSACTION_TYPE,
     TRANSACTION_TYPE_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE,
     CREATION_DATE,
     TRANSACTION_EXTRACTED,
     XML_DOCUMENT_ID,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     PRIMARY_UOM,
     SECONDARY_QUANTITY,
     SECONDARY_UOM,
     l_entity_id
     from mtl_adj_sync_wrapper_v
     where organization_id = p_org_id
     AND xml_document_id = p_xml_doc_id
     AND NVL(transaction_extracted, 'N') IN ('Y');
     --If xml_document_id is not null then other parameters are irrelevant
     --AND transaction_type_id = nvl(l_txn_type_id, transaction_type_id)
     --AND transaction_date >= trx_date_from
     --AND transaction_date < trx_date_to + 1;

     if (g_debug = 1) then
       inv_trx_util_pub.TRACE('no of rows inserted: '||SQL%ROWCOUNT, 'INV_INVENTORY_ADJUSTMENT', 9);
     end if;

   END IF;

END IF;

COMMIT;

IF (xml_doc_id is null) THEN


    if (g_debug = 1) then
       inv_trx_util_pub.TRACE('Updating mmt.transaction_extracted flag to P', 'INV_INVENTORY_ADJUSTMENT', 9);
    end if;

    UPDATE mtl_material_transactions
    SET transaction_extracted = 'P'
    WHERE organization_id = p_org_id
    AND NVL(transaction_extracted, 'N') NOT IN ( 'Y', 'P')
    AND xml_document_id IS NULL
    AND transaction_id IN (select transaction_number
                           from mtl_adjustment_sync_temp
                           where entity_id = l_entity_id);


  COMMIT;


END IF;


      INV_TRANSACTIONS_UTIL2.Send_Document(
          p_entity_id       => l_entity_id,
          p_entity_type     => 'INVADJ',
          p_action_type     => 'A',
          p_document_type   => 'ADJ',
          p_organization_id => p_org_id,
          p_client_code     => p_client_code,
	        p_xml_document_id => xml_doc_id,
          x_return_status   => l_return_status);

      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('Send_Document.l_return_status is ' || l_return_status, 'INV_INVENTORY_ADJUSTMENT', 9);
         inv_trx_util_pub.TRACE('Exiting Send_Document call', 'INV_INVENTORY_ADJUSTMENT', 9);
      end if;

      IF (l_return_status <> rcv_error_pkg.g_ret_sts_success) THEN

        IF (xml_doc_id is null) THEN

           if (g_debug = 1) then
              inv_trx_util_pub.TRACE('send_document failed', 'INV_INVENTORY_ADJUSTMENT', 9);
              inv_trx_util_pub.TRACE('Updating mmt.transaction_extracted flag to null', 'INV_INVENTORY_ADJUSTMENT', 9);
           end if;

           UPDATE mtl_material_transactions
           SET transaction_extracted = null,
               xml_document_id = null
           WHERE organization_id = p_org_id
           AND NVL(transaction_extracted, 'N') = 'P'
           AND xml_document_id IS NULL
           AND transaction_id IN (select transaction_number
                                  from mtl_adjustment_sync_temp
                                  where entity_id = l_entity_id);

        END IF;

        delete_temp_table(l_entity_id);

        COMMIT;

    END IF;


      if (g_debug = 1) then
         inv_trx_util_pub.TRACE('Exit Loop', 'INV_INVENTORY_ADJUSTMENT', 9);
         inv_trx_util_pub.TRACE('Exiting send_adjustment', 'INV_INVENTORY_ADJUSTMENT', 9);
      end if;

COMMIT;

EXCEPTION
    WHEN OTHERS THEN

       if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Exception : '||sqlerrm||' occurred in Send_Adjustment', 'INV_INVENTORY_ADJUSTMENT', 9);
       end if;
       ROLLBACK;

       if(l_entity_id is not null) then
          delete_temp_table(l_entity_id);
       end if;

       x_errbuf := 'Error';
       x_retcode := 2;

 END send_adjustment;

 PROCEDURE delete_temp_table (p_entity_id NUMBER) IS

 BEGIN

    if (p_entity_id is not null) then

       if (g_debug = 1) then
           inv_trx_util_pub.TRACE('deleting the temp table for entity_id: '||p_entity_id, 'INV_INVENTORY_ADJUSTMENT', 9);
       end if;

       delete from mtl_adjustment_sync_temp
       where entity_id = p_entity_id;

       commit;

    end if;

 EXCEPTION

    WHEN OTHERS THEN
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Exception : '||sqlerrm||' occurred in delete_temp_table', 'INV_INVENTORY_ADJUSTMENT', 9);
       end if;
       ROLLBACK;

 END delete_temp_table;

END inv_inventory_adjustment;


/
