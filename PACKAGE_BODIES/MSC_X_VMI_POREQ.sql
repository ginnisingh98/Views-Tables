--------------------------------------------------------
--  DDL for Package Body MSC_X_VMI_POREQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_VMI_POREQ" AS
/* $Header: MSCXVMOB.pls 120.17 2007/11/29 09:58:20 hbinjola ship $ */

PURCHASING_BY_REV      CONSTANT INTEGER := 1;
NOT_PURCHASING_BY_REV  CONSTANT INTEGER := 2;
UNDER_REV_CONTROL      CONSTANT INTEGER := 2;
NOT_UNDER_REV_CONTROL  CONSTANT INTEGER := 1;

var_purchasing_by_rev NUMBER := to_number(FND_PROFILE.VALUE('MRP_PURCHASING_BY_REVISION'));
date_format varchar2(80)  := NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY');

-- This procesure prints out message to user

PROCEDURE log_message( p_user_info IN VARCHAR2)
    IS
BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
    -- dbms_output.put_line(p_user_info); --ut
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_message;

PROCEDURE INITIALIZE(  p_user_name        IN  VARCHAR2,
                       p_resp_name        IN  VARCHAR2,
                       p_application_name IN  VARCHAR2 )
IS

    l_user_id         NUMBER;
    l_application_id  NUMBER;
    l_resp_id         NUMBER;

BEGIN

    /* if user_id = -1, it means this procedure is called from a
       remote database */
    /*IF FND_GLOBAL.USER_ID = -1 THEN
*/

     -- Debug snippet start
     log_message('Inside PROCEDURE INITIALIZE');
     log_message('===================================================');

     -- Tracking parameters passed to initialize
     log_message('p_user_name / p_resp_name / p_appliaction_name = '
                   || p_user_name || '/'
                   || p_resp_name || '/'
                   || p_application_name);

     -- Debug snippet end
       BEGIN

          SELECT USER_ID
            INTO l_user_id
            FROM FND_USER
           WHERE USER_NAME = p_user_name;

          SELECT APPLICATION_ID
            INTO l_application_id
            FROM FND_APPLICATION_VL
           WHERE APPLICATION_NAME = p_application_name;

          SELECT responsibility_id
            INTO l_resp_id
            FROM FND_responsibility_vl
           WHERE responsibility_name = p_resp_name
             AND application_Id = l_application_id;

       EXCEPTION

           WHEN NO_DATA_FOUND THEN RAISE;
           WHEN OTHERS THEN RAISE;

       END;

       FND_GLOBAL.APPS_INITIALIZE( l_user_id,
                                   l_resp_id,
                                   l_application_id);

 /*   END IF;*/

      -- Debug snippet start
       log_message('l_user_id / l_resp_id / l_appliaction_id = '
                   || l_user_id || '/'
                   || l_resp_id || '/'
                   || l_application_id);

     -- Debug snippet end
    EXCEPTION

WHEN OTHERS THEN
    RAISE;

END INITIALIZE;


PROCEDURE LD_PO_REQUISITIONS_INTERFACE1 (
                       p_user_name         in varchar2,
                       p_application_name  in varchar2,
                       p_resp_name         in varchar2,
                       p_po_group_by_name  in varchar2,
                       p_instance_id IN NUMBER,
                       p_instance_code IN VARCHAR2,
                       p_dblink IN VARCHAR2,
                       o_request_id        out nocopy number)

is

    TYPE CharTab  IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
    TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;
    TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


    lv_req_count        NUMBER;
    lv_pri_rowid        RIDTab;
    lv_sec_uom_code     CharTab;
    lv_sec_uom_qty      NumTab;

    l_user_id         number;
    l_application_id  number;
    l_resp_id         number;

    l_PO_BATCH_NUMBER     NUMBER;

    lv_sqlstmt        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);
    lv_result         BOOLEAN;
    l_temp            number;
    l_operating_unit  number;
    lv_global_init_sql    VARCHAR2(2000);
    lv_set_org_sql  VARCHAR2(2000);
    l_apps_version   number;
    l_po_application VARCHAR2(2) := 'PO' ;

Cursor c1 is select pvsa.vendor_site_id,pri.rowid
from po_vendor_sites_all pvsa, po_Requisitions_interface_All pri
where pri.suggested_vendor_id = pvsa.vendor_id
and   pri.suggested_vendor_site = pvsa.vendor_site_code
and   pri.org_id = pvsa.org_id
and   pri.interface_source_code = 'MSC';

-- MOAC Changes
Cursor Purchasing_OU is
Select distinct org_id
from PO_REQUISITIONS_INTERFACE_ALL
WHERE  batch_id = l_PO_BATCH_NUMBER;

CURSOR c1_rec is
        SELECT  item_id,
                destination_organization_id,
                rowid
        from    PO_REQUISITIONS_INTERFACE_all
	where   batch_id = l_PO_BATCH_NUMBER;

    var_revision        VARCHAR2(3);
    var_revision_ctrl   NUMBER;

BEGIN

    SELECT mrp_workbench_query_s.nextval
    INTO   l_PO_BATCH_NUMBER
    FROM DUAL;


    SELECT USER_ID
    INTO l_user_id
    FROM FND_USER
    WHERE USER_NAME = p_user_name;


    if (fnd_global.user_id = -1) then
       /* called from a remote database */


       SELECT APPLICATION_ID
       INTO l_application_id
       FROM FND_APPLICATION_VL
       WHERE APPLICATION_NAME = p_application_name;


       SELECT responsibility_id
       INTO l_resp_id
       FROM FND_responsibility_vl
       WHERE responsibility_name = p_resp_name
       AND application_Id = l_application_id;

       FND_GLOBAL.APPS_INITIALIZE( l_user_id, l_resp_id, l_application_id);

    end if;

/*
    select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID
    into lv_dblink,
         lv_instance_id
    from MRP_AP_APPS_INSTANCES;
*/
		log_message('  destination database instance id/code/link = '
				|| p_instance_id
				|| '/' || p_instance_code
				|| '/' || NVL(p_dblink,'NULL_DBLINK')
				);

    BEGIN
      select DECODE( A2M_DBLINK, NULL, ' ','@'||A2M_DBLINK),
            INSTANCE_ID
      into lv_dblink,
            lv_instance_id
      from MRP_AP_APPS_INSTANCES_ALL
      where instance_id                  = p_instance_id
      and  instance_code                = p_instance_code
      and  nvl(a2m_dblink,'NULL_DBLINK')    = nvl(p_dblink,'NULL_DBLINK')
      and ALLOW_RELEASE_FLAG=1;
  	EXCEPTION
  	WHEN OTHERS THEN
		log_message('  DB link set up is not correct: ' || sqlerrm);
    	--RAISE;
  	END;

		log_message('  destination database link/instance id = '
				|| lv_dblink
				|| '/' || lv_instance_id
				);
lv_sqlstmt:=
      'INSERT INTO PO_REQUISITIONS_INTERFACE_ALL'
||'    ( PROJECT_ACCOUNTING_CONTEXT,'
||'      PROJECT_ID,'
||'      TASK_ID,'
||'      NEED_BY_DATE,'
||'      ITEM_ID,'
||'      ITEM_REVISION,'
||'      CHARGE_ACCOUNT_ID,'
||'      AUTHORIZATION_STATUS,'
||'      BATCH_ID,'
||'      GROUP_CODE,'
||'      PREPARER_ID,'
||'      AUTOSOURCE_FLAG,'
||'      SOURCE_ORGANIZATION_ID,'
||'      DESTINATION_ORGANIZATION_ID,'
||'      DELIVER_TO_LOCATION_ID,'
||'      DELIVER_TO_REQUESTOR_ID,'
||'      SUGGESTED_VENDOR_ID,'
||'      SUGGESTED_VENDOR_SITE,'
||'      LAST_UPDATED_BY,'
||'      LAST_UPDATE_DATE,'
||'      LAST_UPDATE_LOGIN,'
||'      CREATION_DATE,'
||'      CREATED_BY,'
||'      INTERFACE_SOURCE_CODE,'
||'      SOURCE_TYPE_CODE,'
||'      DESTINATION_TYPE_CODE,'
||'      QUANTITY,'
||'      UOM_CODE,'
||'      LINE_TYPE_ID,'
||'      ORG_ID,'
||'      VMI_FLAG,'
||'      END_ITEM_UNIT_NUMBER )'
||'   SELECT'
||'      PROJECT_ACCOUNTING_CONTEXT,'
||'      PROJECT_ID,'
||'      TASK_ID,'
||'      NEED_BY_DATE,'
||'      ITEM_ID,'
||'      ITEM_REVISION,'
||'      CHARGE_ACCOUNT_ID,'
||'      AUTHORIZATION_STATUS,'
||       TO_CHAR(l_PO_BATCH_NUMBER)||','
||'      GROUP_CODE,'
||'      PREPARER_ID,'
||'      AUTOSOURCE_FLAG,'
||'      SOURCE_ORGANIZATION_ID,'
||'      DESTINATION_ORGANIZATION_ID,'
||'      DELIVER_TO_LOCATION_ID,'
||'      DELIVER_TO_REQUESTOR_ID,'
||'      SUGGESTED_VENDOR_ID,'
||'      SUGGESTED_VENDOR_SITE,'
||       l_user_id||','
--||'      FND_GLOBAL.USER_ID,'
||'      SYSDATE,'
||'      LAST_UPDATE_LOGIN,'
||'      SYSDATE,'
||       l_user_id||','
--||'      FND_GLOBAL.USER_ID,'
||'      INTERFACE_SOURCE_CODE,'
||'      SOURCE_TYPE_CODE,'
||'      DESTINATION_TYPE_CODE,'
||'      QUANTITY,'
||'      UOM_CODE,'
||'      LINE_TYPE_ID,'
||'      ORG_ID,'
||'      DECODE(VMI_FLAG,1,''Y'',''N''), '
||'      END_ITEM_UNIT_NUMBER'
||'    FROM MSC_PO_REQUISITIONS_INTERFACE'||lv_dblink
||'   WHERE SR_INSTANCE_ID= :lv_instance_id';

   EXECUTE IMMEDIATE lv_sqlstmt
               USING lv_instance_id;

	 log_message('Rows inserted into PO_REQUISITIONS_INTERFACE_all = ' ||  SQL%ROWCOUNT);


  For i in c1
     Loop

     update po_requisitions_interface_all
     set suggested_vendor_site_id = i.vendor_site_id
     where rowid = i.rowid;

  End loop;

  -- fix for 2541517
  -- Populating SECONDARY_UOM_CODE and SECONDARY_QUANTITY in PO_REQUISITIONS_INTERFACE_ALL from MTL_SYSTEM_ITEMS
  BEGIN


   SELECT pri.rowid,
          msi.SECONDARY_UOM_CODE,
          inv_convert.inv_um_convert(pri.ITEM_ID,9,pri.QUANTITY,pri.UOM_CODE,msi.SECONDARY_UOM_CODE,null,null)
     BULK COLLECT
     INTO lv_pri_rowid,
          lv_sec_uom_code,
          lv_sec_uom_qty
     FROM PO_REQUISITIONS_INTERFACE_ALL pri,
          MTL_SYSTEM_ITEMS msi
     WHERE pri.ITEM_ID = msi.INVENTORY_ITEM_ID
       AND pri.DESTINATION_ORGANIZATION_ID = msi.ORGANIZATION_ID
       AND msi.SECONDARY_UOM_CODE is not NULL
       AND pri.batch_id = l_PO_BATCH_NUMBER;

       lv_req_count:= SQL%ROWCOUNT;

   EXCEPTION
      WHEN OTHERS THEN RAISE;
  END;

   IF lv_req_count <> 0 THEN

      FOR j IN 1..lv_req_count LOOP

      UPDATE PO_REQUISITIONS_INTERFACE_ALL pri
       SET  pri.SECONDARY_UOM_CODE = lv_sec_uom_code(j),
            pri.SECONDARY_QUANTITY = lv_sec_uom_qty(j)
       WHERE ROWID= lv_pri_rowid(j);


      END LOOP;
   END IF;

FOR ctemp in c1_rec LOOP

       BEGIN
             SELECT max(rev.revision),
                    max(msi.revision_qty_control_code)
             INTO   var_revision,var_revision_ctrl
             FROM   mtl_system_items_b msi,
                    mtl_item_revisions rev
             WHERE  msi.inventory_item_id = ctemp.item_id
             AND    msi.organization_id = ctemp.destination_organization_id
             AND    rev.inventory_item_id = msi.inventory_item_id
             AND    rev.organization_id = msi.organization_id
	     AND    TRUNC(rev.effectivity_date) =
                            (SELECT TRUNC(max(rev2.effectivity_date))
                             FROM   mtl_item_revisions rev2
                            WHERE   rev2.implementation_date IS NOT NULL
                            AND     rev2.effectivity_date <= TRUNC(SYSDATE)+.99999
                            AND     rev2.organization_id = rev.organization_id
                            AND     rev2.inventory_item_id = rev.inventory_item_id);

      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	      var_revision_ctrl := NOT_UNDER_REV_CONTROL;
	 WHEN OTHERS THEN
	      RAISE;
      END;

     BEGIN

       UPDATE PO_REQUISITIONS_INTERFACE_all
       set    item_revision = DECODE(var_purchasing_by_rev, NULL,
                              DECODE(var_revision_ctrl, NOT_UNDER_REV_CONTROL, NULL, var_revision),
                                     PURCHASING_BY_REV, var_revision,
                                     NOT_PURCHASING_BY_REV, NULL)
       WHERE ROWID = ctemp.rowid;

     EXCEPTION
             WHEN OTHERS THEN
	        RAISE;
     END;

   END LOOP;

 -- MOAC Changes for Purchasing : Bug 4888403

-- Bug 5766003 changes start
Begin

lv_sqlstmt:='select apps_ver from msc_apps_instances'
||lv_dblink
|| ' where instance_id = '||p_instance_id||' and instance_code = '||''''||p_instance_code||'''';

EXECUTE IMMEDIATE lv_sqlstmt INTO l_apps_version;
-- Bug 5766003 changes end

Exception when others then
log_message('Apps version error.'||sqlerrm);
End;

IF ( l_apps_version > 3) THEN
   Begin

   Open Purchasing_OU ;
   LOOP
   Fetch Purchasing_OU into l_operating_unit ;
    log_message('Operating Unit = '||l_operating_unit);
   exit when Purchasing_OU%notfound ;

   Begin

  Begin
  lv_global_init_sql :=
  ' begin MO_GLOBAL.INIT (:po); end; ' ;
  EXECUTE IMMEDIATE lv_global_init_sql USING l_po_application;
  Exception when others then
   log_message('Error while calling MO_GLOBAL'||sqlerrm);
   End ;

   Begin
   lv_set_org_sql :=
    ' begin FND_REQUEST.SET_ORG_ID(:1); end; ' ;
    EXECUTE IMMEDIATE lv_set_org_sql USING l_operating_unit ;
   Exception when others then
   log_message('Error while calling SET_ORG_ID.'||sqlerrm);
   End;

   -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
   lv_result := FND_REQUEST.SET_MODE(TRUE);

   o_request_id := NULL;
   o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'PO',       -- application
                      'REQIMPORT',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      'MSC',
                      l_PO_BATCH_NUMBER,
                      p_po_group_by_name,
                      0);
Exception when no_data_found then
  log_message('No data found.'||sqlerrm);
 when others then
  log_message('Error. '||sqlerrm);
End ;

End Loop ;
Close Purchasing_OU ;
Exception when others then
  log_message('Error '||sqlerrm);
End ;

ELSE      -- Source is Pre-R12

Begin
lv_result := FND_REQUEST.SET_MODE(TRUE);

   o_request_id := NULL;
   o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'PO',       -- application
                      'REQIMPORT',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      'MSC',
                      l_PO_BATCH_NUMBER,
                      p_po_group_by_name,
                      0);

Exception when others then
log_message('Error in pre-R12 code.');
End;

END IF;
END LD_PO_REQUISITIONS_INTERFACE1;



PROCEDURE LD_PO_REQUISITIONS_INTERFACE2 (
                       p_user_name        IN  VARCHAR2,
                       p_po_group_by_name    IN  VARCHAR2)

IS

    l_user_id         NUMBER;

    l_PO_BATCH_NUMBER     NUMBER;

    lv_sqlstmt        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);
    lv_result         BOOLEAN;


Cursor c1 is select pvsa.vendor_site_id,pri.rowid
from po_vendor_sites_all pvsa, po_Requisitions_interface_All pri
where pri.suggested_vendor_id = pvsa.vendor_id
and   pri.suggested_vendor_site = pvsa.vendor_site_code
and   pri.org_id = pvsa.org_id
and   pri.interface_source_code = 'MSC';



BEGIN

    SELECT mrp_workbench_query_s.nextval
    INTO   l_PO_BATCH_NUMBER
    FROM DUAL;


    SELECT USER_ID
    INTO l_user_id
    FROM FND_USER
    WHERE USER_NAME = p_user_name;


    select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID
      into lv_dblink,
           lv_instance_id
      from MRP_AP_APPS_INSTANCES;


lv_sqlstmt:=
      'INSERT INTO PO_REQUISITIONS_INTERFACE_all'
||'    ( PROJECT_ACCOUNTING_CONTEXT,'
||'      PROJECT_ID,'
||'      TASK_ID,'
||'      NEED_BY_DATE,'
||'      ITEM_ID,'
||'      ITEM_REVISION,'
||'      CHARGE_ACCOUNT_ID,'
||'      AUTHORIZATION_STATUS,'
||'      BATCH_ID,'
||'      GROUP_CODE,'
||'      PREPARER_ID,'
||'      AUTOSOURCE_FLAG,'
||'      SOURCE_ORGANIZATION_ID,'
||'      DESTINATION_ORGANIZATION_ID,'
||'      DELIVER_TO_LOCATION_ID,'
||'      DELIVER_TO_REQUESTOR_ID,'
||'      SUGGESTED_VENDOR_ID,'
||'      SUGGESTED_VENDOR_SITE,'
||'      LAST_UPDATED_BY,'
||'      LAST_UPDATE_DATE,'
||'      LAST_UPDATE_LOGIN,'
||'      CREATION_DATE,'
||'      CREATED_BY,'
||'      INTERFACE_SOURCE_CODE,'
||'      SOURCE_TYPE_CODE,'
||'      DESTINATION_TYPE_CODE,'
||'      QUANTITY,'
||'      UOM_CODE,'
||'      LINE_TYPE_ID,'
||'      ORG_ID,'
||'      VMI_FLAG,'
||'      END_ITEM_UNIT_NUMBER )'
||'   SELECT'
||'      PROJECT_ACCOUNTING_CONTEXT,'
||'      PROJECT_ID,'
||'      TASK_ID,'
||'      NEED_BY_DATE,'
||'      ITEM_ID,'
||'      ITEM_REVISION,'
||'      CHARGE_ACCOUNT_ID,'
||'      AUTHORIZATION_STATUS,'
||       TO_CHAR(l_PO_BATCH_NUMBER)||','
||'      GROUP_CODE,'
||'      PREPARER_ID,'
||'      AUTOSOURCE_FLAG,'
||'      SOURCE_ORGANIZATION_ID,'
||'      DESTINATION_ORGANIZATION_ID,'
||'      DELIVER_TO_LOCATION_ID,'
||'      DELIVER_TO_REQUESTOR_ID,'
||'      SUGGESTED_VENDOR_ID,'
||'      SUGGESTED_VENDOR_SITE,'
||       l_user_id||','
--||'      FND_GLOBAL.USER_ID,'
||'      SYSDATE,'
||'      LAST_UPDATE_LOGIN,'
||'      SYSDATE,'
||       l_user_id||','
--||'      FND_GLOBAL.USER_ID,'
||'      INTERFACE_SOURCE_CODE,'
||'      SOURCE_TYPE_CODE,'
||'      DESTINATION_TYPE_CODE,'
||'      QUANTITY,'
||'      UOM_CODE,'
||'      LINE_TYPE_ID,'
||'      ORG_ID,'
||'      DECODE(VMI_FLAG,1,''Y'',''N''), '
||'      END_ITEM_UNIT_NUMBER'
||'    FROM MSC_PO_REQUISITIONS_INTERFACE'||lv_dblink
||'   WHERE SR_INSTANCE_ID= :lv_instance_id';

   EXECUTE IMMEDIATE lv_sqlstmt
               USING lv_instance_id;


  For i in c1
     Loop

     update po_requisitions_interface_all
     set suggested_vendor_site_id = i.vendor_site_id
     where rowid = i.rowid;

  End loop;


END LD_PO_REQUISITIONS_INTERFACE2;

FUNCTION GET_DEF_SUB_INVENTORY( p_org_id          in  number)
RETURN varchar2
IS

lv_sub_inventory   varchar2(10);

begin

select  SECONDARY_INVENTORY_NAME
  into  lv_sub_inventory
  from  MTL_SECONDARY_INVENTORIES
 where  organization_id = p_org_id
   and  trunc(NVL(DISABLE_DATE,sysdate)) >= trunc(SYSDATE)
   and  rownum = 1;

  return lv_sub_inventory;

EXCEPTION
   WHEN OTHERS THEN
    log_message('Failed in getting the Sub Inventory Code : ' || SQLERRM);
     RAISE;
END GET_DEF_SUB_INVENTORY;

FUNCTION GET_TRANSACTION_TYPE_ID( p_oe_transaction_type          in  varchar2)
RETURN NUMBER
IS

lv_transaction_type_id   number;

begin

 select TRANSACTION_TYPE_ID
   into lv_transaction_type_id
   from oe_transaction_types_tl
  where name = p_oe_transaction_type
    and language = userenv('LANG');

  return lv_transaction_type_id;

EXCEPTION
   WHEN OTHERS THEN
    log_message('Failed in getting the lv_transaction_type_id type : ' || SQLERRM);
     RAISE;
END GET_TRANSACTION_TYPE_ID;


FUNCTION GET_ORDER_TYPE_ID( p_cust_id          in  number,
                            p_ship_to_id       in  number
			    )
RETURN NUMBER
IS

lv_order_type_id   number;

begin

 select nvl(hca.order_type_id, hua.order_type_id) order_type_id
   into lv_order_type_id
   from hz_cust_accounts hca,
	hz_cust_acct_sites_all  hsa,
	hz_cust_site_uses_all hua
  where hca.CUST_ACCOUNT_ID = p_cust_id
    and hca.cust_account_id = hsa.CUST_ACCOUNT_ID
    and hua.cust_acct_site_id = hsa.cust_acct_site_id
    and hua.SITE_USE_ID = p_ship_to_id;

  return lv_order_type_id;

EXCEPTION
   WHEN OTHERS THEN
    log_message('Failed in getting the order type : ' || SQLERRM);
     RAISE;
END GET_ORDER_TYPE_ID;

PROCEDURE GET_BLANKET_INFO( p_item_id          in  number,
                              p_cust_id          in  number,
			      p_cust_site_id   in number ,
			      p_ship_from_org_id in number,
			      p_request_date in date ,
			      o_blanket_number   OUT nocopy number,
			      o_currency_code    OUT nocopy varchar2)
IS

cursor c1 is
select  order_number ,  curr, status
FROM
(
SELECT  BH.ORDER_NUMBER order_number,  bh.TRANSACTIONAL_CURR_CODE curr, bh.FLOW_STATUS_CODE status
FROM    OE_BLANKET_LINES BL,OE_BLANKET_HEADERS BH,OE_BLANKET_LINES_EXT BLE,
OE_BLANKET_HEADERS_EXT BHE,MTL_SYSTEM_ITEMS_TL T,OE_LOOKUPS OL
,HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS ACCT
WHERE   BH.HEADER_ID = BL.HEADER_ID
AND     BL.LINE_ID = BLE.LINE_ID
AND     BH.ORDER_NUMBER  = BHE.ORDER_NUMBER
AND     BH.SOLD_TO_ORG_ID = ACCT.CUST_ACCOUNT_ID(+)
AND     PARTY.PARTY_ID(+) = ACCT.PARTY_ID
AND      acct.status(+) = 'A'
AND     trunc(nvl(to_date(p_request_date, date_format), sysdate))
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND     trunc(nvl(BLE.END_DATE_ACTIVE,
              nvl(to_date(p_request_date, date_format), sysdate)))
AND     BHE.ON_HOLD_FLAG = 'N'
AND     T.ORGANIZATION_ID = p_ship_from_org_id
AND     T.LANGUAGE = userenv('LANG')
AND     nvl(BH.draft_submitted_flag,'Y')='Y'
AND     nvl(BH.FLOW_STATUS_CODE,'ACTIVE') = 'ACTIVE'
AND  bh.sold_to_org_id = p_cust_id
and nvl(bl.ship_to_org_id, p_cust_site_id) = p_cust_site_id    -- Bug #4551452
AND nvl(bh.draft_submitted_flag,'Y')='Y'
AND nvl(bh.transaction_phase_code,'F')='F'
and bh.open_flag = 'Y'
and bl.open_flag = 'Y'
AND    ((bl.inventory_item_id = p_item_id
AND     BL.ITEM_IDENTIFIER_TYPE = 'INT' AND BL.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID)
OR        (BL.ITEM_IDENTIFIER_TYPE = 'ALL' AND T.INVENTORY_ITEM_ID = p_item_id))
AND     (OL.Lookup_type = 'ITEM_IDENTIFIER_TYPE' AND OL.Lookup_code = BL.ITEM_IDENTIFIER_TYPE)
UNION ALL
SELECT  BH.ORDER_NUMBER order_number,  bh.TRANSACTIONAL_CURR_CODE curr, bh.FLOW_STATUS_CODE status
FROM    OE_BLANKET_LINES BL, OE_BLANKET_HEADERS BH, OE_BLANKET_LINES_EXT BLE,
        OE_BLANKET_HEADERS_EXT BHE, mtl_customer_items citems
        ,OE_LOOKUPS OL, HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS ACCT
WHERE   BH. HEADER_ID = BL.HEADER_ID
AND     BH.SOLD_TO_ORG_ID = ACCT.CUST_ACCOUNT_ID(+)
AND     PARTY.PARTY_ID(+) = ACCT.PARTY_ID
AND      acct.status(+) = 'A'
AND     trunc(nvl(to_date(p_request_date, date_format), sysdate))
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND     trunc(nvl(BLE.END_DATE_ACTIVE,
             nvl(to_date(p_request_date, date_format), sysdate)))
AND     BHE.ON_HOLD_FLAG = 'N'
and bh.open_flag = 'Y'
and bl.open_flag = 'Y'
AND     nvl(BH.draft_submitted_flag,'Y') = 'Y'
AND     nvl(BH.flow_status_code,'ACTIVE') = 'ACTIVE'
AND  bh.sold_to_org_id = p_cust_id
and nvl(bl.ship_to_org_id, p_cust_site_id) = p_cust_site_id    -- Bug #4551452
AND nvl(bh.draft_submitted_flag,'Y')='Y'
AND nvl(bh.transaction_phase_code,'F')='F'
AND     BL.ITEM_IDENTIFIER_TYPE = 'CUST'
AND     BL.ORDERED_ITEM_ID = citems.customer_item_id
AND     bl.inventory_item_id =  p_item_id
AND     BL.LINE_ID = BLE.LINE_ID
AND     BH.ORDER_NUMBER  = BHE.ORDER_NUMBER
AND     (OL.Lookup_type = 'ITEM_IDENTIFIER_TYPE' AND OL.Lookup_code = BL.ITEM_IDENTIFIER_TYPE)
UNION ALL
SELECT  BH.ORDER_NUMBER order_number,  bh.TRANSACTIONAL_CURR_CODE curr, bh.FLOW_STATUS_CODE status
FROM    OE_BLANKET_LINES BL,OE_BLANKET_HEADERS BH, MTL_CROSS_REFERENCES MCR,
OE_BLANKET_LINES_EXT BLE, OE_BLANKET_HEADERS_EXT BHE
, HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS ACCT
WHERE BH.HEADER_ID = BL.HEADER_ID
AND BH.SOLD_TO_ORG_ID = ACCT.CUST_ACCOUNT_ID(+)
AND PARTY.PARTY_ID(+) = ACCT.PARTY_ID
AND      acct.status(+) = 'A'
AND trunc(nvl(to_date(p_request_date, date_format), sysdate))
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND trunc(nvl(BLE.END_DATE_ACTIVE,
       nvl(to_date(p_request_date, date_format), sysdate)))
AND     BHE.ON_HOLD_FLAG = 'N'
and bh.open_flag = 'Y'
and bl.open_flag = 'Y'
AND  nvl(BH.draft_submitted_flag,'Y') = 'Y'
AND  nvl(BH.flow_status_code,'ACTIVE') = 'ACTIVE'
AND  bh.sold_to_org_id = p_cust_id
and nvl(bl.ship_to_org_id, p_cust_site_id) = p_cust_site_id    -- Bug #4551452
AND nvl(bh.draft_submitted_flag,'Y')='Y'
AND nvl(bh.transaction_phase_code,'F')='F'
AND  (MCR.ORGANIZATION_ID = p_ship_from_org_id
OR    MCR.ORG_INDEPENDENT_FLAG = 'Y')
AND   BL.ITEM_IDENTIFIER_TYPE  NOT IN ('INT','CUST','ALL','CAT')
AND   BL.ITEM_IDENTIFIER_TYPE = MCR.CROSS_REFERENCE_TYPE
AND   MCR.INVENTORY_ITEM_ID = p_item_id
AND   BL.INVENTORY_ITEM_ID = MCR.INVENTORY_ITEM_ID
AND   BL.LINE_ID = BLE.LINE_ID AND BH.ORDER_NUMBER  = BHE.ORDER_NUMBER
UNION ALL
SELECT BH.ORDER_NUMBER order_number,  bh.TRANSACTIONAL_CURR_CODE curr, bh.FLOW_STATUS_CODE status
FROM OE_BLANKET_LINES BL,OE_BLANKET_HEADERS BH, MTL_ITEM_CATEGORIES IC,
     MTL_CATEGORIES C, OE_BLANKET_LINES_EXT BLE,
     OE_BLANKET_HEADERS_EXT BHE, OE_LOOKUPS OL, HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS ACCT
WHERE BH.HEADER_ID = BL.HEADER_ID
AND BH.SOLD_TO_ORG_ID = ACCT.CUST_ACCOUNT_ID(+)
AND PARTY.PARTY_ID(+) = ACCT.PARTY_ID
AND      acct.status(+) = 'A'
AND trunc(nvl(to_date(p_request_date , date_format), sysdate))
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND trunc(nvl(BLE.END_DATE_ACTIVE,
       nvl(to_date(p_request_date , date_format), sysdate)))
AND     BHE.ON_HOLD_FLAG = 'N'
and bh.open_flag = 'Y'
and bl.open_flag = 'Y'
AND    nvl(BH.draft_submitted_flag,'Y') = 'Y'
AND    nvl(BH.flow_status_code,'ACTIVE') = 'ACTIVE'
AND  bh.sold_to_org_id = p_cust_id
and nvl(bl.ship_to_org_id, p_cust_site_id) = p_cust_site_id    -- Bug #4551452
AND nvl(bh.draft_submitted_flag,'Y')='Y'
AND nvl(bh.transaction_phase_code,'F')='F'
AND   BL.ITEM_IDENTIFIER_TYPE = 'CAT'
AND   IC.ORGANIZATION_ID = p_ship_from_org_id
AND   IC.INVENTORY_ITEM_ID = p_item_id
AND   BL.INVENTORY_ITEM_ID = C.CATEGORY_ID
AND   C.CATEGORY_ID = IC.CATEGORY_ID
AND     BL.LINE_ID = BLE.LINE_ID
AND     BH.ORDER_NUMBER  = BHE.ORDER_NUMBER
AND   (OL.Lookup_type = 'ITEM_IDENTIFIER_TYPE' AND OL.Lookup_code = BL.ITEM_IDENTIFIER_TYPE)
) ORDER BY ORDER_NUMBER ;

l_blanket_number  number;
l_currency_code   varchar2(15);
--lv_dummy           number;
hea_status   varchar2(25);

begin

    open c1;
	    loop
	    fetch c1 into l_blanket_number, l_currency_code, hea_status ;

	    exit;

	    end loop;

	      IF (hea_status is NULL ) THEN
                   log_message('ERROR : NO VALID BLANKET SALES AGREEMENT ');
                   log_message(' Please provide a VALID Blanket Agreement else Currency Code cannot be found and SALES ORDER will not be generated. ') ;
              END IF;

    close c1;

    o_blanket_number :=  l_blanket_number;
    o_currency_code := l_currency_code;



EXCEPTION
   WHEN OTHERS THEN
   RAISE;


END GET_BLANKET_INFO;

--MOAC Changes: Function to find Operating Unit : Bug # 4487587

FUNCTION GET_OU(
            p_customer_id IN NUMBER,
	    p_customer_site_id IN NUMBER)
RETURN  NUMBER
IS
l_operating_unit NUMBER ;

BEGIN
SELECT SITE_USES_ALL.ORG_ID  INTO l_operating_unit FROM
       HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
       HZ_CUST_SITE_USES_ALL SITE_USES_ALL,
       HZ_CUST_ACCOUNTS CUST_ACCT,
       HZ_PARTY_SITES PARTY_SITE,
       HZ_LOCATIONS LOC,
       HR_ORGANIZATION_INFORMATION O,
       HR_ALL_ORGANIZATION_UNITS_TL OTL,
       HZ_PARTIES HP
WHERE OTL.ORGANIZATION_ID = SITE_USES_ALL.ORG_ID
AND   O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
AND   O.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
AND   OTL.LANGUAGE = userenv('LANG')
AND   PARTY_SITE.party_site_id =ACCT_SITE.party_site_id
AND   LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
AND   CUST_ACCT.CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID
AND   SITE_USES_ALL.CUST_ACCT_SITE_ID=ACCT_SITE.CUST_ACCT_SITE_ID
AND   HP.PARTY_ID (+) = CUST_ACCT.PARTY_ID
AND   SITE_USES_ALL.ORG_ID is NOT NULL
and   CUST_ACCT.CUST_ACCOUNT_ID = p_customer_id      --SR_TP_ID,
and   SITE_USES_ALL.site_use_id = p_customer_site_id --SR_TP_SITE_ID
;

log_message('Operating Unit : '||l_operating_unit);

return l_operating_unit ;

EXCEPTION
WHEN NO_DATA_FOUND THEN

log_message('ERROR: Cannot find OPERATING UNIT. Sales Order cannot be generated.'||sqlerrm );
 RAISE ;

WHEN TOO_MANY_ROWS THEN

log_message('Error : More than one value of Operating Unit returned. SqlErr: '||sqlerrm);
 RAISE ;

WHEN OTHERS THEN

log_message('Error occured. SqlErr: '||sqlerrm);
 RAISE ;

END GET_OU;


PROCEDURE LD_SO_RELEASE_INTERFACE(
			         p_user_name            IN  VARCHAR2,
			         p_resp_name            IN  VARCHAR2,
			         p_application_name     IN  VARCHAR2,
                                 p_release_id           IN  NUMBER ,
                       p_instance_id IN NUMBER, -- bug 3436758
                       p_instance_code IN VARCHAR2,
                       p_a2m_dblink IN VARCHAR2,
				 o_status               OUT nocopy NUMBER,
				 o_header_id            OUT nocopy NUMBER,
				 o_line_id              OUT nocopy NUMBER,
				 o_sales_order_number   OUT nocopy NUMBER,
				 o_ship_from_org_id     OUT nocopy NUMBER,
				 o_schedule_ship_date   OUT nocopy DATE,
				 o_schedule_arriv_date  OUT nocopy DATE,
				 o_schedule_date_change OUT nocopy NUMBER,
				 o_error_message        OUT nocopy varchar2
				 )
IS

       /* IN variables */
    lv_header_rec            OE_Order_PUB.Header_Rec_Type;
    lv_line_rec              OE_Order_PUB.Line_Rec_Type;
    lv_Line_Tbl_Type         OE_Order_PUB.Line_Tbl_Type;

    lv_action_rec            OE_Order_PUB.Request_Rec_Type;
    lv_action_req_tbl        OE_Order_PUB.Request_Tbl_Type;

       /* API return values */
    lv_return_status     varchar2(10);
    lv_msg_count         number;
    lv_msg_data          varchar2(5000);

       /* OUT variables */
    l_header_rec                    OE_Order_PUB.Header_Rec_Type;
    l_header_val_rec                OE_Order_PUB.Header_Val_Rec_Type;
    l_Header_Adj_tbl                OE_Order_PUB.Header_Adj_Tbl_Type;
    l_Header_Adj_val_tbl            OE_Order_PUB.Header_Adj_Val_Tbl_Type;
    l_Header_price_Att_tbl          OE_Order_PUB.Header_Price_Att_Tbl_Type;
    l_Header_Adj_Att_tbl            OE_Order_PUB.Header_Adj_Att_Tbl_Type;
    l_Header_Adj_Assoc_tbl          OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
    l_Header_Scredit_tbl            OE_Order_PUB.Header_Scredit_Tbl_Type;
    l_Header_Scredit_val_tbl        OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
    l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
    l_line_val_tbl                  OE_Order_PUB.Line_Val_Tbl_Type;
    l_Line_Adj_tbl                  OE_Order_PUB.Line_Adj_Tbl_Type;
    l_Line_Adj_val_tbl              OE_Order_PUB.Line_Adj_Val_Tbl_Type;
    l_Line_price_Att_tbl            OE_Order_PUB.Line_Price_Att_Tbl_Type;
    l_Line_Adj_Att_tbl              OE_Order_PUB.Line_Adj_Att_Tbl_Type;
    l_Line_Adj_Assoc_tbl            OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
    l_Line_Scredit_tbl              OE_Order_PUB.Line_Scredit_Tbl_Type;
    l_Line_Scredit_val_tbl          OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
    l_Lot_Serial_tbl                OE_Order_PUB.Lot_Serial_Tbl_Type;
    l_Lot_Serial_val_tbl            OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
    l_action_request_tbl            OE_Order_PUB.Request_Tbl_Type;

    userid    varchar2(10);

    lv_sqlstmt        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);
    lv_nulldblink         VARCHAR2(128);
    lv_result         BOOLEAN;

    lv_RELEASE_ID        number;
    lv_CUSTOMER_ID       number;
    lv_CUSTOMER_SITE_ID  number;
    lv_ITEM_ID           number;
    lv_QUANTITY          number;
    lv_ACTION            number;
    lv_REQUEST_DATE      date;
    lv_ATP_OVERRIDE      varchar2(1);
    lv_oe_transaction_type varchar2(30);
    lv_ship_from_org_id  number;

    lv_oe_header_id      number;
    lv_oe_line_id        number;

    lv_blanket_number      number;
    lv_currency_code       varchar2(15);

    lv_schedule_arrival_date date;
    lv_schedule_ship_date    date;
    lv_shipping_org          number;

    lv_UOM_code  varchar2(3);
    lv_operating_unit number;
    lv_ORDER_NUMBER    VARCHAR2(240);
    lv_RELEASE_NUMBER  VARCHAR2(20);
    lv_LINE_NUMBER     VARCHAR2(20);
    lv_END_ORDER_NUMBER       VARCHAR2(240);
    lv_END_ORDER_REL_NUMBER   VARCHAR2(20);
    lv_END_ORDER_LINE_NUMBER  VARCHAR2(20);

BEGIN

    INITIALIZE( p_user_name,
		p_resp_name,
		p_application_name);
/* -- bug 3436758
    select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID,
	   A2M_DBLINK
      into lv_dblink,
           lv_instance_id,
	   lv_nulldblink
      from MRP_AP_APPS_INSTANCES;
*/

		log_message('  destination database instance id/code/link = '
				|| p_instance_id
				|| '/' || p_instance_code
				|| '/' || NVL(p_a2m_dblink,'NULL_DBLINK')
				);

    BEGIN
      select DECODE( A2M_DBLINK, NULL, ' ','@'||A2M_DBLINK),
            INSTANCE_ID
			, A2M_DBLINK
      into lv_dblink,
            lv_instance_id
            , lv_nulldblink
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
				|| lv_dblink
				|| '/' || lv_instance_id
				);


lv_sqlstmt:=
'   SELECT'
||'      RELEASE_ID,'
||'      SR_CUSTOMER_ID,'
||'      SR_CUSTOMER_SITE_ID,'
||'      SR_ITEM_ID,'
||'      QUANTITY,'
||'      UOM_CODE,'
||'      ACTION,'
||'      REQUEST_DATE,'
||'      ATP_OVERRIDE,'
||'      OE_TRANSACTION_TYPE,'
||'      OE_HEADER_ID,'
||'      OE_LINE_ID,'
||'      SHIP_FROM_ORG_ID,'
||'      ORDER_NUMBER,'
||'      RELEASE_NUMBER,'
||'      LINE_NUMBER,'
||'      END_ORDER_NUMBER,'
||'      END_ORDER_REL_NUMBER,'
||'      END_ORDER_LINE_NUMBER'
||'    FROM MSC_SO_RELEASE_INTERFACE'||lv_dblink
||'   WHERE SR_INSTANCE_ID= :lv_instance_id'
||'     AND release_id = :p_release_id';

   EXECUTE IMMEDIATE lv_sqlstmt
		into lv_RELEASE_ID        ,
		     lv_CUSTOMER_ID       ,
		     lv_CUSTOMER_SITE_ID  ,
		     lv_ITEM_ID           ,
		     lv_QUANTITY          ,
		     lv_UOM_CODE          ,
		     lv_ACTION            ,
		     lv_REQUEST_DATE      ,
		     lv_ATP_OVERRIDE ,
		     lv_oe_transaction_type,
		     lv_oe_header_id,
		     lv_oe_line_id,
		     lv_ship_from_org_id,
		     lv_ORDER_NUMBER ,
		     lv_RELEASE_NUMBER,
		     lv_LINE_NUMBER   ,
		     lv_END_ORDER_NUMBER,
		     lv_END_ORDER_REL_NUMBER,
		     lv_END_ORDER_LINE_NUMBER
               USING lv_instance_id,
		     p_release_id;

	 log_message('Rows selected into MSC_SO_RELEASE_INTERFACE = ' ||  SQL%ROWCOUNT);

	 lv_header_rec := OE_Order_PUB.G_MISS_HEADER_REC;
	 lv_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;

	   log_message('ACTION : '||lv_ACTION);

  IF (lv_ACTION = G_CREATE) THEN

	  -- MOAC Changes: Bug # 4487587

	lv_operating_unit := GET_OU(lv_CUSTOMER_ID, lv_CUSTOMER_SITE_ID );

	MO_GLOBAL.SET_POLICY_CONTEXT ('S', lv_operating_unit);

	GET_BLANKET_INFO(lv_item_id,
			    lv_CUSTOMER_ID,
			    lv_CUSTOMER_SITE_ID,      -- Bug #4675461
			    lv_ship_from_org_id,
			    lv_REQUEST_DATE,
			    lv_blanket_number,
			    lv_currency_code);

	 log_message('Item_id : '||lv_item_id||' /Blanket_number : '||lv_blanket_number||' /Currency_code : '||lv_currency_code);

	lv_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
	  /* Enter the Sales Orders Header information  */
              log_message('Customer_id : '||lv_CUSTOMER_ID||' /Customer_site_id : '||lv_CUSTOMER_SITE_ID);

		 lv_header_rec.org_id := lv_operating_unit ;    -- MOAC Changes
		 lv_header_rec.sold_to_org_id := lv_CUSTOMER_ID;
		 lv_header_rec.ship_to_org_id := lv_CUSTOMER_SITE_ID;
		 lv_header_rec.transactional_curr_code := lv_currency_code;
		 lv_header_rec.booked_flag := 'Y';

		 --Bug# 4410048 ---Pricing date for header information

		 IF lv_ship_from_org_id is not null then
                      /* for consumption advice in Consigned VMI */
                              lv_header_rec.pricing_date := to_date(lv_REQUEST_DATE, date_format) ;
		 ELSE
                     /* for replenishment S.O in Unconsigned VMI */
		              lv_header_rec.pricing_date := to_date(sysdate, date_format) ;
		 END IF;

                       ---Pricing date for line information

	         IF lv_ship_from_org_id is not null then
                      /* for consumption advice in Consigned VMI */

                         lv_line_rec.pricing_date := to_date(lv_REQUEST_DATE, date_format) ;
			 lv_line_rec.Customer_job := lv_ORDER_NUMBER;
			 lv_line_rec.cust_model_serial_number := lv_LINE_NUMBER ;
			 lv_line_rec.cust_po_number :=   lv_END_ORDER_NUMBER ;
			 lv_line_rec.customer_line_number :=  lv_END_ORDER_LINE_NUMBER ;

		 ELSE
                     /* for replenishment S.O in Unconsigned VMI */
                         lv_line_rec.pricing_date := to_date(sysdate, date_format) ;
	         END IF;

            log_message('Quantity : '||lv_quantity||' /Request_date : '||lv_request_date||' /Oe_transaction_type : '||lv_oe_transaction_type||' /Ship_from_org_id : '||lv_ship_from_org_id);
              log_message('Pricing_date to be provided in Sales Order line = ' ||lv_line_rec.pricing_date);

          /* Enter the Sales Orders Line information */

		 lv_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
		 lv_line_rec.org_id := lv_operating_unit ;    -- MOAC Changes
		 lv_line_rec.inventory_item_id := lv_item_id;
		 lv_line_rec.Blanket_Number  :=  lv_blanket_number;
		 lv_line_rec.ordered_quantity := lv_quantity;
		 lv_line_rec.order_quantity_uom := lv_uom_code;
		 lv_line_rec.request_date := to_date(lv_request_date, date_format);
	         lv_line_rec.booked_flag := 'Y';
		 lv_line_rec.sold_to_org_id := lv_CUSTOMER_ID;
		 lv_line_rec.ship_to_org_id := lv_CUSTOMER_SITE_ID;  -- Bug #4562922

      if (lv_oe_transaction_type is not null) then
          lv_header_rec.order_type_id := GET_TRANSACTION_TYPE_ID(lv_oe_transaction_type);

          lv_line_rec.ship_from_org_id := lv_ship_from_org_id;
	  lv_line_rec.subinventory := GET_DEF_SUB_INVENTORY(lv_ship_from_org_id);
      else
          lv_header_rec.order_type_id := GET_ORDER_TYPE_ID(lv_CUSTOMER_ID,lv_CUSTOMER_SITE_ID);
	  --lv_line_rec.schedule_action_code := 'SCHEDULE';
      end if;

              /* Book the Order  */
	  lv_action_rec.request_type := OE_GLOBALS.G_BOOK_ORDER;
	  lv_action_rec.entity_code := OE_GLOBALS.G_ENTITY_HEADER;
	  lv_line_rec.schedule_action_code := 'SCHEDULE';

  ELSIF (lv_ACTION = G_UPDATE)  then
                   log_message('ACTION = Update : '||lv_ACTION);

		 lv_header_rec.header_id := lv_oe_header_id;
	         lv_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

		 lv_line_rec.line_id := lv_oe_line_id;
		 lv_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
		 lv_line_rec.ordered_quantity := lv_quantity;
		 lv_line_rec.schedule_arrival_date := to_date(lv_request_date, date_format);
		 lv_line_rec.OVERRIDE_ATP_DATE_CODE := lv_ATP_OVERRIDE;
		 lv_line_rec.schedule_action_code := 'SCHEDULE';

  END IF;

	lv_Line_Tbl_Type(1) := lv_line_rec;
	lv_action_req_tbl(1) := lv_action_rec;


        if (lv_nulldblink is not null) then
	  /* need to commit here for distributed databases
	     This is required because ATP closes the dblink
	     and without this ATP scheduling will fail */
	  commit;
        end if;
		log_message('Before calling processs order api');

	 OE_ORDER_GRP.PROCESS_ORDER(
		     p_api_version_number        => 1.0,
		     x_return_status             => lv_return_status,
		     x_msg_count                 => lv_msg_count,
		     x_msg_data                  => lv_msg_data,
	      /* IN variables */
		     p_header_rec                => lv_header_rec,
		     p_line_tbl                  => lv_Line_Tbl_Type,
		     p_action_request_tbl        => lv_action_req_Tbl,
	      /* OUT variables */
		     x_header_rec                => l_header_rec,
		     x_header_val_rec            => l_header_val_rec,
		     x_Header_Adj_tbl            => l_Header_Adj_tbl,
		     x_Header_Adj_val_tbl        => l_Header_Adj_val_tbl,
		     x_Header_price_Att_tbl      => l_Header_price_Att_tbl,
		     x_Header_Adj_Att_tbl        => l_Header_Adj_Att_tbl,
		     x_Header_Adj_Assoc_tbl      => l_Header_Adj_Assoc_tbl,
		     x_Header_Scredit_tbl        => l_Header_Scredit_tbl,
		     x_Header_Scredit_val_tbl    => l_Header_Scredit_val_tbl,
		     x_line_tbl                  => l_Line_Tbl,
		     x_line_val_tbl              => l_line_val_tbl,
		     x_Line_Adj_tbl              => l_Line_Adj_tbl,
		     x_Line_Adj_val_tbl          => l_Line_Adj_val_tbl,
		     x_Line_price_Att_tbl        => l_Line_price_Att_tbl,
		     x_Line_Adj_Att_tbl          => l_Line_Adj_Att_tbl,
		     x_Line_Adj_Assoc_tbl        => l_Line_Adj_Assoc_tbl,
		     x_Line_Scredit_tbl          => l_Line_Scredit_tbl,
		     x_Line_Scredit_val_tbl      => l_Line_Scredit_val_tbl,
		     x_Lot_Serial_tbl            => l_Lot_Serial_tbl,
		     x_Lot_Serial_val_tbl        => l_Lot_Serial_val_tbl,
		     x_action_request_tbl        => l_action_request_tbl
			     );
			  log_message('After calling processs order api');

           o_schedule_date_change := SYS_NO;

	     if (lv_msg_count > 0) then
		for lv_index in 1..lv_msg_count loop
		  lv_msg_data := OE_MSG_PUB.get(p_msg_index => lv_index,
						p_encoded   => 'F');

			log_message(lv_index|| ' :  '|| lv_msg_data);

			o_error_message := o_error_message || lv_index || ': ' ||lv_msg_data ||'  ';
		end loop;
	     end if;

	     if (lv_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  log_message('Successful in loading Sales order.');
		  log_message('Header ID :' ||l_header_rec.header_id);
		  log_message('Order Number:' ||l_header_rec.order_number);
		  log_message('Inv Item ID :' ||l_line_tbl(1).inventory_item_id);
		  log_message('UOM :' ||l_line_tbl(1).order_quantity_uom);
		  log_message('Item Identifier Type  :' ||l_line_tbl(1).item_identifier_type);
		  log_message('Line ID :' ||l_line_tbl(1).line_id);
		  log_message('Ship above: '||l_line_tbl(1).ship_tolerance_above);
		  log_message('Ordered quantity : '||l_line_tbl(1).ordered_quantity);
		  log_message('Request Date :' ||to_char(l_line_tbl(1).request_date, 'DD-MON-YYYY HH24:MI:SS'));
		  log_message('Header Sold_to_org_id : '||l_header_rec.SOLD_TO_ORG_ID);
		  log_message('Line Sold_to_org_id : '||l_line_tbl(1).SOLD_TO_ORG_ID);
		  log_message('Header Ship_to_org_id : '||l_header_rec.SHIP_TO_ORG_ID);
		  log_message('Line Ship_to_org_id : '||l_line_tbl(1).SHIP_TO_ORG_ID);

		  o_header_id := l_header_rec.header_id;
                  o_sales_order_number := l_header_rec.order_number;
		  o_line_id := l_line_tbl(1).line_id;
		  o_ship_from_org_id :=  l_line_tbl(1).ship_from_org_id;
		  o_schedule_ship_date := l_line_tbl(1).schedule_Ship_date;
		  o_schedule_arriv_date := l_line_tbl(1).schedule_arrival_date;
	          o_status := G_SUCCESS;


		  if (lv_oe_transaction_type is null) and (l_line_tbl(1).line_id is not null) then
			    /* only for New Sales orders and not for Cons. Adv sales orders */
			 begin
			    select SCHEDULE_ARRIVAL_DATE, SCHEDULE_SHIP_DATE,ship_from_org_id
			      into lv_schedule_arrival_date,lv_schedule_ship_date,lv_shipping_org
			      from oe_order_lines_all
			     where line_id = l_line_tbl(1).line_id;
			 exception
			   when others then
			     log_message('Error in getting Scheduled Arrival Date');
			     log_message(SQLERRM);
			 end;

			 o_schedule_ship_date := lv_schedule_ship_date;
			 o_schedule_arriv_date := lv_schedule_arrival_date;
			 o_ship_from_org_id := lv_shipping_org;
		         log_message('Ship From Org :' || lv_shipping_org );
		         log_message('Schedule Ship Date :' ||
				  to_char(lv_schedule_ship_date, 'DD-MON-YYYY HH24:MI:SS'));
		         log_message('Schedule Arrival Date :' ||
				  to_char(lv_schedule_arrival_date, 'DD-MON-YYYY HH24:MI:SS'));

			 if (lv_schedule_arrival_date is null) then
			     o_status := G_ERROR;
			     log_message(' Error : Did not get the Schedule Arrival Date ');
			     log_message('Please schedule the Sales order #' || o_sales_order_number);
			 else
			     IF (trunc(lv_schedule_arrival_date) <> trunc(l_line_tbl(1).request_date)) then
				 o_schedule_date_change := SYS_YES;
			     END IF;
		         end if;
		  end if;

	     else
		  o_header_id := l_header_rec.header_id;
                  o_sales_order_number := l_header_rec.order_number;
		  o_line_id := l_line_tbl(1).line_id;
		  log_message('Error  in loading Sales order.');
		  o_status := G_ERROR;
	     end if;

EXCEPTION
  WHEN OTHERS THEN
--   log_message('An error occured in LD_SO_RELEASE_INTERFACE: '||SQLCODE || SQLERRM);

  o_status := G_ERROR;
  o_error_message := o_error_message || SQLERRM;

  log_message(SQLERRM);
  log_message('Error  in loading Sales order.');

END LD_SO_RELEASE_INTERFACE;


PROCEDURE START_RELEASE_PROGRAM(
	      ERRBUF             OUT NOCOPY VARCHAR2,
	      RETCODE            OUT NOCOPY NUMBER,
	      p_user_name        IN  VARCHAR2,
	      p_resp_name        IN  VARCHAR2,
	      p_application_name IN  VARCHAR2,
              pItem_name         IN  VARCHAR2,
	      pCustomer_name     IN  VARCHAR2,
	      pCustomer_site_name IN  VARCHAR2,
              pItemtype          IN  VARCHAR2,
              pItemkey           IN  VARCHAR2,
	      pRelease_Id        IN  NUMBER,
          p_instance_id IN  NUMBER,
          p_instance_code  IN  VARCHAR2,
          p_a2m_dblink IN  VARCHAR2,
	      o_request_id       OUT NOCOPY NUMBER)
IS

lvs_request_id    NUMBER;

BEGIN

    INITIALIZE( p_user_name,
		p_resp_name,
		p_application_name);

lvs_request_id := FND_REQUEST.SUBMIT_REQUEST(
		     'MSC',
		     'MSCXCVR',
		     NULL,  -- description
		     NULL,  -- start date
		     FALSE, -- not a sub request,
		     pItem_name,
		     pCustomer_name,
		     pCustomer_site_name,
		     pItemtype,
		     pItemkey,
		     pRelease_Id,
		     SYS_NO,        ---running on source
          p_instance_id, -- bug 3436758
          p_instance_code,
          p_a2m_dblink
		     );

		--COMMIT;

   o_request_id := lvs_request_id;

   IF lvs_request_id = 0 THEN
	ERRBUF:= FND_MESSAGE.GET;
   END IF;

   RETCODE:= G_SUCCESS;

EXCEPTION
	WHEN OTHERS THEN
		 RETCODE:= G_ERROR;
		 ERRBUF:= ERRBUF ||SQLERRM;
END START_RELEASE_PROGRAM;

PROCEDURE WAIT_FOR_REQUEST(
              p_request_id   IN  NUMBER,
	      p_timeout      IN  NUMBER,
	      o_retcode      OUT NOCOPY NUMBER)
IS

   l_refreshed_flag           NUMBER;
   l_pending_timeout_flag     NUMBER;
   l_start_time               DATE;

   ---------------- used for fnd_concurrent ---------
   l_call_status      boolean;
   l_phase            varchar2(80);
   l_status           varchar2(80);
   l_dev_phase        varchar2(80);
   l_dev_status       varchar2(80);
   l_message          varchar2(240);

   BEGIN

     l_start_time := SYSDATE;

     LOOP

       l_pending_timeout_flag := SIGN( SYSDATE - l_start_time - p_timeout/1440.0);

       l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                              ( p_request_id,
                                10, --- check interval in seconds
                                7200, --max wait-time for request to complete in secs
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

       EXIT WHEN l_call_status=FALSE;

       IF l_dev_phase='PENDING' THEN
             EXIT WHEN l_pending_timeout_flag= 1;

       ELSIF l_dev_phase='COMPLETE' THEN
             IF l_dev_status = 'NORMAL' THEN
                o_retcode:= SYS_YES;
                RETURN;
             END IF;
             EXIT;

       ELSIF l_dev_phase='INACTIVE' THEN
             EXIT WHEN l_pending_timeout_flag= 1;
       END IF;

       DBMS_LOCK.SLEEP(10);

     END LOOP;

     o_retcode:= SYS_NO;
     RETURN;

END WAIT_FOR_REQUEST;

END MSC_X_VMI_POREQ;

/
